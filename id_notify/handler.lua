function notify(DATA)
    if DATA.title == nil then DATA.title = "" end
    SendNUIMessage({
        createNew = true,
        data = DATA
    })
end

RegisterNetEvent('id_notify:notify', notify)