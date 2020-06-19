set_component FFT_Accel_system_sb_FABOSC_0_OSC
# Microsemi Corp.
# Date: 2020-Jun-14 00:39:57
#

create_clock -ignore_errors -period 20 [ get_pins { I_RCOSC_25_50MHZ/CLKOUT } ]
