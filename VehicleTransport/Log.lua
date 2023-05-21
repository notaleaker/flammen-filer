
-- enable/disable different levels off logging to console
local LEVEL = {
	INFO	= true,
	WARNING	= true,
	ERROR	= true,
	DEBUG	= false
}

function Log(text, ...)
	if (LEVEL.INFO) then
		print(string.format(string.format("^5[INFO] %s^0", text), ...))
	end
end

function LogWarning(text, ...)
	if (LEVEL.WARNING) then
		print(string.format(string.format("^3[WARNING] %s^0", text), ...))
	end
end

function LogError(text, ...)
	if (LEVEL.ERROR) then
		print(string.format(string.format("^1[ERROR] %s^0", text), ...))
	end
end

function LogDebug(text, ...)
	if (LEVEL.DEBUG) then
		print(string.format(string.format("^0[DEBUG] %s^0", text), ...))
	end
end

local RES_NAME = GetCurrentResourceName()
if (IsDuplicityVersion()) then
	RegisterCommand(RES_NAME .. ":log", function(source, args, raw)
		if (#args <= 0 or type(args[1]) ~= "string") then
			LogError("Add a valid log level as an argument. [ INFO | WARNING | ERROR | DEBUG ]")
			return
		end

		local lvl = args[1]:upper()
		if (LEVEL[lvl] == nil) then
			LogError("Log level \"%s\" does not exist.", lvl)
			return
		end

		LEVEL[lvl] = not LEVEL[lvl]

		Log("Log level \"%s\" toggled to \"%s\"", lvl, LEVEL[lvl])

		TriggerClientEvent(RES_NAME .. ":log", -1, lvl, LEVEL[lvl])
	end, true)
else
	RegisterNetEvent(RES_NAME .. ":log", function(lvl, value)
		LEVEL[lvl] = value

		Log("Log level \"%s\" toggled to \"%s\"", lvl, LEVEL[lvl])
	end)
end
