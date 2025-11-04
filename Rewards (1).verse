using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

timer_switch_controller := class(creative_device):

    @editable MySwitch : switch_device = switch_device{}
    @editable StartTrigger : trigger_device = trigger_device{}
    @editable StopTrigger : trigger_device = trigger_device{}

    @editable Timer1 : timer_device = timer_device{}
    @editable Timer2 : timer_device = timer_device{}
    @editable Timer3 : timer_device = timer_device{}
    @editable Timer4 : timer_device = timer_device{}
    @editable Timer5 : timer_device = timer_device{}

    @editable Reward1 : accolades_device = accolades_device{}
    @editable Reward2 : accolades_device = accolades_device{}
    @editable Reward3 : accolades_device = accolades_device{}
    @editable Reward4 : accolades_device = accolades_device{}
    @editable Reward5 : accolades_device = accolades_device{}

    @editable SwitchOnAnalytics : analytics_device = analytics_device{}
    @editable SwitchOffAnalytics : analytics_device = analytics_device{}
    @editable ResetButton : button_device = button_device{}

    OnBegin<override>()<suspends>:void =
        Print("timer_switch_controller: OnBegin - wiring events.")
        MySwitch.TurnedOnEvent.Subscribe(OnSwitchTurnedOn)
        Print("timer_switch_controller: Subscribed to MySwitch.TurnedOnEvent.")
        MySwitch.TurnedOffEvent.Subscribe(OnSwitchTurnedOff)
        Print("timer_switch_controller: Subscribed to MySwitch.TurnedOffEvent.")
        ResetButton.InteractedWithEvent.Subscribe(OnResetPressed)
        Print("timer_switch_controller: Subscribed to ResetButton.InteractedWithEvent.")
        StartTrigger.TriggeredEvent.Subscribe(OnTriggerStart)
        StopTrigger.TriggeredEvent.Subscribe(OnTriggerStop)
        Print("timer_switch_controller: Subscribed to Start/Stop Trigger events.")

        Timer1.SuccessEvent.Subscribe(OnTimer1Finished)
        Timer2.SuccessEvent.Subscribe(OnTimer2Finished)
        Timer3.SuccessEvent.Subscribe(OnTimer3Finished)
        Timer4.SuccessEvent.Subscribe(OnTimer4Finished)
        Timer5.SuccessEvent.Subscribe(OnTimer5Finished)
        Print("timer_switch_controller: Subscribed to all timer SuccessEvent handlers.")

    OnSwitchTurnedOn(TriggeringAgent:agent):void =
        Print("Switch turned ON - triggering StartTrigger")
        StartTrigger.Trigger()

        Reward1.Enable()
        Reward2.Enable()
        Reward3.Enable()
        Reward4.Enable()
        Reward5.Enable()
        Print("timer_switch_controller: Rewards 1-5 enabled.")

        SwitchOnAnalytics.Submit
        Print("timer_switch_controller: SwitchOnAnalytics.Submit called.")

    OnSwitchTurnedOff(TriggeringAgent:agent):void =
        Print("Switch turned OFF - pausing timers")
        StopTrigger.Trigger()

        Reward1.Disable()
        Reward2.Disable()
        Reward3.Disable()
        Reward4.Disable()
        Reward5.Disable()
        Print("timer_switch_controller: Rewards 1-5 disabled.")

        SwitchOffAnalytics.Submit
        Print("timer_switch_controller: SwitchOffAnalytics.Submit called.")

    OnResetPressed(Agent:agent):void =
        Print("Reset button pressed — pausing and resetting all timers")
        Timer1.Pause()
        Timer2.Pause()
        Timer3.Pause()
        Timer4.Pause()
        Timer5.Pause()
        Timer1.Reset()
        Timer2.Reset()
        Timer3.Reset()
        Timer4.Reset()
        Timer5.Reset()
        Reward1.Disable()
        Reward2.Disable()
        Reward3.Disable()
        Reward4.Disable()
        Reward5.Disable()
        Print("timer_switch_controller: All timers paused/reset; rewards disabled.")

    OnTriggerStart(InAgent:?agent):void =
        Print("Trigger activated - starting Timer1")
        Timer1.Start()
        Print("timer_switch_controller: Timer1.Start called.")

    OnTriggerStop(InAgent:?agent):void =
        Print("Stop trigger activated - pausing all timers")
        Timer1.Pause()
        Timer2.Pause()
        Timer3.Pause()
        Timer4.Pause()
        Timer5.Pause()
        Print("timer_switch_controller: Timers 1-5 paused.")

    OnTimer1Finished(Result:?agent):void =
        Print("Timer 1 Finished")
        Timer2.Start()
        Print("timer_switch_controller: Timer2.Start called.")
        Reward1.Award
        Print("timer_switch_controller: Reward1.Award called.")

    OnTimer2Finished(Result:?agent):void =
        Print("Timer 2 Finished")
        Timer3.Start()
        Print("timer_switch_controller: Timer3.Start called.")
        Reward2.Award
        Print("timer_switch_controller: Reward2.Award called.")

    OnTimer3Finished(Result:?agent):void =
        Print("Timer 3 Finished")
        Timer4.Start()
        Print("timer_switch_controller: Timer4.Start called.")
        Reward3.Award
        Print("timer_switch_controller: Reward3.Award called.")

    OnTimer4Finished(Result:?agent):void =
        Print("Timer 4 Finished")
        Timer5.Start()
        Print("timer_switch_controller: Timer5.Start called.")
        Reward4.Award
        Print("timer_switch_controller: Reward4.Award called.")

    OnTimer5Finished(Result:?agent):void =
        Print("Timer 5 Finished")
        Reward5.Award
        Print("timer_switch_controller: Reward5.Award called.")
        StartTrigger.Trigger()
        Print("timer_switch_controller: Restart chain -> StartTrigger.Trigger()")
