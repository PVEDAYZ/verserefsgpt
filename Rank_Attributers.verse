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
using { /Fortnite.com/Game }

#THIS DEVICE WILL ALLOW CONTROL OF DIFFERENT POTENTIAL RANK POINTS

BaseAttributes := enum:
    Elimination
    Death
    Win
    Lose
    Extra


Attribute := class<concrete>():
    RankPersistence : Rank_Persistence = Rank_Persistence{}
    var RankSystem : Rank_System = Rank_System{}
    var BaseType : BaseAttributes = BaseAttributes.Extra

    @editable Trigger : trigger_device = trigger_device{}
    @editable Amount : float = 0.0
    @editable Text : string = ""



    AddAmounts(Agent: ?agent) : void=
        if(RealAgent := Agent?,CP := RankSystem.PlayersRankMap[RealAgent]):
            CP.RankChangeEvent.Signal(Amount,Text)
            CheckBaseTypes(RealAgent)


    CheckBaseTypes(Agent:agent ) : void=
        if(CP := RankSystem.PlayersRankMap[Agent]):
            if(BaseType = BaseAttributes.Elimination):
                set CP.Eliminations += 1.0
                set CP.KillStreak += 1
                RankPersistence.RecordPlayerStat(Agent, StatType.Eliminations, ?Score := 1.0)

            else if(BaseType = BaseAttributes.Death):
                set CP.Deaths += 1.0
                set CP.KillStreak = 0
                RankPersistence.RecordPlayerStat(Agent, StatType.Deaths, ?Score := 1.0)

            else if(BaseType = BaseAttributes.Win):
                set CP.Wins += 1.0
                set CP.WinStreak += 1
                RankPersistence.RecordPlayerStat(Agent, StatType.Wins, ?Score := 1.0)

            else if(BaseType = BaseAttributes.Lose):
                set CP.Loses += 1.0
                set CP.WinStreak = 0
                RankPersistence.RecordPlayerStat(Agent, StatType.Loses, ?Score := 1.0)
                


Rank_Attributers := class(creative_device):
    @editable RankSystem : Rank_System = Rank_System{}
    @editable var ExtraAttributes : []Attribute = array{}

    @editable var Elimination : Attribute = Attribute{BaseType := BaseAttributes.Elimination}
    @editable var Death : Attribute = Attribute{BaseType := BaseAttributes.Death}
    @editable var Win : Attribute = Attribute{BaseType := BaseAttributes.Win}
    @editable var Lose : Attribute = Attribute{BaseType := BaseAttributes.Lose}

    @editable DisplayRankOnLeaderboard : logic = false
    @editable ScoreManager : score_manager_device = score_manager_device{}

    @editable PlayerSpawners : []player_spawner_device = array{}

    OnBegin<override>()<suspends>:void=
        Initialize()

        #Initiates every player in lobby and future players who join
        for(Player : GetPlayspace().GetPlayers()) {TrackPlayer(Player)}
        GetPlayspace().PlayerAddedEvent().Subscribe(TrackPlayer)

        for(Spawner : PlayerSpawners):
            Spawner.SpawnedEvent.Subscribe(ReApplyVFX)

    Initialize() : void=
        set ExtraAttributes += array{Elimination,Death,Win,Lose}
        for(A : ExtraAttributes):
            set A.RankSystem = RankSystem
            A.Trigger.TriggeredEvent.Subscribe(A.AddAmounts)

    TrackPlayer(Agent:agent) : void=
        if(FC := Agent.GetFortCharacter[]):
            FC.EliminatedEvent().Subscribe(PlayerEliminated)
            if(DisplayRankOnLeaderboard?):
                spawn{ScoreWait(Agent)}
    PlayerEliminated(Result : elimination_result) : void=
        if:
            Target := Result.EliminatedCharacter
            TargetAgent := Target.GetAgent[]
            Instigator := Result.EliminatingCharacter?
            InstigatorAgent := Instigator.GetAgent[]
        then:
            if(TargetAgent <> InstigatorAgent):
                Elimination.Trigger.Trigger(InstigatorAgent)
                Death.Trigger.Trigger(TargetAgent)

    ScoreWait(Agent:agent)<suspends> : void=
        if(CP := RankSystem.PlayersRankMap[Agent]):
            loop:
                CP.UpdateEvent.Await()
                if(NewValue := Int[CP.RankValue]):
                    ScoreManager.SetScoreAward(NewValue)
                    ScoreManager.Activate(Agent)

    ReApplyVFX(Agent:agent): void=
        if(CP := RankSystem.PlayersRankMap[Agent],CurRank := CP.AllRanks[CP.Rank]):
            if(CP.ApparelSetting = ApparelType.Back):
                CurRank.RankVFXs.BackVFX.Pickup(CP.Player)
            else if(CP.ApparelSetting = ApparelType.Hover):
                CurRank.RankVFXs.HoverVFX.Pickup(CP.Player)