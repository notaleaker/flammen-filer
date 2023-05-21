fx_version 'cerulean'

game 'gta5'

author 'okok#3488'
description 'okokDelVehicles'

shared_script 'config.lua'

client_scripts {
	'client.lua'
}

server_scripts {
	"@mysql-async/lib/MySQL.lua", -- Remove this if you are using QBCore
	'server.lua'
}

lua54 'yes'

escrow_ignore {
	'config.lua',
	'server.lua',
	'client.lua'
}
dependency '/assetpacks'