lua54 'yes'
fx_version 'adamant'
game 'gta5'

ui_page 'client/html/index.html'

shared_scripts {
	'@es_extended/imports.lua',
	'Config.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/server.lua',
	'server/extra.lua'
}

client_scripts {
	'client/functions.lua',
	'client/client.lua',
	'client/extra.lua'
}

files {
	'client/html/images/*',
	'client/html/index.html',
	'client/html/style.css',
	'client/html/javascript.js',
}

escrow_ignore {
	'Config.lua',
	'server/extra.lua',
	'client/extra.lua'
}
dependency '/assetpacks'