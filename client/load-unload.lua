local config = require 'config.client'

---Initialize health and armor settings on the player's ped
---@param ped number
---@param playerId number
---@param playerMetadata any
local function initHealthAndArmor(ped, playerId, playerMetadata)
    SetEntityMaxHealth(ped, 200)
    SetEntityHealth(ped, playerMetadata.health)
    SetPlayerHealthRechargeMultiplier(playerId, 0.0)
    SetPlayerHealthRechargeLimit(playerId, 0.0)
    SetPedArmour(ped, playerMetadata.armor)
end

---starts death or last stand based off of player's metadata
---@param metadata any
local function initDeathAndLastStand(metadata)
    if metadata.isdead then
        DeathTime = config.deathTime
        OnDeath()
    elseif metadata.inlaststand then
        StartLastStand()
    end
end

---initialize settings from player object
local function onPlayerLoaded()
    pcall(function() exports.spawnmanager:setAutoSpawn(false) end)
    CreateThread(function()
        Wait(1000)
        initHealthAndArmor(cache.ped, cache.playerId, QBX.PlayerData.metadata)
        initDeathAndLastStand(QBX.PlayerData.metadata)
    end)
end

AddEventHandler('QBCore:Client:OnPlayerLoaded', onPlayerLoaded)

AddEventHandler('onResourceStart', function(resourceName)
    if cache.resource ~= resourceName then return end
    onPlayerLoaded()
end)
