read_sdc -scenario "timing_analysis" -netlist "optimized" -pin_separator "/" -ignore_errors {E:/Github_Repos/SF2_Eth_FFT/FFT_Accelerator/designer/FFT_Accel_system/timing_analysis.sdc}
set_options -analysis_scenario "timing_analysis" 
save
