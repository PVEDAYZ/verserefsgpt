using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }

STM<localizes>(String: string): message = "{String}"

TextBlocks := class:
    PinkBlock: text_block;
    WhiteBlock: text_block;

elim_counter_device := class(creative_device):
    var PinkElims: int = 0;
    var WhiteElims: int = 0;

    var TextBlockMap: [player]?TextBlocks = map {}

    @editable elim_manager_pink: elimination_manager_device = elimination_manager_device {}

    @editable elim_manager_white: elimination_manager_device = elimination_manager_device {}

    OnBegin<override>()<suspends>: void =
        Players := GetPlayspace().GetPlayers();
        for (Player : Players):
            CreateWidgetForPlayer(Player);

        GetPlayspace().PlayerAddedEvent().Subscribe(CreateWidgetForPlayer);
        elim_manager_pink.EliminationEvent.Subscribe(AddWhiteElim);
        elim_manager_white.EliminationEvent.Subscribe(AddPinkElim);

    AddPinkElim(Agent: ?agent): void =
        set PinkElims += 1;
        RefreshElims();

    AddWhiteElim(Agent: ?agent): void =
        set WhiteElims += 1;
        RefreshElims();

    RefreshElims(): void =
        for (TextBlock: TextBlockMap, ExistingBlock := TextBlock?):
            ExistingBlock.PinkBlock.SetText(STM(ToString(PinkElims)));
            ExistingBlock.WhiteBlock.SetText(STM(ToString(WhiteElims)));

    CreateWidgetForPlayer(Player: player): void =
        PinkBlock := text_block:
            DefaultText := STM(ToString(PinkElims))
            DefaultTextColor := Pink

        WhiteBlock := text_block:
            DefaultText := STM(ToString(WhiteElims))
            DefaultTextColor := White

        Blocks := TextBlocks:
            PinkBlock := PinkBlock
            WhiteBlock := WhiteBlock

        Root := canvas:
            Slots := array:
                # canvas_slot:
                    # Anchors := anchors { Minimum := vector2 { X := 0.5, Y := 0.0 }, Maximum := vector2 { X := 0.5, Y := 0.0 } }
                    # Alignment := vector2 { X := 0.5, Y := 0.0 }
                    # Offsets := margin { Left := 0.0, Top := 0.0, Right := 501.0, Bottom := 168.0 }
                    # SizeToContent := false
                    # Widget := texture_block:
                        # DefaultImage := WidgetUI.MapCodeTex

                canvas_slot:
                    Anchors := anchors { Minimum := vector2 { X := 0.5, Y := 0.0 }, Maximum := vector2 { X := 0.5, Y := 0.0 } }
                    Alignment := vector2 { X := 0.5, Y := 0.0 }
                    Offsets := margin { Left := -168.3, Top := 160.0 }
                    SizeToContent := true
                    Widget := PinkBlock

                canvas_slot:
                    Anchors := anchors { Minimum := vector2 { X := 0.5, Y := 0.0 }, Maximum := vector2 { X := 0.5, Y := 0.0 } }
                    Alignment := vector2 { X := 0.5, Y := 0.0 }
                    Offsets := margin { Left := 168.3, Top := 160.0 }
                    SizeToContent := true
                    Widget := WhiteBlock

        if (PlayerUI := GetPlayerUI[Player]):
            PlayerUI.AddWidget(Root);
            if (set TextBlockMap[Player] = option { Blocks }) { Print("Pink vs White elim count set up for player"); }
