-- LAVET I SAMARBEJDE MED MOHR
-- sCallback.lua og cCallback.lua kan bruges som man vil, dog værdsættes en smule credit, men vigtigst af alt, SÅ SKAL MAN IKKE SÆLGE DET
-- Link: https://github.com/OMikkel/omik_callbacks

cCallback = {
    TriggerServerCallback = function(self, name, args, cb)
        TriggerServerEvent("omik_polititablet:TriggerServerCallback", name, args)
        while self.server[name] == nil do
            Wait(1)
        end
        cb(self.server[name])
        self.server[name] = nil
    end,
    RegisterClientCallback = function(self, name, f)
        self.client[name] = f
    end,
    server = {},
    client = {}
}
RegisterNetEvent("omik_polititablet:RecieveServerCallback")
AddEventHandler("omik_polititablet:RecieveServerCallback", function(name, data)
    cCallback.server[name] = data
end)

RegisterNetEvent("omik_polititablet:TriggerClientCallback")
AddEventHandler("omik_polititablet:TriggerClientCallback", function(name, args)
    TriggerServerEvent("omik_polititablet:RecieveClientCallback", name, cCallback.client[name](args))
end)
