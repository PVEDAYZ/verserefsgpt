using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Fortnite.com/Game }
using { /Verse.org/Colors }
using { /Verse.org/Simulation/Tags }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.
perplayerdisplay:=class(){
    Device : team_score_display_device
    OurPlayerUI : player_ui
    var Canvas : ?canvas

    TextShadowOffset:?vector2=option{vector2{X:=2.0,Y:=2.0}}

    StringToMessage<localizes>(value:string) : message = "{value}"

    var TeamOneScore:text_block = text_block {DefaultTextColor := NamedColors.White} #White (was Blue)
    var TeamTwoScore:text_block = text_block {DefaultTextColor := NamedColors.White} #Pink (was Red)
    WhiteTeamText:text_block = text_block {DefaultTextColor := NamedColors.White} #Team One (was Blue)
    VsText:text_block = text_block {DefaultTextColor := NamedColors.White} #VS
    PinkTeamText:text_block = text_block {DefaultTextColor := NamedColors.Pink}  #Team Two (was Red)

    InitWidget():void=
        InitDefaultUIValues()
        NewUI := CreateMyUI()
        OurPlayerUI.AddWidget(NewUI, player_ui_slot{ZOrder:=10,InputMode := ui_input_mode.None})
        set Canvas = option{NewUI}

    InitDefaultUIValues():void=
        WhiteTeamText.SetText(StringToMessage("WHITE"))
        PinkTeamText.SetText(StringToMessage("PINK"))
        VsText.SetText(StringToMessage("VS"))
        TeamOneScore.SetText(StringToMessage(ToString("0")))
        TeamTwoScore.SetText(StringToMessage(ToString("0")))

    UpdateUI(InTeamOneScore:int,InTeamTwoScore:int):void=
        TeamOneScore.SetText(StringToMessage(ToString(InTeamOneScore)))
        TeamTwoScore.SetText(StringToMessage(ToString(InTeamTwoScore)))

    CreateMyUI():canvas=
        TeamOneScore.SetShadowOffset(TextShadowOffset)
        TeamOneScore.SetShadowOpacity(1.0)
        TeamOneScore.SetShadowColor(NamedColors.White) # was Blue
        TeamTwoScore.SetShadowOffset(TextShadowOffset)
        TeamTwoScore.SetShadowOpacity(1.0)
        TeamTwoScore.SetShadowColor(NamedColors.Pink)  # was Red
        WhiteTeamText.SetShadowOffset(TextShadowOffset)
        WhiteTeamText.SetShadowOpacity(1.0)
        PinkTeamText.SetShadowOffset(TextShadowOffset)
        PinkTeamText.SetShadowOpacity(1.0)
        VsText.SetShadowOffset(TextShadowOffset)
        VsText.SetShadowOpacity(1.0)

        NewCanvas := canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{ Minimum:= vector2{X:=0.5, Y:=0.04}, Maximum:= vector2{X:=0.5, Y:=0.04} }
                    Alignment := vector2{X:=0.5, Y:=0.0}
                    SizeToContent:=true
                    Widget := stack_box:
                        Orientation := orientation.Horizontal
                        Slots := array:
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Left
                                Widget := stack_box:
                                    Orientation := orientation.Vertical
                                    Slots := array:
                                        stack_box_slot:
                                            HorizontalAlignment := horizontal_alignment.Center
                                            Padding := margin{Top:=6.0, Bottom:= 2.0}
                                            Widget := PinkTeamText
                                        stack_box_slot:
                                            Padding := margin{Top:=2.0, Left:= 12.0, Right:= 12.0, Bottom:= 2.0}
                                            Widget := TeamTwoScore
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                Padding := margin{Top:=2.0, Left:= 24.0, Right:= 24.0, Bottom:= 2.0}
                                Widget := VsText
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Right
                                Widget := stack_box:
                                    Orientation := orientation.Vertical
                                    Slots := array:
                                        stack_box_slot:
                                            HorizontalAlignment := horizontal_alignment.Center
                                            Padding := margin{Top:=6.0, Bottom:= 2.0}
                                            Widget := WhiteTeamText
                                        stack_box_slot:
                                            Padding := margin{Top:=2.0, Left:= 12.0, Right:= 12.0, Bottom:= 2.0}
                                            Widget := TeamOneScore
        return NewCanvas
}

# A Verse-authored creative device that can be placed in a level
team_score_display_device := class(creative_device):
    var MaybeMyUIPerPlayer:[player]perplayerdisplay = map{}
    var TeamOneKills:int=0
    var TeamTwoKills:int=0

    @editable 
    TeamOneWhite : team_settings_and_inventory_device = team_settings_and_inventory_device{} # was Blue
    @editable 
    TeamTwoPink : team_settings_and_inventory_device = team_settings_and_inventory_device{}  # was Red

    OnBegin<override>()<suspends>:void=
        TeamOneWhite.EnemyEliminatedEvent.Subscribe(OnTeamOneScore)
        TeamTwoPink.EnemyEliminatedEvent.Subscribe(OnTeamTwoScore)
        AllPlayers := GetPlayspace().GetPlayers()
        for (L_Agent : AllPlayers):
            HandleJoiningPlayer(L_Agent)
        GetPlayspace().PlayerAddedEvent().Subscribe(HandleJoiningPlayer)

    HandleJoiningPlayer(InAgent:agent):void=
        AddCanvas(InAgent)

    AddCanvas(InAgent:agent):void=
        if (InPlayer := player[InAgent], PlayerUI := GetPlayerUI[InPlayer]):
            if (not MaybeMyUIPerPlayer[InPlayer]):
                PerPlayerDisplay:perplayerdisplay=perplayerdisplay{Device:=Self,OurPlayerUI:=PlayerUI,Canvas:=false}
                PerPlayerDisplay.InitWidget()
                if (set MaybeMyUIPerPlayer[InPlayer] = PerPlayerDisplay) {}

    UpdateUI(InTeamOneScore:int,InTeamTwoScore:int):void=
        for (Key->Value : MaybeMyUIPerPlayer):
            Value.UpdateUI(InTeamOneScore, InTeamTwoScore)

    OnTeamOneScore(InAgent:agent):void=
        IncTeamOneKills()
        UpdateUI(TeamOneKills,TeamTwoKills)

    OnTeamTwoScore(InAgent:agent):void=
        IncTeamTwoKills()
        UpdateUI(TeamOneKills,TeamTwoKills)

    IncTeamOneKills()<transacts>:void=
        set TeamOneKills += 1

    IncTeamTwoKills()<transacts>:void=
        set TeamTwoKills += 1
