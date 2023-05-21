-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

fx_version 'cerulean'
games {'gta5'}

author 'T1GER#9080'
discord 'https://discord.gg/FdHkq5q'
description 'T1GER Bank Robbery'
auth 'Please open a ticket on my discord to get auth & support.'
version '1.0.2'

client_scripts {
	'language.lua',
	'config.lua',
	'client/main.lua',
	'client/drilling.lua',
	'client/safecrack.lua',
	'client/utils.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'language.lua',
	'config.lua',
	'server/main.lua'
}