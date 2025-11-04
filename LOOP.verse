using { /Fortnite.com/Devices }
using { /Fortnite.com/Playspaces }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

round_manager := class(creative_device):

    @editable RoundDurationSeconds : float = 2700.0
    @editable IntermissionSeconds : float = 10.0
    @editable ResetPlayersOnRoundStart : logic = true

    @editable EndRoundDevice : ?end_game_device = false
    @editable RoundCompleteAccolade : ?accolades_device = false
    @editable RoundTimer : ?timer_device = false

    @editable RoundStartTriggers : []trigger_device = array{}
    @editable RoundEndTriggers   : []trigger_device = array{}

    @editable Router : RewardRouter = RewardRouter{}

    @editable AlwaysClosedBarriers : []barrier_device = array{}

    var RoundIndex : int = 0
    var HasStarted : logic = false
    var IsEnding   : logic = false

    OnBegin<override>()<suspends>:void =
        if (HasStarted?):
            Print("Round Manager OnBegin called but already started; ignoring.")
            return
        Print("Round Manager OnBegin starting.")
        set HasStarted = true

        EnsureBarriersEnabled()
        Print("Barriers ensured on startup.")

        spawn:
            BarrierWatchdog()
        Print("BarrierWatchdog spawned.")

        Print("Round Manager online. Duration {RoundDurationSeconds}s, Intermission {IntermissionSeconds}s")
        loop:
            Print("Round loop: StartRound()")
            StartRound()
            Print("Round loop: RunRoundTimer()")
            RunRoundTimer()
            Print("Round loop: FinishRound()")
            FinishRound()
            Print("Round loop: Intermission sleep {IntermissionSeconds}s")
            Sleep(IntermissionSeconds)

    StartRound():void =
        set RoundIndex += 1
        Print("==> Round {RoundIndex} START")

        EnsureBarriersEnabled()

        if (ResetPlayersOnRoundStart?):
            RefreshAllPlayers()
            PlayersNow : []player = GetPlayers()
            Print("Players refreshed at round start. Count:{PlayersNow.Length}")

        if (T := RoundTimer?):
            T.Reset()
            T.SetMaxDuration(RoundDurationSeconds)
            T.Enable()
            T.Start()
            Print("Round timer enabled and started for {RoundDurationSeconds}s")

        var Fired : int = 0
        for (Trig : RoundStartTriggers):
            Trig.Trigger()
            set Fired += 1
        Print("RoundStartTriggers fired: {Fired}")

    RunRoundTimer()<suspends>:void =
        Print("RunRoundTimer: sleeping for {RoundDurationSeconds}s")
        Sleep(RoundDurationSeconds)

    FinishRound():void =
        if (IsEnding?):
            Print("FinishRound called while already ending; ignoring.")
            return
        set IsEnding = true

        EnsureBarriersEnabled()

        Players : []player = GetPlayers()
        Print("<== Round {RoundIndex} END    Players:{Players.Length}")

        if (T := RoundTimer?):
            T.Complete()
            T.Reset()
            Print("Round timer completed and reset.")

        if (Players.Length > 0, End := EndRoundDevice?, A := agent[Players[0]]):
            End.Activate(A)
            Print("EndRoundDevice activated with first player's agent.")
        else:
            Print("No EndRoundDevice (or no players). Performing soft reset via elimination.")
            EliminateAllPlayers()

        if (Acc := RoundCompleteAccolade?):
            Acc.Enable()
            AllPlayers : []player = GetPlayers()
            for (P : AllPlayers):
                if (A2 := agent[P]):
                    Router.AwardAccolade(Acc, A2)
            Print("Round-complete accolade routed via RewardRouter to {AllPlayers.Length} players.")

        var EndFired : int = 0
        for (TrigE : RoundEndTriggers):
            TrigE.Trigger()
            set EndFired += 1
        Print("RoundEndTriggers fired: {EndFired}")

        set IsEnding = false
        Print("FinishRound complete; IsEnding reset.")

    EnsureBarriersEnabled():void =
        for (B : AlwaysClosedBarriers):
            B.Enable()

    BarrierWatchdog()<suspends>:void =
        Print("BarrierWatchdog online.")
        loop:
            EnsureBarriersEnabled()
            Sleep(5.0)

    RefreshAllPlayers():void =
        Players : []player = GetPlayers()
        for (P : Players):
            if (FC := P.GetFortCharacter[]):
                FC.SetHealth(FC.GetMaxHealth())
                FC.SetShield(FC.GetMaxShield())
        Print("RefreshAllPlayers processed {Players.Length} players.")

    EliminateAllPlayers():void =
        Players : []player = GetPlayers()
        for (P : Players):
            if (FC := P.GetFortCharacter[]):
                FC.Damage(999999.0)
        Print("EliminateAllPlayers executed for {Players.Length} players.")

    GetPlayers():[]player =
        GetPlayspace().GetPlayers()
