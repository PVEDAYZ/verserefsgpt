
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Colors }
using { /UnrealEngine.com/Temporary/SpatialMath }

# Admin console device - opens UI with pin pad for entering admin code
admin_console_device := class(creative_device):

    # Link a button to trigger the console
    @editable
    TriggerButton : button_device = button_device{}

    # Game manager to grant currency
    @editable
    GameManager : game_manager = game_manager{}

    # Admin code (default: 1234)
    @editable
    AdminCode : string = "1234"

    # Amount of money to grant when code is correct
    @editable
    MoneyToGrant : int = 100000

    # Success/fail audio
    @editable
    SuccessAudio : audio_player_device = audio_player_device{}

    @editable
    FailAudio : audio_player_device = audio_player_device{}

    # Track active UI sessions
    var ActiveSessions : [agent]admin_session = map{}

    OnBegin<override>()<suspends>:void=
        TriggerButton.InteractedWithEvent.Subscribe(OnButtonPressed)

    OnButtonPressed(Agent : agent):void=
        # Create or get session for this agent
        if (Session := ActiveSessions[Agent]):
            # Session already exists, just show UI again
            Session.ShowConsole()
        else:
            # Create new session
            NewSession := admin_session{Console := Self}
            NewSession.SetAgent(Agent)
            if (set ActiveSessions[Agent] = NewSession):
                NewSession.Initialize()

    # Called by session when code is entered
    CheckCode(Agent : agent, Code : string):void=
        if (Code = AdminCode):
            # Correct code!
            Print("Admin access granted")
            SuccessAudio.Play(Agent)
            GameManager.AddMoney(MoneyToGrant, Agent)
            if (Session := ActiveSessions[Agent]):
                Session.ShowSuccess()
        else:
            # Wrong code
            Print("Invalid admin code")
            FailAudio.Play(Agent)
            if (Session := ActiveSessions[Agent]):
                Session.ShowFailure()

# Session class to handle UI for each player
admin_session := class:
    var Console : admin_console_device = admin_console_device{}
    var<private> CurrentAgent : ?agent = false
    var EnteredCode : string = ""
    
    # UI Elements
    var MainCanvas : canvas = canvas{}
    var TitleText : text_block = text_block{
        DefaultTextColor := White,
        DefaultJustification := text_justification.Center,
        DefaultTextSize := 40.0
    }
    var CodeDisplay : text_block = text_block{
        DefaultTextColor := Yellow,
        DefaultJustification := text_justification.Center,
        DefaultTextSize := 50.0
    }
    var MessageText : text_block = text_block{
        DefaultTextColor := Red,
        DefaultJustification := text_justification.Center,
        DefaultTextSize := 25.0
    }
    var Background : color_block = color_block{
        DefaultColor := Black
        DefaultOpacity := 0.95
    }
    
    # Number buttons
    var Button0 : button_regular = button_regular{}
    var Button1 : button_regular = button_regular{}
    var Button2 : button_regular = button_regular{}
    var Button3 : button_regular = button_regular{}
    var Button4 : button_regular = button_regular{}
    var Button5 : button_regular = button_regular{}
    var Button6 : button_regular = button_regular{}
    var Button7 : button_regular = button_regular{}
    var Button8 : button_regular = button_regular{}
    var Button9 : button_regular = button_regular{}
    var ClearButton : button_regular = button_regular{}
    var SubmitButton : button_regular = button_regular{}
    var CloseButton : button_regular = button_regular{}

    SetAgent(Agent : agent):void=
        set CurrentAgent = option{Agent}

    Initialize():void=
        if (Agent := CurrentAgent?):
            if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
                set MainCanvas = CreateUI()
                PlayerUI.AddWidget(MainCanvas)
                
                # Subscribe to button events
                Button0.OnClick().Subscribe(OnNumber0)
                Button1.OnClick().Subscribe(OnNumber1)
                Button2.OnClick().Subscribe(OnNumber2)
                Button3.OnClick().Subscribe(OnNumber3)
                Button4.OnClick().Subscribe(OnNumber4)
                Button5.OnClick().Subscribe(OnNumber5)
                Button6.OnClick().Subscribe(OnNumber6)
                Button7.OnClick().Subscribe(OnNumber7)
                Button8.OnClick().Subscribe(OnNumber8)
                Button9.OnClick().Subscribe(OnNumber9)
                ClearButton.OnClick().Subscribe(OnClear)
                SubmitButton.OnClick().Subscribe(OnSubmit)
                CloseButton.OnClick().Subscribe(OnClose)
                
                ShowConsole()

    CreateUI():canvas=
        canvas:
            Slots := array:
                # Background
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := -300.0, Left := -250.0, Right := 250.0, Bottom := 300.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := false
                    Widget := Background
                
                # Title
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := -280.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := TitleText
                
                # Code Display
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := -210.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := CodeDisplay
                
                # Message Text
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := -150.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := MessageText
                
                # Number pad - Row 1 (1, 2, 3)
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := -80.0, Left := -120.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := Button1
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := -80.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := Button2
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := -80.0, Left := 120.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := Button3
                
                # Number pad - Row 2 (4, 5, 6)
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 0.0, Left := -120.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := Button4
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := Button5
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 0.0, Left := 120.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := Button6
                
                # Number pad - Row 3 (7, 8, 9)
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 80.0, Left := -120.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := Button7
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 80.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := Button8
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 80.0, Left := 120.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := Button9
                
                # Number pad - Row 4 (Clear, 0, Submit)
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 160.0, Left := -120.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := ClearButton
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 160.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := Button0
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 160.0, Left := 120.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := SubmitButton
                
                # Close button
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 240.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := CloseButton

    ShowConsole():void=
        set EnteredCode = ""
        TitleText.SetText(MakeMessage("ADMIN CONSOLE"))
        CodeDisplay.SetText(MakeMessage("****"))
        MessageText.SetText(MakeMessage("Enter Admin Code"))
        MessageText.SetTextColor(White)
        
        MainCanvas.SetVisibility(widget_visibility.Visible)

    HideConsole():void=
        MainCanvas.SetVisibility(widget_visibility.Hidden)

    MakeMessage<localizes>(Msg : string) : message = "{Msg}"

    UpdateCodeDisplay():void=
        # Show asterisks for entered digits
        var DisplayText : string = ""
        for (I := 1..EnteredCode.Length):
            set DisplayText = DisplayText + "*"
        
        # Add underscores for remaining digits (max 10 digits)
        RemainingDigits := 10 - EnteredCode.Length
        for (I := 1..RemainingDigits):
            set DisplayText = DisplayText + "_"
        
        CodeDisplay.SetText(MakeMessage(DisplayText))

    AddDigit(Digit : string):void=
        if (EnteredCode.Length < 10):
            set EnteredCode = EnteredCode + Digit
            UpdateCodeDisplay()

    OnNumber0(Message:widget_message):void=
        AddDigit("0")

    OnNumber1(Message:widget_message):void=
        AddDigit("1")

    OnNumber2(Message:widget_message):void=
        AddDigit("2")

    OnNumber3(Message:widget_message):void=
        AddDigit("3")

    OnNumber4(Message:widget_message):void=
        AddDigit("4")

    OnNumber5(Message:widget_message):void=
        AddDigit("5")

    OnNumber6(Message:widget_message):void=
        AddDigit("6")

    OnNumber7(Message:widget_message):void=
        AddDigit("7")

    OnNumber8(Message:widget_message):void=
        AddDigit("8")

    OnNumber9(Message:widget_message):void=
        AddDigit("9")

    OnClear(Message:widget_message):void=
        set EnteredCode = ""
        UpdateCodeDisplay()
        MessageText.SetText(MakeMessage("Enter Admin Code"))
        MessageText.SetTextColor(White)

    OnSubmit(Message:widget_message):void=
        if:
            EnteredCode.Length > 0
            Agent := CurrentAgent?
        then:
            Console.CheckCode(Agent, EnteredCode)

    OnClose(Message:widget_message):void=
        HideConsole()

    ShowSuccess():void=
        MessageText.SetText(MakeMessage("ACCESS GRANTED! Money Added!"))
        MessageText.SetTextColor(Green)
        spawn:
            AutoClose()

    ShowFailure():void=
        MessageText.SetText(MakeMessage("ACCESS DENIED! Invalid Code!"))
        MessageText.SetTextColor(Red)
        set EnteredCode = ""
        UpdateCodeDisplay()

    AutoClose()<suspends>:void=
        Sleep(2.0)
        HideConsole()
