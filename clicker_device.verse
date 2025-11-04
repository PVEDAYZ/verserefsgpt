using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }

clicker_device := class(creative_device):

    @editable GameManager : game_manager = game_manager{}
    @editable Prop : creative_prop = creative_prop{}
    @editable PropManipulator : prop_manipulator_device = prop_manipulator_device{}
    @editable AudioPlayer : audio_player_device = audio_player_device{}
    @editable AccoladeA : accolades_device = accolades_device{}
    @editable AccoladeB : accolades_device = accolades_device{}
    @editable Analytics : analytics_device = analytics_device{}

    @editable Resource : string = "Money"
    @editable Amount : int = 0

    # --- Second resource (optional) ---
    @editable UseSecondResource : logic = false
    @editable Resource2 : string = "Money"
    @editable Amount2 : int = 0

    @editable AnimationScaleAmount : float = 0.85
    @editable AnimationScaleTime   : float = 0.08

    # ---- Optional extra accolades (leave empty to no-op) ----
    @editable HitAccolades : []accolades_device = array{}             # every valid hit
    @editable ComboAccolades : []accolades_device = array{}           # when ComboTarget reached
    @editable MilestoneAccolades : []accolades_device = array{}       # every HitsPerMilestone hits
    @editable AmountAccolades : []accolades_device = array{}          # each time total granted crosses AmountPerMilestone

    @editable ComboTarget : int = 5                                   # award after N consecutive hits (resets to 0 each award)
    @editable HitsPerMilestone : int = 25                              # award every N hits (threshold-and-reset, no modulo)
    @editable AmountPerMilestone : int = 1000                          # award every N currency granted by this device

    var AnimationKeyFrames : []keyframe_delta = array{}
    var NextIsA : logic = true

    # counters for optional accolades
    var HitCounter : int = 0
    var ComboCount : int = 0
    var MilestoneCounter : int = 0
    var AccumulatedAmount : int = 0

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>: void =
        Print("clicker_device: OnBegin - enabling devices and wiring events.")
        PropManipulator.Enable()
        PropManipulator.DamagedEvent.Subscribe(OnPropDamaged)
        Print("clicker_device: Subscribed to PropManipulator.DamagedEvent.")

        AccoladeA.Enable()
        AccoladeB.Enable()
        AudioPlayer.Enable()
        Analytics.Enable()
        Print("clicker_device: Accolades/Audio/Analytics enabled.")

        TargetScale : float = AnimationScaleAmount
        InverseTargetScale : float = if (AnimationScaleAmount = 0.0) then 1.0 else 1.0 / AnimationScaleAmount

        DownScaleKeyFrame : keyframe_delta = keyframe_delta{
            DeltaLocation := vector3{X := 0.0, Y := 0.0, Z := 0.0}
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3{X := TargetScale, Y := TargetScale, Z := TargetScale}
            Time := AnimationScaleTime
            Interpolation := EaseIn
        }
        UpScaleKeyFrame : keyframe_delta = keyframe_delta{
            DeltaLocation := vector3{X := 0.0, Y := 0.0, Z := 0.0}
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3{X := InverseTargetScale, Y := InverseTargetScale, Z := InverseTargetScale}
            Time := AnimationScaleTime
            Interpolation := EaseIn
        }

        set AnimationKeyFrames = array{DownScaleKeyFrame, UpScaleKeyFrame}
        Print("clicker_device: AnimationKeyFrames prepared (count={AnimationKeyFrames.Length}).")

    # Method to handle prop damage (and award accolades)
    OnPropDamaged(Agent : agent): void =
        # Give primary resource
        GiveResource(Agent, Resource, Amount)
        # Optionally give second resource
        if(UseSecondResource?):
            GiveResource(Agent, Resource2, Amount2)

        # Optional accolades: per-hit
        AwardAccolades(option{Agent}, HitAccolades)

        # Update counters for optional accolades
        set HitCounter += 1
        set ComboCount += 1
        set MilestoneCounter += 1

        # Amount-based progress only counts money grants
        if(Resource = "Money"):
            set AccumulatedAmount += Amount
        if(UseSecondResource? and Resource2 = "Money"):
            set AccumulatedAmount += Amount2

        # Optional: combo award after N consecutive hits (reset to 0 after award)
        if(ComboTarget > 0 and ComboCount >= ComboTarget):
            AwardAccolades(option{Agent}, ComboAccolades)
            set ComboCount = 0

        # Optional: milestone award every N hits (threshold-and-reset; no modulo)
        if(HitsPerMilestone > 0 and MilestoneCounter >= HitsPerMilestone):
            AwardAccolades(option{Agent}, MilestoneAccolades)
            set MilestoneCounter = 0

        # Optional: amount-based milestone (trigger once per threshold crossed)
        if(AmountPerMilestone > 0):
            loop:
                if(AccumulatedAmount >= AmountPerMilestone):
                    AwardAccolades(option{Agent}, AmountAccolades)
                    set AccumulatedAmount -= AmountPerMilestone
                else:
                    break

        # Handle accolades (alternate between AccoladeA and AccoladeB)
        if(NextIsA?):
            Print("clicker_device: Award path = AccoladeA.")
            AccoladeA.Award(Agent)
            set NextIsA = false
        else:
            Print("clicker_device: Award path = AccoladeB.")
            AccoladeB.Award(Agent)
            set NextIsA = true

        # Play audio on hit
        AudioPlayer.Play(Agent)

        # Send analytics data
        Analytics.Submit(Agent)
        Print("clicker_device: Analytics.Submit called.")

        # Handle animation (if animation controller exists)
        if(PropAnimController := Prop.GetAnimationController[]):
            AnimState := PropAnimController.GetState()
            if(AnimState = animation_controller_state.AnimationNotSet or AnimState = animation_controller_state.Stopped):
                PropAnimController.SetAnimation(AnimationKeyFrames, ?Mode := animation_mode.OneShot)
                PropAnimController.Play()
                Print("clicker_device: OneShot animation set and played.")
            else:
                Print("clicker_device: Animation already active; leaving as-is.")
        else:
            Print("clicker_device: WARNING - Prop has no AnimationController.")

    # --------------- Helpers ---------------
    GiveResource(Agent : agent, RName : string, Amt : int):void=
        if(Amt = 0):
            return
        if(RName = "Money"):
            GameManager.AddMoney(Amt, Agent)
            GameManager.ShowMoney(Amt, Agent)
        else if(RName = "Customers"):
            GameManager.AddCustomers(Amt, Agent)
        else:
            # Unknown resource label: no-op (safe)
            Print("clicker_device: Unknown resource '{RName}', amount {Amt} — skipped.")

    AwardAccolades(MaybeAgent : ?agent, List : []accolades_device):void=
        if(List.Length = 0):
            return
        if(Agent := MaybeAgent?):
            for(A : List):
                A.Award(Agent)
