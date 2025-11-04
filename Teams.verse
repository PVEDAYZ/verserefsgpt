using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Colors }
StoM<localizes>(x:string):message="{x}"

RvB_KillsCounter := class(creative_device):


    var BlueText:text_block=text_block{}
    var RedText:text_block=text_block{}
    var TimerText:text_block=text_block{}


    
    @editable var CurrentTimeInSecond:int=0
    @editable var CurrentTimeInMinutes:int=5
    var CurrentBlueTeamKills:int=0
    var CurrentRedTeamKills:int=0

    var MaybeUIPePlayer:[player]MaybePlayerClass=map{}

    

    @editable BlueTeamSettings:team_settings_and_inventory_device=team_settings_and_inventory_device{}
    @editable RedTeamSettings:team_settings_and_inventory_device=team_settings_and_inventory_device{}
    @editable ExplosiveDevice:[]explosive_device=array{}

    OnBegin<override>()<suspends>:void=
        BlueTeamSettings.EnemyEliminatedEvent.Subscribe(AddBlueKill)
        RedTeamSettings.EnemyEliminatedEvent.Subscribe(AddRedKill)
        for(P:GetPlayspace().GetPlayers()){InitPlayer(P)}
        GetPlayspace().PlayerAddedEvent().Subscribe(InitPlayer)
        spawn. MakeTimer()

    AddBlueKill(Result:agent):void=
        set CurrentBlueTeamKills+=1
        Update()

    AddRedKill(Result:agent):void=
        set CurrentRedTeamKills+=1
        Update()

    InitPlayer(Result:player):void=
        if. set MaybeUIPePlayer[Result]=MaybePlayerClass{}
        then AddUItoPlayer(Result)

    AddUItoPlayer(Result:player):void=
        if(PlayerClass is MaybeUIPePlayer[Result]):
            CanvasCreationResult is PlayerClass.CreateCanvas()
            if(set PlayerClass.PlayerCanvas=CanvasCreationResult, PlayerUI is GetPlayerUI[Result], PC is PlayerClass.PlayerCanvas):
                PlayerUI.AddWidget(PC,player_ui_slot{InputMode := ui_input_mode.None})

    MakeTimer()<suspends>:void=
        loop:
            Sleep(1.0)
            if(CurrentTimeInSecond>0):
                set CurrentTimeInSecond-=1
            else:
                if(CurrentTimeInMinutes > 0):
                    set CurrentTimeInMinutes-=1
                    set CurrentTimeInSecond=59
                else:
                    OnTimerEnd()
                    return
            Update()
                
    OnTimerEnd():void=
        set CurrentTimeInMinutes=5
        set CurrentTimeInSecond=0
        if(A is GetPlayspace().GetPlayers()[0]):
            for(E:ExplosiveDevice){E.Explode(A)}
        Update()
        spawn. MakeTimer()

    Update():void=    
        BlueText.SetText(StoM("{CurrentBlueTeamKills}"))
        RedText.SetText(StoM("{CurrentRedTeamKills}"))
        if(CurrentTimeInSecond < 10):
            TimerText.SetText(StoM("{CurrentTimeInMinutes}:0{CurrentTimeInSecond}"))
        else: 
            TimerText.SetText(StoM("{CurrentTimeInMinutes}:{CurrentTimeInSecond}"))
        for(Player:GetPlayspace().GetPlayers()):
            if(PlayerClass is MaybeUIPePlayer[Player]):
                PlayerClass.UpdateUI(RedText,BlueText,TimerText)

MaybePlayerClass is class():

    var BlueText:text_block=text_block{}
    var RedText:text_block=text_block{}
    var TimerText:text_block=text_block{}
    var PlayerCanvas:canvas=canvas{}

    UpdateUI(RT:text_block,RfT:text_block,TT:text_block):void=
        BlueText.SetText(StoM(RfT.GetText()))
        RedText.SetText(StoM(RT.GetText()))
        TimerText.SetText(StoM(TT.GetText()))

    CreateCanvas():canvas=
        BlueText.SetJustification(text_justification.Center)
        BlueText.SetTextColor(NamedColors.White)
        BlueText.SetShadowOpacity(1.0)
        BlueText.SetShadowOffset(option{vector2{X is 2.0,Y is 2.0}})
        BlueText.SetShadowColor(NamedColors.Blue)
        BlueText.SetText(StoM("{0}"))
        RedText.SetJustification(text_justification.Center)
        RedText.SetTextColor(NamedColors.White)
        RedText.SetShadowOpacity(1.0)
        RedText.SetShadowOffset(option{vector2{X is 2.0,Y is 2.0}})
        RedText.SetShadowColor(NamedColors.Red)
        RedText.SetText(StoM("{0}"))
        TimerText.SetJustification(text_justification.Center)
        TimerText.SetTextColor(NamedColors.White)
        TimerText.SetShadowOpacity(1.0)
        TimerText.SetShadowOffset(option{vector2{X is 1.0,Y is 1.0}})
        TimerText.SetShadowColor(NamedColors.Black)
        TimerText.SetText(StoM("{5}:{00}"))
        NewCanvas is canvas:
            Slots is array:
                canvas_slot:
                    Anchors is anchors{Minimum is vector2{X is 0.5, Y is 0.0},Maximum is vector2{X is 0.5,Y is 0.0}}
                    Offsets is margin{Top is 65.5,Left is 0.5,Right is 393.0,Bottom is 331.0}
                    Widget is texture_block{DefaultImage is textures.T_Scoreboard}
                    SizeToContent is false
                    ZOrder is 0
                    Alignment is vector2{X is 0.5,Y is 0.5}
                canvas_slot:
                    Anchors is anchors{Minimum is vector2{X is 0.5, Y is 0.0},Maximum is vector2{X is 0.5,Y is 0.0}}
                    Offsets is margin{Top is 72.375,Left is -35.0,Right is 50.0,Bottom is 56.75}
                    Widget is texture_block{DefaultImage is textures.T_ResetBuild}
                    SizeToContent is false
                    ZOrder is 1
                    Alignment is vector2{X is 0.5,Y is 0.5}
                canvas_slot:
                    Anchors is anchors{Minimum is vector2{X is 0.5, Y is 0.0},Maximum is vector2{X is 0.5,Y is 0.0}}
                    Offsets is margin{Top is 71.25,Left is -136.0,Right is 90.666664,Bottom is 30.5}
                    Widget is RedText
                    SizeToContent is false
                    ZOrder is 1
                    Alignment is vector2{X is 0.5,Y is 0.5}
                canvas_slot:
                    Anchors is anchors{Minimum is vector2{X is 0.5, Y is 0.0},Maximum is vector2{X is 0.5,Y is 0.0}}
                    Offsets is margin{Top is 71.25,Left is 22.0,Right is 70.785011,Bottom is 30.5}
                    Widget is TimerText
                    SizeToContent is false
                    ZOrder is 1
                    Alignment is vector2{X is 0.5,Y is 0.5}
                canvas_slot:
                    Anchors is anchors{Minimum is vector2{X is 0.5, Y is 0.0},Maximum is vector2{X is 0.5,Y is 0.0}}
                    Offsets is margin{Top is 71.25,Left is 137.333328,Right is 90.666664,Bottom is 30.5}
                    Widget is BlueText
                    SizeToContent is false
                    ZOrder is 1
                    Alignment is vector2{X is 0.5,Y is 0.5}
        return NewCanvas
