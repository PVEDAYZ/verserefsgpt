using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/Diagnostics } 

CollectibleReward := class(tag){}   

Tagged_Collectible_Rewards := class(creative_device):

    @editable CollectibleTag : tag = CollectibleReward{}

    @editable Reward_1 : ?accolades_device = false
    @editable Reward_2 : ?accolades_device = false
    @editable Reward_3 : ?accolades_device = false
    @editable Reward_4 : ?accolades_device = false
    @editable Reward_5 : ?accolades_device = false

    @editable Reward1_Analytics : ?analytics_device = false
    @editable Reward2_Analytics : ?analytics_device = false
    @editable Reward3_Analytics : ?analytics_device = false
    @editable Reward4_Analytics : ?analytics_device = false
    @editable Reward5_Analytics : ?analytics_device = false

    var RewardIndex : int = 0

    OnBegin<override>()<suspends>:void =
        Print("Tagged_Collectible_Rewards: OnBegin - scanning for tagged collectibles.")
        var Subscribed : int = 0
        for (Obj : Self.FindCreativeObjectsWithTag(CollectibleTag)):
            if (C := collectible_object_device[Obj]):
                C.CollectedEvent.Subscribe(OnCollected)
                set Subscribed += 1
            else:
                Print("Tagged_Collectible_Rewards: Found object with tag but not a collectible device.")
        Print("Tagged_Collectible_Rewards: Subscribed to CollectedEvent on {Subscribed} collectible(s).")

    OnCollected(Collector:agent):void =
        Print("Tagged_Collectible_Rewards: OnCollected fired.")
        if (P := player[Collector]):
            Print("Tagged_Collectible_Rewards: Collector is a player. Routing to AwardAlternate12.")
            AwardAlternate12(P)
        else:
            Print("Tagged_Collectible_Rewards: Collector is not a player; skipping.")

    AwardAlternate12(P:player):void =
        Print("Tagged_Collectible_Rewards: AwardAlternate12 entered. Current RewardIndex={RewardIndex}")
        if (RewardIndex = 0):
            if (R1 := Reward_1?):
                R1.Award(P)
                Print("Tagged_Collectible_Rewards: Awarded Reward_1.")
                if (A1 := Reward1_Analytics?):
                    A1.Submit(P)
                    Print("Tagged_Collectible_Rewards: Submitted Reward1_Analytics.")
            else:
                Print("Tagged_Collectible_Rewards: Reward_1 not set, falling back to Reward_2.")
                if (R2 := Reward_2?):
                    R2.Award(P)
                    Print("Tagged_Collectible_Rewards: Awarded Reward_2 (fallback).")
                    if (A2 := Reward2_Analytics?):
                        A2.Submit(P)
                        Print("Tagged_Collectible_Rewards: Submitted Reward2_Analytics (fallback).")
                else:
                    Print("Tagged_Collectible_Rewards: Neither Reward_1 nor Reward_2 set; no award given.")
            set RewardIndex = 1
            Print("Tagged_Collectible_Rewards: Toggled RewardIndex -> {RewardIndex}")
        else:
            if (R2 := Reward_2?):
                R2.Award(P)
                Print("Tagged_Collectible_Rewards: Awarded Reward_2.")
                if (A2 := Reward2_Analytics?):
                    A2.Submit(P)
                    Print("Tagged_Collectible_Rewards: Submitted Reward2_Analytics.")
            else:
                Print("Tagged_Collectible_Rewards: Reward_2 not set, falling back to Reward_1.")
                if (R1 := Reward_1?):
                    R1.Award(P)
                    Print("Tagged_Collectible_Rewards: Awarded Reward_1 (fallback).")
                    if (A1 := Reward1_Analytics?):
                        A1.Submit(P)
                        Print("Tagged_Collectible_Rewards: Submitted Reward1_Analytics (fallback).")
                else:
                    Print("Tagged_Collectible_Rewards: Neither Reward_2 nor Reward_1 set; no award given.")
            set RewardIndex = 0
            Print("Tagged_Collectible_Rewards: Toggled RewardIndex -> {RewardIndex}")
