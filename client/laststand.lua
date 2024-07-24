local config = require 'config.client'
local sharedConfig = require 'config.shared'
local WEAPONS = exports.qbx_core:GetWeapons()

---blocks until ped is no longer moving
function WaitForPlayerToStopMoving()
    local timeOut = 10000
    while GetEntitySpeed(cache.ped) > 0.1 and IsPedRagdoll(cache.ped) and timeOut > 1 do
        timeOut -= 10 Wait(10)
    end
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

    if killer_2 ~= 0 and killer_2 ~= -1 then
        killer = killer_2
    end

    local killerId = NetworkGetPlayerIndexFromPed(killer)
    local killerName = killerId ~= -1 and (' %s (%d)'):format(GetPlayerName(killerId), GetPlayerServerId(killerId)) or locale('info.self_death')
    local weaponItem = WEAPONS[killerWeapon]
    local weaponLabel = locale('info.wep_unknown') or (weaponItem and weaponItem.label)
    local weaponName = locale('info.wep_unknown') or (weaponItem and weaponItem.name)
    local message = locale('logs.death_log_message', killerName, GetPlayerName(cache.playerId), weaponLabel, weaponName)

    lib.callback.await('qbx_medical:server:log', false, 'playerKiller', message)
end

---count down last stand, if last stand is over, put player in death mode and log the killer.
local function countdownLastStand()
    if LaststandTime - 1 > 0 then
        LaststandTime -= 1
    else
        exports.qbx_core:Notify(locale('error.bled_out'), 'error')
        EndLastStand()
        logPlayerKiller()
        DeathTime = config.deathTime
        OnDeath()
    end
end

---put player in last stand mode and notify EMS.
function StartLastStand(attacker, weapon)
    TriggerEvent('ox_inventory:disarm', cache.playerId, true)
    WaitForPlayerToStopMoving()
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'demo', 0.1)
    LaststandTime = config.laststandReviveInterval
    ResurrectPlayer()
    SetEntityHealth(cache.ped, 150)
    SetDeathState(sharedConfig.deathState.LAST_STAND)
    TriggerEvent('qbx_medical:client:onPlayerLaststand', attacker, weapon)
    TriggerServerEvent('qbx_medical:server:onPlayerLaststand', attacker, weapon)
    CreateThread(function()
        while DeathState == sharedConfig.deathState.LAST_STAND do
            countdownLastStand()
            Wait(1000)
        end
    end)

    CreateThread(function()
        while DeathState == sharedConfig.deathState.LAST_STAND do
            DisableControls()
            PlayLastStandAnimation()
            Wait(0)
        end
    end)
end

exports('StartLastStand', StartLastStand)