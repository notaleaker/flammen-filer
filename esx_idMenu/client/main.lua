local onlinePlayers, forceDraw, lookMenu = {}, false, false

Citizen.CreateThread(function()
    TriggerServerEvent("tgiann-showid:add-id")
    while true do
        Citizen.Wait(1)
        local ped = PlayerPedId()
        if IsControlJustPressed(1,11) and not lookMenu then
			local ped = PlayerPedId()
			local players = GetPlayers2()
			lookMenu = true
			TriggerServerEvent("esx_idMenu:showMenu",players)
		elseif IsControlJustPressed(1,48) and lookMenu then
			lookMenu = false
		end
        if lookMenu then
            for k, v in pairs(GetNeareastPlayers()) do
                local x, y, z = table.unpack(v.coords)
                Draw3DText(x, y, z + 1.1, v.playerId, 1.6)
                Draw3DText(x, y, z + 1.20, v.topText, 1.0)
            end
        end
    end
end)

-- Citizen.CreateThread(function()
-- 	Citizen.Wait(1000)
-- 	while true do
-- 		Citizen.Wait(1)
-- 		if IsControlJustPressed(1,11) and not lookMenu then
-- 			local ped = PlayerPedId()
-- 			local players = GetPlayers2()
-- 			lookMenu = true
-- 			TriggerServerEvent("esx_idMenu:showMenu",players)
-- 		elseif IsControlJustPressed(1,48) and lookMenu then
-- 			lookMenu = false
-- 		end
-- 		if lookMenu then
--             for k, v in pairs(GetNeareastPlayers()) do
--                 local x, y, z = table.unpack(v.coords)
--                 Draw3DText(x, y, z + 1.1, v.playerId, 1.6)
--                 Draw3DText(x, y, z + 1.20, v.topText, 1.0)
--             end
-- 		end
-- 	end
-- end)

function GetPlayers2()
    local players = {}
    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, GetPlayerServerId(i))
        end
    end

	table.sort(
		players,
		function(a, b)
			if tonumber(a) ~= nil and tonumber(b) ~= nil then
				return tonumber(a) < tonumber(b)
			else
				return false
			end
		end
	)

    return players
end

RegisterNetEvent('tgiann-showid:client:add-id')
AddEventHandler('tgiann-showid:client:add-id', function(identifier, playerSource)
    if playerSource then
        onlinePlayers[playerSource] = identifier
    else
        onlinePlayers = identifier
    end
end)

RegisterCommand(TGIANN.commandName, function()
    if not forceDraw then
        forceDraw = not forceDraw
        Citizen.Wait(5000)
        forceDraw = false
    end
end)

function Draw3DText(x, y, z, text, newScale)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        local dist = GetDistanceBetweenCoords(GetGameplayCamCoords(), x, y, z, 1)
        local scale = newScale * (1 / dist) * (1 / GetGameplayCamFov()) * 100
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropShadow(0, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextEdge(4, 0, 0, 0, 255)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

RegisterNetEvent("esx_idMenu:showMenu")
AddEventHandler("esx_idMenu:showMenu", function(list)
	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'vis_steam_info',
		{
			title    = "ID Menu",
			align    = 'top-right',
			elements = list
		},
		function(data, menu)
			ESX.ShowNotification("Steamnavn: " .. data.current.name .."\nRockstar: " .. data.current.identifier)
		end,
		function(data, menu)
			menu.close()
			local ped = GetPlayerPed(-1)
			lookMenu = false
		end)
end)

function GetNeareastPlayers()
    local playerPed = PlayerPedId()
    local players_clean = {}
    local playerCoords = GetEntityCoords(playerPed)
    -- if IsPedInAnyVehicle(playerPed, false) then
    --     local playersId = tostring(GetPlayerServerId(PlayerId()))
    --     table.insert(players_clean, {topText = onlinePlayers[playersId], playerId = playersId, coords = playerCoords} )
    -- else
        local players, _ = GetPlayersInArea(playerCoords, TGIANN.drawDistance)
        for i = 1, #players, 1 do
            local playerServerId = GetPlayerServerId(players[i])
            local player = GetPlayerFromServerId(playerServerId)
            local ped = GetPlayerPed(player)
            if IsEntityVisible(ped) then
                for x, identifier in pairs(onlinePlayers) do 
                    if x == tostring(playerServerId) then
                        table.insert(players_clean, {topText = identifier:upper(), playerId = playerServerId, coords = GetEntityCoords(ped)})
                    end
                end
            end
        end
    -- end
   
    return players_clean
end

function GetPlayersInArea(coords, area)
	local players, playersInArea = GetPlayers(), {}
	local coords = vector3(coords.x, coords.y, coords.z)
	for i=1, #players, 1 do
		local target = GetPlayerPed(players[i])
		local targetCoords = GetEntityCoords(target)

		if #(coords - targetCoords) <= area then
			table.insert(playersInArea, players[i])
		end
	end
	return playersInArea
end

function GetPlayers()
    local players = {}
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if DoesEntityExist(ped) then
            table.insert(players, player)
        end
    end
    return players
end