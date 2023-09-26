---@class PlayerStatus
---@field limbs BodyParts
---@field isBleeding number

---@type table<source, PlayerStatus>
local playerStatus = {}

---@type table<source, number[]> weapon hashes
local playerWeaponWounds = {}

local triggerEventHooks = require 'modules.hooks.server'

---@param data number[] weapon hashes
RegisterNetEvent('hospital:server:SetWeaponDamage', function(data)
	if GetInvokingResource() then return end
	local src = source
	local player = QBX.Functions.GetPlayer(src)
	if not player then return end
	playerWeaponWounds[player.PlayerData.source] = data
end)

RegisterNetEvent('hospital:server:RestoreWeaponDamage', function()
	if GetInvokingResource() then return end
	local src = source
	local player = QBX.Functions.GetPlayer(src)
	playerWeaponWounds[player.PlayerData.source] = nil
end)

---Compatibility with txAdmin Menu's heal options.
---This is an admin only server side event that will pass the target player id or -1.
---@class EventData
---@field id number
---@param eventData EventData
AddEventHandler('txAdmin:events:healedPlayer', function(eventData)
	if GetInvokingResource() ~= "monitor" or type(eventData) ~= "table" or type(eventData.id) ~= "number" then
		return
	end

	TriggerClientEvent('hospital:client:Revive', eventData.id)
	TriggerClientEvent("hospital:client:HealInjuries", eventData.id, "full")
end)

---@param data PlayerStatus
RegisterNetEvent('hospital:server:SyncInjuries', function(data)
	if GetInvokingResource() then return end
	local src = source
	playerStatus[src] = data
end)

---@param limbs BodyParts
---@return BodyParts
local function getDamagedBodyParts(limbs)
	local bodyParts = {}
	for bone, bodyPart in pairs(limbs) do
		if bodyPart.isDamaged then
			bodyParts[bone] = bodyPart
		end
	end
	return bodyParts
end

---@param playerId number
lib.callback.register('hospital:GetPlayerStatus', function(_, playerId)
	local playerSource = QBX.Functions.GetPlayer(playerId).PlayerData.source

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
		damage.damagedBodyParts = getDamagedBodyParts(playerInjuries.limbs)
	end

	damage.weaponWounds = playerWeaponWounds[playerSource] or {}
	return damage
end)

---@param isDead boolean
RegisterNetEvent('hospital:server:SetDeathStatus', function(isDead)
	if GetInvokingResource() then return end
	local src = source
	local player = QBX.Functions.GetPlayer(src)
	if not player then return end
	player.Functions.SetMetaData("isdead", isDead)
end)

RegisterNetEvent('qbx-medical:server:playerDied', function()
	if GetInvokingResource() then return end
	local src = source
	local player = QBX.Functions.GetPlayer(src)
	if not player then return end
	player.Functions.SetMetaData("isdead", true)
end)

---@param bool boolean
RegisterNetEvent('hospital:server:SetLaststandStatus', function(bool)
	if GetInvokingResource() then return end
	local src = source
	local player = QBX.Functions.GetPlayer(src)
	if not player then return end
	player.Functions.SetMetaData("inlaststand", bool)
end)

---@param amount number
RegisterNetEvent('hospital:server:SetArmor', function(amount)
	if GetInvokingResource() then return end
	local src = source
	local player = QBX.Functions.GetPlayer(src)
	if not player then return end
	player.Functions.SetMetaData("armor", amount)
end)

RegisterNetEvent('hospital:server:resetHungerThirst', function()
	if GetInvokingResource() then return end
	local player = QBX.Functions.GetPlayer(source)

	if not player then return end

	player.Functions.SetMetaData('hunger', 100)
	player.Functions.SetMetaData('thirst', 100)

	TriggerClientEvent('hud:client:UpdateNeeds', source, 100, 100)
end)

---Triggers the event on the player or src, if no target is specified
---@param src number playerId of the one triggering the event
---@param event string event name
---@param targetPlayerId? string playerId of the target of the event
local function triggerEventOnPlayer(src, event, targetPlayerId)
	if not targetPlayerId then
		TriggerClientEvent(event, src)
		return
	end

	local player = QBX.Functions.GetPlayer(tonumber(targetPlayerId))

	if not player then
		TriggerClientEvent('ox_lib:notify', src, { description = Lang:t('error.not_online'), type = 'error' })
		return
	end

	TriggerClientEvent(event, player.PlayerData.source)
end

lib.addCommand('revive', {
    help = Lang:t('info.revive_player_a'),
	restricted = "admin",
	params = {
        { name = 'id', help = Lang:t('info.player_id'), type = 'playerId', optional = true },
    }
}, function(source, args)
	triggerEventOnPlayer(source, 'hospital:client:Revive', args.id)
end)

lib.addCommand('setpain', {
    help = Lang:t('info.pain_level'),
	restricted = "admin",
	params = {
        { name = 'id', help = Lang:t('info.player_id'), type = 'playerId', optional = true },
    }
}, function(source, args)
	triggerEventOnPlayer(source, 'hospital:client:SetPain', args.id)
end)

lib.addCommand('kill', {
    help =  Lang:t('info.kill'),
	restricted = "admin",
	params = {
        { name = 'id', help = Lang:t('info.player_id'), type = 'playerId', optional = true },
    }
}, function(source, args)
	triggerEventOnPlayer(source, 'hospital:client:KillPlayer', args.id)
end)

lib.addCommand('aheal', {
    help =  Lang:t('info.heal_player_a'),
	restricted = "admin",
	params = {
        { name = 'id', help = Lang:t('info.player_id'), type = 'playerId', optional = true },
    }
}, function(source, args)
	triggerEventOnPlayer(source, 'hospital:client:adminHeal', args.id)
end)

lib.callback.register('qbx-medical:server:respawn', function(source)
	if not triggerEventHooks('respawn', source) then return false end
	TriggerEvent('qbx-medical:server:playerRespawned', source)
	return true
end)
