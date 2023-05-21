
local enabled = Config.defaultEnabled

local Lang		= Config.Strings
local Controls	= Config.Controls

local attachedRamps = {}

local attachNotif



-- delete ramps when vehicle gets unloaded
Citizen.CreateThread(function()
	while (true) do
		Citizen.Wait(0)

		-- deleting ramps
		for vehicle, ramp in pairs(attachedRamps) do
			if (not DoesEntityExist(vehicle)) then
				DeleteEntity(ramp)
				attachedRamps[vehicle] = nil
				break
			end
		end
	end
end)

-- delete ramps on resource stop
AddEventHandler("onResourceStop", function(name)
	if (name ~= GetCurrentResourceName()) then
		return
	end

	for vehicle, ramp in pairs(attachedRamps) do
		if (DoesEntityExist(ramp)) then
			DeleteEntity(ramp)
		end
	end
end)



function StartVehicleTransport()
	-- load transport data from file
	LoadTransportVehicleData()

	local closestVehicle, closestTransport, transport
	local playerPos

	local inRampArea		= false
	local inDoorArea		= false
	local inTransportArea	= false
	local vehicleAttached	= false

	-- get closest vehicles
	Citizen.CreateThread(function()
		while (enabled) do
			Citizen.Wait(2000)

			local clientVehicles = GetGamePool("CVehicle")
			closestVehicle = GetClosestVehicleNoTransport(playerPos, 10.0, clientVehicles)
			closestTransport, transport = GetClosestTransportVehicle(playerPos, 50.0, clientVehicles)
		end
	end)

	-- check player position
	Citizen.CreateThread(function()
		while (enabled) do
			Citizen.Wait(250)

			inRampArea		= false
			inDoorArea		= false
			inTransportArea	= false
			vehicleAttached	= false

			local playerPed	= PlayerPedId()
			playerPos		= GetEntityCoords(playerPed)

			if (DoesEntityExist(closestTransport)) then
				if (not IsPedInAnyVehicle(playerPed)) then
					if (transport.RampModelHash ~= -1 and #(WorldToLocal(closestTransport, playerPos) - transport.RampPosition) < 5.0) then
						inRampArea = true
					elseif (transport.DoorIndex and #(WorldToLocal(closestTransport, playerPos) - transport.DoorPosition) < 5.0) then
						inDoorArea = true
					end
				elseif (DoesEntityExist(closestVehicle) and closestVehicle == GetVehiclePedIsIn(playerPed) and IsInTransportArea(WorldToLocal(closestTransport, GetEntityCoords(closestVehicle)), transport)) then
					inTransportArea = true

					vehicleAttached = IsEntityAttached(closestVehicle)
				end
			end
		end
	end)

	-- input and UI stuff
	Citizen.CreateThread(function()
		while (enabled) do
			Citizen.Wait(0)

			-- ramp interaction
			if (inRampArea) then
				ShowHelpText(Lang.toggleRampHelpText)

				if (IsControlJustPressed(0, Controls.toggleRamp)) then
					ToggleRamp(closestTransport)
				end
			elseif (inDoorArea) then
				ShowHelpText(Lang.toggleRampHelpText)

				if (IsControlJustPressed(0, Controls.toggleRamp)) then
					ToggleDoor(closestTransport, transport)
				end
			end

			-- attach/detach interaction
			if (inTransportArea) then
				if (vehicleAttached) then
					ShowHelpText(Lang.detachHelpText)

					if (IsControlJustPressed(0, Controls.attach)) then
						DetachVehicle(closestVehicle)
					end
				else
					ShowHelpText(Lang.attachHelpText)

					if (IsControlJustPressed(0, Controls.attach)) then
						AttachVehicle(closestVehicle, closestTransport)
					end
				end
			end
		end
	end)
end

function Enable(enable)
	enabled = enable

	if (enabled) then
		StartVehicleTransport()
	end
end
exports("Enable", Enable)
AddEventHandler("VT:enable", Enable)

if (enabled) then
	StartVehicleTransport()
end



function AttachVehicle(vehicle, transportVehicle)
	if (not DoesEntityExist(vehicle) or not DoesEntityExist(transportVehicle)) then
		return
	end

	if (#(GetEntityVelocity(vehicle) - GetEntityVelocity(transportVehicle)) > Config.maxAttachSpeedDiff) then
		attachNotif = ShowNotification(Lang.vehicleTooFastNotif, attachNotif)
	else
		LogDebug("Attaching vehicle \"%s\" to transport \"%s\"", GetVehicleNumberPlateText(vehicle), GetVehicleNumberPlateText(transportVehicle))

		local offset = WorldToLocal(transportVehicle, GetEntityCoords(vehicle))
		local rotationOffset = GetEntityRotation(vehicle) - GetEntityRotation(transportVehicle)
		AttachEntityToEntity(vehicle, transportVehicle, -1, offset, rotationOffset, false, false, true, false, 2, true)

		attachNotif = ShowNotification(Lang.vehicleAttachedNotif, attachNotif)

		TriggerServerEvent("VT:vehicleAttached", NetworkGetNetworkIdFromEntity(vehicle), NetworkGetNetworkIdFromEntity(transportVehicle))
	end
end
function DetachVehicle(vehicle)
	if (not DoesEntityExist(vehicle)) then
		return
	end

	LogDebug("Detaching vehicle \"%s\"", GetVehicleNumberPlateText(vehicle))

	DetachEntity(vehicle)

	attachNotif = ShowNotification(Lang.vehicleDetachedNotif, attachNotif)

	TriggerServerEvent("VT:vehicleDetached", NetworkGetNetworkIdFromEntity(vehicle))
end

function ToggleRamp(transportVehicle)
	TriggerServerEvent(
		"VT:rampState", 
		NetworkGetNetworkIdFromEntity(transportVehicle), 
		Entity(transportVehicle).state.vt_rampAttached
	)
end

function ToggleDoor(transportVehicle, transport)
	if (GetVehicleDoorLockStatus(transportVehicle) == 2) then
		ShowNotification(Lang.vehicleLockedNotif)
		return
	end

	if (NetworkHasControlOfEntity(transportVehicle)) then
		ToggleDoorOnVehicle(transportVehicle, transport.DoorIndex)
	else
		TriggerServerEvent("VT:toggleDoorNet", NetworkGetNetworkIdFromEntity(transportVehicle), transport.DoorIndex)
	end
end
function ToggleDoorOnVehicle(vehicle, doorIndex)
	if (GetVehicleDoorAngleRatio(vehicle, doorIndex) < 0.1) then
		SetVehicleDoorOpen(vehicle, doorIndex, false, false)
	else
		SetVehicleDoorShut(vehicle, doorIndex, false)
	end
end
RegisterNetEvent("VT:toggleDoorNet", function(networkId, doorIndex)
	local vehicle = NetworkGetEntityFromNetworkId(networkId)
	if (not DoesEntityExist(vehicle) or not NetworkHasControlOfEntity(vehicle)) then return end

	ToggleDoorOnVehicle(vehicle, doorIndex)
end)

function AttachRamp(vehicle)
	LogDebug("Attaching ramp to %s", vehicle)

	local transport = GetTransportFromVehicle(vehicle)
	if (not transport) then
		return
	end

	local model = transport.RampModelHash
	if (not HasModelLoaded(model)) then
		RequestModel(model)
		while (not HasModelLoaded(model)) do
			Citizen.Wait(0)
		end
	end

	local ramp = CreateObjectNoOffset(model, GetEntityCoords(vehicle) + vector3(0.0, 0.0, -5.0), false, true)
	AttachEntityToEntity(ramp, vehicle, -1, transport.RampPosition, transport.RampRotation, false, false, true, false, 2, true)

	attachedRamps[vehicle] = ramp
end
function DeleteRamp(vehicle)
	LogDebug("Deleting ramp from %s", vehicle)

	if (DoesEntityExist(attachedRamps[vehicle])) then
		DeleteEntity(attachedRamps[vehicle])
		attachedRamps[vehicle] = nil
	end
end

AddStateBagChangeHandler("vt_rampAttached", nil, function(bagName, key, value, _unused, replicated)
	if (bagName:find("entity") == nil) then
		return
	end

	local networkIdString = bagName:gsub("entity:", "")
	local networkId = tonumber(networkIdString)
	if (not WaitUntilEntityWithNetworkIdExists(networkId, 5000)) then
		return
	end

	local vehicle = NetworkGetEntityFromNetworkId(networkId)

	if (value) then
		AttachRamp(vehicle)
		SetEntityMaxSpeed(vehicle, Config.deployedRampSpeed)
	else
		DeleteRamp(vehicle)
		SetEntityMaxSpeed(vehicle, 200.0)
	end
end)

RegisterNetEvent("VT:vehicleAttached")
RegisterNetEvent("VT:vehicleDetached")



-- get the closest vehicle that is not a transport
function GetClosestVehicleNoTransport(position, maxRadius, vehicles)
	local distance = maxRadius or 1000.0
	local closestVehicle

	for i, vehicle in ipairs(vehicles or GetGamePool("CVehicle")) do
		if (not IsVehicleATransport(vehicle)) then
			local dist = #(GetEntityCoords(vehicle) - position)
			if (dist < distance) then
				distance = dist
				closestVehicle = vehicle
			end
		end
	end

	return closestVehicle
end

-- get the closest transport vehicle
function GetClosestTransportVehicle(position, maxRadius, vehicles)
	local distance = maxRadius or 1000.0
	local closestTransportVehicle, closestTransport

	for i, vehicle in ipairs(vehicles or GetGamePool("CVehicle")) do
		local transport = GetTransportFromVehicle(vehicle)
		if (transport) then
			local dist = #(GetEntityCoords(vehicle) - position)
			if (dist < distance) then
				distance = dist
				closestTransportVehicle = vehicle
				closestTransport = transport
			end
		end
	end

	return closestTransportVehicle, closestTransport
end

-- show help text in upper left corner
function ShowHelpText(text)
	BeginTextCommandDisplayHelp("CELL_EMAIL_BCON")
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayHelp(0, false, false, -1)
end

-- show notification above the map
function ShowNotification(text, notificationId)
	if (notificationId) then
		RemoveNotification(notificationId)
	end

	SetNotificationTextEntry('STRING')
	AddTextComponentSubstringPlayerName(text)
	return DrawNotification(false, true)
end
