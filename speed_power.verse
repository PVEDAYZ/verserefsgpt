using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

CustomPlayer := class():

    var UniqueID:int = 0
    MyAgentObj:agent

    var IsFast:logic = false

FastPowerUp := class(creative_device):

    var PlayersMap:[player]CustomPlayer = map{}

    @editable
    PlayerSpawners : []player_spawner_device = array{}

    @editable
    Speed_Item:conditional_button_device = conditional_button_device{}

    @editable
    MM_Normal:movement_modulator_device = movement_modulator_device{}

    @editable
    MM_Fast:movement_modulator_device = movement_modulator_device{}

    OnBegin<override>()<suspends>:void=
        # Subscribe to spawn events for all spawners in the array
        for (Spawner : PlayerSpawners):
            Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)
        spawn:
            CheckForItem()

    CheckForItem()<suspends>:void=
        loop:
            for(Player:PlayersMap):
                if(Speed_Item.IsHoldingItem[Player.MyAgentObj]):
                    if(Player.IsFast = false):
                        MM_Fast.Activate(Player.MyAgentObj)
                        set Player.IsFast = true
                else:
                    if(Player.IsFast = true):
                        MM_Normal.Activate(Player.MyAgentObj)
                        set Player.IsFast = false
            Sleep(1.0)

    OnPlayerSpawned(Agent:agent):void=
        if (PlayerObj := player[Agent]):
            if (not PlayersMap[PlayerObj]):
                NewCustomPlayer := CustomPlayer{MyAgentObj := Agent}
                if (set PlayersMap[PlayerObj] = NewCustomPlayer) {}

    OnPlayerRemoved(Player:player):void=
        if (OldCustomPlayer := PlayersMap[Player]):
            var TempAllPlayersMap:[player]CustomPlayer = map{}
            for (Key -> Value : PlayersMap, Key <> Player):
                set TempAllPlayersMap = ConcatenateMaps(TempAllPlayersMap, map{Key => Value})
            set PlayersMap = TempAllPlayersMap