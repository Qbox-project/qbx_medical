local allowRespawn = false

local function playDeadAnimation()
    local ped = cache.ped
    local deadAnimDict = "dead"
    local deadAnim = "dead_a"
    local deadVehAnimDict = "veh@low@front_ps@idle_duck"
    local deadVehAnim = "sit"

    if cache.vehicle then
        if not IsEntityPlayingAnim(ped, deadVehAnimDict, deadVehAnim, 3) then
            lib.requestAnimDict(deadVehAnimDict)
            TaskPlayAnim(ped, deadVehAnimDict, deadVehAnim, 1.0, 1.0, -1, 1, 0, false, false, false)
        end
    elseif not IsEntityPlayingAnim(ped, deadAnimDict, deadAnim, 3) then
        lib.requestAnimDict(deadAnimDict)
        TaskPlayAnim(ped, deadAnimDict, deadAnim, 1.0, 1.0, -1, 1, 0, false, false, false)
    end
end

exports('playDeadAnimation', playDeadAnimation)

---put player in death animation and make invincible
function OnDeath()
    if IsDead then return end
    IsDead = true
    TriggerServerEvent('qbx-medical:server:playerDied')
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "demo", 0.1)
    local player = cache.ped

    WaitForPlayerToStopMoving()

    ResurrectPlayer()
    playDeadAnimation()
    SetEntityInvincible(player, true)
    SetEntityHealth(player, GetEntityMaxHealth(player))
end

exports('killPlayer', OnDeath)

local function respawn()
    local success = lib.callback.await('qbx-medical:server:respawn')
    if not success then return end
    if exports["qb-policejob"]:IsHandcuffed() then
        TriggerEvent("police:client:GetCuffed", -1)
    end
    TriggerEvent("police:client:DeEscort")
end

---Allow player to respawn
function AllowRespawn()
    allowRespawn = true
    RespawnHoldTime = 5
    while IsDead do
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

exports('allowRespawn', AllowRespawn)

exports('disableRespawn', function()
    allowRespawn = false
end)

---log the death of a player along with the attacker and the weapon used.
---@param victim number ped
---@param attacker number ped
---@param weapon string weapon hash
local function logDeath(victim, attacker, weapon)
    local playerid = NetworkGetPlayerIndexFromPed(victim)
    local playerName = GetPlayerName(playerid) .. " " .. "(" .. GetPlayerServerId(playerid) .. ")" or Lang:t('info.self_death')
    local killerId = NetworkGetPlayerIndexFromPed(attacker)
    local killerName = GetPlayerName(killerId) .. " " .. "(" .. GetPlayerServerId(killerId) .. ")" or Lang:t('info.self_death')
    local weaponLabel = QBCore.Shared.Weapons[weapon].label or 'Unknown'
    local weaponName = QBCore.Shared.Weapons[weapon].name or 'Unknown'
    TriggerServerEvent("qb-log:server:CreateLog", "death", Lang:t('logs.death_log_title', { playername = playerName, playerid = GetPlayerServerId(playerid) }), "red", Lang:t('logs.death_log_message', { killername = killerName, playername = playerName, weaponlabel = weaponLabel, weaponname = weaponName }))
end

---when player is killed by another player, set last stand mode, or if already in last stand mode, set player to dead mode.
---@param event string
---@param data table
AddEventHandler('gameEventTriggered', function(event, data)
    if event ~= "CEventNetworkEntityDamage" then return end
    local victim, attacker, victimDied, weapon = data[1], data[2], data[4], data[7]
    if not IsEntityAPed(victim) or not victimDied or NetworkGetPlayerIndexFromPed(victim) ~= cache.playerId or not IsEntityDead(cache.ped) then return end
    if not InLaststand then
        StartLastStand()
    elseif not IsDead then
        EndLastStand()
        logDeath(victim, attacker, weapon)
        DeathTime = 0
        OnDeath()
        AllowRespawn()
    end
end)