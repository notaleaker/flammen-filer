local progress = false
local inSelling = false
local deliveryBlip = nil
local selectedCoords = nil
local woodCount = 0


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    if Config.LumberjackJob.jobRequired then
        if job.name == Config.LumberjackJob.jobName then
            for k,v in pairs(Config.Blips["Lumberjack"]) do
                if v.enabled then
                    if not DoesBlipExist(v.blip) then
                        v.blip = CreateBlip(v.coords, v.sprite, v.scale, v.color, v.name)
                    end
                end
            end 
        else
            for k,v in pairs(Config.Blips["Lumberjack"]) do
                if v.enabled then
                    if DoesBlipExist(v.blip) then
                        RemoveBlip(v.blip)
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(job)
    if Config.LumberjackJob.jobRequired then
        if job.name == Config.LumberjackJob.jobName then
            for k,v in pairs(Config.Blips["Lumberjack"]) do
                if v.enabled then
                    if not DoesBlipExist(v.blip) then
                        v.blip = CreateBlip(v.coords, v.sprite, v.scale, v.color, v.name)
                    end
                end
            end 
        else
            for k,v in pairs(Config.Blips["Lumberjack"]) do
                if v.enabled then
                    if DoesBlipExist(v.blip) then
                        RemoveBlip(v.blip)
                    end
                end
            end
        end
    end
end)


RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    playerData = Framework.Functions.GetPlayerData()
    if Config.LumberjackJob.jobRequired then
        if playerData and playerData.job and playerData.job.name == Config.LumberjackJob.jobName then
            for k,v in pairs(Config.Blips["Lumberjack"]) do
                if v.enabled then
                    if not DoesBlipExist(v.blip) then
                        v.blip = CreateBlip(v.coords, v.sprite, v.scale, v.color, v.name)
                    end
                end
            end 
        end
    else
        for k,v in pairs(Config.Blips["Lumberjack"]) do
            if v.enabled then
                if not DoesBlipExist(v.blip) then
                    v.blip = CreateBlip(v.coords, v.sprite, v.scale, v.color, v.name)
                end
            end
        end  
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
    if Config.LumberjackJob.jobRequired then
        if playerData and playerData.job and playerData.job.name == Config.LumberjackJob.jobName then
            for k,v in pairs(Config.Blips["Lumberjack"]) do
                if v.enabled then
                    if not DoesBlipExist(v.blip) then
                        v.blip = CreateBlip(v.coords, v.sprite, v.scale, v.color, v.name)
                    end
                end
            end 
        end
    else
        for k,v in pairs(Config.Blips["Lumberjack"]) do
            if v.enabled then
                if not DoesBlipExist(v.blip) then
                    v.blip = CreateBlip(v.coords, v.sprite, v.scale, v.color, v.name)
                end
            end
        end  
    end
end)

WoodAnim = function(playerPed, heading)
    FreezeEntityPosition(playerPed, true)
    local hatchet = CreateObject(GetHashKey("w_me_battleaxe"), 0, 0, 0, true, true, true) 
    AttachEntityToEntity(hatchet, playerPed, GetPedBoneIndex(playerPed, 57005), 0.09, 0.03, -0.02, -78.0, 13.0, 28.0, false, false, false, false, 1, true)
    SetEntityHeading(playerPed, heading)
    local animDict = "anim@melee@machete@streamed_core_fps@"
    for i = 1, Config.LumberjackJob.hitCount do
        while not HasAnimDictLoaded(animDict) do
            RequestAnimDict(animDict)
            Citizen.Wait(1)
        end
        TaskPlayAnim(playerPed, animDict, "small_melee_wpn_short_range_0", 8.0, 8.0, -1, 16, 0, false, false, false)
        Citizen.Wait(GetAnimDuration(animDict, "small_melee_wpn_short_range_0")* 1000)
    end
    progress = false
    FreezeEntityPosition(playerPed, false)
    DeleteEntity(hatchet)
    RemoveAnimDict(animDict)
    TriggerServerEvent("frp_jobs:server:AddItem", "wood", Config.LumberjackJob.woodGive)
    ShowNotification(Strings["lumberjack_gave_wood"])
end

WoodCuttingAnim = function(playerPed, heading)
    SetEntityHeading(playerPed, heading)
    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_GARDENER_LEAF_BLOWER", 0, true)
    Citizen.Wait(10000)
    ClearPedTasks(playerPed)
    progress = false
    ClearAreaOfEverything(GetEntityCoords(playerPed), 1.0, 0, 0, 0, 0)
    local animDict = "random@domestic"
    while not HasAnimDictLoaded(animDict) do
        RequestAnimDict(animDict)
        Citizen.Wait(1)
    end
    TaskPlayAnim(playerPed, animDict, "pickup_low", 8.0, -8.0, -1, 0, 0, false, false, false)
    RemoveAnimDict(animDict)
    TriggerServerEvent("frp_jobs:server:AddItem", "cleaned_wood", Config.LumberjackJob.cleanedGive)
    ShowNotification(Strings["lumberjack_gave_cleaned_wood"])
end

WoodPruningAnim = function(playerPed, heading)
    FreezeEntityPosition(playerPed, true)
    local hatchet = CreateObject(GetHashKey("w_me_battleaxe"), 0, 0, 0, true, true, true) 
    AttachEntityToEntity(hatchet, playerPed, GetPedBoneIndex(playerPed, 57005), 0.09, 0.03, -0.02, -78.0, 13.0, 28.0, false, false, false, false, 1, true)
    SetEntityHeading(playerPed, heading)
    local animDict = "melee@small_wpn@streamed_core"
    for i = 1, Config.LumberjackJob.plankHitCount do
        while not HasAnimDictLoaded(animDict) do
            RequestAnimDict(animDict)
            Citizen.Wait(1)
        end
        TaskPlayAnim(playerPed, animDict, "small_melee_wpn_long_range_0", 8.0, -8.0, -1, 16, 0, false, false, false)
        Citizen.Wait(GetAnimDuration(animDict, "small_melee_wpn_long_range_0")* 1000)
    end
    progress = false
    FreezeEntityPosition(playerPed, false)
    DeleteEntity(hatchet)
    RemoveAnimDict(animDict)
    TriggerServerEvent("frp_jobs:server:AddItem", "plank", Config.LumberjackJob.packedGive)
    ShowNotification(Strings["lumberjack_gave_plank"])
end

LumberjackTransportStart = function(truck, trailer)
    selectedCoords = Config.LumberjackJob.TransportCoords[math.random(1, #Config.LumberjackJob.TransportCoords)]
    deliveryBlip = AddBlipForCoord(selectedCoords.x, selectedCoords.y, selectedCoords.z)
    SetBlipRoute(deliveryBlip, true)
    local finish = false
    Citizen.CreateThread(function()
        while true do
            local sleep = 1000
            local playerPed = PlayerPedId()
            local pCoords = GetEntityCoords(playerPed)
            if not finish then
                local dst = #(pCoords - selectedCoords)
                if dst <= 50 then
                    sleep = 1
                    if dst <= 20 then
                        DrawMarker(1, selectedCoords.x, selectedCoords.y, selectedCoords.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 10.0, 10.0, 10.0, 105, 80, 51, 100, false, true, 2, false, false, false, false)
                        if dst <= 5 then
                            ShowHelpNotification(Strings["lumberjack_deliver_planks"])
                            if IsControlJustPressed(0, 38) and not progress then
                                progress = true
                                DoScreenFadeOut(1000)
                                Citizen.Wait(1500)
                                selectedCoords = Config.LumberjackJob.FinishCoords
                                RemoveBlip(deliveryBlip)
                                deliveryBlip = AddBlipForCoord(selectedCoords.x, selectedCoords.y, selectedCoords.z)
                                SetBlipRoute(deliveryBlip, true)
                                SetBlipSprite(deliveryBlip, 164)
                                SetBlipColour(deliveryBlip, 5)
                                SetBlipAsShortRange(deliveryBlip, false)
                                BeginTextCommandSetBlipName("STRING")
                                AddTextComponentString("Finish")
                                EndTextCommandSetBlipName(deliveryBlip)
                                DoScreenFadeIn(1000)
                                progress = false
                                finish = true
                                ShowNotification(Strings["lumberjack_back_factory"])
                            end
                        end
                    end
                end
            else
                local dst = #(pCoords - selectedCoords)
                if dst <= 50 then
                    sleep = 1
                    if dst <= 20 then
                        DrawMarker(1, selectedCoords.x, selectedCoords.y, selectedCoords.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 10.0, 10.0, 10.0, 105, 80, 51, 100, false, true, 2, false, false, false, false)
                        if dst <= 5 then
                            ShowHelpNotification(Strings["lumberjack_deliver_truck"])
                            if IsControlJustPressed(0, 38) and not progress then
                                if GetEntityModel(GetVehiclePedIsUsing(playerPed)) == GetHashKey(Config.LumberjackJob.TransportVehicle) then
                                    progress = true
                                    DoScreenFadeOut(1000)
                                    Citizen.Wait(1500)
                                    RemoveBlip(deliveryBlip)
                                    DeleteEntity(truck)
                                    DeleteEntity(trailer)
                                    DoScreenFadeIn(1000)
                                    progress = false
                                    inSelling = false
                                    deliveryBlip = nil
                                    selectedCoords = nil
                                    TriggerServerEvent("frp_jobs:server:AddMoney", woodCount * Config.LumberjackJob.Price)
                                    break
                                else
                                    ShowNotification(Strings["vehicle_not_found"])
                                end
                            end
                        end
                    end
                end  
            end
            Citizen.Wait(sleep)
        end
    end)
end

LumberjackStartSelling = function(playerPed)
    local data = Config.LumberjackJob
    local vehicle = SpawnVehicle(data.TransportVehicle, data.VehicleSpawnCoords)
    local trailer = SpawnVehicle(data.TransportTrailer, data.TrailerSpawnCoords)
    local forklift = SpawnVehicle(data.ForkliftModel, data.ForkliftSpawnCoords)
    local packageCount = 0
    for k,v in pairs(data.PackageCoords) do
        v.handle = CreateObject(GetHashKey(data.PackageModel), v.coords.x, v.coords.y, v.coords.z - 1, true, true, true)
        packageCount = packageCount + 1
    end
    local vblip = AddBlipForEntity(vehicle)
    SetBlipSprite(vblip, 67)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Delivery Vehicle")
    EndTextCommandSetBlipName(vblip)
    ShowNotification(Strings["lumberjack_start_loading"])
    Citizen.CreateThread(function()
        while true do
            local sleep = 1000
            local pCoords = GetEntityCoords(playerPed)
            if packageCount > 0 then
                for k,v in pairs(data.PackageCoords) do
                    if DoesEntityExist(v.handle) then
                        local entityCoords = GetEntityCoords(v.handle)
                        local dst = #(pCoords - entityCoords)
                        if dst <= 50 then
                            sleep = 1
                            if dst <= 20 then
                                DrawMarker(20, entityCoords.x, entityCoords.y, entityCoords.z + 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 105, 80, 51, 100, false, true, 2, false, false, false, false)
                                local dimension = GetModelDimensions(GetEntityModel(trailer))
                                local trunk = GetOffsetFromEntityInWorldCoords(trailer, 0.0, dimension["y"] - 0.2, 0.0)
                                local tdst = #(pCoords - trunk)
                                if tdst <= 5 then
                                    ShowHelpNotification(Strings["lumberjack_load_vehicle"])
                                    DrawMarker(20, trunk.x, trunk.y, trunk.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 105, 80, 51, 100, false, true, 2, false, false, false, false)
                                    if IsControlJustPressed(0, 38) and not progress then
                                        if IsEntityInAir(v.handle) then
                                            progress = true
                                            DeleteEntity(v.handle)
                                            packageCount = packageCount - 1
                                            progress = false
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            else
                DoScreenFadeOut(1000)
                Citizen.Wait(1500)
                DeleteEntity(forklift)
                DoScreenFadeIn(1000)
                ShowNotification(Strings["lumberjack_start_transport"])
                LumberjackTransportStart(vehicle, trailer)
                break
            end
            Citizen.Wait(sleep)
        end
    end)
end

-- Lumberjack
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local pCoords = GetEntityCoords(playerPed)
        -- Wood --
        for k,v in pairs(Config.LumberjackJob.WoodCoords) do
            local dst = #(pCoords - vector3(v.x, v.y, v.z))
            if dst <= 50 then
                sleep = 1
                if dst <= 40 and not progress then
                    DrawMarker(0, v.x, v.y, v.z + 1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 105, 80, 51, 200, 1, 0, 0, 0)
                    if dst <= 3 then
                        ShowHelpNotification(Strings["start_cutting"])
                        if IsControlJustPressed(0,  38) and not progress then
                            progress = true
                            ShowNotification(Strings["lumberjack_cutting"])
                            WoodAnim(playerPed, v.w)
                        end
                    end
                end
            end
        end
        -- Cutting --
        for k,v in pairs(Config.LumberjackJob.CuttingCoords) do
            local dst = #(pCoords - vector3(v.x, v.y, v.z))
            if dst <= 50 then
                sleep = 1
                if dst <= 40 and not progress then
                    DrawMarker(20, v.x, v.y, v.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 105, 80, 51, 200, 0, 1, 0, 0)
                    if dst <= 3 then
                        ShowHelpNotification(Strings["start_cleaning"])
                        if IsControlJustPressed(0,  38) and not progress then
                            TriggerCallback("frp_jobs:server:CheckItem", function(data) 
                                if data.status then
                                    progress = true
                                    TriggerServerEvent("frp_jobs:server:RemoveItem", "wood", Config.LumberjackJob.woodRemove)
                                    ShowNotification(Strings["lumberjack_cleaning"])
                                    WoodCuttingAnim(playerPed, v.w)
                                else
                                    ShowNotification(Strings["dont_have_wood"])
                                end
                            end, { item = "wood", count = Config.LumberjackJob.woodRemove })
                        end
                    end
                end
            end
        end
        -- Plank --
        for k,v in pairs(Config.LumberjackJob.PlankCoords) do
            local dst = #(pCoords - vector3(v.x, v.y, v.z))
            if dst <= 50 then
                sleep = 1
                if dst <= 40 and not progress then
                    DrawMarker(20, v.x, v.y, v.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 105, 80, 51, 200, 0, 1, 0, 0)
                    if dst <= 3 then
                        ShowHelpNotification(Strings["start_pruning"])
                        if IsControlJustPressed(0,  38) and not progress then
                            TriggerCallback("frp_jobs:server:CheckItem", function(data) 
                                if data.status then
                                    progress = true
                                    ShowNotification(Strings["lumberjack_pruning"])
                                    TriggerServerEvent("frp_jobs:server:RemoveItem", "cleaned_wood", Config.LumberjackJob.cleanedRemove)
                                    WoodPruningAnim(playerPed, v.w)
                                else
                                    ShowNotification(Strings["dont_have_cleaned_wood"])
                                end
                            end, { item = "cleaned_wood", count = Config.LumberjackJob.cleanedRemove })
                        end
                    end
                end
            end
        end
        -- Selling --
        local dst = #(pCoords - Config.LumberjackJob.SellingCoords)
        if dst <= 50 then
            sleep = 1
            if dst <= 40 and not inSelling then
                DrawMarker(25, Config.LumberjackJob.SellingCoords.x, Config.LumberjackJob.SellingCoords.y, Config.LumberjackJob.SellingCoords.z - 1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 105, 80, 51, 200, 0, 1, 0, 0)
                if dst <= 2 then
                    ShowHelpNotification(Strings["start_selling_planks"])
                    if IsControlJustPressed(0,  38) and not progress then
                        TriggerCallback("frp_jobs:server:CheckItem", function(data) 
                            if data.status then
                                local spawnPoint = IsAnyVehicleNearPoint(Config.LumberjackJob.VehicleSpawnCoords.x, Config.LumberjackJob.VehicleSpawnCoords.y, Config.LumberjackJob.VehicleSpawnCoords.z, 3.0)
                                if not spawnPoint then
                                    inSelling = true
                                    woodCount = data.count
                                    TriggerServerEvent("frp_jobs:server:RemoveItem", "plank", data.count)
                                    LumberjackStartSelling(playerPed)
                                else
                                    ShowNotification(Strings["spawn_area_full"])
                                end
                            else
                                ShowNotification(Strings["dont_have_planks"])
                            end
                        end, { item = "plank", count = 1 })
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)