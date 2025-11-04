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

ExplodeAllBuilds := class(creative_device):
    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable ExplodeAllBuildsTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}

    @editable ExplodeAllBuildsExplosive : explosive_device = explosive_device{}
    @editable ExplodeAllBuildsSound : audio_player_device = audio_player_device{}
    @editable ExplodeAllBuildsVFXs : []vfx_spawner_device = array{}

 


    OnBegin<override>()<suspends>:void=
        ExplodeAllBuildsTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        ExplodeAllBuildsTimer.SuccessEvent.Subscribe(ResetCooldown)
    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false
    ExplodeAllBuildsAbility(Agent:agent)<suspends> : void=
        if(MaybeCooldown = false):
            ExplodeAllBuildsTimer.Start(Agent)
            set MaybeCooldown=true
            AllPlayers := GetPlayspace().GetPlayers()
            for(VFX : ExplodeAllBuildsVFXs):
                VFX.Enable()
            for(Player : AllPlayers):
                if(FC := Player.GetFortCharacter[],NewAgent := FC.GetAgent[]):
                    ExplodeAllBuildsSound.Play(NewAgent)
            ExplodeAllBuildsExplosive.Explode(Agent)
            Sleep(0.2)
            ExplodeAllBuildsExplosive.Reset()
            for(VFX : ExplodeAllBuildsVFXs):
                VFX.Disable()
        else:
            CooldownMSG.Show(Agent)