using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

Anna_Device := class<concrete>(creative_device):

    @editable Triggers : []trigger_device = array{}
    @editable SpawnAnalytics : analytics_device = analytics_device{}
    @editable PlayerSpawners : []player_spawner_device = array{}

    @editable XReward : accolades_device = accolades_device{}
    @editable BonusReward : accolades_device = accolades_device{}

    @editable Cinematic : cinematic_sequence_device = cinematic_sequence_device{}
    @editable VFX : vfx_spawner_device = vfx_spawner_device{}
    @editable VFXDuration : float = 2.0

    @editable EnableCinematic : logic = true
    @editable EnableVFX : logic = true
    @editable EnableDebug : logic = false

    @editable SpawnTriggerAnalyticsGrace : float = 1.0
    var SpawnGraceActive : logic = false

    @editable AwardCooldownDuration : float = 1.5
    @editable DisableTriggersDuringCooldown : logic = true
    var AwardCooldownActive : logic = false

    @editable RouteThroughRouter : logic = true
    @editable Router : RewardRouter = RewardRouter{}

    @editable RespectRounds : logic = true
    @editable RoundStartTriggers : []trigger_device = array{}
    @editable RoundEndTriggers   : []trigger_device = array{}
    var RoundGateOpen : logic = true  

    OnBegin<override>()<suspends>:void =
        DebugPrint("Anna_Device OnBegin starting.")
        SpawnAnalytics.Enable()
        XReward.Enable()
        BonusReward.Enable()
        DebugPrint("Analytics and rewards enabled.")

        for (T : Triggers):
            T.TriggeredEvent.Subscribe(HandleTrigger)
        DebugPrint("Subscribed to {Triggers.Length} trigger(s).")

        for (Spawner : PlayerSpawners):
            Spawner.SpawnedEvent.Subscribe(HandlePlayerSpawn)
        DebugPrint("Subscribed to {PlayerSpawners.Length} player spawner(s).")

        XReward.TestAwardEvent.Subscribe(HandleTestAward)
        DebugPrint("Subscribed to XReward.TestAwardEvent.")

        for (RS : RoundStartTriggers):
            RS.TriggeredEvent.Subscribe(OnRoundStart)
        for (RE : RoundEndTriggers):
            RE.TriggeredEvent.Subscribe(OnRoundEnd)
        DebugPrint("Round triggers wired: start={RoundStartTriggers.Length}, end={RoundEndTriggers.Length}.")

        DebugPrint("Anna_Device initialized.")

    OnRoundStart(MaybeInstigator:?agent):void =
        if (RespectRounds?):
            set RoundGateOpen = true
            EnableAllTriggers()
            DebugPrint("Anna: Round start → triggers enabled.")

    OnRoundEnd(MaybeInstigator:?agent):void =
        if (RespectRounds?):
            set RoundGateOpen = false
            DisableAllTriggers()
            DebugPrint("Anna: Round end → triggers disabled.")

    HandlePlayerSpawn(Spawned:agent):void =
        SpawnAnalytics.Submit(Spawned)
        DebugPrint("Spawn analytics submitted.")
        if (SpawnTriggerAnalyticsGrace > 0.0):
            DebugPrint("Starting spawn grace window for {SpawnTriggerAnalyticsGrace}s.")
            spawn:
                StartSpawnGraceWindow()

    HandleTrigger(MaybeInstigator:?agent):void =
        if (Instigator := MaybeInstigator?):
            if (SpawnGraceActive?):
                DebugPrint("Skipping trigger analytics due to spawn grace window.")
            else:
                SpawnAnalytics.Submit(Instigator)
                DebugPrint("Trigger analytics submitted for instigator.")

            spawn:
                CelebrateAndAward(Instigator)
            DebugPrint("Handled trigger for agent; CelebrateAndAward scheduled.")
        else:
            DebugPrint("Trigger fired without agent; skipped processing.")

    HandleTestAward(Recipient:agent):void =
        spawn:
            CelebrateAndAward(Recipient)
        DebugPrint("TestAward handled; celebration executed.")

    CelebrateAndAward(Agent:agent)<suspends>:void =
        DebugPrint("CelebrateAndAward: entered.")
        if (RespectRounds? and not RoundGateOpen?):
            DebugPrint("Round-limited: triggers currently disabled; skipping.")
            return

        if (not player[Agent]):
            DebugPrint("Non-player agent; skipping award/FX.")
            return

        if (AwardCooldownActive?):
            DebugPrint("Award cooldown active; skipping award.")
            return

        set AwardCooldownActive = true
        if (DisableTriggersDuringCooldown?):
            DisableAllTriggers()
            DebugPrint("Triggers disabled during award cooldown.")

        if (RouteThroughRouter?):
            Router.AwardPair(XReward, BonusReward, Agent)
            DebugPrint("XReward + BonusReward awarded via RewardRouter.")
        else:
            XReward.Award(Agent)
            BonusReward.Award(Agent)
            DebugPrint("XReward + BonusReward awarded directly (fallback).")

        sync:
            PlayCinematicIfEnabled(Agent)
            PlayVFXIfEnabled(Agent)
        DebugPrint("Celebration (cinematic/VFX) completed.")

        if (AwardCooldownDuration > 0.0):
            DebugPrint("Award cooldown sleeping: {AwardCooldownDuration}s.")
            Sleep(AwardCooldownDuration)

        if (DisableTriggersDuringCooldown?):
            EnableAllTriggers()
            DebugPrint("Triggers re-enabled after cooldown.")
        set AwardCooldownActive = false
        DebugPrint("CelebrateAndAward: exiting; cooldown flag cleared.")

    PlayCinematicIfEnabled(Agent:agent)<suspends>:void =
        if (EnableCinematic?):
            Cinematic.Play(Agent)
            DebugPrint("Cinematic played for agent.")

    PlayVFXIfEnabled(Agent:agent)<suspends>:void =
        if (EnableVFX?):
            PlayVFXAtAgent(Agent)
            DebugPrint("VFX requested for agent.")

    PlayVFXAtAgent(Target:agent)<suspends>:void =
        if (Fort := Target.GetFortCharacter[]):
            T := Fort.GetTransform()
            if (VFX.TeleportTo[T.Translation, T.Rotation]):
                VFX.Enable()
                DebugPrint("VFX enabled at agent location.")
                if (VFXDuration > 0.0):
                    Sleep(VFXDuration)
                VFX.Disable()
                DebugPrint("VFX disabled after {VFXDuration}s.")
            else:
                DebugPrint("VFX teleport failed; skipping VFX.")

    StartSpawnGraceWindow()<suspends>:void =
        if (SpawnGraceActive?):
            DebugPrint("Spawn grace window already active; skipping.")
            return
        set SpawnGraceActive = true
        DebugPrint("Spawn grace window ACTIVE.")
        Sleep(SpawnTriggerAnalyticsGrace)
        set SpawnGraceActive = false
        DebugPrint("Spawn grace window ENDED.")

    DisableAllTriggers():void =
        for (T : Triggers):
            T.Disable()
        DebugPrint("All triggers disabled (cooldown).")

    EnableAllTriggers():void =
        for (T : Triggers):
            T.Enable()
        DebugPrint("All triggers re-enabled.")

    DebugPrint(Msg:string):void =
        if (EnableDebug?):
            Print(Msg)
