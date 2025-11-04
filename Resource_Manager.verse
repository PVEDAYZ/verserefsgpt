using { /Verse.org/Simulation }
using { /Fortnite.com/UI }
using { /Verse.org/Assets }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }



(InResource : GeneralResource).ToPopUpData() : PopUpData=
    PopUpData:
        PopUpName := InResource.ResourceName
        PopUpValue := InResource.ResourceAmount
        PopUpImage := if(RUI := InResource.UISettings?){RUI.ItemPopUpTexture}else{MasterAssets.Placeholder}

MessageCombine<localizes>(Message1 : message, Message2 : message,Message3 : message , Message4 : message) : message = "{Message1}{Message2}{Message3}{Message4}"
     

Persistence_Manager := interface():
    InitializePlayer(Player:player):void

    GetPlayerStats(Agent:agent)<decides><transacts>:player_stats_table

    RecordPlayerStat(Agent:agent, Stat:stat_type, ?Score:float = 0.0):void

    SetPlayerStat(Agent:agent, Stat:stat_type, ?Score:float = 0.0):void

    RecordPlayerArrStat(Agent:agent, Stat:stat_type, ?Score:int = 0):void

    SetPlayerArrStat(Agent:agent, Stat:stat_type, ?Score:[]int):void

    ResetPlayerArrStat(Agent:agent, Stat:stat_type):void

    RemovePlayerArrStat(Agent:agent, Stat:stat_type, ?Score:int = 0):void

    ReplacePlayerArrStat(Agent:agent, Stat:stat_type, ?ReplaceInt:int = 0 , ?Score:int = 0):void

Base_Persistence_Manager := class(Persistence_Manager):

    #Initializes a player into the player map
    InitializePlayer<override>(Player:player):void=
        if:
            Player.IsActive[]
            not PlayerStatsMap[Player]
            set PlayerStatsMap[Player] = player_stats_table{}

            #Gets the players current stats
    GetPlayerStats<override>(Agent:agent)<decides><transacts>:player_stats_table=
        var PlayerStats:player_stats_table = player_stats_table{}
        if:
            Player := player[Agent]
            Player.IsActive[]
            PlayerStatsTable := PlayerStatsMap[Player]
            set PlayerStats = MakePlayerStatsTable(PlayerStatsTable)
        PlayerStats

    RecordPlayerStat<override>(Agent:agent, Stat:stat_type, ?Score:float = 0.0):void=
        return

    SetPlayerStat<override>(Agent:agent, Stat:stat_type, ?Score:float = 0.0):void=
        return

    RecordPlayerArrStat<override>(Agent:agent, Stat:stat_type, ?Score:int = 0):void=
        return

    SetPlayerArrStat<override>(Agent:agent, Stat:stat_type, ?Score:[]int):void=
        return

    ResetPlayerArrStat<override>(Agent:agent, Stat:stat_type):void=
        return

    RemovePlayerArrStat<override>(Agent:agent, Stat:stat_type, ?Score:int = 0):void=
        return

    ReplacePlayerArrStat<override>(Agent:agent, Stat:stat_type, ?ReplaceInt:int = 0 , ?Score:int = 0):void=
        return

Resource_Persistence_Manager := class<concrete>(Base_Persistence_Manager):

    #Increases a stat by a specific amount
    RecordPlayerStat<override>(Agent:agent, Stat:stat_type, ?Score:float = 0.0):void=
        if:
            Player := player[Agent]
            Player.IsActive[]
            PlayerStatsTable := PlayerStatsMap[Player]
            
            if(Stat.Name = "Rebirths"):
                RebirthsStat := PlayerStatsTable.Rebirths
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Rebirths := RebirthsStat + Score
                    
            else if(Stat.Name = "Currency1"):
                Currency1Stat := PlayerStatsTable.Currency1
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency1 := Currency1Stat + Score

            else if(Stat.Name = "Currency2"):
                Currency2Stat := PlayerStatsTable.Currency2
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency2 := Currency2Stat + Score

            else if(Stat.Name = "Currency3"):
                Currency3Stat := PlayerStatsTable.Currency3
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency3 := Currency3Stat + Score

            else if(Stat.Name = "Currency4"):
                Currency4Stat := PlayerStatsTable.Currency4
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency4 := Currency4Stat + Score

            else if(Stat.Name = "Currency5"):
                Currency5Stat := PlayerStatsTable.Currency5
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency5 := Currency5Stat + Score

            else if(Stat.Name = "Currency6"):
                Currency6Stat := PlayerStatsTable.Currency6
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency6 := Currency6Stat + Score

            else if(Stat.Name = "Currency7"):
                Currency7Stat := PlayerStatsTable.Currency7
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency7 := Currency7Stat + Score

            else if(Stat.Name = "Currency8"):
                Currency8Stat := PlayerStatsTable.Currency8
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency8 := Currency8Stat + Score

            else if(Stat.Name = "Currency9"):
                Currency9Stat := PlayerStatsTable.Currency9
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency9 := Currency9Stat + Score

            else if(Stat.Name = "Currency10"):
                Currency10Stat := PlayerStatsTable.Currency10
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency10 := Currency10Stat + Score

            else if(Stat.Name = "RPGResource1"):
                RPGResource1Stat := PlayerStatsTable.RPGResource1
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    RPGResource1 := RPGResource1Stat + Score

            else if(Stat.Name = "RPGResource2"):
                RPGResource2Stat := PlayerStatsTable.RPGResource2
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    RPGResource2 := RPGResource2Stat + Score

            else if(Stat.Name = "RPGResource3"):
                RPGResource3Stat := PlayerStatsTable.RPGResource3
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    RPGResource3 := RPGResource3Stat + Score

            else if(Stat.Name = "RPGResource4"):
                RPGResource4Stat := PlayerStatsTable.RPGResource4
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    RPGResource4 := RPGResource4Stat + Score

            else if(Stat.Name = "RPGResource5"):
                RPGResource5Stat := PlayerStatsTable.RPGResource5
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    RPGResource5 := RPGResource5Stat + Score

            else if(Stat.Name = "RPGResource6"):
                RPGResource6Stat := PlayerStatsTable.RPGResource6
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    RPGResource6 := RPGResource6Stat + Score
                    
            else if(Stat.Name = "RPGResource7"):
                RPGResource7Stat := PlayerStatsTable.RPGResource7
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    RPGResource7 := RPGResource7Stat + Score

            else if(Stat.Name = "RPGResource8"):
                RPGResource8Stat := PlayerStatsTable.RPGResource8
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    RPGResource8 := RPGResource8Stat + Score

            else if(Stat.Name = "RPGResource9"):
                RPGResource9Stat := PlayerStatsTable.RPGResource9
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    RPGResource9 := RPGResource9Stat + Score

            else if(Stat.Name = "RPGResource10"):
                RPGResource10Stat := PlayerStatsTable.RPGResource10
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    RPGResource10 := RPGResource10Stat + Score




    #Sets a stat to a specific amount
    SetPlayerStat<override>(Agent:agent, Stat:stat_type, ?Score:float = 0.0):void=
        if:
            Player := player[Agent]
            Player.IsActive[]
            PlayerStatsTable := PlayerStatsMap[Player]
            
            if(Stat.Name = "Rebirths"):
                RebirthsStat := PlayerStatsTable.Rebirths
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Rebirths := Score
                    
            else if(Stat.Name = "Currency1"):
                Currency1Stat := PlayerStatsTable.Currency1
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency1 := Score

            else if(Stat.Name = "Currency2"):
                Currency2Stat := PlayerStatsTable.Currency2
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency2 := Score

            else if(Stat.Name = "Currency3"):
                Currency3Stat := PlayerStatsTable.Currency3
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency3 := Score

            else if(Stat.Name = "Currency4"):
                Currency4Stat := PlayerStatsTable.Currency4
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency4 := Score

            else if(Stat.Name = "Currency5"):
                Currency5Stat := PlayerStatsTable.Currency5
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency5 := Score

            else if(Stat.Name = "Currency6"):
                Currency6Stat := PlayerStatsTable.Currency6
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency6 := Score

            else if(Stat.Name = "Currency7"):
                Currency7Stat := PlayerStatsTable.Currency7
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency7 := Score

            else if(Stat.Name = "Currency8"):
                Currency8Stat := PlayerStatsTable.Currency8
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency8 := Score

            else if(Stat.Name = "Currency9"):
                Currency9Stat := PlayerStatsTable.Currency9
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency9 := Score

            else if(Stat.Name = "Currency10"):
                Currency10Stat := PlayerStatsTable.Currency10
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency10 := Score

            else if(Stat.Name = "RPGResource1"):
                RPGResource1Stat := PlayerStatsTable.RPGResource1
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    RPGResource1 := Score

            else if(Stat.Name = "RPGResource2"):
                RPGResource2Stat := PlayerStatsTable.RPGResource2
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    RPGResource2 := Score

            else if(Stat.Name = "RPGResource3"):
                RPGResource3Stat := PlayerStatsTable.RPGResource3
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    RPGResource3 := Score

            else if(Stat.Name = "RPGResource4"):
                RPGResource4Stat := PlayerStatsTable.RPGResource4
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    RPGResource4 := Score

            else if(Stat.Name = "RPGResource5"):
                RPGResource5Stat := PlayerStatsTable.RPGResource5
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    RPGResource5 := Score

            else if(Stat.Name = "RPGResource6"):
                RPGResource6Stat := PlayerStatsTable.RPGResource6
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    RPGResource6 := Score
                    
            else if(Stat.Name = "RPGResource7"):
                RPGResource7Stat := PlayerStatsTable.RPGResource7
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    RPGResource7 := Score

            else if(Stat.Name = "RPGResource8"):
                RPGResource8Stat := PlayerStatsTable.RPGResource8
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    RPGResource8 := Score

            else if(Stat.Name = "RPGResource9"):
                RPGResource9Stat := PlayerStatsTable.RPGResource9
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    RPGResource9 := Score

            else if(Stat.Name = "RPGResource10"):
                RPGResource10Stat := PlayerStatsTable.RPGResource10
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    RPGResource10 := Score




Base_Player := class<unique>():
    Player : player

Game_Type := enum:
    RPG
    Tycoon

#THIS SCRIPT MANAGES ALL PLAYER STATS

ResourceCollectType := enum:
    BaseAmount
    IdleAmount
    SecondAmount

#Base resource class that all resources are inherited from
BaseResource := class<concrete>():    
    TT_BR_ResourceName<localizes>:message = "Unique Identifier Used to determinate between different resources"
    @editable ResourceName : string = ""


RebirthResource := class<concrete>(BaseResource):  
    @editable RoundDecimalPlace : int = 0 
    @editable BoostMultiplier : float = 0.0
    @editable SavePersistance : logic = false
    var Amount : float = 0.0


#Resource the can be gained
GainableResource := class<concrete>(BaseResource):    
    TT_GR_Resource_Amount<localizes>:message = "The amount of resource the player gains"
    @editable Amount : float = 0.0

    TT_GR_Resource_EffectIdleAmount<localizes>:message = "Whether or not the resource\'s idle amount is effected"
    @editable EffectIdleAmount : logic  = false

    TT_GR_EffectSecondAmount<localizes>:message = "Whether or not the resource\'s second amount is effected"
    @editable EffectSecondAmount : logic = false

    TT_GR_EffectedByBoost<localizes>:message = "Whether or not the collection of this resource is effected by its boost amount"
    @editable EffectedByBoost : logic = true

    TT_GR_ShowPopUp<localizes>:message = "Whether or not the collection of this resource will make a pop up appear on the players screen"
    @editable ShowPopUp : logic = false

    TT_GR_CollectTheSecondAmountMultiplier<localizes>:message = "Whether or not the resorce\'s second amount is the amount collected/removed. If Enabled, will allow for selection of a multiplier applied to the new amount. Overrides the 'Amount'"
    @editable CollectTheSecondAmountMultiplier : ?float = false

    TT_GR_OverrideRebirthEffect<localizes>:message = "If Enabled, overrides the resources default 'EffectedByRebirth' state and can be either disabled or enabled"
    @editable OverrideRebirthEffect : ?logic = false

    TT_GR_OverridePopUpSettings<localizes>:message = "If Enabled, overrides the default 'BasePopUpSettings' and allows for the creation of custom pop up settings for this collection"
    @editable OverridePopUpSettings : ?PopUpAnimationSetting = false

#Resource the can be spent
SpendableResource := class<concrete>(BaseResource):    
    TT_SR_Resource_EffectIdleAmount<localizes>:message = "Whether or not the resource\'s idle amount is effected"
    @editable EffectIdleAmount : logic  = false

    TT_SR_EffectSecondAmount<localizes>:message = "Whether or not the resource\'s second amount is effected"
    @editable EffectSecondAmount : logic = false

    TT_SR_RemoveTheSecondAmountMultiplier<localizes>:message = "Whether or not the resorce\'s second amount is the amount collected/removed. If Enabled, will allow for selection of a multiplier applied to the new amount. Overrides the 'Amount'"
    @editable RemoveTheSecondAmountMultiplier : ?float = false

    TT_SR_Resource_RemoveResource<localizes>:message = "Whether or not the resource is removed (if false, this will just check if the player has this amount of resource)"
    @editable RemoveResource : logic = true

    TT_SR_Resource_Amount<localizes>:message = "The amount of resource required"
    @editable Amount : float = 0.0


#Resource that is reset
ResetResource := class<concrete>(BaseResource):    

#Resource that is used to boost
BoostResource := class<concrete>(BaseResource):
    @editable Amount : float = 0.0

#Resource that can be created and used for all other resources
GeneralResource := class<concrete>(BaseResource):
    #Actual held amounds
    var ResourceAmount : float = 0.0
    var ResourceIdleAmount : float = 0.0
    var ResourceBoostAmount : float = 1.0
    var ResourceSecondAmount : float = 0.0

    var IsHidden : logic = false

    #Settings
    @editable UISettings : ?ResourceUISettings = false
    @editable SavePersistance : logic = false
    @editable TrackOnScoreboard : logic = false
    @editable ShouldAmountReset : logic = false
    @editable IsEffectedByRebirths : logic = false
    @editable Tracker : ?tracker_device = false


BaseUISettings := class<concrete>():
    var ItemText : text_block = text_block{}
    var ItemTexture : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}
    var ItemPopUpTexture : texture = MasterAssets.Placeholder

    @editable HideUIElementsUntilTriggered : ?trigger_device = false
    @editable RoundDecimalPlace : int = 0
    @editable BaseAmountSettings : BaseAmountSetting = BaseAmountSetting{}

ResourceUISettings := class<concrete>(BaseUISettings):
    #UI elemenrts
    var ResourceIdleText : text_block = text_block{}
    var ResourceIdleTexture : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}

    var ResourceBoostText : text_block = text_block{}
    var ResourceBoostTexture : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}

    @editable IdleSettings : IdleSetting = IdleSetting{}
    @editable BoostSettings : BoostSetting = BoostSetting{}

#Settings that control a resources boost amount
BoostSetting := class<concrete>():
    TT_BS_BoostSetting_ShouldBoostImageAppearOnHud<localizes>:message = "Whether or not the boost image should appear on the hud"
    @editable ShouldBoostImageAppearOnHud : logic = false
    
    TT_BS_BoostSetting_ShouldBoostTextAppearOnHud<localizes>:message = "Whether or not the boost text should appear on the hud"
    @editable ShouldBoostTextAppearOnHud : logic = false

    @editable ShouldBoostReset : logic = false
    @editable TextSettings : TextSetting = TextSetting{}
    @editable BoostImagePosition : CanvasPosition = CanvasPosition{}
    @editable BoostTextPosition : CanvasPosition = CanvasPosition{}

#Settings that control a resources idle amount
IdleSetting := class<concrete>():
    TT_IS_IdleSetting_ShouldIdleImageAppearOnHud<localizes>:message = "Whether or not the idle image should appear on the hud"
    @editable ShouldIdleImageAppearOnHud : logic = false

    TT_IS_IdleSetting_ShouldIdleTextAppearOnHud<localizes>:message = "Whether or not the idle text should appear on the hud"
    @editable ShouldIdleTextAppearOnHud : logic = false

    @editable TextSettings : TextSetting = TextSetting{}
    @editable IdleImagePosition : CanvasPosition = CanvasPosition{}
    @editable IdleTextPosition : CanvasPosition = CanvasPosition{}

#Settings that control a resources base amount
BaseAmountSetting := class<concrete>():
    @editable TextSettings : TextSetting = TextSetting{}
    @editable ImagePosition : CanvasPosition = CanvasPosition{}
    @editable TextPosition : CanvasPosition = CanvasPosition{}

#Class of additional controllers that allow for collection/removal of different resources from triggers
AdditionalCollector := class<concrete>():
    var ResourceManager : Resource_Manager = Resource_Manager{}

    TT_AC_ActivateTrigger<localizes>:message = "Trigger device used to activate this additional collector"
    @editable ActivateTrigger : trigger_device = trigger_device{}

    TT_AC_SuccessfulSpendTrigger<localizes>:message = "Trigger device that is triggered when resources defined in 'SpendResources' are successfully spent"
    @editable SuccessfulSpendTrigger : trigger_device = trigger_device{}

    TT_AC_CollectResources<localizes>:message = "Resources that are collected when this collector is activated"
    @editable CollectResources : []AdditionalCollectorResource = array{}

    TT_AC_SpendResources<localizes>:message = "Resources that are spent when this collector is activated"
    @editable SpendResources : []SpendableResource = array{}

    TT_AC_BoostResources<localizes>:message = "Resources that are boosted when this collector is activated"
    @editable BoostResources : []BoostResource = array{}

    TT_AC_RemoveBoostResources<localizes>:message = "Resources boosts that are removed when this collector is activated"
    @editable RemoveBoostResources : []BoostResource = array{}



    PreHandleTrigger (NAgent : ?agent) : void=
        if(Agent := NAgent?):
            spawn{HandleTrigger(Agent)}
    HandleTrigger(Agent:agent)<suspends> : void=
        if(PR := ResourceManager.PlayersMap[Agent]):  
            PR.Collect(CollectResources)
            HasAmounts := PR.Check(SpendResources)
            if(HasAmounts?):
                SuccessfulSpendTrigger.Trigger(Agent)
                PR.Spend(SpendResources)
        
            PR.Boost(BoostResources)
            PR.RemoveBoost(RemoveBoostResources)


#Resource the can be gained
AdditionalCollectorResource := class<concrete>(BaseResource):    
    TT_ACR_Resource_Amount<localizes>:message = "The amount of resource the player gains"
    @editable Amount : float = 0.0

    TT_ACR_Resource_EffectIdleAmount<localizes>:message = "Whether or not the resource\'s idle amount is effected"
    @editable EffectIdleAmount : logic  = false

    TT_ACR_EffectSecondAmount<localizes>:message = "Whether or not the resource\'s second amount is effected"
    @editable EffectSecondAmount : logic = false

    TT_ACR_EffectedByBoost<localizes>:message = "Whether or not the collection of this resource is effected by its boost amount"
    @editable EffectedByBoost : logic = true

    TT_ACR_ShowPopUp<localizes>:message = "Whether or not the collection of this resource will make a pop up appear on the players screen"
    @editable ShowPopUp : logic = false

    TT_ACR_CollectTheSecondAmountMultiplier<localizes>:message = "Whether or not the resorce\'s second amount is the amount collected/removed. If Enabled, will allow for selection of a multiplier applied to the new amount. Overrides the 'Amount'"
    @editable CollectTheSecondAmount : ?float = false

    TT_ACR_OverrideRebirthEffect<localizes>:message = "If Enabled, overrides the resources default 'EffectedByRebirth' state and can be either disabled or enabled"
    @editable OverrideRebirthEffect : ?logic = false

    TT_ACR_OverridePopUpSettings<localizes>:message = "If Enabled, overrides the default 'BasePopUpSettings' and allows for the creation of custom pop up settings for this collection"
    @editable OverridePopUpSettings : ?PopUpAnimationSetting = false

    TT_ACR_RandomAmountRange<localizes>:message = "If set, 'Amount' will be a random value between the two values defined"
    @editable RandomAmountRange : ?vector2 = false

    TT_ACR_StealFromRandomPlayer<localizes>:message = "A hud message device that if set, will 'steal' the amount specified from a random player (if no player can afford it, a failure message will be displayed instead) *Required Settings*\nMessage Recipient : Triggering Player\nDisplay Time : 3-5 Seconds"
    @editable StealFromRandomPlayer : ?hud_message_device = false


Player_Resource_Data := class<unique>(Base_Player):
    #All Resources
    var ResourceManager : Resource_Manager = Resource_Manager{}
    var Resources : []GeneralResource = array{}

    #Rebirth Values
    var RebirthAmount : float = 0.0          
    var RebirthBoostAmount : float = 0.0               
    var SaveRebirthPersistence : logic = false 

    #Prestige Values
    var PrestigeAmount : float = 0.0
    var PrestigeText : text_block = text_block{}
    var PrestigeImage : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}
    var PrestigeBoostAmount : float = 0.0
    var SavePrestigePersistence : logic = false

    #Pop up
    var PopUp : PopUpCreator = PopUpCreator{}
    var PopUpSettings  : PopUpAnimationSetting = PopUpAnimationSetting{}

    var ResourceUIMap : [player]ResourceUI = map{}


    #Resource Images =================================================================================================================================
    var ResourceTextures : []texture = array{}
    var ResourceIdleTextures : []texture = array{}
    var ResourceBoostTextures : []texture = array{}
    var ResourcePopUpTextures : []texture = array{}
    # ================================================================================================================================================

    #Persistance =========================================================================================================================================

    #RPG Resource Persistance
    AddRPGResourceToPersistence(idx : int,Amount : float) : void=
        PersistenceManager := ResourceManager.PersistenceManager
        if(idx = 0){PersistenceManager.RecordPlayerStat(Player, StatType.RPGResource1, ?Score := Amount)}
        else if(idx = 1){PersistenceManager.RecordPlayerStat(Player, StatType.RPGResource2, ?Score := Amount)}
        else if(idx = 2){PersistenceManager.RecordPlayerStat(Player, StatType.RPGResource3, ?Score := Amount)}
        else if(idx = 3){PersistenceManager.RecordPlayerStat(Player, StatType.RPGResource4, ?Score := Amount)}
        else if(idx = 4){PersistenceManager.RecordPlayerStat(Player, StatType.RPGResource5, ?Score := Amount)}
        else if(idx = 5){PersistenceManager.RecordPlayerStat(Player, StatType.RPGResource6, ?Score := Amount)}
        else if(idx = 6){PersistenceManager.RecordPlayerStat(Player, StatType.RPGResource7, ?Score := Amount)}
        else if(idx = 7){PersistenceManager.RecordPlayerStat(Player, StatType.RPGResource8, ?Score := Amount)}
        else if(idx = 8){PersistenceManager.RecordPlayerStat(Player, StatType.RPGResource9, ?Score := Amount)}
        else if(idx = 9){PersistenceManager.RecordPlayerStat(Player, StatType.RPGResource10, ?Score := Amount)}


    #TODO add tycoon resource persistance
    AddTycoonResourceToPersistence(idx : int,Amount : float) : void=
        PersistenceManager := ResourceManager.PersistenceManager
        if(idx = 0){PersistenceManager.RecordPlayerStat(Player, StatType.Currency1, ?Score := Amount)}
        else if(idx = 1){PersistenceManager.RecordPlayerStat(Player, StatType.Currency2, ?Score := Amount)}
        else if(idx = 2){PersistenceManager.RecordPlayerStat(Player, StatType.Currency3, ?Score := Amount)}
        else if(idx = 3){PersistenceManager.RecordPlayerStat(Player, StatType.Currency4, ?Score := Amount)}
        else if(idx = 4){PersistenceManager.RecordPlayerStat(Player, StatType.Currency5, ?Score := Amount)}
        else if(idx = 5){PersistenceManager.RecordPlayerStat(Player, StatType.Currency6, ?Score := Amount)}
        else if(idx = 6){PersistenceManager.RecordPlayerStat(Player, StatType.Currency7, ?Score := Amount)}
        else if(idx = 7){PersistenceManager.RecordPlayerStat(Player, StatType.Currency8, ?Score := Amount)}
        else if(idx = 8){PersistenceManager.RecordPlayerStat(Player, StatType.Currency9, ?Score := Amount)}
        else if(idx = 9){PersistenceManager.RecordPlayerStat(Player, StatType.Currency10, ?Score := Amount)}

    #Adds a resource to persistance based on the game type
    AddToPersistence(idx : int,Amount : float) : void=
        if(ResourceManager.GameType = Game_Type.RPG):
            AddRPGResourceToPersistence(idx,Amount)
        else if(ResourceManager.GameType = Game_Type.Tycoon):
            AddTycoonResourceToPersistence(idx,Amount)


    
    # Resource Functions ===================================================================================================================================

    ResourceChange(Amount : float , ReIDX : int , EffectedResource : GeneralResource , CollectType : ResourceCollectType , ShowPopUp : logic , EffectedByBoost : logic , EffectedByRebirths : logic , MaybePopUpSettings : ?PopUpAnimationSetting) : void=
        var NewAmount : float = Amount
        if(EffectedByRebirths?){set NewAmount = NewAmount * (1.0 + RebirthAmount * RebirthBoostAmount)}
        if(EffectedByBoost?){set NewAmount = NewAmount * EffectedResource.ResourceBoostAmount}

        if(CollectType = ResourceCollectType.BaseAmount):
            set EffectedResource.ResourceAmount += NewAmount
            if(EffectedResource.SavePersistance?){AddToPersistence(ReIDX,NewAmount)}
        else if(CollectType = ResourceCollectType.IdleAmount):
            set EffectedResource.ResourceIdleAmount += NewAmount
        else if(CollectType = ResourceCollectType.SecondAmount):
            set EffectedResource.ResourceSecondAmount += NewAmount
            
        if(ShowPopUp?):
            if(NewPopUpSettings := MaybePopUpSettings?):
                set PopUp.PopUpAnimationSettings = NewPopUpSettings
            else:
                set PopUp.PopUpAnimationSettings = PopUpSettings
            spawn{PopUp.AddPopUp(Player,EffectedResource.ToPopUpData(), NewAmount)}

        for (CurrPlayer : ResourceManager.GetPlayspace().GetPlayers()):
            if (RUI := ResourceUIMap[CurrPlayer]):
                RUI.UpdateUI()

    #Collects different resources for a player
    Collect(Res : []BaseResource): void=   
        for(idx -> Re : Resources):
            for(GainRes : Res):
                if(Re.ResourceName = GainRes.ResourceName):
                    if(NewRes := AdditionalCollectorResource[GainRes]):
                        HandleAdditionalCollectorResource(idx , NewRes , Re)
                    else if(NewRes := GainableResource[GainRes]):
                        HandleGainableResource(idx , NewRes , Re)
                    else if(NewRes := ResetResource[GainRes]):
                        HandleResetResource(idx , NewRes , Re)


    #Handles collection for Reset Resources
    HandleResetResource(idx : int , NewRes : ResetResource , Re : GeneralResource) : void=
        if(Re.ShouldAmountReset?):
            if(Re.SavePersistance?){AddToPersistence(idx, -Re.ResourceAmount)}
            set Re.ResourceAmount -= Re.ResourceAmount
            set Re.ResourceIdleAmount -= Re.ResourceIdleAmount
            
        if(Re.UISettings?.BoostSettings.ShouldBoostReset?):
            set Re.ResourceBoostAmount = 1.0

    #Handles collection for Gainable Resources
    HandleGainableResource(idx : int , NewRes : GainableResource , Re : GeneralResource) : void=
        var NewAmount : float = NewRes.Amount
        if(Multiplier := NewRes.CollectTheSecondAmountMultiplier?){set NewAmount = (Re.ResourceSecondAmount * Multiplier)}

        var ShouldRebirthEffect : logic = Re.IsEffectedByRebirths
        if(Override := NewRes.OverrideRebirthEffect?){set ShouldRebirthEffect = Override}

        if(NewRes.EffectIdleAmount?):
            ResourceChange(Amount := NewAmount , ReIDX := idx , EffectedResource := Re , CollectType := ResourceCollectType.IdleAmount , ShowPopUp := NewRes.ShowPopUp , NewRes.EffectedByBoost , ShouldRebirthEffect , NewRes.OverridePopUpSettings)
        else if(NewRes.EffectSecondAmount?):
            ResourceChange(Amount := NewAmount , ReIDX := idx , EffectedResource := Re , CollectType := ResourceCollectType.SecondAmount , ShowPopUp := NewRes.ShowPopUp, NewRes.EffectedByBoost , ShouldRebirthEffect , NewRes.OverridePopUpSettings)
        else:
            ResourceChange(Amount := NewAmount , ReIDX := idx , EffectedResource := Re , CollectType := ResourceCollectType.BaseAmount , ShowPopUp := NewRes.ShowPopUp, NewRes.EffectedByBoost , ShouldRebirthEffect , NewRes.OverridePopUpSettings)

    #Handles collection for addition collector resources
    HandleAdditionalCollectorResource(idx : int , NewRes : AdditionalCollectorResource , Re : GeneralResource) : void=
        var NewAmount : float = NewRes.Amount
        if(Multiplier := NewRes.CollectTheSecondAmount?){set NewAmount = (Re.ResourceSecondAmount * Multiplier)}
        if(Range := NewRes.RandomAmountRange?){set NewAmount = GetRandomFloat(Range.X,Range.Y)}

        var ShouldRebirthEffect : logic = Re.IsEffectedByRebirths
        if(Override := NewRes.OverrideRebirthEffect?){set ShouldRebirthEffect = Override}

        var ShouldCollect : logic = true

        #Handles stealing resources
        if(StealHUD := NewRes.StealFromRandomPlayer?):
            NewSpendResource := SpendableResource{ResourceName := NewRes.ResourceName, Amount := NewAmount}
            AffordPlayers := ResourceManager.GetPlayersWhoCanAfford(Player,NewSpendResource , NewAmount)
            if(AffordPlayers.Length > 0):
                if(SelectedPlayer := AffordPlayers[GetRandomInt(0,AffordPlayers.Length-1)] , SelectedRP := ResourceManager.PlayersMap[SelectedPlayer]):
                    SelectedRP.Spend(array{NewSpendResource})
                    InstigatorAgentMSG := MasterA2M(Player)
                    AmountMSG := RoundedAmount("",NewAmount,2,"")
                    ActualText1 := MasterS2M(" has stolen ")
                    ActualText2 := MasterS2M(" from you!")
                    StealHUD.SetText(MessageCombine(InstigatorAgentMSG,ActualText1,AmountMSG,ActualText2))
                    StealHUD.Show(SelectedPlayer)
            else:
                set ShouldCollect = false
                StealHUD.SetText(MasterS2M("No One Could be Stolen From"))
                StealHUD.Show(Player)
    
        else:
            if(ShouldCollect = true):
                if(NewRes.EffectIdleAmount?):
                    ResourceChange(Amount := NewAmount , ReIDX := idx , EffectedResource := Re , CollectType := ResourceCollectType.IdleAmount , ShowPopUp := NewRes.ShowPopUp , NewRes.EffectedByBoost , ShouldRebirthEffect , NewRes.OverridePopUpSettings)
                else if(NewRes.EffectSecondAmount?):
                    ResourceChange(Amount := NewAmount , ReIDX := idx , EffectedResource := Re , CollectType := ResourceCollectType.SecondAmount , ShowPopUp := NewRes.ShowPopUp, NewRes.EffectedByBoost , ShouldRebirthEffect , NewRes.OverridePopUpSettings)
                else:
                    ResourceChange(Amount := NewAmount , ReIDX := idx , EffectedResource := Re , CollectType := ResourceCollectType.BaseAmount , ShowPopUp := NewRes.ShowPopUp, NewRes.EffectedByBoost , ShouldRebirthEffect , NewRes.OverridePopUpSettings)

                    
    #Collects rebirth for player          
    CollectRebirth(Res : []BaseResource): void=
        for(GainRes : Res):
            if(NewRes := RebirthResource[GainRes]):
                set RebirthAmount += NewRes.Amount
                for (CurrPlayer : ResourceManager.GetPlayspace().GetPlayers()):
                    if (RUI := ResourceUIMap[CurrPlayer]):
                        RUI.UpdateUI()
                if(NewRes.SavePersistance?){ResourceManager.PersistenceManager.RecordPlayerStat(Player, StatType.Rebirths, ?Score := NewRes.Amount)}
                    
    #Checks if the player has enough resources
    Check(Res : []SpendableResource) : logic=
        var SuccessAmount : int = 0
        SuccessGoal := Res.Length
        if(SuccessGoal > 0):
            for(Re : Resources):
                for(SpendableRe : Res):
                    if(SpendableRe.ResourceName = Re.ResourceName):
                        if(SpendableRe.EffectIdleAmount?,Re.ResourceIdleAmount >= SpendableRe.Amount):
                            set SuccessAmount += 1
                        else if(Re.ResourceAmount >= SpendableRe.Amount):
                            set SuccessAmount += 1

            for(SpendableRe : Res):
                if(SpendableRe.ResourceName = "Rebirth"):
                    if(RebirthAmount >= SpendableRe.Amount):
                        set SuccessAmount += 1

                if(SpendableRe.ResourceName = "Prestige"):
                    if(PrestigeAmount >= SpendableRe.Amount):
                        set SuccessAmount += 1

            if(SuccessAmount = SuccessGoal):
                return true
            else:
                return false
        else:
            return true

    #Removes resources from the player
    Spend(Res : []SpendableResource ): void=  
        for(idx -> Re : Resources):
            for(SpendableRe : Res):
                if(SpendableRe.ResourceName = Re.ResourceName , SpendableRe.RemoveResource?):
                    var NewAmount : float = SpendableRe.Amount
                    if(Multiplier := SpendableRe.RemoveTheSecondAmountMultiplier?){set NewAmount = (Re.ResourceSecondAmount * Multiplier)}
                    if(SpendableRe.EffectIdleAmount?):
                        ResourceChange(Amount := -NewAmount , ReIDX := idx , EffectedResource := Re , CollectType := ResourceCollectType.IdleAmount , false , false , false , false)
                    else if(SpendableRe.EffectSecondAmount?):
                        ResourceChange(Amount := -NewAmount , ReIDX := idx , EffectedResource := Re , CollectType := ResourceCollectType.SecondAmount , false , false , false , false)
                    else:
                        ResourceChange(Amount := -NewAmount , ReIDX := idx , EffectedResource := Re , CollectType := ResourceCollectType.BaseAmount , false , false , false, false)



        for(SpendableRe : Res):
            if(SpendableRe.ResourceName = "Rebirth", SpendableRe.RemoveResource?):
                set RebirthAmount -= SpendableRe.Amount
                #RebirthText.SetText(RoundedAmount("",RebirthAmount,0,""))  
                for (CurrPlayer : ResourceManager.GetPlayspace().GetPlayers()):
                    if (RUI := ResourceUIMap[CurrPlayer]):
                        RUI.UpdateUI()

                if(SaveRebirthPersistence?):
                    ResourceManager.PersistenceManager.RecordPlayerStat(Player, StatType.Rebirths, ?Score := -SpendableRe.Amount)
        
            if(SpendableRe.ResourceName = "Prestige", SpendableRe.RemoveResource?):
                set PrestigeAmount -= SpendableRe.Amount
                PrestigeText.SetText(RoundedAmount("",PrestigeAmount,0,""))
                if(SavePrestigePersistence?):
                    ResourceManager.PersistenceManager.RecordPlayerStat(Player, StatType.PrestigeCount, ?Score := -SpendableRe.Amount)
        
        for (CurrPlayer : ResourceManager.GetPlayspace().GetPlayers()):
            if (RUI := ResourceUIMap[CurrPlayer]):
                RUI.UpdateUI()

    #Boosts a resource for a player
    Boost(Res : []BaseResource) : void=       
        for(Re : Resources):
            for(BoostRes : Res):
                if(BoostRes.ResourceName = Re.ResourceName):
                    if(NewRes := BoostResource[BoostRes]):
                        set Re.ResourceBoostAmount += NewRes.Amount
        for (CurrPlayer : ResourceManager.GetPlayspace().GetPlayers()):
            if (RUI := ResourceUIMap[CurrPlayer]):
                RUI.UpdateUI()
           
    #Removes a resource boost from a player
    RemoveBoost(Res : []BaseResource) : void= 
        for(Re : Resources):
            for(BoostRes : Res):
                if(BoostRes.ResourceName = Re.ResourceName):
                    if(NewRes := BoostResource[BoostRes]):
                        set Re.ResourceBoostAmount -= NewRes.Amount
        for (CurrPlayer : ResourceManager.GetPlayspace().GetPlayers()):
            if (RUI := ResourceUIMap[CurrPlayer]):
                RUI.UpdateUI()


    SaveAllStats(Agent : agent) : void =
        ResourceManager.PersistenceManager.SetPlayerStat(Agent, StatType.Rebirths, ?Score := RebirthAmount)
        if(C1 := Resources[0].ResourceAmount):
            ResourceManager.PersistenceManager.SetPlayerStat(Agent, StatType.Currency1, ?Score := C1)
        if(C2 := Resources[1].ResourceAmount):
            ResourceManager.PersistenceManager.SetPlayerStat(Agent, StatType.Currency2, ?Score := C2)
        if(C3 := Resources[2].ResourceAmount):
            ResourceManager.PersistenceManager.SetPlayerStat(Agent, StatType.Currency3, ?Score := C3)
        if(C4 := Resources[3].ResourceAmount):
            ResourceManager.PersistenceManager.SetPlayerStat(Agent, StatType.Currency4, ?Score := C4)
        if(C5 := Resources[4].ResourceAmount):
            ResourceManager.PersistenceManager.SetPlayerStat(Agent, StatType.Currency5, ?Score := C5)
        if(C6 := Resources[5].ResourceAmount):
            ResourceManager.PersistenceManager.SetPlayerStat(Agent, StatType.Currency6, ?Score := C6)
        if(C7 := Resources[6].ResourceAmount):
            ResourceManager.PersistenceManager.SetPlayerStat(Agent, StatType.Currency7, ?Score := C7)
        if(C8 := Resources[7].ResourceAmount):
            ResourceManager.PersistenceManager.SetPlayerStat(Agent, StatType.Currency8, ?Score := C8)
        if(C9 := Resources[8].ResourceAmount):
            ResourceManager.PersistenceManager.SetPlayerStat(Agent, StatType.Currency9, ?Score := C9)
        if(C10 := Resources[9].ResourceAmount):
            ResourceManager.PersistenceManager.SetPlayerStat(Agent, StatType.Currency10, ?Score := C10)
            
    #Resets all of the players resources
    ResetStats() : void=    
        var ResetArray : []ResetResource = array{}
        for(Re : Resources):
            #set Re.ResourceAmount = 0.0
            #set Re.ResourceIdleAmount = 0.0
            #set Re.ResourceBoostAmount = 1.0
            #set Re.ResourceSecondAmount = 0.0

            set ResetArray += array{ResetResource{ResourceName := Re.ResourceName}}
        Collect(ResetArray)
        
        # Reset all persistence (except for playtime)
        ResourceManager.PersistenceManager.SetPlayerStat(Player, StatType.Currency1, ?Score := 0.0)
        ResourceManager.PersistenceManager.SetPlayerStat(Player, StatType.Currency2, ?Score := 0.0)
        ResourceManager.PersistenceManager.SetPlayerStat(Player, StatType.Currency3, ?Score := 0.0)
        ResourceManager.PersistenceManager.SetPlayerStat(Player, StatType.Currency4, ?Score := 0.0)
        ResourceManager.PersistenceManager.SetPlayerStat(Player, StatType.Currency5, ?Score := 0.0)
        ResourceManager.PersistenceManager.SetPlayerStat(Player, StatType.Currency6, ?Score := 0.0)
        ResourceManager.PersistenceManager.SetPlayerStat(Player, StatType.Currency7, ?Score := 0.0)
        ResourceManager.PersistenceManager.SetPlayerStat(Player, StatType.Currency8, ?Score := 0.0)
        ResourceManager.PersistenceManager.SetPlayerStat(Player, StatType.Currency9, ?Score := 0.0)
        ResourceManager.PersistenceManager.SetPlayerStat(Player, StatType.Currency10, ?Score := 0.0)


    # Set the player to the UI map
    SetResourceUI(Agent : agent) : void =
        if (PlayerObj := player[Agent]):
            if(set ResourceUIMap[PlayerObj] = ResourceUI{       
                Player := PlayerObj
                ResourceManager := ResourceManager
                }){}
            #Adds the UI
            if(RPUI := ResourceUIMap[PlayerObj]):  
                #RPUI.InitiateUI()
                AddResourcesUISettings()
                RPUI.AddsResourceUI(Agent)

    AddResourcesUISettings() : void =
        var NewResources : []GeneralResource = array{}
        for(Re : Resources):
            var MaybeRUI : ?ResourceUISettings = false
            if(RUI := Re.UISettings?):
                set MaybeRUI = option:
                    ResourceUISettings:
                        ItemText := var NewResourceText : text_block = text_block{}
                        ItemTexture := var NewResourceTexture : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}
                        ResourceIdleText  := var NewResourceIdleText : text_block = text_block{}
                        ResourceIdleTexture := var NewResourceIdleTexture : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}
                        ResourceBoostText := var NewResourceBoostText : text_block = text_block{}
                        ResourceBoostTexture := var NewResourceBoostTexture : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}
                        ItemPopUpTexture := MasterAssets.Placeholder
                        RoundDecimalPlace := RUI.RoundDecimalPlace
                        BaseAmountSettings := RUI.BaseAmountSettings
                        IdleSettings := RUI.IdleSettings
                        BoostSettings := RUI.BoostSettings
                        HideUIElementsUntilTriggered := RUI.HideUIElementsUntilTriggered

            set NewResources += array{GeneralResource{
                ResourceName := Re.ResourceName
                ResourceAmount := Re.ResourceAmount
                ResourceIdleAmount := Re.ResourceIdleAmount
                ResourceSecondAmount := Re.ResourceSecondAmount
                ResourceBoostAmount := Re.ResourceBoostAmount
                UISettings := MaybeRUI
                SavePersistance := Re.SavePersistance
                TrackOnScoreboard := Re.TrackOnScoreboard
                ShouldAmountReset := Re.ShouldAmountReset
                IsEffectedByRebirths := Re.IsEffectedByRebirths
                IsHidden := false
                Tracker := Re.Tracker
            }}
        set Resources = NewResources







# UI ==================================================================================================================================================
ResourceUI := class():
    Player : player
    var ResourceManager : Resource_Manager = Resource_Manager{}

    # Widgets for individual UIs
    var ResourceText : text_block = text_block{}
    var ResourceTexture : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}

    var ResourceIdleText : text_block = text_block{}
    var ResourceIdleTexture : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}

    var ResourceBoostText : text_block = text_block{}
    var ResourceBoostTexture : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}
    var RebirthImage : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}   

    var RebirthText : text_block = text_block{}  

    var ResourcePopUpTexture : texture = MasterAssets.Placeholder

    # Canvas for resources
    var ResourceCanvas : canvas = canvas{}

    #Creates the players UI
    CreateMyUI() : canvas =   
        MyCanvas : canvas = canvas{}
        if (CurrPlayer := ResourceManager.PlayersMap[Player]):
            for(Re : CurrPlayer.Resources, RUI := Re.UISettings?):
                ResourceText.SetVisibility(widget_visibility.Visible)
                ResourceTexture.SetVisibility(widget_visibility.Visible)
                ResourceIdleText.SetVisibility(widget_visibility.Visible)
                ResourceIdleTexture.SetVisibility(widget_visibility.Visible)
                ResourceBoostText.SetVisibility(widget_visibility.Visible)
                ResourceBoostTexture.SetVisibility(widget_visibility.Visible)

                ResourceText.SetShadowOffset(option{RUI.BaseAmountSettings.TextSettings.TextShadowOffset})
                ResourceIdleText.SetShadowOffset(option{RUI.IdleSettings.TextSettings.TextShadowOffset})
                ResourceBoostText.SetShadowOffset(option{RUI.BoostSettings.TextSettings.TextShadowOffset})

                ResourceText.SetShadowColor(RUI.BaseAmountSettings.TextSettings.TextShadowColor)
                RUI.ResourceIdleText.SetShadowColor(RUI.IdleSettings.TextSettings.TextShadowColor)
                RUI.ResourceBoostText.SetShadowColor(RUI.BoostSettings.TextSettings.TextShadowColor)

                ResourceText.SetTextColor(RUI.BaseAmountSettings.TextSettings.TextColor)
                ResourceIdleText.SetTextColor(RUI.IdleSettings.TextSettings.TextColor)
                ResourceBoostText.SetTextColor(RUI.BoostSettings.TextSettings.TextColor)

                ResourceText.SetShadowOpacity(1.0)
                ResourceIdleText.SetShadowOpacity(1.0)
                ResourceBoostText.SetShadowOpacity(1.0)

                MyCanvas.AddWidget(RUI.BaseAmountSettings.TextPosition.MakeCanvasSlot(ResourceText,false))
                MyCanvas.AddWidget(RUI.BaseAmountSettings.ImagePosition.MakeCanvasSlot(ResourceTexture,false))

                if(RUI.IdleSettings.ShouldIdleTextAppearOnHud?):
                    MyCanvas.AddWidget(RUI.IdleSettings.IdleTextPosition.MakeCanvasSlot(ResourceIdleText,false))
                if(RUI.IdleSettings.ShouldIdleImageAppearOnHud?):
                    MyCanvas.AddWidget(RUI.IdleSettings.IdleImagePosition.MakeCanvasSlot(ResourceIdleTexture,false))

                if(RUI.BoostSettings.ShouldBoostTextAppearOnHud?):
                    MyCanvas.AddWidget(RUI.BoostSettings.BoostTextPosition.MakeCanvasSlot(ResourceBoostText,false))
                if(RUI.BoostSettings.ShouldBoostImageAppearOnHud?):
                    MyCanvas.AddWidget(RUI.BoostSettings.BoostImagePosition.MakeCanvasSlot(ResourceBoostTexture,false))

                if(ShowTrigger := RUI.HideUIElementsUntilTriggered?):
                    set Re.IsHidden = true
                    ResourceText.SetVisibility(widget_visibility.Hidden)
                    ResourceTexture.SetVisibility(widget_visibility.Hidden)
                    ResourceIdleText.SetVisibility(widget_visibility.Hidden)
                    ResourceIdleTexture.SetVisibility(widget_visibility.Hidden)
                    ResourceBoostText.SetVisibility(widget_visibility.Hidden)
                    ResourceBoostTexture.SetVisibility(widget_visibility.Hidden)

            for(idx -> Re : CurrPlayer.Resources, RUI := Re.UISettings?):
                if(tex := CurrPlayer.ResourceTextures[idx]){ResourceTexture.SetImage(tex)} 
                if(idletex := CurrPlayer.ResourceIdleTextures[idx] , RUI.IdleSettings.ShouldIdleImageAppearOnHud?){ResourceIdleTexture.SetImage(idletex)} 
                if(boosttex := CurrPlayer.ResourceBoostTextures[idx], RUI.BoostSettings.ShouldBoostImageAppearOnHud?){ResourceBoostTexture.SetImage(boosttex)}
                if(poptex := CurrPlayer.ResourcePopUpTextures[idx]){set ResourcePopUpTexture = poptex}
        return MyCanvas


    #Updates all resource values
    UpdateUI() : void=
        if (CurrPlayer := ResourceManager.PlayersMap[Player]):
            for(Re : CurrPlayer.Resources):
                var NewIdleAmount : float = 0.0
                if(RUI := Re.UISettings?):
                    if(Re.IsEffectedByRebirths?):
                        set NewIdleAmount = Re.ResourceIdleAmount * (Re.ResourceBoostAmount + (CurrPlayer.RebirthAmount * CurrPlayer.RebirthBoostAmount))
                        ResourceIdleText.SetText(RoundedAmount("",NewIdleAmount,RUI.RoundDecimalPlace,"/ Sec"))
                        ResourceBoostText.SetText(RoundedAmount("",Re.ResourceBoostAmount + (CurrPlayer.RebirthAmount * CurrPlayer.RebirthBoostAmount) ,1,"x"))
                    else:
                        set NewIdleAmount = Re.ResourceIdleAmount * (Re.ResourceBoostAmount)
                        ResourceIdleText.SetText(RoundedAmount("",NewIdleAmount,RUI.RoundDecimalPlace,"/ Sec"))
                        ResourceBoostText.SetText(RoundedAmount("",Re.ResourceBoostAmount,1,"x"))

                    ResourceText.SetText(RoundedAmount("",Re.ResourceAmount,RUI.RoundDecimalPlace,""))
                    RebirthText.SetText(RoundedAmount("",CurrPlayer.RebirthAmount,0,""))  
                
                if(Tracker := Re.Tracker?, IntAmount := Int[Re.ResourceAmount]):
                    Tracker.SetValue(Player,IntAmount)


    #Updates all resource values
    UpdateResourceUI() : void=
        if (CurrPlayer := ResourceManager.PlayersMap[Player]):
            for(Re : CurrPlayer.Resources):
                var NewIdleAmount : float = 0.0
                set NewIdleAmount = Re.ResourceIdleAmount * (Re.ResourceBoostAmount)

                if(RUI := Re.UISettings?):
                    ResourceText.SetText(RoundedAmount("",Re.ResourceAmount,RUI.RoundDecimalPlace,""))

                if(Tracker := Re.Tracker?, IntAmount := Int[Re.ResourceAmount]):
                    Tracker.SetValue(Player,IntAmount)

    # Used to remove UI completely from the player's screen
    RemoveResourceUI(Agent : agent) : void =
        if(PlayerObj := player[Agent], PlayerUI := GetPlayerUI[PlayerObj]):
            ResourceCanvas.SetVisibility(widget_visibility.Hidden)
            PlayerUI.RemoveWidget(ResourceCanvas)

    AddsResourceUI(Agent : agent) : void =
        #Adds UI to player
        if(CurrPlayer := ResourceManager.PlayersMap[Player], PlayerObj := Player, PlayerUI := GetPlayerUI[PlayerObj]):
            set ResourceCanvas = CreateMyUI()
            PlayerUI.AddWidget(ResourceCanvas)
            UpdateUI()

            CurrPlayer.PopUp.InitializePopUp(Player)





Resource_Details := class<concrete>():                                                              
    TT_Resources<localizes>:message = "All of the resources that the players can collect (e.g. Money, Gems, etc.)"
    @editable Resources : []GeneralResource = array{}

    TT_AdditionalCollectors<localizes>:message = "A list of custom mechanics that can be used to collect/spend resources"
    @editable AdditionalCollectors : []AdditionalCollector = array{}

    TT_BasePopUpSettings<localizes>:message = "Base Pop Up Settings used by resources. Icons for each resource are set inside RPG_Attribute_Manager.verse inside ResourcePopUpTextures"
    @editable PopUpSettings : PopUpAnimationSetting = PopUpAnimationSetting{}

Resource_Manager := class(creative_device):

    var PlayersMap : [player]Player_Resource_Data = map{}


    var PersistenceManager : Base_Persistence_Manager = Resource_Persistence_Manager{}    

    #All Resources
    @editable ResourceDetails : Resource_Details = Resource_Details{}

    @editable GameType : Game_Type = Game_Type.Tycoon
    

    TT_ResetUITrigger<localizes>:message = "Trigger Device that when triggered will reset all of the resource UI elements for a player"
    @editable ResetUITrigger : trigger_device = trigger_device{}


    #Initializes players and sets up other devices
    OnBegin<override>()<suspends>:void=
        if(GameType = Game_Type.RPG):
            for(Player : GetPlayspace().GetPlayers()){InitResourcePlayer(Player)}
            GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoined)
            
        GetPlayspace().PlayerRemovedEvent().Subscribe(RemoveFromPlayerMap)

        ResourceSetup()

        for(C : ResourceDetails.AdditionalCollectors):
            set C.ResourceManager = Self
            C.ActivateTrigger.TriggeredEvent.Subscribe(C.PreHandleTrigger)

        ResetUITrigger.TriggeredEvent.Subscribe(ResetPlayerUI)


    OnPlayerJoined(Agent : agent):void=
        if(PlayerObj := player[Agent]):
            InitResourcePlayer(PlayerObj)

    #Initializes a resource player
    InitResourcePlayer(InitPlayer : player): void=
        if(PlayerExists := PlayersMap[InitPlayer]):  
            if(RP := PlayersMap[InitPlayer]):  
                if(GameType = Game_Type.RPG):
                    RP.SetResourceUI(InitPlayer)
        else:
            if(set PlayersMap[InitPlayer] = Player_Resource_Data{       
                Player := InitPlayer
                Resources := ResourceDetails.Resources
                ResourceManager := Self
                PopUpSettings := ResourceDetails.PopUpSettings
                }){}
            #Adds the UI
            if(RP := PlayersMap[InitPlayer]):  
                InitializeSavedData(InitPlayer)
                if(GameType = Game_Type.RPG):
                    RP.SetResourceUI(InitPlayer)

    #Initializes the saved resource data for a player
    InitializeSavedData(Player : player): void=
        if(RP := PlayersMap[Player],PlayerStats := PersistenceManager.GetPlayerStats[Player]):
            set RP.RebirthAmount = PlayerStats.Rebirths
            for(idx -> Re : RP.Resources):
                if(Re.SavePersistance?):
                    if(GameType = Game_Type.Tycoon):
                        if(idx = 0){set Re.ResourceAmount = PlayerStats.Currency1}
                        else if(idx = 1){set Re.ResourceAmount = PlayerStats.Currency2}
                        else if(idx = 2){set Re.ResourceAmount = PlayerStats.Currency3}
                        else if(idx = 3){set Re.ResourceAmount = PlayerStats.Currency4}
                        else if(idx = 4){set Re.ResourceAmount = PlayerStats.Currency5}
                        else if(idx = 5){set Re.ResourceAmount = PlayerStats.Currency6}
                        else if(idx = 6){set Re.ResourceAmount = PlayerStats.Currency7}
                        else if(idx = 7){set Re.ResourceAmount = PlayerStats.Currency8}
                        else if(idx = 8){set Re.ResourceAmount = PlayerStats.Currency9}
                        else if(idx = 9){set Re.ResourceAmount = PlayerStats.Currency10}
                    else:
                        if(idx = 0){set Re.ResourceAmount = PlayerStats.RPGResource1}
                        else if(idx = 1){set Re.ResourceAmount = PlayerStats.RPGResource2}
                        else if(idx = 2){set Re.ResourceAmount = PlayerStats.RPGResource3}
                        else if(idx = 3){set Re.ResourceAmount = PlayerStats.RPGResource4}
                        else if(idx = 4){set Re.ResourceAmount = PlayerStats.RPGResource5}
                        else if(idx = 5){set Re.ResourceAmount = PlayerStats.RPGResource6}
                        else if(idx = 6){set Re.ResourceAmount = PlayerStats.RPGResource7}
                        else if(idx = 7){set Re.ResourceAmount = PlayerStats.RPGResource8}
                        else if(idx = 8){set Re.ResourceAmount = PlayerStats.RPGResource9}
                        else if(idx = 9){set Re.ResourceAmount = PlayerStats.RPGResource10}

    #Removes the player from the map whenever they leave the session
    RemoveFromPlayerMap(Agent:agent) : void=
        if(Player := player[Agent],Exists := PlayersMap[Player]):
            if(NewMap := PlayersMap.WithRemovedKey(Player)?):
                set PlayersMap = NewMap

    #Sets up resources trigger events
    ResourceSetup() : void=
        for(Re : ResourceDetails.Resources):
            if(ShowTrigger := Re.UISettings?.HideUIElementsUntilTriggered?):
                spawn{ResourceTriggerWait(ShowTrigger , Re)}

    #Waits for resources trigger to be triggered and shows the resources widgets
    ResourceTriggerWait(Trigger : trigger_device , CheckResource : GeneralResource)<suspends> : void=
        loop:
            MAgent := Trigger.TriggeredEvent.Await()
            if(Agent := MAgent?, RP := PlayersMap[Agent]):
                for(Re : RP.Resources):
                    if(Re.ResourceName = CheckResource.ResourceName, RUI := Re.UISettings?):
                        set Re.IsHidden = false
                        RUI.ItemText.SetVisibility(widget_visibility.Visible)
                        RUI.ItemTexture.SetVisibility(widget_visibility.Visible)
                        RUI.ResourceIdleText.SetVisibility(widget_visibility.Visible)
                        RUI.ResourceIdleTexture.SetVisibility(widget_visibility.Visible)
                        RUI.ResourceBoostText.SetVisibility(widget_visibility.Visible)
                        RUI.ResourceBoostTexture.SetVisibility(widget_visibility.Visible)

    #Resets the players ui
    ResetPlayerUI(MAgent : ?agent) : void=
        if(Agent := MAgent?, RP := PlayersMap[Agent], RPUI := RP.ResourceUIMap[Agent]):
            RPUI.ResourceCanvas.SetVisibility(widget_visibility.Hidden)
            RPUI.ResourceCanvas.SetVisibility(widget_visibility.Visible)
            for(idx -> Re : RP.Resources, RUI := Re.UISettings?):
                if(not Re.IsHidden?):
                    RUI.ItemText.SetVisibility(widget_visibility.Hidden)
                    RUI.ItemTexture.SetVisibility(widget_visibility.Hidden)
                    RUI.ResourceIdleText.SetVisibility(widget_visibility.Hidden)
                    RUI.ResourceIdleTexture.SetVisibility(widget_visibility.Hidden)
                    RUI.ResourceBoostText.SetVisibility(widget_visibility.Hidden)
                    RUI.ResourceBoostTexture.SetVisibility(widget_visibility.Hidden)
                    RUI.ItemText.SetVisibility(widget_visibility.Visible)
                    RUI.ItemTexture.SetVisibility(widget_visibility.Visible)
                    RUI.ResourceIdleText.SetVisibility(widget_visibility.Visible)
                    RUI.ResourceIdleTexture.SetVisibility(widget_visibility.Visible)
                    RUI.ResourceBoostText.SetVisibility(widget_visibility.Visible)
                    RUI.ResourceBoostTexture.SetVisibility(widget_visibility.Visible)

    GetPlayersWhoCanAfford(Player : agent , NewSpendResource : SpendableResource , Amount : float) : []agent =
        var AffordPlayers : []agent = array{}
        for(DifferentPlayer : GetPlayspace().GetPlayers() , DifferentPlayer <> Player , DiffRP := PlayersMap[DifferentPlayer]):
            HasEnough := DiffRP.Check(array{NewSpendResource})
            if(HasEnough?){set AffordPlayers += array{DifferentPlayer}}
        return AffordPlayers



