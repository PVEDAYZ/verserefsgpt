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
using { /Verse.org/Simulation }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors }
using { /Verse.org/Assets }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Random }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }

#THIS SCRIPT IS USED TO HOLD DIFFERENT CLASSES THAT ARE SHARED BY MULTIPLE DEVICES

#Device Combinations =============================================================================================================================================================

#Different devices that are used to activate a button
ActivateDevice := class<concrete>():
    TT_AD_ActivateMutatorZone<localizes>:message = "A mutator zone device that activates a tycoon button\n*Required Settings*\nActivating Team : The team which this button\'s plot is for (for Plot Claim buttons, it should be n+1, where n is the total number of plots in your game)\nVisible In Game : false"
    @editable{ToolTip := TT_AD_ActivateMutatorZone} ActivateMutatorZone: mutator_zone_device = mutator_zone_device{}
    
    TT_AD_ActivateTrigger<localizes>:message = "A trigger device that activates a tycoon button\n*Required Settings*\nActivating Team : The team which this button\'s plot is for (for Plot Claim buttons, it should be n+1, where n is the total number of plots in your game)\nVisible In Game : false"
    @editable{ToolTip := TT_AD_ActivateTrigger} ActivateTrigger: trigger_device = trigger_device{}  

    TT_AD_ActivateButton<localizes>:message = "A button device that activates a tycoon button\n*Required Settings*\nActivating Team : The team which this button\'s plot is for (for Plot Claim buttons, it should be n+1, where n is the total number of plots in your game)\nVisible In Game : false"
    @editable{ToolTip := TT_AD_ActivateButton} ActivateButton: button_device = button_device{}  

    TT_AD_ActivateVolume<localizes>:message = "A volume device that activates a tycoon button\n*Required Settings*\nActivating Team : The team which this button\'s plot is for (for Plot Claim buttons, it should be n+1, where n is the total number of plots in your game)\nVisible In Game : false\nMust be parented to corresponding button prop blueprint"
    @editable{ToolTip := TT_AD_ActivateVolume} ActivateVolume : volume_device = volume_device{}

    DisableAll()<suspends> : void=
        ActivateMutatorZone.Disable()
        ActivateTrigger.Disable()
        ActivateButton.Disable()

    EnableAll()<suspends> : void=
        ActivateMutatorZone.Enable()
        ActivateTrigger.Enable()
        ActivateButton.Enable()


#Buyable UI Classes =============================================================================================================================================================

#A collection of different positions that compose of a singular canvas, which is used to make several of the same widget
CombinedSetting := class<concrete>():
    @editable ButtonType : UIButtonType = UIButtonType.Loud
    @editable ImagePosition : CanvasPosition = CanvasPosition{}
    @editable ButtonPosition : CanvasPosition = CanvasPosition{}

#A position with a widget that is used to define multiple slots on a UI
Slot := class<concrete>():
    @editable Position : CanvasPosition = CanvasPosition{}
    var Widget : canvas = canvas{}

#Settings used to control how a buyable is bought
ShopSetting := class<concrete>():
    @editable ShopType : shoptype = shoptype.Triggers
    @editable ShopUIOptions : ShopUIOption = ShopUIOption{}
    @editable EquipSettings : EquipSetting = EquipSetting{}

#Used to control the buyables shop settings if UI is chosen
ShopUIOption := class<concrete>():
    @editable OpenShopUITrigger : trigger_device = trigger_device{}
    @editable ExitButtonPosition : CanvasPosition = CanvasPosition{}
    @editable BackgroundPosition : CanvasPosition = CanvasPosition{}
    @editable CombinedSettings : CombinedSetting = CombinedSetting{} 
    @editable Slots : []Slot = array{}

#Different buyable shop options
shoptype := enum:
    Triggers
    UI

#Settings used to control how a buyable is equipped
EquipSetting := class<concrete>():
    @editable UseTriggers : logic = false
    @editable UseUI : Useui = Useui{}

#Settings that control the equip UI if enabled
Useui := class<concrete>():
    @editable Enabled : logic = false
    @editable SameAsShop : logic = false
    @editable DifferentTabInShop : DifferentTabInshop = DifferentTabInshop{}
    @editable UseDifferentOpenTrigger : ?trigger_device = false
    @editable EquipUIOptions : EquipUIOption = EquipUIOption{}

DifferentTabInshop := class<concrete>():
    @editable Enabled : logic = false
    @editable SwitchToEquipButtonPos : CanvasPosition = CanvasPosition{}
    @editable SwitchToShopButtonPos : CanvasPosition = CanvasPosition{}
    @editable SwitchToEquipButtonText : string = ""
    @editable SwitchToShopButtonText : string = ""

#Used to control the buyables equip settings if UI is chosen
EquipUIOption := class<concrete>():
    @editable CombinedSettings : CombinedSetting = CombinedSetting{}
    @editable ExitButton : CanvasPosition = CanvasPosition{}
    @editable Background : CanvasPosition = CanvasPosition{}
    @editable Slots : []Slot = array{}

#Different buyable equip options
equiptype := enum:
    Buttons
    UI

#Class to create a UI for a buyable
BuyableUI := class():
    #Base stuff
    var GameManager : Game_Manager = Game_Manager{}
    var ResourceManager : Resource_Manager = Resource_Manager{}
    var Buyables : []Buyable = array{}

    #Shop Stuff
    var ShopMainUI : canvas = canvas{}
    var ShopExitButton : button_loud = button_loud{}    
    var ShopBackgroundImage : texture = MasterAssets.Placeholder
    var ShopBackgroundTexture : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}
    var ShopSettings : ShopSetting = ShopSetting{}
    ClosedShopEvent : event() = event(){}

    
    #Equip Stuff
    var EquipMainUI : canvas = canvas{}
    var EquipExitButton : button_loud = button_loud{}    
    var EquipBackgroundImage : texture = MasterAssets.Placeholder
    var EquipBackgroundTexture : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}
    ClosedEquipEvent : event() = event(){}
    

    #Initializes the UI
    Initialize(Agent:agent) : void=
        SetUpShop()
        SetUpEquip()
        UpdateCheckBuyables(Agent)

    #Updates buyables equip status
    UpdateCheckBuyables(Agent : agent) : void=
        for(idx -> B : Buyables):
            if(CP := Custom_Player[GameManager.PlayersMap[Agent]]):
                if(NewBuyable := ApparelBuyable[B]):
                    if(CP.EquippedApparels.Find[NewBuyable.IDX]):
                        set NewBuyable.IsEquipped = true
                    else:
                        set NewBuyable.IsEquipped = false

    #Updates all buyables
    UpdateBuyables(Agent:agent) : void=
        for(idx -> B : Buyables):
            B.ShopCheck(Agent)
            B.EquipCheck(Agent)
            set B.CurBuyableUI = Self

    #Sets up Equip UI
    SetUpEquip() : void=
        EquipExitButton.SetText(MasterS2M("Exit"))
        EquipExitButton.OnClick().Subscribe(HandleEquipExitButton)
        EquipBackgroundTexture.SetImage(EquipBackgroundImage)
        set EquipMainUI = CreateEquipUI()

    #Creates the Equip UI
    CreateEquipUI() : canvas= 
        var NewEquipUI : canvas = canvas{}
        for(idx -> UISlot : ShopSettings.EquipSettings.UseUI.EquipUIOptions.Slots , CurBuyable := Buyables[idx]):
            NewCanvas := CurBuyable.GetEquipCanvas()
            set UISlot.Widget = NewCanvas
        
            NewSlot := UISlot.Position.MakeCanvasSlot(UISlot.Widget,false)
            NewEquipUI.AddWidget(NewSlot)

        NewEquipUI.AddWidget(ShopSettings.EquipSettings.UseUI.EquipUIOptions.Background.MakeCanvasSlot(EquipBackgroundTexture,false))
        NewEquipUI.AddWidget(ShopSettings.EquipSettings.UseUI.EquipUIOptions.ExitButton.MakeCanvasSlot(EquipExitButton,false))

        if(ShopSettings.EquipSettings.UseUI.DifferentTabInShop.Enabled?):
            var SwitchToEquipButton : button_loud = button_loud{}
            var SwitchToShopButton : button_loud = button_loud{}
            SwitchToEquipButton.SetText(MasterS2M(ShopSettings.EquipSettings.UseUI.DifferentTabInShop.SwitchToEquipButtonText))
            SwitchToShopButton.SetText(MasterS2M(ShopSettings.EquipSettings.UseUI.DifferentTabInShop.SwitchToShopButtonText))
            SwitchToEquipButton.OnClick().Subscribe(SwitchToEquip)
            SwitchToShopButton.OnClick().Subscribe(SwitchToShop)
            NewEquipUI.AddWidget(ShopSettings.EquipSettings.UseUI.DifferentTabInShop.SwitchToEquipButtonPos.MakeCanvasSlot(SwitchToEquipButton,false))
            NewEquipUI.AddWidget(ShopSettings.EquipSettings.UseUI.DifferentTabInShop.SwitchToShopButtonPos.MakeCanvasSlot(SwitchToShopButton,false))

        return NewEquipUI

    #Adds the equip UI to the player
    AddEquipUI(Agent:agent) : void=
        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player], CP := Custom_Player[GameManager.PlayersMap[Agent]]):
            CP.MyUI.SetVisibility(widget_visibility.Hidden)   
            EquipMainUI.SetVisibility(widget_visibility.Visible)
            UpdateBuyables(Agent)
            PlayerUI.AddWidget(EquipMainUI, player_ui_slot{InputMode := ui_input_mode.All})
            spawn{TrackElim(Agent)}


    TrackElim(Agent : agent)<suspends> : void=
        if(FC := Agent.GetFortCharacter[]):
            if(Player := player[Agent], PlayerUI := GetPlayerUI[Player], CP := Custom_Player[GameManager.PlayersMap[Agent]]):
                race:
                    FC.EliminatedEvent().Await()
                    ClosedEquipEvent.Await()
                EquipMainUI.SetVisibility(widget_visibility.Hidden)
                PlayerUI.RemoveWidget(EquipMainUI)
                CP.MyUI.SetVisibility(widget_visibility.Visible)

    #Exits the equip ui
    HandleEquipExitButton(Message : widget_message) : void=
        if (PlayerUI := GetPlayerUI[Message.Player],FC:=Message.Player.GetFortCharacter[],CP := GameManager.PlayersMap[Message.Player]):
            ClosedEquipEvent.Signal()



    SwitchToEquip(Message : widget_message) : void=
        Player := Message.Player
        UpdateBuyables(Player)
        if(PlayerUI := GetPlayerUI[Player], CP := Custom_Player[GameManager.PlayersMap[Player]]):
            ClosedShopEvent.Signal()
            EquipMainUI.SetVisibility(widget_visibility.Visible)
            PlayerUI.AddWidget(EquipMainUI, player_ui_slot{InputMode := ui_input_mode.All})
            spawn{TrackElim(Player)}
            CP.MyUI.SetVisibility(widget_visibility.Hidden)

    #Shop Functions

    #Sets up the shop ui
    SetUpShop() : void=
        ShopExitButton.SetText(MasterS2M("Exit"))
        ShopExitButton.OnClick().Subscribe(HandleShopExitButton)
        ShopBackgroundTexture.SetImage(ShopBackgroundImage)
        set ShopMainUI = CreateShopUI()

    #Creates the shop ui
    CreateShopUI() : canvas= 
        var NewShopUI : canvas = canvas{}
        for(idx -> UISlot : ShopSettings.ShopUIOptions.Slots , CurBuyable := Buyables[idx]):
            NewCanvas := CurBuyable.GetShopCanvas()
            set UISlot.Widget = NewCanvas

            NewSlot := UISlot.Position.MakeCanvasSlot(UISlot.Widget,false)
            NewShopUI.AddWidget(NewSlot)

        NewShopUI.AddWidget(ShopSettings.ShopUIOptions.BackgroundPosition.MakeCanvasSlot(ShopBackgroundTexture,false))
        NewShopUI.AddWidget(ShopSettings.ShopUIOptions.ExitButtonPosition.MakeCanvasSlot(ShopExitButton,false))

        var SwitchToEquipButton : button_loud = button_loud{}
        var SwitchToShopButton : button_loud = button_loud{}
        
        if(ShopSettings.EquipSettings.UseUI.DifferentTabInShop.Enabled?):
            SwitchToEquipButton.SetText(MasterS2M(ShopSettings.EquipSettings.UseUI.DifferentTabInShop.SwitchToEquipButtonText))
            SwitchToShopButton.SetText(MasterS2M(ShopSettings.EquipSettings.UseUI.DifferentTabInShop.SwitchToShopButtonText))
            SwitchToEquipButton.OnClick().Subscribe(SwitchToEquip)
            SwitchToShopButton.OnClick().Subscribe(SwitchToShop)
            NewShopUI.AddWidget(ShopSettings.EquipSettings.UseUI.DifferentTabInShop.SwitchToEquipButtonPos.MakeCanvasSlot(SwitchToEquipButton,false))
            NewShopUI.AddWidget(ShopSettings.EquipSettings.UseUI.DifferentTabInShop.SwitchToShopButtonPos.MakeCanvasSlot(SwitchToShopButton,false))

        return NewShopUI

    #Adds the shop ui to a player
    AddShopUI(Agent:agent) : void=
        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player], CP := Custom_Player[GameManager.PlayersMap[Agent]]):
            CP.MyUI.SetVisibility(widget_visibility.Hidden)   
            ShopMainUI.SetVisibility(widget_visibility.Visible)
            UpdateBuyables(Agent)
            PlayerUI.AddWidget(ShopMainUI, player_ui_slot{InputMode := ui_input_mode.All})
            spawn{TrackShopElim(Agent)}

    TrackShopElim(Agent : agent)<suspends> : void=
        if(FC := Agent.GetFortCharacter[]):
            if(Player := player[Agent], PlayerUI := GetPlayerUI[Player], CP := Custom_Player[GameManager.PlayersMap[Agent]]):
                race:
                    FC.EliminatedEvent().Await()
                    ClosedShopEvent.Await()
                ShopMainUI.SetVisibility(widget_visibility.Hidden)
                PlayerUI.RemoveWidget(ShopMainUI)
                CP.MyUI.SetVisibility(widget_visibility.Visible)

    #Exits the shop ui
    HandleShopExitButton(Message : widget_message) : void=
        if (PlayerUI := GetPlayerUI[Message.Player],FC:=Message.Player.GetFortCharacter[],CP := Custom_Player[GameManager.PlayersMap[Message.Player]]):
            ClosedShopEvent.Signal()
    
    SwitchToShop(Message : widget_message) : void=
        Player := Message.Player
        UpdateBuyables(Player)
        if(PlayerUI := GetPlayerUI[Player], CP := Custom_Player[GameManager.PlayersMap[Player]]):
            ClosedEquipEvent.Signal()
            ShopMainUI.SetVisibility(widget_visibility.Visible)
            PlayerUI.AddWidget(ShopMainUI, player_ui_slot{InputMode := ui_input_mode.All})
            spawn{TrackShopElim(Player)}
            CP.MyUI.SetVisibility(widget_visibility.Hidden)
            

        



#Main buyable class which other buyables classes are built from
Buyable := class<concrete>():
    #Base Stuff
    PersistanceManager : Tycoon_Persistence_Manager = Tycoon_Persistence_Manager{}
    var GameManager : Game_Manager = Game_Manager{}
    var ResourceManager : Resource_Manager = Resource_Manager{}
    var IDX : int = 0
    var CurBuyableUI: BuyableUI = BuyableUI{}

    #Shop Stuff
    var ShopSettings : ShopSetting = ShopSetting{}
    var ShopButtons : UIAllButtons = UIAllButtons{}
    var ShopPreImages : []texture = array{}
    var ShopPostImages : []texture = array{}

    #EquipSettings
    var EquipButtons : UIAllButtons = UIAllButtons{}
    var EquipPreImages : []texture = array{}
    var EquipPostImages : []texture = array{}


    var EquipPreImage : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}
    var EquipPostImage : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}

    #Purchase/Failure Devices
    var PurchaseXP : accolades_device = accolades_device{}
    var PurchaseSuccessSound : audio_player_device = audio_player_device{}
    var PurchaseFailureSound : audio_player_device = audio_player_device{}
    var PurchaseFailMSG : hud_message_device = hud_message_device{}                    
    var AlreadyHaveMSG : hud_message_device = hud_message_device{}                  
    var SuccessMSG : hud_message_device = hud_message_device{}   
    var MustPurchaseFirstMSG : hud_message_device = hud_message_device{}

    #Editables
    @editable MainTrigger : trigger_device = trigger_device{}
    @editable CostResources : []SpendableResource = array{}
    @editable BoostResources : []BoostResource = array{}
    @editable EquippedTrigger : trigger_device = trigger_device{}
    @editable UnEquippedTrigger : trigger_device = trigger_device{}

    var IsEquipped : logic = false


    #Equip Stuff ======================================================================================================================================
    #Returns the buyables canvas for the equip UI
    GetEquipCanvas() : canvas=
        var NewEquipPreImage : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}
        var NewEquipPostImage : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}
        var NewEquipCanvas : canvas = canvas{}
      

        EquipButton := EquipButtons.GetButton(ShopSettings.EquipSettings.UseUI.EquipUIOptions.CombinedSettings.ButtonType)
        if(NewPreImage := EquipPreImages[IDX - 1]){NewEquipPreImage.SetImage(NewPreImage)}
        if(NewPostImage := EquipPostImages[IDX - 1]){NewEquipPostImage.SetImage(NewPostImage)}
        EquipButton.OnClick().Subscribe(EquipForWidget)

        set NewEquipCanvas = canvas:
            Slots := array:
                ShopSettings.EquipSettings.UseUI.EquipUIOptions.CombinedSettings.ImagePosition.MakeCanvasSlot(NewEquipPreImage,false)
                ShopSettings.EquipSettings.UseUI.EquipUIOptions.CombinedSettings.ImagePosition.MakeCanvasSlot(NewEquipPostImage,false)
                ShopSettings.EquipSettings.UseUI.EquipUIOptions.CombinedSettings.ButtonPosition.MakeCanvasSlot(EquipButton,false)

        set EquipPreImage = NewEquipPreImage
        set EquipPostImage = NewEquipPostImage

        return NewEquipCanvas


    #Updates the buttons on the equip screen and gives bonuses
    EquipCheck(Agent:agent) : void=
        EquipButton := EquipButtons.GetButton(ShopSettings.EquipSettings.UseUI.EquipUIOptions.CombinedSettings.ButtonType)
        if(CP := Custom_Player[GameManager.PlayersMap[Agent]]):
            #Handles Apparel
            if(NewBuyable := ApparelBuyable[Self]):
                if(CP.BoughtApparels.Find[IDX]):
                    EquipPostImage.SetVisibility(widget_visibility.Visible)
                    EquipPreImage.SetVisibility(widget_visibility.Hidden)
                    if(CP.EquippedApparels.Find[IDX]):
                        EquipButton.SetText(MasterS2M("UnEquip"))
                        if(IsEquipped = false):
                            NewBuyable.GiveBonuses(Agent)
                    else:
                        EquipButton.SetText(MasterS2M("Equip"))
                        if(IsEquipped = true):
                            NewBuyable.RemoveBonuses(Agent)
                else:
                    EquipPostImage.SetVisibility(widget_visibility.Hidden)
                    EquipPreImage.SetVisibility(widget_visibility.Visible)
                    EquipButton.SetText(MasterS2M("???"))

            #Handles Pets
            if(NewBuyable := PetBuyable[Self]):
                if(CP.BoughtPets.Find[IDX]):
                    EquipPostImage.SetVisibility(widget_visibility.Visible)
                    EquipPreImage.SetVisibility(widget_visibility.Hidden)
                    if(CP.EquippedPets.Find[IDX]):
                        EquipButton.SetText(MasterS2M("UnEquip"))
                    else:
                        EquipButton.SetText(MasterS2M("Equip"))
                else:
                    EquipPostImage.SetVisibility(widget_visibility.Hidden)
                    EquipPreImage.SetVisibility(widget_visibility.Visible)
                    EquipButton.SetText(MasterS2M("???"))

    #Calls the Equip function from a widget
    EquipForWidget(Message : widget_message) : void=
        Player := Message.Player
        TryEquip(Player)

    #Tries to equip a buyable
    TryEquip(Player:agent) : void=
        if(CP := Custom_Player[GameManager.PlayersMap[Player]]):
            #PETS
            if(NewBuyable := PetBuyable[Self],CP.BoughtPets.Find[IDX]):
                if(CP.EquippedPets.Find[IDX]):
                    NewBuyable.UnEquipPet(Player)
                    if(NewArray := CP.EquippedPets.RemoveFirstElement[IDX]){set CP.EquippedPets = NewArray}
                    PersistanceManager.RemovePlayerArrStat(Player, StatType.EquippedPets, ?Score := IDX)
                else:
                    if(PetShopSettings := PetShopSetting[ShopSettings] , CP.EquippedPets.Length < PetShopSettings.MaxEquippedAtATime):
                        NewBuyable.EquipPet(Player)
                        set CP.EquippedPets += array{IDX}
                        PersistanceManager.RecordPlayerArrStat(Player, StatType.EquippedPets, ?Score := IDX)
                EquipCheck(Player)

                
            #APPARELS
            if(NewBuyable := ApparelBuyable[Self],CP.BoughtApparels.Find[IDX]):
                CurBuyableUI.UpdateCheckBuyables(Player)
                if(CP.EquippedApparels.Find[IDX]):
                    NewBuyable.UnEquipApparel(Player)
                else:
                    NewBuyable.EquipApparel(Player)
                CurBuyableUI.UpdateBuyables(Player)

    #Gives the buyables bonuses
    GiveBonuses(Agent:agent): void=
        if(RP := ResourceManager.PlayersMap[Agent]):
            RP.Boost(BoostResources)
            EquippedTrigger.Trigger(Agent)

    #Removes the buyables bonuses
    RemoveBonuses(Agent:agent): void=
        if(RP := ResourceManager.PlayersMap[Agent]):
            RP.RemoveBoost(BoostResources)
            UnEquippedTrigger.Trigger(Agent)


    #Shop Stuff ===============================================================================================================================================================
    #Builds and returns a new canvas for shop of this this buyable
    GetShopCanvas() : canvas=
        var NewShopCanvas : canvas = canvas{}
        var ShopPreImage : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}
        var ShopPostImage : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}
        ShopButton := ShopButtons.GetButton(ShopSettings.ShopUIOptions.CombinedSettings.ButtonType)
        if(NewPreImage := ShopPreImages[IDX - 1]){ShopPreImage.SetImage(NewPreImage)}
        if(NewPostImage := ShopPostImages[IDX - 1]){ShopPostImage.SetImage(NewPostImage)}

        ShopButton.OnClick().Subscribe(PurchaseForWidget)

        set NewShopCanvas = NewCanvas : canvas = canvas:
            Slots := array:
                ShopSettings.ShopUIOptions.CombinedSettings.ImagePosition.MakeCanvasSlot(ShopPreImage,false)
                ShopSettings.ShopUIOptions.CombinedSettings.ImagePosition.MakeCanvasSlot(ShopPostImage,false)
                ShopSettings.ShopUIOptions.CombinedSettings.ButtonPosition.MakeCanvasSlot(ShopButton,false)

        return NewShopCanvas

    #Updates the buttons for the buyable on the shop UI
    ShopCheck(Agent:agent) : void=
        Button := ShopButtons.GetButton(ShopSettings.ShopUIOptions.CombinedSettings.ButtonType)
        if(CP := Custom_Player[GameManager.PlayersMap[Agent]]):
            #APPAREL
            if(NewBuyable := ApparelBuyable[Self]):
                if(CP.BoughtApparels.Find[IDX]):
                    if(ShopSettings.EquipSettings.UseUI.SameAsShop?):
                        if(CP.EquippedApparels.Find[IDX]):
                            Button.SetText(MasterS2M("UnEquip"))
                        else:
                            Button.SetText(MasterS2M("Equip"))
                    else:
                        Button.SetText(MasterS2M("Owned"))
                else:
                    Button.SetText(MasterS2M("Purchase"))

            #PETS
            else if(NewBuyable := PetBuyable[Self]):
                if(CP.BoughtPets.Find[IDX]):
                    if(ShopSettings.EquipSettings.UseUI.SameAsShop?):
                        if(CP.EquippedPets.Find[IDX]):
                            Button.SetText(MasterS2M("UnEquip"))
                        else:
                            Button.SetText(MasterS2M("Equip"))
                    else:
                        Button.SetText(MasterS2M("Owned"))
                else:
                    Button.SetText(MasterS2M("Purchase"))

    #Calls the purchase function from a widget
    PurchaseForWidget(Message : widget_message) : void=
        Player := Message.Player
        TryPurchase(Player , PurchaseMethod.Widget)

    #Calls the purchase function from a trigger
    PurchaseForTrigger(NAgent : ?agent) : void=
        if(Agent := NAgent?){TryPurchase(Agent, PurchaseMethod.Trigger)}

    #Purchase function that tries to purchase the buyable
    TryPurchase(Agent:agent , Method : PurchaseMethod) : void=
        Print("Try Purchase")
        if(CP := Custom_Player[GameManager.PlayersMap[Agent]], RP := ResourceManager.PlayersMap[Agent]):
            Print("Got Player")
            #APPAREL
            if(NewBuyable := ApparelBuyable[Self]):
                if(not CP.BoughtApparels.Find[IDX]):
                    Print("Not Bought")
                    if(Method = PurchaseMethod.Widget and ShopSettings.ShopType = shoptype.UI):
                        Print("Widget and UI")
                        SpendResult := RP.Check(CostResources)
                        
                        if(SpendResult?):
                            RP.Spend(CostResources)
                            set CP.BoughtApparels += array{IDX}
                            PersistanceManager.RecordPlayerArrStat(Agent, StatType.Apparels, ?Score := IDX)
                            PurchaseXP.Award(Agent)
                            PurchaseSuccessSound.Play(Agent)
                        else:
                            PurchaseFailureSound.Play(Agent)

                    if(Method = PurchaseMethod.Trigger and ShopSettings.ShopType = shoptype.Triggers):
                        SpendResult := RP.Check(CostResources)
                        if(SpendResult?):
                            RP.Spend(CostResources)
                            set CP.BoughtApparels += array{IDX}
                            PersistanceManager.RecordPlayerArrStat(Agent, StatType.Apparels, ?Score := IDX)
                            PurchaseXP.Award(Agent)
                            SuccessMSG.Show(Agent)
                        else:
                            PurchaseFailMSG.Show(Agent)
                            
                    else if(Method = PurchaseMethod.Trigger and ShopSettings.ShopType = shoptype.UI):
                        if(ShopSettings.EquipSettings.UseTriggers?):
                            MustPurchaseFirstMSG.Show(Agent)
                            
                else:
                    if(ShopSettings.EquipSettings.UseUI.SameAsShop? , Method = PurchaseMethod.Widget):
                        TryEquip(Agent)
                    else:
                        if(Method = PurchaseMethod.Widget and ShopSettings.ShopType = shoptype.UI):
                            PurchaseFailureSound.Play(Agent)

                        if(Method = PurchaseMethod.Trigger):
                            if(ShopSettings.EquipSettings.UseTriggers?):
                                TryEquip(Agent)
                            else if(ShopSettings.ShopType = shoptype.Triggers):
                                AlreadyHaveMSG.Show(Agent)


       
            #PETS
            if(NewBuyable := PetBuyable[Self]):
                if(not CP.BoughtPets.Find[IDX]):
                    if(Method = PurchaseMethod.Widget and ShopSettings.ShopType = shoptype.UI):
                        SpendResult := RP.Check(CostResources)
                        Print("Checking resources - {ResourceManager.PlayersMap.Length}")
                        if(SpendResult?):
                            RP.Spend(CostResources)
                            set CP.BoughtPets += array{IDX}
                            PersistanceManager.RecordPlayerArrStat(Agent, StatType.Pets, ?Score := IDX)
                            PurchaseXP.Award(Agent)
                            PurchaseSuccessSound.Play(Agent)
                        else:
                            PurchaseFailureSound.Play(Agent)

                    if(Method = PurchaseMethod.Trigger and ShopSettings.ShopType = shoptype.Triggers):
                        SpendResult := RP.Check(CostResources)
                        if(SpendResult?):
                            RP.Spend(CostResources)
                            set CP.BoughtPets += array{IDX}
                            PersistanceManager.RecordPlayerArrStat(Agent, StatType.Pets, ?Score := IDX)
                            PurchaseXP.Award(Agent)
                            SuccessMSG.Show(Agent)
                        else:
                            PurchaseFailMSG.Show(Agent)
                            
                    else if(Method = PurchaseMethod.Trigger and ShopSettings.ShopType = shoptype.UI):
                        if(ShopSettings.EquipSettings.UseTriggers?):
                            MustPurchaseFirstMSG.Show(Agent)
                            
                else:
                    if(ShopSettings.EquipSettings.UseUI.SameAsShop? , Method = PurchaseMethod.Widget):
                        TryEquip(Agent)

                    else:
                        if(Method = PurchaseMethod.Widget and ShopSettings.ShopType = shoptype.UI):
                            PurchaseFailureSound.Play(Agent)

                        if(Method = PurchaseMethod.Trigger):
                            if(ShopSettings.EquipSettings.UseTriggers?):
                                TryEquip(Agent)
                            else if(ShopSettings.ShopType = shoptype.Triggers):
                                AlreadyHaveMSG.Show(Agent)
        ShopCheck(Agent)

#Different purchase methods 
PurchaseMethod := enum:
    Widget
    Trigger
