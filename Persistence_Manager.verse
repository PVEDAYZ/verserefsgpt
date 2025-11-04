
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

player_stats_table := class<final><persistable>:
    Currency : int = 0
    UnlockDoors : []int = array{}


var PlayerStatsMap : weak_map(player , player_stats_table) = map{}

MakePlayerStatsTable<constructor>(OldTable : player_stats_table)<transacts> := player_stats_table:
    Currency := OldTable.Currency
    UnlockDoors := OldTable.UnlockDoors


Persistence_Manager := class():

    InitializePlayer(Player : player) : void=
        if:
            Player.IsActive[]
            not PlayerStatsMap[Player]
            set PlayerStatsMap[Player] = player_stats_table{}


    GetPlayerStats(Agent:agent) : player_stats_table=
        var NewPlayerStats : player_stats_table = player_stats_table{}
        if:
            Player := player[Agent]
            PlayerTable := PlayerStatsMap[Player]
            set NewPlayerStats = PlayerTable
        return NewPlayerStats

    UpdatePlayerStats(Agent : agent, Amount : int, Stat : string) : void=
        if:
            Player := player[Agent]
            Player.IsActive[]
            PlayerTable := PlayerStatsMap[Player]
            if(Stat = "Currency"):
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerTable)
                    Currency := Amount

            else if(Stat = "UnlockDoors"):
                UnlockDoorStat := PlayerTable.UnlockDoors
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerTable)
                    UnlockDoors := UnlockDoorStat + array{Amount}



