--[[
#########################################################
# ██████╗ ███╗   ███╗██╗██╗  ██╗██╗  ██╗███████╗██╗     #
#██╔═══██╗████╗ ████║██║██║ ██╔╝██║ ██╔╝██╔════╝██║     #
#██║   ██║██╔████╔██║██║█████╔╝ █████╔╝ █████╗  ██║     #
#██║   ██║██║╚██╔╝██║██║██╔═██╗ ██╔═██╗ ██╔══╝  ██║     #
#╚██████╔╝██║ ╚═╝ ██║██║██║  ██╗██║  ██╗███████╗███████╗#
# ╚═════╝ ╚═╝     ╚═╝╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝#
#########################################################
--]]
-- Script: omik_polititablet V2
-- Author: OMikkel#3217

cfg = {}

cfg.framework = "esx" -- vrp // esx // qbcore

cfg.esx_event = "esx:getSharedObject" -- KUN HVIS FRAMEWORK ER ESX - esx:getSharedObject // esx:SharedObject1212 // noget helt tredje

cfg.hotkey = "f11" -- Hotkey til at åbne menuen

cfg.jobs = { -- Jobs der kan åbne tabletten
    "police"
} 

cfg.openCMD = "tablet" -- Den command man skriver i chatten for at åbne tabletten. Du kan altid skrive _close efter din command, så fx /tablet_close så vil tabletten lukke, dette er brugbart hvis den bugger.

cfg.notify = "Du har ikke adgang til denne funktion 👮"

cfg.payTicket = function(source, amount)
    if (cfg.framework == "vrp") then
        local user_id = vRP.getUserId({source})
        if vRP.tryFullPayment({user_id, amount}) then
            TriggerClientEvent("pNotify:SendNotification", source, {text = "Du betalte din bøde på "..amount.." DKK", type = "info",timeout = (4000),layout = "centerRight",queue = "global",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
        else
            TriggerClientEvent("pNotify:SendNotification", source, {text = "Du har ikke nok penge til at betale din bøde", type = "info",timeout = (4000),layout = "centerRight",queue = "global",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
        end
    elseif (cfg.framework == "esx") then
        local xPlayer = ESX.GetPlayerFromId(source)
        local accountMoney = xPlayer.getAccount("bank").money
        if accountMoney >= amount then
            xPlayer.removeAccountMoney("bank", amount)
            TriggerClientEvent("pNotify:SendNotification", source, {text = "Du betalte din bøde på "..amount.." DKK", type = "info",timeout = (4000),layout = "centerRight",queue = "global",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
        else
            TriggerClientEvent("pNotify:SendNotification", source, {text = "Du har ikke nok penge til at betale din bøde", type = "info",timeout = (4000),layout = "centerRight",queue = "global",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
        end
    elseif (cfg.framework == "qbcore") then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player.PlayerData.accounts.bank.money >= amount then
            Player.PlayerData.accounts.bank.money = Player.PlayerData.accounts.bank.money - amount
            TriggerClientEvent("pNotify:SendNotification", source, {text = "Du betalte din bøde på "..amount.." DKK", type = "info",timeout = (4000),layout = "centerRight",queue = "global",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
        else
            TriggerClientEvent("pNotify:SendNotification", source, {text = "Du har ikke nok penge til at betale din bøde", type = "info",timeout = (4000),layout = "centerRight",queue = "global",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
        end
    end
end

return cfg