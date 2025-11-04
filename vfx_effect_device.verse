using { /Verse.org }
using { /Fortnite.com/AI }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

vfx_effect_weapon := class(creative_device):

    @editable PlayerSpawner : []player_spawner_device = array{}
    @editable VFX_WEAPONS : []conditional_button_device = array{}
    @editable VFX_EFFECT : vfx_spawner_device = vfx_spawner_device{}

    OnBegin<override>()<suspends>: void=
        for(Spawner : PlayerSpawner):
            Spawner.SpawnedEvent.Subscribe(OnPlayerJoins)

    OnPlayerJoins(Agent: agent): void=
        if(FC := Agent.GetFortCharacter[]):
            FC.DamagedEvent().Subscribe(OnPlayerDamaged)
            FC.DamagedShieldEvent().Subscribe(OnPlayerDamaged)

    OnPlayerDamaged(Result: damage_result): void=
        if:
            Instigator := Result.Instigator?
            InstigatorFC := fort_character[Instigator]
            InstigatorAgent := Instigator.GetInstigatorAgent[]
            DamagedFC := fort_character[Result.Target]
            DamagedAgent := DamagedFC.GetAgent[]
        then:
            for(Weapon : VFX_WEAPONS):
                if(Weapon.IsHoldingItem[InstigatorAgent]):
                    if(VFX_EFFECT.TeleportTo[DamagedFC.GetTransform().Translation, DamagedFC.GetTransform().Rotation]):
                        VFX_EFFECT.Restart()