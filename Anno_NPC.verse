using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/Playspaces }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

PvP_PvE_Starter := class<concrete>(creative_device):

    @editable NPCSpawners : []npc_spawner_device = array{}
    @editable Router : RewardRouter = RewardRouter{}
    @editable EnableDebug : logic = false

    @editable FirstBloodAccolade : accolades_device = accolades_device{}
    var FirstBloodAwarded : logic = false

    @editable MVPAccolade : accolades_device = accolades_device{}
    @editable MPVRoundStartTriggers : []trigger_device = array{}
    @editable MPVRoundEndTriggers : []trigger_device = array{}
    
    var MVPAwarded : logic = false

    @editable EnableAutomaticRounds : logic = false
    @editable RoundDurationSeconds : float = 120.0
    @editable IntermissionSeconds : float = 10.0

    var KillerLog : []agent = array{}

    OnBegin<override>()<suspends>:void =
        D("PvP/PvE starter OnBegin starting.")
        FirstBloodAccolade.Enable()
        MVPAccolade.Enable()
        D("Accolades enabled.")

        for (NS : NPCSpawners):
            NS.SpawnedEvent.Subscribe(OnNPCSpawned)
        D("Subscribed to {NPCSpawners.Length} NPC spawners.")

        PS := GetPlayspace()
        InitialPlayers : []player = PS.GetPlayers()
        for (Pl : InitialPlayers):
            if (FC := Pl.GetFortCharacter[]):
                FC.EliminatedEvent().Subscribe(OnAnyPlayerEliminated)
        D("Subscribed to elimination events for {InitialPlayers.Length} existing players.")

        PS.PlayerAddedEvent().Subscribe(OnPlayerAdded)
        D("Subscribed to PlayerAddedEvent.")

        for (T : MPVRoundEndTriggers):
            T.TriggeredEvent.Subscribe(OnRoundEndTriggered)
        for (S : MPVRoundStartTriggers):
            S.TriggeredEvent.Subscribe(OnRoundStartTriggered)
        D("Round triggers wired: start={MPVRoundStartTriggers.Length}, end={MPVRoundEndTriggers.Length}.")

        if (EnableAutomaticRounds?):
            spawn:
                RoundLoop()
            D("Automatic round loop spawned.")

        D("PvP/PvE starter ready.")

    OnNPCSpawned(NPCAgent:agent):void =
        D("NPC spawned; subscribing to EliminatedEvent.")
        if (NPCFC := NPCAgent.GetFortCharacter[]):
            NPCFC.EliminatedEvent().Subscribe(OnNPCEliminated)

    OnNPCEliminated(Res:elimination_result):void =
        if (KillerFC := Res.EliminatingCharacter?, KillerAgent := KillerFC.GetAgent[]):
            if (player[KillerAgent]):
                Router.RoutePVE(KillerAgent)
                D("PvE: NPC eliminated → routed to BasePVE.")
            else:
                D("PvE: NPC eliminated, but killer not a player; skipped.")
        else:
            D("PvE: NPC eliminated with no valid killer; skipped.")

    OnPlayerAdded(NewPlayer:player):void =
        D("Player added; subscribing to EliminatedEvent.")
        if (FC := NewPlayer.GetFortCharacter[]):
            FC.EliminatedEvent().Subscribe(OnAnyPlayerEliminated)

    OnAnyPlayerEliminated(Res:elimination_result):void =
        if (KillerFC := Res.EliminatingCharacter?, KillerAgent := KillerFC.GetAgent[]):
            if (player[KillerAgent]):
                if (not FirstBloodAwarded?):
                    Router.AwardAccolade(FirstBloodAccolade, KillerAgent)
                    set FirstBloodAwarded = true
                    D("First Blood awarded.")

                Router.RoutePVP(KillerAgent)
                D("PvP: Player elimination → routed to BasePVP.")

                set KillerLog += array{KillerAgent}
                D("Killer logged. Total kills tracked: {KillerLog.Length}")
            else:
                D("Player eliminated, but killer not a player; skipping Router.")
        else:
            D("Player eliminated with no valid killer; skipping Router.")

    OnRoundEndTriggered(MaybeInstigator:?agent):void =
        D("Round end trigger received; awarding MVP (spawned).")
        spawn:
            AwardMVP()

    OnRoundStartTriggered(MaybeInstigator:?agent):void =
        D("Round start trigger received; resetting round.")
        ResetRound()

    RoundLoop()<suspends>:void =
        loop:
            ResetRound()
            D("Round started.")
            if (RoundDurationSeconds > 0.0):
                D("Sleeping for round duration: {RoundDurationSeconds}s")
                Sleep(RoundDurationSeconds)
            if (not MVPAwarded?):
                D("Round ended by time; awarding MVP.")
                AwardMVP()
            if (IntermissionSeconds > 0.0):
                D("Intermission: sleeping {IntermissionSeconds}s")
                Sleep(IntermissionSeconds)

    AwardMVP()<suspends>:void =
        if (MVPAwarded?):
            D("MVP already awarded; ignoring.")
            return

        set MVPAwarded = true
        D("Computing MVP from KillerLog size {KillerLog.Length}")

        var UniqueKillers : []agent = array{}
        for (A : KillerLog):
            var Seen : logic = false
            for (B : UniqueKillers):
                if (B = A):
                    set Seen = true
            if (not Seen?):
                set UniqueKillers += array{A}
        D("Unique killers: {UniqueKillers.Length}")

        var MaxCount : int = 0
        for (U : UniqueKillers):
            var C : int = 0
            for (K : KillerLog):
                if (K = U):
                    set C += 1
            if (C > MaxCount):
                set MaxCount = C
        D("Max kill count: {MaxCount}")

        var TopKillers : []agent = array{}
        for (U2 : UniqueKillers):
            var C2 : int = 0
            for (K2 : KillerLog):
                if (K2 = U2):
                    set C2 += 1
            if (C2 = MaxCount and MaxCount > 0):
                set TopKillers += array{U2}

        if (TopKillers.Length = 0):
            D("No MVP awarded (no PvP eliminations logged).")
            return

        for (W : TopKillers):
            Router.AwardAccolade(MVPAccolade, W)
        D("MVP awarded to {TopKillers.Length} player(s).")

    ResetRound():void =
        set FirstBloodAwarded = false
        set MVPAwarded = false
        set KillerLog = array{}
        D("Round reset.")

    D(Msg:string):void =
        if (EnableDebug?):
            Print(Msg)
