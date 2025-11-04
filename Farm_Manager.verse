using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

#THIS DEVICE WILL WORK AS A FARM TO COLLECT A SPECIFIC RESOURCE THAT REGENERATES OVER TIME

#Class for each individual crop
Crop:= class<concrete>():
    #Base Stuff
    var GameManager : Game_Manager = Game_Manager{}      
    var ResourceManager : Resource_Manager = Resource_Manager{}
    var IsGrown : logic = false      

    #Activated/Gained on collection
    var PickUpAudio : audio_player_device = audio_player_device{}                      
    var CropXP : accolades_device = accolades_device{}                                  
    var CropTracker : tracker_device = tracker_device{}                                 
    var CropResources : []GainableResource = array{} 

    #Growth Settings
    TT_FM_Crop_GrowthSettings_CropMaxGrowScale<localizes>:message = "The maximum scale for the crop"
    @editable CropMaxGrowScale : float = 0.0

    TT_FM_Crop_GrowthSettings_CropMinGrowScale<localizes>:message = "The minimum scale for the crop"
    @editable CropMinGrowScale : float = 0.0

    TT_FM_Crop_GrowthSettings_CropGrowTime<localizes>:message = "The time it takes for the crop to grow from the minimum scale to the maximum scale"
    @editable CropGrowTime : float = 0.0

    #Used to collect the crop
    TT_FM_Crop_CollectionSettings_CropMutator<localizes>:message = "A mutator zone device which is used collect the crop"
    @editable CropMutator : mutator_zone_device = mutator_zone_device{}

    TT_FM_Crop_CollectionSettings_CropManipulator<localizes>:message = "A prop manipulator device which is used to collect the crop when the crop prop is hit"
    @editable CropManipulator : prop_manipulator_device = prop_manipulator_device{}

    #Crop Props
    TT_FM_Crop_Props_CropReadyProp<localizes>:message = "The prop that is shown when the crop is ready"
    @editable CropReadyProp : creative_prop = creative_prop{}

    TT_FM_Crop_Props_CropProp<localizes>:message = "The prop that is shown when the crop is growing"
    @editable CropProp : creative_prop = creative_prop{}

    #Enables and initializes the crop                        
    EnableCrop()<suspends> : void=                                         
        CropProp.Show()                                            
        CropMutator.Enable()    

        CropScale := CropProp.GetTransform().Scale
        CropPos := CropProp.GetTransform().Translation
        CropRot := CropProp.GetTransform().Rotation

        #Shrinks crop to small position and grows to full position
        if(CropProp.TeleportTo[transform{Translation := CropPos,Rotation:= CropRot, Scale:= vector3{X:=CropMinGrowScale,Y:=CropMinGrowScale,Z:=CropMinGrowScale}}]){}
        CropProp.MoveTo(transform{Translation := CropPos,Rotation:= CropRot, Scale:= vector3{X:=CropMaxGrowScale,Y:=CropMaxGrowScale,Z:=CropMaxGrowScale}} , CropGrowTime)

        #Activates when crop is grown
        CropReadyProp.Show()    
        set IsGrown = true
        CropMutator.AgentEntersEvent.Subscribe(CollectCrop)
        CropManipulator.DamagedEvent.Subscribe(CollectCrop)

    #Tries to collect the crop
    CollectCrop(Agent:agent) : void=    
        if(IsGrown = true):     
            if(RP := ResourceManager.PlayersMap[Agent]):  
                #Collects prop stuff
                PickUpAudio.Play(Agent)     
                CropReadyProp.Hide()      
                CropXP.Award(Agent)         
                CropTracker.Increment(Agent)       
                RP.Collect(CropResources)
        
                #Resets Crop
                set IsGrown = false     
                spawn{EnableCrop()}          
        else:

#Set of crops
CropSet := class<concrete>():          
    #Base Stuff
    var GameManager : Game_Manager = Game_Manager{}       
    var ResourceManager : Resource_Manager = Resource_Manager{}

    #Activated/Gained on collection
    var PickUpAudio : audio_player_device = audio_player_device{}                      
    var CropXP : accolades_device = accolades_device{}                                  
    var CropTracker : tracker_device = tracker_device{}                                 

    #Crops
    TT_FM_CropSet_Crops<localizes>:message = "An array of crops"
    @editable Crops : []Crop = array{}       
    
    TT_FM_CropSet_CropResources<localizes>:message = "An array of resources that can be gained from the crops"
    @editable CropResources : []GainableResource = array{}       

    #Trigger to enable the set of crops
    TT_FM_CropSet_EnableTrigger<localizes>:message = "A trigger device which enables/start the growth of the crops"
    @editable EnableTrigger : trigger_device = trigger_device{}    

    #Enables this set of crops
    EnableSet(Agent:?agent) : void=                     
        for(C : Crops){spawn{C.EnableCrop()}}                         
    
    #Initialized all crops in set    
    InitializeCrops(): void=                                     
        for(C: Crops):
            set C.GameManager = GameManager 
            set C.ResourceManager = ResourceManager
            set C.PickUpAudio = PickUpAudio
            set C.CropXP = CropXP
            set C.CropTracker = CropTracker
            set C.CropResources = CropResources
            C.CropReadyProp.Hide()
            C.CropProp.Hide()

    #Resets all crops in set
    ResetCrops() : void=
        for(C : Crops):
            C.CropReadyProp.Hide()
            C.CropProp.Hide()
            C.CropMutator.Disable()

#Main creative device class
Farm_Manager := class(creative_device):
    #Base Stuff
    TT_FM_Device_GameManager<localizes>:message = "Your Game Manager"
    @editable GameManager : Game_Manager = Game_Manager{}   
    
    TT_FM_Device_ResourceManager<localizes>:message = "Your Resource Manager"
    @editable ResourceManager : Resource_Manager = Resource_Manager{}
    
    TT_FM_Device_PlotManager<localizes>:message = "Your Plot Manager"
    @editable PlotManager : Plot_Manager = Plot_Manager{}

    #Crop Sets
    TT_FM_Device_CropSets<localizes>:message = "An array of crop sets"
    @editable CropSets : []CropSet = array{}                                    

    #Activating devices
    TT_FM_Device_PickupAudio<localizes>:message = "The audio player device which is used to play the pickup audio\n*Required Settings*\n Can be heard by : Instigator Only\n Play Location : Instigating Player"
    @editable PickupAudio : audio_player_device = audio_player_device{}
    
    TT_FM_Device_CropXP<localizes>:message = "The accolades device which is used to award the player xp for collecting the crop"
    @editable CropXP : accolades_device = accolades_device{} 
    
    TT_FM_Device_CropTracker<localizes>:message = "The tracker device which is incremented when a crop is collected\n*Required Settings*\nStat to track : Events"
    @editable CropTracker : tracker_device = tracker_device{} 

    #Initializes all crops
    OnBegin<override>()<suspends>:void=
        Sleep(1.0)
        spawn{WaitForReset()}
        for(CS : CropSets):               
            set CS.GameManager = GameManager  
            set CS.ResourceManager = ResourceManager
            set CS.PickUpAudio = PickupAudio
            set CS.CropXP = CropXP
            set CS.CropTracker = CropTracker
            CS.InitializeCrops()
            CS.EnableTrigger.TriggeredEvent.Subscribe(CS.EnableSet)

    #Resets all crops when plot resets
    WaitForReset()<suspends> : void=
        loop:
            PlotManager.ResetPlotEvent.Await()
            Sleep(0.0)
            for(CS : CropSets){CS.ResetCrops()}