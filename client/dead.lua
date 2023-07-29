local function playDeadAnimation()
    local ped = cache.ped
    local deadAnimDict = "dead"
    local deadAnim = "dead_a"
    local deadVehAnimDict = "veh@low@front_ps@idle_duck"
    local deadVehAnim = "sit"

    if cache.vehicle then
        if not IsEntityPlayingAnim(ped, deadVehAnimDict, deadVehAnim, 3) then
            lib.requestAnimDict(deadVehAnimDict)
            TaskPlayAnim(ped, deadVehAnimDict, deadVehAnim, 1.0, 1.0, -1, 1, 0, false, false, false)
        end
    elseif not IsEntityPlayingAnim(ped, deadAnimDict, deadAnim, 3) then
        lib.requestAnimDict(deadAnimDict)
        TaskPlayAnim(ped, deadAnimDict, deadAnim, 1.0, 1.0, -1, 1, 0, false, false, false)
    end
end

exports('playDeadAnimation', playDeadAnimation)

---put player in death animation and make invincible
function OnDeath()
    if IsDead then return end
    IsDead = true
    TriggerServerEvent('qbx-medical:server:playerDied')
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "demo", 0.1)
    local player = cache.ped

    WaitForPlayerToStopMoving()

    ResurrectPlayer()
    playDeadAnimation()
    SetEntityInvincible(player, true)
    SetEntityHealth(player, GetEntityMaxHealth(player))
end

exports('killPlayer', OnDeath)

local function respawn()
    local success = lib.callback.await('qbx-medical:server:respawn')
    if not success then return end
    if exports["qb-policejob"]:IsHandcuffed() then
        TriggerEvent("police:client:GetCuffed", -1)
    end
    TriggerEvent("police:client:DeEscort")
end

---Allow player to respawn
function AllowRespawn(isInHospitalBed)
    RespawnHoldTime = 5
    while IsDead do
        Wait(1000)
        DeathTime -= 1
        if DeathTime <= 0 then
            if IsControlPressed(0, 38) and RespawnHoldTime <= 1 and not isInHospitalBed then
                respawn()
            end
            if IsControlPressed(0, 38) then
                RespawnHoldTime -= 1
            end
            if IsControlReleased(0, 38) then
                RespawnHoldTime = 5
            end
            if RespawnHoldTime <= 1 then
                RespawnHoldTime = 0
            end
        end
    end
end

exports('allowRespawn', AllowRespawn)