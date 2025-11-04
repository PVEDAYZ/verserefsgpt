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

#index 0 -> class 1 = medic, only one that can revive
#index 1 -> class 2 = assassin, press button to become invis for set time
#index 2 -> class 3 = explosive, press button to explode buildings near you
#index 3 -> class 4 = trooper, extra damage
#index 4 -> class 5 = hulk class, invincible for time

Custom_Teleporter := class<concrete>():
    @editable Teleporter : teleporter_device = teleporter_device{}
    var Index : int = 0

Role_System := class(creative_device):
    var AgentAbilityMap : [agent]int = map{}
    var AgentOnCooldownMap : [agent]logic = map{}
    @editable AllTeleporters : []Custom_Teleporter = array{}
    @editable ClassSelectors : []class_and_team_selector_device = array{}
    @editable DBNO : down_but_not_out_device = down_but_not_out_device{}
    @editable InvisTime : float = 10.0
    @editable AssassinCooldown : float = 20.0
    @editable AssassinCooldownTimer : timer_device = timer_device{}
    @editable RemoteManager : signal_remote_manager_device = signal_remote_manager_device{}
    @editable DamageAmp : damage_amplifier_powerup_device = damage_amplifier_powerup_device{}
    @editable TrooperTime : float = 5.0
    @editable TrooperCooldownTimer : timer_device = timer_device{}
    @editable TrooperCooldown : float = 15.0
    @editable InvincibleTime : float = 5.0
    @editable InvincibleCooldown : float = 20.0
    @editable InvincibleCooldownTimer : timer_device = timer_device{}
    @editable CooldownMessage : hud_message_device = hud_message_device{}


    OnBegin<override>()<suspends>:void =
        GameStart()

    GameStart():void =
        Print("starting")
        CheckTeleporters()
        RemoteManager.PrimarySignalEvent.Subscribe(FireAbility)
        for (Player : GetPlayspace().GetPlayers(), FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
            if {set AgentOnCooldownMap[Agent] = false}

    FireAbility(Agent:agent):void =
        Print("firing ability")
        if(AgentOnCooldownMap[Agent] = false):
            Print("not on cooldown")
            if(AgentAbilityMap[Agent] = 1):
                spawn{AssassinAbility(Agent)}
            if(AgentAbilityMap[Agent] = 2):
                spawn{DamageAmpAbility(Agent)}
            if(AgentAbilityMap[Agent] = 3):
                spawn{HulkAbility(Agent)}
        else:
            CooldownMessage.Show(Agent)

    DamageAmpAbility(Agent:agent)<suspends>: void =
        if:
            FC := player[Agent].GetFortCharacter[]
            set AgentOnCooldownMap[Agent] = true
        then:
            DamageAmp.SetDuration(TrooperTime)
            DamageAmp.Pickup(Agent)
            TrooperCooldownTimer.SetMaxDuration(TrooperCooldown)
            TrooperCooldownTimer.Start(Agent)
            Sleep(TrooperCooldown)
            if{set AgentOnCooldownMap[Agent] = false}
        
    HulkAbility(Agent:agent)<suspends>:void =
        if:
            FC := player[Agent].GetFortCharacter[]
            set AgentOnCooldownMap[Agent] = true
        then:
            FC.SetVulnerability(false)
            Sleep(InvincibleTime)
            FC.SetVulnerability(true)
            InvincibleCooldownTimer.SetMaxDuration(InvincibleCooldown)
            InvincibleCooldownTimer.Start(Agent)
            Sleep(InvincibleCooldown)
            if{set AgentOnCooldownMap[Agent] = false}

    AssassinAbility(Agent:agent)<suspends>:void =
        if:
            FC := player[Agent].GetFortCharacter[]
            set AgentOnCooldownMap[Agent] = true
        then:
            FC.Hide()
            Sleep(InvisTime)
            FC.Show()
            AssassinCooldownTimer.SetMaxDuration(AssassinCooldown)
            AssassinCooldownTimer.Start(Agent)
            Sleep(AssassinCooldown)
            if{set AgentOnCooldownMap[Agent] = false}

    CheckTeleporters():void =
        for (Index -> T: AllTeleporters):
            T.Teleporter.EnterEvent.Subscribe(parameter(int){Arg:= Index, Func:= ChangeRoleAndClass}.Invoke)
            
    ChangeRoleAndClass(Agent : agent, Index : int):void =
        if:
            set AgentAbilityMap[Agent] = Index
            S := ClassSelectors[Index]
            Print("changed to index {Index}")
        then:
            S.ChangeClass(Agent)
        
parameter(t:type) := class:
    Arg: t
    Func:type{_(:agent, :t):void}
    Invoke(Agent:agent):void = Func(Agent,Arg)          

        