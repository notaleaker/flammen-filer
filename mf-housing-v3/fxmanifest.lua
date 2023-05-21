fx_version 'bodacious'
games { 'rdr3', 'gta5' }

mod 'mf-housing-v3'
version '1.0.2'

ui_page 'html/index.html'

shared_scripts {
  'config.lua',
  'utils.lua'
}

client_scripts {
  '@PolyZone/client.lua',
  '@PolyZone/BoxZone.lua',
  '@PolyZone/EntityZone.lua',
  '@PolyZone/CircleZone.lua',
  '@PolyZone/ComboZone.lua',

  'client/main.lua',
  'client/events.lua',
  'client/commands.lua',
}

server_scripts {
  '@mysql-async/lib/MySQL.lua',
  
  'credentials.lua',
  'server/main.lua',
  'server/server.lua',
  'server/events.lua',
  'server/commands.lua',
}

files {
  'html/index.html'
}

dependencies {
  'meta_libs',
  'PolyZone',
  'mysql-async',
  'es_extended',
  'fivem-target',
  'esx_datastore',
  'mf-inventory'
}
