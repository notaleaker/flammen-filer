Scully.Radio = {
    serverID = GetPlayerServerId(PlayerId()),
    isOpen = false,
    channel = 0,
    callsign = GetResourceKvpString('scully_radio2_callsign' .. Scully.KVPHandle),
    name = GetResourceKvpString('scully_radio2_name' .. Scully.KVPHandle),
    volume = 50,
    radioProp = nil,
    radioColour = GetResourceKvpString('scully_radio2_colour' .. Scully.KVPHandle) or Scully.RadioColour
}

function Scully.Radio.JoinChannel(newChannel)
    local channel = tonumber(newChannel)
    if Scully.WhitelistedAccess[math.floor(channel)] then
        if Scully.Functions.HasAccess(math.floor(channel)) then
            Scully.Radio.channel = channel
            SendNUIMessage({type = 'playerList', action = 'clear'})
            if Scully.EnableList and Scully.ShowSelf then
                TriggerServerEvent('scully_radio:addPlayerToRadio', Scully.Radio.serverID)
            end
            exports['pma-voice']:setRadioChannel(channel)
            local channelName = Scully.Language.Frequency .. ' ' .. channel
            if Scully.UseCustomChannelNames then
                if Scully.ChannelNames[channel] then
                    if string.len(Scully.ChannelNames[channel]) < 8 then
                        channelName = Scully.Language.Channel .. ' ' .. Scully.ChannelNames[channel]
                    end
                end
            end
            SendNUIMessage({type = 'changedChannel', channel = channelName})
        else
            exports['mythic_notify']:DoHudText('error', 'Du kan ikke joine denne radio frekvens')
        end
    else
        Scully.Radio.channel = channel
        SendNUIMessage({type = 'playerList', action = 'clear'})
        if Scully.EnableList and Scully.ShowSelf then
            TriggerServerEvent('scully_radio:addPlayerToRadio', Scully.Radio.serverID)
        end
        exports['pma-voice']:setRadioChannel(channel)
        local channelName = Scully.Language.Frequency .. ' ' .. channel
        if Scully.UseCustomChannelNames then
            if Scully.ChannelNames[channel] then
                if string.len(Scully.ChannelNames[channel]) < 8 then
                    channelName = Scully.Language.Channel .. ' ' .. Scully.ChannelNames[channel]
                end
            end
        end
        SendNUIMessage({type = 'changedChannel', channel = channelName})
    end
end

function Scully.Radio.LeaveChannel(powerOff)
    if Scully.Radio.channel > 0 then
        Scully.Radio.channel = 0
        exports['pma-voice']:setRadioChannel(0)
        exports['pma-voice']:setVoiceProperty('radioEnabled', false)
        if powerOff then
            SendNUIMessage({type = 'powerOff', channel = Scully.Language.Frequency .. ' ' .. Scully.Language.None})
        else
            SendNUIMessage({type = 'changedChannel', channel = Scully.Language.Frequency .. ' ' .. Scully.Language.None})
        end
    end
end

function Scully.Radio.RadioAnim(enable)
    local playerPed = PlayerPedId()
    if enable then
        RequestAnimDict('cellphone@')
        RequestModel(`prop_cs_hand_radio`)
        while not HasAnimDictLoaded('cellphone@') do
            Wait(0)
        end
        while not HasModelLoaded(`prop_cs_hand_radio`) do
            Wait(10)
        end
        Scully.Radio.radioProp = CreateObject(`prop_cs_hand_radio`, 0, 0, 0, true, true, true)
        AttachEntityToEntity(Scully.Radio.radioProp, playerPed, GetPedBoneIndex(playerPed, 0xdead), 0.13, 0.02, -0.015, 77.0, 0.0, 120.0, true, true, false, true, 1, true)
        TaskPlayAnim(playerPed, 'cellphone@', 'cellphone_call_listen_base', 8.0, 0.0, -1, 49, 0, 0, 0, 0)
    else
        StopAnimTask(playerPed, 'cellphone@', 'cellphone_call_listen_base', -4.0)
        RemoveAnimDict('cellphone@')
        DeleteEntity(Scully.Radio.radioProp)
    end
end

function Scully.Radio.ToggleRadio(enable)
    Scully.Radio.isOpen = enable
    SetNuiFocus(enable, enable)
    if Scully.RadioAnims then
        Scully.Radio.RadioAnim(enable)
    end
    SendNUIMessage({
        type = 'openradio',
        enable = enable,
        colour = Scully.Radio.radioColour,
        edit = Scully.EnableEditing,
        playerId = Scully.Radio.serverID
    })
end

RegisterNetEvent('scully_radio:openRadio', function(colour)
    if colour then
        Scully.Radio.radioColour = colour
    end
	Scully.Radio.ToggleRadio(true)
end)

RegisterNetEvent('scully_radio:joinChannel', function(channel)
    if type(channel) == 'table' then
        channel = channel.channel
    end
    if type(channel) == 'string' then
        channel = tonumber(channel)
    end
    SendNUIMessage({type = 'powerOn'})
	Scully.Radio.JoinChannel(channel)
end)

RegisterNetEvent('scully_radio:leaveChannel', function(powerOff)
	Scully.Radio.LeaveChannel(powerOff)
end)

AddEventHandler('onClientResourceStart', function(resourceName)
	if resourceName == GetCurrentResourceName() then
        while not LocalPlayer.state.isLoggedIn do
            Wait(100)
        end
        if Scully.Radio.callsign then
            TriggerServerEvent('scully_radio:updateRadioInfo', 'callsign', Scully.Radio.callsign)
        end
        if Scully.Radio.name then
            TriggerServerEvent('scully_radio:updateRadioInfo', 'name', Scully.Radio.name)
        end
        if LocalPlayer.state.radioChannel then
            if LocalPlayer.state.radioChannel > 0 then
                exports['pma-voice']:setRadioChannel(0)
                exports['pma-voice']:setVoiceProperty('radioEnabled', false)
            end
        end
	end
end)

if Scully.AllowColours and not Scully.UseItemColours then
    if Scully.ColourCommand ~= '' then
        RegisterCommand(Scully.ColourCommand, function(_, args)
            if args[1] then
                local newColour = tonumber(args[1])
                if newColour then
                    if Scully.RadioColours[newColour] then
                        Scully.Radio.radioColour = Scully.RadioColours[newColour]
                        SetResourceKvp('scully_radio2_colour' .. Scully.KVPHandle, Scully.Radio.radioColour)
                        SendNUIMessage({type = 'changedColour', colour = Scully.Radio.radioColour})
                        exports['mythic_notify']:DoHudText('success', 'Du ændret farven på din radio')
                    end
                end
            end
        end)
    end
end

if Scully.UseKeybind ~= '' then
    RegisterCommand(Scully.Language.Command, function()
        if Scully.UseItem then
            Scully.Functions.HasItem('radio', function(hasItem)
                if hasItem then
                    Scully.Radio.ToggleRadio(true)
                else
                    Scully.Functions.ShowNotification(Scully.Language.NoRadio)
                end
            end)
        else
            Scully.Radio.ToggleRadio(true)
        end
    end)

    RegisterKeyMapping(Scully.Language.Command, Scully.Language.CommandLabel, 'keyboard', Scully.UseKeybind)
end

if Scully.HideListCommand ~= '' then
    RegisterCommand(Scully.HideListCommand, function()
        SendNUIMessage({
            type = 'playerList', 
            action = 'toggle'
        })
    end)
end

RegisterNUICallback('radioOn', function(data, cb)
    exports['pma-voice']:setVoiceProperty('radioEnabled', true)
    exports['pma-voice']:setVoiceProperty('micClicks', Scully.MicClicks)
    --[[if Scully.RadioAnims then
        if not exports['pma-voice']:getRadioAnimState() then
            exports['pma-voice']:setRadioAnim(true) -- Waiting for pma commit to be merged
        end
    end]]--
    PlaySound(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 0, 0, 1)
    SendNUIMessage({
        type = 'playerList', 
        action = 'display',
        show = Scully.EnableList
    })
end)

RegisterNUICallback('changeInfo', function(data, cb)
    if not Scully.EnableEditing then return end
    if data.value then
        if data.value ~= '' then
            Scully.Radio[data.type] = data.value
            SetResourceKvp('scully_radio2_' .. data.type .. Scully.KVPHandle, data.value)
            TriggerServerEvent('scully_radio:updateRadioInfo', data.type, data.value)
            Scully.Functions.ShowNotification(Scully.Language.UpdatedYour .. ' ' .. data.type .. ' ' .. Scully.Language.To .. ' ' .. data.value .. '!')
        end
    end
end)

RegisterNUICallback('joinChannel', function(data, cb)
    Scully.Radio.JoinChannel(data.channel)
end)

RegisterNUICallback('leaveChannel', function(data, cb)
    PlaySound(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 0, 0, 1)
    Scully.Radio.LeaveChannel()
end)

RegisterNUICallback('VolUp', function(data, cb)
    if Scully.Radio.volume < 100 then
        PlaySound(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 0, 0, 1)
        Scully.Radio.volume = Scully.Radio.volume + 10
        exports['pma-voice']:setRadioVolume(Scully.Radio.volume)
    end
end)

RegisterNUICallback('VolDown', function(data, cb)
    if Scully.Radio.volume > 10 then
        PlaySound(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 0, 0, 1)
        Scully.Radio.volume = Scully.Radio.volume - 10
        exports['pma-voice']:setRadioVolume(Scully.Radio.volume)
    end
end)

RegisterNUICallback('close', function(data, cb)
    Scully.Radio.ToggleRadio(false)
end)

-- radio list shit
if Scully.EnableList then
    RegisterNetEvent('pma-voice:addPlayerToRadio', function(player)
        TriggerServerEvent('scully_radio:addPlayerToRadio', player)
    end)
    
    RegisterNetEvent('pma-voice:removePlayerFromRadio', function(player)
        TriggerServerEvent('scully_radio:removePlayerFromRadio', player)
    end)

    if Scully.ShowSelf then
        RegisterNetEvent('pma-voice:radioActive', function(talking)
            SendNUIMessage({
                type = 'playerList', 
                action = 'talking',
                playerId = Scully.Radio.serverID,
                isTalking = talking
            })
        end)
    end
    
    RegisterNetEvent('pma-voice:setTalkingOnRadio', function(player, talking)
        TriggerServerEvent('scully_radio:setTalkingOnRadio', player, talking)
    end)

    RegisterNetEvent('scully_radio:updateRadioInfo', function(player, name)
        if player == Scully.Radio.serverID then
            name = name .. ' ' .. Scully.Language.You
        end
        SendNUIMessage({
            type = 'playerList', 
            action = 'update',
            playerId = player,
            playerName = name
        })
    end)
    
    RegisterNetEvent('scully_radio:addPlayerToRadio', function(player, name)
        if player == Scully.Radio.serverID then
            name = name .. ' ' .. Scully.Language.You
        end
        SendNUIMessage({
            type = 'playerList', 
            action = 'add',
            playerId = player,
            playerName = name
        })
    end)
    
    RegisterNetEvent('scully_radio:removePlayerFromRadio', function(player)
        if player == Scully.Radio.serverID then return end
        SendNUIMessage({
            type = 'playerList', 
            action = 'remove',
            playerId = player
        })
    end)
    
    RegisterNetEvent('scully_radio:setTalkingOnRadio', function(player, talking)
        SendNUIMessage({
            type = 'playerList', 
            action = 'talking',
            playerId = player,
            isTalking = talking
        })
    end)
end

local function stopRadioIf()
    if LocalPlayer.state.radioChannel ~= 0 then
        Scully.Radio.LeaveChannel(true)
    end
end

AddEventHandler('esx:onPlayerDeath', stopRadioIf)

RegisterNetEvent('wg:stopRadioIf', stopRadioIf)

RegisterNetEvent('wg:InventoryCleared', stopRadioIf)