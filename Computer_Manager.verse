using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors }
using { /Fortnite.com/Characters }
using { /Fortnite.com/UI }
using { /Verse.org/Colors/NamedColors }

#THIS DEVICE IS USED TO MAKE A COMPUTER THAT PLAYERS CAN OPEN AND DISPLAYS LOADING SCREENS

#Class for different upgrades
Upgrade := class<concrete>():
    TT_CM_Device_UpgradeTrigger<localizes>:message = "A trigger device that will be used to purchase this upgrade"
    @editable Trigger : trigger_device = trigger_device{}

    TT_CM_Device_ChangePropSettings<localizes>:message = "The settings for changing props when the upgrade is purchased"
    @editable ChangePropSettings : ChangePropSetting = ChangePropSetting{}


    TT_CM_Device_IncreaseType<localizes>:message = "Determines how 'UpgradeAmount' will affect the speed"
    @editable IncreaseType : increasetype = increasetype.Add

    TT_CM_Device_UpgradeAmount<localizes>:message = "The amount that the upgrade will affect the speed"
    @editable UpgradeAmount : float = 0.0

    TT_CM_Device_Reusable<localizes>:message = "Determines if this upgrade can be applied multiple times (switched on and off)"
    @editable Reusable : logic = false

    TT_CM_Device_CostResources<localizes>:message = "The resources that the upgrade will cost"
    @editable CostResources : []SpendableResource = array{}
    var IDX : int = 0

#Class for different progreess bars that appear on the PC
ProgressBar := class<concrete>():
    #UI Stuff
    var BarCanvas : canvas = canvas{}
    var BackgroundBarWid : color_block = color_block{}
    var ProgressBarWid : color_block = color_block{}
    var ProgressBarStackBox : stack_box = stack_box{Orientation := orientation.Horizontal}
    var ProgressBarScalar : color_block = color_block{DefaultColor := White, DefaultOpacity := 0.0}

    var ProgressText : text_block = text_block{DefaultJustification := text_justification.Center}
    var TipTextWid : text_block = text_block{DefaultJustification := text_justification.Center}
    var MainBarText : text_block = text_block{DefaultJustification := text_justification.Center}

    #Settings
    TT_CM_Device_BarSettings<localizes>:message = "The settings for the progress bar"
    @editable BarSettings : ProgressBarSetting = ProgressBarSetting{}

    TT_CM_Device_TextSettings<localizes>:message = "The settings for the text that will be displayed on the progress bar"
    @editable TextSettings : ComputerTextSetting = ComputerTextSetting{}

    TT_CM_Device_Upgrades<localizes>:message = "An array of upgrades for the progress bar"
    @editable Upgrades : []Upgrade = array{}

    TT_CM_Device_BaseSpeed<localizes>:message = "The base speed for the progress bar"
    @editable BaseSpeed : float = 0.0

    #Other Stuff
    CancelEvent : event() = event(){}
    var CompleteEvent : event() = event(){}
    var BarSpeed : float = 0.0
    var XValue : float = 0.0
    var DotIDX : int = 0
    
    #Initializes all bars, text and UI
    Initialize() : void=
        #Text Stuff
        ProgressText.SetTextColor(TextSettings.ProgressTextColors.TextColor)
        ProgressText.SetShadowColor(TextSettings.ProgressTextColors.TextShadowColor)
        ProgressText.SetShadowOffset(option{TextSettings.ProgressTextColors.TextShadowOffset})
        TipTextWid.SetTextColor(TextSettings.TipTextColors.TextColor)
        TipTextWid.SetShadowColor(TextSettings.TipTextColors.TextShadowColor)
        TipTextWid.SetShadowOffset(option{TextSettings.TipTextColors.TextShadowOffset})
        MainBarText.SetTextColor(TextSettings.MainTextColors.TextColor)
        MainBarText.SetShadowColor(TextSettings.MainTextColors.TextShadowColor)
        MainBarText.SetShadowOffset(option{TextSettings.MainTextColors.TextShadowOffset})
        MainBarText.SetShadowOpacity(1.0)
        TipTextWid.SetShadowOpacity(1.0)
        ProgressText.SetShadowOpacity(1.0)
        MainBarText.SetText(MasterS2M(TextSettings.MainText))
        TipTextWid.SetText(MasterS2M(TextSettings.TipText))

        MainBarText.SetVisibility(widget_visibility.Hidden)
        TipTextWid.SetVisibility(widget_visibility.Hidden)
        ProgressText.SetVisibility(widget_visibility.Hidden)

        #Bar and Main UI
        set XValue = 0.0
        set DotIDX = 0
        BackgroundBarWid.SetColor(BarSettings.BackgroundBarColor)
        ProgressBarWid.SetColor(BarSettings.ProgressBarColor)
        ProgressBarScalar.SetDesiredSize(vector2{X:=BarSettings.BarPosition.Right, Y:= BarSettings.BarPosition.Bottom})
        set BarCanvas = CreateUI()

        
    #Sets up a canvas for each bar
    CreateUI() : canvas=
        NewCanvas := canvas:
            Slots := array:
                TextSettings.TipTextPosition.MakeCanvasSlot(TipTextWid, option{CanvasPosition{MaybeZOrder := option{2}}})
                TextSettings.MainTextPosition.MakeCanvasSlot(MainBarText, option{CanvasPosition{MaybeZOrder := option{2}}})
                TextSettings.ProgressTextPosition.MakeCanvasSlot(ProgressText, option{CanvasPosition{MaybeZOrder := option{2}}})

                BarSettings.BarPosition.MakeCanvasSlot(BackgroundBarWid, option{CanvasPosition{MaybeZOrder := option{0}}})

                BarSettings.BarPosition.MakeCanvasSlot(ProgressBarStackBox, option{CanvasPosition{MaybeZOrder := option{1}}})

        ProgressBarStackBox.AddWidget(stack_box_slot:
            Widget := ProgressBarWid
            HorizontalAlignment := horizontal_alignment.Fill
            VerticalAlignment := vertical_alignment.Fill
            Distribution := option{1.0}
        )

        ProgressBarStackBox.AddWidget(stack_box_slot:
            Widget := ProgressBarScalar
            HorizontalAlignment := horizontal_alignment.Fill
            VerticalAlignment := vertical_alignment.Fill
        )

        return NewCanvas

    #Makes the bar start moving and also controls loading "." animation
    Start(Agent:agent)<suspends> : void=
        #Set up variables used and shows text for bar
        MainBarText.SetVisibility(widget_visibility.Visible)
        TipTextWid.SetVisibility(widget_visibility.Visible)
        ProgressText.SetVisibility(widget_visibility.Visible)
        ProgressBarStackBox.SetVisibility(widget_visibility.Visible)
        var MainString : string = TextSettings.MainText
        sync:
            #Controls loading . animation
            race:
                block:
                    CancelEvent.Await()
                    ProgressBarStackBox.SetVisibility(widget_visibility.Hidden)
                    BarCanvas.RemoveWidget(ProgressBarStackBox)
                    BarCanvas.RemoveWidget(MainBarText)
                    
                    
                block:
                    CompleteEvent.Await()
                    if(TextSettings.CompletedMainTextSettings.CompletedType = completetexttype.Hide):
                        MainBarText.SetVisibility(widget_visibility.Hidden)

                    else if(TextSettings.CompletedMainTextSettings.CompletedType = completetexttype.ChangeToCompletedText):
                        MainBarText.SetText(MasterS2M(TextSettings.CompletedMainTextSettings.CompletedText))
                        MainBarText.SetTextColor(TextSettings.CompletedMainTextSettings.CompletedTextColor.TextColor)
                        MainBarText.SetShadowColor(TextSettings.CompletedMainTextSettings.CompletedTextColor.TextShadowColor)
                        MainBarText.SetShadowOffset(option{TextSettings.CompletedMainTextSettings.CompletedTextColor.TextShadowOffset})
                loop:
                    Sleep(TextSettings.MainTextDotAnimationSpeed)
                    if(DotIDX = 3):
                        set MainString = TextSettings.MainText
                        set DotIDX = -1
                    else:
                        set MainString += "."
                    MainBarText.SetText(MasterS2M(MainString))
                    set DotIDX += 1
                    
            #Controls bar animation
            race:
                block:
                    CancelEvent.Await()
                    ProgressBarStackBox.SetVisibility(widget_visibility.Hidden)
                    BarCanvas.RemoveWidget(ProgressBarStackBox)

                block:
                    CompleteEvent.Await()
                    if(not BarSettings.AppearAfterCompleted?):
                        ProgressBarStackBox.SetVisibility(widget_visibility.Hidden)
                        BarCanvas.RemoveWidget(ProgressBarStackBox)
                loop:
                    Sleep(0.0)
                    set XValue += BarSpeed
                    ProgressBarScalar.SetVisibility(widget_visibility.Hidden)
                    
                    ProgressBarScalar.SetVisibility(widget_visibility.Visible)
                    ProgressBarScalar.SetDesiredSize(vector2{X:=BarSettings.BarPosition.Right - XValue, Y:= BarSettings.BarPosition.Bottom})

                    if(Percentage := Int[(XValue / BarSettings.BarPosition.Right) * 100.0]):
                        ProgressText.SetText(MasterS2M("{Percentage}%"))

                    if(XValue >= BarSettings.BarPosition.Right):
                        CompleteEvent.Signal()

    #Resets the Bar
    Reset(Agent:agent): void=
        set XValue = 0.0
        set DotIDX = 0

        ProgressText.SetTextColor(TextSettings.ProgressTextColors.TextColor)
        ProgressText.SetShadowColor(TextSettings.ProgressTextColors.TextShadowColor)
        ProgressText.SetShadowOffset(option{TextSettings.ProgressTextColors.TextShadowOffset})
        TipTextWid.SetTextColor(TextSettings.TipTextColors.TextColor)
        TipTextWid.SetShadowColor(TextSettings.TipTextColors.TextShadowColor)
        TipTextWid.SetShadowOffset(option{TextSettings.TipTextColors.TextShadowOffset})
        MainBarText.SetTextColor(TextSettings.MainTextColors.TextColor)
        MainBarText.SetShadowColor(TextSettings.MainTextColors.TextShadowColor)
        MainBarText.SetShadowOffset(option{TextSettings.MainTextColors.TextShadowOffset})

        MainBarText.SetText(MasterS2M(TextSettings.MainText))
        TipTextWid.SetText(MasterS2M(TextSettings.TipText))

        MainBarText.SetVisibility(widget_visibility.Hidden)
        TipTextWid.SetVisibility(widget_visibility.Hidden)
        ProgressText.SetVisibility(widget_visibility.Hidden)


        ProgressBarScalar.SetVisibility(widget_visibility.Hidden)
        ProgressBarScalar.SetVisibility(widget_visibility.Visible)
        ProgressBarScalar.SetDesiredSize(vector2{X:=BarSettings.BarPosition.Right - XValue, Y:= BarSettings.BarPosition.Bottom})

#Class to hold and control the UI that gets shown to the player
ComputerUI := class():
    #Devices
    var GameManager : Game_Manager = Game_Manager{}
    var ResourceManager : Resource_Manager = Resource_Manager{}
    var ComputerManager : Computer_Manager = Computer_Manager{}
    var OpenComputerCinematic : cinematic_sequence_device = cinematic_sequence_device{}
    var HUDController : hud_controller_device = hud_controller_device{}
   
    #Settings
    var CancelSettings : CancelSetting = CancelSetting{}
    var CompletionSettings : CompletionSetting = CompletionSetting{}
    var OpenSettings : OpenSetting = OpenSetting{}

    #UI Stuff
    var CancelButton : button_loud = button_loud{}
    var MainUI : canvas = canvas{}
    var ExitButton : button_loud = button_loud{}
    var StartButton : button_loud = button_loud{}

    ComputerCloseEvent : event() = event(){}
    
    

    #Adds the UI to the player and Initializes Bars
    AddUI(Agent:agent) : void=
        CancelButton.SetText(MasterS2M("Cancel"))
        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player] , PC := ComputerManager.PlayersComputerMap[Agent],CP := Custom_Player[GameManager.PlayersMap[Agent]]):
            for(B : PC.ProgressBars){B.Initialize()}
            if(OpenSettings.OpenType = opentype.AutoStart):
                if(CancelSettings.CancelType = canceltype.UI):
                    PlayerUI.AddWidget(MainUI , player_ui_slot{InputMode := ui_input_mode.All})
                else:
                    PlayerUI.AddWidget(MainUI)
                CP.MyUI.SetVisibility(widget_visibility.Hidden)
                spawn{PlayBars(Agent)}
                spawn{HandleCancel(Agent)}

            else if(OpenSettings.OpenType = opentype.Optional):
                StartButton.SetText(MasterS2M(OpenSettings.OptionalOpenStartButtonText))
                ExitButton.SetText(MasterS2M(OpenSettings.OptionalOpenExitButtonText))
                MainUI.AddWidget(OpenSettings.OptionalOpenStartButtonPosition.MakeCanvasSlot(StartButton,false))
                MainUI.AddWidget(OpenSettings.OptionalOpenExitButtonPosition.MakeCanvasSlot(ExitButton,false))
                StartButton.OnClick().Subscribe(HandleStart)
                ExitButton.OnClick().Subscribe(HandleExit)
                PlayerUI.AddWidget(MainUI , player_ui_slot{InputMode := ui_input_mode.All})
                CP.MyUI.SetVisibility(widget_visibility.Hidden)

            spawn{ComputerElimTrack(Agent)}

    ComputerElimTrack(Agent:agent)<suspends> : void=
        if (Player := player[Agent],PlayerUI := GetPlayerUI[Player],FC:=Agent.GetFortCharacter[],CP := Custom_Player[GameManager.PlayersMap[Agent]]):
            race:
                FC.EliminatedEvent().Await()
                ComputerCloseEvent.Await()
            
            PlayerUI.RemoveWidget(MainUI)
            OpenComputerCinematic.Stop(Player)
            FC.ReleaseFromStasis()
            CancelSettings.CustomInputTrigger.Unregister(Player)
            HUDController.Disable()
            CP.MyUI.SetVisibility(widget_visibility.Visible)



    #Controls what happens if UI is set to optional and the Start button is selected
    HandleStart(Message : widget_message) : void=
        Player := Message.Player
        if(PlayerUI := GetPlayerUI[Player]):
            StartButton.SetVisibility(widget_visibility.Hidden)
            ExitButton.SetVisibility(widget_visibility.Hidden)
            MainUI.RemoveWidget(StartButton)
            MainUI.RemoveWidget(ExitButton)

            MainUI.SetVisibility(widget_visibility.Hidden)
            PlayerUI.RemoveWidget(MainUI)

            if(CancelSettings.CancelType = canceltype.UI):
                PlayerUI.AddWidget(MainUI , player_ui_slot{InputMode := ui_input_mode.All})
            else:
                PlayerUI.AddWidget(MainUI)
            spawn{PlayBars(Player)}
            spawn{HandleCancel(Player)}

    #Controls what happens if UI is set to optional and the Exit button is selected
    HandleExit(Message : widget_message) : void=
        Player := Message.Player
        if(PlayerUI := GetPlayerUI[Player], FC:= Player.GetFortCharacter[]):
            StartButton.SetVisibility(widget_visibility.Hidden)
            ExitButton.SetVisibility(widget_visibility.Hidden)
            MainUI.RemoveWidget(StartButton)
            MainUI.RemoveWidget(ExitButton)
            ComputerCloseEvent.Signal()
    
    #Tracks for when a player cancels based on the cancel setting
    HandleCancel(Agent:agent)<suspends> : void=
        if(CancelSettings.CancelType = canceltype.UI):
            MainUI.AddWidget(CancelSettings.UIExitPosition.MakeCanvasSlot(CancelButton, false))
            CancelButton.OnClick().Subscribe(CancelUI)

        else if(CancelSettings.CancelType = canceltype.CustomInput):
            CancelSettings.CustomInputTrigger.Register(Agent)
            HUDController.UpdateAffectedTeam(Agent)
            HUDController.Enable()

            CancelSettings.CustomInputTrigger.PressedEvent.Subscribe(Cancel)

    #Starts playing all bars in succession
    PlayBars(Agent:agent)<suspends> : void=
        var BarIDX : int = 0
        if(PC := ComputerManager.PlayersComputerMap[Agent]):
            for(B : PC.ProgressBars):
                if(B.BarSettings.AppearBeforeStarted?):
                    MainUI.AddWidget(B.BarSettings.BarPosition.MakeCanvasSlot(B.BarCanvas, option{CanvasPosition{
                        MaybeZOrder := option{1}
                        MaybeLeft := option{0.0}
                        MaybeRight := option{0.0}
                        MaybeBottom := option{0.0}
                        MaybeTop := option{0.0}
                        MaybeAllignment := option{vector2{X:= 0.5,Y:= 0.5}}
                        }}))
                else:
                    B.BarCanvas.SetVisibility(widget_visibility.Hidden)
            race:
                block:
                    for(B : PC.ProgressBars):
                        B.CancelEvent.Await()

                loop:
                    if(CurrentBar := PC.ProgressBars[BarIDX]):
                        CurrentBar.BarCanvas.SetVisibility(widget_visibility.Hidden)
                        MainUI.RemoveWidget(CurrentBar.BarCanvas)
                        CurrentBar.BarCanvas.SetVisibility(widget_visibility.Visible)

                        MainUI.AddWidget(CurrentBar.BarSettings.BarPosition.MakeCanvasSlot(CurrentBar.BarCanvas, option{CanvasPosition{
                            MaybeZOrder := option{1}
                            MaybeLeft := option{0.0}
                            MaybeRight := option{0.0}
                            MaybeBottom := option{0.0}
                            MaybeTop := option{0.0}
                            MaybeAllignment := option{vector2{X:= 0.5,Y:= 0.5}}
                            }}))

                        spawn{CurrentBar.Start(Agent)}
                        CurrentBar.CompleteEvent.Await()
                        set BarIDX += 1
                        if(not CurrentBar.BarSettings.AppearAfterCompleted?):
                            CurrentBar.BarCanvas.SetVisibility(widget_visibility.Hidden)
                            MainUI.RemoveWidget(CurrentBar.BarCanvas)

                        if(not CurrentBar.TextSettings.ShouldProgressTextAppearAfterComplete?):
                            CurrentBar.ProgressText.SetVisibility(widget_visibility.Hidden)
                    else:
                        Complete(Agent)
                        break

    #Used as a precurser to cancel for ui button
    CancelUI(Message : widget_message) : void=
        Player := Message.Player
        Cancel(Player)

    #Cancels the mechanic
    Cancel(Agent:agent) : void=
        if(FC := Agent.GetFortCharacter[], Player := player[Agent],PlayerUI := GetPlayerUI[Player],PC := ComputerManager.PlayersComputerMap[Agent], CP := GameManager.PlayersMap[Agent] ):
            ComputerCloseEvent.Signal()
            for(B : PC.ProgressBars):
                B.CancelEvent.Signal()

    #Completes the mechanic and awards player
    Complete(Agent:agent) : void=
        if(FC := Agent.GetFortCharacter[], Player := player[Agent],PlayerUI := GetPlayerUI[Player], RP := ResourceManager.PlayersMap[Agent],PC := ComputerManager.PlayersComputerMap[Agent]):
            RP.Collect(CompletionSettings.CompleteResources)
            CompletionSettings.CompleteTrigger.Trigger(Agent)


            if(CompletionSettings.CompletionType = completiontype.Close):
                ComputerCloseEvent.Signal()

            else if(CompletionSettings.CompletionType = completiontype.Loop):
                for(B : PC.ProgressBars){B.Reset(Agent)}
                spawn{PlayBars(Agent)}


#Class to hold players individual bars and track upgrades
PlayerComputers := class():
    Player : player
    PersistanceManager : Tycoon_Persistence_Manager = Tycoon_Persistence_Manager{}
    var GameManager : Game_Manager = Game_Manager{}
    var ResourceManager : Resource_Manager = Resource_Manager{}
    var PlotManager : Plot_Manager = Plot_Manager{}
    var ProgressBars : []ProgressBar = array{}
    ResetEvent : event() = event(){}

    LoadTriggerEvent : event() = event(){}
    
    #Sets up all bars upgrades
    SetUpUpgrades() : void=
        for(ProgressIDX -> P : ProgressBars):
            set P.BarSpeed = P.BaseSpeed
            for(idx -> U : P.Upgrades):
                set U.IDX = idx + 1
                spawn{UpgradeWait(P, U, ProgressIDX)}
        spawn{LoadSavedData()}

    #Loads the saved data for a player when they load a plot
    LoadSavedData()<suspends> : void=
        Agent:=PlotManager.PlotLoadEvent.Await()
        if(Player = Agent):
            if(CP := GameManager.PlayersMap[Player] , PlayerStats := PersistanceManager.GetPlayerStats[Player]):
                for(idx -> P : ProgressBars):
                    if(idx = 0):
                        for(BoughtUp : PlayerStats.Bar1Upgrades):
                            for(Up : P.Upgrades):
                                if(Up.IDX = BoughtUp):
                                    LoadTriggerEvent.Signal()
                                 
                    else if(idx = 1):
                        for(BoughtUp : PlayerStats.Bar2Upgrades):
                            for(Up : P.Upgrades):
                                if(Up.IDX = BoughtUp):
                                    LoadTriggerEvent.Signal()
                    
                    
                    else if(idx = 2):
                        for(BoughtUp : PlayerStats.Bar3Upgrades):
                            for(Up : P.Upgrades):
                                if(Up.IDX = BoughtUp):
                                    LoadTriggerEvent.Signal()




    #Adds persistence to different resources
    AddToPersistence(idx : int,Amount : int) : void=
        if(CP := GameManager.PlayersMap[Player] , PlayerStats := PersistanceManager.GetPlayerStats[Player]):
            if(idx = 0 , not PlayerStats.Bar1Upgrades.Find[Amount]){PersistanceManager.RecordPlayerArrStat(Player, StatType.Bar1Upgrades, ?Score := Amount)}
            else if(idx = 1 , not PlayerStats.Bar2Upgrades.Find[Amount]){PersistanceManager.RecordPlayerArrStat(Player, StatType.Bar2Upgrades, ?Score := Amount)}
            else if(idx = 2 , not PlayerStats.Bar3Upgrades.Find[Amount]){PersistanceManager.RecordPlayerArrStat(Player, StatType.Bar3Upgrades, ?Score := Amount)}
      



    #Waits for upgrades to be activated and upgrades the bar when they are
    UpgradeWait(PB : ProgressBar , Up : Upgrade, ProgressIDX : int)<suspends> : void=
        if(RP := ResourceManager.PlayersMap[Player] , PlayerStats := PersistanceManager.GetPlayerStats[Player]):
            race:
                block:
                    loop:
                        LeavingPlayer := GameManager.GetPlayspace().PlayerRemovedEvent().Await()
                        if(LeavingPlayer = Player):
                            break
                block:
                    ResetEvent.Await()

                block:
                    loop:
                        LoadTriggerEvent.Await()
                        if(Up.IncreaseType = increasetype.Add):
                            set PB.BarSpeed += Up.UpgradeAmount
                        else if(Up.IncreaseType = increasetype.Set):
                            set PB.BarSpeed = Up.UpgradeAmount

                        if(not Up.Reusable?):
                            break
                
                loop:
                    Up.Trigger.TriggeredEvent.Await()
                    HasEnough := RP.Check(Up.CostResources)
                    if(HasEnough?):
                        AddToPersistence(ProgressIDX, Up.IDX)

                        RP.Spend(Up.CostResources)
                        if(Up.IncreaseType = increasetype.Add):
                            set PB.BarSpeed += Up.UpgradeAmount
                        else if(Up.IncreaseType = increasetype.Set):
                            set PB.BarSpeed = Up.UpgradeAmount

                        if(Up.ChangePropSettings.Enabled?):
                            Up.ChangePropSettings.Cinematic.Play(Player)
                            Sleep(Up.ChangePropSettings.HideShowDelay)
                            Up.ChangePropSettings.Trigger.Enable()
                            Up.ChangePropSettings.Trigger.Trigger(Player)

                        if(not Up.Reusable?):
                            break


#Creative Device class
Computer_Manager := class(creative_device):
    #Devices
    TT_CM_Device_GameManager<localizes>:message = "Your Game Manager Device"
    @editable GameManager : Game_Manager = Game_Manager{}

    TT_CM_Device_ResourceManager<localizes>:message = "Your Resource Manager Device"
    @editable ResourceManager : Resource_Manager = Resource_Manager{}

    TT_CM_Device_PlotManager<localizes>:message = "Your Plot Manager Device"
    @editable PlotManager : Plot_Manager = Plot_Manager{}

    TT_CM_Device_OpenComputerTrigger<localizes>:message = "A trigger device that will open the computer UI"
    @editable OpenComputerTrigger : trigger_device = trigger_device{}

    TT_CM_Device_OpenComputerCinematic<localizes>:message = "A cinematic sequence device that will play when the open computer button is pressed\n*Required Settings*\nVisibility : Instigator Only"
    @editable OpenComputerCinematic : cinematic_sequence_device = cinematic_sequence_device{}

    TT_CM_Device_HUDController<localizes>:message = "A hud controller device that will be used to hide the player\'s crosshair when they are interacting with the computer\n*Required Settings*\nDisplay Reticle: Never Show Reticle\nEnabled During Phase : None"
    @editable HUDController : hud_controller_device = hud_controller_device{}
    
    
    TT_CM_Device_Teleporter<localizes>:message = "A teleporter device that will be used to teleport the player when the computer UI is opened\n*Required Settings*\nTeleporter Group : None\nTeleporter Target Group : None\nVisibility : False\nFace Player In Teleporter Direction : Yes"
    @editable Teleporter : teleporter_device = teleporter_device{}

    #Settings
    TT_CM_Device_ProgressBars<localizes>:message = "The settings for progress bars that will be used for the computer"
    @editable ProgressBars : []ProgressBar = array{}

    TT_CM_Device_CancelSettings<localizes>:message = "The settings for how a player can close the computer UI"
    @editable CancelSettings : CancelSetting = CancelSetting{}
    
    TT_CM_Device_OpenSettings<localizes>:message = "The settings for how the computer UI will open"
    @editable OpenSettings : OpenSetting = OpenSetting{}
    
    TT_CM_Device_CompletionSettings<localizes>:message = "The settings for what happens when the progress bars are completed"
    @editable CompletionSettings : CompletionSetting = CompletionSetting{}



    #Map of all players info
    var PlayersComputerMap : [player]PlayerComputers = map{}      

    OnBegin<override>()<suspends>:void=
        #Opens pc when button is interacted with
        OpenComputerTrigger.TriggeredEvent.Subscribe(OpenPC)
        GetPlayspace().PlayerRemovedEvent().Subscribe(RemoveFromPCMap)

        #Initializes players when they join
        Sleep(0.1)
        spawn{InitiatePlayer()}
        spawn{Reset()}

    #Removes the player from the map whenever they leave the session
    RemoveFromPCMap(Agent:agent) : void=
        if(Player := player[Agent],Exists := PlayersComputerMap[Player]):
            if(NewMap := PlayersComputerMap.WithRemovedKey(Player)?):
                set PlayersComputerMap = NewMap


    #Used to reset computers for each player
    Reset()<suspends> : void=
        loop:
            Agent := PlotManager.ResetPlotEvent.Await()
            if(CustomPlayer := PlayersComputerMap[Agent]):
                CustomPlayer.ResetEvent.Signal()
                CustomPlayer.SetUpUpgrades()

    #Opens the Computer UI and activate other devices
    OpenPC(MAgent:?agent) : void=
        if(Agent := MAgent? , FC := Agent.GetFortCharacter[]):
            NewPC := ComputerUI{
                GameManager := GameManager
                ResourceManager := ResourceManager
                OpenComputerCinematic := OpenComputerCinematic
                ComputerManager := Self
                CancelSettings := CancelSettings
                HUDController:= HUDController
                OpenSettings := OpenSettings
                CompletionSettings := CompletionSettings
            }
            NewPC.AddUI(Agent)
        
            spawn{TeleportStasis(Agent)}

    #Opens cinematic for player, teleports player into pc location, and freezes player
    TeleportStasis(Agent:agent)<suspends> : void=
        if(FC := Agent.GetFortCharacter[]):
            OpenComputerCinematic.Play(Agent)
            Teleporter.Teleport(Agent)
            Sleep(0.1)
            FC.PutInStasis(stasis_args{})
            
    #Initiates the players bar info
    InitiatePlayer()<suspends>: void=
        loop:
            Agent:=PlotManager.PlotClaimEvent.Await()
            if(Player := player[Agent]):    
                if(PlayerExists := PlayersComputerMap[Player]):      
                else:
                    if(set PlayersComputerMap[Player] = PlayerComputers{        
                        Player := Player
                        ProgressBars := ProgressBars
                        GameManager := GameManager
                        ResourceManager := ResourceManager
                        PlotManager := PlotManager
                        }){}
                        if(CustomPlayer := PlayersComputerMap[Player]){CustomPlayer.SetUpUpgrades()}
         

#Enums for different settings
increasetype := enum:
    Add
    Set

canceltype := enum:
    UI
    CustomInput

completetexttype := enum:
    ChangeToCompletedText
    Hide

opentype := enum:
    AutoStart
    Optional

completiontype := enum:
    Close
    Loop




#Setting for what happens upon completing when the bars fill
CompletionSetting := class<concrete>():
    TT_CM_Device_CompletionType<localizes>:message = "Determines what happens when the progress bars are completed\nClose : The computer will close after completion\nLoop : The progress bars will reset and continue"
    @editable CompletionType : completiontype = completiontype.Close

    TT_CM_Device_CompleteResources<localizes>:message = "The resources that will be awarded to the player when the progress bars are completed"
    @editable CompleteResources : []GainableResource = array{}

    TT_CM_Device_CompleteTrigger<localizes>:message = "A trigger device that will be triggered when the progress bars are completed"
    @editable CompleteTrigger : trigger_device = trigger_device{}


#Settings for changing props upon upgrade
ChangePropSetting := class<concrete>():
    TT_CM_Device_Enabled<localizes>:message = "Enable or disable the following prop change settings"
    @editable Enabled : logic = false

    TT_CM_Device_Cinematic<localizes>:message = "A cinematic sequence device that will play when the an upgrade is purchased\n*Required Settings*\nVisibility : Instigator Only"
    @editable Cinematic : cinematic_sequence_device = cinematic_sequence_device{}

    TT_CM_Device_Trigger<localizes>:message = "A trigger device that will be used to change the prop when the upgrade is purchased"
    @editable Trigger : trigger_device = trigger_device{}
    
    TT_CM_Device_HideShowDelay<localizes>:message = "How long after purchasing the upgrade, the trigger above will be triggered"
    @editable HideShowDelay : float = 0.0

#Settings for when the Computer is opened
OpenSetting := class<concrete>():
    TT_CM_Device_OpenType<localizes>:message = "Determines how the progress bar is started\nAuto Start : The progress bar starts when the computer is shown\nOptional : A button must be pressed to start the progress bar"
    @editable OpenType : opentype = opentype.AutoStart

    TT_CM_Device_OptionalOpenStartButtonPosition<localizes>:message = "The position of the button on the UI that will start the progress bar when pressed *Only works if OpenType is Optional*"
    @editable OptionalOpenStartButtonPosition : CanvasPosition = CanvasPosition{}

    TT_CM_Device_OptionalOpenStartButtonText<localizes>:message = "The text of the button on the start button *Only works if OpenType is Optional*"
    @editable OptionalOpenStartButtonText : string = ""

    TT_CM_Device_OptionalOpenExitButtonPosition<localizes>:message = "The position of the button on the UI that will stop the progress bar when pressed*"
    @editable OptionalOpenExitButtonPosition : CanvasPosition = CanvasPosition{}

    TT_CM_Device_OptionalOpenExitButtonText<localizes>:message = "The text of the button on the exit button *Only works if OpenType is Optional*"
    @editable OptionalOpenExitButtonText : string = ""

#Settings for how a player cancels
CancelSetting := class<concrete>():
    TT_CM_Device_CancelType<localizes>:message = "Determines how a player can cancel the computer\nUI : A button will be added to the UI that can be pressed to cancel\nCustom Input : Player can press a specific input (like pressing jump) to exit"
    @editable CancelType : canceltype = canceltype.UI

    TT_CM_Device_UIExitPosition<localizes>:message = "The position of the exit button on the UI *Only works if CancelType is UI*"
    @editable UIExitPosition : CanvasPosition = CanvasPosition{}

    TT_CM_Device_CustomInputTrigger<localizes>:message = "A custom input trigger device that will be used to cancel the computer *Only works if CancelType is Custom Input*\n*Required Settings*\nRegistered Player Behavior : Require Registered"
    @editable CustomInputTrigger : input_trigger_device = input_trigger_device{}

#Settings for the texts for each bar
ComputerTextSetting := class<concrete>():

    @editable MainText : string = ""

    @editable MainTextDotAnimationSpeed : float = 0.0

    @editable TipText : string = ""

    @editable TipTextPosition : CanvasPosition = CanvasPosition{}
    @editable TipTextColors : TextSetting = TextSetting{}
    

    @editable MainTextPosition : CanvasPosition = CanvasPosition{}
    @editable MainTextColors : TextSetting = TextSetting{}

    @editable ProgressTextColors : TextSetting = TextSetting{}
    @editable ProgressTextPosition : CanvasPosition = CanvasPosition{}
    @editable ShouldProgressTextAppearAfterComplete : logic = false

    @editable CompletedMainTextSettings : CompletedTextSetting = CompletedTextSetting{}

#Settings for what happens to the text upon completion
CompletedTextSetting := class<concrete>():
    @editable CompletedType : completetexttype = completetexttype.ChangeToCompletedText
    @editable CompletedText : string = ""
    @editable CompletedTextColor : TextSetting = TextSetting{}

#Settings for the bar
ProgressBarSetting := class<concrete>():
    @editable AppearBeforeStarted : logic = false
    @editable AppearAfterCompleted : logic = false


    @editable BackgroundBarColor : color = color{}
    @editable ProgressBarColor : color = color{}

    @editable BarPosition : CanvasPosition = CanvasPosition{}