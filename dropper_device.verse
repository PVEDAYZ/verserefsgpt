using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

dropper_pipe<public> := class<concrete>:
    @editable DroppedProp<public> : creative_prop = creative_prop{}
    @editable DropStartLoc<public> : vector3 = vector3{}
    @editable DropEndLoc<public> : vector3 = vector3{}
    @editable FinalLoc : vector3 = vector3{}

    @editable DownDuration<public> : float = 0.5
    @editable HorizontalDuration<public> : float = 3.0

    @editable var IncomeOnReach<public> : int = 10

    var AnimationKeyFrames : []keyframe_delta = array{}
    var MaybeDropper<public> : ?dropper_device = false

    InitDropperPipe<public>(Dropper : dropper_device):void=
        DroppedProp.Hide()
        DownKeyFrame : keyframe_delta = keyframe_delta{
            DeltaLocation := DropEndLoc - DropStartLoc
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3{X:=1.0, Y:=1.0, Z:=1.0}
            Time := DownDuration
            Interpolation := EaseIn
        }
        HorizontalKeyFrame : keyframe_delta = keyframe_delta{
            DeltaLocation := FinalLoc - DropEndLoc
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3{X:=1.0, Y:=1.0, Z:=1.0}
            Time := HorizontalDuration
            Interpolation := Linear
        }
        set AnimationKeyFrames = array{
            DownMovementKeyFrame := DownKeyFrame,
            HorizontalMovementKeyFrame := HorizontalKeyFrame
        }
        set MaybeDropper = option{Dropper}
    
    StartDropperPipe<public>():void=
        DroppedProp.Show()
        if(Dropper := MaybeDropper?, PropAnimController := DroppedProp.GetAnimationController[]):
            if(DroppedProp.TeleportTo[DropStartLoc, IdentityRotation()]){}
            PropAnimController.SetAnimation(AnimationKeyFrames, ?Mode := animation_mode.OneShot)
            spawn:
                Monitor()
        
    OnAnimComplete():void=
        if(Dropper := MaybeDropper?, PropAnimController := DroppedProp.GetAnimationController[]):
            Dropper.UpdateTotalSavedMoney(IncomeOnReach)
            # Inform the dropper that one pipe cycle completed (for milestone accolades).
            Dropper.NotifyPipeCycleCompleted()
            if(DroppedProp.TeleportTo[DropStartLoc, IdentityRotation()]){}
            PropAnimController.SetAnimation(AnimationKeyFrames, ?Mode := animation_mode.OneShot)
            PropAnimController.Play()
    
    Monitor()<suspends>:void=
        loop:
            if(Dropper := MaybeDropper?):
                OnAnimComplete()
                Sleep(DownDuration+HorizontalDuration)
            else:
                break

    ResetDropperPipe<public>():void=
        set MaybeDropper = false
        DroppedProp.Hide()


dropper_device<public> := class(creative_device):

    @editable GameManager : game_manager = game_manager{}
    @editable DropperPipes : []dropper_pipe = array{}
    @editable IncomeCollectTriggers : []trigger_device = array{}
    @editable IncomeBillboards : []billboard_device = array{}
    @editable HudMessage : hud_message_device = hud_message_device{}

    # -------------------------------
    # Accolades & Config (ADDED)
    # -------------------------------
    @editable ClaimAccolades : []accolades_device = array{}
    @editable CollectAccolades : []accolades_device = array{}
    @editable UpgradeAccolades : []accolades_device = array{}
    @editable PipeCycleAccolades : []accolades_device = array{}
    @editable PipeCyclesPerAccolade : int = 10       # award after N pipe cycles (all pipes combined)

    var MaybeOwnerAgent : ?agent = false
    var TotalSavedMoney : int = 0
    var NumPipes : int = 0
    var Mult : int = 1
    var PipeCycleCounter : int = 0                    # counts completed pipe cycles across all pipes

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for(IncomeCollectTrigger: IncomeCollectTriggers):
            IncomeCollectTrigger.TriggeredEvent.Subscribe(OnIncomeCollectTriggered)
    
    # Runs when the dropper is claimed
    OnClaimerTriggered(MaybeAgent : ?agent):void=
        if(Agent := MaybeAgent?):
            set MaybeOwnerAgent = option{Agent}
            for(DropperPipe : DropperPipes):
                DropperPipe.InitDropperPipe(Self)
            AwardAccolades(option{Agent}, ClaimAccolades)
    
    # Initializes and starts a new pipe
    OnPipeTriggered(MaybeAgent : ?agent):void=
        if(Agent := MaybeAgent?):
            var Index : int = 0
            for(DropperPipe : DropperPipes):
                if(Index = NumPipes):
                    DropperPipe.StartDropperPipe()
                set Index += 1
            set NumPipes += 1
            
    # Add the money to player's money
    OnIncomeCollectTriggered(MaybeAgent : ?agent):void=
        if(Agent := MaybeAgent?):
            GameManager.AddMoney(TotalSavedMoney, Agent)
            HudMessage.Show(Agent, TextForUI("${AddCommas(TotalSavedMoney)}"))
            AwardAccolades(option{Agent}, CollectAccolades)
            SetTotalSavedMoney(0)

    UpdateTotalSavedMoney(Value : int):void=
        SetTotalSavedMoney(TotalSavedMoney + Value*Mult)

    SetTotalSavedMoney(Value : int):void=
        set TotalSavedMoney = Value
        for(IncomeBillboard : IncomeBillboards):
            IncomeBillboard.SetText(TextForUI("{AddCommas(TotalSavedMoney)}"))

    ResetDropper():void=
        for(DropperPipe : DropperPipes):
            DropperPipe.ResetDropperPipe()
        set MaybeOwnerAgent = false
        SetTotalSavedMoney(0)
        for(IncomeCollectTrigger: IncomeCollectTriggers):
            HideTrigger(IncomeCollectTrigger)
        for(IncomeBillboard : IncomeBillboards):
            IncomeBillboard.SetText(TextForUI(""))
        set Mult = 1
        set NumPipes = 0
        set PipeCycleCounter = 0
    
    # Double the dropper money output
    Upgrade(MaybeAgent : ?agent):void=
        set Mult *= 2
        if(Agent := MaybeAgent?):
            AwardAccolades(option{Agent}, UpgradeAccolades)

    # -------------------------------
    # Pipe cycle milestone notify (ADDED)
    # Called by dropper_pipe.OnAnimComplete()
    # -------------------------------
    NotifyPipeCycleCompleted<public>():void=
        set PipeCycleCounter += 1
        if(PipeCyclesPerAccolade > 0):
            # Verse does not support modulo; use threshold-and-reset pattern.
            if(PipeCycleCounter >= PipeCyclesPerAccolade):
                set PipeCycleCounter = 0
                if(Agent := MaybeOwnerAgent?):
                    AwardAccolades(option{Agent}, PipeCycleAccolades)

    # -------------------------------
    # Safe helper to award sets (ADDED)
    # -------------------------------
    AwardAccolades(MaybeAgent : ?agent, List : []accolades_device):void=
        if(List.Length = 0):
            return
        if(Agent := MaybeAgent?):
            for(A : List):
                A.Award(Agent)
