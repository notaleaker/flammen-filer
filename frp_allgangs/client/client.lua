local ESX, ResourceName, ShouldCheck, CurrentJob, CurrentGang = exports['es_extended']:getSharedObject(), GetCurrentResourceName(), false, nil, nil

local function CheckJob()
	CurrentJob = ESX.PlayerData.job.name
	CurrentGang = ConfigGangs[CurrentJob]
	ShouldCheck = CurrentGang ~= nil and ESX.PlayerData.job.grade_name == 'boss'
end

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	CheckJob()
end)

RegisterNetEvent('esx:onPlayerLogout', function()
	ShouldCheck = false
	ESX.PlayerData = {}
end)

RegisterNetEvent('esx:setJob', function(NewJob)
	ESX.PlayerData.job = NewJob
	CheckJob()
end)

function OpenGangMenu()
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', ResourceName, 'gangmenu_actions', {
		title = CurrentGang.menu_title,
		align = 'top-left',
		elements = {
			{ label = 'Ledelse', value = 'boss' }
		}
	}, function(Data, Menu)
		if Data.current.value == 'boss' then
			ESX.UI.Menu.CloseAll()
			TriggerEvent('esx_society:openBossMenu', CurrentJob, function(Data2, Menu2)
				Menu2.close()
			end, { wash = false })
		end
	end, function(Data, Menu)
		Menu.close()
	end)
end

CreateThread(function()
	while true do
		if ShouldCheck then
			if IsControlJustReleased(0, 167) and not ESX.UI.Menu.IsOpen('default', ResourceName, 'gangmenu_actions') then
				OpenGangMenu()
			end

			Wait(0)
		else
			Wait(200)
		end
	end
end)