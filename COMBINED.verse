using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/UI }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }

# ---------------------------
# Per-player Blue UI widget
# ---------------------------
EachPlayer_Blue := class<unique>():

    Player : player

    var Kill   : float = 0.0
    var Death  : float = 0.0
    var KD     : float = 0.0
    var Wins   : float = 0.0
    var Losses : float = 0.0
    var WLR    : float = 0.0

    UIText<localizes>(pValue : float) : message = "{pValue}"

    var TextKill   : text_block = text_block{DefaultTextColor:=White, DefaultJustification:=text_justification.Right}
    var TextDeath  : text_block = text_block{DefaultTextColor:=White, DefaultJustification:=text_justification.Right}
    var TextKD     : text_block = text_block{DefaultTextColor:=White, DefaultJustification:=text_justification.Right}
    var TextWins   : text_block = text_block{DefaultTextColor:=White, DefaultJustification:=text_justification.Right}
    var TextLoss   : text_block = text_block{DefaultTextColor:=White, DefaultJustification:=text_justification.Right}
    var TextWLR    : text_block = text_block{DefaultTextColor:=White, DefaultJustification:=text_justification.Right}

    GetKill():float = Kill
    GetDeath():float = Death
    GetKD():float = KD
    GetWins():float = Wins
    GetLosses():float = Losses
    GetWLR():float = WLR

    SetKill(v:float):void = set Kill = v
    SetDeath(v:float):void = set Death = v
    SetKD(v:float):void = set KD = v
    SetWins(v:float):void = set Wins = v
    SetLosses(v:float):void = set Losses = v
    SetWLR(v:float):void = set WLR = v

    SetUIPlayerKill(v:float):void = TextKill.SetText(UIText(v))
    SetUIPlayerDeath(v:float):void = TextDeath.SetText(UIText(v))
    SetUIPlayerKD(v:float):void = TextKD.SetText(UIText(v))
    SetUIPlayerWins(v:float):void = TextWins.SetText(UIText(v))
    SetUIPlayerLoss(v:float):void = TextLoss.SetText(UIText(v))
    SetUIPlayerWLR(v:float):void = TextWLR.SetText(UIText(v))

    Init():void =
        if (Agent := agent[Player]):
            InitUI()

    InitUI<private>():void =
        NewCanvas : canvas = canvas:
            Slots := array:
                # Kills value
                canvas_slot:
                    Widget := TextKill
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=120.0, Left:=50.0, Right:=0.0, Bottom:=26.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                    ZOrder := 1
                # Kills icon
                canvas_slot:
                    Widget := texture_block{DefaultImage:=C_Images.Eliminations_Hud_Blue}
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=118.0, Left:=50.0, Right:=175.0, Bottom:=45.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                    ZOrder := 0
                # Deaths value
                canvas_slot:
                    Widget := TextDeath
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=180.0, Left:=50.0, Right:=0.0, Bottom:=26.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                # Deaths icon
                canvas_slot:
                    Widget := texture_block{DefaultImage:=C_Images.Eliminated_Hud_BlueHud}
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=178.0, Left:=50.0, Right:=175.0, Bottom:=45.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                # KD value
                canvas_slot:
                    Widget := TextKD
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=253.5, Left:=50.0, Right:=0.0, Bottom:=26.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                # KD icon
                canvas_slot:
                    Widget := texture_block{DefaultImage:=C_Images.KD_Hud_Blue}
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=250.0, Left:=50.0, Right:=175.0, Bottom:=45.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                # Wins (under KD) — KD image as placeholder
                canvas_slot:
                    Widget := TextWins
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=315.0, Left:=50.0, Right:=0.0, Bottom:=26.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                    ZOrder := 1
                canvas_slot:
                    Widget := texture_block{DefaultImage:=C_Images.KD_Hud_Blue}
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=311.0, Left:=50.0, Right:=175.0, Bottom:=45.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                    ZOrder := 0
                # Losses (under Wins) — KD image as placeholder
                canvas_slot:
                    Widget := TextLoss
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=376.5, Left:=50.0, Right:=0.0, Bottom:=26.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                    ZOrder := 1
                canvas_slot:
                    Widget := texture_block{DefaultImage:=C_Images.KD_Hud_Blue}
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=372.0, Left:=50.0, Right:=175.0, Bottom:=45.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                    ZOrder := 0
                # WLR (under Losses) — KD image as placeholder
                canvas_slot:
                    Widget := TextWLR
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=438.0, Left:=50.0, Right:=0.0, Bottom:=26.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                    ZOrder := 1
                canvas_slot:
                    Widget := texture_block{DefaultImage:=C_Images.KD_Hud_Blue}
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=434.0, Left:=50.0, Right:=175.0, Bottom:=45.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                    ZOrder := 0


        if (lUI := GetPlayerUI[Player]):
            lUI.AddWidget(NewCanvas)

# ---------------------------
# Per-player Red UI widget
# ---------------------------
EachPlayer_Red := class<unique>():

    Player : player

    var Kill   : float = 0.0
    var Death  : float = 0.0
    var KD     : float = 0.0
    var Wins   : float = 0.0
    var Losses : float = 0.0
    var WLR    : float = 0.0

    UIText<localizes>(pValue : float) : message = "{pValue}"

    var TextKill   : text_block = text_block{DefaultTextColor:=White, DefaultJustification:=text_justification.Right}
    var TextDeath  : text_block = text_block{DefaultTextColor:=White, DefaultJustification:=text_justification.Right}
    var TextKD     : text_block = text_block{DefaultTextColor:=White, DefaultJustification:=text_justification.Right}
    var TextWins   : text_block = text_block{DefaultTextColor:=White, DefaultJustification:=text_justification.Right}
    var TextLoss   : text_block = text_block{DefaultTextColor:=White, DefaultJustification:=text_justification.Right}
    var TextWLR    : text_block = text_block{DefaultTextColor:=White, DefaultJustification:=text_justification.Right}

    GetKill():float = Kill
    GetDeath():float = Death
    GetKD():float = KD
    GetWins():float = Wins
    GetLosses():float = Losses
    GetWLR():float = WLR

    SetKill(v:float):void = set Kill = v
    SetDeath(v:float):void = set Death = v
    SetKD(v:float):void = set KD = v
    SetWins(v:float):void = set Wins = v
    SetLosses(v:float):void = set Losses = v
    SetWLR(v:float):void = set WLR = v

    SetUIPlayerKill(v:float):void = TextKill.SetText(UIText(v))
    SetUIPlayerDeath(v:float):void = TextDeath.SetText(UIText(v))
    SetUIPlayerKD(v:float):void = TextKD.SetText(UIText(v))
    SetUIPlayerWins(v:float):void = TextWins.SetText(UIText(v))
    SetUIPlayerLoss(v:float):void = TextLoss.SetText(UIText(v))
    SetUIPlayerWLR(v:float):void = TextWLR.SetText(UIText(v))

    Init():void =
        if (Agent := agent[Player]):
            InitUI()

    InitUI<private>():void =
        NewCanvas : canvas = canvas:
            Slots := array:
                # Kills value
                canvas_slot:
                    Widget := TextKill
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=120.0, Left:=50.0, Right:=0.0, Bottom:=26.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                    ZOrder := 1
                # Kills icon
                canvas_slot:
                    Widget := texture_block{DefaultImage:=C_Images.Eliminations_Hud_Red}
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=118.0, Left:=50.0, Right:=175.0, Bottom:=45.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                    ZOrder := 0
                # Deaths value
                canvas_slot:
                    Widget := TextDeath
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=180.0, Left:=50.0, Right:=0.0, Bottom:=26.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                # Deaths icon
                canvas_slot:
                    Widget := texture_block{DefaultImage:=C_Images.Eliminated_Hud_Red}
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=178.0, Left:=50.0, Right:=175.0, Bottom:=45.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                # KD value
                canvas_slot:
                    Widget := TextKD
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=253.5, Left:=50.0, Right:=0.0, Bottom:=26.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                # KD icon
                canvas_slot:
                    Widget := texture_block{DefaultImage:=C_Images.KD_Hud_Red_no_bg}
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=250.0, Left:=50.0, Right:=175.0, Bottom:=45.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                # Wins (under KD)
                canvas_slot:
                    Widget := TextWins
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=315.0, Left:=50.0, Right:=0.0, Bottom:=26.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                    ZOrder := 1
                canvas_slot:
                    Widget := texture_block{DefaultImage:=C_Images.KD_Hud_Red_no_bg}
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=311.0, Left:=50.0, Right:=175.0, Bottom:=45.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                    ZOrder := 0
                # Losses (under Wins)
                canvas_slot:
                    Widget := TextLoss
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=376.5, Left:=50.0, Right:=0.0, Bottom:=26.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                    ZOrder := 1
                canvas_slot:
                    Widget := texture_block{DefaultImage:=C_Images.KD_Hud_Red_no_bg}
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=372.0, Left:=50.0, Right:=175.0, Bottom:=45.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                    ZOrder := 0
                # WLR (under Losses)
                canvas_slot:
                    Widget := TextWLR
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=438.0, Left:=50.0, Right:=0.0, Bottom:=26.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                    ZOrder := 1
                canvas_slot:
                    Widget := texture_block{DefaultImage:=C_Images.KD_Hud_Red_no_bg}
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.5}, Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets := margin{Top:=434.0, Left:=50.0, Right:=175.0, Bottom:=45.0}  # Moved to middle-left
                    Alignment := vector2{X:=0.0,Y:=0.0}
                    SizeToContent := false
                    ZOrder := 0



        if (lUI := GetPlayerUI[Player]):
            lUI.AddWidget(NewCanvas)

# --------------------------------
# Controller that wires both sides
# --------------------------------
UIStatsCounter_Duo := class(creative_device):
    @editable BlueSpawners : []player_spawner_device = array{}
    @editable RedSpawners  : []player_spawner_device = array{}
    @editable ElimManager  : elimination_manager_device = elimination_manager_device{}

    var BlueMap : [player]EachPlayer_Blue = map{}
    var RedMap  : [player]EachPlayer_Red  = map{}

    OnBegin<override>()<suspends>:void =
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerRemoved)

        for (S : BlueSpawners):
            S.SpawnedEvent.Subscribe(OnBlueSpawned)
        for (S2 : RedSpawners):
            S2.SpawnedEvent.Subscribe(OnRedSpawned)

        spawn { ElimLoop() }

    # Elimination loop -> per-elim K/D + KD refresh
    ElimLoop()<suspends>:void =
        loop:
            EliminatedAgent : agent = ElimManager.EliminatedEvent.Await()
            Eliminator      := ElimManager.EliminationEvent.Await()

            if (ElimPl := Eliminator?):
                AddKillStats(ElimPl)
                UpdateKD(ElimPl)

            AddDeathStats(EliminatedAgent)
            UpdateKD(EliminatedAgent)

    # Map maintenance — rebuild maps without the removed player
    OnPlayerRemoved(Ag:agent):void =
        if (P := player[Ag]):
            if (BlueMap[P]):
                var NewB : [player]EachPlayer_Blue = map{}
                for (Pl -> W : BlueMap, Pl <> P):
                    set NewB = ConcatenateMaps(NewB, map{Pl => W})
                set BlueMap = NewB
            if (RedMap[P]):
                var NewR : [player]EachPlayer_Red = map{}
                for (Pl2 -> W2 : RedMap, Pl2 <> P):
                    set NewR = ConcatenateMaps(NewR, map{Pl2 => W2})
                set RedMap = NewR

    OnBlueSpawned(Ag:agent):void =
        if (Pl := player[Ag]):
            if (not BlueMap[Pl]):
                if (set BlueMap[Pl] = EachPlayer_Blue{Player:=Pl}):
                    if (W := BlueMap[Pl]):
                        W.SetUIPlayerKill(W.Kill)
                        W.SetUIPlayerDeath(W.Death)
                        W.SetUIPlayerKD(W.KD)
                        W.SetUIPlayerWins(W.Wins)
                        W.SetUIPlayerLoss(W.Losses)
                        W.SetUIPlayerWLR(W.WLR)
                        W.Init()

    OnRedSpawned(Ag:agent):void =
        if (Pl := player[Ag]):
            if (not RedMap[Pl]):
                if (set RedMap[Pl] = EachPlayer_Red{Player:=Pl}):
                    if (W := RedMap[Pl]):
                        W.SetUIPlayerKill(W.Kill)
                        W.SetUIPlayerDeath(W.Death)
                        W.SetUIPlayerKD(W.KD)
                        W.SetUIPlayerWins(W.Wins)
                        W.SetUIPlayerLoss(W.Losses)
                        W.SetUIPlayerWLR(W.WLR)
                        W.Init()

    # --- Stat updaters (per-elim K/D + KD)
    AddKillStats(Ag:agent):void =
        if (P := player[Ag]):
            if (E := BlueMap[P]):
                E.SetKill(E.GetKill() + 1.0)
                E.SetUIPlayerKill(E.GetKill())
                return
            if (E2 := RedMap[P]):
                E2.SetKill(E2.GetKill() + 1.0)
                E2.SetUIPlayerKill(E2.GetKill())

    AddDeathStats(Ag:agent):void =
        if (P := player[Ag]):
            if (E := BlueMap[P]):
                E.SetDeath(E.GetDeath() + 1.0)
                E.SetUIPlayerDeath(E.GetDeath())
                return
            if (E2 := RedMap[P]):
                E2.SetDeath(E2.GetDeath() + 1.0)
                E2.SetUIPlayerDeath(E2.GetDeath())

    UpdateKD(Agent:agent):void =
        if (P := player[Agent]):
            if (E := BlueMap[P]):
                var KDv : float = 0.0
                k := E.GetKill()
                d := E.GetDeath()
                if (d = 0.0):
                    set KDv = k
                else:
                    set KDv = k / d
                E.SetKD(KDv)
                E.SetUIPlayerKD(E.GetKD())
                return

            if (E2 := RedMap[P]):
                var KDv2 : float = 0.0
                k2 := E2.GetKill()
                d2 := E2.GetDeath()
                if (d2 = 0.0):
                    set KDv2 = k2
                else:
                    set KDv2 = k2 / d2
                E2.SetKD(KDv2)
                E2.SetUIPlayerKD(E2.GetKD())

    # --- WLR helper
    UpdateWLR(Agent:agent):void =
        if (P := player[Agent]):
            if (E := BlueMap[P]):
                var r : float = 0.0
                w := E.GetWins()
                l := E.GetLosses()
                if (l = 0.0):
                    set r = w
                else:
                    set r = w / l
                E.SetWLR(r)
                E.SetUIPlayerWLR(E.GetWLR())
                return
            if (E2 := RedMap[P]):
                var r2 : float = 0.0
                w2 := E2.GetWins()
                l2 := E2.GetLosses()
                if (l2 = 0.0):
                    set r2 = w2
                else:
                    set r2 = w2 / l2
                E2.SetWLR(r2)
                E2.SetUIPlayerWLR(E2.GetWLR())

    # --- Round result hooks (call these from the controller on round end)
    AwardRoundWinForBlue(Winner:agent):void =
        if (P := player[Winner]):
            if (E := BlueMap[P]):
                E.SetWins(E.GetWins() + 1.0)
                E.SetUIPlayerWins(E.GetWins())
                UpdateWLR(Winner)

    AwardRoundWinForRed(Winner:agent):void =
        if (P := player[Winner]):
            if (E := RedMap[P]):
                E.SetWins(E.GetWins() + 1.0)
                E.SetUIPlayerWins(E.GetWins())
                UpdateWLR(Winner)

    AwardRoundLossForBlue(Loser:agent):void =
        if (P := player[Loser]):
            if (E := BlueMap[P]):
                E.SetLosses(E.GetLosses() + 1.0)
                E.SetUIPlayerLoss(E.GetLosses())
                UpdateWLR(Loser)

    AwardRoundLossForRed(Loser:agent):void =
        if (P := player[Loser]):
            if (E := RedMap[P]):
                E.SetLosses(E.GetLosses() + 1.0)
                E.SetUIPlayerLoss(E.GetLosses())
                UpdateWLR(Loser)
