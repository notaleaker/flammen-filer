fx_version 'adamant'
games { 'gta5' }

lua54 'yes'

ui_page 'html/index.html'

author 'Danny255' -- http://discord.gg/t24h5ku3su
description 'TunningSystem' -- https://danny255-scripts.tebex.io/package/4383179
version '1.3.1'

escrow_ignore {
  'config.lua',
  'client/client.lua',
  'server/server.lua',
}

client_scripts {
	'config.lua',
	'client/client.lua',
}

-- Thanks to https://www.flaticon.com/ for the amazing icons :3
-- Thanks to FiveM, Alt:V and RAGE:MP for the amazing documentation

files {
	'html/index.html',
	'html/script.js',
	'html/img/*.png',
	'html/main.css',
    'html/*.svg',
}

server_scripts {
   '@mysql-async/lib/MySQL.lua',
   'config.lua',
   'server/server.lua',
}
dependency '/assetpacks'