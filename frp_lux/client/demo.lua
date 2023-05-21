local isInMarker

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'lux' then
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)

            for i=1, #Config.DemoZones.OpenMenu.Pos, 1 do
                if GetDistanceBetweenCoords(coords, Config.DemoZones.OpenMenu.Pos[i], false) <= Config.DrawDistance then
                    DrawMarker(Config.DemoZones.OpenMenu.Type, Config.DemoZones.OpenMenu.Pos[i],
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    Config.DemoZones.OpenMenu.Size.x, Config.DemoZones.OpenMenu.Size.y, Config.DemoZones.OpenMenu.Size.z,
                    Config.MarkerColor2.r, Config.MarkerColor2.g, Config.MarkerColor2.b, 200,
                    false, true, 2, false, nil, nil, false)

                    if GetDistanceBetweenCoords(coords, Config.DemoZones.OpenMenu.Pos[i], true) <= Config.DemoZones.OpenMenu.Size.z then
                        isInMarker = 'openMenu_'..i
                        ESX.ShowHelpNotification(_U('demo_menu_open_promp'))
                        if IsControlJustReleased(0, 51) then
                            openDemoMenu(i)
                        end
                    end
                elseif isInMarker == 'openMenu_'..i then
                    isInMarker = nil
                    ESX.UI.Menu.CloseAll()
                end
            end

            for i=1, #Config.DemoZones.DeleteVehicle.Pos, 1 do
                if GetDistanceBetweenCoords(coords, Config.DemoZones.DeleteVehicle.Pos[i], false) <= Config.DrawDistance then
                    DrawMarker(Config.DemoZones.DeleteVehicle.Type, Config.DemoZones.DeleteVehicle.Pos[i],
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    Config.DemoZones.DeleteVehicle.Size.x, Config.DemoZones.DeleteVehicle.Size.y, Config.DemoZones.DeleteVehicle.Size.z,
                    Config.MarkerColor2.r, Config.MarkerColor2.g, Config.MarkerColor2.b, 200,
                    false, true, 2, false, nil, nil, false)

                    if GetDistanceBetweenCoords(coords, Config.DemoZones.DeleteVehicle.Pos[i], true) <= Config.DemoZones.DeleteVehicle.Size.z then
                        isInMarker = 'deleteVehicle_'..i
                        local vehicle = GetVehiclePedIsIn(playerPed, false)
                        if vehicle ~= 0 and string.find(GetVehicleNumberPlateText(vehicle), 'DEMO') then
                            ESX.ShowHelpNotification(_U('demo_delete_promp'))
                            if IsControlJustReleased(0, 51) then
                                local model = GetEntityModel(vehicle)
                                local Display = GetDisplayNameFromVehicleModel(model)
                                TriggerServerEvent('cb_logs:cardealer:demoVeh', Display, ESX.Game.GetVehicleProperties(vehicle).plate, true)
                                ESX.Game.DeleteVehicle(vehicle)
                                ESX.Game.Teleport(playerPed, Config.DemoZones.OpenMenu.Pos[i])
                            end
                        elseif vehicle ~= 0 then
                            ESX.ShowHelpNotification(_U('demo_delete_promp_veh'))
                            if IsControlJustReleased(0, 51) then
                                TriggerServerEvent('frp_lux:parkVehicle', ESX.Game.GetVehicleProperties(vehicle))
                                ESX.Game.DeleteVehicle(vehicle)
                            end
                        end
                    end
                elseif isInMarker == 'deleteVehicle_'..i then
                    isInMarker = nil
                    ESX.UI.Menu.CloseAll()
                end
            end
        else
            Citizen.Wait(500)
        end
    end
end)

openDemoMenu = function(locationId)
    ESX.UI.Menu.CloseAll()

    if #Vehicles == 0 then
		print('[frp_lux] [^3ERROR^7] No vehicles found')
		return
	end

	local vehiclesByCategory = {}
	local elements           = {}
	local firstVehicleData   = nil

	for i=1, #Categories, 1 do
		vehiclesByCategory[Categories[i].name] = {}
	end

	for i=1, #Vehicles, 1 do
		if IsModelInCdimage(GetHashKey(Vehicles[i].model)) then
			table.insert(vehiclesByCategory[Vehicles[i].category], Vehicles[i])
		else
			print(('[frp_lux] [^3ERROR^7] Vehicle "%s" does not exist'):format(Vehicles[i].model))
		end
	end

	for k,v in pairs(vehiclesByCategory) do
		table.sort(v, function(a, b)
			return a.name < b.name
		end)
	end

	for i=1, #Categories, 1 do
		local category         = Categories[i]
		local categoryVehicles = vehiclesByCategory[category.name]
		local options          = {}

		for j=1, #categoryVehicles, 1 do
			local vehicle = categoryVehicles[j]

			if i == 1 and j == 1 then
				firstVehicleData = vehicle
			end

			table.insert(options, vehicle.name)
		end

		table.sort(options)

		table.insert(elements, {
			name    = category.name,
			label   = category.label,
			value   = 0,
			type    = 'slider',
			max     = #Categories[i],
			options = options
		})
	end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_shop', {
		title    = _U('demo_menu_title'),
		align    = 'left',
		elements = elements
	}, function(data, menu)
        menu.close()
		local vehicleData = vehiclesByCategory[data.current.name][data.current.value + 1]
        ESX.Game.SpawnVehicle(vehicleData.model, Config.DemoZones.SpawnVehicle.Pos[locationId], Config.DemoZones.SpawnVehicle.Heading[locationId], function(vehicle) 
            local vehProps = ESX.Game.GetVehicleProperties(vehicle)
            vehProps.plate = 'DEMO'..GetRandomNumber(4)
            ESX.Game.SetVehicleProperties(vehicle, vehProps)
            -- SetVehicleColours(
            --     vehicle,67,67
            -- )
            local label2 = getVehicleLabelFromModel(vehicleData.model)
            exports['LegacyFuel']:SetFuel(vehicle, 100)
            exports['t1ger_keys']:SetVehicleLocked(vehicle, 10)
            -- exports['t1ger_keys']:GiveTemporaryKeys(vehProps.plate, label2, 'Exotic MC')
            exports['t1ger_keys']:GiveJobKeys(vehProps.plate, label2, false, {'lux'})
            TriggerServerEvent('cb_logs:cardealer:demoVeh', getVehicleLabelFromModel(vehicleData.model), vehProps.plate, false)
            TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        end)
	end, function(data, menu)
		menu.close()
	end)
end