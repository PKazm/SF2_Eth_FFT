set_component FFT_Accel_system_sb_MSS
# Microsemi Corp.
# Date: 2020-Jun-14 00:39:53
#

create_clock -period 32 [ get_pins { MSS_ADLIB_INST/CLK_CONFIG_APB } ]
set_false_path -ignore_errors -through [ get_pins { MSS_ADLIB_INST/CONFIG_PRESET_N } ]
