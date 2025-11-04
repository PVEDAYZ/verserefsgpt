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
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }

TravelBackInTime := class(creative_device):
    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable TravelBackTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}

    @editable TravelBackProp : creative_prop = creative_prop{}

    @editable MainRemoteMan : signal_remote_manager_device = signal_remote_manager_device{}
    
    @editable TravelBackTime : float = 0.0
    @editable GameStartDevice : GameStart = GameStart{}
    @editable TravelBackClassNumber : int = 100

    var PlayerPastLocation : vector3 = vector3{}
    @editable TravelBackTP : teleporter_device = teleporter_device{}


    @editable TravelBackTPSound : audio_player_device = audio_player_device{}
    @editable TravelBackSetPropSound : audio_player_device = audio_player_device{}

    @editable TravelBackSetting : int = 0
    #0 = no prop at tp location
    #1 = prop at tp location
    #2 = Right click to place place prop left to teleport to it


    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        Sleep(3.0)
        TravelBackTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        TravelBackTimer.SuccessEvent.Subscribe(ResetCooldown)


        MainRemoteMan.SecondarySignalEvent.Subscribe(SetPastLocation)
        MainRemoteMan.PrimarySignalEvent.Subscribe(TPToSetLocation)
        
        for (Player : GetPlayspace().GetPlayers()):
            if(FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = TravelBackClassNumber):
                    spawn:
                        GetPastLocation(FC)



    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false

    TravelBack(Agent:agent)<suspends> : void=
        if(Player := player[Agent], FC:=Player.GetFortCharacter[]):
            if(TravelBackSetting = 0):
                if(MaybeCooldown = false):
                    TravelBackTimer.Start(Agent)
                    set MaybeCooldown=true
                    if(TravelBackTP.TeleportTo[PlayerPastLocation,FC.GetTransform().Rotation]){}
                    TravelBackTP.Teleport(Agent)
                    TravelBackTPSound.Play(Agent)
                    if(TravelBackTP.TeleportTo[PlayerPastLocation,FC.GetTransform().Rotation]){}
                else:
                    CooldownMSG.Show(Agent)
            else if(TravelBackSetting = 1):
                if(MaybeCooldown = false):
                    TravelBackTimer.Start(Agent)
                    set MaybeCooldown=true
                    if(TravelBackTP.TeleportTo[PlayerPastLocation,FC.GetTransform().Rotation]){}
                    TravelBackTP.Teleport(Agent)
                    TravelBackTPSound.Play(Agent)
                    if(TravelBackTP.TeleportTo[PlayerPastLocation,FC.GetTransform().Rotation]){}
                    if(TravelBackProp.TeleportTo[vector3{X:=10000.0,Y:=10000.0,Z:=10000.0},IdentityRotation()]){}
                else:
                    CooldownMSG.Show(Agent)
            else:



    TPToSetLocation(Agent:agent) : void=
        if(TravelBackSetting = 2):
            if(GameStartDevice.EachPlayerMap[Agent].ClassNum = TravelBackClassNumber):
                if(MaybeCooldown = false):
                    TravelBackTimer.Start(Agent)
                    set MaybeCooldown=true
                    if(Player := player[Agent], FC:=Player.GetFortCharacter[]):
                        if(TravelBackTP.TeleportTo[PlayerPastLocation,FC.GetTransform().Rotation]){}
                        TravelBackTP.Teleport(Agent)
                        TravelBackTPSound.Play(Agent)
                        if(TravelBackTP.TeleportTo[PlayerPastLocation,FC.GetTransform().Rotation]){}
                        if(TravelBackProp.TeleportTo[vector3{X:=10000.0,Y:=10000.0,Z:=10000.0},IdentityRotation()]){}
                else:
                    CooldownMSG.Show(Agent)
       

    SetPastLocation(Agent:agent) : void=
        if(TravelBackSetting = 2):
            if(GameStartDevice.EachPlayerMap[Agent].ClassNum = TravelBackClassNumber):
                if(Player := player[Agent],FC:=Player.GetFortCharacter[]):
                    set PlayerPastLocation = FC.GetTransform().Translation
                    if(TravelBackProp.TeleportTo[PlayerPastLocation,IdentityRotation()]){}
                    TravelBackSetPropSound.Play(Agent)

    GetPastLocation(FC:fort_character)<suspends> : void=
        set PlayerPastLocation = FC.GetTransform().Translation
        loop:
            Sleep(TravelBackTime)
            if(TravelBackSetting = 0):
                set PlayerPastLocation = FC.GetTransform().Translation
            else if(TravelBackSetting = 1):
                set PlayerPastLocation = FC.GetTransform().Translation
                if(TravelBackProp.TeleportTo[PlayerPastLocation,IdentityRotation()]){}
            else:







    