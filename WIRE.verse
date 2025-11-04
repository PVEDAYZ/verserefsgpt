using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

# =========================================
# DEVICE → HANDLERS → WHEN IT FIRES
# =========================================
# one_v_one_elim_tp
# - BlueSpawner (player_spawner_device)
#     → OnSpawnFromA(agent)         → player spawns at Blue
# - RedSpawner (player_spawner_device)
#     → OnSpawnFromB(agent)         → player spawns at Red
# - BlueTeleporter/RedTeleporter (teleporter_device)
#     → OnTeleported(agent)         → after a teleport occurs
# - BoundsZones (mutator_zone_device[])
#     → OnBoundsEntered(agent)      → when duel player hits mutator zone (HUD warning)
# - Elims (elimination_manager_device)
#     → ElimLoop() awaits           → any elimination (routes to HandleScoringAndStreaks)
# - ExplodeOnInteractButton (button_device)
#     → OnExplodeButton(agent)      → button pressed (cooldown-gated)
# - FallDamageVolume (damage_volume_device)
#     → OnDamageVolumeEntered(agent)→ agent enters damage volume
# - IntermissionHUD (hud_message_device)
#     → ShowHUDTo(...)              → intermission start
# - Revenge/Comeback packs
#     → AwardRevenge/AwardComeback  → on conditions met
# - TeleportGranters (item_granter_device[])
#     → GrantTeleportLoadout(agent) → after teleport (per-side, cooldown-gated)

# admin_control_bridge
# - ToggleDebugButton        → OnToggleDebugPressed       → flips DEBUG on baseline + managers
# - StateDumpButton          → OnStateDumpPressed         → prints round/time/kills/deaths/streak/intermission
# - StartOvertimeButton      → OnStartOvertimePressed     → forces timeout flow immediately
# - RoundTime30/60/120Button → OnRoundTime*Pressed        → sets RoundSeconds & restarts round
# - GrantBlue/RedButton      → OnGrant*Pressed            → grant loadout (cooldown-aware)
# - GrantBlue/RedBypass      → OnGrant*BypassPressed      → grant loadout (bypass cooldown)
# - TeleportBlue/RedHome     → OnTP*HomePressed           → teleport duel player to side teleporter
# - ManualJumpscareButton    → OnManualJumpscarePressed   → calls JumpScare.DoScareManual
# - SimElimBlue/RedButton    → OnSimElim*Pressed          → simulate elim (no damage, full scoring path)

device_wiring_map := class(creative_device):
    OnBegin<override>()<suspends>:void =
        return
