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

#THIS DEVICE WILL ACT AS A STATISTIC BOARD A PLAYER CAN SUMMON

#Enum to allow different stats to show
Stats := enum:
    None
    Kills
    Deaths
    KDRatio
    Wins
    Loses
    GamesPlayed
    WinRate
    Rating
    WinStreak
    KillStreak
    Prestiges


StatBoard := class<concrete>():
    @editable TextBillBoard : billboard_device = billboard_device{}          
    @editable NumberBillBoard : billboard_device = billboard_device{}                       
    @editable DisplaySetting : Stats = Stats.None

FullBoard := class<concrete>():

    #Used to determine of the board is used
    var IsUsed : logic = false

    #Devices needed for board
    @editable BoardAnchorProp : creative_prop = creative_prop{}                         #Anchors all props together to teleport
    @editable PlayerRef : player_reference_device = player_reference_device{}           #Used to display player skin
    @editable RankImageProp : creative_prop = creative_prop{}                           #Used to display current rank image
    @editable StatDisplays : []StatBoard = array{}                               #Array of billboards for current stats
    @editable NameDisplay : billboard_device = billboard_device{}                       #Billboard to display player name
    @editable RankDisplay : billboard_device = billboard_device{}                       #Billboard to display rank name


    #Function used to reset the stat board
    Reset() : void=
        if(BoardAnchorProp.TeleportTo[vector3{X:= 100000.0,Y:=100000.0,Z:=-100000.0},IdentityRotation()]):
            set IsUsed = false
    
Rank_Board := class(creative_device):
    @editable RankBoardManager : Rank_Board_Manager = Rank_Board_Manager{}
    @editable Board : FullBoard = FullBoard{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        Sleep(1.0)
        set RankBoardManager.AllStatBoards += array{Board}