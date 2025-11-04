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
using { /Fortnite.com/Characters}
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }

PushOrPullGun := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}
    @editable PushOrPullGunClassNumber : int = 100
    @editable ClassRequirement : int = 0
    #0 : no class requirement
    #1 : class requirement


    @editable PushOrPullGunConditional : conditional_button_device = conditional_button_device{}
    @editable PushOrPullGunDevice : movement_modulator_device = movement_modulator_device{}
    @editable PushOrPullGunSound : audio_player_device = audio_player_device{}
    @editable PushOrPullOption : int = 0
    #if 1 Push
    #if 2 Pull

    
    OnBegin<override>()<suspends>:void=
        for (Player : GetPlayspace().GetPlayers(), FortCharacter := Player.GetFortCharacter[]):
            FortCharacter.DamagedEvent().Subscribe(OnPlayerDamaged)
            FortCharacter.DamagedShieldEvent().Subscribe(OnPlayerDamaged)
    OnPlayerDamaged(DamageResult: damage_result): void = 
        if: 
            Instigator := DamageResult.Instigator?
            Agent := Instigator.GetInstigatorAgent[]
            PushOrPullGunConditional.IsHoldingItem[Agent]
            Target:= fort_character[DamageResult.Target]
        then:
            if(ClassRequirement = 0):
                spawn:
                    PushOrPullGunPlayer(Target,Agent)
            else if(ClassRequirement = 1):
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = PushOrPullGunClassNumber):
                    spawn:
                        PushOrPullGunPlayer(Target,Agent)
                else:

    PushOrPullGunPlayer(Target : fort_character,Agent:agent)<suspends> : void=
        if(Player := player[Agent],FC:= Player.GetFortCharacter[], TargetAgent := Target.GetAgent[]):
            if(Target = FC):   
                block:
            else:
                FCRotation := FC.GetTransform().Rotation
                DeviceLocation := PushOrPullGunDevice.GetTransform().Translation
                if(PushOrPullOption = 1):
                    if(PushOrPullGunDevice.TeleportTo[DeviceLocation,FCRotation]){}
                        PushOrPullGunSound.Play(TargetAgent)
                        PushOrPullGunDevice.Activate(TargetAgent)
                else if(PushOrPullOption = 2):
                    NEWRotation := FCRotation.ApplyYaw(3.14)
                    if(PushOrPullGunDevice.TeleportTo[DeviceLocation,NEWRotation]){}
                        PushOrPullGunSound.Play(TargetAgent)
                        PushOrPullGunDevice.Activate(TargetAgent)