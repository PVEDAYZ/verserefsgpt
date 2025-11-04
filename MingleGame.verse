
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /Fortnite.com/Characters }
using { /Fortnite.com/FortPlayerUtilities }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /UnrealEngine.com/Temporary/UI }


# A Verse-authored creative device that can be placed in a level
minglegame := class(creative_device):

    @editable PlayerCounters : []player_counter_device = array{}
    @editable MutatorZones : []mutator_zone_device = array{}
    @editable GameTimer : timer_device = timer_device{}
    @editable Teleporter : teleporter_device = teleporter_device{}
    @editable TimerTime : float = 30.0
    @editable BetweenRoundsTime : float = 10.0
    @editable Locks : []lock_device = array{}
    @editable var Platform : creative_prop = creative_prop{}
    @editable RandomPlayerMin : int = 2
    @editable RandomPlayerMax : int = 5
    @editable EndGameDevice : end_game_device = end_game_device{}
    var RoomTargetCount : int = 0
    var _textWiget: text_block = text_block{DefaultTextColor:= color{R:=1.0, G:=1.0, B:=1.0}}
    @editable PlatformManipulator : prop_manipulator_device = prop_manipulator_device {}
    @editable BeginSequenceDevice : cinematic_sequence_device = cinematic_sequence_device{}
    @editable SpinningSequenceDevice : cinematic_sequence_device = cinematic_sequence_device{}
    @editable SoundDevices : []audio_player_device = array{}
    @editable Accolades : accolades_device = accolades_device{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        BeginSequenceDevice.StoppedEvent.Subscribe(AfterSequence)

    AfterSequence():void =
        TeleportToStart()
        spawn:
            BetweenRounds() 

        var players:[]player = Self.GetPlayspace().GetPlayers()
        if (ValidPlayer := players[0]):
            AddUIToPlayer(ValidPlayer)


    TimerFinished(Agent : ?agent):void =
        Print("Timer Finished")
        spawn:
            CheckRooms()

    TeleportToStart(): void =
        Playspace := GetPlayspace()
        AllPlayers := Playspace.GetPlayers()
        Transform := Teleporter.GetTransform()
        for (Player : AllPlayers, FC := Player.GetFortCharacter[], Agent:= FC.GetAgent[]):
            Teleporter.Teleport(Agent)

    StartTimer()<suspends>:void =
        GameTimer.Start()
        Sleep(TimerTime)
        CheckRooms()
        GameTimer.Reset()

    CheckRooms()<suspends>:void =
        Playspace := GetPlayspace()
        AllPlayers := Playspace.GetPlayers()

        for (Lock : Locks):
            if(Player:=AllPlayers[0], FC:= Player.GetFortCharacter[], NewAgent:= FC.GetAgent[]):
                Lock.Close(NewAgent)
                Lock.Lock(NewAgent)
                Print("Lock Locked")
        for (Counter : PlayerCounters):
            if (Counter.GetCount() <> RoomTargetCount):
                Print("Not Enough Players in a counter")
                for (Player : AllPlayers, FC:=Player.GetFortCharacter[],NewAgent := FC.GetAgent[] ):
                    if (Counter.IsCounted[NewAgent]):
                        FC.Damage(200.0)
                    for (MutatorZone : MutatorZones):
                        if (MutatorZone.IsInVolume[NewAgent]):
                            FC.Damage(200.0)
        Sleep(3.0)
        UpdateUINothing()
        PlatformManipulator.ShowProps()
        spawn:
            BetweenRounds()
        

    BetweenRounds()<suspends>:void =
        Playspace := GetPlayspace()
        AllPlayers := Playspace.GetPlayers()
        set RoomTargetCount = GetRandomInt(RandomPlayerMin, RandomPlayerMax)
        if:
            GetPlayspace().GetPlayers().Length <= RoomTargetCount
            AllPlayersNew := GetPlayspace().GetPlayers()
            FC0 := AllPlayersNew[0].GetFortCharacter[]
            Agent0 := FC0.GetAgent[]
        then:
            for (Player : GetPlayspace().GetPlayers(), FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
                Accolades.Award(Agent)
            EndGameDevice.Activate(Agent0)

        TeleportToStart()
        for (Lock : Locks):
            if(Player:=AllPlayers[0], FC:= Player.GetFortCharacter[], NewAgent:= FC.GetAgent[]):
                Lock.Close(NewAgent)
                Lock.Unlock(NewAgent)
                Print("Lock unLocked")
        spawn:
            RotatePlatform(Platform)
        PlaySound(RoomTargetCount)
        SpinningSequenceDevice.Play()
        Sleep(BetweenRoundsTime)
        spawn:
            StartTimer()

        Print("The target count is {RoomTargetCount}")
        UpdateUI()
        PlatformManipulator.HideProps()

    PlaySound(Integer : int): void =
        Index := Integer - 2
        if (SoundDevice := SoundDevices[Index]):
            SoundDevice.Play()

    RotatePlatform(Prop : creative_prop)<suspends>:void =
         
        Transform := Prop.GetTransform()
        Position:= Transform.Translation
        Rotation := Transform.Rotation
        NewRotation := Rotation.ApplyYaw(180.0)
        Prop.MoveTo(Position, NewRotation, 10.0)

    AddUIToPlayer(Player:agent):void=
        if (PlayerUI := GetPlayerUI[player[Player]]):
            PlayerUI.AddWidget(CreateUI())

    CreateUI() : canvas =        
        UpdateUINothing()
        # align top center of screen
        ui : canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.0}, Maximum := vector2{X := 0.5, Y := 0.0} }
                    Offsets := margin{Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.0}
                    SizeToContent := true
                    Widget := _textWiget

        return ui

    UpdateUI():void=
        _textWiget.SetText(SetDynamicText(RoomTargetCount))

    SetDynamicText<localizes>(IntValue:int) : message = "You need {IntValue} players in each room!"

    UpdateUINothing():void=
        _textWiget.SetText(SetDynamicTextNothing())

    SetDynamicTextNothing<localizes>() : message = ""




        




                
            



  
        