
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /Fortnite.com/Characters }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
VisualObby_Manager := class(creative_device):


    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers()):
            TrackProgress(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(TrackProgress)


    TrackProgress(Player : player) : void=
        if(NewPlayer := player[Player], PlayerUI := GetPlayerUI[NewPlayer]):
            NewCanvas := canvas{}
            BackgroundWidget : texture_block = texture_block{DefaultImage := Obby_BackgroundBar}
            NewCanvas.AddWidget(canvas_slot:
                Widget := BackgroundWidget
                Anchors := anchors{Minimum := vector2{X:= 0.5, Y:= 0.5} , Maximum := vector2{X:= 0.5, Y:= 0.5}}
                Offsets := margin{Left := 805.0, Top := 0.0, Right := 500.0, Bottom := 500.0}
                Alignment := vector2{X:= 0.5, Y:= 0.5}
                SizeToContent := false
                ZOrder := 0
            )
            ProgressStackBox : stack_box = stack_box{Orientation := orientation.Vertical}
            NewCanvas.AddWidget(canvas_slot:
                Widget := ProgressStackBox
                Anchors := anchors{Minimum := vector2{X:= 0.5, Y:= 0.5} , Maximum := vector2{X:= 0.5, Y:= 0.5}}
                Offsets := margin{Left := 805.0, Top := 0.0, Right := 500.0, Bottom := 500.0}
                Alignment := vector2{X:= 0.5, Y:= 0.5}
                SizeToContent := false
                ZOrder := 1
            )

            InvisibleColorBlock : color_block = color_block{DefaultOpacity := 0.0}
            ProgressStackBox.AddWidget(stack_box_slot:
                Widget :=  InvisibleColorBlock
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment := vertical_alignment.Fill
            )

            ProgressWidget : texture_block = texture_block{DefaultImage := Obby_ProgressBar, DefaultDesiredSize := vector2{X:= 0.0, Y:= 0.0}}
            ProgressStackBox.AddWidget(stack_box_slot:
                Widget :=  ProgressWidget
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment := vertical_alignment.Fill
                Distribution := option{1.0}
            )

            TextWidget : text_block = text_block{}
            NewCanvas.AddWidget(canvas_slot:
                Widget := TextWidget
                Anchors := anchors{Minimum := vector2{X:= 0.5, Y:= 0.5} , Maximum := vector2{X:= 0.5, Y:= 0.5}}
                Offsets := margin{Left := 808.0, Top := 0.0, Right := 100.0, Bottom := 30.0}
                Alignment := vector2{X:= 0.5, Y:= 0.5}
                SizeToContent := false
                ZOrder := 3
            )
            PlayerUI.AddWidget(NewCanvas)
            spawn{UpdateLoop(Player, InvisibleColorBlock, TextWidget)}

    StringToMessage<localizes>(String : string) : message = "{String}"
    

    UpdateLoop(Player : player, CB : color_block , TW : text_block)<suspends> : void=
        if(FC := Player.GetFortCharacter[]):
            race:
                block:
                    loop:
                        Sleep(0.0)
                        LeavingPlayer := GetPlayspace().PlayerRemovedEvent().Await()
                        if(LeavingPlayer = Player):
                            break

                loop:
                    Sleep(0.0)
                    PlayerHeight := FC.GetTransform().Translation.Z
                    HeightPercentage := PlayerHeight / 20000.0
                    if(HeightPercentage <= 1.01):
                        NewWidgetAmount := 500.0 - (HeightPercentage * 500.0)
                        CB.SetDesiredSize(vector2{X:=0.0, Y:= NewWidgetAmount})

                        if(NewHeight := Int[HeightPercentage * 100.0]):
                            TW.SetText(StringToMessage("{NewHeight}%"))