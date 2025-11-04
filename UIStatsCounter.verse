
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/UI }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.


EachPlayer := class<unique>():

    Player : player
    var Kill : float = 0.0
    var Death : float = 0.0
    var KD : float = 0.0

    UIText<localizes>(pValue : float ) : message = "{pValue}"
    ToMessage<localizes>(Value : string) : message = "{Value}"

    var TextKill<private> : text_block = text_block{DefaultTextColor:=White, DefaultJustification:=text_justification.Right}
    var TextDeath<private> : text_block = text_block{DefaultTextColor:=White, DefaultJustification:=text_justification.Right}
    var TextKD<private> : text_block = text_block{DefaultTextColor:=White, DefaultJustification:=text_justification.Right}


    GetKill():float=
        return Kill

    GetDeath():float=
        return Death

    SetKill(NewKill:float):void=
        set Kill = NewKill

    SetDeath(NewDeath:float):void=
        set Death = NewDeath

    GetKD():float=
        return KD

    SetKD(NewKD:float):void=
        set KD = NewKD

    SetUIPlayerKill(pKill: float) : void=
        TextKill.SetText(UIText(pKill))

    SetUIPlayerDeath(pDeath: float) : void=
        TextDeath.SetText(UIText(pDeath))
 
    SetUIPlayerKD(pKD: float) : void=
        RoundedKD:= GetRoundedString(pKD, 2)
        TextKD.SetText(ToMessage(RoundedKD))


    
    GetRoundedString<private>(Input : float, NumDigitsAfterDecimal : int) : string =
        if:
            Multiplier := Pow(10.0, NumDigitsAfterDecimal * 1.0)
            RoundedValue := RoundedTickRate := float[Round[Input*Multiplier]*1.0] / Multiplier
            BeforeDecimal := Floor[RoundedValue]
            AfterDecimal := Abs(Round[(RoundedValue - BeforeDecimal*1.0)*Multiplier])
            var AfterDecimalString : string = ToString(AfterDecimal)
    
            for (It := 0..(NumDigitsAfterDecimal-AfterDecimalString.Length-1)):
                set AfterDecimalString = array{'0'} + AfterDecimalString
        then:
            "{BeforeDecimal}.{AfterDecimalString}"
        else:
            ToString(Input)

    Init():void=
        if(Agent:=agent[Player]):
            InitUI()

    InitUI<private>() : void = 
        NewCanvas : canvas  = canvas: 
            Slots := array :
                canvas_slot:
                    Widget:= TextKill
                    Anchors:= anchors{Minimum:= vector2{X:= 0.0, Y := 0.5}, Maximum := vector2{X:= 0.0, Y:= 0.5}}
                    Offsets:= margin{Top:= 137.5, Left:= 140.0, Right:= 68.0, Bottom:= 26.0}
                    Alignment:= vector2{X:= 0.0 , Y := 0.0}
                    SizeToContent:= false
                    ZOrder:=1
                canvas_slot:
                    Widget:= texture_block:
                        DefaultImage:=Img.KillHUD
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
                        DefaultImage:=Img.DeathHUD
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
                        DefaultImage:=Img.KDHud
                    Anchors:= anchors{Minimum:= vector2{X:= 0.0, Y := 0.5}, Maximum := vector2{X:= 0.0, Y:= 0.5}}
                    Offsets:= margin{Top:= 260.0, Left:= 52.0, Right:= 175.0, Bottom:= 45.0}
                    Alignment:= vector2{X:= 0.0 , Y := 0.0}
                    SizeToContent:= false

        if(lPlayerUI:= GetPlayerUI[Player]):
            lPlayerUI.AddWidget(NewCanvas)

# A Verse-authored creative device that can be placed in a level
UIStatsCounter := class(creative_device):

    @editable PlayerSpawner : []player_spawner_device = array{}
    @editable ElimManager : elimination_manager_device = elimination_manager_device{}
    var PersistenceManager : Persistence_Manager = Persistence_Manager{}
    var EachPlayerMap : [player]EachPlayer = map{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=

        GetPlayspace().PlayerRemovedEvent().Subscribe(RemovePlayerFromMap)

        for(Spawner:PlayerSpawner):
            Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

        SetAwaitElimiation()


    SetAwaitElimiation():void=
        spawn{CheckElimlinatedPlayer()}

    CheckElimlinatedPlayer()<suspends>:void=
        loop:
            for (EliminationGamePlayer : EachPlayerMap):

                EliminatedCharacter := ElimManager.EliminatedEvent.Await()
                EliminatingCharacter := ElimManager.EliminationEvent.Await()


                if(EleminatingFortCharacter := EliminatingCharacter?):

                    AddKillStats(EleminatingFortCharacter)
                    UpdateKD(EleminatingFortCharacter)

                EliminatedFortCharacter := EliminatedCharacter

                AddDeathStats(EliminatedFortCharacter)
                UpdateKD(EliminatedFortCharacter)

            Sleep(1.0)


    RemovePlayerFromMap(Agent:agent):void=
        if(PlayerLeaving:= player[Agent]):
            if(ExistingPlayer:= EachPlayerMap[PlayerLeaving]):
                var NewMap:[player]EachPlayer = map{}
                for (Player -> Value : EachPlayerMap, Player <> PlayerLeaving):
                    set NewMap = ConcatenateMaps(NewMap, map{Player => Value})
                set EachPlayerMap = NewMap
    
    AddDeathStats(Agent:agent):void=
        if(PlayerExist := EachPlayerMap[Agent]):
            PlayerExist.SetDeath(PlayerExist.GetDeath() + 1.0)
            PersistenceManager.UpdateNbDeath(Agent, PlayerExist.Death)
            PlayerExist.SetUIPlayerDeath(PlayerExist.Death)


    AddKillStats(Agent:agent):void=
        if(PlayerExist := EachPlayerMap[Agent]):
            PlayerExist.SetKill(PlayerExist.Kill + 1.0)
            PersistenceManager.UpdateNbKill(Agent, PlayerExist.Kill)
            PlayerExist.SetUIPlayerKill(PlayerExist.Kill)

        

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
            PersistenceManager.UpdateNbKD(Agent, PlayerExist.KD)
            PlayerExist.SetUIPlayerKD(PlayerExist.GetKD())


    OnPlayerSpawned(Agent:agent):void=
        if(Player := player[Agent]):
            PersistenceManager.InitializePlayer(Player)
            if(PlayerExist := EachPlayerMap[Player]):
            else:
                SavedPlayerStats := PersistenceManager.GetPlayerStats(Player)
                if(set EachPlayerMap[Player] = EachPlayer{Player:=Player,Kill:=SavedPlayerStats.NbKill,Death:=SavedPlayerStats.NbDeath, KD:=SavedPlayerStats.NbKD}):
                    if(InitalizedPlayer := EachPlayerMap[Player]):
                        InitalizedPlayer.SetUIPlayerKill(InitalizedPlayer.Kill)
                        InitalizedPlayer.SetUIPlayerDeath(InitalizedPlayer.Death)
                        InitalizedPlayer.SetUIPlayerKD(InitalizedPlayer.KD)
                        InitalizedPlayer.Init()