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
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }

#THIS DEVICE ACTS AS A PERK MANAGER TO MANAGER DIFFERENT PLAYERS PERKS


Perk := class<concrete>():                                                                             #Custom class for a perk

    var PerkImage : texture = MoneyUINew

    var PowerManager : Power_Manager = Power_Manager{}                                                  #Manages power

    var StartManager : Start_Manager = Start_Manager{}                                                  #Manages player stats/perks

    var FailureMsgPower : hud_message_device = hud_message_device{}                               #HUD Message device to display if power is off

    var FailureMsgMoney : hud_message_device = hud_message_device{}                               #HUD message device to display if not enough gold

    var FailureMsgAlreadyHave : hud_message_device = hud_message_device{}                               #HUD message device to display if player already has perk

    var PowerupXP : accolades_device = accolades_device{}                                               #XP to grant player when purchasing perk

    var AmountToSpace : float = 0.0                                                                     #Amount to space the perk UI images by

    @editable Button : button_device = button_device{}                                                  #Button to purchase perk

    @editable Conditional : conditional_button_device = conditional_button_device{}                     #Checks to see if play has gold

    @editable Remover : item_remover_device = item_remover_device{}                                     #Remover to remove gold

    @editable ClassSelector : class_and_team_selector_device = class_and_team_selector_device{}         #Class to switch player to   

    @editable BothClassSelector  : class_and_team_selector_device = class_and_team_selector_device{}    #Used if you have more than one class change (Ex. Increased health and Instant Reload)

    @editable SpeedBoost : movement_modulator_device = movement_modulator_device{}                      #Device to increase speed of player if the perk uses it

    @editable DamageBoost : damage_amplifier_powerup_device = damage_amplifier_powerup_device{}         #Device to increase damage of player if perk uses it

    var PerkNum : int = 0

    BuyPerk(Agent:agent) : void=
        if(PowerManager.Power?):                                #If power is on
            if(Conditional.HasAllItems[Agent]):                 #If player has gold
                if(CP := StartManager.PlayersMap[Agent]):
                    if(not CP.OwnedPerks.Find[PerkNum]):            #If perk is owned
                        GiveAbility(Agent)                      #Gives abilities to player
                        AddToUI(Agent)                          #Adds perks to player UI
                        Remover.Remove(Agent)                   #Removes Gold
                        set CP.OwnedPerks += array{PerkNum}     #Adds perk to player manager
                    else:
                        FailureMsgAlreadyHave.Show(Agent)       #Shows if player already has perk
            else:
                FailureMsgMoney.Show(Agent)                     #Shows if player doesnt have enough gold
        else:
            FailureMsgPower.Show(Agent)                         #Shows if power isnt on
 

    AddToUI(Agent:agent) : void=
        if(SpawnedPlayer := player[Agent], CP:= StartManager.PlayersMap[Agent] , PlayerUI := GetPlayerUI[SpawnedPlayer]):
            SpaceAmount := 250.0 + (CP.OwnedPerks.Length * AmountToSpace)       #Creates the amount to space from beginning location by multiplying how many perks the player has by the amount to space
            NewUI := CreatePerkUI(PerkImage,SpaceAmount)
            PlayerUI.AddWidget(NewUI)
            set CP.OwnedPerkWidgets += array{NewUI}


    CreatePerkUI(DisplayTexture : texture , SpaceAmount : float) : canvas=      #Creates the perk widget
        NewCanvas: canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 1.0}, Maximum := vector2{X := 0.0, Y := 1.0}}
                    Offsets := margin{Top := -100.0, Left := (SpaceAmount), Right := 200.0, Bottom := 200.0}
                    Alignment := vector2{X := 0.5, Y := 1.0}
                    SizeToContent := false
                    Widget := texture_block{DefaultImage := DisplayTexture}


    GiveAbility(Agent:agent) : void=
        SpeedBoost.Activate(Agent)
        DamageBoost.Pickup(Agent)

        #UNCOMMIT THE CODE BELOW FOR CLASS CHANGE PERKS

        # if(CP := StartManager.PlayersMap[Agent]):
        #     if(CP.OwnedPerks.Find[#Put number for class with class selector change(This will be the same at the element index)] or CP.OwnedPerks.Find[#Put the number for the other class with class selector change(This will be the same as the element index)]):
        #         BothClassSelector.ChangeClass(Agent)
        #     else:
        #         ClassSelector.ChangeClass(Agent)
      
        
Perk_Manager := class(creative_device): 

    @editable FailureMsgPower : hud_message_device = hud_message_device{}                               #HUD Message device to display if power is off

    @editable FailureMsgMoney : hud_message_device = hud_message_device{}                               #HUD message device to display if not enough gold

    @editable FailureMsgAlreadyHave : hud_message_device = hud_message_device{}                         #HUD message device to display if player already has perk

    @editable PowerManager : Power_Manager = Power_Manager{}                                            #Manages power

    @editable StartManager : Start_Manager = Start_Manager{}                                            #Manages player stats/perks

    @editable PowerupXP : accolades_device = accolades_device{}                                         #XP device to award players when buying perk

    @editable BaseClassSelector : class_and_team_selector_device = class_and_team_selector_device{}     #Class selector to switch players to after they die to reset perks

    @editable AllPerks : []Perk = array{}                                                               #Array of perks

    @editable AmountToSpace : float = 0.0                                                               #Amount to space the perk UI images by



    PerkImages : []texture = array{}            #ui images for each powerup(ORDER MATTERS, make sure each texture element in this array is equal to the perk element in the AllPerks array)



    OnBegin<override>()<suspends>:void=
        Sleep(1.0)
        for(idx -> P:AllPerks):                    #Sets up perks
            set P.PowerManager = PowerManager
            set P.StartManager = StartManager
            set P.FailureMsgPower = FailureMsgPower
            set P.FailureMsgMoney = FailureMsgMoney
            set P.FailureMsgAlreadyHave = FailureMsgAlreadyHave
            set P.PowerupXP = PowerupXP
            set P.AmountToSpace = AmountToSpace
            set P.PerkNum = idx
            if(PImage := PerkImages[idx]):
                set P.PerkImage = PImage
            P.Button.InteractedWithEvent.Subscribe(P.BuyPerk)

        for(Player : GetPlayspace().GetPlayers(),FC:=Player.GetFortCharacter[]):        #When a player is eliminated
            FC.EliminatedEvent().Subscribe(ResetPerks)

    ResetPerks(Result : elimination_result) : void=
        ElimPlayer := Result.EliminatedCharacter
        if(Agent := ElimPlayer.GetAgent[],Player:= player[Agent],CP := StartManager.PlayersMap[Agent], PlayerUI := GetPlayerUI[Player]):
            set CP.OwnedPerks = array{}                     #Reset perks
            BaseClassSelector.ChangeClass(Agent)            #Remove any powerups
            for(W: CP.OwnedPerkWidgets):                    #Remove perk widgets
                PlayerUI.RemoveWidget(W)
            set CP.OwnedPerkWidgets = array{}               #Reset perk widgets
            