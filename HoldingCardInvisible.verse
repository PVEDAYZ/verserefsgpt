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

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
HoldingCardInvisible := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}
    @editable HoldingCardClassNumber : int = 100
    @editable HoldingCardConditional : conditional_button_device = conditional_button_device{}
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        spawn:
            InvisibilityPlayer()
    InvisibilityPlayer()<suspends> : void =
        loop:
            for (Player : GetPlayspace().GetPlayers()):
                if(FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
                    if( GameStartDevice.EachPlayerMap[Agent].ClassNum = HoldingCardClassNumber):
                        if(HoldingCardConditional.IsHoldingItem[Agent]):
                            FC.Hide()
                        else:
                            FC.Show()
                        Sleep(0.1)
            Sleep(0.1)


    
            


    