using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation }



CustomHand := class<concrete>():
    @editable HandCinematic : cinematic_sequence_device = cinematic_sequence_device{}
    @editable HandVFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    var IsAssigned : logic = false


Custom_Hand_Player := class():
    Player : player
    CurrentHand : CustomHand


SlapController := class(creative_device):
    DebugDraw : debug_draw = debug_draw{}
    @editable CustomHands : []CustomHand = array{}
    var PlayerHandsMap : [player]Custom_Hand_Player = map{}
    @editable InputTriggerDevice : input_trigger_device = input_trigger_device{}
    @editable PlayerisSlapperTrigger : trigger_device = trigger_device{}
    @editable PushPlayerMovementModulator : movement_modulator_device = movement_modulator_device{}


    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers()):
            Initialize(Player)
        GetPlayspace().PlayerAddedEvent().Subscribe(Initialize)
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerRemoved)
        InputTriggerDevice.PressedEvent.Subscribe(OnInputPressed)

    OnPlayerRemoved(Player : player) : void=
        if(CHP := PlayerHandsMap[Player]):
            set CHP.CurrentHand.IsAssigned = false

    Initialize(Player : player) : void=
        for(CH : CustomHands):
            if(CH.IsAssigned = false):
                if:
                    not PlayerHandsMap[Player]
                then:
                    if(set PlayerHandsMap[Player] = Custom_Hand_Player{Player := Player , CurrentHand := CH}){}
                    set CH.IsAssigned = true
                    CH.HandVFX.Pickup(Player)

    OnInputPressed(Agent : agent) : void=
        if(CHP := PlayerHandsMap[Agent]):
            CHP.CurrentHand.HandCinematic.Play()
            spawn{HandleSlapFunction(CHP.Player)}

    HandleSlapFunction(Player : player)<suspends> : void=
        Sleep(0.5)
        if(FC := Player.GetFortCharacter[]):
            PlayerPos := FC.GetTransform().Translation
            PlayerRot := FC.GetViewRotation()
            PlayerForward := PlayerRot.GetLocalForward()
            Dimensions := vector3{X := 200.0, Y:= 300.0, Z:= 300.0}
            CenterPoint := (PlayerForward * (0.5 * Dimensions.X)) + PlayerPos
            NewExtent := vector3{X := (100.0), Y:= 300.0, Z:= 300.0}
            DebugDraw.DrawBox(CenterPoint , PlayerRot , ?Extent := NewExtent , ?Duration := 0.5)

            
            for(OtherPlayer : GetPlayspace().GetPlayers()):
                if(not OtherPlayer = Player):
                    if(OtherFC := OtherPlayer.GetFortCharacter[]):
                        OtherPos := OtherFC.GetTransform().Translation
                        IsPlayerInBox := IsInBox(OtherPos, CenterPoint , NewExtent)
                        if(IsPlayerInBox?):
                            PlayerisSlapperTrigger.Trigger(OtherPlayer)
                            NewRotation := GetRotationToLocation(PlayerPos, OtherPos)
                            PushPlayerMovementModulator.TeleportTo[PushPlayerMovementModulator.GetTransform().Translation , NewRotation] or Print("Teleport Failed")
                            PushPlayerMovementModulator.Activate(OtherPlayer)



    GetRotationToLocation(RotatedLocation : vector3 , LocationToRotateTo : vector3) : rotation=
        if(LookDirection := (LocationToRotateTo - RotatedLocation).MakeUnitVector[]):
            Yaw := RadiansToDegrees(ArcTan(LookDirection.Y, LookDirection.X))
            Pitch := 0.0
            Roll := 0.0
            NewRotation := MakeRotationFromYawPitchRollDegrees(Yaw, Pitch, Roll)
            return NewRotation
        return rotation{}

    IsInBox(Point : vector3, Center : vector3 , Extent : vector3) : logic=
        if:
            Point.X >= Center.X - Extent.X and Point.X <= Center.X + Extent.X
            Point.Y >= Center.Y - Extent.Y and Point.Y <= Center.Y + Extent.Y
            Point.Z >= Center.Z - Extent.Z and Point.Z <= Center.Z + Extent.Z
        then:
            return true
        return false
















