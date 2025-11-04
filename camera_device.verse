using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
camera_device := class(creative_device):

    @editable GameManager : game_manager = game_manager{}
    @editable Camera : gameplay_camera_fixed_angle_device = gameplay_camera_fixed_angle_device{}
    @editable Control : gameplay_controls_third_person_device = gameplay_controls_third_person_device{}
    @editable Zone : mutator_zone_device = mutator_zone_device{}
    @editable Accolade : accolades_device = accolades_device{}   # existing single award (kept)

    # --- Optional accolades hooks (leave empty for no extra awards) ---
    @editable EnterAccolades : []accolades_device = array{}          # when agent enters the zone
    @editable ExitAccolades : []accolades_device = array{}           # when agent exits the zone
    @editable EmoteStartAccolades : []accolades_device = array{}     # when agent starts emoting
    @editable EmoteEndAccolades : []accolades_device = array{}       # when agent stops emoting
    @editable PeriodicDanceAccolades : []accolades_device = array{}  # milestone while dancing
    @editable DanceTicksPerAccolade : int = 10                       # every N seconds dancing -> award

    var isDancing : logic = false
    var DanceTickCounter : int = 0

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        Zone.AgentEntersEvent.Subscribe(OnEnter)
        Zone.AgentExitsEvent.Subscribe(OnExit)
        Zone.AgentBeginsEmotingEvent.Subscribe(OnEmoteStart)
        Zone.AgentEndsEmotingEvent.Subscribe(OnEmoteEnd)

    OnEnter(Agent : agent):void=
        Control.AddTo(Agent)
        Camera.AddTo(Agent)
        AwardAccolades(option{Agent}, EnterAccolades)
    
    OnExit(Agent : agent):void=
        Camera.RemoveFrom(Agent)
        Control.RemoveFrom(Agent)
        AwardAccolades(option{Agent}, ExitAccolades)
        set isDancing = false
        set DanceTickCounter = 0

    OnEmoteStart(Agent : agent):void=
        set isDancing = true
        set DanceTickCounter = 0
        AwardAccolades(option{Agent}, EmoteStartAccolades)
        spawn{GiveCustomers(Agent)}
    
    OnEmoteEnd(Agent : agent):void=
        set isDancing = false
        AwardAccolades(option{Agent}, EmoteEndAccolades)
        
    GiveCustomers(Agent : agent)<suspends>:void=
        loop:
            if(isDancing = false):
                break
            else:
                GameManager.AddCustomers(10, Agent)
                # Preserve existing behavior: award the bound accolade every tick while dancing.
                Accolade.Award(Agent)

                # Optional milestone award every N ticks (no modulo used).
                if(DanceTicksPerAccolade > 0):
                    set DanceTickCounter += 1
                    if(DanceTickCounter >= DanceTicksPerAccolade):
                        AwardAccolades(option{Agent}, PeriodicDanceAccolades)
                        set DanceTickCounter = 0
            Sleep(1.0)

    # ---------------- Helpers ----------------
    AwardAccolades(MaybeAgent : ?agent, List : []accolades_device):void=
        if(List.Length = 0):
            return
        if(Agent := MaybeAgent?):
            for(A : List):
                A.Award(Agent)
