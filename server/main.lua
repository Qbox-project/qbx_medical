---@class PlayerStatus
---@field injuries table<BodyPartKey, integer>
---@field isBleeding number

---@alias Source number

---@type table<Source, PlayerStatus>
local playerStatus = {}

---@type table<Source, table<number, boolean>> weapon hashes
local WeaponsThatDamagedPlayers = {}

local triggerEventHooks = require 'modules.hooks.server'

RegisterNetEvent('qbx_medical:server:playerDamagedByWeapon', function(hash)
	if WeaponsThatDamagedPlayers[source][hash] then return end
	WeaponsThatDamagedPlayers[source][hash] = true
end)

---@param player table|number
local function revivePlayer(player)
	if type(player) == "number" then
		player = exports.qbx_core:GetPlayer(player)
	end
	player.Functions.SetMetaData("isdead", false)
	player.Functions.SetMetaData("inlaststand", false)
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

---@param data PlayerStatus
lib.callback.register('qbx_medical:server:syncInjuries', function(source, data)
	playerStatus[source] = data
end)

---@param playerId number
lib.callback.register('hospital:GetPlayerStatus', function(_, playerId)
	local playerSource = exports.qbx_core:GetPlayer(playerId).PlayerData.source

	---@class PlayerDamage
	---@field damagedBodyParts BodyParts
	---@field bleedLevel number
	---@field weaponWounds number[]

	---@type PlayerDamage
	local damage = {
		damagedBodyParts = {},
		bleedLevel = 0,
		weaponWounds = {}
	}
	if not playerSource then
		return damage
	end

	local playerInjuries = playerStatus[playerSource]
	if playerInjuries then
		damage.bleedLevel = playerInjuries.isBleeding or 0
		damage.damagedBodyParts = playerInjuries.injuries
	end

	damage.weaponWounds = WeaponsThatDamagedPlayers[playerSource] or {}
	return damage
end)

RegisterNetEvent('qbx_medical:server:playerDied', function()
	if GetInvokingResource() then return end
	local src = source
	local player = exports.qbx_core:GetPlayer(src)
	if not player then return end
	player.Functions.SetMetaData("isdead", true)
end)

RegisterNetEvent('qbx_medical:server:onPlayerLaststand', function()
	if GetInvokingResource() then return end
	local player = exports.qbx_core:GetPlayer(source)
	player.Functions.SetMetaData("inlaststand", true)
end)

RegisterNetEvent('qbx_medical:server:onPlayerLaststandEnd', function()
	if GetInvokingResource() then return end
	local player = exports.qbx_core:GetPlayer(source)
	player.Functions.SetMetaData("inlaststand", false)
end)

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
