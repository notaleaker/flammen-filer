

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


Citizen.CreateThread(
    function()
        while ESX == nil do
            TriggerEvent(
                "esx:getSharedObject",
                function(obj)
                    ESX = obj
                end
            )
            Citizen.Wait(0)
        end

        while ESX.GetPlayerData().job == nil do
            Citizen.Wait(10)
        end

        job = ESX.GetPlayerData().job.name
        grade = ESX.GetPlayerData().job.grade
    end
)


RegisterNetEvent("esx:setJob")
AddEventHandler(
    "esx:setJob",
    function(j)
        job = j.name
        grade = j.grade
        
    end
)

function openBossMenu(j, l)
    ESX.TriggerServerCallback(
        "lund_jobmenus:getBossMenuData",
        function(grades, employees, fund, gradename)
            if Config.BossMenuU[gradename] ~= nil and job == j then
                SetNuiFocus(true, true)
                SendNUIMessage(
                    {
                        type = "openBoss",
                        job = {job = job, grade = grade},
                        employees = employees,
                        grades = grades,
                        fund = fund,
                        bossJob = j,
                        bossLabel = l,
                        perms = Config.BossMenuU[gradename]
                    }
                )
            else
                SendTextMessage(Config.Text["cant_access_bossmenu"])
            end
        end,
        j
    )
end


RegisterCommand("", function()
    openBossMenu(v.job)
end)


Citizen.CreateThread(
    function()
        while #Config.BossMenuL > 0 do
            Citizen.Wait(0)
            local coords = GetEntityCoords(PlayerPedId())
            for _, v in ipairs(Config.BossMenuL) do
                local dist = #(coords - v.coords)

                if dist < 20 then
                    DrawMarker(
                        Config.MarkerSprite,
                        v.coords[1],
                        v.coords[2],
                        v.coords[3] - 0.95,
                        0.0,
                        0.0,
                        0.0,
                        0.0,
                        0.0,
                        0.0,
                        Config.MarkerSize,
                        Config.MarkerSize,
                        1.0,
                        Config.MarkerColor[1],
                        Config.MarkerColor[2],
                        Config.MarkerColor[3],
                        100,
                        false,
                        true,
                        2,
                        true,
                        false,
                        false,
                        false
                    )
                end
                if dist < Config.MarkerSize then
                    DrawText3D(v.coords[1], v.coords[2], v.coords[3], Config.Text["bossmenu_hologram"])

                    if IsControlJustReleased(0, Keys["E"]) then
                        openMenu(v.job, v.label)
                    end
                end
            end
        end
    end
)


function openMenu(j, l)
    local elements = {
        {label = 'Administration', type = 'open'},
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'open', {
        title    = 'Virksomheds Menu',
        align    = 'left',
        elements = elements
    }, function(data, menu)
        if data.current.type == 'open' then
            openBossMenu(j, l)
            menu.close()
        end

    end, function(data, menu)
        menu.close()
    end)
end




RegisterNUICallback(
    "close",
    function(data)
        TriggerScreenblurFadeOut(1000)
        SetNuiFocus(false, false)
    end
)

RegisterNUICallback(
    "deposit",
    function(data)
        local job = data["job"]
        local amount = data["amount"]

        TriggerServerEvent("lund_jobmenus:deposit", job, amount)
    end
)

RegisterNUICallback(
    "withdraw",
    function(data)
        local job = data["job"]
        local amount = data["amount"]

        TriggerServerEvent("lund_jobmenus:withdraw", job, amount)
    end
)

RegisterNUICallback(
    "hire",
    function(data)
        local id = data["id"]
        local job = data["job"]

        TriggerServerEvent("lund_jobmenus:hire", id, job)
    end
)

RegisterNUICallback(
    "fire",
    function(data)
        local identifier = data["identifier"]
        local job = data["job"]

        TriggerServerEvent("lund_jobmenus:fire", identifier, job)
    end
)



RegisterNUICallback(
    "setrank",
    function(data)
        local identifier = data["identifier"]
        local job = data["job"]
        local rank = data["rank"]

        TriggerServerEvent("lund_jobmenus:setRank", identifier, job, rank)
    end
)

RegisterNUICallback(
    "removejob",
    function(data)
        TriggerServerEvent("lund_jobmenus:removeJob", data["job"], data["grade"])
    end
)

RegisterNUICallback(
    "addjob",
    function(data)
        TriggerServerEvent("lund_jobmenus:addJob", data["job"])
    end
)

RegisterNetEvent("lund_jobmenus:sendMessage")
AddEventHandler(
    "lund_jobmenus:sendMessage",
    function(msg)
        SendTextMessage(msg)
    end
)



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
