local playerArmor = nil

---Increases severity of an injury
---@param bodyPartKey BodyPartKey
local function upgradeInjury(bodyPartKey)
    if Injuries[bodyPartKey] >= 4 then return end
    Injuries[bodyPartKey] += 1
end

---creates an injury on body part with random severity between 1 and maxSeverity.
---@param bodyPartKey BodyPartKey
---@param maxSeverity number
local function createInjury(bodyPartKey, maxSeverity)
    if Injuries[bodyPartKey] then return end
    local severity = math.random(1, maxSeverity)
    Injuries[bodyPartKey] = severity
    NumInjuries += 1
end

---create/upgrade injury at bone.
---@param bodyPartKey BodyPartKey
local function injureBodyPart(bodyPartKey)
    local severity = Injuries[bodyPartKey]
    if not severity then
        createInjury(bodyPartKey, 3)
    else
        upgradeInjury(bodyPartKey)
    end
end

---Adds weapon hashes that damaged the ped that aren't already in the CurrentDamagedList and syncs to the server.
local function findDamageCause()
    for hash, weapon in pairs(exports.qbx_core:GetWeapons()) do
        if HasPedBeenDamagedByWeapon(cache.ped, hash, 0) and not WeaponsThatDamagedPlayer[hash] then
            TriggerEvent('chat:addMessage', {
                color = { 255, 0, 0 },
                multiline = false,
                args = { Lang:t('info.status'), weapon.damagereason }
            })
            WeaponsThatDamagedPlayer[hash] = true
            ---TODO: verify that this only executes once for the loop and can therefore return early.
            TriggerServerEvent('qbx_medical:server:playerDamagedByWeapon', hash)
        end
    end
end

---returns true if player took damage in their upper body or if the weapon class is nothing.
---@param isArmorDamaged boolean
---@param bodypart string
---@param weapon number
---@return boolean
local function checkBodyHitOrWeakWeapon(isArmorDamaged, bodypart, weapon)
    return isArmorDamaged and (bodypart == 'SPINE' or bodypart == 'UPPER_BODY') or weapon == Config.WeaponClasses.NOTHING
end

---gets the weapon class of the weapon that damaged the player.
---@param ped number player's ped
---@return integer|nil weaponClass as defined by config.lua, or nil if player hasn't been damaged.
local function getDamagingWeapon(ped)
    for k, v in pairs(Config.Weapons) do
        if HasPedBeenDamagedByWeapon(ped, k, 0) then
            return v
        end
    end
end

---health lost becomes a damaging event if a certain weapon was used or hp lost is above the force injury threshold.
---Otherwise, the probability of a damaging event goes up from 0 as the damageDone increases above the minimum threshold.
---@param damageDone number hitpoints lost
---@return boolean isDamagingEvent true if player should have disabilities from damage.
local function isDamagingEvent(damageDone, weapon)
    local luck = math.random(100)
    local multi = damageDone / Config.HealthDamage

    return luck < (Config.HealthDamage * multi) or (damageDone >= Config.ForceInjury or multi > Config.MaxInjuryChanceMulti or Config.ForceInjuryWeapons[weapon])
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
    if Config.CriticalAreas[bodyPartKey] and armor <= 0 then
       ApplyBleed(1)
    end

    local staggerArea = Config.StaggerAreas[bodyPartKey]
    if not staggerArea then return end
    applyStaggerEffect(ped, staggerArea.armored, staggerArea.minor, armor)
end

---Applies bleed with probability based on armor and location hit. Also applies stagger effect.
---@param ped number
---@param bodyPartKey BodyPartKey body part where player is damaged
---@param armor number
local function applyImmediateMajorEffects(ped, bodyPartKey, armor)
    local criticalArea = Config.CriticalAreas[bodyPartKey]
    if criticalArea then
        if armor > 0 and criticalArea.armored then
            if math.random(100) <= math.ceil(Config.MajorArmoredBleedChance) then
                ApplyBleed(1)
            end
        else
            ApplyBleed(1)
        end
    else
        if armor > 0 then
            if math.random(100) < (Config.MajorArmoredBleedChance) then
                ApplyBleed(1)
            end
        elseif math.random(100) < (Config.MajorArmoredBleedChance * 2) then
            ApplyBleed(1)
        end
    end

    local staggerArea = Config.StaggerAreas[bodyPartKey]
    if not staggerArea then return end
    applyStaggerEffect(ped, staggerArea.armored, staggerArea.major, armor)
end

---Apply bleeds and staggers effects on damage taken, taking into account armor.
---@param ped number
---@param bodyPartKey BodyPartKey
---@param weapon number
---@param damageDone number
local function applyImmediateEffects(ped, bodyPartKey, weapon, damageDone)
    local armor = GetPedArmour(ped)
    if Config.MinorInjurWeapons[weapon] and damageDone < Config.DamageMinorToMajor then
        applyImmediateMinorEffects(ped, bodyPartKey, armor)
    elseif Config.MajorInjurWeapons[weapon] or (Config.MinorInjurWeapons[weapon] and damageDone >= Config.DamageMinorToMajor) then
        applyImmediateMajorEffects(ped, bodyPartKey, armor)
    end
end

---Apply bleeds, injure the body part hit, make ped limp/stagger
---@param ped number
---@param boneId integer
---@param weapon number
---@param damageDone number
local function checkDamage(ped, boneId, weapon, damageDone)
    if not weapon then return end

    local bodyPartKey = Config.Bones[boneId]
    if not bodyPartKey or IsDead or InLaststand then return end

    applyImmediateEffects(ped, bodyPartKey, weapon, damageDone)
    injureBodyPart(bodyPartKey)

    lib.callback('qbx_medical:server:syncInjuries', false, false,{
        injuries = Injuries,
        isBleeding = BleedLevel
    })

    MakePedLimp()
end

---Apply damage to health and armor based off of damage done and weapon used.
---@param ped number
---@param damageDone number
---@param isArmorDamaged boolean
local function applyDamage(ped, damageDone, isArmorDamaged)
    local hit, bone = GetPedLastDamageBone(ped)
    local bodypart = Config.Bones[bone]
    local weapon = getDamagingWeapon(ped)

    if not hit or bodypart == 'NONE' or not weapon then return end

    if damageDone >= Config.HealthDamage then
        local isBodyHitOrWeakWeapon = checkBodyHitOrWeakWeapon(isArmorDamaged, bodypart, weapon)
        if isBodyHitOrWeakWeapon and isArmorDamaged then
            lib.callback('qbx_medical:server:setArmor', false, false, GetPedArmour(ped))
        elseif not isBodyHitOrWeakWeapon and isDamagingEvent(damageDone, weapon) then
            checkDamage(ped, bone, weapon, damageDone)
        end
    elseif Config.AlwaysBleedChanceWeapons[weapon]
        and math.random(100) < Config.AlwaysBleedChance
        and not checkBodyHitOrWeakWeapon(isArmorDamaged, bodypart, weapon) then
        ApplyBleed(1)
    end
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
    local ped = cache.ped
    local health = GetEntityHealth(ped)
    local armor = GetPedArmour(ped)

    initHealthAndArmorIfNotSet(health, armor)

    local isArmorDamaged = (playerArmor ~= armor and armor < (playerArmor - Config.ArmorDamage) and armor > 0) -- Players armor was damaged
    local isHealthDamaged = (Hp ~= health) -- Players health was damaged

    if isArmorDamaged or isHealthDamaged then
        local damageDone = (Hp - health)
        applyDamage(ped, damageDone, isArmorDamaged)
        findDamageCause()
        ClearEntityLastDamageEntity(ped)
    end

    Hp = health
    playerArmor = armor
end

exports('checkForDamageDeprecated', checkForDamage)