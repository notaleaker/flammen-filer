ESX, QBCore = nil, nil

local vehiclesToDelete = {}
local vehicleTrailersNotToDelete = {}

Citizen.CreateThread(function()
	if Config.Framework == "esx" then
		while ESX == nil do
			TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
			Citizen.Wait(0)
		end
	end
end)

if Config.Framework == "qbcore" then
	QBCore = exports["qb-core"]:GetCoreObject()
end

function _L(str)
	if not Locale then return "Locale error" end
	if not Locale[Config.locale] then return "Invalid locale" end
	if not Locale[Config.locale][str] then return "Invalid string" end
	return Locale[Config.locale][str]
end

Citizen.CreateThread(function()
	for i = 1, #Config.SafeZones, 1 do
		local blip = AddBlipForRadius(Config.SafeZones[i].x, Config.SafeZones[i].y, Config.SafeZones[i].z, Config.SafeZones[i].radius)
		SetBlipColour(blip, Config.SafeZones[i].color)
		SetBlipAlpha(blip, Config.SafeZones[i].alpha)
	end
end)

RegisterNetEvent("okokDelVehicles:delete")
AddEventHandler("okokDelVehicles:delete", function()
	local minuteCalculation = 60000
	local minutesPassed = 0
	local minutesLeft = Config.DeleteVehicleTimer


	exports['okokNotify']:Alert("DV", "Alle forladte køretøjer bliver slettet om "..minutesLeft.." minut!", 10000, 'warning')

	while minutesPassed < Config.DeleteVehicleTimer do
		Citizen.Wait(1*minuteCalculation)
		minutesPassed = minutesPassed + 1
		minutesLeft = minutesLeft - 1
		if minutesLeft == 0 then
			exports['okokNotify']:Alert("DV", "Alle forladte køretøjer er slettet.", 10000, 'info')
		elseif minutesLeft == 1 then
			exports['okokNotify']:Alert("DV", "Alle forladte køretøjer bliver slettet om "..minutesLeft.." minut!", 10000, 'warning')
		else
			exports['okokNotify']:Alert("DV", "Alle forladte køretøjer bliver slettet om "..minutesLeft.." minuter!", 10000, 'warning')
		end
	end
	for vehicle in EnumerateVehicles() do
		local canDelete = true
		local carCoords = GetEntityCoords(vehicle)

		if (not IsPedAPlayer(GetPedInVehicleSeat(vehicle, -1))) then
			if not Config.DeleteVehiclesIfInSafeZone then
				for i = 1, #Config.SafeZones, 1 do
					dist = Vdist(Config.SafeZones[i].x, Config.SafeZones[i].y, Config.SafeZones[i].z, carCoords.x, carCoords.y, carCoords.z)
					if dist < Config.SafeZones[i].radius then
						canDelete = false
					end
				end
			end
			if canDelete then
				table.insert(vehiclesToDelete, vehicle)
			end
		else
			local retval, trailer = GetVehicleTrailerVehicle(vehicle)
			if retval then
				table.insert(vehicleTrailersNotToDelete, trailer)
			end
		end
	end

	if vehicleTrailersNotToDelete[1] ~= nil then
		for k,v in ipairs(vehiclesToDelete) do
			for k2,v2 in ipairs(vehicleTrailersNotToDelete) do
				if v == v2 then
					table.remove(vehiclesToDelete, k)
				end
			end
		end
	end

	for k,vehicle in ipairs(vehiclesToDelete) do
		SetVehicleHasBeenOwnedByPlayer(vehicle, false) 
		SetEntityAsMissionEntity(vehicle, false, false) 
		DeleteVehicle(vehicle)
		if (DoesEntityExist(vehicle)) then 
			DeleteVehicle(vehicle) 
		end
	end

	vehiclesToDelete = {}
	vehicleTrailersNotToDelete = {}
end)

local entityEnumerator = {
	__gc = function(enum)
	if enum.destructor and enum.handle then
		enum.destructor(enum.handle)
	end
	enum.destructor = nil
	enum.handle = nil
end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end

		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)

		local next = true
		repeat
			coroutine.yield(id)
			next, id = moveFunc(iter)
		until not next

		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end

function EnumerateVehicles()
	return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end