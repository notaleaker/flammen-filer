Framework = nil
PlayerData = nil

Citizen.CreateThread(function()
    if Config.Framework == "esx" then
        while Framework == nil do
            TriggerEvent('esx:getSharedObject', function(obj) Framework = obj end)
            Citizen.Wait(0)
        end
        while PlayerData == nil do
            PlayerData = Framework.GetPlayerData()
            Citizen.Wait(500)
        end
    elseif Config.Framework == "qbcore" then
        Framework = exports['qb-core']:GetCoreObject()
        while PlayerData == nil do
            PlayerData = Framework.Functions.GetPlayerData()
            Citizen.Wait(500)
        end
    end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(job)
    PlayerData.job = job
end)

TriggerCallback = function(cbName, cb, data)
    if Config.Framework == "esx" then
        Framework.TriggerServerCallback(cbName, function(output)
            if cb then cb(output) else return output end  
        end, data)
    elseif Config.Framework == "qbcore" then
        Framework.Functions.TriggerCallback(cbName, function(output)
            if cb then cb(output) else return output end  
        end, data)
    end
end

CreateBlip = function(coords, sprite, scale, color, name)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipScale(blip, scale)
    SetBlipColour(blip, color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)
    return blip
end







