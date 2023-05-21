local Beds, CurrentBed, OnBed, BedCoords, BedHeading = { `v_med_bed1`, `gabz_pillbox_diagnostics_bed_03`, `gabz_pillbox_diagnostics_bed_02` }, nil, false, nil, nil
CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Wait(0)
	end
end)

CreateThread(function()
	while true do
		if not OnBed then
			local PlayerCoords, IsNear = GetEntityCoords(PlayerPedId()), false

			for k, v in pairs(Beds) do
				-- print(v)
				local ClosestBed = GetClosestObjectOfType(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, 2.8, v, false, false, false)
				if ClosestBed ~= 0 and ClosestBed ~= nil then
					IsNear = true
					TempCoords = GetEntityCoords(ClosestBed)
					if #(PlayerCoords - TempCoords) < 1.8 then
						CurrentBed = ClosestBed
						BedHeading = GetEntityHeading(CurrentBed)
						BedCoords = TempCoords
						break
					end
				else
					CurrentBed = nil
				end
			end

			if not IsNear then
				Wait(415)
			end
		end

		Wait(185)
	end
end)

local function Draw3DText(x, y, z, text, scale)
	local onScreen, x2, y2 = GetScreenCoordFromWorldCoord(x, y, z)

	if onScreen then
		SetTextScale(scale, scale)
		SetTextOutline()
		SetTextFont(4)
		SetTextCentre(true)
		SetTextColour(255, 255, 255, 215)
		BeginTextCommandDisplayText('STRING')
		AddTextComponentSubstringPlayerName(text)
		EndTextCommandDisplayText(x2, y2)
	end
end

CreateThread(function()
	while true do
		if CurrentBed ~= nil then
			if not OnBed then
				Draw3DText(BedCoords.x, BedCoords.y, BedCoords.z + 0.85, 'Tryk ~g~[E] ~w~for at lægge dig', 0.365)
			else
				Draw3DText(BedCoords.x, BedCoords.y, BedCoords.z + 0.85, 'Tryk ~g~[E] ~w~for at rejse dig', 0.365)
			end
		end

		Wait(0)
	end
end)

CreateThread(function()
	while true do
		if CurrentBed ~= nil and OnBed == false and IsControlJustReleased(0, 38) then
			local PlayerPed = PlayerPedId()

			LoadAnimSet('missfbi1')
			local PlayerCoords = GetEntityCoords(PlayerPedId())

			SetEntityCoords(PlayerPed, BedCoords.x, BedCoords.y, BedCoords.z + 0.35, true, false, false, false)
			SetEntityHeading(PlayerPed, (BedHeading+180))

			FreezeEntityPosition(PlayerPed, true)
			TaskPlayAnim(PlayerPed, 'missfbi1', 'cpr_pumpchest_idle', 8.0, -8.0, -1, 1, 0, false, false, false)
			OnBed = true
			if OnBed == true then
				while GetEntityHealth(PlayerPed) < 200 do
					if GetEntityHealth(PlayerPed) == 0 then
						TriggerEvent('esx_ambulancejob:revive')
						OnBed = false
					end

					Wait(2000)
					SetEntityHealth(PlayerPed, GetEntityHealth(PlayerPed) + 1)
				end

				-- TriggerEvent('esx:showNotification', '~g~ You are now healthy');
			end
		elseif OnBed and IsControlJustReleased(0, 38) then
			FreezeEntityPosition(PlayerPedId(), false)
			ClearPedTasks(PlayerPedId())
			OnBed = false
		end

		Wait(0)
	end
end)

function LoadAnimSet(AnimDict)
	if not HasAnimDictLoaded(AnimDict) then
		RequestAnimDict(AnimDict)

		while not HasAnimDictLoaded(AnimDict) do
			Wait(1)
		end
	end
end

CreateThread(function()
	while true do
		Wait(0)

		if OnBed then
			local playerPed = PlayerPedId()
			DisableControlAction(0, 20, true) -- z
			DisableControlAction(0, 73, true) -- X
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1
			DisableControlAction(0, 21, true) -- Melee Attack 1

			DisableControlAction(0, 45, true) -- Reload
			DisableControlAction(0, 22, true) -- Jump
			DisableControlAction(0, 44, true) -- Cover
			DisableControlAction(0, 37, true) -- Select Weapon

			DisableControlAction(0, 288,  true) -- Disable phone
			DisableControlAction(0, 289, true) -- Inventory
			DisableControlAction(0, 170, true) -- Animations
			DisableControlAction(0, 167, true) -- Job

			DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle

			DisableControlAction(2, 36, true) -- Disable going stealth

			DisableControlAction(0, 47, true)  -- Disable weapon
			DisableControlAction(0, 264, true) -- Disable melee
			--DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
			DisableControlAction(0, 23, true) -- Disable enter vehicle
			--[[if IsEntityPlayingAnim(playerPed, 'missfbi1', 'cpr_pumpchest_idle', 3) ~= 1 then
				ESX.Streaming.RequestAnimDict('missfbi1', function()
					TaskPlayAnim(playerPed, 'missfbi1', 'cpr_pumpchest_idle', 8.0, -8.0, -1, 1, 0, false, false, false)
				end)
			end]]
		else
			Wait(500)
		end
	end
end)