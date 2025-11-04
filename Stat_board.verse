using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/Diagnostics }

Stat_Board := class(creative_device):

    @editable KillTracker : tracker_device = tracker_device{}
    @editable DeathTracker : tracker_device = tracker_device{}
    @editable KillstreakTracker : tracker_device = tracker_device{}
    @editable KDTracker : tracker_device = tracker_device{}
    @editable RoundPlayedTracker : tracker_device = tracker_device{}
    @editable RoundWinTracker : tracker_device = tracker_device{}
    @editable DisplayStatsButton : button_device = button_device{}
    @editable BillboardStats : billboard_device = billboard_device{}
    var AgentList : []agent = array{}
    var AgentMap : [agent]cancelable = map{}

    OnBegin<override>()<suspends>:void=
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeftServer)
        for(Player: GetPlayspace().GetPlayers()):
            spawn{InitPlayer(Player)}
        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerSpawned)
        DisplayStatsButton.InteractedWithEvent.Subscribe(UpdateBillboard1)

    OnPlayerSpawned(Player : player):void=
        if (FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
            spawn{InitPlayer(Agent)}

    InitPlayer(Agent : agent)<suspends>:void=
        if (not AgentMap[Agent]):
            if:
                FortChar := Agent.GetFortCharacter[]
            then:
                ElimEventCancelable := FortChar.EliminatedEvent().Subscribe(PlayerEliminated)

    OnPlayerLeftServer(PlayerLeaving : player):void=
        if (DeathCancelable := AgentMap[PlayerLeaving]):
            var NewAgentMap : [agent]cancelable = map{}

            for (Player -> Value : AgentMap, Player <> PlayerLeaving):
                set NewAgentMap = ConcatenateMaps(NewAgentMap, map{Player => Value})
            set AgentMap = NewAgentMap
            DeathCancelable.Cancel()

    PlayerEliminated(EliminationResult : elimination_result):void=
        if:
            EliminatingFortChar := EliminationResult.EliminatingCharacter?
            EliminatedFortChar := EliminationResult.EliminatedCharacter
            EliminatingFortChar <> EliminatedFortChar
            EliminatingAgent := EliminatingFortChar.GetAgent[]
            EliminatedAgent := EliminatedFortChar.GetAgent[]
        then:
            KillTracker.Increment(EliminatingAgent)
            KillstreakTracker.Increment(EliminatingAgent)
            DeathTracker.Increment(EliminatedAgent)
            KillstreakTracker.Reset(EliminatedAgent)

    StringToMessage<localizes>(String : string) : message = "{String}"

    PlayerBillboardText<localizes>(Kills : int, Deaths : int, Killstreak : int, KD : float, RoundPlayed : int, RoundWin : int, WinP : float) : message=
        "Kills {Kills}\nDeaths {Deaths}\nKillstreak {Killstreak}\nKD {KD}\nRounds Played {RoundPlayed}\nRounds Won {RoundWin}\nWin {WinP}%\n"

    UpdateBillboard1(Agent : agent):void=
        UpdateBillboard(BillboardStats, Agent)

    UpdateBillboard(Billboard : billboard_device, Agent : agent):void=
        Print("Computing stats")
        var KD : float = 0.0
        var WinP : float = 0.0
        Score := 0
        Kills := KillTracker.GetValue(Agent)
        Deaths := DeathTracker.GetValue(Agent)
        Killstreak := KillstreakTracker.GetValue(Agent)
        RoundWin := RoundWinTracker.GetValue(Agent)
        RoundPlayed := RoundPlayedTracker.GetValue(Agent)
        var TotalDeaths : int = Deaths
        if (TotalDeaths = 0):
            set TotalDeaths = 1
        RawKD := (1.0 * Kills) / (1.0 * TotalDeaths)
        if (TestKD := RoundToDecimalPlaces[RawKD, 2]):
            set KD = TestKD
        RawWin := (1.0 * RoundWin) / (1.0 * RoundPlayed)
        if (TestWin := RoundToDecimalPlaces[RawWin * 100.0, 2]):
            set WinP = TestWin
        Billboard.SetText(PlayerBillboardText(Kills, Deaths, Killstreak, KD, RoundPlayed, RoundWin, WinP))

    RoundToDecimalPlaces(Value:float, DecimalPlaces:int)<decides><transacts>:float =
        DecimalPlaces >= 0
        Multiplier := Pow(10.0, DecimalPlaces * 1.0)
        RoundedValues := Round[Value * Multiplier] * 1.0
        return RoundedValues / Multiplier