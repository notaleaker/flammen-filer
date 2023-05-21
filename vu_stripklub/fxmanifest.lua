fx_version      'adamant'
game            'gta5'

author          'Flammen RP'
description     'Stripklub'
version         '1.0.0'

dependencies {
    'es_extended',
    'mythic_notify'
}

server_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    'config.lua',

    'server/main.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    'config.lua',

    'client/main.lua'
}