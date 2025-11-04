
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors }
using { /Verse.org/Assets }
using { /Fortnite.com/Characters }
using { /Verse.org/Random }
using { /Fortnite.com/UI }

parameter_direction(t:type) := class:
    Arg1: t
    Func:type{_(:agent, :t):void}
    Invoke(Agent : agent):void = Func(Agent, Arg1)

int2 := struct:
    X : int
    Y : int

Part := enum:
    Head,
    Body,
    Tail,
    None

Direction := enum:
    Up,
    Down,
    Left,
    Right,
    None

SnakeMovements := struct<concrete>:
    @editable Up : input_trigger_device = input_trigger_device{}
    @editable Down : input_trigger_device = input_trigger_device{}
    @editable Left : input_trigger_device = input_trigger_device{}
    @editable Right : input_trigger_device = input_trigger_device{}

SnakeGameVerse := class(creative_device):
    @editable OpenSnakeButton:button_device = button_device{}
    @editable GridSize : int = 10
    @editable WindowSize : float = 1.0
    @editable LightColor : color = MakeColorFromHex("A7D129FF")
    @editable DarkColor : color = MakeColorFromHex("74A32FFF")
    @editable OutlineColor : color = MakeColorFromHex("4D7B2DFF")
    @editable BarColor : color = MakeColorFromHex("2D5230FF")
    @editable Movements : SnakeMovements = SnakeMovements{}
    var SnakeMap : [agent]tuple(SnakeScreen, ?[]cancelable) = map{}

    OnBegin<override>()<suspends>:void=
        OpenSnakeButton.InteractedWithEvent.Subscribe(OpenSnake)

    OpenSnake(Agent : agent):void=
        AgentSnakeScreen : SnakeScreen = SnakeScreen{
            Main := Self
            SnakeAgent := Agent
            GridSize := GridSize
            LightColor := LightColor
            DarkColor := DarkColor
            OutlineColor := OutlineColor
            BarColor := BarColor
            WindowSize := WindowSize
        }
        if(set SnakeMap[Agent] = (AgentSnakeScreen, false)):
            AgentSnakeScreen.AddUI(Agent)
            EnableInputs(Agent)
            if (FC := player[Agent].GetFortCharacter[]):
                FC.PutInStasis(stasis_args{
                    AllowTurning := false, 
                    AllowEmotes := false,
                    AllowFalling := true
                    })

    EnableInputs(Agent : agent):void=
        CancelableUp := Movements.Up.PressedEvent.Subscribe(parameter_direction(Direction){Arg1 := Direction.Up, Func := ChangeDirection}.Invoke)
        CancelableDown := Movements.Down.PressedEvent.Subscribe(parameter_direction(Direction){Arg1 := Direction.Down, Func := ChangeDirection}.Invoke)
        CancelableLeft := Movements.Left.PressedEvent.Subscribe(parameter_direction(Direction){Arg1 := Direction.Left, Func := ChangeDirection}.Invoke)
        CancelableRight := Movements.Right.PressedEvent.Subscribe(parameter_direction(Direction){Arg1 := Direction.Right, Func := ChangeDirection}.Invoke)
        if (SnakeData := SnakeMap[Agent]):
            if{set SnakeMap[Agent] = (SnakeData(0), option{array{CancelableUp, CancelableDown, CancelableLeft, CancelableRight}})}

    DisableInputs(Agent : agent):void=
        if (SnakeData := SnakeMap[Agent], Cancelables := SnakeData(1)?):
            for (C : Cancelables):
                C.Cancel()
            if{set SnakeMap[Agent] = (SnakeData(0), false)}

    ChangeDirection(Agent : agent, NewDirection : Direction):void=
        if (SnakeData := SnakeMap[Agent]):
            var ActualDirection : Direction = SnakeData(0).GetActualMovingDirection()
            Screen := SnakeData(0)
            
            if (ActualDirection = Direction.None):
                set Screen.MovingDirection = NewDirection
            else if (ActualDirection = Direction.Up, NewDirection <> Direction.Down):
                set Screen.MovingDirection = NewDirection
            else if (ActualDirection = Direction.Down, NewDirection <> Direction.Up):
                set Screen.MovingDirection = NewDirection
            else if (ActualDirection = Direction.Left, NewDirection <> Direction.Right):
                set Screen.MovingDirection = NewDirection
            else if (ActualDirection = Direction.Right, NewDirection <> Direction.Left):
                set Screen.MovingDirection = NewDirection

CreateMessage<localizes>(Input : string) : message = "{Input}" 

SnakeElement := class<unique>():
    var Position : int2 = int2{X := 0, Y := 0}
    var Image : texture = SnakeAssets.apple
    var IsHead : logic = false
    var Next : ?SnakeElement = false
    var SelfPart : Part = Part.None

SnakeScreen := class():
    Main : SnakeGameVerse
    SnakeAgent : agent
    GridSize : int
    LightColor : color
    DarkColor : color
    OutlineColor : color
    BarColor : color
    WindowSize : float
    var SnakeCanvas : canvas = canvas{}
    var MaybeSnakeHead : ?SnakeElement = false
    var MovingDirection : Direction = Direction.None
    var AppleCount : int = 0

    var Tiles : [][]?texture_block = array{}
    var EndGameEvent : event() = event(){}
    var ApplePosition : ?int2 = false

    AppleTextBlock : text_block = text_block{DefaultTextColor := MakeColorFromHex("FFFFFFFF")}

    GetActualMovingDirection():Direction=
        if (SnakeHead := MaybeSnakeHead?):
            if (Body := SnakeHead.Next?):
                return DirectionFromPositions(Body.Position, SnakeHead.Position)
        return MovingDirection

    SpawnApple():void=
        var AppleSpawned : logic = false
        var Attempts : int = 0
        
        loop:
            if (Attempts >= 100 or AppleSpawned = true):
                break
            
            var TestPosition : int2 = int2{
                X := GetRandomInt(0, GridSize - 1) 
                Y := GetRandomInt(0, GridSize - 2)
                }
            
            var IsOccupied : logic = false
            if (SnakeHead := MaybeSnakeHead?):
                var CurrentElement : SnakeElement = SnakeHead
                loop:
                    if (CurrentElement.Position.X = TestPosition.X and CurrentElement.Position.Y = TestPosition.Y):
                        set IsOccupied = true
                        break
                    if (Next := CurrentElement.Next?):
                        set CurrentElement = Next
                    else:
                        break
            
            if (IsOccupied = false):
                set ApplePosition = option{TestPosition}
                if (AppleTile := Tiles[TestPosition.X][TestPosition.Y]?):
                    AppleTile.SetImage(SnakeAssets.apple)
                set AppleSpawned = true
            
            set Attempts = Attempts + 1

    IsAppleEaten(HeadPosition : int2):logic=
        if (Apple := ApplePosition?):
            if (Apple.X = HeadPosition.X and Apple.Y = HeadPosition.Y):
                return true
            else:
                return false
        return false

    RemoveApple():void=
        if (Apple := ApplePosition?):
            if (AppleTile := Tiles[Apple.X][Apple.Y]?):
                AppleTile.SetImage(SnakeAssets.empty)
            set ApplePosition = false
            set AppleCount += 1
            AppleTextBlock.SetText(CreateMessage("{AppleCount}"))

    GrowSnakeAtPosition(OldTailPos : ?int2):void=
        if (SnakeHead := MaybeSnakeHead?, ActualOldTailPos := OldTailPos?):
            var CurrentElement : SnakeElement = SnakeHead
            var TailElement : ?SnakeElement = false
            
            loop:
                if (Next := CurrentElement.Next?):
                    set CurrentElement = Next
                else:
                    set TailElement = option{CurrentElement}
                    break
            
            if (Tail := TailElement?):
                NewTail : SnakeElement = SnakeElement{Position := ActualOldTailPos, SelfPart := Part.Tail}
                
                set Tail.SelfPart = Part.Body
                set Tail.Next = option{NewTail}

    GetSnakeLength():int=
        var SnakeLen : int = 0
        if (SnakeHead := MaybeSnakeHead?):
            var CurrentElement : SnakeElement = SnakeHead
            loop:
                set SnakeLen = SnakeLen + 1
                if (Next := CurrentElement.Next?):
                    set CurrentElement = Next
                else:
                    break
        return SnakeLen

    IsGameWon():logic=
        var TotalTiles : int = GridSize * (GridSize - 1)
        var SnakeLength : int = GetSnakeLength()
        if (SnakeLength = TotalTiles):
            return true
        else:
            return false

    AddUI(Agent : agent):void=
        if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            set SnakeCanvas = InitScreen()
            PlayerUI.AddWidget(SnakeCanvas)
            spawn{SnakeGameLoop()}

    RemoveUI(Agent : agent):void=
        if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(SnakeCanvas)
            Main.DisableInputs(SnakeAgent)

    SnakeGameLoop()<suspends>:void=
        if (MiddleY := Floor[(GridSize-1)*1.0 / 2.0], MiddleX := Floor[GridSize*1.0 / 2.0]):
            Head : SnakeElement = SnakeElement{Position := int2{X := MiddleX, Y := MiddleY}, IsHead := true, SelfPart := Part.Head}
            Body1 : SnakeElement = SnakeElement{Position := int2{X := MiddleX - 1, Y := MiddleY}, SelfPart := Part.Body}
            Tail : SnakeElement = SnakeElement{Position := int2{X := MiddleX - 2, Y := MiddleY}, SelfPart := Part.Tail}

            set Head.Next = option{Body1}
            set Body1.Next = option{Tail}
            set MaybeSnakeHead = option{Head}
        
            set MovingDirection = Direction.None
            UpdateAllSnakeTextures(true)
            
            SpawnApple()

        spawn{UpdateSnakeLoop()}

    UpdateSnakeLoop()<suspends>:void=
        race:
            block:
                EndGameEvent.Await()
            block:
                loop:
                    if (MovingDirection <> Direction.None):
                        break
                    Sleep(0.1)
                loop:
                    UpdateSnake()
                    Sleep(0.22)

    InitScreen():canvas =
        set SnakeCanvas = canvas{}

        for (X := 0..GridSize-1):
            Row : []?texture_block = for (Y := 0..GridSize-2) do false
            set Tiles += array{Row}

        FinalStackBox : stack_box = stack_box{Orientation := orientation.Vertical}
        for (Y := 0..GridSize - 2):
            FinalStackBox.AddWidget(
                stack_box_slot{
                    Widget := MakeRow(Y)
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Distribution := option{1.0}
                }
            )

        GameOverlay : overlay = overlay{}
        GameOverlay.AddWidget(
            overlay_slot{
                Widget := FinalStackBox
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment := vertical_alignment.Fill
            }
        )

        FinalOverlay : overlay = overlay{}
        for (Slot : array{
            overlay_slot{
                Widget := color_block{DefaultColor := OutlineColor}
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment := vertical_alignment.Fill
            }
            overlay_slot{
                Widget := GameOverlay
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment := vertical_alignment.Fill
                Padding := margin{Top := 30.0, Bottom := 30.0, Left := 30.0, Right := 30.0}
            }
        }){FinalOverlay.AddWidget(Slot)}

        AppleOverlay : overlay = overlay{}
        AppleSize := GridSize*1.0/8.0 * 50.0
        for (Slot : array{
            overlay_slot{
                Widget := color_block{DefaultColor := BarColor}
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment := vertical_alignment.Fill
            }
            overlay_slot{
                Widget := texture_block{DefaultImage := SnakeAssets.apple, DefaultDesiredSize := vector2{X := 50.0, Y := 50.0}}
                HorizontalAlignment := horizontal_alignment.Left
                VerticalAlignment := vertical_alignment.Top
                Padding := margin{Left := 23.0, Top := 16.0}
            }
            overlay_slot{
                Widget := AppleTextBlock
                HorizontalAlignment := horizontal_alignment.Left
                VerticalAlignment := vertical_alignment.Top
                Padding := margin{Left := 78.0, Top := 24.0}
            }
        }){AppleOverlay.AddWidget(Slot)}

        AppleTextBlock.SetText(CreateMessage("0"))

        SuperFinalOverlay : overlay = overlay{} 
        for (Slot : array{
            overlay_slot{
                Widget := AppleOverlay
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment := vertical_alignment.Fill
            }
            overlay_slot{
                Widget := FinalOverlay
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment := vertical_alignment.Fill
                Padding := margin{Top := 85.0}
            }
        }){SuperFinalOverlay.AddWidget(Slot)}

        FinalCanvas : canvas = canvas{}
        FinalCanvas.AddWidget(
            canvas_slot{
                Widget := SuperFinalOverlay
                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                Alignment := vector2{X := 0.5, Y := 0.5}
                Offsets := margin{Right := WindowSize*700.0, Bottom := WindowSize*785.0}
                }
            )
        return FinalCanvas

    EndGame()<suspends>:void=
        EndGameEvent.Signal()
        Sleep(2.0)
        RemoveUI(SnakeAgent)
        if (FC := player[SnakeAgent].GetFortCharacter[]):
            FC.ReleaseFromStasis()

    UpdateSnake():void=
        if (SnakeHead := MaybeSnakeHead?):
            var OldTailPosition : ?int2 = false
            var CurrentForTail : SnakeElement = SnakeHead
            loop:
                if (Next := CurrentForTail.Next?):
                    set CurrentForTail = Next
                else:
                    set OldTailPosition = option{CurrentForTail.Position}
                    break

            var Positions : []int2 = array{}
            var CurrentElement : SnakeElement = SnakeHead
            
            loop:
                set Positions = Positions + array{CurrentElement.Position}
                if (Next := CurrentElement.Next?):
                    set CurrentElement = Next
                else:
                    break

            NewHeadPosition : int2 = AdjustPosition(SnakeHead.Position, MovingDirection)
            
            var AppleEaten : logic = IsAppleEaten(NewHeadPosition)
            
            var BorderCollision : logic = false
            
            if (NewHeadPosition.X < 0):
                set BorderCollision = true
            if (NewHeadPosition.X > GridSize - 1):
                set BorderCollision = true
            if (NewHeadPosition.Y < 0):
                set BorderCollision = true
            if (NewHeadPosition.Y > GridSize - 2):
                set BorderCollision = true
            
            var CollisionDetected : logic = false
            if (BorderCollision = false):
                if (FirstBody := SnakeHead.Next?):
                    var CheckElement : SnakeElement = FirstBody
                    loop:
                        if (CheckElement.Position.X = NewHeadPosition.X and CheckElement.Position.Y = NewHeadPosition.Y):
                            set CollisionDetected = true
                            break
                        if (Next := CheckElement.Next?):
                            set CheckElement = Next
                        else:
                            break
            
            var GameWon : logic = IsGameWon()
            
            if (BorderCollision = true or CollisionDetected = true):
                spawn{EndGame()}
            else if (GameWon = true):
                spawn{EndGame()}
            else:
                set SnakeHead.Position = NewHeadPosition
                
                set CurrentElement = SnakeHead
                var PositionIndex : int = 0
                
                loop:
                    if (Next := CurrentElement.Next?):
                        if (PositionIndex >= 0, PositionIndex < Positions.Length):
                            if (OldPos := Positions[PositionIndex]):
                                set Next.Position = OldPos
                        set CurrentElement = Next
                        set PositionIndex = PositionIndex + 1
                    else:
                        break

                if (AppleEaten = true):
                    RemoveApple()
                    GrowSnakeAtPosition(OldTailPosition)
                    SpawnApple()
                else:
                    if (OldTailPos := OldTailPosition?):
                        if (OldTailPos.X >= 0 and OldTailPos.X < GridSize and OldTailPos.Y >= 0 and OldTailPos.Y < (GridSize-1)):
                            if (TailTile := Tiles[OldTailPos.X][OldTailPos.Y]?):
                                TailTile.SetImage(SnakeAssets.empty)

                UpdateAllSnakeTextures(false)

    UpdateAllSnakeTextures(FirstUpdate : logic):void=
        if (SnakeHead := MaybeSnakeHead?):
            var CurrentElement : SnakeElement = SnakeHead
            var PrevElement : ?SnakeElement = false
            
            loop:
                NextElement : ?SnakeElement = CurrentElement.Next
                var SnakeTexture : ?texture = false
                
                if (not PrevElement? and NextElement?):
                    if (FirstUpdate?):
                        set SnakeTexture = GetHeadTextureFromMovement(Direction.Right)
                    else:
                        set SnakeTexture = GetHeadTextureFromMovement(MovingDirection)
                else if (PrevElement? and not NextElement?):
                    if (PrevPos := PrevElement?.Position):
                        set SnakeTexture = GetImage(Part.Tail, option{PrevPos}, CurrentElement.Position, false)
                else if (PrevElement? and NextElement?):
                    if (PrevPos := PrevElement?.Position, NextPos := NextElement?.Position):
                        set SnakeTexture = GetImage(Part.Body, option{PrevPos}, CurrentElement.Position, option{NextPos})
                
                if (Texture := SnakeTexture?):
                    Pos := CurrentElement.Position
                    if (Pos.X >= 0 and Pos.X < GridSize and Pos.Y >= 0 and Pos.Y < (GridSize-1)):
                        if (Tile := Tiles[Pos.X][Pos.Y]?):
                            Tile.SetImage(Texture)
            
                if (Next := CurrentElement.Next?):
                    set PrevElement = option{CurrentElement}
                    set CurrentElement = Next
                else:
                    break
        
    MakeRow(Y : int):stack_box =
        RowStackBox : stack_box = stack_box{Orientation := orientation.Horizontal}
        for (X := 0..GridSize - 1):
            RowStackBox.AddWidget(
                stack_box_slot{
                    Widget := MakeTile(X, Y)
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Distribution := option{1.0}
                }
            )
        return RowStackBox

    MakeTile(X : int, Y : int):stack_box =
        var TileColor : color = LightColor
        if (Mod[X + Y, 2] = 0):
            set TileColor = DarkColor

        TileTexture : texture_block = texture_block{
            DefaultImage := SnakeAssets.empty
        }

        if{set Tiles[X][Y] = option{TileTexture}}

        TileSize := 280.0/(GridSize*1.0)
        TileOverlay : overlay = overlay{}
        for (Slot : array{
            overlay_slot{
                Widget := color_block{DefaultColor := TileColor, DefaultDesiredSize := vector2{X := TileSize, Y := TileSize}}
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment := vertical_alignment.Fill
            },
            overlay_slot{
                Widget := TileTexture
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment := vertical_alignment.Fill
            }
        }){TileOverlay.AddWidget(Slot)}

        TileStackBox : stack_box = stack_box{Orientation := orientation.Vertical}
        TileStackBox.AddWidget(
            stack_box_slot{
                Widget := TileOverlay
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment := vertical_alignment.Fill
                Distribution := option{1.0}
            }
        )
        return TileStackBox

AdjustPosition(Pos : int2, MovingDirection : Direction):int2=
    case(MovingDirection):
        Direction.Up => int2{X := Pos.X, Y := Pos.Y - 1}
        Direction.Down => int2{X := Pos.X, Y := Pos.Y + 1}
        Direction.Left => int2{X := Pos.X - 1, Y := Pos.Y}
        Direction.Right => int2{X := Pos.X + 1, Y := Pos.Y}
        Direction.None => Pos

GetImage(SnakePart : Part, MaybePrevious : ?int2, Current : int2, MaybeNext : ?int2)<transacts>:?texture=
    var DirFromPrev : ?Direction = false
    var DirToNext : ?Direction = false
    if (Previous := MaybePrevious?):
        set DirFromPrev = option{DirectionFromPositions(Previous, Current)}
    if (Next := MaybeNext?):
        set DirToNext = option{DirectionFromPositions(Current, Next)}
    if (SnakePart = Part.Head):
        return GetHeadTexture(DirToNext)
    else if (SnakePart = Part.Body):
        return GetBodyTexture(DirFromPrev, DirToNext)
    else if (SnakePart = Part.Tail):
        return GetTailTexture(DirFromPrev)
    return false

DirectionFromPositions(From : int2, To : int2)<transacts>:Direction=
    if (From.X = To.X):
        if (From.Y < To.Y):
            return Direction.Down
        else if (From.Y > To.Y):
            return Direction.Up
    else if (From.Y = To.Y):
        if (From.X < To.X):
            return Direction.Right
        else if (From.X > To.X):
            return Direction.Left
    return Direction.None

GetHeadTexture(DirToNext : ?Direction)<transacts>:?texture=
    if (GoingDirection : Direction = DirToNext?):
        case(GoingDirection):
            Direction.Up => return option{SnakeAssets.head_up}
            Direction.Down => return option{SnakeAssets.head_down}
            Direction.Left => return option{SnakeAssets.head_left}
            Direction.Right => return option{SnakeAssets.head_right}
            _ => return false
    return false

GetHeadTextureFromMovement(MovingDir : Direction)<transacts>:?texture=
    case(MovingDir):
        Direction.Up => return option{SnakeAssets.head_up}
        Direction.Down => return option{SnakeAssets.head_down}
        Direction.Left => return option{SnakeAssets.head_left}
        Direction.Right => return option{SnakeAssets.head_right}
        _ => return false

GetTailTexture(DirFromPrev : ?Direction)<transacts>:?texture=
    if (ComingDirection : Direction = DirFromPrev?):
        case(ComingDirection):
            Direction.Up => return option{SnakeAssets.tail_up}
            Direction.Down => return option{SnakeAssets.tail_down}
            Direction.Left => return option{SnakeAssets.tail_left}
            Direction.Right => return option{SnakeAssets.tail_right}
            _ => return false
    return false

GetBodyTexture(DirFromPrev : ?Direction, DirToNext : ?Direction)<transacts>:?texture=
    if (FromDirection : Direction = DirFromPrev?, ToDirection : Direction = DirToNext?):
        if (FromDirection = Direction.Up and ToDirection = Direction.Up):
            return option{SnakeAssets.body_vertical}
        else if (FromDirection = Direction.Down and ToDirection = Direction.Down):
            return option{SnakeAssets.body_vertical}
        else if (FromDirection = Direction.Left and ToDirection = Direction.Left):
            return option{SnakeAssets.body_horizontal}
        else if (FromDirection = Direction.Right and ToDirection = Direction.Right):
            return option{SnakeAssets.body_horizontal}
        else if (FromDirection = Direction.Up and ToDirection = Direction.Left):
            return option{SnakeAssets.body_bottomleft}
        else if (FromDirection = Direction.Left and ToDirection = Direction.Up):
            return option{SnakeAssets.body_topright}
        else if (FromDirection = Direction.Up and ToDirection = Direction.Right):
            return option{SnakeAssets.body_bottomright}
        else if (FromDirection = Direction.Right and ToDirection = Direction.Up):
            return option{SnakeAssets.body_topleft}
        else if (FromDirection = Direction.Down and ToDirection = Direction.Left):
            return option{SnakeAssets.body_topleft}
        else if (FromDirection = Direction.Left and ToDirection = Direction.Down):
            return option{SnakeAssets.body_bottomright}
        else if (FromDirection = Direction.Down and ToDirection = Direction.Right):
            return option{SnakeAssets.body_topright}
        else if (FromDirection = Direction.Right and ToDirection = Direction.Down):
            return option{SnakeAssets.body_bottomleft}
        else:
            return option{SnakeAssets.body_horizontal}
    return false



