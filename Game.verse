# one_v_one_elim_tp.verse
# Purpose: 1v1 elimination + teleport round manager with perf guards and HUD/streaks.
# Change log (2025-10-29):
# - Trackers: Assign only on each player’s first spawn (redundancy fix).
# - TeleportAfterRespawn: presence check uses capture pattern (compile-safe).

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }

one_v_one_elim_tp := class(creative_device):

    # ----------------------------
    # Devices
    # ----------------------------
    @editable BlueSpawner      : player_spawner_device      = player_spawner_device{}
    @editable RedSpawner       : player_spawner_device      = player_spawner_device{}
    @editable BlueTeleporter   : teleporter_device          = teleporter_device{}
    @editable RedTeleporter    : teleporter_device          = teleporter_device{}
    @editable BlueKillsTracker : tracker_device             = tracker_device{}
    @editable RedKillsTracker  : tracker_device             = tracker_device{}
    @editable Elims            : elimination_manager_device = elimination_manager_device{}

    # Fall-elimination volume (Damage Volume)
    @editable FallDamageVolume : damage_volume_device       = damage_volume_device{}

    # Per-elimination effects
    @editable ElimSFX          : []audio_player_device            = array{}
    @editable ElimVFXPowerup   : []visual_effect_powerup_device   = array{}
    @editable ElimExplosives   : []explosive_device               = array{}
    @editable ElimItemRemovers : []item_remover_device            = array{}

    # Manual explode button (press to detonate ElimExplosives)
    @editable ExplodeOnInteractButton : button_device              = button_device{}

    # Toggles / perf gates
    @editable EnablePerElimSFX            : logic = true
    @editable EnableAutoTeleportAfterElim : logic = true
    @editable TeleportDelaySeconds        : float = 0.15
    @editable EnableElimVFX               : logic = true
    @editable EnableElimExplosives        : logic = true
    @editable EnableElimItemRemoval       : logic = true
    @editable EnableTeleportGrants        : logic = true
    @editable SFXCooldownSeconds          : float = 0.25

    # Central HUD control (anti-spam)
    @editable EnableHUDAnnouncements      : logic = true
    @editable HUDCooldownSeconds          : float = 0.75

    # Lead-change HUD
    @editable HUDLeadYouBlue  : hud_message_device = hud_message_device{}
    @editable HUDLeadYouRed   : hud_message_device = hud_message_device{}
    @editable HUDLeadTheyBlue : hud_message_device = hud_message_device{}
    @editable HUDLeadTheyRed  : hud_message_device = hud_message_device{}

    # End-of-series finishers
    @editable EnableFinishers : logic                = true
    @editable WinSFX          : audio_player_device  = audio_player_device{}
    @editable WinVFX          : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable LoseSFX         : audio_player_device  = audio_player_device{}
    @editable LoseVFX         : visual_effect_powerup_device = visual_effect_powerup_device{}

    # First Blood / Perfect Round
    @editable AccFirstBlood    : accolades_device   = accolades_device{}
    @editable HUDFirstBlood    : hud_message_device = hud_message_device{}
    @editable AccPerfectRound  : accolades_device   = accolades_device{}
    @editable HUDPerfectRound  : hud_message_device = hud_message_device{}
    @editable AccTakeLead      : accolades_device   = accolades_device{}

    # Teleport item grants
    @editable TeleportGranters : []item_granter_device = array{}   # Only first 5 used

    # Killstreak manager device
    @editable Streaks          : duel_streaks_manager = duel_streaks_manager{}

    # Designer toggles
    @editable EnableSpawnCampMitigation        : logic = true
    @editable SpawnCampRemovalWindowSeconds    : float = 1.25
    @editable EnableDespawnForfeit             : logic = true

    # Round timer
    @editable RoundSeconds : float = 0.0
    @editable RoundTickHz  : float = 1.0

    # ----------------------------
    # Internal state
    # ----------------------------
    var player_a          : ?agent = false
    var player_b          : ?agent = false

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

    # Cached/clamped
    var TeleportDelayClamped : float = 0.15
    var RoundSecondsClamped  : float = 0.0
    var SFXCooldownClamped   : float = 0.0
    var HUDCooldownClamped   : float = 0.0
    var RoundTickHzClamped   : float = 1.0
    var RoundTickStepClamped : float = 1.0

    # Cached spawn-camp window (0..3s) and effective toggles
    var SpawnCampRemovalWindowClamped : float = 0.0
    var EnableElimVFXEff              : logic = false
    var EnableElimExplosivesEff       : logic = false
    var EnableElimItemRemovalEff      : logic = false
    var EnableSpawnCampMitigationEff  : logic = false

    var TeleportGrantersToUse : int   = 0

    # SFX cooldown (tokenized)
    var SFXCooldownActive : logic = false
    var SFXCooldownToken  : int   = 0

    # HUD cooldown (for frequent messages)
    var HUDCooldownActive : logic = false
    var HUDCooldownToken  : int   = 0

    # Perf flags
    var tp_pending_a      : logic = false
    var tp_pending_b      : logic = false

    var round_restart_pending  : logic = false
    var RestartDebounceSeconds : float = 0.05

    # Cached lengths
    var LenElimSFX       : int   = 0
    var LenVFX           : int   = 0
    var LenExplosives    : int   = 0
    var LenRemovers      : int   = 0

    # Coarse shared step + coalesced removal window
    var SharedSleepStep           : float = 1.0
    var removal_window_active     : logic = false
    var removal_window_remaining  : float = 0.0

    # Ensure round end executes once
    var round_end_pending : logic = false

    # ---------- HUD helper (block form) ----------
    ShowHUDTo(H:hud_message_device, To:agent):void =
        if (EnableHUDAnnouncements = false):
            return

        if (HUDCooldownClamped > 0.0 and HUDCooldownActive = true):
            return

        H.Show(To)

        if (HUDCooldownClamped > 0.0 and HUDCooldownActive = false):
            set HUDCooldownActive = true
            set HUDCooldownToken = HUDCooldownToken + 1
            tok := HUDCooldownToken
            spawn { HUDCooldownTask(tok) }

    HUDCooldownTask(Token:int)<suspends>:void =
        Sleep(HUDCooldownClamped)
        if (Token = HUDCooldownToken):
            set HUDCooldownActive = false

    # ---------- Begin ----------
    OnBegin<override>()<suspends>:void =
        # Clamp designer editables (never mutate @editable at runtime)
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

        # Clamp tick rate into safe band [0.25, 5.0] Hz
        set RoundTickHzClamped = RoundTickHz
        if (RoundTickHzClamped < 0.25):
            set RoundTickHzClamped = 0.25
        if (RoundTickHzClamped > 5.0):
            set RoundTickHzClamped = 5.0
        set RoundTickStepClamped = 1.0 / RoundTickHzClamped

        # Shared sleep with floor
        set SharedSleepStep = RoundTickStepClamped
        if (SharedSleepStep < 0.1):
            set SharedSleepStep = 0.1

        # Clamp mitigation window (0..3s) into cached value
        set SpawnCampRemovalWindowClamped = SpawnCampRemovalWindowSeconds
        if (SpawnCampRemovalWindowClamped < 0.0):
            set SpawnCampRemovalWindowClamped = 0.0
        if (SpawnCampRemovalWindowClamped > 3.0):
            set SpawnCampRemovalWindowClamped = 3.0

        # Cache lengths once
        set LenElimSFX    = ElimSFX.Length
        set LenVFX        = ElimVFXPowerup.Length
        set LenExplosives = ElimExplosives.Length
        set LenRemovers   = ElimItemRemovers.Length

        # Compute effective toggles (feature enabled AND devices bound)
        set EnableElimVFXEff             = EnableElimVFX
        if (LenVFX <= 0):
            set EnableElimVFXEff = false

        set EnableElimExplosivesEff      = EnableElimExplosives
        if (LenExplosives <= 0):
            set EnableElimExplosivesEff = false

        set EnableElimItemRemovalEff     = EnableElimItemRemoval
        if (LenRemovers <= 0):
            set EnableElimItemRemovalEff = false

        set EnableSpawnCampMitigationEff = EnableSpawnCampMitigation
        if (SpawnCampRemovalWindowClamped <= 0.0 or LenRemovers <= 0):
            set EnableSpawnCampMitigationEff = false

        # Granter trim
        len_granters := TeleportGranters.Length
        set TeleportGrantersToUse = len_granters
        if (TeleportGrantersToUse > 5):
            set TeleportGrantersToUse = 5

        BlueSpawner.SpawnedEvent.Subscribe(OnSpawnFromA)
        RedSpawner.SpawnedEvent.Subscribe(OnSpawnFromB)

        BlueTeleporter.TeleportedEvent.Subscribe(OnTeleported)
        RedTeleporter.TeleportedEvent.Subscribe(OnTeleported)

        # Button → explode explosives
        ExplodeOnInteractButton.InteractedWithEvent.Subscribe(OnExplodeButton)

        # Damage volume → eliminate entering duelist (agent-arg handler)
        FallDamageVolume.AgentEntersEvent.Subscribe(OnDamageVolumeEntered)

        spawn { ElimLoop() }

    # ---------- Spawns ----------
    OnSpawnFromA(Spawned:agent):void =
        set player_a = option{Spawned}
        # Assign trackers once per player (first spawn only)
        if (first_spawn_awarded_a = false):
            BlueKillsTracker.Assign(Spawned)
            RedKillsTracker.Assign(Spawned)
            set first_spawn_awarded_a = true
        if (RoundSecondsClamped > 0.0 and player_b? and round_token = 0):
            RequestRoundRestart()

    OnSpawnFromB(Spawned:agent):void =
        set player_b = option{Spawned}
        # Assign trackers once per player (first spawn only)
        if (first_spawn_awarded_b = false):
            BlueKillsTracker.Assign(Spawned)
            RedKillsTracker.Assign(Spawned)
            set first_spawn_awarded_b = true
        if (RoundSecondsClamped > 0.0 and player_a? and round_token = 0):
            RequestRoundRestart()

    # ---------- Teleport hook ----------
    OnTeleported(Who:agent):void =
        if (EnableTeleportGrants = true):
            if (A := player_a?):
                GrantTeleportLoadout(A)
            if (B := player_b?):
                GrantTeleportLoadout(B)

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

    # ---------- Manual explode handler ----------
    OnExplodeButton(Presser:agent):void =
        if (EnableElimExplosivesEff = false):
            return
        TriggerElimExplosives(Presser)

    # ---------- Damage volume handler (instant elim) ----------
    OnDamageVolumeEntered(Entered:agent):void =
        # Only eliminate active duelists; ignore others/spectators
        if (P := player[Entered]):
            if (A := player_a?):
                if (Ap := player[A], Ap = P):
                    Elims.Enable()
                    return
            if (B := player_b?):
                if (Bp := player[B], Bp = P):
                    Elims.Enable()

    # ---------- Main elim loop ----------
    ElimLoop()<suspends>:void =
        loop:
            Victim:agent = Elims.EliminatedEvent.Await()

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

            # Coalesced spawn-camp removal window
            if (EnableSpawnCampMitigationEff = true):
                MaybeExtendRemovalWindow(SpawnCampRemovalWindowClamped)

            # Per-round death tallies
            if (A := player_a?, Victim = A):
                set round_deaths_blue = round_deaths_blue + 1
            else:
                if (B := player_b?, Victim = B):
                    set round_deaths_red = round_deaths_red + 1

            # Team kill counters + streak manager + lead-change HUD + FIRST BLOOD
            HandleScoringAndStreaks(Victim)

            RequestRoundRestart()

    HandleScoringAndStreaks(Victim:agent):void =
        # Early bail if duelists missing
        if (not (player_a? and player_b?)):
            return

        # Red scores if Blue dies
        if (A := player_a?, Victim = A):
            if (Scorer := player_b?):
                IncrementTrackerForBoth(RedKillsTracker)
                set red_kills = red_kills + 1

                # FIRST BLOOD (once per round)
                if (round_first_blood_awarded = false):
                    set round_first_blood_awarded = true
                    AccFirstBlood.Award(Scorer)
                    ShowHUDTo(HUDFirstBlood, Scorer)

                # Killstreak manager (Red side = 2)
                Streaks.OnKill(Scorer, 2)

                # Lead change: red moved ahead from tie
                if (red_kills > blue_kills and (red_kills - 1) = blue_kills):
                    AccTakeLead.Award(Scorer)
                    ShowHUDTo(HUDLeadYouRed, Scorer)
                    if (Opp := player_a?):
                        ShowHUDTo(HUDLeadTheyBlue, Opp)
            return

        # Blue scores if Red dies
        if (B := player_b?, Victim = B):
            if (Scorer2 := player_a?):
                IncrementTrackerForBoth(BlueKillsTracker)
                set blue_kills = blue_kills + 1

                # FIRST BLOOD (once per round)
                if (round_first_blood_awarded = false):
                    set round_first_blood_awarded = true
                    AccFirstBlood.Award(Scorer2)
                    ShowHUDTo(HUDFirstBlood, Scorer2)

                # Killstreak manager (Blue side = 1)
                Streaks.OnKill(Scorer2, 1)

                if (blue_kills > red_kills and (blue_kills - 1) = red_kills):
                    AccTakeLead.Award(Scorer2)
                    ShowHUDTo(HUDLeadYouBlue, Scorer2)
                    if (Opp2 := player_b?):
                        ShowHUDTo(HUDLeadTheyRed, Opp2)

    # ---------- Coalesced spawn-camp removal ----------
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

    # ---------- Perf #2 coalesced teleport ----------
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

    TeleportAfterRespawn(ElimAgent:agent, Side:int)<suspends>:void =
        var Delay:float = TeleportDelayClamped
        Dest:teleporter_device = ChooseTeleporterFor(ElimAgent)
        Sleep(Delay)

        # Redundant/invalid teleport guards
        if (Side = 1 and tp_pending_a = false):
            return
        if (Side = 2 and tp_pending_b = false):
            return

        # Compile-safe presence capture
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

    ChooseTeleporterFor(A:agent):teleporter_device =
        if (P := player_a?, A = P):
            return BlueTeleporter
        if (Q := player_b?, A = Q):
            return RedTeleporter
        return BlueTeleporter

    # ---------- Round flow (debounced + coarse tick) ----------
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
        set round_end_pending = false
        CleanArenaReset()
        set round_first_blood_awarded = false
        set round_deaths_blue = 0
        set round_deaths_red  = 0
        Streaks.Reset()
        set round_token = round_token + 1
        this_round := round_token
        if (RoundSecondsClamped > 0.0):
            set RoundRemaining = RoundSecondsClamped
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

            if (EnableDespawnForfeit = true):
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
        set HUDCooldownToken = HUDCooldownToken + 1
        set HUDCooldownActive = false
        ApplyElimItemRemoversBoth()

    OnRoundTimeout()<suspends>:void =
        if (round_end_pending = true):
            return
        set round_end_pending = true

        # Empty-series skip (no deaths)
        if ((round_deaths_blue + round_deaths_red) = 0):
            if (P0 := player_a?):
                BlueTeleporter.Teleport(P0)
            if (Q0 := player_b?):
                RedTeleporter.Teleport(Q0)
            set RoundRemaining = 0.0
            CleanArenaReset()
            Streaks.Reset()
            return

        CheckPerfectRoundAndAward()

        if (EnableFinishers = true):
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

    # ---------- Other helpers ----------
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
