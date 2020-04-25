read_sdc -scenario "place_and_route" -netlist "optimized" -pin_separator "/" -ignore_errors {E:/Github_Repos/SF2_Eth_FFT/FFT_Accelerator/designer/FFT_Accel_system/place_route.sdc}
set_options -tdpr_scenario "place_and_route" 
save
set_options -analysis_scenario "place_and_route"
report -type combinational_loops -format xml {E:\Github_Repos\SF2_Eth_FFT\FFT_Accelerator\designer\FFT_Accel_system\FFT_Accel_system_layout_combinational_loops.xml}
report -type slack {E:\Github_Repos\SF2_Eth_FFT\FFT_Accelerator\designer\FFT_Accel_system\pinslacks.txt}
set coverage [report \
    -type     constraints_coverage \
    -format   xml \
    -slacks   no \
    {E:\Github_Repos\SF2_Eth_FFT\FFT_Accelerator\designer\FFT_Accel_system\FFT_Accel_system_place_and_route_constraint_coverage.xml}]
set reportfile {E:\Github_Repos\SF2_Eth_FFT\FFT_Accelerator\designer\FFT_Accel_system\coverage_placeandroute}
set fp [open $reportfile w]
puts $fp $coverage
close $fp