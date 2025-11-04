using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/FortPlayerUtilities }

PlayerUIClass := class():

    RespawnClass : class_and_team_selector_device
    RespawnText<localizes> : message = "Respawn"
    ButtonRespawn : button_loud = button_loud{}
    var MyCanvas : canvas = canvas{}

    OnRespawnClicked(WidgetPlayer:widget_message):void=
        Print("PlayerUIClass: OnRespawnClicked")
        if (Player := WidgetPlayer.Player, PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(MyCanvas)
            RespawnClass.ChangeClass(Player)
            Print("PlayerUIClass: Forcing respawn at fixed location")
            Player.Respawn(vector3{X := 7168.0, Y := 4875.0, Z := 1537.0}, IdentityRotation())
        else:
            Print("PlayerUIClass: OnRespawnClicked missing Player or PlayerUI")

    Init() : canvas =
        Print("PlayerUIClass: Init UI")
        ButtonRespawn.SetText(RespawnText)
        ButtonRespawn.OnClick().Subscribe(OnRespawnClicked)
        Print("PlayerUIClass: Button wired")

        MainCanvas : canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.2}, Maximum := vector2{X := 0.5, Y := 0.2}}
                    Offsets := margin{}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := ButtonRespawn

        Print("PlayerUIClass: Init complete")
        return MainCanvas

    AddUI(Agent : agent) : void=
        if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            set MyCanvas = Init()
            PlayerUI.AddWidget(MyCanvas, player_ui_slot{InputMode := ui_input_mode.All})
            Print("PlayerUIClass: UI added for player")
        else:
            Print("PlayerUIClass: AddUI failed (no player or PlayerUI)")

Spectate := class(creative_device):

    @editable SpectateButton : button_device = button_device{}
    @editable SpectatorClass : class_and_team_selector_device = class_and_team_selector_device{}
    @editable RespawnClass : class_and_team_selector_device = class_and_team_selector_device{}
    @editable AnalyticsDevice : analytics_device = analytics_device{}

    OnBegin<override>()<suspends>:void=
        Print("Spectate: device initialized")
        SpectateButton.InteractedWithEvent.Subscribe(GoToSpectator)
        Print("Spectate: Subscribed to SpectateButton.InteractedWithEvent")

    GoToSpectator(Agent:agent):void=
        if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            if (FortChar := Player.GetFortCharacter[]):
                Print("Spectate: Submitting analytics and switching to spectator class")
                AnalyticsDevice.Submit
                SpectatorClass.ChangeClass(Agent)
                Print("Spectate: Eliminating current character to complete switch")
                FortChar.Damage(300.0)
                EachPlayerUIClass : PlayerUIClass = PlayerUIClass{RespawnClass := RespawnClass}
                EachPlayerUIClass.AddUI(Agent)
                Print("Spectate: Respawn UI added for player")
            else:
                Print("Spectate: No FortCharacter on player; cannot eliminate to switch")
        else:
            Print("Spectate: Missing Player or PlayerUI for Agent")
