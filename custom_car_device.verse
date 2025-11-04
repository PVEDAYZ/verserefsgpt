
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Vehicles }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }

custom_car := class<concrete>:

    @editable CarButton : button_device = button_device{}
    @editable CarSpawner : vehicle_spawner_sports_car_device = vehicle_spawner_sports_car_device{}
    @editable CarVFX : visual_effect_powerup_device = visual_effect_powerup_device{}

    var MaybeCurrentVehicle : ?fort_vehicle = false
    var EmptyVFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    var MaybeAgent : ?agent = false

    # Runs when the device is started in a running game
    Init(Empty : visual_effect_powerup_device):void=
        CarButton.InteractedWithEvent.Subscribe(OnButtonInteracted)
        CarSpawner.AgentExitsVehicleEvent.Subscribe(OnCarExited)
        CarSpawner.SpawnedEvent.Subscribe(OnCarSpawned)
        CarSpawner.Disable()
        set EmptyVFX = Empty

    OnButtonInteracted(Agent : agent):void=
        CarButton.Disable()
        var ButtonLoc : vector3 = CarButton.GetTransform().Translation
        set ButtonLoc.Z -= 5000.0
        var ButtonRotation : rotation = CarButton.GetTransform().Rotation
        if(CarButton.TeleportTo[ButtonLoc, ButtonRotation]){}
        CarVFX.Pickup(Agent)
        set MaybeAgent = option{Agent}

        CarSpawner.Enable()
        spawn{AsyncCarHandle(Agent, true, 0.1)}

    AsyncCarHandle(Agent : agent, bCarSpawned : logic, Delay : float)<suspends>:void=
        Sleep(Delay)
        if(bCarSpawned = true):
            CarSpawner.AssignDriver(Agent)
        else:
            CarButton.Enable()
            if(Player := player[Agent] ):
                if(Player.IsActive[]):
                    var ButtonLoc : vector3 = CarButton.GetTransform().Translation
                    set ButtonLoc.Z += 5000.0
                    var ButtonRotation : rotation = CarButton.GetTransform().Rotation
                    if (CarButton.TeleportTo[ButtonLoc, ButtonRotation]){}
                    EmptyVFX.Pickup(Agent)

    OnCarExited(Agent : agent):void=
        if(CurAgent := MaybeAgent?):
            if(Agent = CurAgent):
                set MaybeAgent = false
                set MaybeCurrentVehicle = false
                CarSpawner.Disable()
                spawn{AsyncCarHandle(Agent, false, 0.25)}
    
    OnCarSpawned(FortVehicle : fort_vehicle):void=
        set MaybeCurrentVehicle = option{FortVehicle}



custom_car_device := class(creative_device):

    @editable Cars : []custom_car = array{}
    @editable EmptyVFX : visual_effect_powerup_device = visual_effect_powerup_device{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for(Car : Cars):
            Car.Init(EmptyVFX)
