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

-- Citizen.CreateThread(function()
-- 	local blip = AddBlipForCoord(Config.Zones.Mirror.Pos.x, Config.Zones.Mirror.Pos.y, Config.Zones.Mirror.Pos.z)

-- 	SetBlipSprite (blip, 78)
-- 	SetBlipDisplay(blip, 4)
-- 	SetBlipScale  (blip, 0.8)
-- 	SetBlipColour (blip, 27)
-- 	SetBlipAsShortRange(blip, true)

-- 	BeginTextCommandSetBlipName('STRING')
-- 	AddTextComponentSubstringPlayerName('Mirror Resort')
-- 	EndTextCommandSetBlipName(blip)
-- end)


function OpenDLA()

	local elements = {
		{label = 'Faktura', value = "billing"}
	}

	if ESX.PlayerData.job.grade_name == 'boss' then
		table.insert(elements, { label = 'Ledelse', value = 'boss'})
	end
    ESX.UI.Menu.CloseAll()
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'DLA_actions', {
          title    = 'DLA Piper',
          align    = 'top-left',
          elements = elements
		}, function(data, menu)
          if data.current.value == 'boss' then
            ESX.UI.Menu.CloseAll()
            TriggerEvent('esx_society:openBossMenu', 'dla', function(data, menu)
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
						TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_dla', "DLA Piper", amount)
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
        if IsControlJustReleased(0, 167) and not isDead and ESX.PlayerData.job and ESX.PlayerData.job.name == 'dla' and not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'DLA_actions') then
            OpenDLA()
		end
    end
end)