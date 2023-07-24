---@type number[] weapon hashes
CurrentDamageList = {}

---@class Injury
---@field part Bone body part
---@field severity integer higher numbers are worse injuries
---@field label string

---@type Injury[]
Injuries = {}

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

BleedLevel = 0
BleedTickTimer, AdvanceBleedTimer = 0, 0
FadeOutTimer, BlackoutTimer = 0, 0

---@type number
Hp = nil

IsDead = false

exports('getBleedLevel', function()
    return BleedLevel
end)

exports('setBleedLevel', function(bleedLevel)
    BleedLevel = bleedLevel
end)

exports('getBleedTickTimerDeprecated', function()
    return BleedTickTimer
end)

exports('setBleedTickTimerDeprecated', function(timer)
    BleedTickTimer = timer
end)

exports('getAdvanceBleedTimerDeprecated', function()
    return AdvanceBleedTimer
end)

exports('setAdvanceBleedTimerDeprecated', function(timer)
    AdvanceBleedTimer = timer
end)

exports('getInjuries', function()
    return Injuries
end)

exports('getHp', function()
    return Hp
end)

exports('setHp', function(hp)
    Hp = hp
end)

exports('isDead', function()
    return IsDead
end)

exports('kill', function()
    IsDead = true
end)

exports('setIsDeadDeprecated', function(isDead)
    IsDead = isDead
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

    for k, v in pairs(Injuries) do
        if v.severity <= 2 then
            v.severity = 0
            table.remove(Injuries, k)
        end
    end

    if BleedLevel <= 2 then
        BleedLevel = 0
        BleedTickTimer = 0
        AdvanceBleedTimer = 0
        FadeOutTimer = 0
        BlackoutTimer = 0
    end

    TriggerServerEvent('hospital:server:SyncInjuries', {
        limbs = BodyParts,
        isBleeding = BleedLevel
    })

    SendBleedAlert()
end

exports('resetMinorInjuries', ResetMinorInjuries)

function ResetAllInjuries()
    for _, v in pairs(BodyParts) do
        v.isDamaged = false
        v.severity = 0
    end

    Injuries = {}

    BleedLevel = 0
    BleedTickTimer = 0
    AdvanceBleedTimer = 0
    FadeOutTimer = 0
    BlackoutTimer = 0

    TriggerServerEvent('hospital:server:SyncInjuries', {
        limbs = BodyParts,
        isBleeding = BleedLevel
    })

    CurrentDamageList = {}
    TriggerServerEvent('hospital:server:SetWeaponDamage', CurrentDamageList)

    SendBleedAlert()
end

exports('resetAllInjuries', ResetAllInjuries)

function DamageBodyPart(bone, severity)
    BodyParts[bone].isDamaged = true
    BodyParts[bone].severity = severity
end

---creates an injury on body part with random severity between 1 and maxSeverity.
---@param bodyPart BodyPart
---@param bone Bone
---@param maxSeverity number
function CreateInjury(bodyPart, bone, maxSeverity)
    if bodyPart.isDamaged then return end

    local severity = math.random(1, maxSeverity)
    DamageBodyPart(bone, severity)
    Injuries[#Injuries + 1] = {
        part = bone,
        label = bodyPart.label,
        severity = severity,
    }
end

exports('createInjury', function(bodyPart, bone, maxSeverity)
    CreateInjury(bodyPart, bone, maxSeverity)
end)

---notify the player of bleeding to their body.
function SendBleedAlert()
    if IsDead or BleedLevel == 0 then return end
    lib.notify({ title = Lang:t('info.bleed_alert', {bleedstate = Config.BleedingStates[BleedLevel]}), type = 'inform' })
end

exports('sendBleedAlert', SendBleedAlert)

---adds a bleed to the player and alerts them. Total bleed level maxes at 4.
---@param level 1|2|3|4 speed of the bleed
function ApplyBleed(level)
    if BleedLevel == 4 then return end
    BleedLevel += level
    BleedLevel = (BleedLevel >= 4) and 4 or BleedLevel
    SendBleedAlert()
end

---Creates random injuries on the player
RegisterNetEvent('hospital:client:SetPain', function()
    if GetInvokingResource() then return end
    ApplyBleed(math.random(1, 4))
 
    local bone = Config.Bones[24816]
    CreateInjury(BodyParts[bone], bone, 4)

    bone = Config.Bones[40269]
    CreateInjury(BodyParts[bone], bone, 4)

    TriggerServerEvent('hospital:server:SyncInjuries', {
        limbs = BodyParts,
        isBleeding = BleedLevel
    })
end)

exports('getBleedStateLabelDeprecated', function(level)
    return Config.BleedingStates[level]
end)