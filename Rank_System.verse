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
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Assets }
using { /Verse.org/Colors }

#THIS DEVICE IS A FULL RANK SYSTEM FOR PLAYERS

#Enum to allow different bar styles
StyleType := enum:
    Base
    ColorChange
    Custom

#Enum to allow different bar speeds
BarSpeedType := enum:
    Slow
    Fast

#Enum to allow different prestige options
PrestigeType := enum:
    Off
    Auto
    Manual

    
#Enum to allow different apparel styles
ApparelType := enum:
    None
    Back
    Hover


#Enum to allow different display types
DisplayType := enum:
    Points
    Percentage
    ELO

#Class to hold positions on a canvas
CanvasPosition:= class<concrete>():
    @editable AnchorX : type{_X : float where _X >= 0.0, _X <= 1.0} = 0.0
    @editable AnchorY : type{_X : float where _X >= 0.0, _X <= 1.0} = 0.0
    @editable Left : float = 0.0
    @editable Top : float = 0.0
    @editable Right : float = 0.0
    @editable Bottom : float = 0.0


#Class to hold different UI Positions
UIPosition:= class<concrete>():
    @editable RankDisplayTextPosition : CanvasPosition = CanvasPosition{}
    @editable RankPointsTextPosition : CanvasPosition = CanvasPosition{}
    @editable CurrentRankImagePosition : CanvasPosition = CanvasPosition{}
    @editable NextRankImagePosition : CanvasPosition = CanvasPosition{}


#Class to change settings for pop up
BarSetting:= class<concrete>():
    @editable BarSpeed : BarSpeedType = BarSpeedType.Slow
    @editable BarStyle : StyleType = StyleType.Base
    @editable Position : CanvasPosition = CanvasPosition{}
    @editable UseGradient : logic = false


#Class to change settings for pop up
RankChangeSetting:= class<concrete>():
    @editable EnableImageSizeAnimation : logic = false
    @editable EnableChangePopUp : logic = false

#Class to change settings for text colors
TextColorSetting:= class<concrete>():
    @editable RankTextShadowOffset : vector2 = vector2{}

    @editable RankTextColor : color = color{}

    @editable RankTextShadowColor : color = color{}


#Class to change settings for bar colors
BarColorSetting:= class<concrete>():
    @editable ProgressBarColor : color = color{}

    @editable BackgroundBarColor : color = color{}

    @editable ShadowBarColor : color = color{}

    @editable GradientBarColor : color = color{}

#Class for each rank to hold both vfxs
ApparelVFX:= class<concrete>():
    @editable HoverVFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable BackVFX : visual_effect_powerup_device = visual_effect_powerup_device{}


#Class to change settings for pop up
PopUpSetting:= class<concrete>():
    @editable DecreaseColor : color = color{}
    @editable IncreaseColor : color = color{}

    @editable Position : CanvasPosition = CanvasPosition{}

    @editable DisplayDescription : logic = false

    @editable Duration : float = 0.0

    @editable Speed : float = 0.0


#Class for HUD messages that display on rank change
RankChangeMessages:= class<concrete>():

    @editable RankUpHUD : hud_message_device = hud_message_device{}
    @editable RankUpCin : cinematic_sequence_device = cinematic_sequence_device{}

    @editable RankDownHUD : hud_message_device = hud_message_device{}
    @editable RankDownCin : cinematic_sequence_device = cinematic_sequence_device{}

    RankUpPlay(Player : player) : void=
        RankUpHUD.Show(Player)
        RankUpCin.Play(Player)

    RankDownPlay(Player : player) : void=
        RankDownHUD.Show(Player)
        RankDownCin.Play(Player)


#Editable class to hold differnt rank settings
Ranks:= class<concrete>():

    @editable TargetAmount : float = 0.0

    @editable RankDisplayTextColors : TextColorSetting = TextColorSetting{}

    @editable RankPointsTextColors : TextColorSetting = TextColorSetting{}

    @editable BarColors : BarColorSetting = BarColorSetting{}

    @editable RankText : string = ""

    @editable RankChangeHUD : RankChangeMessages = RankChangeMessages{}

    @editable DisplaySetting : DisplayType = DisplayType.Points

    @editable XPOnRankup : accolades_device = accolades_device{}

    @editable TriggerOnRankup : trigger_device = trigger_device{}

    @editable RankVFXs : ApparelVFX = ApparelVFX{}

    @editable NeverLoseRank : logic = false

    @editable ShowNextRank : logic = false

    var RankImage : texture = RankMaterials.blank

    var RankTextImage : texture = RankMaterials.blank
    


#Class for each player to rank hold values and change UI
Ranked_Player := class<unique>():

    #Base Stuff
    Player : player
    RankedPersistence : Rank_Persistence = Rank_Persistence{}

    #Main Stat Variables
    var RankValue : float = 1.0
    var Rank : int = 0
    var Eliminations : float = 0.0
    var Deaths : float = 0.0
    var Wins : float = 0.0
    var Loses : float = 0.0
    var Prestiges : float = 0.0

    var WinStreak : int = 0
    var KillStreak: int = 0


    #UI variables
    var MainUI : canvas = canvas{}

    var BaseProgressBar : color_block = color_block{DefaultColor := White}
    var BaseShadowBar : color_block = color_block{DefaultColor := Gray}
    var BaseBackgroundBar : color_block = color_block{DefaultColor := Black , DefaultOpacity := 0.5}
    var BaseGradientBar : texture_block = texture_block{DefaultImage := RankMaterials.T_Gradient}

    var CustomProgressBar : texture_block = texture_block{DefaultImage := RankMaterials.CustomBarProgress}
    var CustomShadowBar : texture_block = texture_block{DefaultImage := RankMaterials.CustomBarShadow}
    var CustomBackgroundBar : texture_block = texture_block{DefaultImage := RankMaterials.CustomBarBack}

    var RankImage : texture_block = texture_block{DefaultImage := RankMaterials.blank}
    var NextRankImage : texture_block = texture_block{DefaultImage := RankMaterials.blank}
    var RankDisplayText : text_block = text_block{}
    var RankPointsText : text_block = text_block{}


    #Changeable settings
    var AllRanks : []Ranks = array{}
    var PopUpSettings : PopUpSetting = PopUpSetting{}
    var ApparelSetting : ApparelType = ApparelType.None
    var PrestigeSetting : PrestigeType = PrestigeType.Off
    var BarSettings : BarSetting = BarSetting{}
    var RankChangeSettings : RankChangeSetting = RankChangeSetting{}
    var UIPositions : UIPosition = UIPosition{}
    var RankChangeAudioPlayer : audio_player_device = audio_player_device{}

    #Stuff used to add/remove points
    RankChangeEvent : event(tuple(float , string)) = event(tuple(float, string)){}
    var ChangeShadowAmount : float = 0.0
    UpdateEvent : event() = event(){}
    var ChangeAmount : float = 0.0
    var ShadowValue : float = 0.0
    var ShadowWaitTime : float = 0.0

    var RankUpImage : texture = RankMaterials.RankUp
    var RankDownImage : texture = RankMaterials.RankDown

    #Logic checks
    var CanPrestige : logic = false
    var IsTextChanging : logic = false
    var IsChangePopUp : logic = false

    #Function to conver string to message
    ToMessage<localizes>(String : string) : message = "{String}"


    #Function that returns the pevious rank target if it exists, and if not, returns 0
    GetPreRankTarget()<transacts> : float= 
        var PreRankTarget : float = 0.0
        if(NewPreRankTarget := AllRanks[Rank - 1].TargetAmount):
            set PreRankTarget = NewPreRankTarget
        return PreRankTarget


    #Function that returns the progress amount of the bar for the current rank
    GetPercentageAmount(Receive : float , IsAddOn : logic)<transacts> : float=
        var Percentage : float = 0.0
        if:
            CurRankTarget := AllRanks[Rank].TargetAmount
            PreRankTarget := GetPreRankTarget()
        then:
            if(IsAddOn?):
                PercentageComplete := (Receive) / (CurRankTarget - PreRankTarget)
                set Percentage = (BarSettings.Position.Right * PercentageComplete)
            else:
                PercentageComplete := (Receive - PreRankTarget) / (CurRankTarget - PreRankTarget)
                set Percentage = (BarSettings.Position.Right * PercentageComplete)
        return Percentage


    #Function that intializes and adds the players UI
    InitiateUI()<suspends>: void=    
        if(PlayerObj := Player, PlayerUI := GetPlayerUI[PlayerObj]):
            CheckRank(true)
            UpdateRankStuff(true)
            set MainUI = CreateMyUI()
            PlayerUI.AddWidget(MainUI)
            spawn{RankChange()}
            UpdateEvent.Signal()

    
    #Function to check and update the players rank
    CheckRank(IsFirst : logic)<suspends>:void=
        var RankIDX : int = 0
        if(CurrentR := AllRanks[Rank] , CurrentTarget := CurrentR.TargetAmount, PreviousTarget := GetPreRankTarget()):
            if(NextRank := AllRanks[Rank + 1]):
                #Changes rank dependent on if it above/below target amounts
                if(RankValue < PreviousTarget, Rank <> 0):
                    set Rank -= 1
                    spawn{HandleRankChange(false , IsFirst)}
                    CurrentR.RankChangeHUD.RankDownPlay(Player)
                    UpdateRankStuff(true)
                    CheckRank(IsFirst)

                else if(RankValue >= CurrentTarget):
                    set Rank += 1
                    spawn{HandleRankChange(true , IsFirst)}
                    CurrentR.RankChangeHUD.RankUpPlay(Player)
                    CurrentR.XPOnRankup.Award(Player)
                    CurrentR.TriggerOnRankup.Trigger(Player)
                    UpdateRankStuff(true)
                    CheckRank(IsFirst)
            else:
                if(RankValue < PreviousTarget and not CurrentR.NeverLoseRank?):
                    set Rank -= 1
                    spawn{HandleRankChange(false , IsFirst)}
                    CurrentR.RankChangeHUD.RankDownPlay(Player)
                    UpdateRankStuff(true)

                else if(RankValue >= CurrentTarget):
                    if(PrestigeSetting = PrestigeType.Auto):
                        set CanPrestige = true
                        Prestige()
                    else if(PrestigeSetting = PrestigeType.Manual):
                        set CanPrestige = true
                else if(RankValue < CurrentTarget):
                    set CanPrestige = false

                UpdateRankStuff(false)


    #Resets the players rank       
    Prestige() : void=
        if(CurrentR := AllRanks[Rank] , CanPrestige?):
            set Rank = 0
            set CanPrestige = false
            set Prestiges += 1.0
            RankedPersistence.RecordPlayerStat(Player, StatType.Prestiges, ?Score := 1.0)
            RankedPersistence.RecordPlayerStat(Player, StatType.RankValue, ?Score := -RankValue)
            set RankValue = 0.0
            set ShadowValue = 0.0
            spawn{HandleRankChange(false , false)}
            CurrentR.RankChangeHUD.RankUpPlay(Player)
            CurrentR.TriggerOnRankup.Trigger(Player)
            CurrentR.XPOnRankup.Award(Player)
            UpdateRankStuff(true)
            spawn{CheckRank(false)}
            UpdateEvent.Signal()

    
    #Updates rank text, color, and image
    UpdateRankStuff(NewRank : logic): void=
        var ScoreDisplay : string = ""
        if:
            CurRank := AllRanks[Rank]
            CurRankTarget := CurRank.TargetAmount
            PreRankTarget := GetPreRankTarget()
            PercentageComplete := (RankValue - PreRankTarget) / (CurRankTarget - PreRankTarget)
        then:

            #Sets the score text dependent on the DisplaySetting and If it is last rank
            if(CurRank.DisplaySetting = DisplayType.Percentage,Percentage := Int[PercentageComplete * 100.0]):
                set ScoreDisplay = "{Percentage}%"
            else if(CurRank.DisplaySetting = DisplayType.Points,NewRankValue := Int[RankValue], NewTargetValue := Int[CurRankTarget]):
                set ScoreDisplay = "{NewRankValue}/{NewTargetValue}"
            else if(CurRank.DisplaySetting = DisplayType.ELO,NewRankValue := Int[RankValue], NewTargetValue := Int[CurRankTarget]):
                set ScoreDisplay = "{NewRankValue} ELO"

            #Changes text depending on text settings
            RankDisplayText.SetShadowOpacity(1.0)
            RankPointsText.SetShadowOpacity(1.0)
            RankDisplayText.SetShadowOffset(option{CurRank.RankDisplayTextColors.RankTextShadowOffset})
            RankPointsText.SetShadowOffset(option{CurRank.RankPointsTextColors.RankTextShadowOffset})
            RankDisplayText.SetShadowColor(CurRank.RankDisplayTextColors.RankTextShadowColor)
            RankPointsText.SetShadowColor(CurRank.RankPointsTextColors.RankTextShadowColor)
            RankDisplayText.SetTextColor(CurRank.RankDisplayTextColors.RankTextColor)
            RankPointsText.SetTextColor(CurRank.RankPointsTextColors.RankTextColor)
            RankPointsText.SetText(ToMessage("{ScoreDisplay}"))
            if(NewRank = true):
                spawn{TextAnimation()}
            else if(IsTextChanging = false):
                RankDisplayText.SetText(ToMessage("{CurRank.RankText}"))
            


            #Changes bar colors if enabled
            if(BarSettings.BarStyle = StyleType.ColorChange):
                BaseProgressBar.SetColor(CurRank.BarColors.ProgressBarColor)
                BaseBackgroundBar.SetColor(CurRank.BarColors.BackgroundBarColor)
                BaseShadowBar.SetColor(CurRank.BarColors.ShadowBarColor)
                if(BarSettings.UseGradient?):
                    BaseGradientBar.SetTint(CurRank.BarColors.GradientBarColor)


            #Resets and applies new vfx for player
            if(ApparelSetting = ApparelType.Back):
                CurRank.RankVFXs.BackVFX.Pickup(Player)
            else if(ApparelSetting = ApparelType.Hover):
                CurRank.RankVFXs.HoverVFX.Pickup(Player)
            else:

            
    #Displays an animation that makes new text appear one char at a time
    TextAnimation()<suspends> : void=
        if(CurRank := AllRanks[Rank]):
            var TextIDX : int = 1
            set IsTextChanging = true
            loop:
                if(NewText := CurRank.RankText.Slice[0,TextIDX]):
                    RankDisplayText.SetText(ToMessage("{NewText}"))
                    set TextIDX += 1
                else:
                    set IsTextChanging = false
                    break
                Sleep(0.15)

    #Creates the Main Hud UI
    CreateMyUI() : canvas =   
        MyCanvas: canvas = canvas:
            Slots := array:
                #Rank Image
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := UIPositions.CurrentRankImagePosition.AnchorX, Y := UIPositions.CurrentRankImagePosition.AnchorY}, Maximum := vector2{X := UIPositions.CurrentRankImagePosition.AnchorX, Y := UIPositions.CurrentRankImagePosition.AnchorY}}
                    Offsets := margin{Left := UIPositions.CurrentRankImagePosition.Left, Top := UIPositions.CurrentRankImagePosition.Top, Right := UIPositions.CurrentRankImagePosition.Right, Bottom := UIPositions.CurrentRankImagePosition.Bottom}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := false
                    Widget := RankImage

                #Next Rank Image
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := UIPositions.NextRankImagePosition.AnchorX, Y := UIPositions.NextRankImagePosition.AnchorY}, Maximum := vector2{X := UIPositions.NextRankImagePosition.AnchorX, Y := UIPositions.NextRankImagePosition.AnchorY}}
                    Offsets := margin{Left := UIPositions.NextRankImagePosition.Left, Top := UIPositions.NextRankImagePosition.Top, Right := UIPositions.NextRankImagePosition.Right, Bottom := UIPositions.NextRankImagePosition.Bottom}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := false
                    Widget := NextRankImage


                #For Base Bar ==========================================================================================================================
                #Background Bar Image
                canvas_slot:   
                    Anchors := anchors{Minimum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}, Maximum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}}
                    Offsets := margin{Left := BarSettings.Position.Left, Top := BarSettings.Position.Top, Right := BarSettings.Position.Right, Bottom := BarSettings.Position.Bottom}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    SizeToContent := false
                    ZOrder := 0
                    Widget := BaseBackgroundBar

                #Shadow Bar Image
                canvas_slot:   
                    Anchors := anchors{Minimum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}, Maximum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}}
                    Offsets := margin{Left := BarSettings.Position.Left, Top := BarSettings.Position.Top, Right := 0.0, Bottom := BarSettings.Position.Bottom}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    SizeToContent := false
                    ZOrder := 1
                    Widget := BaseShadowBar

                #Progress Bar Image
                canvas_slot:   
                    Anchors := anchors{Minimum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}, Maximum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}}
                    Offsets := margin{Left := BarSettings.Position.Left, Top := BarSettings.Position.Top, Right := GetPercentageAmount(RankValue,false), Bottom := BarSettings.Position.Bottom}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    SizeToContent := false
                    ZOrder := 2
                    Widget := BaseProgressBar

                #Progress Gradient Bar Image
                canvas_slot:   
                    Anchors := anchors{Minimum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}, Maximum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}}
                    Offsets := margin{Left := BarSettings.Position.Left, Top := BarSettings.Position.Top, Right := GetPercentageAmount(RankValue,false), Bottom := BarSettings.Position.Bottom}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    SizeToContent := false
                    ZOrder := 3
                    Widget := BaseGradientBar
                #===========================================================================================================================================



                #For Custom Bar =============================================================================================================================
                #Background Bar Image
                canvas_slot:   
                    Anchors := anchors{Minimum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}, Maximum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}}
                    Offsets := margin{Left := BarSettings.Position.Left, Top := BarSettings.Position.Top, Right := BarSettings.Position.Right, Bottom := BarSettings.Position.Bottom}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    SizeToContent := false
                    ZOrder := 0
                    Widget := CustomBackgroundBar

                #Shadow Bar Image
                canvas_slot:   
                    Anchors := anchors{Minimum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}, Maximum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}}
                    Offsets := margin{Left := BarSettings.Position.Left, Top := BarSettings.Position.Top, Right := 0.0, Bottom := BarSettings.Position.Bottom}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    SizeToContent := false
                    ZOrder := 1
                    Widget := CustomShadowBar

                #Progress Bar Image
                canvas_slot:   
                    Anchors := anchors{Minimum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}, Maximum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}}
                    Offsets := margin{Left := BarSettings.Position.Left, Top := BarSettings.Position.Top, Right := GetPercentageAmount(RankValue,false), Bottom := Bottom := BarSettings.Position.Bottom}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    SizeToContent := false
                    ZOrder := 2
                    Widget := CustomProgressBar
                #===================================================================================================================================================

                #Rank Display Text
                canvas_slot:   
                    Anchors := anchors{Minimum := vector2{X := UIPositions.RankDisplayTextPosition.AnchorX, Y := UIPositions.RankDisplayTextPosition.AnchorY}, Maximum := vector2{X := UIPositions.RankDisplayTextPosition.AnchorX, Y := UIPositions.RankDisplayTextPosition.AnchorY}}
                    Offsets := margin{Left := UIPositions.RankDisplayTextPosition.Left, Top := UIPositions.RankDisplayTextPosition.Top, Right := UIPositions.RankDisplayTextPosition.Right, Bottom := UIPositions.RankDisplayTextPosition.Bottom}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    SizeToContent := false
                    Widget := RankDisplayText

                #Rank Points Text
                canvas_slot:   
                    Anchors := anchors{Minimum := vector2{X := UIPositions.RankPointsTextPosition.AnchorX, Y := UIPositions.RankPointsTextPosition.AnchorY}, Maximum := vector2{X := UIPositions.RankPointsTextPosition.AnchorX, Y := UIPositions.RankPointsTextPosition.AnchorY}}
                    Offsets := margin{Left := UIPositions.RankPointsTextPosition.Left, Top := UIPositions.RankPointsTextPosition.Top, Right := UIPositions.RankPointsTextPosition.Right, Bottom := UIPositions.RankPointsTextPosition.Bottom}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    SizeToContent := false
                    Widget := RankPointsText

        if(BarSettings.BarStyle = StyleType.Base or BarSettings.BarStyle = StyleType.ColorChange):
            CustomProgressBar.SetVisibility(widget_visibility.Hidden)
            CustomShadowBar.SetVisibility(widget_visibility.Hidden)
            CustomBackgroundBar.SetVisibility(widget_visibility.Hidden)
            MainUI.RemoveWidget(CustomProgressBar)
            MainUI.RemoveWidget(CustomShadowBar)
            MainUI.RemoveWidget(CustomBackgroundBar)
        else if(BarSettings.BarStyle = StyleType.Custom):
            BaseProgressBar.SetVisibility(widget_visibility.Hidden)
            BaseShadowBar.SetVisibility(widget_visibility.Hidden)
            BaseBackgroundBar.SetVisibility(widget_visibility.Hidden)
            MainUI.RemoveWidget(BaseProgressBar)
            MainUI.RemoveWidget(BaseShadowBar)
            MainUI.RemoveWidget(BaseBackgroundBar)

        if(not BarSettings.UseGradient?):
            BaseGradientBar.SetVisibility(widget_visibility.Hidden)
            MainUI.RemoveWidget(BaseGradientBar)

        if(CurRank := AllRanks[Rank]):
            RankImage.SetImage(CurRank.RankImage)
            if(NextRank := AllRanks[Rank + 1]):
                NextRankImage.SetImage(NextRank.RankImage)
        return MyCanvas
        

    #Function to control bar movement
    RankChange()<suspends> : void=
        var SpeedAmount : float = 0.0
        if(BarSettings.BarSpeed = BarSpeedType.Slow):
            set SpeedAmount = 0.5
        else if(BarSettings.BarSpeed = BarSpeedType.Fast):
            set SpeedAmount = 1.0
            
        race:

            #Loop that waits for rank change and adds to values
            block:
                loop:
                    Sleep(0.0)
                    #Wait for a rank value change and gets new rank value
                    ReceiveAmount := RankChangeEvent.Await()
                    AmountToIncrease := RankValue + ReceiveAmount(0)


                    #If value is not less than zero, adds to bar values
                    if(AmountToIncrease >= 0.0):
                        spawn{AddPopUp(ReceiveAmount(0),ReceiveAmount(1))}
                        set ChangeAmount += ReceiveAmount(0)
                        if(ReceiveAmount(0) > 0.0):
                            set ShadowValue = RankValue + ChangeAmount
                        else:
                            spawn{DecreaseShadowAmount(ReceiveAmount(0))}
                
                 

            #Loop that feathers new values and actual rank values, while also adding persistence
            block:
                loop:
                    Sleep(0.0)

                    #If Amount to change is greater than 0, decreases change amount and increases rank value
                    if(ChangeAmount > 0.0):
                        set ChangeAmount -= SpeedAmount
                        set RankValue += SpeedAmount
                        RankedPersistence.RecordPlayerStat(Player, StatType.RankValue, ?Score := SpeedAmount)
                        UpdateEvent.Signal()

                    #If Amount to change is less than 0, increase change amount and decreases rank value
                    else if(ChangeAmount < 0.0):
                        if(RankValue > 0.0):
                            set ChangeAmount += SpeedAmount
                            set RankValue -= SpeedAmount
                            RankedPersistence.RecordPlayerStat(Player, StatType.RankValue, ?Score := -SpeedAmount)
                            UpdateEvent.Signal()
                        else:
                            set ChangeAmount = 0.0



            #Loop that moves shadow bar when decreased
            block:
                loop:
                    Sleep(0.0)
                    if(ChangeShadowAmount < 0.0):
                        set ChangeShadowAmount += SpeedAmount
                        set ShadowValue -= SpeedAmount
                        UpdateEvent.Signal()
                




            #Loop that waits for an update in rank score and updates the UI according to it
            loop:

                #Waits for rank score update
                UpdateEvent.Await()

                #Checks rank and gets new progress values for current rank
                CheckRank(false)
                ProgressAmount := GetPercentageAmount(RankValue,false)
                ShadowAmount := GetPercentageAmount(ShadowValue,false)

                #If rank bar is not full
                if(ProgressAmount < BarSettings.Position.Right):

                    #If shadow bar is not full update with current progress and shadow bars
                    if(ShadowAmount < BarSettings.Position.Right):
                        UpdateRankBars(ProgressAmount,ShadowAmount)

                    #If shadow bar is full, update with current progress and a full shadow bar
                    else:
                        UpdateRankBars(ProgressAmount,BarSettings.Position.Right)

                    #Updates rank text
                    UpdateRankStuff(false)

                else:
                    UpdateRankBars(BarSettings.Position.Right,BarSettings.Position.Right)

                #If current rank is the last rank and the NeverLoseLastRank setting is enabled, sets bar to full and breaks loop
                if(CurRank := AllRanks[Rank], CurRank.NeverLoseRank?):
                    UpdateRankBars(BarSettings.Position.Right,0.0)
        


    #Used to have a delay before decreasing shadow bar
    DecreaseShadowAmount(ReceiveAmount : float)<suspends> : void= 
        Sleep(ShadowWaitTime)
        set ChangeShadowAmount += ReceiveAmount


    #Updates Rank Bars 
    UpdateRankBars(ProgressAmount : float,ShadowAmount : float)<suspends> : void=
        if(BarSettings.BarStyle = StyleType.Custom):
            spawn{UpdateCustomBars(ProgressAmount , ShadowAmount)}
        else:
            #Makes bars hidden
            BaseProgressBar.SetVisibility(widget_visibility.Hidden)
            BaseShadowBar.SetVisibility(widget_visibility.Hidden)

            #Removes Bars
            MainUI.RemoveWidget(BaseProgressBar)
            MainUI.RemoveWidget(BaseShadowBar)

            #Makes bars visible
            BaseProgressBar.SetVisibility(widget_visibility.Visible)
            BaseShadowBar.SetVisibility(widget_visibility.Visible)
            Print("{ProgressAmount}")
            #Adds Bars
            MainUI.AddWidget(
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}, Maximum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}}
                Offsets := margin{Left := BarSettings.Position.Left, Top := BarSettings.Position.Top, Right := ProgressAmount, Bottom := BarSettings.Position.Bottom}
                Alignment := vector2{X := 0.0, Y := 0.5}
                SizeToContent := false
                ZOrder := 2
                Widget := BaseProgressBar
            )
            MainUI.AddWidget(
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}, Maximum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}}
                Offsets := margin{Left := BarSettings.Position.Left, Top := BarSettings.Position.Top, Right := ShadowAmount, Bottom := BarSettings.Position.Bottom}
                Alignment := vector2{X := 0.0, Y := 0.5}
                SizeToContent := false
                ZOrder := 1
                Widget := BaseShadowBar
            )

            if(BarSettings.UseGradient?):
                BaseGradientBar.SetVisibility(widget_visibility.Hidden)
                MainUI.RemoveWidget(BaseGradientBar)
                BaseGradientBar.SetVisibility(widget_visibility.Visible)
                MainUI.AddWidget(
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}, Maximum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}}
                        Offsets := margin{Left := BarSettings.Position.Left, Top := BarSettings.Position.Top, Right := ProgressAmount, Bottom := BarSettings.Position.Bottom}
                        Alignment := vector2{X := 0.0, Y := 0.5}
                        SizeToContent := false
                        ZOrder := 3
                        Widget := BaseGradientBar
                    )

    #Updates bars if option is set to custom
    UpdateCustomBars(ProgressAmount : float,ShadowAmount : float)<suspends> : void=
        #Makes bars hidden
        CustomProgressBar.SetVisibility(widget_visibility.Hidden)
        CustomShadowBar.SetVisibility(widget_visibility.Hidden)

        #Removes Bars
        MainUI.RemoveWidget(CustomProgressBar)
        MainUI.RemoveWidget(CustomShadowBar)

        #Makes bars visible
        CustomProgressBar.SetVisibility(widget_visibility.Visible)
        CustomShadowBar.SetVisibility(widget_visibility.Visible)

        #Adds Bars
        MainUI.AddWidget(
        canvas_slot:
            Anchors := anchors{Minimum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}, Maximum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}}
            Offsets := margin{Left := BarSettings.Position.Left, Top := BarSettings.Position.Top, Right := ProgressAmount, Bottom := BarSettings.Position.Bottom}
            Alignment := vector2{X := 0.0, Y := 0.5}
            SizeToContent := false
            ZOrder := 2
            Widget := CustomProgressBar
        )
        MainUI.AddWidget(
        canvas_slot:
            Anchors := anchors{Minimum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}, Maximum := vector2{X := BarSettings.Position.AnchorX, Y := BarSettings.Position.AnchorY}}
            Offsets := margin{Left := BarSettings.Position.Left, Top := BarSettings.Position.Top, Right := ShadowAmount, Bottom := BarSettings.Position.Bottom}
            Alignment := vector2{X := 0.0, Y := 0.5}
            SizeToContent := false
            ZOrder := 1
            Widget := CustomShadowBar
        )
    #Adds pop up text
    AddPopUp(IncreaseAmount : float , Description : string)<suspends> : void=

        #Makes text and basic text values
        var ChangeText : text_block = text_block{DefaultTextColor := White}
        var Height : float = PopUpSettings.Position.Top
        var Opacity : float = 1.0

        #Gets rank and percentage values
        if(CurRank := AllRanks[Rank] , PercentageAdd := (GetPercentageAmount(IncreaseAmount, true) / BarSettings.Position.Right)):
            #Adds description if enabled
            var DescriptionText : string = ""
            if(PopUpSettings.DisplayDescription?):
                set DescriptionText = Description
            else:
                set DescriptionText = ""
            #Adds a + if the number is not negative
            var AddOrPlus : string = ""
            if(PercentageAdd < 0.0):
                set AddOrPlus = ""
                ChangeText.SetTextColor(PopUpSettings.DecreaseColor)
            else:
                set AddOrPlus = "+"
                ChangeText.SetTextColor(PopUpSettings.IncreaseColor)

            #Changes how add score will be displayed based on settings
            var ScoreDisplay : string = ""
            if(CurRank.DisplaySetting = DisplayType.Percentage,Percentage := Int[PercentageAdd * 100.0]):
                set ScoreDisplay = "{AddOrPlus}{Percentage}% {DescriptionText}" 
            else if(CurRank.DisplaySetting = DisplayType.Points,NewValue := Int[IncreaseAmount]):
                set ScoreDisplay = "{AddOrPlus}{NewValue} {DescriptionText}"
            else if(CurRank.DisplaySetting = DisplayType.ELO,NewValue := Int[IncreaseAmount]):
                set ScoreDisplay = "{AddOrPlus}{NewValue} ELO {DescriptionText}"

            #Changes the text
            ChangeText.SetText(ToMessage(ScoreDisplay))

        
        race:
            #Removes the text after allocated time
            block:
                Sleep(PopUpSettings.Duration)
                ChangeText.SetVisibility(widget_visibility.Hidden)
                MainUI.RemoveWidget(ChangeText)
                return


            #Decreases Opacity and Vertically moves the text
            loop:
                Sleep(0.0)
                #Changes Opacity
                set Opacity -= 0.03
                if(NEWOPACITY := type{_X : float where _X >= 0.0, _X <= 1.0}[Opacity]):
                    ChangeText.SetTextOpacity(NEWOPACITY)
                #Changes Height
                set Height -= PopUpSettings.Speed
                ChangeText.SetVisibility(widget_visibility.Hidden)
                MainUI.RemoveWidget(ChangeText)
                ChangeText.SetVisibility(widget_visibility.Visible)
                MainUI.AddWidget(
                    canvas_slot:   #Idle Money Resource Text
                        Anchors := anchors{Minimum := vector2{X := PopUpSettings.Position.AnchorX, Y := PopUpSettings.Position.AnchorY}, Maximum := vector2{X := PopUpSettings.Position.AnchorX, Y := PopUpSettings.Position.AnchorY}}
                        Offsets := margin{Left := PopUpSettings.Position.Left, Top := Height, Right := PopUpSettings.Position.Right, Bottom := PopUpSettings.Position.Bottom}  
                        Alignment := vector2{X := 0.0, Y := 0.5}
                        SizeToContent := false
                        Widget := ChangeText
                )

    #Handles settings when a rank is changed
    HandleRankChange(UpOrDown : logic, IsFirst : logic)<suspends> : void=
        if(not IsFirst?):
            if(RankChangeSettings.EnableImageSizeAnimation?):
                spawn{RankChangeAnimation()}
            else:
                if(CurRank := AllRanks[Rank]):
                    #Sets image
                    RankImage.SetImage(CurRank.RankImage)

                    if(NextRank := AllRanks[Rank + 1],CurRank.ShowNextRank?):
                        NextRankImage.SetImage(NextRank.RankImage)
                    else:
                        NextRankImage.SetImage(RankMaterials.blank)
            if(RankChangeSettings.EnableChangePopUp? , not IsChangePopUp?):
                spawn{RankChangePopUp(UpOrDown)}
        else:
            if(CurRank := AllRanks[Rank]):
                #Sets image
                RankImage.SetImage(CurRank.RankImage)

                if(NextRank := AllRanks[Rank + 1],CurRank.ShowNextRank?):
                    NextRankImage.SetImage(NextRank.RankImage)
                else:
                    NextRankImage.SetImage(RankMaterials.blank)
                
    #Creates a rank change pop up
    RankChangePopUp(UpOrDown : logic) <suspends> : void=
        set IsChangePopUp = true
        RankChangeAudioPlayer.Play(Player)
        if(CurRank := AllRanks[Rank]):
            var CurrentAction : int = 0
            var NewRankImage : texture_block = texture_block{DefaultImage := CurRank.RankImage}
            var NewRankTextImage : texture_block = texture_block{DefaultImage := CurRank.RankTextImage}
            var UpDownImage : texture_block = texture_block{DefaultImage := RankMaterials.blank}
            if(UpOrDown?):
                UpDownImage.SetImage(RankUpImage)
            else:
                UpDownImage.SetImage(RankDownImage)


            var ImageScale : float = 0.0
            var ImageHeight : float = -150.0   + (9.0 * 6)
            var UpDownImageHeight : float = 90.0 + (9.0 * 6)
            var TextImageScaleX : float = 627.0 + (6.0 * 4)
            var TextImageScaleY : float = 340.0 + (6.0 * 4)

            var TestAmount : int = 0

            race:
                block:
                    #Time for scaling rank image
                    Sleep(0.33)

                    #Time for moving rank image and updown image up
                    set CurrentAction = 1
                    Sleep(0.27)

                    #Time for scaling down rank text image
                    set CurrentAction = 2
                    Sleep(0.17)

                    #Pause Time
                    set CurrentAction = 5
                    Sleep(0.33)

                    #Time for rank image to scale up
                    set CurrentAction = 3
                    Sleep(0.17)

                    #Pause time
                    set CurrentAction = 5
                    Sleep(0.13)
                    
                    #time for rank image to scale down
                    set CurrentAction = 4
                    Sleep(0.17)

                    #Pause time
                    set CurrentAction = 5
                    Sleep(3.0)

                    NewRankImage.SetVisibility(widget_visibility.Hidden)
                    NewRankTextImage.SetVisibility(widget_visibility.Hidden)
                    UpDownImage.SetVisibility(widget_visibility.Hidden)
                    MainUI.RemoveWidget(NewRankImage)
                    MainUI.RemoveWidget(NewRankTextImage)
                    MainUI.RemoveWidget(UpDownImage)
                    set IsChangePopUp = false
                    return

                
                loop:
                    if(CurrentAction = 0):
                        set ImageScale += 27.0

                    else if(CurrentAction = 1):
                        set ImageHeight -= 6.0
                        set UpDownImageHeight -= 6.0

                    else if(CurrentAction = 2):
                        set TextImageScaleX += -4.0
                        set TextImageScaleY += -4.0

                    else if(CurrentAction = 3):
                        set ImageScale += 4.0

                    else if(CurrentAction = 4):
                        set ImageScale += -15.0

                    Sleep(0.0)
                    #Updates the widget
                    NewRankImage.SetVisibility(widget_visibility.Hidden)
                    MainUI.RemoveWidget(NewRankImage)
                    NewRankImage.SetVisibility(widget_visibility.Visible)
                    MainUI.AddWidget(
                        canvas_slot:
                            Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                            Offsets := margin{Left := 0.0, Top := ImageHeight, Right := ImageScale, Bottom := ImageScale}
                            Alignment := vector2{X := 0.5, Y := 0.5}
                            SizeToContent := false
                            Widget := NewRankImage
                        )
                    if(CurrentAction = 1):
                        UpDownImage.SetVisibility(widget_visibility.Hidden)
                        MainUI.RemoveWidget(UpDownImage)
                        UpDownImage.SetVisibility(widget_visibility.Visible)
                        MainUI.AddWidget(
                            canvas_slot:
                                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                                Offsets := margin{Left := 0.0, Top := UpDownImageHeight, Right := 470.0, Bottom := 300.0}
                                Alignment := vector2{X := 0.5, Y := 0.5}
                                SizeToContent := false
                                Widget := UpDownImage
                            )
                            
                    else if(CurrentAction = 2):
                        NewRankTextImage.SetVisibility(widget_visibility.Hidden)
                        MainUI.RemoveWidget(NewRankTextImage)
                        NewRankTextImage.SetVisibility(widget_visibility.Visible)
                        MainUI.AddWidget(
                            canvas_slot:
                                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                                Offsets := margin{Left := 0.0, Top := 180.0, Right := TextImageScaleX, Bottom := TextImageScaleY}
                                Alignment := vector2{X := 0.5, Y := 0.5}
                                SizeToContent := false
                                Widget := NewRankTextImage
                            )
                        



    #Creates a rank change animation
    RankChangeAnimation()<suspends> : void=
        var Scale : float = 60.0
        var StartAdding : logic = false

        race:
            #Resets rank and stops transition after a certain amount of time
            block:
                Sleep(1.0)
                RankImage.SetVisibility(widget_visibility.Hidden)
                NextRankImage.SetVisibility(widget_visibility.Hidden)
                MainUI.RemoveWidget(RankImage)
                MainUI.RemoveWidget(NextRankImage)
                RankImage.SetVisibility(widget_visibility.Visible)
                NextRankImage.SetVisibility(widget_visibility.Visible)
                MainUI.AddWidget(
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := UIPositions.CurrentRankImagePosition.AnchorX, Y := UIPositions.CurrentRankImagePosition.AnchorY}, Maximum := vector2{X := UIPositions.CurrentRankImagePosition.AnchorX, Y := UIPositions.CurrentRankImagePosition.AnchorY}}
                        Offsets := margin{Left := UIPositions.CurrentRankImagePosition.Left, Top := UIPositions.CurrentRankImagePosition.Top, Right := UIPositions.CurrentRankImagePosition.Right, Bottom := UIPositions.CurrentRankImagePosition.Bottom}
                        Alignment := vector2{X := 0.5, Y := 0.5}
                        SizeToContent := false
                        Widget := RankImage
                    )

                MainUI.AddWidget(
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := UIPositions.NextRankImagePosition.AnchorX, Y := UIPositions.NextRankImagePosition.AnchorY}, Maximum := vector2{X := UIPositions.NextRankImagePosition.AnchorX, Y := UIPositions.NextRankImagePosition.AnchorY}}
                        Offsets := margin{Left := UIPositions.NextRankImagePosition.Left, Top := UIPositions.NextRankImagePosition.Top, Right := UIPositions.NextRankImagePosition.Right, Bottom :=UIPositions.NextRankImagePosition.Bottom}
                        Alignment := vector2{X := 0.5, Y := 0.5}
                        SizeToContent := false
                        Widget := NextRankImage
                    )
                return


            #Increases/Decreases the scale of the image
            loop:
                Sleep(0.0)

                #Changes Scale Size
                if(Scale = 0.0):
                    set Scale += 4.0
                    set StartAdding = true
                    if(CurRank := AllRanks[Rank]):
                        #Sets image
                        RankImage.SetImage(CurRank.RankImage)

                        if(NextRank := AllRanks[Rank + 1],CurRank.ShowNextRank?):
                            NextRankImage.SetImage(NextRank.RankImage)
                        else:
                            NextRankImage.SetImage(RankMaterials.blank)

                else if(not StartAdding?):
                    set Scale -= 4.0
                else:
                    set Scale += 4.0
               

                #Updates the widget
                NextRankImage.SetVisibility(widget_visibility.Hidden)
                RankImage.SetVisibility(widget_visibility.Hidden)
                MainUI.RemoveWidget(NextRankImage)
                MainUI.RemoveWidget(RankImage)
                NextRankImage.SetVisibility(widget_visibility.Visible)
                RankImage.SetVisibility(widget_visibility.Visible)
                MainUI.AddWidget(
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := UIPositions.CurrentRankImagePosition.AnchorX, Y := UIPositions.CurrentRankImagePosition.AnchorY}, Maximum := vector2{X := UIPositions.CurrentRankImagePosition.AnchorX, Y := UIPositions.CurrentRankImagePosition.AnchorY}}
                        Offsets := margin{Left := UIPositions.CurrentRankImagePosition.Left, Top := UIPositions.CurrentRankImagePosition.Top, Right := Scale, Bottom := Scale}
                        Alignment := vector2{X := 0.5, Y := 0.5}
                        SizeToContent := false
                        Widget := RankImage
                    )
                MainUI.AddWidget(
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := UIPositions.NextRankImagePosition.AnchorX, Y := UIPositions.NextRankImagePosition.AnchorY}, Maximum := vector2{X := UIPositions.NextRankImagePosition.AnchorX, Y := UIPositions.NextRankImagePosition.AnchorY}}
                        Offsets := margin{Left := UIPositions.NextRankImagePosition.Left, Top := UIPositions.NextRankImagePosition.Top, Right := Scale, Bottom := Scale}
                        Alignment := vector2{X := 0.5, Y := 0.5}
                        SizeToContent := false
                        Widget := NextRankImage
                    )


#Main creative device class
Rank_System:= class(creative_device):

    #Persistence Device
    RankedPersistence : Rank_Persistence = Rank_Persistence{}     

    #Map of all players ranked info
    var PlayersRankMap : [player]Ranked_Player = map{}      

    #Editable array of all ranks
    @editable AllRanks : []Ranks = array{}

    #Array of textures for each rank (*ORDER MATTERS* : EACH ELEMENT WILL CORRESPOND TO THE ELEMENT IN YOUR ALLRANKS ARRAY)
    var RankImages : []texture = array{RankMaterials.Unranked_Rank,RankMaterials.Bronze_Rank_1,RankMaterials.Bronze_Rank_2,RankMaterials.Bronze_Rank_3,RankMaterials.Silver_Rank_1,RankMaterials.Silver_Rank_2,RankMaterials.Silver_Rank_3,RankMaterials.Gold_Rank_1,RankMaterials.Gold_Rank_2,RankMaterials.Gold_Rank_3,RankMaterials.Platinum_Rank_1,RankMaterials.Platinum_Rank_2,RankMaterials.Platinum_Rank_3,RankMaterials.Diamond_Rank_1,RankMaterials.Diamond_Rank_2,RankMaterials.Diamond_Rank_3,RankMaterials.ELITE_Rank,RankMaterials.Champion_Rank,RankMaterials.Unreal_Rank}

    var RankTextImages : []texture = array{RankMaterials.TextUnranked,RankMaterials.TextBronze1,RankMaterials.TextBronze2,RankMaterials.TextBronze3,RankMaterials.TextSilver1,RankMaterials.TextSilver2,RankMaterials.TextSilver3,RankMaterials.TextGold1,RankMaterials.TextGold2,RankMaterials.TextGold3,RankMaterials.TextPlatinum1,RankMaterials.TextPlatinum2,RankMaterials.TextPlatinum3,RankMaterials.TextDiamond1,RankMaterials.TextDiamond2,RankMaterials.TextDiamond3,RankMaterials.TextElite,RankMaterials.TextChampion,RankMaterials.TextUnreal}

    @editable PopUpSettings : PopUpSetting = PopUpSetting{}

    @editable BarSettings : BarSetting = BarSetting{}

    @editable RankChangeSettings : RankChangeSetting = RankChangeSetting{}

    @editable UIPositions : UIPosition = UIPosition{}

    @editable ApparelSetting : ApparelType = ApparelType.None

    @editable PrestigeSetting : PrestigeType = PrestigeType.Off

    @editable ShadowWaitTime : type{_X : float where _X >= 0.0, _X <= 1.0} = 0.0

    @editable ActivatePrestigeTrigger : trigger_device = trigger_device{}

    @editable RankChangeAudioPlayer : audio_player_device = audio_player_device{}

    


    OnBegin<override>()<suspends>:void=
        
        #Initializes Ranks
        InitializeRanks()

        #Initiates every player in lobby and future players who join
        for(Player : GetPlayspace().GetPlayers()) {InitiatePlayer(Player)}
        GetPlayspace().PlayerAddedEvent().Subscribe(InitiatePlayer)

        ActivatePrestigeTrigger.TriggeredEvent.Subscribe(TryToPerstige)


    #Initiates every ranks image
    InitializeRanks()<suspends> : void=
        for(idx -> R : AllRanks , RImage := RankImages[idx],RTextImage := RankTextImages[idx]):
            set R.RankImage = RImage
            set R.RankTextImage = RTextImage
    
    #Initiates a player into current player map and gets persistence data
    InitiatePlayer(Agent:agent): void=
        if(Player := player[Agent]):

            #Initializes persistence for player
            RankedPersistence.InitializePlayer(Player)

            #Checks if player already exists in the playermap
            if(PlayerExists := PlayersRankMap[Player]):  
                
            #If player does not already exist
            else:

                #Get players persistence data and updates their current data to it
                if(PlayerStats := RankedPersistence.GetPlayerStats[Player]):    
                    if(set PlayersRankMap[Player] = Ranked_Player{      
                        
                        #Normal Playermap values
                        Player := Player
                        AllRanks := AllRanks

                        #Persistence values
                        RankValue := PlayerStats.RankValue
                        Eliminations := PlayerStats.Eliminations
                        Deaths := PlayerStats.Deaths
                        Wins := PlayerStats.Wins
                        Loses := PlayerStats.Loses
                        Prestiges := PlayerStats.Prestiges

                        PopUpSettings := PopUpSettings
                        ApparelSetting := ApparelSetting
                        PrestigeSetting := PrestigeSetting
                        BarSettings := BarSettings
                        ShadowWaitTime := ShadowWaitTime
                        UIPositions := UIPositions
                        RankChangeSettings := RankChangeSettings
                        RankChangeAudioPlayer := RankChangeAudioPlayer
                        }){}

                    #Initiates the ranked system for the player
                    if(CustomPlayer := PlayersRankMap[Player]) { spawn{CustomPlayer.InitiateUI()} }


    #Function to try to prestige player
    TryToPerstige(Agent:?agent):void=
        if(NewAgent := Agent?,CP := PlayersRankMap[NewAgent]):
            CP.Prestige()