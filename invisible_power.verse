using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
 
 
invisibility := class(creative_device):
 
    @editable
    Detector : conditional_button_device = conditional_button_device{}
 
    CheckForCard()<suspends>:void=
        loop:
            Sleep(0.2)
            AllPlayers:=GetPlayspace().GetPlayers()
            for(Player:AllPlayers):
                if(IsAgent:agent = agent[Player]):
                    if(Detector.IsHoldingItem[IsAgent]):
                        Hide(IsAgent)
                    else:
                        Show(IsAgent)
 
    Hide(Agent:agent)<suspends>:void=
        if(FC:=Agent.GetFortCharacter[]):
            FC.Hide()
    Show(Agent:agent):void=
        if(FC:=Agent.GetFortCharacter[]):
            FC.Show()
 
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        spawn:
            CheckForCard()