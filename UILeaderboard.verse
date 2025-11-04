
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary }

ToMessage<localizes>(Value : float) : message = "{Value}"
ToMessage<localizes>(Agent : agent) : message = "{Agent}"
ToMessage<localizes>(Value : string) : message = "{Value}"


UIStats := class():

    Overlay_157 : overlay = overlay{}
    Overlay_1749 : overlay = overlay{}
    Overlay_1750 : overlay = overlay{}
    Overlay_1751 : overlay = overlay{}
    StackBox_1832 : stack_box = stack_box{Orientation := orientation.Vertical}

    Image_150: texture_block = texture_block{
        DefaultImage := UIElements.StatsBackground,
        DefaultHorizontalTiling := image_tiling.Stretch,
        DefaultVerticalTiling := image_tiling.Stretch,
        DefaultDesiredSize := vector2{X := 166.0,Y := 196.0}
    }
    Image_151: texture_block = texture_block{
        DefaultImage := UIElements.KillIcon,
        DefaultHorizontalTiling := image_tiling.Stretch,
        DefaultVerticalTiling := image_tiling.Stretch,
        DefaultDesiredSize := vector2{X := 41.0,Y := 41.0}
    }
    Image_152: texture_block = texture_block{
        DefaultImage := UIElements.DeathIcon,
        DefaultHorizontalTiling := image_tiling.Stretch,
        DefaultVerticalTiling := image_tiling.Stretch,
        DefaultDesiredSize := vector2{X := 35.0,Y := 41.0}
    }
    Image_153: texture_block = texture_block{
        DefaultImage := UIElements.KDIcon,
        DefaultHorizontalTiling := image_tiling.Stretch,
        DefaultVerticalTiling := image_tiling.Stretch,
        DefaultDesiredSize := vector2{X := 41.0,Y := 41.0}
    }

    PlayerKillText: text_block = text_block{DefaultTextColor := color{R:=0.3, G:=1.0, B:=0.3}}
    PlayerDeathText: text_block = text_block{DefaultTextColor := color{R:=1.0, G:=0.25, B:=0.3}}
    PlayerKDText: text_block = text_block{DefaultTextColor := color{R:=0.0, G:=0.9, B:=1.0}}

    var MainCanvas: canvas = canvas{}
    MainOverlay : overlay = overlay{}

    var PlayerKill : float
    var PlayerDeath : float
    var PlayerKD : float


    SetUIKill(NewKill:float):void=
        set PlayerKill = NewKill
        PlayerKillText.SetText(ToMessage(PlayerKill))

    SetUIDeath(NewDeath:float):void=
        set PlayerDeath = NewDeath
        PlayerDeathText.SetText(ToMessage(PlayerDeath))

    SetUIKD(NewKD:float):void=
        set PlayerKD = NewKD
        RoundedKD:= GetRoundedString(PlayerKD, 2)
        PlayerKDText.SetText(ToMessage(RoundedKD))

    AddUI(Agent : agent) : void=
        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            set MainCanvas = Init(PlayerKill, PlayerDeath, PlayerKD)
            PlayerUI.AddWidget(MainCanvas)

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

    Init(Kill: float, Death: float, KD:float):canvas =
        

        PlayerKillText.SetText(ToMessage(Kill))
        PlayerDeathText.SetText(ToMessage(Death))
        PlayerKDText.SetText(ToMessage(KD))

       


        for (Slot: array{
            overlay_slot{
                Widget := Image_153,
                HorizontalAlignment:= horizontal_alignment.Left,
                VerticalAlignment:= vertical_alignment.Center
            }
            overlay_slot{
                Widget := PlayerKDText,
                HorizontalAlignment:= horizontal_alignment.Right,
                VerticalAlignment:= vertical_alignment.Center
            }
        }){Overlay_1751.AddWidget(Slot)}
        for (Slot: array{
            overlay_slot{
                Widget := Image_152,
                HorizontalAlignment:= horizontal_alignment.Left,
                VerticalAlignment:= vertical_alignment.Center
            }
            overlay_slot{
                Widget := PlayerDeathText,
                HorizontalAlignment:= horizontal_alignment.Right,
                VerticalAlignment:= vertical_alignment.Center
            }
        }){Overlay_1750.AddWidget(Slot)}

        for (Slot: array{
            overlay_slot{
                Widget := Image_151,
                HorizontalAlignment:= horizontal_alignment.Left,
                VerticalAlignment:= vertical_alignment.Center
            }
            overlay_slot{
                Widget := PlayerKillText,
                HorizontalAlignment:= horizontal_alignment.Right,
                VerticalAlignment:= vertical_alignment.Center
            }
        }){Overlay_1749.AddWidget(Slot)}

        for (Slot: array{
            stack_box_slot{
                Widget := Overlay_1749,
                Padding:= margin{Top:= 20.0, Left:= 20.0, Right:= 20.0},
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            }
            stack_box_slot{
                Widget := Overlay_1750,
                Padding:= margin{Top:= 20.0, Left:= 20.0, Right:= 20.0, Bottom:= 20.0},
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            }
            stack_box_slot{
                Widget := Overlay_1751,
                Padding:= margin{Left:= 20.0, Right:= 20.0, Bottom:= 20.0},
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            }
        }){StackBox_1832.AddWidget(Slot)}

        for (Slot: array{
            overlay_slot{
                Widget := Image_150,
                HorizontalAlignment:= horizontal_alignment.Left,
                VerticalAlignment:= vertical_alignment.Top
            }
            overlay_slot{
                Widget := StackBox_1832,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Top
            }
        }){Overlay_157.AddWidget(Slot)}

        for (Slot: array{
            overlay_slot{
                Widget := Overlay_157,
                Padding:= margin{Left:=50.0, Bottom:= 180.0},
                HorizontalAlignment:= horizontal_alignment.Left,
                VerticalAlignment:= vertical_alignment.Top
            }
        }){MainOverlay.AddWidget(Slot)}

        for (Slot: array{
            canvas_slot{
                Widget := MainOverlay,
                SizeToContent:= true,
                Anchors:= anchors{Minimum := vector2{X := 0.0,Y := 1.0},Maximum := vector2{X := 0.0,Y := 1.0}},
                Alignment:= vector2{X := 0.0,Y := 1.0}
            }
        }){MainCanvas.AddWidget(Slot)}
        MainCanvas


UILeaderboard := class():

    var EachPlayerMap : [player]EachPlayerStats
    var SortedPlayerKill : []float = array{}


    var MainCanvas: canvas = canvas{}
    
    MainOverlay : overlay = overlay{}
   


    StackBox_141: stack_box = stack_box{Orientation := orientation.Vertical}
    StackBox_510: stack_box = stack_box{Orientation := orientation.Horizontal}
    StackBox_730: stack_box = stack_box{Orientation := orientation.Vertical}
    Overlay_58 : overlay = overlay{}
    var CreatedStackBox : []stack_box = array{}

    
    Image_114: texture_block = texture_block{
        DefaultImage := UIElements.LeaderboardBackground,
        DefaultHorizontalTiling := image_tiling.Stretch,
        DefaultVerticalTiling := image_tiling.Stretch,
        DefaultDesiredSize := vector2{X := 950.0,Y := 72.0}
    }

    Image_198: texture_block = texture_block{
        DefaultImage := UIElements.PlayerTextLeaderboard,
        DefaultHorizontalTiling := image_tiling.Stretch,
        DefaultVerticalTiling := image_tiling.Stretch,
        DefaultDesiredSize := vector2{X := 104.0,Y := 24.0}
    }
    Image_292: texture_block = texture_block{
        DefaultImage := UIElements.KillIcon,
        DefaultHorizontalTiling := image_tiling.Stretch,
        DefaultVerticalTiling := image_tiling.Stretch,
        DefaultDesiredSize := vector2{X := 41.0,Y := 41.0}
    }
    Image: texture_block = texture_block{
        DefaultImage := UIElements.DeathIcon,
        DefaultHorizontalTiling := image_tiling.Stretch,
        DefaultVerticalTiling := image_tiling.Stretch,
        DefaultDesiredSize := vector2{X := 35.0,Y := 41.0}
    }
    Image_1: texture_block = texture_block{
        DefaultImage := UIElements.KDIcon,
        DefaultHorizontalTiling := image_tiling.Stretch,
        DefaultVerticalTiling := image_tiling.Stretch,
        DefaultDesiredSize := vector2{X := 41.0,Y := 41.0}
    }

    SetNewPlayerMap(Agent: agent, NewPlayerMap:[player]EachPlayerStats):void=
        set EachPlayerMap = NewPlayerMap
        if(Exist := EachPlayerMap[Agent]):
            Print("{Exist.Kill}")
        


    



    AddUI(Agent : agent) : void=
        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player]):

       
            set MainCanvas = Init()
            PlayerUI.AddWidget(MainCanvas)

    RemoveUI(Agent : agent) : void=
        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(MainCanvas)

    
            


    

    CreatePlayerRow(Agent:agent, Kill: float, Death: float, KD:string):stack_box=

        
        StackBox_597 : stack_box = stack_box{Orientation := orientation.Horizontal}
        Overlay_635 : overlay = overlay{}
        Overlay_634 : overlay = overlay{}
        Overlay_569 : overlay = overlay{}
        Overlay_445 : overlay = overlay{}

        Image_445: texture_block = texture_block{
            DefaultImage := UIElements.SpaceSquare,
            DefaultHorizontalTiling := image_tiling.Stretch,
            DefaultVerticalTiling := image_tiling.Stretch,
            DefaultDesiredSize := vector2{X := 48.0,Y := 72.0}
        }
        Image_854: texture_block = texture_block{
            DefaultImage := UIElements.PlayerTextBackground,
            DefaultHorizontalTiling := image_tiling.Stretch,
            DefaultVerticalTiling := image_tiling.Stretch,
            DefaultDesiredSize := vector2{X := 518.0,Y := 72.0}
        }
        Image_3: texture_block = texture_block{
            DefaultImage := UIElements.DataSquareBackground,
            DefaultHorizontalTiling := image_tiling.Stretch,
            DefaultVerticalTiling := image_tiling.Stretch,
            DefaultDesiredSize := vector2{X := 128.0,Y := 72.0}
        }
        Image_2: texture_block = texture_block{
            DefaultImage := UIElements.DataSquareBackground,
            DefaultHorizontalTiling := image_tiling.Stretch,
            DefaultVerticalTiling := image_tiling.Stretch,
            DefaultDesiredSize := vector2{X := 128.0,Y := 72.0}
        }
        Image_960: texture_block = texture_block{
            DefaultImage := UIElements.DataSquareBackground,
            DefaultHorizontalTiling := image_tiling.Stretch,
            DefaultVerticalTiling := image_tiling.Stretch,
            DefaultDesiredSize := vector2{X := 128.0,Y := 72.0}
        }
    
        

        PlayerNameText: text_block = text_block{DefaultTextColor := color{R:=1.0, G:=1.0, B:=1.0}}
        PlayerKillText: text_block = text_block{DefaultTextColor := color{R:=0.3, G:=1.0, B:=0.3}}
        PlayerDeathText: text_block = text_block{DefaultTextColor := color{R:=1.0, G:=0.25, B:=0.3}}
        PlayerKDText: text_block = text_block{DefaultTextColor := color{R:=0.0, G:=0.9, B:=1.0}}

        PlayerNameText.SetText(ToMessage(Agent))
        PlayerKillText.SetText(ToMessage(Kill))
        PlayerDeathText.SetText(ToMessage(Death))
        PlayerKDText.SetText(ToMessage(KD))


        for (Slot: array{
            overlay_slot{
                Widget := Image_854,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            }
            overlay_slot{
                Widget := PlayerNameText,
                Padding:= margin{Left:=15.0},
                HorizontalAlignment:= horizontal_alignment.Left,
                VerticalAlignment:= vertical_alignment.Center
            }
        }){Overlay_445.AddWidget(Slot)}

        for (Slot: array{
            overlay_slot{
                Widget := Image_960,
                HorizontalAlignment:= horizontal_alignment.Left,
                VerticalAlignment:= vertical_alignment.Top
            }
            overlay_slot{
                Widget := PlayerKillText,
                HorizontalAlignment:= horizontal_alignment.Center,
                VerticalAlignment:= vertical_alignment.Center
            }
        }){Overlay_569.AddWidget(Slot)}

        for (Slot: array{
            overlay_slot{
                Widget := Image_2,
                HorizontalAlignment:= horizontal_alignment.Left,
                VerticalAlignment:= vertical_alignment.Top
            }
            overlay_slot{
                Widget := PlayerDeathText,
                HorizontalAlignment:= horizontal_alignment.Center,
                VerticalAlignment:= vertical_alignment.Center
            }
        }){Overlay_634.AddWidget(Slot)}

        for (Slot: array{
            overlay_slot{
                Widget := Image_3,
                HorizontalAlignment:= horizontal_alignment.Left,
                VerticalAlignment:= vertical_alignment.Top
            }
            overlay_slot{
                Widget := PlayerKDText,
                HorizontalAlignment:= horizontal_alignment.Center,
                VerticalAlignment:= vertical_alignment.Center
            }
        }){Overlay_635.AddWidget(Slot)}

        for (Slot: array{
            stack_box_slot{
                Widget := Image_445,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            }
            stack_box_slot{
                Widget := Overlay_445,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            }
            stack_box_slot{
                Widget := Overlay_569,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            }
            stack_box_slot{
                Widget := Overlay_634,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            }
            stack_box_slot{
                Widget := Overlay_635,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            }
        }){StackBox_597.AddWidget(Slot)}
        StackBox_597
        
        

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

    IntegerLess(Lhs:float, Rhs:float)<computes><decides>:void = 
        Lhs > Rhs
    
    SortArray(Array: []float):[]float = 
        SortedFloats:[]float = SortBy(Array, IntegerLess)
    


    MaxRow: ?int = false
    var RowToDisplay : int= 0
    Init():canvas =


        for(Obj:EachPlayerMap):
            set SortedPlayerKill += array{Obj.Kill}

        set SortedPlayerKill = SortArray(SortedPlayerKill)
        
        var SortedPlayerMap : [player]EachPlayerStats = map{}
        for(X:= 0..EachPlayerMap.Length - 1, Player->Obj:EachPlayerMap):
            if(SortedPlayerKill[X] = Obj.Kill):
                if(set SortedPlayerMap[Player] = Obj):
            
        
              
        
        if(MaxRowNumber := MaxRow?):
            if(MaxRowNumber > SortedPlayerMap.Length - 1):
                set RowToDisplay = SortedPlayerMap.Length -1
            else:
                set RowToDisplay = MaxRowNumber -1
        else:
            set RowToDisplay = SortedPlayerMap.Length -1

        for(X:= 0..RowToDisplay, Player->Obj:SortedPlayerMap):
            set CreatedStackBox += array{CreatePlayerRow(Player, Obj.Kill, Obj.Death, GetRoundedString(Obj.KD, 2))}
            for (Slot: array{
                stack_box_slot{
                    Widget := CreatedStackBox[X],
                    Padding:= margin{Top := 5.0},
                    HorizontalAlignment:= horizontal_alignment.Left,
                    VerticalAlignment:= vertical_alignment.Top
                }
            }){StackBox_730.AddWidget(Slot)}

        for (Slot: array{
            stack_box_slot{
                Widget := Image_292,
                Padding:= margin{Right:=90.0},
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            }
            stack_box_slot{
                Widget := Image,
                Padding:= margin{Right:=90.0},
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            }
            stack_box_slot{
                Widget := Image_1,
                Padding:= margin{Right:=45.0},
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            }
        }){StackBox_510.AddWidget(Slot)}


        for (Slot: array{
            overlay_slot{
                Widget := Image_114,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Top
            }
            overlay_slot{
                Widget := Image_198,
                Padding:= margin{Left:=65.0},
                HorizontalAlignment:= horizontal_alignment.Left,
                VerticalAlignment:= vertical_alignment.Center
            }
            overlay_slot{
                Widget := StackBox_510,
                HorizontalAlignment:= horizontal_alignment.Right,
                VerticalAlignment:= vertical_alignment.Center
            }
        }){Overlay_58.AddWidget(Slot)}

        for (Slot: array{
            stack_box_slot{
                Widget := Overlay_58,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            },
            stack_box_slot{
                Widget := StackBox_730,
                HorizontalAlignment:= horizontal_alignment.Left,
                VerticalAlignment:= vertical_alignment.Top
            }
        }){StackBox_141.AddWidget(Slot)}

        for (Slot: array{
            overlay_slot{
                Widget := StackBox_141,
                HorizontalAlignment:= horizontal_alignment.Left,
                VerticalAlignment:= vertical_alignment.Top
            }
        }){MainOverlay.AddWidget(Slot)}


        for (Slot: array{
            canvas_slot{
                Widget := MainOverlay,
                SizeToContent:= true,
                Anchors:= anchors{Minimum := vector2{X := 0.5,Y := 0.5},Maximum := vector2{X := 0.5,Y := 0.5}},
                Alignment:= vector2{X := 0.5,Y := 0.5}
            }
        }){MainCanvas.AddWidget(Slot)}
        MainCanvas

            

EachPlayerStats:= class<unique>():

    Player : player
    var Kill : float = 0.0
    var Death : float = 0.0
    var KD : float = 0.0

    var UIPlayerStats : ?UIStats = false
    var UILeaderboards : ?UILeaderboard = false

    InitUIStats():void=
        set UIPlayerStats = option{UIStats{PlayerKill:=Kill,PlayerDeath:=Death,PlayerKD:=KD}}

    InitLeaderboard(Map:[player]EachPlayerStats, MaxRow:?int):void=
        set UILeaderboards = option{UILeaderboard{EachPlayerMap:=Map, MaxRow:=MaxRow}}
        if(NewUILeaderboard:=UILeaderboards?):
            NewUILeaderboard.AddUI(Player)

    HideLeaderBoard():void=
        if(NewUILeaderboard:=UILeaderboards?):
            NewUILeaderboard.RemoveUI(Player)



    UpdateKill(NewKill: float):void=
        set Kill = NewKill
        if(PlayerUIStats := UIPlayerStats?):
            PlayerUIStats.SetUIKill(Kill)
    UpdateDeath(NewDeath: float):void=
        set Death = NewDeath
        if(PlayerUIStats := UIPlayerStats?):
            PlayerUIStats.SetUIDeath(Death)

    UpdateKD():void=
        if(PlayerUIStats := UIPlayerStats?):
            if (Death = 0.0):
                set KD = Kill
            else: 
                set KD = Kill / Death

            PlayerUIStats.SetUIKD(KD)


        





UILeaderboardDevice := class(creative_device):

    @editable InputTrigger : input_trigger_device = input_trigger_device{}
    @editable PlayerSpawner : []player_spawner_device = array{}
    @editable ElimManager : elimination_manager_device = elimination_manager_device{}
    @editable EnableUILeaderboard : logic = true
    @editable EnableUIStats : logic = true
    @editable MaxRowToDisplay : ?int = false



    var NewUILeaderboard : ?UILeaderboard = false
    var NewUIStats: ?UIStats = false
    var EachPlayerMap : [player]EachPlayerStats = map{}




    OnBegin<override>()<suspends>:void=

        GetPlayspace().PlayerRemovedEvent().Subscribe(RemovePlayerFromMap)
  
        for(Spawner:PlayerSpawner):
            Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

        SetAwaitElimiation()

        InputTrigger.PressedEvent.Subscribe(OpenUI)
        InputTrigger.ReleasedEvent.Subscribe(HideUI)
    
    
            



    SetAwaitElimiation():void=
        spawn{CheckElimlinatedPlayer()}

    CheckElimlinatedPlayer()<suspends>:void=
        loop:
            for (EliminationGamePlayer : EachPlayerMap):

                EliminatedCharacter := ElimManager.EliminatedEvent.Await()
                EliminatingCharacter := ElimManager.EliminationEvent.Await()


                if(EleminatingFortCharacter := EliminatingCharacter?):
                    if(PlayerExist := EachPlayerMap[EleminatingFortCharacter]):
                        PlayerExist.UpdateKill(PlayerExist.Kill + 1.0)
                        PlayerExist.UpdateKD()

                EliminatedFortCharacter := EliminatedCharacter
                if(Player:= EachPlayerMap[EliminatedFortCharacter]):
                    Player.HideLeaderBoard()
                    Player.UpdateDeath(Player.Death + 1.0)
                    Player.UpdateKD()

            Sleep(1.0)
                    
        
    OpenUI(Agent:agent):void=
        if(EnableUILeaderboard?):
            if(Player:= EachPlayerMap[Agent]):
                    Player.InitLeaderboard(EachPlayerMap,MaxRowToDisplay)


    HideUI(Agent:agent, Time:float):void=
        if(EnableUILeaderboard?):
            if(Player:= EachPlayerMap[Agent]):
                Player.HideLeaderBoard()


    OnPlayerSpawned(Agent:agent):void=
        if (Player := player[Agent]):
            if (PlayerExisting := EachPlayerMap[Player]):
            else:
                if(set EachPlayerMap[Player] = EachPlayerStats{Player:=Player}):
                    if (PlayerCreated := EachPlayerMap[Player]):
                        if(EnableUIStats?):
                            PlayerCreated.InitUIStats()
                            if(PlayerUIStats := PlayerCreated.UIPlayerStats?):
                                PlayerUIStats.AddUI(Player)
                        

    RemovePlayerFromMap(Agent:agent):void=
        if(PlayerLeaving:= player[Agent]):
            if(ExistingPlayer:= EachPlayerMap[PlayerLeaving]):
                var NewMap:[player]EachPlayerStats = map{}
                for (Player -> Value : EachPlayerMap, Player <> PlayerLeaving):
                    set NewMap = ConcatenateMaps(NewMap, map{Player => Value})
                set EachPlayerMap = NewMap
