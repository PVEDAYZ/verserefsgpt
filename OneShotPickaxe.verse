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
using { /Fortnite.com/Game }

OneShotPickaxe := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}
    @editable OneShotClassNumber : int = 100

    @editable OneShotConditionals : []conditional_button_device = array{}
    @editable OneShotSound : audio_player_device = audio_player_device{}
    var IsHoldingAnItem : logic = false

    OnBegin<override>()<suspends>:void=
        for (Player : GetPlayspace().GetPlayers(), FortCharacter := Player.GetFortCharacter[]):
            FortCharacter.DamagedEvent().Subscribe(OnPlayerDamaged)
            FortCharacter.DamagedShieldEvent().Subscribe(OnPlayerDamaged)
    OnPlayerDamaged(DamageResult: damage_result): void = 
        if: 
            Instigator := DamageResult.Instigator?
            Agent := Instigator.GetInstigatorAgent[]
            Target:= fort_character[DamageResult.Target]
        then:
            if(InstiPlayer := player[Agent] ,  InstiFC := InstiPlayer.GetFortCharacter[]):
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = OneShotClassNumber):
                    if(not Target = InstiFC):
                        set IsHoldingAnItem = false
                        for(Conditional : OneShotConditionals):
                            if(Conditional.IsHoldingItem[Agent]):
                                set IsHoldingAnItem = true
                        if(IsHoldingAnItem = false):
                            spawn:
                                OneShotPlayer(Target,Agent)

    OneShotPlayer(Target : fort_character,Agent:agent)<suspends> : void=
        OneShotSound.Play(Agent)
        Target.Damage(1000.0)
