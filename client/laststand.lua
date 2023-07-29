---blocks until ped is no longer moving
---@param ped number
function WaitForPlayerToStopMoving()
    local ped = cache.ped
    while GetEntitySpeed(ped) > 0.5 or IsPedRagdoll(ped) do Wait(10) end
end

exports('waitForPlayerToStopMovingDeprecated', WaitForPlayerToStopMoving)

--- low level GTA resurrection
function ResurrectPlayer()
    local ped = cache.ped
    local pos = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local veh = cache.vehicle
    local seat = cache.seat

    NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z + 0.5, heading, true, false)
    if veh then
        SetPedIntoVehicle(ped, veh, seat)
    end
end

exports('resurrectPlayerDeprecated', ResurrectPlayer)

---remove last stand mode from player.
function EndLastStand()
    local ped = cache.ped
    TaskPlayAnim(ped, LastStandDict, "exit", 1.0, 8.0, -1, 1, -1, false, false, false)
    InLaststand = false
    LaststandTime = 0
    TriggerServerEvent("hospital:server:SetLaststandStatus", false)
end

exports('endLastStandDeprecated', EndLastStand)