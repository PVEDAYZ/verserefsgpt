using { /Verse.org }
using { /Verse.org/Random }
using { /Fortnite.com/AI }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

# code made by remu1337 join discord.gg/uefndream for support 
# discord.gg/uefndream give us your weapon power suggestion!

hit_sound_DREAM := class(creative_device):

    @editable
    PlayerSpawner : []player_spawner_device = array{}

    @editable
    AudioWeapons : []conditional_button_device = array{}

    @editable
    AudioPlayers : []audio_player_device = array{}

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
        then:
            for (Weapon : AudioWeapons):
                if (Weapon.IsHoldingItem[InstigatorAgent]):
                    
                    if (AudioPlayers.Length > 0):
                        RandomIndex := GetRandomInt(0, AudioPlayers.Length - 1)
                        if (RandomAudioPlayer := AudioPlayers[RandomIndex]):
                            RandomAudioPlayer.Play(InstigatorAgent)
                    return  