Citizen.CreateThread(function()
  while true do
      
      Citizen.Wait(5*1000) -- Checkea cada 5 segundos
      
      SetDiscordAppId(829658246091767818) -- ID Del BOT

      local player = PlayerId()
        local name = GetPlayerName(player)
		local id = GetPlayerServerId(player)
		SetRichPresence(name ..  " - " .. GlobalState.ServerPlayerCount .. "/150 - ID: " .. id)
     

      SetDiscordRichPresenceAsset("big") -- nombre logo grande
      SetDiscordRichPresenceAssetText(name) -- Nombre en el logo grande

      SetDiscordRichPresenceAssetSmall("small") -- nombre logo pequeño
      SetDiscordRichPresenceAssetSmallText("ID: ".. id) -- logo pequeño

  end
end)