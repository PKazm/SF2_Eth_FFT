set_component FFT_Accel_system_sb_CCC_0_FCCC
# Microsemi Corp.
# Date: 2020-Jun-14 00:39:56
#

create_clock -period 20 [ get_pins { CCC_INST/RCOSC_25_50MHZ } ]
create_generated_clock -multiply_by 5 -divide_by 4 -source [ get_pins { CCC_INST/RCOSC_25_50MHZ } ] -phase 0 [ get_pins { CCC_INST/GL0 } ]
create_generated_clock -multiply_by 5 -divide_by 2 -source [ get_pins { CCC_INST/RCOSC_25_50MHZ } ] -phase 0 [ get_pins { CCC_INST/GL1 } ]
