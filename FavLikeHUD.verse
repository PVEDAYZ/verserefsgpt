
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
FavLikeHUD := class(creative_device):

    @editable LikeFavHUD : hud_message_device = hud_message_device{}
    @editable LikeFavTimer : timer_device = timer_device{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=

        LikeFavTimer.SuccessEvent.Subscribe(ShowLikeFav)
        for(Players:GetPlayspace().GetPlayers(), Agent := agent[Players]):
            ShowLikeFav(option{Agent})
       
    ShowLikeFav(IsAgent:?agent):void=
        if:
            Agent := IsAgent?
        then:
            AllPlayers := GetPlayspace().GetPlayers()
            for(Players:AllPlayers, Agents := agent[Players]):
                    LikeFavHUD.Show()
                    spawn:
                        RestartTimer()

    RestartTimer()<suspends>:void=
        LikeFavTimer.Reset()
        Sleep(0.2)
        LikeFavTimer.Start()