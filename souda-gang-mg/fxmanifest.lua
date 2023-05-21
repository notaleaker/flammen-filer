fx_version 'adamant'
games { 'rdr3', 'gta5' }

author 'Souda'
description 'Souda Gang Hood MG'
version '1.0.0'

files {
    'stream/murietta_heights.ymt',
    'audio/souda_mg.dat151.rel'
  }

data_file "SCENARIO_POINTS_OVERRIDE_FILE" 'stream/murietta_heights.ymt'
data_file 'AUDIO_GAMEDATA' 'audio/souda_mg.dat'

this_is_a_map 'yes'

lua54 'yes'

dependency '/assetpacks'