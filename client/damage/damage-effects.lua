local legCount = 0
local armCount = 0
local headCount = 0

---based off of injuries to leg bodyparts of a certain severity.
---@param bodyPartKey BodyPartKey
---@param bodyPart BodyPart
---@return boolean isLegDamaged if leg is considered damaged
local function isLegDamaged(bodyPartKey, bodyPart)
    return (bodyPartKey == 'LLEG' and bodyPart.severity > 1) or (bodyPartKey == 'RLEG' and bodyPart.severity > 1) or (bodyPartKey == 'LFOOT' and bodyPart.severity > 2) or (bodyPartKey == 'RFOOT' and bodyPart.severity > 2)
end

---shake camera and ragdoll player forward
---@param ped number
local function makePedFall(ped)
    ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08) -- change this float to increase/decrease camera shake
    SetPedToRagdollWithFall(ped, 1500, 2000, 1, GetEntityForwardVector(ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
end

---makes player fall based on random number determined by leg injuries. Difference chance while player is walking vs running.
---@param ped number
local function chancePedFalls(ped)
    if IsPedRagdoll(ped) or not IsPedOnFoot(ped) then return end
    local chance = (IsPedRunning(ped) or IsPedSprinting(ped)) and Config.LegInjuryChance.Running or Config.LegInjuryChance.Walking
    local rand = math.random(100)
    if rand > chance then return end
    makePedFall(ped)
end

---checks if left arm is damaged based off of injury location and severity.
---@param bodyPartKey BodyPartKey
---@param bodyPart BodyPart
---@return boolean isDamaged true if the left arm is damaged
local function isLeftArmDamaged(bodyPartKey, bodyPart)
    return (bodyPartKey == 'LARM' and bodyPart.severity > 1) or (bodyPartKey == 'LHAND' and bodyPart.severity > 1) or (bodyPartKey == 'LFINGER' and bodyPart.severity > 2)
end

---checks if either arm is damaged based on injury location and severity.
---@param bodyPartKey BodyPartKey
---@param bodyPart BodyPart
---@return boolean isDamaged true if either arm is damaged
local function isArmDamaged(bodyPartKey, bodyPart)
    return isLeftArmDamaged(bodyPartKey, bodyPart) or (bodyPartKey == 'RARM' and bodyPart.severity > 1) or (bodyPartKey == 'RHAND' and bodyPart.severity > 1) or (bodyPartKey == 'RFINGER' and bodyPart.severity > 2)
end

---enforce following arm disabilities on the player for a set time period:
---Disable left turns in vehicles; disable weapon firing for left arm injuries, and weapon aiming for right arm injuries.
---@param ped number the player's ped
---@param leftArmDamaged boolean true if the player's left arm is damaged, false if the right arm is damaged. 
local function disableArms(ped, leftArmDamaged)
    local disableTimer = 15
    while disableTimer > 0 do
        if IsPedInAnyVehicle(ped, true) then
            DisableControlAction(0, 63, true) -- veh turn left
        end

        local playerId = cache.playerId
        if IsPlayerFreeAiming(playerId) then
            if leftArmDamaged then
                DisablePlayerFiring(playerId, true) -- Disable weapon firing
            else
                DisableControlAction(0, 25, true) -- Disable weapon aiming
            end
        end

        disableTimer -= 1
        Wait(1)
    end
end

---returns whether the player's head is damaged based on injury location and severity.
---@param bodyPartKey BodyPartKey
---@param bodyPart BodyPart
---@return boolean
local function isHeadDamaged(bodyPartKey, bodyPart)
    return bodyPartKey == 'HEAD' and bodyPart.severity > 2
end

---flash screen, fade out, ragdoll, fade in.
---@param ped number
local function playBrainDamageEffectAndRagdoll(ped)
    SetFlash(0, 0, 100, 10000, 100)

    DoScreenFadeOut(100)
    while not IsScreenFadedOut() do
        Wait(0)
    end

    if not IsPedRagdoll(ped) and IsPedOnFoot(ped) and not IsPedSwimming(ped) then
        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08) -- change this float to increase/decrease camera shake
        SetPedToRagdoll(ped, 5000, 1, 2)
    end

    Wait(5000)
    DoScreenFadeIn(250)
end

---applies disabling status effects based on injuries to specific body parts
function ApplyDamageEffects()
    local ped = cache.ped
    if IsDead or InLaststand then return end
    for bodyPartKey, bodyPart in pairs(BodyParts) do
        if isLegDamaged(bodyPartKey, bodyPart) then
            if legCount >= Config.LegInjuryTimer then
                chancePedFalls(ped)
                legCount = 0
            else
                legCount += 1
            end
        elseif isArmDamaged(bodyPartKey, bodyPart) then
            if armCount >= Config.ArmInjuryTimer then
                CreateThread(function()
                    disableArms(ped, isLeftArmDamaged(bodyPartKey, bodyPart))
                end)
                armCount = 0
            else
                armCount += 1
            end
        elseif isHeadDamaged(bodyPartKey, bodyPart) then
            if headCount >= Config.HeadInjuryTimer then
                local chance = math.random(100)

                if chance <= Config.HeadInjuryChance then
                    playBrainDamageEffectAndRagdoll(ped)
                end
                headCount = 0
            else
                headCount += 1
            end
        end
    end
end

exports('applyDamageEffectsDeprecated', ApplyDamageEffects)