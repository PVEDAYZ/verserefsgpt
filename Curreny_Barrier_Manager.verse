
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }

#Custom Player Class that holds values for each player
Custom_Player := class<unique>():
    Player : player
    var Currency1 : int = 0
    var UnlockedBarriers : []int = array{}
    var CurrencyTB : text_block = text_block{}

    #Initializes the players ui
    Initialize() : void=
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.AddWidget(CreateUI())
    
    #Creates the Main Hud UI
    CreateUI() : canvas =   
        MyCanvas: canvas = canvas:
            Slots := array:
                canvas_slot:   
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                    Offsets := margin{Left := 105.0, Top := 0.0, Right := 170.0, Bottom := 45.0}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    SizeToContent := false
                    Widget := CurrencyTB


#Custom barrier class
Custom_Barrier := class<concrete>():
    @editable UnlockButton : button_device = button_device{}
    @editable Barrier : barrier_device = barrier_device{}
    @editable Cost : int = 0
    var Identifier : int = 0
    var CurrencyBarrierManager : Currency_Barrier_Manager = Currency_Barrier_Manager{}
    PersistenceManager : Persistence_Manager = Persistence_Manager{}

    StringToMessage<localizes>(String : string) : message = "{String}"

    Unlock(Agent:agent) : void=
        if(CP := CurrencyBarrierManager.PlayerMap[Agent], not CP.UnlockedBarriers.Find[Identifier]):
            if(CP.Currency1 >= Cost):
                set CP.UnlockedBarriers += array{Identifier}
                Barrier.AddToIgnoreList(Agent)
                PersistenceManager.UpdatePlayerStats(Agent, Identifier, "UnlockDoors")

                set CP.Currency1 -= Cost
                CP.CurrencyTB.SetText(StringToMessage("{CP.Currency1}"))
                PersistenceManager.UpdatePlayerStats(Agent, CP.Currency1, "Currency")





#Creative Device Class
Currency_Barrier_Manager := class(creative_device):

    #Player Map
    var PlayerMap : [player]Custom_Player = map{}
    PersistenceManager : Persistence_Manager = Persistence_Manager{}

    #Devices
    @editable IncreaseButton : button_device = button_device{}
    @editable DecreaseButton : button_device = button_device{}

    @editable AllBarriers : []Custom_Barrier = array{}

    #Initializes all subscribes
    OnBegin<override>()<suspends>:void=
        InitializeBarriers()
        
        for(Player : GetPlayspace().GetPlayers()){InitiatePlayer(Player)}
        GetPlayspace().PlayerAddedEvent().Subscribe(InitiatePlayer)

        IncreaseButton.InteractedWithEvent.Subscribe(IncreaseCurrency)
        DecreaseButton.InteractedWithEvent.Subscribe(DecreaseCurrency)

      

    #Initializes all custom barriers
    InitializeBarriers() : void=
        for(idx -> B : AllBarriers):
            set B.CurrencyBarrierManager = Self
            set B.Identifier = idx
            B.UnlockButton.InteractedWithEvent.Subscribe(B.Unlock)

    #Initializes the player into the playermap
    InitiatePlayer(Agent:agent): void=
        if(Player := player[Agent] , FC:= Agent.GetFortCharacter[]):    
            PersistenceManager.InitializePlayer(Player)
            if(PlayerExists := PlayerMap[Player]):     
            else:
                SavedPlayerStats := PersistenceManager.GetPlayerStats(Player)
                if(set PlayerMap[Player] = Custom_Player{       
                    Player := Player
                    Currency1 := SavedPlayerStats.Currency
                    UnlockedBarriers := SavedPlayerStats.UnlockDoors
                    }){}
                if(CP := PlayerMap[Player]):
                    CP.Initialize()
                    for(B : AllBarriers):
                        if(CP.UnlockedBarriers.Find[B.Identifier]):
                            B.Barrier.AddToIgnoreList(Player)



    StringToMessage<localizes>(String : string) : message = "{String}"
    
    #Increases the currency of a player and updates ui
    IncreaseCurrency(Agent:agent) : void=
        if(CP := PlayerMap[Agent]):
            set CP.Currency1 += 1
            CP.CurrencyTB.SetText(StringToMessage("{CP.Currency1}"))
            PersistenceManager.UpdatePlayerStats(Agent, CP.Currency1, "Currency")
        
    #Decreases the currency of a player and updates ui
    DecreaseCurrency(Agent:agent) : void=
        if(CP := PlayerMap[Agent]):
            set CP.Currency1 -= 1
            CP.CurrencyTB.SetText(StringToMessage("{CP.Currency1}"))
            PersistenceManager.UpdatePlayerStats(Agent, CP.Currency1, "Currency")
