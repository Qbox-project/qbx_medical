local isEscorted = false
local vehicleDict = 'veh@low@front_ps@idle_duck'
local vehicleAnim = 'sit'
local LastStandCuffedDict = 'dead'
local LastStandCuffedAnim = 'dead_f'

local function playUnescortedLastStandAnimation()
    if cache.vehicle then
        if not IsEntityPlayingAnim(cache.ped, vehicleDict, vehicleAnim, 3) then
            lib.playAnim(cache.ped, vehicleDict, vehicleAnim, 1.0, 1.0, -1, 1, 0, false, false, false)
        end
    else
        local dict = not QBX.PlayerData.metadata.ishandcuffed and LastStandDict or LastStandCuffedDict
        local anim = not QBX.PlayerData.metadata.ishandcuffed and LastStandAnim or LastStandCuffedAnim
        if not IsEntityPlayingAnim(cache.ped, dict, anim, 3) then
            lib.playAnim(cache.ped, dict, anim, 1.0, 1.0, -1, 1, 0, false, false, false)
        end
    end
end

---@param ped number
local function playEscortedLastStandAnimation(ped)
    if cache.vehicle then
        lib.requestAnimDict(vehicleDict, 5000)
        if IsEntityPlayingAnim(ped, vehicleDict, vehicleAnim, 3) then
            StopAnimTask(ped, vehicleDict, vehicleAnim, 3)
        end
        RemoveAnimDict(vehicleDict)
    else
        local dict = not QBX.PlayerData.metadata.ishandcuffed and LastStandDict or LastStandCuffedDict
        local anim = not QBX.PlayerData.metadata.ishandcuffed and LastStandAnim or LastStandCuffedAnim
        lib.requestAnimDict(dict, 5000)
        if IsEntityPlayingAnim(ped, dict, anim, 3) then
            StopAnimTask(ped, dict, anim, 3)
        end
        RemoveAnimDict(dict)
    end
end

function PlayLastStandAnimation()
    if isEscorted then
        playEscortedLastStandAnimation(cache.ped)
    else
        playUnescortedLastStandAnimation()
    end
end

---@param bool boolean
---TODO: this event name should be changed within qb-policejob to be generic
AddEventHandler('hospital:client:isEscorted', function(bool)
    isEscorted = bool
end)