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