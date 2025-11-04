<#
====================================================================================================
THIS CODE IS MAPACADEMY PROPERTY. RESPECT THE RIGHTS OF THIS CODE.
SHARING THIS CODE COULD COME WITH A LEGAL CONSEQUENCES.                                                                                                 
CONTACT MAPPCO ON DISCORD
====================================================================================================
#>

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

#THIS DEVICE IS ACTS AS A MYSTERY BOX

MysteryBox := class(creative_device):

    @editable Button : button_device = button_device{}                                      #Button device for the mystery box

    @editable Conditional : conditional_button_device = conditional_button_device{}         #Conditional button to check if player has gold

    @editable ItemSpawn : item_spawner_device = item_spawner_device{}                       #Item spawner that filters all items in mystery box

    @editable ItemRemover : item_remover_device = item_remover_device{}                     #Item remover to remove gold

    @editable Closed : creative_prop = creative_prop{}                                      #Prop to show when the mystery box is closed

    @editable Open : creative_prop = creative_prop{}                                        #Prop to show when the mystery box is opening

    @editable FailureMsg : hud_message_device = hud_message_device{}                        #HUD message to display if player does not have enough gold

    @editable SoundEffect : audio_player_device = audio_player_device{}                     #Sound effect that plays when mystery box is opened                                                             

    @editable MysteryXP : accolades_device = accolades_device{}                             #XP awared to player for purchasing mystery box

    @editable SpinTime : float = 0.0

    @editable DespawnTime : float = 0.0                                                     #Amount of time until the item is despawned if not picked up

    OnBegin<override>()<suspends>:void=
        Open.Hide() #Hides the open prop
        Button.InteractedWithEvent.Subscribe(ActivateBox) #Activates when mystery box button is pressed
 

    ActivateBox(Agent:agent) : void=      #If player has required gold
        if:
            Conditional.HasAllItems[Agent]  #If player has required gold
        then:
            spawn:
                ActivateBoxReal(Agent)      #Open box
        else:
            FailureMsg.Show(Agent)          #If not enough gold show error message
             

    ActivateBoxReal(Agent:agent)<suspends> : void= 
        MysteryXP.Award(Agent)    #gives xp to player

        ItemSpawn.Enable()          #enables item spawner

        SoundEffect.Play()     #plays sound effect

        Closed.Hide()               #Hides the closed prop

        Open.Show()                 #Shows the open prop

        ItemRemover.Remove(Agent)    #removes gold

        Button.Disable()                #Disables button to stop spamming

        race:                    #shows random items in mystery box until timer is up
            block:
                Sleep(SpinTime)
                spawn:
                    DespawnTimer()                    #Starts timer for item to despawn
                return
            loop:                      
                ItemSpawn.SpawnItem()       #spawns item
                Sleep(0.2)
                ItemSpawn.CycleToNextItem()     #goes to next item

        
 

    DespawnTimer()<suspends> : void=   #weapon despawn timer
        Sleep(DespawnTime)              #Waits specified time
        ItemSpawn.Disable()             #Despawns item
        Open.Hide()                     #Hides open prop
        Closed.Show()                   #Shows closed prop
        Button.Enable()                 #Enabled the button for activating again