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
WallHacks := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}
    @editable WallHacksClassNumber : int = 100

    @editable WallHacksVFXs : []vfx_spawner_device = array{}
    var WallHackIDX : int = 0

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        Sleep(3.0)
        set WallHackIDX = 0
        for (Player : GetPlayspace().GetPlayers()):
            if(FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = WallHacksClassNumber):
                    spawn:
                        WallHackPlayer(Agent)
    WallHackPlayer(Agent:agent) <suspends> : void=
        if(MainPlayer := player[Agent], MainFC:= MainPlayer.GetFortCharacter[]):
            for (Player : GetPlayspace().GetPlayers()):
                if(FC := Player.GetFortCharacter[], NewAgent := FC.GetAgent[]):
                    if(FC = MainFC):
                    else:
                        if(CurrentVFX := WallHacksVFXs[WallHackIDX]):
                            spawn:
                                TrackPlayer(FC,CurrentVFX)
                            set WallHackIDX += 1


    TrackPlayer(FC:fort_character, VFX : vfx_spawner_device)<suspends>: void=
        VFX.Enable()
        loop:
            Sleep(0.0)
            if(VFX.TeleportTo[FC.GetTransform().Translation,IdentityRotation()]){}
    
