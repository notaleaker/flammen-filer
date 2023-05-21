CreateThread(function()
    local sleep = 100
	while true do
        Wait(sleep)
        local playerPed = PlayerPedId()
        local nothing, weapon = GetCurrentPedWeapon(playerPed, true)
        local blacklisted, name = isWeaponBlacklisted(weapon)
		if blacklisted then
			RemoveWeaponFromPed(playerPed, weapon)
            if Config.BlacklistWeaponLog then
                TriggerServerEvent('gvz-blacklistweaepon:dclog', 'Personen har et blacklisted våben på sig, vær opmærksom! : '..name)
            end
            if Config.KickPlayer then
                TriggerServerEvent('gvz-blacklistweaepon:drop')
            end
		end
	end
end)

function isWeaponBlacklisted(model)
	for _, blacklistedWeapon in pairs(Config.BlacklistedWeapons) do
		if model == GetHashKey(blacklistedWeapon) then
			return true, blacklistedWeapon
		end
	end
	return false, nil
end

