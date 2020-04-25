set_family {SmartFusion2}
read_adl {E:\Github_Repos\SF2_Eth_FFT\FFT_Accelerator\designer\FFT_Accel_system\FFT_Accel_system.adl}
read_afl {E:\Github_Repos\SF2_Eth_FFT\FFT_Accelerator\designer\FFT_Accel_system\FFT_Accel_system.afl}
map_netlist
read_sdc {E:\Github_Repos\SF2_Eth_FFT\FFT_Accelerator\constraint\FFT_Accel_system_derived_constraints.sdc}
check_constraints {E:\Github_Repos\SF2_Eth_FFT\FFT_Accelerator\constraint\timing_sdc_errors.log}
write_sdc -strict -afl {E:\Github_Repos\SF2_Eth_FFT\FFT_Accelerator\designer\FFT_Accel_system\timing_analysis.sdc}
