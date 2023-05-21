fx_version 'adamant'
game 'gta5'

Author 'Grillmeister-Services'
description 'Vespucci Cardealer'

version '2.3'


this_is_a_map 'yes'


file 'GRS_cardealer_ext.ytyp'
file 'grs_cardealer_shell_milo.ytyp'
file 'GRS_windows.ytyp'

data_file 'DLC_ITYP_REQUEST' 'GRS_cardealer_ext.ytyp'
data_file 'DLC_ITYP_REQUEST' 'grs_cardealer_shell_milo.ytyp'
data_file 'DLC_ITYP_REQUEST' 'GRS_windows.ytyp'


escrow_ignore {
    'stream/dt1_23_build4_rls.ydr',
    'stream/dt1_23_build4_glass.ydr',
    'stream/dt1_23_build4_decalsa.ydr',
    'stream/dt1_rd1_r1_24.ydr',
    'stream/hei_dt1_23_build4.ydr',
    'stream/hei_dt1_23_ground.ydr',
    'stream/hei_dt1_23_ov3.ydr'
  }

dependency '/assetpacks'