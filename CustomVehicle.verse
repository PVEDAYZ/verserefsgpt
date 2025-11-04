<#
====================================================================================================
Copyright (c) 2024 MapAcademy. All rights reserved.

 

This software and its associated documentation files (the "Software") are the

proprietary property of MapAcademy and are protected by copyright law.

 

The Software is provided to you under the terms of the MapAcademy End User

License Agreement (the "License"). You may use, copy, distribute, and modify

the Software solely in accordance with the terms of the License.

 

BY USING THE SOFTWARE, YOU AGREE TO BE BOUND BY THE TERMS OF THE LICENSE.

IF YOU DO NOT AGREE TO THE TERMS OF THE LICENSE, DO NOT USE THE SOFTWARE.

 

The Software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND,

either express or implied, including without limitation any warranties of

MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, or NON-INFRINGEMENT.

For more details, please refer to the MapAcademy End User License Agreement.
====================================================================================================
#>
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Vehicles }

CustomVehicle := class(creative_device):
    @editable CustomVehicleVehicle : vehicle_spawner_sportbike_device = vehicle_spawner_sportbike_device{} #Can be any vehicle (may have to change to better fit custom vehicle)
    @editable VehicleVFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable VehicleTrigger : trigger_device = trigger_device{}
    @editable VehicleSound : audio_player_device = audio_player_device{}


    var IsVehiclePiloted : logic = false
    var SleepTime : float = 5.0
    


    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable VehicleSpawnTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}





    OnBegin<override>()<suspends>:void=
        Sleep(3.0)
        VehicleTrigger.Trigger()
        VehicleSpawnTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        VehicleSpawnTimer.SuccessEvent.Subscribe(ResetCooldown)

        CustomVehicleVehicle.AgentEntersVehicleEvent.Subscribe(HandleEntered)
        CustomVehicleVehicle.AgentExitsVehicleEvent.Subscribe(HandleExit)


    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false


    HandleEntered(Agent : agent) : void =
        VehicleVFX.Pickup(Agent)
        VehicleSound.Play(Agent)


    HandleExit( Agent : agent ) : void =
        VehicleTrigger.Trigger(Agent)
        VehicleSound.Stop(Agent)




    SpawnVehicle(Agent:agent) <suspends> : void=
        if(MaybeCooldown = false):
            VehicleSpawnTimer.Start(Agent)
            set MaybeCooldown=true
            CustomVehicleVehicle.RespawnVehicle()
            if(Player:=player[Agent],FC:=Player.GetFortCharacter[]):
                PlayerLocation := FC.GetTransform().Translation
                if(PlayerLocation.Y  >= 2000.0):
                    NewPlayerLocation := PlayerLocation - vector3{Y:= 400.0}
                    if(CustomVehicleVehicle.TeleportTo[NewPlayerLocation,IdentityRotation()]){}
                else:
                    if(CustomVehicleVehicle.TeleportTo[PlayerLocation- vector3{Y:= 200.0},IdentityRotation()]){}
                Sleep(1.0)
                CustomVehicleVehicle.AssignDriver(Agent)
        else:
            CooldownMSG.Show(Agent)