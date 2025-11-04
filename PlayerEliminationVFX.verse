
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

#VERSE SCRIPT
#Author: Logan Lewis
#Follow me on Twitter.com/X.com @LL_Visuals
#Discord: llvisual
#A device that spawns a Blueprint Prop (in the example shown, inside is a Niagra Particle System Component) upon player death

#TO-DO: 
# - Drag your Blueprint with a Niagra System inside, from your content browser, into the details panel into "DeathNiagraFX"
# - Select your Elimination Manager Device in the details panel

eliminationvfx := class(creative_device):
    @editable DeathNiagraFX : creative_prop_asset = DefaultCreativePropAsset 
    @editable EliminationManager : elimination_manager_device = elimination_manager_device {}

    OnBegin<override>()<suspends>:void=
        EliminationManager.EliminatedEvent.Subscribe(Eliminated) ###gets the eliminated Agent

    Eliminated(Agent:agent):void=
        if(Fort := Agent.GetFortCharacter[]): ### getting fort_character from the Agent
            FortTransform := Fort.GetTransform() ### getting transform
            Position4 := FortTransform.Translation ### getting Position
            Rotation := FortTransform.Rotation ### Rotation
            SpawnedPropResult := SpawnProp(DeathNiagraFX, Position4, Rotation) ### spawning a creative_prop_asset
                Print("spawned NiagraFX") ###Print-Log
                if (SpawnedProp := SpawnedPropResult(0)?): ###making it into a useable creative_prop
                    Print("spawnedProp") ###Print-Log
                    spawn:
                        DeathNiagraFXHandle(SpawnedProp) ###spawning async function passing in the creative_prop     

    DeathNiagraFXHandle(NiagraFXProp : creative_prop)<suspends>:void=   
        Sleep(5.0) ### Put in how long you want the niagra particle system to last before being destroyed
        NiagraFXProp.Dispose() ###destroys the niagra system
        Print("despawned niagrafx")   ### Print-Log