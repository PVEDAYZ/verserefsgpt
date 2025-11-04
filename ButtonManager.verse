using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Colors/NamedColors }


# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# Car Tags
car1 := class(tag){}
car2 := class(tag){}
car3 := class(tag){}
car4 := class(tag){}

# Team tags
team1 := class(tag){}
team2 := class(tag){}
team3 := class(tag){}


button_trigger<public> := class<concrete>:

    @editable Price : int = 0
    @editable ResourceType : string = "Money"
    @editable Trigger : trigger_device = trigger_device{}
    @editable TriggersToShow : []trigger_device = array{}
    @editable ItemsToShow : []creative_prop = array{}
    @editable ItemsToHide : []creative_prop = array{}
    @editable ButtonsToShow : []button_device = array{}
    @editable MaybeDropper : ?dropper_device = false
    @editable ClaimDropper : logic = false
    @editable BuyPipe : logic = false
    @editable ItemSpawners : []item_spawner_device = array{}
    @editable SpecID : int = 0

    var GameManager : game_manager = game_manager{}
    var SuccessMessage : hud_message_device = hud_message_device{}
    var FailMessage : hud_message_device = hud_message_device{}
    var AccoladeDevice : accolades_device = accolades_device{}
    var RebirthButton : button_device = button_device{}
    var TeamTag : []tag = array{}
    var Index : int = 0

    # Reset
    Reset():void=
        for(Prop : ItemsToShow):
            HideProp(Prop)
        for(Trig : TriggersToShow):
            HideTrigger(Trig)
        for(Btn : ButtonsToShow):
            HideButton(Btn)
        for(Spawner: ItemSpawners):
            Spawner.Disable();

    # Initialize Button 
    InitButton(GM : game_manager, SuccMess : hud_message_device, FailMess : hud_message_device, Team : []tag, AccDevice : accolades_device, RebirthBtn : button_device, Idx : int):void=
        if(Idx <> 0):
            Trigger.TriggeredEvent.Subscribe(OnTriggered)
        set GameManager = GM
        set SuccessMessage = SuccMess
        set FailMessage = FailMess
        set AccoladeDevice = AccDevice
        set RebirthButton = RebirthBtn
        set TeamTag = Team
        set Index = Idx
        for(Prop : ItemsToShow):
            HideProp(Prop)
        for(Trig : TriggersToShow):
            HideTrigger(Trig)
        for(Btn : ButtonsToShow):
            HideButton(Btn)

        
    # When Trigger is pressed, this function activates
    OnTriggered(MaybeAgent : ?agent):void=
        if(Agent := MaybeAgent?, AgentData := GameManager.AgentMap[Agent]):
            var ToCheck : int = 0
            if(Temp := Floor[AgentData.TotalMoney]):
                set ToCheck = Temp
            if(ResourceType = "Customer"):
                set ToCheck = AgentData.Customers
            if(Price > ToCheck):                    #Failed
                FailMessage.Show(Agent)
            else:                                   #Success
                SuccessMessage.Show(Agent)
                AccoladeDevice.Award(Agent)
                GameManager.AddItemsBought(1, Index, Agent)
                Items := GameManager.GetItemsBought(Agent)
                if(Items >= 143):
                    ShowButton(RebirthButton)
                    spawn:
                        GameManager.ShowMessage("You've completed 100% progress! Rebirth", "has been unlocked at the front!", 0, 5.0, Agent)
                if(ResourceType = "Money"):
                    set AgentData.TotalMoney -= Price*1.0
                HideTrigger(Trigger)
                for(Trig : TriggersToShow):
                    Trig.Enable()
                    ShowTrigger(Trig)
                for(Prop : ItemsToShow):
                    ShowProp(Prop)
                for(Prop : ItemsToHide):
                    HideProp(Prop)
                for(Btn : ButtonsToShow):
                    ShowButton(Btn)  
                for(Spawner: ItemSpawners):
                    Spawner.Enable();
                    Spawner.SpawnItem();
                if(Dropper := MaybeDropper?):
                    if(ClaimDropper = true){Dropper.OnClaimerTriggered(MaybeAgent)}
                    if(BuyPipe = true){Dropper.OnPipeTriggered(MaybeAgent)}
                # Save data 
                GameManager.SaveData(Agent)
                # Special ID tag actions
                if(SpecID = 1):
                    if( Prop := vehicle_spawner_sedan_device[GetCreativeObjectsWithTags(tag_search_criteria:
                        RequiredTags := array{car1{}} + TeamTag
                    )[0]]):
                        Prop.Enable()
                else if(SpecID = 2):
                    if( Prop := vehicle_spawner_sportbike_device[GetCreativeObjectsWithTags(tag_search_criteria:
                        RequiredTags := array{car2{}} + TeamTag
                    )[0]]):
                        Prop.Enable()
                else if(SpecID = 3):
                    if( Prop := vehicle_spawner_sports_car_device[GetCreativeObjectsWithTags(tag_search_criteria:
                        RequiredTags := array{car3{}} + TeamTag
                    )[0]]):
                        Prop.Enable()
                else if(SpecID = 4):
                    if( Prop := vehicle_spawner_nitro_drifter_sedan_device[GetCreativeObjectsWithTags(tag_search_criteria:
                        RequiredTags := array{car4{}} + TeamTag
                    )[0]]):
                        Prop.Enable()
                else if(SpecID = 5):
                    GameManager.AddOrdersPerTick(1, Agent)
                    spawn:
                        GameManager.ShowMessage("Hire more workers to complete orders", "for you!", 0, 5.0, Agent)
                else if(SpecID = 6):
                    GameManager.AddOrdersPerTick(1, Agent)
                else if(SpecID = 7):
                    spawn:
                        GameManager.ShowMessage("Complete orders at the counter! More ", "orders = more customers!", 0, 5.0, Agent)
                else if(SpecID = 8):
                    spawn:
                        GameManager.ShowMessage("Dance at the advertising area to ", "attract more customers!", 0, 5.0, Agent)
                else if(SpecID = 9):
                    spawn:
                        GameManager.ShowMessage("Play cup pong for a chance to earn ", "15k! Each game costs $3,000!", 0, 5.0, Agent)
                else if(SpecID = 10):
                    spawn:
                        GameManager.ShowMessage("Fight monsters through the portal to  ", "get more cash!", 0, 5.0, Agent)

    # Called when loading data from previous save. Does some of the things as OnTriggered
    LoadButtonData(Agent : agent):void=
        for(Trig : TriggersToShow):
            Trig.Enable()
            ShowTrigger(Trig)
        for(Prop : ItemsToShow):
            ShowProp(Prop)
        for(Btn : ButtonsToShow):
            ShowButton(Btn)  
        for(Spawner: ItemSpawners):
            Spawner.Enable();
            Spawner.SpawnItem();
        if(Dropper := MaybeDropper?):
            if(ClaimDropper = true){Dropper.OnClaimerTriggered(option{Agent})}
            if(BuyPipe = true){Dropper.OnPipeTriggered(option{Agent})}
        
        # Check if rebirth button should be shown when loading data
        Items := GameManager.GetItemsBought(Agent)
        if(Items >= 143):
            ShowButton(RebirthButton)

        # Special IDs
        if(SpecID = 1):
            if( Prop := vehicle_spawner_sedan_device[GetCreativeObjectsWithTags(tag_search_criteria:
                RequiredTags := array{car1{}} + TeamTag
            )[0]]):
                Prop.Enable()
        else if(SpecID = 2):
            if( Prop := vehicle_spawner_sportbike_device[GetCreativeObjectsWithTags(tag_search_criteria:
                RequiredTags := array{car2{}} + TeamTag
            )[0]]):
                Prop.Enable()
        else if(SpecID = 3):
            if( Prop := vehicle_spawner_sports_car_device[GetCreativeObjectsWithTags(tag_search_criteria:
                RequiredTags := array{car3{}} + TeamTag
            )[0]]):
                Prop.Enable()
        else if(SpecID = 4):
            if( Prop := vehicle_spawner_nitro_drifter_sedan_device[GetCreativeObjectsWithTags(tag_search_criteria:
                RequiredTags := array{car4{}} + TeamTag
            )[0]]):
                Prop.Enable()

# A Verse-authored creative device that can be placed in a level
button_manager := class(creative_device):

    @editable GameManager : game_manager = game_manager{}
    @editable PlotManager : plot_manager = plot_manager{}
    @editable RebirthButton : button_device = button_device{}
    @editable ToHideOnRebirth : []creative_prop = array{}

    @editable Team : int = 1
    @editable SuccessMessage : hud_message_device = hud_message_device{}
    @editable FailMessage : hud_message_device = hud_message_device{}
    @editable AccoladeDevice : accolades_device = accolades_device{} 
    @editable RebirthAccolade : accolades_device = accolades_device{}
    @editable ButtonArray : []button_trigger = array{}

    var TeamTag : []tag = array{}
    var MainCanvas : canvas = canvas{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        if(Team = 1):
            set TeamTag = array{team1{}}
        else if(Team = 2):
            set TeamTag = array{team2{}}
        else if(Team = 3):
            set TeamTag = array{team3{}}
        var Index : int = 0
        for(b : ButtonArray):
            b.InitButton(GameManager, SuccessMessage, FailMessage, TeamTag, AccoladeDevice, RebirthButton, Index)
            set Index += 1
        # Set the claim trigger to initload
        if(ButtonArray[0].Trigger.TriggeredEvent.Subscribe(InitLoad)){}
        HideButton(RebirthButton)
        RebirthButton.InteractedWithEvent.Subscribe(OnRebirthInteract)
        GetPlayspace().PlayerRemovedEvent().Subscribe(Reset)

    # When the player presses on the claimer trigger, ask to either load data or start new
    InitLoad(MaybeAgent : ?agent):void=
        if(Agent := MaybeAgent?):
            if(Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
                GameManager.SetMoneyPerSecond(1, Player)
                if(PlayerProfileDataMap[Player]):
                    Print("Previous data detected")
                    set MainCanvas = MakeCanvas()
                    PlayerUI.AddWidget(MainCanvas, player_ui_slot{InputMode := ui_input_mode.All})
                else:
                    Print("New user")
                    PlotManager.OnClaimerTriggered(Player)
                    if(Button := ButtonArray[0]):
                        Button.OnTriggered(option{Player})
                    spawn:
                        PlotManager.StartMessages(Player)

    # Loads data from save 
    StartWithLoadedData(WM:widget_message):void=
        Player := WM.Player
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(MainCanvas)

        GameManager.LoadData(Player)
        PlotManager.OnClaimerTriggered(Player)
        # Check for 100% progress
        Items := GameManager.GetItemsBought(Player)
            if(Items = 143):
                ShowButton(RebirthButton)
                spawn:
                    GameManager.ShowMessage("You've completed 100% progress! Rebirth", "has been unlocked at the front!", 0, 5.0, Player)
        if(AgentData := GameManager.AgentMap[Player]):
            # Load the button data for all buttons
            for(Index : AgentData.Indexes):
                if(Button := ButtonArray[Index]):
                    Button.LoadButtonData(Player)
            # Hide the triggers that have been bought
            for(Index : AgentData.Indexes):
                if(Button := ButtonArray[Index]):
                    spawn{DelayHideTrigger(Button.Trigger)}
            if(AgentData.ItemsBought = 0):
                if(Button := ButtonArray[0]):
                    Button.OnTriggered(option{Player})
                GameManager.SetMoneyPerSecond(1, Player)
                spawn:
                    PlotManager.StartMessages(Player)

    # Starts without loading the saved data
    StartWithoutData(WM:widget_message):void=
        Player := WM.Player
        PlotManager.OnClaimerTriggered(Player)
        spawn:
            PlotManager.StartMessages(Player)
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(MainCanvas)
        
        if(Button := ButtonArray[0]):
            Button.OnTriggered(option{Player})

    DelayHideTrigger(Trig : trigger_device)<suspends>:void=
        Sleep(0.3)
        HideTrigger(Trig)


    MakeCanvas():canvas=
        LoadButton := button_loud{DefaultText:=TextForUI("Load")}
        LoadButton.OnClick().Subscribe(StartWithLoadedData)
        ResetButton := button_loud{DefaultText:=TextForUI("Reset")}  
        ResetButton.OnClick().Subscribe(StartWithoutData)
        # var Background : color_block = color_block{
        #     DefaultColor := White
        #     DefaultOpacity := 0.5
        #     DefaultDesiredSize:=vector2{X:=1220.0,Y:=670.0}
        # }
        var Img : texture_block = texture_block{DefaultImage := Images.IMG_SaveWindow, DefaultDesiredSize:=vector2{X:=585.0,Y:=550.0}}
        MyCanvas:= canvas:
            Slots:=array:
                # Background
                # canvas_slot:
                #     Anchors:=anchors{Minimum:=vector2{X:=0.5,Y:=0.5}, Maximum:=vector2{X:=0.5,Y:=0.5}}
                #     Offsets := margin{Left := 0.0, Top := -100.0, Right := 1220.0, Bottom := 670.0}
                #     Alignment:=vector2{X:=0.5,Y:=0.5}
                #     ZOrder:=0
                #     SizeToContent:=false
                #     Widget:=Background
                # Image
                canvas_slot:
                    Anchors:=anchors{Minimum:=vector2{X:=0.5,Y:=0.5}, Maximum:=vector2{X:=0.5,Y:=0.5}}
                    Offsets := margin{Left := 0.0, Top := 0.0, Right := 585.0, Bottom := 550.0}
                    Alignment:=vector2{X:=0.5,Y:=0.5}
                    ZOrder:=1
                    SizeToContent:=false
                    Widget:=Img
                # Load Button
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Left := -128.0, Top := 172.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    ZOrder := 2
                    SizeToContent := true
                    Widget := LoadButton
                # Reset Button
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Left := 120.0, Top := 172.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    ZOrder := 2
                    SizeToContent := true
                    Widget := ResetButton
                            
        return MyCanvas
    
    # Reset everything on the plot
    Reset(Agent : agent):void=
        var AgentTeamNum : int = 0
        TeamCollection := GetPlayspace().GetTeamCollection()
        if (AgentsTeam := TeamCollection.GetTeam[Agent]):
            TeamArray := TeamCollection.GetTeams()
            for (TeamNumber->TeamRef : TeamArray):
                if (AgentsTeam = TeamRef):
                    set AgentTeamNum = TeamNumber+1
        if(AgentTeamNum <> Team):
            return
        MaybeAgent : ?agent = option{Agent} 
        for(b : ButtonArray):
            b.Reset()
        for(prop : ToHideOnRebirth):
            HideProp(prop)

        HideButton(RebirthButton)
        DespawnVeicles()
        PlotManager.Reset(Agent)

    # If the player has 100,000 customers, then reset 
    OnRebirthInteract(Agent : agent):void=
        Amount := GameManager.GetCustomers(Agent)
        if(Amount >= 100000):
            Reset(Agent)
            GameManager.SaveData(Agent)
            RebirthAccolade.Award(Agent)
        else:
            FailMessage.Show(Agent)

    DespawnVeicles():void=
        if( Prop := vehicle_spawner_sedan_device[GetCreativeObjectsWithTags(tag_search_criteria:
            RequiredTags := array{car1{}} + TeamTag
        )[0]]):
            Prop.Disable()
        if( Prop := vehicle_spawner_sportbike_device[GetCreativeObjectsWithTags(tag_search_criteria:
            RequiredTags := array{car2{}} + TeamTag
        )[0]]):
            Prop.Disable()
        if( Prop := vehicle_spawner_sports_car_device[GetCreativeObjectsWithTags(tag_search_criteria:
            RequiredTags := array{car3{}} + TeamTag
        )[0]]):
            Prop.Disable()
        if( Prop := vehicle_spawner_nitro_drifter_sedan_device[GetCreativeObjectsWithTags(tag_search_criteria:
            RequiredTags := array{car4{}} + TeamTag
        )[0]]):
            Prop.Disable()

# Checks if a specified item is in an array
Contains(Arr : []trigger_device, Target : trigger_device):logic=
    for(Item : Arr):
        if(Item.GetTransform().Translation.X = Target.GetTransform().Translation.X and 
            Item.GetTransform().Translation.Y = Target.GetTransform().Translation.Y and
            Item.GetTransform().Translation.Z = Target.GetTransform().Translation.Z):
            return true
    return false

# Teleports the trigger underground
HideTrigger<public>(Trig : trigger_device):void=
    OldLoc := Trig.GetTransform().Translation
    Rotation := Trig.GetTransform().Rotation
    if(OldLoc.Z > 0.0):
        spawn:
            Trig.MoveTo(vector3{X := OldLoc.X, Y := OldLoc.Y, Z := OldLoc.Z-5000.0}, Rotation, 0.1)

# Teleports the trigger to original location
ShowTrigger<public>(Trig : trigger_device):void=
    OldLoc := Trig.GetTransform().Translation
    Rotation := Trig.GetTransform().Rotation
    if(OldLoc.Z < 0.0):
        spawn:
            Trig.MoveTo(vector3{X := OldLoc.X, Y := OldLoc.Y, Z := OldLoc.Z+5000.0}, Rotation, 0.1)

# Teleports the Prop underground
HideProp<public>(Prop : creative_prop):void=
        spawn:
            HideHelper(Prop)

HideHelper<public>(Prop : creative_prop)<suspends>:void=
    OldLoc := Prop.GetTransform().Translation
    Rotation := Prop.GetTransform().Rotation
    if(Prop.IsValid[] and OldLoc.Z > 0.0):
        Prop.Hide()
        Prop.MoveTo(vector3{X := OldLoc.X, Y := OldLoc.Y, Z := OldLoc.Z-5000.0}, Rotation, 0.1)
        Prop.Show()

# Teleports the Prop to original location
ShowProp<public>(Prop : creative_prop):void=
    OldLoc := Prop.GetTransform().Translation
    Rotation := Prop.GetTransform().Rotation
    if(Prop.IsValid[] and OldLoc.Z < 0.0):
        spawn:
            Prop.MoveTo(vector3{X := OldLoc.X, Y := OldLoc.Y, Z := OldLoc.Z+5000.0}, Rotation, 0.1)

HideButton<public>(Prop : button_device):void=
    OldLoc := Prop.GetTransform().Translation
    Rotation := Prop.GetTransform().Rotation
    if(OldLoc.Z > 0.0):
        spawn:
            Prop.MoveTo(vector3{X := OldLoc.X, Y := OldLoc.Y, Z := OldLoc.Z-5000.0}, Rotation, 0.1)

ShowButton<public>(Prop : button_device):void=
    OldLoc := Prop.GetTransform().Translation
    Rotation := Prop.GetTransform().Rotation
    if(OldLoc.Z < 0.0):
        spawn:
            Prop.MoveTo(vector3{X := OldLoc.X, Y := OldLoc.Y, Z := OldLoc.Z+5000.0}, Rotation, 0.1)

HideBarrier<public>(Prop : barrier_device):void=
    OldLoc := Prop.GetTransform().Translation
    Rotation := Prop.GetTransform().Rotation
    if(OldLoc.Z > 0.0):
        spawn:
            Prop.MoveTo(vector3{X := OldLoc.X, Y := OldLoc.Y, Z := OldLoc.Z-5000.0}, Rotation, 0.1)

ShowBarrier<public>(Prop : barrier_device):void=
    OldLoc := Prop.GetTransform().Translation
    Rotation := Prop.GetTransform().Rotation
    if(OldLoc.Z < 0.0):
        spawn:
            Prop.MoveTo(vector3{X := OldLoc.X, Y := OldLoc.Y, Z := OldLoc.Z+5000.0}, Rotation, 0.1)