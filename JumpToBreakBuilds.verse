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

JumpToBreakBuilds := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}
    @editable JumpToBreakClassNumber : int = 100

    @editable JumpToBreakExplosive : explosive_device = explosive_device{}
    @editable JumpToBreakVFX : vfx_spawner_device = vfx_spawner_device{}
    @editable JumpToBreakSound : audio_player_device = audio_player_device{}
  
    OnBegin<override>()<suspends>:void=
        Sleep(3.0)
        for (Player : GetPlayspace().GetPlayers()):
            if(FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = JumpToBreakClassNumber):
                    spawn:
                        JumpToBreakBuildsPlayer(Agent)
    JumpToBreakBuildsPlayer(Agent:agent) <suspends>: void=
        if(Player := player[Agent] , FC:= Player.GetFortCharacter[]):
            FC.JumpedEvent().Subscribe(OnJump)
    OnJump(FC : fort_character) : void=
        if(Agent := FC.GetAgent[]):
            PlayerPos := FC.GetTransform().Translation
            if(JumpToBreakExplosive.TeleportTo[PlayerPos,IdentityRotation()]){}
            if(JumpToBreakVFX.TeleportTo[PlayerPos,IdentityRotation()]){}
            JumpToBreakVFX.Enable()
            JumpToBreakSound.Play(Agent)
            JumpToBreakExplosive.Explode(Agent)

            
            spawn:
                ResetExplosive()
    ResetExplosive()<suspends> : void=
        Sleep(0.2)
        JumpToBreakExplosive.Reset()
        JumpToBreakVFX.Disable()

            