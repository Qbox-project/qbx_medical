local config = require 'config.client'
local sharedConfig = require 'config.shared'
local WEAPONS = exports.qbx_core:GetWeapons()

---blocks until ped is no longer moving
function WaitForPlayerToStopMoving()
    local timeOut = 10000
    while GetEntitySpeed(cache.ped) > 0.5 or IsPedRagdoll(cache.ped) and timeOut > 1 do timeOut -= 10 Wait(10) end
end

--- low level GTA resurrection
function ResurrectPlayer()
    local pos = GetEntityCoords(cache.ped)
    local heading = GetEntityHeading(cache.ped)

    NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z + 0.5, heading, true, false)
    if cache.vehicle then
        SetPedIntoVehicle(cache.ped, cache.vehicle, cache.seat)
    end
end

---remove last stand mode from player.
function EndLastStand()
    TaskPlayAnim(cache.ped, LastStandDict, 'exit', 1.0, 8.0, -1, 1, -1, false, false, false)
    LaststandTime = 0
    TriggerServerEvent('qbx_medical:server:onPlayerLaststandEnd')
end

local function logPlayerKiller()
    local killer_2, killerWeapon = NetworkGetEntityKillerOfPlayer(cache.playerId)
    local killer = GetPedSourceOfDeath(cache.ped)
    if killer_2 ~= 0 and killer_2 ~= -1 then killer = killer_2 end
    local killerId = NetworkGetPlayerIndexFromPed(killer)
    local killerName = killerId ~= -1 and GetPlayerName(killerId) .. ' ' .. '(' .. GetPlayerServerId(killerId) .. ')' or Lang:t('info.self_death')
    local weaponLabel = Lang:t('info.wep_unknown')
    local weaponName = Lang:t('info.wep_unknown')
    local weaponItem = WEAPONS[killerWeapon]
    if weaponItem then
        weaponLabel = weaponItem.label
        weaponName = weaponItem.name
    end
    TriggerServerEvent('qb-log:server:CreateLog', 'death', Lang:t('logs.death_log_title', { playername = GetPlayerName(cache.playerId), playerid = GetPlayerServerId(cache.playerId) }), 'red', Lang:t('logs.death_log_message', { killername = killerName, playername = GetPlayerName(cache.playerId), weaponlabel = weaponLabel, weaponname = weaponName }))
end

---count down last stand, if last stand is over, put player in death mode and log the killer.
local function countdownLastStand()
    if LaststandTime - 1 > 0 then
        LaststandTime -= 1
    else
        exports.qbx_core:Notify(Lang:t('error.bled_out'), 'error')
        EndLastStand()
        logPlayerKiller()
        DeathTime = 0
        OnDeath()
        AllowRespawn()
    end
end

---put player in last stand mode and notify EMS.
function StartLastStand()
    Wait(1000)
    WaitForPlayerToStopMoving()
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'demo', 0.1)
    LaststandTime = config.laststandReviveInterval
    ResurrectPlayer()
    SetEntityHealth(cache.ped, 150)
    PlayUnescortedLastStandAnimation()
    SetDeathState(sharedConfig.deathState.LAST_STAND)
    TriggerEvent('qbx_medical:client:onPlayerLaststand')
    TriggerServerEvent('qbx_medical:server:onPlayerLaststand')
    CreateThread(function()
        while DeathState == sharedConfig.deathState.LAST_STAND do
            countdownLastStand()
            Wait(1000)
        end
    end)

    CreateThread(function()
        while DeathState == sharedConfig.deathState.LAST_STAND do
            DisableControls()
            Wait(0)
        end
    end)
end
