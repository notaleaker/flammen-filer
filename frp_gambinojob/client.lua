local CurrentActionData = {}
local HasAlreadyEnteredMarker = false
local LastStation, LastPart, LastPartNum, CurrentAction, CurrentActionMsg
local PlayerData              = {}

--#########################################
--#		    	    ESX          		  #
--#########################################
ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)
AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true
end)

AddEventHandler('playerSpawned', function(spawn)
	isDead = false
end)


--#########################################
--#		    	    FUNCTIONS         	  #
--#########################################
function GambinoKoretojer()
	local playerPed = PlayerPedId()
	FreezeEntityPosition(playerPed, true)

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'koretojer', {
		title    = Config.VabenhandlerNavn..' - Køretøjer',
		align    = 'left',
		elements = {
			{label = '<strong>KØRETØJER</strong>',  value = nil},
			{label = 'Baller',  value = 'baller'},
			{label = 'XLS',  value = 'xls'},
			{label = 'Schafter',  value = 'schafter'},
			{label = 'Deity',  value = 'deity'},
			{label = 'Jubilee',  value = 'jubilee'},
			{label = 'cog552',  value = 'cog552'},
			{label = 'Speedo Varevogn',  value = 'speedo'},
			{label = nil,  value = nil},
			{label = '<strong>PARKER KØRETØJ</strong>',  value = nil},
			{label = 'Parker dit køretøj',  value = 'parker'},
	}}, function(data, menu)

		if data.current.value == 'baller' then
			FreezeEntityPosition(playerPed, false)
			menu.close()
			ESX.Game.SpawnVehicle('baller6', vector3(877.0948, -3246.118, -98.28624), 270.636, function(vehicle)
				TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
				SetVehicleNumberPlateText(vehicle, Config.VabenhandlerNavn)
			end)
		elseif data.current.value == 'xls' then
			FreezeEntityPosition(playerPed, false)
			menu.close()
			ESX.Game.SpawnVehicle('xls2', vector3(877.0948, -3246.118, -98.28624), 270.636, function(vehicle)
				TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
				SetVehicleNumberPlateText(vehicle, Config.VabenhandlerNavn)
			end)
		elseif data.current.value == 'deity' then
			FreezeEntityPosition(playerPed, false)
			menu.close()
			ESX.Game.SpawnVehicle('deity', vector3(877.0948, -3246.118, -98.28624), 270.636, function(vehicle)
				TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
				SetVehicleNumberPlateText(vehicle, Config.VabenhandlerNavn)
			end)
		elseif data.current.value == 'jubilee' then
			FreezeEntityPosition(playerPed, false)
			menu.close()
			ESX.Game.SpawnVehicle('jubilee', vector3(877.0948, -3246.118, -98.28624), 270.636, function(vehicle)
				TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
				SetVehicleNumberPlateText(vehicle, Config.VabenhandlerNavn)
			end)
		elseif data.current.value == 'cog552' then
			FreezeEntityPosition(playerPed, false)
			menu.close()
			ESX.Game.SpawnVehicle('cog552', vector3(877.0948, -3246.118, -98.28624), 270.636, function(vehicle)
				TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
				SetVehicleNumberPlateText(vehicle, Config.VabenhandlerNavn)
			end)
		elseif data.current.value == 'schafter' then
			FreezeEntityPosition(playerPed, false)
			menu.close()
			ESX.Game.SpawnVehicle('schafter5', vector3(877.0948, -3246.118, -98.28624), 270.636, function(vehicle)
				TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
				SetVehicleNumberPlateText(vehicle, Config.VabenhandlerNavn)
			end)
		elseif data.current.value == 'speedo' then
			FreezeEntityPosition(playerPed, false)
			menu.close()
			ESX.Game.SpawnVehicle('speedo4', vector3(877.0948, -3246.118, -98.28624), 270.636, function(vehicle)
				TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
				SetVehicleNumberPlateText(vehicle, Config.VabenhandlerNavn)
			end)
		elseif data.current.value == 'parker' then
			local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
			menu.close()
			FreezeEntityPosition(playerPed, false)
			ESX.Game.DeleteVehicle(vehicle)
		end
	end, function(data, menu)
		menu.close()
		FreezeEntityPosition(playerPed, false)

		CurrentAction     = 'menu_garage'
		--CurrentActionMsg  = "åben"
		TriggerEvent('cd_drawtextui:ShowUI', 'show', "Tryk <strong>[E]</strong> for at tilgå Garagen.")
		CurrentActionData = {}
	end)
end
function spawnCar(car)
    local car = GetHashKey(car)

    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(0)
    end

    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), false))
    local vehicle = CreateVehicle(car, x + 2, y + 2, z + 1, 0.0, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
end
function OpenGambinoMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'weapons', {
		title    = Config.VabenhandlerNavn.." - Våben",
		align    = 'top-left',
		elements = Config.Vabenskab 
	}, function(data, menu)
		if data.current.item ~= nil then
            menu.close()
			TriggerEvent('frp_gambinojob:tagVåben')
			Citizen.Wait(17000)
			TriggerServerEvent('Gambino:giveItem', data.current.item, data.current.amount)
		end
	end, function(data, menu)
		menu.close()

		CurrentAction     = 'menu_weapons'
		--CurrentActionMsg  = "Åben"
		TriggerEvent('cd_drawtextui:ShowUI', 'show', "Tryk <strong>[E]</strong> for at tilgå Lager.")
		CurrentActionData = {}
	end)
end

RegisterNetEvent('frp_gambinojob:tagVåben')
AddEventHandler('frp_gambinojob:tagVåben', function()
	local playerPed = PlayerPedId()
	FreezeEntityPosition(playerPed, true)
	ExecuteCommand('e mechanic4')

    exports['progressBars']:startUI(5000, 'Samler det valgte produkt...')
	Citizen.Wait(5000)
	exports["id_notify"]:notify({
		title = 'Våbenhandler',
		message = 'Du fik dit valgte produkt.. Du går videre til næste trin.',
		type = 'success'
	})
	Citizen.Wait(1000)
    exports['progressBars']:startUI(5000, 'Fin pudser det valgte produkt..')
	Citizen.Wait(5000)
	exports["id_notify"]:notify({
		title = 'Våbenhandler',
		message = 'Du fik pudset det valgte produkt.. Du går videre til næste trin.',
		type = 'success'
	})
	Citizen.Wait(1000)
    exports['progressBars']:startUI(5000, 'Pakker det valgte produkt ind..')
	Citizen.Wait(5000)
	exports["id_notify"]:notify({
		title = 'Våbenhandler',
		message = 'Du fik pakket det hele, og det er nu klar til levering!',
		type = 'success'
	})

	FreezeEntityPosition(playerPed, false)
	ClearPedTasksImmediately(playerPed)
end)

--#########################################
--#		  	      MARKERS OSV          	  #
--#########################################

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction then

			if IsControlJustReleased(0, 38) and ESX.PlayerData.job and ESX.PlayerData.job.name == 'weapondealer' then
                TriggerEvent('cd_drawtextui:HideUI')

				if CurrentAction == 'menu_weapons' then
					OpenGambinoMenu()
				elseif CurrentAction == 'menu_garage' then
					GambinoKoretojer()
				end

				CurrentAction = nil
			end
		end 
	end
end)

AddEventHandler('frp_gambinojob:hasEnteredMarker', function(station, part, partNum)
	if part == 'Lager' then
		CurrentAction     = 'menu_weapons'
		--CurrentActionMsg  = "eeeee"
		--TriggerEvent('cd_drawtextui:ShowUI', 'show', "Tryk <strong>[E]</strong> for at tilgå Lager.")
		CurrentActionData = {}
	elseif part == 'Garage' then
		CurrentAction     = 'menu_garage'
		--CurrentActionMsg  = "eeeee"
		--TriggerEvent('cd_drawtextui:ShowUI', 'show', "Tryk <strong>[E]</strong> for at tilgå Garagen.")
		CurrentActionData = {}
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'weapondealer' then
			local playerPed = PlayerPedId()
			local playerCoords = GetEntityCoords(playerPed)
			local isInMarker, hasExited, letSleep = false, false, true
			local currentStation, currentPart, currentPartNum

			for k,v in pairs(Config.Bunker) do

				for i=1, #v.Lager, 1 do
					local distance = #(playerCoords - v.Lager[i])

					if distance < Config.DrawDistance then
						DrawMarker(Config.MarkerType.Lager, v.Lager[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
						letSleep = false

						if distance < Config.MarkerSize.x then
							isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Lager', i
						end
					end
				end
				for i=1, #v.Garage, 1 do
					local distance = #(playerCoords - v.Garage[i])

					if distance < Config.DrawDistance then
						DrawMarker(Config.MarkerType.Garage, v.Garage[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
						letSleep = false

						if distance < Config.MarkerSize.x then
							isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Garage', i
						end
					end
				end
            end

			if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)) then
				if
					(LastStation and LastPart and LastPartNum) and
					(LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)
				then
					TriggerEvent('frp_gambinojob:hasExitedMarker', LastStation, LastPart, LastPartNum)
					hasExited = true
				end

				HasAlreadyEnteredMarker = true
				LastStation             = currentStation
				LastPart                = currentPart
				LastPartNum             = currentPartNum

				TriggerEvent('frp_gambinojob:hasEnteredMarker', currentStation, currentPart, currentPartNum)
			end

			if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('frp_gambinojob:hasExitedMarker', LastStation, LastPart, LastPartNum)
			end

			if letSleep then
				Citizen.Wait(500)
			end
		else
			Citizen.Wait(500)
		end
	end
end)
AddEventHandler('frp_gambinojob:hasExitedMarker', function(station, part, partNum)
	TriggerEvent('cd_drawtextui:HideUI')
	ESX.UI.Menu.CloseAll()

	CurrentAction = nil
end)

-- POKE X BLACKMANLOVER DECRYPTED
-- https://discord.gg/plh