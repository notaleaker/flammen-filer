local maxSpeed = 999.0

RegisterCommand('cc', function(source, args, rawCommand)
    local player = GetPlayerPed(-1)
    if not IsPedInAnyVehicle(player) then
        exports['mythic_notify']:DoHudText('error', "Du er ikke i noget køretøj")
    else
        if args[1] then
            local player = GetPlayerPed(-1)
            local vehicle = GetVehiclePedIsIn(player)
            local vehicleSpeed = GetEntitySpeed(vehicle)
            --print("YES")
            print(args[1])
            print(vehicleSpeed)
            if args[1] + 0.0 >= vehicleSpeed then
                maxSpeed = ((args[1] + 0.0) / 3.6) - 0.4
                exports['mythic_notify']:DoHudText('success', "Du har sat fartpilot til "..args[1].." Km/t")
            else
                exports['mythic_notify']:DoHudText('error', "Fartpiloten kan ikke sættes til en fart under din hastighed")
            end
        else 
            exports['mythic_notify']:DoHudText('inform', "Du slog din fartpilot fra")
            maxSpeed = 999.0
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        local player = GetPlayerPed(-1)
        if IsPedInAnyVehicle(player) then
            local vehicle = GetVehiclePedIsIn(player)
            SetVehicleMaxSpeed(vehicle, maxSpeed)
        end        
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 20) or IsDisabledControlJustPressed(0, 20) then
            local player = GetPlayerPed(-1)
            if IsPedInAnyVehicle(player) then
                local vehicle = GetVehiclePedIsIn(player)
                SetVehicleMaxSpeed(vehicle, 999.0)
            end 
        end
    end
end)

--[[Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if maxSpeed < 900.0 then
            if IsControlJustPressed(0, 31) then
                exports['mythic_notify']:DoHudText('inform', "Ophævede cruise control")
                maxSpeed = 999.0    
            end
        end
    end
end)]]