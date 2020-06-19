----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Wed Jun 10 01:38:17 2020
-- Parameters for COREFIFO
----------------------------------------------------------------------


LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;
   USE ieee.numeric_std.all;

package coreparameters is
    constant AE_STATIC_EN : integer := 0;
    constant AEVAL : integer := 4;
    constant AF_STATIC_EN : integer := 0;
    constant AFVAL : integer := 60;
    constant CTRL_TYPE : integer := 3;
    constant ECC : integer := 0;
    constant ESTOP : integer := 1;
    constant FAMILY : integer := 19;
    constant FSTOP : integer := 1;
    constant FWFT : integer := 0;
    constant HDL_License : string( 1 to 1 ) := "U";
    constant NUM_STAGES : integer := 2;
    constant OVERFLOW_EN : integer := 0;
    constant PIPE : integer := 1;
    constant PREFETCH : integer := 0;
    constant RCLK_EDGE : integer := 1;
    constant RDCNT_EN : integer := 0;
    constant RDEPTH : integer := 64;
    constant RE_POLARITY : integer := 0;
    constant READ_DVALID : integer := 1;
    constant RESET_POLARITY : integer := 0;
    constant RWIDTH : integer := 16;
    constant SYNC : integer := 0;
    constant testbench : string( 1 to 4 ) := "User";
    constant UNDERFLOW_EN : integer := 0;
    constant WCLK_EDGE : integer := 1;
    constant WDEPTH : integer := 128;
    constant WE_POLARITY : integer := 0;
    constant WRCNT_EN : integer := 0;
    constant WRITE_ACK : integer := 0;
    constant WWIDTH : integer := 8;
end coreparameters;
