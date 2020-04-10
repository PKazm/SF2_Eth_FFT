set_family {SmartFusion2}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\SF2_FFT_Accelerator\FFT_Accelerator\component\work\DPSRAM_C0\DPSRAM_C0_0\DPSRAM_C0_DPSRAM_C0_0_DPSRAM.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\SF2_FFT_Accelerator\FFT_Accelerator\component\work\DPSRAM_C0\DPSRAM_C0.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\SF2_FFT_Accelerator\FFT_Accelerator\hdl\FFT_Package.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\SF2_FFT_Accelerator\FFT_Accelerator\hdl\FFT_Sample_Loader.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\SF2_FFT_Accelerator\FFT_Accelerator\component\work\HARD_MULT_ADDSUB_C0\HARD_MULT_ADDSUB_C0_0\HARD_MULT_ADDSUB_C0_HARD_MULT_ADDSUB_C0_0_HARD_MULT_ADDSUB.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\SF2_FFT_Accelerator\FFT_Accelerator\component\work\HARD_MULT_ADDSUB_C0\HARD_MULT_ADDSUB_C0.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\SF2_FFT_Accelerator\FFT_Accelerator\hdl\FFT_Butterfly_HW_MATHDSP.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\SF2_FFT_Accelerator\FFT_Accelerator\hdl\Twiddle_table.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\SF2_FFT_Accelerator\FFT_Accelerator\hdl\FFT_Transformer.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\SF2_FFT_Accelerator\FFT_Accelerator\hdl\FFT_Sample_Outputer.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\SF2_FFT_Accelerator\FFT_Accelerator\hdl\FFT.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\SF2_FFT_Accelerator\FFT_Accelerator\component\work\HARD_MULT_ADDSUB_C1\HARD_MULT_ADDSUB_C1_0\HARD_MULT_ADDSUB_C1_HARD_MULT_ADDSUB_C1_0_HARD_MULT_ADDSUB.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\SF2_FFT_Accelerator\FFT_Accelerator\component\work\HARD_MULT_ADDSUB_C1\HARD_MULT_ADDSUB_C1.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\SF2_FFT_Accelerator\FFT_Accelerator\hdl\Alpha_Max_plus_Beta_Min.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\SF2_FFT_Accelerator\FFT_Accelerator\hdl\FFT_APB_Wrapper.vhd}
set_top_level {FFT_APB_Wrapper}
map_netlist
check_constraints {E:\Github_Repos\SF2_FFT_Accelerator\FFT_Accelerator\constraint\synthesis_sdc_errors.log}
write_fdc {E:\Github_Repos\SF2_FFT_Accelerator\FFT_Accelerator\designer\FFT_APB_Wrapper\synthesis.fdc}
