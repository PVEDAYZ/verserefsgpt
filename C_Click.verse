using { /Fortnite.com/Devices }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

clicker_prop_device := class(creative_device):

    @editable PropManipulator : prop_manipulator_device = prop_manipulator_device{}
    @editable ClickerProp : creative_prop = creative_prop{}
    @editable ItemGranter : item_granter_device = item_granter_device{}
    @editable AccoladeA : accolades_device = accolades_device{}
    @editable AccoladeB : accolades_device = accolades_device{}
    @editable HitSound : audio_player_device = audio_player_device{}
    @editable Analytics : analytics_device = analytics_device{}

    @editable AnimationScaleAmount : float = 0.85
    @editable AnimationScaleTime   : float = 0.08

    var NextIsA : logic = true
    var AnimationKeyFrames : []keyframe_delta = array{}

    OnBegin<override>()<suspends> : void =
        Print("clicker_prop_device: OnBegin - enabling devices and wiring events.")
        PropManipulator.Enable()
        PropManipulator.DamagedEvent.Subscribe(OnPropDamaged)
        Print("clicker_prop_device: Subscribed to PropManipulator.DamagedEvent.")

        AccoladeA.Enable()
        AccoladeB.Enable()
        HitSound.Enable()
        Analytics.Enable()
        Print("clicker_prop_device: Accolades/Audio/Analytics enabled.")

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
        Print("clicker_prop_device: AnimationKeyFrames prepared (count={AnimationKeyFrames.Length}).")
    
    OnPropDamaged(Agent : agent) : void =
        ItemGranter.GrantItem(Agent)
        HitSound.Play()

        if (NextIsA?):
            Print("clicker_prop_device: Award path = AccoladeA.")
            AccoladeA.Award(Agent)
            set NextIsA = false
        else:
            Print("clicker_prop_device: Award path = AccoladeB.")
            AccoladeB.Award(Agent)
            set NextIsA = true

        Analytics.Submit(Agent)
        Print("clicker_prop_device: Analytics.Submit called.")

        if (PropAnimController := ClickerProp.GetAnimationController[]):
            AnimState := PropAnimController.GetState()
            if (AnimState = animation_controller_state.AnimationNotSet or AnimState = animation_controller_state.Stopped):
                PropAnimController.SetAnimation(AnimationKeyFrames, ?Mode := animation_mode.OneShot)
                PropAnimController.Play()
                Print("clicker_prop_device: OneShot animation set and played.")
            else:
                Print("clicker_prop_device: Animation already active; leaving as-is.")
        else:
            Print("clicker_prop_device: WARNING - ClickerProp has no AnimationController.")
