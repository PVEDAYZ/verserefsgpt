using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

per_player_asmr_device := class(creative_device):
    @editable
    EnableTrigger : trigger_device = trigger_device{}

    @editable
    DisableTrigger : trigger_device = trigger_device{}

    @editable
    MovementInput : input_trigger_device = input_trigger_device{}

    @editable
    SprintInput : input_trigger_device = input_trigger_device{}

    @editable
    JumpInput : input_trigger_device = input_trigger_device{}

    @editable
    LeftInput : input_trigger_device = input_trigger_device{}

    @editable
    RightInput : input_trigger_device = input_trigger_device{}

    @editable
    FireInput : input_trigger_device = input_trigger_device{}

    @editable
    MovementAudio : audio_player_device = audio_player_device{}

    @editable
    SprintAudio : audio_player_device = audio_player_device{}

    @editable
    JumpAudio : audio_player_device = audio_player_device{}

    @editable
    LeftAudio : audio_player_device = audio_player_device{}

    @editable
    RightAudio : audio_player_device = audio_player_device{}

    @editable
    FireAudio : audio_player_device = audio_player_device{}

   
    var EnabledPlayers : [agent][]int = map{}

    OnBegin<override>()<suspends> : void =
        EnableTrigger.TriggeredEvent.Subscribe(OnEnableTrigger)
        DisableTrigger.TriggeredEvent.Subscribe(OnDisableTrigger)

        MovementInput.PressedEvent.Subscribe(OnMovementPressed)
        MovementInput.ReleasedEvent.Subscribe(OnMovementReleasedWrapper)
        SprintInput.PressedEvent.Subscribe(OnSprintPressed)
        SprintInput.ReleasedEvent.Subscribe(OnSprintReleasedWrapper)
        JumpInput.PressedEvent.Subscribe(OnJumpPressed)
        JumpInput.ReleasedEvent.Subscribe(OnJumpReleasedWrapper)
        LeftInput.PressedEvent.Subscribe(OnLeftPressed)
        LeftInput.ReleasedEvent.Subscribe(OnLeftReleasedWrapper)
        RightInput.PressedEvent.Subscribe(OnRightPressed)
        RightInput.ReleasedEvent.Subscribe(OnRightReleasedWrapper)
        FireInput.PressedEvent.Subscribe(OnFirePressed)
        FireInput.ReleasedEvent.Subscribe(OnFireReleasedWrapper)

    OnEnableTrigger(Agent : ?agent) : void =
        if (Player := Agent?):
            if (set EnabledPlayers[Player] = array{0, 0, 0, 0, 0, 0}):
                Print("ASMR enabled for a player")

    OnDisableTrigger(Agent : ?agent) : void =
        if (Player := Agent?):
            var NewPlayers : [agent][]int = map{}
            for (EnabledPlayer -> Counts : EnabledPlayers, EnabledPlayer <> Player):
                if (set NewPlayers[EnabledPlayer] = Counts) {}
            set EnabledPlayers = NewPlayers
            MovementAudio.Stop(Player)
            SprintAudio.Stop(Player)
            JumpAudio.Stop(Player)
            LeftAudio.Stop(Player)
            RightAudio.Stop(Player)
            FireAudio.Stop(Player)
            Print("ASMR disabled for a player")

    IncrementInputCount(Agent : agent, Index : int, Audio : audio_player_device) : void =
        if (Counts := EnabledPlayers[Agent]):
            if (Count := Counts[Index]):
                var NewCounts : []int = Counts
                if (set NewCounts[Index] = Count + 1):
                    if (set EnabledPlayers[Agent] = NewCounts):
                        if (Count = 0):
                            Audio.Play(Agent)

    DecrementInputCount(Agent : agent, Index : int, Audio : audio_player_device) : void =
        if (Counts := EnabledPlayers[Agent]):
            if (Count := Counts[Index], Count > 0):
                var NewCounts : []int = Counts
                if (set NewCounts[Index] = Count - 1):
                    if (set EnabledPlayers[Agent] = NewCounts):
                        if (Count = 1):
                            Audio.Stop(Agent)

    OnMovementPressed(Agent : agent) : void = IncrementInputCount(Agent, 0, MovementAudio)
    OnMovementReleasedWrapper(InputData : tuple(agent, float)) : void = DecrementInputCount(InputData(0), 0, MovementAudio)

    OnSprintPressed(Agent : agent) : void = IncrementInputCount(Agent, 1, SprintAudio)
    OnSprintReleasedWrapper(InputData : tuple(agent, float)) : void = DecrementInputCount(InputData(0), 1, SprintAudio)

    OnJumpPressed(Agent : agent) : void = IncrementInputCount(Agent, 2, JumpAudio)
    OnJumpReleasedWrapper(InputData : tuple(agent, float)) : void = DecrementInputCount(InputData(0), 2, JumpAudio)

    OnLeftPressed(Agent : agent) : void = IncrementInputCount(Agent, 3, LeftAudio)
    OnLeftReleasedWrapper(InputData : tuple(agent, float)) : void = DecrementInputCount(InputData(0), 3, LeftAudio)

    OnRightPressed(Agent : agent) : void = IncrementInputCount(Agent, 4, RightAudio)
    OnRightReleasedWrapper(InputData : tuple(agent, float)) : void = DecrementInputCount(InputData(0), 4, RightAudio)

    OnFirePressed(Agent : agent) : void = IncrementInputCount(Agent, 5, FireAudio)
    OnFireReleasedWrapper(InputData : tuple(agent, float)) : void = DecrementInputCount(InputData(0), 5, FireAudio)