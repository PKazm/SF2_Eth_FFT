-- Copyright 2013 Actel Corporation.  All rights reserved.
-- IP Solutions Group
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED 
-- IN ADVANCE IN WRITING.  
--  
-- File:  dualram.vhd
--     
-- Description: Core10100
--              Dual port RAM   
--
-- SVN Revision Information:
-- SVN $Revision: 6737 $
-- SVN $Date: 2009-02-20 23:42:36 +0530 (Fri, 20 Feb 2009) $  
--   
--
-- Notes:  Either infers RAM or instantiates based on FAMILY
--		   May need modifying for inference
--
-- *********************************************************************/ 
--

library IEEE;
use ieee.std_logic_1164.all; 
use IEEE.NUMERIC_STD.all;
use work.utility.all;

entity DUALRAM is
  generic (	 FAMILY  : INTEGER range 0 to 24;
             AWIDTH  : INTEGER range 6 to 12;	 -- FIXED WIDTH 8JAN08 IPB
             DWIDTH  : INTEGER range 8 to 32
            );
  port (  CLKW  : in  STD_LOGIC;
          CLKR  : in  STD_LOGIC;
          WE    : in  STD_LOGIC;
          WADDR : in  STD_LOGIC_VECTOR(AWIDTH-1 downto 0);
          RADDR : in  STD_LOGIC_VECTOR(AWIDTH-1 downto 0);
          WDATA : in  STD_LOGIC_VECTOR(DWIDTH-1 downto 0);
          RDATA : out STD_LOGIC_VECTOR(DWIDTH-1 downto 0)
	);
end DUALRAM;



architecture RTL of dualram is

-- declare all RAM blocks in RAMBLOCKs_XXX.vhd

component RAMBLOCK64X8
port (
    Q : out STD_LOGIC_VECTOR(7 downto 0);
    Data : in STD_LOGIC_VECTOR(7 downto 0);
    WAddress : in STD_LOGIC_VECTOR(5 downto 0);
    RAddress : in STD_LOGIC_VECTOR(5 downto 0);
    WE : in STD_LOGIC;
    RE : in STD_LOGIC;
    WClock : in STD_LOGIC;
    RClock : in STD_LOGIC);
end component;
component RAMBLOCK128X8
port (
    Q : out STD_LOGIC_VECTOR(7 downto 0);
    Data : in STD_LOGIC_VECTOR(7 downto 0);
    WAddress : in STD_LOGIC_VECTOR(6 downto 0);
    RAddress : in STD_LOGIC_VECTOR(6 downto 0);
    WE : in STD_LOGIC;
    RE : in STD_LOGIC;
    WClock : in STD_LOGIC;
    RClock : in STD_LOGIC);
end component;
component RAMBLOCK256X8
port (
    Q : out STD_LOGIC_VECTOR(7 downto 0);
    Data : in STD_LOGIC_VECTOR(7 downto 0);
    WAddress : in STD_LOGIC_VECTOR(7 downto 0);
    RAddress : in STD_LOGIC_VECTOR(7 downto 0);
    WE : in STD_LOGIC;
    RE : in STD_LOGIC;
    WClock : in STD_LOGIC;
    RClock : in STD_LOGIC);
end component;
component RAMBLOCK512X8
port (
    Q : out STD_LOGIC_VECTOR(7 downto 0);
    Data : in STD_LOGIC_VECTOR(7 downto 0);
    WAddress : in STD_LOGIC_VECTOR(8 downto 0);
    RAddress : in STD_LOGIC_VECTOR(8 downto 0);
    WE : in STD_LOGIC;
    RE : in STD_LOGIC;
    WClock : in STD_LOGIC;
    RClock : in STD_LOGIC);
end component;
component RAMBLOCK1024X8
port (
    Q : out STD_LOGIC_VECTOR(7 downto 0);
    Data : in STD_LOGIC_VECTOR(7 downto 0);
    WAddress : in STD_LOGIC_VECTOR(9 downto 0);
    RAddress : in STD_LOGIC_VECTOR(9 downto 0);
    WE : in STD_LOGIC;
    RE : in STD_LOGIC;
    WClock : in STD_LOGIC;
    RClock : in STD_LOGIC);
end component;
component RAMBLOCK2048X8
port (
    Q : out STD_LOGIC_VECTOR(7 downto 0);
    Data : in STD_LOGIC_VECTOR(7 downto 0);
    WAddress : in STD_LOGIC_VECTOR(10 downto 0);
    RAddress : in STD_LOGIC_VECTOR(10 downto 0);
    WE : in STD_LOGIC;
    RE : in STD_LOGIC;
    WClock : in STD_LOGIC;
    RClock : in STD_LOGIC);
end component;
component RAMBLOCK4096X8
port (
    Q : out STD_LOGIC_VECTOR(7 downto 0);
    Data : in STD_LOGIC_VECTOR(7 downto 0);
    WAddress : in STD_LOGIC_VECTOR(11 downto 0);
    RAddress : in STD_LOGIC_VECTOR(11 downto 0);
    WE : in STD_LOGIC;
    RE : in STD_LOGIC;
    WClock : in STD_LOGIC;
    RClock : in STD_LOGIC);
end component;
component RAMBLOCK64X16
port (
    Q : out STD_LOGIC_VECTOR(15 downto 0);
    Data : in STD_LOGIC_VECTOR(15 downto 0);
    WAddress : in STD_LOGIC_VECTOR(5 downto 0);
    RAddress : in STD_LOGIC_VECTOR(5 downto 0);
    WE : in STD_LOGIC;
    RE : in STD_LOGIC;
    WClock : in STD_LOGIC;
    RClock : in STD_LOGIC);
end component;
component RAMBLOCK128X16
port (
    Q : out STD_LOGIC_VECTOR(15 downto 0);
    Data : in STD_LOGIC_VECTOR(15 downto 0);
    WAddress : in STD_LOGIC_VECTOR(6 downto 0);
    RAddress : in STD_LOGIC_VECTOR(6 downto 0);
    WE : in STD_LOGIC;
    RE : in STD_LOGIC;
    WClock : in STD_LOGIC;
    RClock : in STD_LOGIC);
end component;
component RAMBLOCK256X16
port (
    Q : out STD_LOGIC_VECTOR(15 downto 0);
    Data : in STD_LOGIC_VECTOR(15 downto 0);
    WAddress : in STD_LOGIC_VECTOR(7 downto 0);
    RAddress : in STD_LOGIC_VECTOR(7 downto 0);
    WE : in STD_LOGIC;
    RE : in STD_LOGIC;
    WClock : in STD_LOGIC;
    RClock : in STD_LOGIC);
end component;
component RAMBLOCK512X16
port (
    Q : out STD_LOGIC_VECTOR(15 downto 0);
    Data : in STD_LOGIC_VECTOR(15 downto 0);
    WAddress : in STD_LOGIC_VECTOR(8 downto 0);
    RAddress : in STD_LOGIC_VECTOR(8 downto 0);
    WE : in STD_LOGIC;
    RE : in STD_LOGIC;
    WClock : in STD_LOGIC;
    RClock : in STD_LOGIC);
end component;
component RAMBLOCK1024X16
port (
    Q : out STD_LOGIC_VECTOR(15 downto 0);
    Data : in STD_LOGIC_VECTOR(15 downto 0);
    WAddress : in STD_LOGIC_VECTOR(9 downto 0);
    RAddress : in STD_LOGIC_VECTOR(9 downto 0);
    WE : in STD_LOGIC;
    RE : in STD_LOGIC;
    WClock : in STD_LOGIC;
    RClock : in STD_LOGIC);
end component;
component RAMBLOCK2048X16
port (
    Q : out STD_LOGIC_VECTOR(15 downto 0);
    Data : in STD_LOGIC_VECTOR(15 downto 0);
    WAddress : in STD_LOGIC_VECTOR(10 downto 0);
    RAddress : in STD_LOGIC_VECTOR(10 downto 0);
    WE : in STD_LOGIC;
    RE : in STD_LOGIC;
    WClock : in STD_LOGIC;
    RClock : in STD_LOGIC);
end component;
component RAMBLOCK4096X16
port (
    Q : out STD_LOGIC_VECTOR(15 downto 0);
    Data : in STD_LOGIC_VECTOR(15 downto 0);
    WAddress : in STD_LOGIC_VECTOR(11 downto 0);
    RAddress : in STD_LOGIC_VECTOR(11 downto 0);
    WE : in STD_LOGIC;
    RE : in STD_LOGIC;
    WClock : in STD_LOGIC;
    RClock : in STD_LOGIC);
end component;
component RAMBLOCK64X32
port (
    Q : out STD_LOGIC_VECTOR(31 downto 0);
    Data : in STD_LOGIC_VECTOR(31 downto 0);
    WAddress : in STD_LOGIC_VECTOR(5 downto 0);
    RAddress : in STD_LOGIC_VECTOR(5 downto 0);
    WE : in STD_LOGIC;
    RE : in STD_LOGIC;
    WClock : in STD_LOGIC;
    RClock : in STD_LOGIC);
end component;
component RAMBLOCK128X32
port (
    Q : out STD_LOGIC_VECTOR(31 downto 0);
    Data : in STD_LOGIC_VECTOR(31 downto 0);
    WAddress : in STD_LOGIC_VECTOR(6 downto 0);
    RAddress : in STD_LOGIC_VECTOR(6 downto 0);
    WE : in STD_LOGIC;
    RE : in STD_LOGIC;
    WClock : in STD_LOGIC;
    RClock : in STD_LOGIC);
end component;
component RAMBLOCK256X32
port (
    Q : out STD_LOGIC_VECTOR(31 downto 0);
    Data : in STD_LOGIC_VECTOR(31 downto 0);
    WAddress : in STD_LOGIC_VECTOR(7 downto 0);
    RAddress : in STD_LOGIC_VECTOR(7 downto 0);
    WE : in STD_LOGIC;
    RE : in STD_LOGIC;
    WClock : in STD_LOGIC;
    RClock : in STD_LOGIC);
end component;
component RAMBLOCK512X32
port (
    Q : out STD_LOGIC_VECTOR(31 downto 0);
    Data : in STD_LOGIC_VECTOR(31 downto 0);
    WAddress : in STD_LOGIC_VECTOR(8 downto 0);
    RAddress : in STD_LOGIC_VECTOR(8 downto 0);
    WE : in STD_LOGIC;
    RE : in STD_LOGIC;
    WClock : in STD_LOGIC;
    RClock : in STD_LOGIC);
end component;
component RAMBLOCK1024X32
port (
    Q : out STD_LOGIC_VECTOR(31 downto 0);
    Data : in STD_LOGIC_VECTOR(31 downto 0);
    WAddress : in STD_LOGIC_VECTOR(9 downto 0);
    RAddress : in STD_LOGIC_VECTOR(9 downto 0);
    WE : in STD_LOGIC;
    RE : in STD_LOGIC;
    WClock : in STD_LOGIC;
    RClock : in STD_LOGIC);
end component;
component RAMBLOCK2048X32
port (
    Q : out STD_LOGIC_VECTOR(31 downto 0);
    Data : in STD_LOGIC_VECTOR(31 downto 0);
    WAddress : in STD_LOGIC_VECTOR(10 downto 0);
    RAddress : in STD_LOGIC_VECTOR(10 downto 0);
    WE : in STD_LOGIC;
    RE : in STD_LOGIC;
    WClock : in STD_LOGIC;
    RClock : in STD_LOGIC);
end component;
component RAMBLOCK4096X32
port (
    Q : out STD_LOGIC_VECTOR(31 downto 0);
    Data : in STD_LOGIC_VECTOR(31 downto 0);
    WAddress : in STD_LOGIC_VECTOR(11 downto 0);
    RAddress : in STD_LOGIC_VECTOR(11 downto 0);
    WE : in STD_LOGIC;
    RE : in STD_LOGIC;
    WClock : in STD_LOGIC;
    RClock : in STD_LOGIC);
end component;

subtype RAMWORD    is std_logic_vector (DWIDTH-1 downto 0);
type RAMWORD_ARRAY is array ( INTEGER range <>) of RAMWORD;

-- Verification testbench requires that RAM starts of at zero an not X's

signal READEN   : STD_LOGIC;
signal WRITEEN  : STD_LOGIC;
signal RAM :  RAMWORD_ARRAY(0 to 2**AWIDTH) := (others => ( others => '0'));

--------------------------------------------------------------------------------------

begin
	
	
URTL: if FAMILY=0 generate
	
  process(clkw)
  variable addr : integer range 0 to 2**AWIDTH-1;
  begin
    if clkw='1' and clkw'event then
      if (we='1') then
  	    addr := to_integer(to_unsigned(WADDR));
  	    RAM(addr) <= WDATA;
  	  end if;  
    end if;
  end process;

  process(clkr)
  variable addr : integer range 0 to 2**AWIDTH-1;
  begin
    if clkr='1' and clkr'event then
  	  addr := to_integer(to_unsigned(RADDR));
  	  RDATA <= RAM(addr);
    end if;
  end process;

end generate;	
	
--------------------------------------------------------------------------------------
-- Sort out the RAM RE/WE polarities
--  is now taken care of in the ramblocks_apa file

WRITEEN <= WE;
READEN  <= '1';

--------------------------------------------------------------------------------------

U_RAMBLOCK64X8: if FAMILY>0 and DWIDTH = 8 and AWIDTH = 6 generate
UU_RAMBLOCK64X8: RAMBLOCK64X8
port map(
    Q => rdata ,
    Data => wdata ,
    WAddress => waddr ,
    RAddress => raddr ,
    WE => WRITEEN ,
    RE => READEN ,
    WClock => clkw ,
    RClock => clkr );
end generate;

U_RAMBLOCK128X8: if FAMILY>0 and DWIDTH = 8 and AWIDTH = 7 generate
UU_RAMBLOCK128X8: RAMBLOCK128X8
port map(
    Q => rdata ,
    Data => wdata ,
    WAddress => waddr ,
    RAddress => raddr ,
    WE => WRITEEN ,
    RE => READEN ,
    WClock => clkw ,
    RClock => clkr );
end generate;

U_RAMBLOCK256X8: if FAMILY>0 and DWIDTH = 8 and AWIDTH = 8 generate
UU_RAMBLOCK256X8: RAMBLOCK256X8
port map(
    Q => rdata ,
    Data => wdata ,
    WAddress => waddr ,
    RAddress => raddr ,
    WE => WRITEEN ,
    RE => READEN ,
    WClock => clkw ,
    RClock => clkr );
end generate;

U_RAMBLOCK512X8: if FAMILY>0 and DWIDTH = 8 and AWIDTH = 9 generate
UU_RAMBLOCK512X8: RAMBLOCK512X8
port map(
    Q => rdata ,
    Data => wdata ,
    WAddress => waddr ,
    RAddress => raddr ,
    WE => WRITEEN ,
    RE => READEN ,
    WClock => clkw ,
    RClock => clkr );
end generate;

U_RAMBLOCK1024X8: if FAMILY>0 and DWIDTH = 8 and AWIDTH = 10 generate
UU_RAMBLOCK1024X8: RAMBLOCK1024X8
port map(
    Q => rdata ,
    Data => wdata ,
    WAddress => waddr ,
    RAddress => raddr ,
    WE => WRITEEN ,
    RE => READEN ,
    WClock => clkw ,
    RClock => clkr );
end generate;

U_RAMBLOCK2048X8: if FAMILY>0 and DWIDTH = 8 and AWIDTH = 11 generate
UU_RAMBLOCK2048X8: RAMBLOCK2048X8
port map(
    Q => rdata ,
    Data => wdata ,
    WAddress => waddr ,
    RAddress => raddr ,
    WE => WRITEEN ,
    RE => READEN ,
    WClock => clkw ,
    RClock => clkr );
end generate;

U_RAMBLOCK4096X8: if FAMILY>0 and DWIDTH = 8 and AWIDTH = 12 generate
UU_RAMBLOCK4096X8: RAMBLOCK4096X8
port map(
    Q => rdata ,
    Data => wdata ,
    WAddress => waddr ,
    RAddress => raddr ,
    WE => WRITEEN ,
    RE => READEN ,
    WClock => clkw ,
    RClock => clkr );
end generate;

U_RAMBLOCK64X16: if FAMILY>0 and DWIDTH = 16 and AWIDTH = 6 generate
UU_RAMBLOCK64X16: RAMBLOCK64X16
port map(
    Q => rdata ,
    Data => wdata ,
    WAddress => waddr ,
    RAddress => raddr ,
    WE => WRITEEN ,
    RE => READEN ,
    WClock => clkw ,
    RClock => clkr );
end generate;

U_RAMBLOCK128X16: if FAMILY>0 and DWIDTH = 16 and AWIDTH = 7 generate
UU_RAMBLOCK128X16: RAMBLOCK128X16
port map(
    Q => rdata ,
    Data => wdata ,
    WAddress => waddr ,
    RAddress => raddr ,
    WE => WRITEEN ,
    RE => READEN ,
    WClock => clkw ,
    RClock => clkr );
end generate;

U_RAMBLOCK256X16: if FAMILY>0 and DWIDTH = 16 and AWIDTH = 8 generate
UU_RAMBLOCK256X16: RAMBLOCK256X16
port map(
    Q => rdata ,
    Data => wdata ,
    WAddress => waddr ,
    RAddress => raddr ,
    WE => WRITEEN ,
    RE => READEN ,
    WClock => clkw ,
    RClock => clkr );
end generate;

U_RAMBLOCK512X16: if FAMILY>0 and DWIDTH = 16 and AWIDTH = 9 generate
UU_RAMBLOCK512X16: RAMBLOCK512X16
port map(
    Q => rdata ,
    Data => wdata ,
    WAddress => waddr ,
    RAddress => raddr ,
    WE => WRITEEN ,
    RE => READEN ,
    WClock => clkw ,
    RClock => clkr );
end generate;

U_RAMBLOCK1024X16: if FAMILY>0 and DWIDTH = 16 and AWIDTH = 10 generate
UU_RAMBLOCK1024X16: RAMBLOCK1024X16
port map(
    Q => rdata ,
    Data => wdata ,
    WAddress => waddr ,
    RAddress => raddr ,
    WE => WRITEEN ,
    RE => READEN ,
    WClock => clkw ,
    RClock => clkr );
end generate;

U_RAMBLOCK2048X16: if FAMILY>0 and DWIDTH = 16 and AWIDTH = 11 generate
UU_RAMBLOCK2048X16: RAMBLOCK2048X16
port map(
    Q => rdata ,
    Data => wdata ,
    WAddress => waddr ,
    RAddress => raddr ,
    WE => WRITEEN ,
    RE => READEN ,
    WClock => clkw ,
    RClock => clkr );
end generate;

U_RAMBLOCK4096X16: if FAMILY>0 and DWIDTH = 16 and AWIDTH = 12 generate
UU_RAMBLOCK4096X16: RAMBLOCK4096X16
port map(
    Q => rdata ,
    Data => wdata ,
    WAddress => waddr ,
    RAddress => raddr ,
    WE => WRITEEN ,
    RE => READEN ,
    WClock => clkw ,
    RClock => clkr );
end generate;

U_RAMBLOCK64X32: if FAMILY>0 and DWIDTH = 32 and AWIDTH = 6 generate
UU_RAMBLOCK64X32: RAMBLOCK64X32
port map(
    Q => rdata ,
    Data => wdata ,
    WAddress => waddr ,
    RAddress => raddr ,
    WE => WRITEEN ,
    RE => READEN ,
    WClock => clkw ,
    RClock => clkr );
end generate;

U_RAMBLOCK128X32: if FAMILY>0 and DWIDTH = 32 and AWIDTH = 7 generate
UU_RAMBLOCK128X32: RAMBLOCK128X32
port map(
    Q => rdata ,
    Data => wdata ,
    WAddress => waddr ,
    RAddress => raddr ,
    WE => WRITEEN ,
    RE => READEN ,
    WClock => clkw ,
    RClock => clkr );
end generate;

U_RAMBLOCK256X32: if FAMILY>0 and DWIDTH = 32 and AWIDTH = 8 generate
UU_RAMBLOCK256X32: RAMBLOCK256X32
port map(
    Q => rdata ,
    Data => wdata ,
    WAddress => waddr ,
    RAddress => raddr ,
    WE => WRITEEN ,
    RE => READEN ,
    WClock => clkw ,
    RClock => clkr );
end generate;

U_RAMBLOCK512X32: if FAMILY>0 and DWIDTH = 32 and AWIDTH = 9 generate
UU_RAMBLOCK512X32: RAMBLOCK512X32
port map(
    Q => rdata ,
    Data => wdata ,
    WAddress => waddr ,
    RAddress => raddr ,
    WE => WRITEEN ,
    RE => READEN ,
    WClock => clkw ,
    RClock => clkr );
end generate;

U_RAMBLOCK1024X32: if FAMILY>0 and DWIDTH = 32 and AWIDTH = 10 generate
UU_RAMBLOCK1024X32: RAMBLOCK1024X32
port map(
    Q => rdata ,
    Data => wdata ,
    WAddress => waddr ,
    RAddress => raddr ,
    WE => WRITEEN ,
    RE => READEN ,
    WClock => clkw ,
    RClock => clkr );
end generate;

U_RAMBLOCK2048X32: if FAMILY>0 and DWIDTH = 32 and AWIDTH = 11 generate
UU_RAMBLOCK2048X32: RAMBLOCK2048X32
port map(
    Q => rdata ,
    Data => wdata ,
    WAddress => waddr ,
    RAddress => raddr ,
    WE => WRITEEN ,
    RE => READEN ,
    WClock => clkw ,
    RClock => clkr );
end generate;

U_RAMBLOCK4096X32: if FAMILY>0 and DWIDTH = 32 and AWIDTH = 12 generate
UU_RAMBLOCK4096X32: RAMBLOCK4096X32
port map(
    Q => rdata ,
    Data => wdata ,
    WAddress => waddr ,
    RAddress => raddr ,
    WE => WRITEEN ,
    RE => READEN ,
    WClock => clkw ,
    RClock => clkr );
end generate;

end RTL;
