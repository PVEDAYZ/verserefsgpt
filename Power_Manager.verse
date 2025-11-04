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

#THIS DEVICE MANAGES POWER GENERATOR

Power_Manager := class(creative_device):

    #generator stuff
    @editable GenButton : button_device = button_device{}                                   #Button to turn on generator

    @editable GenConditional : conditional_button_device = conditional_button_device{}      #Conditional to check for gold
    
    @editable GenAudio : audio_player_device = audio_player_device{}                        #Audio to play when generator is turned on

    @editable GenRemover : item_remover_device = item_remover_device{}                      #Remover to remove gold


    #keycard stuff
    @editable KeyButton : button_device = button_device{}                                   #Button to collect keycard

    @editable KeyGiver : item_granter_device = item_granter_device{}                        #Granter to give player card

    @editable KeyHud : hud_message_device = hud_message_device{}                            #HUD message to display when a player collects card


    #lock stuff
    @editable LockConditional : conditional_button_device = conditional_button_device{}     #Conditional to check for key and used to activate

    @editable Lock : lock_device = lock_device{}                                            #Lock to unlock/open door

    @editable DoorOpenSound : audio_player_device = audio_player_device{}                   #Sound to play when door is unlocked


    #base stuff
    @editable MoneyFailureMsg : hud_message_device = hud_message_device{}                   #HUD message to show when player doesnt have enough gold

    @editable PowerEnabledMsg : hud_message_device = hud_message_device{}                   #HUD message to show when power is turned on

    @editable KeyFailureMsg : hud_message_device = hud_message_device{}                     #HUD message to show when a play doesnt have key

    @editable Lights : []customizable_light_device = array{}                                #Lights to enable when power is turned on

    var Power : logic = false                                                               #Logic that enables when power is enabled


    OnBegin<override>()<suspends>:void=
        for (Light : Lights):               #turns off all lights
            Light.TurnOff()

        GenButton.InteractedWithEvent.Subscribe(OnInteract)         #Activates on Generator Button
        KeyButton.InteractedWithEvent.Subscribe(OnInteractKey)      #Activates on Key Button
        LockConditional.ActivatedEvent.Subscribe(LockActivate)      #Activates on Lock Button


    LockActivate(Agent:agent): void=       
        LockConditional.Disable()   #Disables conditional
        Lock.Open(Agent)            #Opens door
        DoorOpenSound.Play(Agent)   #Plays door open sound

    OnInteractKey(Agent:agent) : void=      
        KeyGiver.GrantItem(Agent)       #Gives player Key
        KeyHud.Show(Agent)              #Shows gather key hud message

    OnInteract(Agent:agent): void=          
        if(GenConditional.HasAllItems[Agent]):      #If player has enough gold:
            GenAudio.Play()                             #Plays generator sound
            set Power = true                            #Sets power to true
            GenRemover.Remove(Agent)                    #Removes gold
            GenButton.Disable()                         #Disables generator button
            PowerEnabledMsg.Show(Agent)                 #Shows generator enabled HUD message
            for (Light : Lights):                       #Turns on lights
                Light.TurnOn()
        else:
            MoneyFailureMsg.Show(Agent)             #Shows if player doesnt have enough gold