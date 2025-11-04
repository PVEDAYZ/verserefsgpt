
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
AttachPlayer := class(creative_device):

    @editable Chair : chair_device = chair_device{}
    @editable RemoteManager : signal_remote_manager_device = signal_remote_manager_device{}

    OnBegin<override>()<suspends>:void=
        RemoteManager.PrimarySignalEvent.Subscribe(AttachToPlayer)
        RemoteManager.SecondarySignalEvent.Subscribe(ThrowPlayer)

    ThrowPlayer(Agent : agent) : void=
        Chair.Eject()

    AttachToPlayer(Agent : agent) : void=
        spawn:
            AttachToPlayerNew(Agent)

        for(Player : GetPlayspace().GetPlayers()):
            if(not Player = Agent):
                Chair.Seat(Player)

    AttachToPlayerNew(Agent : agent)<suspends> : void=
        if(FC := Agent.GetFortCharacter[]):
            loop:
                Sleep(0.0)
                PlayerPos := FC.GetTransform().Translation
                PlayerRot := FC.GetTransform().Rotation
                spawn{Chair.MoveTo(PlayerPos + vector3{Z:= 10.0},PlayerRot, 0.1)}