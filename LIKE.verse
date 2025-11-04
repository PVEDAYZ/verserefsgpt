using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

fav_like_hud := class(creative_device):

    @editable ShowOnRoundStart : logic = true
    @editable ShowOnMilestone  : logic = true
    @editable MilestoneStep    : int   = 10
    @editable DEBUG            : logic = false

    @editable RoundStartHUD    : hud_message_device           = hud_message_device{}
    @editable MilestoneHUD     : hud_message_device           = hud_message_device{}
    @editable RoundStartSFX    : audio_player_device          = audio_player_device{}
    @editable MilestoneSFX     : audio_player_device          = audio_player_device{}
    @editable RoundStartVFX    : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable MilestoneVFX     : visual_effect_powerup_device = visual_effect_powerup_device{}

    @editable MilestoneAccolade : accolades_device  = accolades_device{}
    @editable MilestoneTrigger  : trigger_device    = trigger_device{}
    @editable MilestoneTracker  : tracker_device    = tracker_device{}

    var StepClamped     : int   = 10
    var NextMilestone   : int   = 10
    var assigned_blue   : logic = false
    var assigned_red    : logic = false

    Log(S:string):void =
        if (DEBUG = true):
            Print(S)

    OnBegin<override>()<suspends>:void =
        set StepClamped = MilestoneStep
        if (StepClamped < 1):
            set StepClamped = 10
        set NextMilestone = StepClamped

    EnsureTrackerAssigned(Blue:?agent, Red:?agent):void =
        if (B := Blue?):
            if (assigned_blue = false):
                MilestoneTracker.Assign(B)
                set assigned_blue = true
        if (R := Red?):
            if (assigned_red = false):
                MilestoneTracker.Assign(R)
                set assigned_red = true

    ShowRoundStart(Blue:?agent, Red:?agent):void =
        if (ShowOnRoundStart = false):
            return

        set NextMilestone = StepClamped
        set assigned_blue = false
        set assigned_red  = false
        EnsureTrackerAssigned(Blue, Red)

        var played:logic = false

        if (B := Blue?):
            RoundStartHUD.Show(B)
            if (played = false):
                RoundStartSFX.Play()
                set played = true
            RoundStartVFX.Pickup(B)

        if (R := Red?):
            RoundStartHUD.Show(R)
            if (played = false):
                RoundStartSFX.Play()
                set played = true
            RoundStartVFX.Pickup(R)

    NotifyTotalElims(Total:int, Blue:?agent, Red:?agent):void =
        if (ShowOnMilestone = false):
            return
        if (StepClamped <= 0):
            return

        if (Total >= NextMilestone):
            EnsureTrackerAssigned(Blue, Red)

            if (B := Blue?):
                MilestoneHUD.Show(B)
                MilestoneSFX.Play()
                MilestoneVFX.Pickup(B)
                MilestoneAccolade.Award(B)
                MilestoneTracker.Increment(B)

            if (R := Red?):
                MilestoneHUD.Show(R)
                MilestoneSFX.Play()
                MilestoneVFX.Pickup(R)
                MilestoneAccolade.Award(R)
                MilestoneTracker.Increment(R)

            MilestoneTrigger.Trigger()
            set NextMilestone = NextMilestone + StepClamped
