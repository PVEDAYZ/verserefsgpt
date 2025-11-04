
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }
using { /Verse.org/Random }
using { /Fortnite.com/UI }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
Boss_Manager := class(creative_device):

    @editable BossTimer : timer_device = timer_device{}
    @editable Mutator : mutator_zone_device = mutator_zone_device{}
    @editable PropManipulator : prop_manipulator_device = prop_manipulator_device{}
    @editable BossProp : creative_prop = creative_prop{}

    @editable RunCinematic : cinematic_sequence_device = cinematic_sequence_device{}
    @editable StompCinematic : cinematic_sequence_device = cinematic_sequence_device{}
    @editable ArenaCinematic : cinematic_sequence_device = cinematic_sequence_device{}

    @editable SummonCinematic : cinematic_sequence_device = cinematic_sequence_device{}
    @editable PlayerCinematics : []cinematic_sequence_device = array{}
    @editable PlayerDamages : []damage_volume_device = array{}

    var BossHealth : float = 5000.0

    BossFightEndedEvent : event() = event(){}
    
    var PlayersInFight : []player = array{}

    var BossInitialPosition : vector3 = vector3{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        BossTimer.Start()
        BossTimer.SuccessEvent.Subscribe(StartBossFight)
        PropManipulator.DamagedEvent.Subscribe(DamageBoss)

        set BossInitialPosition = BossProp.GetTransform().Translation


    DamageBoss(Agent : agent) : void=
        set BossHealth -= 50.0


    StartBossFight(MaybeAgent : ?agent) : void=
        
        for(Player:GetPlayspace().GetPlayers()):
            if(Mutator.IsInVolume[Player]):
                set PlayersInFight += array{Player}


        for(Player : PlayersInFight):
            Initiate(Player)
            spawn{TrackPlayersElimination(Player)}

        spawn:
            TrackBossFight()


        spawn:
            BossFightAttacks()

    BossFightAttacks()<suspends> : void=
        race:
            block:
                BossFightEndedEvent.Await()

            block:
                loop:
                    Sleep(0.0)
                    RandomAttack := GetRandomInt(0,2)

                    if(RandomAttack = 0):
                        for(AttackLoop := 0..9):
                            RunCinematic.Play()
                            if(Target := FindNearestTargetProp[BossProp]):
                                BossPos := BossProp.GetTransform().Translation
                                TargetPos := Target.GetTransform().Translation
                                RotationToLook := GetRotationToLocation(BossPos , TargetPos)

                                DistanceToTarget := Distance(BossPos,TargetPos) - 300.0
                                Time := (DistanceToTarget / 700.0) / 5.0

                                if(LineFacingTarget := (TargetPos - BossPos).MakeUnitVector[]):
                                    NewPos := BossPos + LineFacingTarget * (DistanceToTarget / 5.0)
                                    BossProp.MoveTo(vector3{X:= NewPos.X, Y:= NewPos.Y , Z:= 0.0} , RotationToLook, Time)

                                    NewDistanceToTarget := Distance(BossPos,TargetPos)
                                    if(NewDistanceToTarget < 500.0):
                                        RunCinematic.Stop()
                                        StompCinematic.Play()
                                        Sleep(2.0)

                    else if(RandomAttack = 1):
                        RunCinematic.Stop()
                        SummonCinematic.Play()
                        Sleep(1.3)
                        for(idx -> Player : PlayersInFight , FC := Player.GetFortCharacter[]):
                            if:
                                PlayersDamager := PlayerDamages[idx]
                                PlayersCin := PlayerCinematics[idx]
                            then:
                                if(PlayersDamager.TeleportTo[FC.GetTransform()]){}
                                PlayersCin.Play()
                        Sleep(1.5)
                        for(Damage : PlayerDamages):
                            if(Damage.TeleportTo[vector3{X:= 10000.0,Y:=10000.0,Z:=-10000.0} , rotation{}]){}
                                

                    else if(RandomAttack = 2):
                        RunCinematic.Stop()
                        ArenaCinematic.Play()
                        Sleep(8.0)



    FindNearestTargetProp(FromProp : creative_prop)<transacts><decides> : fort_character =
        var MaybeTarget : ?fort_character = false
        var NearestLocation : float = 1000000.0
        
        for (AP : PlayersInFight, Target := AP.GetFortCharacter[]):
            if (DistancePlayerToTarget := Distance(Target.GetTransform().Translation, FromProp.GetTransform().Translation) < NearestLocation):
                set MaybeTarget = option{Target}
                set NearestLocation = DistancePlayerToTarget
        return MaybeTarget?

    GetRotationToLocation(RotatedLocation : vector3 , LocationToRotateTo : vector3) : rotation=
        if(LookDirection := (LocationToRotateTo - RotatedLocation).MakeUnitVector[]):
            Yaw := RadiansToDegrees(ArcTan(LookDirection.Y, LookDirection.X))
            Pitch := 0.0
            Roll := 0.0
            NewRotation := MakeRotationFromYawPitchRollDegrees(Yaw, Pitch, Roll).ApplyYaw(-1.57)
            return NewRotation
        return rotation{}



            


    TrackBossFight()<suspends> : void=
        DidPlayersWin := race:
            block:
                loop:
                    Sleep(0.0)
                    if(PlayersInFight.Length <= 0):
                        BossFightEndedEvent.Signal()
                        break
                false
            block:
                loop:
                    Sleep(0.0)
                    if(BossHealth <= 0.0):
                        BossFightEndedEvent.Signal()
                        break
                true

        
        
        if(DidPlayersWin?):
            if(BossProp.TeleportTo[BossInitialPosition - vector3{Z:= 5000.0} , BossProp.GetTransform().Rotation]){}
            Print("Win")
        else:
            Print("Lose")


        Sleep(10.0)
        ResetBoss()


    ResetBoss()<suspends> : void=
        if(BossProp.TeleportTo[BossInitialPosition, BossProp.GetTransform().Rotation]){}
        set BossHealth = 5000.0
        set PlayersInFight = array{}
        BossTimer.Start()


    TrackPlayersElimination(Player : player)<suspends> : void=
        if(FC := Player.GetFortCharacter[]):
            FC.EliminatedEvent().Await()
            if(NewArray := PlayersInFight.RemoveFirstElement[Player]):
                set PlayersInFight = NewArray
        


    StringToMessage<localizes>(String : string) : message = "{String}"
    
    Initiate(Agent : agent) : void=
        var HealthStackBox : stack_box = stack_box{Orientation := orientation.Horizontal}
        var HealthFiller : color_block = color_block{DefaultOpacity := 0.0}
        var HealthBackgroundBar : color_block = color_block{DefaultColor := Black , DefaultOpacity := 0.5}
        var HealthBar : color_block = color_block{DefaultColor := Green , DefaultOpacity := 1.0}

        var HealthText : text_block = text_block{DefaultJustification := text_justification.Center}
        var NameText : text_block = text_block{DefaultJustification := text_justification.Center}

        NameText.SetText(StringToMessage("Gobla the Golem"))


        HealthStackBox.AddWidget(
            stack_box_slot:
                Widget := HealthBar
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment := vertical_alignment.Fill
                Distribution := option{1.0}
        )
        HealthStackBox.AddWidget(
            stack_box_slot:
                Widget := HealthFiller
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment := vertical_alignment.Fill
        )


        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            NewCanvas := canvas:
                Slots := array:
                    canvas_slot:
                        Widget := HealthBackgroundBar
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.0} , Maximum := vector2{X:=0.5, Y:= 0.0}}
                        Offsets := margin{Left := 0.0, Top := 150.0, Right := 1400.0, Bottom := 80.0}
                        Alignment := vector2{X:= 0.5, Y:= 0.5}
                        ZOrder := 0
                        SizeToContent := false
                    canvas_slot:
                        Widget := HealthStackBox
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.0} , Maximum := vector2{X:=0.5, Y:= 0.0}}
                        Offsets := margin{Left := 0.0, Top := 150.0, Right := 1400.0, Bottom := 80.0}
                        Alignment := vector2{X:= 0.5, Y:= 0.5}
                        ZOrder := 1
                        SizeToContent := false

                    canvas_slot:
                        Widget := HealthText
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.0} , Maximum := vector2{X:=0.5, Y:= 0.0}}
                        Offsets := margin{Left := 0.0, Top := 150.0, Right := 165.0, Bottom := 40.0}
                        Alignment := vector2{X:= 0.5, Y:= 0.5}
                        ZOrder := 1
                        SizeToContent := false

                    canvas_slot:
                        Widget := NameText
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.0} , Maximum := vector2{X:=0.5, Y:= 0.0}}
                        Offsets := margin{Left := 0.0, Top := 75.0, Right := 165.0, Bottom := 40.0}
                        Alignment := vector2{X:= 0.5, Y:= 0.5}
                        ZOrder := 1
                        SizeToContent := false
            

            PlayerUI.AddWidget(NewCanvas)
            spawn:
                TrackPlayerHealth(Agent, NewCanvas, HealthFiller , HealthText)


    TrackPlayerHealth(Agent : agent, Canvas : canvas, HPFiller : color_block, HealthText : text_block)<suspends> : void=
        if(FC := Agent.GetFortCharacter[]):

            race:
                block:
                    loop:
                        LeavingPlayer := GetPlayspace().PlayerRemovedEvent().Await()
                        if(LeavingPlayer = Agent):
                            break

                block:
                    BossFightEndedEvent.Await()
                    if(Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
                        PlayerUI.RemoveWidget(Canvas)
                    return
                    
                        
                loop:
                    Sleep(0.0)
                    HealthPercentage := BossHealth / 5000.0
                    NewHPXValue := 1400.0 - (1400.0 * HealthPercentage)
                    HPFiller.SetDesiredSize(vector2{X:= NewHPXValue , Y:= 0.0})

                    if(BossHealthInt := Int[BossHealth]):
                        HealthText.SetText(StringToMessage("{BossHealthInt}/{5000.0}"))
                 