using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

#THIS SCRIPT HOLDS & ADDS ALL PERSISTABLE VARIABLES FOR PLAYERS

#Stat type that is persistable
player_stat := class<final><persistable>:
    CurrentValue:int = 0
    SetHighestValue(NewValue:int)<transacts>:int=
        CurrentValue

#Makes a new stat based off of the current value
MakeUpdatedPlayerStat<constructor>(OldStats:player_stat, NewValue:int)<transacts> := player_stat:
    CurrentValue := NewValue

#Table holding all of the different persistable variables
player_stats_table := class<final><persistable>:

#Tycoon Content -----------------------------------------------------------------------------------------------------------------------------
    BoughtPets : []int = array {}
    BoughtDoors : []int = array {}
    BoughtApparels : []int = array{}
    BoughtColors : []int = array{}
    ClaimedRewards : []int = array{}
    
    EquippedPets : []int = array {}
    EquippedApparels : []int = array {0,0,0}

    Rebirths : float = 0.0
    Playtime : float = 0.0

    Bar1Upgrades : []int = array {}
    Bar2Upgrades : []int = array {}
    Bar3Upgrades : []int = array{}

    Currency1 : float = 0.0
    Currency2 : float = 0.0
    Currency3 : float = 0.0
    Currency4 : float = 0.0
    Currency5 : float = 0.0
    Currency6 : float = 0.0
    Currency7 : float = 0.0
    Currency8 : float = 0.0
    Currency9 : float = 0.0
    Currency10 : float = 0.0

    PlotID : int = 0

#Ranked Content -------------------------------------------------------------------------------------------------------------------------------
    RankValue : float = 0.0
    Eliminations : float = 0.0
    Deaths : float = 0.0
    Wins : float = 0.0
    Loses : float = 0.0
    Prestiges : float = 0.0

#Finisher Content -------------------------------------------------------------------------------------------------------------------------------
    BoughtFinishers : []int = array {}
    EquippedFinisher : int = 0

#Daily Reward Content -------------------------------------------------------------------------------------------------------------------------------

    DRClaimedDays : int = 0

    DRTimeUntilNextClaim : int = 0

    DRHasPremium : int = 0

#RPG Content --------------------------------------------------------------------------------------------------------------------------------
    BoughtRPGZones : []int = array{}

    EquippedRPGPets : []int = array {}

    EquippedRPGWeapons : []int = array {}

    # Attribute Collection (attribute value, attribute points, attribute boost, attribute critical chance, attribute critical multiplier)
    AttributeCollection1 : []float = array{0.0,0.0,1.0,0.0,0.0}
    AttributeCollection2 : []float = array{0.0,0.0,1.0,0.0,0.0}
    AttributeCollection3 : []float = array{0.0,0.0,1.0,0.0,0.0}
    AttributeCollection4 : []float = array{0.0,0.0,1.0,0.0,0.0}
    AttributeCollection5 : []float = array{0.0,0.0,1.0,0.0,0.0}
    AttributeCollection6 : []float = array{0.0,0.0,1.0,0.0,0.0}
    AttributeCollection7 : []float = array{0.0,0.0,1.0,0.0,0.0}


    #Fort Attributes

    FortHealthAttributeCollection : []float = array{0.0,0.0,1.0}

    FortShieldAttributeCollection : []float = array{0.0,0.0,1.0}


    PrestigeCount : float = 0.0
    RPGMaxPetEquipCount : float = 1.0

    RPGResource1 : float = 0.0
    RPGResource2 : float = 0.0
    RPGResource3 : float = 0.0
    RPGResource4 : float = 0.0
    RPGResource5 : float = 0.0
    RPGResource6 : float = 0.0
    RPGResource7 : float = 0.0
    RPGResource8 : float = 0.0
    RPGResource9 : float = 0.0
    RPGResource10 : float = 0.0

    # Pet Stats (owned count, pet level)
    OwnedRPGPetStat1 : []float = array{0.0,0.0}
    OwnedRPGPetStat2 : []float = array{0.0,0.0}
    OwnedRPGPetStat3 : []float = array{0.0,0.0}
    OwnedRPGPetStat4 : []float = array{0.0,0.0}
    OwnedRPGPetStat5 : []float = array{0.0,0.0}
    OwnedRPGPetStat6 : []float = array{0.0,0.0}
    OwnedRPGPetStat7 : []float = array{0.0,0.0}
    OwnedRPGPetStat8 : []float = array{0.0,0.0}
    OwnedRPGPetStat9 : []float = array{0.0,0.0}
    OwnedRPGPetStat10 : []float = array{0.0,0.0}

    # Weapon Stats (owned count, weapon level)
    OwnedRPGWeaponStat1 : []float = array{0.0,0.0}
    OwnedRPGWeaponStat2 : []float = array{0.0,0.0}
    OwnedRPGWeaponStat3 : []float = array{0.0,0.0}
    OwnedRPGWeaponStat4 : []float = array{0.0,0.0}
    OwnedRPGWeaponStat5 : []float = array{0.0,0.0}
    OwnedRPGWeaponStat6 : []float = array{0.0,0.0}
    OwnedRPGWeaponStat7 : []float = array{0.0,0.0}
    OwnedRPGWeaponStat8 : []float = array{0.0,0.0}
    OwnedRPGWeaponStat9 : []float = array{0.0,0.0}
    OwnedRPGWeaponStat10 : []float = array{0.0,0.0}


#Player map to connect all of the values to a player
var PlayerStatsMap:weak_map(player, player_stats_table) = map{}

#Makes a new stats table from the current/old table
MakePlayerStatsTable<constructor>(OldTable:player_stats_table)<transacts> := player_stats_table:
    BoughtPets := OldTable.BoughtPets
    BoughtDoors := OldTable.BoughtDoors
    BoughtApparels := OldTable.BoughtApparels
    BoughtColors := OldTable.BoughtColors
    ClaimedRewards := OldTable.ClaimedRewards

    EquippedPets := OldTable.EquippedPets
    EquippedApparels := OldTable.EquippedApparels

    Rebirths := OldTable.Rebirths
    Playtime := OldTable.Playtime

    Bar1Upgrades := OldTable.Bar1Upgrades
    Bar2Upgrades := OldTable.Bar2Upgrades 
    Bar3Upgrades := OldTable.Bar3Upgrades

    Currency1 := OldTable.Currency1
    Currency2 := OldTable.Currency2
    Currency3 := OldTable.Currency3
    Currency4 := OldTable.Currency4
    Currency5 := OldTable.Currency5
    Currency6 := OldTable.Currency6
    Currency7 := OldTable.Currency7
    Currency8 := OldTable.Currency8
    Currency9 := OldTable.Currency9
    Currency10 := OldTable.Currency10

    PlotID := OldTable.PlotID





    RankValue := OldTable.RankValue
    Eliminations := OldTable.Eliminations
    Deaths := OldTable.Deaths
    Wins := OldTable.Wins
    Loses := OldTable.Loses
    Prestiges := OldTable.Prestiges


    BoughtFinishers := OldTable.BoughtFinishers
    EquippedFinisher := OldTable.EquippedFinisher


    DRClaimedDays := OldTable.DRClaimedDays
    DRTimeUntilNextClaim := OldTable.DRTimeUntilNextClaim
    DRHasPremium := OldTable.DRHasPremium


    BoughtRPGZones := OldTable.BoughtRPGZones

    EquippedRPGPets := OldTable.EquippedRPGPets

    EquippedRPGWeapons := OldTable.EquippedRPGWeapons

    AttributeCollection1 := OldTable.AttributeCollection1
    AttributeCollection2 := OldTable.AttributeCollection2
    AttributeCollection3 := OldTable.AttributeCollection3
    AttributeCollection4 := OldTable.AttributeCollection4
    AttributeCollection5 := OldTable.AttributeCollection5
    AttributeCollection6 := OldTable.AttributeCollection6
    AttributeCollection7 := OldTable.AttributeCollection7

    FortShieldAttributeCollection := OldTable.FortShieldAttributeCollection
    FortHealthAttributeCollection := OldTable.FortHealthAttributeCollection

    PrestigeCount := OldTable.PrestigeCount
    RPGMaxPetEquipCount := OldTable.RPGMaxPetEquipCount
    

    RPGResource1 := OldTable.RPGResource1
    RPGResource2 := OldTable.RPGResource2
    RPGResource3 := OldTable.RPGResource3
    RPGResource4 := OldTable.RPGResource4
    RPGResource5 := OldTable.RPGResource5
    RPGResource6 := OldTable.RPGResource6
    RPGResource7 := OldTable.RPGResource7
    RPGResource8 := OldTable.RPGResource8
    RPGResource9 := OldTable.RPGResource9
    RPGResource10 := OldTable.RPGResource10

    OwnedRPGPetStat1 := OldTable.OwnedRPGPetStat1
    OwnedRPGPetStat2 := OldTable.OwnedRPGPetStat2
    OwnedRPGPetStat3 := OldTable.OwnedRPGPetStat3
    OwnedRPGPetStat4 := OldTable.OwnedRPGPetStat4
    OwnedRPGPetStat5 := OldTable.OwnedRPGPetStat5
    OwnedRPGPetStat6 := OldTable.OwnedRPGPetStat6
    OwnedRPGPetStat7 := OldTable.OwnedRPGPetStat7
    OwnedRPGPetStat8 := OldTable.OwnedRPGPetStat8
    OwnedRPGPetStat9 := OldTable.OwnedRPGPetStat9
    OwnedRPGPetStat10 := OldTable.OwnedRPGPetStat10 

    OwnedRPGWeaponStat1 := OldTable.OwnedRPGWeaponStat1
    OwnedRPGWeaponStat2 := OldTable.OwnedRPGWeaponStat2
    OwnedRPGWeaponStat3 := OldTable.OwnedRPGWeaponStat3
    OwnedRPGWeaponStat4 := OldTable.OwnedRPGWeaponStat4
    OwnedRPGWeaponStat5 := OldTable.OwnedRPGWeaponStat5
    OwnedRPGWeaponStat6 := OldTable.OwnedRPGWeaponStat6
    OwnedRPGWeaponStat7 := OldTable.OwnedRPGWeaponStat7
    OwnedRPGWeaponStat8 := OldTable.OwnedRPGWeaponStat8
    OwnedRPGWeaponStat9 := OldTable.OwnedRPGWeaponStat9
    OwnedRPGWeaponStat10 := OldTable.OwnedRPGWeaponStat10



#Base stat type for each resource
stat_type := class<computes><abstract> :
    Name : string

#Classes of all different stat types
StatType := module:
    doors<public> := class<computes>(stat_type):
    pets<public> := class<computes>(stat_type):
    apparels<public> := class<computes>(stat_type):
    colors<public> := class<computes>(stat_type):
    rewards<public> := class<computes>(stat_type):


    equippedpets<public> := class<computes>(stat_type):
    equippedapparels<public> := class<computes>(stat_type):


    rebirths<public> := class<computes>(stat_type):
    playtime<public> := class<computes>(stat_type):

    bar1upgrades<public> := class<computes>(stat_type):
    bar2upgrades<public> := class<computes>(stat_type):
    bar3upgrades<public> := class<computes>(stat_type):

    currency1<public> := class<computes>(stat_type):
    currency2<public> := class<computes>(stat_type):
    currency3<public> := class<computes>(stat_type):
    currency4<public> := class<computes>(stat_type):
    currency5<public> := class<computes>(stat_type):
    currency6<public> := class<computes>(stat_type):
    currency7<public> := class<computes>(stat_type):
    currency8<public> := class<computes>(stat_type):
    currency9<public> := class<computes>(stat_type):
    currency10<public> := class<computes>(stat_type):

    plotid<public> := class<computes>(stat_type):




    rankvalue_stat<public> := class<computes>(stat_type):

    eliminations_stat<public> := class<computes>(stat_type):

    deaths_stat<public> := class<computes>(stat_type):

    wins_stat<public> := class<computes>(stat_type):

    loses_stat<public> := class<computes>(stat_type):

    prestiges_stat<public> := class<computes>(stat_type):




    boughtfinishers<public> := class<computes>(stat_type):
    equippedfinisher<public> := class<computes>(stat_type):


    
    daysclaimed<public> := class<computes>(stat_type):
    timetilnextclaim<public> := class<computes>(stat_type):
    drhaspremium<public> := class<computes>(stat_type):    


    boughtrpgzones<public> := class<computes>(stat_type):
    equippedrpgpets<public> := class<computes>(stat_type):
    equippedrpgweapons<public> := class<computes>(stat_type):

    attributecollection1<public> := class<computes>(stat_type):
    attributecollection2<public> := class<computes>(stat_type):
    attributecollection3<public> := class<computes>(stat_type):
    attributecollection4<public> := class<computes>(stat_type):
    attributecollection5<public> := class<computes>(stat_type):
    attributecollection6<public> := class<computes>(stat_type):
    attributecollection7<public> := class<computes>(stat_type):

    fortschildattributecollection<public> := class<computes>(stat_type):
    forthealthattributecollection<public> := class<computes>(stat_type):

    prestigecount<public> := class<computes>(stat_type):
    rpgmaxpetequipcount<public> := class<computes>(stat_type):
        

    rpgresource1<public> := class<computes>(stat_type):
    rpgresource2<public> := class<computes>(stat_type):
    rpgresource3<public> := class<computes>(stat_type):
    rpgresource4<public> := class<computes>(stat_type):
    rpgresource5<public> := class<computes>(stat_type):
    rpgresource6<public> := class<computes>(stat_type):
    rpgresource7<public> := class<computes>(stat_type):
    rpgresource8<public> := class<computes>(stat_type):
    rpgresource9<public> := class<computes>(stat_type):
    rpgresource10<public> := class<computes>(stat_type):

    ownedrpgpetstat1<public> := class<computes>(stat_type):
    ownedrpgpetstat2<public> := class<computes>(stat_type):
    ownedrpgpetstat3<public> := class<computes>(stat_type):
    ownedrpgpetstat4<public> := class<computes>(stat_type):
    ownedrpgpetstat5<public> := class<computes>(stat_type):
    ownedrpgpetstat6<public> := class<computes>(stat_type):
    ownedrpgpetstat7<public> := class<computes>(stat_type):
    ownedrpgpetstat8<public> := class<computes>(stat_type):
    ownedrpgpetstat9<public> := class<computes>(stat_type):
    ownedrpgpetstat10<public> := class<computes>(stat_type):
          
    ownedrpgweaponstat1<public> := class<computes>(stat_type):
    ownedrpgweaponstat2<public> := class<computes>(stat_type):
    ownedrpgweaponstat3<public> := class<computes>(stat_type):
    ownedrpgweaponstat4<public> := class<computes>(stat_type):
    ownedrpgweaponstat5<public> := class<computes>(stat_type):
    ownedrpgweaponstat6<public> := class<computes>(stat_type):
    ownedrpgweaponstat7<public> := class<computes>(stat_type):
    ownedrpgweaponstat8<public> := class<computes>(stat_type):
    ownedrpgweaponstat9<public> := class<computes>(stat_type):
    ownedrpgweaponstat10<public> := class<computes>(stat_type):


    # Instances of each stat_type you can use in your experience

    Doors <public>:doors = doors{Name := "Doors"}
    Pets <public>:pets = pets{Name := "Pets"}
    Apparels <public>:apparels = apparels{Name := "Apparels"}
    Colors <public>:colors = colors{Name := "Colors"}
    ClaimedRewards<public>:rewards = rewards{Name := "ClaimedRewards"}

    EquippedPets <public>:equippedpets = equippedpets{Name := "EquippedPets"}
    EquippedApparels <public>:equippedapparels = equippedapparels{Name := "EquippedApparels"}

    Rebirths <public>:rebirths = rebirths{Name := "Rebirths"}
    Playtime <public>:playtime = playtime{Name := "Playtime"}

    Bar1Upgrades <public>:bar1upgrades = bar1upgrades{Name := "Bar1Upgrades"}
    Bar2Upgrades <public>:bar2upgrades = bar2upgrades{Name := "Bar2Upgrades"}
    Bar3Upgrades <public>:bar3upgrades = bar3upgrades{Name := "Bar3Upgrades"}


    Currency1 <public>:currency1 = currency1{Name := "Currency1"}
    Currency2<public>:currency2 = currency2{Name := "Currency2"}
    Currency3<public>:currency3 = currency3{Name := "Currency3"}
    Currency4<public>:currency4 = currency4{Name := "Currency4"}
    Currency5<public>:currency5 = currency5{Name := "Currency5"}
    Currency6<public>:currency6 = currency6{Name := "Currency6"}
    Currency7<public>:currency7 = currency7{Name := "Currency7"}
    Currency8<public>:currency8 = currency8{Name := "Currency8"}
    Currency9<public>:currency9 = currency9{Name := "Currency9"}
    Currency10<public>:currency10 = currency10{Name := "Currency10"}

    PlotID<public>:plotid = plotid{Name := "PlotID"}




    RankValue<public>:rankvalue_stat = rankvalue_stat{Name := "RankValue"}
    Eliminations<public>:eliminations_stat = eliminations_stat{Name := "Eliminations"}
    Deaths<public>:deaths_stat = deaths_stat{Name := "Deaths"}
    Wins<public>:wins_stat = wins_stat{Name := "Wins"}
    Loses<public>:loses_stat = loses_stat{Name := "Loses"}
    Prestiges<public>:prestiges_stat = prestiges_stat{Name := "Prestiges"}
   


    BoughtFinishers <public>:boughtfinishers = boughtfinishers{Name := "BoughtFinishers"}
    EquippedFinisher <public>:equippedfinisher = equippedfinisher{Name := "EquippedFinisher"}


    DRClaimedDays <public>:daysclaimed = daysclaimed{Name := "ClaimedDays"}
    DRTimeUntilNextClaim <public>:timetilnextclaim = timetilnextclaim{Name := "TimeUntilNextClaim"}
    DRHasPremium <public>:drhaspremium = drhaspremium{Name := "DRHasPremium"}


    BoughtRPGZones <public>:boughtrpgzones = boughtrpgzones{Name := "BoughtRPGZones"}
    EquippedRPGPets <public>:equippedrpgpets = equippedrpgpets{Name := "EquippedRPGPets"}
    EquippedRPGWeapons <public>:equippedrpgweapons = equippedrpgweapons{Name := "EquippedRPGWeapons"}

    AttributeCollection1 <public>:attributecollection1 = attributecollection1{Name := "AttributeCollection1"}
    AttributeCollection2 <public>:attributecollection2 = attributecollection2{Name := "AttributeCollection2"}
    AttributeCollection3 <public>:attributecollection3 = attributecollection3{Name := "AttributeCollection3"}
    AttributeCollection4 <public>:attributecollection4 = attributecollection4{Name := "AttributeCollection4"}
    AttributeCollection5 <public>:attributecollection5 = attributecollection5{Name := "AttributeCollection5"}
    AttributeCollection6 <public>:attributecollection6 = attributecollection6{Name := "AttributeCollection6"}
    AttributeCollection7 <public>:attributecollection7 = attributecollection7{Name := "AttributeCollection7"}

    FortShieldAttributeCollection <public>:fortschildattributecollection = fortschildattributecollection{Name := "FortShieldAttributeCollection"}
    FortHealthAttributeCollection <public>:forthealthattributecollection = forthealthattributecollection{Name := "FortHealthAttributeCollection"}

    PrestigeCount <public>:prestigecount = prestigecount{Name := "PrestigeCount"}
    RPGMaxPetEquipCount <public>:rpgmaxpetequipcount = rpgmaxpetequipcount{Name := "RPGMaxPetEquipCount"}

    RPGResource1 <public>:rpgresource1 = rpgresource1{Name := "RPGResource1"}
    RPGResource2 <public>:rpgresource2 = rpgresource2{Name := "RPGResource2"}
    RPGResource3 <public>:rpgresource3 = rpgresource3{Name := "RPGResource3"}
    RPGResource4 <public>:rpgresource4 = rpgresource4{Name := "RPGResource4"}
    RPGResource5 <public>:rpgresource5 = rpgresource5{Name := "RPGResource5"}
    RPGResource6 <public>:rpgresource6 = rpgresource6{Name := "RPGResource6"}
    RPGResource7 <public>:rpgresource7 = rpgresource7{Name := "RPGResource7"}
    RPGResource8 <public>:rpgresource8 = rpgresource8{Name := "RPGResource8"}
    RPGResource9 <public>:rpgresource9 = rpgresource9{Name := "RPGResource9"}
    RPGResource10 <public>:rpgresource10 = rpgresource10{Name := "RPGResource10"}

    OwnedRPGPetStat1 <public>:ownedrpgpetstat1 = ownedrpgpetstat1{Name := "OwnedRPGPetStat1"}
    OwnedRPGPetStat2 <public>:ownedrpgpetstat2 = ownedrpgpetstat2{Name := "OwnedRPGPetStat2"}
    OwnedRPGPetStat3 <public>:ownedrpgpetstat3 = ownedrpgpetstat3{Name := "OwnedRPGPetStat3"}
    OwnedRPGPetStat4 <public>:ownedrpgpetstat4 = ownedrpgpetstat4{Name := "OwnedRPGPetStat4"}
    OwnedRPGPetStat5 <public>:ownedrpgpetstat5 = ownedrpgpetstat5{Name := "OwnedRPGPetStat5"}
    OwnedRPGPetStat6 <public>:ownedrpgpetstat6 = ownedrpgpetstat6{Name := "OwnedRPGPetStat6"}
    OwnedRPGPetStat7 <public>:ownedrpgpetstat7 = ownedrpgpetstat7{Name := "OwnedRPGPetStat7"}
    OwnedRPGPetStat8 <public>:ownedrpgpetstat8 = ownedrpgpetstat8{Name := "OwnedRPGPetStat8"}
    OwnedRPGPetStat9 <public>:ownedrpgpetstat9 = ownedrpgpetstat9{Name := "OwnedRPGPetStat9"}
    OwnedRPGPetStat10 <public>:ownedrpgpetstat10 = ownedrpgpetstat10{Name := "OwnedRPGPetStat10"}

    OwnedRPGWeaponStat1 <public>:ownedrpgweaponstat1 = ownedrpgweaponstat1{Name := "OwnedRPGWeaponStat1"}
    OwnedRPGWeaponStat2 <public>:ownedrpgweaponstat2 = ownedrpgweaponstat2{Name := "OwnedRPGWeaponStat2"}
    OwnedRPGWeaponStat3 <public>:ownedrpgweaponstat3 = ownedrpgweaponstat3{Name := "OwnedRPGWeaponStat3"}
    OwnedRPGWeaponStat4 <public>:ownedrpgweaponstat4 = ownedrpgweaponstat4{Name := "OwnedRPGWeaponStat4"}
    OwnedRPGWeaponStat5 <public>:ownedrpgweaponstat5 = ownedrpgweaponstat5{Name := "OwnedRPGWeaponStat5"}
    OwnedRPGWeaponStat6 <public>:ownedrpgweaponstat6 = ownedrpgweaponstat6{Name := "OwnedRPGWeaponStat6"}
    OwnedRPGWeaponStat7 <public>:ownedrpgweaponstat7 = ownedrpgweaponstat7{Name := "OwnedRPGWeaponStat7"}
    OwnedRPGWeaponStat8 <public>:ownedrpgweaponstat8 = ownedrpgweaponstat8{Name := "OwnedRPGWeaponStat8"}
    OwnedRPGWeaponStat9 <public>:ownedrpgweaponstat9 = ownedrpgweaponstat9{Name := "OwnedRPGWeaponStat9"}
    OwnedRPGWeaponStat10 <public>:ownedrpgweaponstat10 = ownedrpgweaponstat10{Name := "OwnedRPGWeaponStat10"}
        
