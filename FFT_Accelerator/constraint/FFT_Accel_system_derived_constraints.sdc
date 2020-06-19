# Microsemi Corp.
# Date: 2020-Jun-13 23:52:55
# This file was generated based on the following SDC source files:
#   E:/Github_Repos/SF2_Eth_FFT/FFT_Accelerator/component/work/FFT_Accel_system_sb/CCC_0/FFT_Accel_system_sb_CCC_0_FCCC.sdc
#   C:/Microsemi/Libero_SoC_v12.4/Designer/data/aPA4M/cores/constraints/coreresetp.sdc
#   E:/Github_Repos/SF2_Eth_FFT/FFT_Accelerator/component/work/FFT_Accel_system_sb/FABOSC_0/FFT_Accel_system_sb_FABOSC_0_OSC.sdc
#   E:/Github_Repos/SF2_Eth_FFT/FFT_Accelerator/component/work/FFT_Accel_system_sb_MSS/FFT_Accel_system_sb_MSS.sdc
#   C:/Microsemi/Libero_SoC_v12.4/Designer/data/aPA4M/cores/constraints/sysreset.sdc
#

create_clock -ignore_errors -name {FFT_Accel_system_sb_0/FABOSC_0/I_RCOSC_25_50MHZ/CLKOUT} -period 20 [ get_pins { FFT_Accel_system_sb_0/FABOSC_0/I_RCOSC_25_50MHZ/CLKOUT } ]
create_generated_clock -name {FFT_Accel_system_sb_0/CCC_0/GL0} -multiply_by 5 -divide_by 4 -source [ get_pins { FFT_Accel_system_sb_0/CCC_0/CCC_INST/RCOSC_25_50MHZ } ] -phase 0 [ get_pins { FFT_Accel_system_sb_0/CCC_0/CCC_INST/GL0 } ]
create_generated_clock -name {FFT_Accel_system_sb_0/CCC_0/GL1} -multiply_by 5 -divide_by 2 -source [ get_pins { FFT_Accel_system_sb_0/CCC_0/CCC_INST/RCOSC_25_50MHZ } ] -phase 0 [ get_pins { FFT_Accel_system_sb_0/CCC_0/CCC_INST/GL1 } ]
set_false_path -ignore_errors -through [ get_nets { FFT_Accel_system_sb_0/CORERESETP_0/ddr_settled FFT_Accel_system_sb_0/CORERESETP_0/count_ddr_enable FFT_Accel_system_sb_0/CORERESETP_0/release_sdif*_core FFT_Accel_system_sb_0/CORERESETP_0/count_sdif*_enable } ]
set_false_path -ignore_errors -from [ get_cells { FFT_Accel_system_sb_0/CORERESETP_0/MSS_HPMS_READY_int } ] -to [ get_cells { FFT_Accel_system_sb_0/CORERESETP_0/sm0_areset_n_rcosc FFT_Accel_system_sb_0/CORERESETP_0/sm0_areset_n_rcosc_q1 } ]
set_false_path -ignore_errors -from [ get_cells { FFT_Accel_system_sb_0/CORERESETP_0/MSS_HPMS_READY_int FFT_Accel_system_sb_0/CORERESETP_0/SDIF*_PERST_N_re } ] -to [ get_cells { FFT_Accel_system_sb_0/CORERESETP_0/sdif*_areset_n_rcosc* } ]
set_false_path -ignore_errors -through [ get_nets { FFT_Accel_system_sb_0/CORERESETP_0/CONFIG1_DONE FFT_Accel_system_sb_0/CORERESETP_0/CONFIG2_DONE FFT_Accel_system_sb_0/CORERESETP_0/SDIF*_PERST_N FFT_Accel_system_sb_0/CORERESETP_0/SDIF*_PSEL FFT_Accel_system_sb_0/CORERESETP_0/SDIF*_PWRITE FFT_Accel_system_sb_0/CORERESETP_0/SDIF*_PRDATA[*] FFT_Accel_system_sb_0/CORERESETP_0/SOFT_EXT_RESET_OUT FFT_Accel_system_sb_0/CORERESETP_0/SOFT_RESET_F2M FFT_Accel_system_sb_0/CORERESETP_0/SOFT_M3_RESET FFT_Accel_system_sb_0/CORERESETP_0/SOFT_MDDR_DDR_AXI_S_CORE_RESET FFT_Accel_system_sb_0/CORERESETP_0/SOFT_FDDR_CORE_RESET FFT_Accel_system_sb_0/CORERESETP_0/SOFT_SDIF*_PHY_RESET FFT_Accel_system_sb_0/CORERESETP_0/SOFT_SDIF*_CORE_RESET FFT_Accel_system_sb_0/CORERESETP_0/SOFT_SDIF0_0_CORE_RESET FFT_Accel_system_sb_0/CORERESETP_0/SOFT_SDIF0_1_CORE_RESET } ]
set_false_path -ignore_errors -through [ get_pins { FFT_Accel_system_sb_0/FFT_Accel_system_sb_MSS_0/MSS_ADLIB_INST/CONFIG_PRESET_N } ]
set_false_path -ignore_errors -through [ get_pins { FFT_Accel_system_sb_0/SYSRESET_POR/POWER_ON_RESET_N } ]
