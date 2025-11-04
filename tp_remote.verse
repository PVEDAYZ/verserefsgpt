using { /Verse.org }
using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

# code made by remu1337 join discord.gg/uefndream for support 
# discord.gg/uefndream give us your weapon power suggestion!

TP_REMOTE_DREAM := class(creative_device):

    @editable
    RemoteManager: signal_remote_manager_device = signal_remote_manager_device{}

    @editable
    MessageDevice: hud_message_device = hud_message_device{}

    @editable
    CooldownDuration: float = 10.0

    @editable
    MaxTeleportDistance: float = 1000000000.0

    var CooldownActive: logic = false

    OnBegin<override>()<suspends>:void=
        RemoteManager.PrimarySignalEvent.Subscribe(OnTeleportRequested)

    OnTeleportRequested(Agent:agent):void=
        if (CooldownActive = false):
            spawn:
                ExecuteTeleport(Agent)

    ExecuteTeleport(Agent:agent)<suspends>:void=
        Players := GetPlayspace().GetPlayers()

        if (SourceCharacter := Agent.GetFortCharacter[]):
            ViewLocation := SourceCharacter.GetViewLocation()

            var NearestCharacter : ?fort_character = false
            var ShortestDistance: float = MaxTeleportDistance

            for (Player : Players):
                if (Character := fort_character[Player.GetFortCharacter[]]):
                    if (Character <> SourceCharacter):
                        CharacterLocation := Character.GetTransform().Translation
                        CurrentDistance := Distance(ViewLocation, CharacterLocation)
                        if (CurrentDistance < ShortestDistance):
                            set NearestCharacter = option{Character}
                            set ShortestDistance = CurrentDistance

            if (TargetCharacter := NearestCharacter?):
                TargetTransform := TargetCharacter.GetTransform()
                if (SourceCharacter.TeleportTo[TargetTransform.Translation, TargetTransform.Rotation]):
                    MessageDevice.SetText(SuccessTeleportMessage())
                    MessageDevice.Show(Agent)
                    set CooldownActive = true
                    spawn{ResetCooldown()}
            else:
                MessageDevice.SetText(EmptyTeleportMessage())
                MessageDevice.Show(Agent)

    ResetCooldown()<suspends>:void=
        Sleep(CooldownDuration)
        set CooldownActive = false

EmptyTeleportMessage<localizes>():message = "No player found!"

SuccessTeleportMessage<localizes>():message = "Teleported to nearest player!"