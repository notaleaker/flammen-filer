Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

local unarmedCount, nightstickCount = 0, 0
local timerCount = 0

CreateThread(function()
    while true do
        Wait(0)

        local playerPed = GetPlayerPed(-1)

        if HasPedBeenDamagedByWeapon(playerPed, `WEAPON_NIGHTSTICK`, 0) then
            if random(1, 2) == 2 then
                local ragTime = random(7500, 14000)
                DoScreenFadeOut(500)
                SetPedToRagdoll(GetPlayerPed(-1), ragTime, ragTime, 0, 0, 0, 0)
                ClearEntityLastDamageEntity(playerPed)
                Wait(ragTime)
                DoScreenFadeIn(500)
				exports['mythic_notify']:DoHudText('error', 'Du blev knockoutet')
            end
        elseif HasPedBeenDamagedByWeapon(playerPed, `WEAPON_UNARMED`, 0) then
            local ragTime = random(7500, 14000)

            ClearEntityLastDamageEntity(playerPed)

            unarmedCount = unarmedCount+1

            if unarmedCount == 1 then
                unarmedId = CreateTimeout(300000, function()
                    unarmedCount = 0
                end)
            end

			local Knockout = random(1, 3)
            if unarmedCount > 8 and Knockout ~= 3 then
                DeleteTimeout(unarmedId)
                unarmedCount = 0

                DoScreenFadeOut(500)
                SetPedToRagdoll(GetPlayerPed(-1), ragTime, ragTime, 0, 0, 0, 0)
                Wait(ragTime)
                DoScreenFadeIn(500)
                ClearEntityLastDamageEntity(playerPed)
                exports['mythic_notify']:DoHudText('error', 'Du blev knockoutet')
            end
        else
            Wait(500)
        end
    end
end)

local TimeoutCounter = {}

CreateTimeout = function(msec, cb)
    local id = timerCount + 1

    SetTimeout(msec, function()
        if TimeoutCounter[id] then
            TimeoutCounter[id] = nil
        else
            cb()
        end
    end)

    timerCount = id

    return id
end

DeleteTimeout = function(id)
    TimeoutCounter[id] = true
end

local randomCount = math.random(1,100)

random = function(x, y)
    randomCount = randomCount + 1
    if x ~= nil and y ~= nil then
        return math.floor(x +(math.random(math.randomseed(GetGameTimer()+randomCount))*999999 %y))
    else
        return math.floor((math.random(math.randomseed(GetGameTimer()+randomCount))*100))
    end
end