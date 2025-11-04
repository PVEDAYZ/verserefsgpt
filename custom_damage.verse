using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }

damage_device := class(creative_device):

    @editable
    WeaponButtons : []conditional_button_device = array{}

    @editable
    DamageTest : damage_amplifier_powerup_device = damage_amplifier_powerup_device{}

    @editable
    VFX1 : visual_effect_powerup_device = visual_effect_powerup_device{}

    @editable
    DamageMultiplier : float = 0.0

    var ActivePlayers : [player]logic = map{}

    WeaponButtons_Func(Player : player)<suspends>:void=
        if (FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
            loop:
                Sleep(0.5)
                var AnyButtonHeld : logic = false

                for (Button : WeaponButtons):
                    if (Button.IsHoldingItem[Player]):
                        set AnyButtonHeld = true
                        if (not ActivePlayers[Player]?):
                            if (set ActivePlayers[Player] = true):
                                DamageTest.Spawn()
                                VFX1.Spawn()
                                VFX1.Pickup(Agent)
                                DamageTest.Pickup(Agent)
                                DamageTest.SetMagnitude(DamageMultiplier)
                                Print("Damage boost applied")

                if (AnyButtonHeld = false):
                    if (ActivePlayers[Player]?):
                        if (set ActivePlayers[Player] = false):
                            var OtherPlayersActive : logic = false
                            for (OtherPlayer -> IsActive : ActivePlayers):
                                if (IsActive = true):
                                    set OtherPlayersActive = true
                            if (OtherPlayersActive = false):
                                DamageTest.SetMagnitude(1.0)
                                DamageTest.Despawn()
                                VFX1.Despawn()
                                Print("Damage boost removed")

    OnBegin<override>()<suspends>:void =
        for (Player : GetPlayspace().GetPlayers()):
            spawn:
                WeaponButtons_Func(Player)