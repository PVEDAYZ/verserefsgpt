using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /Fortnite.com/Game }

# code made by remu1337 join discord.gg/uefndream for support 

arena_config := class<concrete>:
    @editable
    EntryTeleporter1 : teleporter_device = teleporter_device{}
    
    @editable
    EntryTeleporter2 : teleporter_device = teleporter_device{}
    
    @editable
    PlayerCounter : player_counter_device = player_counter_device{}

    var Locked : logic = false
    var PlayersInArena : []agent = array{}
    var ActiveSubscriptions : []cancelable = array{} 

dream_1v1_manager := class(creative_device):
    @editable
    Arenas : []arena_config = array{}

    @editable
    ExitTeleporter : teleporter_device = teleporter_device{}

    @editable
    WinHUDMessage : hud_message_device = hud_message_device{}

    @editable
    FightHUDMessage : hud_message_device = hud_message_device{}

    GetWinMessage<localizes>(WinnerPlayer : player) : message = "{WinnerPlayer}"

    GetFightMessage<localizes>(Opponent : player) : message = "{Opponent}"

    OnBegin<override>()<suspends> : void =
        for (Arena : Arenas):
            Arena.PlayerCounter.CountedEvent.Subscribe(HandleArenaPlayerCounted)
            Arena.PlayerCounter.RemovedEvent.Subscribe(HandleArenaPlayerRemoved)

    HandleArenaPlayerCounted(Agent : agent) : void =
        for (Arena : Arenas):
            if (Arena.PlayerCounter.IsCounted[Agent]):
                OnArenaPlayerCounted(Agent, Arena)

    HandleArenaPlayerRemoved(Agent : agent) : void =
        for (Arena : Arenas):
            if (not Arena.PlayerCounter.IsCounted[Agent]):
                OnArenaPlayerRemoved(Agent, Arena)

    OnArenaPlayerCounted(Agent : agent, Arena : arena_config) : void =
        if (Arena.Locked = false):
            set Arena.PlayersInArena += array{Agent}
            if (Arena.PlayersInArena.Length = 2):
                StartFight(Arena)

    OnArenaPlayerRemoved(Agent : agent, Arena : arena_config) : void =
        if (Arena.Locked = false):
            var NewArray : []agent = array{}
            for (Player : Arena.PlayersInArena, Player <> Agent):
                set NewArray += array{Player}
            set Arena.PlayersInArena = NewArray

    StartFight(Arena : arena_config) : void =
        set Arena.Locked = true
        if (Arena.PlayersInArena.Length = 2):
            if (Player1 := Arena.PlayersInArena[0], Player2 := Arena.PlayersInArena[1]):
                Arena.EntryTeleporter1.Teleport(Player1)
                Arena.EntryTeleporter2.Teleport(Player2)
                if (Character1 := Player1.GetFortCharacter[]):
                    Subscription1 := Character1.EliminatedEvent().Subscribe(OnPlayerEliminated)
                    set Arena.ActiveSubscriptions += array{Subscription1}
                if (Character2 := Player2.GetFortCharacter[]):
                    Subscription2 := Character2.EliminatedEvent().Subscribe(OnPlayerEliminated)
                    set Arena.ActiveSubscriptions += array{Subscription2}
                ShowFightMessage(Player1, Player2)

    OnPlayerEliminated(Result : elimination_result) : void =
        if (EliminatedChar := Result.EliminatedCharacter, EliminatedAgent := EliminatedChar.GetAgent[]):
            for (Arena : Arenas):
                if (Arena.Locked = true):
                    if (Winner := Result.EliminatingCharacter?, WinnerAgent := Winner.GetAgent[]):
                        ShowWinMessage(WinnerAgent, Arena)
                        TeleportPlayersBack(Arena) 
                        for (Subscription : Arena.ActiveSubscriptions):
                            Subscription.Cancel()
                        set Arena.ActiveSubscriptions = array{}
                        set Arena.Locked = false
                        set Arena.PlayersInArena = array{}

    ShowWinMessage(Winner : agent, Arena : arena_config) : void =
        if (WinnerPlayer := player[Winner]):
            WinMessage := GetWinMessage(WinnerPlayer)
            for (Player : Arena.PlayersInArena):
                if (PlayerAgent := player[Player]):
                    WinHUDMessage.Show(PlayerAgent, WinMessage)

    ShowFightMessage(Player1 : agent, Player2 : agent) : void =
        if (Player1Player := player[Player1], Player2Player := player[Player2]):
            FightHUDMessage.Show(Player1Player, GetFightMessage(Player2Player))
            FightHUDMessage.Show(Player2Player, GetFightMessage(Player1Player))

    TeleportPlayersBack(Arena : arena_config) : void =
        for (Player : Arena.PlayersInArena):
            ExitTeleporter.Teleport(Player)