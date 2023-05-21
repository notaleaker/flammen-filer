fx_version 'cerulean'

game 'gta5'

author 'okok#3488'
description 'okokVehicleShop'

ui_page 'web/ui.html'

files {
	'web/*.*',
	'web/img/*.png'
}

shared_script 'config.lua'

client_scripts {
	'cl_utils.lua',
	'client.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'sv_utils.lua',
	'server.lua'
}

lua54 'yes'

escrow_ignore {
	'config.lua',
	'sv_utils.lua',
	'cl_utils.lua'
}
dependency '/assetpacks'