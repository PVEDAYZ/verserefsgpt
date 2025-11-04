using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Colors }
using { /Verse.org/Assets }
using { /Verse.org/Random }
using { /Fortnite.com/Characters }

#THIS DEVICE CREATES A UI THAT ALLOWS PLAYERS TO COLLECT REWARDS THAT ARE UNLOCKED THROUGH PLAYTIME

#Class for different rewards
Reward := class<concrete>():
    #Base Stuff
    PersistanceManager : Tycoon_Persistence_Manager = Tycoon_Persistence_Manager{}
    var GameManager : Game_Manager = Game_Manager{}
    var ResourceManager : Resource_Manager = Resource_Manager{}
    var RewardManager : Reward_Manager = Reward_Manager{}
    var RewardNum : int = 0
    
    #UI Stuff
    var RewardCanvas : canvas = canvas{}
    var Timer : TimerWidget = TimerWidget{}
    var Buttons : UIAllButtons = UIAllButtons{}
    var Checkmark : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}

    #Check Image for when a reward is claimed
    #=====================================================================================================================
    var CheckImage : texture = MasterAssets.Placeholder
    #=====================================================================================================================


    #Extra Settings
    var RewardSettings : RewardSetting = RewardSetting{}

   #Resources granted when claimed
   TT_RM_Reward_RewardResources<localizes>:message = "The resources that are granted when the reward is claimed"
   @editable RewardResources : []GainableResource = array{}

   #Duration for the reward to unlock
   TT_RM_Reward_Duration<localizes>:message = "The duration for the reward to unlock (hours:minutes:seconds)"
   @editable var Hours : int = 0
   @editable var Minutes : int = 0
   @editable var Seconds : int = 0

   #Devices
   TT_RM_Reward_ClaimTrigger<localizes>:message = "The trigger that gets triggered when a reward is claimed"
   @editable ClaimTrigger : trigger_device = trigger_device{}

   TT_RM_Reward_AlertHUD<localizes>:message = "The hud message that is shown when the reward is available"
   @editable AlertHUD : hud_message_device = hud_message_device{}
    
    #Adjusts the current reward times for the player based on their saved playtime, if the persistence is enabled
    AdjustForPersistence(Agent:agent , Playtime : float) : void=
        if(RewardSettings.ShouldPlaytimePersist?):
            if:
                PTHours := Int[Playtime / 3600.0]
                PTMinutes := Int[(Playtime - (PTHours * 3600.0)) / 60.0]
                PTSeconds := Int[Playtime - (PTHours * 3600.0) - (PTMinutes * 60.0)]
            then:
                set Hours -= PTHours
                set Minutes -= PTMinutes
                set Seconds -= PTSeconds

            if(Hours < 0):
                set Hours = 0
                set Minutes = 0
                set Seconds = 0

            if(Minutes < 0):
                if(Hours > 0):
                    set Hours -= 1
                    set Minutes = 60 + Minutes
                else:
                    set Minutes = 0
                    set Seconds = 0

            if(Seconds < 0):
                if(Minutes > 0):
                    set Minutes -= 1
                    set Seconds = 60 + Seconds
                else:
                    if(Hours > 0):
                        set Hours -= 1
                        set Minutes = 59
                        set Seconds = 60 + Seconds
                    else:
                        set Seconds = 0
    
    #Initializes the Reward
    Initialize(Agent:agent) : void=
        #UI Setup
        Button := Buttons.GetButton(RewardSettings.ClaimButtonSettings.ButtonType)
        Button.SetText(MasterS2M("Claim"))
        Checkmark.SetVisibility(widget_visibility.Hidden)
        Button.OnClick().Subscribe(HandleClaimButton)   
        set RewardCanvas = CreateUI()

        #Starts timers and waits for them to complete
        spawn{Timer.StartTime(Agent , Hours , Minutes , Seconds)}
        spawn{AwaitAlert(Agent)}

        #Handles different UI changes depending on settings
        if(RewardSettings.ClaimButtonSettings.VisibleBeforeClaim = ButtonDisplayType.Hidden):
            Button.SetVisibility(widget_visibility.Hidden)
        else if(RewardSettings.ClaimButtonSettings.VisibleBeforeClaim = ButtonDisplayType.Disabled):
            Button.SetEnabled(false)

        #Changes the UI for rewards that have already been claimed by the player, if persistance is enabled
        if(RewardSettings.ShouldPlaytimePersist?):
            if(PR := RewardManager.PlayerRewardMap[Agent]):
                if(PR.ClaimedRewards.Find[RewardNum]):
                    Checkmark.SetVisibility(widget_visibility.Visible)
                    if(RewardSettings.ClaimButtonSettings.VisibleAfterClaim = ButtonDisplayType.Hidden):
                        Button.SetVisibility(widget_visibility.Hidden)
                    else if(RewardSettings.ClaimButtonSettings.VisibleAfterClaim = ButtonDisplayType.Disabled):
                        Button.SetEnabled(false)

    #Waits for reward to be available
    AwaitAlert(Agent:agent)<suspends> : void=
        if(PR := RewardManager.PlayerRewardMap[Agent]):
            Button := Buttons.GetButton(RewardSettings.ClaimButtonSettings.ButtonType)
            loop:
                Sleep(0.0)
                Player := Timer.CompleteEvent.Await()
                if(not PR.ClaimedRewards.Find[RewardNum]):
                    PR.UpdateAlertUI()
                    Button.SetEnabled(true)
                    Button.SetVisibility(widget_visibility.Visible)
                    AlertHUD.Show(Player)

    #Creates the reward UI
    CreateUI() : canvas=
        Button := Buttons.GetButton(RewardSettings.ClaimButtonSettings.ButtonType)
        NewCanvas : canvas = canvas{
            Slots := array:
                RewardSettings.DifferentPositions.CombinedRewardSettings.CheckMarkPosition.MakeCanvasSlot(Checkmark,false)
                RewardSettings.DifferentPositions.CombinedRewardSettings.ButtonPosition.MakeCanvasSlot(Button,false)
                RewardSettings.DifferentPositions.CombinedRewardSettings.TimerPosition.MakeCanvasSlot(Timer.Widget,false)
        }

    #Claims rewards if the timer is finished
    HandleClaimButton(Message : widget_message) : void=
        Player := Message.Player
        Button := Buttons.GetButton(RewardSettings.ClaimButtonSettings.ButtonType)
        if (PlayerUI := GetPlayerUI[Message.Player],CP := Custom_Player[GameManager.PlayersMap[Message.Player]] , PR := RewardManager.PlayerRewardMap[Player], RP := ResourceManager.PlayersMap[Player]):
            if(Timer.IsFinished?,not PR.ClaimedRewards.Find[RewardNum]):
                set Timer.IsFinished = false
                Checkmark.SetVisibility(widget_visibility.Visible)
                ClaimTrigger.Trigger(Player)
                RP.Collect(RewardResources)

                #Changes UI depending on different settings
                if(RewardSettings.ClaimButtonSettings.VisibleAfterClaim = ButtonDisplayType.Hidden):
                    Button.SetVisibility(widget_visibility.Hidden)
                else if(RewardSettings.ClaimButtonSettings.VisibleAfterClaim = ButtonDisplayType.Disabled):
                    Button.SetEnabled(false)

                if(RewardSettings.ClaimButtonSettings.ShouldClaimCloseUI? , CurrentUI := CP.CurrentExtraEvent):
                    CurrentUI.Signal()


                if(RewardSettings.ShouldPlaytimePersist?):
                    set PR.ClaimedRewards += array{RewardNum}
                    PersistanceManager.RecordPlayerArrStat(Player, StatType.ClaimedRewards, ?Score := RewardNum)

                PR.UpdateAlertUI()

#Class for the entire UI that displays all rewards
RewardUI := class():
    #Base stuff
    var GameManager : Game_Manager = Game_Manager{}    
    
    #UI Stuff
    var MainUI : canvas = canvas{}                            
    var ExitButton : button_loud = button_loud{}   

    #RewardUI Background Image
    #====================================================================================================================================
    var BackgroundImage : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}            
    #====================================================================================================================================

    #Different rewards & settings for them
    var Rewards : []Reward = array{}
    var RewardSettings : RewardSetting = RewardSetting{}

    RewardCloseEvent : event() = event(){}
    

    #initializes the UI
    Initialize(Agent:agent) : void=
        ExitButton.SetText(MasterS2M("Exit"))
        ExitButton.OnClick().Subscribe(HandleExitButton)   
        set MainUI = CreateUI()      
        spawn{RewardElimTrack(Agent)}

    RewardElimTrack(Agent:agent)<suspends> : void=
        if (Player := player[Agent],PlayerUI := GetPlayerUI[Player],FC:=Agent.GetFortCharacter[],CP := Custom_Player[GameManager.PlayersMap[Agent]]):
            race:
                FC.EliminatedEvent().Await()
                RewardCloseEvent.Await()

            MainUI.SetVisibility(widget_visibility.Hidden)
            CP.MyUI.SetVisibility(widget_visibility.Visible)
            PlayerUI.RemoveWidget(MainUI)

    #Exits the UI
    HandleExitButton(Message : widget_message) : void=  #Closes the UI
        Player := Message.Player
        if (PlayerUI := GetPlayerUI[Player], CP := GameManager.PlayersMap[Player]):
            RewardCloseEvent.Signal()



    #Creates the main ui and adds all reward UIs
    CreateUI() : canvas= 
        var NewShopUI : canvas = canvas{}
        for(idx -> SlotNum : RewardSettings.DifferentPositions.DisplayedRewards):
            if(Rew := Rewards[idx]):
                NewCanvas := Rew.RewardCanvas
                set SlotNum.Widget = NewCanvas
            NewSlot := SlotNum.Position.MakeCanvasSlot(SlotNum.Widget,false)
            NewShopUI.AddWidget(NewSlot)
        NewShopUI.AddWidget(RewardSettings.DifferentPositions.BackgroundPosition.MakeCanvasSlot(BackgroundImage,false))
        NewShopUI.AddWidget(RewardSettings.DifferentPositions.ExitButtonPosition.MakeCanvasSlot(ExitButton,false))
        return NewShopUI



#Class to hold the players stats and rewards
PlayerRewards := class<unique>():
    #Base Stuff
    Player : player
    PersistanceManager : Tycoon_Persistence_Manager = Tycoon_Persistence_Manager{}
    var RewardManager : Reward_Manager = Reward_Manager{}
    var GameManager : Game_Manager = Game_Manager{}
    var ResourceManager : Resource_Manager = Resource_Manager{}

    #Devices
    var RewardBoxXP : accolades_device = accolades_device{}

    #Settings & Rewards
    var RewardSettings : RewardSetting = RewardSetting{}
    var Rewards : []Reward = array{}

    #Player Stats
    var Playtime : float = 0.0
    var ClaimedRewards : []int = array{}

    #UI Stuff for displaying available rewards on player UI
    var RewardPlayerUIText : text_block = text_block{}

    #========================================================================================================================
    var RewardPlayerUIAlertBackgroundImage : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}
    var RewardPlayerUIAlertReadyImage : texture_block = texture_block{DefaultImage := MasterAssets.Placeholder}
    #========================================================================================================================

    #Starts the timers for the player and sets up all rewards
    Initiate() : void=
        spawn{PlaytimeCounter()}
        for(idx -> Rew : Rewards):
            set Rew.RewardNum = idx
            set Rew.RewardManager = RewardManager
            set Rew.GameManager = GameManager
            set Rew.ResourceManager = ResourceManager
            set Rew.RewardSettings = RewardSettings
            Rew.AdjustForPersistence(Player , Playtime)
            Rew.Initialize(Player)
        AddAlertUI()
        UpdateAlertUI()

    #Updates the UI on players screen to determine if they have any rewards available
    UpdateAlertUI() : void=
        var AvailableRewardAmount : int = 0
        for(R : Rewards):
            if(R.Timer.IsFinished?,not ClaimedRewards.Find[R.RewardNum]):
                set AvailableRewardAmount += 1
        if(AvailableRewardAmount > 0):
            RewardPlayerUIAlertReadyImage.SetVisibility(widget_visibility.Visible)
            RewardPlayerUIText.SetText(MasterS2M("{AvailableRewardAmount}"))
        else:
            RewardPlayerUIAlertReadyImage.SetVisibility(widget_visibility.Hidden)
            RewardPlayerUIText.SetText(MasterS2M(""))

    #Adds the Alert UI to the player if enabled
    AddAlertUI() : void=
        RewardPlayerUIText.SetTextColor(RewardSettings.AlertSettings.RewardPlayerUITextSettings.TextColor)
        RewardPlayerUIText.SetShadowColor(RewardSettings.AlertSettings.RewardPlayerUITextSettings.TextShadowColor)
        RewardPlayerUIText.SetShadowOffset(option{RewardSettings.AlertSettings.RewardPlayerUITextSettings.TextShadowOffset})
        RewardPlayerUIText.SetShadowOpacity(1.0)
        if(RewardSettings.AlertSettings.DisplayRewardsOnPlayerUI? , PlayerUI := GetPlayerUI[Player]):
            NewUI : canvas = canvas:
                Slots := array:
                    RewardSettings.AlertSettings.RewardPlayerUIBackgroundImagePosition.MakeCanvasSlot(RewardPlayerUIAlertBackgroundImage, false)
                    RewardSettings.AlertSettings.RewardPlayerUIAlertImagePosition.MakeCanvasSlot(RewardPlayerUIAlertReadyImage, false)
                    RewardSettings.AlertSettings.RewardPlayerUITextPosition.MakeCanvasSlot(RewardPlayerUIText, false)
            PlayerUI.AddWidget(NewUI)
    
    #Loop that counts the players playtime if persistence is enabled
    PlaytimeCounter()<suspends> : void=
        if(RewardSettings.ShouldPlaytimePersist?):
            PS := GameManager.ReturnPlayspace()
            race:
                block:
                    loop:
                        Sleep(0.0)
                        LeavingPlayer := PS.PlayerRemovedEvent().Await()
                        if(LeavingPlayer = Player):
                            break
                loop:
                    Sleep(1.0)
                    set Playtime += 1.0
                    PersistanceManager.RecordPlayerStat(Player, StatType.Playtime, ?Score := 1.0)

#A timer for each reward
TimerWidget := class():  
    #Base Stuff   
    var Hours : int = 0
    var Minutes : int = 0
    var Seconds : int = 5
    var Time : float = 0.0
    var Widget : text_block = text_block{DefaultTextColor := White}
    var ClaimButton : button_loud = button_loud{}
    var IsFinished : logic = false
    var CompleteEvent<public> : event(agent) = event(agent){}

    #Starts the timer
    StartTime(Agent : agent , NewHours : int , NewMinutes : int, NewSeconds : int)<suspends> : void=      
        set Hours = NewHours
        set Minutes = NewMinutes
        set Seconds = NewSeconds
        loop:
            Sleep(1.0)
            var BonusZeroHours : string = ""
            var BonusZeroMinutes : string = ""
            var BonusZeroSeconds : string = ""
            if(Hours < 10){set BonusZeroHours = "0"}
            if(Minutes < 10){set BonusZeroMinutes = "0"}
            if(Seconds < 10){set BonusZeroSeconds = "0"}
            Widget.SetText(MasterS2M("{BonusZeroHours}{Hours}:{BonusZeroMinutes}{Minutes}:{BonusZeroSeconds}{Seconds}"))
            set Seconds -= 1
            if(Seconds <= 0):
                if(not Minutes <= 0):
                    set Minutes -= 1
                    set Seconds = 59
                else if(not Hours <= 0):
                    set Hours -= 1
                    set Minutes = 59
                    set Seconds = 59
                else:
                    set IsFinished = true
                    Widget.SetText(MasterS2M(""))
                    CompleteEvent.Signal(Agent)
                    break

#Main creative device class
Reward_Manager := class(creative_device):
    #Base stuff
    PersistanceManager : Tycoon_Persistence_Manager = Tycoon_Persistence_Manager{}
    TT_RM_Device_GameManager<localizes>:message = "Your game manager device"
    @editable GameManager : Game_Manager = Game_Manager{}

    TT_RM_Device_ResourceManager<localizes>:message = "Your Resource Manager"
    @editable ResourceManager : Resource_Manager = Resource_Manager{}


    var PlayerRewardMap : [player]PlayerRewards = map{}

    #Devices
    TT_RM_Device_RewardActivateTrigger<localizes>:message = "The trigger that activates the rewards timer"
    @editable RewardActivateTrigger : trigger_device = trigger_device{}

    TT_RM_Device_RewardSettings<localizes>:message = "The settings for the rewards"
    @editable RewardSettings : RewardSetting = RewardSetting{}

    TT_RM_Device_RewardOpenTrigger<localizes>:message = "The trigger that opens the reward UI"
    @editable RewardOpenTrigger : trigger_device = trigger_device{}

    #Different Rewards
    @editable Rewards : []Reward = array{}

    #Initializes all devices and adds players to reward map
    OnBegin<override>()<suspends>:void=
        RewardOpenTrigger.TriggeredEvent.Subscribe(OpenRewardBox) 
        GetPlayspace().PlayerRemovedEvent().Subscribe(RemoveFromRewardMap)
        #Starts counting players either at game start or off of a trigger, based on settings
        if(RewardSettings.StartPlaytimeSetting = PlaytimeType.GameStart):
            for(Player : GetPlayspace().GetPlayers()){InitiateRewards(Player)}
            GetPlayspace().PlayerAddedEvent().Subscribe(InitiateRewards)
        else:     
            RewardActivateTrigger.TriggeredEvent.Subscribe(TInitiateRewards)



    #Removes the player from the map whenever they leave the session
    RemoveFromRewardMap(Agent:agent) : void=
        if(Player := player[Agent],Exists := PlayerRewardMap[Player]):
            if(NewMap := PlayerRewardMap.WithRemovedKey(Player)?):
                set PlayerRewardMap = NewMap

    #Opens the reward UI
    OpenRewardBox(MAgent:?agent): void=
        if(Agent := MAgent?, Player := player[Agent], PlayerUI := GetPlayerUI[Player] , CP := Custom_Player[GameManager.PlayersMap[Agent]] , RP := PlayerRewardMap[Agent]):
            NewRewardUI : RewardUI = RewardUI:
                GameManager := GameManager
                Rewards := RP.Rewards
                RewardSettings := RewardSettings
            NewRewardUI.Initialize(Agent)
            CP.MyUI.SetVisibility(widget_visibility.Hidden)
            PlayerUI.AddWidget(NewRewardUI.MainUI, player_ui_slot{InputMode := ui_input_mode.All})
            set CP.CurrentExtraEvent = NewRewardUI.RewardCloseEvent

    #Initiates rewards from a trigger
    TInitiateRewards(MAgent:?agent) : void=
        if(Agent:= MAgent?){InitiateRewards(Agent)}

    #Initiates rewards for the player
    InitiateRewards(Agent:agent) : void=   
        #Sets up rewards for player
        if(Player := player[Agent]):                    
            if(PlayerExists := PlayerRewardMap[Player]):
            else:
                if:
                    FC := Player.GetFortCharacter[]
                then:
                    NewRewards := GetNewRewards()
                    if(set PlayerRewardMap[Player] = PlayerRewards:
                        Player := Player
                        GameManager := GameManager
                        ResourceManager := ResourceManager
                        Rewards := NewRewards
                        RewardSettings := RewardSettings
                        RewardManager := Self
                    ){}
                    #Initializes player info
                    InitializeSavedData(Player)
                    if(RP := PlayerRewardMap[Player]):   
                        RP.Initiate()

    #Returns a new set of rewards
    GetNewRewards() : []Reward = 
        var NewRewards : []Reward = array{}
        for(R : Rewards):
            set NewRewards += array{Reward{
                PersistanceManager := R.PersistanceManager
                GameManager := R.GameManager
                ResourceManager := R.ResourceManager
                RewardManager := R.RewardManager
                RewardNum := R.RewardNum
                RewardSettings := R.RewardSettings
                RewardResources := R.RewardResources
                Hours := R.Hours
                Minutes := R.Minutes
                Seconds := R.Seconds
                ClaimTrigger := R.ClaimTrigger
                AlertHUD := R.AlertHUD

                RewardCanvas := canvas{}
                Timer := TimerWidget{}
                Buttons := UIAllButtons{}
                Checkmark := texture_block{DefaultImage := R.CheckImage}
            }}
        return NewRewards

    #Adds saved data to player if persistence is enabled
    InitializeSavedData(Player : player) : void=
        if(PR := PlayerRewardMap[Player] , PlayerStats := PersistanceManager.GetPlayerStats[Player]):
            if(RewardSettings.ShouldPlaytimePersist?):
                set PR.Playtime = PlayerStats.Playtime
                set PR.ClaimedRewards = PlayerStats.ClaimedRewards

#Different options to track playtime
PlaytimeType := enum:
    GameStart
    Trigger

#Different options for how buttons show be displayed for rewards
ButtonDisplayType := enum:
    Hidden
    Visible
    Disabled

#Combined settings for all rewards
CombinedRewardSetting := class<concrete>():
    TT_RM_CR_CheckMarkPosition<localizes>:message = "The position of the checkmark on the reward which is shown when it is claimed"
    @editable CheckMarkPosition : CanvasPosition = CanvasPosition{}

    TT_RM_CR_ButtonPosition<localizes>:message = "The position of the claim button on the reward"
    @editable ButtonPosition : CanvasPosition = CanvasPosition{}
    

    TT_RM_CR_TimerPosition<localizes>:message = "The position of the timer on the reward"
    @editable TimerPosition : CanvasPosition = CanvasPosition{}

#Different postion settings for the Reward UI
DifferentPosition:= class<concrete>():
    @editable CombinedRewardSettings : CombinedRewardSetting  = CombinedRewardSetting{}
    @editable DisplayedRewards: []DisplayedReward = array{}
    @editable ExitButtonPosition : CanvasPosition = CanvasPosition{}
    @editable BackgroundPosition : CanvasPosition = CanvasPosition{}

#Settings for the claim buttons in a reward
ClaimButtonSetting:= class<concrete>():
    @editable VisibleBeforeClaim : ButtonDisplayType = ButtonDisplayType.Hidden
    @editable VisibleAfterClaim : ButtonDisplayType = ButtonDisplayType.Hidden
    @editable ShouldClaimCloseUI : logic = false
    @editable ButtonType : UIButtonType = UIButtonType.Loud

#Collection of different settings for rewards
RewardSetting := class<concrete>():
    @editable DifferentPositions : DifferentPosition = DifferentPosition{}
    @editable ClaimButtonSettings : ClaimButtonSetting = ClaimButtonSetting{}
    @editable AlertSettings : AlertSetting = AlertSetting{}
    TT_RM_RewardSetting_ShouldPlaytimePersist<localizes>:message = "Whether or not the rewards should persist between games"
    @editable ShouldPlaytimePersist : logic = false

    TT_RM_RewardSetting_StartPlaytimeSetting<localizes>:message = "Whether or not the rewards should start counting playtime from game start or a trigger"
    @editable StartPlaytimeSetting : PlaytimeType = PlaytimeType.GameStart

#Settings that control how a player is alerted for rewards
AlertSetting := class<concrete>():
    @editable DisplayRewardsOnPlayerUI : logic = false
    @editable RewardPlayerUITextSettings : TextSetting = TextSetting{}
    @editable RewardPlayerUIBackgroundImagePosition : CanvasPosition = CanvasPosition{}
    @editable RewardPlayerUIAlertImagePosition : CanvasPosition = CanvasPosition{}
    @editable RewardPlayerUITextPosition : CanvasPosition = CanvasPosition{}

#Setting to control where a reward is placed on the full Reward UI
DisplayedReward := class<concrete>():
    @editable Position : CanvasPosition = CanvasPosition{}
    var Widget : canvas = canvas{}
