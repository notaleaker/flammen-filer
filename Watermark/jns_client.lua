local show = true
local SourceID = -1

CreateThread(function()
    SourceID = GetPlayerServerId(PlayerId())
end)

RegisterCommand('watermark', function()
    show = not show
    SendNUIMessage({
        show = show
    })
end, false)

RegisterNetEvent('Watermark:SendData', function(text)
    SendNUIMessage({
        text = text .. SourceID
    })
end)