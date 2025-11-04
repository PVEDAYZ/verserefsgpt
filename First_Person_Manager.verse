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
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /Verse.org/Colors/NamedColors }

#THIS DEVICE MANAGES FIRST PERSON FOR ALL PLAYERS

First_Person_Manager := class(creative_device):

    @editable StartManager : Start_Manager = Start_Manager{}                #Device to manage players

    @editable FirstPersonCam : gameplay_camera_orbit_device = gameplay_camera_orbit_device{} #First Person Cam

    @editable CrouchFirstPersonCam : gameplay_camera_orbit_device = gameplay_camera_orbit_device{} #First Person Cam

    @editable InputDevice : input_trigger_device = input_trigger_device{}   #Input device to track when a player is ADS

    @editable ScopeGuns : []conditional_button_device = array{}             #Array of conditionals to determine what gun the player is holding (Should contain all scopeable guns)


    OnBegin<override>()<suspends>:void=
        StartManager.FirstPersonEnableEvent.Await()                  #Waits to enable first person
        for(Player:GetPlayspace().GetPlayers()):                    #Starts cam for all players
            StartFirstPerson(Player)

        InputDevice.PressedEvent.Subscribe(Pressed)                 #Triggers when player is ADS
        InputDevice.ReleasedEvent.Subscribe(Released)               #Triggers when player releases ADS


    StartFirstPerson(Player : player) : void=
        InputDevice.Enable()                                        #Enables the input device
        InputDevice.Register(Player)                                #Tracks player with input device
        if(FC:= Player.GetFortCharacter[],Agent := FC.GetAgent[]):
            FirstPersonCam.AddTo(Agent)                 #Enables first person cam
            spawn:
                CrouchCheck(Player , FC)                            #Checks for when a player is crouching

    Pressed(Agent:agent) : void=                                    #If a player is ADS with a scoped gun, disables first person
        for(S : ScopeGuns):
            if(S.IsHoldingItem[Agent]):
                FirstPersonCam.RemoveFrom(Agent)

    Released(Agent:agent, MaybeTime : float) : void=                #If a player releases ADS with a scoped gun, enables first person
        for(S : ScopeGuns):
            if(S.IsHoldingItem[Agent]):
                FirstPersonCam.AddTo(Agent)



    CrouchCheck(Player : player,FC : fort_character)<suspends>: void=   
        loop:
            FC.CrouchedEvent().Await()                  #Waits for a player to crouch
            CrouchFirstPersonCam.AddTo(Player)             #Adds crouch cam
            FC.CrouchedEvent().Await()                  #Waits for a player to uncrouch
            CrouchFirstPersonCam.RemoveFrom(Player)            #Removes crouch cam