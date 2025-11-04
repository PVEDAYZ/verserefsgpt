
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

unlockable := class<concrete>:
    @editable Barrier : barrier_device = barrier_device{}
    @editable TimeBoard : billboard_device = billboard_device{}
    @editable Button : button_device = button_device{}
    @editable Time : int = 60
    
    var CurTime : int = 0
    var isRunning : logic = false

    Start():void=
        set CurTime = Time*60
        set isRunning = true
        ShowBarrier(Barrier)
        ShowButton(Button)
        Barrier.Enable()
        spawn{Update()}

    Update()<suspends>:void=
        loop:
            if(isRunning = false):
                break
            else:
                set CurTime -= 1
                if(CurTime <= 0):
                    set isRunning = false
                    Barrier.Disable()
                    TimeBoard.SetText(TextForUI(""))
                    break
                if(Mins : int = Floor(CurTime/60)):
                    var Seconds : int = CurTime - Mins*60
                    TimeBoard.SetText(TextForUI("{Mins}:{Seconds}"))
            Sleep(1.0)

    Reset():void=
        set isRunning = false
        HideAll()

    HideAll():void=
        HideBarrier(Barrier)
        HideButton(Button)
        TimeBoard.SetText(TextForUI(""))

# A Verse-authored creative device that can be placed in a level
plot_manager := class(creative_device):

    @editable GameManager : game_manager = game_manager{}
    @editable DropperDevice : dropper_device = dropper_device{}

    @editable ClaimerTrigger : trigger_device = trigger_device{}
    @editable ClassSelector : class_and_team_selector_device = class_and_team_selector_device{}
    @editable PetsDevice : pets_device = pets_device{} 
    @editable PlayerRef : player_reference_device = player_reference_device{}
    @editable Giftbox : giftbox_device = giftbox_device{}
    @editable Spinner : spinner_device = spinner_device{}
    @editable Vault : pinpad_device = pinpad_device{}
    @editable Unlockables : []unlockable = array{}

    var MaybeOwnerAgent : ?agent = false

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        # Hide unlockables
        for(Unlockable : Unlockables):
            Unlockable.HideAll()
        spawn:
            SaveCycle()

    # Runs when the dropper is claimed
    OnClaimerTriggered(Agent : agent):void=
        set MaybeOwnerAgent = option{Agent}
        ClassSelector.ChangeTeam(Agent)
        PlayerRef.Enable()
        PlayerRef.Register(Agent)
        Giftbox.Start()
        for(Unlockable : Unlockables):
            Unlockable.Start()

    SaveCycle()<suspends>:void=
        loop:
            Sleep(1.0)
            if(Agent := MaybeOwnerAgent?):
                GameManager.SaveData(Agent)
    
    StartMessages(Agent : agent)<suspends>:void=
        GameManager.ShowMessage("So you want to run an ice cream shop?", "Lets see if you've got what it takes!", 1, 5.0, Agent)
        Sleep(150.0)
        GameManager.ShowMessage("Want faster cash? Capture the control", "point in the center for a cash bonus!", 1, 8.0, Agent)
        Sleep(300.0)
        GameManager.ShowMessage("Want faster progress? Check out the pet", "shop to buy pets that give you perks!", 1, 8.0, Agent)
        Sleep(300.0)
        GameManager.ShowMessage("Enjoying the map? Drop a like and add to", "favorites to support me!", 1, 10.0, Agent)
        Sleep(600.0)
        GameManager.ShowMessage("Enjoying the map? Drop a like and add to", "favorites to support me!", 1, 10.0, Agent)
    
    # Changes the owner back to false
    Reset(Agent : agent):void=
        set MaybeOwnerAgent = false 
        PetsDevice.Reset(Agent)
        GameManager.Rebirth(Agent)
        DropperDevice.ResetDropper()
        Giftbox.Reset()
        Spinner.Reset()
        ShowTrigger(ClaimerTrigger)
        ClaimerTrigger.Enable()
        PlayerRef.Clear()
        PlayerRef.Disable()
        for(Unlockable : Unlockables):
            Unlockable.Reset()
