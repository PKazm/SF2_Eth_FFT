--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: AHB_Package.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--
-- Description: 
--
-- <Description here>
--
-- Targeted device: <Family::SmartFusion2> <Die::M2S010> <Package::144 TQ>
-- Author: <Name>
--
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package AHB_Package is

    constant HTRANS_IDLE     : std_logic_vector(1 downto 0) := "00";
    constant HTRANS_BUSY     : std_logic_vector(1 downto 0) := "01";
    constant HTRANS_NONSEQ   : std_logic_vector(1 downto 0) := "10";
    constant HTRANS_SEQ      : std_logic_vector(1 downto 0) := "11";

    constant HSIZE_8         : std_logic_vector(2 downto 0) := "000";
    constant HSIZE_16        : std_logic_vector(2 downto 0) := "001";
    constant HSIZE_32        : std_logic_vector(2 downto 0) := "010";
    constant HSIZE_64        : std_logic_vector(2 downto 0) := "011";
    constant HSIZE_128       : std_logic_vector(2 downto 0) := "100";
    constant HSIZE_256       : std_logic_vector(2 downto 0) := "101";
    constant HSIZE_512       : std_logic_vector(2 downto 0) := "110";
    constant HSIZE_1024      : std_logic_vector(2 downto 0) := "111";

    constant HBURST_SINGLE   : std_logic_vector(2 downto 0) := "000";
    constant HBURST_INCR     : std_logic_vector(2 downto 0) := "001";
    constant HBURST_WRAP4    : std_logic_vector(2 downto 0) := "010";
    constant HBURST_INCR4    : std_logic_vector(2 downto 0) := "011";
    constant HBURST_WRAP8    : std_logic_vector(2 downto 0) := "100";
    constant HBURST_INCR8    : std_logic_vector(2 downto 0) := "101";
    constant HBURST_WRAP16   : std_logic_vector(2 downto 0) := "110";
    constant HBURST_INCR16   : std_logic_vector(2 downto 0) := "111";

    constant HRESP_OKAY     : std_logic_vector(1 downto 0) := "00";
    constant HRESP_ERROR    : std_logic_vector(1 downto 0) := "01";
    constant HRESP_RETRY    : std_logic_vector(1 downto 0) := "10";
    constant HRESP_SPLIT    : std_logic_vector(1 downto 0) := "11";

    constant HPROT_OPCODE_FETCH  : std_logic_vector(3 downto 0) := "0000";
    constant HPROT_DATA_ACCESS   : std_logic_vector(3 downto 0) := "0001";
    constant HPROT_USE_ACCESS    : std_logic_vector(3 downto 0) := "0000";
    constant HPROT_PRIV_ACCESS   : std_logic_vector(3 downto 0) := "0010";
    constant HPROT_NON_BUFF      : std_logic_vector(3 downto 0) := "0000";
    constant HPROT_BUFF          : std_logic_vector(3 downto 0) := "0100";
    constant HPROT_NON_CACHE     : std_logic_vector(3 downto 0) := "0000";
    constant HPROT_CACHE         : std_logic_vector(3 downto 0) := "1000";

end package AHB_Package;

package body AHB_Package is


end package body AHB_Package;
