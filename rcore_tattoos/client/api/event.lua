if Framework == Frameworks.ESX then
    AddEventHandler(Config.Events["esx:playerSpawned"], function()
        resetPedDecorations()
    end)
else
    AddEventHandler('playerSpawned', function()
        resetPedDecorations()
    end)
end
