---@type table<number, boolean> weapon hashes as a set
WeaponsThatDamagedPlayer = {}

NumInjuries = 0

---@type table<BodyPartKey, integer>
Injuries = {}

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
    for bodyPartKey in pairs(Injuries) do
        if Config.BodyParts[bodyPartKey].causeLimp then
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
        for bodyPartKey, severity in pairs(Injuries) do
            local bodyPart = Config.BodyParts[bodyPartKey]
            limbDamageMsg = limbDamageMsg .. Lang:t('info.pain_message', { limb = bodyPart.label, severity = Config.woundLevels[severity].label})
            injuriesI += 1
            if injuriesI < NumInjuries then
                limbDamageMsg = limbDamageMsg .. " | "
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

local function resetMinorInjuries()
    for bodyPartKey, severity in pairs(Injuries) do
        if severity <= 2 then
            Injuries[bodyPartKey] = nil
        end
    end

    if BleedLevel <= 2 then
        BleedLevel = 0
        BleedTickTimer = 0
        AdvanceBleedTimer = 0
        FadeOutTimer = 0
        BlackoutTimer = 0
    end

    lib.callback('qbx_medical:server:syncInjuries', false, false,{
        injuries = Injuries,
        isBleeding = BleedLevel
    })

    SendBleedAlert()
    MakePedLimp()
    doLimbAlert()
end

local function resetAllInjuries()
    Injuries = {}
    NumInjuries = 0
    BleedLevel = 0
    BleedTickTimer = 0
    AdvanceBleedTimer = 0
    FadeOutTimer = 0
    BlackoutTimer = 0

    lib.callback('qbx_medical:server:syncInjuries', false, false,{
        injuries = Injuries,
        isBleeding = BleedLevel
    })

    WeaponsThatDamagedPlayer = {}

    SendBleedAlert()
    MakePedLimp()
    doLimbAlert()
    lib.callback('qbx_medical:server:resetHungerAndThirst')
end

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
        resetAllInjuries()
    else
        resetMinorInjuries()
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
---@return string[]
local function getPatientStatus()
    local status = {}
    for bodyPartKey, severity in pairs(Injuries) do
        local bodyPart = Config.BodyParts[bodyPartKey]
        status[#status + 1] = bodyPart.label .. " (" .. Config.woundLevels[severity].label .. ")"
    end
    return status
end

exports('getPatientStatus', getPatientStatus)

---Revives player, healing all injuries
RegisterNetEvent('qbx_medical:client:playerRevived', function()
    if source then return end
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
    resetAllInjuries()
    ResetPedMovementClipset(ped, 0.0)
    TriggerServerEvent('hud:server:RelieveStress', 100)
    exports.qbx_core:Notify(Lang:t('info.healthy'), 'inform')
end)
