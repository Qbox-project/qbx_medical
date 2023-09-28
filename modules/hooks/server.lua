-- Modified from original source https://github.com/overextended/ox_inventory/blob/main/modules/hooks/server.lua
-- Copyright (C) 2021  Linden <https://github.com/thelindat>, Dunak <https://github.com/dunak-debug>, Luke <https://github.com/LukeWasTakenn>

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

if not lib then return end

local eventHooks = {}
local microtime = os.microtime()

local function triggerEventHooks(event, payload)
    local hooks = eventHooks[event]
    if not hooks then return true end

    for i = 1, #hooks do
        local hook = hooks[i]

        if hook.print then
            lib.print.info(('Triggering event hook "%s:%s:%s".'):format(hook.resource, event, i))
        end

        local start = microtime()
        local _, response = pcall(hooks[i], payload)
        local executionTime = microtime() - start

        if executionTime >= 100000 then
            warn(('Execution of event hook "%s:%s:%s" took %.2fms.'):format(hook.resource, event, i, executionTime / 1e3))
        end

        if response == false then
            return false
        end
    end
end

local hookId = 0

exports('registerHook', function(event, cb, options)
    if not eventHooks[event] then
        eventHooks[event] = {}
    end

	local mt = getmetatable(cb)
	mt.__index = nil
	mt.__newindex = nil
    cb.resource = GetInvokingResource()
	hookId += 1
	cb.hookId = hookId

	if options then
		for k, v in pairs(options) do
			cb[k] = v
		end
	end

    eventHooks[event][#eventHooks[event] + 1] = cb
	return hookId
end)

local function removeResourceHooks(resource, id)
    for _, hooks in pairs(eventHooks) do
        for i = #hooks, 1, -1 do
			local hook = hooks[i]

            if hook.resource == resource and (not id or hook.hookId == id) then
                table.remove(hooks, i)
            end
        end
    end
end

AddEventHandler('onResourceStop', removeResourceHooks)

exports('removeHooks', function(id)
	removeResourceHooks(GetInvokingResource() or cache.resource, id)
end)

return triggerEventHooks