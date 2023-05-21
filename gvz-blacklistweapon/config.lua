Config = {
    
    BlacklistWeaponLog = true, -- Discorda Log Atar 
    KickPlayer = false,  -- Oyuncuyu Oyundan Kickler

    KickMessage = 'Du har et blacklisted våben på dig https://discord.gg/8Xpph4r5GX',

    DiscordWebhook = 'https://discordapp.com/api/webhooks/1009175712839770112/ASuR1uJsvX5Z4ySWILUtezpQUekviiz1W6LD5eV9neWTQ3JnwbPsru_tcQ1C4TCUgcbn',
    WebhookName = 'blacklistweapon',
    WebhookAvatarUrl = '', 

    BlacklistedWeapons = {
        "WEAPON_BULLPUPSHOTGUN",
        "WEAPON_GRENADELAUNCHER",
        "WEAPON_GRENADELAUNCHER_SMOKE",
        "WEAPON_RPG",
        "WEAPON_STINGER",
        "WEAPON_MINIGUN",
        "WEAPON_STUNGUN",
    },
}

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)