local progress = false

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    if Config.MinerJob.jobRequired then
        if job.name == Config.MinerJob.jobName then
            for k,v in pairs(Config.Blips["Miner"]) do
                if v.enabled then
                    if not DoesBlipExist(v.blip) then
                        v.blip = CreateBlip(v.coords, v.sprite, v.scale, v.color, v.name)
                    end
                end
            end 
        else
            for k,v in pairs(Config.Blips["Miner"]) do
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
    if Config.MinerJob.jobRequired then
        if job.name == Config.MinerJob.jobName then
            for k,v in pairs(Config.Blips["Miner"]) do
                if v.enabled then
                    if not DoesBlipExist(v.blip) then
                        v.blip = CreateBlip(v.coords, v.sprite, v.scale, v.color, v.name)
                    end
                end
            end 
        else
            for k,v in pairs(Config.Blips["Miner"]) do
                if v.enabled then
                    if DoesBlipExist(v.blip) then
                        RemoveBlip(v.blip)
                    end
                end
            end
        end
    end
end)

MiningAnim = function(playerPed, heading)
    FreezeEntityPosition(playerPed, true)
    local pickAxe = CreateObject(GetHashKey("prop_tool_pickaxe"), 0, 0, 0, true, true, true) 
    AttachEntityToEntity(pickAxe, playerPed, GetPedBoneIndex(playerPed, 57005), 0.09, 0.03, -0.02, -78.0, 13.0, 28.0, false, false, false, false, 1, true)
    SetEntityHeading(playerPed, heading)
    local animDict = "melee@large_wpn@streamed_core"
    for i = 1, Config.MinerJob.hitCount do
        while not HasAnimDictLoaded(animDict) do
            RequestAnimDict(animDict)
            Citizen.Wait(1)
        end
        TaskPlayAnim(playerPed, animDict, "ground_attack_0", 8.0, -8.0, -1, 16, 0, false, false, false)
        Citizen.Wait(GetAnimDuration(animDict, "ground_attack_0")* 1000)
    end
    progress = false
    FreezeEntityPosition(playerPed, false)
    DeleteEntity(pickAxe)
    RemoveAnimDict(animDict)
    TriggerServerEvent("frp_jobs:server:AddItem", "stone", Config.MinerJob.stoneGive)
    ShowNotification(Strings["miner_gave_stone"])
end

MinerWashingAnim = function(playerPed, heading)
    SetEntityHeading(playerPed, heading)
    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_BUM_WASH", 0, true)
    Citizen.Wait(10000)
    ClearPedTasks(playerPed)
    progress = false
    TriggerServerEvent("frp_jobs:server:AddItem", "washed_stone", Config.MinerJob.washedGive)
    ShowNotification(Strings["miner_gave_washed_stone"])
end

MinerSmeltingAnim = function(playerPed, heading)
    SetEntityHeading(playerPed, heading)
    TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
    Citizen.Wait(10000)
    ClearPedTasks(playerPed)
    TriggerServerEvent("frp_jobs:server:AddItem", "processed_ore", Config.MinerJob.smeltingGive)
    ShowNotification(Strings["miner_gave_processed_ore"])
    progress = false
end

MinerSellingAnim = function(playerPed)
    local pCoords = GetEntityCoords(playerPed)
    local animDict = "anim@heists@box_carry@"
    local prop = CreateObject(GetHashKey('prop_security_case_01'), pCoords.x, pCoords.y, pCoords.z + 0.2, true, true, true)
    AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 60309), 0.2, 0.08, 0.255, -145.0, 290.0, 0.0, true, true, false, true, 1, true)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(10)
        RequestAnimDict(animDict)
    end
    TaskPlayAnim(playerPed, animDict, "idle", 8.0, -8.0, -1, 0, 0, 0, 0, 0)
    Citizen.Wait(GetAnimDuration(animDict, "idle")* 1000)
    DeleteEntity(prop)
    TriggerServerEvent("frp_jobs:server:SellItem", "processed_ore", Config.MinerJob.Price)
    progress = false
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    playerData = Framework.Functions.GetPlayerData()
    if Config.MinerJob.jobRequired then
        if playerData and playerData.job and playerData.job.name == Config.MinerJob.jobName then
            for k,v in pairs(Config.Blips["Miner"]) do
                if v.enabled then
                    if not DoesBlipExist(v.blip) then
                        v.blip = CreateBlip(v.coords, v.sprite, v.scale, v.color, v.name)
                    end
                end
            end 
        end
    else
        for k,v in pairs(Config.Blips["Miner"]) do
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
    if Config.MinerJob.jobRequired then
        if playerData and playerData.job and playerData.job.name == Config.MinerJob.jobName then
            for k,v in pairs(Config.Blips["Miner"]) do
                if v.enabled then
                    if not DoesBlipExist(v.blip) then
                        v.blip = CreateBlip(v.coords, v.sprite, v.scale, v.color, v.name)
                    end
                end
            end 
        end
    else
        for k,v in pairs(Config.Blips["Miner"]) do
            if v.enabled then
                if not DoesBlipExist(v.blip) then
                    v.blip = CreateBlip(v.coords, v.sprite, v.scale, v.color, v.name)
                end
            end
        end  
    end
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local pCoords = GetEntityCoords(playerPed)
        -- Mining --
        for k,v in pairs(Config.MinerJob.MiningCoords) do
            local dst = #(pCoords - vector3(v.x, v.y, v.z))
            if dst <= 50 then
                sleep = 1
                if dst <= 40 and not progress then
                    DrawMarker(0, v.x, v.y, v.z + 1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 237, 181, 14, 200, 1, 0, 0, 0)
                    if dst <= 3 then
                        ShowHelpNotification(Strings["start_mining"])
                        if IsControlJustPressed(0,  38) and not progress then
                            progress = true
                            ShowNotification(Strings["miner_mining"])
                            MiningAnim(playerPed, v.w)
                        end
                    end
                end
            end
        end
        -- Washing --
        for k,v in pairs(Config.MinerJob.WashingCoords) do
            local dst = #(pCoords - vector3(v.x, v.y, v.z))
            if dst <= 50 then
                sleep = 1
                if dst <= 40 and not progress then
                    DrawMarker(20, v.x, v.y, v.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 237, 181, 14, 200, 0, 1, 0, 0)
                    if dst <= 3 then
                        ShowHelpNotification(Strings["start_washing"])
                        if IsControlJustPressed(0, 38) and not progress then
                            TriggerCallback("frp_jobs:server:CheckItem", function(data) 
                                if data.status then
                                    progress = true
                                    TriggerServerEvent("frp_jobs:server:RemoveItem", "stone", Config.MinerJob.stoneRemove)
                                    ShowNotification(Strings["miner_washing"])
                                    MinerWashingAnim(playerPed, v.w)
                                else
                                    ShowNotification(Strings["dont_have_stones"])
                                end
                            end, { item = "stone", count = Config.MinerJob.stoneRemove })
                        end
                    end
                end
            end
        end
        -- Smelting --
        for k,v in pairs(Config.MinerJob.SmeltingCoords) do
            local dst = #(pCoords - vector3(v.x, v.y, v.z))
            if dst <= 50 then
                sleep = 1
                if dst <= 40 and not progress then
                    DrawMarker(20, v.x, v.y, v.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 237, 181, 14, 200, 0, 1, 0, 0)
                    if dst <= 3 then
                        ShowHelpNotification(Strings["start_smelting"])
                        if IsControlJustPressed(0,  38) and not progress then
                            TriggerCallback("frp_jobs:server:CheckItem", function(data) 
                                if data.status then
                                    progress = true
                                    TriggerServerEvent("frp_jobs:server:RemoveItem", "washed_stone", Config.MinerJob.washedRemove)
                                    MinerSmeltingAnim(playerPed, v.w)
                                    ShowNotification(Strings["miner_smelting"])
                                else
                                    ShowNotification(Strings["dont_have_washed_stones"])
                                end
                            end, { item = "washed_stone", count = Config.MinerJob.washedRemove })
                        end
                    end
                end
            end
        end
        -- Selling --
        local dst = #(pCoords - Config.MinerJob.SellingCoords)
        if dst <= 50 then
            sleep = 1
            if dst <= 40 and not progress then
                DrawMarker(20, Config.MinerJob.SellingCoords.x, Config.MinerJob.SellingCoords.y, Config.MinerJob.SellingCoords.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 237, 181, 14, 200, 0, 1, 0, 0)
                if dst <= 3 then
                    ShowHelpNotification(Strings["start_selling_ores"])
                    if IsControlJustPressed(0,  38) and not progress then
                        TriggerCallback("frp_jobs:server:CheckItem", function(data) 
                            if data.status then
                                progress = true
                                MinerSellingAnim(playerPed)
                            else
                                ShowNotification(Strings["dont_have_processed_ore"])
                            end
                        end, { item = "processed_ore", count = 1 })
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)
