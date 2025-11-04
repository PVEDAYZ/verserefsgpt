
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/FortPlayerUtilities }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
InstantRespawnSetting := class<concrete>():

    @editable TeleportDevice : teleporter_device = teleporter_device{}
    @editable TeamIndex : int = 0
   

GameSetting := enum:
    OneVOne
    FFA

InstantRespawn := class(creative_device):

    var ArrayOfTeleporter : []teleporter_device = array{}
    @editable GameMode : GameSetting = GameSetting.FFA

    @editable ElimManager : elimination_manager_device = elimination_manager_device{}
    @editable InstantRespawnSettings : []InstantRespawnSetting = array{}
   
    
    OnBegin<override>()<suspends>:void=
        if (GameMode = GameSetting.OneVOne):
            SetEliminationAwaitOneVOne()

        if (GameMode = GameSetting.FFA):
            SetEliminationAwaitFFA()



    SetEliminationAwaitFFA():void=
        spawn{WaitAnEliminatedFFA()}


    WaitAnEliminatedFFA()<suspends>:void=
        loop:
            set ArrayOfTeleporter = array{}
            EliminatedAgent := ElimManager.EliminatedEvent.Await()

            for(Element:InstantRespawnSettings):
                set ArrayOfTeleporter += array{Element.TeleportDevice}

            RandomInt :=  GetRandomInt(0, ArrayOfTeleporter.Length-1)

            Sleep(0.1)
            if(EliminatedAgent.Respawn(ArrayOfTeleporter[RandomInt].GetTransform().Translation, rotation{})):
                Sleep(0.02)
                if(TeleporterSelected := ArrayOfTeleporter[RandomInt]):
                    TeleporterSelected.Teleport(EliminatedAgent)
            else:
                Print("Error: Respawn failed")


       

    SetEliminationAwaitOneVOne():void=
        spawn{WaitAnEliminatedEvent()}

    
            

    WaitAnEliminatedEvent()<suspends>:void=
        loop:
            EliminatedAgent := ElimManager.EliminatedEvent.Await()
            EliminationAgent := ElimManager.EliminationEvent.Await()
            if(TeamIndexEliminated := GetPlayspace().GetTeamCollection().GetTeams().Find[GetPlayspace().GetTeamCollection().GetTeam[EliminatedAgent]]):
                for(Element:InstantRespawnSettings):
                    TeamIndex := Element.TeamIndex -1
                    if(TeamIndexEliminated = TeamIndex):
                        Sleep(0.1)
                        EliminatedAgent.Respawn(Element.TeleportDevice.GetTransform().Translation, rotation{})
                        Sleep(0.02)
                        Element.TeleportDevice.Teleport(EliminatedAgent)
                    else:
                        Print("Error: TeamIndex not found")

            if(TeamIndexElimination := GetPlayspace().GetTeamCollection().GetTeams().Find[GetPlayspace().GetTeamCollection().GetTeam[EliminationAgent?]]):
                for(Element:InstantRespawnSettings):
                    TeamIndex := Element.TeamIndex -1
                    if(TeamIndexElimination = TeamIndex):
                        if(AgentElimination := EliminationAgent?):
                            Sleep(0.1)
                            AgentElimination.Respawn(Element.TeleportDevice.GetTransform().Translation, rotation{})
                            Sleep(0.02)
                            Element.TeleportDevice.Teleport(AgentElimination)
                    else:
                        Print("Error: TeamIndex not found")
