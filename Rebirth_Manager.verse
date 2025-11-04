using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Fortnite.com/Characters }

#THIS DEVICE ALLOWS THE PLAYER TO REBIRTH, RESETTING THEM BUT GAINING AN INFINITE MONEY BOOST

#Class for rebirth UI
RebirthUI := class():
    #Base Stuff
    var GameManager : Game_Manager = Game_Manager{}
    var ResourceManager : Resource_Manager = Resource_Manager{}
    PersistanceManager : Tycoon_Persistence_Manager = Tycoon_Persistence_Manager{}
    var ButtonManager : Button_Manager = Button_Manager{} 
    var PlotManager : Plot_Manager = Plot_Manager{}       

    #UI Stuff
    var MainUI : canvas = canvas{}
    var CancelButtons : UIAllButtons = UIAllButtons{}
    var RebirthButtons : UIAllButtons = UIAllButtons{}
    var DisplayText : text_block = text_block{}

    #Rebirth Background Image
    #===================================================================================================================================
    var Background : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}
    #===================================================================================================================================

    #Devices
    var BaseClassSelector : class_and_team_selector_device = class_and_team_selector_device{}
    var RebirthedTrigger : trigger_device = trigger_device{}

    #Extra Settings
    var RebirthSettings : RebirthSetting = RebirthSetting{}
    RebirthCloseEvent : event() = event(){}
    

    #Initializes the UI widgets
    Initialize(Agent:agent) : void=
        CancelButton := CancelButtons.GetButton(RebirthSettings.RebirthChoiceUISettings.ButtonType)
        RebirthButton := RebirthButtons.GetButton(RebirthSettings.RebirthChoiceUISettings.ButtonType)

        CancelButton.SetText(MasterS2M("Cancel"))
        RebirthButton.SetText(MasterS2M("Accept"))
        set MainUI = CreateUI(Agent)

        spawn{RebirthElimTrack(Agent)}

    RebirthElimTrack(Agent:agent)<suspends> : void=
        if (Player := player[Agent],PlayerUI := GetPlayerUI[Player],FC:=Agent.GetFortCharacter[],CP := Custom_Player[GameManager.PlayersMap[Agent]]):
            race:
                FC.EliminatedEvent().Await()
                RebirthCloseEvent.Await()

            MainUI.SetVisibility(widget_visibility.Hidden)
            CP.MyUI.SetVisibility(widget_visibility.Visible)
            PlayerUI.RemoveWidget(MainUI)

    #Creates the UI
    CreateUI(Agent:agent) : canvas= 
        CancelButton := CancelButtons.GetButton(RebirthSettings.RebirthChoiceUISettings.ButtonType)
        RebirthButton := RebirthButtons.GetButton(RebirthSettings.RebirthChoiceUISettings.ButtonType)
        if(CP := Custom_Player[GameManager.PlayersMap[Agent]],RP := ResourceManager.PlayersMap[Agent]):
            if(RebirthSettings.RebirthCollectionSettings.CollectionType = collectiontype.BasedAmount):
                for(Re : RP.Resources):
                    if(Re.ResourceName = RebirthSettings.RebirthCollectionSettings.BasedResource.ResourceName):
                        if(NewAmount := Int[(Re.ResourceAmount / RebirthSettings.RebirthCollectionSettings.BasedAmountPerRebirth)] * 1.0):
                            DisplayText.SetText(RoundedAmount("",NewAmount,0,""))

        DisplayText.SetShadowOffset(option{RebirthSettings.RebirthChoiceUISettings.GainTextSettings.TextShadowOffset})
        DisplayText.SetShadowColor(RebirthSettings.RebirthChoiceUISettings.GainTextSettings.TextShadowColor)
        DisplayText.SetTextColor(RebirthSettings.RebirthChoiceUISettings.GainTextSettings.TextColor)
        DisplayText.SetShadowOpacity(1.0)

        CancelButton.OnClick().Subscribe(Cancel)
        RebirthButton.OnClick().Subscribe(RebirthPlayer)
        NewUnlockUI : canvas = canvas:
            Slots := array:
                RebirthSettings.RebirthChoiceUISettings.CancelButtonPosition.MakeCanvasSlot(CancelButton , false)
                RebirthSettings.RebirthChoiceUISettings.AcceptButtonPosition.MakeCanvasSlot(RebirthButton , false)
                RebirthSettings.RebirthChoiceUISettings.BackgroundPosition.MakeCanvasSlot(Background , false)
                RebirthSettings.RebirthChoiceUISettings.GainTextPosition.MakeCanvasSlot(DisplayText , false)


    #Loads the saved progress for the player
    Cancel(Message : widget_message) : void=
        Player := Message.Player
        if (PlayerUI := GetPlayerUI[Message.Player],CP := GameManager.PlayersMap[Player]):
            RebirthCloseEvent.Signal()




    #Resets the saved progress for the player
    RebirthPlayer(Message : widget_message) : void=
        Player := Message.Player
        if (PlayerUI := GetPlayerUI[Message.Player], RP := ResourceManager.PlayersMap[Player]):
            #Closes UI
            RebirthCloseEvent.Signal()
            

            #Collects differet amounts of rebirths depending on setting
            if(RebirthSettings.RebirthCollectionSettings.CollectionType = collectiontype.SetAmount):
                set RebirthSettings.ResourceSettings.Amount = RebirthSettings.RebirthCollectionSettings.SetAmount
                RP.CollectRebirth(array{RebirthSettings.ResourceSettings}) 

            else if(RebirthSettings.RebirthCollectionSettings.CollectionType = collectiontype.BasedAmount):
                for(Re : RP.Resources):
                    if(Re.ResourceName = RebirthSettings.RebirthCollectionSettings.BasedResource.ResourceName):
                        if(NewAmount := Int[(Re.ResourceAmount / RebirthSettings.RebirthCollectionSettings.BasedAmountPerRebirth)]):
                            set RebirthSettings.ResourceSettings.Amount = NewAmount * 1.0
                            RP.CollectRebirth(array{RebirthSettings.ResourceSettings})

            #Activates devices
            RebirthedTrigger.Trigger(Player)
            PlotManager.ClaimPlotPlayerRef.Clear()
            for (PlotPlayer : PlotManager.PlotsPlayer):
                BaseClassSelector.ChangeTeam(PlotPlayer)

            #Resets plot
            for(B : ButtonManager.ButtonsArray){spawn{B.ResetButton(Player)}}    
            PlotManager.ResetPlotEvent.Signal(Player)
            ButtonManager.ResetEvent.Signal(Player)
                
            #Resets Plot Manager ATMs
            for(A : PlotManager.ATMs):
                A.ResetEvent.Signal()
                for(ATMRes : A.ATMResources):
                    set ATMRes.TempAmount = 0.0
                    for(B : ATMRes.Billboard):
                        B.SetText(MasterS2M(""))     

            #Shows the first button again
            if(FirstButton := ButtonManager.ButtonsArray[0]):
                spawn{FirstButton.ActivateDevices.EnableAll()}
                for(idx -> Item: FirstButton.ItemsToHide , CustomProp := FirstButton.ItemsToHideMap[idx]):
                    IsShown := CustomProp.CheckLocation()
                    if(not IsShown?):
                        CustomProp.ShowProp(FirstButton.RiseAnimation , true)
            
           
            #Resets Player Stats
            for (PlotPlayer : PlotManager.PlotsPlayer):
                PersistanceManager.ResetPlayerArrStat(PlotPlayer, StatType.Doors)
                PersistanceManager.ResetPlayerArrStat(PlotPlayer, StatType.Bar1Upgrades)
                PersistanceManager.ResetPlayerArrStat(PlotPlayer, StatType.Bar2Upgrades)
                PersistanceManager.ResetPlayerArrStat(PlotPlayer, StatType.Bar3Upgrades)
                if (CP := Custom_Player[GameManager.PlayersMap[PlotPlayer]]):
                    set CP.BoughtDoors = array{}

            RP.ResetStats()

#Main creative device class
Rebirth_Manager := class(creative_device):
    #Base Stuff
    PersistanceManager : Tycoon_Persistence_Manager = Tycoon_Persistence_Manager{}
    TT_RBM_Device_GameManager<localizes>:message = "Your Game Manager"
    @editable GameManager : Game_Manager = Game_Manager{}   
    
    TT_RBM_Device_ResourceManager<localizes>:message = "Your Resource Manager device"
    @editable ResourceManager : Resource_Manager = Resource_Manager{}

    TT_RBM_Device_ButtonManager<localizes>:message = "Your Button Manager"
    @editable ButtonManager : Button_Manager = Button_Manager{}

    TT_RBM_Device_PlotManager<localizes>:message = "Your Plot Manager"
    @editable PlotManager : Plot_Manager = Plot_Manager{}       

    #Devices
    TT_RBM_Device_BaseClassSelector<localizes>:message = "A class and team selector device that resets the player\'s team after rebirth"
    @editable BaseClassSelector : class_and_team_selector_device = class_and_team_selector_device{}
    
    TT_RBM_Device_RebirthPlayerTrigger<localizes>:message = "A trigger device that rebirths the player when triggered"
    @editable RebirthPlayerTrigger : trigger_device = trigger_device{} 

    TT_RBM_Device_RebirthedTrigger<localizes>:message = "A trigger device that get triggered when the player rebirths"
    @editable RebirthedTrigger : trigger_device = trigger_device{}

    TT_RBM_Device_AddedPlayerTrigger<localizes>:message = "A trigger device that get triggered when a player is added to the plot"
    @editable PlayerAddedToPlotTrigger : trigger_device = trigger_device{}

    #Extra Settings
    @editable RebirthSettings : RebirthSetting = RebirthSetting{}
    #Rebirth Image for Player UI
    #=========================================================================================================
    RebirthUITexture : texture = MasterAssets.Placeholder
    #=========================================================================================================

    #Initializes devices and adds rebirth UI for new players
    OnBegin<override>()<suspends>:void=
        RebirthPlayerTrigger.TriggeredEvent.Subscribe(TryRebirth)
        PlayerAddedToPlotTrigger.TriggeredEvent.Subscribe(AddedPlayerRebirthUI)
        #for(Player : GetPlayspace().GetPlayers()){spawn{AddRebirthUI(Player)}}
        #GetPlayspace().PlayerAddedEvent().Subscribe(PreAddRebirthUI)

    #Pre function to AddRebirthUI
    PreAddRebirthUI(Agent:agent) : void=
        spawn{AddRebirthUI(Agent)}

    AddedPlayerRebirthUI(MAgent : ?agent) : void =
        if (Agent := MAgent?):
            spawn{AddRebirthUI(Agent)}

    #Adds the Rebirth UI (Displays rebirths on screen) if enabled
    AddRebirthUI(Agent:agent)<suspends> : void=
        Sleep(1.0)
        if(CP := Custom_Player[GameManager.PlayersMap[Agent]], RP := ResourceManager.PlayersMap[Agent], RPUI := RP.ResourceUIMap[Agent]):
            set RP.RebirthBoostAmount = RebirthSettings.ResourceSettings.BoostMultiplier
            set RP.SaveRebirthPersistence = RebirthSettings.ResourceSettings.SavePersistance

            if(RebirthSettings.RebirthPlayerUISettings.DisplayOnPlayerUI?):
                
                RPUI.RebirthImage.SetImage(RebirthUITexture)
                RPUI.RebirthText.SetShadowOffset(option{RebirthSettings.RebirthPlayerUISettings.UIPositionSettings.TextSettings.TextShadowOffset})
                RPUI.RebirthText.SetShadowColor(RebirthSettings.RebirthPlayerUISettings.UIPositionSettings.TextSettings.TextShadowColor)
                RPUI.RebirthText.SetTextColor(RebirthSettings.RebirthPlayerUISettings.UIPositionSettings.TextSettings.TextColor)
                RPUI.RebirthText.SetShadowOpacity(1.0)
                RPUI.ResourceCanvas.AddWidget(RebirthSettings.RebirthPlayerUISettings.UIPositionSettings.TextPosition.MakeCanvasSlot(RPUI.RebirthText,false))
                RPUI.ResourceCanvas.AddWidget(RebirthSettings.RebirthPlayerUISettings.UIPositionSettings.ImagePosition.MakeCanvasSlot(RPUI.RebirthImage,false))

                RPUI.RebirthText.SetText(RoundedAmount("",RP.RebirthAmount,RebirthSettings.ResourceSettings.RoundDecimalPlace,""))

            if(ReDisplayType := RebirthSettings.RebirthPlayerUISettings.DisplayButtonAmountOnUI?):
                var ButtonRequirementText : text_block = text_block{}
                TextSettings := RebirthSettings.RebirthPlayerUISettings.DisplayButtonAmountOnUITextSettings
                ButtonRequirementText.SetShadowOffset(option{TextSettings.TextShadowOffset})
                ButtonRequirementText.SetShadowColor(TextSettings.TextShadowColor)
                ButtonRequirementText.SetTextColor(TextSettings.TextColor)
                ButtonRequirementText.SetShadowOpacity(1.0)
                CP.MyUI.AddWidget(RebirthSettings.RebirthPlayerUISettings.DisplayButtonAmountOnUIPosition.MakeCanvasSlot(ButtonRequirementText,false))
                spawn{UpdateTextLoop(Agent,ButtonRequirementText , ReDisplayType)}

    #Updates the players rebirth percentage text if enabled
    UpdateTextLoop(Agent : agent, TB : text_block , ReDisplayType : RemainingButtonDisplayType)<suspends> : void=
        if(CP := Custom_Player[GameManager.PlayersMap[Agent]]):
            race:
                block:
                    loop:
                        LeavingPlayer := GetPlayspace().PlayerRemovedEvent().Await()
                        if(LeavingPlayer = Agent):
                            break
                loop:
                    Sleep(0.5)
                    if(CP.BoughtDoors.Length <= RebirthSettings.RebirthPlayerUISettings.ButtonRequiredAmount):
                        if(ReDisplayType = RemainingButtonDisplayType.ButtonsRemaining):
                            TB.SetText(MasterS2M("{CP.BoughtDoors.Length} / {RebirthSettings.RebirthPlayerUISettings.ButtonRequiredAmount}"))
                        else if(ReDisplayType = RemainingButtonDisplayType.Percentage):
                            Percentage := ((CP.BoughtDoors.Length*1.0) /(RebirthSettings.RebirthPlayerUISettings.ButtonRequiredAmount*1.0)) * 100.0
                            TB.SetText(RoundedAmount("",Percentage,0,"%"))

    #Trys to rebirth the player with a trigger
    TryRebirth(NAgent:?agent) : void=
        if(Agent := NAgent?):
            if(RebirthSettings.ChoiceSetting = ChoiceType.Optional):
                if(Player := player[Agent], PlayerUI := GetPlayerUI[Player],CP := Custom_Player[GameManager.PlayersMap[Player]]):
                    NewRebirthUI := RebirthUI:
                        RebirthSettings := RebirthSettings
                        ButtonManager := ButtonManager
                        PlotManager := PlotManager
                        GameManager := GameManager
                        ResourceManager := ResourceManager
                        BaseClassSelector := BaseClassSelector
                        RebirthedTrigger := RebirthedTrigger
                    NewRebirthUI.Initialize(Agent)
                    CP.MyUI.SetVisibility(widget_visibility.Hidden)
                    PlayerUI.AddWidget(NewRebirthUI.MainUI,player_ui_slot{InputMode := ui_input_mode.All})
            else:
                RebirthPlayer(Agent)

    #Rebirths the player
    RebirthPlayer(Agent:agent) : void=
        if (RP := ResourceManager.PlayersMap[Agent]):
            if (CTS := PlotManager.CoopTycoonSettings?, CTS.CoopResourceCollectionType = CooperativeCollectionType.DifferentResources):
                for (PlotPlayer : PlotManager.PlotsPlayer):
                    AddRebirthResourceToCoop(PlotPlayer)
            else:
                #Collects differet amounts of rebirths depending on setting
                if(RebirthSettings.RebirthCollectionSettings.CollectionType = collectiontype.SetAmount):
                    set RebirthSettings.ResourceSettings.Amount = RebirthSettings.RebirthCollectionSettings.SetAmount
                    RP.CollectRebirth(array{RebirthSettings.ResourceSettings}) 

                else if(RebirthSettings.RebirthCollectionSettings.CollectionType = collectiontype.BasedAmount):
                    for(Re : RP.Resources):
                        if(Re.ResourceName = RebirthSettings.RebirthCollectionSettings.BasedResource.ResourceName):
                            if(NewAmount := Int[(Re.ResourceAmount / RebirthSettings.RebirthCollectionSettings.BasedAmountPerRebirth)]):
                                set RebirthSettings.ResourceSettings.Amount = NewAmount * 1.0
                                RP.CollectRebirth(array{RebirthSettings.ResourceSettings})

            #Activates devices
            RebirthedTrigger.Trigger(Agent)
            PlotManager.ClaimPlotPlayerRef.Clear()
            for (PlotPlayer : PlotManager.PlotsPlayer):
                BaseClassSelector.ChangeTeam(PlotPlayer)

            #Resets plot
            for(B : ButtonManager.ButtonsArray){spawn{B.ResetButton(Agent)}}    
            PlotManager.ResetPlotEvent.Signal(Agent)
            ButtonManager.ResetEvent.Signal(Agent)
                
            #Resets Plot Manager ATMs
            for(A : PlotManager.ATMs):
                A.ResetEvent.Signal()
                for(ATMRes : A.ATMResources):
                    set ATMRes.TempAmount = 0.0
                    for(B : ATMRes.Billboard):
                        B.SetText(MasterS2M(""))     

            #Shows the first button again
            if(FirstButton := ButtonManager.ButtonsArray[0]):
                spawn{FirstButton.ActivateDevices.EnableAll()}
                for(idx -> Item: FirstButton.ItemsToHide , CustomProp := FirstButton.ItemsToHideMap[idx]):
                    IsShown := CustomProp.CheckLocation()
                    if(not IsShown?):
                        CustomProp.ShowProp(FirstButton.RiseAnimation , true)
            
           
            #Resets Player Stats
            for (PlotPlayer : PlotManager.PlotsPlayer):
                PersistanceManager.ResetPlayerArrStat(PlotPlayer, StatType.Doors)
                PersistanceManager.ResetPlayerArrStat(PlotPlayer, StatType.Bar1Upgrades)
                PersistanceManager.ResetPlayerArrStat(PlotPlayer, StatType.Bar2Upgrades)
                PersistanceManager.ResetPlayerArrStat(PlotPlayer, StatType.Bar3Upgrades)
                if (CP := Custom_Player[GameManager.PlayersMap[PlotPlayer]]):
                    set CP.BoughtDoors = array{}

            for (PlotPlayer : PlotManager.PlotsPlayer, RPMap := ResourceManager.PlayersMap[PlotPlayer], RPUI := RPMap.ResourceUIMap[PlotPlayer]):
                RPUI.RemoveResourceUI(PlotPlayer)
                RPMap.ResetStats()

    # Adds rebirths to all players in the plot, used for co-op w/ different resources
    AddRebirthResourceToCoop(Agent : agent) : void =
        if (RP := ResourceManager.PlayersMap[Agent]):
            #Collects differet amounts of rebirths depending on setting
            if(RebirthSettings.RebirthCollectionSettings.CollectionType = collectiontype.SetAmount):
                set RebirthSettings.ResourceSettings.Amount = RebirthSettings.RebirthCollectionSettings.SetAmount
                RP.CollectRebirth(array{RebirthSettings.ResourceSettings}) 

            else if(RebirthSettings.RebirthCollectionSettings.CollectionType = collectiontype.BasedAmount):
                for(Re : RP.Resources):
                    if(Re.ResourceName = RebirthSettings.RebirthCollectionSettings.BasedResource.ResourceName):
                        if(NewAmount := Int[(Re.ResourceAmount / RebirthSettings.RebirthCollectionSettings.BasedAmountPerRebirth)]):
                            set RebirthSettings.ResourceSettings.Amount = NewAmount * 1.0
                            RP.CollectRebirth(array{RebirthSettings.ResourceSettings})


#Settings that control the rebirth choice UI
RebirthChoiceUISetting := class<concrete>():
    @editable CancelButtonPosition : CanvasPosition = CanvasPosition{}
    @editable AcceptButtonPosition : CanvasPosition = CanvasPosition{}
    @editable BackgroundPosition : CanvasPosition = CanvasPosition{}
    @editable GainTextPosition : CanvasPosition = CanvasPosition{}
    @editable GainTextSettings : TextSetting = TextSetting{}
    @editable ButtonType : UIButtonType = UIButtonType.Loud

#Settings that control whether the rebirth amount should be displayed on players UI
RebirthPlayerUISetting := class<concrete>():
    @editable DisplayOnPlayerUI : logic = false
    @editable UIPositionSettings : BaseAmountSetting = BaseAmountSetting{}
    @editable DisplayButtonAmountOnUI : ?RemainingButtonDisplayType = false
    @editable DisplayButtonAmountOnUIPosition : CanvasPosition = CanvasPosition{}
    @editable DisplayButtonAmountOnUITextSettings : TextSetting = TextSetting{}
    @editable ButtonRequiredAmount : int = 0

#Overall settings that hold other settings
RebirthSetting := class<concrete>():
    TT_RBM_Device_RebirthSetting_ChoiceSetting<localizes>:message = "How the player can rebirth\nAuto: player automatically rebirths after 'RebirthPlayerTrigger' is triggered\nOptional : a UI is shown and the player has to confirm"
    @editable ChoiceSetting : ChoiceType = ChoiceType.Optional
    
    TT_RBM_Device_RebirthSetting_RebirthChoiceUISettings<localizes>:message = "The settings that control the UI when the player rebirths"
    @editable RebirthChoiceUISettings : RebirthChoiceUISetting = RebirthChoiceUISetting{}
    
    TT_RBM_Device_RebirthSetting_RebirthPlayerUISettings<localizes>:message = "The settings that control the UI that displays the rebirth resource amount"
    @editable RebirthPlayerUISettings : RebirthPlayerUISetting = RebirthPlayerUISetting{}
    
    TT_RBM_Device_RebirthSetting_ResourceSettings<localizes>:message = "The settings that controls how the rebirth resource is displayed"
    @editable ResourceSettings : RebirthResource = RebirthResource{ResourceName := "Rebirth"}
    
    TT_RBM_Device_RebirthSetting_RebirthCollectionSettings<localizes>:message = "The settings that controls how rebirths are collected"
    @editable RebirthCollectionSettings : RebirthCollectionSetting = RebirthCollectionSetting{}

#Settings that control how rebirths are collected
RebirthCollectionSetting:= class<concrete>():
    TT_RBM_Device_RebirthSetting_RebirthCollectionSetting_CollectionType<localizes>:message = "How the rebirth amount is collected\nSetAmount: the amount is set to a specific amount\nBasedAmount: the amount is based on the amount of a resource"
    @editable CollectionType : collectiontype = collectiontype.SetAmount

    TT_RBM_Device_RebirthSetting_RebirthCollectionSetting_SetAmount<localizes>:message = "The fixed amount of rebirths that is collected\nOnly works if 'CollectionType' is 'SetAmount'"
    @editable SetAmount : float = 0.0

    TT_RBM_Device_RebirthSetting_RebirthCollectionSetting_BasedResource<localizes>:message = "The resource that is used to calculate the rebirth amount\nOnly works if 'CollectionType' is 'BasedAmount'"
    @editable BasedResource : BaseResource = BaseResource{}

    TT_RBM_Device_RebirthSetting_RebirthCollectionSetting_BasedAmountPerRebirth<localizes>:message = "The amount of the 'BasedResource' that is needed to collect 1 rebirth\nOnly works if 'CollectionType' is 'BasedAmount'"
    @editable BasedAmountPerRebirth : float = 0.0

#Different collection types
collectiontype := enum:
    SetAmount
    BasedAmount

#Different choice types
ChoiceType := enum:
    Auto
    Optional

#Different choice types
RemainingButtonDisplayType := enum:
    ButtonsRemaining
    Percentage