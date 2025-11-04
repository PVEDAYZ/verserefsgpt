using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Native }


# The code was made by remu1337 -> for support and updates join our discord server -> discord.gg/uefndream 

Jail_Weapon := class(creative_device):

    @editable PlayerSpawner : []player_spawner_device = array{}
    @editable Weapons_Jail : []conditional_button_device = array{}
    @editable Jail_TP : teleporter_device = teleporter_device{}
    @editable Jail_HUD : hud_message_device = hud_message_device{}
    @editable Jail_Button : button_device = button_device{}
    @editable SkillDevice : skilled_interaction_device = skilled_interaction_device{}
    @editable ReturnTeleporter : teleporter_device = teleporter_device{}
    @editable ReturnHUDMessage : hud_message_device = hud_message_device{}
    @editable InteractionCountHUD : hud_message_device = hud_message_device{}


    @editable CooldownHUD : hud_message_device = hud_message_device{} # SETTINGS FOR DEVICE: MESSAGE: EMPTY, DISPLAY TIME: 1s, Message recipient: triggering player 
    @editable CooldownDuration : float = 15.0 

    var SkillSuccessCount : [agent]int = map{}
    var AgentCooldowns : [agent]float = map{}

    StringToMessage<localizes>(InString : string) : message = "{InString}" 

    OnBegin<override>()<suspends>: void=
        for(Spawner : PlayerSpawner):
            Spawner.SpawnedEvent.Subscribe(OnPlayerJoins)
        Jail_Button.InteractedWithEvent.Subscribe(OnButtonPressed)
        SkillDevice.InteractionSucceededEvent.Subscribe(OnSkillSuccess)

    OnPlayerJoins(Agent: agent): void=
        if(FC := Agent.GetFortCharacter[]):
            FC.DamagedEvent().Subscribe(OnPlayerDamaged)
            FC.DamagedShieldEvent().Subscribe(OnPlayerDamaged)

    OnPlayerDamaged(Result: damage_result): void=
        if:
            Instigator := Result.Instigator?
            InstigatorFC := fort_character[Instigator]
            InstigatorAgent := Instigator.GetInstigatorAgent[]
            DamagedFC := fort_character[Result.Target]
            DamagedAgent := DamagedFC.GetAgent[]
        then:
            var IsOnCooldown : logic = false
            if (CooldownTime := AgentCooldowns[InstigatorAgent], CooldownTime > 0.0):
                set IsOnCooldown = true
            if (IsOnCooldown = false):
                for(Weapon : Weapons_Jail):
                    if(Weapon.IsHoldingItem[InstigatorAgent]):
                        Jail_TP.Teleport(DamagedAgent)
                        Jail_HUD.Show(DamagedAgent)
                        if (set AgentCooldowns[InstigatorAgent] = CooldownDuration) {}
                        spawn{StartAgentCooldownCountdown(InstigatorAgent)}

    StartAgentCooldownCountdown(Agent:agent)<suspends>: void=
        var RemainingTime : int = 0
        if (TimeInt := Int[CooldownDuration]):
            set RemainingTime = TimeInt
        else:
            set RemainingTime = 15
        loop:
            if (RemainingTime <= 0):
                break
            CooldownHUD.Show(Agent, StringToMessage("Cooldown: {RemainingTime}s"))
            Sleep(1.0)
            set RemainingTime -= 1
        CooldownHUD.Hide(Agent)
        if (set AgentCooldowns[Agent] = 0.0) {}

    OnButtonPressed(Agent:agent):void =
        if (SkillDevice.BeginInteraction[Agent]) {}

    OnSkillSuccess(Agent:agent):void =
        var Count : int = 0
        if (Current := SkillSuccessCount[Agent]):
            set Count = Current
        set Count += 1
        if (set SkillSuccessCount[Agent] = Count) {}
        Remaining : int = 4 - Count
        InteractionCountHUD.Show(Agent, StringToMessage("Interactions left: {Remaining}"))
        if (Count >= 4):
            ReturnTeleporter.Teleport(Agent)
            ReturnHUDMessage.Show(Agent)
            if (set SkillSuccessCount[Agent] = 0) {}
            InteractionCountHUD.Hide(Agent)