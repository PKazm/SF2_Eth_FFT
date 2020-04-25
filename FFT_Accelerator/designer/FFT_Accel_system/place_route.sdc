# Microsemi Corp.
# Date: 2020-Apr-23 03:42:36
# This file was generated based on the following SDC source files:
#   E:/Github_Repos/SF2_Eth_FFT/FFT_Accelerator/constraint/FFT_Accel_system_derived_constraints.sdc
#

create_clock -name {FFT_Accel_system_sb_0/FABOSC_0/I_RCOSC_25_50MHZ/CLKOUT} -period 20 [ get_pins { FFT_Accel_system_sb_0/FABOSC_0/I_RCOSC_25_50MHZ/CLKOUT } ]
create_generated_clock -name {FFT_Accel_system_sb_0/CCC_0/GL0} -multiply_by 20 -divide_by 10 -source [ get_pins { FFT_Accel_system_sb_0/CCC_0/CCC_INST/INST_CCC_IP/RCOSC_25_50MHZ } ] -phase 0 [ get_pins { FFT_Accel_system_sb_0/CCC_0/CCC_INST/INST_CCC_IP/GL0 } ]
create_generated_clock -name {FFT_Accel_system_sb_0/CCC_0/GL1} -multiply_by 20 -divide_by 8 -source [ get_pins { FFT_Accel_system_sb_0/CCC_0/CCC_INST/INST_CCC_IP/RCOSC_25_50MHZ } ] -phase 0 [ get_pins { FFT_Accel_system_sb_0/CCC_0/CCC_INST/INST_CCC_IP/GL1 } ]
set_false_path -through [ get_pins { FFT_Accel_system_sb_0/FFT_Accel_system_sb_MSS_0/MSS_ADLIB_INST/INST_MSS_010_IP/CONFIG_PRESET_N } ]
set_false_path -through [ get_pins { FFT_Accel_system_sb_0/SYSRESET_POR/INST_SYSRESET_FF_IP/POWER_ON_RESET_N } ]
