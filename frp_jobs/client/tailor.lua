local progress = false
local package = nil
local inSelling = false
local deliveryBlip = nil
local selectedCoords = nil
local packageInHand = false
local count = 0
local woolCount = 0


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    if Config.TailorJob.jobRequired then
        if job.name == Config.TailorJob.jobName then
            for k,v in pairs(Config.Blips["Tailor"]) do
                if v.enabled then
                    if not DoesBlipExist(v.blip) then
                        v.blip = CreateBlip(v.coords, v.sprite, v.scale, v.color, v.name)
                    end
                end
            end 
        else
            for k,v in pairs(Config.Blips["Tailor"]) do
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
    if Config.TailorJob.jobRequired then
        if job.name == Config.TailorJob.jobName then
            for k,v in pairs(Config.Blips["Tailor"]) do
                if v.enabled then
                    if not DoesBlipExist(v.blip) then
                        v.blip = CreateBlip(v.coords, v.sprite, v.scale, v.color, v.name)
                    end
                end
            end 
        else
            for k,v in pairs(Config.Blips["Tailor"]) do
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
    if Config.TailorJob.jobRequired then
        if playerData and playerData.job and playerData.job.name == Config.TailorJob.jobName then
            for k,v in pairs(Config.Blips["Tailor"]) do
                if v.enabled then
                    if not DoesBlipExist(v.blip) then
                        v.blip = CreateBlip(v.coords, v.sprite, v.scale, v.color, v.name)
                    end
                end
            end 
        end
    else
        for k,v in pairs(Config.Blips["Tailor"]) do
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
    if Config.TailorJob.jobRequired then
        if playerData and playerData.job and playerData.job.name == Config.TailorJob.jobName then
            for k,v in pairs(Config.Blips["Tailor"]) do
                if v.enabled then
                    if not DoesBlipExist(v.blip) then
                        v.blip = CreateBlip(v.coords, v.sprite, v.scale, v.color, v.name)
                    end
                end
            end 
        end
    else
        for k,v in pairs(Config.Blips["Tailor"]) do
            if v.enabled then
                if not DoesBlipExist(v.blip) then
                    v.blip = CreateBlip(v.coords, v.sprite, v.scale, v.color, v.name)
                end
            end
        end  
    end
end)


TailorDeliveryAnim = function(npc, npcCoords)
    local prop = CreateObject(GetHashKey('hei_prop_heist_box'), npcCoords.x, npcCoords.y, npcCoords.z + 0.2, true, true, true)
    AttachEntityToEntity(prop, npc, GetPedBoneIndex(npc, 60309), 0.025, 0.08, 0.255,-145.0, 290.0, 0.0, true, true, false, true, 1, true)
    while not HasAnimDictLoaded("anim@heists@box_carry@") do
        Citizen.Wait(10)
        RequestAnimDict("anim@heists@box_carry@")
    end
    TaskPlayAnim(npc, "anim@heists@box_carry@", "idle", 8.0, -8.0, -1, 0, 0, 0, 0, 0)
    Citizen.Wait(2000)
    DeleteEntity(prop)
    ClearPedTasksImmediately(npc)
    progress = false
    TriggerServerEvent("frp_jobs:server:AddItem", "wool", Config.TailorJob.woolGive)
    ShowNotification(Strings["tailor_buyed_wool"])
end

TailorSewingAnim = function(playerPed, heading, anim)
    SetEntityHeading(playerPed, heading)
    local animDict = "missheist_jewel_setup"
    while not HasAnimDictLoaded(animDict) do
        RequestAnimDict(animDict)
        Citizen.Wait(1)
    end
    TaskPlayAnim(playerPed, animDict, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
    Citizen.Wait(GetAnimDuration(animDict, anim) * 1000)
    ClearPedTasks(playerPed)
    progress = false
    TriggerServerEvent("frp_jobs:server:AddItem", "clothes", Config.TailorJob.clothesGive)
    ShowNotification(Strings["tailor_gave_clothes"])
end

TailorPackingAnim = function(playerPed, heading)
	SetEntityHeading(playerPed, heading)
    local animDict = 'anim@heists@ornate_bank@grab_cash_heels'
    local pCoords = GetEntityCoords(playerPed)
    while not HasAnimDictLoaded(animDict) do
        RequestAnimDict(animDict)
        Citizen.Wait(1)
    end
	local shirt = CreateObject(GetHashKey('p_t_shirt_pile_s'), pCoords.x, pCoords.y,pCoords.z, true, true, true)
	local box = CreateObject(GetHashKey('prop_cs_clothes_box'), pCoords.x, pCoords.y,pCoords.z, true, true, true)
	AttachEntityToEntity(shirt, playerPed, GetPedBoneIndex(playerPed, 0x49D9), 0.15, 0.0, 0.01, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
	AttachEntityToEntity(box, playerPed, GetPedBoneIndex(playerPed, 57005), 0.13, 0.0, -0.16, 250.0, -30.0, 0.0, false, false, false, false, 2, true)
	TaskPlayAnim(playerPed, animDict, "grab", 8.0, -8.0, -1, 1, 0, false, false, false)
    Citizen.Wait(Config.TailorJob.PackageWait * 1000)
    ClearPedTasks(playerPed)
    DeleteEntity(shirt)
    DeleteEntity(box)
    progress = false
    TriggerServerEvent("frp_jobs:server:AddItem", "packaged_clothes", Config.TailorJob.packagedGive)
    ShowNotification(Strings["tailor_gave_packaged_clothes"])
end

TailorGetPackageAnim = function(playerPed, vehicle)
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

TailorFinishSelling = function(playerPed, vehicle, blip)
    if DoesEntityExist(vehicle) then
        SetEntityAsMissionEntity(vehicle, true, true)
        DeleteEntity(vehicle)
    end
    if DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
    progress = false
    package = nil
    inSelling = false
    deliveryBlip = nil
    selectedCoords = nil
    packageInHand = false
    count = 0
    TriggerServerEvent("frp_jobs:server:AddMoney", woolCount * Config.TailorJob.Price)
    woolCount = 0
end

TailorStartSelling = function(playerPed, spawnCoords)
    Citizen.CreateThread(function()
        local vehicle = SpawnVehicle(Config.TailorJob.TransportVehicle, spawnCoords)
        local vblip = AddBlipForEntity(vehicle)
        SetBlipSprite(vblip, 67)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Delivery Vehicle")
        EndTextCommandSetBlipName(vblip)
        selectedCoords = Config.TailorJob.TransportCoords[math.random(1, #Config.TailorJob.TransportCoords)]
        deliveryBlip = AddBlipForCoord(selectedCoords.x, selectedCoords.y, selectedCoords.z)
        SetBlipRoute(deliveryBlip, true)
        ShowNotification(Strings["tailor_start_transport"])
        while true do
            local playerPed = PlayerPedId()
            local pCoords = GetEntityCoords(playerPed)
            local dst = #(pCoords - selectedCoords)
            if Config.TailorJob.TransportCount > count then
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
                        DrawMarker(2, trunk.x, trunk.y, trunk.z - 0.3, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 199, 195, 195, 200, 0, 1, 0, 0)
                        if tdst <= 1 then
                            ShowHelpNotification(Strings["open_trunk"])
                            if IsControlJustPressed(0, 38) and not progress then
                                progress = true
                                packageInHand = true
                                TailorGetPackageAnim(playerPed, vehicle)
                            end
                        end
                    end
                    if dst <= 15 and packageInHand then
                        DrawMarker(25, selectedCoords.x, selectedCoords.y, selectedCoords.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 199, 195, 195, 200, 0, 1, 0, 0)
                        if dst <= 3 then
                            ShowHelpNotification(Strings["tailor_deliver_package"])
                            if IsControlJustPressed(0, 38) and progress then
                                progress = false
                                packageInHand = false
                                RemoveBlip(deliveryBlip)
                                DeleteEntity(package)
                                ClearPedTasksImmediately(playerPed)
                                count = count + 1
                                if Config.TailorJob.TransportCount > count then
                                    ShowNotification(Strings["tailor_deliver_next"])
                                    selectedCoords = Config.TailorJob.TransportCoords[math.random(1, #Config.TailorJob.TransportCoords)]
                                end
                            end
                        end
                    end
                end
            else
                selectedCoords = Config.TailorJob.FinishCoords
                if not DoesBlipExist(deliveryBlip) then
                    deliveryBlip = AddBlipForCoord(selectedCoords.x, selectedCoords.y, selectedCoords.z)
                    SetBlipRoute(deliveryBlip, true)
                    SetBlipSprite(deliveryBlip, 164)
                    SetBlipColour(deliveryBlip, 5)
                    SetBlipAsShortRange(deliveryBlip, false)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Finish")
                    EndTextCommandSetBlipName(deliveryBlip)
                    ShowNotification(Strings["tailor_back_factory"])
                end
                local dst = #(pCoords - Config.TailorJob.FinishCoords)
                if dst <= 50 then
                    sleep = 1
                    if dst <= 15 then
                        DrawMarker(1, Config.TailorJob.FinishCoords.x, Config.TailorJob.FinishCoords.y, Config.TailorJob.FinishCoords.z - 1, 0, 0, 0, 0, 0, 0, 10.0, 10.0, 10.0, 199, 195, 195, 200, 0, 1, 0, 0)
                        if dst <= 5 then
                            ShowHelpNotification(Strings["tailor_deliver_van"])
                            if IsControlJustPressed(0, 38) and not progress then
                                if GetEntityModel(GetVehiclePedIsUsing(playerPed)) == GetHashKey(Config.TailorJob.TransportVehicle) then
                                    progress = true
                                    TailorFinishSelling(playerPed, vehicle, deliveryBlip)
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
    while not HasModelLoaded(Config.TailorJob.PedModel) do
        RequestModel(Config.TailorJob.PedModel)
        Citizen.Wait(10)
    end
    local ped = CreatePed(4, Config.TailorJob.PedModel, Config.TailorJob.PedCoords.x, Config.TailorJob.PedCoords.y, Config.TailorJob.PedCoords.z - 1, Config.TailorJob.PedCoords.w, false, false)
    SetPedDiesWhenInjured(ped, false)
    SetEntityInvincible(ped , true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    local npcCoords = GetEntityCoords(ped)
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local pCoords = GetEntityCoords(playerPed)
        local dst = #(pCoords - npcCoords)
        if dst <= 50 then
            sleep = 1
            if dst <= 3 and not progress then
                ShowHelpNotification((Strings["delivery_take"]):format(Config.TailorJob.WoolPrice))
                if IsControlJustPressed(0,  38) and not progress then
                    TriggerCallback("frp_jobs:server:CheckMoney", function(data) 
                        if data.status then
                            progress = true
                            TailorDeliveryAnim(ped, npcCoords)
                        else
                            ShowNotification(Strings["dont_have_money"])
                        end
                    end, { price = Config.TailorJob.WoolPrice })
                end
            end
        end
        for k,v in pairs(Config.TailorJob.SewingCoords) do
            local dst = #(pCoords - vector3(v.coords.x, v.coords.y, v.coords.z))
            if dst <= 50 then
                sleep = 1
                if dst <= 40 and not progress then
                    DrawMarker(25, v.coords.x, v.coords.y, v.coords.z - 1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 199, 195, 195, 200, 0, 1, 0, 0)
                    if dst <= 2 then
                        ShowHelpNotification(Strings["start_sewing"])
                        if IsControlJustPressed(0,  38) and not progress then
                            TriggerCallback("frp_jobs:server:CheckItem", function(data) 
                                if data.status then
                                    progress = true
                                    ShowNotification(Strings["tailor_sewing"])
                                    TriggerServerEvent("frp_jobs:server:RemoveItem", "wool", Config.TailorJob.woolRemove)
                                    TailorSewingAnim(playerPed, v.coords.w, v.anim)
                                else
                                    ShowNotification(Strings["dont_have_wool"])
                                end
                            end, { item = "wool", count = Config.TailorJob.woolRemove })
                        end
                    end
                end
            end
        end
        for k,v in pairs(Config.TailorJob.PackageCoords) do
            local dst = #(pCoords - vector3(v.x, v.y, v.z))
            if dst <= 50 then
                sleep = 1
                if dst <= 40 and not progress then
                    DrawMarker(25, v.x, v.y, v.z - 1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 199, 195, 195, 200, 0, 1, 0, 0)
                    if dst <= 2 then
                        ShowHelpNotification(Strings["start_package_clothes"])
                        if IsControlJustPressed(0,  38) and not progress then
                            TriggerCallback("frp_jobs:server:CheckItem", function(data) 
                                if data.status then
                                    progress = true
                                    TriggerServerEvent("frp_jobs:server:RemoveItem", "clothes", Config.TailorJob.clothesRemove)
                                    ShowNotification(Strings["tailor_start_packing"])
                                    TailorPackingAnim(playerPed, v.w)
                                else
                                    ShowNotification(Strings["dont_have_clothes"])
                                end
                            end, { item = "clothes", count = Config.TailorJob.clothesRemove })
                        end
                    end
                end
            end
        end
        local dst = #(pCoords - Config.TailorJob.SellingCoords)
        if dst <= 50 then
            sleep = 1
            if dst <= 40 and not inSelling then
                DrawMarker(25, Config.TailorJob.SellingCoords.x, Config.TailorJob.SellingCoords.y, Config.TailorJob.SellingCoords.z - 1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 199, 195, 195, 200, 0, 1, 0, 0)
                if dst <= 2 then
                    ShowHelpNotification(Strings["start_selling_clothes"])
                    if IsControlJustPressed(0,  38) and not progress then
                        TriggerCallback("frp_jobs:server:CheckItem", function(data) 
                            if data.status then
                                local spawnPoint = IsSpawnPointClear(Config.TailorJob.VehicleSpawnCoords)
                                if spawnPoint then
                                    inSelling = true
                                    woolCount = data.count
                                    TriggerServerEvent("frp_jobs:server:RemoveItem", "packaged_clothes", data.count)
                                    TailorStartSelling(playerPed, spawnPoint)
                                else
                                    ShowNotification(Strings["spawn_area_full"])
                                end
                            else
                                ShowNotification(Strings["dont_have_packaged_clothes"])
                            end
                        end, { item = "packaged_clothes", count = 1 })
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)
