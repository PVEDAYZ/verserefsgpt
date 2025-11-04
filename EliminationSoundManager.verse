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
using { /Fortnite.com/Game }

EliminationSoundManager := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}


    @editable Class1Sound : audio_player_device = audio_player_device{}
    @editable Class2Sound : audio_player_device = audio_player_device{}
    @editable Class3Sound : audio_player_device = audio_player_device{}
    @editable Class4Sound : audio_player_device = audio_player_device{}
    @editable Class5Sound : audio_player_device = audio_player_device{}
    @editable Class6Sound : audio_player_device = audio_player_device{}
    @editable Class7Sound : audio_player_device = audio_player_device{}
    @editable Class8Sound : audio_player_device = audio_player_device{}
    @editable Class9Sound : audio_player_device = audio_player_device{}
    @editable Class10Sound : audio_player_device = audio_player_device{}
    @editable Class11Sound : audio_player_device = audio_player_device{}
    @editable Class12Sound : audio_player_device = audio_player_device{}
    @editable Class13Sound : audio_player_device = audio_player_device{}
    @editable Class14Sound : audio_player_device = audio_player_device{}
    @editable Class15Sound : audio_player_device = audio_player_device{}
    @editable Class16Sound : audio_player_device = audio_player_device{}




    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers()):
            if(FC := Player.GetFortCharacter[]):
                FC.EliminatedEvent().Subscribe(PlayerIsEliminated)
    PlayerIsEliminated(Result : elimination_result): void=
        if:
            KillerPlayer := Result.EliminatingCharacter?
            KillerAgent := KillerPlayer.GetAgent[]
            DeadPlayer := Result.EliminatedCharacter
            DeadAgent := DeadPlayer.GetAgent[]
        then:
            if(GameStartDevice.EachPlayerMap[KillerAgent].ClassNum = 1):
                Class1Sound.Play(KillerAgent)
            if(GameStartDevice.EachPlayerMap[KillerAgent].ClassNum = 2):
                Class2Sound.Play(KillerAgent)
            if(GameStartDevice.EachPlayerMap[KillerAgent].ClassNum = 3):
                Class3Sound.Play(KillerAgent)   
            if(GameStartDevice.EachPlayerMap[KillerAgent].ClassNum = 4):
                Class4Sound.Play(KillerAgent)
            if(GameStartDevice.EachPlayerMap[KillerAgent].ClassNum = 5):
                Class5Sound.Play(KillerAgent)
            if(GameStartDevice.EachPlayerMap[KillerAgent].ClassNum = 6):
                Class6Sound.Play(KillerAgent)
            if(GameStartDevice.EachPlayerMap[KillerAgent].ClassNum = 7):
                Class7Sound.Play(KillerAgent)
            if(GameStartDevice.EachPlayerMap[KillerAgent].ClassNum = 8):
                Class8Sound.Play(KillerAgent)
            if(GameStartDevice.EachPlayerMap[KillerAgent].ClassNum = 9):
                Class9Sound.Play(KillerAgent)
            if(GameStartDevice.EachPlayerMap[KillerAgent].ClassNum = 10):
                Class10Sound.Play(KillerAgent)
            if(GameStartDevice.EachPlayerMap[KillerAgent].ClassNum = 11):
                Class11Sound.Play(KillerAgent)
            if(GameStartDevice.EachPlayerMap[KillerAgent].ClassNum = 12):
                Class12Sound.Play(KillerAgent)
            if(GameStartDevice.EachPlayerMap[KillerAgent].ClassNum = 13):
                Class13Sound.Play(KillerAgent)
            if(GameStartDevice.EachPlayerMap[KillerAgent].ClassNum = 14):
                Class14Sound.Play(KillerAgent)
            if(GameStartDevice.EachPlayerMap[KillerAgent].ClassNum = 15):
                Class15Sound.Play(KillerAgent)
            if(GameStartDevice.EachPlayerMap[KillerAgent].ClassNum = 16):
                Class16Sound.Play(KillerAgent)

        


