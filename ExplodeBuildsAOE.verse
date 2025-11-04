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
using { /Verse.org/Random }

ExplodeBuildsAOE := class(creative_device):
    @editable ExplodeAOEDevice : explosive_device = explosive_device{}
    @editable ExplodeAOESound : audio_player_device = audio_player_device{}
    @editable ExplodeAOEVFX : vfx_spawner_device = vfx_spawner_device{}



    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable ExplodeAOETimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}


    OnBegin<override>()<suspends>:void=
        ExplodeAOETimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        ExplodeAOETimer.SuccessEvent.Subscribe(ResetCooldown)
    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false
    AOEExplosion(Agent:agent)<suspends> : void=
        if(MaybeCooldown = false):
            ExplodeAOETimer.Start(Agent)
            set MaybeCooldown=true
            if (Player:=player[Agent],Target := Player.GetFortCharacter[]):
                if(ExplodeAOEDevice.TeleportTo[Target.GetTransform().Translation, ExplodeAOEDevice.GetTransform().Rotation]){}
                if(ExplodeAOEVFX.TeleportTo[Target.GetTransform().Translation, ExplodeAOEDevice.GetTransform().Rotation]){}
                ExplodeAOEVFX.Enable()
                ExplodeAOEDevice.Explode(Agent)
                ExplodeAOESound.Play(Agent)
                Sleep(0.1)
                ExplodeAOEVFX.Disable()
                if(ExplodeAOEDevice.TeleportTo[vector3{X:=1000.0,Y:=1000.0,Z:=1000.0},ExplodeAOEDevice.GetTransform().Rotation]){}
                ExplodeAOEDevice.Reset()
        else:
            CooldownMSG.Show(Agent)




    