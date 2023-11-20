local legCount = 0
local armCount = 0
local headCount = 0

---based off of injuries to leg bodyparts of a certain severity.
---@param part BodyPartKey
---@param injury Injury
---@return boolean isLegDamaged if leg is considered damaged
local function isLegDamaged(part, injury)
    return (part == 'LLEG' and injury.severity > 1) or (part == 'RLEG' and injury.severity > 1) or (part == 'LFOOT' and injury.severity > 2) or (part == 'RFOOT' and injury.severity > 2)
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
---@param part BodyPartKey
---@param injury Injury
---@return boolean isDamaged true if the left arm is damaged
local function isLeftArmDamaged(part, injury)
    return (part == 'LARM' and injury.severity > 1) or (part == 'LHAND' and injury.severity > 1) or (part == 'LFINGER' and injury.severity > 2)
end

---checks if either arm is damaged based on injury location and severity.
---@param part BodyPartKey
---@param injury Injury
---@return boolean isDamaged true if either arm is damaged
local function isArmDamaged(part, injury)
    return isLeftArmDamaged(part, injury) or (part == 'RARM' and injury.severity > 1) or (part == 'RHAND' and injury.severity > 1) or (part == 'RFINGER' and injury.severity > 2)
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
---@param part BodyPartKey
---@param injury Injury
---@return boolean
local function isHeadDamaged(part, injury)
    return part == 'HEAD' and injury.severity > 2
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
        for i = 1, #bodyPart.injuries do
            local injury = bodyPart.injuries[i]

            if isLegDamaged(bodyPartKey, injury) then
                if legCount >= Config.LegInjuryTimer then
                    chancePedFalls(ped)
                    legCount = 0
                else
                    legCount += 1
                end
            elseif isArmDamaged(bodyPartKey, injury) then
                if armCount >= Config.ArmInjuryTimer then
                    CreateThread(function()
                        disableArms(ped, isLeftArmDamaged(bodyPartKey, injury))
                    end)
                    armCount = 0
                else
                    armCount += 1
                end
            elseif isHeadDamaged(bodyPartKey, injury) then
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
end

exports('applyDamageEffectsDeprecated', ApplyDamageEffects)