
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.


power<public> := class<concrete>:

    @editable Button : button_device = button_device{}
    @editable Price : int = 0
    @editable Selector : class_and_team_selector_device = class_and_team_selector_device{}

    var GameManager : game_manager = game_manager{}
    var SuccessMessage : hud_message_device = hud_message_device{}
    var FailMessage : hud_message_device = hud_message_device{}

    Init(GM : game_manager, SuccMess : hud_message_device, FailMess : hud_message_device):void=
        set GameManager = GM
        set SuccessMessage = SuccMess
        set FailMessage = FailMess
        Button.InteractedWithEvent.Subscribe(Press)

    Press(Agent : agent):void=
        Rebirths := GameManager.GetRebirths(Agent)
        if(Rebirths >= Price):
            Selector.ChangeClass(Agent)
            SuccessMessage.Show(Agent)
        else:
            FailMessage.Show(Agent)

# A Verse-authored creative device that can be placed in a level
rebirth_shop_device := class(creative_device):

    @editable GameManager : game_manager = game_manager{}
    @editable Powers : []power = array{}
    @editable SuccessMessage : hud_message_device = hud_message_device{}
    @editable FailMessage : hud_message_device = hud_message_device{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for(Power : Powers):
            Power.Init(GameManager, SuccessMessage, FailMessage)