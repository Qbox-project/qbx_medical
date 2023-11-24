---@class PlayerStatus
---@field injuries table<BodyPartKey, integer>
---@field isBleeding number

---@alias Source number

---@type table<Source, table<number, boolean>> weapon hashes
local WeaponsThatDamagedPlayers = {}

local triggerEventHooks = require 'modules.hooks.server'

local playerState

local function getDeathState(src)
	local player = exports.qbx_core:GetPlayer(src)
	return player.PlayerData.metadata.isdead and Config.DeathState.DEAD
		or player.PlayerData.metadata.inlaststand and Config.DeathState.LAST_STAND
		or Config.DeathState.ALIVE
end

AddEventHandler('QBCore:Server:OnPlayerLoaded', function()
	playerState = Player(source).state
	playerState:set(DEATH_STATE_STATE_BAG, getDeathState(source), true)
	playerState:set(BLEED_LEVEL_STATE_BAG, 0, true)
	for bodyPartKey in pairs(Config.BodyParts) do
		playerState:set(BODY_PART_STATE_BAG_PREFIX .. bodyPartKey, nil, true)
	end
end)

AddStateBagChangeHandler(DEATH_STATE_STATE_BAG, nil, function(bagName, _, value)
	local playerId = GetPlayerFromStateBagName(bagName)
	local player = exports.qbx_core:GetPlayer(playerId)
	player.Functions.SetMetaData("isdead", value == Config.DeathState.DEAD)
	player.Functions.SetMetaData("inlaststand", value == Config.DeathState.LAST_STAND)
end)

RegisterNetEvent('qbx_medical:server:playerDamagedByWeapon', function(hash)
	if WeaponsThatDamagedPlayers[source][hash] then return end
	WeaponsThatDamagedPlayers[source][hash] = true
end)

---@param player table|number
local function revivePlayer(player)
	if type(player) == "number" then
		player = exports.qbx_core:GetPlayer(player)
	end
	WeaponsThatDamagedPlayers[player.PlayerData.source] = nil
	TriggerClientEvent('qbx_medical:client:playerRevived', player.PlayerData.source)
end

---Compatibility with txAdmin Menu's heal options.
---This is an admin only server side event that will pass the target player id or -1.
---@class EventData
---@field id number
---@param eventData EventData
AddEventHandler('txAdmin:events:healedPlayer', function(eventData)
	if GetInvokingResource() ~= "monitor" or type(eventData) ~= "table" or type(eventData.id) ~= "number" then
		return
	end

	revivePlayer(eventData.id)
	lib.callback('qbx_medical:client:heal', eventData.id, false, "full")
end)

local function getPlayerInjuries(state)
	local injuries = {}
	for bodyPartKey in pairs(Config.BodyParts) do
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
	local i = 0
	for bodyPartKey, severity in pairs(injuries) do
        local bodyPart = Config.BodyParts[bodyPartKey]
		i += 1
        injuryStatuses[i] = bodyPart.label .. " (" .. Config.woundLevels[severity].label .. ")"
    end

	local status = {
		injuries = injuryStatuses,
		bleedLevel = bleedLevel,
		bleedState = Config.BleedingStates[bleedLevel],
		damageCauses = WeaponsThatDamagedPlayers[src] or {}
	}

	return status
end

exports('GetPlayerStatus', getPlayerStatus)

---@param amount number
lib.callback.register('qbx_medical:server:setArmor', function(source, amount)
	local player = exports.qbx_core:GetPlayer(source)
	player.Functions.SetMetaData("armor", amount)
end)

local function resetHungerAndThirst(player)
	if type(player == 'number') then
		player = exports.qbx_core:GetPlayer(player)
	end

	player.Functions.SetMetaData('hunger', 100)
	player.Functions.SetMetaData('thirst', 100)
	TriggerClientEvent('hud:client:UpdateNeeds', player.PlayerData.source, 100, 100)
end

lib.callback.register('qbx_medical:server:resetHungerAndThirst', resetHungerAndThirst)

lib.addCommand('revive', {
    help = Lang:t('info.revive_player_a'),
	restricted = "admin",
	params = {
        { name = 'id', help = Lang:t('info.player_id'), type = 'playerId', optional = true },
    }
}, function(source, args)
	if not args.id then args.id = source end
	local player = exports.qbx_core:GetPlayer(tonumber(args.id))
	if not player then
		TriggerClientEvent('ox_lib:notify', source, { description = Lang:t('error.not_online'), type = 'error' })
		return
	end
	revivePlayer(args.id)
end)

lib.addCommand('kill', {
    help =  Lang:t('info.kill'),
	restricted = "admin",
	params = {
        { name = 'id', help = Lang:t('info.player_id'), type = 'playerId', optional = true },
    }
}, function(source, args)
	if not args.id then args.id = source end
	local player = exports.qbx_core:GetPlayer(tonumber(args.id))
	if not player then
		TriggerClientEvent('ox_lib:notify', source, { description = Lang:t('error.not_online'), type = 'error' })
		return
	end
	lib.callback('qbx_medical:client:killPlayer', args.id)
end)

lib.addCommand('aheal', {
    help =  Lang:t('info.heal_player_a'),
	restricted = "admin",
	params = {
        { name = 'id', help = Lang:t('info.player_id'), type = 'playerId', optional = true },
    }
}, function(source, args)
	if not args.id then args.id = source end
	local player = exports.qbx_core:GetPlayer(tonumber(args.id))
	if not player then
		TriggerClientEvent('ox_lib:notify', source, { description = Lang:t('error.not_online'), type = 'error' })
		return
	end
	lib.callback('qbx_medical:client:heal', args.id, false, "full")
end)

lib.callback.register('qbx_medical:server:respawn', function(source)
	if not triggerEventHooks('respawn', source) then return false end
	TriggerEvent('qbx_medical:server:playerRespawned', source)
	return true
end)
