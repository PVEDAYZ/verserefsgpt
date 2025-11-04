
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level

PlayerScores := class():
    var Player : agent
    var Score : int = 0


Leaderboard_Manager := class(creative_device):

    @editable ScoreManager : score_manager_device = score_manager_device{}
    @editable Billboards : []billboard_device = array{}

    OnBegin<override>()<suspends>:void=
        UpdateScoreLoop()

    StringToMessage<localizes>(String : string, Agent : agent) : message = "{String}{Agent}"
    
    UpdateScoreLoop()<suspends> : void=
        loop:
            Sleep(1.0)
            var AllScores : []PlayerScores = array{}
            for(Player : GetPlayspace().GetPlayers()): 
                CurrentPlayerScore := ScoreManager.GetCurrentScore(Player)
                set AllScores += array{PlayerScores{Player := Player, Score := CurrentPlayerScore}}

            SortedScores := SortAllScores(AllScores)

            for(idx -> S : SortedScores, BB := Billboards[idx]):
                BB.SetText(StringToMessage("#{idx+1} / {S.Score} / ", S.Player))

    SortAllScores(UnsortedScore : []PlayerScores) : []PlayerScores=
        var SortedArray : []PlayerScores = UnsortedScore

        for(I := 0..SortedArray.Length - 1):
            for(J := 0..SortedArray.Length - I - 2):
                if(E1 := SortedArray[J], E2 := SortedArray[J + 1]):
                    if(E1.Score < E2.Score):
                        if:
                            set SortedArray[J] = E2
                            set SortedArray[J + 1] = E1
        return SortedArray