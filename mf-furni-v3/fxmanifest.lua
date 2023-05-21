fx_version 'bodacious'
games { 'rdr3', 'gta5' }

mod 'mf-furni-v3'
version '1.0.1'

ui_page 'nui/index.html'

lua54 'yes'

shared_scripts {
  'shared/categories.lua',
  'shared/shops.lua',
  'shared/presets.lua',
  'shared/config.lua',
  'shared/utils.lua'
}

client_scripts {
  '@PolyZone/client.lua',
  '@PolyZone/BoxZone.lua',
  '@PolyZone/EntityZone.lua',
  '@PolyZone/CircleZone.lua',
  '@PolyZone/ComboZone.lua',

  'client/main.lua',
  'client/commands.lua',
}

server_scripts {
  '@mysql-async/lib/MySQL.lua',
  
  'credentials.lua',
  'server/server.lua',
}

files {
  'nui/index.html'
}

dependencies {
  'meta_libs',
  'PolyZone',
  'mysql-async',
  'es_extended',
  'mythic_interiors',
  'fivem-target',
  'mf-inventory',
  'mf-housing-v3'
}
