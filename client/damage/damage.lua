local config = require 'config.client'
local sharedConfig = require 'config.shared'
local playerArmor = nil
local damageEffectsEnabled = true
local WEAPONS = exports.qbx_core:GetWeapons()

---Increases severity of an injury
---@param bodyPartKey BodyPartKey
local function upgradeInjury(bodyPartKey)
    local injury = Injuries[bodyPartKey]
    if injury.severity >= 4 then return end
    injury.severity += 1
    SetInjury(bodyPartKey, injury)
end

---creates an injury on body part with random severity between 1 and 3.
---@param bodyPartKey BodyPartKey
---@param weaponHash number
local function createInjury(bodyPartKey, weaponHash)
    local severity = math.random(1, 3)
    SetInjury(bodyPartKey, {severity = severity, weaponHash = weaponHash} )
    NumInjuries += 1
end

---create/upgrade injury at bone.
---@param bodyPartKey BodyPartKey
---@param weaponHash number
local function injureBodyPart(bodyPartKey, weaponHash)
    local severity = Injuries[bodyPartKey]
    if not severity then
        createInjury(bodyPartKey, weaponHash)
    else
        upgradeInjury(bodyPartKey)
    end
end

---returns true if player took damage in their upper body or if the weapon class is NONE
---@param isArmorDamaged boolean
---@param bodypart string
---@param weapon number
---@return boolean
local function checkBodyHitOrWeakWeapon(isArmorDamaged, bodypart, weapon)
    return isArmorDamaged and (bodypart == 'SPINE' or bodypart == 'UPPER_BODY') or weapon == config.weaponClasses.NONE
end

---gets the weapon class of the weapon that damaged the player.
---@param ped number player's ped
---@return integer? hash of weapon that damaged player, or nil if player hasn't been damaged.
local function getDamagingWeapon(ped)
    for hash in pairs(config.weapons) do
        if HasPedBeenDamagedByWeapon(ped, hash, 0) then
            return hash
        end
    end
end

---health lost becomes a damaging event if a certain weapon was used or hp lost is above the force injury threshold.
---Otherwise, the probability of a damaging event goes up from 0 as the damageDone increases above the minimum threshold.
---@param damageDone number hitpoints lost
---@return boolean isDamagingEvent true if player should have disabilities from damage.
local function isDamagingEvent(damageDone, weaponClass)
    local luck = math.random(100)
    local multi = damageDone / config.healthDamage

    return luck < (config.healthDamage * multi) or (damageDone >= config.forceInjury or multi > config.maxInjuryChanceMulti or config.forceInjuryWeapons[weaponClass])
end

---Sets a ragdoll effect probablistically on the player's ped.
---@param ped number
---@param isArmored boolean
---@param chance number
---@param armor number
local function applyStaggerEffect(ped, isArmored, chance, armor)
    if not isArmored or armor > 0 or math.random(100) > math.ceil(chance) then return end
    SetPedToRagdoll(ped, 1500, 2000, 3, true, true, false)
end

---applies a minor bleed if player has no armor and is hit in a critical area.
---also makes player stagger if hit in a certain body part.
---@param ped number
---@param bodyPartKey BodyPartKey body part where player is damaged
---@param armor number
local function applyImmediateMinorEffects(ped, bodyPartKey, armor)
    if config.criticalAreas[bodyPartKey] and armor <= 0 then
       ApplyBleed(1)
    end

    local staggerArea = config.staggerAreas[bodyPartKey]
    if not staggerArea then return end
    applyStaggerEffect(ped, staggerArea.armored, staggerArea.minor, armor)
end

---Applies bleed with probability based on armor and location hit. Also applies stagger effect.
---@param ped number
---@param bodyPartKey BodyPartKey body part where player is damaged
---@param armor number
local function applyImmediateMajorEffects(ped, bodyPartKey, armor)
    local criticalArea = config.criticalAreas[bodyPartKey]
    if criticalArea then
        if armor > 0 and criticalArea.armored then
            if math.random(100) <= math.ceil(config.majorArmoredBleedChance) then
                ApplyBleed(1)
            end
        else
            ApplyBleed(1)
        end
    else
        if armor > 0 then
            if math.random(100) < (config.majorArmoredBleedChance) then
                ApplyBleed(1)
            end
        elseif math.random(100) < (config.majorArmoredBleedChance * 2) then
            ApplyBleed(1)
        end
    end

    local staggerArea = config.staggerAreas[bodyPartKey]
    if not staggerArea then return end
    applyStaggerEffect(ped, staggerArea.armored, staggerArea.major, armor)
end

---Apply bleeds and staggers effects on damage taken, taking into account armor.
---@param ped number
---@param bodyPartKey BodyPartKey
---@param weaponClass WeaponClass
---@param damageDone number
local function applyImmediateEffects(ped, bodyPartKey, weaponClass, damageDone)
    local armor = GetPedArmour(ped)
    if config.minorInjurWeapons[weaponClass] and damageDone < config.damageMinorToMajor then
        applyImmediateMinorEffects(ped, bodyPartKey, armor)
    elseif config.majorInjurWeapons[weaponClass] or (config.minorInjurWeapons[weaponClass] and damageDone >= config.damageMinorToMajor) then
        applyImmediateMajorEffects(ped, bodyPartKey, armor)
    end
end

---Apply bleeds, injure the body part hit, make ped limp/stagger
---@param ped number
---@param boneId integer
---@param weaponHash number
---@param weaponClass WeaponClass
---@param damageDone number
local function checkDamage(ped, boneId, weaponHash, weaponClass, damageDone)
    if not weaponClass then return end

    local bodyPartKey = config.bones[boneId]
    if not bodyPartKey or DeathState ~= sharedConfig.deathState.ALIVE then return end

    applyImmediateEffects(ped, bodyPartKey, weaponClass, damageDone)
    injureBodyPart(bodyPartKey, weaponHash)
    MakePedLimp()
end

---Apply damage to health and armor based off of damage done and weapon used.
---@param ped number
---@param damageDone number
---@param isArmorDamaged boolean
---@return number? weaponHash
local function applyDamage(ped, damageDone, isArmorDamaged)
    local hit, bone = GetPedLastDamageBone(ped)
    local bodypart = config.bones[bone]
    local weaponHash = getDamagingWeapon(ped)
    if not hit or bodypart == 'NONE' or not weaponHash then return end
    local weaponClass = config.weapons[weaponHash]

    if damageDone >= config.healthDamage then
        local isBodyHitOrWeakWeapon = checkBodyHitOrWeakWeapon(isArmorDamaged, bodypart, weaponClass)
        if isBodyHitOrWeakWeapon and isArmorDamaged then
            lib.callback.await('qbx_medical:server:setArmor', false, GetPedArmour(ped))
        elseif not isBodyHitOrWeakWeapon and isDamagingEvent(damageDone, weaponClass) then
            checkDamage(ped, bone, weaponHash, weaponClass, damageDone)
        end
    elseif config.alwaysBleedChanceWeapons[weaponClass]
        and math.random(100) < config.alwaysBleedChance
        and not checkBodyHitOrWeakWeapon(isArmorDamaged, bodypart, weaponClass) then
        ApplyBleed(1)
    end

    return weaponHash
end

---If the player health and armor haven't already been set, initialize them.
---@param health number
---@param armor number
local function initHealthAndArmorIfNotSet(health, armor)
    if not Hp then
        Hp = health
    end

    if not playerArmor then
        playerArmor = armor
    end
end

---detects if player took damage, applies injuries, and updates health/armor values
local function checkForDamage()
    local health = GetEntityHealth(cache.ped)
    local armor = GetPedArmour(cache.ped)

    initHealthAndArmorIfNotSet(health, armor)

    local isArmorDamaged = (playerArmor ~= armor and armor < (playerArmor - config.armorDamage) and armor > 0) -- Players armor was damaged
    local isHealthDamaged = (Hp ~= health) -- Players health was damaged

    if isArmorDamaged or isHealthDamaged then
        local damageDone = (Hp - health)
        local weaponHash = applyDamage(cache.ped, damageDone, isArmorDamaged)
        if weaponHash and not WeaponsThatDamagedPlayer[weaponHash] then
            TriggerEvent('chat:addMessage', {
                color = { 255, 0, 0 },
                multiline = false,
                args = { locale('info.status'), WEAPONS[weaponHash].damagereason }
            })
            WeaponsThatDamagedPlayer[weaponHash] = true
        end
        ClearEntityLastDamageEntity(cache.ped)
    end

    Hp = health
    playerArmor = armor
end

---Checks the player for damage, applies injuries, and damage effects
CreateThread(function()
    while true do
        checkForDamage()
        if damageEffectsEnabled then
            ApplyDamageEffects()
        end
        Wait(100)
    end
end)

exports('EnableDamageEffects', function()
    damageEffectsEnabled = true
end)

exports('DisableDamageEffects', function()
    damageEffectsEnabled = false
end)
