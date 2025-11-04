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
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Colors }
using { /Verse.org/Assets }
using { /Verse.org/Random }
using { /Fortnite.com/Characters }

#THIS DEVICE WILL ACT AS A PET MANAGER AND ALLOW PLAYERS TO EQUP / UNEQUIP THE PETS THAT THEY OWN

#Main creative device class visible in UEFN
Pet_Manager := class(creative_device):
    #Devices
    TT_PetManager_Device_GameManager<localizes>:message = "Your Game Manager device"
    @editable{ToolTip := TT_PetManager_Device_GameManager} GameManager : Game_Manager = Game_Manager{}       

    TT_PetManager_Device_ResourceManager<localizes>:message = "Your Resource Manager device"
    @editable{ToolTip := TT_PetManager_Device_ResourceManager} ResourceManager : Resource_Manager = Resource_Manager{}

    TT_PetManager_Device_PurchaseXP<localizes>:message = "The accolades device which is used to award the player xp for purchasing a pet"
    @editable{ToolTip := TT_PetManager_Device_PurchaseXP} PurchaseXP : accolades_device = accolades_device{}

    TT_PetManager_Device_PurchaseSuccessSound<localizes>:message = "The audio player device which is used to play the sound when a pet is purchased\n*Required Settings*\n Can be heard by : Instigator Only\n Play Location : Instigating Player"
    @editable{ToolTip := TT_PetManager_Device_PurchaseSuccessSound} PurchaseSuccessSound : audio_player_device = audio_player_device{}
    
    TT_PetManager_Device_PurchaseFailureSound<localizes>:message = "The audio player device which is used to play the sound when a pet cannot be purchased\n*Required Settings*\n Can be heard by : Instigator Only\n Play Location : Instigating Player"
    @editable{ToolTip := TT_PetManager_Device_PurchaseFailureSound} PurchaseFailureSound : audio_player_device = audio_player_device{}
    
    TT_PetManager_Device_PurchaseFailMSG<localizes>:message = "The hud message device which is used to display the message when a pet cannot be purchased\n*Required Settings*\nMessage Recipient : Triggering Player"
    @editable{ToolTip := TT_PetManager_Device_PurchaseFailMSG} PurchaseFailMSG : hud_message_device = hud_message_device{}                     
    
    TT_PetManager_Device_AlreadyHaveMSG<localizes>:message = "The hud message device which is used to display the message when a player already has a pet equipped\n*Required Settings*\nMessage Recipient : Triggering Player"
    @editable AlreadyHaveMSG : hud_message_device = hud_message_device{}                  
    
    TT_PetManager_Device_SuccessMSG<localizes>:message = "The hud message device which is used to display the message when a pet is purchased\n*Required Settings*\nMessage Recipient : Triggering Player"
    @editable{ToolTip := TT_PetManager_Device_SuccessMSG} SuccessMSG : hud_message_device = hud_message_device{}
    
    TT_PetManager_Device_MustPurchaseFirstMSG<localizes>:message = "The hud message device which is used to display the message when a player must purchase a pet first\n*Required Settings*\nMessage Recipient : Triggering Player"
    @editable{ToolTip := TT_PetManager_Device_MustPurchaseFirstMSG} MustPurchaseFirstMSG : hud_message_device = hud_message_device{}

    #Settings
    TT_PetManager_Device_AllPets<localizes>:message = "The array of all pets"
    @editable{ToolTip := TT_PetManager_Device_AllPets} AllPets : []PetBuyable = array{}
    
    TT_PetManager_Device_ShopSettings<localizes>:message = "The shop settings for the pet shop"
    @editable{ToolTip := TT_PetManager_Device_ShopSettings} ShopSettings : PetShopSetting = PetShopSetting{}

    TT_RBM_Device_AddedPlayerTrigger<localizes>:message = "A trigger device that get triggered when a player is added to the plot"
    @editable{ToolTip := TT_RBM_Device_AddedPlayerTrigger} PlayerAddedToPlotTrigger : trigger_device = trigger_device{}

    #Map of all players info
    var PlayersPetMap : [player]PlayerPets = map{}      

    #Images
    #====================================================================================================================================================
    var EquipPostImages : []texture = array{}
    var EquipPreImages : []texture = array{}
    var ShopPostImages : []texture = array{}
    var ShopPreImages : []texture = array{}
    var EquipBackgroundImage : texture = MasterAssets.Placeholder
    var ShopBackgroundImage : texture = MasterAssets.Placeholder
    #====================================================================================================================================================

    #Calls event binding and initialize functions
    OnBegin<override>()<suspends>:void=
        InitializePets()
        if(OpenEquipTrigger := trigger_device[ShopSettings.EquipSettings.UseUI.UseDifferentOpenTrigger?], ShopSettings.EquipSettings.UseUI.Enabled?){OpenEquipTrigger.TriggeredEvent.Subscribe(OpenEquipUI)}   
        if(ShopSettings.ShopType = shoptype.UI){ShopSettings.ShopUIOptions.OpenShopUITrigger.TriggeredEvent.Subscribe(OpenPetShop)}
            
        #Calls functions to equip previously equipped pets when a player joins
        #for(Player : GetPlayspace().GetPlayers()){AddPetsOnStart1(Player)}
        #GetPlayspace().PlayerAddedEvent().Subscribe(AddPetsOnStart1)
        GetPlayspace().PlayerRemovedEvent().Subscribe(RemoveFromPetMap)
        PlayerAddedToPlotTrigger.TriggeredEvent.Subscribe(AddPetsOnStart1)
        
    #Removes the player from the map whenever they leave the session
    RemoveFromPetMap(Agent:agent) : void=
        if(Player := player[Agent],Exists := PlayersPetMap[Player]):
            if(NewMap := PlayersPetMap.WithRemovedKey(Player)?):
                set PlayersPetMap = NewMap

    #Opens the equip UI from the shop settings
    OpenEquipUI(MAgent:?agent) : void=       
        if(Agent := MAgent?, PlayersPets := PlayersPetMap[Agent]):
            NewPets := GetNewPets()
            NewUI := BuyableUI:
                GameManager := GameManager
                ResourceManager := ResourceManager
                ShopSettings := ShopSettings
                Buyables := NewPets
                EquipBackgroundImage := EquipBackgroundImage
                ShopBackgroundImage := ShopBackgroundImage

            NewUI.Initialize(Agent)
            NewUI.AddEquipUI(Agent)

    #Opens the shop UI from the shop settings
    OpenPetShop(MAgent:?agent) : void=
        if(Agent := MAgent?, PlayersPets := PlayersPetMap[Agent]):
            Print("OPEN UI")
            NewPets := GetNewPets()
            NewShopUI := BuyableUI{
                GameManager := GameManager
                Buyables := NewPets
                ShopSettings := ShopSettings
                ShopBackgroundImage := ShopBackgroundImage
                EquipBackgroundImage := EquipBackgroundImage
            }
           
            NewShopUI.Initialize(Agent)
            NewShopUI.AddShopUI(Agent)

    #Initializes all pets
    InitializePets() : void=
        for(idx -> P : AllPets):
            set P.IDX = idx + 1
            set P.GameManager = GameManager
            set P.ResourceManager = ResourceManager
            set P.PetManager = Self
            set P.ShopSettings = ShopSettings
            set P.PurchaseXP = PurchaseXP
            set P.PurchaseSuccessSound = PurchaseSuccessSound
            set P.PurchaseFailureSound = PurchaseFailureSound
            set P.PurchaseFailMSG = PurchaseFailMSG         
            set P.AlreadyHaveMSG = AlreadyHaveMSG         
            set P.SuccessMSG = SuccessMSG
            set P.MustPurchaseFirstMSG = MustPurchaseFirstMSG
            set P.ShopPostImages = ShopPostImages
            set P.ShopPreImages = ShopPreImages
            set P.EquipPreImages = EquipPreImages
            set P.EquipPostImages = EquipPostImages
            P.MainTrigger.TriggeredEvent.Subscribe(P.PurchaseForTrigger)

    #Prefunction to AddPetsOnStart
    AddPetsOnStart1(MaybeAgent:?agent) : void=
        Print("TRY START")
        if (Agent := MaybeAgent?):
            InitializePlayerPets(Agent)
            #spawn{AddPetsOnStart(Agent)}


    #Adds all pets that were previously equipped when a player joins the game
    AddPetsOnStart(Agent:agent)<suspends> : void=
        Sleep(1.0)
        if(CP := Custom_Player[GameManager.PlayersMap[Agent]]):
            NewPets := GetNewPets()
            for(Num : CP.EquippedPets):
                for(P : NewPets):
                    if(P.IDX = Num){P.EquipPet(Agent)}

    #Initializes pets for a player
    InitializePlayerPets(Agent:agent) : void=
        if(Player := player[Agent]):    
            if(PlayerExists := PlayersPetMap[Player]):      
            else:
                NewPets := GetNewPets()
                if(set PlayersPetMap[Player] = PlayerPets{        
                    Player := Player
                    }){}
                spawn{AddPetsOnStart(Agent)}
    
    #Returns a duplicate copy of pets, except with new buttons
    GetNewPets() : []PetBuyable=
        var NewPets : []PetBuyable = array{}
        for(A : AllPets):
            set NewPets += array{PetBuyable{
                PersistanceManager := A.PersistanceManager
                GameManager := A.GameManager
                ResourceManager := A.ResourceManager
                PetManager := A.PetManager 
                IDX := A.IDX
                CurBuyableUI := A.CurBuyableUI
                ShopSettings := A.ShopSettings
                ShopButtons := UIAllButtons{}
                ShopPreImages := A.ShopPreImages
                ShopPostImages := A.ShopPostImages
                EquipPreImages := A.EquipPreImages
                EquipPostImages := A.EquipPostImages
                EquipButtons := UIAllButtons{}
                EquipPreImage := A.EquipPreImage
                EquipPostImage := A.EquipPostImage
                PurchaseXP := A.PurchaseXP
                PurchaseSuccessSound := A.PurchaseSuccessSound
                PurchaseFailureSound := A.PurchaseFailureSound
                PurchaseFailMSG := A.PurchaseFailMSG
                AlreadyHaveMSG := A.AlreadyHaveMSG
                SuccessMSG := A.SuccessMSG
                MustPurchaseFirstMSG := A.MustPurchaseFirstMSG
                MainTrigger := A.MainTrigger
                CostResources := A.CostResources
                BoostResources := A.BoostResources
                EquippedTrigger := A.EquippedTrigger
                UnEquippedTrigger := A.UnEquippedTrigger
                PetProp := A.PetProp
                PetHoverHeight := A.PetHoverHeight
                DistanceAllowedNearPlayer := A.DistanceAllowedNearPlayer
                ConstantSpeedCMPerS := A.ConstantSpeedCMPerS
                TimedSpeed := A.TimedSpeed
                IdleAnimation := A.IdleAnimation

                IsEquipped := false
                DespawnEvent := event(){}
                IsIdle := false
                ChangeStatEvent := event(){}

            }}
        return NewPets
            
#Class for each pet that is inherited from main Buyable class
PetBuyable := class<concrete>(Buyable):
    #Devices
    TT_PetManager_Device_PetProp<localizes>:message = "The prop that is used to display the pet"
    @editable{ToolTip := TT_PetManager_Device_PetProp} PetProp : creative_prop_asset = DefaultCreativePropAsset
    var PetManager : Pet_Manager = Pet_Manager{}

    #Settings
    TT_PetManager_Device_PetHoverHeight<localizes>:message = "The height relative to the player that the pet will hover at"
    @editable{ToolTip := TT_PetManager_Device_PetHoverHeight} PetHoverHeight : float = 0.0
    
    TT_PetManager_Device_DistanceAllowedNearPlayer<localizes>:message = "How close the pet will get to the player"
    @editable{ToolTip := TT_PetManager_Device_DistanceAllowedNearPlayer} DistanceAllowedNearPlayer : float = 0.0
    
    TT_PetManager_Device_ConstantSpeedCMPerS<localizes>:message = "The speed at which the pet will move towards the player"
    @editable{ToolTip := TT_PetManager_Device_ConstantSpeedCMPerS} ConstantSpeedCMPerS : ?float = false

    TT_PetManager_Device_TimedSpeed<localizes>:message = "If set, the pet will always take this long to reach the player regardless of distance"
    @editable{ToolTip := TT_PetManager_Device_TimedSpeed} TimedSpeed : ?float = false

    TT_PetManager_Device_IdleAnimation<localizes>:message = "If true, the pet will play an idle animation when it is not moving"
    @editable{ToolTip := TT_PetManager_Device_IdleAnimation} IdleAnimation : logic = false

    #Extra
    var DespawnEvent : event() = event(){}
    var IsIdle : logic = false
    var ChangeStatEvent : event() = event(){}
    
    #Equips the pet
    EquipPet(Agent:agent) : void=
        SpawnPet(Agent)
        GiveBonuses(Agent)
        if(PlayersPets := PetManager.PlayersPetMap[Agent]):
            set PlayersPets.Pets += array{Self}

    #Unequips the pet
    UnEquipPet(Agent:agent) : void=
        RemoveBonuses(Agent)
        if(PlayersPets := PetManager.PlayersPetMap[Agent]):
            for(P : PlayersPets.Pets):
                if(P.IDX = IDX):
                    P.DespawnEvent.Signal()

    #Spawns the pet in when equipped
    SpawnPet(Agent:agent):void=    
        if(FC:=Agent.GetFortCharacter[ ]):
            PlayerPos := FC.GetTransform().Translation
            PlayerForward := FC.GetViewRotation().GetLocalForward() * 300.0
            PetSpawnPos := PlayerPos + PlayerForward
            if(SpawnedProp := SpawnProp(PetProp,PetSpawnPos,rotation{})(0)?):
                spawn{PetFollowsPlayer(FC,SpawnedProp)}  

    #Controls the pet movement when spawned
    PetFollowsPlayer( FortniteCharacter : fort_character, CreativeProp : creative_prop)<suspends> : void =
        if(Agent := FortniteCharacter.GetAgent[], CP := Custom_Player[GameManager.PlayersMap[Agent]]):
            race:
                block:
                    DespawnEvent.Await()
                    CreativeProp.Dispose()
                    return
                loop:
                    Sleep(0.0)
                    PlayerPos := FortniteCharacter.GetTransform().Translation
                    PetPos := CreativeProp.GetTransform().Translation
                    DistanceFromPlayer := Distance(PlayerPos, PetPos)
                    PlayerRight := FortniteCharacter.GetTransform().Rotation.GetLocalRight()
                    DirectionPetToPlayer := PlayerPos - PetPos
                    Angle := ArcTan(DirectionPetToPlayer.X, DirectionPetToPlayer.Y) - 3.14 / 2.0
                    NewRotation := MakeRotation( vector3{ X := 0.0, Y := 0.0, Z := -1.0} , Angle)  
                    if(EquippedPos := CP.EquippedPets.Find[IDX]):
                        NoJumpPlayerPos := vector3{ X := PlayerPos.X + PlayerRight.X * DistanceAllowedNearPlayer * 0.65 + (EquippedPos * 70.0), Y := PlayerPos.Y + PlayerRight.Y * DistanceAllowedNearPlayer * 0.65 + (EquippedPos * 70.0), Z := PlayerPos.Z + PetHoverHeight}
                        if (DistanceFromPlayer > DistanceAllowedNearPlayer):
                            set IsIdle = false
                            ChangeStatEvent.Signal()
                            if(NewTime := ConstantSpeedCMPerS?):
                                Time := DistanceFromPlayer / NewTime
                                CreativeProp.MoveTo(NoJumpPlayerPos, NewRotation, Time)
                            else if(NewTime := TimedSpeed?):
                                CreativeProp.MoveTo(NoJumpPlayerPos, NewRotation, NewTime)
                        else:
                            if(not IsIdle? , IdleAnimation?):
                                set IsIdle = true
                                spawn{PlayIdleAnim(CreativeProp)}

    #Plays the idle animation for the pet
    PlayIdleAnim(Prop : creative_prop)<suspends> : void=
        PetPos := Prop.GetTransform().Translation
        PetRot := Prop.GetTransform().Rotation
        race:
            block:
                ChangeStatEvent.Await()
            loop:
                Sleep(0.0)
                Prop.MoveTo(PetPos - vector3{Z:= 30.0}, PetRot, 0.5)
                Prop.MoveTo(PetPos + vector3{Z:= 30.0}, PetRot, 0.5)

#Class to hold each players pets
PlayerPets := class():
    Player : player
    var Pets : []PetBuyable = array{}

#Extra settings unique to pet shop, inherited from the base class 'ShopSetting'
PetShopSetting := class<concrete>(ShopSetting):
    @editable MaxEquippedAtATime : int = 0