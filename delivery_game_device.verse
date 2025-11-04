
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
delivery_game_device := class(creative_device):

    @editable GameManager : game_manager = game_manager{}
    @editable Button : button_device = button_device{}
    @editable Zone : mutator_zone_device = mutator_zone_device{}
    @editable MapIndicator : map_indicator_device = map_indicator_device{}
    @editable Beacon : beacon_device = beacon_device{}
    @editable Truck : vehicle_spawner_sports_car_device = vehicle_spawner_sports_car_device{}
    @editable HudMessage : hud_message_device = hud_message_device{}
    @editable Switch : switch_device = switch_device{}
    @editable Team : int = 1
    @editable Accolade : accolades_device = accolades_device{}
    @editable Root : creative_prop = creative_prop{}
    @editable PropArray : []creative_prop = array{}

    var CurDeliveryNum: int = 0

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        Beacon.Disable()
        Button.InteractedWithEvent.Subscribe(StartGame)
        Truck.AgentExitsVehicleEvent.Subscribe(EndGame)
        Zone.AgentEntersEvent.Subscribe(OnTriggered)

    StartGame(Agent : agent):void=
        set CurDeliveryNum = 0
        UpdateLoc(Agent)
        MapIndicator.ActivateObjectivePulse(Agent)
        Beacon.Enable()
        # Set switch active for this team only
        TeamCollection := GetPlayspace().GetTeamCollection()
        if (AgentsTeam := TeamCollection.GetTeam[Agent]):
            TeamArray := TeamCollection.GetTeams()
                for (TeamNumber->TeamRef : TeamArray):
                    if (AgentsTeam = TeamRef):
                        if(TeamNumber+1 = Team):
                            Switch.SetState(Agent, true)                

    OnTriggered(Agent : agent):void=
        UpdateLoc(Agent)
        HudMessage.Show(Agent)
        GameManager.AddOrders(3, Agent)
        Accolade.Award(Agent)

    UpdateLoc(Agent : agent):void=
        set CurDeliveryNum += 1
        spawn{UpdateRot(Agent)}
        Index := GetRandomInt(0, PropArray.Length-1)
        if(Prop := PropArray[Index]):
            Pos := Prop.GetTransform()
            Trans := Pos.Translation
            if(Zone.TeleportTo[Pos]){}
            if(MapIndicator.TeleportTo[Pos]){}
            if(Beacon.TeleportTo[Pos]){}
            if(Switch.TeleportTo[vector3{X:=Trans.X, Y:=Trans.Y, Z:=Trans.Z+500.0}, IdentityRotation()]){}

    EndGame(Agent : agent):void=
        # Only end game if the exiting agent is this team
        TeamCollection := GetPlayspace().GetTeamCollection()
        if (AgentsTeam := TeamCollection.GetTeam[Agent]):
            TeamArray := TeamCollection.GetTeams()
                for (TeamNumber->TeamRef : TeamArray):
                    if (AgentsTeam = TeamRef):
                        if(TeamNumber+1 = Team):
                            set CurDeliveryNum = 0
                            MapIndicator.DeactivateObjectivePulse(Agent)
                            Beacon.Disable()
                            # Set switch off for this team only
                            Switch.SetState(Agent, false)               
                            Pos := Root.GetTransform()
                            if(Zone.TeleportTo[Pos]){}
                            if(MapIndicator.TeleportTo[Pos]){}
                            if(Beacon.TeleportTo[Pos]){}
                            if(Switch.TeleportTo[Pos]){}

    RaceCompleted(Agent : agent):void=
        GameManager.AddOrders(10, Agent);


    UpdateRot(Agent : agent)<suspends>:void=
        ThisNum := CurDeliveryNum
        loop:
            Sleep(0.01)
            if(ThisNum <> CurDeliveryNum):
                break
            TeamCollection := GetPlayspace().GetTeamCollection()
            if (AgentsTeam := TeamCollection.GetTeam[Agent]):
                TeamArray := TeamCollection.GetTeams()
                for (TeamNumber->TeamRef : TeamArray):
                    if (AgentsTeam = TeamRef):
                        if(TeamNumber+1 = Team):
                            Switch.SetState(Agent, true)               
                            # Set rotation to face the player
                            if(FortCharacter := Agent.GetFortCharacter[]):
                                CharacterTranslation := FortCharacter.GetTransform().Translation
                                SwitchTranslation := Switch.GetTransform().Translation

                                if(LookDirection := (CharacterTranslation - SwitchTranslation).MakeUnitVector[]):
                                    Yaw := RadiansToDegrees(ArcTan(LookDirection.Y, LookDirection.X)) - 90.0
                                    Pitch := 0.0
                                    Roll := 90.0

                                    Dist := Distance(CharacterTranslation, SwitchTranslation)
                                    NewScale := Max(Dist/1000.0, 2.0)

                                    NewRotation := MakeRotationFromYawPitchRollDegrees(Yaw, Pitch, Roll)
                                    NewTransform := transform{Translation := SwitchTranslation, Rotation := NewRotation, Scale := vector3{X:=NewScale,Y:=NewScale,Z:=NewScale}}
                                    Switch.MoveTo(NewTransform, 0.01)