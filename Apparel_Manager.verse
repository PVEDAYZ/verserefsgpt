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
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Assets }

#THIS DEVICE IS USED TO PURCHASE AND EQUIP CUSTOM APPAREL/VFX

#Class for the extra apparel UI
ApparelUI := class():
    #Devices
    PersistanceManager : Tycoon_Persistence_Manager = Tycoon_Persistence_Manager{}
    var GameManager : Game_Manager = Game_Manager{}     
    var Position1Trigger : trigger_device = trigger_device{}                                          
    var Position2Trigger : trigger_device = trigger_device{}                                          
    var Position3Trigger : trigger_device = trigger_device{}                                          
    var ApparelCam : gameplay_camera_fixed_point_device = gameplay_camera_fixed_point_device{}       
    var ApparelTP : teleporter_device = teleporter_device{}    

    #Extra Stuff
    var EquipSettings : ApparelEquipSetting = ApparelEquipSetting{}
    var AllApparel : []ApparelBuyable = array{}

    #UI Stuff
    var MainUI : canvas = canvas{}
    var Buttons : UIAllButtons = UIAllButtons{}
    var Slot1Image : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}
    var Slot2Image : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}
    var Slot3Image : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}
    var Position1ButtonLs : UIAllButtons = UIAllButtons{}
    var Position1ButtonRs : UIAllButtons = UIAllButtons{}
    var Position2ButtonLs : UIAllButtons = UIAllButtons{}
    var Position2ButtonRs : UIAllButtons = UIAllButtons{}
    var Position3ButtonLs : UIAllButtons = UIAllButtons{}
    var Position3ButtonRs : UIAllButtons = UIAllButtons{}
    var ExitButton : button_loud = button_loud{}                                                           
    var PostImages : []texture = array{}

    ApparelUIClosedEvent : event() = event(){}


    #Initializes all of the UI buttons
    Initialize() : void=
        Position1ButtonL := Position1ButtonLs.GetButton(EquipSettings.UIPositions.ButtonType)
        Position1ButtonR := Position1ButtonRs.GetButton(EquipSettings.UIPositions.ButtonType)
        Position2ButtonL := Position2ButtonLs.GetButton(EquipSettings.UIPositions.ButtonType)
        Position2ButtonR := Position2ButtonRs.GetButton(EquipSettings.UIPositions.ButtonType)
        Position3ButtonL := Position3ButtonLs.GetButton(EquipSettings.UIPositions.ButtonType)
        Position3ButtonR := Position3ButtonRs.GetButton(EquipSettings.UIPositions.ButtonType)

        Position1ButtonL.SetText(MasterS2M("<"))
        Position1ButtonR.SetText(MasterS2M(">"))
        Position2ButtonL.SetText(MasterS2M("<"))
        Position2ButtonR.SetText(MasterS2M(">"))
        Position3ButtonL.SetText(MasterS2M("<"))
        Position3ButtonR.SetText(MasterS2M(">"))

        ExitButton.SetText(MasterS2M("Exit"))
        ExitButton.OnClick().Subscribe(HandleExitButton)

        Position1ButtonL.OnClick().Subscribe(LeftPos1)
        Position1ButtonR.OnClick().Subscribe(RightPos1)
        Position2ButtonL.OnClick().Subscribe(LeftPos2)
        Position2ButtonR.OnClick().Subscribe(RightPos2)
        Position3ButtonL.OnClick().Subscribe(LeftPos3)
        Position3ButtonR.OnClick().Subscribe(RightPos3)

        set MainUI = CreateUI()

    #Opens the ui for the player, activates the necessary devices, and updates UI values
    OpenUI(Agent:agent)<suspends> : void=
        if(Player := player[Agent],FC := Agent.GetFortCharacter[], PlayerUI := GetPlayerUI[Player], CP := Custom_Player[GameManager.PlayersMap[Agent]]):
            ApparelTP.Teleport(Agent)               
            Sleep(0.1)
            FC.PutInStasis(stasis_args{})           
            ApparelCam.AddTo(Agent)                 
            CP.MyUI.SetVisibility(widget_visibility.Hidden)
            MainUI.SetVisibility(widget_visibility.Visible)
            PlayerUI.AddWidget(MainUI, player_ui_slot{InputMode := ui_input_mode.All})
            ScrollThrough(Player,0,false)
            spawn{ElimTrackApparelUI(Player)}

    ElimTrackApparelUI(Agent:agent)<suspends> : void=
        if(Player := player[Agent],FC := Agent.GetFortCharacter[], PlayerUI := GetPlayerUI[Player], CP := Custom_Player[GameManager.PlayersMap[Agent]]):
            race:
                FC.EliminatedEvent().Await()
                ApparelUIClosedEvent.Await()
            MainUI.SetVisibility(widget_visibility.Hidden)
            PlayerUI.RemoveWidget(MainUI)
            CP.MyUI.SetVisibility(widget_visibility.Visible)
            ApparelCam.RemoveFrom(Player)
            FC.ReleaseFromStasis()


    #Assembles the UI
    CreateUI() : canvas=
        Position1ButtonL := Position1ButtonLs.GetButton(EquipSettings.UIPositions.ButtonType)
        Position1ButtonR := Position1ButtonRs.GetButton(EquipSettings.UIPositions.ButtonType)
        Position2ButtonL := Position2ButtonLs.GetButton(EquipSettings.UIPositions.ButtonType)
        Position2ButtonR := Position2ButtonRs.GetButton(EquipSettings.UIPositions.ButtonType)
        Position3ButtonL := Position3ButtonLs.GetButton(EquipSettings.UIPositions.ButtonType)
        Position3ButtonR := Position3ButtonRs.GetButton(EquipSettings.UIPositions.ButtonType)
        NewUnlockUI : canvas = canvas:
            Slots := array:
                EquipSettings.UIPositions.ExitButton.MakeCanvasSlot(ExitButton , false)
                EquipSettings.UIPositions.Slot1LeftButton.MakeCanvasSlot(Position1ButtonL , false)
                EquipSettings.UIPositions.Slot2LeftButton.MakeCanvasSlot(Position2ButtonL , false)
                EquipSettings.UIPositions.Slot3LeftButton.MakeCanvasSlot(Position3ButtonL , false)

                EquipSettings.UIPositions.Slot1RightButton.MakeCanvasSlot(Position1ButtonR , false)
                EquipSettings.UIPositions.Slot2RightButton.MakeCanvasSlot(Position2ButtonR , false)
                EquipSettings.UIPositions.Slot3RightButton.MakeCanvasSlot(Position3ButtonR , false)

        if(EquipSettings.ImageSettings.Enabled?):
            NewUnlockUI.AddWidget(EquipSettings.ImageSettings.Slot1ImagePosition.MakeCanvasSlot(Slot1Image,false))
            NewUnlockUI.AddWidget(EquipSettings.ImageSettings.Slot2ImagePosition.MakeCanvasSlot(Slot2Image,false))
            NewUnlockUI.AddWidget(EquipSettings.ImageSettings.Slot3ImagePosition.MakeCanvasSlot(Slot3Image,false))

        return NewUnlockUI

    #Different handler functions for different buttons
    LeftPos1(Message : widget_message) : void =
        if (Player:= Message.Player, CP := GameManager.PlayersMap[Player]):
            ScrollThrough(Player,1,true)
    LeftPos2(Message : widget_message) : void =
        if (Player:= Message.Player, CP := GameManager.PlayersMap[Player]):
            ScrollThrough(Player,2,true)
    LeftPos3(Message : widget_message) : void =
        if (Player:= Message.Player, CP := GameManager.PlayersMap[Player]):
            ScrollThrough(Player,3,true)
    RightPos1(Message : widget_message) : void =
        if (Player:= Message.Player, CP := GameManager.PlayersMap[Player]):
            ScrollThrough(Player,1,false)
    RightPos2(Message : widget_message) : void =
        if (Player:= Message.Player, CP := GameManager.PlayersMap[Player]):
            ScrollThrough(Player,2,false)
    RightPos3(Message : widget_message) : void =
        if (Player:= Message.Player, CP := GameManager.PlayersMap[Player]):
            ScrollThrough(Player,3,false)
            
    #Function to scroll through apparel for different positions
    ScrollThrough(Player : player, Pos : int , IsLeft : logic) : void=
        if (CP := Custom_Player[GameManager.PlayersMap[Player]]):
            #Sorts apparels into different arrays of owned apparels for different slots
            var OwnedSlot1 : []int = array{}
            var OwnedSlot2 : []int = array{}
            var OwnedSlot3 : []int = array{}
            for(idx -> OwnedApp : CP.BoughtApparels):                  
                for(App : AllApparel):                                 
                    if(OwnedApp = App.IDX):                     
                        if(App.BodySlot = bodyslot.Slot1):                        
                            set OwnedSlot1 += array{App.IDX}
                        if(App.BodySlot = bodyslot.Slot2):
                            set OwnedSlot2 += array{App.IDX}
                        if(App.BodySlot = bodyslot.Slot3):
                            set OwnedSlot3 += array{App.IDX}

            #Unequips current apparels
            if(ToEquip1 := CP.EquippedApparels[0]):
                for(App : AllApparel):
                    if(App.IDX = ToEquip1){App.RemoveBonuses(Player)}
            if(ToEquip2 := CP.EquippedApparels[1]):
                for(App : AllApparel):
                    if(App.IDX = ToEquip2){App.RemoveBonuses(Player)}
            if(ToEquip3 := CP.EquippedApparels[2]):
                for(App : AllApparel):
                    if(App.IDX = ToEquip3){App.RemoveBonuses(Player) }
                        
            #Gets the length for the amount of owned apparels in different slots
            AmountofSlot1 := OwnedSlot1.Length
            AmountofSlot2 := OwnedSlot2.Length
            AmountofSlot3 := OwnedSlot3.Length

            #Makes and updates the current position in owned apparels of the current equipped apparel in that slot
            var SlotPosition1 : int = 0
            var SlotPosition2 : int = 0
            var SlotPosition3 : int = 0
            if(NewSlotPosition := OwnedSlot1.Find[CP.EquippedApparels[0]]) {set SlotPosition1 = NewSlotPosition + 1}
            if(NewSlotPosition := OwnedSlot2.Find[CP.EquippedApparels[1]]) {set SlotPosition2 = NewSlotPosition + 1}
            if(NewSlotPosition := OwnedSlot3.Find[CP.EquippedApparels[2]]) {set SlotPosition3 = NewSlotPosition + 1}

            #Handles the change of the currently equipped apparels
            if(IsLeft?):
                if(Pos = 1):
                    if(SlotPosition1 - 1 = 0):
                        if(set CP.EquippedApparels[0] = 0){}
                    else if(SlotPosition1 - 1 < 0):
                        if(NewSlot := OwnedSlot1[AmountofSlot1 - 1], set CP.EquippedApparels[0] = NewSlot){}
                    else:
                        if(NewSlot := OwnedSlot1[SlotPosition1 - 2], set CP.EquippedApparels[0] = NewSlot){}
        
                else if(Pos = 2):
                    if(SlotPosition2 - 1 = 0):
                        if(set CP.EquippedApparels[1] = 0){}
                    else if(SlotPosition2 - 1 < 0):
                        if(NewSlot := OwnedSlot2[AmountofSlot2 - 1], set CP.EquippedApparels[1] = NewSlot){}
                    else:
                        if(NewSlot := OwnedSlot2[SlotPosition2 - 2], set CP.EquippedApparels[1] = NewSlot){}

                else if(Pos = 3):
                    if(SlotPosition3 - 1 = 0):
                        if(set CP.EquippedApparels[2] = 0){}
                    else if(SlotPosition3 - 1 < 0):
                        if(NewSlot := OwnedSlot3[AmountofSlot3 - 1], set CP.EquippedApparels[2] = NewSlot){}
                    else:
                        if(NewSlot := OwnedSlot3[SlotPosition3 - 2], set CP.EquippedApparels[2] = NewSlot){}
            else:
                if(Pos = 1):
                    if(SlotPosition1 + 1 > AmountofSlot1):
                        if(set CP.EquippedApparels[0] = 0){}
                    else:
                        if(NewSlot := OwnedSlot1[SlotPosition1], set CP.EquippedApparels[0] = NewSlot){}
                else if(Pos = 2):
                    if(SlotPosition2 + 1 > AmountofSlot2):
                        if(set CP.EquippedApparels[1] = 0){}
                    else:
                        if(NewSlot := OwnedSlot2[SlotPosition2], set CP.EquippedApparels[1] = NewSlot){}
                else if(Pos = 3):                    
                    if(SlotPosition3 + 1 > AmountofSlot3):
                        if(set CP.EquippedApparels[2] = 0){}
                    else:
                        if(NewSlot := OwnedSlot3[SlotPosition3], set CP.EquippedApparels[2] = NewSlot){}
    
            ApparelCheck(Player,OwnedSlot1,OwnedSlot2,OwnedSlot3)

    #Handles the changing of the images that are currently shown for each of the equipped apparel
    HandleImageChange(App : ApparelBuyable,SlotNum : int) : void=
        if(EquipSettings.ImageSettings.Enabled?):
            if(SlotNum = 1):
                if(CurImage := PostImages[App.IDX - 1]):
                    Slot1Image.SetImage(CurImage)
                    Slot1Image.SetVisibility(widget_visibility.Visible)

            else if(SlotNum = 2):
                if(CurImage := PostImages[App.IDX - 1]):
                    Slot2Image.SetImage(CurImage)
                    Slot2Image.SetVisibility(widget_visibility.Visible)

            else if(SlotNum = 3):
                if(CurImage := PostImages[App.IDX - 1]):
                    Slot3Image.SetImage(CurImage)
                    Slot3Image.SetVisibility(widget_visibility.Visible)


    #Function to check which apparel is equipped and equip sit 
    ApparelCheck(Player:player, Owned1 : []int ,Owned2 : []int,Owned3 : []int) : void=
        #Unequips all apparel vfxs and resets current equipped apparels
        Position1Trigger.Trigger(Player)
        Position2Trigger.Trigger(Player)
        Position3Trigger.Trigger(Player)
        PersistanceManager.ResetPlayerArrStat(Player, StatType.EquippedApparels)

        #Hides images of equipped apparel if enabled
        if(EquipSettings.ImageSettings.Enabled?):
            Slot1Image.SetVisibility(widget_visibility.Hidden)
            Slot2Image.SetVisibility(widget_visibility.Hidden)
            Slot3Image.SetVisibility(widget_visibility.Hidden)

        #Finds the apparel that is equipped and equips it
        if(CP :=  Custom_Player[GameManager.PlayersMap[Player]]):
            if(EquipNum := CP.EquippedApparels[0]):
                for(App : AllApparel):
                    if(App.IDX = EquipNum): 
                        HandleImageChange(App, 1)
                        for(V : App.VFXs):
                            V.Pickup(Player)
                            App.GiveBonuses(Player)
                        PersistanceManager.ReplacePlayerArrStat(Player, StatType.EquippedApparels, ?ReplaceInt := 0, ?Score := App.IDX)

            if(EquipNum := CP.EquippedApparels[1]):
                for(App : AllApparel):
                    if(App.IDX = EquipNum):
                        HandleImageChange(App, 2)
                        for(V : App.VFXs):
                            V.Pickup(Player)
                            App.GiveBonuses(Player)
        
                        PersistanceManager.ReplacePlayerArrStat(Player, StatType.EquippedApparels, ?ReplaceInt := 1, ?Score := App.IDX)

            if(EquipNum := CP.EquippedApparels[2]):
                for(App : AllApparel):
                    if(App.IDX = EquipNum):
                        HandleImageChange(App, 3)
                        for(V : App.VFXs):
                            V.Pickup(Player)
                            App.GiveBonuses(Player)
                        PersistanceManager.ReplacePlayerArrStat(Player, StatType.EquippedApparels, ?ReplaceInt := 2, ?Score := App.IDX)

    #Closes the UI when exited
    HandleExitButton(Message : widget_message) : void=
        if (PlayerUI := GetPlayerUI[Message.Player],FC:=Message.Player.GetFortCharacter[],CP := GameManager.PlayersMap[Message.Player]):
            ApparelUIClosedEvent.Signal()

            

#Main creaative device class
Apparel_Manager := class(creative_device):
    #Devices
    PersistanceManager : Tycoon_Persistence_Manager = Tycoon_Persistence_Manager{}
    TT_APM_Device_GameManager<localizes>:message = "Your Game Manager Device"
    @editable{ToolTip := TT_APM_Device_GameManager} GameManager : Game_Manager = Game_Manager{}     

    TT_APM_Device_ResourceManager<localizes>:message = "Your Resource Manager Device"
    @editable{ToolTip := TT_APM_Device_ResourceManager} ResourceManager : Resource_Manager = Resource_Manager{}
    
    TT_APM_Device_PurchaseXP<localizes>:message = "The accolades device which is used to award the player xp for purchasing an apparel"
    @editable{ToolTip := TT_APM_Device_PurchaseXP} PurchaseXP : accolades_device = accolades_device{}

    TT_APM_Device_PurchaseSuccessSound<localizes>:message = "An audio player device which plays a sound when a player purchases an apparel\n*Required Settings*\n Can be heard by : Instigator Only\n Play Location : Instigating Player"
    @editable{ToolTip := TT_APM_Device_PurchaseSuccessSound} PurchaseSuccessSound : audio_player_device = audio_player_device{}

    TT_APM_Device_PurchaseFailureSound<localizes>:message = "An audio player device which plays a sound when a player fails to purchase an apparel\n*Required Settings*\n Can be heard by : Instigator Only\n Play Location : Instigating Player"
    @editable{ToolTip := TT_APM_Device_PurchaseFailureSound} PurchaseFailureSound : audio_player_device = audio_player_device{}

    TT_APM_Device_PurchaseFailMSG<localizes>:message = "A hud message device which displays a message when a player fails to purchase an apparel\n*Required Settings*\nMessage Recipient : Triggering Player"
    @editable{ToolTip := TT_APM_Device_PurchaseFailMSG} PurchaseFailMSG : hud_message_device = hud_message_device{}     
    
    TT_APM_Device_AlreadyHaveMSG<localizes>:message = "A hud message device which displays a message when a player already has an apparel\n*Required Settings*\nMessage Recipient : Triggering Player"
    @editable{ToolTip := TT_APM_Device_AlreadyHaveMSG} AlreadyHaveMSG : hud_message_device = hud_message_device{}  
    
    TT_APM_Device_SuccessMSG<localizes>:message = "A hud message device which displays a message when a player successfully purchases an apparel\n*Required Settings*\nMessage Recipient : Triggering Player"
    @editable{ToolTip := TT_APM_Device_SuccessMSG} SuccessMSG : hud_message_device = hud_message_device{}       

    #Settings
    TT_APM_Device_AllApparel<localizes>:message = "An array of all the apparels that can be purchased"
    @editable{ToolTip := TT_APM_Device_AllApparel} AllApparel : []ApparelBuyable = array{}

    TT_APM_Device_AdditionalEquipSettings<localizes>:message = "The settings for the additional apparel equip menu"
    @editable{ToolTip := TT_APM_Device_AdditionalEquipSettings} AdditionalEquipSettings : ApparelEquipSetting = ApparelEquipSetting{}

    TT_APM_Device_ShopSettings<localizes>:message = "The settings for the apparel shop"
    @editable{ToolTip := TT_APM_Device_ShopSettings} ShopSettings : ShopSetting = ShopSetting{}

    TT_RBM_Device_AddedPlayerTrigger<localizes>:message = "A trigger device that get triggered when a player is added to the plot"
    @editable{ToolTip := TT_RBM_Device_AddedPlayerTrigger} PlayerAddedToPlotTrigger : trigger_device = trigger_device{}

    #Map of all players info
    var PlayersApparelMap : [player]PlayerApparel = map{}      

    #IMAGES
    #==================================================================================================================================================================
    var EquipPostImages : []texture = array{}
    var EquipPreImages : []texture = array{}
    var ShopPostImages : []texture = array{}
    var ShopPreImages : []texture = array{}
    var EquipBackgroundImage : texture = MasterAssets.Placeholder
    var ShopBackgroundImage : texture = MasterAssets.Placeholder
    #==================================================================================================================================================================
   
    #Sets up all events and calls initialize functions
    OnBegin<override>()<suspends>:void=
        if(OpenEquipTrigger := trigger_device[ShopSettings.EquipSettings.UseUI.UseDifferentOpenTrigger?], ShopSettings.EquipSettings.UseUI.Enabled?){OpenEquipTrigger.TriggeredEvent.Subscribe(OpenApparelEquipUI)}   
        AdditionalEquipSettings.OpenApparelTrigger.TriggeredEvent.Subscribe(OpenApparelCloset)          
        if(ShopSettings.ShopType = shoptype.UI){ShopSettings.ShopUIOptions.OpenShopUITrigger.TriggeredEvent.Subscribe(OpenApparelShop)}
        InitializeApparels()    

        #Calls a function to add apparels when a player joins the game again
        GetPlayspace().PlayerRemovedEvent().Subscribe(RemoveFromApparelMap)
        PlayerAddedToPlotTrigger.TriggeredEvent.Subscribe(AddApparelsOnStart1)
        #for(Player : GetPlayspace().GetPlayers()){AddApparelsOnStart1(Player)}
        #GetPlayspace().PlayerAddedEvent().Subscribe(AddApparelsOnStart1)

    #Removes the player from the map whenever they leave the session
    RemoveFromApparelMap(Agent:agent) : void=
        if(Player := player[Agent],Exists := PlayersApparelMap[Player]):
            if(NewMap := PlayersApparelMap.WithRemovedKey(Player)?):
                set PlayersApparelMap = NewMap
            
    #Initializes all of the apparels
    InitializeApparels() : void=
        for(idx -> App : AllApparel):                
            set App.IDX = idx + 1
            set App.ShopSettings = ShopSettings
            set App.GameManager = GameManager
            set App.ResourceManager = ResourceManager
            set App.PurchaseXP = PurchaseXP
            set App.PurchaseSuccessSound = PurchaseSuccessSound
            set App.PurchaseFailureSound = PurchaseFailureSound
            set App.PurchaseFailMSG = PurchaseFailMSG         
            set App.AlreadyHaveMSG = AlreadyHaveMSG         
            set App.SuccessMSG = SuccessMSG
            set App.Position1Trigger = AdditionalEquipSettings.Position1Trigger
            set App.Position2Trigger = AdditionalEquipSettings.Position2Trigger
            set App.Position3Trigger = AdditionalEquipSettings.Position3Trigger
            set App.ShopPostImages = ShopPostImages
            set App.ShopPreImages = ShopPreImages
            set App.EquipPreImages = EquipPreImages
            set App.EquipPostImages = EquipPostImages
            App.MainTrigger.TriggeredEvent.Subscribe(App.PurchaseForTrigger)

    #Opens the apparel equip menu based from the extra equip settings
    OpenApparelCloset(MAgent:?agent) : void=
        if(Agent := MAgent?):
            NewApparelUI := ApparelUI{
                GameManager := GameManager
                AllApparel := AllApparel
                Position1Trigger := AdditionalEquipSettings.Position1Trigger
                Position2Trigger := AdditionalEquipSettings.Position2Trigger
                Position3Trigger := AdditionalEquipSettings.Position3Trigger
                ApparelCam := AdditionalEquipSettings.ApparelCam
                ApparelTP := AdditionalEquipSettings.ApparelTP
                EquipSettings := AdditionalEquipSettings
                PostImages := EquipPostImages
                }
            NewApparelUI.Initialize()
            spawn{NewApparelUI.OpenUI(Agent)}

    #Opens the apparel equip menu based from shop settings
    OpenApparelEquipUI(MAgent:?agent) : void=    
        if(Agent := MAgent?):
            NewUI := BuyableUI:
                GameManager := GameManager  
                ResourceManager := ResourceManager
                ShopSettings := ShopSettings
                Buyables := GetNewApparels()
                EquipBackgroundImage := EquipBackgroundImage
                ShopBackgroundImage := ShopBackgroundImage

            NewUI.Initialize(Agent)
            NewUI.AddEquipUI(Agent)

    #Opens the apparel shop menu from the shop settings
    OpenApparelShop(MAgent:?agent) : void=
        if(Agent := MAgent?):
            NewShopUI := BuyableUI{
                GameManager := GameManager
                ResourceManager := ResourceManager
                Buyables := GetNewApparels()
                ShopSettings := ShopSettings
                EquipBackgroundImage := EquipBackgroundImage
                ShopBackgroundImage := ShopBackgroundImage
            }
            NewShopUI.Initialize(Agent)
            NewShopUI.AddShopUI(Agent)

    #Prefunction for AddApparelsOnStart
    AddApparelsOnStart1(MaybeAgent:?agent) : void=
        if (Agent := MaybeAgent?):
            InitializePlayerPets(Agent)
        
    #Adds the players currently equipped apparels
    AddApparelsOnStart(Agent:agent)<suspends> : void=
        Sleep(1.0)
        Print("ADDIN PPA")
        if (CP := Custom_Player[GameManager.PlayersMap[Agent]], AM := PlayersApparelMap[Agent]):
            if(EquipNum := CP.EquippedApparels[0]):
                for(App : AllApparel):
                    if(App.IDX = EquipNum): 
                        for(V : App.VFXs):
                            V.Pickup(Agent)
                        App.GiveBonuses(Agent)
            if(EquipNum := CP.EquippedApparels[1]):
                for(App : AllApparel):
                    if(App.IDX = EquipNum):
                        for(V : App.VFXs):
                            V.Pickup(Agent)
                        App.GiveBonuses(Agent)
            if(EquipNum := CP.EquippedApparels[2]):
                for(App : AllApparel):
                    if(App.IDX = EquipNum):
                        for(V : App.VFXs):
                            V.Pickup(Agent)
                        App.GiveBonuses(Agent)

    #Initializes pets for a player
    InitializePlayerPets(Agent:agent) : void=
        if(Player := player[Agent]):    
            if(PlayerExists := PlayersApparelMap[Player]):      
            else:
                if(set PlayersApparelMap[Player] = PlayerApparel{        
                    Player := Player
                    }){}
                spawn{AddApparelsOnStart(Agent)}

    #Returns a duplicate copy of apparels, except with new buttons
    GetNewApparels() : []ApparelBuyable=
        var NewApparels : []ApparelBuyable = array{}
        for(A : AllApparel):
            set NewApparels += array{ApparelBuyable{
                PersistanceManager := A.PersistanceManager
                GameManager := A.GameManager
                ResourceManager := A.ResourceManager
                IDX := A.IDX
                CurBuyableUI := A.CurBuyableUI
                ShopSettings := A.ShopSettings
                ShopButtons := UIAllButtons{}
                ShopPreImages := A.ShopPreImages
                ShopPostImages := A.ShopPostImages
                EquipPreImages := A.EquipPreImages
                EquipPostImages := A.EquipPostImages
                EquipButtons := UIAllButtons{}
                EquipPreImage := A.EquipPreImage
                EquipPostImage := A.EquipPostImage
                PurchaseXP := A.PurchaseXP
                PurchaseSuccessSound := A.PurchaseSuccessSound
                PurchaseFailureSound := A.PurchaseFailureSound
                PurchaseFailMSG := A.PurchaseFailMSG
                AlreadyHaveMSG := A.AlreadyHaveMSG
                SuccessMSG := A.SuccessMSG
                MustPurchaseFirstMSG := A.MustPurchaseFirstMSG
                MainTrigger := A.MainTrigger
                CostResources := A.CostResources
                BoostResources := A.BoostResources
                EquippedTrigger := A.EquippedTrigger
                UnEquippedTrigger := A.UnEquippedTrigger
                IsEquipped := false
                BodySlot := A.BodySlot
                VFXs := A.VFXs
                Position1Trigger := A.Position1Trigger
                Position2Trigger := A.Position2Trigger
                Position3Trigger := A.Position3Trigger

            }}
        return NewApparels
       

#Class inherited from main Buyable class that is specific to apparels
ApparelBuyable := class<concrete>(Buyable):
    var ApparelManager : Apparel_Manager = Apparel_Manager{}
    #Body slot and VFXs
    TT_APM_ApparelBuyable_BodySlot<localizes>:message = "The body slot that this apparel is equipped to. Used for the custom Equip UI"
    @editable{ToolTip := TT_APM_ApparelBuyable_BodySlot} BodySlot : bodyslot = bodyslot.Slot1       
    
    TT_APM_ApparelBuyable_VFXs<localizes>:message = "The VFX power up device that is used to display the apparel\'s VFX"
    @editable{ToolTip := TT_APM_ApparelBuyable_VFXs} VFXs : []visual_effect_powerup_device = array{}                                

    #Clear triggers
    var Position1Trigger : trigger_device = trigger_device{}                                         
    var Position2Trigger : trigger_device = trigger_device{}                                        
    var Position3Trigger : trigger_device = trigger_device{}                                       

    #Equips this apparel
    EquipApparel(Agent:agent) : void=
        if(CP := Custom_Player[GameManager.PlayersMap[Agent]]):
            for(V : VFXs):
                V.Pickup(Agent)
            if(BodySlot = bodyslot.Slot1):
                if(set CP.EquippedApparels[0] = IDX){}
                if(PlayersApparel := ApparelManager.PlayersApparelMap[Agent], set PlayersApparel.Apparel[0] = IDX){}
                PersistanceManager.ReplacePlayerArrStat(Agent, StatType.EquippedApparels, ?ReplaceInt := 0, ?Score := IDX)

            if(BodySlot = bodyslot.Slot2):
                if(set CP.EquippedApparels[1] = IDX){}
                if(PlayersApparel := ApparelManager.PlayersApparelMap[Agent], set PlayersApparel.Apparel[1] = IDX){}
                PersistanceManager.ReplacePlayerArrStat(Agent, StatType.EquippedApparels, ?ReplaceInt := 1, ?Score := IDX)

            if(BodySlot = bodyslot.Slot3):
                if(set CP.EquippedApparels[2] = IDX){}
                if(PlayersApparel := ApparelManager.PlayersApparelMap[Agent], set PlayersApparel.Apparel[2] = IDX){}
                PersistanceManager.ReplacePlayerArrStat(Agent, StatType.EquippedApparels, ?ReplaceInt := 2, ?Score := IDX)
        
    #Unequips this apparel
    UnEquipApparel(Agent:agent) : void=
        if(CP := Custom_Player[GameManager.PlayersMap[Agent]]):
            if(BodySlot = bodyslot.Slot1):
                if(set CP.EquippedApparels[0] = 0){}
                if(PlayersApparel := ApparelManager.PlayersApparelMap[Agent], set PlayersApparel.Apparel[0] = 0){}
                PersistanceManager.ReplacePlayerArrStat(Agent, StatType.EquippedApparels, ?ReplaceInt := 0, ?Score := 0)
                Position1Trigger.Trigger(Agent)

            if(BodySlot = bodyslot.Slot2):
                if(set CP.EquippedApparels[1] = 0){}
                if(PlayersApparel := ApparelManager.PlayersApparelMap[Agent], set PlayersApparel.Apparel[1] = 0){}
                PersistanceManager.ReplacePlayerArrStat(Agent, StatType.EquippedApparels, ?ReplaceInt := 1, ?Score := 0)
                Position2Trigger.Trigger(Agent)

            if(BodySlot = bodyslot.Slot3):
                if(set CP.EquippedApparels[2] = 0){}
                if(PlayersApparel := ApparelManager.PlayersApparelMap[Agent], set PlayersApparel.Apparel[1] = 0){}
                PersistanceManager.ReplacePlayerArrStat(Agent, StatType.EquippedApparels, ?ReplaceInt := 2, ?Score := 0)
                Position3Trigger.Trigger(Agent)

#Different apparel equip settings for the extra UI
ApparelEquipSetting := class<concrete>():
    #Devices
    TT_APM_ApparelEquipSetting_OpenApparelTrigger<localizes>:message = "A trigger device which opens the apparel equip menu"
    @editable{ToolTip := TT_APM_ApparelEquipSetting_OpenApparelTrigger} OpenApparelTrigger : trigger_device = trigger_device{}     
    
    TT_APM_ApparelEquipSetting_ApparelCam<localizes>:message = "A gameplay camera device which is used to display the player when they open the apparel equip menu"
    @editable{ToolTip := TT_APM_ApparelEquipSetting_ApparelCam} ApparelCam : gameplay_camera_fixed_point_device = gameplay_camera_fixed_point_device{}    
    
    TT_APM_ApparelEquipSetting_ApparelTP<localizes>:message = "A teleporter device which teleports the player infront of where the camera is\n*Required Settings*\nTeleporter Group: None\nTeleporter Target Group: None"
    @editable{ToolTip := TT_APM_ApparelEquipSetting_ApparelTP} ApparelTP : teleporter_device = teleporter_device{}      
         
    TT_APM_PositionTrigger<localizes>:message = "Trigger Device used to clear vfxs\n*Required Settings*\nSet all VFXs in the corresponding position to clear from this trigger's triggered event"
    @editable{ToolTip := TT_APM_PositionTrigger} Position1Trigger : trigger_device = trigger_device{}                                          
    @editable{ToolTip := TT_APM_PositionTrigger} Position2Trigger : trigger_device = trigger_device{}                                         
    @editable{ToolTip := TT_APM_PositionTrigger} Position3Trigger : trigger_device = trigger_device{}         
    
    #Settings
    @editable UIPositions : ApparelUIPositions = ApparelUIPositions{}
    @editable ImageSettings : ImageSetting = ImageSetting{}

#Different settings for the images on the extra apparel UI
ImageSetting := class<concrete>():  
    @editable Enabled : logic = false
    @editable Slot1ImagePosition : CanvasPosition = CanvasPosition{}
    @editable Slot2ImagePosition : CanvasPosition = CanvasPosition{}
    @editable Slot3ImagePosition : CanvasPosition = CanvasPosition{}

#Different UI positions for the extra apparel UI
ApparelUIPositions := class<concrete>():
    @editable ButtonType : UIButtonType = UIButtonType.Loud
    @editable ExitButton : CanvasPosition = CanvasPosition{}

    @editable Slot1LeftButton : CanvasPosition = CanvasPosition{}
    @editable Slot1RightButton : CanvasPosition = CanvasPosition{}
    @editable Slot2LeftButton : CanvasPosition = CanvasPosition{}
    @editable Slot2RightButton : CanvasPosition = CanvasPosition{}
    @editable Slot3LeftButton : CanvasPosition = CanvasPosition{}
    @editable Slot3RightButton : CanvasPosition = CanvasPosition{}

#Different possible slots for each apparel
bodyslot := enum:
    Slot1
    Slot2
    Slot3

#Class to hold each players pets
PlayerApparel := class():
    Player : player
    var Apparel : []int = array{0,0,0}