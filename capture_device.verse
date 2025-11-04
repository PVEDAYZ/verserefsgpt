using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
capture_device := class(creative_device):

    @editable GameManager : game_manager = game_manager{}
    @editable CaptureArea : capture_area_device = capture_area_device{}

    # --- Accolades hooks (optional; leave empty for no XP awards) ---
    @editable ControlGainAccolades : []accolades_device = array{}   # awarded when control changes to a new agent
    @editable PeriodicAccolades   : []accolades_device = array{}    # awarded to current owner every N payouts
    @editable PayoutsPerAccolade  : int = 6                         # N payout ticks (Sleep 5s each) -> award; 6 = ~30s

    var OwnerAgent : ?agent = false
    var PayoutCounter : int = 0

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        CaptureArea.ControlChangeEvent.Subscribe(ChangeOwner)
        spawn:
            GiveMoney()

    ChangeOwner(Agent : agent):void=
        set OwnerAgent = option{Agent}
        set PayoutCounter = 0
        AwardAccolades(option{Agent}, ControlGainAccolades)

    GiveMoney()<suspends>:void=
        loop:
            Sleep(5.0)
            if(Agent := OwnerAgent?, AgentRef := GameManager.AgentMap[Agent]):
                set AgentRef.TotalMoney += AgentRef.MoneyPerSecond

                # periodic accolade award based on payout ticks (no modulo used)
                if(PayoutsPerAccolade > 0):
                    set PayoutCounter += 1
                    if(PayoutCounter >= PayoutsPerAccolade):
                        AwardAccolades(option{Agent}, PeriodicAccolades)
                        set PayoutCounter = 0

    # ---------------- Helpers ----------------
    AwardAccolades(MaybeAgent : ?agent, List : []accolades_device):void=
        if(List.Length = 0):
            return
        if(Agent := MaybeAgent?):
            for(A : List):
                A.Award(Agent)
