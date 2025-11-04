using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

one_v_one_elim_tp := class(creative_device):

    @editable BlueSpawner      : player_spawner_device      = player_spawner_device{}
    @editable RedSpawner       : player_spawner_device      = player_spawner_device{}
    @editable BlueTeleporter   : teleporter_device          = teleporter_device{}
    @editable RedTeleporter    : teleporter_device          = teleporter_device{}
    @editable BlueKillsTracker : tracker_device             = tracker_device{}
    @editable RedKillsTracker  : tracker_device             = tracker_device{}
    @editable Elims            : elimination_manager_device = elimination_manager_device{}

    @editable PlayerRefBlue    : player_reference_device    = player_reference_device{}
    @editable PlayerRefRed     : player_reference_device    = player_reference_device{}

    @editable EnableFavHUD     : logic          = true
    @editable FavHUD           : fav_like_hud   = fav_like_hud{}

    @editable JumpScare        : jump_scare_manager         = jump_scare_manager{}

    @editable FallDamageVolume : damage_volume_device       = damage_volume_device{}

    @editable ElimSFX          : []audio_player_device            = array{}
    @editable ElimVFXPowerup   : []visual_effect_powerup_device   = array{}
    @editable ElimExplosives   : []explosive_device               = array{}
    @editable ElimItemRemovers : []item_remover_device            = array{}

    @editable ExplodeOnInteractButton : button_device              = button_device{}

    @editable EnablePerElimSFX            : logic = true
    @editable EnableAutoTeleportAfterElim : logic = true
    @editable TeleportDelaySeconds        : float = 0.15
    @editable EnableElimVFX               : logic = true
    @editable EnableElimExplosives        : logic = true
    @editable EnableElimItemRemoval       : logic = true
    @editable EnableTeleportGrants        : logic = true
    @editable SFXCooldownSeconds          : float = 0.25

    @editable EnableHUDAnnouncements      : logic = true
    @editable HUDCooldownSeconds          : float = 0.75

    @editable HUDLeadYouBlue  : hud_message_device = hud_message_device{}
    @editable HUDLeadYouRed   : hud_message_device = hud_message_device{}
    @editable HUDLeadTheyBlue : hud_message_device = hud_message_device{}
    @editable HUDLeadTheyRed  : hud_message_device = hud_message_device{}

    @editable EnableFinishers : logic                = true
    @editable WinSFX          : audio_player_device  = audio_player_device{}
    @editable WinVFX          : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable LoseSFX         : audio_player_device  = audio_player_device{}
    @editable LoseVFX         : visual_effect_powerup_device = visual_effect_powerup_device{}

    @editable AccFirstBlood    : accolades_device   = accolades_device{}
    @editable HUDFirstBlood    : hud_message_device = hud_message_device{}
    @editable AccPerfectRound  : accolades_device   = accolades_device{}
    @editable HUDPerfectRound  : hud_message_device = hud_message_device{}
    @editable AccTakeLead      : accolades_device   = accolades_device{}

    @editable AccOnElim        : accolades_device   = accolades_device{}

    # Accolade on Spawn (config)
    @editable EnableAccoladeOnSpawn : logic = true
    @editable AccOnSpawnBlue        : accolades_device = accolades_device{}
    @editable AccOnSpawnRed         : accolades_device = accolades_device{}
    @editable AccOnSpawnMode        : int   = 1   # 0=Every Spawn, 1=Once/Round, 2=Once/Match

    @editable TeleportGranters : []item_granter_device = array{} 

    @editable Streaks          : duel_streaks_manager = duel_streaks_manager{}

    @editable EnableSpawnCampMitigation        : logic = true
    @editable SpawnCampRemovalWindowSeconds    : float = 1.25
    @editable EnableDespawnForfeit             : logic = true

    @editable RoundSeconds : float = 0.0
    @editable RoundTickHz  : float = 1.0

    @editable EnableKillAccolades : logic = true

    @editable EnableLeadChangeHype            : logic = true   
    @editable EnableFirstBloodDrama           : logic = true   
    @editable EnablePerfectRoundCelebration   : logic = true   
    @editable EnableRoundFinishers            : logic = true   
    @editable EnableMilestoneMoments          : logic = true   
    @editable EnableRoundIntroAnnouncement    : logic = true   
    @editable EnableTeleportLoadoutGrants     : logic = true   
    @editable EnableAutoResetCleanup          : logic = true   
    @editable EnableAutoNextRoundAfterTimeout : logic = true  
    @editable IntermissionSeconds             : float = 2.0   
    @editable TeleportGrantCooldownSeconds    : float = 1.0   

    # --- Intermission Notice HUD ---
    @editable IntermissionHUD : hud_message_device = hud_message_device{}

    # --- Explode button cooldown (anti-spam) ---
    @editable ExplodeButtonCooldownSeconds : float = 0.5

    # --- NEW: Revenge Kill (devices & toggle) ---
    @editable EnableRevengeAccolade : logic = true
    @editable AccRevenge            : accolades_device             = accolades_device{}
    @editable HUDRevengeBlue        : hud_message_device           = hud_message_device{}
    @editable HUDRevengeRed         : hud_message_device           = hud_message_device{}
    @editable RevengeSFX            : audio_player_device          = audio_player_device{}
    @editable RevengeVFX            : visual_effect_powerup_device = visual_effect_powerup_device{}

    # --- NEW: Comeback (devices & toggle) ---
    @editable EnableComebackAccolade : logic = true
    @editable AccComeback            : accolades_device             = accolades_device{}
    @editable HUDComebackBlue        : hud_message_device           = hud_message_device{}
    @editable HUDComebackRed         : hud_message_device           = hud_message_device{}
    @editable ComebackSFX            : audio_player_device          = audio_player_device{}
    @editable ComebackVFX            : visual_effect_powerup_device = visual_effect_powerup_device{}

    # --- NEW: Bounds HUD on mutator zones ---
    @editable EnableBoundsHUD          : logic = true
    @editable BoundsZones              : []mutator_zone_device = array{}
    @editable BoundsHUD                : hud_message_device = hud_message_device{}
    @editable BoundsHUDCooldownSeconds : float = 1.0

    # --- Reliability: single DEBUG switch for optional logs ---
    @editable DEBUG : logic = false

    var player_a          : ?agent  = false
    var player_b          : ?agent  = false
    var player_a_pl       : ?player = false
    var player_b_pl       : ?player = false

    var round_token       : int   = 0
    var sfx_next          : int   = 0
    var RoundRemaining    : float = 0.0

    var first_spawn_awarded_a : logic = false
    var first_spawn_awarded_b : logic = false
    var blue_kills            : int   = 0
    var red_kills             : int   = 0

    var round_first_blood_awarded : logic = false
    var round_deaths_blue         : int   = 0
    var round_deaths_red          : int   = 0

    var round_had_both : logic = false

    var IntermissionActive : logic = false

    var TeleportDelayClamped           : float = 0.15
    var RoundSecondsClamped            : float = 0.0
    var SFXCooldownClamped             : float = 0.0
    var HUDCooldownClamped             : float = 0.0
    var RoundTickHzClamped             : float = 1.0
    var RoundTickStepClamped           : float = 1.0
    var IntermissionClamped            : float = 0.0
    var TeleportGrantCooldownClamped   : float = 0.0

    var SpawnCampRemovalWindowClamped : float = 0.0
    var EnableElimVFXEff              : logic = false
    var EnableElimExplosivesEff       : logic = false
    var EnableElimItemRemovalEff      : logic = false
    var EnableSpawnCampMitigationEff  : logic = false

    var TeleportGrantersToUse : int   = 0

    var SFXCooldownActive : logic = false
    var SFXCooldownToken  : int   = 0

    var HUDCooldownActiveA : logic = false
    var HUDCooldownActiveB : logic = false
    var HUDCooldownTokenA  : int   = 0
    var HUDCooldownTokenB  : int   = 0

    var GrantCD_A      : logic = false
    var GrantCD_B      : logic = false
    var GrantCDTok_A   : int   = 0
    var GrantCDTok_B   : int   = 0

    var tp_pending_a      : logic = false
    var tp_pending_b      : logic = false

    var round_restart_pending  : logic = false
    var RestartDebounceSeconds : float = 0.05

    var LenElimSFX       : int   = 0
    var LenVFX           : int   = 0
    var LenExplosives    : int   = 0
    var LenRemovers      : int   = 0

    var SharedSleepStep           : float = 1.0
    var removal_window_active     : logic = false
    var removal_window_remaining  : float = 0.0

    var round_end_pending : logic = false
    var RoundEndToken     : int   = 0   # for debug visibility only

    var EnableFinishersEff      : logic = false
    var EnableTeleportGrantsEff : logic = false

    var AutoNextRoundToken : int = 0

    # Spawn accolade gating flags
    var spawn_acc_awarded_round_blue : logic = false
    var spawn_acc_awarded_round_red  : logic = false
    var spawn_acc_awarded_match_blue : logic = false
    var spawn_acc_awarded_match_red  : logic = false

    # --- Explode cooldown state ---
    var ExplodeCDClamped : float = 0.0
    var ExplodeCDActive  : logic = false
    var ExplodeCDToken   : int   = 0

    # --- NEW: Revenge tracking (which side last killed each player) ---
    # 0 = none; 1 = Blue; 2 = Red
    var last_killed_by_blue : int = 0
    var last_killed_by_red  : int = 0

    # --- NEW: Comeback tracking (per-round) ---
    var max_def_blue_neg       : int   = 0   # most negative (blue behind)
    var max_def_red_neg        : int   = 0   # most negative (red behind)
    var blue_comeback_tied     : logic = false
    var red_comeback_tied      : logic = false
    var blue_comeback_awarded  : logic = false
    var red_comeback_awarded   : logic = false

    # --- NEW: Bounds HUD cooldown state ---
    var BoundsCDClamped : float = 0.0
    var BoundsCDAActive : logic = false
    var BoundsCDBActive : logic = false
    var BoundsCDTokA    : int   = 0
    var BoundsCDTokB    : int   = 0
    var LenBoundsZones  : int   = 0

    # --- DEBUG helper (string-only wrapper; use Print(...) directly for { } interpolation) ---
    Log(S:string):void =
        if (DEBUG = true):
            Print(S)

    # --- Round-start tracker HUD kickstart helpers ---
    KickstartTrackerFor(T:tracker_device, A:agent):void =
        T.Increment(A)
        T.Decrement(A)

    EnsureKillTrackersAssignedAndKickstarted():void =
        if (A := player_a?):
            BlueKillsTracker.Assign(A)
            RedKillsTracker.Assign(A)
            KickstartTrackerFor(BlueKillsTracker, A)
            KickstartTrackerFor(RedKillsTracker, A)
        if (B := player_b?):
            BlueKillsTracker.Assign(B)
            RedKillsTracker.Assign(B)
            KickstartTrackerFor(BlueKillsTracker, B)
            KickstartTrackerFor(RedKillsTracker, B)

    ShowHUDTo(H:hud_message_device, To:agent):void =
        if (EnableHUDAnnouncements = false):
            return

        if (HUDCooldownClamped > 0.0):
            if (A := player_a?, To = A):
                if (HUDCooldownActiveA = true):
                    return
                H.Show(To)
                set HUDCooldownActiveA = true
                set HUDCooldownTokenA  = HUDCooldownTokenA + 1
                tokA := HUDCooldownTokenA
                spawn { HUDCooldownTaskSide(1, tokA) }
                return

            if (B := player_b?, To = B):
                if (HUDCooldownActiveB = true):
                    return
                H.Show(To)
                set HUDCooldownActiveB = true
                set HUDCooldownTokenB  = HUDCooldownTokenB + 1
                tokB := HUDCooldownTokenB
                spawn { HUDCooldownTaskSide(2, tokB) }
                return

        H.Show(To)

    HUDCooldownTaskSide(Side:int, Token:int)<suspends>:void =
        Sleep(HUDCooldownClamped)
        if (Side = 1 and Token = HUDCooldownTokenA):
            set HUDCooldownActiveA = false
        if (Side = 2 and Token = HUDCooldownTokenB):
            set HUDCooldownActiveB = false

    SafeKillAccolade(A:accolades_device, To:agent):void =
        if (EnableKillAccolades = false):
            return
        A.Award(To)

    # --- NEW: Award helpers ---
    AwardRevenge(Side:int, Scorer:agent):void =
        if (EnableRevengeAccolade = false):
            return
        AccRevenge.Award(Scorer)
        if (Side = 1):
            ShowHUDTo(HUDRevengeBlue, Scorer)
        else:
            if (Side = 2):
                ShowHUDTo(HUDRevengeRed, Scorer)
        RevengeSFX.Play()
        RevengeVFX.Pickup(Scorer)

    AwardComeback(Side:int, Scorer:agent):void =
        if (EnableComebackAccolade = false):
            return
        AccComeback.Award(Scorer)
        if (Side = 1):
            ShowHUDTo(HUDComebackBlue, Scorer)
        else:
            if (Side = 2):
                ShowHUDTo(HUDComebackRed, Scorer)
        ComebackSFX.Play()
        ComebackVFX.Pickup(Scorer)

    # --- NEW: Bounds enter handlers ---
    OnBoundsEntered(Entered:agent):void =
        if (EnableBoundsHUD = false):
            return
        if (A := player_a?, Entered = A):
            if (BoundsCDClamped > 0.0 and BoundsCDAActive = true):
                return
            BoundsHUD.Show(Entered)
            if (BoundsCDClamped > 0.0 and BoundsCDAActive = false):
                set BoundsCDAActive = true
                set BoundsCDTokA = BoundsCDTokA + 1
                tokA := BoundsCDTokA
                spawn { BoundsCooldownTask(1, tokA) }
            return

        if (B := player_b?, Entered = B):
            if (BoundsCDClamped > 0.0 and BoundsCDBActive = true):
                return
            BoundsHUD.Show(Entered)
            if (BoundsCDClamped > 0.0 and BoundsCDBActive = false):
                set BoundsCDBActive = true
                set BoundsCDTokB = BoundsCDTokB + 1
                tokB := BoundsCDTokB
                spawn { BoundsCooldownTask(2, tokB) }

    BoundsCooldownTask(Side:int, Token:int)<suspends>:void =
        Sleep(BoundsCDClamped)
        if (Side = 1 and Token = BoundsCDTokA):
            set BoundsCDAActive = false
        if (Side = 2 and Token = BoundsCDTokB):
            set BoundsCDBActive = false

    OnBegin<override>()<suspends>:void =
        # Reset match-level spawn accolade gates
        set spawn_acc_awarded_match_blue = false
        set spawn_acc_awarded_match_red  = false
        set spawn_acc_awarded_round_blue = false
        set spawn_acc_awarded_round_red  = false

        set TeleportDelayClamped = TeleportDelaySeconds
        if (TeleportDelayClamped < 0.0):
            set TeleportDelayClamped = 0.0

        set RoundSecondsClamped = RoundSeconds
        if (RoundSecondsClamped < 0.0):
            set RoundSecondsClamped = 0.0

        set SFXCooldownClamped = SFXCooldownSeconds
        if (SFXCooldownClamped < 0.0):
            set SFXCooldownClamped = 0.0

        set HUDCooldownClamped = HUDCooldownSeconds
        if (HUDCooldownClamped < 0.0):
            set HUDCooldownClamped = 0.0

        set RoundTickHzClamped = RoundTickHz
        if (RoundTickHzClamped < 0.25):
            set RoundTickHzClamped = 0.25
        if (RoundTickHzClamped > 5.0):
            set RoundTickHzClamped = 5.0
        set RoundTickStepClamped = 1.0 / RoundTickHzClamped

        set SharedSleepStep = RoundTickStepClamped
        if (SharedSleepStep < 0.1):
            set SharedSleepStep = 0.1

        set SpawnCampRemovalWindowClamped = SpawnCampRemovalWindowSeconds
        if (SpawnCampRemovalWindowClamped < 0.0):
            set SpawnCampRemovalWindowClamped = 0.0
        if (SpawnCampRemovalWindowClamped > 3.0):
            set SpawnCampRemovalWindowClamped = 3.0

        set IntermissionClamped = IntermissionSeconds
        if (IntermissionClamped < 0.0):
            set IntermissionClamped = 0.0
        if (IntermissionClamped > 10.0):
            set IntermissionClamped = 10.0

        set TeleportGrantCooldownClamped = TeleportGrantCooldownSeconds
        if (TeleportGrantCooldownClamped < 0.0):
            set TeleportGrantCooldownClamped = 0.0
        if (TeleportGrantCooldownClamped > 5.0):
            set TeleportGrantCooldownClamped = 5.0

        # clamp explode button cooldown
        set ExplodeCDClamped = ExplodeButtonCooldownSeconds
        if (ExplodeCDClamped < 0.0):
            set ExplodeCDClamped = 0.0
        if (ExplodeCDClamped > 5.0):
            set ExplodeCDClamped = 5.0

        # clamp bounds HUD cooldown & subscribe mutator zones
        set BoundsCDClamped = BoundsHUDCooldownSeconds
        if (BoundsCDClamped < 0.0):
            set BoundsCDClamped = 0.0
        if (BoundsCDClamped > 5.0):
            set BoundsCDClamped = 5.0
        set LenBoundsZones = BoundsZones.Length
        for (Z : BoundsZones):
            Z.AgentEntersEvent.Subscribe(OnBoundsEntered)

        set LenElimSFX    = ElimSFX.Length
        set LenVFX        = ElimVFXPowerup.Length
        set LenExplosives = ElimExplosives.Length
        set LenRemovers   = ElimItemRemovers.Length

        set EnableElimVFXEff = EnableElimVFX
        if (LenVFX <= 0):
            set EnableElimVFXEff = false

        set EnableElimExplosivesEff = EnableElimExplosives
        if (LenExplosives <= 0):
            set EnableElimExplosivesEff = false

        set EnableElimItemRemovalEff = EnableElimItemRemoval
        if (LenRemovers <= 0):
            set EnableElimItemRemovalEff = false

        set EnableSpawnCampMitigationEff = EnableSpawnCampMitigation
        if (SpawnCampRemovalWindowClamped <= 0.0 or LenRemovers <= 0):
            set EnableSpawnCampMitigationEff = false

        set EnableFinishersEff = EnableFinishers
        if (EnableRoundFinishers = false):
            set EnableFinishersEff = false

        set EnableTeleportGrantsEff = EnableTeleportGrants
        if (EnableTeleportLoadoutGrants = false):
            set EnableTeleportGrantsEff = false

        len_granters := TeleportGranters.Length
        set TeleportGrantersToUse = len_granters
        if (TeleportGrantersToUse > 5):
            set TeleportGrantersToUse = 5

        BlueSpawner.SpawnedEvent.Subscribe(OnSpawnFromA)
        RedSpawner.SpawnedEvent.Subscribe(OnSpawnFromB)
        BlueTeleporter.TeleportedEvent.Subscribe(OnTeleported)
        RedTeleporter.TeleportedEvent.Subscribe(OnTeleported)
        ExplodeOnInteractButton.InteractedWithEvent.Subscribe(OnExplodeButton)
        FallDamageVolume.AgentEntersEvent.Subscribe(OnDamageVolumeEntered)

        # Boot self-test summary — call Print(...) directly to allow { } interpolation
        if (DEBUG = true):
            Print("BOOT one_v_one_elim_tp: LenSFX={LenElimSFX} LenVFX={LenVFX} LenExpl={LenExplosives} LenRem={LenRemovers} LenBounds={LenBoundsZones} TDly={TeleportDelayClamped} RSec={RoundSecondsClamped} Hz={RoundTickHzClamped} Step={SharedSleepStep} RmWin={SpawnCampRemovalWindowClamped} Interm={IntermissionClamped} GrantCD={TeleportGrantCooldownClamped}")

        spawn { ElimLoop() }

    OnSpawnFromA(Spawned:agent):void =
        set player_a = option{Spawned}
        if (Pl := player[Spawned]):
            set player_a_pl = option{Pl}
        PlayerRefBlue.Register(Spawned)
        if (first_spawn_awarded_a = false):
            BlueKillsTracker.Assign(Spawned)
            RedKillsTracker.Assign(Spawned)
            set first_spawn_awarded_a = true

        MaybeAwardSpawnAccolade(1, Spawned)

        if (RoundSecondsClamped > 0.0 and round_token = 0):
            RequestRoundRestart()

    OnSpawnFromB(Spawned:agent):void =
        set player_b = option{Spawned}
        if (Pl := player[Spawned]):
            set player_b_pl = option{Pl}
        PlayerRefRed.Register(Spawned)
        if (first_spawn_awarded_b = false):
            BlueKillsTracker.Assign(Spawned)
            RedKillsTracker.Assign(Spawned)
            set first_spawn_awarded_b = true

        MaybeAwardSpawnAccolade(2, Spawned)

        if (RoundSecondsClamped > 0.0 and round_token = 0):
            RequestRoundRestart()

    OnTeleported(Who:agent):void =
        if (EnableTeleportGrantsEff = false):
            return
        if (IntermissionActive = true):
            return

        if (A := player_a?, Who = A):
            MaybeGrantTeleportLoadoutForSide(1)
            return

        if (B := player_b?, Who = B):
            MaybeGrantTeleportLoadoutForSide(2)

    MaybeGrantTeleportLoadoutForSide(Side:int):void =
        if (TeleportGrantersToUse <= 0):
            return

        if (Side = 1):
            if (TeleportGrantCooldownClamped > 0.0 and GrantCD_A = true):
                return
            if (A := player_a?):
                GrantTeleportLoadout(A)
                if (TeleportGrantCooldownClamped > 0.0 and GrantCD_A = false):
                    set GrantCD_A = true
                    set GrantCDTok_A = GrantCDTok_A + 1
                    tokA := GrantCDTok_A
                    spawn { TeleportGrantCooldownTask(1, tokA) }
            return

        if (Side = 2):
            if (TeleportGrantCooldownClamped > 0.0 and GrantCD_B = true):
                return
            if (B := player_b?):
                GrantTeleportLoadout(B)
                if (TeleportGrantCooldownClamped > 0.0 and GrantCD_B = false):
                    set GrantCD_B = true
                    set GrantCDTok_B = GrantCDTok_B + 1
                    tokB := GrantCDTok_B
                    spawn { TeleportGrantCooldownTask(2, tokB) }

    TeleportGrantCooldownTask(Side:int, Token:int)<suspends>:void =
        Sleep(TeleportGrantCooldownClamped)
        if (Side = 1 and Token = GrantCDTok_A):
            set GrantCD_A = false
        if (Side = 2 and Token = GrantCDTok_B):
            set GrantCD_B = false

    GrantTeleportLoadout(A:agent):void =
        if (Pl := player[A]):
            if (TeleportGrantersToUse <= 0):
                return
            var used:int = 0
            for (G : TeleportGranters):
                if (used >= TeleportGrantersToUse):
                    return
                G.GrantItem(Pl)
                set used = used + 1
            return

    OnExplodeButton(Presser:agent):void =
        if (EnableElimExplosivesEff = false):
            return
        # cooldown gate
        if (ExplodeCDClamped > 0.0 and ExplodeCDActive = true):
            return
        TriggerElimExplosives(Presser)
        if (ExplodeCDClamped > 0.0 and ExplodeCDActive = false):
            set ExplodeCDActive = true
            set ExplodeCDToken = ExplodeCDToken + 1
            tok := ExplodeCDToken
            spawn { ExplodeCooldownTask(tok) }

    ExplodeCooldownTask(Token:int)<suspends>:void =
        Sleep(ExplodeCDClamped)
        if (Token = ExplodeCDToken):
            set ExplodeCDActive = false

    OnDamageVolumeEntered(Entered:agent):void =
        if (P := player[Entered]):
            if (A := player_a?):
                if (Ap := player[A], Ap = P):
                    Elims.Enable()
                    return
            if (B := player_b?):
                if (Bp := player[B], Bp = P):
                    Elims.Enable()

    ElimLoop()<suspends>:void =
        loop:
            Victim:agent = Elims.EliminatedEvent.Await()

            if (IntermissionActive = false):
                if (EnableAutoTeleportAfterElim = true):
                    MaybeScheduleTeleport(Victim)

                if (EnablePerElimSFX = true):
                    PlayNextElimSFX()

                if (EnableElimVFXEff = true):
                    ApplyElimVFXPowerups(Victim)

                if (EnableElimExplosivesEff = true):
                    TriggerElimExplosives(Victim)

                if (EnableElimItemRemovalEff = true):
                    ApplyElimItemRemoversBoth()

                if (EnableSpawnCampMitigationEff = true):
                    MaybeExtendRemovalWindow(SpawnCampRemovalWindowClamped)

                if (A := player_a?, Victim = A):
                    set round_deaths_blue = round_deaths_blue + 1
                else:
                    if (B := player_b?, Victim = B):
                        set round_deaths_red = round_deaths_red + 1

                HandleScoringAndStreaks(Victim)

                RequestRoundRestart()

    # --- NEW: Comeback tracker update ---
    UpdateComebackStateAfterKill(LastScorerSide:int, LastScorer:agent):void =
        blueRoundKills := round_deaths_red
        redRoundKills  := round_deaths_blue

        deltaBlue := blueRoundKills - redRoundKills
        deltaRed  := redRoundKills  - blueRoundKills

        if (deltaBlue < max_def_blue_neg):
            set max_def_blue_neg = deltaBlue
        if (deltaRed < max_def_red_neg):
            set max_def_red_neg = deltaRed

        if (LastScorerSide = 1):
            if (EnableComebackAccolade = true and blue_comeback_awarded = false):
                if (max_def_blue_neg <= -2):
                    if (deltaBlue = 0 and blue_comeback_tied = false):
                        set blue_comeback_tied = true
                    if (blue_comeback_tied = true and deltaBlue > 0):
                        AwardComeback(1, LastScorer)
                        set blue_comeback_awarded = true
        else:
            if (LastScorerSide = 2):
                if (EnableComebackAccolade = true and red_comeback_awarded = false):
                    if (max_def_red_neg <= -2):
                        if (deltaRed = 0 and red_comeback_tied = false):
                            set red_comeback_tied = true
                        if (red_comeback_tied = true and deltaRed > 0):
                            AwardComeback(2, LastScorer)
                            set red_comeback_awarded = true

    HandleScoringAndStreaks(Victim:agent):void =
        if (not (player_a? and player_b?)):
            return

        if (A := player_a?, Victim = A):
            if (Scorer := player_b?):
                # victim is Blue, scorer is Red
                set last_killed_by_blue = 2  # Red just killed Blue

                # REPRISAL: Did Red kill the last player who killed Red?
                if (last_killed_by_red = 1 and EnableRevengeAccolade = true):
                    AwardRevenge(2, Scorer)
                    set last_killed_by_red = 0

                IncrementTrackerForBoth(RedKillsTracker)
                set red_kills = red_kills + 1

                SafeKillAccolade(AccOnElim, Scorer)

                if (EnableFirstBloodDrama = true and round_first_blood_awarded = false):
                    set round_first_blood_awarded = true
                    SafeKillAccolade(AccFirstBlood, Scorer)
                    ShowHUDTo(HUDFirstBlood, Scorer)

                Streaks.OnKill(Scorer, 2)

                if (EnableLeadChangeHype = true):
                    if (red_kills > blue_kills and (red_kills - 1) = blue_kills):
                        SafeKillAccolade(AccTakeLead, Scorer)
                        ShowHUDTo(HUDLeadYouRed, Scorer)
                        if (Opp := player_a?):
                            ShowHUDTo(HUDLeadTheyBlue, Opp)

                # Comeback evaluation (after counters moved)
                UpdateComebackStateAfterKill(2, Scorer)

        if (B := player_b?, Victim = B):
            if (Scorer2 := player_a?):
                # victim is Red, scorer is Blue
                set last_killed_by_red = 1  # Blue just killed Red

                # REPRISAL: Did Blue kill the last player who killed Blue?
                if (last_killed_by_blue = 2 and EnableRevengeAccolade = true):
                    AwardRevenge(1, Scorer2)
                    set last_killed_by_blue = 0

                IncrementTrackerForBoth(BlueKillsTracker)
                set blue_kills = blue_kills + 1

                SafeKillAccolade(AccOnElim, Scorer2)

                if (EnableFirstBloodDrama = true and round_first_blood_awarded = false):
                    set round_first_blood_awarded = true
                    SafeKillAccolade(AccFirstBlood, Scorer2)
                    ShowHUDTo(HUDFirstBlood, Scorer2)

                Streaks.OnKill(Scorer2, 1)

                if (EnableLeadChangeHype = true):
                    if (blue_kills > red_kills and (blue_kills - 1) = red_kills):
                        SafeKillAccolade(AccTakeLead, Scorer2)
                        ShowHUDTo(HUDLeadYouBlue, Scorer2)
                        if (Opp2 := player_b?):
                            ShowHUDTo(HUDLeadTheyRed, Opp2)

                # Comeback evaluation (after counters moved)
                UpdateComebackStateAfterKill(1, Scorer2)

        total := blue_kills + red_kills
        JumpScare.OnTotalElims(total, player_a, player_b)

        if (EnableMilestoneMoments = true and EnableFavHUD = true):
            FavHUD.NotifyTotalElims(total, player_a, player_b)

    MaybeExtendRemovalWindow(Duration:float):void =
        if (removal_window_active = false):
            set removal_window_active = true
            set removal_window_remaining = Duration
            spawn { RemovalWindowCoalescedTask() }
            return
        if (Duration > removal_window_remaining):
            set removal_window_remaining = Duration

    RemovalWindowCoalescedTask()<suspends>:void =
        var step:float = SharedSleepStep
        if (step <= 0.0):
            set step = 0.1
        loop:
            if (removal_window_active = false):
                return
            ApplyElimItemRemoversBoth()
            if (removal_window_remaining <= 0.0):
                set removal_window_active = false
                return
            Sleep(step)
            set removal_window_remaining = removal_window_remaining - step
            if (removal_window_remaining < 0.0):
                set removal_window_remaining = 0.0

    MaybeScheduleTeleport(ElimAgent:agent):void =
        if (A := player_a?, ElimAgent = A):
            if (tp_pending_a = true):
                return
            set tp_pending_a = true
            spawn { TeleportAfterRespawn(ElimAgent, 1) }
            return

        if (B := player_b?, ElimAgent = B):
            if (tp_pending_b = true):
                return
            set tp_pending_b = true
            spawn { TeleportAfterRespawn(ElimAgent, 2) }
            return

    ApplyElimItemRemoversBoth():void =
        if (LenRemovers <= 0):
            return
        if (A := player_a?):
            if (Pa := player[A]):
                for (R : ElimItemRemovers):
                    R.Remove(Pa)
        if (B := player_b?):
            if (Pb := player[B]):
                for (R : ElimItemRemovers):
                    R.Remove(Pb)

    # --- Reliability: destination chosen AFTER delay, by side (fallback survives ref clears) ---
    TeleportAfterRespawn(ElimAgent:agent, Side:int)<suspends>:void =
        var Delay:float = TeleportDelayClamped
        Sleep(Delay)

        if (Side = 1 and tp_pending_a = false):
            return
        if (Side = 2 and tp_pending_b = false):
            return
        if (IntermissionActive = true):
            if (Side = 1):
                set tp_pending_a = false
            else:
                if (Side = 2):
                    set tp_pending_b = false
            return

        # Pick by side (fallback even if refs cleared mid-task)
        Dest:teleporter_device = ChooseTeleporterForSide(Side)

        if (P := player[ElimAgent]):
            Dest.Teleport(ElimAgent)
        else:
            if (Side = 1):
                set tp_pending_a = false
            else:
                if (Side = 2):
                    set tp_pending_b = false
            return

        if (Side = 1):
            set tp_pending_a = false
        else:
            if (Side = 2):
                set tp_pending_b = false

    ChooseTeleporterForSide(Side:int):teleporter_device =
        if (Side = 1):
            return BlueTeleporter
        if (Side = 2):
            return RedTeleporter
        return BlueTeleporter

    RequestRoundRestart():void =
        if (RoundSecondsClamped <= 0.0):
            return
        if (round_restart_pending = true):
            return
        set round_restart_pending = true
        spawn { DebouncedStartNewRound() }

    DebouncedStartNewRound()<suspends>:void =
        Sleep(RestartDebounceSeconds)
        StartNewRound()
        set round_restart_pending = false

    StartNewRound():void =
        # Clear any pending async state at the top for race safety
        set tp_pending_a = false
        set tp_pending_b = false
        set removal_window_active = false

        set round_end_pending = false
        set IntermissionActive = false
        JumpScare.SetIntermissionActive(false)
        set round_had_both = false
        if (player_a? and player_b?):
            set round_had_both = true
        CleanArenaReset()
        set round_first_blood_awarded = false
        set round_deaths_blue = 0
        set round_deaths_red  = 0
        Streaks.Reset()
        set round_token = round_token + 1
        this_round := round_token
        if (RoundSecondsClamped > 0.0):
            set RoundRemaining = RoundSecondsClamped

        # Reset per-round spawn accolade gates
        set spawn_acc_awarded_round_blue = false
        set spawn_acc_awarded_round_red  = false

        # Reset comeback trackers per round
        set max_def_blue_neg      = 0
        set max_def_red_neg       = 0
        set blue_comeback_tied    = false
        set red_comeback_tied     = false
        set blue_comeback_awarded = false
        set red_comeback_awarded  = false

        # Ensure tracker HUDs are visible at round start (only)
        EnsureKillTrackersAssignedAndKickstarted()

        if (EnableRoundIntroAnnouncement = true and EnableFavHUD = true):
            FavHUD.ShowRoundStart(player_a, player_b)

        spawn { RoundTimer(this_round) }

    RoundTimer(marker:int)<suspends>:void =
        if (RoundSecondsClamped <= 0.0):
            set RoundRemaining = 0.0
            return

        var step:float = SharedSleepStep
        loop:
            if (not (marker = round_token)):
                set RoundRemaining = 0.0
                return

            ClearPlayerRefsIfLeft()

            if (player_a? and player_b?):
                set round_had_both = true

            if (EnableDespawnForfeit = true and round_had_both = true):
                var gone_blue:logic = true
                var gone_red:logic  = true

                if (A := player_a?):
                    if (Pa := player[A]):
                        set gone_blue = false
                if (B := player_b?):
                    if (Pb := player[B]):
                        set gone_red = false

                if (gone_blue = true and gone_red = false):
                    set round_deaths_blue = round_deaths_blue + 1
                    IncrementTrackerForBoth(RedKillsTracker)
                    set red_kills = red_kills + 1
                    OnRoundTimeout()
                    return

                if (gone_red = true and gone_blue = false):
                    set round_deaths_red = round_deaths_red + 1
                    IncrementTrackerForBoth(BlueKillsTracker)
                    set blue_kills = blue_kills + 1
                    OnRoundTimeout()
                    return

            if (RoundRemaining <= 0.0):
                break

            Sleep(step)
            set RoundRemaining = RoundRemaining - step
            if (RoundRemaining < 0.0):
                set RoundRemaining = 0.0

        if (marker = round_token):
            OnRoundTimeout()

    CleanArenaReset():void =
        set SFXCooldownToken = SFXCooldownToken + 1
        set SFXCooldownActive = false
        set HUDCooldownTokenA = HUDCooldownTokenA + 1
        set HUDCooldownActiveA = false
        set HUDCooldownTokenB = HUDCooldownTokenB + 1
        set HUDCooldownActiveB = false

        if (EnableAutoResetCleanup = true and EnableElimItemRemovalEff = true):
            ApplyElimItemRemoversBoth()

    ScheduleAutoNextRound():void =
        if (EnableAutoNextRoundAfterTimeout = false):
            return
        if (RoundSecondsClamped <= 0.0):
            return
        set round_restart_pending = false
        set AutoNextRoundToken = AutoNextRoundToken + 1
        tok := AutoNextRoundToken
        old_round := round_token
        spawn { IntermissionThenStartNextRound(tok, old_round) }

    IntermissionThenStartNextRound(Token:int, OldRound:int)<suspends>:void =
        var d:float = IntermissionClamped
        if (d < 0.0):
            set d = 0.0
        Sleep(d)
        if (Token = AutoNextRoundToken and round_token = OldRound):
            StartNewRound()

    OnRoundTimeout()<suspends>:void =
        if (round_end_pending = true):
            return

        set round_end_pending = true
        set RoundEndToken = RoundEndToken + 1

        set IntermissionActive = true
        JumpScare.SetIntermissionActive(true)

        # Intermission notice HUD to both players (static message)
        if (A0 := player_a?):
            ShowHUDTo(IntermissionHUD, A0)
        if (B0 := player_b?):
            ShowHUDTo(IntermissionHUD, B0)

        set tp_pending_a = false
        set tp_pending_b = false

        if ((round_deaths_blue + round_deaths_red) = 0):
            if (P0 := player_a?):
                BlueTeleporter.Teleport(P0)
            if (Q0 := player_b?):
                RedTeleporter.Teleport(Q0)
            set RoundRemaining = 0.0
            CleanArenaReset()
            Streaks.Reset()
            ScheduleAutoNextRound()
            return

        if (EnablePerfectRoundCelebration = true):
            CheckPerfectRoundAndAward()

        if (EnableFinishersEff = true):
            blueDeaths := round_deaths_blue
            redDeaths  := round_deaths_red
            if (blueDeaths < redDeaths):
                if (A := player_a?):
                    WinSFX.Play()
                    WinVFX.Pickup(A)
                if (B := player_b?):
                    LoseSFX.Play()
                    LoseVFX.Pickup(B)
            else:
                if (redDeaths < blueDeaths):
                    if (B2 := player_b?):
                        WinSFX.Play()
                        WinVFX.Pickup(B2)
                    if (A2 := player_a?):
                        LoseSFX.Play()
                        LoseVFX.Pickup(A2)

        if (P := player_a?):
            BlueTeleporter.Teleport(P)
        if (Q := player_b?):
            RedTeleporter.Teleport(Q)
        set RoundRemaining = 0.0
        CleanArenaReset()
        Streaks.Reset()

        ScheduleAutoNextRound()

    ApplyElimVFXPowerups(Victim:agent):void =
        if (LenVFX <= 0):
            return
        for (P : ElimVFXPowerup):
            P.Pickup(Victim)

    TriggerElimExplosives(Victim:agent):void =
        if (LenExplosives <= 0):
            return
        for (E : ElimExplosives):
            E.Explode(Victim)

    IncrementTrackerForBoth(T:tracker_device):void =
        if (Pa := player_a?):
            T.Increment(Pa)
        if (Pb := player_b?):
            T.Increment(Pb)

    CheckPerfectRoundAndAward():void =
        total := round_deaths_blue + round_deaths_red
        if (total <= 0):
            return
        if (round_deaths_blue = 0 and round_deaths_red > 0):
            if (P := player_a?):
                AccPerfectRound.Award(P)
                ShowHUDTo(HUDPerfectRound, P)
            return
        if (round_deaths_red = 0 and round_deaths_blue > 0):
            if (Q := player_b?):
                AccPerfectRound.Award(Q)
                ShowHUDTo(HUDPerfectRound, Q)

    PlayNextElimSFX():void =
        if (LenElimSFX <= 0):
            return
        if (SFXCooldownClamped > 0.0 and SFXCooldownActive = true):
            return
        if (sfx_next >= LenElimSFX):
            set sfx_next = 0
        var i:int = 0
        for (Dev : ElimSFX):
            if (i = sfx_next):
                Dev.Play()
            set i = i + 1
        set sfx_next = sfx_next + 1
        if (SFXCooldownClamped > 0.0):
            if (SFXCooldownActive = false):
                set SFXCooldownActive = true
                set SFXCooldownToken = SFXCooldownToken + 1
                tok := SFXCooldownToken
                spawn { SFXCooldownTask(tok) }

    SFXCooldownTask(Token:int)<suspends>:void =
        Sleep(SFXCooldownClamped)
        if (Token = SFXCooldownToken):
            set SFXCooldownActive = false

    ClearPlayerRefsIfLeft():void =
        if (A := player_a?):
            if (Pa := player[A]):
                set player_a_pl = option{Pa}
            else:
                set player_a = false
                set player_a_pl = false
                set first_spawn_awarded_a = false
                PlayerRefBlue.Clear()

        if (B := player_b?):
            if (Pb := player[B]):
                set player_b_pl = option{Pb}
            else:
                set player_b = false
                set player_b_pl = false
                set first_spawn_awarded_b = false
                PlayerRefRed.Clear()

    # Spawn accolade helper
    MaybeAwardSpawnAccolade(Side:int, Who:agent):void =
        if (EnableAccoladeOnSpawn = false):
            return

        mode := AccOnSpawnMode  # 0=Every Spawn, 1=Once/Round, 2=Once/Match

        if (Side = 1):
            if (mode = 2 and spawn_acc_awarded_match_blue = true):
                return
            if (mode = 1 and spawn_acc_awarded_round_blue = true):
                return
            AccOnSpawnBlue.Award(Who)
            set spawn_acc_awarded_round_blue = true
            set spawn_acc_awarded_match_blue = true
            return

        if (Side = 2):
            if (mode = 2 and spawn_acc_awarded_match_red = true):
                return
            if (mode = 1 and spawn_acc_awarded_round_red = true):
                return
            AccOnSpawnRed.Award(Who)
            set spawn_acc_awarded_round_red = true
            set spawn_acc_awarded_match_red = true
