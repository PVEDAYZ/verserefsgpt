using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/UI }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }

C_Stats := class<unique>():

    Player : player
    var Kill : float = 0.0
    var Death : float = 0.0
    var KD : float = 0.0

    UIText<localizes>(pValue : float ) : message = "{pValue}"

    var TextKill<private> : text_block = text_block{DefaultTextColor:=White, DefaultJustification:=text_justification.Right}
    var TextDeath<private> : text_block = text_block{DefaultTextColor:=White, DefaultJustification:=text_justification.Right}
    var TextKD<private> : text_block = text_block{DefaultTextColor:=White, DefaultJustification:=text_justification.Right}

    GetKill():float=
        return Kill

    GetDeath():float=
        return Death

    SetKill(NewKill:float):void=
        set Kill = NewKill
        Print("C_Stats: SetKill -> {Kill}")

    SetDeath(NewDeath:float):void=
        set Death = NewDeath
        Print("C_Stats: SetDeath -> {Death}")

    GetKD():float=
        return KD

    SetKD(NewKD:float):void=
        set KD = NewKD
        Print("C_Stats: SetKD -> {KD}")

    SetUIPlayerKill(pKill: float) : void=
        TextKill.SetText(UIText(pKill))
        Print("C_Stats: UI Kill updated -> {pKill}")

    SetUIPlayerDeath(pDeath: float) : void=
        TextDeath.SetText(UIText(pDeath))
        Print("C_Stats: UI Death updated -> {pDeath}")

    SetUIPlayerKD(pKD: float) : void=
        TextKD.SetText(UIText(pKD))
        Print("C_Stats: UI KD updated -> {pKD}")

    Init():void=
        Print("C_Stats: Init called.")
        if(Agent:=agent[Player]):
            Print("C_Stats: Player agent valid. Initializing UI.")
            InitUI()
        else:
            Print("C_Stats: Player agent invalid; UI not initialized.")

    InitUI<private>() : void =
        Print("C_Stats: Building HUD canvas.")
        NewCanvas : canvas  = canvas:
            Slots := array:
                canvas_slot:
                    Widget:= TextKill
                    Anchors:= anchors{Minimum:= vector2{X:= 0.0, Y := 0.5}, Maximum := vector2{X:= 0.0, Y:= 0.5}}
                    Offsets:= margin{Top:= 137.5, Left:= 140.0, Right:= 68.0, Bottom:= 26.0}
                    Alignment:= vector2{X:= 0.0 , Y := 0.0}
                    SizeToContent:= false
                    ZOrder:=1
                canvas_slot:
                    Widget:= texture_block:
                        DefaultImage:=C_UI.KillHUD
                    Anchors:= anchors{Minimum:= vector2{X:= 0.0, Y := 0.5}, Maximum := vector2{X:= 0.0, Y:= 0.5}}
                    Offsets:= margin{Top:= 135.0, Left:= 52.0, Right:= 175.0, Bottom:= 45.0}
                    Alignment:= vector2{X:= 0.0 , Y := 0.0}
                    SizeToContent:= false
                    ZOrder:=0

                canvas_slot:
                    Widget:= TextDeath
                    Anchors:= anchors{Minimum:= vector2{X:= 0.0, Y := 0.5}, Maximum := vector2{X:= 0.0, Y:= 0.5}}
                    Offsets:= margin{Top:= 198.0, Left:= 140.0, Right:= 68.0, Bottom:= 26.0}
                    Alignment:= vector2{X:= 0.0 , Y := 0.0}
                    SizeToContent:= false
                canvas_slot:
                    Widget:= texture_block:
                        DefaultImage:=C_UI.DeathHUD
                    Anchors:= anchors{Minimum:= vector2{X:= 0.0, Y := 0.5}, Maximum := vector2{X:= 0.0, Y:= 0.5}}
                    Offsets:= margin{Top:= 196.0, Left:= 52.0, Right:= 175.0, Bottom:= 45.0}
                    Alignment:= vector2{X:= 0.0 , Y := 0.0}
                    SizeToContent:= false

                canvas_slot:
                    Widget:= TextKD
                    Anchors:= anchors{Minimum:= vector2{X:= 0.0, Y := 0.5}, Maximum := vector2{X:= 0.0, Y:= 0.5}}
                    Offsets:= margin{Top:= 263.5, Left:= 140.0, Right:= 68.0, Bottom:= 26.0}
                    Alignment:= vector2{X:= 0.0 , Y := 0.0}
                    SizeToContent:= false
                canvas_slot:
                    Widget:= texture_block:
                        DefaultImage:=C_UI.KDHud
                    Anchors:= anchors{Minimum:= vector2{X:= 0.0, Y := 0.5}, Maximum := vector2{X:= 0.0, Y:= 0.5}}
                    Offsets:= margin{Top:= 260.0, Left:= 52.0, Right:= 175.0, Bottom:= 45.0}
                    Alignment:= vector2{X:= 0.0 , Y := 0.0}
                    SizeToContent:= false

        if(lPlayerUI:= GetPlayerUI[Player]):
            lPlayerUI.AddWidget(NewCanvas)
            Print("C_Stats: HUD canvas added to player UI.")
        else:
            Print("C_Stats: GetPlayerUI failed; HUD not added.")

UIStatsCounter := class(creative_device):

    @editable PlayerSpawner : []player_spawner_device = array{}
    @editable ElimManager : elimination_manager_device = elimination_manager_device{}
    var EachPlayerMap : [player]C_Stats = map{}

    OnBegin<override>()<suspends>:void=
        Print("UIStatsCounter: OnBegin.")
        GetPlayspace().PlayerRemovedEvent().Subscribe(RemovePlayerFromMap)
        Print("UIStatsCounter: Subscribed to PlayerRemovedEvent.")

        for(Spawner:PlayerSpawner):
            Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)
        Print("UIStatsCounter: Subscribed to {PlayerSpawner.Length} PlayerSpawner(s).")

        SetAwaitElimiation()
        Print("UIStatsCounter: Elimination await loop scheduled.")

    SetAwaitElimiation():void=
        Print("UIStatsCounter: SetAwaitElimiation -> spawning CheckElimlinatedPlayer loop.")
        spawn{CheckElimlinatedPlayer()}

    CheckElimlinatedPlayer()<suspends>:void=
        Print("UIStatsCounter: CheckElimlinatedPlayer loop started.")
        loop:
            for (EliminationGamePlayer : EachPlayerMap):
                Print("UIStatsCounter: Awaiting elimination events...")
                EliminatedCharacter := ElimManager.EliminatedEvent.Await()
                EliminatingCharacter := ElimManager.EliminationEvent.Await()
                Print("UIStatsCounter: Elimination events received.")

                if(EleminatingFortCharacter := EliminatingCharacter?):
                    Print("UIStatsCounter: Processing killer -> +Kill, KD update.")
                    AddKillStats(EleminatingFortCharacter)
                    UpdateKD(EleminatingFortCharacter)

                EliminatedFortCharacter := EliminatedCharacter
                Print("UIStatsCounter: Processing victim -> +Death, KD update.")
                AddDeathStats(EliminatedFortCharacter)
                UpdateKD(EliminatedFortCharacter)

            Sleep(1.0)

    RemovePlayerFromMap(Agent:agent):void=
        if(PlayerLeaving:= player[Agent]):
            if(ExistingPlayer:= EachPlayerMap[PlayerLeaving]):
                Print("UIStatsCounter: Removing player from map.")
                var NewMap:[player]C_Stats = map{}
                for (Player -> Value : EachPlayerMap, Player <> PlayerLeaving):
                    set NewMap = ConcatenateMaps(NewMap, map{Player => Value})
                set EachPlayerMap = NewMap
                Print("UIStatsCounter: Player removed. Remaining tracked: {EachPlayerMap.Length}")

    AddDeathStats(Agent:agent):void=
        if(PlayerExist := EachPlayerMap[Agent]):
            PlayerExist.SetDeath(PlayerExist.GetDeath() + 1.0)
            PlayerExist.SetUIPlayerDeath(PlayerExist.Death)
            Print("UIStatsCounter: Death++ -> {PlayerExist.Death}")

    AddKillStats(Agent:agent):void=
        if(PlayerExist := EachPlayerMap[Agent]):
            PlayerExist.SetKill(PlayerExist.Kill + 1.0)
            PlayerExist.SetUIPlayerKill(PlayerExist.Kill)
            Print("UIStatsCounter: Kill++ -> {PlayerExist.Kill}")

    UpdateKD(Agent: agent):void=
        if(PlayerExist := EachPlayerMap[Agent]):
            var KD: float = 0.0
            Kill := PlayerExist.Kill
            Death := PlayerExist.Death

            if (Death = 0.0):
                set KD = Kill
            else:
                set KD = Kill / Death

            PlayerExist.SetKD(KD)
            PlayerExist.SetUIPlayerKD(PlayerExist.GetKD())
            Print("UIStatsCounter: KD updated -> {PlayerExist.KD} (K:{Kill} / D:{Death})")

    OnPlayerSpawned(Agent:agent):void=
        if(Player := player[Agent]):
            if(PlayerExist := EachPlayerMap[Player]):
                Print("UIStatsCounter: Player already tracked; skipping init.")
            else:
                if(set EachPlayerMap[Player] = C_Stats{Player:=Player}):
                    if(InitalizedPlayer := EachPlayerMap[Player]):
                        Print("UIStatsCounter: New player tracked; initializing UI counters.")
                        InitalizedPlayer.SetUIPlayerKill(InitalizedPlayer.Kill)
                        InitalizedPlayer.SetUIPlayerDeath(InitalizedPlayer.Death)
                        InitalizedPlayer.SetUIPlayerKD(InitalizedPlayer.KD)
                        InitalizedPlayer.Init()
                        Print("UIStatsCounter: Player UI initialized.")
