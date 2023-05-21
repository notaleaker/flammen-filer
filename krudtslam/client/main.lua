ESX = nil
local hasShot = false

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)ESX = obj end)
        Citizen.Wait(0)
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        ped = GetPlayerPed(-1)
        if IsPedShooting(ped) then
            TriggerServerEvent('esx_gsr:SetGSR', timer)
            hasShot = true
            Citizen.Wait(Config.gsrUpdate)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(2000)
        if Config.waterClean and hasShot then
            ped = GetPlayerPed(-1)
            if IsEntityInWater(ped) then
                exports['mythic_notify']:DoHudText('inform', 'Bliv i vandet for 30 sekuder for at vaske krudtslam af dne hænder.') 
                Citizen.Wait(Config.waterCleanTime)
                if IsEntityInWater(ped) then
                    hasShot = false
                    TriggerServerEvent('esx_gsr:Remove')
                    exports['mythic_notify']:DoHudText('inform', 'Du vaskede dit krudtslam af dine hænder.') 
                else
                    exports['mythic_notify']:DoHudText('inform', 'Du blev ik i vandet i lang nok tid så du fik ik vasket krudtslam af dine hænder.') 
                end
            end
        end
    end
end)

function status()
    if hasShot then
        ESX.TriggerServerCallback('esx_gsr:Status', function(cb)
            if not cb then
                hasShot = false
            end
        end)
    end
    SetTimeout(Config.gsrUpdateStatus, status)
end

status()
