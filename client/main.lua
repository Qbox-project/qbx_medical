RegisterNetEvent('hospital:client:adminHeal', function()
    if GetInvokingResource() then return end
    SetEntityHealth(cache.ped, 200)
    TriggerServerEvent("hospital:server:resetHungerThirst")
end)

RegisterNetEvent('hospital:client:KillPlayer', function()
    if GetInvokingResource() then return end
    SetEntityHealth(cache.ped, 0)
end)