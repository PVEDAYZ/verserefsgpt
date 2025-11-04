using { /Verse.org/Verse }
using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }

Reset_Device := class(creative_device):

    @editable BoomBooms: []explosive_device = array{}
    @editable ResetButtons: []trigger_device = array{}
    @editable Accolades: accolades_device = accolades_device{}
    @editable Score: score_manager_device = score_manager_device{}
    @editable UI: hud_message_device = hud_message_device{}
    @editable VFX: vfx_creator_device = vfx_creator_device{}
    @editable SFX: audio_player_device = audio_player_device{}
    @editable Analytics: analytics_device = analytics_device{}

    @editable ResetCooldownSeconds: float = 2.0
    @editable TransmitDelaySeconds: float = 0.0

    OnBegin<override>()<suspends>:void =
        for (btn: ResetButtons):
            btn.SetResetDelay(ResetCooldownSeconds)
            if (TransmitDelaySeconds > 0.0):
                btn.SetTransmitDelay(TransmitDelaySeconds)
            btn.TriggeredEvent.Subscribe(ResetBuilds)

    ResetBuilds(maybeInstigator:?agent):void =
        # Gate re-entry by disabling all triggers for the duration
        for (btn: ResetButtons):
            btn.Disable()

        if (instigator := maybeInstigator?):
            for (boom: BoomBooms):
                boom.Explode(instigator)
                boom.Reset()
            Accolades.Award(instigator)
            Score.Activate(instigator)
            UI.Show(instigator)
            VFX.Begin(instigator)
            SFX.Play(instigator)
            Analytics.Submit(instigator)
        else:
            for (boom: BoomBooms):
                boom.Reset()
            UI.Show()
            VFX.Begin()
            SFX.Play()

        # Re-enable triggers after work is done
        for (btn: ResetButtons):
            btn.Enable()
