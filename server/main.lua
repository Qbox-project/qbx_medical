local sharedConfig = require 'config.shared'
local logger = require '@qbx_core.modules.logger'

---@class Injury
---@field severity integer
---@field weaponHash number

---@class PlayerStatus
---@field injuries table<BodyPartKey, Injury>
---@field isBleeding number

---@alias Source number

local triggerEventHooks = require '@qbx_core.modules.hooks'
local respawning = {}

local function getDeathState(src)
	local player = exports.qbx_core:GetPlayer(src)
	return player.PlayerData.metadata.isdead and sharedConfig.deathState.DEAD
		or player.PlayerData.metadata.inlaststand and sharedConfig.deathState.LAST_STAND
		or sharedConfig.deathState.ALIVE
end

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
	local playerState = Player(source).state
	playerState:set(DEATH_STATE_STATE_BAG, getDeathState(source), true)
	playerState:set(BLEED_LEVEL_STATE_BAG, 0, true)
	for bodyPartKey in pairs(sharedConfig.bodyParts) do
		playerState:set(BODY_PART_STATE_BAG_PREFIX .. bodyPartKey, nil, true)
	end
end)

AddStateBagChangeHandler(DEATH_STATE_STATE_BAG, nil, function(bagName, _, value)
    local playerId = GetPlayerFromStateBagName(bagName)
    local player = exports.qbx_core:GetPlayer(playerId)

    if player then
        player.Functions.SetMetaData('isdead', value == sharedConfig.deathState.DEAD)
        player.Functions.SetMetaData('inlaststand', value == sharedConfig.deathState.LAST_STAND)
        Player(playerId).state:set("isDead", value == sharedConfig.deathState.DEAD or value == sharedConfig.deathState.LAST_STAND, true)
        if value == sharedConfig.deathState.ALIVE then
            respawning[playerId] = nil
        end
    end
end)

---@param player table|number
local function resetHungerAndThirst(player)
    if type(player) == 'number' then
        player = exports.qbx_core:GetPlayer(player)
    end
    if not player then return end

    player.Functions.SetMetaData('hunger', 100)
    player.Functions.SetMetaData('thirst', 100)
    TriggerClientEvent('hud:client:UpdateNeeds', player.PlayerData.source, 100, 100)
end

---@param player table|number
local function revivePlayer(player)
    resetHungerAndThirst(player)
    TriggerClientEvent('qbx_medical:client:playerRevived', player --[[@as number]])
end

exports('Revive', revivePlayer)

---removes all ailments, sets to full health, and fills up hunger and thirst.
---@param src Source
local function heal(src)
    resetHungerAndThirst(src)
    TriggerClientEvent('qbx_medical:client:heal', src, 'full')
end

exports('Heal', heal)

---Removes any injuries with severity 2 or lower. Stops bleeding if bleed level is less than 3.
---@param src Source
local function healPartially(src)
    TriggerClientEvent('qbx_medical:client:heal', src, 'partial')
end

exports('HealPartially', healPartially)

---Compatibility with txAdmin Menu's heal options.
---This is an admin only server side event that will pass the target player id or -1.
---@class EventData
---@field id number
---@param eventData EventData
AddEventHandler('txAdmin:events:healedPlayer', function(eventData)
	if GetInvokingResource() ~= 'monitor' or type(eventData) ~= 'table' or type(eventData.id) ~= 'number' then
		return
	end

	revivePlayer(eventData.id)
	heal(eventData.id)
end)

local function getPlayerInjuries(state)
	local injuries = {}
	for bodyPartKey in pairs(sharedConfig.bodyParts) do
		injuries[bodyPartKey] = state[BODY_PART_STATE_BAG_PREFIX .. bodyPartKey]
	end
	return injuries
end

---Get human readable info on a player's health
---@param src Source
---@return {injuries: string[], bleedLevel: integer, bleedState: string, damageCauses: table<number, true>}
local function getPlayerStatus(src)
	local state = Player(src).state
	local bleedLevel = state[BLEED_LEVEL_STATE_BAG]
	local injuries = getPlayerInjuries(state)

	local injuryStatuses = {}
	local weaponsThatDamagedPlayer = {}
	local i = 0
	for bodyPartKey, injury in pairs(injuries) do
        local bodyPart = sharedConfig.bodyParts[bodyPartKey]
		i += 1
        injuryStatuses[i] = bodyPart.label .. ' (' .. sharedConfig.woundLevels[injury.severity].label .. ')'
		weaponsThatDamagedPlayer[injury.weaponHash] = true
	end

	local status = {
		injuries = injuryStatuses,
		bleedLevel = bleedLevel,
		bleedState = sharedConfig.bleedingStates[bleedLevel],
		damageCauses = weaponsThatDamagedPlayer
	}

	return status
end

exports('GetPlayerStatus', getPlayerStatus)

lib.callback.register('qbx_medical:server:setArmor', function(source)
	local player = exports.qbx_core:GetPlayer(source)
	if not player then return end
	local armor = math.max(0, math.min(100, GetPedArmour(GetPlayerPed(source))))
	player.Functions.SetMetaData('armor', armor)
end)

lib.addCommand('revive', {
    help = locale('info.revive_player_a'),
	restricted = 'group.admin',
	params = {
        { name = 'id', help = locale('info.player_id'), type = 'playerId', optional = true },
    }
}, function(source, args)
	if not args.id then args.id = source end
	local player = exports.qbx_core:GetPlayer(tonumber(args.id))
	if not player then
		exports.qbx_core:Notify(source, locale('error.not_online'), 'error')
		return
	end
	revivePlayer(args.id)
end)

lib.addCommand('kill', {
    help =  locale('info.kill'),
	restricted = 'group.admin',
	params = {
        { name = 'id', help = locale('info.player_id'), type = 'playerId', optional = true },
    }
}, function(source, args)
	if not args.id then args.id = source end
	local player = exports.qbx_core:GetPlayer(tonumber(args.id))
	if not player then
		exports.qbx_core:Notify(source, locale('error.not_online'), 'error')
		return
	end
	lib.callback.await('qbx_medical:client:killPlayer', args.id)
end)

lib.addCommand('aheal', {
    help =  locale('info.heal_player_a'),
	restricted = 'group.admin',
	params = {
        { name = 'id', help = locale('info.player_id'), type = 'playerId', optional = true },
    }
}, function(source, args)
	if not args.id then args.id = source end
	local player = exports.qbx_core:GetPlayer(tonumber(args.id))
	if not player then
		exports.qbx_core:Notify(source, locale('error.not_online'), 'error')
		return
	end
	heal(args.id)
end)

lib.callback.register('qbx_medical:server:respawn', function(source)
	if Player(source).state[DEATH_STATE_STATE_BAG] ~= sharedConfig.deathState.DEAD or respawning[source] then return false end
	local respawnToken = GetGameTimer()
	respawning[source] = respawnToken
	if not triggerEventHooks('respawn', {source = source}) then
		respawning[source] = nil
		return false
	end
	TriggerEvent('qbx_medical:server:playerRespawned', source)
	SetTimeout(30000, function()
		if respawning[source] == respawnToken then respawning[source] = nil end
	end)
	return true
end)

lib.callback.register('qbx_medical:server:log', function(_, event, message)
	logger.log({source = 'qbx_medical', event = event, message = message})
end)

AddEventHandler('playerDropped', function()
	respawning[source] = nil
end)
