
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Verse.org/Random }

RandomLoadouts := class(creative_device):

    @editable
    Weapon1Array : []item_granter_device = array{}

    @editable
    Weapon2Array : []item_granter_device = array{}

    @editable
    Weapon3Array : []item_granter_device = array{}

    @editable
    Weapon4Array : []item_granter_device = array{}

    @editable
    Weapon5Array : []item_granter_device = array{}

    OnBegin<override>()<suspends>:void=
        Playspace := GetPlayspace()
        AllPlayers := Playspace.GetPlayers()
        for(Player: AllPlayers, FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
            GenerateLoadout(Agent)

    GenerateLoadout(Agent:agent): void =
        RandomNum1 := GetRandomInt(0, Weapon1Array.Length -1)
        if (Granter := Weapon1Array[RandomNum1]):
            Granter.GrantItem(Agent)
        # RandomNum2 := GetRandomInt(0, Weapon2Array.Length -1)
        # if (Granter := Weapon2Array[RandomNum2]):
        #     Granter.GrantItem(Agent)
        # RandomNum3 := GetRandomInt(0, Weapon3Array.Length -1)
        # if (Granter := Weapon3Array[RandomNum3]):
        #     Granter.GrantItem(Agent)
        # RandomNum4 := GetRandomInt(0, Weapon4Array.Length -1)
        # if (Granter := Weapon4Array[RandomNum4]):
        #     Granter.GrantItem(Agent)
        # RandomNum5 := GetRandomInt(0, Weapon5Array.Length -1)
        # if (Granter := Weapon5Array[RandomNum5]):
        #     Granter.GrantItem(Agent)
