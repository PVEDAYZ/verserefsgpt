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
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation/Tags }
using { /Verse.org/Assets }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }

#THIS SCRIPT WILL HIDE/SHOW PROPS

#Tag for all floor buttons
ButtonTag := class(tag){}

#Settings to control the rise animation
ButtonRiseAnimationSetting := class<concrete>(): 
    @editable StartingZValueFromInitialPosition : float = 0.0
    @editable KeyFrames : []ButtonKeyFrame = array{}

#Key frames used to control the rise animation movements
ButtonKeyFrame := class<concrete>():
    @editable Offset : transform = transform{}
    @editable Time : float = 0.0
    @editable Interp : CustomInterpTypes = CustomInterpTypes.InterpLinear



#Prop class that holds different values for each prop
Props := class():   
    var Prop : creative_prop = creative_prop{}
    var InitialZLocation : int = 0
    var HiddenZLocation : int = 0
    var ZOffset : float = 0.0
    var ButtonRiseAnimationSettings : ButtonRiseAnimationSetting = ButtonRiseAnimationSetting{}

    #Sets up the props Initial and Hidden locations
    Initialize(): void=
        if(Location := Int[Prop.GetTransform().Translation.Z]){set InitialZLocation = Location}
        if(Location := Int[Prop.GetTransform().Translation.Z - ZOffset]){set HiddenZLocation = Location}
            
    #Checks the props location, if in its initial location returns true, else returns false
    CheckLocation() : logic =
        if(PropZPos := Int[Prop.GetTransform().Translation.Z]):
            PropMin := (InitialZLocation * 1.0) - Abs(ButtonRiseAnimationSettings.StartingZValueFromInitialPosition)
            PropMax :=  (InitialZLocation * 1.0) + Abs(ButtonRiseAnimationSettings.StartingZValueFromInitialPosition)
            if((PropZPos * 1.0) >= PropMin  and  (PropZPos * 1.0) <= PropMax):
                return true
            else if(PropZPos = HiddenZLocation):
                return false
            else:
                Print("Invalid Location : {Prop.GetTransform().Translation.Z}")
                return false
        return false

    #Moves the prop back to its initial location and applies animation if enabled
    ShowProp(RiseAnimation : logic , AddToPersistence : logic) : void=
        PropPos := Prop.GetTransform().Translation
        PropRot := Prop.GetTransform().Rotation
        if(RiseAnimation? , AddToPersistence?):     
            spawn{SmoothItemMove()}
        else:
            if(Prop.TeleportTo[vector3{X:=PropPos.X,Y:=PropPos.Y,Z:=InitialZLocation * 1.0},PropRot]){}

    #Used to create animation for shown props
    SmoothItemMove()<suspends> : void=
        Sleep(0.0)
        PropPos := Prop.GetTransform().Translation
        PropRot := Prop.GetTransform().Rotation
        if(Prop.TeleportTo[vector3{X:=PropPos.X,Y:=PropPos.Y,Z:= (InitialZLocation * 1.0) + ButtonRiseAnimationSettings.StartingZValueFromInitialPosition},PropRot]): 
            for(F : ButtonRiseAnimationSettings.KeyFrames):
                Prop.ACMoveToLocation(F.Offset.Translation, F.Offset.Rotation , F.Offset.Scale , F.Time , F.Interp)
      

    #Moves the prop to its hidden location
    HideProp() : void=
        PropPos := Prop.GetTransform().Translation
        PropRot := Prop.GetTransform().Rotation
        if(Prop.TeleportTo[vector3{X:=PropPos.X,Y:=PropPos.Y,Z:=(HiddenZLocation * 1.0)},PropRot]){}


#Class for each unlockable
SpawnerButton:= class<concrete>():  
    #Base Stuff
    var PersistanceManager : Tycoon_Persistence_Manager = Tycoon_Persistence_Manager{}
    var GameManager : Game_Manager = Game_Manager{}
    var ResourceManager : Resource_Manager = Resource_Manager{}
    var Identifier : int = 0        
    var ItemsToShowMap: [int]Props = map{}     
    var ItemsToHideMap: [int]Props = map{}     
    var ZOffset : float = 0.0
    var PurchasedEvent : event(agent) = event(agent){}
    var PropsHiddenAtATime : int = 0
    var ButtonPlayerLocationVFX : vfx_spawner_device = vfx_spawner_device{}
    var ButtonRiseAnimationSettings : ButtonRiseAnimationSetting = ButtonRiseAnimationSetting{}

    var IsPurchased : logic = false

    #Devices that can be used to activate the button/unlockable
    TT_SB_ActivateDevices<localizes>:message = "Devices that can be used to activate the button/unlockable"
    @editable{ToolTip := TT_SB_ActivateDevices} ActivateDevices : ActivateDevice = ActivateDevice{}

    TT_SB_ActivateDevicesToShow<localizes>:message = "Devices that are enabled / shown / hidden upon successful purchase"
    @editable{ToolTip := TT_SB_ActivateDevicesToShow} ActivateDevicesToShow : []ActivateDevice = array{}

    TT_SB_ItemsToShow<localizes>:message = "List of props that will show when the button is purchased"
    @editable{ToolTip := TT_SB_ItemsToShow} ItemsToShow: []creative_prop = array{}

    TT_SB_ItemsToHide<localizes>:message = "List of props that will be hidden when the button is purchased (usually used to hide the button prop after it is purchased)"
    @editable{ToolTip := TT_SB_ItemsToHide} ItemsToHide: []creative_prop = array{}      

    TT_SB_ExtraDevices<localizes>:message = "Devices that are activated upon successful purchase"
    @editable{ToolTip := TT_SB_ExtraDevices} ExtraDevices : ExtraDevice = ExtraDevice{}

    var BuildHouseXP : accolades_device = accolades_device{}  
    var PurchaseMSG : hud_message_device = hud_message_device{}     
    var NotEnoughMoneyMSG : hud_message_device = hud_message_device{}      
    
    TT_SB_CostResources<localizes>:message = "Resources that the button costs"
    @editable{ToolTip := TT_SB_CostResources} CostResources : []SpendableResource = array{}

    TT_SB_GainResources<localizes>:message = "Resources that the player gains upon purchasing the button"
    @editable{ToolTip := TT_SB_GainResources} GainResources : []GainableResource = array{}

    TT_SB_RiseAnimation<localizes>:message = "Whether or not the props shown should play an animation"
    @editable{ToolTip := TT_SB_RiseAnimation} RiseAnimation : logic = false 

    TT_SB_ShowVFX<localizes>:message = "Whether or not the button should show a vfx when a player purchases it"
    @editable{ToolTip := TT_SB_ShowVFX} ShowVFX : logic = false

    #Resets the button back to its hidden state
    ResetButton(Agent:agent)<suspends> : void=
        #Hides props
        var CurrentResetAmount : int = 0
        for(B : ItemsToShowMap):                           
            IsShown := B.CheckLocation()
            if(IsShown?):
                B.HideProp()
                if(CurrentResetAmount <= PropsHiddenAtATime):
                    set CurrentResetAmount += 1
                else:
                    Sleep(0.01)
                    set CurrentResetAmount = 0

        #Disables unique stuff
        ExtraDevices.CarSpawner1.Disable()
        ExtraDevices.CarSpawner2.Disable()
        ExtraDevices.Cinematic.Stop() 
        ExtraDevices.DisableTrigger.Trigger(Agent)                       

        #Disables Activators
        for(A : ActivateDevicesToShow){A.DisableAll()}     
        set IsPurchased = false       
            
    #Activates CheckButton but for a trigger
    CheckButtonForTrigger(Agent:?agent) : void=
        if(NewAgent := Agent?){CheckButton(NewAgent)}
            
    #Tries to unlock the unlockable
    CheckButton(Agent:agent) : void=   
        if(RP := ResourceManager.PlayersMap[Agent]):
            if(not IsPurchased?):
                HasAmounts := RP.Check(CostResources)
                if(HasAmounts?):
                    if(Identifier <> 0):
                        RP.Spend(CostResources)
                        spawn{UnlockButton(Agent,true)}
                else:
                    NotEnoughMoneyMSG.Show(Agent)   

    #Unlocks the unlockable
    UnlockButton(Agent:agent,AddToPersistence : logic)<suspends>: void=   
        if(CustomPlayer := Custom_Player[GameManager.PlayersMap[Agent]], RP := ResourceManager.PlayersMap[Agent]):
            set IsPurchased = true

            #Collects resources and shows success devices
            RP.Collect(GainResources)      
            PurchasedEvent.Signal(Agent)
            if(Identifier <> 0){PurchaseMSG.Show(Agent)}
            spawn{HandleExtras(Agent)}

            #Shows props
            for(idx -> Item: ItemsToShow, CustomProp := ItemsToShowMap[idx]):
                IsShown := CustomProp.CheckLocation()
                if(not IsShown?):
                    CustomProp.ShowProp(RiseAnimation , AddToPersistence)
                  
            #Hides Props
            for(idx -> Item: ItemsToHide , CustomProp := ItemsToHideMap[idx]):    
                IsShown := CustomProp.CheckLocation()
                if(IsShown?):
                    CustomProp.HideProp()

            #Disables its own activating devices
            spawn{ActivateDevices.DisableAll()}
    

            #If true, adds the door to persistence and waits 1 second before activating next mutators
            if(AddToPersistence?):     
                if(ShowVFX?){spawn{HandleVFX(Agent)}}  
                if(not CustomPlayer.BoughtDoors.Find[Identifier]):
                    PersistanceManager.RecordPlayerArrStat(Agent, StatType.Doors, ?Score := Identifier)
                    set CustomPlayer.BoughtDoors += array{Identifier}
                Sleep(1.5) 
                for(A : ActivateDevicesToShow){spawn{A.EnableAll()}}  

            #If false, automatically activate next mutators    
            else:
                for(A : ActivateDevicesToShow){spawn{A.EnableAll()}}     

    HandleVFX(Agent : agent)<suspends> : void=
        if:
            FC := Agent.GetFortCharacter[]
            PlayerPos := FC.GetTransform().Translation
            PlayerRot := FC.GetTransform().Rotation
            ButtonPlayerLocationVFX.TeleportTo[PlayerPos + vector3{Z:= 30.0},PlayerRot]
        then:
            Print("Activate VFX")
            Sleep(0.1)
            ButtonPlayerLocationVFX.Restart()
            Sleep(0.1)
            ButtonPlayerLocationVFX.Disable()


    #Activates all extra devices
    HandleExtras(Agent:agent)<suspends> : void=  
        
        ExtraDevices.Cinematic.Play()
        ExtraDevices.EnableTrigger.Trigger(Agent)

        ExtraDevices.CarSpawner1.Disable()
        Sleep(1.0)
        ExtraDevices.CarSpawner2.Enable()
            


#Button Manager creative device
Button_Manager := class(creative_device):
    #Base Stuff
    PersistanceManager : Tycoon_Persistence_Manager = Tycoon_Persistence_Manager{}
    TT_BM_GameManager<localizes>:message = "Your main game manager device"
    @editable{ToolTip := TT_BM_GameManager} GameManager: Game_Manager = Game_Manager{}

    TT_BM_ResourceManager<localizes>:message = "Your Resource Manager Device"
    @editable{ToolTip := TT_BM_ResourceManager} ResourceManager : Resource_Manager = Resource_Manager{}

    ResetEvent : event(agent) = event(agent){}
    PlotClaimedEvent : event(agent) = event(agent){}
    


    #Additional devices that applies to every button
    #Additional devices that applies to every button
    TT_BM_FailedMSG<localizes>:message = "A hud message device that shows a message when the player tries to purchase a button but does not have enough resources"
    @editable{ToolTip := TT_BM_FailedMSG} FailedMSG : hud_message_device = hud_message_device{} #Hud msg when button fails

    TT_BM_PurchasedMSG<localizes>:message = "A hud message device that shows a message when the player successfully purchases a button"
    @editable{ToolTip := TT_BM_PurchasedMSG} PurchasedMSG : hud_message_device = hud_message_device{}  #Hud msg when button succeeds

    TT_BM_PurchaseXP<localizes>:message = "An accolades device that grants XP when a player successfully purchases a button"
    @editable{ToolTip := TT_BM_PurchaseXP} PurchaseXP : accolades_device = accolades_device{}  #XP granted when button succeeds


    TT_BM_ButtonsArray<localizes>:message = "Main array of all buttons in a plot and settings to control how they are hidden"
    @editable{ToolTip := TT_BM_ButtonsArray} ButtonsArray: []SpawnerButton = array{}

    TT_BM_ZOffset<localizes>:message = "The Z offset for all the hidden button (Recommended range : 15,000.0 - 50,000.0)"
    @editable{ToolTip := TT_BM_ZOffset} ZOffset : float = 0.0

    TT_BM_PropsHiddenAtATime<localizes>:message = "The amount of props that should be hidden at a time at the start or when the plot resets (Recommended range : 3 - 10)"
    @editable{ToolTip := TT_BM_PropsHiddenAtATime} PropsHiddenAtATime : int = 0

    
    #Extra Settings
    TT_BM_ButtonsColorChange<localizes>:message = "Whether or not the buttons should change color based on whether the player can afford them"
    @editable{ToolTip := TT_BM_ButtonsColorChange} ButtonsColorChange : logic = false

    TT_BM_IndicatorSettings<localizes>:message = "Settings for the map indicator"
    @editable{ToolTip := TT_BM_IndicatorSettings} IndicatorSettings : IndicatorSetting = IndicatorSetting{}

    TT_BM_ButtonPlayerLocationVFX<localizes>:message = "A vfx device that spawns at the button when a player purchases it\n*Required Settings*\nCustom Visual Effect Override : True\nCustom Visual Effect : Your Custom Button VFX\nEnable On Reset : True\nClear Particles On Disable : False"
    @editable{ToolTip := TT_BM_ButtonPlayerLocationVFX} ButtonPlayerLocationVFX : vfx_spawner_device = vfx_spawner_device{}

    TT_BM_ButtonRiseAnimationSettings<localizes>:message = "Control how the rise animation works/displays"
    @editable{ToolTip := TT_BM_ButtonRiseAnimationSettings} ButtonRiseAnimationSettings : ButtonRiseAnimationSetting = ButtonRiseAnimationSetting{}

    #===============================================================================================================================================
    #FIRST ELEMENT IS WHEN THE PLAYER HAS ENOUGH, SECOND IS WHEN THEY DO NOT
    var ButtonsColorChangeMaterials : []material = array{}  
    #===============================================================================================================================================

    OnBegin<override>()<suspends>:void=
        Sleep(1.0)
        spawn{HandleMapIndicators()}
        spawn{ButtonColorChangeLoop()}
        #Sets up all buttons
        for(idx -> Button : ButtonsArray):   
            set Button.GameManager = GameManager
            set Button.ResourceManager = ResourceManager
            set Button.PersistanceManager = PersistanceManager
            set Button.ZOffset = ZOffset
            set Button.PurchaseMSG = PurchasedMSG
            set Button.NotEnoughMoneyMSG = FailedMSG
            set Button.BuildHouseXP = PurchaseXP
            set Button.Identifier = idx
            set Button.PropsHiddenAtATime = PropsHiddenAtATime
            set Button.ButtonPlayerLocationVFX = ButtonPlayerLocationVFX
            Button.ActivateDevices.DisableAll()

            Button.ActivateDevices.ActivateMutatorZone.AgentEntersEvent.Subscribe(Button.CheckButton) 
            Button.ActivateDevices.ActivateButton.InteractedWithEvent.Subscribe(Button.CheckButton) 
            Button.ActivateDevices.ActivateTrigger.TriggeredEvent.Subscribe(Button.CheckButtonForTrigger) 
            Button.ActivateDevices.ActivateVolume.AgentEntersEvent.Subscribe(Button.CheckButton) 
           
            #Initalizes show props 
            for(index -> Item: Button.ItemsToShow):   
                if(set Button.ItemsToShowMap[index] = Props{Prop := Item, ZOffset := ZOffset , ButtonRiseAnimationSettings := ButtonRiseAnimationSettings}):
                    if(CurrentProp := Button.ItemsToShowMap[index]){CurrentProp.Initialize()}
                        
            #Initalizes Hide props 
            for(index -> Item: Button.ItemsToHide):   
                if(set Button.ItemsToHideMap[index] = Props{Prop := Item, ZOffset := ZOffset , ButtonRiseAnimationSettings := ButtonRiseAnimationSettings}):
                    if(CurrentProp := Button.ItemsToHideMap[index]){CurrentProp.Initialize()}
                   
        #Hides all props
        var CurrentResetAmount : int = 0
        for(Button : ButtonsArray):
            for(B : Button.ItemsToShowMap):               
                IsShown := B.CheckLocation()
                if(IsShown?):
                    B.HideProp()
                    if(CurrentResetAmount <= PropsHiddenAtATime):
                        set CurrentResetAmount += 1
                    else:
                        Sleep(0.01)
                        set CurrentResetAmount = 0

        if(FirstButton := ButtonsArray[0]):
            FirstButton.ActivateDevices.EnableAll()

    #Handles moving the map indicator to specified buttons
    HandleMapIndicators()<suspends> : void=
        var CurrentIndicatorIDX : int = 0
        race:
            #Waits for plot to reset and restarts the indicator
            block:
                Agent := ResetEvent.Await()
                spawn{HandleMapIndicators()}
                IndicatorSettings.MapIndicatorDevice.DeactivateObjectivePulse(Agent)

            #Progressively moves the indicator through the buttons selected
            loop:
                if:
                    ButtonIndicatorIDX := IndicatorSettings.IndicatorButtonOrder[CurrentIndicatorIDX] 
                    CurrentButton := ButtonsArray[ButtonIndicatorIDX]
                then:
                    Agent := CurrentButton.PurchasedEvent.Await()
                    IndicatorSettings.MapIndicatorDevice.DeactivateObjectivePulse(Agent)
                    if:
                        NextButtonIndicatorIDX := IndicatorSettings.IndicatorButtonOrder[CurrentIndicatorIDX + 1] 
                        NextButton := ButtonsArray[NextButtonIndicatorIDX]
                    then:
                        TaggedActors := FindCreativeObjectsWithTag(ButtonTag{})
                        for(idx -> Item: NextButton.ItemsToHide, CustomItem := NextButton.ItemsToHideMap[idx], ButtonTrans := Item.GetTransform().Translation):
                            for(P : TaggedActors,Prop := creative_prop[P] , PropTrans := Prop.GetTransform().Translation):
                                if:
                                    ButtonTrans.X = PropTrans.X
                                    ButtonTrans.Y = PropTrans.Y
                                    ButtonTrans.Z = PropTrans.Z
                                then:
                                    set CurrentIndicatorIDX += 1
                                    if(IndicatorSettings.MapIndicatorDevice.TeleportTo[vector3{X:= ButtonTrans.X, Y:= ButtonTrans.Y, Z:= CustomItem.InitialZLocation * 1.0}, IdentityRotation()]):
                                        IndicatorSettings.MapIndicatorDevice.ActivateObjectivePulse(Agent)
                                        IndicatorSettings.MapIndicatorDevice.ActivateObjectivePulse(Agent)
                else:
                    if(IndicatorSettings.IndicatorButtonOrder.Length = 0):
                        break
                    else:
                        Sleep(0.0)


    #Loop to continually change the material of buttons based on if the player has enough resources
    ButtonColorChangeLoop()<suspends> : void=
        Agent := PlotClaimedEvent.Await()
        if(ButtonsColorChange? , RP := ResourceManager.PlayersMap[Agent]):
            race:
                block:
                    ResetEvent.Await()
                    spawn{ButtonColorChangeLoop()}
                loop:
                    Sleep(1.0)
                    TaggedActors := FindCreativeObjectsWithTag(ButtonTag{})
                    for(idx -> Button : ButtonsArray ):
                        Sleep(0.0)
                        for(B : Button.ItemsToHide , ButtonTrans := B.GetTransform().Translation):
                            for(P : TaggedActors,Prop := creative_prop[P] , PropTrans := Prop.GetTransform().Translation):
                                if:
                                    ButtonTrans.X = PropTrans.X
                                    ButtonTrans.Y = PropTrans.Y
                                    ButtonTrans.Z = PropTrans.Z
                                then:
                                    HasEnough := RP.Check(Button.CostResources)
                                    if(HasEnough?):
                                        if(Mat := ButtonsColorChangeMaterials[0]){Prop.SetMaterial(Mat)}
                                    else:
                                        if(Mat := ButtonsColorChangeMaterials[1]){Prop.SetMaterial(Mat)}

#Settings used to control the indicator
IndicatorSetting:= class<concrete>():
    TT_IS_IndicatorButtonOrder<localizes>:message = "The element of the button inside the buttons array that the map indicator should point to. Goes in order starting after the purchase of the first element in this array"
    @editable{ToolTip := TT_IS_IndicatorButtonOrder} IndicatorButtonOrder : []int = array{}

    TT_IS_MapIndicatorDevice<localizes>:message = "The map indicator device that displays an line toward the next button"
    @editable{ToolTip := TT_IS_MapIndicatorDevice} MapIndicatorDevice : map_indicator_device = map_indicator_device{}

#Different devices that are activated for each unlockable
ExtraDevice := class<concrete>():
    TT_ED_EnableTrigger<localizes>:message = "A trigger device that gets triggered when the button is purchased"
    @editable{ToolTip := TT_ED_EnableTrigger} EnableTrigger : trigger_device = trigger_device{}

    TT_ED_DisableTrigger<localizes>:message = "A trigger device is triggered when the button reset"
    @editable{ToolTip := TT_ED_DisableTrigger} DisableTrigger : trigger_device = trigger_device{}

    TT_ED_Cinematic<localizes>:message = "A cinematic device that plays when the button is purchased"
    @editable{ToolTip := TT_ED_Cinematic} Cinematic : cinematic_sequence_device = cinematic_sequence_device{}

    TT_ED_CarSpawner1<localizes>:message = "A vehicle spawner device that gets disabled when the button is purchased"
    @editable{ToolTip := TT_ED_CarSpawner1} CarSpawner1 : vehicle_spawner_sports_car_device = vehicle_spawner_sports_car_device{}

    TT_ED_CarSpawner2<localizes>:message = "A vehicle spawner device that gets enabled when the button is purchased"
    @editable{ToolTip := TT_ED_CarSpawner2} CarSpawner2 : vehicle_spawner_sports_car_device = vehicle_spawner_sports_car_device{}

