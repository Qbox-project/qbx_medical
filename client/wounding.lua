local prevPos = nil

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
        if #Injuries > 0 then
            local level = getWorstInjury()
            SetPedMoveRateOverride(cache.ped, Config.MovementRate[level])
            Wait(5)
        else
            Wait(1000)
        end
    end
end)

local function makePlayerBlackout()
    local ped = cache.ped
    SetFlash(0, 0, 100, 7000, 100)

    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(0)
    end

    if not IsPedRagdoll(ped) and IsPedOnFoot(ped) and not IsPedSwimming(ped) then
        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08) -- change this float to increase/decrease camera shake
        SetPedToRagdollWithFall(ped, 7500, 9000, 1, GetEntityForwardVector(ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    end

    Wait(1500)
    DoScreenFadeIn(1000)
end

exports('makePlayerBlackout', makePlayerBlackout)

local function makePlayerFadeOut()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(0)
    end
    DoScreenFadeIn(500)
end

exports('makePlayerFadeOut', makePlayerFadeOut)

local function applyBleedEffects()
    local ped = cache.ped
    local playerData = QBCore.Functions.GetPlayerData()
    if not playerData then return end
    local bleedDamage = BleedLevel * Config.BleedTickDamage
    ApplyDamageToPed(ped, bleedDamage, false)
    SendBleedAlert()
    Hp -= bleedDamage
    local randX = math.random() + math.random(-1, 1)
    local randY = math.random() + math.random(-1, 1)
    local coords = GetOffsetFromEntityInWorldCoords(ped, randX, randY, 0)
    TriggerServerEvent("evidence:server:CreateBloodDrop", playerData.citizenid, playerData.metadata.bloodtype, coords)

    if AdvanceBleedTimer >= Config.AdvanceBleedTimer then
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
    BleedLevel -= level
    BleedLevel = (BleedLevel < 0) and 0 or BleedLevel
    SendBleedAlert()
end

exports('removeBleed', removeBleed)

local function handleBleeding()
    if IsDead or InLaststand or BleedLevel <= 0 then return end
    if FadeOutTimer + 1 == Config.FadeOutTimer then
        if BlackoutTimer + 1 == Config.BlackoutTimer then
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
    if math.floor(BleedTickTimer % (Config.BleedTickRate / 10)) == 0 then
        local currPos = GetEntityCoords(ped, true)
        local moving = #(prevPos.xy - currPos.xy)
        if (moving > 1 and not cache.vehicle) and BleedLevel > 2 then
            AdvanceBleedTimer += Config.BleedMovementAdvance
            BleedTickTimer += Config.BleedMovementTick
            prevPos = currPos
        else
            BleedTickTimer += 1
        end
    end
    BleedTickTimer += 1
end

local function checkBleeding()
    if BleedLevel == 0 then return end
    local player = cache.ped
    if BleedTickTimer >= Config.BleedTickRate and not IsInHospitalBed then
        handleBleeding()
        BleedTickTimer = 0
    else
        bleedTick(player)
    end
end

exports('checkBleedingDeprecated', checkBleeding)

local function savePlayerPos()
    prevPos = GetEntityCoords(cache.ped, true)
end

AddEventHandler('QBCore:Client:OnPlayerLoaded', savePlayerPos)
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    savePlayerPos()
end)
