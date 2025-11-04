
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }
using { /Fortnite.com/Characters }

pet_purchase_data := class<concrete>:
    @editable BuyButton : button_device = button_device{}
    @editable Price : int = 0
    @editable BuffStat : string = "Customers"
    @editable Mult : float = 0.1 
    @editable PetProps : []creative_prop = array{}

    var Index : int = -1
    var MaybeMainDevice : ?pets_device = false
    var AvailablePetProps : []logic = array{}

    OnPurchase(Agent : agent): void=
        if(MainDevice := MaybeMainDevice?):
            MainDevice.Purchase(Agent, Self) 


# A Verse-authored creative device that can be placed in a level
pets_device := class(creative_device):

    @editable PetPurchasesData : []pet_purchase_data = array{}
    @editable GameManager : game_manager = game_manager{}
    @editable SuccessMessage : hud_message_device = hud_message_device{}
    @editable FailMessage : hud_message_device = hud_message_device{}

    var AnimationKeyFrames : []keyframe_delta = array{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for(I := 0..PetPurchasesData.Length-1, PetPurchaseData := PetPurchasesData[I]):
            for(J := 0..PetPurchaseData.PetProps.Length-1, PetProp := PetPurchaseData.PetProps[J]):
                PetProp.Hide()
                set PetPurchaseData.AvailablePetProps += array{true}

            set PetPurchaseData.MaybeMainDevice = option{Self}
            set PetPurchaseData.Index = I
            PetPurchaseData.BuyButton.InteractedWithEvent.Subscribe(PetPurchaseData.OnPurchase)
        
        UpMovementKeyframe : keyframe_delta = keyframe_delta{
            DeltaLocation := vector3{X := 0.0, Y := 0.0, Z := 30.0}
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3{X := 1.0, Y := 1.0, Z := 1.0}
            Time := 0.85
            Interpolation := Ease
        }

        DownMovementKeyframe : keyframe_delta = keyframe_delta{
            DeltaLocation := vector3{X := 0.0, Y := 0.0, Z := -30.0}
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3{X := 1.0, Y := 1.0, Z := 1.0}
            Time := 0.85
            Interpolation := Ease
        }

        set AnimationKeyFrames = array{UpMovementKeyframe, DownMovementKeyframe}
        spawn{AsyncPetFollow()}
        spawn{GiveBuff()}

    Reset(Agent: agent):void=
        if(AgentData := GameManager.AgentMap[Agent]):
            for(OwnedPetTuple : AgentData.OwnedPets):
                PetProp : creative_prop = OwnedPetTuple(0)
                PetPurchaseDataIndex : int = OwnedPetTuple(1)

                PetProp.Hide()
                if(PetPurchaseData := PetPurchasesData[PetPurchaseDataIndex]):
                    var I : int = 0
                    loop:
                        if(Availability : logic = PetPurchaseData.AvailablePetProps[I]):
                            if(Availability = false):
                                if(set PetPurchaseData.AvailablePetProps[I] = true){}
                                break
                        else:
                            break
                        set I += 1

    Purchase(Agent : agent, PetPurchaseData : pet_purchase_data):void=
        var FoundPetIndex : int = -1
        if(AgentData := GameManager.AgentMap[Agent]):
            for(I := 0..AgentData.OwnedPets.Length-1, OwnedPetTuple := AgentData.OwnedPets[I]):
                PetPurchaseIndex : int = OwnedPetTuple(1)
                if(PetPurchaseIndex = PetPurchaseData.Index):
                    set FoundPetIndex = I

        if(FoundPetIndex = -1):
            var AvailablePetPropIndex : int = -1
            for(I := 0..PetPurchaseData.AvailablePetProps.Length-1, AvailablePetProp := PetPurchaseData.AvailablePetProps[I]):
                if(AvailablePetProp = true):
                    set AvailablePetPropIndex = I

            if(AvailablePetPropIndex = -1):
                Print("All Pets are Purchased!")
                return
            Money := GameManager.GetMoney(Agent)
            if(Money < PetPurchaseData.Price*1.0):
                Print("Not Enough Money!")
                FailMessage.Show(Agent)
                return
            
            GameManager.AddMoney(PetPurchaseData.Price*-1, Agent)
            SuccessMessage.Show(Agent)

            if(set PetPurchaseData.AvailablePetProps[AvailablePetPropIndex] = false){}

            if(PetProp : creative_prop = PetPurchaseData.PetProps[AvailablePetPropIndex], AgentData := GameManager.AgentMap[Agent]):
                PetTuple : tuple(creative_prop, int) = (PetProp, PetPurchaseData.Index)

                set AgentData.OwnedPets += array{PetTuple}
                set FoundPetIndex = AgentData.OwnedPets.Length-1


        if(AgentData := GameManager.AgentMap[Agent]):
            if(PetPropTuple := AgentData.OwnedPets[AgentData.ActivePetIndex]):
                PetProp := PetPropTuple(0)
                PetProp.Hide()
            
            set AgentData.ActivePetIndex = FoundPetIndex
            if(PetPropTuple := AgentData.OwnedPets[AgentData.ActivePetIndex]):
                PetProp := PetPropTuple(0)
                PetProp.Show()

                if(FortCharacter := Agent.GetFortCharacter[]):
                    var TeleportLoc : vector3 = FortCharacter.GetTransform().Translation
                    set TeleportLoc.X += 50.0

                    if(PetProp.TeleportTo[TeleportLoc, IdentityRotation()]){}
            
            set AgentData.bPetPlayingAnim = false
    
    AsyncPetFollow()<suspends>:void=
        FollowDistance : float = 200.0
        WaitDistance : float = 100.0
        SleepTime : float = 0.5

        loop: 
            Sleep(SleepTime)
            for(Player : GetPlayspace().GetPlayers(), AgentData := GameManager.AgentMap[Player],
            PetPropTuple := AgentData.OwnedPets[AgentData.ActivePetIndex], FortCharacter := Player.GetFortCharacter[]):
                PetProp : creative_prop = PetPropTuple(0)
                PetLoc : vector3 = PetProp.GetTransform().Translation
                PlayerLoc : vector3 = FortCharacter.GetTransform().Translation
                DistanceToPlayer : float = Distance(PetLoc, PlayerLoc)

                if(DistanceToPlayer >= FollowDistance):
                    if(Direction := (PlayerLoc-PetLoc).MakeUnitVector[]):
                        DistanceToTravel : float = DistanceToPlayer - WaitDistance
                        var LocationToTravel : vector3 = PetLoc + (Direction * DistanceToTravel)

                        set AgentData.bPetPlayingAnim = false

                        if(PropAnimController := PetProp.GetAnimationController[]):
                            PropAnimController.Stop()
                        
                        PlayerRotation := FortCharacter.GetTransform().Rotation
                        spawn{PetProp.MoveTo(LocationToTravel, PlayerRotation, SleepTime)}
                else:
                    if(AgentData.bPetPlayingAnim = false):
                        set AgentData.bPetPlayingAnim = true
                        if(PropAnimController := PetProp.GetAnimationController[]):
                            PropAnimController.SetAnimation(AnimationKeyFrames, ?Mode := animation_mode.Loop)
                            PropAnimController.Play()

    GiveBuff()<suspends>:void=
        loop: 
            Sleep(1.0)
            for(Player : GetPlayspace().GetPlayers(), AgentData := GameManager.AgentMap[Player]):
                for(PetPurchaseData : PetPurchasesData):
                    if(PetPurchaseData.Index = AgentData.ActivePetIndex):
                        if(PetPurchaseData.BuffStat = "Customers"):
                            if(ToAdd := Floor[AgentData.Orders*PetPurchaseData.Mult]):
                                set AgentData.Customers += ToAdd
                        else if(PetPurchaseData.BuffStat = "Money"):
                            ToAdd := AgentData.MoneyPerSecond*PetPurchaseData.Mult
                            set AgentData.TotalMoney += ToAdd



