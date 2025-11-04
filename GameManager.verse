
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Colors }

TextForUI<localizes>(Text: string) : message = "{Text}"

AddCommas<public>(Amount : int):string=
    Str := ToString(Amount)
    var Output : string = ""
    for(X := 1..Str.Length):
        if(Mod[X-1,3]=0 and X <> 1):
            set Output = "," + Output
        if(Char := ToString(Str[Str.Length-X])):
            set Output = Char + Output
    return Output

# Class that holds all player data
agent_data<public> := class:

    # Game Stats
    var TotalMoney : float = 0.0
    var MoneyPerSecond : float = 0.0
    var Customers : int = 0
    var Orders : int = 0
    var OrdersPerTick : int = 0
    var Rebirths : int = 0
    var ItemsBought : int = 0
    var Level : int = 1
    var Indexes : []int = array{}

    # Pets
    var OwnedPets : []tuple(creative_prop, int) = array{}
    var ActivePetIndex : int = -1
    var bPetPlayingAnim : logic = false

    # Level Up Amounts
    var LevelUpAmounts : []int = array{20, 40, 60, 80, 100, 120}

    # Canvas
    var MainCanvas : canvas = canvas{}
    # Widgets
    var MoneyBlock : text_block = text_block {
        DefaultTextColor := MakeColorFromHex("#983F00"),
        DefaultJustification := text_justification.Center,
        DefaultTextSize := 25.0
        }
    var CustomerBlock : text_block = text_block {
        DefaultTextColor := MakeColorFromHex("#983F00"),
        DefaultJustification := text_justification.Center,
        DefaultTextSize := 25.0
        }
    var OrderBlock : text_block = text_block {
        DefaultTextColor := MakeColorFromHex("#983F00"),
        DefaultJustification := text_justification.Center,
        DefaultTextSize := 25.0
        }
    var RebirthBlock : text_block = text_block {
        DefaultTextColor := MakeColorFromHex("#983F00"),
        DefaultJustification := text_justification.Center,
        DefaultTextSize := 25.0
        }
    var MultBlock : text_block = text_block {
        DefaultTextColor := MakeColorFromHex("#983F00"),
        DefaultJustification := text_justification.Center,
        DefaultTextSize := 25.0
        }
    var LevelBlock : text_block = text_block {DefaultTextColor := White}
    var LevelLabel : text_block = text_block {
        DefaultTextColor := MakeColorFromHex("#983F00"),
        DefaultJustification := text_justification.Center,
        DefaultTextSize := 25.0
        }
    var LevelLabel2 : text_block = text_block {DefaultTextColor := LightSeaGreen}
    var MessageText : text_block = text_block {DefaultTextColor := White}
    var MessageText2 : text_block = text_block {DefaultTextColor := White}
    var MoneyText : text_block = text_block {
        DefaultTextColor := MakeColorFromHex("#00e649ff"), 
        DefaultJustification:=text_justification.Center, 
        DefaultShadowColor:= Black
    }
    var MessageTitle : text_block = text_block {DefaultTextColor := White}
    var MessageBackground : texture_block = texture_block{DefaultImage := Images.MessageBackground, DefaultDesiredSize:=vector2{X:=900.0,Y:=300.0}}
    var Helper : texture_block = texture_block{DefaultImage := Images.HelperRender, DefaultDesiredSize:=vector2{X:=80.0,Y:=72.0}}
    var LevelBackground : color_block = color_block{
        DefaultColor := Black
        DefaultOpacity := 0.3
    }
    var Background : texture_block = texture_block{
        DefaultImage := Images.IMG_CurrenciesWidget
        # DefaultDesiredSize:=vector2{X:=978.0,Y:=213.0}
    }
    var Background2 : color_block = color_block{
        DefaultColor := Black
        DefaultOpacity := 0.3
    }
    var Background3 : color_block = color_block{
        DefaultColor := Black
        DefaultOpacity := 0.3
    }
    var Background4 : color_block = color_block{
        DefaultColor := Black
        DefaultOpacity := 0.3
    }
    var Background5 : color_block = color_block{
        DefaultColor := Black
        DefaultOpacity := 0.3
    }
    var MoneyBackground : color_block = color_block{
        DefaultColor := DarkGreen
        DefaultOpacity := 0.5
    }

    # Makes and adds UI to player
    Initialize(GoldCounter : conditional_button_device, ItemRemover : item_remover_device, Agent : agent, StatDev : stat_creator_device):void=
        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            set MainCanvas = MakeUI()
            PlayerUI.AddWidget(MainCanvas)
            GoldAmount := GoldCounter.GetItemCount(Agent, 0)
            if(GoldAmount > 0):
                set Rebirths = GoldCounter.GetItemCount(Agent, 0)
                ItemRemover.Remove(Agent)
            MessageBackground.SetVisibility(widget_visibility.Hidden)
            Helper.SetVisibility(widget_visibility.Hidden)
            MessageText.SetVisibility(widget_visibility.Hidden)
            MessageText2.SetVisibility(widget_visibility.Hidden) 
            MoneyText.SetVisibility(widget_visibility.Hidden) 
            MoneyBackground.SetVisibility(widget_visibility.Hidden) 
            MessageTitle.SetVisibility(widget_visibility.Hidden)
            
            # Hide old level display (now using stat creator)
            LevelBlock.SetVisibility(widget_visibility.Hidden)      # "Level: X"
            # LevelLabel shows money/s - keep it visible!
            LevelLabel2.SetVisibility(widget_visibility.Hidden)      # "Progress: X%"
            LevelBackground.SetVisibility(widget_visibility.Hidden)
            
            # Initialize stat device with ItemsBought as XP
            if (StatDev.SetValue[Agent, ItemsBought]):
                Print("Stat device initialized with XP: {ItemsBought}")
        spawn:
            IncrementStats()
        spawn:
            IncrementOrders()
        spawn:
            UpdateWidgets()

    # Makes the UI for a player
    MakeUI() : canvas = 
        NewUI : canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                    Offsets := margin{Top := -355.0, Left := 100.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    SizeToContent := false
                    Widget := LevelBlock
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 1.0, Y := 0.5}, Maximum := vector2{X := 1.0, Y := 0.5}}
                    Offsets := margin{Top := 196.0, Left := -88.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := LevelLabel
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                    Offsets := margin{Top := -300.0, Left := 100.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    SizeToContent := false
                    Widget := LevelLabel2
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                    Offsets := margin{Top := -380.0, Left := 50.0, Right := 350.0, Bottom := 200.0}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    SizeToContent := false
                    Widget := LevelBackground
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.0}, Maximum := vector2{X := 0.5, Y := 0.0}}
                    Offsets := margin{Top := 116.0, Left := -360.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := MoneyBlock
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.0}, Maximum := vector2{X := 0.5, Y := 0.0}}
                    Offsets := margin{Top := 116.0, Left := -180.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := CustomerBlock
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.0}, Maximum := vector2{X := 0.5, Y := 0.0}}
                    Offsets := margin{Top := 116.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := OrderBlock
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.0}, Maximum := vector2{X := 0.5, Y := 0.0}}
                    Offsets := margin{Top := 116.0, Left := 180.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := RebirthBlock
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.0}, Maximum := vector2{X := 0.5, Y := 0.0}}
                    Offsets := margin{Top := 116.0, Left := 360.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := MultBlock
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.0}, Maximum := vector2{X := 0.5, Y := 0.0}}
                    Offsets := margin{Top := 106.0, Left := 0.0, Right := 978.0, Bottom := 213.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := false
                    Widget := Background
                # canvas_slot:
                #     Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                #     Offsets := margin{Top := -5.0, Left := 115.0, Right := 350.0, Bottom := 50.0}
                #     Alignment := vector2{X := 0.0, Y := 0.0}
                #     SizeToContent := false
                #     Widget := Background2
                # canvas_slot:
                #     Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                #     Offsets := margin{Top := 45.0, Left := 115.0, Right := 250.0, Bottom := 50.0}
                #     Alignment := vector2{X := 0.0, Y := 0.0}
                #     SizeToContent := false
                #     Widget := Background3
                # canvas_slot:
                #     Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                #     Offsets := margin{Top := 95.0, Left := 115.0, Right := 200.0, Bottom := 50.0}
                #     Alignment := vector2{X := 0.0, Y := 0.0}
                #     SizeToContent := false
                #     Widget := Background4
                # canvas_slot:
                #     Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                #     Offsets := margin{Top := 145.0, Left := 115.0, Right := 250.0, Bottom := 50.0}
                #     Alignment := vector2{X := 0.0, Y := 0.0}
                #     SizeToContent := false
                #     Widget := Background5
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 1.0, Y := 1.0}, Maximum := vector2{X := 1.0, Y := 1.0}}
                    Offsets := margin{Top := -550.0, Left := -1400.0, Right := 900.0, Bottom := 350.0}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    SizeToContent := false
                    Widget := MessageBackground
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 1.0, Y := 1.0}, Maximum := vector2{X := 1.0, Y := 1.0}}
                    Offsets := margin{Top := 0.0, Left := 0.0, Right := 480.0, Bottom := 432.0}
                    Alignment := vector2{X := 1.0, Y := 1.0}
                    SizeToContent := false
                    ZOrder := 2
                    Widget := Helper
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 1.0, Y := 1.0}, Maximum := vector2{X := 1.0, Y := 1.0}}
                    Offsets := margin{Top := -390.0, Left := -1230.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    SizeToContent := false
                    Widget := MessageText
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 1.0, Y := 1.0}, Maximum := vector2{X := 1.0, Y := 1.0}}
                    Offsets := margin{Top := -320.0, Left := -1230.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    SizeToContent := false
                    Widget := MessageText2
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 1.0, Y := 1.0}, Maximum := vector2{X := 1.0, Y := 1.0}}
                    Offsets := margin{Top := -510.0, Left := -1310.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    SizeToContent := false
                    Widget := MessageTitle    
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := -20.0, Left := 150.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := false
                    Widget := MoneyText     
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 0.0, Left := 150.0, Right := 200.0, Bottom := 50.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := false
                    Widget := MoneyBackground           

    UpdateWidgets()<suspends>:void=
        loop:
            Sleep(0.1)
            if(NewAmount := Floor[TotalMoney]):
                MoneyBlock.SetText(TextForUI("${AddCommas(NewAmount)}"))
            if(NewAmount := Floor[MoneyPerSecond]):
                LevelLabel.SetText(TextForUI("+ ${AddCommas(NewAmount)}/S"))
            CustomerBlock.SetText(TextForUI("{AddCommas(Customers)}"))
            OrderBlock.SetText(TextForUI("{AddCommas(Orders)}"))
            RebirthBlock.SetText(TextForUI("{AddCommas(Rebirths)}"))
            if(Mult := (Floor[(Rebirths*0.2)*100])):
                MultBlock.SetText(TextForUI("{AddCommas(Mult)}%"))
            LevelBlock.SetText(TextForUI("Level: {Level}"))
            if(Precent := Floor[ItemsBought*1.0/143.0*100.0]):
                LevelLabel2.SetText(TextForUI("Progress: {Precent}%"))

    
    
    IncrementStats()<suspends>:void=
        loop:
            set TotalMoney += MoneyPerSecond
            set Customers += Orders
            Sleep(1.0)

    IncrementOrders()<suspends>:void=
        loop:
            set Orders += OrdersPerTick
            Sleep(10.0)

    AddItems(Amount : int, Index : int):void=
        set ItemsBought += Amount
        set Indexes += array{Index}
        for(LevelUpAmount : LevelUpAmounts):
            if(ItemsBought = LevelUpAmount):
                LevelUp()
    
    LevelUp():void=
        set Level += 1
        if(Level = 2):
            set MoneyPerSecond = 5.0
        else if(Level = 3):
            set MoneyPerSecond = 20.0
        else if(Level = 4):
            set MoneyPerSecond = 50.0
        else if(Level = 5):
            set MoneyPerSecond = 100.0
        else if(Level = 6):
            set MoneyPerSecond = 300.0
        else if(Level = 7):
            set MoneyPerSecond = 750.0
        Mult := Rebirths*0.2 + 1.0
        set MoneyPerSecond *= Mult

    # Shows the current message
    ShowMessage(Message : string, Message2 : string, Type : int, Dur : float, CurAudio : audio_player_device, Agent : agent)<suspends>:void=
        loop:
            IsVisible := MessageText.GetVisibility()
            if(IsVisible = widget_visibility.Visible):
                Sleep(1.0)
            else:
                break
        MessageText.SetText(TextForUI(Message))
        MessageText2.SetText(TextForUI(Message2))
        MessageTitle.SetText(TextForUI("Helper"))
        CurAudio.Play(Agent)
        Helper.SetVisibility(widget_visibility.Visible)
        MessageBackground.SetVisibility(widget_visibility.Visible)
        MessageText.SetVisibility(widget_visibility.Visible)
        MessageText2.SetVisibility(widget_visibility.Visible)
        MessageTitle.SetVisibility(widget_visibility.Visible)
        # Sleep(300.0)
        Sleep(Dur)
        Helper.SetVisibility(widget_visibility.Hidden)
        MessageBackground.SetVisibility(widget_visibility.Hidden)
        MessageText.SetVisibility(widget_visibility.Hidden)
        MessageText2.SetVisibility(widget_visibility.Hidden)
        MessageTitle.SetVisibility(widget_visibility.Hidden)


    # Vars and methods for showing money gained
    var MoneyToShow : int = 0
    var MoneyTimer : float = 0.0
    var IsTimerActive : logic = false
    ShowMoney(Amount : int):void=
        spawn:
            ShowNewMoneyWidget(Amount)
        if(IsTimerActive = false):
            set IsTimerActive = true
            spawn{StartMoneyTimer()}
        set MoneyTimer = 1.5
        set MoneyToShow += Amount
        MoneyText.SetText(TextForUI("💵  +${MoneyToShow}"))
        MoneyText.SetVisibility(widget_visibility.Visible)
        MoneyBackground.SetVisibility(widget_visibility.Visible)

    StartMoneyTimer()<suspends>:void=
        loop:
            Sleep(0.5)
            if(MoneyTimer = 0.0):
                set IsTimerActive = false
                MoneyText.SetVisibility(widget_visibility.Hidden)
                MoneyBackground.SetVisibility(widget_visibility.Hidden)
                set MoneyToShow = 0
                break
            else:
                set MoneyTimer -= 0.5

    
    ShowNewMoneyWidget(Amount : int)<suspends>:void=
        var NewWidget : text_block = text_block {
            DefaultTextColor := MakeColorFromHex("#00e649ff"), 
            DefaultJustification := text_justification.Center
        }
        NewWidget.SetText(TextForUI("💵  +${Amount}"))

        var YValue : float = -50.0
        var Opacity : float = 1.0
        loop:
            Sleep(0.0)
            if(YValue < -100.0):
                MainCanvas.RemoveWidget(NewWidget)
                break
            set YValue -= 1.5
            set Opacity -= 0.02
            MainCanvas.RemoveWidget(NewWidget)
            NewWidget.SetVisibility(widget_visibility.Hidden)
            if (AdjustedOpacity := type{_X:float where 0.000000 <= _X, _X <= 1.000000}[Opacity]): 
                NewWidget.SetTextOpacity(AdjustedOpacity)
            MainCanvas.AddWidget(
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                Offsets := margin{Top := YValue, Left := 150.0, Right := 0.0, Bottom := 0.0}
                Alignment := vector2{X := 0.5, Y := 0.5}
                SizeToContent := false
                Widget := NewWidget
            )
            NewWidget.SetVisibility(widget_visibility.Visible)

            
    
    # Resets all data for the agent and removes the UI
    ResetData(Agent : agent):void=
        set TotalMoney = 0.0
        set MoneyPerSecond = 0.0
        set Customers = 0
        set Orders = 0
        set OrdersPerTick = 0
        set ItemsBought = 0
        set Indexes = array{}
        set Rebirths += 1
        set OwnedPets = array{}
        set ActivePetIndex = -1
        set bPetPlayingAnim = false
        set Level = 1

MakePlayerProfileData<constructor>(Src:player_profile_data)<transacts> := player_profile_data:
    Version := Src.Version
    TotalMoney := Src.TotalMoney
    MoneyPerSecond := Src.MoneyPerSecond
    Customers := Src.Customers
    Orders := Src.Orders
    OrdersPerTick := Src.OrdersPerTick
    Rebirths := Src.Rebirths
    ItemsBought := Src.ItemsBought
    Level := Src.Level
    Indexes := Src.Indexes


player_profile_data := class<final><persistable>:
    Version:int = 0
    TotalMoney : float = 0.0
    MoneyPerSecond : float = 0.0
    Customers : int = 0
    Orders : int = 0
    OrdersPerTick : int = 0
    Rebirths : int = 0
    ItemsBought : int = 0
    Level : int = 1
    Indexes:[]int = array{}

var PlayerProfileDataMap:weak_map(player, player_profile_data) = map{}
    

# A Verse-authored creative device that can be placed in a level
game_manager<public> := class(creative_device):

    @editable ClassSelector : class_and_team_selector_device = class_and_team_selector_device{}
    @editable GoldCounter: conditional_button_device = conditional_button_device{}
    @editable ItemRemover: item_remover_device = item_remover_device{}
    @editable Granter : item_granter_device = item_granter_device{}
    @editable MessageAudios : []audio_player_device = array{}
    
    # Stat Creator for level/XP display (just like container tycoon)
    @editable
    StatDevice : stat_creator_device = stat_creator_device{}

    var IsLoading : logic = false
    var<public> AgentMap : [agent]agent_data = map{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for (Player : GetPlayspace().GetPlayers()):
            OnPlayerJoined(Player)
            
        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoined)
        
    # Runs when a player joins and changes the player to team 4 
    OnPlayerJoined(Agent: agent):void=
        if(set AgentMap[Agent] = agent_data{}):
            if(Ref := AgentMap[Agent]):
                Ref.Initialize(GoldCounter, ItemRemover, Agent, StatDevice)
            spawn:
                ChangeTeam(Agent)

    ChangeTeam(Agent: agent)<suspends>:void=
        loop:
            TeamCollection := GetPlayspace().GetTeamCollection()
            if (AgentsTeam := TeamCollection.GetTeam[Agent]):
                TeamArray := TeamCollection.GetTeams()
                for (TeamNumber->TeamRef : TeamArray):
                    if (AgentsTeam = TeamRef):
                         if(TeamNumber = 3):
                            break
            ClassSelector.ChangeTeam(Agent)
            Sleep(1.0)

    # Saves all the data of the agent
    SaveData(Agent:agent):void=
        if:
            CheckSaveDataForPlayer[Agent]
            Player := player[Agent]
            SourceData := PlayerProfileDataMap[Player]
            CurAgentMap := AgentMap[Agent]
        
            set PlayerProfileDataMap[Player] = player_profile_data:
                TotalMoney := CurAgentMap.TotalMoney
                MoneyPerSecond := CurAgentMap.MoneyPerSecond
                Customers := CurAgentMap.Customers
                Orders := CurAgentMap.Orders
                OrdersPerTick := CurAgentMap.OrdersPerTick
                Rebirths := CurAgentMap.Rebirths
                ItemsBought := CurAgentMap.ItemsBought
                Level := CurAgentMap.Level
                Indexes := CurAgentMap.Indexes
                MakePlayerProfileData<constructor>(SourceData)
            Print("Data Saved! Customers is now: {PlayerProfileDataMap[Player].Customers}")

    # Loads all data into the agent map
    LoadData(Agent:agent):void=
        set IsLoading = true
        if:
            CheckSaveDataForPlayer[Agent]
            Player := player[Agent]
            SourceData := PlayerProfileDataMap[Player]

            set AgentMap[Agent].TotalMoney = SourceData.TotalMoney
            set AgentMap[Agent].MoneyPerSecond = SourceData.MoneyPerSecond
            set AgentMap[Agent].Customers = SourceData.Customers
            set AgentMap[Agent].Orders = SourceData.Orders
            set AgentMap[Agent].OrdersPerTick = SourceData.OrdersPerTick
            set AgentMap[Agent].Rebirths = SourceData.Rebirths
            set AgentMap[Agent].ItemsBought = SourceData.ItemsBought
            set AgentMap[Agent].Level = SourceData.Level
            set AgentMap[Agent].Indexes = SourceData.Indexes
            
            # Sync loaded XP (ItemsBought) to stat device for progress display
            if (StatDevice.SetValue[Agent, SourceData.ItemsBought]):
                Print("Stat device synced with loaded XP: {SourceData.ItemsBought}")
            
            Print("Data Loaded! Player has bought {SourceData.ItemsBought} items")
            set IsLoading = false

    # Checks if the player has a PlayerProfileDataMap
    CheckSaveDataForPlayer(Agent:agent)<decides><transacts>:void=
        if(Player := player[Agent]):
            if(PlayerProfileDataMap[Player]):
                # no-op
            else:
                set PlayerProfileDataMap[Player] = player_profile_data{}
    
    # Adds specified amount of money to a player
    AddMoney(Amount : int, Agent : agent):void=
        if(set AgentMap[Agent].TotalMoney += Amount*1.0){}

    AddItemsBought(Amount : int, Index : int, Agent : agent):void=
        if(AgentRef := AgentMap[Agent]):
            AgentRef.AddItems(Amount, Index)
            # Update stat device with ItemsBought (XP) for progress tracking
            if (StatDevice.SetValue[Agent, AgentRef.ItemsBought]):
                Print("XP updated in stat device: {AgentRef.ItemsBought}")

    AddCustomers(Amount : int, Agent : agent):void=
        if(set AgentMap[Agent].Customers += Amount){}

    AddOrders(Amount : int, Agent : agent):void=
        if(set AgentMap[Agent].Orders += Amount){}

    AddOrdersPerTick(Amount : int, Agent : agent):void=
        if(set AgentMap[Agent].OrdersPerTick += Amount){}

    AddRebirths(Amount : int, Agent : agent):void=
        if(set AgentMap[Agent].Rebirths += Amount){}
    
    # Sets the MoneyPerSecond for a player
    SetMoneyPerSecond(Amount : int, Agent : agent):void=
        if(set AgentMap[Agent].MoneyPerSecond = Amount*1.0){}

    GetMoneyPerSecond(Agent : agent):float=
        if(Amount := AgentMap[Agent].MoneyPerSecond):
            return Amount
        return 0.0

    GetMoney(Agent : agent):float=
        if(Amount := AgentMap[Agent].TotalMoney):
            return Amount
        return 0.0

    GetCustomers(Agent : agent):int=
        if(Amount := AgentMap[Agent].Customers):
            return Amount
        return 0

    GetRebirths(Agent : agent):int=
        if(Amount := AgentMap[Agent].Rebirths):
            return Amount
        return 0

    GetItemsBought(Agent : agent):int=
        if(Amount := AgentMap[Agent].ItemsBought):
            return Amount
        return 0

    # Shows the current message
    ShowMessage(Message : string, Message2 : string, Type : int, Dur : float, Agent : agent)<suspends>:void=
        if(IsLoading = true):
            return
        if(AgentRef := AgentMap[Agent]):
            if(CurAudio := MessageAudios[0]):
                AgentRef.ShowMessage(Message, Message2, Type, Dur, CurAudio, Agent)

    # Displays a given amount of money being added
    ShowMoney(Amount : int, Agent : agent):void=
        if(AgentRef := AgentMap[Agent]):
            AgentRef.ShowMoney(Amount)
        

    # Resets all data and clears UI. Team is switched to 4
    Rebirth(Agent : agent):void=
        if(AgentRef := AgentMap[Agent]):
            AgentRef.ResetData(Agent)
            # Sync stat device after rebirth reset
            if (StatDevice.SetValue[Agent, 0]):
                Print("Stat device reset to 0 after rebirth")
        ClassSelector.ChangeTeam(Agent)
        


