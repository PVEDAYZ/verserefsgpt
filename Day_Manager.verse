<#
====================================================================================================
Copyright (c) 2024 MapAcademy. All rights reserved.

 

This software and its associated documentation files (the "Software") are the

proprietary property of MapAcademy and are protected by copyright law.

 

The Software is provided to you under the terms of the MapAcademy End User

License Agreement (the "License"). You may use, copy, distribute, and modify

the Software solely in accordance with the terms of the License.

 

BY USING THE SOFTWARE, YOU AGREE TO BE BOUND BY THE TERMS OF THE LICENSE.

IF YOU DO NOT AGREE TO THE TERMS OF THE LICENSE, DO NOT USE THE SOFTWARE.

 

The Software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND,

either express or implied, including without limitation any warranties of

MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, or NON-INFRINGEMENT.

For more details, please refer to the MapAcademy End User License Agreement.
====================================================================================================
#>

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

#THIS DEVICE MANAGES A PROGRESSIVE ZOMBIE / DAY SYSTEM

Level := class<concrete>():     #Class for each progressive level of zombie spawners

    @editable Spawners : []creature_spawner_device =array{}     #Zombies spawners for the current level

    var AllSpawners : []creature_spawner_device = array{}       #All of the Zombie Spawners

    Switch() : void=                    #Switches all zombie spawners to new levels'

        #Disables every spawner
        for(Spawner : AllSpawners):     
            Spawner.Disable()
            
        #Enables only current levels spawners
        for(Spawner : Spawners):        
            Spawner.Enable()

Day := class():           #Class for each day
    var Tracker : tracker_device = tracker_device{}     #Tracker to track days

    var TextForEachDay : string = ""                    #Text on the tracker

    var TargetForEachDay : int = 0                      #Amount of zombies that need to be eliminated for the day to end


    AddtoTrack(Result : device_ai_interaction_result) : void=       #Adds to tracker when a zombie is kiled
        Agent := Result.Source
        if(RealAgent := Agent?):
            Tracker.Increment(RealAgent)

    StringToMessage<localizes>(value:string) : message = "{value}"  #String to message for tracker

    NextDay(DayNumber : int,Agent:agent) : void=        #Transfers to the next day on tracker
        Tracker.Reset(Agent)                                    #Resets the tracker
        Tracker.SetTarget(TargetForEachDay)                     #Sets new tracker target
        set TextForEachDay = "Day {DayNumber+2} Zombies Left:"  #Makes tracker text
        Tracker.SetTitleText(StringToMessage(TextForEachDay))   #Sets Tracker Text
        Tracker.AssignToAll()                                   #Assigns tracker to all

Day_Manager := class(creative_device):

    @editable TrackerForAll : tracker_device = tracker_device{}     #Main tracker for days

    @editable AllSpawners : []creature_spawner_device =array{}      #All creature spawners

    @editable GiveGold : item_granter_device = item_granter_device{}    #Granter to grant gold on each zombie kill

    @editable NewDayMsg : hud_message_device = hud_message_device{}     #HUD to display when a new day is starting

    @editable Reviver :down_but_not_out_device = down_but_not_out_device{}      #DBNO device to revive downed players at the end of a day

    @editable DayPauseTimer : timer_device = timer_device{}                     #Timer that shows grace period in between days



    #Day stuff
    var CurrentDay : Day = Day{}            #The current day
    var Days : []Day = array{}              #Array of days
    var DayIDX : int = 0                    #Current day Index
    var HudTextForEachDay : string = ""     #Base text for each day
    var NewTarget : int = 5                 #Base target for each day


    #Level Stuff
    @editable Levels : []Level = array{}    #Array of levels of zombie spawners
    var CurrentLevel : Level = Level{}      #The Current Level
    var LevelIDX : int = 0                  #Current Level Index
    

 
    
    @editable DayXP : accolades_device = accolades_device{}     #XP Rewarded for completing a day
    
    @editable ZombieXP : accolades_device = accolades_device{}  #XP Rewarded for eliminating a zombie

    @editable BeginSpawner : creature_spawner_device = creature_spawner_device{}    #Very first creature spawner


    var TempNum1 : int = 0


    StringToMessage<localizes>(value:string) : message = "{value}"  #String to message function

    
    OnBegin<override>()<suspends>:void=
        spawn:
            Initalize()#Initializes values

        CurrentDay.Tracker.CompleteEvent.Subscribe(NextDay) #Goes to next day when tracker is completed

        for(Creature : AllSpawners):
            Creature.EliminatedEvent.Subscribe(AddtoTracker)       #Triggers when a zombie is eliminated

    Initalize()<suspends> : void=

        for(L : Levels):
            set L.AllSpawners = AllSpawners     #Initializes all levels

        if(NewCurrentDay := Days[DayIDX]):      #Sets current day to day 0
            set CurrentDay = NewCurrentDay
        set CurrentDay.Tracker = TrackerForAll      #Sets tracker on current day to main tracker

        if(NewCurrentLevel := Levels[LevelIDX]):    #Sets current level to level 0
            set CurrentLevel = NewCurrentLevel



    AddtoTracker(Result : device_ai_interaction_result) : void=         #Adds to tracker and grants stuff
            Agent := Result.Source
                if(RealAgent := Agent?):
                    GiveGold.GrantItem(RealAgent)       #grants gold to player who eliminated zombie
                    ZombieXP.Award(RealAgent)           #grants xp to player who eliminated zombie
            CurrentDay.AddtoTrack(Result)   #Adds to tracker


    NextDay(Agent:agent) : void=        #goes to the next day

        DayXP.Award(Agent)  #Grants xp for completing day

        #logic to only change once (Trackers dont allow you to increment without assigning agent, making function trigger multiple times)
        set TempNum1 = 0
        var TempArray : []agent = array{}
        for(Player : GetPlayspace().GetPlayers()):
            if(FC:=Player.GetFortCharacter[], CurAgent:=FC.GetAgent[]):
                set TempArray += array{Agent}
        set TempNum1 += 1
        spawn:
            ResetTempNum1()

        if(TempNum1 =  TempArray.Length):
            if(DayIDX = 9 or DayIDX = 19 or DayIDX = 29 or DayIDX = 39 or DayIDX = 49 or DayIDX = 59 or DayIDX = 69 or DayIDX = 79 or DayIDX = 89): 
                ChangeLevel()   #Every 10 waves, goes to next level

            spawn:
                NextDayReal(Agent)  #Goes to next day
            
            for(Player:GetPlayspace().GetPlayers()):
                if(FC := Player.GetFortCharacter[],DownedAgent := FC.GetAgent[]):
                    if(FC.IsDownButNotOut[]):
                        Reviver.Revive(DownedAgent)     #Revives all downed players


    NextDayReal(Agent:agent)<suspends> : void=  #Function to go to next day
        Sleep(0.1)
        spawn:
            PauseBetween()          #Pauses in between days

        set NewTarget += 1  #Sets the new target for each day 1 higher

        set CurrentDay.TargetForEachDay = NewTarget   #Assigns new target  

        CurrentDay.NextDay(DayIDX,Agent)            #Changes tracker message

        set DayIDX += 1     #Increases day Index

        if(NewCurrentDay := Days[DayIDX]):      #Assigns new current day
            set CurrentDay = NewCurrentDay

        set CurrentDay.Tracker = TrackerForAll      #Assigns tracker to new day

            

    PauseBetween()<suspends> : void=        #pause in between days
        for(Creature : AllSpawners):        #Disables all spawners
            Creature.Disable()
            Creature.EliminateCreatures()
        
        set HudTextForEachDay = "Day {DayIDX+2}"    #Sets new hud message
        NewDayMsg.SetText(StringToMessage(HudTextForEachDay))   #Assigns it to HUD message device
        NewDayMsg.Show()    #Shows HUD to all players

        DayPauseTimer.Start()                   #Starts the pause timer
        DayPauseTimer.SuccessEvent.Await()      #Waits for timer to complete
        for(Creature : CurrentLevel.Spawners):  #Enables all current spawners    
            Creature.Enable()

    

    EnableFirstSpawners():void=     #Function used to start the first spawners

        for(Creature : CurrentLevel.Spawners):
            Creature.Enable()                   #Enables the first spawners

        TrackerForAll.AssignToAll()             #Assigns the tracker to all

        
    ChangeLevel() : void=           #changes the level 
        set LevelIDX += 1           #increase level index

        if(NewCurrentLevel := Levels[LevelIDX]):    #sets current level to new level
            set CurrentLevel = NewCurrentLevel

        CurrentLevel.Switch()                       #Switch spawners over


    ResetTempNum1()<suspends> : void=       #resets a number(For tracker logic)
        Sleep(5.0)
        set TempNum1 = 0


 


    
    

    
    
  

  



    

    
                
        
