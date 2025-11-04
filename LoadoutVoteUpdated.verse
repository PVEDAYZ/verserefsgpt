using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using {/Fortnite.com/Teams}
using {/Verse.org/Simulation}
using {/Fortnite.com/Characters}
using {/Verse.org/Random}
using {/Fortnite.com/Game}
using {/Fortnite.com/FortPlayerUtilities}
using {/UnrealEngine.com/Temporary/SpatialMath}
 
Piececontrol := class(creative_device):

    @editable VoteTeleporters : []teleporter_device = array{}
    @editable ClassSelectors : []class_and_team_selector_device = array{}
    @editable WaitTime : float = 10.0
    @editable Billboards : []billboard_device = array{}
    var IndexCounted : int = 0
    var HighestIndex : int = 0
    var HighestValue : int = 0
    var VoteFrequencyMap : [int]int = map{}
    var VoteAgentMap : [agent]int = map{}
    var WinnerIndex : int = 0
    @editable Class99 : class_and_team_selector_device = class_and_team_selector_device{}

    OnBegin<override>()<suspends>:void=
        for (Player:GetPlayspace().GetPlayers(), FC := Player.GetFortCharacter[]):
            FC.EliminatedEvent().Subscribe(SpawnResetLoadout)
        spawn:
            VoteLogic()

    SpawnResetLoadout(Result : elimination_result):void =
        spawn:
            ResetLoadout()
        
    ResetLoadout()<suspends>:void =
        for (Player:GetPlayspace().GetPlayers(), FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
            Class99.ChangeClass(Agent)
            Sleep(0.5)
            if (CorrectSelector := ClassSelectors[WinnerIndex]):
                CorrectSelector.ChangeClass(Agent)
            
    VoteLogic()<suspends> : void =
        for (Index := 0..VoteTeleporters.Length - 1):
            if(VoteTeleporter := VoteTeleporters[Index]):
                VoteTeleporter.EnterEvent.Subscribe(parameter(int){Arg:= Index, Func:= PlayerVotes}.Invoke)

        Sleep(WaitTime)
        set WinnerIndex = CheckVotes()
        for (Player : GetPlayspace().GetPlayers()):
            if (CorrectClass := ClassSelectors[WinnerIndex]):
                CorrectClass.ChangeClass(Player)
    
    PlayerVotes(Agent : agent, Index : int): void =
        if:
            set VoteAgentMap[Agent] = Index
        UpdateBillBoards()
    
    CheckVotes(): int=
        set HighestValue = 0
        set HighestIndex  = 0
        var RandomInt : int = 0
        var SameNumberArray : []int = array{}
        for (Index -> Value : VoteFrequencyMap):
            if:
                Value > HighestValue
                set HighestValue = Value
                set HighestIndex = Index
        var Count : int = 0
        for (Index -> Value : VoteFrequencyMap):
            if (Value = HighestIndex):
                set Count += 1
                set SameNumberArray += array{Index}
        if (Count < 2):
            return HighestIndex
        else:
            set RandomInt = GetRandomInt(0,SameNumberArray.Length-1)
            return RandomInt

    GetVotes() : void =
        set VoteFrequencyMap = map{}
        for (Index := 0..Billboards.Length -1):

            if (set VoteFrequencyMap[Index] = 0):

        for (Agent -> IndexVoted : VoteAgentMap):
            if:
                set VoteFrequencyMap[IndexVoted] += 1

    UpdateBillBoards(): void =
        GetVotes()
        for (Index := 0..Billboards.Length -1):
            if:
                var Value : int = VoteFrequencyMap[Index]
                Billboard := Billboards[Index]
            then:
                Billboard.SetText(StringToMessage(ToString(Value)))
            

    
    StringToMessage<localizes>(IntValue : string): message = "{IntValue}"

parameter(t:type) := class:
    Arg: t
    Func:type{_(:agent, :t):void}
    Invoke(Agent:agent):void = Func(Agent,Arg)