
using { /Fortnite.com }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org }
using { /Verse.org/Random }
using { /Verse.org/Simulation }


Tag_Manager := class(creative_device):


    var Runners : []player = array{}
    var Taggers : []player = array{}
    var SafeRunners : []player = array{}

    @editable RunnerVFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable TaggerVFX : visual_effect_powerup_device = visual_effect_powerup_device{}

    @editable RunnerTP : teleporter_device = teleporter_device{}
    @editable TaggerTP : teleporter_device = teleporter_device{}

    @editable AllConditionals : []conditional_button_device = array{}

    @editable FinishLineTrigger : trigger_device = trigger_device{}
    @editable GameTimer : timer_device = timer_device{}

    @editable WinGameGranter : item_granter_device = item_granter_device{}

    @editable LobbyTimer : timer_device = timer_device{}
    @editable LobbyTP : teleporter_device = teleporter_device{}

    @editable Barrier : barrier_device = barrier_device{}

    @editable ClearVFXTrigger : trigger_device = trigger_device{}

    OnBegin<override>()<suspends>:void=
        StartGame()
        FinishLineTrigger.TriggeredEvent.Subscribe(MakeRunnerSafe)
        for(Player : GetPlayspace().GetPlayers()):
            TrackDamage(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(TrackDamage)


    TrackGame()<suspends> :void=
        GameTimer.Start()
        race:
            block:
                GameTimer.SuccessEvent.Await()

            block:
                loop:
                    Sleep(0.0)
                    if(Runners.Length = -1):
                        break

        if(SafeRunners.Length > 0):
            for(SafeRunner : SafeRunners):
                WinGameGranter.GrantItem(SafeRunner)


        GameTimer.Complete()
        spawn:
            StartGame()


    StartGame()<suspends> : void=
        Barrier.Enable()
        set Runners = array{}
        set Taggers = array{}
        set SafeRunners = array{}
        for(Player : GetPlayspace().GetPlayers()):
            LobbyTP.Teleport(Player)
            ClearVFXTrigger.Trigger(Player)

        LobbyTimer.Start()
        LobbyTimer.SuccessEvent.Await()
        
        InitializeTeams()
        spawn:
            TrackGame()

        




    MakeRunnerSafe(MAgent : ?agent) : void=
        if(Agent := MAgent? , Player := player[Agent]):
            if(NewArray := Runners.RemoveFirstElement[Player]):
                set Runners = NewArray
            set SafeRunners += array{Player}
            ClearVFXTrigger.Trigger(Player)



    InitializeTeams() : void=
        var AllPlayers : []player = GetPlayspace().GetPlayers()
        for(NewTagger := 1..1):
            RandomNum := GetRandomInt(0, AllPlayers.Length-1)
            if(SelectedPlayer := AllPlayers[RandomNum]):
                set Taggers += array{SelectedPlayer}
            if(NewArray := AllPlayers.RemoveElement[RandomNum]):
                set AllPlayers = NewArray
        set Runners = AllPlayers


        for(Runner : Runners, FC := Runner.GetFortCharacter[]):
            RunnerVFX.Pickup(Runner)
            RunnerTP.Teleport(Runner)
            

        for(Tagger : Taggers):
            TaggerVFX.Pickup(Tagger)
            TaggerTP.Teleport(Tagger)

    OnRunnerDamaged(Result : damage_result) : void=
        if:
            Target := fort_character[Result.Target]
            Instigator := Result.Instigator?.GetInstigatorAgent[]
            TargetPlayer := player[Target.GetAgent[]]
            InstigatorPlayer := player[Instigator]
        then:
            if:
                Runners.Find[TargetPlayer]
                Taggers.Find[InstigatorPlayer]
                var IsHoldingAnItem : logic = false
                for(Conditional : AllConditionals , IsHoldingAnItem = false):
                    if(Conditional.IsHoldingItem[InstigatorPlayer]):
                        set IsHoldingAnItem = true
                not IsHoldingAnItem?
            then:
                if(NewArray := Runners.RemoveFirstElement[TargetPlayer]):
                    set Runners = NewArray
                set Taggers += array{TargetPlayer}
                TaggerVFX.Pickup(TargetPlayer)


    TrackDamage(Player : player) : void=
        if(FC := Player.GetFortCharacter[]):
            FC.DamagedEvent().Subscribe(OnRunnerDamaged)
            FC.DamagedShieldEvent().Subscribe(OnRunnerDamaged)