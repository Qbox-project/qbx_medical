local sharedConfig = require 'config.shared'
local WEAPONS = exports.qbx_core:GetWeapons()
local allowRespawn = false

local function playDeadAnimation()
    local deadAnimDict = 'dead'
    local deadAnim = not QBX.PlayerData.metadata.ishandcuffed and 'dead_a' or 'dead_f'
    local deadVehAnimDict = 'veh@low@front_ps@idle_duck'
    local deadVehAnim = 'sit'

    if cache.vehicle then
        if not IsEntityPlayingAnim(cache.ped, deadVehAnimDict, deadVehAnim, 3) then
            lib.requestAnimDict(deadVehAnimDict, 5000)
            TaskPlayAnim(cache.ped, deadVehAnimDict, deadVehAnim, 1.0, 1.0, -1, 1, 0, false, false, false)
        end
    elseif not IsEntityPlayingAnim(cache.ped, deadAnimDict, deadAnim, 3) then
        lib.requestAnimDict(deadAnimDict, 5000)
        TaskPlayAnim(cache.ped, deadAnimDict, deadAnim, 1.0, 1.0, -1, 1, 0, false, false, false)
    end
end

exports('PlayDeadAnimation', playDeadAnimation)

---put player in death animation and make invincible
function OnDeath()
    if DeathState == sharedConfig.deathState.DEAD then return end
    SetDeathState(sharedConfig.deathState.DEAD)
    TriggerEvent('qbx_medical:client:onPlayerDied')
    TriggerServerEvent('qbx_medical:server:onPlayerDied')
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'demo', 0.1)

    WaitForPlayerToStopMoving()

    CreateThread(function()
        while DeathState == sharedConfig.deathState.DEAD do
            DisableControls()
            SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
            Wait(0)
        end
    end)

    ResurrectPlayer()
    playDeadAnimation()
    SetEntityInvincible(cache.ped, true)
    SetEntityHealth(cache.ped, GetEntityMaxHealth(cache.ped))
end

exports('KillPlayer', OnDeath)

local function respawn()
    local success = lib.callback.await('qbx_medical:server:respawn')
    if not success then return end
    if exports.qbx_policejob:IsHandcuffed() then
        TriggerEvent('police:client:GetCuffed', -1)
    end
    TriggerEvent('police:client:DeEscort')
end

---Allow player to respawn
function AllowRespawn()
    allowRespawn = true
    RespawnHoldTime = 5
    while DeathState == sharedConfig.deathState.DEAD do
        Wait(1000)
        DeathTime -= 1
        if DeathTime <= 0 then
            if IsControlPressed(0, 38) and RespawnHoldTime <= 1 and allowRespawn then
                respawn()
            end
            if IsControlPressed(0, 38) then
                RespawnHoldTime -= 1
            end
            if IsControlReleased(0, 38) then
                RespawnHoldTime = 5
            end
            if RespawnHoldTime <= 1 then
                RespawnHoldTime = 0
            end
        end
    end
end

exports('AllowRespawn', AllowRespawn)

exports('DisableRespawn', function()
    allowRespawn = false
end)

---log the death of a player along with the attacker and the weapon used.
---@param victim number ped
---@param attacker number ped
---@param weapon string weapon hash
local function logDeath(victim, attacker, weapon)
    local playerId = NetworkGetPlayerIndexFromPed(victim)
    local playerName = (' %s (%d)'):format(GetPlayerName(playerId), GetPlayerServerId(playerId)) or Lang:t('info.self_death')
    local killerId = NetworkGetPlayerIndexFromPed(attacker)
    local killerName = ('%s (%d)'):format(GetPlayerName(killerId), GetPlayerServerId(killerId)) or Lang:t('info.self_death')
    local weaponLabel = WEAPONS[weapon].label or 'Unknown'
    local weaponName = WEAPONS[weapon].name or 'Unknown'
    local message = Lang:t('logs.death_log_message', { killername = killerName, playername = playerName, weaponlabel = weaponLabel, weaponname = weaponName })

    lib.callback.await('qbx_medical:server:log', false, 'logDeath', message)
end

---when player is killed by another player, set last stand mode, or if already in last stand mode, set player to dead mode.
---@param event string
---@param data table
AddEventHandler('gameEventTriggered', function(event, data)
    if event ~= 'CEventNetworkEntityDamage' then return end
    local victim, attacker, victimDied, weapon = data[1], data[2], data[4], data[7]
    if not IsEntityAPed(victim) or not victimDied or NetworkGetPlayerIndexFromPed(victim) ~= cache.playerId or not IsEntityDead(cache.ped) then return end
    if DeathState == sharedConfig.deathState.ALIVE then
        StartLastStand()
    elseif DeathState == sharedConfig.deathState.LAST_STAND then
        EndLastStand()
        logDeath(victim, attacker, weapon)
        DeathTime = 0
        OnDeath()
        AllowRespawn()
    end
end)

function DisableControls()
    DisableAllControlActions(0)
    EnableControlAction(0, 1, true)
    EnableControlAction(0, 2, true)
    EnableControlAction(0, 245, true)
    EnableControlAction(0, 38, true)
    EnableControlAction(0, 0, true)
    EnableControlAction(0, 322, true)
    EnableControlAction(0, 288, true)
    EnableControlAction(0, 213, true)
    EnableControlAction(0, 249, true)
    EnableControlAction(0, 46, true)
    EnableControlAction(0, 47, true)
end