using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

#THIS SCRIPT COLLECTS RESOURCES FOR A PLAYER WHEN IN A SPECIFIED ZONE

AFK_Manager := class(creative_device):
    #Base Stuff
    TT_AFK_GameManager<localizes>:message = "Your Game Manager device"
    @editable GameManager : Game_Manager = Game_Manager{}  

    TT_AFK_ResourceManager<localizes>:message = "Your Resource Manager Device"
    @editable ResourceManager : Resource_Manager = Resource_Manager{}

    var LeftEvent : event(agent) = event(agent){}
    
    
    #Devices
    TT_AFK_AFKCin<localizes>:message = "The cinematic sequence device that plays when a player enters the zone\n*Required Settings*\nVisibility: Instigator Only"
    @editable AFKCin : cinematic_sequence_device = cinematic_sequence_device{}

    TT_AFK_AFKMutator<localizes>:message = "The mutator zone device that detects when the player enters the AFK zone"
    @editable AFKMutator : mutator_zone_device = mutator_zone_device{}   

    TT_AFK_AFKHUD<localizes>:message = "The hud message device that displays a message when the player is in the AFK zone\n*Required Settings*\nMessage Ricipient : Triggering Player"
    @editable AFKHUD : hud_message_device = hud_message_device{}     

    #Settings
    TT_AFK_AFKCollectionSettings<localizes>:message = "The settings for the resources collected when the player is in the AFK zone"
    @editable AFKCollectionSettings : AFKCollectionSetting = AFKCollectionSetting{}

    
    
    OnBegin<override>()<suspends>:void=
        #Activates different actions based on mutator events
        AFKMutator.AgentEntersEvent.Subscribe(OnEntered)     
        AFKMutator.AgentExitsEvent.Subscribe(OnExit)     
        AFKMutator.AgentBeginsEmotingEvent.Subscribe(StartDance)     
        AFKMutator.AgentEndsEmotingEvent.Subscribe(StopDance)        

    #Handles when a player enters zone
    OnEntered(Agent:agent) : void=      
        AFKCin.Play(Agent)       
        AFKHUD.Show(Agent)       
        spawn{Activate(Agent)}

    #Handles when a player exits zone
    OnExit(Agent:agent ) : void=     
        AFKCin.Stop(Agent)      
        AFKHUD.Hide()            
        LeftEvent.Signal(Agent)

    # Loop that collects resources for the player while in zone
    Activate(Agent:agent)<suspends> : void=
        if(CP := Custom_Player[GameManager.PlayersMap[Agent]], RP := ResourceManager.PlayersMap[Agent]):
            race:
                #Waits for the player to leave the mutator and ends loop
                block:
                    loop:
                        LeavingPlayer := LeftEvent.Await()
                        if(LeavingPlayer = Agent):
                            for(Re : AFKCollectionSettings.CollectionResources):
                                if(Re.CollectionType = AFKCollectionType.ResourceBoost):
                                    if(CP.IsBoosted?):
                                        CP.RemoveAFKBoost(ResourceManager,array{Re})
                            set CP.IsBoosted = false
                            break

                #Main loop for collection resources
                loop:
                    #Collects resources / boosts resources when player is dancing
                    if(AFKCollectionSettings.RequiresDance?):
                        if(CP.IsDancing?):
                            for(Re : AFKCollectionSettings.CollectionResources):
                                if(Re.CollectionType = AFKCollectionType.ResourceBoost , not CP.IsBoosted?):
                                    CP.BoostAFKResources(ResourceManager,array{Re})
                                    set CP.IsBoosted=true

                                else if(Re.CollectionType = AFKCollectionType.ResourceCollect):
                                    if(Re.CollectIdleAmountInstead?):
                                        CP.CollectAtmResources(ResourceManager,array{ATMResource{ResourceName := Re.ResourceName, AutoCollect := true}})
                                    else:
                                        RP.Collect(array{GainableResource{ResourceName := Re.ResourceName , Amount := Re.Amount, EffectIdleAmount := false }})
            
                    #Collects resources / boosts resources when player is in zone
                    else:
                        for(Re : AFKCollectionSettings.CollectionResources):
                            if(Re.CollectionType = AFKCollectionType.ResourceBoost , not CP.IsBoosted?):
                                CP.BoostAFKResources(ResourceManager,array{Re})
                                set CP.IsBoosted=true

                            else if(Re.CollectionType = AFKCollectionType.ResourceCollect):
                                if(Re.CollectIdleAmountInstead?):
                                    CP.CollectAtmResources(ResourceManager,array{ATMResource{ResourceName := Re.ResourceName, AutoCollect := true}})
                                else:
                                    RP.Collect(array{GainableResource{ResourceName := Re.ResourceName , Amount := Re.Amount, EffectIdleAmount := false }})

                    #waits specified amount between resource awards
                    Sleep(AFKCollectionSettings.CollectionTime)

    #Activates when the player begins dancing
    StartDance(Agent:agent) : void=     
        if(CP := Custom_Player[GameManager.PlayersMap[Agent]]):
            if(CP.IsDancing = false){set CP.IsDancing = true}      
            
    #Activates when the player stops dancing
    StopDance(Agent:agent) : void=      
        if(CP := Custom_Player[GameManager.PlayersMap[Agent]]):
            if(CP.IsDancing = true){set CP.IsDancing = false}         
            
#Settings that control what/how resources are collected
AFKCollectionSetting:= class<concrete>():
    TT_AFK_AFKCollectionSetting_RequiresDance<localizes>:message = "If enabled, the player must be dancing to collect resources"
    @editable RequiresDance : logic = false

    TT_AFK_AFKCollectionSetting_CollectionResources<localizes>:message = "The resources that are collected when the player is in the AFK zone"
    @editable CollectionResources : []AFKResource = array{}
    @editable CollectionTime : float = 0.0

#Resource that is collected
AFKResource := class<concrete>(BaseResource):
    TT_AFK_AFKResource_CollectionType<localizes>:message = "How the resource is collected (Boost or fixed amount)"
    @editable CollectionType : AFKCollectionType = AFKCollectionType.ResourceBoost

    TT_AFK_AFKResource_Amount<localizes>:message = "The amount of the resource that is collected *Only works if collection type is set to ResourceCollect"
    @editable Amount : float = 0.0

    TT_AFK_AFKResource_CollectIdleAmountInstead<localizes>:message = "If enabled, 'Amount' will be added to player\'s idle amount instead of total resource amount"
    @editable CollectIdleAmountInstead : logic = false
    
#Different collection types
AFKCollectionType := enum:
    ResourceBoost
    ResourceCollect


#Extensions =============================================================================================================================================================

(InPlayer : Base_Player).BoostAFKResources(RM : Resource_Manager , BoostResources : []AFKResource) : void=
    if(RP := RM.PlayersMap[InPlayer.Player]):
        for(Re : RP.Resources):
            for(BoostRe : BoostResources):
                if(BoostRe.ResourceName = Re.ResourceName):
                    NewBoostResource := BoostResource:
                        ResourceName := BoostRe.ResourceName
                        Amount := BoostRe.Amount
                    RP.Boost(array{NewBoostResource})


(InPlayer : Base_Player).RemoveAFKBoost(RM : Resource_Manager , RemoveResources : []AFKResource) : void=
    if(RP := RM.PlayersMap[InPlayer.Player]):
        for(Re : RP.Resources):
            for(RemoveRe : RemoveResources):
                if(RemoveRe.ResourceName = Re.ResourceName):
                    NewBoostResource := BoostResource:
                        ResourceName := RemoveRe.ResourceName
                        Amount := RemoveRe.Amount
                    RP.RemoveBoost(array{NewBoostResource})
                    
