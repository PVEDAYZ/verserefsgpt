using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }

glass_bridge := class(creative_device):

    @editable
    var PropManipulatorsLeft : []prop_manipulator_device = array{}
    
    @editable
    var PropManipulatorsRight : []prop_manipulator_device = array{}

    @editable
    var MutatorZonesLeft : []mutator_zone_device = array{}

    @editable
    var MutatorZonesRight : []mutator_zone_device = array{}

    var Distance : int = 0

    var CorrectSides : []int = array{}

    OnBegin<override>()<suspends> : void =
        CheckPicks()
        SetSides()

    SetSides():void =
        for (Index : int = 0..MutatorZonesLeft.Length-1):
            CorrectSide := GetRandomInt(0,1)
            Print("{CorrectSide}")
            set CorrectSides += array{CorrectSide}

    CheckPicks(): void =
        for (Index : int = 0..MutatorZonesLeft.Length - 1):
            if(MutatorZone := MutatorZonesLeft[Index]):
                MutatorZone.AgentEntersEvent.Subscribe(parameter(int){Arg:= Index, Func:= PickSideLeft}.Invoke)
        for (Index : int = 0..MutatorZonesRight.Length - 1):
            if(MutatorZone := MutatorZonesRight[Index]):
                MutatorZone.AgentEntersEvent.Subscribe(parameter(int){Arg:= Index, Func:= PickSideRight}.Invoke)
    
    PickSideLeft(Agent:agent, Index : int): void =
        if (CorrectSides[Index] = 1):
            #side is right -> wrong side
            if(NewProp := PropManipulatorsLeft[Index]):
                NewProp.HideProps()
            set Distance += 1
        else:
            #side is left -> correct side
            set Distance += 1


    PickSideRight(Agent:agent, Index : int): void =
        if (CorrectSides[Index] = 0):
            #side is left -> wrong side
            if(NewProp := PropManipulatorsRight[Index]):
                NewProp.HideProps()
            set Distance += 1
        else:
            #side is right -> correct side
            set Distance += 1
            
parameter(t:type) := class:
    Arg: t
    Func:type{_(:agent, :t):void}
    Invoke(Agent:agent):void = Func(Agent,Arg)          


        
