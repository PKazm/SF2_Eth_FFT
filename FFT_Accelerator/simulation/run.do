quietly set ACTELLIBNAME SmartFusion2
quietly set PROJECT_DIR "E:/Github_Repos/SF2_Eth_FFT/FFT_Accelerator"
source "${PROJECT_DIR}/simulation/CM3_compile_bfm.tcl";


if {[file exists presynth/_info]} {
   echo "INFO: Simulation library presynth already exists"
} else {
   file delete -force presynth 
   vlib presynth
}
vmap presynth presynth
vmap SmartFusion2 "C:/Microsemi/Libero_SoC_v12.4/Designer/lib/modelsimpro/precompiled/vlog/SmartFusion2"
if {[file exists COREAPB3_LIB/_info]} {
   echo "INFO: Simulation library COREAPB3_LIB already exists"
} else {
   file delete -force COREAPB3_LIB 
   vlib COREAPB3_LIB
}
vmap COREAPB3_LIB "COREAPB3_LIB"
vmap COREAHBLITE_LIB "../component/Actel/DirectCore/CoreAHBLite/5.4.102/mti/user_vhdl/COREAHBLITE_LIB"
vcom -work COREAHBLITE_LIB -force_refresh
vlog -work COREAHBLITE_LIB -force_refresh
if {[file exists COREAHBLSRAM_LIB/_info]} {
   echo "INFO: Simulation library COREAHBLSRAM_LIB already exists"
} else {
   file delete -force COREAHBLSRAM_LIB 
   vlib COREAHBLSRAM_LIB
}
vmap COREAHBLSRAM_LIB "COREAHBLSRAM_LIB"
if {[file exists COREAHBTOAPB3_LIB/_info]} {
   echo "INFO: Simulation library COREAHBTOAPB3_LIB already exists"
} else {
   file delete -force COREAHBTOAPB3_LIB 
   vlib COREAHBTOAPB3_LIB
}
vmap COREAHBTOAPB3_LIB "COREAHBTOAPB3_LIB"

vcom -2008 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.4.102/rtl/vhdl/core/coreahblite_slavearbiter.vhd"
vcom -2008 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.4.102/rtl/vhdl/core/coreahblite_slavestage.vhd"
vcom -2008 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.4.102/rtl/vhdl/core/coreahblite_defaultslavesm.vhd"
vcom -2008 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.4.102/rtl/vhdl/core/coreahblite_addrdec.vhd"
vcom -2008 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.4.102/rtl/vhdl/core/coreahblite_masterstage.vhd"
vcom -2008 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.4.102/rtl/vhdl/core/coreahblite_matrix4x16.vhd"
vcom -2008 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.4.102/rtl/vhdl/core/coreahblite_pkg.vhd"
vcom -2008 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/work/CoreAHBLite_C0/CoreAHBLite_C0_0/rtl/vhdl/core/coreahblite.vhd"
vcom -2008 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/work/CoreAHBLite_C0/CoreAHBLite_C0_0/rtl/vhdl/core/components.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/CoreAHBLite_C0/CoreAHBLite_C0.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/DPSRAM_C0/DPSRAM_C0_0/DPSRAM_C0_DPSRAM_C0_0_DPSRAM.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/DPSRAM_C0/DPSRAM_C0.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/FFT_Package.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/FFT_Sample_Loader.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/FFT_Sample_Outputer.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/HARD_MULT_ADDSUB_C0/HARD_MULT_ADDSUB_C0_0/HARD_MULT_ADDSUB_C0_HARD_MULT_ADDSUB_C0_0_HARD_MULT_ADDSUB.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/HARD_MULT_ADDSUB_C0/HARD_MULT_ADDSUB_C0.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/FFT_Butterfly_HW_MATHDSP.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/Twiddle_table.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/FFT_Transformer.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/FFT.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/HARD_MULT_ADDSUB_C1/HARD_MULT_ADDSUB_C1_0/HARD_MULT_ADDSUB_C1_HARD_MULT_ADDSUB_C1_0_HARD_MULT_ADDSUB.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/HARD_MULT_ADDSUB_C1/HARD_MULT_ADDSUB_C1.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/Alpha_Max_plus_Beta_Min.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/AHB_Package.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/FFT_AHB_Wrapper.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/FFT_Accel_system_sb/CCC_0/FFT_Accel_system_sb_CCC_0_FCCC.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/FFT_Accel_system_sb/FABOSC_0/FFT_Accel_system_sb_FABOSC_0_OSC.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/FFT_Accel_system_sb_MSS/FFT_Accel_system_sb_MSS.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CoreResetP/7.1.100/rtl/vhdl/core/coreresetp_pcie_hotreset.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CoreResetP/7.1.100/rtl/vhdl/core/coreresetp.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/FFT_Accel_system_sb/FFT_Accel_system_sb.vhd"
vcom -2008 -explicit  -work presynth "C:/Users/Phoenix136/Dropbox/FPGA/My_Stuff/Standalone Files/LED_inverter_dimmer.vhd"
vcom -2008 -explicit  -work presynth "E:/Github_Repos/SF2_MKR_KIT_IO_Constraints/MSS_to_IO_Interpreter.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/FFT_Accel_system/FFT_Accel_system.vhd"
vcom -2008 -explicit  -work COREAHBTOAPB3_LIB "${PROJECT_DIR}/component/Actel/DirectCore/COREAHBTOAPB3/3.1.100/rtl/vhdl/core/ahbtoapb3_pkg.vhd"
vcom -2008 -explicit  -work COREAHBTOAPB3_LIB "${PROJECT_DIR}/component/Actel/DirectCore/COREAHBTOAPB3/3.1.100/rtl/vhdl/core/components.vhd"
vcom -2008 -explicit  -work COREAPB3_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAPB3/4.1.100/rtl/vhdl/core/components.vhd"

vsim -L SmartFusion2 -L presynth -L COREAPB3_LIB -L COREAHBLITE_LIB -L COREAHBLSRAM_LIB -L COREAHBTOAPB3_LIB  -t 10ps presynth.FFT_Accel_system
# The following lines are commented because no testbench is associated with the project
# add wave /testbench/*
# run 1000ns
