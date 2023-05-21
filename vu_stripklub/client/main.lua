ESX = nil
local isInMarker

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

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["INSERT"] = 121, ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

function DrawText3Ds(coords, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(coords.x,coords.y,coords.z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 0, 0, 0, 120)
end

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(Config.Blip.coords)

    SetBlipSprite(blip, Config.Blip.sprite)
    SetBlipDisplay(blip, Config.Blip.display)
    SetBlipScale(blip, Config.Blip.scale)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(_U('map_blip'))
    EndTextCommandSetBlipName(blip)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if ESX.PlayerData.job and ESX.PlayerData.job.name == Config.JobName then
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)

            if GetDistanceBetweenCoords(coords, Config.Locations.Bar, false) <= Config.DrawDistance then
                DrawMarker(21, Config.Locations.Bar,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.5, 0.5, 0.5,
                200, 0, 0, 200,
                false, false, 2, true, nil, nil, false)

                if GetDistanceBetweenCoords(coords, Config.Locations.Bar, true) <= 0.6 then
                    isInMarker = 'bar'
                    DrawText3Ds(Config.Locations.Bar, _U('bar_spawn_promp'))
                    if IsControlJustReleased(0, 51) then
                        openBarMenu()
                    end
                elseif isInMarker == 'bar' then
                    ESX.UI.Menu.CloseAll()
                    isInMarker = nil
                end
            end

            if GetDistanceBetweenCoords(coords, Config.Locations.BossMenu, false) <= Config.DrawDistance then
                DrawMarker(22, Config.Locations.BossMenu,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.7, 0.7, 0.7,
                200, 0, 0, 200,
                false, false, 2, true, nil, nil, false)

                if GetDistanceBetweenCoords(coords, Config.Locations.BossMenu, true) <= 0.8 then
                    isInMarker = 'bossMenu'
                    ESX.ShowHelpNotification(_U('bossmenu_promp'))
                    if IsControlJustReleased(0, 51) then
                        TriggerEvent('esx_society:openBossMenu', Config.JobName, function(data, menu)
                            menu.close()
                            isInMarker = nil
                        end, { wash = false }) -- disable washing money
                    end
                elseif isInMarker == 'bossMenu' then
                    ESX.UI.Menu.CloseAll()
                    isInMarker = nil
                end
            end

            if GetDistanceBetweenCoords(coords, Config.Locations.Vehicle.spawner, false) <= Config.DrawDistance then
                DrawMarker(36, Config.Locations.Vehicle.spawner,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.5, 0.5, 0.5,
                200, 0, 0, 200,
                false, false, 2, true, nil, nil, false)

                if GetDistanceBetweenCoords(coords, Config.Locations.Vehicle.spawner, true) <= 0.6 then
                    isInMarker = 'VehicleSpawner'
                    DrawText3Ds(Config.Locations.Vehicle.spawner, _U('vehicle_spawn_promp'))
                    if IsControlJustReleased(0, 51) then
                        openVehicleMenu()
                    end
                elseif isInMarker == 'VehicleSpawner' then
                    ESX.UI.Menu.CloseAll()
                    isInMarker = nil
                end
            end

            if GetDistanceBetweenCoords(coords, Config.Locations.Vehicle.deleter, false) <= Config.DrawDistance then
                DrawMarker(27, Config.Locations.Vehicle.deleter,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                2.5, 2.5, 2.5,
                200, 0, 0, 200,
                false, false, 2, true, nil, nil, false)

                if GetDistanceBetweenCoords(coords, Config.Locations.Vehicle.deleter, true) <= 2.5 then
                    if IsPedInAnyVehicle(playerPed, false) then
                        local vehicle = GetVehiclePedIsIn(playerPed, false)
                        local plate = ESX.Game.GetVehicleProperties(vehicle).plate
                        if string.find(plate, 'VU') then
                            isInMarker = 'VehicleDeleter'
                            ESX.ShowHelpNotification(_U('vehicle_deleter_promp'))
                            if IsControlJustReleased(0, 51) then
                                --TriggerServerEvent('cBeyerV1:removeOwnedVehicle', plate)
                                ESX.Game.DeleteVehicle(vehicle)
                            end
                        end
                    end
                elseif isInMarker == 'VehicleDeleter' then
                    ESX.UI.Menu.CloseAll()
                    isInMarker = nil
                end
            end
        else
            Citizen.Wait(500)
        end
    end
end)

openBarMenu = function()
    ESX.UI.Menu.CloseAll()
    local inventory = ESX.PlayerData.inventory
    local elements = {}
    for k,v in pairs(Config.Bar) do
        for k2,v2 in pairs(inventory) do
            if k == v2.name then
                table.insert(elements, {
                    label = v2.label.." - Pris: "..v.." DKK",
                    item = k
                })
            end
        end
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'take_items', {
        title = _U('bar_spawn_title'),
        align = 'left',
        elements = elements
    }, function(data, menu)
        ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "amount", {
            title = "Skriv det antal du vil have"
        }, function(data2, menu2)
            if tonumber(data2.value) then
                TriggerServerEvent("vu_stripklub:giveBarItem", data.current.item, data2.value)
            end
            menu2.close()
            menu.close()
        end, function(data2, menu2)
            menu2.close()
        end)
    end, function(data, menu)
        menu.close()
    end)
end

openVehicleMenu = function()
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'take_vehicle', {
        title = _U('vehicle_spawn_title'),
        align = 'left',
        elements = Config.Vehicles
    }, function(data, menu)
        ESX.Game.SpawnVehicle(data.current.model, Config.Locations.Vehicle.spawnPoint, Config.Locations.Vehicle.heading, function(vehicle) 
            local playerPed = PlayerPedId()
            local vehProps = ESX.Game.GetVehicleProperties(vehicle)
            --vehProps.plate = exports['cBeyerV1']:GeneratePlate('VU', 4)
            vehProps.plateIndex = 1
            vehProps.windowTint = 1
            vehProps.modEngine = 2
            vehProps.modBrakes = 2
            vehProps.modTransmission = 2
            vehProps.modTurbo = true
            vehProps.modSuspension = 3
            vehProps.color1 = 12
            vehProps.color2 = 12
            vehProps.modSpoilers = 2
            ESX.Game.SetVehicleProperties(vehicle, vehProps)
            exports['LegacyFuel']:SetFuel(vehicle, 100)
            --TriggerServerEvent('cBeyerV1:setVehicleOwned', vehProps)
            TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
        end)
    end, function(data, menu)
        menu.close()
    end)
end