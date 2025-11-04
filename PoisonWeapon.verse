using { /Verse.org }
using { /Fortnite.com/AI }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }


# code made by remu1337 join discord.gg/uefndream for support 
# discord.gg/uefndream give us your weapon power suggestion!

PosionWeapon_Dream := class(creative_device):

    @editable PlayerSpawner : []player_spawner_device = array{}
    @editable PosionWeapon : conditional_button_device = conditional_button_device{}
    @editable HealthPowerup : health_powerup_device = health_powerup_device{}

    @editable
    poisonedInterval : float = 1.0 

    @editable
    poisonedDuration : float = 5.0  

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
            if(PosionWeapon.IsHoldingItem[InstigatorAgent]):
             
                spawn{ApplyPoisonEffect(DamagedAgent)}


    ApplyPoisonEffect(Target: agent)<suspends>: void=
        var ElapsedTime : float = 0.0
        
  
        loop:
            if (ElapsedTime >= poisonedDuration):
                break

      
            HealthPowerup.Pickup(Target)

            Sleep(poisonedInterval)
            set ElapsedTime += poisonedInterval