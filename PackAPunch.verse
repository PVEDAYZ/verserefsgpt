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

#THIS DEVICE WORKS AS A PACK-A-PUNCH MACHINE TO UPGRADE WEAPONS

Weapon:= class<concrete>():     #Class for each weapon in mystery box

    @editable Granter : item_granter_device = item_granter_device{}                     #Grants upgraded item

    @editable Remover : item_remover_device = item_remover_device{}                     #Removes item that gets upgraded

    @editable Conditional : conditional_button_device = conditional_button_device{}     #Checks for item that is being held


    Check(Agent:agent) : logic=                         #method to check which item player is holding
        if(Conditional.IsHoldingItem[Agent]):   #If player is holding item
            Remover.Remove(Agent)   #Remove the item
            spawn:
                GiveItem(Agent)     #Give them the upgraded item
            return true     #Returns true if holding item
        else:
            return false    #Returns false if not holding item
    


    GiveItem(Agent:agent)<suspends> : void=    #method to give upgraded item to player
        Sleep(4.0)                  #Waits 4 seconds
        Granter.GrantItem(Agent)    #Grants the item




packapunch := class(creative_device):   

    @editable Button : button_device = button_device{}                                                  #Button to activate device

    @editable MoneyConditional : conditional_button_device = conditional_button_device{}                #Checks if player has enough gold

    @editable MoneyRemover: item_remover_device = item_remover_device{}                                 #Removes gold

    @editable NoMoneyHud : hud_message_device = hud_message_device{}                                    #HUD msg to show if player does not have enough gold

    @editable NotRightItem : hud_message_device = hud_message_device{}                                  #HUD msg to show if player is not holding an eligible item

    @editable Weapons : []Weapon = array{}                                                              #Array of weapons that are upgradeable

    @editable Sound : audio_player_device = audio_player_device{}                                       #Sound to play when activated

    @editable PackApunchXP : accolades_device = accolades_device{}                                      #XP to grant when activated

    var MaybeCount : int = 0
    OnBegin<override>()<suspends>:void=
        Button.InteractedWithEvent.Subscribe(OnInteract)    #Activates when button is pressed


    OnInteract(Agent:agent) : void=        
        if(MoneyConditional.HasAllItems[Agent]):     #if player has enough gold:
            PackApunchXP.Award(Agent)           #gives xp to player
            spawn:
                ItemCheck(Agent)                #checks the item the player is holding
        else:
            NoMoneyHud.Show(Agent)              #shows fail hud if not enough gold/items


    ItemCheck(Agent:agent) <suspends> : void=
        set MaybeCount = 0
        for(weapon : Weapons):             #checks to see if the weapon the player is holding is in the possible list of upgradeable weapons
            IsPlayerHolding := weapon.Check(Agent)
            if(IsPlayerHolding = true):       #if player is holding an upgradeable weapon:
                Sound.Play(Agent)                   #Plays sound
                MoneyRemover.Remove(Agent)          #Removes gold
                Button.Disable()                    #temporarily disables button
                spawn:
                    TurnButtonBackOn()              #Starts timer to turn button back on after 5 seconds
            else:
                set MaybeCount+=1

        if(MaybeCount = Weapons.Length):        #If a weapon was not upgraded:    
            NotRightItem.Show(Agent)            #Shows fail message
        else:


    TurnButtonBackOn()<suspends> : void=        #Turns on button again after 5 seconds
        Sleep(5.0)
        Button.Enable()



            
        
