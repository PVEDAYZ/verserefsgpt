using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

jump_scare_manager := class(creative_device):

    @editable EnableJumpScare           : logic = false
    @editable MaxWithin                : int   = 20             
    @editable TriggerChancePercent     : int   = 20             
    @editable MaxTriggersPerWindow     : int   = 6              
    @editable UseSeed                  : logic = true
    @editable Seed                     : int   = 1337

    @editable MaxScaresPerMatch        : int   = 0

    @editable OnlyWhenBothPresent      : logic = false  
    @editable DisableDuringIntermission: logic = false 

    @editable DEBUG                    : logic = false

    # Freeze (optional)
    @editable ShouldFreezeSetting      : int   = 0            # 0 = no freeze, 1 = freeze on scare
    @editable FreezeTrigger            : trigger_device          = trigger_device{}

    # Jumpscare AV
    @editable ScareSFX                 : audio_player_device          = audio_player_device{}
    @editable ScareVFX                 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable ScareHUD                 : hud_message_device           = hud_message_device{}
    @editable ScareTrigger             : trigger_device               = trigger_device{}

    # Cinematic playback (wire to Cinematic Sequence Device "Play")
    @editable EnableCinematic          : logic = false
    @editable CinematicTrigger         : trigger_device               = trigger_device{}
    @editable CinematicPlayDelaySeconds: float = 0.0

    # Accolades
    @editable EnableAccolades          : logic = true
    @editable AccScareBasic            : accolades_device             = accolades_device{}   
    @editable AccFirstScare            : accolades_device             = accolades_device{}  
    @editable AccBackToBackScare       : accolades_device             = accolades_device{}   
    @editable AccRareScare             : accolades_device             = accolades_device{} 
    @editable AccWindowOpener          : accolades_device             = accolades_device{}  
    @editable AccWindowCloser          : accolades_device             = accolades_device{}   
    @editable AccWindowMaxed           : accolades_device             = accolades_device{}   
    @editable AccQuietWindow           : accolades_device             = accolades_device{}   
    @editable RareRollPercent          : int   = 3  

    # --- Manual test button ---
    @editable EnableManualButton       : logic = true
    @editable ManualScareButton        : button_device                = button_device{}
    @editable ManualRespectsEnable     : logic = true
    @editable ManualIgnoresGates       : logic = false
    @editable ManualCountsTowardsLimits: logic = false
    @editable ManualAwardsAccolades    : logic = false

    # --- State ---
    var CurrentWindow        : int   = 1
    var Window               : int   = 1
    var PosInWindow          : int   = 0
    var TriggersThisWindow   : int   = 0
    var TotalScares          : int   = 0
    var PrevWasScare         : logic = false

    var LastRoll             : int   = 0
    var LastWasRare          : logic = false
    var IntermissionActive   : logic = false

    var CinematicDelayClamped: float = 0.0

    var LastBlue             : ?agent = false
    var LastRed              : ?agent = false

    Log(S:string):void =
        if (DEBUG = true):
            Print(S)

    SetIntermissionActive(On:logic):void =
        set IntermissionActive = On

    OnBegin<override>()<suspends>:void =
        set Window = 1
        set CurrentWindow = 1
        set PosInWindow = 0
        set TriggersThisWindow = 0
        set TotalScares = 0
        set PrevWasScare = false
        set LastRoll = 0
        set LastWasRare = false
        set IntermissionActive = false

        set CinematicDelayClamped = CinematicPlayDelaySeconds
        if (CinematicDelayClamped < 0.0):
            set CinematicDelayClamped = 0.0
        if (CinematicDelayClamped > 5.0):
            set CinematicDelayClamped = 5.0

        ManualScareButton.InteractedWithEvent.Subscribe(OnManualButton)

    IntMod(A:int, B:int):int =
        if (B <= 0):
            return 0
        var r:int = A
        loop:
            if (r < B):
                return r
            set r = r - B

    IntMin(A:int, B:int):int =
        if (A < B):
            return A
        return B

    Mix3(A:int, B:int, C:int):int =
        x := (A * 1103515245) + 12345
        y := ((B + 1) * 1664525) + 1013904223
        z := ((C + 7) * 22695477) + 1
        s := (x + y) + z
        return (s * 1103515245) + 12345

    SafeAbs(V:int):int =
        if (V < 0):
            return -V
        return V

    ShouldTrigger(W:int, P:int):logic =
        chance := TriggerChancePercent
        if (chance <= 0):
            set LastRoll = 0
            set LastWasRare = false
            return false

        var baseSeed:int = Seed
        if (UseSeed = false):
            set baseSeed = 987654321

        key  := SafeAbs(Mix3(baseSeed, W, P))
        roll := IntMod(key, 100)
        set LastRoll = roll

        limit := IntMin(RareRollPercent, chance)
        var rare_now:logic = false
        if (roll < limit):
            set rare_now = true
        set LastWasRare = rare_now

        if (roll < chance):
            return true
        return false

    AwardTo(Acc:accolades_device, A:?agent):void =
        if (P := A?):
            Acc.Award(P)

    AwardBoth(Acc:accolades_device, Blue:?agent, Red:?agent):void =
        AwardTo(Acc, Blue)
        AwardTo(Acc, Red)

    CinematicAfterDelay(Delay:float)<suspends>:void =
        if (Delay > 0.0):
            Sleep(Delay)
        CinematicTrigger.Trigger()

    DoScare(Blue:?agent, Red:?agent, W:int, P:int):void =
        ScareSFX.Play()
        ScareTrigger.Trigger()

        if (B := Blue?):
            ScareHUD.Show(B)
            ScareVFX.Pickup(B)
        if (R := Red?):
            ScareHUD.Show(R)
            ScareVFX.Pickup(R)

        if (ShouldFreezeSetting = 1):
            FreezeTrigger.Trigger()

        if (EnableCinematic = true):
            d := CinematicDelayClamped
            spawn { CinematicAfterDelay(d) }

        if (EnableAccolades = true):
            AwardBoth(AccScareBasic, Blue, Red)
            if (TotalScares = 0):
                AwardBoth(AccFirstScare, Blue, Red)
            if (PrevWasScare = true):
                AwardBoth(AccBackToBackScare, Blue, Red)
            if (LastWasRare = true):
                AwardBoth(AccRareScare, Blue, Red)
            if (P = 1):
                AwardBoth(AccWindowOpener, Blue, Red)
            if (P = MaxWithin):
                AwardBoth(AccWindowCloser, Blue, Red)
            if (TriggersThisWindow = MaxTriggersPerWindow):
                AwardBoth(AccWindowMaxed, Blue, Red)

        set PrevWasScare = true
        set TotalScares  = TotalScares + 1

    DoScareManual(Blue:?agent, Red:?agent):void =
        ScareSFX.Play()
        ScareTrigger.Trigger()

        if (B := Blue?):
            ScareHUD.Show(B)
            ScareVFX.Pickup(B)
        if (R := Red?):
            ScareHUD.Show(R)
            ScareVFX.Pickup(R)

        if (ShouldFreezeSetting = 1):
            FreezeTrigger.Trigger()

        if (EnableCinematic = true):
            d2 := CinematicDelayClamped
            spawn { CinematicAfterDelay(d2) }

        if (ManualAwardsAccolades = true and EnableAccolades = true):
            AwardBoth(AccScareBasic, Blue, Red)

    AwardQuietPreviousWindowIfAny(PrevCount:int, Blue:?agent, Red:?agent):void =
        if (EnableAccolades = false):
            return
        if (PrevCount = 0):
            AwardBoth(AccQuietWindow, Blue, Red)

    OnManualButton(Presser:agent):void =
        if (EnableManualButton = false):
            return
        if (ManualRespectsEnable = true and EnableJumpScare = false):
            return

        Blue := LastBlue
        Red  := LastRed

        if (ManualIgnoresGates = false):
            if (DisableDuringIntermission = true and IntermissionActive = true):
                return
            if (OnlyWhenBothPresent = true):
                var both:logic = false
                if (B := Blue?):
                    if (player[B]):
                        if (R := Red?):
                            if (player[R]):
                                set both = true
                if (both = false):
                    return

        if (ManualCountsTowardsLimits = true):
            var w:int = Window
            var p:int = PosInWindow
            DoScare(Blue, Red, w, p)
        else:
            DoScareManual(Blue, Red)

    OnTotalElims(Total:int, Blue:?agent, Red:?agent):void =
        set LastBlue = Blue
        set LastRed  = Red

        if (EnableJumpScare = false):
            return
        if (Total <= 0):
            return

        if (MaxScaresPerMatch > 0):
            if (TotalScares >= MaxScaresPerMatch):
                set PrevWasScare = false
                return

        if (DisableDuringIntermission = true and IntermissionActive = true):
            set PrevWasScare = false
            return

        if (OnlyWhenBothPresent = true):
            var both2:logic = false
            if (B2 := Blue?):
                if (player[B2]):
                    if (R2 := Red?):
                        if (player[R2]):
                            set both2 = true
            if (both2 = false):
                set PrevWasScare = false
                return

        mw := MaxWithin
        if (mw <= 0):
            set PrevWasScare = false
            return

        if (PosInWindow <= 0):
            set PosInWindow = 1
        else:
            set PosInWindow = PosInWindow + 1
            if (PosInWindow > mw):
                prev := TriggersThisWindow
                AwardQuietPreviousWindowIfAny(prev, Blue, Red)
                set Window = Window + 1
                set CurrentWindow = Window
                set TriggersThisWindow = 0
                set PosInWindow = 1

        if (CurrentWindow <= 0):
            set CurrentWindow = Window

        if (TriggersThisWindow >= MaxTriggersPerWindow):
            set PrevWasScare = false
            return

        var should_fire:logic = ShouldTrigger(Window, PosInWindow)
        if (should_fire = false):
            set PrevWasScare = false
            return

        set TriggersThisWindow = TriggersThisWindow + 1
        DoScare(Blue, Red, Window, PosInWindow)
