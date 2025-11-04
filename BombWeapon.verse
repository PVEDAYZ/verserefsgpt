using { /Verse.org }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation }
using { /Fortnite.com/Game }

# code made by remu1337 join discord.gg/uefndream for support 
# discord.gg/uefndream give us your weapon power suggestion!

BOMB_weapon_dream := class(creative_device):
    @editable
    PlayerSpawner : []player_spawner_device = array{} #ALL PLAYER SPAWNERA
    @editable
    BomberWeapon : conditional_button_device = conditional_button_device{} #CONDITIONAL BUTTON WITH THE SPECIFIC WEAPON
    @editable
    ChairsS : []chair_device = array{}  # ADD AS MANY CHAIR DEVICES AS PLAYERS ON MAP
    @editable
    ExplosiveDevicesS : []explosive_device = array{} # ADD AS MANY EXPLOSIVE DEVICES AS PLAYERS ON MAP
    @editable
    SeatDuration : float = 3.0 # HOW LONG SHOULD THE PLAYER SIT
    @editable
    HudSeatTime : hud_message_device = hud_message_device{} # HUD TO SHOW THE SEAT TIME
    @editable
    HUDDelay : hud_message_device = hud_message_device{} # HUD HOW MUCH DELAY LEFT
    @editable
    DropProp : creative_prop_asset = DefaultCreativePropAsset # the prop you want
    @editable
    DropHeight : float = 500.0 # HEIGHT ABOVE THE PLAYER
    @editable
    DropDuration : float = 1.0 # HOW LONG THE PROP SHOULD FALL
    @editable
    UsageDelay : float = 5.0 # DELAY BETWEEN FUNCTION USE
    @editable
    ExplosionAudio : audio_player_device = audio_player_device{}
    @editable
    AudioPreDelay : float = 0.2 # SECONDS BEFORE THE EXPLOSION
    @editable
    PropDamage : float = 50.0 # HOW MUCH DAMAGE SHOULD THE EXPLOSION MAKE

    var IsOnCooldown : logic = false
    var CurrentProp : ?creative_prop = false
    var ChairAssignments : [agent]?chair_device = map{}
    var ExplosiveAssignments : [agent]?explosive_device = map{}

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
            InstigatorAgent := InstigatorFC.GetAgent[]
            DamagedFC := fort_character[Result.Target]
            DamagedAgent := DamagedFC.GetAgent[]
        then:
            if (BomberWeapon.IsHoldingItem[InstigatorAgent] and IsOnCooldown = false):
                spawn{SeatPlayerWithChair(DamagedAgent, InstigatorAgent)}

    GetCountdownMessage<localizes>(TimeLeft : float) : message = "Seat Time: {TimeLeft} seconds"
    GetDelayMessage<localizes>(TimeLeft : float) : message = "Delay: {TimeLeft} seconds"

    AnimatePropDropAndExplode(
        Prop: creative_prop, 
        StartPos: vector3, 
        EndPos: vector3, 
        Explosive: explosive_device,
        PlayerLocation: vector3,
        PlayerRotation: rotation,
        DamagedAgent: agent
    )<suspends>:void =
        var CurrentTime: float = 0.0
        loop:
            if (CurrentTime >= DropDuration):
                break
            Alpha := CurrentTime / DropDuration
            CurrentPos := Lerp(StartPos, EndPos, Alpha)
            if (Prop.TeleportTo[CurrentPos, PlayerRotation]) {}
            Sleep(0.016)
            set CurrentTime += 0.016
        if (Prop.TeleportTo[EndPos, PlayerRotation]) {}
        if (DamagedFC := DamagedAgent.GetFortCharacter[]):
            DamagedFC.Damage(PropDamage)
        if (Explosive.TeleportTo[PlayerLocation, PlayerRotation]):
            ExplosionAudio.Play(DamagedAgent)
            Sleep(AudioPreDelay)
            Explosive.Explode(DamagedAgent)
            Explosive.Reset()

    SeatPlayerWithChair(DamagedAgent: agent, InstigatorAgent: agent)<suspends>: void =
        if (DamagedFC := DamagedAgent.GetFortCharacter[]):
            var AssignedChair : ?chair_device = false
            var AssignedExplosive : ?explosive_device = false

            for (Chair : ChairsS):
                if (not AssignedChair?):
                    set AssignedChair = option{Chair}

            for (Explosive : ExplosiveDevicesS):
                if (not AssignedExplosive?):
                    set AssignedExplosive = option{Explosive}

            if (Chair := AssignedChair?):
                PlayerLocation := DamagedFC.GetTransform().Translation
                PlayerRotation := DamagedFC.GetTransform().Rotation
                
                ChairOffset := vector3{X := 0.0, Y := 0.0, Z := -50.0}
                CorrectedChairPosition := PlayerLocation + ChairOffset
                if (Chair.TeleportTo[CorrectedChairPosition, PlayerRotation]):

                    if (OldProp := CurrentProp?):
                        OldProp.Dispose()
                    PropSpawnLocation := PlayerLocation + vector3{X := 0.0, Y := 0.0, Z := DropHeight}
                    PropResult := SpawnProp(DropProp, PropSpawnLocation, PlayerRotation)
                    if (Prop := PropResult(0)?):
                        set CurrentProp = option{Prop}
                        if (Explosive := AssignedExplosive?):
                            spawn{AnimatePropDropAndExplode(Prop, PropSpawnLocation, PlayerLocation, Explosive, PlayerLocation, PlayerRotation, DamagedAgent)}
                        Chair.Seat(DamagedAgent)
                        var TimeLeft : float = SeatDuration
                        loop:
                            if (TimeLeft <= 0.0):
                                break
                            HudSeatTime.Show(DamagedAgent, GetCountdownMessage(TimeLeft))
                            Sleep(1.0)
                            set TimeLeft -= 1.0
                        Prop.Dispose()
                        set CurrentProp = false
                        Chair.Eject(DamagedAgent)
                        HudSeatTime.Hide(DamagedAgent)

                        set IsOnCooldown = true
                        var DelayTimeLeft : float = UsageDelay
                        loop:
                            if (DelayTimeLeft <= 0.0):
                                break
                            if (BomberWeapon.IsHoldingItem[InstigatorAgent]):
                                HUDDelay.Show(InstigatorAgent, GetDelayMessage(DelayTimeLeft))
                            Sleep(1.0)
                            set DelayTimeLeft -= 1.0
                        HUDDelay.Hide(InstigatorAgent)
                        Sleep(UsageDelay)
                        set IsOnCooldown = false