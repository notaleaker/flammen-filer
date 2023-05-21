function getEsxObject()
    local promise = promise.new()
    xpcall(function()
        esxObj = exports['es_extended']:getSharedObject()
        promise:resolve(esxObj)
    end, function(err)
        Citizen.CreateThread(function()
            while esxObj == nil do
                TriggerEvent(Config.Events['esx:getSharedObject'], function(obj) esxObj = obj end)
                Citizen.Wait(0)
            end

            promise:resolve(esxObj)
        end)
    end)

    return Citizen.Await(promise)
end

function loadFramework(esxObj, qbObj)
    if Config.Framework == Frameworks.ESX or Config.Framework == Frameworks.ESX_LIMIT then
        esxObj = getEsxObject()
    elseif Config.Framework == Frameworks.QBCORE then
        qbObj = exports[Config.Events['qb-core']]:GetCoreObject()
    else
        dbg.critical('Wrong option in frameworks!')
    end
end
