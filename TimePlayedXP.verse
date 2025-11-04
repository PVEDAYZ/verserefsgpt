
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
TimePlayedXP := class(creative_device):

    @editable XPStat : stat_creator_device = stat_creator_device{}
    @editable Timer : timer_device = timer_device{}
    @editable AccoladeDevice : accolades_device = accolades_device{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        # TODO: Replace this with your code
        Timer.SuccessEvent.Subscribe(GrantStat)
        XPStat.MaximumReachedEvent.Subscribe(GrantXP)

    GrantStat(IsAgent:?agent):void=
        if(Agent := IsAgent?):
            if(CurrentValue := XPStat.GetValue[Agent]):
                if(XPStat.SetValue[Agent, CurrentValue + 1]):
                    spawn:
                        RestartTimer(Agent)

    RestartTimer(Agent:agent)<suspends>:void=
        Timer.Reset(Agent)
        Sleep(0.2)
        Timer.Start(Agent)


    GrantXP(IsAgent:?agent, Level : int):void=
        Print("Max XP Reached")
        if(Agent := IsAgent?):
            if(CurrentValue := XPStat.GetValue[Agent]):
                if(CurrentValue = 30 ):
                    if(XPStat.SetValue[Agent, 0]):
                        AccoladeDevice.Award(Agent)