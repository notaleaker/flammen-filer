local pickups = {}

CreateThread(function()
	while not Config.Multichar do
		Wait(0)
		if NetworkIsPlayerActive(PlayerId()) then
			exports.spawnmanager:setAutoSpawn(false)
			DoScreenFadeOut(0)
			TriggerServerEvent('esx:onPlayerJoined')
			break
		end
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer, isNew, skin)
	ESX.PlayerLoaded = true
	ESX.PlayerData = xPlayer

	FreezeEntityPosition(PlayerPedId(), true)

	if Config.Multichar then
		Wait(3000)
	else
		exports.spawnmanager:spawnPlayer({
			x = ESX.PlayerData.coords.x,
			y = ESX.PlayerData.coords.y,
			z = ESX.PlayerData.coords.z + 0.25,
			heading = ESX.PlayerData.coords.heading,
			model = GetHashKey("mp_m_freemode_01"),
			skipFade = false
		}, function()
			TriggerServerEvent('esx:onPlayerSpawn')
			TriggerEvent('esx:onPlayerSpawn')
			TriggerEvent('esx:restoreLoadout')

			if isNew then
				TriggerEvent('skinchanger:loadDefaultModel', skin.sex == 0)
			elseif skin then
				TriggerEvent('skinchanger:loadSkin', skin)
			end

			TriggerEvent('esx:loadingScreenOff')
			ShutdownLoadingScreen()
			ShutdownLoadingScreenNui()
			FreezeEntityPosition(ESX.PlayerData.ped, false)
		end)
	end

	while ESX.PlayerData.ped == nil do Wait(20) end
	-- enable PVP
	if Config.EnablePVP then
		SetCanAttackFriendly(ESX.PlayerData.ped, true, false)
		NetworkSetFriendlyFireOption(true)
	end

	if Config.EnableHud then
		for k,v in ipairs(ESX.PlayerData.accounts) do
			local accountTpl = '<div><img src="img/accounts/' .. v.name .. '.png"/>&nbsp;{{money}}</div>'
			ESX.UI.HUD.RegisterElement('account_' .. v.name, k, 0, accountTpl, {money = ESX.Math.GroupDigits(v.money)})
		end

		local jobTpl = '<div>{{job_label}}{{grade_label}}</div>'

		local gradeLabel = ESX.PlayerData.job.grade_label ~= ESX.PlayerData.job.label and ESX.PlayerData.job.grade_label or ''
		if gradeLabel ~= '' then gradeLabel = ' - '..gradeLabel end

		ESX.UI.HUD.RegisterElement('job', #ESX.PlayerData.accounts, 0, jobTpl, {
			job_label = ESX.PlayerData.job.label,
			grade_label = gradeLabel
		})
	end
	StartServerSyncLoops()
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	if Config.EnableHud then ESX.UI.HUD.Reset() end
end)

RegisterNetEvent('esx:setMaxWeight')
AddEventHandler('esx:setMaxWeight', function(newMaxWeight) ESX.PlayerData.maxWeight = newMaxWeight end)

local function onPlayerSpawn()
	if ESX.PlayerLoaded then
		ESX.SetPlayerData('ped', PlayerPedId())
		ESX.SetPlayerData('dead', false)
	end
end

AddEventHandler('playerSpawned', onPlayerSpawn)
AddEventHandler('esx:onPlayerSpawn', onPlayerSpawn)

AddEventHandler('esx:onPlayerDeath', function()
	ESX.SetPlayerData('ped', PlayerPedId())
	ESX.SetPlayerData('dead', true)
end)

AddEventHandler('skinchanger:modelLoaded', function()
	while not ESX.PlayerLoaded do
		Wait(100)
	end
	TriggerEvent('esx:restoreLoadout')
end)

AddEventHandler('esx:restoreLoadout', function()
	ESX.SetPlayerData('ped', PlayerPedId())
	local ammoTypes = {}
	RemoveAllPedWeapons(ESX.PlayerData.ped, true)

	for k,v in ipairs(ESX.PlayerData.loadout) do
		local weaponName = v.name
		local weaponHash = GetHashKey(weaponName)

		GiveWeaponToPed(ESX.PlayerData.ped, weaponHash, 0, false, false)
		SetPedWeaponTintIndex(ESX.PlayerData.ped, weaponHash, v.tintIndex)

		local ammoType = GetPedAmmoTypeFromWeapon(ESX.PlayerData.ped, weaponHash)

		for k2,v2 in ipairs(v.components) do
			local componentHash = ESX.GetWeaponComponent(weaponName, v2).hash
			GiveWeaponComponentToPed(ESX.PlayerData.ped, weaponHash, componentHash)
		end

		if not ammoTypes[ammoType] then
			AddAmmoToPed(ESX.PlayerData.ped, weaponHash, v.ammo)
			ammoTypes[ammoType] = true
		end
	end
end)

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
	for k,v in ipairs(ESX.PlayerData.accounts) do
		if v.name == account.name then
			ESX.PlayerData.accounts[k] = account
			break
		end
	end
	ESX.SetPlayerData('accounts', ESX.PlayerData.accounts)

	if Config.EnableHud then
		ESX.UI.HUD.UpdateElement('account_' .. account.name, {
			money = ESX.Math.GroupDigits(account.money)
		})
	end
end)

RegisterNetEvent('esx:addInventoryItem')
AddEventHandler('esx:addInventoryItem', function(item, count, showNotification)
	for k,v in ipairs(ESX.PlayerData.inventory) do
		if v.name == item then
			ESX.UI.ShowInventoryItemNotification(true, v.label, count - v.count)
			ESX.PlayerData.inventory[k].count = count
			break
		end
	end

	if showNotification then
		ESX.UI.ShowInventoryItemNotification(true, item, count)
	end

	if ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
		ESX.ShowInventory()
	end
end)

RegisterNetEvent('esx:removeInventoryItem')
AddEventHandler('esx:removeInventoryItem', function(item, count, showNotification)
	for k,v in ipairs(ESX.PlayerData.inventory) do
		if v.name == item then
			ESX.UI.ShowInventoryItemNotification(false, v.label, v.count - count)
			ESX.PlayerData.inventory[k].count = count
			break
		end
	end

	if showNotification then
		ESX.UI.ShowInventoryItemNotification(false, item, count)
	end

	if ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
		ESX.ShowInventory()
	end
end)

RegisterNetEvent('esx:addWeapon')
AddEventHandler('esx:addWeapon', function(weapon, ammo)
	GiveWeaponToPed(ESX.PlayerData.ped, GetHashKey(weapon), ammo, false, false)
end)

RegisterNetEvent('esx:addWeaponComponent')
AddEventHandler('esx:addWeaponComponent', function(weapon, weaponComponent)
	local componentHash = ESX.GetWeaponComponent(weapon, weaponComponent).hash
	GiveWeaponComponentToPed(ESX.PlayerData.ped, GetHashKey(weapon), componentHash)
end)

RegisterNetEvent('esx:setWeaponAmmo')
AddEventHandler('esx:setWeaponAmmo', function(weapon, weaponAmmo)
	SetPedAmmo(ESX.PlayerData.ped, GetHashKey(weapon), weaponAmmo)
end)

RegisterNetEvent('esx:setWeaponTint')
AddEventHandler('esx:setWeaponTint', function(weapon, weaponTintIndex)
	SetPedWeaponTintIndex(ESX.PlayerData.ped, GetHashKey(weapon), weaponTintIndex)
end)

RegisterNetEvent('esx:removeWeapon')
AddEventHandler('esx:removeWeapon', function(weapon)
	local playerPed = ESX.PlayerData.ped
	RemoveWeaponFromPed(ESX.PlayerData.ped, GetHashKey(weapon))
	SetPedAmmo(ESX.PlayerData.ped, GetHashKey(weapon), 0)
end)

RegisterNetEvent('esx:removeWeaponComponent')
AddEventHandler('esx:removeWeaponComponent', function(weapon, weaponComponent)
	local componentHash = ESX.GetWeaponComponent(weapon, weaponComponent).hash
	RemoveWeaponComponentFromPed(ESX.PlayerData.ped, GetHashKey(weapon), componentHash)
end)

RegisterNetEvent('esx:teleport')
AddEventHandler('esx:teleport', function(coords)
	ESX.Game.Teleport(ESX.PlayerData.ped, coords)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(Job)
	if Config.EnableHud then
		local gradeLabel = Job.grade_label ~= Job.label and Job.grade_label or ''
		if gradeLabel ~= '' then gradeLabel = ' - '..gradeLabel end
		ESX.UI.HUD.UpdateElement('job', {
			job_label = Job.label,
			grade_label = gradeLabel
		})
	end
	ESX.SetPlayerData('job', Job)
end)

RegisterNetEvent('esx:spawnVehicle')
AddEventHandler('esx:spawnVehicle', function(vehicle)
	ESX.TriggerServerCallback("esx:isUserAdmin", function(admin)
		if admin then
			local model = (type(vehicle) == 'number' and vehicle or GetHashKey(vehicle))

			if IsModelInCdimage(model) then
				local playerCoords, playerHeading = GetEntityCoords(ESX.PlayerData.ped), GetEntityHeading(ESX.PlayerData.ped)

				ESX.Game.SpawnVehicle(model, playerCoords, playerHeading, function(vehicle)
					TaskWarpPedIntoVehicle(ESX.PlayerData.ped, vehicle, -1)
				end)
				exports['t1ger_keys']:SetVehicleLocked(model, 1)
			else
				TriggerEvent('chat:addMessage', { args = { '^1SYSTEM', 'Invalid vehicle model.' } })
			end
		end
	end)
end)

RegisterNetEvent('esx:createPickup')
AddEventHandler('esx:createPickup', function(pickupId, label, coords, type, name, components, tintIndex)
	local function setObjectProperties(object)
		SetEntityAsMissionEntity(object, true, false)
		PlaceObjectOnGroundProperly(object)
		FreezeEntityPosition(object, true)
		SetEntityCollision(object, false, true)

		pickups[pickupId] = {
			obj = object,
			label = label,
			inRange = false,
			coords = vector3(coords.x, coords.y, coords.z)
		}
	end

	if type == 'item_weapon' then
		local weaponHash = GetHashKey(name)
		ESX.Streaming.RequestWeaponAsset(weaponHash)
		local pickupObject = CreateWeaponObject(weaponHash, 50, coords.x, coords.y, coords.z, true, 1.0, 0)
		SetWeaponObjectTintIndex(pickupObject, tintIndex)

		for k,v in ipairs(components) do
			local component = ESX.GetWeaponComponent(name, v)
			GiveWeaponComponentToWeaponObject(pickupObject, component.hash)
		end

		setObjectProperties(pickupObject)
	else
		ESX.Game.SpawnLocalObject('prop_money_bag_01', coords, setObjectProperties)
	end
end)

RegisterNetEvent('esx:createMissingPickups')
AddEventHandler('esx:createMissingPickups', function(missingPickups)
	for pickupId, pickup in pairs(missingPickups) do
		TriggerEvent('esx:createPickup', pickupId, pickup.label, pickup.coords, pickup.type, pickup.name, pickup.components, pickup.tintIndex)
	end
end)

RegisterNetEvent('esx:registerSuggestions')
AddEventHandler('esx:registerSuggestions', function(registeredCommands)
	for name,command in pairs(registeredCommands) do
		if command.suggestion then
			TriggerEvent('chat:addSuggestion', ('/%s'):format(name), command.suggestion.help, command.suggestion.arguments)
		end
	end
end)

RegisterNetEvent('esx:removePickup')
AddEventHandler('esx:removePickup', function(pickupId)
	if pickups[pickupId] and pickups[pickupId].obj then
		ESX.Game.DeleteObject(pickups[pickupId].obj)
		pickups[pickupId] = nil
	end
end)

RegisterNetEvent('esx:deleteVehicle')
AddEventHandler('esx:deleteVehicle', function(radius)
	if radius and tonumber(radius) then
		radius = tonumber(radius) + 0.01
		local vehicles = ESX.Game.GetVehiclesInArea(GetEntityCoords(ESX.PlayerData.ped), radius)

		for k,entity in ipairs(vehicles) do
			local attempt = 0

			while not NetworkHasControlOfEntity(entity) and attempt < 100 and DoesEntityExist(entity) do
				Wait(100)
				NetworkRequestControlOfEntity(entity)
				attempt = attempt + 1
			end

			if DoesEntityExist(entity) and NetworkHasControlOfEntity(entity) then
				ESX.Game.DeleteVehicle(entity)
			end
		end
	else
		local vehicle, attempt = ESX.Game.GetVehicleInDirection(), 0

		if IsPedInAnyVehicle(ESX.PlayerData.ped, true) then
			vehicle = GetVehiclePedIsIn(ESX.PlayerData.ped, false)
		end

		while not NetworkHasControlOfEntity(vehicle) and attempt < 100 and DoesEntityExist(vehicle) do
			Wait(100)
			NetworkRequestControlOfEntity(vehicle)
			attempt = attempt + 1
		end

		if DoesEntityExist(vehicle) and NetworkHasControlOfEntity(vehicle) then
			ESX.Game.DeleteVehicle(vehicle)
		end
	end
end)

-- Pause menu disables HUD display
if Config.EnableHud then
	CreateThread(function()
		local isPaused = false
		local time = 500
		while true do
			Wait(time)

			if IsPauseMenuActive() and not isPaused then
				time = 100
				isPaused = true
				ESX.UI.HUD.SetDisplay(0.0)
			elseif not IsPauseMenuActive() and isPaused then
				time = 100
				isPaused = false
				ESX.UI.HUD.SetDisplay(1.0)
			end
		end
	end)

	AddEventHandler('esx:loadingScreenOff', function()
		ESX.UI.HUD.SetDisplay(1.0)
	end)
end

function StartServerSyncLoops()
	-- keep track of ammo
	Citizen.CreateThread(function()
	  while true do
		Citizen.Wait(0)
  
		if isDead then
		  Citizen.Wait(500)
		else
		  local playerPed = PlayerPedId()
  
		  if IsPedShooting(playerPed) then
			local _,weaponHash = GetCurrentPedWeapon(playerPed, true)
			local weapon = ESX.GetWeaponFromHash(weaponHash)
  
			if weapon then
			  local ammoCount = GetAmmoInPedWeapon(playerPed, weaponHash)
			  local removeWeapon = false
  
			  if ammoCount <= 0 then
				local damageType = GetWeaponDamageType(weaponHash)
  
				if damageType == 1
				or damageType == 5
				or damageType == 6
				or damageType == 12
				or damageType == 13
				then                
				  Wait(1000)
  
				  if not HasPedGotWeapon(playerPed, weaponHash, false) then
					removeWeapon = true
				  end
				end
			  end
  
			  TriggerServerEvent('esx:updateWeaponAmmo', weapon.name, ammoCount, removeWeapon)
			end
		  end
		end
	  end
	end)
  
	-- sync current player coords with server
	Citizen.CreateThread(function()
	  local previousCoords = vector3(ESX.PlayerData.coords.x, ESX.PlayerData.coords.y, ESX.PlayerData.coords.z)
  
	  while true do
		Citizen.Wait(6000)
		local playerPed = PlayerPedId()
  
		if DoesEntityExist(playerPed) then
		  local playerCoords = GetEntityCoords(playerPed)
		  local distance = #(playerCoords - previousCoords)
  
		  if distance > 1 then
			previousCoords = playerCoords
			local playerHeading = ESX.Math.Round(GetEntityHeading(playerPed), 1)
			local formattedCoords = {x = ESX.Math.Round(playerCoords.x, 1), y = ESX.Math.Round(playerCoords.y, 1), z = ESX.Math.Round(playerCoords.z, 1), heading = playerHeading}
			TriggerServerEvent('esx:updateCoords', formattedCoords)
		  end
		end
	  end
	end)
  end

if Config.EnableDefaultInventory then
	RegisterCommand('showinv', function()
		if not ESX.PlayerData.dead and not ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
			ESX.ShowInventory()
		end
	end)

	RegisterKeyMapping('showinv', _U('keymap_showinventory'), 'keyboard', 'F2')
end

-- disable wanted level
if not Config.EnableWantedLevel then
	ClearPlayerWantedLevel(PlayerId())
	SetMaxWantedLevel(0)
end

CreateThread(function()
	while true do
		Wait(0)
		local playerCoords, letSleep = GetEntityCoords(ESX.PlayerData.ped), true
		local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer(playerCoords)

		for pickupId,pickup in pairs(pickups) do
			local distance = #(playerCoords - pickup.coords)

			if distance < 5 then
				local label = pickup.label
				letSleep = false

				if distance < 1 then
					if IsControlJustReleased(0, 38) then
						if IsPedOnFoot(ESX.PlayerData.ped) and (closestDistance == -1 or closestDistance > 3) and not pickup.inRange then
							pickup.inRange = true

							local dict, anim = 'weapons@first_person@aim_rng@generic@projectile@sticky_bomb@', 'plant_floor'
							ESX.Streaming.RequestAnimDict(dict)
							TaskPlayAnim(ESX.PlayerData.ped, dict, anim, 8.0, 1.0, 1000, 16, 0.0, false, false, false)
							Wait(1000)

							TriggerServerEvent('esx:onPickup', pickupId)
							PlaySoundFrontend(-1, 'PICK_UP', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
						end
					end

					label = ('%s~n~%s'):format(label, _U('threw_pickup_prompt'))
				end

				ESX.Game.Utils.DrawText3D({
					x = pickup.coords.x,
					y = pickup.coords.y,
					z = pickup.coords.z + 0.25
				}, label, 1.2, 1)
			elseif pickup.inRange then
				pickup.inRange = false
			end
		end

		if letSleep then
			Wait(500)
		end
	end
end)

----- Admin commnads from esx_adminplus

RegisterNetEvent("esx:tpm")
AddEventHandler("esx:tpm", function()
	ESX.TriggerServerCallback("esx:isUserAdmin", function(admin)
		if admin then
    	local WaypointHandle = GetFirstBlipInfoId(8)
    	if DoesBlipExist(WaypointHandle) then
        	local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)

        	for height = 1, 1000 do
            	SetPedCoordsKeepVehicle(ESX.PlayerData.ped, waypointCoords["x"], waypointCoords["y"], height + 0.0)

            	local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], height + 0.0)

            	if foundGround then
              	SetPedCoordsKeepVehicle(ESX.PlayerData.ped, waypointCoords["x"], waypointCoords["y"], height + 0.0)

                break
            	end

            Wait(5)
        	end
        TriggerEvent('chatMessage', "Successfully Teleported")
    	else
        TriggerEvent('chatMessage', "No Waypoint Set")
    	end
		end
	end)
end)

function getPosition()
	local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
	return x,y,z
  end
  
  
  
  function getCamDirection()
	local heading = GetGameplayCamRelativeHeading()+GetEntityHeading(GetPlayerPed(-1))
	local pitch = GetGameplayCamRelativePitch()
  
	local x = -math.sin(heading*math.pi/180.0)
	local y = math.cos(heading*math.pi/180.0)
	local z = math.sin(pitch*math.pi/180.0)
  
	-- normalize
	local len = math.sqrt(x*x+y*y+z*z)
	if len ~= 0 then
	  x = x/len
	  y = y/len
	  z = z/len
	end
  
	return x,y,z
  end

local noclip = false
local noclip_speed = 1.0
RegisterNetEvent("esx:noclip")
AddEventHandler("esx:noclip", function(input)
    local player = PlayerId()
	
    local msg = "deaktiveret"
	if(noclip == false)then
		noclip_pos = GetEntityCoords(ESX.PlayerData.ped, false)
	end

	noclip = not noclip

	if(noclip)then
		msg = "aktiveret"
		local name = GetPlayerName(player)
		TriggerServerEvent("noadminabuse", 'https://discordapp.com/api/webhooks/1005443579482751076/hlpKwHe0l2WoUzlVJljkAv6_deka7HoAi2CP-7kLVOkz0DfBOpXRRyBmc5qN_gFCZ5Pd', name, "Har " .. msg .. " noclip")
	end

	TriggerEvent("chatMessage", "Noclip er blevet ^2^*" .. msg)
	end)
	
	local heading = 0
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
		  if(noclip)then
			local ped = GetPlayerPed(-1)
			local x,y,z = getPosition()
			local dx,dy,dz = getCamDirection()
			local speed = noclip_speed
			SetEntityVisible(GetPlayerPed(-1), false, false)
			SetEntityInvincible(GetPlayerPed(-1), true)
	
		  -- reset velocity
		  SetEntityVelocity(ped, 0.0001, 0.0001, 0.0001)
		  if IsControlPressed(0, 21) then
			  speed = speed + 3
			  end
		  if IsControlPressed(0, 19) then
			  speed = speed - 0.5
		  end
		  -- forward
				 if IsControlPressed(0,32) then -- MOVE UP
				  x = x+speed*dx
				  y = y+speed*dy
				  z = z+speed*dz
				   end
	
		  -- backward
				   if IsControlPressed(0,269) then -- MOVE DOWN
				  x = x-speed*dx
				  y = y-speed*dy
				  z = z-speed*dz
				   end
			SetEntityCoordsNoOffset(ped,x,y,z,true,true,true)
				else
				SetEntityVisible(GetPlayerPed(-1), true, false)
				SetEntityInvincible(GetPlayerPed(-1), false)
	
			 end
		end
  end)

RegisterNetEvent("esx:killPlayer")
AddEventHandler("esx:killPlayer", function()
  SetEntityHealth(ESX.PlayerData.ped, 0)
end)

RegisterNetEvent("esx:freezePlayer")
AddEventHandler("esx:freezePlayer", function(input)
    local player = PlayerId()
    if input == 'freeze' then
        SetEntityCollision(ESX.PlayerData.ped, false)
        FreezeEntityPosition(ESX.PlayerData.ped, true)
        SetPlayerInvincible(player, true)
    elseif input == 'unfreeze' then
        SetEntityCollision(ESX.PlayerData.ped, true)
	    FreezeEntityPosition(ESX.PlayerData.ped, false)
        SetPlayerInvincible(player, false)
    end
end)
