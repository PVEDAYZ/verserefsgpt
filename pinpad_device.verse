using { /Fortnite.com/Devices }
using { /Fortnite.com/UI } 
using { /Verse.org/Simulation }
using { /Verse.org/Colors }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# -------------------------------------------------------------------
# code_location: unchanged behavior; optional accolades on UI open.
# -------------------------------------------------------------------
code_location<public> := class<concrete>:
    StringToMessage<localizes>(String : string) : message = "{String}"

    @editable Button : button_device = button_device{}
    @editable DisplayString : string = "_______"
    @editable ViewAccolades : []accolades_device = array{}    # OPTIONAL

    var MainCanvas : canvas = canvas{}

    InitButton():void=
        Button.InteractedWithEvent.Subscribe(OpenUI)

    OpenUI(Agent: agent):void=
        # Award for viewing this location (no-op if none wired)
        for(A : ViewAccolades):
            A.Award(Agent)

        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            set MainCanvas = MakeCanvas()
            PlayerUI.AddWidget(MainCanvas, player_ui_slot{InputMode := ui_input_mode.All})

    MakeCanvas():canvas=
        ExitButton := button_regular{DefaultText:=StringToMessage("Exit")}
        ExitButton.OnClick().Subscribe(Exit)
        MyCanvas:= canvas:
            Slots:=array:
                canvas_slot:
                    Anchors:=anchors{Minimum:=vector2{X:=0.5,Y:=0.5}, Maximum:=vector2{X:=0.5,Y:=0.5}}
                    Alignment:=vector2{X:=0.5,Y:=0.5}
                    SizeToContent:=true
                    Offsets:=margin{Top:=-100.0}
                    Widget:=text_block{DefaultText:=StringToMessage("{DisplayString}")}
                canvas_slot:
                    Anchors:=anchors{Minimum:=vector2{X:=0.5,Y:=0.5}, Maximum:=vector2{X:=0.5,Y:=0.5}}
                    Alignment:=vector2{X:=0.5,Y:=0.5}
                    SizeToContent:=true
                    Offsets:=margin{Top:=100.0}
                    Widget:=ExitButton
        return MyCanvas

    Exit(WM:widget_message):void=
        Player := WM.Player
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(MainCanvas)


# -------------------------------------------------------------------
# pinpad_device: same gameplay; optional accolades on open/success/fail.
# Expanded UI slots to canonical multi-line form (no inline shorthand).
# -------------------------------------------------------------------
pinpad_device := class(creative_device):
    StringToMessage<localizes>(String : string) : message = "{String}"
    
    @editable GameManager : game_manager = game_manager{}
    @editable OpenButton : button_device = button_device{}
    @editable OpenVault : creative_prop = creative_prop{}
    @editable ClosedVault : creative_prop = creative_prop{}
    @editable CodeLocations : []code_location = array{}

    # OPTIONAL accolades
    @editable OpenAccolades : []accolades_device = array{}      # when UI opens
    @editable SuccessAccolades : []accolades_device = array{}   # correct code
    @editable FailAccolades : []accolades_device = array{}      # wrong code

    var MainCanvas : canvas = canvas{}
    var NumTB : text_block = text_block{}
    Code : string = "5242170"
    var LastAgent : ?agent = false

    OnBegin<override>()<suspends>:void=
        HideProp(OpenVault)
        OpenButton.InteractedWithEvent.Subscribe(OpenUI)
        for(Loc : CodeLocations):
            Loc.InitButton()

    OpenUI(Agent: agent):void=
        set LastAgent = option{Agent}
        AwardAccolades(LastAgent, OpenAccolades)

        OpenButton.Disable()
        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            set MainCanvas = MakeCanvas()
            PlayerUI.AddWidget(MainCanvas, player_ui_slot{InputMode := ui_input_mode.All})

    Add0(WM:widget_message):void={AddChar("0")}
    Add1(WM:widget_message):void={AddChar("1")}
    Add2(WM:widget_message):void={AddChar("2")}
    Add3(WM:widget_message):void={AddChar("3")}
    Add4(WM:widget_message):void={AddChar("4")}
    Add5(WM:widget_message):void={AddChar("5")}
    Add6(WM:widget_message):void={AddChar("6")}
    Add7(WM:widget_message):void={AddChar("7")}
    Add8(WM:widget_message):void={AddChar("8")}
    Add9(WM:widget_message):void={AddChar("9")}

    MakeCanvas():canvas=
        Button0 := button_loud{DefaultText:=StringToMessage("0")}
        Button0.OnClick().Subscribe(Add0)
        Button1 := button_loud{DefaultText:=StringToMessage("1")}
        Button1.OnClick().Subscribe(Add1)
        Button2 := button_loud{DefaultText:=StringToMessage("2")}
        Button2.OnClick().Subscribe(Add2)
        Button3 := button_loud{DefaultText:=StringToMessage("3")}
        Button3.OnClick().Subscribe(Add3)
        Button4 := button_loud{DefaultText:=StringToMessage("4")}
        Button4.OnClick().Subscribe(Add4)
        Button5 := button_loud{DefaultText:=StringToMessage("5")}
        Button5.OnClick().Subscribe(Add5)
        Button6 := button_loud{DefaultText:=StringToMessage("6")}
        Button6.OnClick().Subscribe(Add6)
        Button7 := button_loud{DefaultText:=StringToMessage("7")}
        Button7.OnClick().Subscribe(Add7)
        Button8 := button_loud{DefaultText:=StringToMessage("8")}
        Button8.OnClick().Subscribe(Add8)
        Button9 := button_loud{DefaultText:=StringToMessage("9")}
        Button9.OnClick().Subscribe(Add9)
        DelButton := button_regular{DefaultText:=StringToMessage("DEL")}
        DelButton.OnClick().Subscribe(RemoveChar)
        RetButton := button_regular{DefaultText:=StringToMessage(">>")}
        RetButton.OnClick().Subscribe(Enter)

        set NumTB = text_block{DefaultText:=StringToMessage(""), DefaultTextColor:=White}

        MyCanvas:= canvas:
            Slots:=array:
                canvas_slot:
                    Anchors:=anchors{Minimum:=vector2{X:=0.5,Y:=0.5}, Maximum:=vector2{X:=0.5,Y:=0.5}}
                    Alignment:=vector2{X:=0.5,Y:=0.5}
                    SizeToContent:=true
                    Widget:=overlay:
                        Slots:=array:
                            # Outside Colorblock
                            overlay_slot:
                                HorizontalAlignment:=horizontal_alignment.Fill
                                VerticalAlignment:=vertical_alignment.Fill
                                Widget:=color_block{DefaultColor := Black, DefaultOpacity := 0.0, DefaultDesiredSize:=vector2{X:=32.0,Y:=850.0}}
                            # Pinpad Overlay
                            overlay_slot:
                                HorizontalAlignment:=horizontal_alignment.Center
                                VerticalAlignment:=vertical_alignment.Bottom
                                Padding:=margin{Bottom:=100.0}
                                Widget:=overlay:
                                    Slots:=array:
                                        # Pinpad Colorblock
                                        overlay_slot:
                                            HorizontalAlignment:=horizontal_alignment.Fill
                                            VerticalAlignment:=vertical_alignment.Fill
                                            Widget:=color_block{DefaultColor := Black, DefaultOpacity := 0.3, DefaultDesiredSize:=vector2{X:=450.0,Y:=32.0}}
                                        # Pinpad
                                        overlay_slot:
                                            HorizontalAlignment:=horizontal_alignment.Fill
                                            VerticalAlignment:=vertical_alignment.Fill
                                            Padding:=margin{Left:= 0.0, Top:=30.0, Right:=0.0, Bottom:=30.0}
                                            Widget:=stack_box:
                                                Orientation:=orientation.Vertical
                                                Slots:=array:
                                                    # 1-3 Row
                                                    stack_box_slot:
                                                        HorizontalAlignment:=horizontal_alignment.Fill
                                                        VerticalAlignment:=vertical_alignment.Fill
                                                        Padding:=margin{Left:= 0.0, Top:=30.0, Right:=0.0, Bottom:=30.0}
                                                        Widget:=stack_box:
                                                            Orientation:=orientation.Horizontal
                                                            Slots:=array:
                                                                stack_box_slot:
                                                                    Distribution:=option{1.0}
                                                                    HorizontalAlignment:=horizontal_alignment.Center
                                                                    VerticalAlignment:=vertical_alignment.Center
                                                                    Widget:=Button1
                                                                stack_box_slot:
                                                                    Distribution:=option{1.0}
                                                                    HorizontalAlignment:=horizontal_alignment.Center
                                                                    VerticalAlignment:=vertical_alignment.Center
                                                                    Widget:=Button2
                                                                stack_box_slot:
                                                                    Distribution:=option{1.0}
                                                                    HorizontalAlignment:=horizontal_alignment.Center
                                                                    VerticalAlignment:=vertical_alignment.Center
                                                                    Widget:=Button3
                                                    # 4-6 Row
                                                    stack_box_slot:
                                                        HorizontalAlignment:=horizontal_alignment.Fill
                                                        VerticalAlignment:=vertical_alignment.Fill
                                                        Padding:=margin{Left:= 0.0, Top:=30.0, Right:=0.0, Bottom:=30.0}
                                                        Widget:=stack_box:
                                                            Orientation:=orientation.Horizontal
                                                            Slots:=array:
                                                                stack_box_slot:
                                                                    Distribution:=option{1.0}
                                                                    HorizontalAlignment:=horizontal_alignment.Center
                                                                    VerticalAlignment:=vertical_alignment.Center
                                                                    Widget:=Button4
                                                                stack_box_slot:
                                                                    Distribution:=option{1.0}
                                                                    HorizontalAlignment:=horizontal_alignment.Center
                                                                    VerticalAlignment:=vertical_alignment.Center
                                                                    Widget:=Button5
                                                                stack_box_slot:
                                                                    Distribution:=option{1.0}
                                                                    HorizontalAlignment:=horizontal_alignment.Center
                                                                    VerticalAlignment:=vertical_alignment.Center
                                                                    Widget:=Button6
                                                    # 7-9 Row
                                                    stack_box_slot:
                                                        HorizontalAlignment:=horizontal_alignment.Fill
                                                        VerticalAlignment:=vertical_alignment.Fill
                                                        Padding:=margin{Left:= 0.0, Top:=30.0, Right:=0.0, Bottom:=30.0}
                                                        Widget:=stack_box:
                                                            Orientation:=orientation.Horizontal
                                                            Slots:=array:
                                                                stack_box_slot:
                                                                    Distribution:=option{1.0}
                                                                    HorizontalAlignment:=horizontal_alignment.Center
                                                                    VerticalAlignment:=vertical_alignment.Center
                                                                    Widget:=Button7
                                                                stack_box_slot:
                                                                    Distribution:=option{1.0}
                                                                    HorizontalAlignment:=horizontal_alignment.Center
                                                                    VerticalAlignment:=vertical_alignment.Center
                                                                    Widget:=Button8
                                                                stack_box_slot:
                                                                    Distribution:=option{1.0}
                                                                    HorizontalAlignment:=horizontal_alignment.Center
                                                                    VerticalAlignment:=vertical_alignment.Center
                                                                    Widget:=Button9
                                                    # del-0-enter Row
                                                    stack_box_slot:
                                                        HorizontalAlignment:=horizontal_alignment.Fill
                                                        VerticalAlignment:=vertical_alignment.Fill
                                                        Padding:=margin{Left:= 0.0, Top:=30.0, Right:=0.0, Bottom:=30.0}
                                                        Widget:=stack_box:
                                                            Orientation:=orientation.Horizontal
                                                            Slots:=array:
                                                                stack_box_slot:
                                                                    Distribution:=option{1.0}
                                                                    HorizontalAlignment:=horizontal_alignment.Center
                                                                    VerticalAlignment:=vertical_alignment.Center
                                                                    Widget:=DelButton
                                                                stack_box_slot:
                                                                    Distribution:=option{1.0}
                                                                    HorizontalAlignment:=horizontal_alignment.Center
                                                                    VerticalAlignment:=vertical_alignment.Center
                                                                    Widget:=Button0
                                                                stack_box_slot:
                                                                    Distribution:=option{1.0}
                                                                    HorizontalAlignment:=horizontal_alignment.Center
                                                                    VerticalAlignment:=vertical_alignment.Center
                                                                    Widget:=RetButton
                            # Number Overlay
                            overlay_slot:
                                HorizontalAlignment:=horizontal_alignment.Center
                                VerticalAlignment:=vertical_alignment.Top
                                Padding:=margin{Bottom:=100.0}
                                Widget:=overlay:
                                    Slots:=array:
                                        overlay_slot:
                                            HorizontalAlignment:=horizontal_alignment.Fill
                                            VerticalAlignment:=vertical_alignment.Fill
                                            Widget:=color_block{DefaultColor:=Black, DefaultDesiredSize:=vector2{X:=410.0,Y:=60.0}}
                                        overlay_slot:
                                            HorizontalAlignment:=horizontal_alignment.Center
                                            VerticalAlignment:=vertical_alignment.Center
                                            Widget:=NumTB
        return MyCanvas

    AddChar(Num:string):void=
        Cur := NumTB.GetText()
        NumTB.SetText(StringToMessage("{Cur+Num}"))
    
    RemoveChar(WM:widget_message):void=
        Cur := NumTB.GetText()
        var NewString : string = ""
        for(Index->S:Cur):
            if(Index < Cur.Length-1):
                set NewString += "{S}"
        NumTB.SetText(StringToMessage(NewString))
    
    Enter(WM:widget_message):void=
        Cur := NumTB.GetText()
        OpenButton.Enable()
        if(Cur = Code):
            HideProp(ClosedVault)
            ShowProp(OpenVault)
            AwardAccolades(LastAgent, SuccessAccolades)
        else:
            AwardAccolades(LastAgent, FailAccolades)

        Player := WM.Player
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(MainCanvas)

    # ---------- Helpers ----------
    AwardAccolades(MaybeAgent : ?agent, List : []accolades_device):void=
        if(List.Length = 0):
            return
        if(Agent := MaybeAgent?):
            for(A : List):
                A.Award(Agent)
