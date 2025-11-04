using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }


EachP := class():
    Player: player
    var CurrentMaxShield : float
    var CurrentMaxHealth : float

SprintAndOvershield := class(creative_device):
    @editable OverShield : trigger_device = trigger_device{}
    @editable Sprint : trigger_device = trigger_device{}
    var SprintEnabled : logic = false
    var OvershieldEnabled : logic = false
    @editable NoSprintNoOvershield : class_and_team_selector_device = class_and_team_selector_device{}
    @editable NoSprintOvershield : class_and_team_selector_device = class_and_team_selector_device{}
    @editable SprintNoOvershield : class_and_team_selector_device = class_and_team_selector_device{}
    @editable SprintOvershield : class_and_team_selector_device = class_and_team_selector_device{}

    @editable PlayerSpawner : []player_spawner_device = array{}

    var PlayerMap : [player]EachP = map{}

    OnBegin<override>()<suspends>:void =

        for(Spawner:PlayerSpawner):
            Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

        OverShield.TriggeredEvent.Subscribe(ToggleOvershield)
        Sprint.TriggeredEvent.Subscribe(ToggleSprint)

        NoSprintNoOvershield.ClassSwitchedEvent.Subscribe(ChangeHealthAndShield)
        NoSprintOvershield.ClassSwitchedEvent.Subscribe(ChangeHealthAndShield)
        SprintNoOvershield.ClassSwitchedEvent.Subscribe(ChangeHealthAndShield)
        SprintOvershield.ClassSwitchedEvent.Subscribe(ChangeHealthAndShield)

        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeft)


    ChangeHealthAndShield(Agent:agent):void=
        if(Player := player[Agent], ExistingPlayer := PlayerMap[Player], FC := Agent.GetFortCharacter[]):
            FC.SetMaxShield(ExistingPlayer.CurrentMaxShield)
            FC.SetMaxHealth(ExistingPlayer.CurrentMaxHealth)

        
        
    ToggleOvershield(Agent : ?agent):void =
        if(NewAgent := Agent?):
            if(Player := player[NewAgent], PlayerExisting := PlayerMap[Player]):
                if(FC := NewAgent.GetFortCharacter[]):
                    CurrentMaxShield := FC.GetMaxShield()
                    CurrentMaxHealth := FC.GetMaxHealth()

                    set PlayerExisting.CurrentMaxShield = CurrentMaxShield
                    set PlayerExisting.CurrentMaxHealth = CurrentMaxHealth

                    if (OvershieldEnabled?):
                        set OvershieldEnabled = false
                    else:
                        set OvershieldEnabled = true
                    SwitchPlayers()

               
                

    ToggleSprint(Agent : ?agent):void =
        if(NewAgent := Agent?):
            if(Player := player[NewAgent], PlayerExisting := PlayerMap[Player]):
                if(FC := NewAgent.GetFortCharacter[]):

                    CurrentMaxShield := FC.GetMaxShield()
                    CurrentMaxHealth := FC.GetMaxHealth()

                    set PlayerExisting.CurrentMaxShield = CurrentMaxShield
                    set PlayerExisting.CurrentMaxHealth = CurrentMaxHealth

                    if (SprintEnabled?):
                        set SprintEnabled = false
                    else:
                        set SprintEnabled = true
                    SwitchPlayers()

                  


    SwitchPlayers():void =
        for (Player : GetPlayspace().GetPlayers(), FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
            if (SprintEnabled? and OvershieldEnabled?):
                SprintOvershield.ChangeClass(Agent)
            else if (not SprintEnabled? and OvershieldEnabled?):
                NoSprintOvershield.ChangeClass(Agent)
            else if (SprintEnabled? and not OvershieldEnabled?):
                SprintNoOvershield.ChangeClass(Agent)
            else if (not SprintEnabled? and not OvershieldEnabled?):
                NoSprintNoOvershield.ChangeClass(Agent)


    OnPlayerSpawned(Agent:agent):void =
        if:
            Player := player[Agent]
            not EachP[Player]
            FC := Agent.GetFortCharacter[]
        then:
            if(set PlayerMap[Player] = EachP{Player := Player, CurrentMaxShield:=  FC.GetMaxShield(), CurrentMaxHealth := FC.GetMaxHealth()}):

    OnPlayerLeft(Agent:agent):void=
        if(Player := player[Agent]):
            RemoveKeyFromMap(PlayerMap, Player)


    RemoveKeyFromMap(OgMap:[player]EachP, Player:player):[player]EachP=
        var NewMap:[player]EachP = map{}
       
        for (Key -> Value : OgMap, Key <> Player):
            set NewMap = ConcatenateMaps(NewMap, map{Key => Value})
        return NewMap



