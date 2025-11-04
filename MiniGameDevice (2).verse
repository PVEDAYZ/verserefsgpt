
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors/NamedColors }
using { /Fortnite.com/UI }

MiniGame := class():
    var MainCanvas : canvas = canvas{}
    var BarBackground : color_block = color_block{DefaultColor := White}
    var BarGoal : color_block = color_block{DefaultColor := Green}
    var MovingPiece : color_block = color_block{DefaultColor := Black}
    var ClickButton : button_loud = button_loud{}
    var ExitButton : button_loud = button_loud{}

    var RewardTrigger : trigger_device = trigger_device{}
    var XValue : float = -600.0

    var EndLoop : logic = false

    StringToMessage<localizes>(String : string) : message = "{String}"
    
    AddMiniGameUI(Agent:agent) : void=
        ExitButton.OnClick().Subscribe(HandleExit)
        ClickButton.OnClick().Subscribe(HandleClick)
        ExitButton.SetText(StringToMessage("Exit"))
        ClickButton.SetText(StringToMessage("Click"))

        if(Player := player[Agent],PlayerUI := GetPlayerUI[Player]):
            set MainCanvas = CreateUI()
            PlayerUI.AddWidget(MainCanvas, player_ui_slot{InputMode := ui_input_mode.All})


    HandleExit(Message : widget_message) : void=
        Player := Message.Player
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(MainCanvas)
            set EndLoop = true

    HandleClick(Message : widget_message) : void=
        Player := Message.Player
        if(XValue > -90.0 and XValue < 90.0):
            RewardTrigger.Trigger(Player)
            if(PlayerUI := GetPlayerUI[Player]):
                PlayerUI.RemoveWidget(MainCanvas)
                set EndLoop = true

    CreateUI() : canvas=
        NewCanvas : canvas = canvas{
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:= 0.5, Y:= 0.5}, Maximum := vector2{X:= 0.5, Y:= 0.5}}
                    Offsets := margin{Left := 0.0, Top := 100.0,Right := 1250.0 , Bottom := 70.0}
                    Alignment := vector2{X:= 0.5, Y:=0.5}
                    ZOrder := 0
                    SizeToContent := false
                    Widget := BarBackground

                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:= 0.5, Y:= 0.5}, Maximum := vector2{X:= 0.5, Y:= 0.5}}
                    Offsets := margin{Left := 0.0, Top := 100.0,Right := 200.0 , Bottom := 67.0}
                    Alignment := vector2{X:= 0.5, Y:=0.5}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := BarGoal

                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:= 0.5, Y:= 0.5}, Maximum := vector2{X:= 0.5, Y:= 0.5}}
                    Offsets := margin{Left := -600.0, Top := 100.0,Right := 50.0 , Bottom := 90.0}
                    Alignment := vector2{X:= 0.5, Y:=0.5}
                    ZOrder := 2
                    SizeToContent := false
                    Widget := MovingPiece

                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:= 0.5, Y:= 0.5}, Maximum := vector2{X:= 0.5, Y:= 0.5}}
                    Offsets := margin{Left := 0.0, Top := 230.0,Right := 350.0 , Bottom := 60.0}
                    Alignment := vector2{X:= 0.5, Y:=0.5}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := ClickButton

                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:= 0.5, Y:= 0.5}, Maximum := vector2{X:= 0.5, Y:= 0.5}}
                    Offsets := margin{Left := 0.0, Top := 360.0,Right := 350.0 , Bottom := 60.0}
                    Alignment := vector2{X:= 0.5, Y:=0.5}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := ExitButton
                    
        }
        spawn:
            MovePiece()
        return NewCanvas

    MovePiece()<suspends> : void=
        var Direction : logic = false

        loop:
            Sleep(0.0)
            if(Direction = false):
                set XValue += 12.0
            else if(Direction = true):
                set XValue -= 12.0

            if(XValue = 600.0):
                set Direction = true
            else if(XValue = -600.0):
                set Direction = false
            
            UpdatePiece()
            if(EndLoop = true):
                break


    UpdatePiece() : void=
        MovingPiece.SetVisibility(widget_visibility.Hidden)
        MainCanvas.RemoveWidget(MovingPiece)
        MovingPiece.SetVisibility(widget_visibility.Visible)
        MainCanvas.AddWidget(
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X:= 0.5, Y:= 0.5}, Maximum := vector2{X:= 0.5, Y:= 0.5}}
                Offsets := margin{Left := XValue, Top := 100.0,Right := 50.0 , Bottom := 90.0}
                Alignment := vector2{X:= 0.5, Y:=0.5}
                ZOrder := 2
                SizeToContent := false
                Widget := MovingPiece
        )

            




MiniGameDevice := class(creative_device):
    @editable RewardTrigger : trigger_device = trigger_device{}
    @editable OpenButton : button_device = button_device{}
    OnBegin<override>()<suspends>:void=
        OpenButton.InteractedWithEvent.Subscribe(OpenUI)


    OpenUI(Agent:agent) : void=
        NewMinigame := MiniGame{RewardTrigger := RewardTrigger}
        NewMinigame.AddMiniGameUI(Agent)