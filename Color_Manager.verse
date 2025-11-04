using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Assets }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation/Tags }

#THIS DEVICE IS USED TO ALLOW THE PLAYER TO PURCHASE AND CHANGE THE MATERIALS OF DIFFERENT PROPS

#Tag to apply to props for changing
ColorChange := class(tag){}

#Class for each color
ColorOption := class<concrete>():
    #Add Images & Materials Here 
    #*************************************************************************************************************************************************
    var PrePurchaseImages : []texture = array{}
    var PostPurchaseImages : []texture = array{}
    var Mats : []material = array{}
    #*************************************************************************************************************************************************

    #Verse Devices and Settings
    PersistanceManager : Tycoon_Persistence_Manager = Tycoon_Persistence_Manager{}
    var GameManager : Game_Manager = Game_Manager{}
    var ResourceManager : Resource_Manager = Resource_Manager{}
    var ButtonManager : Button_Manager = Button_Manager{}
    var ColorChangeSettings : ColorChangeSetting = ColorChangeSetting{}

    #UI Stuff
    var ColorCanvas : canvas = canvas{}
    var ColorImage : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}
    var ColorButtons : UIAllButtons = UIAllButtons{}

    #Extra Stuff
    CheckEvent : event() = event(){}
    var IDX : int = 0

    #Editables
    TT_CM_Setting_ImageIDX<localizes>:message = "The index of the image in the PrePurchaseImages and PostPurchaseImages arrays to use for the color"
    @editable ImageIDX : int = 0

    TT_CM_Setting_MaterialIDX<localizes>:message = "The index of the material in the Mats array to use for the color"
    @editable MaterialIDX : int = 0

    TT_CM_Setting_SuccessSound<localizes>:message = "An audio player device that will play when the color is purchased\n*Required Settings*\nAudio : The sound to play\nCan Be Heard By : Instigator Only\nPlay Location : Instigating Player"
    @editable SuccessSound : audio_player_device = audio_player_device{}

    TT_CM_Setting_FailureSound<localizes>:message = "An audio player device that will play when the player tries to purchase a color without enough resources\n*Required Settings*\nAudio : The sound to play\nCan Be Heard By : Instigator Only\nPlay Location : Instigating Player"
    @editable FailureSound : audio_player_device = audio_player_device{}

    TT_CM_Setting_PurchaseXP<localizes>:message = "An accolades device that will award the player XP when the color is purchased\n*Required Settings*\nTriggering Player Only : true"
    @editable PurchaseXP : accolades_device = accolades_device{}

    TT_CM_Setting_CostResources<localizes>:message = "The resources that the player must have to purchase the color"
    @editable CostResources : []SpendableResource = array{}
  
    TT_CM_Trigger<localizes>:message = "Trigger Device used to purchase/equip this color"
    @editable Trigger : trigger_device = trigger_device{}


    #Sets up the canvas for each Color option on the UI, based off of the "Combined Position Settings"
    SetUpCanvas() : void=
        ColorButton := ColorButtons.GetButton(ColorChangeSettings.CombinedPositionSettings.ButtonType)

        ColorButton.OnClick().Subscribe(HandlePressWidget)
        if(NewImage := PrePurchaseImages[ImageIDX]){ColorImage.SetImage(NewImage)}
        set ColorCanvas = NewCanvas : canvas = canvas{
            Slots := array:
                ColorChangeSettings.CombinedPositionSettings.ImagePosition.MakeCanvasSlot(ColorImage,false)
                ColorChangeSettings.CombinedPositionSettings.ButtonPosition.MakeCanvasSlot(ColorButton,false)
        }
    #Calls the handle press function, but receives from a trigger
    HandlePressTrigger(MAgent : ?agent) : void=
        if(Agent := MAgent?){HandlePress(Agent)}

    #Calls the handle press function, but receives from a button widget
    HandlePressWidget(Message : widget_message) : void=
        HandlePress(Message.Player)
        
    #When a color button is pressed, checks if it is owned and if it is equipped and handles accordingly
    HandlePress(Agent : agent) : void=
        if( CP := Custom_Player[GameManager.PlayersMap[Agent]], RP := ResourceManager.PlayersMap[Agent]):
            if(not CP.BoughtColors.Find[IDX]):              
                HasEnough := RP.Check(CostResources)
                if(HasEnough?):
                    RP.Spend(CostResources)
                    set CP.BoughtColors += array{IDX}
                    PersistanceManager.RecordPlayerArrStat(Agent, StatType.Colors, ?Score := IDX)
                    SuccessSound.Play(Agent)
                    PurchaseXP.Award(Agent)
                else:
                    FailureSound.Play(Agent)
            else:
                if(not CP.EquippedColor = IDX):
                    set CP.EquippedColor = IDX
                    Equip(Agent)
        CheckEvent.Signal()

    #Equips the color and changes all props tagged to the colors material
    Equip(Agent:agent) : void=
        TaggedActors := ButtonManager.FindCreativeObjectsWithTag(ColorChange{})
        for(Button : ButtonManager.ButtonsArray):
            for(B : Button.ItemsToShow , ButtonTrans := B.GetTransform().Translation):
                for(P : TaggedActors,Prop := creative_prop[P] , PropTrans := Prop.GetTransform().Translation):
                    if:
                        ButtonTrans.X = PropTrans.X
                        ButtonTrans.Y = PropTrans.Y
                        ButtonTrans.Z = PropTrans.Z
                    then:
                        if(Mat := Mats[MaterialIDX]){Prop.SetMaterial(Mat)}
                
    #Changes the text and images based on whether the color is owned or equipped
    CheckText(Agent:agent) : void=
        ColorButton := ColorButtons.GetButton(ColorChangeSettings.CombinedPositionSettings.ButtonType)
        if(CP := Custom_Player[GameManager.PlayersMap[Agent]]):
            if(CP.BoughtColors.Find[IDX]):
                if(NewImage := PostPurchaseImages[ImageIDX]){ColorImage.SetImage(NewImage)}
                if(CP.EquippedColor = IDX):
                    ColorButton.SetText(MasterS2M("Equipped"))
                else:
                    ColorButton.SetText(MasterS2M("Equip"))
            else:
                if(NewImage := PrePurchaseImages[ImageIDX]){ColorImage.SetImage(NewImage)}
                ColorButton.SetText(MasterS2M("Purchase"))
    
#Main class to create the UI
ColorChangeUI := class():
    #Devices and settings
    var GameManager : Game_Manager = Game_Manager{}
    var ColorChangeSettings : ColorChangeSetting = ColorChangeSetting{}
    var ColorCancelSettings : ColorCancelSetting = ColorCancelSetting{}
    var Cinematic : cinematic_sequence_device = cinematic_sequence_device{}

    #All of the colors available
    var AllColors : []ColorOption = array{}

    #UI stuff
    var MainUI : canvas = canvas{}
    var ExitButton : button_loud = button_loud{}
    ColorCloseEvent : event() = event(){}
    
    
    #Initializes the UI and adds it to the player
    OpenUI(Agent:agent) : void=
        for(C : AllColors){spawn{TextUpdate(Agent,C)}}
        ExitButton.SetText(MasterS2M("Exit"))
        ExitButton.OnClick().Subscribe(HandleExitUI)
        spawn{HandleCancel(Agent)}
        if(Player := player[Agent],PlayerUI := GetPlayerUI[Player]):
            set MainUI = CreateUI()
            PlayerUI.AddWidget(MainUI, player_ui_slot{InputMode := ui_input_mode.All})

            spawn{ColorElimTrack(Agent)}

    ColorElimTrack(Agent:agent)<suspends> : void=
        if (Player := player[Agent],PlayerUI := GetPlayerUI[Player],FC:=Agent.GetFortCharacter[],CP := GameManager.PlayersMap[Agent]):
            race:
                ColorCloseEvent.Await()
                FC.EliminatedEvent().Await()
            MainUI.SetVisibility(widget_visibility.Hidden)
            PlayerUI.RemoveWidget(MainUI)
            Cinematic.Stop(Agent)

    #Adds all of the colors UIs to the main UI
    CreateUI() : canvas =
        var NewUI : canvas = canvas{}
        for(idx -> UISlot : ColorChangeSettings.AllColorPositions , CurColor := AllColors[idx]):
            NewCanvas := CurColor.ColorCanvas
            set UISlot.Canvas = NewCanvas

            NewSlot := UISlot.Position.MakeCanvasSlot(UISlot.Canvas,false)
            NewUI.AddWidget(NewSlot)

        if(ColorCancelSettings.CancelType = colorcanceltype.UI):
            ExitButton.SetVisibility(widget_visibility.Visible)
            NewUI.AddWidget(ColorCancelSettings.UIExitPosition.MakeCanvasSlot(ExitButton, false))
        return NewUI

    #Used to call the exit function, except from the UI button
    HandleExitUI(Message : widget_message) : void=
        Player := Message.Player
        HandleExit(Player)

    #Exits the UI and removes the cinematic
    HandleExit(Agent:agent) : void=
        if (Player := player[Agent],PlayerUI := GetPlayerUI[Player],FC:=Agent.GetFortCharacter[],CP := GameManager.PlayersMap[Agent]):
            ColorCloseEvent.Signal()

            
    #Waits for a color button to be pressed and updates the text for all buttons when it is
    TextUpdate(Agent:agent , Col : ColorOption)<suspends> : void=
        Col.CheckText(Agent)
        loop:
            Sleep(0.0)
            Col.CheckEvent.Await()
            for(C : AllColors){C.CheckText(Agent)}
              
    #Tracks for when a player cancels based on the cancel setting
    HandleCancel(Agent:agent)<suspends> : void=
        if(ColorCancelSettings.CancelType = colorcanceltype.UI):
            ExitButton.OnClick().Subscribe(HandleExitUI)

        else if(ColorCancelSettings.CancelType = colorcanceltype.Duration):
            Sleep(ColorCancelSettings.CancelDuration)
            HandleExit(Agent)

#Creative device class
Color_Manager := class(creative_device):
    #Devices
    TT_CM_Device_GameManager<localizes>:message = "Your Game Manager Device"
    @editable GameManager : Game_Manager = Game_Manager{}

    TT_CM_Device_ResourceManager<localizes>:message = "Your Resource Manager Device"
    @editable ResourceManager : Resource_Manager = Resource_Manager{}

    TT_CM_Device_ButtonManager<localizes>:message = "Your Button Manager Device"
    @editable ButtonManager : Button_Manager = Button_Manager{}

    TT_CM_OpenUITrigger<localizes>:message = "A trigger device that will open the color change UI"
    @editable OpenUITrigger : trigger_device = trigger_device{}

    TT_CM_Device_Cinematic<localizes>:message = "A cinematic sequence device that will play when the button is color change pressed\n*Required Settings*\nVisibility : Instigator Only"
    @editable Cinematic : cinematic_sequence_device = cinematic_sequence_device{}

    #Settings
    TT_CM_Device_ColorChangeSettings<localizes>:message = "The settings for the color change UI"
    @editable ColorChangeSettings : ColorChangeSetting = ColorChangeSetting{}
    
    TT_CM_Device_ColorCancelSettings<localizes>:message = "The settings for closing the color change UI"
    @editable ColorCancelSettings : ColorCancelSetting = ColorCancelSetting{}

    TT_CM_Device_AllColors<localizes>:message = "The colors that the player can purchase"
    @editable AllColors : []ColorOption = array{}
  

    

    #Initializes at the start of the game and waits for button to be pressed
    OnBegin<override>()<suspends>:void=
        Initialize()
        OpenUITrigger.TriggeredEvent.Subscribe(OpenUI)

    #Initializes all of the colors
    Initialize() : void=
        for(idx -> C : AllColors):
            set C.GameManager = GameManager
            set C.ResourceManager = ResourceManager
            set C.ButtonManager = ButtonManager
            set C.IDX = idx
            set C.ColorChangeSettings = ColorChangeSettings
            C.Trigger.TriggeredEvent.Subscribe(C.HandlePressTrigger)
            C.SetUpCanvas()

    #Makes a new UI And adds it to the player when button is pressed, also plays cinematic
    OpenUI(MAgent:?agent) : void=
        if(Agent := MAgent?):
            NewColorUI := ColorChangeUI:
                GameManager := GameManager
                ColorChangeSettings := ColorChangeSettings 
                ColorCancelSettings := ColorCancelSettings
                Cinematic := Cinematic
                AllColors := AllColors
            NewColorUI.OpenUI(Agent)
            Cinematic.Play(Agent)

#Different cancel types
colorcanceltype := enum:
    UI
    Duration

#Settings to control how UI is canceled / closed
ColorCancelSetting := class<concrete>():
    TT_CM_Setting_CancelType<localizes>:message = "How the color change UI is canceled/closed\nUI : The UI has a button that the player can click to close it\nDuration : The UI will close after a set amount of time"
    @editable CancelType : colorcanceltype = colorcanceltype.UI

    TT_CM_Setting_UIExitPosition<localizes>:message = "The position of the exit button on the UI *Only used if Cancel Type is UI*"
    @editable UIExitPosition : CanvasPosition = CanvasPosition{}
    
    TT_CM_Setting_CancelDuration<localizes>:message = "The duration of the color change UI *Only used if Cancel Type is Duration*"
    @editable CancelDuration : float = 0.0

#Position of each color
ColorPosition := class<concrete>():
    @editable Position : CanvasPosition = CanvasPosition{}
    var Canvas : canvas = canvas{}

#Combination of other color settings to be concise
ColorChangeSetting := class<concrete>():
    TT_CM_Setting_CombinedPositionSettings<localizes>:message = "The settings for the positioning of the each colors widgets in the color change UI"
    @editable CombinedPositionSettings : CombinedSetting = CombinedSetting{}
    
    TT_CM_Setting_AllColorPositions<localizes>:message = "The nubmer of colors on the screen and their positions. Corresponds to the identical elements in the AllColors array"
    @editable AllColorPositions : []ColorPosition = array{} 