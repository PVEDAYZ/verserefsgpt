using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

Univ_Triggers := class(creative_device):

    @editable Sources : []trigger_device = array{}             

    @editable Univ_Trigger : trigger_device = trigger_device{}     

    @editable Univ_Accolade : accolades_device = accolades_device{}  

    @editable Univ_Audio : audio_player_device = audio_player_device{} 

    @editable Univ_Analytics : analytics_device = analytics_device{} 

    @editable var DelaySeconds : float = 0.5                    

    MaxSources : int = 100

    OnBegin<override>()<suspends> : void =
        Print("Univ_Triggers: OnBegin - wiring Universal Trigger and enabling devices.")
        Univ_Trigger.TriggeredEvent.Subscribe(OnUniversalTriggered)

        Univ_Accolade.Enable()
        Univ_Audio.Enable()
        Univ_Analytics.Enable()
        Print("Univ_Triggers: Devices enabled (Accolade/Audio/Analytics).")

        Print("Univ_Triggers: Sources configured = {Sources.Length}, subscribing up to MaxSources = {MaxSources}.")
        for (Idx -> T : Sources):
            if (Idx < MaxSources):
                T.TriggeredEvent.Subscribe(OnSourceTriggered)
                Print("Univ_Triggers: Source[{Idx}] subscribed.")
            else:
                Print("Univ_Triggers: Source[{Idx}] skipped (>= MaxSources).")

    OnSourceTriggered(Instigator : ?agent) : void =
        Print("Univ_Triggers: OnSourceTriggered - spawning RelayAfterDelay.")
        spawn:
            RelayAfterDelay(Instigator)

    RelayAfterDelay(Instigator : ?agent)<suspends> : void =
        if (DelaySeconds > 0.0):
            Print("Univ_Triggers: RelayAfterDelay sleeping for {DelaySeconds}s.")
            Sleep(DelaySeconds)
            Print("Univ_Triggers: RelayAfterDelay woke after {DelaySeconds}s.")
        else:
            Print("Univ_Triggers: RelayAfterDelay with no sleep (DelaySeconds <= 0).")

        if (A := agent[Instigator?]):
            Univ_Trigger.Trigger(A)
            Print("Univ_Triggers: Relayed Univ_Trigger WITH instigator.")
        else:
            Univ_Trigger.Trigger()
            Print("Univ_Triggers: Relayed Univ_Trigger WITHOUT instigator.")

    OnUniversalTriggered(Instigator : ?agent) : void =
        Print("Univ_Triggers: OnUniversalTriggered fired.")
        if (A := agent[Instigator?]):
            Univ_Accolade.Award(A)   
            Univ_Audio.Play(A)
            Univ_Analytics.Submit(A)
            Print("Univ_Triggers: Awarded Accolade, played Audio, submitted Analytics WITH instigator.")
        else:
            Univ_Audio.Play()
            Print("Univ_Triggers: Played Audio WITHOUT instigator.")
