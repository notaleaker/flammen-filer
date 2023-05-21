-- Resource Metadata
fx_version 'cerulean'
games { 'gta5' }

author 'John Doe <j.doe@example.com>'
description 'Example resource'
version '1.0.0'

client_scripts {
    'client.lua'
} 

files {
    'progressbar.html'
}

exports {
    "StartUI",
    "StopUI",
}

ui_page 'progressbar.html'