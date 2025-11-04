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
using { /Fortnite.com/AI }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Animation/PlayAnimation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Colors }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors/NamedColors }
using { /Fortnite.com/UI }

#THIS SCRIPT IS USED TO CREATE INTERACTABLE NPCS WITH VARIOUS FUNCTIONALITY

#Button class that can be reused for different NPCs
TrackedButton := class<concrete>():
    @editable ButtonDevice : button_device = button_device{}
    var IsAvailable : logic = true
    var DelayedPlayers : []agent = array{}
    var AttachedProp : creative_prop = creative_prop{}

    HandleDelay(Delay : float , Agent : agent)<suspends> : void=
        set DelayedPlayers += array{Agent}
        Sleep(Delay)
        if(NewDelayedPlayers := DelayedPlayers.RemoveFirstElement[Agent]){set DelayedPlayers = NewDelayedPlayers}

#Collection of NPC spawners with set functionality
NPCSpawnerCollection :=class<concrete>():
    var GameManager : Game_Manager = Game_Manager{}
    var ResourceManager : Resource_Manager = Resource_Manager{}
    var NPCManager : NPC_Manager = NPC_Manager{}
    var TrackedButtons : []TrackedButton = array{}
    TT_NPC_SC_NPCSpawners<localizes>:message = "List of npc spawner devices that are used to spawn the NPCs"
    @editable{ToolTip := TT_NPC_SC_NPCSpawners} NPCSpawners : []npc_spawner_device = array{}

    TT_NPC_SC_EliminatedTrigger<localizes>:message = "A Trigger device that is activated when the NPC is eliminated"
    @editable{ToolTip := TT_NPC_SC_EliminatedTrigger} EliminatedTrigger : trigger_device = trigger_device{}

    TT_NPC_SC_InteractionSettings<localizes>:message = "The settings for the interaction functionality of the NPC"
    @editable{ToolTip := TT_NPC_SC_InteractionSettings} InteractionSettings : InteractionSetting = InteractionSetting{}

    TT_NPC_SC_AttachProp<localizes>:message = "The prop that is attached to the NPC (Optional - empty by default)"
    @editable{ToolTip := TT_NPC_SC_AttachProp} AttachProp : ?creative_prop_asset = false

    #Initializes all spawners in collection
    Initialize() : void=
        for(Spawner : NPCSpawners):
            Spawner.SpawnedEvent.Subscribe(HandleSpawned)
            Spawner.EliminatedEvent.Subscribe(HandleEliminated)
            
    #Resests NPC button when eliminated and triggers elimination trigger
    HandleEliminated(Result : device_ai_interaction_result) : void=
        if:
            TargetAgent := Result.Target?
            InstigatorAgent := Result.Source?
        then:
            if(NPCButton := NPCManager.NPCButtonMap[TargetAgent]):
                set NPCButton.IsAvailable = true
                NPCButton.AttachedProp.Dispose()
                if(NPCButton.ButtonDevice.TeleportTo[vector3{X:=0.0 , Y:=0.0 , Z:=-10000.0}, IdentityRotation()]){}
                if(NewMap := NPCManager.NPCButtonMap.WithRemovedKey(TargetAgent)?):
                    set NPCManager.NPCButtonMap = NewMap

            EliminatedTrigger.Trigger(InstigatorAgent)

    #Assigns a button to NPC and calls button track function
    HandleSpawned(Agent : agent) : void = 
        var IsFound : logic = false
        for(B : TrackedButtons, not IsFound?):
            if(B.IsAvailable?):
                set IsFound = true
                set B.IsAvailable = false
                spawn{HandleButtonMove(B,Agent)}
                if(set NPCManager.NPCButtonMap[Agent] = B){}

    #Moves the button to the NPCs location and waits for its interaction
    HandleButtonMove(TB : TrackedButton , NPCAgent : agent)<suspends> : void=
        if(FC := NPCAgent.GetFortCharacter[]):
            
            race:
                block:
                    FC.EliminatedEvent().Await()
                block:
                    loop:
                        Sleep(0.0)
                        Agent := TB.ButtonDevice.InteractedWithEvent.Await()
                        if(not TB.DelayedPlayers.Find[Agent]):
                            spawn{HandleButtonInteract(NPCAgent,TB,Agent)}
                        else:
                            if(Delay := InteractionSettings.DelayBetweenPresses?){Delay.OnDelayHUD.Show(Agent)}
                block:
                    if(PropAsset := AttachProp?, SpawnedProp := SpawnProp(PropAsset, FC.GetTransform().Translation,IdentityRotation())(0)?):
                        set TB.AttachedProp = SpawnedProp
                        loop:
                            Sleep(0.0)
                            NPCPos := FC.GetTransform().Translation
                            SpawnedProp.MoveTo(NPCPos,IdentityRotation(),0.1)
                loop:
                    Sleep(0.0)
                    NPCPos := FC.GetTransform().Translation
                    TB.ButtonDevice.MoveTo(NPCPos,IdentityRotation(),0.1)

    #Handles all actions after button has been interacted with
    HandleButtonInteract(NPCAgent : agent, TB : TrackedButton, Agent : agent)<suspends> : void=
        if(FC := NPCAgent.GetFortCharacter[]):
            InteractionSettings.ActivateTrigger.Trigger(Agent)
            InteractionSettings.InteractAudio.Play(NPCAgent)
            spawn{HandleDurationPause(NPCAgent, TB, Agent)}
            spawn{HandleTriggerPause(NPCAgent, TB, Agent)}
            spawn{HandleDistanceTrack(NPCAgent, TB, Agent)}
            if(Delay := InteractionSettings.DelayBetweenPresses?){spawn{TB.HandleDelay(Delay.Delay,Agent)}}

    #Handles the 'PauseDuration' setting that temporarily freezes the NPC
    HandleDurationPause(NPCAgent : agent, TB : TrackedButton, Agent : agent)<suspends> : void=
        if(Duration := InteractionSettings.PauseSettings.PauseDuration?):
            if(FC := NPCAgent.GetFortCharacter[]):
                if(InteractionSettings.PauseSettings.DisableButtonDuringPause?){TB.ButtonDevice.Disable()}
                FC.PutInStasis(stasis_args{})
                Sleep(Duration)
                FC.ReleaseFromStasis()
                if(InteractionSettings.PauseSettings.DisableButtonDuringPause?){TB.ButtonDevice.Enable()}

    #Handles the 'PauseTrigger' setting that freezes the NPC until a trigger is activated
    HandleTriggerPause(NPCAgent : agent, TB : TrackedButton, Agent : agent)<suspends> : void=
        if(UnPauseTrigger := InteractionSettings.PauseSettings.UnpauseTrigger?):
            if(FC := NPCAgent.GetFortCharacter[]):
                FC.PutInStasis(stasis_args{})
                if(InteractionSettings.PauseSettings.DisableButtonDuringPause?){TB.ButtonDevice.Disable()}
                race:
                    block:
                        FC.EliminatedEvent().Await()
                    loop:
                        UnpauseAgent := UnPauseTrigger.TriggeredEvent.Await()
                        if(NewUnpauseAgent := UnpauseAgent?, NewUnpauseAgent = Agent):
                            FC.ReleaseFromStasis()
                            if(InteractionSettings.PauseSettings.DisableButtonDuringPause?){TB.ButtonDevice.Enable()}
                            break

    #Handles the 'DistanceTrack' setting that awards players if they remain within a specific distance of the NPC and shows a progress bar
    HandleDistanceTrack(NPCAgent : agent, TB : TrackedButton, Agent : agent)<suspends> : void=
        if(NewDistanceSettings := InteractionSettings.RemainDistanceSettings?):
            if(Player := player[Agent], PlayerUI := GetPlayerUI[Player] , NPCFC := NPCAgent.GetFortCharacter[] , PlayerFC := Agent.GetFortCharacter[]):
                var BackgroundBarWid : color_block = color_block{DefaultColor := NewDistanceSettings.BackgroundBarColor}
                var ProgressBarWid : color_block = color_block{DefaultColor := NewDistanceSettings.ProgressBarColor}
                var ProgressBarStackBox : stack_box = stack_box{Orientation := orientation.Horizontal}
                var ProgressBarScalar : color_block = color_block{DefaultColor := White, DefaultOpacity := 0.0}
                var XValue : float = 0.0
                ProgressBarScalar.SetDesiredSize(vector2{X:=NewDistanceSettings.ProgressBarPosition.Right, Y:= NewDistanceSettings.ProgressBarPosition.Bottom})
                ProgressBarStackBox.AddWidget(stack_box_slot:
                        Widget := ProgressBarWid
                        HorizontalAlignment := horizontal_alignment.Fill
                        VerticalAlignment := vertical_alignment.Fill
                        Distribution := option{1.0}
                )
                ProgressBarStackBox.AddWidget(stack_box_slot:
                    Widget := ProgressBarScalar
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                )
                var NewCanvas : canvas = canvas{}
                NewCanvas.AddWidget(NewDistanceSettings.ProgressBarPosition.MakeCanvasSlot(ProgressBarStackBox, option{CanvasPosition{MaybeZOrder := option{1}}}))
                NewCanvas.AddWidget(NewDistanceSettings.ProgressBarPosition.MakeCanvasSlot(BackgroundBarWid, option{CanvasPosition{MaybeZOrder := option{0}}}))
                
                var ShowPercentageText : text_block = text_block{}
                var ShowDistanceText : text_block = text_block{}
                var AllTexts : []text_block = array{}
                for(TW : NewDistanceSettings.AddTexts):
                    NewText := TW.GetText()
                    NewCanvas.AddWidget(TW.Position.MakeCanvasSlot(NewText,false))
                    set AllTexts += array{NewText}
                    if(TW.ShowPercentage?){set ShowPercentageText = NewText}
                    else if(TW.ShowDistance?){set ShowDistanceText = NewText}
                    


                PlayerUI.AddWidget(NewCanvas)
                TB.ButtonDevice.Disable()

                loop:
                    Sleep(0.0)
                    PlayerPos := PlayerFC.GetTransform().Translation
                    NPCPos := NPCFC.GetTransform().Translation
                    for(T : AllTexts){T.SetVisibility(widget_visibility.Visible)}
                    if(CurrentDistance := Distance(PlayerPos,NPCPos) < NewDistanceSettings.RemainDistance):
                        set XValue += (NewDistanceSettings.ProgressBarPosition.Right / (31.0 * NewDistanceSettings.RemainTime))
                        if(Percentage := Int[((XValue/NewDistanceSettings.ProgressBarPosition.Right) * 100.0)]){ShowPercentageText.SetText(MasterS2M("{Percentage}%"))}
                        if(NewDistance := Int[CurrentDistance]){ShowDistanceText.SetText(MasterS2M("{NewDistance}m"))}
                        ProgressBarScalar.SetDesiredSize(vector2{X:=NewDistanceSettings.ProgressBarPosition.Right - XValue, Y:= NewDistanceSettings.ProgressBarPosition.Bottom})
                        if(XValue >= NewDistanceSettings.ProgressBarPosition.Right):
                            NewCanvas.SetVisibility(widget_visibility.Hidden)
                            PlayerUI.RemoveWidget(NewCanvas)
                            NewDistanceSettings.CompletionTrigger.Trigger(Agent)
                            if(RP := ResourceManager.PlayersMap[Agent]):
                                RP.Collect(NewDistanceSettings.CompletionResources)
                            TB.ButtonDevice.Enable()
                            break
                    else:
                        if(GS := NewDistanceSettings.GracePeriodSettings?):
                            var GraceShowPercentageText : text_block = text_block{}
                            var GraceShowDistanceText : text_block = text_block{}
                            var GraceRemainingTimeText : text_block = text_block{}
                            var GraceAllTexts : []text_block = array{}
                            var NewDuration : float = GS.Duration
                            race:
                                block:
                                    if(not GS.ShowReverseProgressBar?):
                                        BackgroundBarWid.SetVisibility(widget_visibility.Hidden)
                                        ProgressBarStackBox.SetVisibility(widget_visibility.Hidden)
                                    for(T : AllTexts){T.SetVisibility(widget_visibility.Hidden)}
                                    for(TW : GS.AddTexts):
                                        NewText := TW.GetText()
                                        NewCanvas.AddWidget(TW.Position.MakeCanvasSlot(NewText,false))
                                        set GraceAllTexts += array{NewText}
                                        if(TW.ShowPercentage?){set GraceShowPercentageText = NewText}
                                        else if(TW.ShowDistance?){set GraceShowDistanceText = NewText}
                                        else if(TW.ShowRemainingTime?){set GraceRemainingTimeText = NewText}
                                    Sleep(GS.Duration)
                                    NewCanvas.SetVisibility(widget_visibility.Hidden)
                                    PlayerUI.RemoveWidget(NewCanvas)
                                    TB.ButtonDevice.Enable()
                                    return

                                loop:
                                    Sleep(0.0)
                                    NewPlayerPos := PlayerFC.GetTransform().Translation
                                    NewNPCPos := NPCFC.GetTransform().Translation
                                    CurrentDistance := Distance(NewPlayerPos,NewNPCPos)
                                    if(CurrentDistance  < NewDistanceSettings.RemainDistance):
                                        for(T : GraceAllTexts): 
                                            T.SetVisibility(widget_visibility.Hidden)
                                            NewCanvas.RemoveWidget(T)
                                        break
                                    else:
                                        if(GS.ShowReverseProgressBar?):
                                            BackgroundBarWid.SetVisibility(widget_visibility.Visible)
                                            ProgressBarStackBox.SetVisibility(widget_visibility.Visible)
                                            set XValue -= (NewDistanceSettings.ProgressBarPosition.Right / (31.0 * NewDistanceSettings.RemainTime))
                                            if(Percentage := Int[((XValue/NewDistanceSettings.ProgressBarPosition.Right) * 100.0)]){GraceShowPercentageText.SetText(MasterS2M("{Percentage}%"))}
                                            if(NewDistance := Int[CurrentDistance]){GraceShowDistanceText.SetText(MasterS2M("{NewDistance}m"))}
                                            set NewDuration -= 0.03225
                                            GraceRemainingTimeText.SetText(RoundedAmount("",NewDuration,2,"s"))
                                            ProgressBarScalar.SetDesiredSize(vector2{X:=NewDistanceSettings.ProgressBarPosition.Right - XValue, Y:= NewDistanceSettings.ProgressBarPosition.Bottom})
                                            if(XValue <= 0.0):
                                                NewCanvas.SetVisibility(widget_visibility.Hidden)
                                                PlayerUI.RemoveWidget(NewCanvas)
                                                TB.ButtonDevice.Enable()
                                                break
                        else:
                            NewCanvas.SetVisibility(widget_visibility.Hidden)
                            PlayerUI.RemoveWidget(NewCanvas)
                            NewDistanceSettings.FailureTrigger.Trigger(Agent)
                            TB.ButtonDevice.Enable()
                            break
            
#Class for settings that control the Distance Tracking option
RemainDistanceSetting := class<concrete>():
    TT_NPC_Interaction_RemainDistance<localizes>:message = "The range the player must remain within to gain resources after interacting with the NPC"
    @editable{ToolTip := TT_NPC_Interaction_RemainDistance} RemainDistance : float = 0.0

    TT_NPC_Interaction_RemainTime<localizes>:message = "The time the player must remain within the range to gain resources after interacting with the NPC"
    @editable{ToolTip := TT_NPC_Interaction_RemainTime} RemainTime : float = 0.0

    TT_NPC_Interaction_ProgressBarPosition<localizes>:message = "The settings for player\'s interaction progress bar"
    @editable{ToolTip := TT_NPC_Interaction_ProgressBarPosition} ProgressBarPosition : CanvasPosition = CanvasPosition{}
    
    @editable BackgroundBarColor : color = color{}
    @editable ProgressBarColor : color = color{}

    TT_NPC_Interaction_CompletionTrigger<localizes>:message = "A trigger device that is activated if the player remains within the range for the required time"
    @editable{ToolTip := TT_NPC_Interaction_CompletionTrigger} CompletionTrigger : trigger_device = trigger_device{}

    TT_NPC_Interaction_FailureTrigger<localizes>:message = "A trigger device that is activated if the player does not remain within the range for the required time"
    @editable{ToolTip := TT_NPC_Interaction_FailureTrigger} FailureTrigger : trigger_device = trigger_device{}

    TT_NPC_Interaction_CompletionResources<localizes>:message = "The resources that are awarded to the player if they remain within the range for the required time"
    @editable{ToolTip := TT_NPC_Interaction_CompletionResources} CompletionResources : []GainableResource = array{}

    TT_NPC_Interaction_NPCPopUpSettings<localizes>:message = "The settings for the pop up animation that is displayed when resources are gained through interacting with the NPC"
    @editable{ToolTip := TT_NPC_Interaction_NPCPopUpSettings} NPCPopUpSettings : PopUpAnimationSetting = PopUpAnimationSetting{}

    TT_NPC_Interaction_AddTexts<localizes>:message = "Texts that shown on screen while interacting with the NPC"
    @editable{ToolTip := TT_NPC_Interaction_AddTexts} AddTexts : []CustomTextWidget = array{}

    TT_NPC_Interaction_GracePeriodSettings<localizes>:message = "The settings for the grace period that allows the player to have a chance to get close to the NPC again after failing to remain within the range for the required time"
    @editable{ToolTip := TT_NPC_Interaction_GracePeriodSettings} GracePeriodSettings : ?GracePeriodSetting = false

#Class for settings that control the Distance Tracking option
GracePeriodSetting := class<concrete>():
     TT_NPC_Interaction_GracePeriodDuration<localizes>:message = "The duration of the grace period"
    @editable{ToolTip := TT_NPC_Interaction_GracePeriodDuration} Duration : float = 0.0

    TT_NPC_Interaction_ShowReverseProgressBar<localizes>:message = "if enabled, the progress bar will decrease back to 0 instead of waiting for the specified duration to complete"
    @editable{ToolTip := TT_NPC_Interaction_ShowReverseProgressBar} ShowReverseProgressBar : logic = false

    @editable AddTexts : []CustomGraceTextWidget = array{}
   
#Class used to add different text widgets on the UI with different functionalities for grace period
CustomGraceTextWidget := class<concrete>(CustomTextWidget):
    @editable ShowRemainingTime : logic = false

#Class used to add different text widgets on the UI with different functionalities
CustomTextWidget := class<concrete>():
    @editable Position : CanvasPosition = CanvasPosition{}
    @editable TextSettings : TextSetting = TextSetting{}
    @editable TextMessage : string = ""
    @editable ShowPercentage : logic = false
    @editable ShowDistance : logic = false
    GetText() : text_block=
        var NextTextBlock : text_block = text_block{DefaultTextColor := TextSettings.TextColor, DefaultShadowColor := TextSettings.TextShadowColor , DefaultShadowOffset := option{TextSettings.TextShadowOffset}}
        NextTextBlock.SetShadowOpacity(1.0)
        NextTextBlock.SetText(MasterS2M(TextMessage))
        return NextTextBlock
            
#Different settings used to control interaction functionalities
InteractionSetting := class<concrete>():
    TT_NPC_Interaction_ActivateTrigger<localizes>:message = "A trigger device that is activated when the NPC is interacted with"
    @editable{ToolTip := TT_NPC_Interaction_ActivateTrigger} ActivateTrigger : trigger_device = trigger_device{}

    TT_NPC_Interaction_InteractAudio<localizes>:message = "The audio that is played when the NPC is interacted with\n*Required Settings*\n Can be heard by : Instigator Only\n Play Location : Instigating Player"
    @editable{ToolTip := TT_NPC_Interaction_InteractAudio} InteractAudio : audio_player_device = audio_player_device{}

    TT_NPC_Interaction_PauseSettings<localizes>:message = "The settings for the pause/stop moving functionality of the NPC"
    @editable{ToolTip := TT_NPC_Interaction_PauseSettings} PauseSettings : PauseSetting = PauseSetting{}

    TT_NPC_Interaction_DelayBetweenPresses<localizes>:message = "A delay which does not allow the same player to interact with the NPC again until the delay is over"
    @editable{ToolTip := TT_NPC_Interaction_DelayBetweenPresses} DelayBetweenPresses : ?NPCDelaySetting = false

    TT_NPC_Interaction_RemainDistanceSettings<localizes>:message = "The settings for the distance tracking functionality of the NPC"
    @editable{ToolTip := TT_NPC_Interaction_RemainDistanceSettings} RemainDistanceSettings : ?RemainDistanceSetting = false

#Settings for the different delay options
NPCDelaySetting := class<concrete>():
    TT_NPC_Interaction_Delay<localizes>:message = "The delay between each interaction with the NPC"
    @editable{ToolTip := TT_NPC_Interaction_Delay} Delay : float = 0.0

    TT_NPC_Interaction_OnDelayHUD<localizes>:message = "A hud message device that is shown when the delay is active and the player cannot interact with the NPC\n*Required Settings*\nMessage Recipient : Triggering Player"
    @editable{ToolTip := TT_NPC_Interaction_OnDelayHUD} OnDelayHUD : hud_message_device = hud_message_device{}

#Settings for the different pause options
PauseSetting := class<concrete>():
    TT_NPC_Interaction_DisableButtonDuringPause<localizes>:message = "Whether the button is disabled when the NPC is paused so other players cannot interact with it"
    @editable{ToolTip := TT_NPC_Interaction_DisableButtonDuringPause} DisableButtonDuringPause : logic = false

    TT_NPC_Interaction_PauseDuration<localizes>:message = "The duration of the pause/stop moving functionality of the NPC"
    @editable{ToolTip := TT_NPC_Interaction_PauseDuration} PauseDuration : ?float = false

    TT_NPC_Interaction_UnpauseTrigger<localizes>:message = "A trigger device that unpauses the NPC when activated"
    @editable{ToolTip := TT_NPC_Interaction_UnpauseTrigger} UnpauseTrigger : ?trigger_device = false

#Main creative device class
NPC_Manager := class(creative_device):
    TT_NPC_Device_GameManager<localizes>:message = "Your Game manager device"
    @editable{ToolTip := TT_NPC_Device_GameManager} GameManager : Game_Manager = Game_Manager{}

    TT_NPC_Device_ResourceManager<localizes>:message = "Your Resource manager device"
    @editable{ToolTip := TT_NPC_Device_ResourceManager} ResourceManager : Resource_Manager = Resource_Manager{}

    TT_NPC_Device_NPCCollections<localizes>:message = "List of NPC collections that are used to spawn the NPCs"
    @editable{ToolTip := TT_NPC_Device_NPCCollections} NPCCollections : []NPCSpawnerCollection = array{}

    TT_NPC_Device_TrackedButtons<localizes>:message = "List of tracked buttons that are used to track the NPCs"
    @editable{ToolTip := TT_NPC_Device_TrackedButtons} TrackedButtons : []TrackedButton = array{}
    var NPCButtonMap : [agent]TrackedButton = map{}

    #Initializes all NPC collections
    OnBegin<override>()<suspends>:void=
        for(Collection : NPCCollections):
            set Collection.TrackedButtons = TrackedButtons
            set Collection.NPCManager = Self
            set Collection.GameManager = GameManager
            set Collection.ResourceManager = ResourceManager
            Collection.Initialize()

#Different movement types to control NPC movement
MovementTypes := enum:
    Walking
    Running
    IntervalRandom

#NPC Behavior applied to NPCs to have them randomly move between different set locations
InteractableNPCBehavior := class(npc_behavior):
    TT_NPC_Behavior_MoveLocations<localizes>:message = "List of props that are used to control the NPC\'s movement path"
    @editable{ToolTip := TT_NPC_Behavior_MoveLocations} MoveLocations : []creative_prop = array{}

    TT_NPC_Behavior_MovementType<localizes>:message = "The movement type of the NPC\nWalking : Moves between the set locations at a walking pace\nRunning : Moves between the set locations at a running pace\nIntervalRandom : Randomly moves between walking and running"
    @editable{ToolTip := TT_NPC_Behavior_MovementType} NPCMovementType : MovementTypes = MovementTypes.Walking
    EliminatedEvent : event() = event(){}
    
    #Gets NPC values and finds the set location that most closely corresponds with its spawn location
    OnBegin<override>()<suspends>:void=
        if:
            NPCAgent := GetAgent[]
            NPCChar := NPCAgent.GetFortCharacter[]
            NPCNav := NPCChar.GetNavigatable[]
            NPCFocus := NPCChar.GetFocusInterface[]
            NPCAnim := NPCChar.GetPlayAnimationController[]
        then:
            NPCSpawnLocation := NPCChar.GetTransform().Translation
            var ClosestPropLocationIDX : int = 0
            var ClosestDistance : float = 99999.0
            for(idx -> Prop : MoveLocations):
                PropPos := Prop.GetTransform().Translation
                if(NewDistance := Distance(PropPos,NPCSpawnLocation) < ClosestDistance):
                    set ClosestDistance = NewDistance
                    set ClosestPropLocationIDX = idx
            spawn{RandomLocationMove(ClosestPropLocationIDX)}

    #Randomy moves the NPC between the set positions
    RandomLocationMove(InitialLocationIDX : int)<suspends> : void=
        var CurrentLocationIDX : int = InitialLocationIDX
        if:
            NPCAgent := GetAgent[]
            NPCChar := NPCAgent.GetFortCharacter[]
            NPCNav := NPCChar.GetNavigatable[]
            NPCFocus := NPCChar.GetFocusInterface[]
            NPCAnim := NPCChar.GetPlayAnimationController[]
        then:
            race:
                block:
                    EliminatedEvent.Await()
                loop:
                    Sleep(0.0)
                    if(CurrentLocationIDX <= 0):
                        set CurrentLocationIDX += 1
                    else if(CurrentLocationIDX >= MoveLocations.Length - 1):
                        set CurrentLocationIDX -= 1
                    else:
                        Direction := GetRandomInt(0,1)
                        if(Direction = 1):
                            set CurrentLocationIDX += 1

                        else if(Direction = 0):
                            set CurrentLocationIDX -= 1

                    if(NewMoveLocation := MoveLocations[CurrentLocationIDX]):
                        NewMovePos := NewMoveLocation.GetTransform().Translation
                        NewMoveNav := MakeNavigationTarget(NewMovePos)
                        spawn{NPCFocus.MaintainFocus(NewMovePos)}

                        if(NPCMovementType = MovementTypes.Walking):
                            NPCNav.NavigateTo(NewMoveNav, ?MovementType := movement_types.Walking)

                        else if(NPCMovementType = MovementTypes.Running):
                            NPCNav.NavigateTo(NewMoveNav, ?MovementType := movement_types.Running)

                        else if(NPCMovementType = MovementTypes.IntervalRandom):
                            NewMoveType := GetRandomInt(0,1)
                            if(NewMoveType = 1):
                                NPCNav.NavigateTo(NewMoveNav, ?MovementType := movement_types.Walking)
                            else if(NewMoveType = 0):
                                NPCNav.NavigateTo(NewMoveNav, ?MovementType := movement_types.Running)
                                
    OnEnd<override>():void=
        EliminatedEvent.Signal()