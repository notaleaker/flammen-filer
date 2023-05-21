function ESX()
	local ESX = nil
	TriggerEvent(Config.ESXPrefix..":"..Config.getSharedObject, function(obj) ESX = obj end)
	return ESX
end

RegisterNetEvent(Config.EventPrefix..":giveKeys")
AddEventHandler(Config.EventPrefix..":giveKeys", function(vehicle)
	-- Leave blank if you have no keys to give
	
end)

RegisterNetEvent(Config.EventPrefix..":giveKeysTestDrive")
AddEventHandler(Config.EventPrefix..":giveKeysTestDrive", function(vehicle)
	-- Leave blank if you have no keys to give
end)

RegisterNetEvent(Config.EventPrefix..":giveKeysTowTruck")
AddEventHandler(Config.EventPrefix..":giveKeysTowTruck", function(vehicle)
	-- Leave blank if you have no keys to give
end)

RegisterNetEvent(Config.EventPrefix..":notification")
AddEventHandler(Config.EventPrefix..":notification", function(notifyName, text)
	local data = Config.NotificationsText[notifyName]

	exports['okokNotify']:Alert(data.title, text, data.time, data.type)
end)

RegisterNetEvent(Config.EventPrefix..":onMenuOpen")
AddEventHandler(Config.EventPrefix..":onMenuOpen", function()
	-- Code to execute when the player opens the vehicle shop
end)

RegisterNetEvent(Config.EventPrefix..":onMenuClose")
AddEventHandler(Config.EventPrefix..":onMenuClose", function()
	-- Code to execute when the player leaves the vehicle shop
end)

RegisterNetEvent(Config.EventPrefix..":onStartTestDrive")
AddEventHandler(Config.EventPrefix..":onStartTestDrive", function()
	-- Code to execute when the player starts the test drive
end)

RegisterNetEvent(Config.EventPrefix..":onFinishTestDrive")
AddEventHandler(Config.EventPrefix..":onFinishTestDrive", function(vehicle)
	-- Code to execute when the player finishes the test drive
end)

RegisterNetEvent(Config.EventPrefix..":onFinishMission")
AddEventHandler(Config.EventPrefix..":onFinishMission", function(vehicle)
	-- Code to execute when the player finishes a mission/order
end)

RegisterNetEvent(Config.EventPrefix..":createVehicleAfterBuying")
AddEventHandler(Config.EventPrefix..":createVehicleAfterBuying", function(vehicle_id, vehicle_name, id, vehicleColor, spawnLocationID)
	Citizen.Wait(1300)
	local playerPed = PlayerPedId()
	local spawnPos = vector3(Config.ShowVehicle[id].vehicleSpawn[spawnLocationID].x, Config.ShowVehicle[id].vehicleSpawn[spawnLocationID].y, Config.ShowVehicle[id].vehicleSpawn[spawnLocationID].z)
		
	ESX.Game.SpawnVehicle(vehicle_id, spawnPos, Config.ShowVehicle[id].vehicleSpawn[spawnLocationID].h, function (vehicle)
		while not DoesEntityExist(vehicle) do
			Citizen.Wait(20)
		end

		if vehicleColor == nil then
			if Config.UseColorID then
				SetVehicleColours(vehicle, Config.colors["color1"]["id"], Config.colors["color1"]["id"])
			else
				SetVehicleCustomPrimaryColour(vehicle, Config.colors["color1"][1], Config.colors["color1"][2], Config.colors["color1"][3])
				SetVehicleCustomSecondaryColour(vehicle, Config.colors["color1"][1], Config.colors["color1"][2], Config.colors["color1"][3])
			end
		else
			if Config.UseColorID then
				SetVehicleColours(vehicle, vehicleColor["id"], vehicleColor["id"])
			else
				SetVehicleCustomPrimaryColour(vehicle, vehicleColor[1], vehicleColor[2], vehicleColor[3])
				SetVehicleCustomSecondaryColour(vehicle, vehicleColor[1], vehicleColor[2], vehicleColor[3])
			end
		end
		
		local newPlate = GeneratePlate()
		local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)

		vehicleProps.plate = newPlate
		SetVehicleDirtLevel(vehicle, 0.0)
		SetVehicleNumberPlateText(vehicle, newPlate)
		TriggerEvent(Config.EventPrefix..":giveKeys", vehicle)
		exports['t1ger_keys']:SetVehicleLocked(vehicle, 0)
        
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		TriggerServerEvent(Config.EventPrefix..':setVehicleOwned', vehicleProps, vehicle_id, id)
		TriggerServerEvent('t1ger_keys:updateOwnedKeys', newPlate, true)
	end)
end)

-- Select vehicle

function spawnVehicle(model)
	local hash = GetHashKey(model)
	if not HasModelLoaded(hash) and IsModelInCdimage(hash) then
		RequestModel(hash)
		TriggerEvent(Config.EventPrefix..':notification', 'load_vehicle', notifyData['load_vehicle'].text)
		loadingVehicle = true
		while not HasModelLoaded(hash) do
				Citizen.Wait(10)
		end
	end
	loadingVehicle = false
	if selectedVehicle ~= nil then
		DeleteEntity(selectedVehicle)
		selectedVehicle = nil
	end

	if vehicleShopIsOpen then
		local position = Config.ShowVehicle[id].position

		selectedVehicle = CreateVehicle(hash, position.x, position.y, position.z, position.h, false, false)
		SetVehicleSteeringAngle(selectedVehicle, -30.0)
		SetEntityCollision(selectedVehicle, false)
		FreezeEntityPosition(selectedVehicle, true)
		WashDecalsFromVehicle(selectedVehicle, 1.0)
		SetVehicleDirtLevel(selectedVehicle, 0.0)
		SetPedIntoVehicle(PlayerPedId(), selectedVehicle, -1)

		if vehicleColor == nil then
			if Config.UseColorID then
				SetVehicleColours(selectedVehicle, Config.colors["color1"]["id"], Config.colors["color1"]["id"])
			else
				SetVehicleCustomPrimaryColour(selectedVehicle, Config.colors["color1"][1], Config.colors["color1"][2], Config.colors["color1"][3])
				SetVehicleCustomSecondaryColour(selectedVehicle, Config.colors["color1"][1], Config.colors["color1"][2], Config.colors["color1"][3])
			end
		else
			if Config.UseColorID then
				SetVehicleColours(selectedVehicle, vehicleColor["id"], vehicleColor["id"])
			else
				SetVehicleCustomPrimaryColour(selectedVehicle, vehicleColor[1], vehicleColor[2], vehicleColor[3])
				SetVehicleCustomSecondaryColour(selectedVehicle, vehicleColor[1], vehicleColor[2], vehicleColor[3])
			end
		end

		local vehicleData = {}

		local fInitialDriveMaxFlatVel = GetVehicleHandlingFloat(selectedVehicle, 'CHandlingData', 'fInitialDriveMaxFlatVel')
		if Config.UseKMh then
			vehicleData.topspeed = math.ceil(fInitialDriveMaxFlatVel * 1.3)
		else
			vehicleData.topspeed = math.ceil(fInitialDriveMaxFlatVel * 0.8)
		end

		vehicleData.acceleration = GetVehicleModelAcceleration(GetEntityModel(selectedVehicle))

		vehicleData.brakes = GetVehicleHandlingFloat(selectedVehicle, 'CHandlingData', 'fBrakeForce')

		local fTractionBiasFront = GetVehicleHandlingFloat(selectedVehicle, 'CHandlingData', 'fTractionBiasFront')
		local fTractionCurveMax = GetVehicleHandlingFloat(selectedVehicle, 'CHandlingData', 'fTractionCurveMax')
		local fTractionCurveMin = GetVehicleHandlingFloat(selectedVehicle, 'CHandlingData', 'fTractionCurveMin')
		vehicleData.handling = (fTractionBiasFront + fTractionCurveMax * fTractionCurveMin)
			
		SendNUIMessage({
			action = 'afterSpawningVehicle',
			id = model,
			brand = brand,
			model = vehiclemodel,
			price = price,
			data = vehicleData,
			maxSpeed = Config.MaxVehiclesSpeed,
		})

		RenderScriptCams(0)
		DestroyAllCams(true)
		startCamAnimation()
	end
end

-- Mission/Order

RegisterNetEvent(Config.EventPrefix..":startMission")
AddEventHandler(Config.EventPrefix..":startMission", function(vehicle_id, mission_id, businessName)
	local hash = GetHashKey(Config.SmallTowTruckID)
	local trailerHash = GetHashKey(Config.TrailerID)
	local vehicleHash = GetHashKey(vehicle_id)
	local ped = PlayerPedId()
	local isTowed = false
	local shown = false
	local isLocked = true

	if not shopHasBigVehicles then
		hash = GetHashKey(Config.SmallTowTruckID)
	else
		hash = GetHashKey(Config.BigTowTruckID)

		if not HasModelLoaded(trailerHash) then
			RequestModel(trailerHash)
			while not HasModelLoaded(trailerHash) do
				Citizen.Wait(10)
			end
		end
	end

	doingMission = true

	if not HasModelLoaded(hash) then
		RequestModel(hash)
		while not HasModelLoaded(hash) do
			Citizen.Wait(10)
		end
	end

	if not HasModelLoaded(vehicleHash) then
		RequestModel(vehicleHash)
		while not HasModelLoaded(vehicleHash) do
			Citizen.Wait(10)
		end
	end

	if missionTruck ~= nil then
		DeleteEntity(missionTruck)
		missionTruck = nil
	end

	missionTruck = CreateVehicle(hash, spawnTruckMission.x, spawnTruckMission.y, spawnTruckMission.z, spawnTruckMission.h, true, false)
	SetVehicleDirtLevel(missionTruck, 0.0)
	TriggerEvent(Config.EventPrefix..":giveKeysTowTruck", missionTruck)
	if shopHasBigVehicles then
		local trailerCoords = GetOffsetFromEntityInWorldCoords(missionTruck, 0.0, -10.5, 0.0)
		missionTrailer = CreateVehicle(trailerHash, trailerCoords.x, trailerCoords.y, trailerCoords.z, spawnTruckMission.h, true, false)
		SetVehicleDirtLevel(missionTrailer, 0.0)
	end

	SetVehicleDoorsLockedForAllPlayers(missionTruck, true)

	while not DoesEntityExist(missionTruck) do
		Citizen.Wait(100)
	end
	TriggerEvent(Config.EventPrefix..':notification', 'got_to_truck', notifyData['got_to_truck'].text)

	missionBlips.truck = AddBlipForCoord(spawnTruckMission.x, spawnTruckMission.y, spawnTruckMission.z)
	SetBlipSprite(missionBlips.truck, Config.TruckBlip.blipId)
	SetBlipDisplay(missionBlips.truck, 4)
	SetBlipScale(missionBlips.truck, Config.TruckBlip.blipScale)
	SetBlipColour(missionBlips.truck, Config.TruckBlip.blipColor)
	SetBlipAsShortRange(missionBlips.truck, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(Config.TruckBlip.blipText)
	EndTextCommandSetBlipName(missionBlips.truck)

	if missionBlips.trailer == nil then
		local trailerCoords = GetEntityCoords(missionTrailer)
		missionBlips.trailer = AddBlipForCoord(trailerCoords.x, trailerCoords.y, trailerCoords.z)
		SetBlipSprite(missionBlips.trailer, Config.TrailerBlip.blipId)
		SetBlipDisplay(missionBlips.trailer, 4)
		SetBlipScale(missionBlips.trailer, Config.TrailerBlip.blipScale)
		SetBlipColour(missionBlips.trailer, Config.TrailerBlip.blipColor)
		SetBlipAsShortRange(missionBlips.trailer, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(Config.TrailerBlip.blipText)
		EndTextCommandSetBlipName(missionBlips.trailer)
	end

	local hasTrailer = true
	local setFuel = true
	local failedToLoad = false
	local inVehicleRange = false

	while doingMission do
		Citizen.Wait(1)
		local waitMore = true
		local inZone = false
		if missionCanceled then break end
		if shopHasBigVehicles then
			hasTrailer = GetVehicleTrailerVehicle(missionTruck)
		end

		if GetVehiclePedIsIn(ped, false) == missionTruck then
			if setFuel then
				if GetIsVehicleEngineRunning(missionTruck) then
					setFuel = false
					SetVehicleFuelLevel(missionTruck, 100.0)
				end
			end
			if hasTrailer then
				if missionBlips.trailer ~= nil then
					RemoveBlip(missionBlips.trailer)
						missionBlips.trailer = nil
				end
				local playerCoords = GetEntityCoords(ped)
				if not isTowed then
					local distance = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, mission.x, mission.y, mission.z)
					if distance < 250 and missionVehicle == nil then
						missionVehicle = CreateVehicle(vehicleHash, mission.x, mission.y, mission.z, mission.h, true, false)

						local time = 0
						while not DoesEntityExist(missionVehicle) do
							Citizen.Wait(10)
							time = time + 10
							if time >= 5000 then
								failedToLoad = true
								TriggerEvent(Config.EventPrefix..':notification', 'failed_to_load', notifyData['failed_to_load'].text)
								break
							end
						end

						if not inVehicleRange then
							local coord = GetEntityCoords(missionVehicle)
							if missionBlips.order ~= nil then
								RemoveBlip(missionBlips.order)
								missionBlips.order = nil
							end
							if missionBlips.order == nil then
								missionBlips.order = AddBlipForCoord(coord.x, coord.y, coord.z)
								SetBlipSprite(missionBlips.order, Config.OrderBlip.blipId)
								SetBlipColour(missionBlips.order, Config.OrderBlip.blipColor)
								SetBlipAsShortRange(missionBlips.order, false)
								BeginTextCommandSetBlipName("STRING")
								AddTextComponentString(Config.OrderBlip.blipText)
								EndTextCommandSetBlipName(missionBlips.order)
								SetBlipRoute(missionBlips.order, 1)
							end
							inVehicleRange = true
						end

						if not failedToLoad then
							SetVehicleDirtLevel(missionVehicle, 0.0)
							SetVehicleDoorsLockedForAllPlayers(missionVehicle, true)
						else
							DeleteEntity(missionVehicle)
							missionVehicle = nil
							if missionBlips.order ~= nil then
								RemoveBlip(missionBlips.order)
								missionBlips.order = nil
							end
							isTowed = true
						end
					end
				else
					local distance = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, spawnTruckMission.x, spawnTruckMission.y, spawnTruckMission.z)
					if distance < 100 then
						waitMore = false
						DrawMarker(Config.TowMarker.id, spawnTruckMission.x, spawnTruckMission.y, spawnTruckMission.z, 0, 0, 0, 0, 0, 0, Config.TowMarker.size.x, Config.TowMarker.size.y, Config.TowMarker.size.z, Config.TowMarker.color.r, Config.TowMarker.color.g, Config.TowMarker.color.b, Config.TowMarker.color.a, Config.TowMarker.bobUpAndDown, Config.TowMarker.faceCamera, 2, Config.TowMarker.rotate, 0, 0, Config.TowMarker.drawOnEnts)
						if distance < 5 then
							break
						end
					end
				end

				if not isTowed then
					if missionBlips.order == nil then
						missionBlips.order = AddBlipForCoord(mission.x, mission.y, mission.z)
						SetBlipSprite(missionBlips.order, Config.OrderBlip.blipId)
						SetBlipColour(missionBlips.order, Config.OrderBlip.blipColor)
						SetBlipAsShortRange(missionBlips.order, false)
						BeginTextCommandSetBlipName("STRING")
						AddTextComponentString(Config.OrderBlip.blipText)
						EndTextCommandSetBlipName(missionBlips.order)
						SetBlipRoute(missionBlips.order, 1)
					end
				else
					if missionBlips.order == nil then
						missionBlips.order = AddBlipForCoord(spawnTruckMission.x, spawnTruckMission.y, spawnTruckMission.z)
						SetBlipSprite(missionBlips.order, Config.OrderBlip.blipId)
						SetBlipColour(missionBlips.order, Config.OrderBlip.blipColor)
						SetBlipAsShortRange(missionBlips.order, false)
						BeginTextCommandSetBlipName("STRING")
						AddTextComponentString(Config.OrderBlip.blipText)
						EndTextCommandSetBlipName(missionBlips.order)
						SetBlipRoute(missionBlips.order, 1)
					end
				end
			else
				if missionBlips.order ~= nil then
					RemoveBlip(missionBlips.order)
					missionBlips.order = nil
				end

				if missionBlips.trailer == nil then
					local trailerCoords = GetEntityCoords(missionTrailer)
					missionBlips.trailer = AddBlipForCoord(trailerCoords.x, trailerCoords.y, trailerCoords.z)
					SetBlipSprite(missionBlips.trailer, Config.TrailerBlip.blipId)
					SetBlipDisplay(missionBlips.trailer, 4)
					SetBlipScale(missionBlips.trailer, Config.TrailerBlip.blipScale)
					SetBlipColour(missionBlips.trailer, Config.TrailerBlip.blipColor)
					SetBlipAsShortRange(missionBlips.trailer, true)
					BeginTextCommandSetBlipName("STRING")
					AddTextComponentString(Config.TrailerBlip.blipText)
					EndTextCommandSetBlipName(missionBlips.trailer)
				end
			end

			if missionBlips.truck ~= nil then
				RemoveBlip(missionBlips.truck)
					missionBlips.truck = nil
				end

			elseif GetVehiclePedIsIn(ped, false) == 0 then
				local playerCoords = GetEntityCoords(ped)
				local truckCoordsForLocking = GetEntityCoords(missionTruck)
				local distance = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, truckCoordsForLocking.x, truckCoordsForLocking.y, truckCoordsForLocking.z)

				if distance < 8 and isLocked then
					isLocked = false
					SetVehicleDoorsLockedForAllPlayers(missionTruck, false)
				elseif distance > 8 and not isLocked then
					isLocked = true
					SetVehicleDoorsLockedForAllPlayers(missionTruck, true)
				end

				if missionBlips.truck == nil then
					local truckCoords = GetEntityCoords(missionTruck)
					missionBlips.truck = AddBlipForCoord(truckCoords.x, truckCoords.y, truckCoords.z)
					SetBlipSprite(missionBlips.truck, Config.TruckBlip.blipId)
					SetBlipDisplay(missionBlips.truck, 4)
					SetBlipScale(missionBlips.truck, Config.TruckBlip.blipScale)
					SetBlipColour(missionBlips.truck, Config.TruckBlip.blipColor)
					SetBlipAsShortRange(missionBlips.truck, true)
					BeginTextCommandSetBlipName("STRING")
					AddTextComponentString(Config.TruckBlip.blipText)
					EndTextCommandSetBlipName(missionBlips.truck)
				end

				if hasTrailer then
				if missionBlips.trailer ~= nil then
					RemoveBlip(missionBlips.trailer)
						missionBlips.trailer = nil
				end
				if missionVehicle ~= nil then
					waitMore = false
					local truckCoords = nil 
					if shopHasBigVehicles then
						truckCoords = GetOffsetFromEntityInWorldCoords(missionTrailer, 0.0, -7.5, 0.0)
					else
						truckCoords = GetOffsetFromEntityInWorldCoords(missionTruck, 0.0, -6.5, 0.0)
					end

					local orderCoords = GetEntityCoords(missionVehicle)
					local distanceTruck = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, truckCoords.x, truckCoords.y, truckCoords.z)
					local distanceOrder = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, orderCoords.x, orderCoords.y, orderCoords.z)
					if not isTowed then
						DrawMarker(Config.TowMarker.id, truckCoords.x, truckCoords.y, truckCoords.z, 0, 0, 0, 0, 0, 0, Config.TowMarker.size.x, Config.TowMarker.size.y, Config.TowMarker.size.z, Config.TowMarker.color.r, Config.TowMarker.color.g, Config.TowMarker.color.b, Config.TowMarker.color.a, Config.TowMarker.bobUpAndDown, Config.TowMarker.faceCamera, 2, Config.TowMarker.rotate, 0, 0, Config.TowMarker.drawOnEnts)
						if distanceTruck < 1 then
							inZone = true
							
							if not Config.UseOkokTextUI then
								ESX.ShowHelpNotification(Config.HelpNotification['tow'].text)
							end

							if IsControlJustReleased(0, Config.Key) then
								local maxDistance = 6

								if shopHasBigVehicles then
									maxDistance = 8
								end

								if distanceOrder < maxDistance then
									isTowed = true
									if not shopHasBigVehicles then
										AttachEntityToEntity(missionVehicle, missionTruck, towCoords.bone, towCoords.xPos, towCoords.yPos, towCoords.zPos, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
									else
										AttachEntityToEntity(missionVehicle, missionTrailer, towCoords.bone, towCoords.xPos, towCoords.yPos, towCoords.zPos, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
									end

									if missionBlips.order ~= nil then
										RemoveBlip(missionBlips.order)
											missionBlips.order = nil
									end

									if missionBlips.order == nil then
										missionBlips.order = AddBlipForCoord(spawnTruckMission.x, spawnTruckMission.y, spawnTruckMission.z)
										SetBlipSprite(missionBlips.order, Config.OrderBlip.blipId)
										SetBlipColour(missionBlips.order, Config.OrderBlip.blipColor)
										SetBlipAsShortRange(missionBlips.order, false)
										BeginTextCommandSetBlipName("STRING")
										AddTextComponentString(Config.OrderBlip.blipText)
										EndTextCommandSetBlipName(missionBlips.order)
										SetBlipRoute(missionBlips.order, 1)
									end
									TriggerEvent(Config.EventPrefix..':notification', 'towed', notifyData['towed'].text)
								else
									TriggerEvent(Config.EventPrefix..':notification', 'not_towing', notifyData['not_towing'].text)
								end
							end
						end
					end
				end
			else
				if missionBlips.trailer == nil then
					local trailerCoords = GetEntityCoords(missionTrailer)
					missionBlips.trailer = AddBlipForCoord(trailerCoords.x, trailerCoords.y, trailerCoords.z)
					SetBlipSprite(missionBlips.trailer, Config.TrailerBlip.blipId)
					SetBlipDisplay(missionBlips.trailer, 4)
					SetBlipScale(missionBlips.trailer, Config.TrailerBlip.blipScale)
					SetBlipColour(missionBlips.trailer, Config.TrailerBlip.blipColor)
					SetBlipAsShortRange(missionBlips.trailer, true)
					BeginTextCommandSetBlipName("STRING")
					AddTextComponentString(Config.TrailerBlip.blipText)
					EndTextCommandSetBlipName(missionBlips.trailer)
				end
			end
		end

		if Config.UseOkokTextUI then
			if not shown and inZone then
				shown = true
				exports['okokTextUI']:Open(Config.TextUI['tow'].text, Config.TextUI['tow'].color, Config.TextUI['tow'].side)
			elseif shown and not inZone then
				shown = false
				exports['okokTextUI']:Close()
			end
		end

		if waitMore then
			Citizen.Wait(1000)
		end
	end

	if missionBlips.truck ~= nil then
		RemoveBlip(missionBlips.truck)
		missionBlips.truck = nil
	end

	if missionBlips.order ~= nil then
		RemoveBlip(missionBlips.order)
			missionBlips.order = nil
	end
	TriggerEvent(Config.EventPrefix..":onFinishMission", missionTruck)
	if missionTruck ~= nil then
		DeleteEntity(missionTruck)
		missionTruck = nil
	end

	if missionTrailer ~= nil then
		DeleteEntity(missionTrailer)
		missionTrailer = nil
	end

	if missionVehicle ~= nil then
		DeleteEntity(missionVehicle)
		missionVehicle = nil
	end
	if not missionCanceled then
		TriggerServerEvent(Config.EventPrefix..":endMission", mission_id, businessName)
	end
end)

-- Plate generation


local NumberCharset = {}
local Charset = {}

for i = 48,	57 do table.insert(NumberCharset, string.char(i)) end

for i = 65,	90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

function GeneratePlate()
	local generatedPlate
	local doBreak = false

	while true do
		Citizen.Wait(0)
		math.randomseed(GetGameTimer())
		if Config.PlateUseSpace then
			generatedPlate = string.upper(GetRandomLetter(Config.PlateLetters) .. ' ' .. GetRandomNumber(Config.PlateNumbers))
		else
			generatedPlate = string.upper(GetRandomLetter(Config.PlateLetters) .. GetRandomNumber(Config.PlateNumbers))
		end

		ESX.TriggerServerCallback(Config.EventPrefix..':isPlateTaken', function (isPlateTaken)
			if not isPlateTaken then
				doBreak = true
			end
		end, generatedPlate)

		if doBreak then
			break
		end
	end

	return generatedPlate
end

function GetRandomNumber(length)
	Citizen.Wait(1)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
	else
		return ''
	end
end

function GetRandomLetter(length)
	Citizen.Wait(1)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
	else
		return ''
	end
end