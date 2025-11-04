using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /Fortnite.com/Characters }
using { /Fortnite.com/FortPlayerUtilities }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/Game }

Phases:= enum:
    Top2
    Top4
    Top8
    Top16
    Top32

Custom_Teleporter := class<concrete>():
    @editable Teleporter : teleporter_device = teleporter_device{}
    var Index : int = 0

Tournament_System := class(creative_device):
    
    @editable Top32Teleporters : []Custom_Teleporter = array{}
    @editable Top16Teleporters : []Custom_Teleporter = array{}
    @editable Top8Teleporters : []Custom_Teleporter = array{}
    @editable Top4Teleporters : []Custom_Teleporter = array{}
    @editable Top2Teleporters : []Custom_Teleporter = array{}
    var GamePhase : Phases = Phases.Top32

    OnBegin<override>()<suspends>:void =
        InitGamePhase()
        TeleportToMap()
        spawn{PlayerAmountChanges()}

    InitGamePhase():void =
        AllPlayers := GetPlayspace().GetPlayers()
        if (AllPlayers.Length <= 2):
            set GamePhase = Phases.Top2
        else if (AllPlayers.Length <= 4):
            set GamePhase = Phases.Top4
        else if (AllPlayers.Length <= 8):
            set GamePhase = Phases.Top8
        else if (AllPlayers.Length <= 16):
            set GamePhase = Phases.Top16

    TeleportToMap():void =
        AllPlayers := GetPlayspace().GetPlayers()
        if:
            GamePhase = Phases.Top32
            AllPlayers = Shuffle(AllPlayers)
        then:
            for (Index -> T : Top32Teleporters):
                if:
                    CorrectPlayer := AllPlayers[Index]
                    FC := CorrectPlayer.GetFortCharacter[]
                    Agent := FC.GetAgent[]
                then:
                    T.Teleporter.Teleport(Agent)

        else if:
            GamePhase = Phases.Top16
            AllPlayers = Shuffle(AllPlayers)
        then:
            for (Index -> T : Top16Teleporters):
                if:
                    CorrectPlayer := AllPlayers[Index]
                    FC := CorrectPlayer.GetFortCharacter[]
                    Agent := FC.GetAgent[]
                then:
                    T.Teleporter.Teleport(Agent)

        else if:
            GamePhase = Phases.Top8
            AllPlayers = Shuffle(AllPlayers)
        then:
            for (Index -> T : Top8Teleporters):
                if:
                    CorrectPlayer := AllPlayers[Index]
                    FC := CorrectPlayer.GetFortCharacter[]
                    Agent := FC.GetAgent[]
                then:
                    T.Teleporter.Teleport(Agent)

        else if:
            GamePhase = Phases.Top4
            AllPlayers = Shuffle(AllPlayers)
        then:
            for (Index -> T : Top4Teleporters):
                if:
                    CorrectPlayer := AllPlayers[Index]
                    FC := CorrectPlayer.GetFortCharacter[]
                    Agent := FC.GetAgent[]
                then:
                    T.Teleporter.Teleport(Agent)
                
        else if:
            GamePhase = Phases.Top2
            AllPlayers = Shuffle(AllPlayers)
        then:
            for (Index -> T : Top2Teleporters):
                if:
                    CorrectPlayer := AllPlayers[Index]
                    FC := CorrectPlayer.GetFortCharacter[]
                    Agent := FC.GetAgent[]
                then:
                    T.Teleporter.Teleport(Agent)
        
    PlayerAmountChanges()<suspends>:void =
        loop: 
            if (GamePhase = Phases.Top32):
                if (GetPlayspace().GetPlayers().Length = 16):
                    set GamePhase = Phases.Top16
                    TeleportToMap()
            if (GamePhase = Phases.Top16):
                if (GetPlayspace().GetPlayers().Length = 8):
                    set GamePhase = Phases.Top8
                    TeleportToMap()
            if (GamePhase = Phases.Top8):
                if (GetPlayspace().GetPlayers().Length = 4):
                    set GamePhase = Phases.Top4
                    TeleportToMap()
            if (GamePhase = Phases.Top4):
                if (GetPlayspace().GetPlayers().Length = 2):
                    set GamePhase = Phases.Top2
                    TeleportToMap()
            Sleep(1.0)

            

            
        
    
        
