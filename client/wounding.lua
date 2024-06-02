local config = require 'config.client'
local sharedConfig = require 'config.shared'
local prevPos = vec3(0.0, 0.0, 0.0)
local enableBleeding = true

local function getWorstInjury()
    local level = 0
    for _, injury in pairs(Injuries) do
        if injury.severity > level then
            level = injury.severity
        end
    end

    return level
end

CreateThread(function()
    while true do
        if NumInjuries > 0 then
            local level = getWorstInjury()
            SetPedMoveRateOverride(cache.ped, sharedConfig.woundLevels[level].movementRate)
            Wait(5)
        else
            Wait(1000)
        end
    end
end)

local function makePlayerBlackout()
    SetFlash(0, 0, 100, 7000, 100)

    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(0)
    end

    if not IsPedRagdoll(cache.ped) and IsPedOnFoot(cache.ped) and not IsPedSwimming(cache.ped) then
        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08) -- change this float to increase/decrease camera shake
        SetPedToRagdollWithFall(cache.ped, 7500, 9000, 1, GetEntityForwardVector(cache.ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    end

    Wait(1500)
    DoScreenFadeIn(1000)
end

exports('MakePlayerBlackout', makePlayerBlackout)

local function makePlayerFadeOut()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(0)
    end
    DoScreenFadeIn(500)
end

exports('MakePlayerFadeOut', makePlayerFadeOut)

local function applyBleedEffects()
    if not QBX.PlayerData then return end
    local bleedDamage = BleedLevel * config.bleedDamageTimer
    ApplyDamageToPed(cache.ped, bleedDamage, false)
    SendBleedAlert()
    Hp -= bleedDamage
    local randX = math.random() + math.random(-1, 1)
    local randY = math.random() + math.random(-1, 1)
    local coords = GetOffsetFromEntityInWorldCoords(cache.ped, randX, randY, 0)
    TriggerServerEvent('evidence:server:CreateBloodDrop', QBX.PlayerData.citizenid, QBX.PlayerData.metadata.bloodtype, coords)

    if AdvanceBleedTimer >= config.advanceBleedTimer then
        ApplyBleed(1)
        AdvanceBleedTimer = 0
    else
        AdvanceBleedTimer += 1
    end
end

---reduce bleeding by level. Bleed level cannot be negative.
---@param level number
local function removeBleed(level)
    if BleedLevel == 0 then return end
    local newBleedLevel = BleedLevel - level
    if newBleedLevel < 0 then
        SetBleedLevel(0)
    else
        SetBleedLevel(newBleedLevel)
    end

    SendBleedAlert()
end

exports('RemoveBleed', removeBleed)

local function handleBleeding()
    if DeathState ~= sharedConfig.deathState.ALIVE or BleedLevel <= 0 then return end
    if FadeOutTimer + 1 == config.fadeOutTimer then
        if BlackoutTimer + 1 == config.blackoutTimer then
            makePlayerBlackout()
            BlackoutTimer = 0
        else
            makePlayerFadeOut()
            BlackoutTimer += BleedLevel > 3 and 2 or 1
        end

        FadeOutTimer = 0
    else
        FadeOutTimer += 1
    end
    applyBleedEffects()
end

---@param ped number
local function bleedTick(ped)
    if math.floor(BleedTickTimer % (config.bleedTickRate / 10)) == 0 then
        local currPos = GetEntityCoords(ped, true)
        local moving = #(prevPos.xy - currPos.xy)
        if (moving > 1 and not cache.vehicle) and BleedLevel > 2 then
            AdvanceBleedTimer += config.bleedMovementAdvance
            BleedTickTimer += config.bleedMovementTick
            prevPos = currPos
        else
            BleedTickTimer += 1
        end
    end
    BleedTickTimer += 1
end

local function checkBleeding()
    if BleedLevel == 0 then return end
    if BleedTickTimer >= config.bleedTickRate then
        handleBleeding()
        BleedTickTimer = 0
    else
        bleedTick(cache.ped)
    end
end

--- enables all systems associated with bleeds
exports('EnableBleeding', function()
    enableBleeding = true
end)

--- prevents existing bleeds from increasing, disables damage taken from bleeding, and disables ill effects from blood loss such as blacking out
exports('DisableBleeding', function()
    enableBleeding = false
end)

CreateThread(function()
    Wait(2500)
    while true do
        Wait(1000)
        if enableBleeding then
            checkBleeding()
        end
    end
end)

local function savePlayerPos()
    prevPos = GetEntityCoords(cache.ped, true)
end

AddEventHandler('QBCore:Client:OnPlayerLoaded', savePlayerPos)
AddEventHandler('onResourceStart', function(resourceName)
    if cache.resource ~= resourceName then return end
    savePlayerPos()
end)
