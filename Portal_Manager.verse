using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

#THIS DEVICE IS USED TO MANAGE DIFFERENT "PORTALS" THAT UNLOCK AFTER CERTAIN DURATIONS

#Class for each portal
Portal := class<concrete>():
    #Base stuff
    var GameManager : Game_Manager = Game_Manager{}
    var PortalFinished : logic = false

    #Devices
    TT_Portal_PortalBillboard<localizes>:message = "The billboard that displays the portal timer"
    @editable PortalBillboard : billboard_device = billboard_device{}

    TT_Portal_PortalTeleporter<localizes>:message = "The teleporter that teleports the player to the portal\'s destination\n*Required Settings*\nTeleporter Group : None\nTeleporter Target Group : None\nTeleporter Rift Visible : false"
    @editable PortalTeleporter : teleporter_device = teleporter_device{}

    TT_Portal_PortalMutator<localizes>:message = "The mutator zone that is used to enter the portal"
    @editable PortalMutator : mutator_zone_device = mutator_zone_device{}

    TT_Portal_PortalUnlockHUD<localizes>:message = "The hud message that is shown when the portal gets unlocked\n*Required Settings*\nMessage Recipient : All"
    @editable PortalUnlockHUD : hud_message_device = hud_message_device{}
    var BackTeleporter : teleporter_device = teleporter_device{}

    #Stuff for when back button is pressed
    TT_Portal_BackTeleporter<localizes>:message = "The button that teleports the player back when pressed"
    @editable ButtonToTeleportBack : button_device = button_device{}          

    #Controls time of portal
    TT_Portal_PortalTimer<localizes>:message = "How long it takes the portal to unlock (hours:minutes:seconds)"
    @editable var PortalTimerSec : int = 0                                           
    @editable var PotalTimerMinutes : int =  0                                      
    @editable var PortalTimerHours : int = 0                                               

    #Initializes portal timer and devices
    Initialize()<suspends> : void=                                              
        spawn{Timer()}
        PortalMutator.AgentEntersEvent.Subscribe(TeleportPlayer)               
        ButtonToTeleportBack.InteractedWithEvent.Subscribe(TeleportBack)

    #Teleports the player back and activates reward stuff
    TeleportBack(Agent : agent) : void =        
        if(CP := GameManager.PlayersMap[Agent]):
            BackTeleporter.Teleport(Agent)

    #Teleports the player from mutator
    TeleportPlayer(Agent:agent) : void=  
        PortalTeleporter.Teleport(Agent)

    #Timer loop to decrease time
    Timer()<suspends> : void=                                        
        loop:
            Sleep(1.0)
            var BonusZeroHours : string = ""
            var BonusZeroMinutes : string = ""
            var BonusZeroSeconds : string = ""
            if(PortalTimerHours < 10){set BonusZeroHours = "0"}
            if(PotalTimerMinutes < 10){set BonusZeroMinutes = "0"}
            if(PortalTimerSec < 10){set BonusZeroSeconds = "0"}
            PortalBillboard.SetText(MasterS2M("{BonusZeroHours}{PortalTimerHours}:{BonusZeroMinutes}{PotalTimerMinutes}:{BonusZeroSeconds}{PortalTimerSec}"))
            set PortalTimerSec -= 1
            if(PortalTimerSec <= 0):
                if(not PotalTimerMinutes <= 0):
                    set PotalTimerMinutes -= 1
                    set PortalTimerSec = 59
                else if(not PortalTimerHours <= 0):
                    set PortalTimerHours -= 1
                    set PotalTimerMinutes = 59
                    set PortalTimerSec = 59
                else:
                    set PortalFinished = true
                    PortalMutator.Enable()
                    PortalBillboard.SetText(MasterS2M(""))
                    PortalUnlockHUD.Show()
                    break

#Main Creative Device Class
Portal_Manager := class(creative_device):
    TT_PMM_Device_GameManager<localizes>:message = "Your game manager device"
    @editable GameManager : Game_Manager = Game_Manager{}      

    #All of the different portals
    TT_PMM_Device_AllPortals<localizes>:message = "A list of portals"
    @editable AllPortals : []Portal = array{}

    #Teleporter to teleport back to
    TT_PMM_Device_BackTeleporter<localizes>:message = "The teleporter that teleports the player back\n*Required Settings*\nTeleporter Group : None\nTeleporter Target Group : None\nTeleporter Rift Visible : false"
    @editable BackTeleporter : teleporter_device = teleporter_device{}

    #Initializes all portals
    OnBegin<override>()<suspends>:void=
        for(Port : AllPortals):                     
            set Port.GameManager = GameManager
            set Port.BackTeleporter = BackTeleporter
            spawn{Port.Initialize()}