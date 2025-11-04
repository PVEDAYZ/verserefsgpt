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

LifeSteal := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}
    @editable LifeStealClassNumber : int = 100

    @editable StealPercent : float = 0.0

    OnBegin<override>()<suspends>:void=
        for (Player : GetPlayspace().GetPlayers(), FortCharacter := Player.GetFortCharacter[]):
            FortCharacter.DamagedEvent().Subscribe(HealAttacker)
            FortCharacter.DamagedShieldEvent().Subscribe(HealAttacker)
  


    HealAttacker( Result : damage_result) : void =
        Amount := Result.Amount
        if (Instigator := Result.Instigator?, Agent := Instigator.GetInstigatorAgent[], FortCharacter := Agent.GetFortCharacter[]):
            if(Target:= fort_character[Result.Target]):
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = LifeStealClassNumber):
                    if(Target = FortCharacter):   
                        block:
                    else:
                        HealAmount := Amount * StealPercent
                        SheildAmount := FortCharacter.GetShield()
                        HealthAmount := FortCharacter.GetHealth()
                        if(SheildAmount > 0.0):
                            FortCharacter.SetShield(SheildAmount + HealAmount)
                        else if(SheildAmount = 0.0 and HealthAmount < 100.0):
                            FortCharacter.Heal(HealAmount)
                        else:
                            FortCharacter.SetShield(SheildAmount + HealAmount)


  



                
    