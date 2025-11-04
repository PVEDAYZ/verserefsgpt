using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# A Verse-authored creative device that can be placed in a level
cash_spawner_device := class(creative_device):

    @editable GameManager : game_manager = game_manager{}
    @editable Props : []creative_prop = array{}
    @editable Collectables : []collectible_object_device = array{}
    @editable CashToGive : int = 200
    @editable RespawnTime : float = 60.0
    @editable SpinSpeed : float = 0.1
    @editable RewardInterval : float = 30.0  # Customizable interval for rewards
    @editable ItemGranter : item_granter_device = item_granter_device{}  # The item granter device

    # Audio feedback properties for collect and respawn sounds
    @editable CollectSound : audio_player_device = audio_player_device{}
    @editable RespawnSound : audio_player_device = audio_player_device{}

    # ---- Accolades hooks (optional; leave empty for no XP awards) ----
    @editable CollectAccolades : []accolades_device = array{}   # award on each collect
    @editable IntervalAccolades : []accolades_device = array{}  # award to most recent collector when GrantReward fires

    # Internal
    var LastCollector : ?agent = false

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>: void = 
        spawn{RotateProps()}
        spawn{RespawnCash()}
        spawn{GrantReward()}  # Start reward granting loop
        for(Collectable : Collectables):
            # Subscribe to event
            Collectable.CollectedEvent.Subscribe(OnCollected)  # Subscribe without visibility checks

    OnCollected(Agent : agent): void = 
        # Play sound when item is collected
        CollectSound.Play(Agent)  # Play sound for the agent (player)
        
        # Add money to the player's account and show the money
        GameManager.AddMoney(CashToGive, Agent)
        GameManager.ShowMoney(CashToGive, Agent)

        # Accolades: award for this collect (optional)
        AwardAccolades(option{Agent}, CollectAccolades)

        # Track the most recent collector for interval awards
        set LastCollector = option{Agent}

    RespawnCash() <suspends>: void = 
        loop:
            Sleep(RespawnTime)  # Wait for RespawnTime before respawning
            for(Collectable : Collectables):
                # Respawn all collectibles
                Collectable.RespawnForAll()
                
                # Play sound when collectible respawns
                RespawnSound.Play()  # Play respawn sound without specifying a target

    GrantReward() <suspends>: void = 
        loop:
            Sleep(RewardInterval)  # Wait for the customizable reward interval
            # Grant an item to the player through the Item Granter
            ItemGranter.GrantItem  # This matches existing behavior
            # Accolades: award interval-based XP to the most recent collector (if any configured)
            AwardAccolades(LastCollector, IntervalAccolades)

    var I : int = 0
    RotateProps() <suspends>: void = 
        loop:
            Sleep(1.0)  # Sleep for 1 second to reduce the loop frequency
            set I += 1
            for (Prop : Props):
                # Cache the transform of the prop once per loop iteration
                PropTransform := Prop.GetTransform()

                # Apply rotation only to the cached transform
                Rot := PropTransform.Rotation.ApplyYaw(SpinSpeed)
                PropTranslation := PropTransform.Translation

                # Move the prop to the new position with the updated rotation
                if(Prop.TeleportTo[PropTranslation, Rot]) {}

                # Reset rotation after a large number of iterations
                if(I = 10000):
                    if(Prop.TeleportTo[PropTranslation, IdentityRotation()]) {}

    # ---------------- Helpers ----------------
    AwardAccolades(MaybeAgent : ?agent, List : []accolades_device):void=
        if(List.Length = 0):
            return
        if(Agent := MaybeAgent?):
            for(A : List):
                A.Award(Agent)
