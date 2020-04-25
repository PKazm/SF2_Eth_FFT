# Written by Synplify Pro version mapact, Build 2737R. Synopsys Run ID: sid1587627712 
# Top Level Design Parameters 

# Clocks 
create_clock -period 20.000 -waveform {0.000 10.000} -name {FFT_Accel_system_sb_0/FABOSC_0/I_RCOSC_25_50MHZ/CLKOUT} [get_pins {FFT_Accel_system_sb_0/FABOSC_0/I_RCOSC_25_50MHZ/CLKOUT}] 
create_clock -period 10.000 -waveform {0.000 5.000} -name {FFT_Accel_system|GMII_RX_CLK} [get_ports {GMII_RX_CLK}] 

# Virtual Clocks 

# Generated Clocks 
create_generated_clock -name {FFT_Accel_system_sb_0/CCC_0/GL0} -multiply_by {20} -divide_by {10} -source [get_pins {FFT_Accel_system_sb_0/CCC_0/CCC_INST/RCOSC_25_50MHZ}]  [get_pins {FFT_Accel_system_sb_0/CCC_0/CCC_INST/GL0}] 
create_generated_clock -name {FFT_Accel_system_sb_0/CCC_0/GL1} -multiply_by {20} -divide_by {8} -source [get_pins {FFT_Accel_system_sb_0/CCC_0/CCC_INST/RCOSC_25_50MHZ}]  [get_pins {FFT_Accel_system_sb_0/CCC_0/CCC_INST/GL1}] 

# Paths Between Clocks 

# Multicycle Constraints 

# Point-to-point Delay Constraints 

# False Path Constraints 

# Output Load Constraints 

# Driving Cell Constraints 

# Input Delay Constraints 

# Output Delay Constraints 

# Wire Loads 

# Other Constraints 

# syn_hier Attributes 

# set_case Attributes 

# Clock Delay Constraints 
set_clock_groups -asynchronous -group [get_clocks {FFT_Accel_system|GMII_RX_CLK}]

# syn_mode Attributes 

# Cells 

# Port DRC Rules 

# Input Transition Constraints 

# Unused constraints (intentionally commented out) 
# set_false_path -through [get_nets { FFT_Accel_system_sb_0.CORERESETP_0.ddr_settled FFT_Accel_system_sb_0.CORERESETP_0.count_ddr_enable FFT_Accel_system_sb_0.CORERESETP_0.release_sdif*_core FFT_Accel_system_sb_0.CORERESETP_0.count_sdif*_enable }]
# set_false_path -from [get_cells { FFT_Accel_system_sb_0.CORERESETP_0.MSS_HPMS_READY_int }] -to [get_cells { FFT_Accel_system_sb_0.CORERESETP_0.sm0_areset_n_rcosc FFT_Accel_system_sb_0.CORERESETP_0.sm0_areset_n_rcosc_q1 }]
# set_false_path -from [get_cells { FFT_Accel_system_sb_0.CORERESETP_0.MSS_HPMS_READY_int FFT_Accel_system_sb_0.CORERESETP_0.SDIF*_PERST_N_re }] -to [get_cells { FFT_Accel_system_sb_0.CORERESETP_0.sdif*_areset_n_rcosc* }]
# set_false_path -through [get_nets { FFT_Accel_system_sb_0.CORERESETP_0.CONFIG1_DONE FFT_Accel_system_sb_0.CORERESETP_0.CONFIG2_DONE FFT_Accel_system_sb_0.CORERESETP_0.SDIF*_PERST_N FFT_Accel_system_sb_0.CORERESETP_0.SDIF*_PSEL FFT_Accel_system_sb_0.CORERESETP_0.SDIF*_PWRITE FFT_Accel_system_sb_0.CORERESETP_0.SDIF*_PRDATA[*] FFT_Accel_system_sb_0.CORERESETP_0.SOFT_EXT_RESET_OUT FFT_Accel_system_sb_0.CORERESETP_0.SOFT_RESET_F2M FFT_Accel_system_sb_0.CORERESETP_0.SOFT_M3_RESET FFT_Accel_system_sb_0.CORERESETP_0.SOFT_MDDR_DDR_AXI_S_CORE_RESET FFT_Accel_system_sb_0.CORERESETP_0.SOFT_FDDR_CORE_RESET FFT_Accel_system_sb_0.CORERESETP_0.SOFT_SDIF*_PHY_RESET FFT_Accel_system_sb_0.CORERESETP_0.SOFT_SDIF*_CORE_RESET FFT_Accel_system_sb_0.CORERESETP_0.SOFT_SDIF0_0_CORE_RESET FFT_Accel_system_sb_0.CORERESETP_0.SOFT_SDIF0_1_CORE_RESET }]
# set_false_path -through [get_pins { FFT_Accel_system_sb_0.FFT_Accel_system_sb_MSS_0.MSS_ADLIB_INST.CONFIG_PRESET_N }]
# set_false_path -through [get_pins { FFT_Accel_system_sb_0.SYSRESET_POR.POWER_ON_RESET_N }]


# Non-forward-annotatable constraints (intentionally commented out) 

# Block Path constraints 

