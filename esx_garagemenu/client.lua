ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(100)
	end
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

local strlen

-- Function for 3D text:
function DrawText3Ds(x,y,z, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
	if onScreen then

		SetTextScale(0.32, 0.32)
		SetTextFont(4)
		SetTextColour(255, 255, 255, 255)
		SetTextCentre(true)
		BeginTextCommandDisplayText("STRING")
		AddTextComponentSubstringPlayerName(text)
		EndTextCommandDisplayText(_x, _y)
		DrawRect(_x, _y + 0.01125, strlen, 0.03, 0, 0, 0, 80)
	end
end

local insideMarker = false

-- Core Thread Function:
CreateThread(function()
	strlen = 0.015 + Config.ExtraDraw3DText:len() / 500

	while true do
		local Sleep = 500

		if (ESX.PlayerData.job and (ESX.PlayerData.job.name == Config.PoliceDatabaseName or ESX.PlayerData.job.name == Config.DocDatabaseName)) then
			if insideMarker == false then
				local PedID = PlayerPedId()
				if IsPedInAnyVehicle(PedID, true) then
					Sleep = 100
					local coords = GetEntityCoords(PedID)
					for i = 1, #Config.ExtraZones do
						local distance = #(coords - Config.ExtraZones[i])

						if distance < 10.0 then
							Sleep = 0
							DrawMarker(Config.PoliceExtraMarker, Config.ExtraZones[i].x, Config.ExtraZones[i].y, Config.ExtraZones[i].z - 0.97, 0.0, 0.0, 0.0, 0.0, 0, 0.0, Config.PoliceExtraMarkerScale.x, Config.PoliceExtraMarkerScale.y, Config.PoliceExtraMarkerScale.z, Config.PoliceExtraMarkerColor.r,Config.PoliceExtraMarkerColor.g,Config.PoliceExtraMarkerColor.b,Config.PoliceExtraMarkerColor.a, false, true, 2, true, nil, nil, false)

							if distance < 2.5 then
								DrawText3Ds(Config.ExtraZones[i].x, Config.ExtraZones[i].y, Config.ExtraZones[i].z, Config.ExtraDraw3DText)
								if IsControlJustPressed(0, Config.KeyToOpenExtraGarage) then
									OpenMainMenu()
									insideMarker = true
									Wait(500)
								end
							end
						end
					end
				end
			end
		end

		Wait(Sleep)
	end
end)

-- Police Extra Menu:
function OpenExtraMenu()
	local elements = {}
	local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
	for id=0, 12 do
		if DoesExtraExist(vehicle, id) then
			local state = IsVehicleExtraTurnedOn(vehicle, id)

			if state then
				elements[#elements + 1] = {
					label = "Extra: "..id.." | "..('<span style="color:green;">%s</span>'):format("On"),
					value = id,
					state = not state
				}
			else
				elements[#elements + 1] = {
					label = "Extra: "..id.." | "..('<span style="color:red;">%s</span>'):format("Off"),
					value = id,
					state = not state
				}
			end
		end
	end
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'extra_actions', {
		title    = Config.TitlePoliceExtra,
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		SetVehicleExtra(vehicle, data.current.value, not data.current.state)
		local newData = data.current
		if data.current.state then
			newData.label = "Extra: "..data.current.value.." | "..('<span style="color:green;">%s</span>'):format("On")
		else
			newData.label = "Extra: "..data.current.value.." | "..('<span style="color:red;">%s</span>'):format("Off")
		end
		newData.state = not data.current.state

		menu.update({value = data.current.value}, newData)
		menu.refresh()
	end, function(data, menu)
		menu.close()
	end)
end

-- Police Livery Menu:
function OpenLiveryMenu()
	local elements = {}

	local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

	SetVehicleModKit(vehicle, 0)

	local liveryCount = GetVehicleLiveryCount(vehicle)

	if liveryCount > 0 then
		local CurrentLivery = GetVehicleLivery(vehicle)

		for i = 0, liveryCount - 1 do
			local state = CurrentLivery == i
			local text

			if state then
				text = "Livery: " .. (i + 1) .. " | " .. ('<span style="color:green;">%s</span>'):format("On")
			else
				text = "Livery: " .. (i + 1) .. " | " .. ('<span style="color:red;">%s</span>'):format("Off")
			end

			elements[#elements + 1] = {
				label = text,
				value = i,
				state = state
			}
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'livery_menu', {
			title    = Config.TitlePoliceLivery,
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			SetVehicleLivery(vehicle, data.current.value)

			SetVehicleDirtLevel(vehicle, 0.00)

			local newData = data.current

			newData.label = "Livery: " .. (data.current.value + 1) .. " | " .. ('<span style="color:green;">%s</span>'):format("On")

			newData.state = true

			for i = 1, #menu.data.elements do
				if menu.data.elements[i].state then
					menu.data.elements[i].state = false
					menu.data.elements[i].label = "Livery: " .. (menu.data.elements[i].value + 1) .. " | " .. ('<span style="color:red;">%s</span>'):format("Off")
					menu.update({value = menu.data.elements[i].value}, menu.data.elements[i])
				end
			end

			menu.update({value = data.current.value}, newData)

			menu.refresh()

			--menu.close()
		end, function(data, menu)
			menu.close()
		end)
	else
		local CurrentMod = GetVehicleMod(vehicle, 48)
		local NumMods = GetNumVehicleMods(vehicle, 48)
		if NumMods > 0 then
			for i = -1, NumMods - 1 do
				local state = CurrentMod == i
				local text

				if state then
					text = ("Livery: " .. (i + 1)):gsub('Livery: 0', 'Ingen livery') .. " | " .. ('<span style="color:green;">%s</span>'):format("On")
				else
					text = ("Livery: " .. (i + 1)):gsub('Livery: 0', 'Ingen livery') .. " | " .. ('<span style="color:red;">%s</span>'):format("Off")
				end

				elements[#elements + 1] = {
					label = text,
					value = i,
					state = state
				}
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'livery_menu', {
			title    = Config.TitlePoliceLivery,
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			SetVehicleMod(vehicle, 48, data.current.value, false)

			SetVehicleDirtLevel(vehicle, 0.00)

			local newData = data.current

			newData.label = ("Livery: " .. (data.current.value + 1)):gsub('Livery: 0', 'Ingen livery') .. " | " .. ('<span style="color:green;">%s</span>'):format("On")

			newData.state = true

			for i = 1, #menu.data.elements do
				if menu.data.elements[i].state then
					menu.data.elements[i].state = false
					menu.data.elements[i].label = ("Livery: " .. (menu.data.elements[i].value + 1)):gsub('Livery: 0', 'Ingen livery') .. " | " .. ('<span style="color:red;">%s</span>'):format("Off")
					menu.update({value = menu.data.elements[i].value}, menu.data.elements[i])
				end
			end

			menu.update({value = data.current.value}, newData)

			menu.refresh()

			--menu.close()
		end, function(data, menu)
			menu.close()
		end)
	end
end

-- Police Extra Main Menu:
function OpenMainMenu()
	local elements = {
		{label = Config.LabelPrimaryCol,value = 'primary'},
		{label = Config.LabelSecondaryCol,value = 'secondary'},
		{label = Config.LabelExtra,value = 'extra'},
		{label = Config.LabelLivery,value = 'livery'},
	}
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'color_menu', {
		title    = Config.TitlePoliceExtra,
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'extra' then
			OpenExtraMenu()
		elseif data.current.value == 'livery' then
			OpenLiveryMenu()
		elseif data.current.value == 'primary' then
			OpenMainColorMenu('primary')
		elseif data.current.value == 'secondary' then
			OpenMainColorMenu('secondary')
		end
	end, function(data, menu)
		menu.close()
		insideMarker = false
	end)
end

-- Police Color Main Menu:
function OpenMainColorMenu(colortype)
	local elements = {}
	for k,v in pairs(Config.Colors) do
		table.insert(elements, {
			label = v.label,
			value = v.value
		})
	end
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'main_color_menu', {
		title    = Config.TitleColorType,
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		OpenColorMenu(data.current.type, data.current.value, colortype)
	end, function(data, menu)
		menu.close()
	end)
end

-- Police Color Menu:
function OpenColorMenu(type, value, colortype)
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'extra_actions', {
		title    = Config.TitleValues,
		align    = 'top-left',
		elements = GetColors(value)
	}, function(data, menu)
		local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
		local pr,sec = GetVehicleColours(vehicle)
		if colortype == 'primary' then
			SetVehicleColours(vehicle, data.current.index, sec)
		elseif colortype == 'secondary' then
			SetVehicleColours(vehicle, pr, data.current.index)
		end
		SetVehicleDirtLevel(vehicle, 0.00)

	end, function(data, menu)
		menu.close()
	end)
end