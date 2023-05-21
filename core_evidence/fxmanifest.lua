
fx_version 'adamant'
game 'gta5'

author 'c8re'
description 'Original Evidence system for FiveM'
version '2.2.0'

ui_page 'html/form.html'

files {
	'html/form.html',
	'html/img/logo.png',
	'html/img/report.jpg',
	'html/css.css',
	'html/script.js',
	'html/jquery-3.4.1.min.js',
}

client_scripts{
    'config.lua',
    'client/main.lua',
}

server_scripts{
    'config.lua',
    '@mysql-async/lib/MySQL.lua',
    'server/main.lua',
}

lua54 'yes'


escrow_ignore {
  'client/main.lua',
  'server/main.lua',
  'config.lua'
}

dependency '/assetpacks'