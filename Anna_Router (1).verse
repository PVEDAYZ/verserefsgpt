using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }                
using { /UnrealEngine.com/Temporary/Diagnostics }

RewardRouter := class<concrete>(creative_device):

    @editable BasePVE : accolades_device = accolades_device{}

    @editable BasePVP : accolades_device = accolades_device{}

    @editable EnableDebug : logic = false

    @editable GlobalAwardCooldown : float = 0.0
    var CooldownActive : logic = false

    OnBegin<override>()<suspends>:void =
        D("Router OnBegin: enabling base accolades.")
        BasePVE.Enable()
        BasePVP.Enable()
        D("Router ready. Cooldown={GlobalAwardCooldown}s")

    RoutePVE<public>(Recipient:agent):void =
        D("RoutePVE called.")
        AwardAll(array{BasePVE}, Recipient)

    RoutePVP<public>(Recipient:agent):void =
        D("RoutePVP called.")
        AwardAll(array{BasePVP}, Recipient)

    AwardAccolade<public>(Acc:accolades_device, Recipient:agent):void =
        D("AwardAccolade called (single).")
        AwardAll(array{Acc}, Recipient)

    AwardPair<public>(Acc1:accolades_device, Acc2:accolades_device, Recipient:agent):void =
        D("AwardPair called (two accolades).")
        AwardAll(array{Acc1, Acc2}, Recipient)

    AwardAll(Accs:[]accolades_device, Recipient:agent):void =
        if (GlobalAwardCooldown > 0.0 and CooldownActive?):
            D("Router cooldown active; award skipped.")
            return

        if (GlobalAwardCooldown > 0.0 and not CooldownActive?):
            set CooldownActive = true
            D("Starting global award cooldown for {GlobalAwardCooldown}s.")
            spawn:
                StartCooldown()

        D("AwardAll: processing {Accs.Length} accolade(s).")
        for (A : Accs):
            A.Award(Recipient)
            D("Awarded via Router.")

    StartCooldown()<suspends>:void =
        Sleep(GlobalAwardCooldown)
        set CooldownActive = false
        D("Global award cooldown finished.")

    D(Msg:string):void =
        if (EnableDebug?):
            Print(Msg)
