ESX = nil
local PlayerData              	= {}
local currentZone               = ''
local LastZone                  = ''
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}

local alldeliveries             = {}
local spawns					= {}	
local randomdelivery            = 1
local isTaken                   = 0
local isDelivered               = 0
local car						= 0
local deliveryblip
local carCorrect 				= false
local carPlateChanged 			= false
local isChanging				= false
local isDeliving				= false
local color 					= ''

Citizen.CreateThread(function()
	while securityToken == nil do
		Citizen.Wait(100)
	end
end)

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

--Add all deliveries to the table
Citizen.CreateThread(function()
	local deliveryids = 1
	for k,v in pairs(Config.Delivery) do
		table.insert(alldeliveries, {
            id = deliveryids,
            posx = v.Pos.x,
            posy = v.Pos.y,
            posz = v.Pos.z,
            payment = v.Payment,
            car = v.Cars,
		})
		deliveryids = deliveryids + 1  
	end
end)

Citizen.CreateThread(function()
	local spawnids = 1
	for k,v in pairs(Config.Pickup) do
		table.insert(spawns, {
            id = spawnids,
            posx = v.Pos.x,
            posy = v.Pos.y,
            posz = v.Pos.z,
            payment = v.Payment,
            car = v.Cars,
		})
		spawnids = spawnids + 1  
	end
end)

function SpawnCar()
	ESX.TriggerServerCallback('frp-carthief:isActive', function(cooldown)
		if cooldown == nil or cooldown <= 0 then
			if cooldowntime == nil or cooldowntime <= 0 then
				isTaken = 1
				isDelivered = 0
				cooldowntime = 60000 * 15
				carCorrect = false
				carPlateChanged = false
			else
				ESX.ShowNotification("Du er allerede i gang med et job")
			end
		else
			if cooldown == nil then
				ESX.ShowNotification("Du kan ikke starte en ny mission endnu")
			elseif cooldown >= 0 then
				-- Format ms to minutes and seconds
				local minutes = math.floor(cooldown / 60000)
				local seconds = math.floor((cooldown % 60000) / 1000)
				ESX.ShowNotification("Vent " .. minutes .. ' min & ' .. seconds .. " sek, før du kan starte en ny mission")
			end
		end
	end)
end

function FinishDelivery()
	local coords = GetEntityCoords(PlayerPedId())
	v = alldeliveries[randomdelivery]
	local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
	local ped = PlayerPedId()

	if GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId()), -1) == PlayerPedId() and GetEntitySpeed(vehicle) < 3 and GetDistanceBetweenCoords(coords, v.posx, v.posy, v.posz, true) < 10 and GetVehicleNumberPlateText(vehicle) == "        " and not isDeliving then
		isDeliving = true
		-- Freeze car and disable controls
		FreezeEntityPosition(vehicle, true)
		DisableControlAction(0, 75, true)
		DisableControlAction(0, 76, true)
		DisableControlAction(0, 140, true)
		DisableControlAction(0, 141, true)
		DisableControlAction(0, 142, true)
		DisableControlAction(0, 143, true)
		DisableControlAction(0, 37, true)
		DisableControlAction(0, 25, true)

		FreezeEntityPosition(vehicle, true)

		-- progress bar
		exports['progressBars']:startUI(10000, "Aflevere bilen")
		Citizen.Wait(10000)


		--Delete Car
		SetEntityAsNoLongerNeeded(vehicle)
		DeleteEntity(vehicle)
		
		--Remove delivery zone
		RemoveBlip(deliveryblip)

		--Pay the poor fella
		TriggerServerEvent('frp-carthief:pay', securityToken, randomdelivery)

		--For delivery blip
		isTaken = 0

		--For delivery blip
		isDelivered = 1

		-- Reset cooldown
		cooldowntime = 0

		-- carCoorect false
		carCorrect = false
		carPlateChanged = false
		isDeliving = false
		
	else
		TriggerEvent('esx:showNotification', _U('car_provided_rule'))
	end
end

function AbortDelivery()
	--Delete Car
	SetEntityAsNoLongerNeeded(car)

	--Remove delivery zone
	RemoveBlip(deliveryblip)

	--For delivery blip
	isTaken = 0

	--For delivery blip
	isDelivered = 1

	-- Reset cooldown
	TriggerServerEvent('frp-carthief:setcooldownabort', securityToken)
	cooldowntime = 0

	-- carCoorect false
	carCorrect = false
	carPlateChanged = false
	isDeliving = false
end

-- Time to find car
Citizen.CreateThread(function()
	while true do
	  	Citizen.Wait(1000)
		if isTaken == 1 and isDelivered == 0 and cooldowntime > 0 then
			cooldowntime = cooldowntime - 1000
		end
		if isTaken == 1 and isDelivered == 0 and cooldowntime <= 0 then
			AbortDelivery()
		end
	end
end)

-- Draw 2d text on screen (for cooldowntime)
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if isTaken == 1 and isDelivered == 0 and cooldowntime > 0 then
			local minutes = math.floor(cooldowntime / 60000)
			local seconds = math.floor((cooldowntime % 60000) / 1000)
			local text = "Tid tilbage: " .. minutes .. " min & " .. seconds .. " sek"
			DrawText2D(0.50, 0.93, text, 0.45)
			if GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId(), false), -1) == PlayerPedId() then
				local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
				if GetVehicleNumberPlateText(vehicle) ~= "        " then
					local vehiclex = GetVehiclePedIsIn(PlayerPedId(), true)
					local distance = GetDistanceBetweenCoords(Config.ChangePlate.Pos.x, Config.ChangePlate.Pos.y, Config.ChangePlate.Pos.z, GetEntityCoords(PlayerPedId()), true)
					if distance < 6 then
						DrawText2D(0.50, 0.96, "Fjern nummerpladen på bilen", 0.45)
					else
						DrawText2D(0.50, 0.96, "Fjern nummerpladen ved sandy skrotplads", 0.45)
					end
					if carCorrect then
						--Delete old vehicle and remove the old blip (or nothing if there's no old delivery)
						RemoveBlip(deliveryblip)
						carCorrect = false
					end
					if not carPlateChanged then
						RemoveBlip(plateBlip)

						--Set plate blip
						plateBlip = AddBlipForCoord(Config.ChangePlate.Pos.x, Config.ChangePlate.Pos.y, Config.ChangePlate.Pos.z)
						SetBlipSprite(plateBlip, 1)
						SetBlipDisplay(plateBlip, 4)
						SetBlipScale(plateBlip, 1.0)
						SetBlipColour(plateBlip, 5)
						SetBlipAsShortRange(plateBlip, true)
						BeginTextCommandSetBlipName("STRING")
						AddTextComponentString("Fjern nummerplade")
						EndTextCommandSetBlipName(plateBlip)
						
						SetBlipRoute(plateBlip, true)

						carPlateChanged = true
					end
				else
					DrawText2D(0.50, 0.96, "Aflever bilen ved den markeret lokation", 0.45)
					if not carCorrect then
						--Delete old vehicle and remove the old blip (or nothing if there's no old delivery)
						RemoveBlip(deliveryblip)
						
						--Set delivery blip
						deliveryblip = AddBlipForCoord(alldeliveries[randomdelivery].posx, alldeliveries[randomdelivery].posy, alldeliveries[randomdelivery].posz)
						SetBlipSprite(deliveryblip, 1)
						SetBlipDisplay(deliveryblip, 4)
						SetBlipScale(deliveryblip, 1.0)
						SetBlipColour(deliveryblip, 5)
						SetBlipAsShortRange(deliveryblip, true)
						BeginTextCommandSetBlipName("STRING")
						AddTextComponentString("Aflever bilen")
						EndTextCommandSetBlipName(deliveryblip)
						
						SetBlipRoute(deliveryblip, true)

						carCorrect = true
					end
					if carPlateChanged then
						--Delete old vehicle and remove the old blip (or nothing if there's no old delivery)
						RemoveBlip(plateBlip)
						carPlateChanged = false
					end
				end
			else
				-- Get distance between player and Config.ChangePlate.Pos
				local vehiclex = GetVehiclePedIsIn(PlayerPedId(), true)
				local distance = GetDistanceBetweenCoords(Config.ChangePlate.Pos.x, Config.ChangePlate.Pos.y, Config.ChangePlate.Pos.z, GetEntityCoords(PlayerPedId()), true)
				if distance < 6 and vehiclex ~= 0 then
					if GetVehicleNumberPlateText(GetVehiclePedIsTryingToEnter(PlayerPedId())) ~= "        " then
						if GetVehicleNumberPlateText(vehiclex) == "        " then

							DrawText2D(0.50, 0.96, "Aflever bilen ved den markeret lokation", 0.45)
							RemoveBlip(plateBlip)
							carPlateChanged = false
							RemoveBlip(deliveryblip)
							
							--Set delivery blip
							deliveryblip = AddBlipForCoord(alldeliveries[randomdelivery].posx, alldeliveries[randomdelivery].posy, alldeliveries[randomdelivery].posz)
							SetBlipSprite(deliveryblip, 1)
							SetBlipDisplay(deliveryblip, 4)
							SetBlipScale(deliveryblip, 1.0)
							SetBlipColour(deliveryblip, 5)
							SetBlipAsShortRange(deliveryblip, true)
							BeginTextCommandSetBlipName("STRING")
							AddTextComponentString("Aflever bilen")
							EndTextCommandSetBlipName(deliveryblip)
							
							SetBlipRoute(deliveryblip, true)

							carCorrect = true
						else
							RemoveBlip(deliveryblip)
							carCorrect = false
							-- Get vehicle trunk position
							local trunkpos = GetOffsetFromEntityInWorldCoords(GetVehiclePedIsIn(PlayerPedId(), true), 0.0, -3.0, -0.5)
							local distance2 = GetDistanceBetweenCoords(trunkpos.x, trunkpos.y, trunkpos.z, GetEntityCoords(PlayerPedId()), true)

							-- Draw marker at trunk position
							DrawMarker(1, trunkpos.x, trunkpos.y, trunkpos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 100, false, true, 2, false, false, false, false)
							DrawText2D(0.50, 0.96, "Fjern nummerpladen på bilen", 0.45)
							if distance2 < 2 then

								-- Check if player pressed E
								-- ESX show help text
								ESX.ShowHelpNotification("Tryk ~INPUT_CONTEXT~ for at fjerne nummerplade")
								if IsControlPressed(0, 38) and not isChanging then
									isChanging = true
									-- Change plate
									FreezeEntityPosition(PlayerPedId(), true)
									TaskStartScenarioInPlace(PlayerPedId(), 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
									exports['progressBars']:startUI(5000, "Fjerner nummerplade")
									Citizen.Wait(5000)
									ClearPedTasks(PlayerPedId())
									local vehiclex = GetVehiclePedIsIn(PlayerPedId(), true)
									local plate = GetVehicleNumberPlateText(vehiclex)
									SetVehicleNumberPlateText(vehiclex, "        ")
									ESX.ShowNotification("Nummerplade er blevet fjernet")
									FreezeEntityPosition(PlayerPedId(), false)
									isChanging = false
								end
							end
						end
					end
				else
					DrawText2D(0.50, 0.96, "Stjæl en bil for at få mere information", 0.45)
					RemoveBlip(deliveryblip)
					carCorrect = false
				end
			end
		else
			Citizen.Wait(1000)
		end
	end
end)

AddEventHandler('frp-carthief:hasEnteredMarker', function(zone)
  if LastZone == 'cardelivered' then
    CurrentAction     = 'cardelivered_menu'
    CurrentActionMsg  = _U('drop_car_off')
    CurrentActionData = {zone = zone}
  end
end)

AddEventHandler('frp-carthief:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
    while true do
		Wait(0)
		local coords      = GetEntityCoords(PlayerPedId())
		local isInMarker  = false
		local currentZone = nil
      
		if isTaken == 1 and (GetDistanceBetweenCoords(coords, alldeliveries[randomdelivery].posx, alldeliveries[randomdelivery].posy, alldeliveries[randomdelivery].posz, true) < 3) then
			isInMarker  = true
			currentZone = 'cardelivered'
			LastZone    = 'cardelivered'
		end
        
		if isInMarker and not HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = true
			TriggerEvent('frp-carthief:hasEnteredMarker', currentZone)
		end
		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('frp-carthief:hasExitedMarker', LastZone)
		end
	end
end)

Citizen.CreateThread(function()
	local hash = GetHashKey("s_m_y_dealer_01")

	while not HasModelLoaded(hash) do
		RequestModel(hash)
		Citizen.Wait(0)
	end

	DealerPed = CreatePed("PED_TYPE_CIVMALE", "s_m_y_dealer_01", Config.Zones.VehicleSpawner.Pos.x, Config.Zones.VehicleSpawner.Pos.y, Config.Zones.VehicleSpawner.Pos.z + 0.2, 275.0, false, false)
	SetBlockingOfNonTemporaryEvents(DealerPed, true)
	SetPedDiesWhenInjured(DealerPed, false)
	SetPedCanPlayAmbientAnims(DealerPed, true)
	SetPedCanRagdollFromPlayerImpact(DealerPed, false)
	SetEntityInvincible(DealerPed, true)
	FreezeEntityPosition(DealerPed, true)
	SetModelAsNoLongerNeeded(hash)

	local pos = GetEntityCoords(DealerPed)
	exports["fivem-target"]:AddTargetPoint({
		name = "test_point",
		label = "Bil Tyveri",
		icon = "fas fa-car",
		point = pos,
		interactDist = 1.5,
		onInteract = onInteract,
		options = {
		  {
			name = "startMission",
			label = "Start Mission"
		  },
		  {
			name = "stopMission",
			label = "Anuller Mission"
		  }
		}
	})
end)

onInteract = function(targetName,optionName,vars,entityHit)
  	if optionName == "startMission" then
    	SpawnCar()
	elseif optionName == "stopMission" then
		AbortDelivery()
	end
end

-- Key Controls
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
	local sleep
    if CurrentAction ~= nil then
	  sleep = false
      SetTextComponentFormat('STRING')
      AddTextComponentString(CurrentActionMsg)
      DisplayHelpTextFromStringLabel(0, 0, 1, -1)
      if IsControlJustReleased(0, 38) then
        if CurrentAction == 'cardelivered_menu' then
          	FinishDelivery()
        end
        CurrentAction = nil
      end
    else
		sleep = true
	end
	if sleep then
		Citizen.Wait(1000)
	end
  end
end)

-- Display markers for delivery place
Citizen.CreateThread(function()
	while true do
		Wait(0)
		local sleep
		if isTaken == 1 and isDelivered == 0 then
			sleep = false
			local coords = GetEntityCoords(PlayerPedId())
			v = alldeliveries[randomdelivery]
			if (GetDistanceBetweenCoords(coords, v.posx, v.posy, v.posz, true) < Config.DrawDistance) then
				DrawMarker(1, v.posx, v.posy, v.posz, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 5.0, 5.0, 1.0, 204, 204, 0, 100, false, false, 2, false, false, false, false)
			end
		else
			sleep = true
		end
		if sleep then
			Citizen.Wait(1000)
		end
	end
end)

-- Create Blips for Car Spawner
Citizen.CreateThread(function()
    info = Config.Zones.VehicleSpawner
    info.blip = AddBlipForCoord(info.Pos.x, info.Pos.y, info.Pos.z)
    SetBlipSprite(info.blip, info.Id)
    SetBlipDisplay(info.blip, 4)
    SetBlipScale(info.blip, 1.0)
    SetBlipColour(info.blip, info.Colour)
    SetBlipAsShortRange(info.blip, true)
    BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(_U('vehicle_robbery'))
    EndTextCommandSetBlipName(info.blip)
end)

-- Function for drawtext3d
function DrawText3Ds(x,y,z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
	local scale = (1/dist)*2
	local fov = (1/GetGameplayCamFov())*100
	local scale = scale*fov
   
	if onScreen then
		SetTextScale(0.0*scale, 0.55*scale)
		SetTextFont(0)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 255)
		SetTextDropshadow(0, 0, 0, 0, 255)
		SetTextEdge(2, 0, 0, 0, 150)
		SetTextDropShadow()
		SetTextOutline()
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
		DrawText(_x,_y)
	end
end

-- Function for text drawing on screen
function DrawText2D(x, y, text, scale)
	SetTextScale(scale, scale)
	SetTextFont(4)
	SetTextEntry("STRING")
	SetTextCentre(1)
	SetTextColour(255, 255, 255, 215)
	SetTextOutline()
	AddTextComponentString(text)
	DrawText(x, y)
end
