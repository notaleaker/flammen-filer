--CORE EVIDENCE 0.1

local Keys = {
    ["ESC"] = 322,
    ["F1"] = 288,
    ["F2"] = 289,
    ["F3"] = 170,
    ["F5"] = 166,
    ["F6"] = 167,
    ["F7"] = 168,
    ["F8"] = 169,
    ["F9"] = 56,
    ["F10"] = 57,
    ["~"] = 243,
    ["1"] = 157,
    ["2"] = 158,
    ["3"] = 160,
    ["4"] = 164,
    ["5"] = 165,
    ["6"] = 159,
    ["7"] = 161,
    ["8"] = 162,
    ["9"] = 163,
    ["-"] = 84,
    ["="] = 83,
    ["BACKSPACE"] = 177,
    ["TAB"] = 37,
    ["Q"] = 44,
    ["W"] = 32,
    ["E"] = 38,
    ["R"] = 45,
    ["T"] = 245,
    ["Y"] = 246,
    ["U"] = 303,
    ["P"] = 199,
    ["["] = 39,
    ["]"] = 40,
    ["ENTER"] = 18,
    ["CAPS"] = 137,
    ["A"] = 34,
    ["S"] = 8,
    ["D"] = 9,
    ["F"] = 23,
    ["G"] = 47,
    ["H"] = 74,
    ["K"] = 311,
    ["L"] = 182,
    ["LEFTSHIFT"] = 21,
    ["Z"] = 20,
    ["X"] = 73,
    ["C"] = 26,
    ["V"] = 0,
    ["B"] = 29,
    ["N"] = 249,
    ["M"] = 244,
    [","] = 82,
    ["."] = 81,
    ["LEFTCTRL"] = 36,
    ["LEFTALT"] = 19,
    ["SPACE"] = 22,
    ["RIGHTCTRL"] = 70,
    ["HOME"] = 213,
    ["PAGEUP"] = 10,
    ["PAGEDOWN"] = 11,
    ["DELETE"] = 178,
    ["LEFT"] = 174,
    ["RIGHT"] = 175,
    ["TOP"] = 27,
    ["DOWN"] = 173,
    ["NENTER"] = 201,
    ["N4"] = 108,
    ["N5"] = 60,
    ["N6"] = 107,
    ["N+"] = 96,
    ["N-"] = 97,
    ["N7"] = 117,
    ["N8"] = 61,
    ["N9"] = 118
}

local shots = {}
local blood = {}

local update = true
local last = 0
local time = 0
local open = false
local analyzing = false
local analyzingDone = false
local ignore = false

local job = ""
local grade = 0

local canAccess = false
local evidence = {}

Citizen.CreateThread(
    function()
        while ESX == nil do
            if not Config.NewESX then
                TriggerEvent(
                    "esx:getSharedObject",
                    function(obj)
                        ESX = obj
                    end
                )
            else
                ESX = exports["es_extended"]:getSharedObject()
            end
            Citizen.Wait(0)
        end

        while ESX.GetPlayerData().job == nil do
            Citizen.Wait(10)
        end

        job = ESX.GetPlayerData().job.name
        grade = ESX.GetPlayerData().job.grade

        

        for k, v in pairs(Config.JobRequired) do
            if job == k and grade >= v then
                canAccess = true
            end
        end
    end
)

RegisterNetEvent("esx:setJob")
AddEventHandler(
    "esx:setJob",
    function(j)


        job = j.name
        grade = j.grade



        canAccess = false

        for k, v in pairs(Config.JobRequired) do
            if job == k and grade == v then
                canAccess = true
            end
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1)

            local playerid = PlayerId()

            if not IsPlayerFreeAiming(playerid) then
                update = true
                Citizen.Wait(500)
            else
                local playerPed = GetPlayerPed(-1)

                if IsPlayerFreeAiming(playerid) and GetSelectedPedWeapon(playerPed) == GetHashKey("WEAPON_FLASHLIGHT") then
                    if update then
                        ESX.TriggerServerCallback(
                            "core_evidence:getData",
                            function(ans)
                                shots = ans.shots
                                blood = ans.blood
                                time = ans.time
                            end
                        )
                        update = false
                    end

                    for t, s in pairs(blood) do
                        if GetDistanceBetweenCoords(s.coords, GetEntityCoords(playerPed)) < 30 then
                            DrawMarker(
                                1,
                                s.coords[1],
                                s.coords[2],
                                s.coords[3] - 0.9,
                                0.0,
                                0.0,
                                0.0,
                                0,
                                0.0,
                                0.0,
                                0.2,
                                0.2,
                                0.2,
                                255,
                                41,
                                41,
                                100,
                                false,
                                true,
                                2,
                                false,
                                false,
                                false,
                                false
                            )
                        end

                        if GetDistanceBetweenCoords(s.coords, GetEntityCoords(playerPed)) < 5 then
                            DrawText3D(s.coords[1], s.coords[2], s.coords[3] - 0.5, Config.Text["blood_hologram"])

                            local passed = time - t

                            if passed > 300 and passed < 600 then
                                DrawText3D(
                                    s.coords[1],
                                    s.coords[2],
                                    s.coords[3] - 0.57,
                                    Config.Text["blood_after_5_minutes"]
                                )
                            elseif passed > 600 then
                                DrawText3D(
                                    s.coords[1],
                                    s.coords[2],
                                    s.coords[3] - 0.57,
                                    Config.Text["blood_after_10_minutes"]
                                )
                            else
                                DrawText3D(
                                    s.coords[1],
                                    s.coords[2],
                                    s.coords[3] - 0.57,
                                    Config.Text["blood_after_0_minutes"]
                                )
                            end
                        end

                        if GetDistanceBetweenCoords(s.coords, GetEntityCoords(playerPed)) < 1 then
                            if canAccess then
                                DrawText3D(
                                    s.coords[1],
                                    s.coords[2],
                                    s.coords[3] - 0.65,
                                    Config.Text["pick_up_evidence_text"]
                                )
                                if IsControlJustReleased(0, Keys[Config.PickupEvidenceKey]) then
                                    if #evidence < 3 then
                                        local dict, anim =
                                            "weapons@first_person@aim_rng@generic@projectile@sticky_bomb@",
                                            "plant_floor"
                                        ESX.Streaming.RequestAnimDict(dict)
                                        TaskPlayAnim(
                                            playerPed,
                                            dict,
                                            anim,
                                            8.0,
                                            1.0,
                                            1000,
                                            16,
                                            0.0,
                                            false,
                                            false,
                                            false
                                        )
                                        Citizen.Wait(1000)
                                        blood[t] = nil
                                        evidence[#evidence + 1] = {type = "blood", evidence = s.reportInfo}
                                        TriggerServerEvent("core_evidence:removeBlood", t)
                                        SendTextMessage(
                                            string.gsub(Config.Text["evidence_colleted"], "{number}", #evidence)
                                        )
                                        PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                                    else
                                        SendTextMessage(Config.Text["no_more_space"])
                                    end
                                end
                            else
                                DrawText3D(s.coords[1], s.coords[2], s.coords[3] - 0.65, Config.Text["remove_evidence"])
                                if IsControlJustReleased(0, Keys[Config.PickupEvidenceKey]) then
                                    if (time - t) > Config.TimeBeforeCrimsCanDestory then
                                        local dict, anim =
                                            "weapons@first_person@aim_rng@generic@projectile@sticky_bomb@",
                                            "plant_floor"
                                        ESX.Streaming.RequestAnimDict(dict)
                                        TaskPlayAnim(
                                            playerPed,
                                            dict,
                                            anim,
                                            8.0,
                                            1.0,
                                            1000,
                                            16,
                                            0.0,
                                            false,
                                            false,
                                            false
                                        )
                                        Citizen.Wait(1000)
                                        blood[t] = nil

                                        TriggerServerEvent("core_evidence:removeBlood", t)
                                        SendTextMessage(Config.Text["evidence_removed"])
                                        PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                                    else
                                        SendTextMessage(Config.Text["cooldown_before_pickup"])
                                    end
                                end
                            end
                        end
                    end

                    for t, s in pairs(shots) do
                        if GetDistanceBetweenCoords(s.coords, GetEntityCoords(playerPed)) < 30 then
                            DrawMarker(
                                3,
                                s.coords[1],
                                s.coords[2],
                                s.coords[3] - 0.9,
                                0.0,
                                0.0,
                                0.0,
                                0,
                                0.0,
                                0.0,
                                0.15,
                                0.15,
                                0.2,
                                66,
                                135,
                                245,
                                100,
                                false,
                                true,
                                2,
                                false,
                                false,
                                false,
                                false
                            )
                        end

                        if GetDistanceBetweenCoords(s.coords, GetEntityCoords(playerPed)) < 5 then
                            DrawText3D(
                                s.coords[1],
                                s.coords[2],
                                s.coords[3] - 0.5,
                                string.gsub(Config.Text["shell_hologram"], "{guncategory}", s.bullet)
                            )

                            local passed = time - t

                            if passed > 300 and passed < 600 then
                                DrawText3D(
                                    s.coords[1],
                                    s.coords[2],
                                    s.coords[3] - 0.57,
                                    Config.Text["shell_after_5_minutes"]
                                )
                            elseif passed > 600 then
                                DrawText3D(
                                    s.coords[1],
                                    s.coords[2],
                                    s.coords[3] - 0.57,
                                    Config.Text["shell_after_10_minutes"]
                                )
                            else
                                DrawText3D(
                                    s.coords[1],
                                    s.coords[2],
                                    s.coords[3] - 0.57,
                                    Config.Text["shell_after_0_minutes"]
                                )
                            end
                        end

                        if GetDistanceBetweenCoords(s.coords, GetEntityCoords(playerPed)) < 1 then
                            if canAccess then
                                DrawText3D(
                                    s.coords[1],
                                    s.coords[2],
                                    s.coords[3] - 0.65,
                                    Config.Text["pick_up_evidence_text"]
                                )
                                if IsControlJustReleased(0, Keys[Config.PickupEvidenceKey]) then
                                    if #evidence < 3 then
                                        local dict, anim =
                                            "weapons@first_person@aim_rng@generic@projectile@sticky_bomb@",
                                            "plant_floor"
                                        ESX.Streaming.RequestAnimDict(dict)
                                        TaskPlayAnim(
                                            playerPed,
                                            dict,
                                            anim,
                                            8.0,
                                            1.0,
                                            1000,
                                            16,
                                            0.0,
                                            false,
                                            false,
                                            false
                                        )
                                        Citizen.Wait(1000)
                                        shots[t] = nil
                                        evidence[#evidence + 1] = {type = "bullet", evidence = s.reportInfo}
                                        TriggerServerEvent("core_evidence:removeShot", t)
                                        SendTextMessage(
                                            string.gsub(Config.Text["evidence_colleted"], "{number}", #evidence)
                                        )
                                        PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                                    else
                                        SendTextMessage(Config.Text["no_more_space"])
                                    end
                                end
                            else
                                DrawText3D(s.coords[1], s.coords[2], s.coords[3] - 0.65, Config.Text["remove_evidence"])
                                if IsControlJustReleased(0, Keys[Config.PickupEvidenceKey]) then
                                    if (time - t) > Config.TimeBeforeCrimsCanDestory then
                                        local dict, anim =
                                            "weapons@first_person@aim_rng@generic@projectile@sticky_bomb@",
                                            "plant_floor"
                                        ESX.Streaming.RequestAnimDict(dict)
                                        TaskPlayAnim(
                                            playerPed,
                                            dict,
                                            anim,
                                            8.0,
                                            1.0,
                                            1000,
                                            16,
                                            0.0,
                                            false,
                                            false,
                                            false
                                        )
                                        Citizen.Wait(1000)
                                        shots[t] = nil

                                        TriggerServerEvent("core_evidence:removeShot", t)
                                        SendTextMessage(Config.Text["evidence_removed"])
                                        PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                                    else
                                        SendTextMessage(Config.Text["cooldown_before_pickup"])
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
)

RegisterNUICallback(
    "close",
    function(data)
        SetNuiFocus(false, false)
    end
)

RegisterNUICallback(
    "remove",
    function(data)
        local evidence = data["evidence"]

        TriggerServerEvent("core_evidence:deleteEvidenceFromStorage", evidence)
        SendTextMessage(Config.Text["evidence_deleted_from_archive"])
    end
)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1)

            if canAccess then
                local ped = GetPlayerPed(-1)
                local veh = GetVehiclePedIsTryingToEnter(ped)
                local seat = GetSeatPedIsTryingToEnter(ped)
                local coords = GetEntityCoords(ped)

                if GetDistanceBetweenCoords(coords, Config.EvidenceStorageLocation) < 1.5 then
                    DrawText3D(
                        Config.EvidenceStorageLocation[1],
                        Config.EvidenceStorageLocation[2],
                        Config.EvidenceStorageLocation[3],
                        Config.Text["open_evidence_archive"]
                    )

                    if IsControlJustReleased(0, 38) then
                        ESX.TriggerServerCallback(
                            "core_evidence:getStorageData",
                            function(data)
                                ESX.UI.Menu.CloseAll()

                                local elements = {}

                                for _, v in ipairs(data) do
                                    table.insert(
                                        elements,
                                        {label = Config.Text["report_list"] .. v.id, value = v.data, id = v.id}
                                    )
                                end

                                SetNuiFocus(true, true)

                                SendNUIMessage(
                                    {
                                        type = "openLocker",
                                        evidences = data
                                    }
                                )
                            end
                        )
                    end
                elseif GetDistanceBetweenCoords(coords, Config.EvidenceAnalysisLocation) < 1 then
                    if not analyzing and not analyzingDone then
                        DrawText3D(
                            Config.EvidenceAnalysisLocation[1],
                            Config.EvidenceAnalysisLocation[2],
                            Config.EvidenceAnalysisLocation[3],
                            Config.Text["analyze_evidence"]
                        )
                    elseif analyzingDone then
                        DrawText3D(
                            Config.EvidenceAnalysisLocation[1],
                            Config.EvidenceAnalysisLocation[2],
                            Config.EvidenceAnalysisLocation[3],
                            Config.Text["read_evidence_report"]
                        )
                    else
                        DrawText3D(
                            Config.EvidenceAnalysisLocation[1],
                            Config.EvidenceAnalysisLocation[2],
                            Config.EvidenceAnalysisLocation[3],
                            Config.Text["evidence_being_analyzed_hologram"]
                        )
                    end
                    if IsControlJustReleased(0, 38) and not analyzing and not analyzingDone then
                        if #evidence > 0 then
                            Citizen.CreateThread(
                                function()
                                    SendTextMessage(Config.Text["evidence_being_analyzed"])

                                    analyzing = true
                                    Citizen.Wait(Config.TimeToAnalyze)

                                    analyzingDone = true
                                    analyzing = false
                                end
                            )
                        else
                            SendTextMessage(Config.Text["no_evidence_to_analyze"])
                        end
                    elseif IsControlJustReleased(0, 38) and not analyzing and analyzingDone then
                        SendNUIMessage(
                            {
                                type = "showReport",
                                evidence = evidence
                            }
                        )
                        TriggerServerEvent("core_evidence:addEvidenceToStorage", json.encode(evidence))
                        if Config.PlayClipboardAnimation then
                            TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, true)
                        end
                        open = true
                        analyzingDone = false
                        evidence = {}
                    end
                end

                if IsControlJustReleased(0, Keys[Config.CloseReportKey]) and open then
                    SendNUIMessage(
                        {
                            type = "close"
                        }
                    )
                    ClearPedTasks(ped)
                    open = false
                end

                if veh ~= 0 then
                    local lastped = GetLastPedInVehicleSeat(veh, seat)
                    local gloves = GetPedDrawableVariation(lastped, 3)

                    if lastped ~= ped then
                        if gloves > 15 and gloves ~= 112 and gloves ~= 113 and gloves ~= 114 then
                            last = 0
                        else
                            last = lastped
                        end
                    end
                end
            end
        end
    end
)

RegisterNetEvent("core_evidence:addFingerPrint")
AddEventHandler(
    "core_evidence:addFingerPrint",
    function(report)
        Citizen.CreateThread(
            function()
                SendTextMessage(Config.Text["analyzing_car"])

                local dict, anim = "anim@heists@prison_heiststation@cop_reactions", "cop_b_idle"
                ESX.Streaming.RequestAnimDict(dict)
                TaskPlayAnim(GetPlayerPed(-1), dict, anim, 8.0, 1.0, 1000, 16, 0.0, false, false, false)

                Citizen.Wait(Config.TimeToFindFingerprints)

                if #evidence < 3 then
                    evidence[#evidence + 1] = {type = "fingerprint", evidence = report}

                    SendTextMessage(string.gsub(Config.Text["evidence_colleted"], "{number}", #evidence))
                    PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                else
                    SendTextMessage(Config.Text["no_more_space"])
                end
            end
        )
    end
)

RegisterNetEvent("core_evidence:unmarkedBullets")
AddEventHandler(
    "core_evidence:unmarkedBullets",
    function(value)
        ignore = value
    end
)

RegisterNetEvent("core_evidence:SendTextMessage")
AddEventHandler(
    "core_evidence:SendTextMessage",
    function(msg)
        SendTextMessage(msg)
    end
)

RegisterNetEvent("core_evidence:checkForFingerprints")
AddEventHandler(
    "core_evidence:checkForFingerprints",
    function()
        if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
            TriggerServerEvent("core_evidence:LastInCar", NetworkGetNetworkIdFromEntity(last))
        else
            SendTextMessage(Config.Text["not_in_vehicle"])
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(5000)
            if Config.RainRemovesEvidence then
                if GetRainLevel() > 0.3 then
                    TriggerServerEvent("core_evidence:removeEverything")
                    Citizen.Wait(10000)
                end
            end
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(10)

            local ped = GetPlayerPed(-1)
            local coords = GetEntityCoords(ped)

            if HasPedBeenDamagedByWeapon(ped, 0 , 2) then
                 ClearEntityLastDamageEntity(ped)
                if Config.ShowBloodSplatsOnGround then
                    local stain =
                        CreateObject(
                        GetHashKey("p_bloodsplat_s"),
                        coords[1],
                        coords[2],
                        coords[3] - 2.0,
                        true,
                        true,
                        false
                    )

                    PlaceObjectOnGroundProperly(stain)
                    local stainCoords = GetEntityCoords(stain)
                    SetEntityCoords(stain, stainCoords[1], stainCoords[2], stainCoords[3] - 0.25)
                    SetEntityAsMissionEntity(stain, true, true)
                    SetEntityRotation(stain, -90.0, 0.0, 0.0, 2, false)
                    FreezeEntityPosition(stain, true)
                end

                      local var1, var2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
                hash1 = GetStreetNameFromHashKey(var1);
                hash2 = GetStreetNameFromHashKey(var2);


                TriggerServerEvent("core_evidence:saveBlood",  hash1 .. ' ' .. hash2, coords, GetInteriorFromEntity(ped))
                Citizen.Wait(2000)
            end

            if IsPedShooting(ped) and not ignore then

                  local var1, var2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
                hash1 = GetStreetNameFromHashKey(var1);
                hash2 = GetStreetNameFromHashKey(var2);

                -- TriggerServerEvent(
                --     "core_evidence:saveShot",
                --      hash1 .. ' ' .. hash2,
                --     coords,
                --     getWeaponName(GetSelectedPedWeapon(ped)),
                --     GetInteriorFromEntity(ped)
                -- )
            end
        end
    end
)

function getWeaponName(hash)
    local ped = GetPlayerPed(-1)

    if GetWeapontypeGroup(hash) == -957766203 then
        return Config.Text["submachine_category"]
    end
    if GetWeapontypeGroup(hash) == 416676503 then
        return Config.Text["pistol_category"]
    end
    if GetWeapontypeGroup(hash) == 860033945 then
        return Config.Text["shotgun_category"]
    end
    if GetWeapontypeGroup(hash) == 970310034 then
        return Config.Text["assault_category"]
    end
    if GetWeapontypeGroup(hash) == 1159398588 then
        return Config.Text["lightmachine_category"]
    end
    if GetWeapontypeGroup(hash) == -1212426201 then
        return Config.Text["sniper_category"]
    end
    if GetWeapontypeGroup(hash) == -1569042529 then
        return Config.Text["heavy_category"]
    end

    return GetWeapontypeGroup(hash)
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)

    local scale = ((1 / dist) * 2) * (1 / GetGameplayCamFov()) * 100

    if onScreen then
        SetTextColour(255, 255, 255, 255)
        SetTextScale(0.0 * scale, 0.35 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextCentre(true)

        SetTextDropshadow(1, 1, 1, 1, 255)

        BeginTextCommandWidth("STRING")
        AddTextComponentString(text)
        local height = GetTextScaleHeight(0.55 * scale, 4)
        local width = EndTextCommandGetWidth(4)

        SetTextEntry("STRING")
        AddTextComponentString(text)
        EndTextCommandDisplayText(_x, _y)
    end
end
