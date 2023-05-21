-- get your current world position offset from the interior spawn position.
-- this is used to get a correct entry offset position for new shells in the config.
RegisterCommand('housing:getIntOffset',function()
  if Housing.InsideInterior then
    SendNUIMessage({
      type = "Copy",
      text = tostring(-(GetEntityCoords(PlayerPedId()) - Housing.InsideInterior.shell.position))
    })

    Utils.ShowNotification("Interior offset copied to clipboard.")
  end
end)

-- create a new house.
RegisterCommand('housing:createHouse',function()
  local plyData = ESX.GetPlayerData()

  if Config.RealtorJobs[plyData.job.name] and Config.RealtorJobs[plyData.job.name].minRank <= plyData.job.grade then
    local pos = GetEntityCoords(PlayerPedId())
    local zone = GetZoneAtCoords(pos.x,pos.y,pos.z)
    local zoneScumminess = GetZoneScumminess(zone)

    Housing.CreatingHouse = {
      commission = 0,
      price = 0,
      modifier = Config.ScumminessPriceModifier[zoneScumminess],
      streetNumber = -1
    }

    Housing.OpenCreationUI(Housing.CreatingHouse)
  end
end)