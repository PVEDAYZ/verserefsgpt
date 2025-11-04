using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }

spacerespawn := class(creative_device):

    @editable
    DBNODevice : down_but_not_out_device = down_but_not_out_device{}

    @editable
    HUDMessage : hud_message_device = hud_message_device{}

    @editable
    InputTrigger : input_trigger_device = input_trigger_device{}

    @editable
    Teleporters : []teleporter_device = array{}

    var KnockedOutPlayers : [agent]logic = map{}

    StringToMessage<localizes>(InString : string) : message = "{InString}"

    OnBegin<override>()<suspends> : void =
        DBNODevice.AgentDownedEvent.Subscribe(OnPlayerKnockedOut)
        InputTrigger.PressedEvent.Subscribe(OnSpacePressed)

    OnPlayerKnockedOut(Agent : agent) : void =
        if (set KnockedOutPlayers[Agent] = true):
            HUDMessage.Show(Agent, StringToMessage("Jump to Respawn")) # you can change the message to whatever you want to be shown
            InputTrigger.Enable()

    OnSpacePressed(Agent : agent) : void =
        if (KnockedOutPlayers[Agent] = true):
            if (Character := Agent.GetFortCharacter[]):
                DBNODevice.Revive(Agent)
                Character.SetHealth(100.0)
                Character.SetShield(100.0)
                if (Teleporter := Teleporters[0]):
                    Teleporter.Teleport(Agent)
                if (set KnockedOutPlayers[Agent] = false):
                    HUDMessage.Hide(Agent)
                    var AnyKnockedOut : logic = false
                    for (Player -> IsKnockedOut : KnockedOutPlayers, IsKnockedOut = true):
                        set AnyKnockedOut = true
                    if (AnyKnockedOut = false):
                        InputTrigger.Disable()


                        # join us discord.gg/uefndream