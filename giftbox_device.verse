
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }

# A Verse-authored creative device that can be placed in a level
giftbox_device := class(creative_device):

    @editable Prop : creative_prop = creative_prop{}
    @editable Button : button_device = button_device{}
    @editable Times : []int = array{}
    @editable Accolades : []accolades_device = array{}

    var Index : int = 0
    var TimeElapsed : int = 0
    var isActive : logic = false
    var AnimKeyframes : []keyframe_delta = array{}
    var GiftboxCanvas : canvas = canvas{}
    var TimeBlocks : []text_block = array{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        WaitFrame : keyframe_delta = keyframe_delta{
            DeltaLocation := vector3{X:=0.0, Y:=0.0, Z:=0.0}
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3{X:=1.0, Y:=1.0, Z:=1.0}
            Time := 0.6
            Interpolation := EaseInOut
        }
        UpFrame : keyframe_delta = keyframe_delta{
            DeltaLocation := vector3{X:=0.0, Y:=0.0, Z:=100.0}
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3{X:=1.0, Y:=0.6, Z:=1.3}
            Time := 0.2
            Interpolation := EaseOut
        }
        DownFrame : keyframe_delta = keyframe_delta{
            DeltaLocation := vector3{X:=0.0, Y:=0.0, Z:=-120.0}
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3{X:=1.0, Y:=1.0/0.6, Z:=0.6/1.3}
            Time := 0.2
            Interpolation := EaseIn
        }
        CompleteFrame : keyframe_delta = keyframe_delta{
            DeltaLocation := vector3{X:=0.0, Y:=0.0, Z:=20.0}
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3{X:=1.0, Y:=1.0, Z:=1.0/0.6}
            Time := 0.12
            Interpolation := EaseIn
        }
        Button.InteractedWithEvent.Subscribe(Interacted)
        set AnimKeyframes = array{WaitFrame, UpFrame, DownFrame, CompleteFrame}
    
    Animate()<suspends>:void=
        loop:
            if(isActive = false):
                break
            Sleep(5.0)
            if(PropAnimController := Prop.GetAnimationController[]):
                AnimState := PropAnimController.GetState()
                if(AnimState = animation_controller_state.AnimationNotSet or AnimState = animation_controller_state.Stopped):
                    PropAnimController.SetAnimation(AnimKeyframes, ?Mode := animation_mode.OneShot)
                    PropAnimController.Play()

    Start():void=
        set GiftboxCanvas = CreateGiftboxCanvas()
        set isActive = true
        spawn{Update()}
        if(PropAnimController := Prop.GetAnimationController[]):
            spawn{Animate()}

    Update()<suspends>:void=
        loop:
            if(isActive = false):
                break
            set TimeElapsed += 1
            for(I := 0..8, TimeBlock := TimeBlocks[I], Time := Times[I]):
                TimeBlock.SetText(TextForUI(GetTimeString(Time)))
            Sleep(1.0)

    Reset():void=
        if(PropAnimController := Prop.GetAnimationController[]):
            PropAnimController.Stop()
            set isActive = false
            set TimeElapsed = 0
            set Index = 0
            HideProp(Prop)

    Interacted(Agent : agent):void=
        if(Index = Times.Length):
            if(Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
                GiftboxCanvas.SetVisibility(widget_visibility.Visible)
                PlayerUI.AddWidget(GiftboxCanvas, player_ui_slot{InputMode := ui_input_mode.All})
        else if(TimeElapsed > Times[Index]*60):
            if(Accolade := Accolades[Index]):
                Accolade.Award(Agent)
            set Index += 1
        else:
            if(Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
                GiftboxCanvas.SetVisibility(widget_visibility.Visible)
                PlayerUI.AddWidget(GiftboxCanvas, player_ui_slot{InputMode := ui_input_mode.All})

    CreateGiftboxCanvas():canvas=
        var CanvasSlots : []canvas_slot = array{}
        var RewardBlocks : []texture_block = array{}
        for(I := 1..3):
            set RewardBlocks += array{texture_block{DefaultImage := Images.GiftBox, DefaultDesiredSize := vector2{X := 115.0, Y := 115.0}}}
        for(I := 1..3):
            set RewardBlocks += array{texture_block{DefaultImage := Images.Treasure1, DefaultDesiredSize := vector2{X := 115.0, Y := 115.0}}}
        for(I := 1..3):
            set RewardBlocks += array{texture_block{DefaultImage := Images.Treasure2, DefaultDesiredSize := vector2{X := 115.0, Y := 115.0}}}

        for(I := 1..9):
            TextBlock : text_block = text_block{DefaultTextColor := NamedColors.White, DefaultJustification := text_justification.Center}
            set TimeBlocks += array{TextBlock}

        CenterVector := vector2{X:=0.5, Y:=0.5}
        CenterAnchors := anchors{Minimum := CenterVector, Maximum := CenterVector}
        set CanvasSlots += array{
            canvas_slot:
                Anchors := CenterAnchors
                Offsets := margin{Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                Alignment := CenterVector
                SizeToContent := true
                Widget := texture_block{DefaultImage := Images.GiftboxBG, DefaultDesiredSize := vector2{X:=800.0,Y:=800.0}}
        }

        BlockOffsets : []float = array{-195.0, -10.0, 180.0}
        var BlockIndex : int = 0
        for(YOffset : BlockOffsets):
            for(XOffset : BlockOffsets, RewardBlock := RewardBlocks[BlockIndex]):
                set CanvasSlots += array{
                    canvas_slot:
                        Anchors := CenterAnchors
                        Offsets := margin{Top := YOffset, Left := XOffset, Right := 0.0, Bottom := 0.0}
                        Alignment := CenterVector
                        SizeToContent := true
                        Widget := RewardBlock
                }
                set BlockIndex += 1

        TimeBlockYOffsets : []float = array{-188.0, -3.0, 187.0}
        TimeBlockXOffsets : []float = array{-192.0, -7.0, 183.0}
        set BlockIndex = 0
        for(YOffset : TimeBlockYOffsets):
            for(XOffset : TimeBlockXOffsets, TimeBlock := TimeBlocks[BlockIndex]):
                set CanvasSlots += array{
                    canvas_slot:
                        Anchors := CenterAnchors
                        Offsets := margin{Top := YOffset, Left := XOffset, Right := 0.0, Bottom := 0.0}
                        Alignment := CenterVector
                        SizeToContent := true
                        Widget := TimeBlock
                }
                set BlockIndex += 1
        
        QuitButton : button_quiet = button_quiet{DefaultText := TextForUI("Exit")}
        QuitButton.OnClick().Subscribe(OnQuit)
        set CanvasSlots += array{
            canvas_slot:
                Anchors := CenterAnchors
                Offsets := margin{Top := 300.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                Alignment := CenterVector
                SizeToContent := true
                Widget := QuitButton
        } 

        Canvas : canvas = canvas:
            Slots := CanvasSlots
        
        return Canvas

    OnQuit(WidgetMessage : widget_message):void=
        if(PlayerUI := GetPlayerUI[WidgetMessage.Player]):
            PlayerUI.RemoveWidget(GiftboxCanvas)
            GiftboxCanvas.SetVisibility(widget_visibility.Collapsed)

    GetTimeString(Time : int):string=
        TimeLeft := Time*60 - TimeElapsed
        if(TimeLeft < 0):
            return "✔️"
        if(Mins : int = Floor(TimeLeft/60)):
            var Seconds : int = TimeLeft - Mins*60
            return "{Mins}:{Seconds}"
        return ""
