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
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Assets }

#THIS DEVICE IS USED TO SHOW A BOARD OF PLAYER STATS WHEN THEY PRESS A REMOTE


#Class for each player to hold their stat board and perform board actions
RankedPlayerWithStatBoard:= class():

    #Stat board for the player
    PlayerStatBoard : FullBoard = FullBoard{}

    #Used to get players rank
    var RankSystem : Rank_System = Rank_System{}

    #Array of materials for rank images
    var RankImageMats : []material = array{RankMaterials.UNRANKED_MAT,RankMaterials.BRONZE_MAT_1, RankMaterials.BRONZE_MAT_2,RankMaterials.BRONZE_MAT_3,RankMaterials.SILVER_MAT_1,RankMaterials.SILVER_MAT_2,RankMaterials.SILVER_MAT_3,RankMaterials.GOLD_MAT_1,RankMaterials.GOLD_MAT_2,RankMaterials.GOLD_MAT_3,RankMaterials.PLATINUM_MAT_1,RankMaterials.PLATINUM_MAT_2,RankMaterials.PLATINUM_MAT_3,RankMaterials.DIAMOND_MAT_1,RankMaterials.DIAMOND_MAT_2,RankMaterials.DIAMOND_MAT_3,RankMaterials.ELITE_MAT,RankMaterials.CHAMPION_MAT,RankMaterials.UNREAL_MATForBoard}

    #Logic if the player currently has a board showing
    var IsShowing : logic = false

    #Length until boards despawn
    var TimeUntilDespawn : float = 0.0

    #Event to reset the despawn timer
    ResetDespawnTimer : event() = event(){}
    


    #Function to Show that stat board to the player
    ShowStatBoard(Agent:agent) : void=
        if:
            FC := Agent.GetFortCharacter[]
            PlayerPos := FC.GetTransform().Translation
            PlayerRot := FC.GetTransform().Rotation
            RotTurn90 := PlayerRot.ApplyYaw(1.5708)
            PlayerForward := FC.GetViewRotation().GetLocalForward() * 300.0
            SpawnPos := PlayerPos + PlayerForward + vector3{Z:= 40.0}
        then:    
            UpdateBoard(Agent)
            if(PlayerStatBoard.BoardAnchorProp.TeleportTo[SpawnPos,RotTurn90]){}


    #function to despawn the board after a certain amount of time        
    DespawnTimer()<suspends> : void=
        set IsShowing = true
        var DespawnTime : float = TimeUntilDespawn
        race:
            block:
                loop:
                    ResetDespawnTimer.Await()
                    set DespawnTime = TimeUntilDespawn

            loop:
                Sleep(1.0)
                set DespawnTime -= 1.0
                if(DespawnTime <= 0.0):
                    set IsShowing = false
                    PlayerStatBoard.Reset()
                    break


    #Function to update all board information for the player
    UpdateBoard(Agent:agent) : void=
        if:
            #Gets all player info and billboards
            CP := RankSystem.PlayersRankMap[Agent]
            BoardEliminations := Int[CP.Eliminations]
            BoardDeaths := Int[CP.Deaths]
            BoardWins := Int[CP.Wins]
            BoardLoses := Int[CP.Loses]
            BoardMatches := BoardWins + BoardLoses
            BoardWinRate := TruncateFloatString(((BoardWins * 1.0) / (BoardMatches * 1.0)) * 100.0,2)
            BoardRating := Int[CP.RankValue]
            BoardPrestiges := Int[CP.Prestiges]
            BoardWinStreak := CP.WinStreak
            BoardKillStreak := CP.KillStreak
            BoardRankName := CP.AllRanks[CP.Rank].RankText
            BoardRankIcon := RankImageMats[CP.Rank]
            BoardKD := (CP.Eliminations * 1.0) / (CP.Deaths *1.0)
            BoardRoundedKD := TruncateFloatString(BoardKD, 2)

        then:

            #Assigns stat board texts
            for(BB : PlayerStatBoard.StatDisplays):
                case (BB.DisplaySetting):
                    Stats.Kills =>
                        BB.TextBillBoard.SetText(StringToMessage("Kills:"))
                        BB.NumberBillBoard.SetText(StringToMessage("{BoardEliminations}"))
                    Stats.Deaths =>
                        BB.TextBillBoard.SetText(StringToMessage("Deaths:"))
                        BB.NumberBillBoard.SetText(StringToMessage("{BoardDeaths}"))
                    Stats.KDRatio =>
                        BB.TextBillBoard.SetText(StringToMessage("K/D:"))
                        BB.NumberBillBoard.SetText(StringToMessage("{BoardRoundedKD}"))
                    Stats.Wins =>
                        BB.TextBillBoard.SetText(StringToMessage("Wins:"))
                        BB.NumberBillBoard.SetText(StringToMessage("{BoardWins}"))
                    Stats.Loses =>
                        BB.TextBillBoard.SetText(StringToMessage("Loses:"))
                        BB.NumberBillBoard.SetText(StringToMessage("{BoardLoses}"))
                    Stats.GamesPlayed =>
                        BB.TextBillBoard.SetText(StringToMessage("Matches:"))
                        BB.NumberBillBoard.SetText(StringToMessage("{BoardMatches}"))
                    Stats.WinRate =>
                        BB.TextBillBoard.SetText(StringToMessage("Win %:"))
                        BB.NumberBillBoard.SetText(StringToMessage("{BoardWinRate}%"))
                    Stats.Rating =>
                        BB.TextBillBoard.SetText(StringToMessage("Rating:"))
                        BB.NumberBillBoard.SetText(StringToMessage("{BoardRating}"))
                    Stats.WinStreak =>
                        BB.TextBillBoard.SetText(StringToMessage("Win Streak:"))
                        BB.NumberBillBoard.SetText(StringToMessage("{BoardWinStreak}"))
                    Stats.KillStreak =>
                        BB.TextBillBoard.SetText(StringToMessage("Kill Streak:"))
                        BB.NumberBillBoard.SetText(StringToMessage("{BoardKillStreak}"))
                    Stats.Prestiges =>
                        BB.TextBillBoard.SetText(StringToMessage("Prestiges:"))
                        BB.NumberBillBoard.SetText(StringToMessage("{BoardPrestiges}"))
                    _=>
                        Print("N/A Stat")

            #Sets all the of props and player references
            PlayerStatBoard.PlayerRef.Register(Agent)
            PlayerStatBoard.RankImageProp.SetMaterial(BoardRankIcon)
            PlayerStatBoard.NameDisplay.SetText(AgentToMessage(Agent))
            PlayerStatBoard.RankDisplay.SetText(StringToMessage(BoardRankName))


    #Functions to convert to messages
    AgentToMessage<localizes>(Agent : agent) : message = "{Agent}"
    StringToMessage<localizes>(String : string) : message = "{String}"
            

    #Function to round values
    TruncateFloatString(Input:float, Decimals:int)<transacts> : []char = {
        var String : []char = ToString(Input)
    
        if (DotIndex := String.Find['.']) {
            StopIndex := if (Decimals > 0) { Min(DotIndex+Decimals+1,String.Length) } else { DotIndex }
            if (FinalString := String.Slice[0, StopIndex]) {
                return FinalString
            }
        }
        return "0"
        }


#Main creative device class
Rank_Board_Manager := class(creative_device): 

    #Used to get player rank info
    @editable RankSystem : Rank_System = Rank_System{}

    #Remote manager to activate boards
    @editable RemoteMan : signal_remote_manager_device = signal_remote_manager_device{}

    #Amount of time until boards despawn after being placed
    @editable TimeUntilDespawn : float = 0.0

    #All stat boards
    var AllStatBoards : []FullBoard = array{}

    #Map of each player and their boards
    var PlayersRankBoardMap : [player]RankedPlayerWithStatBoard = map{}      


    OnBegin<override>()<suspends>:void=

        #Waits for remote to be pressed
        RemoteMan.PrimarySignalEvent.Subscribe(Open)
        GetPlayspace().PlayerRemovedEvent().Subscribe(ResetBoard)
    
    #Shows stat board
    Open(Agent:agent) : void=
        if(Player := player[Agent], FC:= Player.GetFortCharacter[]):

            #If that player already has a stat board, show it
            if(PlayerExists := PlayersRankBoardMap[Player] ):  
                PlayerExists.ShowStatBoard(Agent)
                if(PlayerExists.IsShowing?):
                    PlayerExists.ResetDespawnTimer.Signal()
                else:
                    spawn{PlayerExists.DespawnTimer()}

                
            #If player does not have a stat board:
            else:

                #Assigns an unused stat board
                var FoundBoard : logic = false
                for(Board : AllStatBoards, not FoundBoard?):
                    if(not Board.IsUsed?):
                        set FoundBoard = true
                        set Board.IsUsed = true
                        #Shows the stat board
                        if(set PlayersRankBoardMap[Player] = RankedPlayerWithStatBoard{PlayerStatBoard := Board, RankSystem := RankSystem,TimeUntilDespawn := TimeUntilDespawn }){}
                        if(PlayerExists := PlayersRankBoardMap[Player] ):  
                            PlayerExists.ShowStatBoard(Agent)
                            spawn{PlayerExists.DespawnTimer()}


                        


    #Function to reset the board whenever a player leaves
    ResetBoard(Agent:agent) : void=
        if(CP := PlayersRankBoardMap[Agent]):
            CP.PlayerStatBoard.Reset()