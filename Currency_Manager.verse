
using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Simulation }


Player_Currency := class():
    Player : player

    var Currency1 : float = 0.0
    var Currency2 : float = 0.0

    Currency1TextBlock : text_block = text_block{DefaultTextColor := White, DefaultShadowOpacity := 1.0, DefaultShadowColor := Black}
    Currency2TextBlock : text_block = text_block{DefaultTextColor := White, DefaultShadowOpacity := 1.0, DefaultShadowColor := Black}

    Initialize() : void=
        SetUpUI()
        UpdateCurrencyUI()


    CollectCurrency(CurrencyName : string , CurrencyAmount : float) : void=
        if(CurrencyName = "Currency1"):
            set Currency1 += CurrencyAmount
        else if(CurrencyName = "Currency2"):
            set Currency2 += CurrencyAmount

        UpdateCurrencyUI()

    SpendCurrency(CurrencyName : string , CurrencyAmount : float) : logic=
        if(CurrencyName = "Currency1"):
            if(Currency1 >= Abs(CurrencyAmount)):
                set Currency1 += CurrencyAmount
                UpdateCurrencyUI()
                return true
            else:
                return false
        else if(CurrencyName = "Currency2"):
            if(Currency2 >= Abs(CurrencyAmount)):
                set Currency2 += CurrencyAmount
                UpdateCurrencyUI()
                return true
            else:
                return false
        return false


    StringToMessage<localizes>(String : string) : message = "{String}"


    MakeRoundedMessage(Amount : float) : message=
        var TempAmount : float = Amount
        var FinalSuffix : string = ""
        Suffixes : []string = array{"" , "K" , "M" , "B" , "T", "Qa"}
        if:
            Magnitude := Int[Log(10.0, TempAmount)] * 1.0
            SuffixIndex := Int[Magnitude/3.0]

            NewSuffix := Suffixes[SuffixIndex]
            set FinalSuffix = NewSuffix

            Divisor := Pow(10.0 , SuffixIndex * 3.0)
            set TempAmount /= Divisor
        then:

            var AmountAsString : string = ToString(TempAmount)
            if:
                DotIndex := AmountAsString.Find['.']
                FinalString := AmountAsString.Slice[0,DotIndex + 2]
            then:
                return StringToMessage("{FinalString}{FinalSuffix}")

        return StringToMessage("0.0")

        



    

    UpdateCurrencyUI() : void=
        Currency1TextBlock.SetText(MakeRoundedMessage(Currency1))
        Currency2TextBlock.SetText(MakeRoundedMessage(Currency2))


    SetUpUI() : void=
        Currency1ImageBlock : texture_block = texture_block{DefaultImage := MoneyUINew}
        Currency2ImageBlock : texture_block = texture_block{DefaultImage := CarrotUI}

        if(PlayerUI := GetPlayerUI[Player]):
            NewCanvas : canvas = canvas{
                Slots := array:
                    canvas_slot:
                        Widget := Currency1TextBlock
                        Anchors := anchors{Minimum := vector2{X := 0.0 , Y := 1.0}, Maximum := vector2{X := 0.0 , Y := 1.0}}
                        Offsets := margin{Left := 115.0, Top := -370.0, Right := 165.0 , Bottom := 41.0}
                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                        SizeToContent := false
                        ZOrder := 0
                    canvas_slot:
                        Widget := Currency2TextBlock
                        Anchors := anchors{Minimum := vector2{X := 0.0 , Y := 1.0}, Maximum := vector2{X := 0.0 , Y := 1.0}}
                        Offsets := margin{Left := 115.0, Top := -490.0, Right := 165.0 , Bottom := 41.0}
                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                        SizeToContent := false
                        ZOrder := 0
                    canvas_slot:
                        Widget := Currency1ImageBlock
                        Anchors := anchors{Minimum := vector2{X := 0.0 , Y := 1.0}, Maximum := vector2{X := 0.0 , Y := 1.0}}
                        Offsets := margin{Left := -80.0, Top := -500.0, Right := 500.0 , Bottom := 300.0}
                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                        SizeToContent := false
                        ZOrder := 0
                    canvas_slot:
                        Widget := Currency2ImageBlock
                        Anchors := anchors{Minimum := vector2{X := 0.0 , Y := 1.0}, Maximum := vector2{X := 0.0 , Y := 1.0}}
                        Offsets := margin{Left := -80.0, Top := -620.0, Right := 500.0 , Bottom := 300.0}
                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                        SizeToContent := false
                        ZOrder := 0
            }
            PlayerUI.AddWidget(NewCanvas)



CurrencyAdder := class<concrete>():
    var CurrencyManager : Currency_Manager = Currency_Manager{}
    @editable ActivateTrigger : trigger_device = trigger_device{}
    @editable SuccessfulSpendTrigger : trigger_device = trigger_device{}
    @editable CurrencyName : string = ""
    @editable ChangeAmount : float = 0.0

    Activate(MAgent : ?agent) : void=
        if(Agent := MAgent?):
            if(PC := CurrencyManager.PlayerCurrencyMap[Agent]):
                if(ChangeAmount < 0.0):
                    IsSuccessful := PC.SpendCurrency(CurrencyName, ChangeAmount)
                    if(IsSuccessful?):
                        SuccessfulSpendTrigger.Trigger(Agent)
                else:
                    PC.CollectCurrency(CurrencyName, ChangeAmount)



Currency_Manager := class(creative_device):

    @editable PlayerSpawners : []player_spawner_device = array{}

    @editable CurrencyAdders : []CurrencyAdder = array{}

    var PlayerCurrencyMap : [player]Player_Currency = map{}

    OnBegin<override>()<suspends>:void=
        for(PS : PlayerSpawners):
            PS.SpawnedEvent.Subscribe(OnSpawned)


        for(CA : CurrencyAdders):
            set CA.CurrencyManager = Self
            CA.ActivateTrigger.TriggeredEvent.Subscribe(CA.Activate)


    OnSpawned(Agent : agent) : void=
        if(Player := player[Agent]):
            if:
                not PlayerCurrencyMap[Player]
                set PlayerCurrencyMap[Player] = Player_Currency{Player := Player}
                PC := PlayerCurrencyMap[Player]
            then:
                PC.Initialize()