using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

#THIS SCRIPT HOLDS & ADDS ALL PERSISTABLE VARIABLES FOR PLAYERS


#Main Class
Tycoon_Persistence_Manager := class(Base_Persistence_Manager):

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


            if(Stat.Name = "Playtime"):
                PlaytimeStat := PlayerStatsTable.Playtime
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Playtime := PlaytimeStat + Score
                    

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


            if(Stat.Name = "Playtime"):
                PlaytimeStat := PlayerStatsTable.Playtime
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Playtime := Score
                    

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


    #Adds a specific number into an array stat
    RecordPlayerArrStat<override>(Agent:agent, Stat:stat_type, ?Score:int = 0):void=
        if:
            Player := player[Agent]
            Player.IsActive[]
            PlayerStatsTable := PlayerStatsMap[Player]
            

            if(Stat.Name = "Doors"):
                DoorsStat := PlayerStatsTable.BoughtDoors
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    BoughtDoors := DoorsStat + array{Score}

            else if(Stat.Name = "Pets"):
                PetsStat := PlayerStatsTable.BoughtPets
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    BoughtPets := PetsStat + array{Score}

            else if(Stat.Name = "Apparels"):
                ApparelsStat := PlayerStatsTable.BoughtApparels
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    BoughtApparels := ApparelsStat + array{Score}

            else if(Stat.Name = "Colors"):
                ColorsStat := PlayerStatsTable.BoughtColors
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    BoughtColors := ColorsStat + array{Score}        

            else if(Stat.Name = "ClaimedRewards"):
                ClaimedRewardsStat := PlayerStatsTable.ClaimedRewards
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    ClaimedRewards := ClaimedRewardsStat + array{Score}

            else if(Stat.Name = "EquippedPets"):
                EquippedPetsStat := PlayerStatsTable.EquippedPets
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    EquippedPets := EquippedPetsStat + array{Score}

            else if(Stat.Name = "EquippedApparels"):
                EquippedApparelsStat := PlayerStatsTable.EquippedApparels
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    EquippedApparels := EquippedApparelsStat + array{Score}



            else if(Stat.Name = "Bar1Upgrades"):
                Bar1UpgradesStat := PlayerStatsTable.Bar1Upgrades
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Bar1Upgrades := Bar1UpgradesStat + array{Score}

            else if(Stat.Name = "Bar2Upgrades"):
                Bar2UpgradesStat := PlayerStatsTable.Bar2Upgrades
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Bar2Upgrades := Bar2UpgradesStat + array{Score}

            else if(Stat.Name = "Bar3Upgrades"):
                Bar3UpgradesStat := PlayerStatsTable.Bar3Upgrades
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Bar3Upgrades := Bar3UpgradesStat + array{Score}


            else if(Stat.Name = "PlotID"):
                ScoreInt := Score
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    PlotID := ScoreInt

    #Sets a specific number into an array stat
    SetPlayerArrStat<override>(Agent:agent, Stat:stat_type, ?Score:[]int):void=
        if:
            Player := player[Agent]
            Player.IsActive[]
            PlayerStatsTable := PlayerStatsMap[Player]
            

            if(Stat.Name = "Doors"):
                DoorsStat := PlayerStatsTable.BoughtDoors
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    BoughtDoors := Score

            else if(Stat.Name = "Pets"):
                PetsStat := PlayerStatsTable.BoughtPets
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    BoughtPets := Score

            else if(Stat.Name = "Apparels"):
                ApparelsStat := PlayerStatsTable.BoughtApparels
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    BoughtApparels := Score

            else if(Stat.Name = "Colors"):
                ColorsStat := PlayerStatsTable.BoughtColors
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    BoughtColors := Score

            else if(Stat.Name = "ClaimedRewards"):
                ClaimedRewardsStat := PlayerStatsTable.ClaimedRewards
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    ClaimedRewards := Score

            else if(Stat.Name = "EquippedPets"):
                EquippedPetsStat := PlayerStatsTable.EquippedPets
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    EquippedPets := Score

            else if(Stat.Name = "EquippedApparels"):
                EquippedApparelsStat := PlayerStatsTable.EquippedApparels
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    EquippedApparels := Score



            else if(Stat.Name = "Bar1Upgrades"):
                Bar1UpgradesStat := PlayerStatsTable.Bar1Upgrades
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Bar1Upgrades := Score

            else if(Stat.Name = "Bar2Upgrades"):
                Bar2UpgradesStat := PlayerStatsTable.Bar2Upgrades
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Bar2Upgrades := Score

            else if(Stat.Name = "Bar3Upgrades"):
                Bar3UpgradesStat := PlayerStatsTable.Bar3Upgrades
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Bar3Upgrades := Score

    #Resets a specific array stat
    ResetPlayerArrStat<override>(Agent:agent, Stat:stat_type):void=
        if:
            Player := player[Agent]
            Player.IsActive[]
            PlayerStatsTable := PlayerStatsMap[Player]
            

            if(Stat.Name = "Doors"):
                DoorsStat := PlayerStatsTable.BoughtDoors
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    BoughtDoors := array{}
        
            else if(Stat.Name = "Pets"):
                PetsStat := PlayerStatsTable.BoughtPets
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    BoughtPets := array{}

            else if(Stat.Name = "Apparels"):
                ApparelsStat := PlayerStatsTable.BoughtApparels
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    BoughtApparels := array{}

            else if(Stat.Name = "ClaimedRewards"):
                ClaimedRewardsStat := PlayerStatsTable.ClaimedRewards
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    ClaimedRewards := array{}



            else if(Stat.Name = "EquippedPets"):
                EquippedPetsStat := PlayerStatsTable.EquippedPets
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    EquippedPets := array{}

            else if(Stat.Name = "EquippedApparels"):
                EquippedApparelsStat := PlayerStatsTable.EquippedApparels
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    EquippedApparels := array{0,0,0}


            else if(Stat.Name = "Bar1Upgrades"):
                Bar1UpgradesStat := PlayerStatsTable.Bar1Upgrades
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Bar1Upgrades := array{}

            else if(Stat.Name = "Bar2Upgrades"):
                Bar2UpgradesStat := PlayerStatsTable.Bar2Upgrades
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Bar2Upgrades := array{}

            else if(Stat.Name = "Bar3Upgrades"):
                Bar3UpgradesStat := PlayerStatsTable.Bar3Upgrades
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Bar3Upgrades := array{}

    #Removes a specific number from an array stat
    RemovePlayerArrStat<override>(Agent:agent, Stat:stat_type, ?Score:int = 0):void=
        if:
            Player := player[Agent]
            Player.IsActive[]
            PlayerStatsTable := PlayerStatsMap[Player]
            
            if(Stat.Name = "EquippedPets"):
                EquippedPetsStat := PlayerStatsTable.EquippedPets
                NewArray := EquippedPetsStat.RemoveFirstElement[Score]
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    EquippedPets := NewArray
          
    #Replaces a specific number from an array stat with another specific number
    ReplacePlayerArrStat<override>(Agent:agent, Stat:stat_type, ?ReplaceInt:int = 0 , ?Score:int = 0):void=
        if:
            Player := player[Agent]
            Player.IsActive[]
            PlayerStatsTable := PlayerStatsMap[Player]
            
            if(Stat.Name = "EquippedApparels"):
                EquippedApparelsStat := PlayerStatsTable.EquippedApparels
                NewArray := EquippedApparelsStat.ReplaceElement[ReplaceInt , Score]
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    EquippedApparels := NewArray