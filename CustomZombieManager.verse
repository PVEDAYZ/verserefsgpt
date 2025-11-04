
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
CustomZombieManager := class(creative_device):

    @editable GameManager : game_manager = game_manager{}
    @editable ZombieSpawners : []creature_spawner_device = array{}
    @editable CustomProp1 : creative_prop_asset = DefaultCreativePropAsset
    @editable CustomProp2 : creative_prop_asset = DefaultCreativePropAsset
    @editable MoneyGranted : int = 0

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for(Spawner : ZombieSpawners):
            Spawner.SpawnedEvent.Subscribe(OnSpawned)
            Spawner.EliminatedEvent.Subscribe(OnEliminated)

    OnEliminated(Result : device_ai_interaction_result) : void=
        if(Agent := Result.Source?):
            GameManager.AddMoney(MoneyGranted, Agent)
            GameManager.ShowMoney(MoneyGranted, Agent)

    OnSpawned(ZombieAgent : agent) : void=
        if(FC := ZombieAgent.GetFortCharacter[]):
            FC.Hide()
            if:
                NewProp := SpawnProp(CustomProp1, FC.GetTransform().Translation, FC.GetTransform().Rotation)(0)?
                NewProp2 := SpawnProp(CustomProp2, FC.GetTransform().Translation, FC.GetTransform().Rotation)(0)?
            then: 
                spawn:
                    TrackZombie(NewProp, NewProp2, ZombieAgent)

    TrackZombie(Prop : creative_prop, Prop2 : creative_prop, Agent : agent)<suspends> : void=
        if(FC := Agent.GetFortCharacter[]):
            race: 
                block: 
                    FC.EliminatedEvent().Await()
                    Prop.Dispose()
                    Prop2.Dispose()
                    return

                loop: 
                    Sleep(0.0)
                    ZombiePos := FC.GetTransform().Translation
                    ZombieRot := FC.GetTransform().Rotation
                    ClosestPlayer := GetClosestPlayer(FC)
                    NewDistance := Distance(ClosestPlayer.GetTransform().Translation, ZombiePos)
                    if(NewDistance < 200.0):
                        Prop2.Show()
                        Prop.Hide()
                    else:
                        Prop.Show()
                        Prop2.Hide()
                    spawn{Prop.MoveTo(ZombiePos, ZombieRot, 0.1)}
                    spawn{Prop2.MoveTo(ZombiePos, ZombieRot, 0.1)}


    GetClosestPlayer(FC : fort_character) : fort_character=
        ZombiePos := FC.GetTransform().Translation
        var ClosestPlayer : ?fort_character = false
        var ClosestDist : float = 999999.0
        for(Player : GetPlayspace().GetPlayers(), PlayerFC := Player.GetFortCharacter[]):
            NewDistance := Distance(PlayerFC.GetTransform().Translation, ZombiePos)
            if(NewDistance < ClosestDist):
                set ClosestPlayer = option{PlayerFC}
                set ClosestDist = NewDistance
        if(NewClosestPlayer :=  ClosestPlayer?):
            return NewClosestPlayer

        return FC