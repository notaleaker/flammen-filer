local progress = false
local chickenPed = "a_c_hen"
local package = nil
local inSelling = false
local deliveryBlip = nil
local selectedCoords = nil
local packageInHand = false
local count = 0
local chickenCount = 0


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    if Config.ButcherJob.jobRequired then
        if job.name == Config.ButcherJob.jobName then
            for k,v in pairs(Config.Blips["Butcher"]) do
                if v.enabled then
                    if not DoesBlipExist(v.blip) then
                        v.blip = CreateBlip(v.coords, v.sprite, v.scale, v.color, v.name)
                    end
                end
            end 
        else
            for k,v in pairs(Config.Blips["Butcher"]) do
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
    if Config.ButcherJob.jobRequired then
        if job.name == Config.ButcherJob.jobName then
            for k,v in pairs(Config.Blips["Butcher"]) do
                if v.enabled then
                    if not DoesBlipExist(v.blip) then
                        v.blip = CreateBlip(v.coords, v.sprite, v.scale, v.color, v.name)
                    end
                end
            end 
        else
            for k,v in pairs(Config.Blips["Butcher"]) do
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
    if Config.ButcherJob.jobRequired then
        if playerData and playerData.job and playerData.job.name == Config.ButcherJob.jobName then
            for k,v in pairs(Config.Blips["Butcher"]) do
                if v.enabled then
                    if not DoesBlipExist(v.blip) then
                        v.blip = CreateBlip(v.coords, v.sprite, v.scale, v.color, v.name)
                    end
                end
            end 
        end
    else
        for k,v in pairs(Config.Blips["Butcher"]) do
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
    if Config.ButcherJob.jobRequired then
        if playerData and playerData.job and playerData.job.name == Config.ButcherJob.jobName then
            for k,v in pairs(Config.Blips["Butcher"]) do
                if v.enabled then
                    if not DoesBlipExist(v.blip) then
                        v.blip = CreateBlip(v.coords, v.sprite, v.scale, v.color, v.name)
                    end
                end
            end 
        end
    else
        for k,v in pairs(Config.Blips["Butcher"]) do
            if v.enabled then
                if not DoesBlipExist(v.blip) then
                    v.blip = CreateBlip(v.coords, v.sprite, v.scale, v.color, v.name)
                end
            end
        end  
    end
end)

SpawnChicken = function()
    RequestAndWaitModel(chickenPed)
    for k,v in pairs(Config.ButcherJob.ChickenCoords) do
        if not DoesEntityExist(v.handle) then
            v.handle = CreatePed(26, chickenPed, v.coords, false, false)
            TaskReactAndFleePed(v.handle, PlayerPedId())
        end
    end
    return
end

ButcherCatchAnim = function(playerPed, chicken)
    local animDict = "move_jump"
    while not HasAnimDictLoaded(animDict) do
        RequestAnimDict(animDict)
        Citizen.Wait(1)
    end
    TaskPlayAnim(playerPed, animDict, 'dive_start_run', 8.0, -8.0, -1, 0, 0.0, 0, 0, 0)
    Citizen.Wait(GetAnimDuration(animDict, "dive_start_run")* 1000)
    RemoveAnimDict(animDict)
    local chance = math.random(1, 4)
    if chance == 2 then
        DeleteEntity(chicken)
        TriggerServerEvent("frp_jobs:server:AddItem", "alive_chicken", Config.ButcherJob.chickenGive)
        ShowNotification(Strings["butcher_gave_chicken"])
    else
        ShowNotification(Strings["butcher_fail_chicken"])
    end
    progress = false
end

ButcherCuttingAnim = function(playerPed, heading, chickenCoords, chickenRotation)
    SetEntityHeading(playerPed, heading)
    local animDict = 'anim@amb@business@coc@coc_unpack_cut_left@'
    local pCoords = GetEntityCoords(playerPed)
    while not HasAnimDictLoaded(animDict) do
        RequestAnimDict(animDict)
        Citizen.Wait(1)
    end
    TaskPlayAnim(playerPed, animDict, "coke_cut_v1_coccutter", 3.0, -8, -1, 63, 0, 0, 0, 0 )
    local knife = CreateObject(GetHashKey('prop_knife'), pCoords.x, pCoords.y,pCoords.z, true, true, true)
    AttachEntityToEntity(knife, playerPed, GetPedBoneIndex(playerPed, 0xDEAD), 0.13, 0.14, 0.09, 40.0, 0.0, 0.0, false, false, false, false, 2, true)
    local chicken = CreateObject(GetHashKey('prop_int_cf_chick_01'), chickenCoords, true, true, true)
    SetEntityRotation(chicken, chickenRotation, 1, true)
    Citizen.Wait(GetAnimDuration(animDict, "coke_cut_v1_coccutter")* 1000)
    ClearPedTasks(playerPed)
    DeleteEntity(knife)
    DeleteEntity(chicken)
    progress = false
    TriggerServerEvent("frp_jobs:server:AddItem", "slaughtered_chicken", Config.ButcherJob.slaughteredGive)
    ShowNotification(Strings["butcher_gave_slaughtered_chicken"])
end

ButcherPackageAnim = function(playerPed, heading)
	SetEntityHeading(playerPed, heading)
    local animDict = 'anim@heists@ornate_bank@grab_cash_heels'
    local pCoords = GetEntityCoords(playerPed)
    while not HasAnimDictLoaded(animDict) do
        RequestAnimDict(animDict)
        Citizen.Wait(1)
    end
	local steak = CreateObject(GetHashKey('prop_cs_steak'), pCoords.x, pCoords.y,pCoords.z, true, true, true)
	local box = CreateObject(GetHashKey('prop_cs_clothes_box'), pCoords.x, pCoords.y,pCoords.z, true, true, true)
	AttachEntityToEntity(steak, playerPed, GetPedBoneIndex(playerPed, 0x49D9), 0.15, 0.0, 0.01, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
	AttachEntityToEntity(box, playerPed, GetPedBoneIndex(playerPed, 57005), 0.13, 0.0, -0.16, 250.0, -30.0, 0.0, false, false, false, false, 2, true)
	TaskPlayAnim(playerPed, animDict, "grab", 8.0, -8.0, -1, 1, 0, false, false, false)
    Citizen.Wait(Config.ButcherJob.PackageWait * 1000)
    ClearPedTasks(playerPed)
    DeleteEntity(steak)
    DeleteEntity(box)
    progress = false
    TriggerServerEvent("frp_jobs:server:AddItem", "packaged_chicken", Config.ButcherJob.packagedGive)
    ShowNotification(Strings["butcher_gave_packaged_chicken"])
end

ButcherFinishSelling = function(playerPed, vehicle, blip)
    if DoesEntityExist(vehicle) then
        SetEntityAsMissionEntity(vehicle, true, true)
        DeleteEntity(vehicle)
    end
    if DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
    progress = false
    inSelling = false
    TriggerServerEvent("frp_jobs:server:AddMoney", chickenCount * Config.ButcherJob.Price)
    package = nil
    deliveryBlip = nil
    selectedCoords = nil
    packageInHand = false
    count = 0
    chickenCount = 0
end

ButcherGetPackageAnim = function(playerPed, vehicle)
    local animDict = 'anim@heists@box_carry@'
    while not HasAnimDictLoaded(animDict) do
        RequestAnimDict(animDict)
        Citizen.Wait(1)
    end
    SetVehicleDoorOpen(vehicle, 2, false, false)
    SetVehicleDoorOpen(vehicle, 3, false, false)
    package = CreateObject(GetHashKey("prop_cs_cardbox_01"), 0.0, 0.0, 0.0, true, true, true)
    AttachEntityToEntity(package, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, -0.03, 0.0, 5.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
    TaskPlayAnim(playerPed, animDict, "idle", 8.0, 8.0, -1, 50, 0, false, false, false)
    Citizen.Wait(500)
    SetVehicleDoorShut(vehicle, 2, false, true)
    SetVehicleDoorShut(vehicle, 3, false, true)
end

ButcherStartSelling = function(playerPed, spawnCoords)
    Citizen.CreateThread(function()
        local vehicle = SpawnVehicle(Config.ButcherJob.TransportVehicle, spawnCoords)
        local vblip = AddBlipForEntity(vehicle)
        SetBlipSprite(vblip, 67)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Delivery Vehicle")
        EndTextCommandSetBlipName(vblip)
        selectedCoords = Config.ButcherJob.TransportCoords[math.random(1, #Config.ButcherJob.TransportCoords)]
        deliveryBlip = AddBlipForCoord(selectedCoords.x, selectedCoords.y, selectedCoords.z)
        SetBlipRoute(deliveryBlip, true)
        while true do
            local playerPed = PlayerPedId()
            local pCoords = GetEntityCoords(playerPed)
            local dst = #(pCoords - selectedCoords)
            if Config.ButcherJob.TransportCount > count then
                if not DoesBlipExist(deliveryBlip) then
                    deliveryBlip = AddBlipForCoord(selectedCoords.x, selectedCoords.y, selectedCoords.z)
                    SetBlipRoute(deliveryBlip, true)
                end
                if dst <= 50 then
                    sleep = 1
                    local dimension = GetModelDimensions(GetEntityModel(vehicle))
                    local trunk = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, dimension["y"] - 0.2, 0.0)
                    local tdst = #(pCoords - trunk)
                    if tdst <= 10 and not IsPedInAnyVehicle(playerPed) and not progress then
                        DrawMarker(2, trunk.x, trunk.y, trunk.z - 0.3, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 230, 138, 46, 200, 0, 1, 0, 0)
                        if tdst <= 1 then
                            ShowHelpNotification(Strings["open_trunk"])
                            if IsControlJustPressed(0, 38) and not progress then
                                progress = true
                                packageInHand = true
                                ButcherGetPackageAnim(playerPed, vehicle)
                            end
                        end
                    end
                    if dst <= 15 and packageInHand then
                        DrawMarker(25, selectedCoords.x, selectedCoords.y, selectedCoords.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 230, 138, 46, 200, 0, 1, 0, 0)
                        if dst <= 3 then
                            ShowHelpNotification(Strings["butcher_deliver_package"])
                            if IsControlJustPressed(0, 38) and progress then
                                progress = false
                                packageInHand = false
                                RemoveBlip(deliveryBlip)
                                DeleteEntity(package)
                                ClearPedTasksImmediately(playerPed)
                                count = count + 1
                                if Config.ButcherJob.TransportCount > count then
                                    ShowNotification(Strings["butcher_deliver_next"])
                                    selectedCoords = Config.ButcherJob.TransportCoords[math.random(1, #Config.ButcherJob.TransportCoords)]
                                end
                            end
                        end
                    end
                end
            else
                selectedCoords = Config.ButcherJob.FinishCoords
                if not DoesBlipExist(deliveryBlip) then
                    deliveryBlip = AddBlipForCoord(selectedCoords.x, selectedCoords.y, selectedCoords.z)
                    SetBlipSprite(deliveryBlip, 164)
                    SetBlipColour(deliveryBlip, 5)
                    SetBlipAsShortRange(deliveryBlip, false)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Finish")
                    EndTextCommandSetBlipName(deliveryBlip)
                    SetBlipRoute(deliveryBlip, true)
                    ShowNotification(Strings["butcher_back_factory"])
                end
                local dst = #(pCoords - Config.ButcherJob.FinishCoords)
                if dst <= 50 then
                    sleep = 1
                    if dst <= 15 then
                        DrawMarker(1, Config.ButcherJob.FinishCoords.x, Config.ButcherJob.FinishCoords.y, Config.ButcherJob.FinishCoords.z - 1, 0, 0, 0, 0, 0, 0, 10.0, 10.0, 10.0, 230, 138, 46, 200, 0, 1, 0, 0)
                        if dst <= 5 then
                            ShowHelpNotification(Strings["butcher_deliver_van"])
                            if IsControlJustPressed(0, 38) and not progress then
                                if GetEntityModel(GetVehiclePedIsUsing(playerPed)) == GetHashKey(Config.ButcherJob.TransportVehicle) then
                                    progress = true
                                    ButcherFinishSelling(playerPed, vehicle, deliveryBlip)
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

Citizen.CreateThread(function()
    SpawnChicken()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local pCoords = GetEntityCoords(playerPed)
        -- Gathering --
        for k,v in pairs(Config.ButcherJob.ChickenCoords) do
            if DoesEntityExist(v.handle) and not IsEntityDead(v.handle) then
                local chickenCoords = GetEntityCoords(v.handle)
                local dst = #(pCoords - chickenCoords)
                local dst2 = #(chickenCoords - v.coords)
                if dst2 > 25 or not DoesEntityExist(v.handle) then
                    SpawnChicken()
                end
                if dst <= 50 then
                    sleep = 1
                    if dst <= 10 then
                        DrawMarker(0, chickenCoords.x, chickenCoords.y, chickenCoords.z + 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 0, 0, 100, true, false, 2, false, false, false, false)
                        if dst <= 1.5 then
                            ShowHelpNotification(Strings["start_catching"])
                            if IsControlJustPressed(0, 38) and not progress then
                                progress = true
                                ButcherCatchAnim(playerPed, v.handle)
                            end
                        end
                    end
                end
            else
                if IsEntityDead(v.handle) then
                    DeleteEntity(v.handle)
                    v.handle = nil
                end
                SpawnChicken()
            end
        end
        -- Cutting --
        for k,v in pairs(Config.ButcherJob.CuttingCoords) do
            local dst = #(pCoords - vector3(v.coords.x, v.coords.y, v.coords.z))
            if dst <= 50 then
                sleep = 1
                if dst <= 40 and not progress then
                    DrawMarker(25, v.coords.x, v.coords.y, v.coords.z - 1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 230, 138, 46, 200, 0, 1, 0, 0)
                    if dst <= 2 then
                        ShowHelpNotification(Strings["start_cutting_chicken"])
                        if IsControlJustPressed(0,  38) and not progress then
                            TriggerCallback("frp_jobs:server:CheckItem", function(data) 
                                if data.status then
                                    progress = true
                                    TriggerServerEvent("frp_jobs:server:RemoveItem", "alive_chicken", Config.ButcherJob.chickenRemove)
                                    ShowNotification(Strings["butcher_start_slaughtered"])
                                    ButcherCuttingAnim(playerPed, v.coords.w, v.chickenCoords, v.rotation)
                                else
                                    ShowNotification(Strings["dont_have_chicken"])
                                end
                            end, { item = "alive_chicken", count = Config.ButcherJob.chickenRemove })
                        end
                    end
                end
            end
        end
        -- Package --
        for k,v in pairs(Config.ButcherJob.PackageCoords) do
            local dst = #(pCoords - vector3(v.x, v.y, v.z))
            if dst <= 50 then
                sleep = 1
                if dst <= 40 and not progress then
                    DrawMarker(25, v.x, v.y, v.z - 1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 230, 138, 46, 200, 0, 1, 0, 0)
                    if dst <= 2 then
                        ShowHelpNotification(Strings["start_packing_chicken"])
                        if IsControlJustPressed(0,  38) and not progress then
                            TriggerCallback("frp_jobs:server:CheckItem", function(data) 
                                if data.status then
                                    progress = true
                                    TriggerServerEvent("frp_jobs:server:RemoveItem", "slaughtered_chicken", Config.ButcherJob.slaughteredRemove)
                                    ShowNotification(Strings["butcher_start_packing"])
                                    ButcherPackageAnim(playerPed, v.w)
                                else
                                    ShowNotification(Strings["dont_have_slaughtered_chicken"])
                                end
                            end, { item = "slaughtered_chicken", count = Config.ButcherJob.slaughteredRemove })
                        end
                    end
                end
            end
        end
        -- Selling --
        local dst = #(pCoords - Config.ButcherJob.SellingCoords)
        if dst <= 50 then
            sleep = 1
            if dst <= 40 and not inSelling then
                DrawMarker(25, Config.ButcherJob.SellingCoords.x, Config.ButcherJob.SellingCoords.y, Config.ButcherJob.SellingCoords.z - 1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 230, 138, 46, 200, 0, 1, 0, 0)
                if dst <= 2 then
                    ShowHelpNotification(Strings["butcher_deliver_chicken"])
                    if IsControlJustPressed(0,  38) and not progress then
                        TriggerCallback("frp_jobs:server:CheckItem", function(data) 
                            if data.status then
                                local spawnPoint = IsSpawnPointClear(Config.ButcherJob.VehicleSpawnCoords)
                                if spawnPoint then
                                    inSelling = true
                                    chickenCount = data.count
                                    TriggerServerEvent("frp_jobs:server:RemoveItem", "packaged_chicken", data.count)
                                    ButcherStartSelling(playerPed, spawnPoint)
                                else
                                    ShowNotification(Strings["spawn_area_full"])
                                end
                            else
                                ShowNotification(Strings["dont_have_packaged_chicken"])
                            end
                        end, { item = "packaged_chicken", count = 1 })
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)
