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


TurnInvincible := class(creative_device):
    @editable InvincibityVFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable InvincibilitySound : audio_player_device = audio_player_device{}
    @editable InvincibilityTime : float = 0.0


    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable InvincibilityTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}
    # Make sure both VFX and Invincibility time are the same
    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers(),FC:=Player.GetFortCharacter[]):
            FC.SetVulnerability(true)


        InvincibilityTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        InvincibilityTimer.SuccessEvent.Subscribe(ResetCooldown)
    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false
    
    Invincibity(Agent:agent)<suspends> : void=
        if(MaybeCooldown = false):
            InvincibilityTimer.Start(Agent)
            set MaybeCooldown=true

            if(Player:=player[Agent], FC:=Player.GetFortCharacter[]):
                InvincibilitySound.Play(Agent)
                InvincibityVFX.Pickup(Agent)
                FC.SetVulnerability(false)
                Sleep(InvincibilityTime)
                FC.SetVulnerability(true)
        else:
            CooldownMSG.Show(Agent)
        
    