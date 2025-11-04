using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Colors/NamedColors }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }

#THIS DEVICE GRANTS PLAYERS REWARDS WHEN HIT

#A level that can be upgraded to in a crate
CrateLevel:= class<concrete>():     
    TT_Crate_CrateLevel_CollectResources<localizes>:message = "The resources that are collected when the crate is hit"
    @editable CollectResources : []GainableResource = array{}

    TT_Crate_CrateLevel_Target<localizes>:message = "The target which the crate will be upgraded when reached"
    @editable Target : int = 0

#A class for each crate
Crate:= class<concrete>():
    #Base Stuff
    var GameManager : Game_Manager = Game_Manager{} 
    var ResourceManager : Resource_Manager = Resource_Manager{}
    var PlotManager : Plot_Manager = Plot_Manager{}
    var AnimationFrames : []keyframe_delta = array{}

    #Crate Level Stuff
    TT_Crate_Crate_CrateLevels<localizes>:message = "An array of crate levels"
    @editable CrateLevels : []CrateLevel = array{}
    var CurrentLevel : CrateLevel = CrateLevel{}                                            
    var LevelIDX : int = 0                                                                  
    var CurrentTargetAmount : int = 0

    #Crate devices
    TT_Crate_Crate_PropManip<localizes>:message = "A prop manipulator device that is used to detect when the crate is hit"
    @editable PropManip : prop_manipulator_device = prop_manipulator_device{}    
    
    TT_Crate_Crate_CrateProp<localizes>:message = "A creative prop which represents the crate"
    @editable CrateProp : creative_prop = creative_prop{}    
    
    TT_Crate_Crate_CrateVFX<localizes>:message = "A vfx spawner device which is used to spawn a vfx when the crate is hit"
    @editable CrateVFX : vfx_spawner_device = vfx_spawner_device{}  

    TT_Crate_Crate_CrateSound<localizes>:message = "An audio player device which is used to play a sound when the crate is hit"
    @editable CrateSound : audio_player_device = audio_player_device{} 

    TT_Crate_Crate_CrateXP<localizes>:message = "An accolades device which is used to award xp when the crate is hit"
    @editable CrateXP : accolades_device = accolades_device{}

    #Settings to control different options in the crate
    TT_Crate_Crate_CrateSettings<localizes>:message = "The settings for the crate"
    @editable CrateSettings : CrateSetting = CrateSetting{}

    #Initializes all crate values and level
    InitializeCrate() : void=
        if(NewLevel := CrateLevels[LevelIDX]):
            set CurrentLevel = NewLevel
            set CurrentTargetAmount = NewLevel.Target

        CrateSettings.UpgradeSettings.UpgradeDisplayBillboard.SetText(MasterS2M("Hits until upgrade: {CurrentTargetAmount}"))
        InitializeAnimation()
        PropManip.DamagedEvent.Subscribe(CheckDelay)     
        CrateSettings.UpgradeSettings.UpgradeCrateTrigger.TriggeredEvent.Subscribe(UpgradeLevelTri)

    #Plays VFX when crate is hit
    PlayVFX()<suspends> : void=                
        CrateVFX.Enable()
        Sleep(0.2)
        CrateVFX.Disable()

    #Upgrades crate level for trigger
    UpgradeLevelTri(Agent : ?agent) : void=
        if(NAgent := Agent?):
            if(CrateSettings.UpgradeSettings.UpgradeOn = UpgradeType.OnTrigger){UpgradeLevel(NAgent)}

    #Upgrades the crate level
    UpgradeLevel(Agent:agent) : void=        
        set LevelIDX += 1
        if(NewL := CrateLevels[LevelIDX]):
            set CurrentLevel = NewL
            set CurrentTargetAmount = NewL.Target
        CrateSettings.UpgradeSettings.UpgradeDisplayHUD.Show(Agent)

    #Checks the crate level and updates values/level
    CheckLevel(Agent:agent) : void=
        if(CrateSettings.UpgradeSettings.UpgradeOn = UpgradeType.OnTargetReached):
            if(CurrentTargetAmount - 1 <= 0 and not LevelIDX = CrateLevels.Length - 1):
                UpgradeLevel(Agent)
            else:
                set CurrentTargetAmount -= 1

            if(LevelIDX = CrateLevels.Length - 1):
                CrateSettings.UpgradeSettings.UpgradeDisplayBillboard.SetText(MasterS2M("Max"))
            else: 
                CrateSettings.UpgradeSettings.UpgradeDisplayBillboard.SetText(MasterS2M("{CurrentTargetAmount}"))




    #Checks if delay is enabled and activated when hit
    CheckDelay(Agent:agent) : void=
        for(PlotPlayer : PlotManager.PlotsPlayer):
            if(Agent = PlotPlayer):
                if(CrateSettings.DelaySettings.DelayBetweenHits?):
                    if(not CrateSettings.DelaySettings.CurrentDelay?):
                        OnHit(Agent)
                        spawn{CrateSettings.DelaySettings.StartDelay()}
                else:
                    OnHit(Agent)

                

    #Activates when crate is hit
    OnHit(Agent:agent) : void=  
        if(RP := ResourceManager.PlayersMap[Agent]):
            #Activates and collects hit devices
            CrateXP.Award(Agent)
            CrateSound.Play()              
            spawn{PlayVFX()}
            if(CrateSettings.CollectionSettings.CollectOn = CrateCollectionType.OnHit){RP.Collect(CurrentLevel.CollectResources)}
            if(CrateSettings.GrowthAnimationSettings.Enabled?){GrowthAnimation()}
            CheckLevel(Agent)
        
    
    #Initializes the crates hit animation
    InitializeAnimation() : void=
        TargetScale : float = CrateSettings.GrowthAnimationSettings.AnimationScaleAmount
        InverseTargetScale : float = 1.0/CrateSettings.GrowthAnimationSettings.AnimationScaleAmount

        DownScaleKeyFrame : keyframe_delta = keyframe_delta{
            DeltaLocation := vector3{ X:= 0.0, Y:= 0.0, Z:= 0.0}
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3{X:= TargetScale, Y:= TargetScale, Z:= TargetScale}
            Time := CrateSettings.GrowthAnimationSettings.AnimationScaleTime
            Interpolation := EaseIn
        }

        UpScaleKeyFrame : keyframe_delta = keyframe_delta{
            DeltaLocation := vector3{ X:= 0.0, Y:= 0.0, Z:= 0.0}
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3{X:= InverseTargetScale, Y:= InverseTargetScale, Z:= InverseTargetScale}
            Time := CrateSettings.GrowthAnimationSettings.AnimationScaleTime
            Interpolation := EaseIn
        }
        set AnimationFrames = array{ DownScaleKeyFrame,UpScaleKeyFrame}

    #Plays the animation for crate
    GrowthAnimation() : void=                           
        if(PropAnimController := CrateProp.GetAnimationController[]):
            AnimState := PropAnimController.GetState()
            if(AnimState = animation_controller_state.AnimationNotSet or AnimState = animation_controller_state.Stopped):
                PropAnimController.SetAnimation(AnimationFrames,?Mode := animation_mode.OneShot)
                PropAnimController.Play()

    #Resets the crate
    Reset() : void=
        set LevelIDX = 0
        if(NewL := CrateLevels[LevelIDX]):
            set CurrentLevel = NewL
            set CurrentTargetAmount = NewL.Target
        CrateSettings.UpgradeSettings.UpgradeDisplayBillboard.SetText(MasterS2M("Hits until upgrade: {CurrentTargetAmount}"))

#Main creative device
Crate_Manager := class(creative_device):
    #Base Stuff
    @editable GameManager : Game_Manager = Game_Manager{}
    @editable ResourceManager : Resource_Manager = Resource_Manager{}
    @editable PlotManager : Plot_Manager = Plot_Manager{}

    #Array of crates
    @editable Crates : []Crate = array{}

    #Initializes Crates
    OnBegin<override>()<suspends>:void=
        spawn{WaitForReset()}
        for(C : Crates):
            C.InitializeCrate()
            set C.GameManager = GameManager
            set C.PlotManager = PlotManager
            set C.ResourceManager = ResourceManager

    #Waits for plot to reset and restets all crates
    WaitForReset()<suspends> : void=
        loop:
            PlotManager.ResetPlotEvent.Await()
            Sleep(0.0)
            for(C:Crates){C.Reset()}

#Settings used to control crate
CrateSetting:= class<concrete>():
    TT_Crate_CrateSetting_DelaySettings<localizes>:message = "The settings for the delay between crate hits"
    @editable DelaySettings : DelaySetting = DelaySetting{}

    TT_Crate_CrateSetting_GrowthAnimationSettings<localizes>:message = "The settings for the growth/hit animation of the crate"
    @editable GrowthAnimationSettings : ScaleAnimationSetting = ScaleAnimationSetting{}
    
    TT_Crate_CrateSetting_CollectionSettings<localizes>:message = "The settings for the collection of resources from a crate"
    @editable CollectionSettings : CollectionSetting = CollectionSetting{}

    TT_Crate_CrateSetting_UpgradeSettings<localizes>:message = "The settings for the upgrade of the crate"
    @editable UpgradeSettings : UpgradeSetting = UpgradeSetting{}

#Settings used to control delay between crate hits
DelaySetting:= class<concrete>():
    @editable DelayBetweenHits : logic = false
    @editable DelayDuration : float = 0.0
    var CurrentDelay : logic = false
    StartDelay()<suspends> : void=
        set CurrentDelay = true
        Sleep(DelayDuration)
        set CurrentDelay = false

#Settings that control how a crate is upgraded
UpgradeSetting:= class<concrete>():
    TT_Crate_UpgradeSetting_UpgradeOn<localizes>:message = "The type of upgrade that will trigger the crate to upgrade\nOnTrigger: When the a trigger device is triggered\nOnTargetReached: When the crate reaches its target"
    @editable UpgradeOn : UpgradeType = UpgradeType.OnTargetReached

    TT_Crate_UpgradeSetting_UpgradeDisplayBillboard<localizes>:message = "A billboard device which is used to display the current progress  of the crate"
    @editable UpgradeDisplayBillboard : billboard_device = billboard_device{}
    
    TT_Crate_UpgradeSetting_UpgradeDisplayHUD<localizes>:message = "A hud message device which is used to display the upgrade message to the player\n*Required Settings*\nMessage Recipient : Triggering Player"
    @editable UpgradeDisplayHUD : hud_message_device = hud_message_device{}
    
    TT_Crate_UpgradeSetting_UpgradeCrateTrigger<localizes>:message = "A trigger device which is used to signal the crate to upgrade *Only works if UpgradeOn is set to OnTrigger*"
    @editable UpgradeCrateTrigger : trigger_device = trigger_device{}                    

#Setting that controls how resources are collected from a crate
CollectionSetting:= class<concrete>():
    @editable CollectOn : CrateCollectionType = CrateCollectionType.OnHit

#Setting that controls how a crates animation appears
ScaleAnimationSetting:= class<concrete>():
    @editable Enabled : logic = false
    @editable AnimationScaleAmount : float = 1.0
    @editable AnimationScaleTime : float = 1.0

#Differnt upgrade types
UpgradeType := enum:
    OnTargetReached
    OnTrigger

#Different Collection types
CrateCollectionType := enum:
    OnHit
    OnUpgrade