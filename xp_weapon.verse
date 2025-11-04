using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }

# code made by remu1337 join discord.gg/uefndream for support 
# discord.gg/uefndream give us your weapon power suggestion!

XP_GUN_DREAM := class(creative_device):
 
    @editable
    PlayerSpawner : []player_spawner_device = array{}
 
    @editable
    XPWeapon : conditional_button_device = conditional_button_device{}
 
    @editable
    AccoladeAward : accolades_device = accolades_device{}
 
    OnBegin<override>()<suspends>: void =
        for (Spawner : PlayerSpawner):
            Spawner.SpawnedEvent.Subscribe(OnPlayerJoins)
 
    OnPlayerJoins(Agent: agent): void =
        if (FC := Agent.GetFortCharacter[]):
            FC.DamagedEvent().Subscribe(OnPlayerDamaged)
            FC.DamagedShieldEvent().Subscribe(OnPlayerDamaged)
 
    OnPlayerDamaged(Result: damage_result): void =
        if:
            Instigator := Result.Instigator?
            InstigatorFC := fort_character[Instigator]
            InstigatorAgent := Instigator.GetInstigatorAgent[]
            XPWeapon.IsHoldingItem[InstigatorAgent]
        then:
            AccoladeAward.Award(InstigatorAgent)
