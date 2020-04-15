quietly set ACTELLIBNAME SmartFusion2
quietly set PROJECT_DIR "E:/Github_Repos/SF2_Eth_FFT/FFT_Accelerator"

if {[file exists presynth/_info]} {
   echo "INFO: Simulation library presynth already exists"
} else {
   file delete -force presynth 
   vlib presynth
}
vmap presynth presynth
vmap SmartFusion2 "C:/Microsemi/Libero_SoC_v12.1/Designer/lib/modelsimpro/precompiled/vlog/SmartFusion2"
if {[file exists COREAPB3_LIB/_info]} {
   echo "INFO: Simulation library COREAPB3_LIB already exists"
} else {
   file delete -force COREAPB3_LIB 
   vlib COREAPB3_LIB
}
vmap COREAPB3_LIB "COREAPB3_LIB"

vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/DPSRAM_C0/DPSRAM_C0_0/DPSRAM_C0_DPSRAM_C0_0_DPSRAM.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/DPSRAM_C0/DPSRAM_C0.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/FFT_Package.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/FFT_Sample_Loader.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/HARD_MULT_ADDSUB_C0/HARD_MULT_ADDSUB_C0_0/HARD_MULT_ADDSUB_C0_HARD_MULT_ADDSUB_C0_0_HARD_MULT_ADDSUB.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/HARD_MULT_ADDSUB_C0/HARD_MULT_ADDSUB_C0.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/FFT_Butterfly_HW_MATHDSP.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/Twiddle_table.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/FFT_Transformer.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/FFT_Sample_Outputer.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/FFT.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/HARD_MULT_ADDSUB_C1/HARD_MULT_ADDSUB_C1_0/HARD_MULT_ADDSUB_C1_HARD_MULT_ADDSUB_C1_0_HARD_MULT_ADDSUB.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/HARD_MULT_ADDSUB_C1/HARD_MULT_ADDSUB_C1.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/Alpha_Max_plus_Beta_Min.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/FFT_APB_Wrapper.vhd"
vcom -2008 -explicit  -work COREAPB3_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAPB3/4.1.100/rtl/vhdl/core/components.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/stimulus/FFT_APB_Wrappe_tb.vhd"

vsim -L SmartFusion2 -L presynth -L COREAPB3_LIB  -t 10ps presynth.testbench
add wave /testbench/*
run 1000ns
