using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Assets }
using { /Fortnite.com/Playspaces }
using { /Verse.org/Random }



#Class that holds values for each player
Custom_Player := class(Base_Player): 
    #Base Stuff
    PersistanceManager : Tycoon_Persistence_Manager = Tycoon_Persistence_Manager{}
    var MyUI : canvas = canvas{}
    var CurrentExtraEvent : event() = event(){}
    var MusicPlaying : logic = true    
    var IsDancing : logic = false   
    var IsBoosted : logic = false
    var GameManager : Game_Manager = Game_Manager{}

    
    #Bought Items Saved For Persistence
    var BoughtDoors : []int = array {}
    var BoughtPets : []int = array {}
    var BoughtApparels : []int = array{}
    var BoughtColors : []int = array{}

    #Currently Equipped Buyables
    var EquippedColor : int = 999
    var EquippedPets : []int = array {}
    var EquippedApparels : []int = array{0,0,0}

    # Current Plot ID
    var CurrentPlotID : int = 0


    GameAgentToMessage<localizes>(Agent : agent) : message = "{Agent}"


    ResetAllStats(Agent : agent) : void =
        set BoughtDoors = array{}
        set BoughtPets = array {}
        set BoughtApparels = array{}
        set BoughtColors = array{}
        set EquippedColor = 999
        set EquippedPets = array {}
        set EquippedApparels = array{0,0,0}
        PersistanceManager.ResetPlayerArrStat(Agent, StatType.Doors)
        PersistanceManager.ResetPlayerArrStat(Agent, StatType.Pets)
        PersistanceManager.ResetPlayerArrStat(Agent, StatType.Apparels)
        PersistanceManager.ResetPlayerArrStat(Agent, StatType.Colors)
        PersistanceManager.ResetPlayerArrStat(Agent, StatType.EquippedPets)
        PersistanceManager.ResetPlayerArrStat(Agent, StatType.EquippedApparels)

               
#Main creative device
Game_Manager := class(creative_device): 
    var PlayersMap : [player]Custom_Player = map{}
    #Base Stuff
    PersistenceManager : Tycoon_Persistence_Manager = Tycoon_Persistence_Manager{}    
    TT_BaseClassSelector<localizes>:message = "Default class selector used to assign players to the default team\n*Required Settings*\n Team To Switch To : Team Index =  n+1 (where n is the total number of plots in your game)"
    @editable BaseClassSelector : class_and_team_selector_device = class_and_team_selector_device{}  
       
    #Music Stuff
    TT_ToggleMusicToggleMusicTrigger<localizes>:message = "Trigger used to toggle the music on and off for the player"
    @editable ToggleMusicTrigger : trigger_device = trigger_device{}

    TT_MusicPlayer<localizes>:message = "Audio player used to play music for the player\n*Required Settings*\nCan Be Heard By : Instigator Only\nPlay Location : Instigating Player"
    @editable MusicPlayer : audio_player_device = audio_player_device{}


    #Extra Settings
    TT_MatchmakingSettings<localizes>:message = "Controls what happens to match making when the game starts"
    @editable MatchmakingSettings : MatchmakingSetting = MatchmakingSetting{}




    #Initializes players and sets up other devices
    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers()){InitiatePlayer(Player)}
        GetPlayspace().PlayerAddedEvent().Subscribe(InitiatePlayer)
        GetPlayspace().PlayerRemovedEvent().Subscribe(RemoveFromPlayerMap)


        ToggleMusicTrigger.TriggeredEvent.Subscribe(ToggleMusic)    
        if(MatchmakingSettings.CloseMatchmakingAfterGameStart?){spawn{CloseMatchmaking()}}


    #Removes the player from the map whenever they leave the session
    RemoveFromPlayerMap(Agent:agent) : void=
        if(Player := player[Agent],Exists := PlayersMap[Player]):
            if(NewMap := PlayersMap.WithRemovedKey(Player)?):
                set PlayersMap = NewMap

    #Initializes the player into the playermap
    InitiatePlayer(Agent:agent): void=
        if(Player := player[Agent]):    
            BaseClassSelector.ChangeTeam(Agent)        
            MusicPlayer.Play(Agent)                     
            PersistenceManager.InitializePlayer(Player)

            if(PlayerExists := PlayersMap[Player]):     
            else:
                if(set PlayersMap[Player] = Custom_Player{       
                    Player := Player
                    GameManager := Self
                    }){}

                #Adds the UI
                if(CustomPlayer := PlayersMap[Player]):     
                    InitializeSavedData(Player)


    #Initializes any saved data if the player has it
    InitializeSavedData(Player : player) : void=
        if(CP := Custom_Player[PlayersMap[Player]] , PlayerStats := PersistenceManager.GetPlayerStats[Player]):
            set CP.BoughtDoors = PlayerStats.BoughtDoors
            set CP.BoughtPets = PlayerStats.BoughtPets
            set CP.BoughtApparels = PlayerStats.BoughtApparels
            set CP.BoughtColors = PlayerStats.BoughtColors
            set CP.EquippedApparels = PlayerStats.EquippedApparels
            set CP.EquippedPets = PlayerStats.EquippedPets
            set CP.CurrentPlotID = PlayerStats.PlotID

    #Function used to toggle music
    ToggleMusic(MAgent:?agent) : void=  
        if(Agent := MAgent? , CP := Custom_Player[PlayersMap[Agent]]):
            if(CP.MusicPlaying?):
                MusicPlayer.Stop(Agent)
                set CP.MusicPlaying = false
            else:
                MusicPlayer.Play(Agent)
                set CP.MusicPlaying = true

    #Closes matchmaking if enabled
    CloseMatchmaking()<suspends> : void=
        Sleep(MatchmakingSettings.Delay)
        MatchmakingSettings.RoundSettingsDevice.DisableMatchmaking()

    #Returns the current playspace
    ReturnPlayspace() : fort_playspace =
        GetPlayspace()



#Settings to control matchmaking
MatchmakingSetting:= class<concrete>():
    TT_CloseMatchmakingAfterGameStart<localizes>:message = "If enabled, matchmaking will be closed after the game starts"
    @editable CloseMatchmakingAfterGameStart : logic = false

    TT_RoundSettingsDevice<localizes>:message = "Round settings device used to control the round settings for the game"
    @editable RoundSettingsDevice : round_settings_device = round_settings_device{}

    TT_Delay<localizes>:message = "How long to wait before matchmaking is closed after the game starts\n*Required Settings*\nCloseMatchmakingAfterGameStart : True"
    @editable Delay : float = 0.0

