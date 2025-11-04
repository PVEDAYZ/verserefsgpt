using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors/NamedColors }
using { /Fortnite.com/UI }
using { /Verse.org/Random }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

minigame := class():
    var MainCanvas : canvas = canvas{}

    # Text and color widgets
    var Text : text_block = text_block {DefaultTextColor := White}
    var TextBackground : color_block = color_block{
        DefaultColor := Black
        DefaultOpacity := 0.8
        DefaultDesiredSize:=vector2{X:=390.0,Y:=70.0}
    }
    var ItemBackground : color_block = color_block{
        DefaultColor := White
        DefaultOpacity := 0.3
        DefaultDesiredSize:=vector2{X:=390.0,Y:=655.0}
    }
    

    # Button widgets
    var MakeButton : button_loud = button_loud{}
    var ExitButton : button_loud = button_loud{}
    var ConeButton : button_regular = button_regular{}
    var CreamButton : button_regular = button_regular{}
    var ToppingButton : button_regular = button_regular{}

    # Image widgets
    var Cone1Img : texture_block = texture_block{DefaultImage := Images.Cone1, DefaultDesiredSize:=vector2{X:=270.0,Y:=310.0}}
    var Cone3Img : texture_block = texture_block{DefaultImage := Images.Cone3, DefaultDesiredSize:=vector2{X:=270.0,Y:=310.0}}
    var ChocolateImg : texture_block = texture_block{DefaultImage := Images.Chocolate, DefaultDesiredSize:=vector2{X:=320.0,Y:=340.0}}
    var VanillaImg : texture_block = texture_block{DefaultImage := Images.Vanilla, DefaultDesiredSize:=vector2{X:=320.0,Y:=340.0}}
    var StrawberryImg : texture_block = texture_block{DefaultImage := Images.Strawberry, DefaultDesiredSize:=vector2{X:=320.0,Y:=340.0}}
    var CherryImg : texture_block = texture_block{DefaultImage := Images.Cherry, DefaultDesiredSize:=vector2{X:=320.0,Y:=320.0}}
    var OreoImg : texture_block = texture_block{DefaultImage := Images.Oreo, DefaultDesiredSize:=vector2{X:=200.0,Y:=200.0}}

    # Order Image widgets
    var OrderCone1Img : texture_block = texture_block{DefaultImage := Images.Cone1, DefaultDesiredSize:=vector2{X:=270.0,Y:=310.0}}
    var OrderCone3Img : texture_block = texture_block{DefaultImage := Images.Cone3, DefaultDesiredSize:=vector2{X:=270.0,Y:=310.0}}
    var OrderChocolateImg : texture_block = texture_block{DefaultImage := Images.Chocolate, DefaultDesiredSize:=vector2{X:=320.0,Y:=340.0}}
    var OrderVanillaImg : texture_block = texture_block{DefaultImage := Images.Vanilla, DefaultDesiredSize:=vector2{X:=320.0,Y:=340.0}}
    var OrderStrawberryImg : texture_block = texture_block{DefaultImage := Images.Strawberry, DefaultDesiredSize:=vector2{X:=320.0,Y:=340.0}}
    var OrderCherryImg : texture_block = texture_block{DefaultImage := Images.Cherry, DefaultDesiredSize:=vector2{X:=320.0,Y:=320.0}}
    var OrderOreoImg : texture_block = texture_block{DefaultImage := Images.Oreo, DefaultDesiredSize:=vector2{X:=200.0,Y:=200.0}}

    # Game Variables
    var CurArray : []int = array{0, 0, 0}
    var CurWidgets : []texture_block = array{}
    var OrderArray : []int = array{0, 0, 0}
    var OrderWidgets : []texture_block = array{}
    var ConeWidgets : []texture_block = array{}
    var CreamWidgets : []texture_block = array{}
    var ToppingWidgets : []texture_block = array{}
    var OrderConeWidgets : []texture_block = array{}
    var OrderCreamWidgets : []texture_block = array{}
    var OrderToppingWidgets : []texture_block = array{}

    # External Variables
    var GameManager : game_manager = game_manager{}
    var MaybeAgent : ?agent = false
    var HudMessage : hud_message_device
    var OpenButton : button_device
    var SuccessAudio : audio_player_device
    var FailAudio : audio_player_device
    var Accolade : accolades_device

    StringToMessage<localizes>(String : string) : message = "{String}"

    AddMiniGameUI(Agent: agent):void=
        set ConeWidgets = array{Cone1Img, Cone3Img}
        set CreamWidgets = array{ChocolateImg, VanillaImg}
        set ToppingWidgets = array{OreoImg, CherryImg}

        set OrderConeWidgets = array{OrderCone1Img, OrderCone3Img}
        set OrderCreamWidgets = array{OrderChocolateImg, OrderVanillaImg}
        set OrderToppingWidgets = array{OrderOreoImg, OrderCherryImg}

        set CurWidgets = array{Cone1Img, ChocolateImg, OreoImg}
        set OrderWidgets = array{OrderCone1Img, OrderChocolateImg, OrderOreoImg}

        ExitButton.OnClick().Subscribe(HandleExit)
        MakeButton.OnClick().Subscribe(HandleMake)
        ConeButton.OnClick().Subscribe(HandleCone)
        CreamButton.OnClick().Subscribe(HandleCream)
        ToppingButton.OnClick().Subscribe(HandleTopping)

        ExitButton.SetText(StringToMessage("Exit"))
        MakeButton.SetText(StringToMessage("Serve Ice Cream!"))
        ConeButton.SetText(StringToMessage("-->"))
        CreamButton.SetText(StringToMessage("-->"))
        ToppingButton.SetText(StringToMessage("-->"))

        Text.SetJustification(text_justification.Center)
        Text.SetText(StringToMessage("Order:"))
        
        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            set MainCanvas = CreateUI()
            PlayerUI.AddWidget(MainCanvas, player_ui_slot{InputMode := ui_input_mode.All})

        InitCurWidgets()
        # NewOrder()

    HandleExit(Message : widget_message) : void=
        Player := Message.Player
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(MainCanvas)
            OpenButton.Enable()

    # Sets a new order
    NewOrder():void=
        # Clear widgets
        for(Item : OrderWidgets):
            Item.SetVisibility(widget_visibility.Hidden)
            MainCanvas.RemoveWidget(Item)

        # Get random order
        for(I:=0..2):
            Index := GetRandomInt(0, 1)
            if(set OrderArray[I] = Index){}

        # Set new widgets
        # Cone
        if(var NewWidget : texture_block = OrderConeWidgets[OrderArray[0]]):
            NewWidget.SetVisibility(widget_visibility.Hidden)
            MainCanvas.AddWidget(
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                Offsets := margin{Left := 380.0, Top := 30.0}
                Alignment := vector2{X := 0.5, Y := 0.5}
                ZOrder := 1
                SizeToContent := false
                Widget := NewWidget
            )
            NewWidget.SetVisibility(widget_visibility.Visible)
            if(set OrderWidgets[0] = NewWidget){}
        # Cream
        if(var NewWidget : texture_block = OrderCreamWidgets[OrderArray[1]]):
            NewWidget.SetVisibility(widget_visibility.Hidden)
            MainCanvas.AddWidget(
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                Offsets := margin{Left := 380.0, Top := -188.0}
                Alignment := vector2{X := 0.5, Y := 0.5}
                ZOrder := 1
                SizeToContent := false
                Widget := NewWidget
            )
            NewWidget.SetVisibility(widget_visibility.Visible)
            if(set OrderWidgets[1] = NewWidget){}

        # Topping
        if(var NewWidget : texture_block = OrderToppingWidgets[OrderArray[2]]):
            NewWidget.SetVisibility(widget_visibility.Hidden)
            MainCanvas.AddWidget(
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                Offsets := margin{Left := 380.0, Top := -330.0}
                Alignment := vector2{X := 0.5, Y := 0.5}
                ZOrder := 1
                SizeToContent := false
                Widget := NewWidget
            )
            NewWidget.SetVisibility(widget_visibility.Visible)
            if(set OrderWidgets[2] = NewWidget){}

    # Checks if the order array and current array are equal
    CheckEquals():logic=
        for(X := 0..2):
            if(OrderArray[X] <> CurArray[X]):
                return false
        return true

    # Makes the ice cream with current array
    HandleMake(Message : widget_message) : void=
        Player := Message.Player
        Result := CheckEquals()
        if(Result?):
            # SuccessAudio.Play(Player)
            if(Agent := MaybeAgent?):
                GameManager.AddOrders(1, Agent)
                HudMessage.Show(Agent)
                Accolade.Award(Agent)
                HandleExit(Message)
        else:
            FailAudio.Play(Player)

    # Cycles to next cone
    HandleCone(Messaage : widget_message) : void=
        # Remove current
        var index : int = 0
        for(Item : CurWidgets):
            if(index = 0):
                Item.SetVisibility(widget_visibility.Hidden)
                MainCanvas.RemoveWidget(Item)
            set index += 1

        # Cycle and add new 
        if(var ConeNum : int = CurArray[0]):
            set ConeNum += 1
            if(ConeNum = 2):
                set ConeNum = 0
            if(set CurArray[0] = ConeNum){}
            if(var NewWidget : texture_block = ConeWidgets[ConeNum]):
                NewWidget.SetVisibility(widget_visibility.Hidden)
                MainCanvas.AddWidget(
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Left := -500.0, Top := 170.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    ZOrder := 2
                    SizeToContent := true
                    Widget := NewWidget
                )
                NewWidget.SetVisibility(widget_visibility.Visible)
                if(set CurWidgets[0] = NewWidget){}

    # Cycles to next cream
    HandleCream(Messaage : widget_message) : void=
        # Remove current 
        var index : int = 0
        for(Item : CurWidgets):
            if(index = 1):
                Item.SetVisibility(widget_visibility.Hidden)
                MainCanvas.RemoveWidget(Item)
            set index += 1

        # Cycle and add new 
        if(var CreamNum : int = CurArray[1]):
            set CreamNum += 1
            if(CreamNum = 2):
                set CreamNum = 0
            if(set CurArray[1] = CreamNum){}
            if(var NewWidget : texture_block = CreamWidgets[CreamNum]):
                NewWidget.SetVisibility(widget_visibility.Hidden)
                MainCanvas.AddWidget(
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Left := -500.0, Top := -130.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    ZOrder := 2
                    SizeToContent := true
                    Widget := NewWidget
                )
                NewWidget.SetVisibility(widget_visibility.Visible)
                if(set CurWidgets[1] = NewWidget){}

    # Cycles to next topping
    HandleTopping(Messaage : widget_message) : void=
        # Remove current 
        var index : int = 0
        for(Item : CurWidgets):
            if(index = 2):
                Item.SetVisibility(widget_visibility.Hidden)
                MainCanvas.RemoveWidget(Item)
            set index += 1

        # Cycle and add new 
        if(var ToppingNum : int = CurArray[2]):
            set ToppingNum += 1
            if(ToppingNum = 2):
                set ToppingNum = 0
            if(set CurArray[2] = ToppingNum){}
            if(var NewWidget : texture_block = ToppingWidgets[ToppingNum]):
                NewWidget.SetVisibility(widget_visibility.Hidden)
                MainCanvas.AddWidget(
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Left := -500.0, Top := -400.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    ZOrder := 2
                    SizeToContent := true
                    Widget := NewWidget
                )
                NewWidget.SetVisibility(widget_visibility.Visible)
                if(set CurWidgets[2] = NewWidget){}

    # Add the first widgets to the canvas and the array
    InitCurWidgets():void=
        # Cone
        if(var NewWidget : texture_block = ConeWidgets[CurArray[0]]):
            NewWidget.SetVisibility(widget_visibility.Hidden)
            MainCanvas.AddWidget(
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                Offsets := margin{Left := -500.0, Top := 170.0}
                Alignment := vector2{X := 0.5, Y := 0.5}
                ZOrder := 2
                SizeToContent := true
                Widget := NewWidget
            )
            NewWidget.SetVisibility(widget_visibility.Visible)
            if(set CurWidgets[0] = NewWidget){}
        
        # Cream
        if(var NewWidget : texture_block = CreamWidgets[CurArray[1]]):
            NewWidget.SetVisibility(widget_visibility.Hidden)
            MainCanvas.AddWidget(
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                Offsets := margin{Left := -500.0, Top := -130.0}
                Alignment := vector2{X := 0.5, Y := 0.5}
                ZOrder := 2
                SizeToContent := true
                Widget := NewWidget
            )
            NewWidget.SetVisibility(widget_visibility.Visible)
            if(set CurWidgets[1] = NewWidget){}

        # Topping
        if(var NewWidget : texture_block = ToppingWidgets[CurArray[2]]):
            NewWidget.SetVisibility(widget_visibility.Hidden)
            MainCanvas.AddWidget(
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                Offsets := margin{Left := -500.0, Top := -400.0}
                Alignment := vector2{X := 0.5, Y := 0.5}
                ZOrder := 2
                SizeToContent := true
                Widget := NewWidget
            )
            NewWidget.SetVisibility(widget_visibility.Visible)
            if(set CurWidgets[2] = NewWidget){}

        # Init order widgets
        # Get random order
        for(I:=0..2):
            Index := GetRandomInt(0, 1)
            if(set OrderArray[I] = Index){}
        # Cone
        if(var NewWidget : texture_block = OrderConeWidgets[OrderArray[0]]):
            NewWidget.SetVisibility(widget_visibility.Hidden)
            MainCanvas.AddWidget(
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                Offsets := margin{Left := 380.0, Top := 30.0}
                Alignment := vector2{X := 0.5, Y := 0.5}
                ZOrder := 1
                SizeToContent := true
                Widget := NewWidget
            )
            NewWidget.SetVisibility(widget_visibility.Visible)
            if(set OrderWidgets[0] = NewWidget){}
        # Cream
        if(var NewWidget : texture_block = OrderCreamWidgets[OrderArray[1]]):
            NewWidget.SetVisibility(widget_visibility.Hidden)
            MainCanvas.AddWidget(
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                Offsets := margin{Left := 380.0, Top := -188.0}
                Alignment := vector2{X := 0.5, Y := 0.5}
                ZOrder := 1
                SizeToContent := true
                Widget := NewWidget
            )
            NewWidget.SetVisibility(widget_visibility.Visible)
            if(set OrderWidgets[1] = NewWidget){}

        # Topping
        if(var NewWidget : texture_block = OrderToppingWidgets[OrderArray[2]]):
            NewWidget.SetVisibility(widget_visibility.Hidden)
            MainCanvas.AddWidget(
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                Offsets := margin{Left := 380.0, Top := -330.0}
                Alignment := vector2{X := 0.5, Y := 0.5}
                ZOrder := 1
                SizeToContent := true
                Widget := NewWidget
            )
            NewWidget.SetVisibility(widget_visibility.Visible)
            if(set OrderWidgets[2] = NewWidget){}

    CreateUI(): canvas=
        NewCanvas : canvas = canvas{
            Slots := array:
                # Item Background
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Left := 380.0, Top := -90.0, Right := 390.0, Bottom := 655.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    ZOrder := 0
                    SizeToContent := false
                    Widget := ItemBackground
                # Text Background
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Left := 380.0, Top := -455.0, Right := 390.0, Bottom := 70.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    ZOrder := 0
                    SizeToContent := false
                    Widget := TextBackground
                # Text
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Left := 380.0, Top := -455.0, Right := 165.0, Bottom := 40.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    ZOrder := 2
                    SizeToContent := false
                    Widget := Text
                # Cone Button
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 135.0, Left := -320.0}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    ZOrder := 2
                    SizeToContent := true
                    Widget := ConeButton
                # Cream Button
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := -150.0, Left := -320.0}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    ZOrder := 2
                    SizeToContent := true
                    Widget := CreamButton
                # Topping Button
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := -435.0, Left := -320.0}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    ZOrder := 2
                    SizeToContent := true
                    Widget := ToppingButton
                # Exit Button
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 1.0}, Maximum := vector2{X := 0.5, Y := 1.0}}
                    Offsets := margin{Top := -170.0, Left := 130.0}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    ZOrder := 2
                    SizeToContent := true
                    Widget := ExitButton
                # Serve Button
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 1.0}, Maximum := vector2{X := 0.5, Y := 1.0}}
                    Offsets := margin{Top := -170.0, Left := -460.0}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    ZOrder := 2
                    SizeToContent := true
                    Widget := MakeButton
        }
        return NewCanvas

# A Verse-authored creative device that can be placed in a level
icecream_game_device := class(creative_device):

    @editable GameManager : game_manager = game_manager{}
    @editable OpenButton : button_device = button_device{}
    @editable HudMessage : hud_message_device = hud_message_device{}
    @editable SuccessAudio : audio_player_device = audio_player_device{}
    @editable FailAudio : audio_player_device = audio_player_device{}
    @editable Accolade : accolades_device = accolades_device{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        OpenButton.InteractedWithEvent.Subscribe(OpenUI)

    OpenUI(Agent: agent):void=
        OpenButton.Disable()
        NewMinigame := minigame{
            MaybeAgent := option{Agent}
            GameManager := GameManager
            HudMessage := HudMessage
            OpenButton := OpenButton
            SuccessAudio := SuccessAudio
            FailAudio := FailAudio
            Accolade := Accolade
        }
        NewMinigame.AddMiniGameUI(Agent)