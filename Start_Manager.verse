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
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /Verse.org/Colors/NamedColors }

CustomPlayer := class<unique>():
    Player : player
    var IsMusicPlaying : logic = false
    var OwnedPerks : []int = array{}
    var OwnedPerkWidgets : []canvas = array{}

        
Start_Manager := class(creative_device):

    @editable DayManager : Day_Manager = Day_Manager{}                                      #Manages Zombies

    @editable PreGameProp : creative_prop = creative_prop{}                                 #Props that show before the game is started (Ex. Rules/Directions as well as #ads)

    @editable PlayerSpawners : []player_spawner_device = array{}                            #All player spawners

    @editable StartSequence : cinematic_sequence_device = cinematic_sequence_device{}       #Cinematic to play at the start of the game

    @editable HudBegin : hud_message_device = hud_message_device{}                          #HUD message that shows to plays at the end of the cinematic

    @editable DisableMatchmakingDevice : round_settings_device = round_settings_device{}    #Device to disable matchmaking after the game has started

    @editable ItemGiver : item_granter_device = item_granter_device{}                       #Grants players an item at the start of the game



    #Music Stuff
    @editable MusicButton : button_device = button_device{}
    @editable MusicDevice : audio_player_device = audio_player_device{}

   
    FirstPersonEnableEvent<public> : event() = event(){}                                   #Event to enable first person
   

    var MaybeMyUIPerPlayer : [player]?canvas = map{}
    var MyUIPerPlayer : [player]canvas = map{}


    # MapCode : texture = #Put Map Code Image Here                                                        #Map Code Image
  

    
    var PlayersMap : [player]CustomPlayer = map{}                                           #Map of all players
   

    OnBegin<override>()<suspends>:void=
        PreGameProp.Hide()                    #Hides pregame prop
        spawn:
            StartStuff()
        DisableMatchmakingDevice.DisableMatchmaking()   #Disables Matchmaking
        MusicButton.InteractedWithEvent.Subscribe(ToggleMusic)

    ToggleMusic(Agent:agent):void=              #Toggles music for player
        if(CP := PlayersMap[Agent]):
            if(CP.IsMusicPlaying?):
                MusicDevice.Stop(Agent)
                set CP.IsMusicPlaying = false
            else:
                MusicDevice.Play(Agent)
                set CP.IsMusicPlaying = true


    StartStuff()<suspends> : void=
        StartSequence.SetPlaybackFrame(0)           #Resets cinematic
        Sleep(1.0)
        for(Player:GetPlayspace().GetPlayers(),FC:=Player.GetFortCharacter[]):      #Hides, freezes, and plays cinematic for all players
            FC.Hide()
            FC.PutInStasis(stasis_args{})
            StartSequence.Play(Player)

        StartSequence.StoppedEvent.Await()          #Waits for cinematic to stop

        for(Player:GetPlayspace().GetPlayers(),FC:=Player.GetFortCharacter[]):      #Shows, unfreezes, plays music, and initializes all players
            FC.Show()
            FC.ReleaseFromStasis()
            HudBegin.Show(Player)
            InitializePlayer(Player)
            MusicDevice.Play(Player)
            DayManager.EnableFirstSpawners()                    #Enables the first creature spawners

        FirstPersonEnableEvent.Signal()     #Starts first person for players



    InitializePlayer(Agent:agent) : void=               #Initializes the player
        ItemGiver.GrantItem(Agent)                      #Grants starting weapon
        AssignHUDS(Agent)                               #Assigns the code HUD
        if(Player := player[Agent]):
            if(PlayerExists := PlayersMap[Player]):
            else:
                if(set PlayersMap[Player] = CustomPlayer{Player := Player}){}



    AssignHUDS(Agent:agent) : void=
        if(SpawnedPlayer := player[Agent], PlayerUI := GetPlayerUI[SpawnedPlayer]):     
            # NewUI := CreateMyUI(MapCode)                                                #Creates Code Widget
            # PlayerUI.AddWidget(NewUI)                                                   #Adds the widget to UI
            # if (set MaybeMyUIPerPlayer[SpawnedPlayer]= option{NewUI}) {}


    CreateMyUI(DisplayTexture : texture) : canvas=                                                  
        MyCanvas: canvas = canvas:
            Slots := array:
                canvas_slot:            #Code Image Slot
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.0}, Maximum := vector2{X := 0.5, Y := 0.0}}
                    Offsets := margin{Top := -100.0, Left := 0.0, Right := 550.0, Bottom := 300.0}
                    Alignment := vector2{X := 0.5, Y := 0.0}
                    SizeToContent := false
                    Widget := texture_block{DefaultImage := DisplayTexture}
