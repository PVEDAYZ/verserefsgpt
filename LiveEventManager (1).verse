
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }



CustomDateAndTime := class<concrete>():
    @editable Year : int = 2025
    @editable Month : int = 1
    @editable Day : int = 1
    @editable Hour : int = 0
    @editable Minute : int = 0
    @editable Second : int = 0


CustomEvent := class<concrete>():
    LiveEventManagerDevice : LiveEventManager = LiveEventManager{}
    @editable EventTime : CustomDateAndTime = CustomDateAndTime{}
    @editable CountdownBillboard : billboard_device = billboard_device{}
    @editable ActivateTrigger : trigger_device = trigger_device{}


    HandleEventTimer()<suspends> : void=
        loop:
            if(NewSeconds := Int[GetSecondsSinceEpoch()]):
                EventEpoch := LiveEventManagerDevice.GetEpochFromDateAndTime(EventTime)
                SecondsDifference := EventEpoch - NewSeconds
                if(SecondsDifference = 0):
                    ActivateTrigger.Trigger()
                    CountdownBillboard.SetText(StringToMessage("Activated"))
                    break
                else if(SecondsDifference < 0):
                    break

                DifferenceDateTime := LiveEventManagerDevice.GetDateAndTimeFromSeconds(SecondsDifference)
                TimeString := "{DifferenceDateTime.Day - 1}:{DifferenceDateTime.Hour}:{DifferenceDateTime.Minute}:{DifferenceDateTime.Second} UTC"
                CountdownBillboard.SetText(StringToMessage(TimeString))

            Sleep(1.0)


StringToMessage<localizes>(String : string) : message = "{String}"

LiveEventManager := class(creative_device):
    SecondsInAMinute : int = 60
    SecondsInAnHour : int = 3600
    SecondsInADay : int = 86400
    SecondsInAYear : int = 31536000
    SecondsInALeapYear : int = 31622400
    DaysOfTheWeek : []string = array{"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"}
    MonthsOfTheYear : []string = array{"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
    var DaysInMonth : []int = array{31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}


    @editable CurrentDateBillboard : billboard_device = billboard_device{}
    @editable CurrentTimeBillboard : billboard_device = billboard_device{}

    @editable CustomEvents : []CustomEvent = array{}



    

    OnBegin<override>()<suspends>:void=
        spawn{UpdateCurrentTime()}
        for(CE : CustomEvents):
            spawn{CE.HandleEventTimer()}
        



    UpdateCurrentTime()<suspends> : void=
        loop:
            if(NewSeconds := Int[GetSecondsSinceEpoch()]):
                DateAndTime := GetDateAndTimeFromSeconds(NewSeconds)
                if(MonthName := MonthsOfTheYear[DateAndTime.Month - 1]):
                    DateString := "{MonthName} {DateAndTime.Day}, {DateAndTime.Year}"
                    TimeString := "{DateAndTime.Hour}:{DateAndTime.Minute}:{DateAndTime.Second} UTC"
                    CurrentDateBillboard.SetText(StringToMessage(DateString))
                    CurrentTimeBillboard.SetText(StringToMessage(TimeString))
            Sleep(1.0)


    GetEpochFromDateAndTime(InDateAndTime : CustomDateAndTime) : int=
        var CurrentYears : int = InDateAndTime.Year
        var CurrentMonth : int = InDateAndTime.Month
        var CurrentDays : int = InDateAndTime.Day
        var CurrentHours : int = InDateAndTime.Hour
        var CurrentMinutes : int = InDateAndTime.Minute
        var CurrentSeconds : int = InDateAndTime.Second


        loop:
            NewYearlySeconds :=  if(IsLeapYear(CurrentYears)?){SecondsInALeapYear}else{SecondsInAYear}
            if(CurrentYears = 1970):
                break
            else:
                set CurrentSeconds += NewYearlySeconds
                set CurrentYears -= 1


        if:
            if(IsLeapYear(CurrentYears)?):
                set DaysInMonth[1] = 29
            else:
                set DaysInMonth[1] = 28
    
        loop:
            if(CurrentMonthSeconds := DaysInMonth[CurrentMonth - 1] * SecondsInADay):
                if(CurrentMonth = 1):
                    break
                else:
                    set CurrentSeconds += CurrentMonthSeconds
                    set CurrentMonth -= 1
                    

        set CurrentSeconds += (CurrentDays - 1) * SecondsInADay
    
        set CurrentSeconds += CurrentHours * SecondsInAnHour

        set CurrentSeconds += CurrentMinutes * SecondsInAMinute

        return CurrentSeconds


    GetDateAndTimeFromSeconds(InSeconds : int) : CustomDateAndTime=
        var CurrentYears : int = 1970
        var CurrentMonth : int = 1
        var CurrentDays : int = 1
        var CurrentHours : int = 0
        var CurrentMinutes : int = 0
        var CurrentSeconds : int = InSeconds


        loop:
            NewYearlySeconds :=  if(IsLeapYear(CurrentYears)?){SecondsInALeapYear}else{SecondsInAYear}
            if(CurrentSeconds < NewYearlySeconds):
                break
            else:
                set CurrentSeconds -= NewYearlySeconds
                set CurrentYears += 1


        if:
            if(IsLeapYear(CurrentYears)?):
                set DaysInMonth[1] = 29
            else:
                set DaysInMonth[1] = 28
    
        loop:
            if(CurrentMonthSeconds := DaysInMonth[CurrentMonth - 1] * SecondsInADay):
                if(CurrentSeconds < CurrentMonthSeconds):
                    break
                else:
                    set CurrentSeconds -= CurrentMonthSeconds
                    set CurrentMonth += 1
                    
        if(NewDays := Floor(CurrentSeconds / SecondsInADay)):
            set CurrentDays = NewDays + 1
            set CurrentSeconds -= NewDays * SecondsInADay

        if(NewHours := Floor(CurrentSeconds / SecondsInAnHour)):
            set CurrentHours = NewHours
            set CurrentSeconds -= NewHours * SecondsInAnHour

        if(NewMinutes := Floor(CurrentSeconds / SecondsInAMinute)):
            set CurrentMinutes = NewMinutes
            set CurrentSeconds -= NewMinutes * SecondsInAMinute


        return (CustomDateAndTime{Year := CurrentYears , Month := CurrentMonth , Day := CurrentDays , Hour := CurrentHours, Minute := CurrentMinutes , Second := CurrentSeconds})


    IsLeapYear(Year : int)<transacts> : logic=
        if(Mod[Year , 4] = 0 and Mod[Year , 100] <> 0):
            return true
        else if(Mod[Year, 400] = 0):
            return true
        return false
