using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }


redlight_greenlight := class(creative_device):

    var FinishedPlayerArray : []player = array{}

    var GreenLight : logic = true

    var OldPosAgentMap : [agent]vector3 = map{}

    var NewPosAgentMap : [agent]vector3 = map{}

    @editable
    StartGameTimer : timer_device = timer_device{}

    @editable
    StartGameBarrier : barrier_device = barrier_device{}

    @editable
    EndGameTimer : timer_device = timer_device{}

    @editable
    GreenLightHud : hud_message_device = hud_message_device{}

    @editable
    RedLightHud : hud_message_device = hud_message_device{}

    @editable
    EndGameBarrier : barrier_device = barrier_device{}

    @editable
    MutatorZoneEndGame : mutator_zone_device = mutator_zone_device{}

    @editable
    FinishMutator: mutator_zone_device = mutator_zone_device{}

    @editable
    TimeMin : int = 2

    @editable
    TimeMax : int = 7

    @editable
    RedAudioPlayer : audio_player_device = audio_player_device{}

    @editable
    GreenAudioPlayer : audio_player_device = audio_player_device{}

    @editable
    EndGameDevice : end_game_device = end_game_device{}

    var RandomInt : int = 0

    var GameStarted : logic = false

    OnBegin<override>()<suspends> : void =
        StartGameTimer.SuccessEvent.Subscribe(GameStart)
        EndGameTimer.SuccessEvent.Subscribe(EndGame)
        for (Player: GetPlayspace().GetPlayers(), FC := Player.GetFortCharacter[], NewAgent:= FC.GetAgent[]):
            FinishMutator.AgentEntersEvent.Subscribe(PlayerFinished)

    GameStart(Agent: ?agent): void =
        StartGameBarrier.Disable()
        for (Player: GetPlayspace().GetPlayers(), FC := Player.GetFortCharacter[], NewAgent:= FC.GetAgent[]):
            EndGameBarrier.AddToIgnoreList(NewAgent)
        spawn:
            GameFunctionality()
        Print("Green Light")
        GreenLightHud.Show()
        spawn:
            LightChanger()
    
    LightChanger()<suspends>: void =
        loop:
            set RandomInt = GetRandomInt(TimeMin,TimeMax)
            Sleep(RandomInt * 1.0)
            Print("Red Light")
            RedAudioPlayer.Play()
            RedLightHud.Show()
            Sleep(1.0)
            set GreenLight = false
            spawn:
                GameFunctionality()
            set RandomInt = GetRandomInt(TimeMin,TimeMax)
            Sleep(RandomInt * 1.0)
            set GreenLight = true
            Print("Green Light")
            GreenAudioPlayer.Play()
            GreenLightHud.Show()
            spawn:
                CheckEndGameCondition()

    PlayerFinished(Agent:agent):void =
        EndGameBarrier.RemoveFromIgnoreList(Agent)
        if (Player := player[Agent]):
            set FinishedPlayerArray += array{Player}

    EndGame(Agent: ?agent): void =
        for (Player: GetPlayspace().GetPlayers(), FC := Player.GetFortCharacter[], NewAgent:= FC.GetAgent[]):
            if (MutatorZoneEndGame.IsInVolume[NewAgent]):
                FC.Damage(200.0)
            EndGameDevice.Activate(NewAgent)
                
    GameFunctionality()<suspends>: void =
        loop:
            if (GreenLight?):
                break
            for (Player: GetPlayspace().GetPlayers(), FC := Player.GetFortCharacter[], Agent:= FC.GetAgent[]):
                if (set OldPosAgentMap[Agent] = FC.GetTransform().Translation):
            Sleep(0.5)
            for (Player: GetPlayspace().GetPlayers(), FC := Player.GetFortCharacter[], Agent:= FC.GetAgent[]):
                if (set NewPosAgentMap[Agent] = FC.GetTransform().Translation):
                    CheckDistance(Agent)

    CheckDistance(Agent:agent): void =
        if:
            OldPosAgentMap[Agent] <> NewPosAgentMap[Agent]
            FC := Agent.GetFortCharacter[]
            Player := player[Agent]
            not FinishedPlayerArray.Find[Player]
        then:
            FC.Damage(200.0)
    
    CheckEndGameCondition()<suspends>: void =
        AllPlayers := GetPlayspace().GetPlayers()
        if:
            AllPlayers.Length = FinishedPlayerArray.Length
            FC0 := AllPlayers[0].GetFortCharacter[]
            Agent0 := FC0.GetAgent[]
        then:
            Sleep(3.0)
            EndGameDevice.Activate(Agent0)

    
    


        
