RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)

Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.Zones.Pizza.Pos.x, Config.Zones.Pizza.Pos.y, Config.Zones.Pizza.Pos.z)

	SetBlipSprite (blip, Config.Zones.Pizza.Type)
	SetBlipDisplay(blip, 4)
	SetBlipScale  (blip, 0.8)
	SetBlipColour (blip, 1)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName('Pablos Pizza Palace')
	EndTextCommandSetBlipName(blip)
end)


function OpenPPizza()

	local elements = {
		{label = 'Faktura', value = "billing"}
	}

	if ESX.PlayerData.job.grade_name == 'boss' then
		table.insert(elements, { label = 'Ledelse', value = 'boss'})
	end
    ESX.UI.Menu.CloseAll()
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'Pizza_actions', {
          title    = 'Pablos Pizza Palace',
          align    = 'top-left',
          elements = elements
		}, function(data, menu)
          if data.current.value == 'boss' then
            ESX.UI.Menu.CloseAll()
            TriggerEvent('esx_society:openBossMenu', 'ppizza', function(data, menu)
                menu.close()

                --CurrentAction     = 'menu_boss_actions'
                --CurrentActionMsg  = _U('open_bossmenu')
                --CurrentActionData = {}
            end, { wash = false })
		elseif data.current.value == 'billing' then
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
				title = "Faktura Beløb"
			}, function(data, menu)
				local amount = tonumber(data.value)

				if amount == nil or amount < 0 then
					ESX.ShowNotification("Ugyldigt Beløb")
				else
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification("Ingen spillere tæt på.")
					else
						menu.close()
						TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_ppizza', "Pablos Pizza Palace", amount)
					end
				end
			end, function(data, menu)
				menu.close()
			end)
          end
      end, function(data, menu)
          menu.close()
    end)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
        if IsControlJustReleased(0, 167) and not isDead and ESX.PlayerData.job and ESX.PlayerData.job.name == 'ppizza' and not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'Pizza_actions') then
            OpenPPizza()
		end
    end
end)