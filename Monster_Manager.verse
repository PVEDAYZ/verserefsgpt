using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors/NamedColors }
using { /Fortnite.com/Characters}

#THIS DEVICE CONTROLS CUSTOM CREATURES THAT WILL AWARD PLAYERS A RESOURCE WHEN ELIMINATED

Monster_Manager := class(creative_device):
    TT_MM_Device_GameManager<localizes>:message = "Your Game Manager"
    @editable GameManager : Game_Manager = Game_Manager{}   
    
    TT_MM_Device_ResourceManager<localizes>:message = "Your Resource Manager"
    @editable ResourceManager : Resource_Manager = Resource_Manager{}
    
    #Awarded on elimination
    TT_MM_Device_MonsterXP<localizes>:message = "The accolades device which is used to award the player xp for eliminating the monster"
    @editable MonsterXP : accolades_device = accolades_device{}
    
    TT_MM_Device_CollectResources<localizes>:message = "The resources that are collected when the monster is eliminated"
    @editable CollectResources : []GainableResource = array{}
    
    TT_MM_Device_MonsterHUD<localizes>:message = "The hud message device which is displayed when a monster is eliminated\n*Required Settings*\nMessage Recipient : Triggering Player"
    @editable MonsterHUD : hud_message_device = hud_message_device{}     

    #Spawners used
    TT_MM_Device_MonsterSpawners<localizes>:message = "List of creature spawner devices that are used to spawn the monsters"
    @editable MonsterSpawners : []creature_spawner_device = array{}      
    
    TT_MM_Device_NPCSpawners<localizes>:message = "List of npc spawner devices that are used to spawn the monsters"
    @editable NPCSpawners : []npc_spawner_device = array{}
      

    #Props used to customize monster
    TT_MM_Device_MonsterWalkingProp<localizes>:message = "The prop that is used to display the monster\'s walking animation"
    @editable MonsterWalkingProp : creative_prop_asset = DefaultCreativePropAsset

    TT_MM_Device_MonsterAttackingProp<localizes>:message = "The prop that is used to display the monster\'s attacking animation"
    @editable MonsterAttackingProp : creative_prop_asset = DefaultCreativePropAsset
    
    TT_MM_Device_MonsterIdleProp<localizes>:message = "The prop that is used to display the monster\'s idle animation"
    @editable MonsterIdleProp : creative_prop_asset = DefaultCreativePropAsset

    #Initializes all spawners
    OnBegin<override>()<suspends>:void=
        for(Spawner :MonsterSpawners):                         
            Spawner.SpawnedEvent.Subscribe(SpawnedR)       
            Spawner.EliminatedEvent.Subscribe(Eliminated)   
        for(NPCS : NPCSpawners):
            NPCS.EliminatedEvent.Subscribe(Eliminated)

    #Activated when a monster is eliminated and grants rewards to player
    Eliminated(Result : device_ai_interaction_result) : void=
        if(Agent := Result.Source?):
            if(RP :=ResourceManager.PlayersMap[Agent]):
                RP.Collect(CollectResources)           
                MonsterXP.Award(Agent)                                          
                MonsterHUD.Show(Agent)                                      

    #Precursor to Spawned Function, activated when a zombie is spawned
    SpawnedR(Agent:agent) : void=
        spawn{Spawned(Agent)}
            
    #Spawns new props and replaces the zombie with them
    Spawned(Agent:agent)<suspends> : void=                                         
        if(FC := Agent.GetFortCharacter[]):
            FC.Hide()                                                              
            ZombPos := FC.GetTransform().Translation - vector3{Z:=80.0}            

            #Spawns Props at creatures location
            MaybeWalkProp := SpawnProp(MonsterWalkingProp,ZombPos,IdentityRotation())         
            MaybeAttackProp := SpawnProp(MonsterAttackingProp,ZombPos,IdentityRotation())
            MaybeIdleProp := SpawnProp(MonsterIdleProp,ZombPos,IdentityRotation())

            #Gets the props spawned
            if:
                WalkProp := MaybeWalkProp(0)?
                AttackProp := MaybeAttackProp(0)?
                IdleProp := MaybeIdleProp(0)?
            then:
                var CurrentState : int = 0                                                                                  
                race:
                    #Waits for creature to die
                    block:                              
                        loop:
                            Sleep(0.1)
                            if(not FC.IsActive[]):              
                                WalkProp.Dispose()
                                AttackProp.Dispose()
                                IdleProp.Dispose()                   
                                return

                    #Checks if creature is close enough to any players to begin attack animation
                    block:                                      
                        loop:
                            Sleep(0.1)
                            ZombP := FC.GetTransform().Translation - vector3{Z:=80.0}
                            for(Player : GetPlayspace().GetPlayers(), PC:=Player.GetFortCharacter[]):
                                PlayerP := PC.GetTransform().Translation
                                if(Distance(PlayerP,ZombP) < 150.0):
                                    WalkProp.Hide()
                                    IdleProp.Hide()
                                    AttackProp.Show()
                                    set CurrentState = 3
           
                    #If attack animation is not playing, checks if the creature is idle or moving and shows props accordingly
                    block:                                      
                        loop:
                            Sleep(0.1)
                            ZombP := FC.GetTransform().Translation - vector3{Z:=80.0}
                            var TempLocation : vector3 = vector3{}
                            set TempLocation = ZombPos
                            Sleep(0.1)
                            NewZombP := FC.GetTransform().Translation - vector3{Z:=80.0}
                            if(Distance(NewZombP,ZombP) > 0.0,CurrentState<>3):
                                WalkProp.Show()
                                IdleProp.Hide()
                                AttackProp.Hide()
                                set CurrentState = 2
                            else:
                                WalkProp.Hide()
                                IdleProp.Show()
                                AttackProp.Hide()
                                set CurrentState = 1

                    #Main loop to move all props to the zombies location
                    loop:                                        
                        Sleep(0.1)
                        ZombP := FC.GetTransform().Translation - vector3{Z:=80.0}
                        ZombR := FC.GetTransform().Rotation
                        spawn:
                            WalkProp.MoveTo(ZombP,ZombR,0.1)
                        spawn:
                            AttackProp.MoveTo(ZombP,ZombR,0.1)
                        spawn:
                            IdleProp.MoveTo(ZombP,ZombR,0.1)
