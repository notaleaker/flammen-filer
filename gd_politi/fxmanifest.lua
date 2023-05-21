fx_version "cerulean"
game "gta5"
name "cars"
description "GeekDesigns - Politi Køretøjer"
author "Købt hos geekdesigns.tebex.io"
version "1.0.0"
lua54 'yes'

files{
    'data/**/*.meta',
    'audio/sfx/**/*.awc',
    'audio/*.rel'
}

data_file 'HANDLING_FILE' 'data/**/handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/**/vehicles.meta'
data_file 'CARCOLS_FILE' 'data/**/carcols.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/**/carvariations.meta'
data_file 'AUDIO_WAVEPACK' 'audio/sfx/dlc_argento'
data_file 'AUDIO_GAMEDATA' 'audio/argento_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/argento_sounds.dat'
dependency '/assetpacks'