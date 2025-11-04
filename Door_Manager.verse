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

#THIS DEVICE MANAGES UNLOCKABLE DOORS

button:= class<concrete>():    #class of buyable doors

    var BuySound : audio_player_device = audio_player_device{}      #Sound that plays when door is bought

    var FailureMsg : hud_message_device = hud_message_device{}      #HUD message that plays if door buying fails

    @editable Conditional : conditional_button_device = conditional_button_device{}     #Conditional that checks for gold amount

    @editable ItemRemover : item_remover_device = item_remover_device{}                 #Remover that removes the gold

    @editable Button : button_device = button_device{}                                  #Actual button used to activate the door

    @editable ItemsToHide: []creative_prop = array{}                                    #Props that hide when the door is unlocked

    @editable ItemsToShow: []creative_prop = array{}                                    #Props that show when the door is unlocked

    @editable Barrier : barrier_device = barrier_device{}                               #Barrier that disables when door is unlocked

    @editable Cinematic : cinematic_sequence_device = cinematic_sequence_device{}       #Cinematic that plays when door is unlocked

    @editable SpecialIdentifier : int = 0                                               #Special identifier for unique events

    @editable RequiresPower : logic = false                                             #Wether or not this button requires power to function
    

   

    HasItems(Agent:agent) : void=  #method to unlock doors
        if:
            Conditional.HasAllItems[Agent]     #if player has gold amount
        then:                                   
            BuySound.Play(Agent)    #Buy sound plays
            Button.Disable()        #Door button disables
            ItemRemover.Remove(Agent)           #Gold is removed
            for(Item:ItemsToHide):              #Items are hidden
                Item.Hide()
            for(Item:ItemsToShow):              #items are showed
                Item.Show()
            Barrier.Disable()                   #Barrier gets disabled
            CheckSpecials(Agent)                #checks for any special events
    
    CheckSpecials(Agent:agent) : void=
        #If you want the door to do something special add it here: 
        #Ex:
        if(SpecialIdentifier = 1):
            #Do special task

Door_Manager := class(creative_device):
    @editable Doors : []button = array{}    #list of buyable doors
    @editable BuySound : audio_player_device = audio_player_device{}    #buy door sounds
    @editable FailureMsg : hud_message_device = hud_message_device{}    #HUD message that plays if door buying fails

    OnBegin<override>()<suspends>:void=
        Sleep(1.0)
        for(B : Doors):   #Setups all doors
            set B.BuySound = BuySound
            set B.FailureMsg = FailureMsg
            B.Button.InteractedWithEvent.Subscribe(B.HasItems)    #If button is pressed try to unlock door
