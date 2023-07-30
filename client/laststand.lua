---blocks until ped is no longer moving
---@param ped number
function WaitForPlayerToStopMoving()
    local ped = cache.ped
    while GetEntitySpeed(ped) > 0.5 or IsPedRagdoll(ped) do Wait(10) end
end

--- low level GTA resurrection
function ResurrectPlayer()
    local ped = cache.ped
    local pos = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local veh = cache.vehicle
    local seat = cache.seat

    NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z + 0.5, heading, true, false)
    if veh then
        SetPedIntoVehicle(ped, veh, seat)
    end
end

---remove last stand mode from player.
function EndLastStand()
    local ped = cache.ped
    TaskPlayAnim(ped, LastStandDict, "exit", 1.0, 8.0, -1, 1, -1, false, false, false)
    InLaststand = false
    LaststandTime = 0
    TriggerServerEvent("hospital:server:SetLaststandStatus", false)
end

exports('endLastStandDeprecated', EndLastStand)

local function logPlayerKiller()
    local ped = cache.ped
    local player = cache.playerId
    local killer_2, killerWeapon = NetworkGetEntityKillerOfPlayer(player)
    local killer = GetPedSourceOfDeath(ped)
    if killer_2 ~= 0 and killer_2 ~= -1 then killer = killer_2 end
    local killerId = NetworkGetPlayerIndexFromPed(killer)
    local killerName = killerId ~= -1 and GetPlayerName(killerId) .. " " .. "(" .. GetPlayerServerId(killerId) .. ")" or Lang:t('info.self_death')
    local weaponLabel = Lang:t('info.wep_unknown')
    local weaponName = Lang:t('info.wep_unknown')
    local weaponItem = QBCore.Shared.Weapons[killerWeapon]
    if weaponItem then
        weaponLabel = weaponItem.label
        weaponName = weaponItem.name
    end
    TriggerServerEvent("qb-log:server:CreateLog", "death", Lang:t('logs.death_log_title', { playername = GetPlayerName(cache.playerId), playerid = GetPlayerServerId(player) }), "red", Lang:t('logs.death_log_message', { killername = killerName, playername = GetPlayerName(player), weaponlabel = weaponLabel, weaponname = weaponName }))
end

---count down last stand, if last stand is over, put player in death mode and log the killer.
local function countdownLastStand()
    
    if LaststandTime - 1 > 0 then
        LaststandTime -= 1
        Config.DeathTime = LaststandTime
    else
        lib.notify({ description = Lang:t('error.bled_out'), type = 'error' })
        EndLastStand()
        logPlayerKiller()
        DeathTime = 0
        OnDeath()
        AllowRespawn()
    end
    Wait(1000)
end

---put player in last stand mode and notify EMS.
function StartLastStand()
    local ped = cache.ped
    Wait(1000)
    WaitForPlayerToStopMoving()
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "demo", 0.1)
    LaststandTime = Laststand.ReviveInterval
    ResurrectPlayer()
    SetEntityHealth(ped, 150)
    PlayUnescortedLastStandAnimation()
    InLaststand = true
    TriggerServerEvent('qbx-medical:server:onPlayerLaststand')
    CreateThread(function()
        while InLaststand do
            countdownLastStand()
        end
    end)
    TriggerServerEvent("hospital:server:SetLaststandStatus", true)
end