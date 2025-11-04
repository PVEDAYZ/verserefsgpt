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
<#
###############################################################
#                                                             #
#    ____  _____ _   _____  _      _   _ _____ _____ _   _    #
#   |  _ \| ____| | |_   _|/ \    | | | | ____|  ___| \ | |   #
#   | | | |  _| | |   | | / _ \   | | | |  _| | |_  |  \| |   #
#   | |_| | |___| |___| |/ ___ \  | |_| | |___|  _| | |\  |   #
#   |____/|_____|_____|_/_/   \_\  \___/|_____|_|   |_| \_|   #
#                                                             #
###############################################################

INFO
DISCORD: https://discord.gg/deltauefn
YOUTUBE: https://www.youtube.com/@deltauefn
WEBSITE: https://deltauefn.com
PATREON: https://patreon.com/DeltaUEFN

***THIS CODE WAS CREATED BY @1jop ON 3/3/2025***
IF YOU PURCHASED THIS CODE PLEASE INFORM ME ON DISCORD @1jop

JOIN THE DELTA UEFN DISCORD FOR MORE FREE CODE
#>

Custom_Alive := class<unique>:
    @editable PlayersAlive : int = 0
    @editable PointsToGrant : int = 0

Points_Manager := class(creative_device):
    @editable PlayerPoints : stat_creator_device = stat_creator_device{}
    @editable FirstRound : round_settings_device = round_settings_device{}
    @editable EndGame : end_game_device = end_game_device{}
    @editable PointsElim : int = 0
    @editable VictoryTime : float = 1.0
    @editable var Levels : []Custom_Alive = array{}
    var NewLevels : []Custom_Alive = array{}
    EndGameWith1Player: logic = true
    var PlayerCount : int = 0
    var EndGameNow : logic = false

    OnBegin<override>()<suspends>:void =
        FirstRound.RoundBeginEvent.Subscribe(ResetPoints)
        InitAgents()
        InitLevels()
        Main()

    Main()<suspends>:void =
        GetPlayspace().PlayerRemovedEvent().Subscribe(PlayerRemoved)
        GetPlayspace().PlayerAddedEvent().Subscribe(PlayerAdded)

    InitLevels():void =
        set PlayerCount = CountPlayers()
        for (Level : Levels):
            if (PlayerCount > Level.PlayersAlive):
                set NewLevels += array{Level}

    CountPlayers():int =
        var Count : int = 0
        for (Player : GetPlayspace().GetPlayers(), FC := Player.GetFortCharacter[]):
            if:
                FC.IsActive[]
            then:
                set Count += 1
        return Count

    PlayerAdded(Agent : agent):void =
        if(FC := player[Agent].GetFortCharacter[]):
            if (FC.IsActive[]):
                FC.EliminatedEvent().Subscribe(PlayerEliminated)

    ResetPoints():void =
        for (Player : GetPlayspace().GetPlayers(), FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
            if{PlayerPoints.SetValue[Agent, 0]}

    InitAgents():void =
        for (Player : GetPlayspace().GetParticipants(), FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
            if (FC.IsActive[]):
                FC.EliminatedEvent().Subscribe(PlayerEliminated)

    PlayerRemoved(Player : player):void =
        NextCheck()

    PlayerEliminated(Result : elimination_result):void =
        EliminatingCharacter := Result.EliminatingCharacter
        EliminatedCharacter := Result.EliminatedCharacter
        if:
            EliminatingFortCharacter := EliminatingCharacter?
            EliminatingAgent := EliminatingFortCharacter.GetAgent[]
            EliminatedFortCharacter := EliminatedCharacter
            EliminatedAgent := EliminatedFortCharacter.GetAgent[]
            EliminatedAgent <> EliminatingAgent
        then:
            if:
                CurrentPoints := PlayerPoints.GetValue[EliminatingAgent]
                PlayerPoints.SetValue[EliminatingAgent, CurrentPoints + PointsElim]
        NextCheck()

    NextCheck():void =
        set PlayerCount = CountPlayers()
        CheckAmount()

    CheckAmount():void =
        if:
            Level := NewLevels[0]
            PlayerCount <= Level.PlayersAlive
        then:
            for (Player : GetPlayspace().GetPlayers(), FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
                if:
                    FC.IsActive[]
                    CurrentPoints := PlayerPoints.GetValue[Agent]
                    PlayerPoints.SetValue[Agent, CurrentPoints + Level.PointsToGrant]

            if (NewArray := NewLevels.RemoveElement[0]):
                set NewLevels = NewArray 
        if:
            EndGameWith1Player?
            PlayerCount = 1
        then:
            spawn{EndGameWinner()}
        
    EndGameWinner()<suspends>:void =
        set EndGameNow = true
        Sleep(VictoryTime)
        for (Player : GetPlayspace().GetPlayers(), FC := Player.GetFortCharacter[], Agent := FC.GetAgent[], FC.IsActive[]):
            EndGame.Activate(Agent)

                                        