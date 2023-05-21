RegisterCommand("flip", function()
    FlipHelmet()
end)

function FlipHelmet()
    -- if not hasPoliceJob then
    --     return
    -- end

    local dict = "anim@mp_helmets@on_foot"
    local upAnim = "goggles_up"
    local downAnim = "goggles_down"

    LoadAnim(dict)

    local playerPed = PlayerPedId()
    local texture = GetPedPropTextureIndex(playerPed, 0)

    if GetPedPropIndex(playerPed, 0) == 114 then
        TaskPlayAnim(playerPed, dict, upAnim, 8.0, 8.0, 800, 1, 1, 0, 0, 0)

        Citizen.Wait(600)
        SetPedPropIndex(playerPed, 0, 115, texture, true)
        return
    end

    if GetPedPropIndex(playerPed, 0) == 115 then
        TaskPlayAnim(playerPed, dict, downAnim, 8.0, 8.0, 800, 1, 1, 0, 0, 0)

        Citizen.Wait(600)
        SetPedPropIndex(playerPed, 0, 114, texture, true)
        return
    end

    if GetPedPropIndex(playerPed, 0) == 116 then
        TaskPlayAnim(playerPed, dict, downAnim, 8.0, 8.0, 800, 1, 1, 0, 0, 0)

        Citizen.Wait(600)
        SetPedPropIndex(playerPed, 0, 117, texture, true)
        return
    end

    if GetPedPropIndex(playerPed, 0) == 117 then
        TaskPlayAnim(playerPed, dict, upAnim, 8.0, 8.0, 800, 1, 1, 0, 0, 0)

        Citizen.Wait(600)
        SetPedPropIndex(playerPed, 0, 116, texture, true)
        return
    end

    if GetPedPropIndex(playerPed, 0) == 125 then
        TaskPlayAnim(playerPed, dict, upAnim, 8.0, 8.0, 800, 1, 1, 0, 0, 0)

        Citizen.Wait(600)
        SetPedPropIndex(playerPed, 0, 126, texture, true)
        return
    end

    if GetPedPropIndex(playerPed, 0) == 126 then
        TaskPlayAnim(playerPed, dict, downAnim, 8.0, 8.0, 800, 1, 1, 0, 0, 0)

        Citizen.Wait(600)
        SetPedPropIndex(playerPed, 0, 125, texture, true)
        return
    end
end

--LoadAnim = function(dict)
function LoadAnim(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Citizen.Wait(1)
	end
end

--LoadModel = function(model)
function LoadModel(model)
	while not HasModelLoaded(model) do
		RequestModel(model)
		Citizen.Wait(1)
	end
end
