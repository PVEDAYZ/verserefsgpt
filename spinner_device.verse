
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
spinner_device := class(creative_device):

    @editable GameManager : game_manager = game_manager{}
    @editable WheelProp : creative_prop = creative_prop{}
    @editable SpinButton : button_device = button_device{}
    @editable Accolades : []accolades_device = array{}
    @editable TimeBoard : billboard_device = billboard_device{}
    @editable HudMessage : hud_message_device = hud_message_device{}
    @editable Audio : audio_player_device = audio_player_device{}
    @editable Team : int = 1

    var Time : int = 2
    var CurTime : int = 0

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        SpinButton.InteractedWithEvent.Subscribe(StartSpin)
        TimeBoard.SetText(TextForUI("Spin Available!"))

    StartTimer():void=
        set CurTime = Time*60*60
        spawn{Update()}

    Update()<suspends>:void=
        loop: 
            set CurTime -= 1
            if(CurTime <= 0):
                SpinButton.Enable()
                TimeBoard.SetText(TextForUI("Spin Available!"))
                break
            if(var Mins : int = Floor(CurTime/60), Hours : int = Floor(Mins/60)):
                var Seconds : int = CurTime - Mins*60
                set Mins = Mins - Hours*60
                TimeBoard.SetText(TextForUI("{Hours}:{Mins}:{Seconds}"))
            Sleep(1.0)

    StartSpin(Agent: agent):void=
        SpinButton.Disable()
        spawn{Spin(Agent)}

    Spin(Agent: agent)<suspends>:void=
        var SpinCount : float = GetRandomFloat(2.5, 3.5);
        loop:
            Sleep(0.0)
            if(SpinCount <= 0.0):
                WheelRotation := WheelProp.GetTransform().Rotation
                var Rot : float = 0.0
                if(Team = 1):
                    set Rot = -1*RadiansToDegrees(WheelRotation.GetAngle()*WheelRotation.GetAxis().X)
                else if(Team = 2):
                    set Rot = -1*RadiansToDegrees(WheelRotation.GetAngle()*WheelRotation.GetAxis().Y)
                else if(Team = 3):
                    set Rot = RadiansToDegrees(WheelRotation.GetAngle()*WheelRotation.GetAxis().Y)
                if(Rot < 0.0){set Rot += 360.0}
                # Print("{Rot}")
                # Print("{WheelProp.GetTransform().Rotation}")
                Audio.Play(Agent)
                if(Rot >= 0.0 and Rot < 45.0):
                    Print("CASH")
                    HudMessage.Show(Agent, TextForUI("X4 CASH"))
                    Money := GameManager.GetMoney(Agent)
                    if(Amount := Round[Money]){GameManager.AddMoney(Amount*3, Agent)}
                else if(Rot >= 45.0 and Rot < 90.0):
                    Print("HUGE")
                    if(Acc := Accolades[2]){Acc.Award(Agent)}
                else if(Rot >= 90.0 and Rot < 135.0):
                    Print("+1 REBIRTH")
                    HudMessage.Show(Agent, TextForUI("+1 REBIRTH"))
                    GameManager.AddRebirths(1, Agent)
                else if(Rot >= 135.0 and Rot < 180.0):
                    Print("CRAZY!")
                    if(Acc := Accolades[4]){Acc.Award(Agent)}
                else if(Rot >= 180.0 and Rot < 225.0):
                    Print("MEGA")
                    if(Acc := Accolades[3]){Acc.Award(Agent)}
                else if(Rot >= 225.0 and Rot < 270.0):
                    Print("CASH")
                    Money := GameManager.GetMoney(Agent)
                    HudMessage.Show(Agent, TextForUI("X2 CASH"))
                    if(Amount := Round[Money]){GameManager.AddMoney(Amount, Agent)}
                else if(Rot >= 270.0 and Rot < 315.0):
                    Print("LARGE")
                    if(Acc := Accolades[1]){Acc.Award(Agent)}
                else if(Rot >= 315.0 and Rot <= 360.0):
                    Print("SMALL")
                    if(Acc := Accolades[0]){Acc.Award(Agent)}
                StartTimer()
                break
            else:
                set SpinCount -= 0.01
                PropTranslation := WheelProp.GetTransform().Translation
                if(Team = 1):
                    Rot := WheelProp.GetTransform().Rotation.ApplyRoll(SpinCount/10.0)
                    if(WheelProp.TeleportTo[PropTranslation, Rot]){}
                else if(Team = 2):
                    Rot := WheelProp.GetTransform().Rotation.ApplyPitch(SpinCount/10.0)
                    if(WheelProp.TeleportTo[PropTranslation, Rot]){}
                else if(Team = 3):
                    Rot := WheelProp.GetTransform().Rotation.ApplyPitch(SpinCount/10.0)
                    if(WheelProp.TeleportTo[PropTranslation, Rot]){}
    
    Reset():void=
        set CurTime = 0

        
