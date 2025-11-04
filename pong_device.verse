using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# A Verse-authored creative device that can be placed in a level
pong_device := class(creative_device):

    @editable GameManager : game_manager = game_manager{}
    @editable SkillDevice : skilled_interaction_device = skilled_interaction_device{}
    @editable HudMessage : hud_message_device = hud_message_device{}
    @editable FailMessage : hud_message_device = hud_message_device{}
    @editable OpenButton : button_device = button_device{}
    @editable LargeAccolade : accolades_device = accolades_device{}
    @editable Price : float = 3000.0

    # -------- Optional accolades (leave arrays empty for no extra XP) --------
    @editable StartAccolades : []accolades_device = array{}        # when player successfully starts a round (paid)
    @editable GoodInputAccolades : []accolades_device = array{}    # each successful input
    @editable PrecisionAccolades : []accolades_device = array{}    # when "good" input is very precise (see threshold)
    @editable StreakAccolades : []accolades_device = array{}       # when player hits N good inputs in a row
    @editable WinAccolades : []accolades_device = array{}          # in addition to LargeAccolade on win
    @editable LoseAccolades : []accolades_device = array{}         # when the round ends without winning
    @editable CloseCallAccolades : []accolades_device = array{}    # e.g., 4/5 made but not perfect
    @editable InsufficientFundsAccolades : []accolades_device = array{}  # tried to play but couldn't afford

    # Tunables for accolades
    @editable PrecisionThreshold : float = 0.05    # smaller = more precise
    @editable StreakTarget : int = 3               # N consecutive good inputs for streak award

    var Shots : int = 5
    var Made : int = 0
    var StreakCount : int = 0

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        OpenButton.InteractedWithEvent.Subscribe(TryStart)
        SkillDevice.InteractionStartedEvent.Subscribe(StartGame)
        SkillDevice.GoodInputTriggeredEvent.Subscribe(GoodInput)
        # Use a dedicated handler for bad input so we can reset streaks cleanly,
        # then delegate to the shared finish logic.
        SkillDevice.BadInputTriggeredEvent.Subscribe(OnBadInput)

    TryStart(Agent : agent):void=
        if(AgentData := GameManager.AgentMap[Agent]):
            if(AgentData.TotalMoney > Price):
                set AgentData.TotalMoney -= Price
                if(SkillDevice.BeginInteraction[Agent]){}
                AwardAccolades(option{Agent}, StartAccolades)
            else:
                FailMessage.Show(Agent)
                AwardAccolades(option{Agent}, InsufficientFundsAccolades)

    StartGame(Agent : agent):void=
        set Shots = 5
        set Made = 0
        set StreakCount = 0

    GoodInput(Agent : agent, Dist : float):void=
        set Made += 1
        set StreakCount += 1
        GameManager.AddMoney(1000, Agent)
        AwardAccolades(option{Agent}, GoodInputAccolades)

        # Precision award when input is within threshold.
        if(Dist <= PrecisionThreshold):
            AwardAccolades(option{Agent}, PrecisionAccolades)

        # Streak award when N in a row; then reset to avoid modulo use.
        if(StreakTarget > 0 and StreakCount >= StreakTarget):
            AwardAccolades(option{Agent}, StreakAccolades)
            set StreakCount = 0

        CheckFinish(Agent, Dist)

    OnBadInput(Agent : agent, Dist : float):void=
        # Miss breaks the current streak.
        set StreakCount = 0
        CheckFinish(Agent, Dist)

    CheckFinish(Agent : agent, Dist : float):void=
        set Shots -= 1
        if(Made = 5):
            spawn{Win(Agent)}
        else if(Shots = 0):
            # Round ended without a perfect score.
            if(SkillDevice.EndInteraction[Agent]){}
            # Close call: 4/5.
            if(Made = 4):
                AwardAccolades(option{Agent}, CloseCallAccolades)
            AwardAccolades(option{Agent}, LoseAccolades)

    Win(Agent: agent)<suspends>:void=
        Sleep(0.1)
        Money := GameManager.GetMoney(Agent)
        GameManager.AddMoney(15000, Agent)
        LargeAccolade.Award(Agent)                # existing large win award
        AwardAccolades(option{Agent}, WinAccolades)
        HudMessage.Show(Agent, TextForUI("${AddCommas(15000)}"))

    # ---------------- Helpers ----------------
    AwardAccolades(MaybeAgent : ?agent, List : []accolades_device):void=
        if(List.Length = 0):
            return
        if(Agent := MaybeAgent?):
            for(A : List):
                A.Award(Agent)
