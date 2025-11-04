using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

duel_streaks_manager := class(creative_device):

    @editable UseShortStreaks : logic = false
    @editable DEBUG           : logic = false

    @editable Streak1SFX     : audio_player_device          = audio_player_device{}
    @editable Streak2SFX     : audio_player_device          = audio_player_device{}
    @editable Streak3SFX     : audio_player_device          = audio_player_device{}
    @editable Streak1VFX     : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable Streak2VFX     : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable Streak3VFX     : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable Streak1Trigger : trigger_device               = trigger_device{}
    @editable Streak2Trigger : trigger_device               = trigger_device{}
    @editable Streak3Trigger : trigger_device               = trigger_device{}
    @editable Streak1HUD     : hud_message_device           = hud_message_device{}
    @editable Streak2HUD     : hud_message_device           = hud_message_device{}
    @editable Streak3HUD     : hud_message_device           = hud_message_device{}

    @editable AccStreak1     : accolades_device             = accolades_device{}
    @editable AccStreak2     : accolades_device             = accolades_device{}
    @editable AccStreak3     : accolades_device             = accolades_device{}
    @editable AccBackToBack  : accolades_device             = accolades_device{}
    @editable AccShutdowns   : []accolades_device           = array{}

    var BlueElimStreak : int   = 0
    var RedElimStreak  : int   = 0
    var last_side      : int   = 0

    var T1 : int = 3
    var T2 : int = 6
    var T3 : int = 9

    var LenShutdowns : int = 0

    Log(S:string):void =
        if (DEBUG = true):
            Print(S)

    OnBegin<override>()<suspends>:void =
        if (UseShortStreaks = true):
            set T1 = 1
            set T2 = 2
            set T3 = 3
        else:
            set T1 = 3
            set T2 = 6
            set T3 = 9
        set LenShutdowns = AccShutdowns.Length

    Reset():void =
        set BlueElimStreak = 0
        set RedElimStreak  = 0
        set last_side      = 0

    # --- Public getters for admin panel ---
    GetLastSide():int = last_side
    GetBlueStreak():int = BlueElimStreak
    GetRedStreak():int = RedElimStreak

    OnKill(Scorer:agent, ScorerSide:int):void =
        if (ScorerSide = 1):
            prev_opponent := RedElimStreak
            set BlueElimStreak = BlueElimStreak + 1
            set RedElimStreak  = 0
            if (last_side = 1):
                AccBackToBack.Award(Scorer)
            set last_side = 1
            AwardShutdowns(prev_opponent, Scorer)
            HandleTierRewards(Scorer, 1, BlueElimStreak)
            return

        if (ScorerSide = 2):
            prev_opponent2 := BlueElimStreak
            set RedElimStreak  = RedElimStreak + 1
            set BlueElimStreak = 0
            if (last_side = 2):
                AccBackToBack.Award(Scorer)
            set last_side = 2
            AwardShutdowns(prev_opponent2, Scorer)
            HandleTierRewards(Scorer, 2, RedElimStreak)

    AwardShutdowns(prev:int, scorer:agent):void =
        if (prev <= 0):
            return
        if (LenShutdowns <= 0):
            return
        var idx:int = prev
        if (idx > LenShutdowns):
            set idx = LenShutdowns
        var i:int = 0
        for (ADev : AccShutdowns):
            set i = i + 1
            if (i = idx):
                ADev.Award(scorer)
                return

    HandleTierRewards(Scorer:agent, Side:int, Count:int):void =
        if (Count = T1):
            Streak1SFX.Play()
            Streak1VFX.Pickup(Scorer)
            Streak1Trigger.Trigger()
            AccStreak1.Award(Scorer)
            Streak1HUD.Show(Scorer)
            return

        if (Count = T2):
            Streak2SFX.Play()
            Streak2VFX.Pickup(Scorer)
            Streak2Trigger.Trigger()
            AccStreak2.Award(Scorer)
            Streak2HUD.Show(Scorer)
            return

        if (Count = T3):
            Streak3SFX.Play()
            Streak3VFX.Pickup(Scorer)
            Streak3Trigger.Trigger()
            AccStreak3.Award(Scorer)
            Streak3HUD.Show(Scorer)
            if (Side = 1):
                set BlueElimStreak = 0
            else:
                if (Side = 2):
                    set RedElimStreak = 0
