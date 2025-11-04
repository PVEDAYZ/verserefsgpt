using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

invincibility := class(creative_device):

    @editable
    Detector : conditional_button_device = conditional_button_device{}

    OnBegin<override>()<suspends>:void=
        loop:
            for (Agent : GetPlayspace().GetPlayers()):
                if (Character := Agent.GetFortCharacter[]):
                    if (Detector.IsHoldingItem[Agent]):
                        Character.SetHealth(100.0)
                        Character.SetShield(100.0)
                        Character.SetVulnerability(false)
                    else:
                        Character.SetVulnerability(true)
            Sleep(0.1) 