local hasAlreadyEnteredMarker, lastZone
local currentAction, currentActionMsg, currentActionData = nil, nil, {}
ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function OpenShopMenu2(zone)
	local elements = {}
	for i=1, #Config.Shops[zone].Items, 1 do
		local item = Config.Shops[zone].Items[i]

		table.insert(elements, {
			label      = ('%s - <span style="color:green;">%s</span>'):format(item.label, _U('shop_item', ESX.Math.GroupDigits(item.price))),
			itemLabel = item.label,
			item       = item.name,
			price      = item.price,

			-- menu properties
			value      = 1,
			type       = 'slider',
			min        = 1,
			max        = 1
		})
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop', {
		title    = _U('shop'),
		align    = 'bottom-right',
		elements = elements
	}, function(data, menu)
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_confirm', {
			title    = _U('shop_confirm', data.current.value, data.current.itemLabel, ESX.Math.GroupDigits(data.current.price * data.current.value)),
			align    = 'bottom-right',
			elements = {
				{label = _U('no'),  value = 'no'},
				{label = _U('yes'), value = 'yes'}
		}}, function(data2, menu2)
			if data2.current.value == 'yes' then
				TriggerServerEvent('FRP_Lux:buyItem', data.current.item, data.current.value, zone)
			end

			menu2.close()
		end, function(data2, menu2)
			menu2.close()
		end)
	end, function(data, menu)
		menu.close()

		currentAction     = 'shop_menu'
		currentActionMsg  = _U('press_menu')
		currentActionData = {zone = zone}
	end)
end

AddEventHandler('FRP_Lux:hasEnteredMarker', function(zone)
	currentAction     = 'shop_menu'
	currentActionMsg  = _U('press_menu')
	currentActionData = {zone = zone}
end)

AddEventHandler('FRP_Lux:hasExitedMarker', function(zone)
	currentAction = nil
	ESX.UI.Menu.CloseAll()
end)

-- Create Blips
-- Citizen.CreateThread(function()
-- 	for k,v in pairs(Config.Shops) do
-- 		for i = 1, #v.Pos, 1 do
-- 			if v.ShowBlip then
-- 			local blip = AddBlipForCoord(v.Pos[i])

-- 			SetBlipSprite (blip, v.Type)
-- 			SetBlipScale  (blip, v.Size)
-- 			SetBlipColour (blip, v.Color)
-- 			SetBlipAsShortRange(blip, true)

-- 			BeginTextCommandSetBlipName('STRING')
-- 			AddTextComponentSubstringPlayerName(_U('shops'))
-- 			EndTextCommandSetBlipName(blip)
-- 		end
-- 	end
-- 	end
-- end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local isInMarker, letSleep, currentZone = false, false

		for k,v in pairs(Config.Shops) do
			for i = 1, #v.Pos, 1 do
				local distance = #(playerCoords - v.Pos[i])

				if distance < Config.DrawDistance then
					if v.ShowMarker then
					DrawMarker(Config.MarkerType, v.Pos[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor2.r, Config.MarkerColor2.g, Config.MarkerColor2.b, 100, false, true, 2, false, nil, nil, false)
				  	end
					letSleep = false

					if distance < 2.0 then
						isInMarker  = true
						currentZone = k
						lastZone    = k
					end
				end
			end
		end

		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			TriggerEvent('FRP_Lux:hasEnteredMarker', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('FRP_Lux:hasExitedMarker', lastZone)
		end

		if letSleep then
			Citizen.Wait(500)
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if currentAction then
			ESX.ShowHelpNotification(currentActionMsg)

			if IsControlJustReleased(0, 38) then
				if currentAction == 'shop_menu' then
					OpenShopMenu2(currentActionData.zone)
				end

				currentAction = nil
			end
		else
			Citizen.Wait(500)
		end
	end
end)
