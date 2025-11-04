
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/FortPlayerUtilities }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

            

PlayerUIClass := class():

    RespawnClass : class_and_team_selector_device
    RespawnText<localizes> : message = "Respawn"
    ButtonRespawn : button_loud = button_loud{}
    var MyCanvas : canvas = canvas{}


    OnRespawnClicked(WidgetPlayer:widget_message):void=
        if(Player:= WidgetPlayer.Player, PlayerUI:= GetPlayerUI[Player]):
                PlayerUI.RemoveWidget(MyCanvas)
                RespawnClass.ChangeClass(Player)
                Player.Respawn(vector3{X:=1.0,Y:=1.0,Z:=1.0}, IdentityRotation())
                

    Init() : canvas =
        
        ButtonRespawn.SetText(RespawnText)

        ButtonRespawn.OnClick().Subscribe(OnRespawnClicked)
        
        MainCanvas : canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.2}, Maximum := vector2{X := 0.5, Y := 0.2}}
                    Offsets := margin{Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := ButtonRespawn

        return MainCanvas

    AddUI(Agent : agent) : void=
        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player]):

            set MyCanvas = Init()
            PlayerUI.AddWidget(MyCanvas , player_ui_slot{InputMode := ui_input_mode.All})


# A Verse-authored creative device that can be placed in a level
RespawnSpectator := class(creative_device):

    @editable SpectateButton:button_device = button_device{}
    @editable SpectatorClass:class_and_team_selector_device = class_and_team_selector_device{}
    @editable RespawnClass:class_and_team_selector_device = class_and_team_selector_device{}


    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=

        SpectateButton.InteractedWithEvent.Subscribe(GoToSpectator)

    GoToSpectator(Agent:agent):void=
        if(Player:= player[Agent], PlayerUI:=GetPlayerUI[Player]):
            if(FortChar := Player.GetFortCharacter[]):
                SpectatorClass.ChangeClass(Agent)
                FortChar.Damage(300.0)

                EachPlayerUIClass: PlayerUIClass = PlayerUIClass{RespawnClass:=RespawnClass}
                EachPlayerUIClass.AddUI(Agent)


                

