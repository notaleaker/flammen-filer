Config = {}

--[[
	Enable verbose output on the console
	VerboseClient should be disable in production since it exposed tokens
]]
Config.VerboseClient = false
Config.VerboseServer = false

--[[
	Adjust the delay between when the client deploys the listeners and
	when the server sends the information.
	250 seems like a sweet spot here, but it can be reduced or increased if desired.
]]

Config.ClientDelay = 250

--[[
	Define the message given to users with an invalid token
--]]
Config.KickMessage = "Invalid security token detected."

--[[
	Define a custom function to trigger when a player is kicked
	If Config.CustomAction is false, the player will be dropped
]]
Config.CustomAction = true
Config.CustomActionFunction = function(source, resource)
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.getIdentifier()
	local name = GetPlayerName(source)
	DropPlayer(source, Config.KickMessage)
	PerformHttpRequest("https://discordapp.com/api/webhooks/1005464390277005374/YfK-W-qMIg39ZiZ0L_iWRv0TVmj6AIs3HviiGir38mkdevra-yls4Wb-CpoVslH_5lOO", function(err, text, headers) end, 'POST', json.encode({username = name, content = name .. " ( ".. xPlayer.getName() .. " " .. identifier .. " ) Blev smidt ud pga ugyldig token i ".. resource}), { ['Content-Type'] = 'application/json' })
end
