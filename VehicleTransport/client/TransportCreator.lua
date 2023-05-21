
local function NewTransportCreator(_name)
	local self = setmetatable({}, TransportCreator)


	-- error checking
	if (_name == nil) then
		LogError("No name for the transport was specified!")
		return
	end

	local vehicle = nil
	if (IsPedInAnyVehicle(PlayerPedId())) then
		vehicle = GetVehiclePedIsIn(PlayerPedId())
	else
		vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 50.0)
	end
	if (not DoesEntityExist(vehicle)) then
		LogError("No vehicle in range!")
		return
	end

	LogDebug("Creating new transport \"%s\"", _name)


	-- variables
	local name = _name

	local minValue		= -vector3(1.0, 1.0, 1.0)
	local maxValue		= vector3(1.0, 1.0, 1.0)
	local rampPosition	= vector3(0.0, 0.0, 0.0)
	local rampRotation	= vector3(0.0, 0.0, 0.0)

	local settingValue = "none"

	local ramp = nil

	local door = nil
	local doorPosition = vector3(0.0, 0.0, 0.0)


	-- process input and debug draw
	function self:Process()
		DisableAllControlActions(0)
		EnableControlAction(0, 1, true)
		EnableControlAction(0, 2, true)
		EnableControlAction(0, 0, true)
		EnableControlAction(0, 245, true)

		local change = vector3(
			GetDisabledControlNormal(0, 30), 
			-GetDisabledControlNormal(0, 31), 
			-GetDisabledControlNormal(0, 110)
		) * (IsDisabledControlPressed(0, 21) and 3.0 or 1.0) * GetFrameTime()

		if (settingValue == "min") then
			minValue = minValue + change
		elseif (settingValue == "max") then
			maxValue = maxValue + change
		elseif (settingValue == "rampPosition") then
			rampPosition = rampPosition + change

			AttachEntityToEntity(ramp, vehicle, -1, rampPosition, rampRotation, false, false, true, false, 2, true)
		elseif (settingValue == "doorPosition") then
			doorPosition = doorPosition + change
			DrawMarker(28, LocalToWorld(vehicle, doorPosition), vector3(0,0,0), vector3(0,0,0), vector3(1,1,1) * 3.0, 0, 0, 255, 100, false, false, 2)
		end

		if (settingValue == "min" or settingValue == "max") then
			local min = LocalToWorld(vehicle, minValue)
			local max = LocalToWorld(vehicle, maxValue)
			DrawMarker(28, min, vector3(0,0,0), vector3(0,0,0), vector3(1,1,1) * 0.2, 0, 255, 0, 255, false, false, 2)
			DrawMarker(28, max, vector3(0,0,0), vector3(0,0,0), vector3(1,1,1) * 0.2, 255, 0, 0, 255, false, false, 2)

			DrawCube({
				min,
				LocalToWorld(vehicle, vector3(minValue.x, minValue.y, maxValue.z)),
				LocalToWorld(vehicle, vector3(maxValue.x, minValue.y, maxValue.z)),
				LocalToWorld(vehicle, vector3(maxValue.x, minValue.y, minValue.z)),
				LocalToWorld(vehicle, vector3(maxValue.x, maxValue.y, minValue.z)),
				max,
				LocalToWorld(vehicle, vector3(minValue.x, maxValue.y, maxValue.z)),
				LocalToWorld(vehicle, vector3(minValue.x, maxValue.y, minValue.z)),
			})
		end
	end

	-- set the minimum position of the attachment area
	function self:SetMin()
		LogDebug("Setting min value")

		settingValue = "min"
	end

	-- set the maximum position of the attachment area
	function self:SetMax()
		LogDebug("Setting max value")

		settingValue = "max"
	end

	-- set the ramp model
	function self:SetRampModel(model)
		if (model == nil or type(model) ~= "number") then
			LogError("No ramp model specified!")
			return
		end

		LogDebug("Setting ramp model")

		if (DoesEntityExist(ramp)) then
			DeleteEntity(ramp)
		end

		rampPosition = vector3(0.0, 0.0, 0.0)
		rampRotation = vector3(0.0, 0.0, 0.0)

		ramp = CreateLocalObject(model, GetEntityCoords(vehicle))
		SetEntityNoCollisionEntity(ramp, vehicle, true)

		settingValue = "rampPosition"
	end

	-- set the door and position
	function self:SetDoor(doorIndex)
		if (doorIndex == nil) then
			LogError("No door index specified!")
			return
		end

		LogDebug("Setting door position")

		door = doorIndex

		settingValue = "doorPosition"
	end

	-- save data to server
	function self:Save()
		LogDebug("Saving transport")

		settingValue = "none"

		TriggerServerEvent("VT:save", {
			ModelName		= name,
			ModelHash		= GetEntityModel(vehicle),
			Min				= minValue,
			Max				= maxValue,
			RampModelHash	= DoesEntityExist(ramp) and GetEntityModel(ramp) or -1,
			RampPosition	= rampPosition,
			RampRotation	= rampRotation,
			DoorIndex		= door,
			DoorPosition	= doorPosition,
		})

		if (DoesEntityExist(ramp)) then
			DeleteEntity(ramp)
		end
	end


	return self
end

TransportCreator = {}
TransportCreator.__index = TransportCreator
setmetatable(TransportCreator, {
	__call = function(cls, ...)
		return NewTransportCreator(...)
	end
})



-- create a local object
function CreateLocalObject(model, position)
	if (not HasModelLoaded(model)) then
		RequestModel(model)
		while (not HasModelLoaded(model)) do
			Citizen.Wait(0)
		end
	end

	local obj = CreateObjectNoOffset(model, position, false, false, false)
	SetModelAsNoLongerNeeded(model)

	return obj
end

-- draw a cube
function DrawCube(verts)
	-- front
	DrawLine(verts[1], verts[2], 255, 255, 255, 255)
	DrawLine(verts[2], verts[3], 255, 255, 255, 255)
	DrawLine(verts[3], verts[4], 255, 255, 255, 255)
	DrawLine(verts[4], verts[1], 255, 255, 255, 255)
	-- back
	DrawLine(verts[5], verts[6], 255, 255, 255, 255)
	DrawLine(verts[6], verts[7], 255, 255, 255, 255)
	DrawLine(verts[7], verts[8], 255, 255, 255, 255)
	DrawLine(verts[8], verts[5], 255, 255, 255, 255)
	-- between
	DrawLine(verts[1], verts[8], 255, 255, 255, 255)
	DrawLine(verts[2], verts[7], 255, 255, 255, 255)
	DrawLine(verts[3], verts[6], 255, 255, 255, 255)
	DrawLine(verts[4], verts[5], 255, 255, 255, 255)

	-- faces
	DrawPoly(verts[3], verts[2], verts[1], 0, 0, 0, 100)
	DrawPoly(verts[4], verts[3], verts[1], 0, 0, 0, 100)
	DrawPoly(verts[7], verts[6], verts[5], 0, 0, 0, 100)
	DrawPoly(verts[8], verts[7], verts[5], 0, 0, 0, 100)
	DrawPoly(verts[6], verts[3], verts[4], 0, 0, 0, 100)
	DrawPoly(verts[5], verts[6], verts[4], 0, 0, 0, 100)
	DrawPoly(verts[2], verts[7], verts[8], 0, 0, 0, 100)
	DrawPoly(verts[1], verts[2], verts[8], 0, 0, 0, 100)
	DrawPoly(verts[6], verts[7], verts[2], 0, 0, 0, 100)
	DrawPoly(verts[3], verts[6], verts[2], 0, 0, 0, 100)
	DrawPoly(verts[4], verts[1], verts[8], 0, 0, 0, 100)
	DrawPoly(verts[5], verts[4], verts[8], 0, 0, 0, 100)
end

-- return the closest vehicle
function GetClosestVehicle(position, maxRadius, vehicles)
	local distance = maxRadius or 1000.0
	local closestVehicle

	for i, vehicle in ipairs(vehicles or GetGamePool("CVehicle")) do
		local dist = #(GetEntityCoords(vehicle) - position)
		if (dist < distance) then
			distance = dist
			closestVehicle = vehicle
		end
	end

	return closestVehicle
end



local creator = nil
RegisterNetEvent("VT:create", function(creationType, arg)
	if (creationType == "new") then
		creator = TransportCreator(arg)

		Citizen.CreateThread(function()
			while (creator) do
				creator:Process()

				Citizen.Wait(0)
			end
		end)
	end

	if (creator) then
		if (creationType == "min") then
			creator:SetMin()
		elseif (creationType == "max") then
			creator:SetMax()
		elseif (creationType == "rampmodel") then
			creator:SetRampModel(tonumber(arg) or GetHashKey(arg))
		elseif (creationType == "door") then
			creator:SetDoor(tonumber(arg))
		elseif (creationType == "save") then
			creator:Save()

			creator = nil
		end
	else
		LogError("Failed executing \"%s\". Use command \"/new [name]\" first!", creationType)
	end
end)
