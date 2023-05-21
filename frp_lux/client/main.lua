local HasAlreadyEnteredMarker, IsInShopMenu = false, false
local CurrentAction, CurrentActionMsg, LastZone, currentDisplayVehicle
local CurrentActionData = {}
Vehicles, Categories = {}, {}

ESX = nil

local ScriptStartPromise

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

    while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()

	PlayerManagement()

	if ScriptStartPromise then
		ScriptStartPromise:resolve()
	end
end)

function getVehicleLabelFromModel(model)
	for k,v in ipairs(Vehicles) do
		if v.model == model then
			return v.name
		end
	end

	return
end

function getVehicles()
	ESX.TriggerServerCallback('frp_lux:getCategories', function(categories)
		Categories = categories
	end)

	ESX.TriggerServerCallback('frp_lux:getVehicles', function(vehicles)
		Vehicles = vehicles
	end)
end

function PlayerManagement()
	if Config.EnablePlayerManagement then
		if ESX.PlayerData.job.name == 'lux' then
			Config.Zones.ShopEntering.Type = 20

			if ESX.PlayerData.job.grade_name == 'boss' then
				Config.Zones.BossActions.Type = 22
            else
                Config.Zones.BossActions.Type  = -1
			end

		else
			Config.Zones.ShopEntering.Type = -1
			Config.Zones.BossActions.Type  = -1
			Config.Zones.ResellVehicle.Type = 29
		end
	end
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	PlayerManagement()
	getVehicles()
end)

AddEventHandler('onResourceStart', function(resourceName)
	ScriptStartPromise = promise.new()
	Citizen.Await(ScriptStartPromise)
	getVehicles()
end)

RegisterNetEvent('frp_lux:sendCategories')
AddEventHandler('frp_lux:sendCategories', function(categories)
	Categories = categories
end)

RegisterNetEvent('frp_lux:sendVehicles')
AddEventHandler('frp_lux:sendVehicles', function(vehicles)
	Vehicles = vehicles
end)


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
    PlayerManagement()
end)

function DeleteDisplayVehicleInsideShop()
	local attempt = 0

	if currentDisplayVehicle and DoesEntityExist(currentDisplayVehicle) then
		while DoesEntityExist(currentDisplayVehicle) and not NetworkHasControlOfEntity(currentDisplayVehicle) and attempt < 100 do
			Citizen.Wait(100)
			NetworkRequestControlOfEntity(currentDisplayVehicle)
			attempt = attempt + 1
		end

		if DoesEntityExist(currentDisplayVehicle) and NetworkHasControlOfEntity(currentDisplayVehicle) then
			ESX.Game.DeleteVehicle(currentDisplayVehicle)
		end
	end
end

function ReturnVehicleProvider()
	ESX.TriggerServerCallback('frp_lux:getCommercialVehicles', function(vehicles)
		local elements = {}

		for k,v in ipairs(vehicles) do
			local returnPrice = ESX.Math.Round(v.price * 0.75)
			local vehicleLabel = getVehicleLabelFromModel(v.vehicle)

			table.insert(elements, {
				label = ('%s [<span style="color:orange;">%s</span>]'):format(vehicleLabel, _U('generic_shopitem', ESX.Math.GroupDigits(returnPrice))),
				value = v.vehicle
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_provider_menu', {
			title    = _U('return_provider_menu'),
			align    = 'left',
			elements = elements
		}, function(data, menu)
			TriggerServerEvent('frp_lux:returnProvider', data.current.value)

			Citizen.Wait(300)
			menu.close()
			ReturnVehicleProvider()
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function StartShopRestriction()
	Citizen.CreateThread(function()
		while IsInShopMenu do
			Citizen.Wait(0)

			DisableControlAction(0, 75,  true) -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
		end
	end)
end

function OpenShopMenu()
	if #Vehicles == 0 then
		print('[frp_lux] [^3ERROR^7] No vehicles found')
		return
	end

	IsInShopMenu = true

	StartShopRestriction()
	ESX.UI.Menu.CloseAll()

	local playerPed = PlayerPedId()

	FreezeEntityPosition(playerPed, true)
	SetEntityVisible(playerPed, false)
    local coords = vector3(Config.Zones.ShopInside.Pos.x, Config.Zones.ShopInside.Pos.y, Config.Zones.ShopInside.Pos.z)
	SetEntityCoords(playerPed, coords)

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

			table.insert(options, ('%s <span style="color:green;">%s</span>'):format(vehicle.name, _U('generic_shopitem', ESX.Math.GroupDigits(vehicle.price))))
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

    exports['progressBars']:startUI(2500, 'Indlæser køretøjer...')
    Citizen.Wait(2500)
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_shop', {
		title    = _U('car_dealer'),
		align    = 'left',
		elements = elements
	}, function(data, menu)
		local vehicleData = vehiclesByCategory[data.current.name][data.current.value + 1]
        
        ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'shop_amount', {
            title = _U('buy_vehicle_amount')
        }, function(data3, menu3)
            menu3.close()
            local vehicleAmount = (tonumber(data3.value) and tonumber(data3.value)) or 1
            local vehiclePrice = vehicleData.price * vehicleAmount
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_confirm', {
                title = _U('buy_vehicle_shop', vehicleAmount, vehicleData.name, ESX.Math.GroupDigits(vehiclePrice)),
                align = 'left',
                elements = {
                    {label = _U('no'),  value = 'no'},
                    {label = _U('yes'), value = 'yes'}
            }}, function(data2, menu2)
                if data2.current.value == 'yes' then
                    ESX.TriggerServerCallback('frp_lux:buyCarDealerVehicle', function(success)
                        if success then
                            IsInShopMenu = false
                            DeleteDisplayVehicleInsideShop()

                            CurrentAction     = 'shop_menu'
                            CurrentActionMsg  = _U('shop_menu')
                            CurrentActionData = {}

                            local playerPed = PlayerPedId()
                            FreezeEntityPosition(playerPed, false)
                            SetEntityVisible(playerPed, true)
                            local coords = vector3(Config.Zones.BossActions.Pos.x, Config.Zones.BossActions.Pos.y, Config.Zones.BossActions.Pos.z - 1)
                            SetEntityCoords(playerPed, coords)

                            menu2.close()
                            menu.close()
                            ESX.ShowNotification(_U('vehicle_purchased'))
                        else
                            ESX.ShowNotification(_U('broke_company'))
                        end
                    end, vehicleData.model, vehicleAmount)
                else
                    menu2.close()
                end
            end, function(data2, menu2)
                menu2.close()
            end)
        end, function(data3, menu3)
            menu3.close()
        end)
	end, function(data, menu)
		menu.close()
		DeleteDisplayVehicleInsideShop()
		local playerPed = PlayerPedId()

		CurrentAction     = 'shop_menu'
		CurrentActionMsg  = _U('shop_menu')
		CurrentActionData = {}

		FreezeEntityPosition(playerPed, false)
		SetEntityVisible(playerPed, true)
        local coords = vector3(Config.Zones.BossActions.Pos.x, Config.Zones.BossActions.Pos.y, Config.Zones.BossActions.Pos.z - 1)
		SetEntityCoords(playerPed, coords)

		IsInShopMenu = false
	end, function(data, menu)
		local vehicleData = vehiclesByCategory[data.current.name][data.current.value + 1]
		local playerPed   = PlayerPedId()

		DeleteDisplayVehicleInsideShop()
		WaitForVehicleToLoad(vehicleData.model)

		ESX.Game.SpawnLocalVehicle(vehicleData.model, Config.Zones.ShopInside.Pos, Config.Zones.ShopInside.Heading, function(vehicle)
			currentDisplayVehicle = vehicle
			TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
			FreezeEntityPosition(vehicle, true)
			SetModelAsNoLongerNeeded(vehicleData.model)
		end)
	end)

	DeleteDisplayVehicleInsideShop()
	WaitForVehicleToLoad(firstVehicleData.model)

	ESX.Game.SpawnLocalVehicle(firstVehicleData.model, Config.Zones.ShopInside.Pos, Config.Zones.ShopInside.Heading, function(vehicle)
		currentDisplayVehicle = vehicle
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		FreezeEntityPosition(vehicle, true)
		SetModelAsNoLongerNeeded(firstVehicleData.model)
	end)
end

function OpenLux()
	local elements = {
		{label = 'Faktura', value = "billing"},
		{label = 'License', value = 'license'}
	}

	if ESX.PlayerData.job.grade_name == 'boss' then
		table.insert(elements, { label = 'Ledelse', value = 'boss'})
	end

	ESX.UI.Menu.CloseAll()
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'Lux_actions', {
          title    = 'Lux Koncern',
          align    = 'top-left',
          elements = elements
		}, function(data, menu)
          if data.current.value == 'boss' then
            ESX.UI.Menu.CloseAll()
            TriggerEvent('esx_society:openBossMenu', 'lux', function(data, menu)
                menu.close()
            end, { wash = false })
		elseif data.current.value == 'billing' then
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
				title = "Faktura Beløb"
			}, function(data, menu)
				local amount = tonumber(data.value)

				if amount == nil or amount < 0 then
					ESX.ShowNotification("Ugyldigt Beløb")
				else
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestPlayer == -1 or closestDistance > 1.5 then
						ESX.ShowNotification("Ingen spillere tæt på.")
					else
						menu.close()
						TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_lux', "Lux Koncern", amount)
					end
				end
			end, function(data, menu)
				menu.close()
			end)

		elseif data.current.value == 'license' then
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
				if closestPlayer ~= -1 and closestDistance <= 1.5 then
					ChooseMenu(closestPlayer)
				else
					ESX.ShowNotification("Ingen spillere tæt på.")
				end
        end
      end, function(data, menu)
          menu.close()
    end)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
        if IsControlJustReleased(0, 167) and not isDead and ESX.PlayerData.job and ESX.PlayerData.job.name == 'lux' and not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'Lux_actions') then
            OpenLux()
		end
    end
end)

function ChooseMenu(closestPlayer)
	local elements = {
		{label = 'Tilføj License', value = "tlicense"},
		{label = 'Fjern License', value = 'flicense'}
	}

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'choose_menu', {
			title = 'Tilføj/fratag',
			align = 'top-left',
			elements = elements,
		}, function(data, menu)
			local metode = data.current.value
			if metode == 'flicense' then
				RemoveLicense(closestPlayer)
			elseif metode == 'tlicense' then
				AddLicense(closestPlayer)
			end
	end, function(data, menu)
		menu.close()
	end)
end

local BlockedLicenses = {
	["drive"] = true,
	["drive_bike"] = true,
	["drive_truck"] = true,
	["dmv"] = true
}

function RemoveLicense(player)
	local elements = {}

	ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(playerData)
		if playerData.licenses then
			for i=1, #playerData.licenses, 1 do
				if not BlockedLicenses[playerData.licenses[i].type] then
					if playerData.licenses[i].label and playerData.licenses[i].type then
						table.insert(elements, {
							label = playerData.licenses[i].label,
							type = playerData.licenses[i].type
						})
					end
				end
			end
		end
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_license', {
			title    = _U('license_revoke'),
			align    = 'top-left',
			elements = elements,
		}, function(data, menu)
			ESX.ShowNotification(_U('licence_you_revoked', data.current.label, playerData.name))
			TriggerServerEvent('esx_policejob:message', GetPlayerServerId(player), _U('license_revoked', data.current.label))

			TriggerServerEvent('esx_license:removeLicense', GetPlayerServerId(player), data.current.type)

			ESX.SetTimeout(300, function()
				RemoveLicense(player)
			end)
		end, function(data, menu)
			menu.close()
		end)
	end, GetPlayerServerId(player))
end

local LicenseList = {
	{label = 'Helikopter License', type = 'heli'},
	{label = 'Lille Fly License', type = 'plane'},
	{label = 'Stort Fly License', type = 'plane1'},
}

function AddLicense(player)
	local elements = {}
	ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(playerData)
		local LicensesHas = {}

		for i=1, #playerData.licenses do
			LicensesHas[playerData.licenses[i].type] = true
		end

		for i=1, #LicenseList do
			if not LicensesHas[LicenseList[i].type] then
				elements[#elements + 1] = LicenseList[i]
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_license', {
			title    = _U('license_add'),
			align    = 'top-left',
			elements = elements,
		}, function(data, menu)
			ESX.ShowNotification(_U('licence_you_added', data.current.label, playerData.name))
			TriggerServerEvent('esx_policejob:message', GetPlayerServerId(player), _U('license_added', data.current.label))

			TriggerServerEvent('esx_license:addLicense', GetPlayerServerId(player), data.current.type)

			ESX.SetTimeout(300, function()
				AddLicense(player)
			end)
		end, function(data, menu)
			menu.close()
		end)
	end, GetPlayerServerId(player))
end

function WaitForVehicleToLoad(modelHash)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		BeginTextCommandBusyspinnerOn('STRING')
		AddTextComponentSubstringPlayerName(_U('shop_awaiting_model'))
		EndTextCommandBusyspinnerOn(4)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(0)
			DisableAllControlActions(0)
		end

		BusyspinnerOff()
	end
end

function OpenShowcaseMenu()
	ESX.UI.Menu.CloseAll()
	if #Vehicles == 0 then
		print('[frp_lux] [^3ERROR^7] No vehicles found')
		return
	end

	IsInShopMenu = true

	StartShopRestriction()
	ESX.UI.Menu.CloseAll()

	local playerPed = PlayerPedId()

	FreezeEntityPosition(playerPed, true)
	SetEntityVisible(playerPed, false)
    local coords = vector3(Config.Zones.ShowcaseZone.Pos.x, Config.Zones.ShowcaseZone.Pos.y, Config.Zones.ShowcaseZone.Pos.z)
	SetEntityCoords(playerPed, coords)

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

            if Config.ShowPriceInShowcase then
			    table.insert(options, ('%s <span style="color:green;">%s</span>'):format(vehicle.name, _U('generic_shopitem', ESX.Math.GroupDigits(vehicle.price))))
            else
                table.insert(options, vehicle.name)
            end
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
	print(json.encode(elements))
    exports['progressBars']:startUI(2500, 'Indlæser køretøjer...')
    Citizen.Wait(2500)
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_shop', {
		title    = _U('showcase_menu_title'),
		align    = 'left',
		elements = elements
	}, function(data, menu)
		print("3")
	end, function(data, menu)
		print("2")
		menu.close()
		DeleteDisplayVehicleInsideShop()
		local playerPed = PlayerPedId()

		CurrentAction     = 'showcase_menu'
		CurrentActionMsg  = _U('showcase_menu_open_promp')
		CurrentActionData = {}

		FreezeEntityPosition(playerPed, false)
		SetEntityVisible(playerPed, true)
        local coords = vector3(Config.Zones.ShowCaseMarker.Pos.x, Config.Zones.ShowCaseMarker.Pos.y, Config.Zones.ShowCaseMarker.Pos.z - 1)
		SetEntityCoords(playerPed, coords)

		IsInShopMenu = false
	end, function(data, menu)
		local vehicleData = vehiclesByCategory[data.current.name][data.current.value + 1]
		local playerPed   = PlayerPedId()

		DeleteDisplayVehicleInsideShop()
		WaitForVehicleToLoad(vehicleData.model)

		ESX.Game.SpawnLocalVehicle(vehicleData.model, Config.Zones.ShowcaseZone.Pos, Config.Zones.ShowcaseZone.Heading, function(vehicle)
			currentDisplayVehicle = vehicle
			TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
			FreezeEntityPosition(vehicle, true)
			SetModelAsNoLongerNeeded(vehicleData.model)
		end)
	end)

	DeleteDisplayVehicleInsideShop()
	WaitForVehicleToLoad(firstVehicleData.model)

	ESX.Game.SpawnLocalVehicle(firstVehicleData.model, Config.Zones.ShowcaseZone.Pos, Config.Zones.ShowcaseZone.Heading, function(vehicle)
		print(ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'vehicle_shop'))
		print("1")
		currentDisplayVehicle = vehicle
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		FreezeEntityPosition(vehicle, true)
		SetModelAsNoLongerNeeded(firstVehicleData.model)
	end)
end

function OpenResellerMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'reseller', {
		title    = _U('car_dealer'),
		align    = 'left',
		elements = {
			{label = _U('set_vehicle_owner_sell'), value = 'set_vehicle_owner_sell'},
	}}, function(data, menu)
		local action = data.current.value
		if action == 'set_vehicle_owner_sell' then
            local coords = GetEntityCoords(PlayerPedId())
            local closestPlayers = ESX.Game.GetPlayersInArea(coords, 3)
            local serverPlayers = {}
            for i=1, #closestPlayers, 1 do
                if closestPlayers[i] ~= PlayerId() then
                    table.insert(serverPlayers, GetPlayerServerId(closestPlayers[i]))
                end
            end

        
			if #serverPlayers > 0 then
                ESX.TriggerServerCallback('frp_lux:getRPName', function(playerNames)
                    local elements = {}
                    for i=1, #playerNames, 1 do
                        table.insert(elements, {
                            label = playerNames[i].rpName,
                            value = playerNames[i].serverId
                        })
                    end
                    
                    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'closest_players', {
                        title = _U('select_player'),
                        align = 'left',
                        elements = elements
                    }, function(data4, menu4)
                        ESX.TriggerServerCallback('frp_lux:getCommercialVehicles', function(vehicles)
                            menu4.close()
                            if #vehicles > 0 then
                                local elements = {}
                                local vehicleList = {}
                        
                                for k,v in ipairs(vehicles) do
                                    local vehicleLabel = getVehicleLabelFromModel(v.vehicle)
                                    if has_value(elements, v.vehicle) then
                                        for i=1, #elements, 1 do
                                            if elements[i].value == v.vehicle then
                                                elements[i].amount = elements[i].amount + 1
                                            end
                                        end
                                    else
                                        table.insert(elements, {
                                            label = vehicleLabel,
                                            amount = 1,
                                            value = v.vehicle,
                                            price = v.price
                                        })
                                    end
                                end

                                if #elements > 0 then
                                    for i=1, #elements, 1 do
                                        elements[i].label = elements[i].label..' x'..elements[i].amount
                                    end
                                end
                        
                                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sell_vehicle_to_player', {
                                    title    = _U('sell_vehicle_to_player'),
                                    align    = 'left',
                                    elements = elements
                                }, function(data3, menu3)
                                    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'set_price_vehicle', {
                                        title = _U('set_price_sell_vehicle', ESX.Math.GroupDigits(data3.current.price)),
                                    }, function(data2, menu2)
                                        local price = (tonumber(data2.value) and tonumber(data2.value)) or data3.current.price
                                        if price >= data3.current.price * Config.MinPriceProcent then
                                            local plate = GeneratePlate()
                                            menu2.close()
                                            TriggerServerEvent('frp_lux:confirmBuy', data4.current.value, plate, data3.current.value, getVehicleLabelFromModel(data3.current.value), price)
                                        else
                                            menu2.close()
                                            ESX.ShowNotification(_U('too_low_price'))
                                        end
                                    end, function(data2, menu2)
                                        menu2.close()
                                    end)
                                end, function(data3, menu3)
                                    menu3.close()
                                end)
                            else
                                ESX.ShowNotification(_U('no_vehicles_in_shop'))
                            end
                        end)
                    end, function(data4, menu4)
                        menu4.close()
                    end)
                end, serverPlayers)
            else
                ESX.ShowNotification(_U('no_players'))
            end
		end
	end, function(data, menu)
		menu.close()

		CurrentAction     = 'reseller_menu'
		CurrentActionMsg  = _U('shop_menu')
		CurrentActionData = {}
	end)
end

function OpenBossActionsMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'reseller',{
		title    = _U('dealer_boss'),
		align    = 'left',
		elements = {
			{label = _U('boss_actions'), value = 'boss_actions'},
            {label = _U('buy_vehicle'), value = 'buy_vehicle'},
            {label = _U('return_provider'), value = 'return_provider'},
			{label = _U('boss_sold'), value = 'sold_vehicles'}
	}}, function(data, menu)
        if data.current.value == 'buy_vehicle' then
			OpenShopMenu()
        elseif data.current.value == 'return_provider' then
            ReturnVehicleProvider()
		elseif data.current.value == 'boss_actions' then
			TriggerEvent('esx_society:openBossMenu', 'lux', function(data2, menu2)
				menu2.close()
			end)
		elseif data.current.value == 'sold_vehicles' then

			ESX.TriggerServerCallback('frp_lux:getSoldVehicles', function(customers)
				local elements = {
					head = { _U('customer_client'), _U('customer_model'), _U('customer_plate'), _U('customer_soldby'), _U('customer_price'), _U('customer_date') },
					rows = {}
				}

				for i=1, #customers, 1 do
					table.insert(elements.rows, {
						data = customers[i],
						cols = {
							customers[i].client,
							customers[i].model,
							customers[i].plate,
							customers[i].soldby,
                            customers[i].price,
							customers[i].date
						}
					})
				end
				table.sort(elements.rows, function (a, b)
					local DateTable = {
						tonumber(string.sub(a.data.date, 7, 10)),
						tonumber(string.sub(a.data.date, 4, 5)),
						tonumber(string.sub(a.data.date, 1, 2)),
						tonumber(string.sub(a.data.date, 14, 15)),
						tonumber(string.sub(a.data.date, 17, 18))
					}
				
					local DateTable2 = {
						tonumber(string.sub(b.data.date, 7, 10)),
						tonumber(string.sub(b.data.date, 4, 5)),
						tonumber(string.sub(b.data.date, 1, 2)),
						tonumber(string.sub(b.data.date, 14, 15)),
						tonumber(string.sub(b.data.date, 17, 18))
					}
				
					for i = 1, 5 do
						if DateTable[i] > DateTable2[i] then
							return true
						elseif DateTable[i] < DateTable2[i] then
							return false
						end
					end
				
					return false
				end)
				ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'sold_vehicles', elements, function(data2, menu2)

				end, function(data2, menu2)
					menu2.close()
				end)
			end)
		end

	end, function(data, menu)
		menu.close()

		CurrentAction     = 'boss_actions_menu'
		CurrentActionMsg  = _U('shop_menu')
		CurrentActionData = {}
	end)
end

AddEventHandler('frp_lux:hasEnteredMarker', function(zone)
	if zone == 'ShopEntering' then

		if Config.EnablePlayerManagement then
			if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'lux' then
				CurrentAction     = 'reseller_menu'
				CurrentActionMsg  = _U('shop_menu')
				CurrentActionData = {}
			end
		else
			CurrentAction     = 'shop_menu'
			CurrentActionMsg  = _U('shop_menu')
			CurrentActionData = {}
		end

    elseif zone == 'ShowCaseMarker' then
        CurrentAction     = 'showcase_menu'
        CurrentActionMsg  = _U('showcase_menu_open_promp')
        CurrentActionData = {}
	elseif zone == 'ResellVehicle' then
		local playerPed = PlayerPedId()

		if IsPedSittingInAnyVehicle(playerPed) then
			local vehicle = GetVehiclePedIsIn(playerPed, false)
			local vehicleData, model, resellPrice, plate

			if GetPedInVehicleSeat(vehicle, -1) == playerPed then
				for i=1, #Vehicles, 1 do
					if GetHashKey(Vehicles[i].model) == GetEntityModel(vehicle) then
						vehicleData = Vehicles[i]
						break
					end
				end

				if vehicleData then
					resellPrice = ESX.Math.Round(vehicleData.price / 100 * Config.ResellPercentage)
					model = GetEntityModel(vehicle)
					plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))

					CurrentAction     = 'resell_vehicle'
					CurrentActionMsg  = _U('sell_menu', vehicleData.name, ESX.Math.GroupDigits(resellPrice))

					CurrentActionData = {
						vehicle = vehicle,
						label = vehicleData.name,
						price = resellPrice,
						model = model,
						plate = plate
					}
				else
					ESX.ShowNotification(_U('invalid_vehicle'))
				end
			end
		end

	elseif zone == 'BossActions' and Config.EnablePlayerManagement and ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'lux' and ESX.PlayerData.job.grade_name == 'boss' then
		CurrentAction     = 'boss_actions_menu'
		CurrentActionMsg  = _U('shop_menu')
		CurrentActionData = {}
	end
end)

AddEventHandler('frp_lux:hasExitedMarker', function(zone)
	if not IsInShopMenu then
		ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'confirm_buy_veh')
		ESX.UI.Menu.Close('list', GetCurrentResourceName(), 'sold_vehicles')
		ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'reseller')
		ESX.UI.Menu.Close('dialog', GetCurrentResourceName(), 'set_price_vehicle')
		ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'sell_vehicle_to_player')
		ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'closest_players')
		ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'vehicle_shop')
		ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'shop_confirm')
		ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'return_provider_menu')
	end

	CurrentAction = nil
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if IsInShopMenu then
			ESX.UI.Menu.CloseAll()

			local playerPed = PlayerPedId()

			FreezeEntityPosition(playerPed, false)
			SetEntityVisible(playerPed, true)
            local coords = vector3(Config.Zones.BossActions.Pos.x, Config.Zones.BossActions.Pos.y, Config.Zones.BossActions.Pos.z - 1)
			SetEntityCoords(playerPed, coords)
		end

		DeleteDisplayVehicleInsideShop()
	end
end)

if Config.EnablePlayerManagement then
	RegisterNetEvent('esx_phone:loaded')
	AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)
		local specialContact = {
			name       = _U('dealership'),
			number     = 'cardealer',
			base64Icon = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAMAAABrrFhUAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAMAUExURQAAADMzMzszM0M0M0w0M1Q1M101M2U2M242M3Y3M383Moc4MpA4Mpg5MqE5Mqk6MrI6Mro7Mrw8Mr89M71DML5EO8I+NMU/NcBMLshANctBNs5CN8RULMddKsheKs9YLtBCONZEOdlFOtxGO99HPNhMNsplKM1nKM1uJtRhLddiLt5kMNJwJ9B2JNR/IeNIPeVJPehKPuRQOuhSO+lZOOlhNuloM+p3Lep/KupwMMFORsVYUcplXc1waNJ7delUSepgVexrYe12bdeHH9iIH9qQHd2YG+udH+OEJeuGJ+uOJeuVIuChGeSpF+aqGOykHOysGeeyFeuzFuyzFuq6E+27FO+Cee3CEdaGgdqTjvCNhfKYkvOkngAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJezdycAAAEAdFJOU////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wBT9wclAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAGHRFWHRTb2Z0d2FyZQBwYWludC5uZXQgNC4xLjb9TgnoAAAQGElEQVR4Xt2d+WMUtxXHbS6bEGMPMcQQ04aEUnqYo9xJWvC6kAKmQLM2rdn//9+g0uir2Tl0PElPszP7+cnH7Fj6rPTeG2lmvfKld2azk8lk/36L/cnkZDbDIT3Sp4DZ8QS9dTI57tNDTwJOOu+4j/0TvDQz+QXMSG+7mUn+sZBZQELnNROcKhMZBXx+gS4k8+IzTpmBXAJOnqPxTDzPFRKyCODuvSKPgwwC2EZ+lxf4E4xwCzhBU7PBPQx4BWR88+fwDgNGAbMsM9/Ec8bygE3A5966L3nOlhiZBGSf+l2YggGLgBna1DMsE4FBQH9zvw1HLEgX0Evkt5GeEVIFMFztpJF6rZQm4DNasVDSEkKSgIVN/ibP0ZwoEgQsfPTPSZgH8QIG8vYr4gdBrIABvf2K2EEQKWBQb78ichBECRhE8O8SlQ5iBAQvcffFPhoYQoSAAQ5/TcQ0CBYw0OGvCZ4GoQIGF/3bhGaDQAELvfKhERgIwgQMePrPCQsEQQLwFwYPmksiQMCC1n1iCFgooQtYwLJfPPQFQ7KAUfU/wABVwMj6TzdAFDDY6tcOMR3SBIyw/1QDJAGj7D/RAEXA6Oa/hhIHCAJG23+SAb+AEfefYsArYET1nwlvTegVgBONFnTDik8ATjNi0BEbHgGjuP5147k6dgsYaQHQxF0OOAUMfv2LhnOVzCVg4OufdFwrpS4BePkSgA6ZcAhYggCocQRCu4ClCIAaeyC0CliaAKCwhgGrALxwaUC3OtgELFEAUNjCgEXAklQAdSzVgEUAXrRUoGstzAKWbgJIzJPAKGAJJ4DEOAmMAvCCpQPda2ASsJQTQGKa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',
		}

		TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)
	end)
end

-- Create Blips
Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.Blip)

	SetBlipSprite (blip, 424)
	SetBlipDisplay(blip, 4)
	SetBlipColour(blip, 3)
	-- SetBlipSquaredRotation(blip, 90)
	SetBlipRotation(blip, 330)
	SetBlipScale  (blip, 1.20)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(_U('car_dealer'))
	EndTextCommandSetBlipName(blip)
end)

-- Enter / Exit marker events & Draw Markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local isInMarker, letSleep, currentZone = false, true

		for k,v in pairs(Config.Zones) do
			if type(v.Pos) == 'table' then 
				for i=1, #v.Pos, 1 do
					local distance = #(playerCoords - v.Pos[i])

					if distance < Config.DrawDistance then
						letSleep = false

						if v.Type ~= -1 then
							DrawMarker(v.Type, v.Pos[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, Config.MarkerColor2.r, Config.MarkerColor2.g, Config.MarkerColor2.b, 100, false, true, 2, false, nil, nil, false)
						end

						if distance < v.Size.x then
							isInMarker, currentZone = true, k
						end
					end
				end
			else
				local distance = #(playerCoords - v.Pos)

				if distance < Config.DrawDistance then
					letSleep = false

					if v.Type ~= -1 then
						DrawMarker(v.Type, v.Pos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, Config.MarkerColor2.r, Config.MarkerColor2.g, Config.MarkerColor2.b, 100, false, true, 2, false, nil, nil, false)
					end

					if distance < v.Size.x then
						isInMarker, currentZone = true, k
					end
				end
			end
		end

		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
			HasAlreadyEnteredMarker, LastZone = true, currentZone
			LastZone = currentZone
			TriggerEvent('frp_lux:hasEnteredMarker', currentZone)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('frp_lux:hasExitedMarker', LastZone)
		end

		if letSleep then
			Citizen.Wait(500)
		end
	end
end)

-- Key controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)

		if CurrentAction then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, 38) then
				if CurrentAction == 'shop_menu' then
					if Config.LicenseEnable then
						ESX.TriggerServerCallback('esx_license:checkLicense', function(hasDriversLicense)
							if hasDriversLicense then
								OpenShopMenu()
							else
								ESX.ShowNotification(_U('license_missing'))
							end
						end, GetPlayerServerId(PlayerId()), 'drive')
					else
						OpenShopMenu()
					end
                elseif CurrentAction == 'showcase_menu' then
                    OpenShowcaseMenu()
				elseif CurrentAction == 'reseller_menu' then
					OpenResellerMenu()
				elseif CurrentAction == 'resell_vehicle' then
                    local aheadVehName = GetDisplayNameFromVehicleModel(CurrentActionData.model)
				    local vehicleName = GetLabelText(aheadVehName)
					ESX.TriggerServerCallback('frp_lux:resellVehicle', function(vehicleSold)
						if vehicleSold then
							ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
							ESX.ShowNotification(_U('vehicle_sold_for', CurrentActionData.label, ESX.Math.GroupDigits(CurrentActionData.price)))
						else
							ESX.ShowNotification(_U('not_yours'))
						end
					end, CurrentActionData.plate, CurrentActionData.model, vehicleName)
				elseif CurrentAction == 'boss_actions_menu' then
					OpenBossActionsMenu()
				end

				CurrentAction = nil
			end
		else
			Citizen.Wait(500)
		end
	end
end)

Citizen.CreateThread(function()
    while true do
        Wait(5)
        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'lux' then
            if IsControlJustReleased(0, 167) then
                TriggerServerEvent('cb_calllist:initOpen')
                Wait(1000)
            end
        else
            Wait(1000)
        end
    end
end)



RegisterNetEvent('frp_lux:confirmBuy')
AddEventHandler('frp_lux:confirmBuy', function(seller, plate, model, label, price)
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'confirm_buy_veh', {
        title = _U('confirm_buy_veh', label, ESX.Math.GroupDigits(price)),
        align = 'center',
        elements = {
            {label = _U('no')},
            {label = _U('yes'), value = true},
        }
    }, function(data, menu)
        menu.close()
        if data.current.value then
            TriggerServerEvent('frp_lux:acceptetConfirm', seller, plate, model, label, price)
        else
            TriggerServerEvent('frp_lux:deniedConfirm', seller)
        end
    end, function(data, menu)
        menu.close()
        TriggerServerEvent('frp_lux:deniedConfirm', seller)
    end)
end)


RegisterNetEvent('frp_lux:acceptetConfirm')
AddEventHandler('frp_lux:acceptetConfirm', function(target, plate, model, label, price)
    local locId = nil
	for k,v in pairs(Config.Zones.VehSpawn.Pos) do
		if ESX.Game.IsSpawnPointClear(v, 4.0) then
			locId = k
			break
		end
	end
	
    if locId then
        ESX.TriggerServerCallback('frp_lux:setVehicleOwnedPlayerId', function(success)
             if success then
				
                ESX.UI.Menu.CloseAll()
                ESX.Game.SpawnVehicle(model, Config.Zones.VehSpawn.Pos[locId], Config.Zones.VehSpawn.Heading[locId], function(vehicle)
                    local vehProps = ESX.Game.GetVehicleProperties(vehicle) 
                    vehProps.plate = plate
                    ESX.Game.SetVehicleProperties(vehicle, vehProps)
                end)
				TriggerServerEvent('t1ger_keys:updateOwnedKeys', plate, true)
            else
                ESX.UI.Menu.CloseAll()
                ESX.ShowNotification(_U('customer_no_money'))
            end
        end, target, plate, model, label, price)
    else
        exports['id_notify']:notify({
            title = 'Fejl',
            message = _U('car_in_the_way'),
            type = 'error'
        })
    end
end)

