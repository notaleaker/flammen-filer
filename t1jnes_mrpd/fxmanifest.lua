fx_version 'bodacious'
game 'gta5'

author 'T1JNES'

this_is_a_map 'yes'

replace_level_meta 'doortuning/gta5'

files {
    'doortuning/gta5.meta',
    'doortuning/doortuning.ymt',
    'audio/t1jnes_mrpd_col_game.dat151.rel',
    'audio/t1jnes_mrpd_col_mix.dat15.rel',
}

data_file 'AUDIO_GAMEDATA' 'audio/t1jnes_mrpd_col_game.dat'
data_file 'AUDIO_DYNAMIXDATA' 'audio/t1jnes_mrpd_col_mix.dat'

escrow_ignore {
    'stream/ytd/t1jnes_mrpd_int.ytd', -- Works for any file, stream or code
    'stream/ytd/t1jnes_mrpd_props.ytd', -- Works for any file, stream or code
  }
dependency '/assetpacks'