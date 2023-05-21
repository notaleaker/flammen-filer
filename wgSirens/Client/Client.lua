local SirenVehicles, ActiveVehicles, ActiveSoundIDs, TempVehicleCounters = Config.SirenVehicles, {}, {}, {}

local function SirenSwitch()
	local PedID = PlayerPedId()
	local Vehicle = GetVehiclePedIsIn(PedID, false)
	if Vehicle ~= 0 then
		local SirenVehicle = SirenVehicles[GetEntityModel(Vehicle)]
		if SirenVehicle then
			if GetPedInVehicleSeat(Vehicle, -1) == PedID or (SirenVehicle.PassengerControl and GetPedInVehicleSeat(Vehicle, 0) == PedID) then
				TriggerServerEvent('wgSirens:SwitchSirens', NetworkGetNetworkIdFromEntity(Vehicle))
			end
		end
	end
end

RegisterCommand('sirenswitch', SirenSwitch, false)

RegisterKeyMapping('sirenswitch', 'Skifter mellem sirener.', 'keyboard', 'q')

RegisterCommand('setsiren', function(_, Args)
	if Args[1] then
		local SirenNumber = tonumber(Args[1])
		if SirenNumber then
			local PedID = PlayerPedId()
			local Vehicle = GetVehiclePedIsIn(PedID, false)
			if Vehicle ~= 0 then
				local SirenVehicle = SirenVehicles[GetEntityModel(Vehicle)]
				if SirenVehicle then
					if GetPedInVehicleSeat(Vehicle, -1) == PedID or (SirenVehicle.PassengerControl and GetPedInVehicleSeat(Vehicle, 0) == PedID) then
						if #SirenVehicle.Sirens >= SirenNumber then
							TriggerServerEvent('wgSirens:SetSiren', NetworkGetNetworkIdFromEntity(Vehicle), SirenNumber)
						end
					end
				end
			end
		end
	end
end, false)

RegisterKeyMapping('setsiren 0', 'Slå sirene fra.', '', '')

RegisterKeyMapping('setsiren 1', 'Skifter til sirene 1.', '', '')

RegisterKeyMapping('setsiren 2', 'Skifter til sirene 2.', '', '')

RegisterKeyMapping('setsiren 3', 'Skifter til sirene 3.', '', '')

CreateThread(function()
	AddStateBagChangeHandler('wgSiren', '', function(BagName, _, Value)
		local Vehicle = GetEntityFromStateBagName(BagName)
		local i = 0
		while Vehicle == 0 and i < 15 do
			Wait(250)
			Vehicle = GetEntityFromStateBagName(BagName)
			i += 1
		end

		if Vehicle ~= 0 then
			TempVehicleCounters[Vehicle] = TempVehicleCounters[Vehicle] and TempVehicleCounters[Vehicle] + 1 or math.mininteger
			local TempCounter = TempVehicleCounters[Vehicle]

			if DoesEntityExist(Vehicle) then
				if ActiveVehicles[Vehicle] then
					StopSound(ActiveVehicles[Vehicle])
					ReleaseSoundId(ActiveVehicles[Vehicle])
					ActiveSoundIDs[ActiveVehicles[Vehicle]] = nil
					ActiveVehicles[Vehicle] = nil
				end

				Wait(0) -- Skal måske flyttes op

				if Value > 0 and TempVehicleCounters[Vehicle] == TempCounter then
					local SoundID = GetSoundId()
					if SoundID ~= -1 then
						ActiveSoundIDs[SoundID] = Vehicle
						ActiveVehicles[Vehicle] = SoundID
						PlaySoundFromEntity(SoundID, SirenVehicles[GetEntityModel(Vehicle)].Sirens[Value], Vehicle, '', false, false)
					else
						print('Der opstod en fejl. Kontakt venligst en udvikler med fejlkoden: #2.')
					end
				end
			else
				print('Der opstod en fejl. Kontakt venligst en udvikler med fejlkoden: #1.')
			end
		else
			print('Der opstod en fejl. Kontakt venligst en udvikler med fejlkoden: #3.')
		end
	end)

	while true do
		local ToBeRemoved = {}
		for SoundID, VehicleID in pairs(ActiveSoundIDs) do
			if not DoesEntityExist(VehicleID) then
				--StopSound(SoundID) -- Maybe
				ReleaseSoundId(SoundID)
				ToBeRemoved[#ToBeRemoved + 1] = {SoundID, VehicleID}
			end
		end

		for i=1, #ToBeRemoved do
			ActiveSoundIDs[ToBeRemoved[i][1]] = nil
			ActiveVehicles[ToBeRemoved[i][2]] = nil
		end

		Wait(400)
	end
end)