-- Created by Scully#5775 | https://discord.gg/eNtGFS6
fx_version 'cerulean'

game 'gta5'

author 'Scully#5775'
description 'v2 of very noice radio'
version '2.4'

dependencies {
	'/server:5402',
	'/onesync',
	'pma-voice'
}

lua54 'yes'

shared_scripts {
	'config.lua',
	'functions/*.lua'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}

escrow_ignore {
	'config.lua',
	'client/*.lua',
	'server/*.lua',
	'functions/*.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/*.css',
	'ui/*.js',
	'ui/images/**/*.png'
}

dependency '/assetpacks'