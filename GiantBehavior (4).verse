using { /Fortnite.com/AI }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Animation/PlayAnimation }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }

GiantBehavior<public> := class(npc_behavior):
    BehaviorHelp : BehaviorHelper = BehaviorHelper{}
    var Attack1 : animation_sequence = NPCStuff.Giant_Anim_EnemyArmature_EnemyArmature_EnemyArmature_Attack

    # This function runs when the NPC is spawned in the world and ready to follow a behavior.
    OnBegin<override>()<suspends>:void=
        if:
            NPCAgent := GetAgent[]
            NPCChar := NPCAgent.GetFortCharacter[]

            NPCNav := NPCChar.GetNavigatable[]
            NPCFocus := NPCChar.GetFocusInterface[]
            NPCAnim := NPCChar.GetPlayAnimationController[]
        then:
            NPCSpawnPoint := NPCChar.GetTransform().Translation

            loop:
                Sleep(0.1)
                if(not NPCChar.IsActive[]):
                    break
                if(NewTarget := BehaviorHelp.FindNearestTarget[NPCChar],NewAgent := NewTarget.GetAgent[]):
                    spawn{NPCFocus.MaintainFocus(NewAgent)}
                    NavTarget := MakeNavigationTarget(NewAgent)
                    NPCNav.NavigateTo(NavTarget , ?MovementType := movement_types.Running, ?ReachRadius := 150.0)
                    NPCAnim.Play(Attack1)
                    Sleep(0.46)
                    if(Distance(NPCChar.GetTransform().Translation, NewTarget.GetTransform().Translation) < 200.0):
                        NewTarget.Damage(15.0)





    # This function runs when the NPC is despawned or eliminated from the world.
    OnEnd<override>():void=
        # TODO: Replace this with your code
        Print("Goodbye, NPC!")