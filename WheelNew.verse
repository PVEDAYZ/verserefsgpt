using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
 
NormalizeAngle(Angle:float):float =
    var Result:float = Angle
    loop:
        if (Result < 0.0):
            set Result += 360.0
        else if (Result >= 360.0):
            set Result -= 360.0
        else:
            break
    return Result
 
team1_device := class(creative_device):
 
    @editable
    CarnavalWheel:creative_prop=creative_prop{}
    @editable
    WheelButton:button_device=button_device{}
    @editable
    wheelActivator : button_device = button_device {}
    @editable
    TriggerBoogie : trigger_device = trigger_device {}
    @editable
    TriggerPlunger : trigger_device = trigger_device {}
    @editable
    TriggerIce : trigger_device = trigger_device {}
    @editable
    TriggerJunk : trigger_device = trigger_device {}
 
    var IsRotating:logic=false
    var playercoins :int =0
    var playerPoints : int = 50000
    var UsedButtonPlayers:[player]logic = map{}
    var InitialWheelTransform:transform = transform{}
 
    OnBegin<override>()<suspends>:void=
        set InitialWheelTransform = CarnavalWheel.GetTransform()
        initial()
        WheelButton.InteractedWithEvent.Subscribe(OnSpinButtonClick)
 
    OnSpinButtonClick(Agent:agent):void=
        if (Player := player[Agent]):
            if (not UsedButtonPlayers[Player]?):
                if(IsRotating = false):
                    if (playerPoints >= 500):
                        set playerPoints = playerPoints - 500
                        if (set UsedButtonPlayers[Player] = true):
                            spawn:
                                RotatWheel(Agent)

 
    ResetWheelPosition()<suspends>:void=
        CarnavalWheel.MoveTo(InitialWheelTransform.Translation, InitialWheelTransform.Rotation, 1.0)
 
    RotatWheel(Agent:agent)<suspends>:void=
        var RotateDegrees:float = 150.0
        set IsRotating = true
        loop:
            CarnavalWheel.MoveTo(CarnavalWheel.GetTransform().Translation,CarnavalWheel.GetTransform().Rotation.ApplyPitch(DegreesToRadians(RotateDegrees)),1.0)
            var RandomInt:int=GetRandomInt(5,25)
            RandomFloat:float=RandomInt*1.0
 
            set RotateDegrees -= RandomFloat
            if(RotateDegrees< 0.0):
                set IsRotating = false
                WheelRotation:[]float = CarnavalWheel.GetTransform().Rotation.GetYawPitchRollDegrees()
                if (Pitch:float = WheelRotation[1]):
                    NormalizedPitch:float = NormalizeAngle(Pitch)
                    if(NormalizedPitch>=0.0 and NormalizedPitch <=44.9):
                        TriggerIce.Trigger(Agent)
                    else if(NormalizedPitch>=45.0 and NormalizedPitch <=89.9):
                        TriggerJunk.Trigger(Agent)
                    else if(NormalizedPitch>=90.0 and NormalizedPitch <=134.9):
                        TriggerBoogie.Trigger(Agent)
                    else if(NormalizedPitch>=135.0 and NormalizedPitch <=180.0):
                        TriggerPlunger.Trigger(Agent)
                    else if(NormalizedPitch>=180.0 and NormalizedPitch <=225.0):
                        TriggerIce.Trigger(Agent)
                    else if(NormalizedPitch>=225.0 and NormalizedPitch <=270.0):
                        TriggerJunk.Trigger(Agent)
                    else if(NormalizedPitch>=270.0 and NormalizedPitch <=315.0):
                        TriggerBoogie.Trigger(Agent)
                    else if(NormalizedPitch>=315.0 and NormalizedPitch <=360.0):
                        TriggerPlunger.Trigger(Agent)
                ResetWheelPosition()
                break
 
    initial():void=
        wheelActivator.Enable()