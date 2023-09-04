---Initialize health and armor settings on the player's ped
---@param ped number
---@param playerId number
---@param playerMetadata any
local function initHealthAndArmor(ped, playerId, playerMetadata)
    SetEntityHealth(ped, playerMetadata.health)
    SetPlayerHealthRechargeMultiplier(playerId, 0.0)
    SetPlayerHealthRechargeLimit(playerId, 0.0)
    SetPedArmour(ped, playerMetadata.armor)
end

---starts death or last stand based off of player's metadata
---@param metadata any
local function initDeathAndLastStand(metadata)
    if metadata.isdead then
        DeathTime = Config.LaststandReviveInterval
        OnDeath()
        AllowRespawn()
    elseif metadata.inlaststand then
        StartLastStand()
    else
        TriggerServerEvent("hospital:server:SetDeathStatus", false)
        TriggerServerEvent("hospital:server:SetLaststandStatus", false)
    end
end

---initialize settings from player object
local function onPlayerLoaded()
    pcall(function() exports.spawnmanager:setAutoSpawn(false) end)
    CreateThread(function()
        Wait(1000)
        local ped = cache.ped
        local playerId = cache.playerId
        PlayerData = QBCore.Functions.GetPlayerData()
        initHealthAndArmor(ped, playerId, PlayerData.metadata)
        initDeathAndLastStand(PlayerData.metadata)
    end)
end

---reset player settings that the server is storing
local function onPlayerUnloaded()
    local ped = cache.ped
    TriggerServerEvent("hospital:server:SetDeathStatus", false)
    TriggerServerEvent('hospital:server:SetLaststandStatus', false)
    TriggerServerEvent("hospital:server:SetArmor", GetPedArmour(ped))
    IsDead = false
    DeathTime = 0
    SetEntityInvincible(ped, false)
    SetPedArmour(ped, 0)
    ResetAllInjuries()
end

AddEventHandler('QBCore:Client:OnPlayerLoaded', onPlayerLoaded)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', onPlayerUnloaded)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    onPlayerLoaded()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    onPlayerUnloaded()
end)
