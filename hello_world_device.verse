using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }


chained_device := class(creative_device):
    @editable Buttons : []button_device = array{}
    @editable InvitePopup : popup_dialog_device = popup_dialog_device{}
    @editable UnchainPopup : popup_dialog_device = popup_dialog_device{}

    var PlayerButton : [player]button_device = map{}

    var PlayerChained : [player][]player = map{}
    var PlayerChained01 : [player]player = map{}
    var PlayerChained02 : [player]player = map{}
    var PlayerChained03 : [player]player = map{}
    var PlayerChained04 : [player]player = map{}

    @editable Blueprint : creative_prop_asset = DefaultCreativePropAsset

    var PlayerInvite : [player]agent = map{}

    OnBegin<override>()<suspends>:void=
        
        InvitePopup.RespondingButtonEvent.Subscribe(OnRespondingButtonEvent)

        for(Button:Buttons):
            Button.InteractedWithEvent.Subscribe(OnInteractedWithButton)
            
        for(Index -> Player:GetPlayspace().GetPlayers()):
            spawn{ShowInterface(Player)}
            SetPlayerButton(Player,Index)
            spawn{TeleportButton(Player)}
               
    OnRespondingButtonEvent(Agent:agent,Index:int):void=
        if(Index=0):
            if(Player:=player[Agent]):
                if(Duo:=player[PlayerInvite[Player]]):
                    spawn{ChainedFunction(Player,Duo)}

    StringToMessage<localizes>(String : string) : message = "{String}"
    
    ShowInterface(Player:player)<suspends>:void=
        if(set PlayerChained[Player] = array{}):

        if(Agent := agent[Player]):


        Tex01 := texture_block{DefaultImage:=Textures.Character_Graphic,DefaultDesiredSize:=vector2{X:=50.0,Y:=50.0}}
        Tex02 := texture_block{DefaultImage:=Textures.Character_Graphic,DefaultDesiredSize:=vector2{X:=50.0,Y:=50.0}}
        Tex03 := texture_block{DefaultImage:=Textures.Character_Graphic,DefaultDesiredSize:=vector2{X:=50.0,Y:=50.0}}
        Tex04 := texture_block{DefaultImage:=Textures.Character_Graphic,DefaultDesiredSize:=vector2{X:=50.0,Y:=50.0}}
        Interface:canvas=canvas:
            Slots:=array:
                canvas_slot:
                    Widget:=text_block{DefaultText:=StringToMessage("00:00")}
                    Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=1.0},Maximum:=vector2{X:=0.5,Y:=1.0}}
                    Alignment := vector2{X:=0.5,Y:=0.5}
                    Offsets := margin{Top:=-145.0}
                canvas_slot:
                    Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=1.0},Maximum:=vector2{X:=0.5,Y:=1.0}}
                    Alignment := vector2{X:=0.5,Y:=0.5}
                    Offsets := margin{Top:=-200.0}
                    SizeToContent := true
                    Widget := stack_box:
                        Orientation:=orientation.Horizontal
                        Slots:=array:
                            stack_box_slot:
                                Widget:=Tex01
                            stack_box_slot:
                                Widget:=Tex02
                            stack_box_slot:
                                Widget:=Tex03
                            stack_box_slot:
                                Widget:=Tex04

        if(PlayerUI := GetPlayerUI[Player]){PlayerUI.AddWidget(Interface)}
            loop:
                Sleep(0.1)
                if(PlayerChained[Player].Length = 0):
                    Tex01.SetVisibility(widget_visibility.Visible)
                    Tex01.SetDesiredSize(vector2{X:=50.0,Y:=50.0})
                    Tex02.SetVisibility(widget_visibility.Hidden)
                    Tex02.SetDesiredSize(vector2{X:=0.0,Y:=0.0})
                    Tex03.SetVisibility(widget_visibility.Hidden)
                    Tex03.SetDesiredSize(vector2{X:=0.0,Y:=0.0})
                    Tex04.SetVisibility(widget_visibility.Hidden)
                    Tex04.SetDesiredSize(vector2{X:=0.0,Y:=0.0})
                if(PlayerChained[Player].Length = 1):
                    Tex02.SetVisibility(widget_visibility.Visible)
                    Tex02.SetDesiredSize(vector2{X:=50.0,Y:=50.0})
                    Tex03.SetVisibility(widget_visibility.Hidden)
                    Tex03.SetDesiredSize(vector2{X:=0.0,Y:=0.0})
                    Tex04.SetVisibility(widget_visibility.Hidden)
                    Tex04.SetDesiredSize(vector2{X:=0.0,Y:=0.0})
                if(PlayerChained[Player].Length = 2):
                    Tex03.SetVisibility(widget_visibility.Visible)
                    Tex03.SetDesiredSize(vector2{X:=50.0,Y:=50.0})
                    Tex04.SetVisibility(widget_visibility.Hidden)
                    Tex04.SetDesiredSize(vector2{X:=0.0,Y:=0.0})
                if(PlayerChained[Player].Length = 3):
                    Tex04.SetVisibility(widget_visibility.Visible)
                    Tex04.SetDesiredSize(vector2{X:=50.0,Y:=50.0})


    ChainedFunction(Player01:player,Player02:player)<suspends>:void=
        if(Fortchar01:=Player01.GetFortCharacter[],Fortchar02:=Player02.GetFortCharacter[]):
            spawn{func(Fortchar01,Fortchar02)}

        if(set PlayerChained[Player01] += array{Player02}):
        if(set PlayerChained[Player02] += array{Player01}):
            
        if(PlayerChained[Player01].Length = 0):
            if(set PlayerChained01[Player01] = Player02):
        if(PlayerChained[Player01].Length = 1):
            if(set PlayerChained02[Player01] = Player02):
        if(PlayerChained[Player01].Length = 2):
            if(set PlayerChained03[Player01] = Player02):
        if(PlayerChained[Player01].Length = 3):
            if(set PlayerChained04[Player01] = Player02):
                
        if(PlayerChained[Player02].Length = 0):
            if(set PlayerChained01[Player02] = Player01):
        if(PlayerChained[Player02].Length = 1):
            if(set PlayerChained02[Player02] = Player01):
        if(PlayerChained[Player02].Length = 2):
            if(set PlayerChained03[Player02] = Player01):
        if(PlayerChained[Player02].Length = 3):
            if(set PlayerChained04[Player02] = Player01):

        if (Prop := SpawnProp(Blueprint, vector3{}, IdentityRotation())(0)?):
            Prop.SetMesh(Meshes.SM_Indic)
            loop:
                if:
                    # Get the positions of the two players
                    PlayerPosition01 := Player01.GetFortCharacter[].GetTransform().Translation
                    PlayerPosition02 := Player02.GetFortCharacter[].GetTransform().Translation
                then:
                    # Calculate the direction vector between the two positions
                    DirectionVector := Normalize(vector3{X := PlayerPosition01.X - PlayerPosition02.X, Y := PlayerPosition01.Y - PlayerPosition02.Y, Z := PlayerPosition01.Z - PlayerPosition02.Z})

                    # Calculate yaw and pitch angles for rotation
                    YawAngle := ArcTan(DirectionVector.Y, DirectionVector.X) * 180.0 / PiFloat
                    PitchAngle := ArcTan(DirectionVector.Z, Sqrt(DirectionVector.X * DirectionVector.X + DirectionVector.Y * DirectionVector.Y)) * 180.0 / PiFloat
                    RollAngle := 0.0  # Roll is set to 0



                    # Calculate the distance between the two players
                    Distances := Sqrt((PlayerPosition01.X - PlayerPosition02.X) * (PlayerPosition01.X - PlayerPosition02.X) +
                                        (PlayerPosition01.Y - PlayerPosition02.Y) * (PlayerPosition01.Y - PlayerPosition02.Y) +
                                        (PlayerPosition01.Z - PlayerPosition02.Z) * (PlayerPosition01.Z - PlayerPosition02.Z))

                    # Adjust the scale of the barrier in the X direction based on the distance with a conversion factor
                    AdjustedScaleX := Distances / 100.0

                    # Move the barrier to the midpoint between the two players with the calculated rotation
                    var PropTransform : transform = Prop.GetTransform()
                    set PropTransform.Translation = vector3{X := (PlayerPosition01.X + PlayerPosition02.X) / 2.0, Y := (PlayerPosition01.Y + PlayerPosition02.Y) / 2.0, Z := (PlayerPosition01.Z + PlayerPosition02.Z) / 2.0}
                    set PropTransform.Scale = vector3{X:=AdjustedScaleX,Y:=PropTransform.Scale.Y,Z:=PropTransform.Scale.Z}
                    set PropTransform.Rotation = MakeRotationFromYawPitchRollDegrees(YawAngle, PitchAngle, RollAngle)
                    Prop.MoveTo(PropTransform,0.1)
                else:
                    Print("No other player found, retrying in 5 seconds",?Duration:=5.0)  # Print message
                    Prop.Dispose()
                    break


    # Function to normalize a vector
    Normalize(Vector: vector3): vector3=
        length := Sqrt(Vector.X * Vector.X + Vector.Y * Vector.Y + Vector.Z * Vector.Z)
        return vector3{X := Vector.X / length, Y := Vector.Y / length, Z := Vector.Z / length}



            
    StringToMessage<localizes>(Agent:agent) : message = "You have been invited by {Agent}, do you accept their invite?"
    
    OnInteractedWithButton(Agent:agent):void=
        if(FortChar:=Agent.GetFortCharacter[]):
            ClosestFortCharacter := GetClosestFortCharacter(FortChar)
            if(AgentTarget:=ClosestFortCharacter?.GetAgent[]):
                InvitePopup.SetDescriptionText(StringToMessage(Agent))
                InvitePopup.Show(AgentTarget)

                if(Player:=player[AgentTarget]):
                    if(set PlayerInvite[Player] = Agent):

    SetPlayerButton(Player:player,Index:int):void=
        Teams := GetPlayspace().GetTeamCollection().GetTeams()
        if (TeamToAssign := Teams[Index], GetPlayspace().GetTeamCollection().AddToTeam[Player, TeamToAssign]):
        if(ButtonToAssign := Buttons[Index], set PlayerButton[Player] = ButtonToAssign):

    GetClosestFortCharacter(FortChar:fort_character):?fort_character= 
        var Character : ?fort_character = false
        var SmallestValue : float = 1.7976931348623157e+308
        for(Player:GetPlayspace().GetPlayers(),EnemiesFortChar:=Player.GetFortCharacter[]):

            if(EnemiesFortChar<>FortChar):

                if(PlayerChained[Player].Length = 0):

                    if(z := Distance(EnemiesFortChar.GetTransform().Translation,FortChar.GetTransform().Translation) < SmallestValue):
                        set Character = option{EnemiesFortChar}
                        set SmallestValue = z

                if(PlayerChained[Player].Length = 1):
                    if(PlayerChained01[Player].GetFortCharacter[] <> EnemiesFortChar):
                        if(z := Distance(EnemiesFortChar.GetTransform().Translation,FortChar.GetTransform().Translation) < SmallestValue):
                            set Character = option{EnemiesFortChar}
                            set SmallestValue = z

        return Character

    TeleportButton(Player:player)<suspends>:void=
        if(FortChar:=Player.GetFortCharacter[]):
            loop:
                ClosestFortCharacter := GetClosestFortCharacter(FortChar)
                if(Button := PlayerButton[Player],Closest:=ClosestFortCharacter?):
                    Button.MoveTo(Closest.GetTransform().Translation,IdentityRotation(),0.1)
                else:
                    Sleep(0.1)











    func(Player01:fort_character,Player02:fort_character)<suspends>:void=
        spawn{PulledEvent(Player01,Player02)}
        Print("func")
        loop:
            Sleep(0.1)

            if(Distance(Player01.GetTransform().Translation,Player02.GetTransform().Translation) > MaxDistance):
                if(Agent:=Player01.GetAgent[]):
                    PullInput.Unregister(Agent)
                if(Agent:=Player02.GetAgent[]):
                    PullInput.Unregister(Agent)

                if(not Player01.IsFalling[] and not Player02.IsFalling[]):
                    if(Agent:=Player01.GetAgent[]):
                        PullPlayerFunction(Agent,Player02.GetTransform().Translation,Player01.GetTransform().Translation)
                    if(Agent:=Player02.GetAgent[]):
                        PullPlayerFunction(Agent,Player01.GetTransform().Translation,Player02.GetTransform().Translation)

                if(Player01.IsFalling[] and not Player02.IsFalling[]):
                    if(Agent:=Player01.GetAgent[]):
                        PullPlayerFunction(Agent,Player02.GetTransform().Translation,Player01.GetTransform().Translation)

                if(not Player01.IsFalling[] and Player02.IsFalling[]):
                    if(Agent:=Player02.GetAgent[]):
                        PullPlayerFunction(Agent,Player01.GetTransform().Translation,Player02.GetTransform().Translation)

            if(Distance(Player01.GetTransform().Translation,Player02.GetTransform().Translation) < MaxDistance):

                if(not Player01.IsFalling[] and not Player02.IsFalling[]):
                    if(Agent:=Player01.GetAgent[]):
                        PullInput.Unregister(Agent)
                    if(Agent:=Player02.GetAgent[]):
                        PullInput.Unregister(Agent)
                if(Player01.IsFalling[] and not Player02.IsFalling[]):
                    if(Agent:=Player02.GetAgent[]):
                        PullInput.Register(Agent)

                if(not Player01.IsFalling[] and Player02.IsFalling[]):
                    if(Agent:=Player01.GetAgent[]):
                        PullInput.Register(Agent)


    @editable Impulse : movement_modulator_device = movement_modulator_device{}
    @editable MaxDistance : float = 500.0
    @editable PullInput : input_trigger_device = input_trigger_device{}


    PulledEvent(Player01:fort_character,Player02:fort_character)<suspends>:void=
        loop:
            Agent := PullInput.PressedEvent.Await()

            if(Agent.GetFortCharacter[] = Player01):
                if(IsAgent:=Player02.GetAgent[]):
                    PullPlayerFunction(IsAgent,Player01.GetTransform().Translation,Player02.GetTransform().Translation)

            if(Agent.GetFortCharacter[] = Player02):
                if(IsAgent:=Player01.GetAgent[]):
                    PullPlayerFunction(IsAgent,Player02.GetTransform().Translation,Player01.GetTransform().Translation)



        



    PullPlayerFunction(Agent:agent,PlayerPosition01:vector3,PlayerPosition02:vector3)<suspends>:void=
        DirectionVector := Normalize(vector3{X := PlayerPosition01.X - PlayerPosition02.X, Y := PlayerPosition01.Y - PlayerPosition02.Y, Z := PlayerPosition01.Z - PlayerPosition02.Z})
        # Calculate yaw and pitch angles for rotation
        YawAngle := ArcTan(DirectionVector.Y, DirectionVector.X) * 180.0 / PiFloat
        PitchAngle := ArcTan(DirectionVector.Z, Sqrt(DirectionVector.X * DirectionVector.X + DirectionVector.Y * DirectionVector.Y)) * 180.0 / PiFloat
        RollAngle := 0.0  # Roll is set to 0
        if(Impulse.TeleportTo[Impulse.GetTransform().Translation,MakeRotationFromYawPitchRollDegrees(YawAngle, PitchAngle, RollAngle)]):
            Impulse.Activate(Agent)