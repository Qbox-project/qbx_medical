---@class BodyPart
---@field label string
---@field causeLimp boolean
---@field isDamaged boolean
---@field severity integer

---@alias BodyParts table<Bone, BodyPart>
---@type BodyParts
BodyParts = {
    ['HEAD'] = { label = Lang:t('body.head'), causeLimp = false, isDamaged = false, severity = 0 },
    ['NECK'] = { label = Lang:t('body.neck'), causeLimp = false, isDamaged = false, severity = 0 },
    ['SPINE'] = { label = Lang:t('body.spine'), causeLimp = true, isDamaged = false, severity = 0 },
    ['UPPER_BODY'] = { label = Lang:t('body.upper_body'), causeLimp = false, isDamaged = false, severity = 0 },
    ['LOWER_BODY'] = { label = Lang:t('body.lower_body'), causeLimp = true, isDamaged = false, severity = 0 },
    ['LARM'] = { label = Lang:t('body.left_arm'), causeLimp = false, isDamaged = false, severity = 0 },
    ['LHAND'] = { label = Lang:t('body.left_hand'), causeLimp = false, isDamaged = false, severity = 0 },
    ['LFINGER'] = { label = Lang:t('body.left_fingers'), causeLimp = false, isDamaged = false, severity = 0 },
    ['LLEG'] = { label = Lang:t('body.left_leg'), causeLimp = true, isDamaged = false, severity = 0 },
    ['LFOOT'] = { label = Lang:t('body.left_foot'), causeLimp = true, isDamaged = false, severity = 0 },
    ['RARM'] = { label = Lang:t('body.right_arm'), causeLimp = false, isDamaged = false, severity = 0 },
    ['RHAND'] = { label = Lang:t('body.right_hand'), causeLimp = false, isDamaged = false, severity = 0 },
    ['RFINGER'] = { label = Lang:t('body.right_fingers'), causeLimp = false, isDamaged = false, severity = 0 },
    ['RLEG'] = { label = Lang:t('body.right_leg'), causeLimp = true, isDamaged = false, severity = 0 },
    ['RFOOT'] = { label = Lang:t('body.right_foot'), causeLimp = true, isDamaged = false, severity = 0 },
}

--- temporary export to aid in qbx-ambulancejob transition
exports('getBodyPartsDeprecated', function()
    return BodyParts
end)

RegisterNetEvent('hospital:client:adminHeal', function()
    if GetInvokingResource() then return end
    SetEntityHealth(cache.ped, 200)
    TriggerServerEvent("hospital:server:resetHungerThirst")
end)

RegisterNetEvent('hospital:client:KillPlayer', function()
    if GetInvokingResource() then return end
    SetEntityHealth(cache.ped, 0)
end)

---@return boolean isInjuryCausingLimp if injury causes a limp and is damaged.
local function isInjuryCausingLimp()
    for _, v in pairs(BodyParts) do
        if v.causeLimp and v.isDamaged then
            return true
        end
    end
    return false
end

---sets ped animation to limping and prevents running.
function MakePedLimp()
    if not isInjuryCausingLimp() then return end
    lib.requestAnimSet("move_m@injured")
    SetPedMovementClipset(cache.ped, "move_m@injured", 1)
    SetPlayerSprint(cache.playerId, false)
end

--- TODO: this export should not check any conditions, but force the ped to limp instead.
exports('makePedLimp', MakePedLimp)

function ResetMinorInjuries()
    for _, v in pairs(BodyParts) do
        if v.isDamaged and v.severity <= 2 then
            v.isDamaged = false
            v.severity = 0
        end
    end
end

exports('resetMinorInjuries', ResetMinorInjuries)

function ResetAllInjuries()
    for _, v in pairs(BodyParts) do
        v.isDamaged = false
        v.severity = 0
    end
end

exports('resetAllInjuries', ResetAllInjuries)

exports('damageBodyPart', function(bone, severity)
    BodyParts[bone].isDamaged = true
    BodyParts[bone].severity = severity
end)