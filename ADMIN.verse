using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

admin_control_bridge := class(creative_device):

    # --- Target baseline controller (select your placed instance) ---
    @editable Baseline : one_v_one_elim_tp = one_v_one_elim_tp{}

    # --- Admin buttons (wire these to your legacy Admin panel UI/buttons) ---
    @editable SoftResetButton     : button_device = button_device{}   # Clean + New Round
    @editable SkipRoundButton     : button_device = button_device{}   # Force round timeout
    @editable StartNewRoundButton : button_device = button_device{}   # Start a fresh round
    @editable CleanOnlyButton     : button_device = button_device{}   # Clean without starting

    OnBegin<override>()<suspends>:void =
        SoftResetButton.InteractedWithEvent.Subscribe(OnSoftResetPressed)
        SkipRoundButton.InteractedWithEvent.Subscribe(OnSkipRoundPressed)
        StartNewRoundButton.InteractedWithEvent.Subscribe(OnStartNewRoundPressed)
        CleanOnlyButton.InteractedWithEvent.Subscribe(OnCleanOnlyPressed)

    # --- Handlers ---
    OnSoftResetPressed(Presser:agent):void =
        # Clean the arena state and immediately begin a new round
        Baseline.CleanArenaReset()
        Baseline.StartNewRound()

    OnSkipRoundPressed(Presser:agent):void =
        # Use the baseline's safe timeout path (teleports, finishers, etc.)
        spawn { Baseline.OnRoundTimeout() }

    OnStartNewRoundPressed(Presser:agent):void =
        Baseline.StartNewRound()

    OnCleanOnlyPressed(Presser:agent):void =
        Baseline.CleanArenaReset()
