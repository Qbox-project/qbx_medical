---Increases severity of an injury
---@param bodyPart BodyPart
---@param bone Bone
local function upgradeInjury(bodyPart, bone)
    if bodyPart.severity >= 4 then return end

    bodyPart.severity += 1
    DamageBodyPart(bone, bodyPart.severity)
    for _, injury in pairs(Injuries) do
        if injury.part == bone then
            injury.severity = bodyPart.severity
        end
    end
end

---create/upgrade injury at bone.
---@param bone Bone
local function injureBodyPart(bone)
    local bodyPart = BodyParts[bone]
    if not bodyPart.isDamaged then
        CreateInjury(bodyPart, bone, 3)
    else
        upgradeInjury(bodyPart, bone)
    end
end

exports('injureBodyPart', injureBodyPart)

---@param array any[]
---@param value any
---@return boolean found
local function isInArray(array, value)
    if not array then return false end

    for i = 1, #array do
        if array[i] == value then
            return true
        end
    end

    return false
end

---Adds weapon hashes that damaged the ped that aren't already in the CurrentDamagedList and syncs to the server.
local function findDamageCause()
    local detected = false
    for hash, weapon in pairs(QBCore.Shared.Weapons) do
        if HasPedBeenDamagedByWeapon(cache.ped, hash, 0) and not isInArray(CurrentDamageList, hash) then
            detected = true
            TriggerEvent('chat:addMessage', {
                color = { 255, 0, 0 },
                multiline = false,
                args = { Lang:t('info.status'), weapon.damagereason }
            })
            CurrentDamageList[#CurrentDamageList + 1] = hash
        end
    end
    if detected then
        TriggerServerEvent("hospital:server:SetWeaponDamage", CurrentDamageList)
    end
end

exports('findDamageCauseDeprecated', findDamageCause)