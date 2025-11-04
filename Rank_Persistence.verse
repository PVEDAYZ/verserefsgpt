
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
using { /Fortnite.com/UI }

#THIS CODE IS A TABLE FOR ALL PLAYER STAT PERSISTENCE

player_stat := class<final><persistable>:
    CurrentValue:int = 0

    SetHighestValue(NewValue:int)<transacts>:int=
        CurrentValue

MakeUpdatedPlayerStat<constructor>(OldStats:player_stat, NewValue:int)<transacts> := player_stat:
    CurrentValue := NewValue


player_stats_table := class<final><persistable>:

    RankValue : float = 0.0
    Eliminations : float = 0.0
    Deaths : float = 0.0
    Wins : float = 0.0
    Loses : float = 0.0
    Prestiges : float = 0.0
    


var PlayerStatsMap:weak_map(player, player_stats_table) = map{}

MakePlayerStatsTable<constructor>(OldTable:player_stats_table)<transacts> := player_stats_table:
    RankValue := OldTable.RankValue
    Eliminations := OldTable.Eliminations
    Deaths := OldTable.Deaths
    Wins := OldTable.Wins
    Loses := OldTable.Loses
    Prestiges := OldTable.Prestiges




stat_type := class<computes><unique><abstract>:
    DebugString():string

StatType := module:
    rankvalue_stat<public> := class<computes><unique>(stat_type):
        DebugString<override>():string = "RankValue"

    eliminations_stat<public> := class<computes><unique>(stat_type):
        DebugString<override>():string = "Eliminations"

    deaths_stat<public> := class<computes><unique>(stat_type):
        DebugString<override>():string = "Deaths"

    wins_stat<public> := class<computes><unique>(stat_type):
        DebugString<override>():string = "Wins"

    loses_stat<public> := class<computes><unique>(stat_type):
        DebugString<override>():string = "Loses"

    prestiges_stat<public> := class<computes><unique>(stat_type):
        DebugString<override>():string = "Prestiges"



    # Instances of each stat_type you can use in your experience

    RankValue<public>:rankvalue_stat = rankvalue_stat{}
    Eliminations<public>:eliminations_stat = eliminations_stat{}
    Deaths<public>:deaths_stat = deaths_stat{}
    Wins<public>:wins_stat = wins_stat{}
    Loses<public>:loses_stat = loses_stat{}
    Prestiges<public>:prestiges_stat = prestiges_stat{}
   


Rank_Persistence := class():
    InitializePlayer(Player:player):void=
        if:
            not PlayerStatsMap[Player]
            set PlayerStatsMap[Player] = player_stats_table{}

    GetPlayerStats(Agent:agent)<decides><transacts>:player_stats_table=
        var PlayerStats:player_stats_table = player_stats_table{}
        if:
            Player := player[Agent]
            PlayerStatsTable := PlayerStatsMap[Player]
            set PlayerStats = MakePlayerStatsTable(PlayerStatsTable)
        PlayerStats

        
    RecordPlayerStat(Agent:agent, Stat:stat_type, ?Score:float = 0.0):void=
        if:
            Player := player[Agent]
            PlayerStatsTable := PlayerStatsMap[Player]

            if(Stat = StatType.RankValue):
                RankValueStat := PlayerStatsTable.RankValue
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    RankValue := RankValueStat + Score

            else if(Stat = StatType.Eliminations):
                EliminationsStat := PlayerStatsTable.Eliminations
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Eliminations := EliminationsStat + Score

            else if(Stat = StatType.Deaths):
                DeathsStat := PlayerStatsTable.Deaths
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Deaths := DeathsStat + Score

            else if(Stat = StatType.Wins):
                WinsStat := PlayerStatsTable.Wins
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Wins := WinsStat + Score

            else if(Stat = StatType.Loses):
                LosesStat := PlayerStatsTable.Loses
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Loses := LosesStat + Score

            else if(Stat = StatType.Prestiges):
                PrestigesStat := PlayerStatsTable.Prestiges
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Prestiges := PrestigesStat + Score
        