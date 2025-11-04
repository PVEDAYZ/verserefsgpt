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
using { /Fortnite.com/Characters}
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }

TeleportBehindRandom := class(creative_device):
    var ArrayOfPlayers : []player = array{}
    var ButtonPresserIDX: int = 0
    @editable TeleportBehindRandomSound : audio_player_device = audio_player_device{}
    @editable TeleportBehindRandomTP : teleporter_device = teleporter_device{}
    @editable FreezeTime : float = 0.0


    
    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable TeleportBehindRandomTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}

    OnBegin<override>()<suspends>:void=
        TeleportBehindRandomTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        TeleportBehindRandomTimer.SuccessEvent.Subscribe(ResetCooldown)
    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false
            

    RealTP(Agent:agent)<suspends> : void=
        if(MaybeCooldown = false):
            TeleportBehindRandomTimer.Start(Agent)
            set MaybeCooldown=true

            set ArrayOfPlayers = array{}
            for (Player : GetPlayspace().GetPlayers(),FortCharacter := Player.GetFortCharacter[]):
                set ArrayOfPlayers += array{Player}
            if (ButtonPresser := player[Agent], ButtonPresserChar := ButtonPresser.GetFortCharacter[]):
                if(NEWIDX  := ArrayOfPlayers.Find[ButtonPresser]):
                    if(NEWARRAY := ArrayOfPlayers.RemoveElement[NEWIDX]):
                        set ArrayOfPlayers = NEWARRAY
                    RandomInt :=  GetRandomInt(0, ArrayOfPlayers.Length-1)
                    if(RandomPlayer := ArrayOfPlayers[RandomInt],RandomChar := RandomPlayer.GetFortCharacter[]):
                        if(TeleportBehindRandomTP.TeleportTo[RandomChar.GetViewLocation(), RandomChar.GetTransform().Rotation]){}
                        TeleportBehindRandomTP.Teleport(Agent)
                        TeleportBehindRandomSound.Play(Agent)
                        if(TeleportBehindRandomTP.TeleportTo[vector3{X:=1000.0,Y:=1000.0,Z:=1000.0},TeleportBehindRandomTP.GetTransform().Rotation]){}
                        if(ActivatorPlayer := player[Agent],ActivatorChar := ActivatorPlayer.GetFortCharacter[]):
                            S:stasis_args = stasis_args{}
                            if(S.AllowEmotes = false, S.AllowFalling = true, S.AllowTurning=false):
                            ActivatorChar.PutInStasis(S)
                            Sleep(FreezeTime)
                            ActivatorChar.ReleaseFromStasis()
        else:
            CooldownMSG.Show(Agent)