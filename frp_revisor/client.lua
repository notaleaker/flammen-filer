RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)


Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.Zones.Moneywash.Pos.x, Config.Zones.Moneywash.Pos.y, Config.Zones.Moneywash.Pos.z)

	SetBlipSprite (blip, 374)
	SetBlipDisplay(blip, 4)
	SetBlipScale  (blip, 0.8)
	SetBlipColour (blip, 29)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName('Revisor')
	EndTextCommandSetBlipName(blip)
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'revisor' then
			local coords, letSleep = GetEntityCoords(PlayerPedId()), true

			for k,v in pairs(Config.Zones) do
				if v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance then
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, nil, nil, false)
					letSleep = false
				end
			end

			if letSleep then
				Citizen.Wait(500)
			end
		else
			Citizen.Wait(500)
		end
	end
end)
function OpenBankActionsMenu()
	local elements = {
		{label = 'Hvidvask', value = 'test'}
	}

	if ESX.PlayerData.job.grade_name == 'boss' then
		table.insert(elements, { label = 'Åben Chefmuligheder', value = 'boss_actions' })
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'bank_actions', {
		title    = _U('bank'),
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'test' then
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'fuck13di2nmor21', {
				title = ('Skriv antal procent uden %'),
			}, function(data, menu)
				local length = string.len(data.value)
				local test = tonumber(data.value)
				print(tonumber(data.value))
				-- 
				if test == nil then
					ESX.ShowNotification('Du skal ikke skrive %')
				else
					menu.close()
					ESX.TriggerServerCallback("PP:Moneywash", function(cb)
						
					end, test)
		
				end
			end, function(data, menu)
				menu.close()
			end)
		elseif data.current.value == 'boss_actions' then
			TriggerEvent('esx_society:openBossMenu', 'revisor', function (data, menu)
			menu.close()
			end, {wash = false})
		end
	end, function(data, menu)
		menu.close()

		CurrentAction     = 'mechanic_actions_menu'
		CurrentActionMsg  = _U('open_actions')
		CurrentActionData = {}
	end)
end


function iguess()

end

RegisterNetEvent("PP:Timer")
AddEventHandler("PP:Timer", function(timer)
	FreezeEntityPosition(PlayerPedId(), true)
	TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_CLIPBOARD", 0, true);
	exports['progressBars']:startUI(timer, "Hvidvasker")
	Citizen.Wait(timer)
	FreezeEntityPosition(PlayerPedId(), false)
	ClearPedTasks(PlayerPedId())
end)

AddEventHandler('frp_revisor:hasEnteredMarker', function(zone)
	if zone == 'Moneywash' then
		CurrentAction     = 'mechanic_actions_menu'
		CurrentActionMsg  = _U('open_actions')
		CurrentActionData = {}
	end
end)

AddEventHandler('frp_revisor:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)

		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'revisor' then

			local coords = GetEntityCoords(PlayerPedId())
			local isInMarker = false
			local currentZone = nil

			for k,v in pairs(Config.Zones) do
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
					isInMarker  = true
					currentZone = k
				end
			end

			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker = true
				LastZone                = currentZone
				TriggerEvent('frp_revisor:hasEnteredMarker', currentZone)
			end

			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('frp_revisor:hasExitedMarker', LastZone)
			end

		end
	end
end)


-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, 38) and ESX.PlayerData.job and ESX.PlayerData.job.name == 'revisor' then

				if CurrentAction == 'mechanic_actions_menu' then
					OpenBankActionsMenu()
				elseif CurrentAction == 'menu_boss_actions' then
					ESX.UI.Menu.CloseAll()
					TriggerEvent('esx_society:openBossMenu', 'revisor', function(data, menu)
						menu.close()
			
						CurrentAction     = 'menu_boss_actions'
						CurrentActionMsg  = _U('open_bossmenu')
						CurrentActionData = {}
					end, { wash = false }) -- disable washing money
				end

				CurrentAction = nil
			end
		end
	end
end)