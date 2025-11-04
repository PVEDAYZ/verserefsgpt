<#
====================================================================================================
Copyright (c) 2024 MapAcademy. All rights reserved.

 

This software and its associated documentation files (the "Software") are the

proprietary property of MapAcademy and are protected by copyright law.

 

The Software is provided to you under the terms of the MapAcademy End User

License Agreement (the "License"). You may use, copy, distribute, and modify

the Software solely in accordance with the terms of the License.

 

BY USING THE SOFTWARE, YOU AGREE TO BE BOUND BY THE TERMS OF THE LICENSE.

IF YOU DO NOT AGREE TO THE TERMS OF THE LICENSE, DO NOT USE THE SOFTWARE.

 

The Software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND,

either express or implied, including without limitation any warranties of

MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, or NON-INFRINGEMENT.

For more details, please refer to the MapAcademy End User License Agreement.
====================================================================================================
#>

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Assets  }
using { /Fortnite.com/Characters }
using { /Verse.org/Random }

#THIS SCRIPT MANAGES WHICH PLAYER OWNS A PLOT AND CONTROLS ATMS

#Class for each ATM
ATM := class<concrete>():
    #Base Stuff
    var GameManager : Game_Manager = Game_Manager{}
    var ResourceManager : Resource_Manager = Resource_Manager{}
    var PlotManager : Plot_Manager = Plot_Manager{}
    var ScoreManager : score_manager_device = score_manager_device{}
    PersistanceManager : Tycoon_Persistence_Manager = Tycoon_Persistence_Manager{}
    ResetEvent<public> : event() = event(){}    
    
    #Devices
    TT_ATM_StartATMTrigger<localizes>:message = "A trigger deivce that activates this ATM"
    @editable{ToolTip := TT_ATM_StartATMTrigger} StartATMTrigger : trigger_device = trigger_device{}

    TT_ATM_ClaimMoneyActivator<localizes>:message = "An activator device that claims the money from the ATM when activated"
    @editable{ToolTip := TT_ATM_ClaimMoneyActivator} ClaimMoneyActivator : []ActivateDevice = array{}


    var ClaimMoneyHUD : hud_message_device = hud_message_device{}

    TT_ATM_ATMVFX<localizes>:message = "A vfx spawner device that spawns a vfx when money is claimed from the ATM"
    @editable{ToolTip := TT_ATM_ATMVFX} ATMVFX : vfx_spawner_device = vfx_spawner_device{}

    #Resources collected by the ATM
    TT_ATM_ATMResources<localizes>:message = "The resources that are collected in the ATM"
    @editable{ToolTip := TT_ATM_ATMResources} ATMResources : []ATMResource = array{} 

    #Extra Settings
    TT_ATM_ATMSpeed<localizes>:message = "The speed at which the ATM collects money"
    @editable{ToolTip := TT_ATM_ATMSpeed} ATMSpeed : float = 1.0

    #Starts the ATM loop for a trigger
    ATMStartTrigger(NAgent : ?agent) : void=
        if(Agent := NAgent?){spawn{ATMStart(Agent)}}

    #Starts the ATM loop
    ATMStart(Agent:agent)<suspends> : void=
        ATMVFX.Enable()
        if(Player := player[Agent], CustomPlayer := GameManager.PlayersMap[Player], RP := ResourceManager.PlayersMap[Player]):
            race:
                #Waits for ATM to reset
                block:  
                    ResetEvent.Await()     
                    ATMVFX.Disable()
                    return

                #Collects Resources in ATM loop
                loop:      
                    Sleep(ATMSpeed)
                    # If co-op enabled, 
                    if (CTS := PlotManager.CoopTycoonSettings?, CTS.CoopResourceCollectionType = CooperativeCollectionType.DifferentResources):
                        MostIdlePlayer := PlayerMostIdleResource()
                        for (PlayerPlot : PlotManager.PlotsPlayer, RPS := ResourceManager.PlayersMap[PlayerPlot]):
                            if (MIP := MostIdlePlayer?, RPMostIdle := ResourceManager.PlayersMap[MIP]):
                                for (Index -> Resource : RPS.Resources):
                                    if (RIA := RPMostIdle.Resources[Index].ResourceIdleAmount):
                                        set Resource.ResourceIdleAmount = RIA

                        for (PlayerPlot : PlotManager.PlotsPlayer, RPS := ResourceManager.PlayersMap[PlayerPlot]):
                            RPS.CollectAtmResources(ResourceManager,ATMResources) 

                    else if(CTS := PlotManager.CoopTycoonSettings?, CTS.CoopResourceCollectionType = CooperativeCollectionType.SharedResources):
                        if (MainPlayer := PlotManager.PlotsPlayer[0], RPS := ResourceManager.PlayersMap[MainPlayer]):
                            RPS.CollectAtmResources(ResourceManager,ATMResources)   

                    else:
                        RP.CollectAtmResources(ResourceManager,ATMResources)  

                    for(Re : RP.Resources):
                        for(ATMRes : ATMResources):
                            if(Re.ResourceName = ATMRes.ResourceName , not ATMRes.AutoCollect?):
                                if(Re.IsEffectedByRebirths?):
                                    NewIncAmount := Re.ResourceIdleAmount * (Re.ResourceBoostAmount + (RP.RebirthAmount * RP.RebirthBoostAmount))
                                    set ATMRes.TempAmount += NewIncAmount
                                    for(B : ATMRes.Billboard):
                                        B.SetText(RoundedAmount("",ATMRes.TempAmount , 1 , ""))
                                else:
                                    NewIncAmount := Re.ResourceIdleAmount * Re.ResourceBoostAmount
                                    set ATMRes.TempAmount += NewIncAmount
                                    for(B : ATMRes.Billboard):
                                        B.SetText(RoundedAmount("",ATMRes.TempAmount , 1 , ""))

                            #Adds score to score manager
                            if(Re.TrackOnScoreboard?):
                                if(NewAmount := Int[Re.ResourceAmount]):
                                    ScoreManager.SetScoreAward(NewAmount)
                                    ScoreManager.Activate(Agent)


    PlayerMostIdleResource() : ?agent =
        var PlayerMostIdle : ?agent = false
        var MostIdle : float = 0.0
        for (PlotPlayer : PlotManager.PlotsPlayer):
            if (RP := ResourceManager.PlayersMap[PlotPlayer]):
                if (Res := RP.Resources[0]):
                    if(Res.ResourceIdleAmount >= MostIdle):
                        set PlayerMostIdle = option{PlotPlayer}
                        set MostIdle = Res.ResourceIdleAmount

        return PlayerMostIdle
    
    #Calls the 'ClaimMoney' function except from a trigger
    ClaimMoneyTrigger(NAgent:?agent) : void=      
        if(Agent := NAgent?){ClaimMoney(Agent)}

    #Claims the current money in the ATM for the player
    ClaimMoney(Agent:agent) : void=      
        if(Player := player[Agent], CustomPlayer := GameManager.PlayersMap[Player]):
            var CollectResourceArray : []ATMResource = array{}
            for(ATMRes : ATMResources):
                set CollectResourceArray += array{ATMResource{
                    ResourceName := ATMRes.ResourceName
                    Amount := ATMRes.TempAmount
                    ShowPopUp := ATMRes.ShowPopUp 
                    EffectedByBoost := ATMRes.EffectedByBoost
                    OverrideRebirthEffect := ATMRes.OverrideRebirthEffect
                    OverridePopUpSettings := ATMRes.OverridePopUpSettings
                    }}
                set ATMRes.TempAmount = 0.0
                for(B : ATMRes.Billboard):
                    B.SetText(RoundedAmount("",ATMRes.TempAmount,1,""))
  

            CustomPlayer.CollectAtmResources(ResourceManager,CollectResourceArray)
            ClaimMoneyHUD.Show(Agent)   

#Main creative device class
Plot_Manager := class(creative_device):
    # Unique ID for every plot, used for co-op tycoon joining
    var PlotID : int = 0

    #Base Stuff
    TT_PM_ButtonManager<localizes>:message = "Your button manager device"
    @editable{ToolTip := TT_PM_ButtonManager} ButtonManager : Button_Manager = Button_Manager{}

    TT_PM_GameManager<localizes>:message = "Your game manager device"
    @editable{ToolTip := TT_PM_GameManager} GameManager : Game_Manager = Game_Manager{}

    TT_PM_ResourceManager<localizes>:message = "Your resource manager device"
    @editable{ToolTip := TT_PM_ResourceManager} ResourceManager : Resource_Manager = Resource_Manager{}

    PersistanceManager : Tycoon_Persistence_Manager = Tycoon_Persistence_Manager{}
    var PlotsPlayer : []agent = array{}
    ResetPlotEvent : event(agent) = event(agent){}
    var MaybeMyUIPerPlayer : [player]?canvas = map{}
    PlotLoadEvent : event(agent) = event(agent){}
    PlotClaimEvent : event(agent) = event(agent){}
    PlotClosedUIEvent : event() = event(){}
    
    

    #Devices
    TT_PM_ClaimPlotActivator<localizes>:message = "The activator device that claims the plot"
    @editable{ToolTip := TT_PM_ClaimPlotActivator} ClaimPlotActivator : ActivateDevice = ActivateDevice{}

    TT_PM_ClaimPlotSelector<localizes>:message = "A class and team selector device that changes the player\'s team to the plot\'s team\n*Required Settings*\nTeam To Switch To: Team Index X (where X is the plot number)"
    @editable{ToolTip := TT_PM_ClaimPlotSelector} ClaimPlotSelector : class_and_team_selector_device = class_and_team_selector_device{}  

    TT_PM_ClaimMoneyHUD<localizes>:message = "A hud message device that is displayed whenever the player claims money from the ATM\n*Required Settings*\nMessage Recipient: Triggering Player"
    @editable{ToolTip := TT_PM_ClaimMoneyHUD} ClaimMoneyHUD : hud_message_device = hud_message_device{}   

    TT_PM_ClaimPlotPlayerRef<localizes>:message = "A player reference device that displays the player that claimed the plot"
    @editable{ToolTip := TT_PM_ClaimPlotPlayerRef} ClaimPlotPlayerRef : player_reference_device = player_reference_device{} 

    TT_PM_ClaimPlotHud<localizes>:message = "A hud message device that is displayed when the player claims the plot\n*Required Settings*\nMessage Recipient: Triggering Player"
    @editable{ToolTip := TT_PM_ClaimPlotHud} ClaimPlotHud : hud_message_device = hud_message_device{}

    TT_PM_ClaimPlotTracker<localizes>:message = "A tracker device that is incremented when the player claims the plot\n*Required Settings*\nStat To Track : Events\nTarget Value: 1"
    @editable{ToolTip := TT_PM_ClaimPlotTracker} ClaimPlotTracker : tracker_device = tracker_device{}

    TT_PM_ScoreManager<localizes>:message = "A score manager device that is used to display a player\'s currency amount on the game\'s score leaderboard\n*Required Settings*\nScore Award Type : Set"
    @editable{ToolTip := TT_PM_ScoreManager} ScoreManager : score_manager_device = score_manager_device{}

    #Extra settings
    TT_PM_ResetOnPlayerLeave<localizes>:message = "If enabled, the plot will be reset when the player leaves the game\nFor co-op, if all players leave the plot, then the plot resets."
    @editable{ToolTip := TT_PM_ResetOnPlayerLeave} ResetOnPlayerLeave : logic = false

    # Coop
    TT_PM_CoopTycoonSettings<localizes>:message = "Settings to create a co-op tycoon instead of a solo one.\nIf you do not want a co-op tycoon, make sure the button says \"Set To Value\""
    @editable{ToolTip := TT_PM_CoopTycoonSettings} CoopTycoonSettings : ?CooperativeSetting = false

    TT_RBM_Device_AddedPlayerTrigger<localizes>:message = "A trigger device that get triggered when a player is added to the plot"
    @editable{ToolTip := TT_RBM_Device_AddedPlayerTrigger} PlayerAddedToPlotTrigger : trigger_device = trigger_device{}

    TT_PM_PlotLoadSettings<localizes>:message = "Settings to control how the plot is loaded when the player has played before"
    @editable{ToolTip := TT_PM_PlotLoadSettings} PlotLoadSettings : PlotLoadSetting = PlotLoadSetting{}

    #ATMs
    TT_PM_ATMs<localizes>:message = "The ATMs that are associated with this plot"
    @editable{ToolTip := TT_PM_ATMs} ATMs : []ATM = array{}

    #Background image for Plot Load UI
    #=================================================================================================================================
    var PlotLoadTextImage : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}
    #=================================================================================================================================
           
    #Initializes devices and ATMs
    OnBegin<override>()<suspends>:void= 
        ClaimPlotActivator.ActivateMutatorZone.AgentEntersEvent.Subscribe(ClaimPlotSetup)
        ClaimPlotActivator.ActivateTrigger.TriggeredEvent.Subscribe(ClaimPlotSetupTrigger)
        ClaimPlotActivator.ActivateButton.InteractedWithEvent.Subscribe(ClaimPlotSetup)
        ClaimPlotActivator.ActivateVolume.AgentEntersEvent.Subscribe(ClaimPlotSetup) 

        GetPlayspace().PlayerRemovedEvent().Subscribe(PlayerLeft)

        for(A : ATMs):
            set A.GameManager = GameManager
            set A.ResourceManager = ResourceManager
            set A.ScoreManager = ScoreManager
            set A.PlotManager = Self
            set A.ClaimMoneyHUD = ClaimMoneyHUD
            for(Activator : A.ClaimMoneyActivator):
                Activator.ActivateMutatorZone.AgentEntersEvent.Subscribe(A.ClaimMoney)
                Activator.ActivateTrigger.TriggeredEvent.Subscribe(A.ClaimMoneyTrigger)
                Activator.ActivateButton.InteractedWithEvent.Subscribe(A.ClaimMoney)
                Activator.ActivateVolume.AgentEntersEvent.Subscribe(A.ClaimMoney) 
            A.StartATMTrigger.TriggeredEvent.Subscribe(A.ATMStartTrigger)

        if (CTS := CoopTycoonSettings?):
            set CTS.PlotManager = Self
            CTS.JoinPlotDevices.ActivateMutatorZone.AgentEntersEvent.Subscribe(CTS.JoinPlot)
            CTS.JoinPlotDevices.ActivateTrigger.TriggeredEvent.Subscribe(CTS.JoinPlotTrigger)
            CTS.JoinPlotDevices.ActivateButton.InteractedWithEvent.Subscribe(CTS.JoinPlot)
            CTS.JoinPlotDevices.ActivateVolume.AgentEntersEvent.Subscribe(CTS.JoinPlot) 
            spawn{CTS.EnableDisablePlotJoinTrig()}


                    

    #Calls 'ClaimPlotSetup' but with a trigger
    ClaimPlotSetupTrigger(NAgent : ?agent): void=
        if(Agent := NAgent?){ClaimPlotSetup(Agent)}

    #Starts ATMs and Claims Plot
    ClaimPlotSetup(Agent:agent) : void=
        spawn{ClaimPlot(Agent)}
    
    #Claims Plot
    ClaimPlot(Agent:agent)<suspends> : void=
        if(Player := player[Agent], CustomPlayer := Custom_Player[GameManager.PlayersMap[Player]]):
            set PlotID = CustomPlayer.CurrentPlotID

            # If there is no saved plot ID, generate a random new one
            if (PlotID = 0):
                set PlotID = GetRandomInt(0, 999999)
                set CustomPlayer.CurrentPlotID = PlotID

            PersistanceManager.RecordPlayerArrStat(Agent, StatType.PlotID, ?Score := PlotID)

            # Adds the resources and resource UI to the player
            ResourceManager.OnPlayerJoined(Player)

            #Activates claim plot devices
            ClaimPlotSelector.ChangeTeam(Agent)     
            ClaimPlotPlayerRef.Register(Agent)         
            ClaimPlotHud.Show(Agent)               
            ClaimPlotTracker.Increment(Agent)
            PlotClaimEvent.Signal(Agent)
            ButtonManager.PlotClaimedEvent.Signal(Agent)
            

            #Assigns player to plot manager
            set PlotsPlayer = array{}
            set PlotsPlayer += array {Agent}  

            #If player has not bought any doors, unlocks first button
            if(CustomPlayer.BoughtDoors.Length < 1 ):   
                if(FirstButton := ButtonManager.ButtonsArray[0]){spawn{FirstButton.UnlockButton(Agent,true)}}
                if(RP := ResourceManager.PlayersMap[Player]):
                    RP.SetResourceUI(Player)
                    
            #If player has bought doors before, and plot loading is off, unlocks first button
            else if(PlotLoadSettings.PlotLoading = LoadingType.Off):
                if(FirstButton := ButtonManager.ButtonsArray[0]){spawn{FirstButton.UnlockButton(Agent,true)}}
                if(RP := ResourceManager.PlayersMap[Player]):
                    RP.SetResourceUI(Player)
                    
            #If player has bought doors before, and plot loading is on automatic, unlocks all of the players bought doors
            else if(PlotLoadSettings.PlotLoading = LoadingType.Auto):
                PlotLoadEvent.Signal(Agent)
                if(RP := ResourceManager.PlayersMap[Player]):
                    RP.SetResourceUI(Player)
                for(BoughtDoor : CustomPlayer.BoughtDoors):
                    if(TempB := ButtonManager.ButtonsArray[BoughtDoor]){spawn{TempB.UnlockButton(Player,false)}}
                        
            #If player has bought doors before, and plot loading is on optional, prompts the player to choose between loading or resetting
            else if(PlotLoadSettings.PlotLoading = LoadingType.Optional):     
                ChooseToUnlock(Agent)
                if(RP := ResourceManager.PlayersMap[Player]):
                    RP.SetResourceUI(Player)

            PlayerAddedToPlotTrigger.Trigger(Agent)

            if (CTS := CoopTycoonSettings?):
                spawn{UpdateBoughtDoorsForCoop()}

    # Adds player to plot for co-op tycoon
    AddPlayerToPlot(Agent : agent) : void =
        if (PlotsPlayer.Length > 0):
            if(Player := player[Agent], CustomPlayer := Custom_Player[GameManager.PlayersMap[Player]], CTS := CoopTycoonSettings?):
                if(PlotID = CustomPlayer.CurrentPlotID or CustomPlayer.CurrentPlotID = 0):
                    PersistanceManager.RecordPlayerArrStat(Agent, StatType.PlotID, ?Score := PlotID)
                    #Activates claim plot devices
                    ClaimPlotSelector.ChangeTeam(Agent) 

                    #Assigns player to plot manager
                    set PlotsPlayer += array {Agent}  

                    # Sets the player's resource manager to the current plots
                    if (CTS.CoopResourceCollectionType = CooperativeCollectionType.SharedResources):
                        if:
                            PlotClaimer := PlotsPlayer[0]
                            PCPlayer := player[PlotClaimer]
                            PCMap := ResourceManager.PlayersMap[PCPlayer]
                        then:
                            set CustomPlayer.CurrentPlotID = PlotID
                            PersistanceManager.RecordPlayerArrStat(Agent, StatType.PlotID, ?Score := PlotID)
                            ResourceManager.OnPlayerJoined(Player)
                            if(set ResourceManager.PlayersMap[Player] = PCMap, RP := ResourceManager.PlayersMap[Player]):
                                RP.SaveAllStats(Player)
                                RP.SetResourceUI(Agent)
                                PlayerAddedToPlotTrigger.Trigger(Agent)
                    else:
                        ResourceManager.OnPlayerJoined(Player)
                        if(RP := ResourceManager.PlayersMap[Player], PlotClaimer := PlotsPlayer[0], PCMap := ResourceManager.PlayersMap[PlotClaimer]):
                            if (CustomPlayer.CurrentPlotID = 0):
                                RP.ResetStats()
                                RP.SaveAllStats(Player)
                            # Set the rebirths and idle amounts, as they are plot shared
                            set RP.RebirthAmount = PCMap.RebirthAmount
                            PersistanceManager.SetPlayerStat(Agent, StatType.Rebirths, ?Score := RP.RebirthAmount)
                            for (Index -> Resource : RP.Resources):
                                if (RIA := PCMap.Resources[Index].ResourceIdleAmount):
                                    set Resource.ResourceIdleAmount = RIA

                            set CustomPlayer.CurrentPlotID = PlotID
                            PersistanceManager.RecordPlayerArrStat(Agent, StatType.PlotID, ?Score := PlotID)
                            RP.SetResourceUI(Agent)
                            PlayerAddedToPlotTrigger.Trigger(Agent)
                else:
                    # WARNING POP UP 
                    if (PlayerUI := GetPlayerUI[Player]):
                        JoinPlotUICanvas := JoinPlotUI:
                            PlotManager := Self
                            GameManager := GameManager
                            ResourceManager := ResourceManager
                            JoinPlotUISettings := CTS.JoinPlotUISettings
                        JoinPlotUICanvas.Initialize(Agent)
                        PlayerUI.AddWidget(JoinPlotUICanvas.MainUI,player_ui_slot{InputMode := ui_input_mode.All})
                        
        else:
            #Print("PLOT IS NOT CLAIMED YET!")


    #Adds the unlock UI to player
    ChooseToUnlock(Agent:agent) : void=
        if(Player := player[Agent],PlayerUI := GetPlayerUI[Player]):
            UnlockUI := CreateUnlockUI()
            PlayerUI.AddWidget(UnlockUI,player_ui_slot{InputMode := ui_input_mode.All})
            if(set MaybeMyUIPerPlayer[Player] = option{UnlockUI}){}
            spawn{PlotElimTrack(Agent)}
    
    PlotElimTrack(Agent:agent)<suspends> : void=
        if (Player := player[Agent],PlayerUI := GetPlayerUI[Player],FC:=Agent.GetFortCharacter[],CP := GameManager.PlayersMap[Agent], PlayerWidget := MaybeMyUIPerPlayer[Player]?):
            race:
                FC.EliminatedEvent().Await()
                PlotClosedUIEvent.Await()
            PlayerWidget.SetVisibility(widget_visibility.Hidden)
            PlayerUI.RemoveWidget(PlayerWidget)
            if(set MaybeMyUIPerPlayer[Player] = false){}

    #Creates the unlock UI
    CreateUnlockUI() : canvas=
        var LoadButtons : UIAllButtons = UIAllButtons{}
        var ResetButtons : UIAllButtons = UIAllButtons{}
        LoadButton := LoadButtons.GetButton(PlotLoadSettings.ButtonType)
        ResetButton := ResetButtons.GetButton(PlotLoadSettings.ButtonType)
        LoadButton.SetText(MasterS2M("Load"))
        ResetButton.SetText(MasterS2M("Reset"))
        LoadButton.OnClick().Subscribe(Load)
        ResetButton.OnClick().Subscribe(Reset)
        NewUnlockUI : canvas = canvas:
            Slots := array:
                PlotLoadSettings.TextImagePosition.MakeCanvasSlot(PlotLoadTextImage , false)
                PlotLoadSettings.ResetButtonPosition.MakeCanvasSlot(ResetButton , false)
                PlotLoadSettings.LoadButtonPosition.MakeCanvasSlot(LoadButton , false)


    #Loads the saved progress for the player
    Load(Message : widget_message) : void=
        Player := Message.Player
        if (PlayerUI := GetPlayerUI[Message.Player], PlayerWidget := MaybeMyUIPerPlayer[Player]?,CP := Custom_Player[GameManager.PlayersMap[Player]]):
            PlotClosedUIEvent.Signal()

            #Unlocks all doors from the players persistence data
            PlotLoadEvent.Signal(Player)
            for(BoughtDoor : CP.BoughtDoors):      
                if(TempB := ButtonManager.ButtonsArray[BoughtDoor]){spawn{TempB.UnlockButton(Player,false)}}
                
                    

    
    #resets the saved progress for the player
    Reset(Message : widget_message) : void=
        Player := Message.Player
        if (PlayerUI := GetPlayerUI[Message.Player], PlayerWidget := MaybeMyUIPerPlayer[Player]?, RP := ResourceManager.PlayersMap[Player]):
            PlotClosedUIEvent.Signal()
            set PlotID = GetRandomInt(0, 999999)
            set RP.RebirthAmount = 0.0
            PersistanceManager.RecordPlayerArrStat(Player, StatType.PlotID, ?Score := PlotID)

            RP.ResetStats()
            ResourceManager.PersistenceManager.SetPlayerStat(Player, StatType.Rebirths, ?Score := 0.0)
            for (PlotPlayer : PlotsPlayer):
                PersistanceManager.ResetPlayerArrStat(PlotPlayer, StatType.Doors)
                PersistanceManager.ResetPlayerArrStat(PlotPlayer, StatType.Bar1Upgrades)
                PersistanceManager.ResetPlayerArrStat(PlotPlayer, StatType.Bar2Upgrades)
                PersistanceManager.ResetPlayerArrStat(PlotPlayer, StatType.Bar3Upgrades)
                if (CP := Custom_Player[GameManager.PlayersMap[PlotPlayer]]):
                    set CP.BoughtDoors = array{}

            if(FirstButton := ButtonManager.ButtonsArray[0]){spawn{FirstButton.UnlockButton(Player,true)}}
                
    #Resets the plot when the player leaves if enabled
    PlayerLeft(Agent:agent ) : void=            
        #if(CP := GameManager.PlayersMap[Agent]):
            if(ResetOnPlayerLeave = true):
                if (PlotsPlayer.Length = 1):
                    for(B : ButtonManager.ButtonsArray):       
                        spawn{B.ResetButton(Agent)}
                        
                        ClaimPlotPlayerRef.Clear()

                    for(A : ATMs):
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
                        
                    ResetPlotEvent.Signal(Agent)
                    ButtonManager.ResetEvent.Signal(Agent)
                else:
                    #Print("PLAYERS STILL IN PLOT LEFT!")
            
            # Remove player from PlotPlayers
            for (Index -> Player : PlotsPlayer):
                if (Agent = Player, NewArray := PlotsPlayer.RemoveElement[Index]):
                    set PlotsPlayer = NewArray


    # In co-op, this will update the button array for all players when 1 player buys it
    UpdateBoughtDoorsForCoop()<suspends> : void =
        race:
            loop:
                if(PlotsPlayer.Length = 0):
                    break
                Sleep(3.0)
            loop:
                var PlayerMostButtons : ?agent = false
                var MostButtons : int = 0
                for (PlotPlayer : PlotsPlayer):
                    if (CP := Custom_Player[GameManager.PlayersMap[PlotPlayer]]):
                        if(CP.BoughtDoors.Length > MostButtons):
                            set PlayerMostButtons = option{PlotPlayer}
                            set MostButtons = CP.BoughtDoors.Length

                if (MostP := Custom_Player[GameManager.PlayersMap[PlayerMostButtons?]]):
                    for (PlotPlayer : PlotsPlayer, PlotPlayer <> PlayerMostButtons?):
                        if (CP := Custom_Player[GameManager.PlayersMap[PlotPlayer]], CP.BoughtDoors <> MostP.BoughtDoors):
                            set CP.BoughtDoors = MostP.BoughtDoors
                            PersistanceManager.SetPlayerArrStat(PlotPlayer, StatType.Doors, ?Score := CP.BoughtDoors)

                Sleep(3.0)





JoinPlotUI := class():
    var GameManager : Game_Manager = Game_Manager{}
    var ResourceManager : Resource_Manager = Resource_Manager{}
    var PlotManager : Plot_Manager = Plot_Manager{}
    #UI Stuff
    var MainUI : canvas = canvas{}
    var CancelButtons : UIAllButtons = UIAllButtons{}
    var AcceptButtons : UIAllButtons = UIAllButtons{}
    var DisplayText : text_block = text_block{}

    var JoinPlotUISettings : JoinPlotUISetting = JoinPlotUISetting{}
    JoinPlotCloseEvent : event() = event(){}

    #JoinPlot Background Image
    #===================================================================================================================================
    var Background : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}
    #===================================================================================================================================

    #Initializes the UI widgets
    Initialize(Agent:agent) : void=
        CancelButton := CancelButtons.GetButton(JoinPlotUISettings.ButtonType)
        AcceptButton := AcceptButtons.GetButton(JoinPlotUISettings.ButtonType)

        CancelButton.SetText(MasterS2M("Cancel"))
        AcceptButton.SetText(MasterS2M("Accept"))
        set MainUI = CreateUI(Agent)

        spawn{PlotJoinElimTrack(Agent)}

    PlotJoinElimTrack(Agent:agent)<suspends> : void=
        if (Player := player[Agent],PlayerUI := GetPlayerUI[Player],FC:=Agent.GetFortCharacter[],CP := Custom_Player[GameManager.PlayersMap[Agent]]):
            race:
                FC.EliminatedEvent().Await()
                JoinPlotCloseEvent.Await()

            MainUI.SetVisibility(widget_visibility.Hidden)
            CP.MyUI.SetVisibility(widget_visibility.Visible)
            PlayerUI.RemoveWidget(MainUI)

    #Creates the UI
    CreateUI(Agent:agent) : canvas= 
        CancelButton := CancelButtons.GetButton(JoinPlotUISettings.ButtonType)
        AcceptButton := AcceptButtons.GetButton(JoinPlotUISettings.ButtonType)

        DisplayText.SetShadowOffset(option{JoinPlotUISettings.DisplayTextSettings.TextShadowOffset})
        DisplayText.SetShadowColor(JoinPlotUISettings.DisplayTextSettings.TextShadowColor)
        DisplayText.SetTextColor(JoinPlotUISettings.DisplayTextSettings.TextColor)
        DisplayText.SetShadowOpacity(1.0)
        DisplayText.SetText(MasterS2M("{JoinPlotUISettings.DisplayText}"))
        DisplayText.SetJustification(text_justification.Center)

        CancelButton.OnClick().Subscribe(Cancel)
        AcceptButton.OnClick().Subscribe(JoinPlotAccept)
        NewUnlockUI : canvas = canvas:
            Slots := array:
                JoinPlotUISettings.CancelButtonPosition.MakeCanvasSlot(CancelButton , false)
                JoinPlotUISettings.AcceptButtonPosition.MakeCanvasSlot(AcceptButton , false)
                JoinPlotUISettings.BackgroundPosition.MakeCanvasSlot(Background , false)
                JoinPlotUISettings.DisplayTextPosition.MakeCanvasSlot(DisplayText , false)

        return NewUnlockUI


    # Cancels the UI for the player
    Cancel(Message : widget_message) : void=
        Player := Message.Player
        if (PlayerUI := GetPlayerUI[Message.Player],CP := GameManager.PlayersMap[Player]):
            JoinPlotCloseEvent.Signal()


    #Resets the saved progress for the player
    JoinPlotAccept(Message : widget_message) : void=
        Player := Message.Player
        if (PlayerUI := GetPlayerUI[Message.Player], CP := GameManager.PlayersMap[Player]):
            #Closes UI
            JoinPlotCloseEvent.Signal()
            
            # Resets stats and adds player to the plot
            set CP.CurrentPlotID = 0
            CP.ResetAllStats(Player)
            PlotManager.AddPlayerToPlot(Player)
            
            


# Settings to create a co-op tycoon
CooperativeSetting := class<concrete>():
    var PlotManager : Plot_Manager = Plot_Manager{}

    TT_CS_Enable<localizes>:message = "Enables the co-op tycoon features"
    @editable{ToolTip := TT_CS_Enable} EnableCoopTycoon : logic = true

    TT_CS_JoinPlotDev<localizes>:message = "The devices that the player will activate to join the plot"
    @editable{ToolTip := TT_CS_JoinPlotDev} JoinPlotDevices : ActivateDevice = ActivateDevice{}

    TT_CS_PlotJoinUI<localizes>:message = "The UI settings for the Plot Join UI"
    @editable{ToolTip := TT_CS_PlotJoinUI} JoinPlotUISettings : JoinPlotUISetting = JoinPlotUISetting{}

    TT_CS_DisablePlotTrig<localizes>:message = "Trigger to disable and enable the Plot Joining Trigger"
    @editable{ToolTip := TT_CS_DisablePlotTrig} DisablePlotJoiningTrigger : trigger_device = trigger_device{}

    TT_CS_Max<localizes>:message = "The max amount of players that a co-op tycoon can have"
    @editable{ToolTip := TT_CS_Max} MaxAmountOfPlayers : int = 2

    TT_CS_CollectionType<localizes>:message = "The type of resource collection for the co-op players\nSharedResources: All players have the same resource amount pool\nDifferentResources: Each player has their own resource amount"
    @editable{ToolTip := TT_CS_CollectionType} CoopResourceCollectionType : CooperativeCollectionType = CooperativeCollectionType.SharedResources
    
    TT_CS_PlotFull<localizes>:message = "The HUD that pops up when the Plot is full"
    @editable{ToolTip := TT_CS_PlotFull} PlotIsFullHUD : hud_message_device = hud_message_device{}


    JoinPlotTrigger(MAgent : ?agent) : void =
        if (Agent := MAgent?):
            JoinPlot(Agent)

    # Joins the plot if not apart of the plot already
    JoinPlot(Agent : agent) : void =
        if (EnableCoopTycoon = true):
            if (PlotManager.PlotsPlayer.Length < MaxAmountOfPlayers):
                if (IsPlayerInPlot(Agent) = false):
                    # JOIN
                    PlotManager.AddPlayerToPlot(Agent)
                else:
                    #Print("ALREADY JOINED PLOT!")
            else:
                # Plot is full
                PlotIsFullHUD.Show(Agent)
        else:
            #Print("CO-OP TYCOON IS DISABLED!")

    EnableDisablePlotJoinTrig()<suspends> : void =
        loop:
            DisablePlotJoiningTrigger.TriggeredEvent.Await()
            JoinPlotDevices.ActivateMutatorZone.Disable()
            JoinPlotDevices.ActivateTrigger.Disable()
            JoinPlotDevices.ActivateButton.Disable()
            if(JoinPlotDevices.ActivateVolume.TeleportTo[vector3{Z:=JoinPlotDevices.ActivateVolume.GetTransform().Translation.Z - 100.0},JoinPlotDevices.ActivateVolume.GetTransform().Rotation]){}
            DisablePlotJoiningTrigger.TriggeredEvent.Await()
            JoinPlotDevices.ActivateMutatorZone.Enable()
            JoinPlotDevices.ActivateTrigger.Enable()
            JoinPlotDevices.ActivateButton.Enable()
            if(JoinPlotDevices.ActivateVolume.TeleportTo[vector3{Z:=JoinPlotDevices.ActivateVolume.GetTransform().Translation.Z + 100.0},JoinPlotDevices.ActivateVolume.GetTransform().Rotation]){}
            Sleep(0.1)

    IsPlayerInPlot(Agent : agent)<transacts> : logic =
        for (PMPlayer : PlotManager.PlotsPlayer):
            if (PMPlayer = Agent):
                return true

        return false


#Overall settings that hold other settings
JoinPlotUISetting := class<concrete>():
    TT_CS_CancelB<localizes>:message = "The position for the Cancel Button"
    TT_CS_AcceptB<localizes>:message = "The position for the Accept Button"
    TT_CS_BgPos<localizes>:message = "The position for the Background image"
    TT_CS_DTPos<localizes>:message = "The position for the Display text"
    TT_CS_DTSet<localizes>:message = "The settings for the Display Text"
    TT_CS_ButtonType<localizes>:message = "The type of button for both the Accept and Cancel"
    TT_CS_DisplayText<localizes>:message = "The display text that appears when joining a plot."
    
    @editable{ToolTip := TT_CS_CancelB} CancelButtonPosition : CanvasPosition = CanvasPosition{}
    @editable{ToolTip := TT_CS_AcceptB} AcceptButtonPosition : CanvasPosition = CanvasPosition{}
    @editable{ToolTip := TT_CS_BgPos} BackgroundPosition : CanvasPosition = CanvasPosition{}
    @editable{ToolTip := TT_CS_DTPos} DisplayTextPosition : CanvasPosition = CanvasPosition{}
    @editable{ToolTip := TT_CS_DTSet} DisplayTextSettings : TextSetting = TextSetting{}
    @editable{ToolTip := TT_CS_ButtonType} ButtonType : UIButtonType = UIButtonType.Loud
    @editable{ToolTip := TT_CS_DisplayText} DisplayText : string = "You already have a plot saved!\nIf you join this plot, you will loose your last plot's progress.\nDo you want to continue?"

#Types of coop resource collection
CooperativeCollectionType := enum:
    SharedResources
    DifferentResources

#Resource that is collected by an ATM
ATMResource := class<concrete>(BaseResource): 
    var TempAmount : float = 0.0
    var Amount : float = 0.0
    @editable AutoCollect : logic = false

    @editable ShowPopUp : logic = false
    @editable EffectedByBoost : logic = true
    @editable OverrideRebirthEffect : ?logic = false
    @editable OverridePopUpSettings : ?PopUpAnimationSetting = false

    @editable Billboard : []billboard_device = array{}

#Settings to control how a plot is loaded
PlotLoadSetting := class<concrete>():
    @editable PlotLoading : LoadingType = LoadingType.Off
    @editable TextImagePosition : CanvasPosition = CanvasPosition{}
    @editable ResetButtonPosition : CanvasPosition = CanvasPosition{}
    @editable LoadButtonPosition : CanvasPosition = CanvasPosition{}
    @editable ButtonType : UIButtonType = UIButtonType.Loud

#Types of plot loading
LoadingType := enum:
    Off
    Auto
    Optional

(InPlayer : Base_Player).HandleAtmResource(RM : Resource_Manager,idx : int , NewRes : ATMResource , Re : GeneralResource) : void=
    if(RP := RM.PlayersMap[InPlayer.Player]):
        var NewAmount : float = NewRes.Amount
        var ShouldRebirthEffect : logic = Re.IsEffectedByRebirths
        if(Override := NewRes.OverrideRebirthEffect?){set ShouldRebirthEffect = Override}
        if(NewRes.AutoCollect?):
            RP.ResourceChange(Amount := Re.ResourceIdleAmount , ReIDX := idx , EffectedResource := Re , CollectType := ResourceCollectType.BaseAmount , ShowPopUp := NewRes.ShowPopUp, NewRes.EffectedByBoost , ShouldRebirthEffect , NewRes.OverridePopUpSettings)
        else:
            RP.ResourceChange(Amount := NewAmount , ReIDX := idx , EffectedResource := Re , CollectType := ResourceCollectType.BaseAmount , ShowPopUp := NewRes.ShowPopUp, NewRes.EffectedByBoost , ShouldRebirthEffect , NewRes.OverridePopUpSettings)

(InPlayer : Base_Player).CollectAtmResources(RM : Resource_Manager, Res : []ATMResource) : void=
    if(RP := RM.PlayersMap[InPlayer.Player]):
        for(idx -> Re : RP.Resources):
            for(NewRes : Res):
                if(Re.ResourceName = NewRes.ResourceName):
                    InPlayer.HandleAtmResource(RM,idx,NewRes,Re)
