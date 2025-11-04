
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
CrateManager := class(creative_device):

    @editable CrateProp : creative_prop = creative_prop{}
    @editable PropManip : prop_manipulator_device = prop_manipulator_device{}
    @editable RewardTrigger : trigger_device = trigger_device{}
    @editable VFXSpawner : vfx_spawner_device = vfx_spawner_device{}

    var IsAnimating : logic = false

    OnBegin<override>()<suspends>:void=
        PropManip.DamagedEvent.Subscribe(OnHit)

    OnHit(Agent:agent) : void=
        RewardTrigger.Trigger(Agent)
        spawn{PlayAnimation()}
        spawn{PlayVFX()}

    PlayAnimation()<suspends> : void=
        if(not IsAnimating?):
            set IsAnimating = true
            CratePos := CrateProp.GetTransform().Translation
            CrateRot := CrateProp.GetTransform().Rotation
            CrateProp.MoveTo(transform{Translation := CratePos, Rotation := CrateRot, Scale := vector3{X:= 0.8, Y:= 0.8, Z:=0.8}}, 0.2)
            CrateProp.MoveTo(transform{Translation := CratePos, Rotation := CrateRot, Scale := vector3{X:= 1.0, Y:= 1.0, Z:=1.0}}, 0.2)
            set IsAnimating = false

    PlayVFX()<suspends> : void=
        VFXSpawner.Restart()
        Sleep(0.1)
        VFXSpawner.Disable()