---@type number[] weapon hashes
CurrentDamageList = {}

---@class Injury
---@field severity integer higher numbers are worse injuries

NumInjuries = 0

---@class BodyPart
---@field label string
---@field causeLimp boolean
---@field isDamaged boolean
---@field severity integer
---@field injuries Injury[]

---@alias BodyPartKey string

---@alias BodyParts table<BodyPartKey, BodyPart>
---@type BodyParts
BodyParts = {
    HEAD = { label = Lang:t('body.head'), causeLimp = false, isDamaged = false, severity = 0, injuries = {} },
    NECK = { label = Lang:t('body.neck'), causeLimp = false, isDamaged = false, severity = 0, injuries = {} },
    SPINE = { label = Lang:t('body.spine'), causeLimp = true, isDamaged = false, severity = 0, injuries = {} },
    UPPER_BODY = { label = Lang:t('body.upper_body'), causeLimp = false, isDamaged = false, severity = 0, injuries = {} },
    LOWER_BODY = { label = Lang:t('body.lower_body'), causeLimp = true, isDamaged = false, severity = 0, injuries = {} },
    LARM = { label = Lang:t('body.left_arm'), causeLimp = false, isDamaged = false, severity = 0, injuries = {} },
    LHAND = { label = Lang:t('body.left_hand'), causeLimp = false, isDamaged = false, severity = 0, injuries = {} },
    LFINGER = { label = Lang:t('body.left_fingers'), causeLimp = false, isDamaged = false, severity = 0, injuries = {} },
    LLEG = { label = Lang:t('body.left_leg'), causeLimp = true, isDamaged = false, severity = 0, injuries = {} },
    LFOOT = { label = Lang:t('body.left_foot'), causeLimp = true, isDamaged = false, severity = 0, injuries = {} },
    RARM = { label = Lang:t('body.right_arm'), causeLimp = false, isDamaged = false, severity = 0, injuries = {} },
    RHAND = { label = Lang:t('body.right_hand'), causeLimp = false, isDamaged = false, severity = 0, injuries = {} },
    RFINGER = { label = Lang:t('body.right_fingers'), causeLimp = false, isDamaged = false, severity = 0, injuries = {} },
    RLEG = { label = Lang:t('body.right_leg'), causeLimp = true, isDamaged = false, severity = 0, injuries = {} },
    RFOOT = { label = Lang:t('body.right_foot'), causeLimp = true, isDamaged = false, severity = 0, injuries = {} },
}

BleedLevel = 0
BleedTickTimer, AdvanceBleedTimer = 0, 0
FadeOutTimer, BlackoutTimer = 0, 0

---@type number
Hp = nil

IsDead = false
InLaststand = false
DeathTime = 0
LaststandTime = 0
RespawnHoldTime = 5
LastStandDict = "combat@damage@writhe"
LastStandAnim = "writhe_loop"

exports('getBleedLevel', function()
    return BleedLevel
end)

exports('setBleedLevel', function(bleedLevel)
    BleedLevel = bleedLevel
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

exports('setIsDeadDeprecated', function(isDead)
    IsDead = isDead
end)

exports('getLaststand', function()
    return InLaststand
end)

exports('setLaststand', function(inLaststand)
    InLaststand = inLaststand
end)

exports('getDeathTime', function()
    return DeathTime
end)

exports('setDeathTime', function(value)
    DeathTime = value
end)

exports('getLaststandTime', function()
    return LaststandTime
end)

exports('setLaststandTime', function(value)
    LaststandTime = value
end)

exports('getRespawnHoldTimeDeprecated', function()
    return RespawnHoldTime
end)

lib.callback('qbx_medical:client:killPlayer', function()
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

---notify the player of damage to their body.
local function doLimbAlert()
    if IsDead or InLaststand or NumInjuries == 0 then return end

    local limbDamageMsg = ''
    if NumInjuries <= Config.AlertShowInfo then
        local injuriesI = 0
        for _, bodyPart in pairs(BodyParts) do
            for i = 1, #bodyPart.injuries do
                local injury = bodyPart.injuries[i]
                limbDamageMsg = limbDamageMsg .. Lang:t('info.pain_message', { limb = bodyPart.label, severity = Config.woundLevels[injury.severity].label})
                injuriesI += 1
                if injuriesI < NumInjuries then
                    limbDamageMsg = limbDamageMsg .. " | "
                end
            end
        end
    else
        limbDamageMsg = Lang:t('info.many_places')
    end
    exports.qbx_core:Notify(limbDamageMsg, 'error')
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
    for _, bodyPart in pairs(BodyParts) do
        if bodyPart.isDamaged and bodyPart.severity <= 2 then
            bodyPart.isDamaged = false
            bodyPart.severity = 0
        end
        local onlySevereInjuries = {}
        for i = 1, #bodyPart.injuries do
            local injury = bodyPart.injuries[i]
            if injury.severity > 2 then
                onlySevereInjuries[#onlySevereInjuries+1] = injury
            end
        end
        bodyPart.injuries = onlySevereInjuries
    end

    if BleedLevel <= 2 then
        BleedLevel = 0
        BleedTickTimer = 0
        AdvanceBleedTimer = 0
        FadeOutTimer = 0
        BlackoutTimer = 0
    end

    lib.callback('qbx_medical:server:syncInjuries', false, false,{
        limbs = BodyParts,
        isBleeding = BleedLevel
    })

    SendBleedAlert()
    MakePedLimp()
    doLimbAlert()
end

exports('resetMinorInjuries', ResetMinorInjuries)

function ResetAllInjuries()
    for _, v in pairs(BodyParts) do
        v.isDamaged = false
        v.severity = 0
        v.injuries = {}
    end
    
    NumInjuries = 0
    BleedLevel = 0
    BleedTickTimer = 0
    AdvanceBleedTimer = 0
    FadeOutTimer = 0
    BlackoutTimer = 0

    lib.callback('qbx_medical:server:syncInjuries', false, false,{
        limbs = BodyParts,
        isBleeding = BleedLevel
    })

    CurrentDamageList = {}
    lib.callback('qbx_medical:server:SetWeaponWounds', false, false, CurrentDamageList)

    SendBleedAlert()
    MakePedLimp()
    doLimbAlert()
    lib.callback('qbx_medical:server:resetHungerAndThirst')
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
    bodyPart.injuries[bodyPart.injuries + 1] = {
        severity = severity,
    }
    NumInjuries += 1
end

exports('createInjury', function(bodyPart, bone, maxSeverity)
    CreateInjury(bodyPart, bone, maxSeverity)
end)

---notify the player of bleeding to their body.
function SendBleedAlert()
    if IsDead or BleedLevel == 0 then return end
    exports.qbx_core:Notify(Lang:t('info.bleed_alert', {bleedstate = Config.BleedingStates[BleedLevel]}), 'inform')
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

exports('getBleedStateLabelDeprecated', function(level)
    return Config.BleedingStates[level]
end)

---heals player wounds.
---@param type? "full"|any heals all wounds if full otherwise heals only major wounds.
lib.callback.register('qbx_medical:client:heal', function(type)
    if type == "full" then
        ResetAllInjuries()
    else
        ResetMinorInjuries()
    end
    exports.qbx_core:Notify(Lang:t('success.wounds_healed'), 'success')
end)

CreateThread(function()
    while true do
        Wait((1000 * Config.MessageTimer))
        doLimbAlert()
    end
end)

---Convert wounded body part data to a human readable form
---@param damagedBodyParts BodyParts
---@return string[]
local function getPatientStatus(damagedBodyParts)
    local status = {}
    for _, bodyPart in pairs(damagedBodyParts) do
        status[#status + 1] = bodyPart.label .. " (" .. Config.woundLevels[bodyPart.severity].label .. ")"
    end
    return status
end

exports('getPatientStatus', getPatientStatus)

---Revives player, healing all injuries
---Intended to be called from client or server.
RegisterNetEvent('qbx_medical:client:playerRevived', function()
    local ped = cache.ped

    if IsDead or InLaststand then
        local pos = GetEntityCoords(ped, true)
        NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z, GetEntityHeading(ped), true, false)
        IsDead = false
        SetEntityInvincible(ped, false)
        EndLastStand()
    end

    SetEntityMaxHealth(ped, 200)
    SetEntityHealth(ped, 200)
    ClearPedBloodDamage(ped)
    SetPlayerSprint(cache.playerId, true)
    ResetAllInjuries()
    ResetPedMovementClipset(ped, 0.0)
    TriggerServerEvent('hud:server:RelieveStress', 100)
    exports.qbx_core:Notify(Lang:t('info.healthy'), 'inform')
end)
