fx_version "cerulean"

game "gta5"

shared_script "config.lua"

client_scripts {
    "functions.lua",
    "client/*.lua",
} 

server_script "server/server.lua"

lua54 'yes'

escrow_ignore {
    'config.lua',
    '[items]/shared.lua'
}