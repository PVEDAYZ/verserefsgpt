
using { /Verse.org/Assets }
using { /Verse.org/Random }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

widget_data := struct:
    Widget : widget
    RewardLevel : int
    bGold : logic
    
jackpot_device := class(creative_device):
    
   
    @editable
    VerySmallReward : accolades_device = accolades_device{}

    @editable
    SmallReward : accolades_device = accolades_device{}

    @editable
    MediumReward : accolades_device = accolades_device{}

    @editable
    LargeReward : accolades_device = accolades_device{}

    @editable
    VertLargeReward : accolades_device = accolades_device{}

    @editable
    InteractionButton : button_device = button_device{}

    @editable
    ScrollAudioPlayer : audio_player_device = audio_player_device{}

    @editable
    RewardAudioPlayer : audio_player_device = audio_player_device{}

    TextureSize : vector2 = vector2 { X := 160.0, Y := 160.0 }
    BackgroundSize : vector2 = vector2 { X := 1280.0, Y := 720.0 }

    var WidgetsDataPerAgent : [agent][]widget_data = map{}
    var GoldGranters : []accolades_device = array{}
    var ItemGranters : []accolades_device = array{}

    OnBegin<override>()<suspends>:void=
        Print("OnBegin")

        set ItemGranters += array{ VerySmallReward }
        set ItemGranters += array{ SmallReward }
        set ItemGranters += array{ MediumReward }
        set ItemGranters += array{ LargeReward }
        set ItemGranters += array{ VertLargeReward }

        InteractionButton.InteractedWithEvent.Subscribe(OnButtonActivated)

    OnButtonActivated(Agent : agent):void=
        if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            JackpotCanvas := CreateJackpotCanvas(Agent)
            PlayerUI.AddWidget(JackpotCanvas)
            spawn{ AsyncSlideJackpotCanvas(JackpotCanvas, Player) }

    AsyncSlideJackpotCanvas(JackpotCanvas : canvas, Player : player)<suspends>:void=
        TotalScrollRatioMin : float = 1.0
        TotalScrollRatioMax : float = 2.0
        TotalScrollRatio : float = GetRandomFloat(TotalScrollRatioMin, TotalScrollRatioMax)

        ScrollDurationMin : float = 5.0
        ScrollDurationMax : float = 7.0
        ScrollDuration : float = GetRandomFloat(ScrollDurationMin, ScrollDurationMax)

        var SlideSlotCount : int = 0
        if (FirstSlideCanvas : canvas = canvas[JackpotCanvas.Slots[1].Widget]):
            set SlideSlotCount = FirstSlideCanvas.Slots.Length

        OneSlideOffset : float = TextureSize.X * SlideSlotCount

        var SlideWidgets : []widget = array{}
        for (I := 1..JackpotCanvas.Slots.Length-1, Widget := JackpotCanvas.Slots[I].Widget):
            set SlideWidgets += array{ Widget }

        for (I := 1 .. JackpotCanvas.Slots.Length-1, SlideWidgetSlot : canvas_slot = JackpotCanvas.Slots[I],
        SlideWidgetCanvas : canvas = canvas[SlideWidgetSlot.Widget]):
            SlideWidgetSlotOffsetsLeft := (I - 1) * OneSlideOffset - 0.0

            for (TextureWidgetSlot : SlideWidgetCanvas.Slots):
                TotalOffset := SlideWidgetSlotOffsetsLeft + TextureWidgetSlot.Offsets.Left - (OneSlideOffset / 2.0) + (TextureSize.X / 2.0)
                AbsTotalOffset := Abs(TotalOffset)

                if (AbsTotalOffset < (BackgroundSize.X / 2.0 - TextureSize.X / 2.0)):
                    TextureWidgetSlot.Widget.SetVisibility(widget_visibility.Visible)
                else:
                    TextureWidgetSlot.Widget.SetVisibility(widget_visibility.Hidden)

        ScrollStartTime : float = GetSimulationElapsedTime()
        ScrollAudioPlayer.Play(Player)
        var CurrentOffset : float = 0.0
        var LastDivision : float = 0.5
        loop:

            Sleep(0.0)

            CurrentTime := GetSimulationElapsedTime()
            var T : float = (CurrentTime - ScrollStartTime) / ScrollDuration
            if (T >= 1.0):
                set T = 1.0

            ScrollRatio : float = EaseInOut(T)
            set CurrentOffset = OneSlideOffset * ScrollRatio * TotalScrollRatio

            for (SlideWidget : SlideWidgets):
                SlideWidget.SetVisibility(widget_visibility.Collapsed)

            for (SlideWidget : SlideWidgets):
                JackpotCanvas.RemoveWidget(SlideWidget)

            for (SlideWidget : SlideWidgets):
                SlideWidget.SetVisibility(widget_visibility.Visible)
                
            for (I := 0 .. SlideWidgets.Length-1, SlideWidget := SlideWidgets[I]):
                CanvasSlot := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 0.5 }, Maximum := vector2{ X := 0.5, Y := 0.5 } }
                    Offsets := margin{Top := 0.0, Left := I * OneSlideOffset - CurrentOffset, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{ X := 0.5, Y := 0.5 }
                    SizeToContent := true
                    Widget := SlideWidget

                JackpotCanvas.AddWidget(CanvasSlot)

            Division := CurrentOffset / TextureSize.X
            if (Division > (LastDivision + 0.1) or T = 1.0):
                set LastDivision = Division

                for (I := 1 .. JackpotCanvas.Slots.Length-1, SlideWidgetSlot : canvas_slot = JackpotCanvas.Slots[I],
                SlideWidgetCanvas : canvas = canvas[SlideWidgetSlot.Widget]):
                    SlideWidgetSlotOffsetsLeft := (I - 1) * OneSlideOffset - CurrentOffset

                    for (TextureWidgetSlot : SlideWidgetCanvas.Slots):
                        TotalOffset := SlideWidgetSlotOffsetsLeft + TextureWidgetSlot.Offsets.Left - (OneSlideOffset / 2.0) + (TextureSize.X / 2.0)
                        AbsTotalOffset := Abs(TotalOffset)

                        if (AbsTotalOffset < (BackgroundSize.X / 2.0 - TextureSize.X / 2.0)):
                            TextureWidgetSlot.Widget.SetVisibility(widget_visibility.Visible)
                        else:
                            TextureWidgetSlot.Widget.SetVisibility(widget_visibility.Hidden)

            if (T = 1.0):
                break

        var MaybeCenterWidget : ?widget = false
        var MinOffsetDiff : float = OneSlideOffset
        for (I := 1 .. JackpotCanvas.Slots.Length-1, SlideWidgetSlot : canvas_slot = JackpotCanvas.Slots[I],
        SlideWidgetCanvas : canvas = canvas[SlideWidgetSlot.Widget]):
            SlideWidgetSlotOffsetsLeft := (I - 1) * OneSlideOffset - CurrentOffset

            for (TextureWidgetSlot : SlideWidgetCanvas.Slots):                
                TotalOffset := SlideWidgetSlotOffsetsLeft + TextureWidgetSlot.Offsets.Left - (OneSlideOffset / 2.0) + (TextureSize.X / 2.0)
                AbsOffsetDiff : float = Abs(TotalOffset)
                if (AbsOffsetDiff < MinOffsetDiff):
                    set MinOffsetDiff = AbsOffsetDiff
                    set MaybeCenterWidget = option{ TextureWidgetSlot.Widget }

        ScrollAudioPlayer.Stop(Player)        
        Sleep(0.5)
        RewardAudioPlayer.Play(Player)

        if (CenterWidget := MaybeCenterWidget?, WidgetsData := WidgetsDataPerAgent[Player]):
            var I : int = 0
            loop:
                if (WidgetData := WidgetsData[I]):
                    if (WidgetData.Widget = CenterWidget):

                        if (WidgetData.bGold = false, ItemGranter := ItemGranters[WidgetData.RewardLevel]):
                            ItemGranter.Award(Player)
                            ItemGranter.Award(Player)
                else:
                    break

                set I += 1

        if (set WidgetsDataPerAgent[Player] = array{}){}

        if (CenterWidget := MaybeCenterWidget?, TextureBlock := texture_block[CenterWidget]):
            for (I := 1 .. 20):
                TextureBlock.SetTint(NamedColors.Green)
                Sleep(0.1)

                TextureBlock.SetTint(NamedColors.White)
                Sleep(0.1)

        if (PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(JackpotCanvas)

    EaseInOut(T : float):float=
        TSquare : float = T * T;
        return (TSquare / (2.0 * (TSquare - T) + 1.0))

    GetEffectiveLength(Arr : []int, InvalidValue : int):int=
        var EffectiveLength : int = 0
        for (Value : Arr):
            if (Value <> InvalidValue):
                set EffectiveLength += 1

        return EffectiveLength

    GetRealIndexFromEffectiveIndex(Arr : []int, InvalidValue : int, TargetEffectiveIndex : int):int=
        var TraversedIndex : int = 0
        var TraversedEffectiveIndex : int = 0
        for (Value : Arr):
            if (Value <> InvalidValue):
                if (TraversedEffectiveIndex = TargetEffectiveIndex):
                    return TraversedIndex

                set TraversedEffectiveIndex += 1

            set TraversedIndex += 1

        return -1

    CreateJackpotCanvas(Agent : agent):canvas=
        if (set WidgetsDataPerAgent[Agent] = array{}){}
        var CanvasSlots : []canvas_slot = array{}

        FirstToSlide : canvas = CreateCanvasToSlide(Agent)
        OneSlideOffset : float = FirstToSlide.Slots.Length * TextureSize.X

        set CanvasSlots += array
        {
            canvas_slot:
                Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 0.5 }, Maximum := vector2{ X := 0.5, Y := 0.5 } }
                Offsets := margin{Top := -30.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                Alignment := vector2{ X := 0.5, Y := 0.5 }
                SizeToContent := true
                Widget := texture_block{ DefaultImage := Textures.T_JackBG, DefaultDesiredSize := BackgroundSize }
            canvas_slot:
                Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 0.5 }, Maximum := vector2{ X := 0.5, Y := 0.5 } }
                Offsets := margin{Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                Alignment := vector2{ X := 0.5, Y := 0.5 }
                SizeToContent := true
                Widget := FirstToSlide
        }

        AdditionalSlides := 2
        for (I := 1..AdditionalSlides):
            set CanvasSlots += array
            {
                canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 0.5 }, Maximum := vector2{ X := 0.5, Y := 0.5 } }
                    Offsets := margin{Top := 0.0, Left := I * OneSlideOffset, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{ X := 0.5, Y := 0.5 }
                    SizeToContent := true
                    Widget := CreateCanvasToSlide(Agent)
            }

        Canvas : canvas = canvas:
            Slots := CanvasSlots

        return Canvas

    CreateCanvasToSlide(Agent : agent):canvas=
        var WidgetsData : []widget_data = array{}
        var CanvasSlots : []canvas_slot = array{}

        WeaponTextures : []texture = array{ Textures.T_VerySmallReward, Textures.T_SmallReward, Textures.T_MediumReward, Textures.T_LargeReward, Textures.T_VeryLargeReward }
        RewardAmountsPerLevel : []int = array{ 7, 5, 3, 2, 1 }
        LvlCount : int = 5

        var TotalAddedTexture : int = 0

        var RewardAmountsToPullGold : []int = array{}
        set RewardAmountsToPullGold = RewardAmountsPerLevel

        var RewardAmountsToPullWeapon : []int = array{}
        set RewardAmountsToPullWeapon = RewardAmountsPerLevel

        loop:
            var RemainingGoldsToPull : int = 0
            var RemainingWeaponsToPull : int = 0

            for (RewardAmountToPull : RewardAmountsToPullGold):
                set RemainingGoldsToPull += RewardAmountToPull
            for (RewardAmountToPull : RewardAmountsToPullWeapon):
                set RemainingWeaponsToPull += RewardAmountToPull

            if (RemainingGoldsToPull = 0 and RemainingWeaponsToPull = 0):
                break

            var bPullGold : logic = true            
            if (RemainingGoldsToPull > 0 and RemainingWeaponsToPull > 0):
                set bPullGold = logic {GetRandomInt(0, 1) = 0}

            else if (RemainingGoldsToPull = 0):
                set bPullGold = false

            var RewardAmountsToPullEffectiveLength : int = if (bPullGold = true)
            then GetEffectiveLength(RewardAmountsToPullGold, 0)
            else GetEffectiveLength(RewardAmountsToPullWeapon, 0)

            var MaybeTexture : ?texture = false
            EffectiveIndexToPull : int = GetRandomInt(0, RewardAmountsToPullEffectiveLength-1)

            RealIndexToPull : int = if (bPullGold = true)
            then GetRealIndexFromEffectiveIndex(RewardAmountsToPullGold, 0, EffectiveIndexToPull)
            else GetRealIndexFromEffectiveIndex(RewardAmountsToPullWeapon, 0, EffectiveIndexToPull)

            if (bPullGold = true):
                if (ImVal := RewardAmountsToPullGold[RealIndexToPull]):
                    if (set RewardAmountsToPullGold[RealIndexToPull] = ImVal-1){}
            else:
                if (ImVal := RewardAmountsToPullWeapon[RealIndexToPull]):
                    if (set RewardAmountsToPullWeapon[RealIndexToPull] = ImVal-1){}

                    if (Texture := WeaponTextures[RealIndexToPull]):
                        set MaybeTexture = option{ Texture }

            if (Texture := MaybeTexture?):
                set CanvasSlots += array
                {
                    canvas_slot:
                        Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 } }
                        Offsets := margin{Top := 0.0, Left := TotalAddedTexture*TextureSize.X, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{ X := 0.0, Y := 0.0 }
                        SizeToContent := true
                        Widget := texture_block{ DefaultImage := Texture, DefaultDesiredSize := TextureSize }
                }

                set TotalAddedTexture += 1
                if (LastSlot := CanvasSlots[CanvasSlots.Length-1]):
                    set WidgetsData += array{ widget_data{ Widget := LastSlot.Widget, RewardLevel := RealIndexToPull, bGold := bPullGold } }


       
        set TotalAddedTexture += 1
        if (LastSlot := CanvasSlots[CanvasSlots.Length-1]):
            set WidgetsData += array{ widget_data{ Widget := LastSlot.Widget, RewardLevel := ItemGranters.Length-1, bGold := false } }

        Canvas : canvas = canvas:
            Slots := CanvasSlots

        if (set WidgetsDataPerAgent[Agent] += WidgetsData){}

        return Canvas