
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }


Player_Effects := class():
    Player : player
    var PlayersEquippedVFX : ?creative_prop_asset = false


VFXEquippers := class<concrete>():
    @editable Trigger : trigger_device = trigger_device{}
    @editable EffectProp : creative_prop_asset = DefaultCreativePropAsset
    var EliminationEffectManager : EliminationEffect_Manager = EliminationEffect_Manager{}

    ChangeEffect(MAgent : ?agent) : void=
        if(Agent := MAgent?):
            if(PE := EliminationEffectManager.PlayerMap[Agent]):
                set PE.PlayersEquippedVFX = option{EffectProp}


EliminationEffect_Manager := class(creative_device):

   
    @editable Equippers : []VFXEquippers = array{}

    var PlayerMap : [player]Player_Effects = map{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers()):
            TrackElim(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(TrackElim)


        for(Equipper : Equippers):
            set Equipper.EliminationEffectManager = Self
            Equipper.Trigger.TriggeredEvent.Subscribe(Equipper.ChangeEffect)


    TrackElim(Player : player) : void=
        if(not PlayerMap[Player]):
            if(set PlayerMap[Player] = Player_Effects{Player := Player}){}





        spawn:
            TrackElim2(Player)

    TrackElim2(Player : player)<suspends> : void=
        if(FC := Player.GetFortCharacter[]):
            race:
                block:
                    loop:
                        LeavingPlayer := GetPlayspace().PlayerRemovedEvent().Await()
                        if(LeavingPlayer = Player):
                            break
                block:
                    loop:
                        Sleep(0.0)
                        ElimResult := FC.EliminatedEvent().Await()
                        spawn{PlayEffectAt(ElimResult)}


    PlayEffectAt(ElimResult : elimination_result)<suspends> : void=
        DeadFC := ElimResult.EliminatedCharacter
        if(KillerFC := ElimResult.EliminatingCharacter?):
            if(KillerAgent := KillerFC.GetAgent[]):
                if(KillerPE := PlayerMap[KillerAgent]):
                    if(VFXIsEquipped := KillerPE.PlayersEquippedVFX?):
                        PlayerPos := DeadFC.GetTransform()
                        if(NewProp := SpawnProp(VFXIsEquipped , PlayerPos)(0)?):
                            Sleep(3.0)
                            NewProp.Dispose()