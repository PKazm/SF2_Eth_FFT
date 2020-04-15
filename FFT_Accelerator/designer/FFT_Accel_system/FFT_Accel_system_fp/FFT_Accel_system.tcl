open_project -project {E:\Github_Repos\SF2_Eth_FFT\FFT_Accelerator\designer\FFT_Accel_system\FFT_Accel_system_fp\FFT_Accel_system.pro}
enable_device -name {M2S010} -enable 1
set_programming_file -name {M2S010} -file {E:\Github_Repos\SF2_Eth_FFT\FFT_Accelerator\designer\FFT_Accel_system\FFT_Accel_system.ppd}
set_programming_action -action {PROGRAM} -name {M2S010} 
run_selected_actions
set_programming_file -name {M2S010} -no_file
save_project
close_project
