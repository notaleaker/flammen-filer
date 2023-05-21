--[[
#########################################################
# ██████╗ ███╗   ███╗██╗██╗  ██╗██╗  ██╗███████╗██╗     #
#██╔═══██╗████╗ ████║██║██║ ██╔╝██║ ██╔╝██╔════╝██║     #
#██║   ██║██╔████╔██║██║█████╔╝ █████╔╝ █████╗  ██║     #
#██║   ██║██║╚██╔╝██║██║██╔═██╗ ██╔═██╗ ██╔══╝  ██║     #
#╚██████╔╝██║ ╚═╝ ██║██║██║  ██╗██║  ██╗███████╗███████╗#
# ╚═════╝ ╚═╝     ╚═╝╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝#
#########################################################
--]]
-- Script: omik_polititablet V2
-- Author: OMikkel#3217

fx_version "cerulean"
game "gta5"

name 'omik_polititablet'
author 'OMikkel#3217 - https://omikkel.com/ - https://omikkel.com/discord'
description 'omik_polititablet_V2 | Lavet af OMikkel#3217 - https://omikkel.com/'

version "2.5.3"

dependencies {
    "mysql-async"
}

shared_script '@es_extended/imports.lua'

server_scripts {
    "lib/sCallback.lua",
    "@vrp/lib/utils.lua",
    "@mysql-async/lib/MySQL.lua",
    "api/queries.lua",
    "api/constructQuery.lua",
    "api/endpoints.lua",
    "api/server.lua",
    'licensekey.lua',
    'config.lua',
    'server.lua'
}

client_script {
    "lib/cCallback.lua",
    "api/endpoints.lua",
    "api/callbacks.lua",
    'config.lua',
    'client.lua'
}

files {
    "img/*.png"
}

--ui_page 'https://omik-polititablet-ggtngxs3q-omikkel.vercel.app/'
ui_page 'https://tablet.omikkel.com/'