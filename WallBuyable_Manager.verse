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

#THIS DEVICE MANAGES BUYABLE WALLS & AMMO 

WallBuyable := class<concrete>():            #class of wall buyables

    @editable Button: button_device = button_device{}                                   #button device used to buy weapon

    @editable Conditional: conditional_button_device = conditional_button_device{}      #conditional device that checks for gold

    @editable Remover : item_remover_device = item_remover_device{}                     #remover device that removes the gold

    @editable Granter : item_granter_device = item_granter_device{}                     #granter device that grants weapons/ammo

    var BuySound : audio_player_device = audio_player_device{}                          #sound that plays when bought

    var NotEnoughMoneyMsg : hud_message_device = hud_message_device{}                   #HUD msg that shows when buy fails


    BuyItem(Agent:agent) : void=            #method to buy an item
        if(Conditional.HasAllItems[Agent]):     #If the player has enough gold
            Remover.Remove(Agent)               #Removes the gold
            Granter.GrantItem(Agent)            #Grants the Item
            BuySound.Play(Agent)                #Plays buy sound
        else:
            NotEnoughMoneyMsg.Show(Agent)       #Shows fail msg if not enough gold

WallBuyable_Manager := class(creative_device): 
    @editable AllWallBuyables : []WallBuyable = array{}                                     #list of different wall buyables
    @editable NotEnoughMoneyMsg : hud_message_device = hud_message_device{}         #HUD failure message
    @editable BuySound : audio_player_device = audio_player_device{}                #Buy sound audio device

    OnBegin<override>()<suspends>:void=
        for(W : AllWallBuyables):                                       #Sets up all wallbuyables
            set W.BuySound = BuySound
            set W.NotEnoughMoneyMsg = NotEnoughMoneyMsg
            W.Button.InteractedWithEvent.Subscribe(W.BuyItem)           #Tries to buy item when pressed
    
                                