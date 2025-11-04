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

DamageChange := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}
    @editable DamageClassNumber : int = 100
    @editable DamageAMP : damage_amplifier_powerup_device = damage_amplifier_powerup_device{}
    @editable IncreaseDMGBy : float = 0.0

    OnBegin<override>()<suspends>:void=
        Sleep(3.0)
        for (Player : GetPlayspace().GetPlayers()):
            if(FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = DamageClassNumber):
                    spawn:
                        DMGPlayer(Agent)
    DMGPlayer(Agent:agent)<suspends> : void=
        DamageAMP.SetMagnitude(IncreaseDMGBy)
        DamageAMP.Pickup(Agent)