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

    WaitForPedToStopMoving(player)

    ResurrectPlayer(player)
    playDeadAnimation()
    SetEntityInvincible(player, true)
    SetEntityHealth(player, GetEntityMaxHealth(player))
end

exports('killPlayer', OnDeath)