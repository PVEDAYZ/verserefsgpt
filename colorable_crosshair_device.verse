
using { /Fortnite.com/UI }
using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Colors }
using { /Verse.org/Assets }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

ColorableCrosshairModule := module:

    # IMPORTANT(frozenpawn): image_selection definitions
    # will use the texture data 'in order' that they're defined.
    # For example: The first image_selection, will use the first texture
    # value in there and so on...
    # If you want to have more than 24 textures, add more textures here,
    # Or if you want to change the texture of an existing texture_selection
    # change the value in here.
    # (frozenpawn): texture - aspectratio(x/y)
    CrosshairData : []tuple(texture, float) = array
    {
        (Textures.T_Crosshair_1, 49.0/49.0)
        (Textures.T_Crosshair_2, 143.0/139.0)
        (Textures.T_Crosshair_3, 143.0/142.0)
        (Textures.T_Crosshair_4, 144.0/142.0)
        (Textures.T_Crosshair_5, 127.0/127.0)
        (Textures.T_Crosshair_6, 136.0/137.0)
        (Textures.T_Crosshair_7, 92.0/93.0)
        (Textures.T_Crosshair_8, 85.0/88.0)
        (Textures.T_Crosshair_9, 117.0/117.0)
        (Textures.T_Crosshair_10, 120.0/119.0)
        (Textures.T_Crosshair_11, 91.0/90.0)
        (Textures.T_Crosshair_12, 150.0/86.0)
        (Textures.T_Crosshair_13, 125.0/125.0)
        (Textures.T_Crosshair_14, 125.0/125.0)
        (Textures.T_Crosshair_15, 120.0/120.0)
        (Textures.T_Crosshair_16, 120.0/120.0)
        (Textures.T_Crosshair_17, 102.0/101.0)
        (Textures.T_Crosshair_18, 98.0/98.0)
        (Textures.T_Crosshair_19, 111.0/111.0)
        (Textures.T_Crosshair_20, 99.0/100.0)
        (Textures.T_Crosshair_21, 90.0/90.0)
        (Textures.T_Crosshair_22, 146.0/146.0)
        (Textures.T_Crosshair_23, 115.0/115.0)
        (Textures.T_Crosshair_24, 94.0/95.0)
    }

    # IMPORTANT(frozenpawn): color_selection definitions
    # will use the color data 'in order' that they're defined.
    # For example: The first color_selection, will use the first color
    # value in there and so on...
    # If you want to have more than 8 base colors, add more colors here,
    # Or if you want to change the color of an existing color_selection
    # change the value in here.
    # (frozenpawn): R-G-B color data for the color_selection.
    ColorData : []tuple(int, int, int) = array
    {
        (140, 137, 154),
        (14, 41, 88),
        (6, 230, 0),
        (0, 255, 255),
        (244, 2, 11),
        (228, 20, 203),
        (252, 209, 4),
        (5, 98, 233)
    }

    agent_data := class:
        var MaybeHUD : ?canvas = false
        var CrosshairRGB : []int = array{255, 255, 255}
        var CrosshairSize : float = 64.0
        var TextureIndex : int = 0

    image_selection := class<concrete>:
        @editable
        MaybeSelectionByFire : ?objective_device = false

        @editable
        MaybeSelectionByButton : ?button_device = false

        var TextureIndex : int = 0
        var MaybeMainDevice : ?colorable_crosshair_device = false

        Init(CrosshairDevice : colorable_crosshair_device, Index : int):void=
            Print("Init")

            set TextureIndex = Index

            # (frozenpawn): Objective device is a bit buggy. If we don't call
            # a function on it first. Its events won't fire.
            if (SelectionByFire := MaybeSelectionByFire?):
                SelectionByFire.Heal(1.0)
                SelectionByFire.DamagedEvent().Subscribe(OnDamaged)

            if (SelectionByButton := MaybeSelectionByButton?):
                SelectionByButton.InteractedWithEvent.Subscribe(OnInteractedWith)

            set MaybeMainDevice = option{ CrosshairDevice }

        OnDamaged(DamageResult : damage_result):void=
            Print("OnDamaged")

            if (MainDevice := MaybeMainDevice?, Instigator := DamageResult.Instigator?,
            Agent := Instigator.GetInstigatorAgent[]):
                MainDevice.SetCrosshairTexture(Agent, TextureIndex)

        OnInteractedWith(Agent : agent):void=
            Print("OnInteractedWith")

            if (MainDevice := MaybeMainDevice?):
                MainDevice.SetCrosshairTexture(Agent, TextureIndex)

    color_selection := class<concrete>:
        @editable
        MaybeSelectionByFire : ?objective_device = false

        @editable
        MaybeSelectionByButton : ?button_device = false

        var ColorIndex : int = 0
        var MaybeMainDevice : ?colorable_crosshair_device = false

        Init(CrosshairDevice : colorable_crosshair_device, Index : int):void=
            Print("Init")

            set ColorIndex = Index

            if (SelectionByFire := MaybeSelectionByFire?):
                SelectionByFire.Heal(1.0)
                SelectionByFire.DamagedEvent().Subscribe(OnDamaged)

            if (SelectionByButton := MaybeSelectionByButton?):
                SelectionByButton.InteractedWithEvent.Subscribe(OnInteractedWith)

            set MaybeMainDevice = option{ CrosshairDevice }

        OnDamaged(DamageResult : damage_result):void=
            Print("OnDamaged")

            if (MainDevice := MaybeMainDevice?, Instigator := DamageResult.Instigator?,
            Agent := Instigator.GetInstigatorAgent[], RGBTuple := ColorData[ColorIndex]):
                MainDevice.SetCrosshairColor(Agent, MakeColorFromSRGBValues(RGBTuple(0), RGBTuple(1), RGBTuple(2)))

        OnInteractedWith(Agent : agent):void=
            Print("OnInteractedWith")

            if (MainDevice := MaybeMainDevice?, RGBTuple := ColorData[ColorIndex]):
                MainDevice.SetCrosshairColor(Agent, MakeColorFromSRGBValues(RGBTuple(0), RGBTuple(1), RGBTuple(2)))

    colorable_crosshair_device := class(creative_device):

        @editable
        DefaultCrosshairClass : class_and_team_selector_device = class_and_team_selector_device{}
        @editable
        CustomCrosshairClass : class_and_team_selector_device = class_and_team_selector_device{}        

        @editable
        ImageSelections : []image_selection = array{}

        @editable
        ColorSelections : []color_selection = array{}

        @editable
        CrosshairStartingSize : float = 64.0

        @editable
        SizeChangeStep : int = 1
        @editable
        RGBChangeStep : int = 1        

        @editable
        ColorWheelObjective : objective_device = objective_device{}
        @editable
        ColorWheelRadius : float = 0.0

        @editable
        MaybeRemoveByFire : ?objective_device = false
        @editable
        MaybeRemoveByButton : ?button_device = false

        @editable
        MaybeRValueDecreaseByFire : ?objective_device = false
        @editable
        MaybeRValueDecreaseByButton : ?button_device = false
        @editable
        MaybeRValueIncreaseByFire : ?objective_device = false
        @editable
        MaybeRValueIncreaseByButton : ?button_device = false

        @editable
        MaybeGValueDecreaseByFire : ?objective_device = false
        @editable
        MaybeGValueDecreaseByButton : ?button_device = false
        @editable
        MaybeGValueIncreaseByFire : ?objective_device = false
        @editable
        MaybeGValueIncreaseByButton : ?button_device = false

        @editable
        MaybeBValueDecreaseByFire : ?objective_device = false
        @editable
        MaybeBValueDecreaseByButton : ?button_device = false
        @editable
        MaybeBValueIncreaseByFire : ?objective_device = false
        @editable
        MaybeBValueIncreaseByButton : ?button_device = false

        @editable
        MaybeCrosshairSizeDecreaseByFire : ?objective_device = false
        @editable
        MaybeCrosshairSizeDecreaseByButton : ?button_device = false
        @editable
        MaybeCrosshairSizeIncreaseByFire : ?objective_device = false
        @editable
        MaybeCrosshairSizeIncreaseByButton : ?button_device = false

        @editable
        DamageDisablingZone : mutator_zone_device = mutator_zone_device{}

        var AgentMap : [agent]agent_data = map{}

        OnBegin<override>()<suspends>:void=
            Print("OnBegin")

            for (Player : GetPlayspace().GetPlayers()):
                OnPlayerJoined(Player)

            GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoined)

            ImageSelectionCount := ImageSelections.Length
            for (I := 0 .. ImageSelectionCount-1, ImageSelection := ImageSelections[I]):
                ImageSelection.Init(Self, I)

            ColorSelectionCount := ColorSelections.Length
            for (I := 0 .. ColorSelectionCount-1, ColorSelection := ColorSelections[I]):
                ColorSelection.Init(Self, I)

            ColorWheelObjective.Heal(1.0)
            ColorWheelObjective.DamagedEvent().Subscribe(OnColorWheelHit)           

            if (ResetByFire := MaybeRemoveByFire?):
                ResetByFire.Heal(1.0)
                ResetByFire.DamagedEvent().Subscribe(OnResetDamaged)

            if (ResetByButton := MaybeRemoveByButton?):
                ResetByButton.InteractedWithEvent.Subscribe(ResetCrosshair)

            # (frozenpawn): Bind the increase for R Value.
            if (RValueDecreaseByFire := MaybeRValueDecreaseByFire?):
                RValueDecreaseByFire.Heal(1.0)
                RValueDecreaseByFire.DamagedEvent().Subscribe(RValueDecreaseOnFire)
            if (RValueDecreaseByButton := MaybeRValueDecreaseByButton?):
                RValueDecreaseByButton.InteractedWithEvent.Subscribe(RValueDecreaseOnButton)

            # (frozenpawn): Bind the decrease for R Value.
            if (RValueIncreaseByFire := MaybeRValueIncreaseByFire?):
                RValueIncreaseByFire.Heal(1.0)
                RValueIncreaseByFire.DamagedEvent().Subscribe(RValueIncreaseOnFire)
            if (RValueIncreaseByButton := MaybeRValueIncreaseByButton?):
                RValueIncreaseByButton.InteractedWithEvent.Subscribe(RValueIncreaseOnButton)

            # (frozenpawn): Bind the increase for G Value.
            if (GValueDecreaseByFire := MaybeGValueDecreaseByFire?):
                GValueDecreaseByFire.Heal(1.0)
                GValueDecreaseByFire.DamagedEvent().Subscribe(GValueDecreaseOnFire)
            if (GValueDecreaseByButton := MaybeGValueDecreaseByButton?):
                GValueDecreaseByButton.InteractedWithEvent.Subscribe(GValueDecreaseOnButton)

            # (frozenpawn): Bind the decrease for G Value.
            if (GValueIncreaseByFire := MaybeGValueIncreaseByFire?):
                GValueIncreaseByFire.Heal(1.0)
                GValueIncreaseByFire.DamagedEvent().Subscribe(GValueIncreaseOnFire)
            if (GValueIncreaseByButton := MaybeGValueIncreaseByButton?):
                GValueIncreaseByButton.InteractedWithEvent.Subscribe(GValueIncreaseOnButton)

            # (frozenpawn): Bind the increase for B Value.
            if (BValueDecreaseByFire := MaybeBValueDecreaseByFire?):
                BValueDecreaseByFire.Heal(1.0)
                BValueDecreaseByFire.DamagedEvent().Subscribe(BValueDecreaseOnFire)
            if (BValueDecreaseByButton := MaybeBValueDecreaseByButton?):
                BValueDecreaseByButton.InteractedWithEvent.Subscribe(BValueDecreaseOnButton)

            # (frozenpawn): Bind the decrease for B Value.
            if (BValueIncreaseByFire := MaybeBValueIncreaseByFire?):
                BValueIncreaseByFire.Heal(1.0)
                BValueIncreaseByFire.DamagedEvent().Subscribe(BValueIncreaseOnFire)
            if (BValueIncreaseByButton := MaybeBValueIncreaseByButton?):
                BValueIncreaseByButton.InteractedWithEvent.Subscribe(BValueIncreaseOnButton)

            # (frozenpawn): Bind the decrease for size.
            if (CrosshairSizeDecreaseByFire := MaybeCrosshairSizeDecreaseByFire?):
                CrosshairSizeDecreaseByFire.Heal(1.0)
                CrosshairSizeDecreaseByFire.DamagedEvent().Subscribe(DecreaseCrosshairSizeOnFire)
            if (CrosshairSizeDecreaseByButton := MaybeCrosshairSizeDecreaseByButton?):
                CrosshairSizeDecreaseByButton.InteractedWithEvent.Subscribe(DecreaseCrosshairSizeOnButton)

            # (frozenpawn): Bind the increase for size.
            if (CrosshairSizeIncreaseByFire := MaybeCrosshairSizeIncreaseByFire?):
                CrosshairSizeIncreaseByFire.Heal(1.0)
                CrosshairSizeIncreaseByFire.DamagedEvent().Subscribe(IncreaseCrosshairSizeOnFire)
            if (CrosshairSizeIncreaseByButton := MaybeCrosshairSizeIncreaseByButton?):
                CrosshairSizeIncreaseByButton.InteractedWithEvent.Subscribe(IncreaseCrosshairSizeOnButton)

        OnResetDamaged(DamageResult : damage_result):void=
            Print("OnResetDamaged")

            if (Instigator := DamageResult.Instigator?, Agent := Instigator.GetInstigatorAgent[]):
                ResetCrosshair(Agent)

        ResetCrosshair(Agent : agent):void=
            Print("ResetCrosshair")

            if (AgentData := AgentMap[Agent], CrosshairHUD := AgentData.MaybeHUD?,
            Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
                DefaultCrosshairClass.ChangeClass(Agent)

                PlayerUI.RemoveWidget(CrosshairHUD)
                set AgentData.MaybeHUD = false

        OnPlayerJoined(Player : player):void=
            Print("OnPlayerJoined")
            DefaultCrosshairClass.ChangeClass(Player)

            if (not AgentMap[Player]):
                if (set AgentMap[Player] = agent_data{ CrosshairSize := CrosshairStartingSize }){}

                if (FC := Player.GetFortCharacter[]):
                    FC.DamagedShieldEvent().Subscribe(OnPlayerDamaged)
                    FC.DamagedEvent().Subscribe(OnPlayerDamaged)

        OnPlayerDamaged(DamageResult : damage_result):void=
            Print("OnPlayerDamaged")

            if (FC := fort_character[DamageResult.Target], Agent := FC.GetAgent[],
            DamageDisablingZone.IsInVolume[Agent]):
                FC.SetShield(FC.GetMaxShield())
                FC.SetHealth(FC.GetMaxHealth())

        OnColorWheelHit(DamageResult : damage_result):void=
            Print("OnColorWheelHit")

            if (Instigator := DamageResult.Instigator?, Agent := Instigator.GetInstigatorAgent[], FC := Agent.GetFortCharacter[]):
                #Print("ViewLocation: {FC.GetViewLocation()}")

                ColorWheelTransform := ColorWheelObjective.GetTransform()

                ViewDirection := FC.GetViewRotation().GetLocalForward()
                PlaneNormal := ColorWheelTransform.Rotation.GetLocalUp()
                Denominator := DotProduct(ViewDirection, PlaneNormal)

                HitDistance := DotProduct(ColorWheelTransform.Translation - FC.GetViewLocation(), PlaneNormal) / Denominator
                HitLocation := FC.GetViewLocation() + ViewDirection*HitDistance

                HitDistanceFromCenter := Distance(HitLocation, ColorWheelTransform.Translation)
                if (HitDistanceFromCenter > ColorWheelRadius):
                    Print("Hit outside of the circle, exiting.")
                    return

                #Print("Denominator: {Denominator}")
                #Print("HitDistance: {HitDistance}")
                #Print("HitLocation: {HitLocation}")

                # (frozenpawn): Circle location to RGB.
                CircleCenter := ColorWheelTransform.Translation
                PointOnCircle := HitLocation

                # Project the direction onto the circle's plane.
                PointDirection := PointOnCircle - CircleCenter
                Projection := PointDirection - PlaneNormal*DotProduct(PointDirection, PlaneNormal)

                if (ProjectedDirection := Projection.MakeUnitVector[]):
                    # X axis of the circle.
                    LocalForward := ColorWheelTransform.Rotation.GetLocalForward()
                    # Y axis of the circle.
                    LocalRight := ColorWheelTransform.Rotation.GetLocalRight()

                    CircleX := DotProduct(ProjectedDirection, LocalForward)
                    CircleY := DotProduct(ProjectedDirection, LocalRight)                    

                    # Calculate the angle in radians.
                    var Angle : float = ArcTan(CircleY, CircleX)
                    if (Angle < 0.0):
                        set Angle += 2.0 * PiFloat

                    # (frozenpawn): Some color wheel rotation.
                    set Angle += DegreesToRadians(5.0)

                    # Normalize the angle to [0, 1] for hue.
                    NormalizedAngle := Angle / (2.0 * PiFloat)

                    # Convert the hue to RGB.
                    Hue := NormalizedAngle * 360.0
                    Saturation := (HitDistanceFromCenter / ColorWheelRadius)
                    RGBColor := MakeColorFromHSV(Hue, Saturation, 1.0)

                    SetCrosshairColor(Agent, RGBColor)

                    #Print("Direction: {PointDirection}")
                    #Print("ProjectedDirection: {ProjectedDirection}")
                    #Print("Circle (X,Y): ({CircleX},{CircleY})")
                    #Print("Angle: {Angle}")
                    #Print("NormalizedAngle: {NormalizedAngle}")
                    #Print("ColorRGB: ({RGBColor.R}, {RGBColor.G}, {RGBColor.B})")

        RValueDecreaseOnFire(DamageResult : damage_result):void=
            Print("RValueDecreseByFire")
            if (Instigator := DamageResult.Instigator?, Agent := Instigator.GetInstigatorAgent[]):
                DecreaseCrosshairR(Agent)
        RValueDecreaseOnButton(Agent : agent):void=
            Print("RValueDecreaseOnButton")
            DecreaseCrosshairR(Agent)

        RValueIncreaseOnFire(DamageResult : damage_result):void=
            Print("RValueIncreseByFire")
            if (Instigator := DamageResult.Instigator?, Agent := Instigator.GetInstigatorAgent[]):
                IncreaseCrosshairR(Agent)
        RValueIncreaseOnButton(Agent : agent):void=
            Print("RValueIncreaseOnButton")
            IncreaseCrosshairR(Agent)

        GValueDecreaseOnFire(DamageResult : damage_result):void=
            Print("GValueDecreseByFire")
            if (Instigator := DamageResult.Instigator?, Agent := Instigator.GetInstigatorAgent[]):
                DecreaseCrosshairG(Agent)
        GValueDecreaseOnButton(Agent : agent):void=
            Print("GValueDecreaseOnButton")
            DecreaseCrosshairG(Agent)

        GValueIncreaseOnFire(DamageResult : damage_result):void=
            Print("GValueIncreaseByFire")
            if (Instigator := DamageResult.Instigator?, Agent := Instigator.GetInstigatorAgent[]):
                IncreaseCrosshairG(Agent)
        GValueIncreaseOnButton(Agent : agent):void=
            Print("GValueIncreaseOnButton")
            IncreaseCrosshairG(Agent)

        BValueDecreaseOnFire(DamageResult : damage_result):void=
            Print("BValueDecreseByFire")
            if (Instigator := DamageResult.Instigator?, Agent := Instigator.GetInstigatorAgent[]):
                DecreaseCrosshairB(Agent)
        BValueDecreaseOnButton(Agent : agent):void=
            Print("BValueDecreaseOnButton")
            DecreaseCrosshairB(Agent)

        BValueIncreaseOnFire(DamageResult : damage_result):void=
            Print("BValueIncreseByFire")
            if (Instigator := DamageResult.Instigator?, Agent := Instigator.GetInstigatorAgent[]):
                IncreaseCrosshairB(Agent)
        BValueIncreaseOnButton(Agent : agent):void=
            Print("BValueIncreaseOnButton")
            IncreaseCrosshairB(Agent)

        DecreaseCrosshairSizeOnFire(DamageResult : damage_result):void=
            Print("DecreaseCrosshairSizeOnFire")
            if (Instigator := DamageResult.Instigator?, Agent := Instigator.GetInstigatorAgent[]):
                UpdateCrosshairSize(Agent, false)
        DecreaseCrosshairSizeOnButton(Agent : agent):void=
            Print("DecreaseCrosshairSizeOnButton")
            UpdateCrosshairSize(Agent, false)

        IncreaseCrosshairSizeOnFire(DamageResult : damage_result):void=
            Print("IncreaseCrosshairSizeOnFire")
            if (Instigator := DamageResult.Instigator?, Agent := Instigator.GetInstigatorAgent[]):
                UpdateCrosshairSize(Agent, true)
        IncreaseCrosshairSizeOnButton(Agent : agent):void=
            Print("IncreaseCrosshairSizeOnButton")
            UpdateCrosshairSize(Agent, true)

        DecreaseCrosshairR(Agent : agent):void=
            Print("DecreaseCrosshairR")
            UpdateCrosshairRGB(Agent, -RGBChangeStep, 0)
        DecreaseCrosshairG(Agent : agent):void=
            Print("DecreaseCrosshairG")
            UpdateCrosshairRGB(Agent, -RGBChangeStep, 1)
        DecreaseCrosshairB(Agent : agent):void=
            Print("DecreaseCrosshairB")
            UpdateCrosshairRGB(Agent, -RGBChangeStep, 2)

        IncreaseCrosshairR(Agent : agent):void=
            Print("IncreaseCrosshairR")
            UpdateCrosshairRGB(Agent, RGBChangeStep, 0)
        IncreaseCrosshairG(Agent : agent):void=
            Print("IncreaseCrosshairG")
            UpdateCrosshairRGB(Agent, RGBChangeStep, 1)
        IncreaseCrosshairB(Agent : agent):void=
            Print("IncreaseCrosshairB")
            UpdateCrosshairRGB(Agent, RGBChangeStep, 2)

        UpdateCrosshairRGB(Agent : agent, UpdateValue : int, RGBIndex : int):void=
            Print("UpdateCrosshairRGB")

            if (AgentData := AgentMap[Agent], Canvas := AgentData.MaybeHUD?,
            CrosshairTextureBlock := texture_block[Canvas.Slots[0].Widget]):
                if (ImmValue := AgentData.CrosshairRGB[RGBIndex]):
                    ValueToSet := Clamp((ImmValue + UpdateValue), 0, 255)

                    if (set AgentData.CrosshairRGB[RGBIndex] = ValueToSet){}

                    if (R := AgentData.CrosshairRGB[0], G := AgentData.CrosshairRGB[1],
                    B := AgentData.CrosshairRGB[2]):                        
                        Color := MakeColorFromSRGBValues(R, G, B)
                        CrosshairTextureBlock.SetTint(Color)

                        Print("R,G,B: ({R}, {G}, {B})")

        UpdateCrosshairSize(Agent : agent, bIncrease : logic):void=
            Print("SetCrosshairSize")

            if (AgentData := AgentMap[Agent],
            CrosshairTuple := CrosshairData[AgentData.TextureIndex],
            Canvas := AgentData.MaybeHUD?,
            CrosshairTextureBlock := texture_block[Canvas.Slots[0].Widget]):

                AspectRatioXOverY : float = CrosshairTuple(1)
                set AgentData.CrosshairSize += if (bIncrease = true)
                then SizeChangeStep*1.0
                else -SizeChangeStep*1.0

                Size := vector2{ X := AgentData.CrosshairSize * AspectRatioXOverY, Y := AgentData.CrosshairSize }
                CrosshairTextureBlock.SetDesiredSize(Size)

        SetCrosshairTexture(Agent : agent, TextureIndex : int):void=
            Print("SetCrosshairTexture")

            if (AgentData := AgentMap[Agent],
            CrosshairTuple := CrosshairData[TextureIndex]):
                CustomCrosshairClass.ChangeClass(Agent)

                CrosshairTexture := CrosshairTuple(0)
                AspectRatioXOverY : float = CrosshairTuple(1)

                # (frozenpawn): Canvas is empty, create it first.
                if (AgentData.MaybeHUD = false, Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
                    Size := vector2{ X := AgentData.CrosshairSize * AspectRatioXOverY, Y := AgentData.CrosshairSize }
                    Canvas := CreateCanvas(CrosshairTexture, Size)

                    set AgentData.MaybeHUD = option{ Canvas }

                    PlayerUI.AddWidget(Canvas)                    

                if (Canvas := AgentData.MaybeHUD?,
                CrosshairTextureBlock := texture_block[Canvas.Slots[0].Widget]):

                    set AgentData.TextureIndex = TextureIndex
                    Size := vector2{ X := AgentData.CrosshairSize * AspectRatioXOverY, Y := AgentData.CrosshairSize }

                    CrosshairTextureBlock.SetDesiredSize(Size)
                    CrosshairTextureBlock.SetImage(CrosshairTexture)

        SetCrosshairColor(Agent : agent, Color : color):void=
            Print("SetCrosshairColor")

            if (AgentData := AgentMap[Agent], Canvas := AgentData.MaybeHUD?,
            CrosshairTextureBlock := texture_block[Canvas.Slots[0].Widget],
            R := Round[Color.R*255], G := Round[Color.G*255], B := Round[Color.B*255]):

                if (set AgentData.CrosshairRGB[0] = R, set AgentData.CrosshairRGB[1] = G,
                set AgentData.CrosshairRGB[2] = B){}

                ConvertedColor := MakeColorFromSRGBValues(R, G, B)
                CrosshairTextureBlock.SetTint(ConvertedColor)

        CreateCanvas(Texture : texture, Size : vector2):canvas=
            Print("CreateCanvas")

            return Canvas := canvas:
                Slots := array
                {
                    canvas_slot:
                        Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 0.5 }, Maximum := vector2{ X := 0.5, Y := 0.5 } }
                        Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                        Alignment := vector2{ X := 0.5, Y := 0.5 }
                        SizeToContent := true
                        ZOrder := 0
                        Widget := texture_block{ DefaultImage := Texture, DefaultDesiredSize := Size }
                }