using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

#THIS DEVICE CONVERTS ONE OR MORE RESOURCES TO ANOTHER

Converter := class<concrete>():
    #Base Stuff
    var GameManager : Game_Manager = Game_Manager{}   
    var ResourceManager : Resource_Manager = Resource_Manager{}
    #Activating Devices
    var FailureHUD : hud_message_device = hud_message_device{}                 
    var ConvertXP : accolades_device = accolades_device{}                       
    var SuccessHUD : hud_message_device = hud_message_device{}       
    
    #Trigger used to activate converter
    TT_Convertor_ConverterTrigger<localizes>:message = "A trigger device that converts resources"
    @editable ConverterTrigger : trigger_device = trigger_device{}               

    #Amount of resources that are spent and gained per conversion
    TT_Convertor_CostResources<localizes>:message = "The resources that are spent per conversion"
    @editable CostResources : []SpendableResource = array{}                             
    
    TT_Convertor_GainResources<localizes>:message = "The resources that are gained per conversion"
    @editable GainResources : []GainableResource = array{}                             

    #Settings to control different converter options
    TT_Convertor_ConverterSettings<localizes>:message = "Settings to control different converter options"
    @editable ConverterSettings : ConverterSetting = ConverterSetting{}
  

    #Function that gets the element with the lowest amount in an array
    GetLowestInt(Arr : []int) : int=
        var LargestInt : int = 0
        var LowestInt : int = 0
        for(I : Arr):
            if(I > LargestInt):
                set LargestInt = I

        set LowestInt = LargestInt
        for(I : Arr):
            if(I < LowestInt):
                set LowestInt = I
        return LowestInt

    #Converts resources
    TryConversion(MAgent:?agent) : void=
        if(Agent := MAgent? , CP := GameManager.PlayersMap[Agent], RP := ResourceManager.PlayersMap[Agent]):

           #Gets the option that is selected and based off of the options settings converts the amount
            for(Option : ConverterSettings.ConvertOptions):
                if(Option.Selected?):
                    #If option is converting all
                    if(Option.ConvertAll?):
                        var SuccessAmounts : []int = array{}
                        for(Re : RP.Resources):
                            for(CosRes : CostResources):
                                if(CosRes.ResourceName = Re.ResourceName):
                                    if(CosRes.EffectIdleAmount?):
                                        if(SuccessAmount := Int[Re.ResourceIdleAmount / CosRes.Amount]){set SuccessAmounts += array{SuccessAmount}}    
                                    else:
                                        if(SuccessAmount := Int[Re.ResourceAmount / CosRes.Amount]){set SuccessAmounts += array{SuccessAmount}}
                                            
                        LowestSuccessCount := GetLowestInt(SuccessAmounts)
                        if(LowestSuccessCount > 0):
                            SuccessHUD.Show(Agent)
                            ConvertXP.Award(Agent)
                            for(CosRes : CostResources):
                                NewAmount := CosRes.Amount * LowestSuccessCount
                                NewGainRes := SpendableResource{ResourceName := CosRes.ResourceName , EffectIdleAmount := CosRes.EffectIdleAmount, RemoveResource := CosRes.RemoveResource, Amount := NewAmount}
                                RP.Spend(array{NewGainRes})

                            for(GainRes : GainResources):
                                NewAmount := GainRes.Amount * LowestSuccessCount
                                NewGainRes := GainableResource{ResourceName := GainRes.ResourceName , EffectIdleAmount := GainRes.EffectIdleAmount, Amount := NewAmount}
                                RP.Collect(array{NewGainRes})

                        else:
                            FailureHUD.Show(Agent)

                    #If option is converting a multiplier
                    else:
                        var NewCostResources : []SpendableResource = array{}
                        var NewGainResources : []GainableResource = array{}
                        for(SpendRe : CostResources):
                            NewRe := SpendableResource{ResourceName := SpendRe.ResourceName,EffectIdleAmount := SpendRe.EffectIdleAmount, RemoveResource := SpendRe.RemoveResource, Amount := SpendRe.Amount * Option.ConvertMultiplier}
                            set NewCostResources += array{NewRe}

                        for(GainRe : GainResources):
                            NewRe := GainableResource{ResourceName := GainRe.ResourceName,EffectIdleAmount := GainRe.EffectIdleAmount, Amount := GainRe.Amount * Option.ConvertMultiplier, ShowPopUp := GainRe.ShowPopUp, OverridePopUpSettings := GainRe.OverridePopUpSettings}
                            set NewGainResources += array{NewRe}

                        HasAmounts := RP.Check(NewCostResources)
                        if(HasAmounts?):      
                            RP.Spend(NewCostResources)
                            RP.Collect(NewGainResources)  
                            SuccessHUD.Show(Agent)
                            ConvertXP.Award(Agent)
                        else:
                            FailureHUD.Show(Agent)
            
#Main creative device class
Convert_Manager := class(creative_device):

    TT_CVM_GameManager<localizes>:message = "Your Game Manager device"
    @editable GameManager : Game_Manager = Game_Manager{}     
    
    TT_CVM_ResourceManager<localizes>:message = "Your Resource Manager device"
    @editable ResourceManager : Resource_Manager = Resource_Manager{}
    
    #Base Devices
    TT_CVM_FailureHUD<localizes>:message = "The hud message device that displays a message when a conversion fails\n*Required Settings*\nMessage recipient : Triggering Player"
    @editable FailureHUD : hud_message_device = hud_message_device{}    
    

    TT_CVM_SuccessHUD<localizes>:message = "The hud message device that displays a message when a conversion is successful\n*Required Settings*\nMessage recipient : Triggering Player"
    @editable SuccessHUD : hud_message_device = hud_message_device{}

    TT_CVM_ConvertXP<localizes>:message = "The accolades device that awards xp when a conversion is successful\n*Required Settings*\nTriggering Player Only : True"
    @editable ConvertXP : accolades_device = accolades_device{}   
    
    #All converters
    TT_CVM_Converters<localizes>:message = "Array of converters that are used to convert resources"
    @editable Converters : []Converter = array{}   


    OnBegin<override>()<suspends>:void=
        #Initiliazes converters
        for(Convert : Converters):                                              
            set Convert.GameManager = GameManager
            set Convert.ResourceManager = ResourceManager
            set Convert.FailureHUD = FailureHUD
            set Convert.ConvertXP = ConvertXP
            set Convert.SuccessHUD = SuccessHUD

            #Activates when button is pressed
            Convert.ConverterTrigger.TriggeredEvent.Subscribe(Convert.TryConversion)        

            #Sets up different converter options for each converter
            Convert.ConverterSettings.UnselectAll()
            for(O : Convert.ConverterSettings.ConvertOptions):
                O.Trigger.TriggeredEvent.Subscribe(Convert.ConverterSettings.UnselectAllPre)
                O.Trigger.TriggeredEvent.Subscribe(O.SelectPre)

            #Selects the first option in the array
            if(FirstO := Convert.ConverterSettings.ConvertOptions[0]){spawn{FirstO.Select()}}
            

#Different settings for each converter
ConverterSetting := class<concrete>():
    TT_Convertor_ConverterSetting_ConvertOptions<localizes>:message = "The options for the converter"
    @editable ConvertOptions : []ConvertOption = array{}

    UnselectAllPre(Agent:?agent) : void=
        UnselectAll()

    UnselectAll() : void=
        for(O : ConvertOptions):
            set O.Selected = false
            O.Prop.Hide()

#Option/Multiplier for the converter
ConvertOption := class<concrete>():
    TT_Convertor_ConvertOption_ConvertAll<localizes>:message = "If enabled, will convert all the resources for as many times as possible"
    @editable ConvertAll : logic = false
    
    TT_Convertor_ConvertOption_Trigger<localizes>:message = "The trigger device that is used to select the option"
    @editable Trigger : trigger_device = trigger_device{}
    
    TT_Convertor_ConvertOption_ConvertMultiplier<localizes>:message = "The multiplier for the converter"
    @editable ConvertMultiplier : float = 0.0
    
    TT_Convertor_ConvertOption_Prop<localizes>:message = "The prop that is shown if this option is selected"
    @editable Prop : creative_prop = creative_prop{}

    var Selected : logic = false

    SelectPre(Agent:?agent) : void=
        spawn{Select()}

    Select()<suspends> : void=
        Sleep(0.1)
        set Selected = true
        Prop.Show()