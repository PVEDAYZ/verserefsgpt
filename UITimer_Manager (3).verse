
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }

Timer := class():
    var TimerCanvas : canvas = canvas{}
    var TimerText : text_block = text_block{}
    var TimerImage : texture_block = texture_block{DefaultImage := vaultpng}
    var Hours : int = 0
    var Minutes : int = 1
    var Seconds : int = 15

    var TimerDevice : UITimer_Manager = UITimer_Manager{}

    var Trigger : trigger_device = trigger_device{}

    SetUpCanvas() : void=
        set TimerCanvas = canvas:
            Slots := array:
                canvas_slot:
                    Widget := TimerText
                    Anchors := anchors{Minimum := vector2{X:= 0.5, Y:= 0.5}, Maximum := vector2{X:= 0.5, Y:= 0.5}}
                    Offsets := margin{Left := -81.0, Top := 37.0, Right := 165.0, Bottom := 40.0}
                    Alignment := vector2{X:= 0.0, Y:=0.0}
                    SizeToContent := false
                    ZOrder := 1

                canvas_slot:
                    Widget := TimerImage
                    Anchors := anchors{Minimum := vector2{X:= 0.5, Y:= 0.5}, Maximum := vector2{X:= 0.5, Y:= 0.5}}
                    Offsets := margin{Left := -77.0, Top := -102.0, Right := 165.0, Bottom := 130.0}
                    Alignment := vector2{X:= 0.0, Y:=0.0}
                    SizeToContent := false
                    ZOrder := 0

    StringToMessage<localizes>(String : string) : message = "{String}"

    HandleTimer(Agent : agent , PlayerCanvas : canvas)<suspends> : void=
        if(Player := player[Agent],PlayerUI := GetPlayerUI[Player]):
            var HoursZeros : string = ""
            var MinutesZeros : string = ""
            var SecondsZeros : string = ""
            race:
                block:
                    loop:
                        LeavingPlayer := TimerDevice.GetPlayspace().PlayerRemovedEvent().Await()
                        if(LeavingPlayer = Agent):
                            break

                loop:
                    Sleep(1.0)
                    set Seconds -= 1
                    if(Seconds <= 0):
                        if(Minutes <= 0):
                            if(Hours <= 0):
                                PlayerUI.RemoveWidget(PlayerCanvas)
                                Trigger.Trigger(Agent)
                                break
                            else:
                                set Hours -= 1
                                set Minutes = 59
                                set Seconds = 60
                        else:
                            set Minutes -= 1
                            set Seconds = 60
                    if(Hours < 10):
                        set HoursZeros = "0"
                    else:
                        set HoursZeros = ""
                    if(Minutes < 10):
                        set MinutesZeros = "0"
                    else:
                        set MinutesZeros = ""
                    if(Seconds < 10):
                        set SecondsZeros = "0"
                    else:
                        set SecondsZeros = ""
                    
                    TimerText.SetText(StringToMessage("{HoursZeros}{Hours}:{MinutesZeros}{Minutes}:{SecondsZeros}{Seconds}"))



UITimer_Manager := class(creative_device):

    @editable Trigger : trigger_device = trigger_device{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers()):
            InitalizeTimer(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(InitalizeTimer)


    InitalizeTimer(Agent:agent) : void=
        NewTimer : Timer = Timer{Trigger := Trigger , TimerDevice := Self}
        NewTimer.SetUpCanvas()
        if(Player := player[Agent],PlayerUI := GetPlayerUI[Player]):
            PlayerUI.AddWidget(NewPlayerCanvas : canvas = canvas:
                Slots := array:
                    canvas_slot:
                        Widget := NewTimer.TimerCanvas
                        Anchors := anchors{Minimum := vector2{X:= 1.0, Y:= 0.5}, Maximum := vector2{X:= 1.0, Y:= 0.5}}
                        Offsets := margin{Left := -260.0, Top := -170.0, Right := 210.0, Bottom := 160.0}
                        Alignment := vector2{X:= 0.0, Y:=0.0}
                        SizeToContent := false
                        ZOrder := 1
            )
            spawn:
                NewTimer.HandleTimer(Agent, NewPlayerCanvas)