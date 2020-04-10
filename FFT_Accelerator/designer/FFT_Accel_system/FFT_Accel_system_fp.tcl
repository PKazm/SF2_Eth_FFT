new_project \
         -name {FFT_Accel_system} \
         -location {E:\Github_Repos\SF2_FFT_Accelerator\FFT_Accelerator\designer\FFT_Accel_system\FFT_Accel_system_fp} \
         -mode {chain} \
         -connect_programmers {FALSE}
add_actel_device \
         -device {M2S010} \
         -name {M2S010}
enable_device \
         -name {M2S010} \
         -enable {TRUE}
save_project
close_project
