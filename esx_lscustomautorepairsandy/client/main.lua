local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX =					nil
local Vehicles =		{}
local PlayerData		= {}
local lsMenuIsShowed	= false
local isInLSMarker		= false
local IsSpecial			= false
local startCar			= {}
local myCar				= {}
local mainPrice 		= {}
local totalPrice 		= 0

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
	end
    Citizen.Wait(10000)
    ESX.TriggerServerCallback('esx_lscustomautorepairsandy:getVehiclesPrices', function(vehicles)
        Vehicles = vehicles
	end)
end)

RegisterNetEvent('esx:playerLoaded') -- Store the players data
AddEventHandler('esx:playerLoaded', function(xPlayer, isNew)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
	ESX.TriggerServerCallback('esx_lscustomautorepairsandy:getVehiclesPrices', function(vehicles)
		Vehicles = vehicles
	end)
end)

RegisterNetEvent('esx:playerLogout') -- When a player logs out (multicharacter), reset their data
AddEventHandler('esx:playerLogout', function(xPlayer, isNew)
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterNetEvent('esx_lscustomautorepairsandy:cancelInstallMod')
AddEventHandler('esx_lscustomautorepairsandy:cancelInstallMod', function()
	local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
	ESX.Game.SetVehicleProperties(vehicle, myCar)
end)

RegisterNetEvent('esx_lscustomautorepairsandy:repair')
AddEventHandler('esx_lscustomautorepairsandy:repair', function()
	local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
	SetVehicleFixed(vehicle)
	myCar = ESX.Game.GetVehicleProperties(vehicle)
	startCar = ESX.Game.GetVehicleProperties(vehicle)
	TriggerServerEvent('esx_lscustomautorepairsandy:setStarterCarServer', startCar)
	mainPrice = {}
	totalPrice = 0
	GetAction({value = 'main'})
end)

RegisterNetEvent('esx_lscustomautorepairsandy:GoOutOfLS')
AddEventHandler('esx_lscustomautorepairsandy:GoOutOfLS', function()
	local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
	SetVehicleDoorsShut(vehicle, false)
	if parent == nil then
		lsMenuIsShowed = false
		FreezeEntityPosition(vehicle, false)
		myCar = {}
		startCar = {}
		mainPrice = {}
		totalPrice = 0
	end
end)

RegisterNetEvent('esx_lscustomautorepairsandy:setVehicleProps')
AddEventHandler('esx_lscustomautorepairsandy:setVehicleProps', function(props)
	for k,v in pairs(Config.Zones) do
		local coords = {x = v.Pos.x, y = v.Pos.y, z = v.Pos.z}
		local vehicles = ESX.Game.GetVehiclesInArea(coords, 10.0)
		for _,vehicle in pairs(vehicles) do
			vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
			if vehicleProps["model"] == props ["model"] and vehicleProps["plate"] == props ["plate"] then
				ESX.Game.SetVehicleProperties(vehicle, props)
			end
		end
	end
end)

function addPrice(modType,price,modint,pricedown)
	if mainPrice[modType] == nil then
		mainPrice[modType] = {}
		mainPrice[modType].price = price
		totalPrice = totalPrice + price
	elseif pricedown then
		totalPrice = totalPrice - mainPrice[modType].price
		mainPrice[modType] = nil
	elseif modint ~= nil then 
		if modint == 11 or modint == 12 or modint == 13 or modint == 15 or modint == 16 then
			totalPrice = totalPrice - mainPrice[modType].price
			mainPrice[modType].price = price
			totalPrice = totalPrice + price
		end
	end
end

function OpenPayMenu()
	local elements = {
		{label = _U('no'),value = 'no'},
		{label = _U('yes'),value = 'yeas'},
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pay_menu', {
		title    = _U('buyupgrades'),
		align    = 'top-right',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'no' then
			menu.close()
			lsMenuIsShowed = false
			local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
			FreezeEntityPosition(vehicle, false)
			ESX.Game.SetVehicleProperties(vehicle, startCar)
			myCar = {}
			startCar = {}
			TriggerServerEvent('esx_lscustomautorepairsandy:removeStarterCarServer')
		elseif data.current.value == 'yeas' then
			ESX.TriggerServerCallback('esx_lscustomautorepairsandy:hasMoneyToExit', function(paid)
				if paid then
					menu.close()
					lsMenuIsShowed = false
					local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
					FreezeEntityPosition(vehicle, false)
					TriggerServerEvent('esx_lscustomautorepairsandy:refreshOwnedVehicle', myCar)
					TriggerServerEvent('esx_lscustomautorepairsandy:removeStarterCarServer')
					myCar = {}
					startCar = {}
				end
			end, totalPrice, IsSpecial)
		end
	end, function(data, menu)
		ESX.ShowNotification(_U('choose'))
	end)
end



function OpenLSMenu(elems, menuName, menuTitle, parent)
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), menuName,
	{
		css =  'lscustom',
		title    = menuTitle,
		align    = 'top-right',
		elements = elems
	}, function(data, menu)
		local isRimMod, found = false, false
		local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

		if data.current.modType == "modFrontWheels" then
			isRimMod = true
		end

		for k,v in pairs(Config.Menus) do

			if k == data.current.modType or isRimMod then
				if (data.current.label == " ".._U('by_default') and GetVehicleMod(vehicle, v.modType) ~= -1) or string.match(data.current.label, _U('installed')) then
					ESX.ShowNotification(_U('already_own', data.current.label))
				else
					local vehiclePrice = 50000

					if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'autorepairs' then
						vehiclePrice = vehiclePrice*0.30
					end

					if isRimMod then
						price = math.floor(vehiclePrice * data.current.price / 100)
						--TriggerServerEvent("esx_lscustomautorepairsandy:buyMod", price)
						addPrice(k, price*2)
						myCar = ESX.Game.GetVehicleProperties(vehicle)
					elseif v.modType == 11 or v.modType == 12 or v.modType == 13 or v.modType == 15 or v.modType == 16 then
						price = math.floor(vehiclePrice * v.price[data.current.modNum + 1] / 100)
						--TriggerServerEvent("esx_lscustomautorepairsandy:buyMod", price)
						addPrice(k, price*2, v.modType)
						myCar = ESX.Game.GetVehicleProperties(vehicle)
					elseif v.modType == 17 then
						price = math.floor(vehiclePrice * v.price[1] / 100)
						--TriggerServerEvent("esx_lscustomautorepairsandy:buyMod", price)
						addPrice(k, price)
						myCar = ESX.Game.GetVehicleProperties(vehicle)
					elseif v.modType == 'modTires' then
						price = math.floor(vehiclePrice * v.price / 100)
						--TriggerServerEvent("esx_lscustomautorepairsandy:buyMod", price)
						addPrice(k, price)
						myCar = ESX.Game.GetVehicleProperties(vehicle)
					elseif v.modType == 'modTires' then
						price = math.floor(vehiclePrice * v.price / 100)
						--TriggerServerEvent("esx_lscustomautorepairsandy:buyMod", price)
						addPrice(k, price)
						myCar = ESX.Game.GetVehicleProperties(vehicle)
					else
						price = math.floor(vehiclePrice * v.price / 100)
						--TriggerServerEvent("esx_lscustomautorepairsandy:buyMod", price)
						myCar = ESX.Game.GetVehicleProperties(vehicle)
						addPrice(k, price*2, nil)
					end
				end

				menu.close()
				found = true
				break
			end

		end

		if not found then
			GetAction(data.current)
		end
	end, function(data, menu) -- on cancel
		menu.close()
		TriggerEvent('esx_lscustomautorepairsandy:cancelInstallMod')

		local playerPed = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(playerPed, false)
		SetVehicleDoorsShut(vehicle, false)

		if parent == nil then
			if totalPrice > 0 then
				OpenPayMenu()
			else
				menu.close()
				lsMenuIsShowed = false
				local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
				FreezeEntityPosition(vehicle, false)
				ESX.Game.SetVehicleProperties(vehicle, startCar)
				myCar = {}
				startCar = {}
			end
		end
	end, function(data, menu) -- on change
		UpdateMods(data.current)
	end)
end

function UpdateMods(data)
	local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

	if data.modType ~= nil then
		local props = {}

		if data.wheelType ~= nil then
			props['wheels'] = data.wheelType
			ESX.Game.SetVehicleProperties(vehicle, props)
			props = {}
		elseif data.modType == 'neonColor' then
			if data.modNum[1] == 0 and data.modNum[2] == 0 and data.modNum[3] == 0 then
				props['neonEnabled'] = { false, false, false, false }
			else
				props['neonEnabled'] = { true, true, true, true }
			end
			ESX.Game.SetVehicleProperties(vehicle, props)
			props = {}
		elseif data.modType == 'tyreSmokeColor' then
			props['modSmokeEnabled'] = true
			ESX.Game.SetVehicleProperties(vehicle, props)
			props = {}
		elseif data.modType == 'modTires' then
			local origProps = ESX.Game.GetVehicleProperties(vehicle)
			props['modFrontWheels'] = origProps['modFrontWheels']
			props['modTires'] = data.modNum
			ESX.Game.SetVehicleProperties(vehicle, props)
			props = {}
		elseif data.modType == 'color1' then
			props.color3 = nil
		elseif data.modType == 'color2' then
			props.color4 = nil
		end

		props[data.modType] = data.modNum
		ESX.Game.SetVehicleProperties(vehicle, props)
	end
end

function GetAction(data)
	local elements  = {}
	local menuName  = ''
	local menuTitle = ''
	local parent    = nil

	local playerPed = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(playerPed, false)
	local currentMods = ESX.Game.GetVehicleProperties(vehicle)

	if data.value == 'modSpeakers' or
		data.value == 'modTrunk' or
		data.value == 'modHydrolic' or
		data.value == 'modEngineBlock' or
		data.value == 'modAirFilter' or
		data.value == 'modStruts' or
		data.value == 'modTank' then
		SetVehicleDoorOpen(vehicle, 4, false)
		SetVehicleDoorOpen(vehicle, 5, false)
	elseif data.value == 'modDoorSpeaker' then
		SetVehicleDoorOpen(vehicle, 0, false)
		SetVehicleDoorOpen(vehicle, 1, false)
		SetVehicleDoorOpen(vehicle, 2, false)
		SetVehicleDoorOpen(vehicle, 3, false)
	else
		SetVehicleDoorsShut(vehicle, false)
	end

	local vehiclePrice = 50000

	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'autorepairs' then
		vehiclePrice = vehiclePrice*0.20
	end

	for k,v in pairs(Config.Menus) do

		if data.value == k then

			menuName  = k
			menuTitle = v.label
			parent    = v.parent

			if v.modType ~= nil then

				if v.modType == 22 then
					table.insert(elements, {label = " " .. _U('by_default'), modType = k, modNum = false})
				elseif v.modType == 'neonColor' or v.modType == 'tyreSmokeColor' then -- disable neon
					table.insert(elements, {label = " " ..  _U('by_default'), modType = k, modNum = {0, 0, 0}})
				elseif v.modType == 'color1' or v.modType == 'color2' or v.modType == 'pearlescentColor' or v.modType == 'wheelColor' then
					local num = myCar[v.modType]
					table.insert(elements, {label = " " .. _U('by_default'), modType = k, modNum = num})
				elseif v.modType == 17 then
					table.insert(elements, {label = " " .. _U('no_turbo'), modType = k, modNum = false})
				elseif v.modType == 'modTires' then
					table.insert(elements, {label = " " .. _U('by_default'), modType = k, modNum = false})
 				else
					table.insert(elements, {label = " " .. _U('by_default'), modType = k, modNum = -1})
				end

				if v.modType == 14 then -- HORNS
					for j = 0, 51, 1 do
						local _label = ''
						if j == currentMods.modHorns then
							_label = GetHornName(j) .. ' - <span style="color:cornflowerblue;">'.. _U('installed') ..'</span>'
						else
							price = math.floor(vehiclePrice * v.price / 100)
							_label = GetHornName(j) .. ' - <span style="color:green;">DKK' .. format_thousand(price) .. ' </span>'
						end
						table.insert(elements, {label = _label, modType = k, modNum = j})
					end
				elseif v.modType == 'plateIndex' then -- PLATES
					for j = 0, 4, 1 do
						local _label = ''
						if j == currentMods.plateIndex then
							_label = GetPlatesName(j) .. ' - <span style="color:cornflowerblue;">'.. _U('installed') ..'</span>'
						else
							price = math.floor(vehiclePrice * v.price / 100)
							_label = GetPlatesName(j) .. ' - <span style="color:green;">DKK' .. format_thousand(price) .. ' </span>'
						end
						table.insert(elements, {label = _label, modType = k, modNum = j})
					end
				elseif v.modType == 22 then -- NEON
					local _label = ''
					if currentMods.modXenon then
						_label = _U('neon') .. ' - <span style="color:cornflowerblue;">'.. _U('installed') ..'</span>'
					else
						price = math.floor(vehiclePrice * v.price / 50)
						_label = _U('neon') .. ' - <span style="color:green;">DKK' .. format_thousand(price) .. ' </span>'
					end
					table.insert(elements, {label = _label, modType = k, modNum = true})
				elseif v.modType == 'neonColor' or v.modType == 'tyreSmokeColor' then -- NEON & SMOKE COLOR
					local neons = GetNeons()
					price = math.floor(vehiclePrice * v.price / 50)
					for i=1, #neons, 1 do
						table.insert(elements, {
							label = '<span style="color:rgb(' .. neons[i].r .. ',' .. neons[i].g .. ',' .. neons[i].b .. ');">' .. neons[i].label .. ' - <span style="color:green;">DKK' .. format_thousand(price) .. '</span>',
							modType = k,
							modNum = { neons[i].r, neons[i].g, neons[i].b }
						})
					end
				elseif v.modType == 'color1' or v.modType == 'color2' or v.modType == 'pearlescentColor' or v.modType == 'wheelColor' then -- RESPRAYS
					local colors = GetColors(data.color)
					for j = 1, #colors, 1 do
						local _label = ''
						price = math.floor(vehiclePrice * v.price / 50)
						_label = colors[j].label .. ' - <span style="color:green;">DKK' .. format_thousand(price) .. ' </span>'
						table.insert(elements, {label = _label, modType = k, modNum = colors[j].index})
					end
				elseif v.modType == 'modHeadlight'  then -- HeadLight color
					local colors = GetHeadLights()
					for j = 1, #colors, 1 do
						local _label = ''
						price = math.floor(vehiclePrice * v.price / 50)
						_label = colors[j].label .. ' - <span style="color:green;">DKK' .. format_thousand(price) .. ' </span>'
						table.insert(elements, {label = _label, modType = k, modNum = colors[j].index})
					end
				elseif v.modType == 'windowTint' then -- WINDOWS TINT
					for j = 1, 5, 1 do
						local _label = ''
						if j == currentMods.modHorns then
							_label = GetWindowName(j) .. ' - <span style="color:cornflowerblue;">'.. _U('installed') ..'</span>'
						else
							price = math.floor(vehiclePrice * v.price / 100)
							_label = GetWindowName(j) .. ' - <span style="color:green;">DKK' .. format_thousand(price) .. ' </span>'
						end
						table.insert(elements, {label = _label, modType = k, modNum = j})
					end
				elseif v.modType == 23 then -- WHEELS RIM & TYPE
					local props = {}

					props['wheels'] = v.wheelType
					ESX.Game.SetVehicleProperties(vehicle, props)

					local modCount = GetNumVehicleMods(vehicle, v.modType)
					for j = 0, modCount, 1 do
						local modName = GetModTextLabel(vehicle, v.modType, j)
						if modName ~= nil then
							local _label = ''
							if j == currentMods.modFrontWheels then
								_label = GetLabelText(modName) .. ' - <span style="color:cornflowerblue;">'.. _U('installed') ..'</span>'
							else
								price = math.floor(vehiclePrice * v.price / 50)
								_label = GetLabelText(modName) .. ' - <span style="color:green;">DKK' .. format_thousand(price) .. ' </span>'
							end
							table.insert(elements, {label = _label, modType = 'modFrontWheels', modNum = j, wheelType = v.wheelType, price = v.price})
						end
					end
				elseif v.modType == 11 or v.modType == 12 or v.modType == 13 or v.modType == 15 or v.modType == 16 then
					local modCount = GetNumVehicleMods(vehicle, v.modType) -- UPGRADES
					for j = 0, modCount, 1 do
						local _label = ''
						if j == currentMods[k] then
							_label = _U('level', j+1) .. ' - <span style="color:cornflowerblue;">'.. _U('installed') ..'</span>'
						else
							price = math.floor(1000 * v.price[j+1])
							_label = _U('level', j+1) .. ' - <span style="color:green;">DKK' .. format_thousand(price) .. ' </span>'
						end
						table.insert(elements, {label = _label, modType = k, modNum = j})
						if j == modCount-1 then
							break
						end
					end
				elseif v.modType == 17 then -- TURBO
					local _label = ''
					if currentMods[k] then
						_label = 'Turbo - <span style="color:cornflowerblue;">'.. _U('installed') ..'</span>'
					else
						_label = 'Turbo - <span style="color:green;">DKK' .. format_thousand(math.floor(1000 * v.price[1])) .. ' </span>'
					end
					table.insert(elements, {label = _label, modType = k, modNum = true})
				elseif v.modType == 'modTires' then -- Tires
					local _label = ''
					if currentMods[k] then
						_label = 'Custom Dæk - <span style="color:cornflowerblue;">'.. _U('installed') ..'</span>'
					else
						_label = 'Custom Dæk - <span style="color:green;">DKK' .. format_thousand(math.floor(vehiclePrice * v.price / 100)) .. ' </span>'
					end
					table.insert(elements, {label = _label, modType = k, modNum = true})
				else
					local modCount = GetNumVehicleMods(vehicle, v.modType) -- BODYPARTS
					for j = 0, modCount, 1 do
						local modName = GetModTextLabel(vehicle, v.modType, j)
						if modName ~= nil then
							local _label = ''
							if j == currentMods[k] then
								_label = GetLabelText(modName) .. ' - <span style="color:cornflowerblue;">'.. _U('installed') ..'</span>'
							else
								price = math.floor(vehiclePrice * v.price / 50)
								_label = GetLabelText(modName) .. ' - <span style="color:green;">DKK' .. format_thousand(price) .. ' </span>'
							end
							table.insert(elements, {label = _label, modType = k, modNum = j})
						end
					end
				end
			else
				if data.value == 'primaryRespray' or data.value == 'secondaryRespray' or data.value == 'pearlescentRespray' or data.value == 'modFrontWheelsColor' then
					for i=1, #Config.Colors, 1 do
						if data.value == 'primaryRespray' then
							table.insert(elements, {label = Config.Colors[i].label, value = 'color1', color = Config.Colors[i].value})
						elseif data.value == 'secondaryRespray' then
							table.insert(elements, {label = Config.Colors[i].label, value = 'color2', color = Config.Colors[i].value})
						elseif data.value == 'pearlescentRespray' then
							table.insert(elements, {label = Config.Colors[i].label, value = 'pearlescentColor', color = Config.Colors[i].value})
						elseif data.value == 'modFrontWheelsColor' then
							table.insert(elements, {label = Config.Colors[i].label, value = 'wheelColor', color = Config.Colors[i].value})
						end
					end
				else
					for l,w in pairs(v) do
						if l ~= 'label' and l ~= 'parent' then
							if l == 'upgrades' then
								if (ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'autorepairs') then
									table.insert(elements, {label = w, value = l})
								end
							else
								table.insert(elements, {label = w, value = l})
							end
						end
					end
				end
			end
			break
		end
	end

	table.sort(elements, function(a, b)
		return a.label < b.label
	end)

	OpenLSMenu(elements, menuName, menuTitle, parent)
end

function OpenRepairMenu()
	local elements = {}
	local price = Config.DefaultRepairPrice

	if Config.UseCalculatedPrice == true then
		price = CalculateRepairPrice()
	end

	table.insert(elements, {
		label = _U('repair')..('<span style="color:green;">DKK%s</span>'):format(price),
		value = 'repair'
	})

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'ls_repair', {
		css =  'lscustom',
		title    = _U('blip_name'),
		align    = 'top-right',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'repair' then
			menu.close()
			TriggerServerEvent("esx_lscustomautorepairsandy:buyrepair",  price)
		end
	end, function(data, menu)
		menu.close()
		local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
		SetVehicleDoorsShut(vehicle, false)
		if parent == nil then
			menu.close()
			lsMenuIsShowed = false
			local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
			FreezeEntityPosition(vehicle, false)
			ESX.Game.SetVehicleProperties(vehicle, startCar)
			myCar = {}
			startCar = {}
		end
	end)
end

function CalculateRepairPrice()
	local price = 2000
	local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
	local vehiclePrice = 2500

	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'autorepairs' then
		vehiclePrice = vehiclePrice*0.20
	end

	price = price + ((1000-GetVehicleEngineHealth(vehicle))*22)
	price = price + ((1000-GetVehicleBodyHealth(vehicle))*22)


	for i = 0, 6, 1 do
		if IsVehicleTyreBurst(vehicle, i, false) then
			price = price + (10*20)
		end
	end

	for i = 0, 5, 1 do
		if IsVehicleDoorDamaged(vehicle, i) then
			price = price + (10*20)
		end
	end

	for i = 0, 5, 1 do
		if IsVehicleWindowIntact(vehicle, i) then
			price = price + (5*20)
		end
	end

	return math.ceil(price)
end

-- Blips
Citizen.CreateThread(function()
	for k,v in pairs(Config.Zones) do
		if (v.blip == false) then

		else
			local blip = AddBlipForCoord(v.Pos.x, v.Pos.y, v.Pos.z)
			SetBlipSprite(blip, v.sprite)
			SetBlipScale(blip, 0.7)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(v.Name)
			EndTextCommandSetBlipName(blip)
		end
	end
end)

-- local mechaniconline = false

-- Activate menu when player is inside marker
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()
		if IsPedInAnyVehicle(playerPed, false) then
			local coords      = GetEntityCoords(PlayerPedId())
			local currentZone = nil
			local zone 		  = nil
			local lastZone    = nil
			local vehicle = GetVehiclePedIsIn(playerPed, false)
			if (ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'autorepairs') or Config.IsMechanicJobOnly == false then
				for k,v in pairs(Config.Zones) do
					if GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x then
						isInLSMarker  = true
						IsSpecial = v.IsSpecial
						if not lsMenuIsShowed then
							ESX.ShowHelpNotification(v.Hint)
						end
						break
					else
						isInLSMarker  = false
					end
				end
			end

			if IsControlJustReleased(0, Keys['E']) and not lsMenuIsShowed and isInLSMarker then
				if not IsSpecial or (ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'autorepairs') then
					ESX.TriggerServerCallback("esx_lscutom:Checkjob", function(job)
						local Vehicle = GetVehiclePedIsUsing(PlayerPedId())
						for i = 0, 5 do
							local idk = IsVehicleDoorDamaged(Vehicle, i)
							if idk == 1 then
								SetVehicleDoorBroken(Vehicle, i, true)
							end
						end
						if GetVehicleEngineHealth(vehicle) > 995 and GetVehicleBodyHealth(vehicle) > 995 then
							lsMenuIsShowed = true
							FreezeEntityPosition(vehicle, true)
							startCar = ESX.Game.GetVehicleProperties(vehicle)
							TriggerServerEvent('esx_lscustomautorepairsandy:setStarterCarServer', startCar)
							myCar = ESX.Game.GetVehicleProperties(vehicle)
							ESX.UI.Menu.CloseAll()
							mainPrice = {}
							totalPrice = 0
							GetAction({value = 'main'})
						else
							if job < 3 then
								lsMenuIsShowed = true
								FreezeEntityPosition(vehicle, true)
								startCar = ESX.Game.GetVehicleProperties(vehicle)
								TriggerServerEvent('esx_lscustomautorepairsandy:setStarterCarServer', startCar)
								myCar = ESX.Game.GetVehicleProperties(vehicle)	
								ESX.UI.Menu.CloseAll()
								OpenRepairMenu()
							else
								lsMenuIsShowed = true
								FreezeEntityPosition(vehicle, true)
								startCar = ESX.Game.GetVehicleProperties(vehicle)
								TriggerServerEvent('esx_lscustomautorepairsandy:setStarterCarServer', startCar)
								myCar = ESX.Game.GetVehicleProperties(vehicle)
								ESX.UI.Menu.CloseAll()
								mainPrice = {}
								totalPrice = 0
								GetAction({value = 'main'})
							end
						end
					end)
				else
					ESX.ShowNotification(_U('no_permission'))
				end
			end

			if lsMenuIsShowed then
				if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'autorepairs' then
					ESX.ShowHelpNotification(_U('totalprice',format_thousand(totalPrice)))
				else
					ESX.ShowHelpNotification(_U('totalprice',format_thousand(totalPrice)))
				end
			end

			if isInLSMarker and not hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker = true
			end

			if not isInLSMarker and hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker = false
			end

		end
	end
end)

-- Prevent Free Tunning Bug
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if lsMenuIsShowed then
			-- DisableControlAction(2, Keys['F1'], true)
			-- DisableControlAction(2, Keys['F2'], true)
			-- DisableControlAction(2, 289, true)
			-- DisableControlAction(2, Keys['F3'], true)
			-- DisableControlAction(2, Keys['F6'], true)
			-- DisableControlAction(2, Keys['F7'], true)
			DisableControlAction(2, Keys['F'], true)
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
			if IsControlPressed(2, Keys['F1']) or IsControlPressed(2, Keys['F2']) or IsControlPressed(2, Keys['F3']) or IsControlPressed(2, Keys['F5']) or IsControlPressed(2, Keys['F6']) or IsControlPressed(2, Keys['F7']) or IsControlPressed(2, Keys['F9']) or IsControlPressed(2, Keys['ESC']) then
				ESX.UI.Menu.CloseAll()
				lsMenuIsShowed = false
				local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
				FreezeEntityPosition(vehicle, false)
				ESX.Game.SetVehicleProperties(vehicle, startCar)
				myCar = {}
				startCar = {}
			end
		else
			Citizen.Wait(500)
		end
	end
end)

-- Citizen.CreateThread(function()
-- 	while true do
-- 		Citizen.Wait(100)
-- 		ESX.TriggerServerCallback('esx_mechanicjob:getConnectedPlayers', function(connectedPlayers)
-- 			updatemechs(connectedPlayers)
-- 		end)
-- 		Citizen.Wait(120000)
-- 	end
-- end)

-- function updatemechs(connectedPlayers)
-- 	mechaniconline = false
-- 	for k,v in pairs(connectedPlayers) do
-- 		if v.job == 'mechanic' then
-- 			mechaniconline = true
-- 		end
-- 	end
-- end

function format_thousand(v)
	if type(v) == "number" or  type(v) == "integer" or type(v) == "vector2" or type(v) == "vector3"or type(v) == "vector4" then
		local s = string.format("%d", math.floor(v))
		local pos = string.len(s) % 3
		if pos == 0 then pos = 3 end
		return string.sub(s, 1, pos)
			.. string.gsub(string.sub(s, pos+1), "(...)", ",%1")
	end
	return 0
end
