-- *********************************************************************/ 
-- Copyright 2013 Microsemi Corporation.  All rights reserved.
-- IP Solutions Group
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED 
-- IN ADVANCE IN WRITING.  
--  
-- File:  bd.vhd
--     
-- Description: Core10100
--              Core - Transmit for half duplex  
--
-- SVN Revision Information:
-- SVN $Revision: 6737 $
-- SVN $Date: 2009-02-20 23:42:36 +0530 (Fri, 20 Feb 2009) $  
--   
--
-- Notes: 
--		  
--
-- *********************************************************************/ 
--



--*******************************************************************--
-- Copyright (c) 2001-2003  Actel Corp.                             --
--*******************************************************************--
-- Please review the terms of the license agreement before using     --
-- this file. If you are not an authorized user, please destroy this --
-- source code file and notify Actel Corp. immediately that you     --
-- inadvertently received an unauthorized copy.                      --
--*******************************************************************--

-----------------------------------------------------------------------
-- Project name         : MAC
-- Project description  : Ethernet Media Access Controller
--
-- File name            : bd.vhd
-- File contents        : Entity BD
--                        Architecture RTL of BD
-- Purpose              : Transmit procedures for half duplex operation
--
-- Destination library  : work
-- Dependencies         : work.UTILITY
--                        IEEE.STD_LOGIC_1164
--                        IEEE.STD_LOGIC_UNSIGNED
--
-- Design Engineer      : T.K.
-- Quality Engineer     : M.B.
-- Version              : 2.00.E08
-- Last modification    : 2004-06-07
-----------------------------------------------------------------------

--*******************************************************************--
-- Modifications with respect to Version 2.00.E00:
-- 2.00.E01   :
-- 2003.03.21 : T.K. - MIIWIDTH generic removed
-- 2003.03.21 : T.K. - support for frame bursting removed
-- 2.00.E02   :
-- 2003.04.15 : T.K  - synchronous processes merged
-- 2.00.E06   : 
-- 2004.01.20 : T.K  - transmition status bug fixed (F200.05.tx_status) :
--                      * crs_reg_proc process modified
--
-- 2004.01.20 : B.W. - RTL code changes due to VN Check
--                     and code coverage (I200.06.vn):
--                      * bkrel_proc process modified
-- 2.00.E07   :
-- 2004.03.22 : L.C. - fixed backoff algorithm (F200.06.backoff)
--                      * crc port width modified
--                      * rand signal width modified
--                      * rand_reg_proc process changed
--                      * slcnt_reg_proc process changed
-- 2004.03.22 : T.K. - Fixed collision functionality (F200.06.retry).
--                      * ilc signal added
--                      * bkcnt_reg_proc process changed
--                      * ibkoff_reg_proc process changed
--                      * col_reg_proc process changed
--                      * lc_drv assignment added
-- 2.00.E08   :
-- 2004.06.07 : T.K. - modified backoff algorithm (F200.08.backoff)
--                      * crc port removed
--                      * tprogf_c and tprog_r signals removed
--                      * tprog_reg_proc process removed
--                      * tprogf_drv assignment removed
--                      * rand_reg_proc process changed
--*******************************************************************--

library IEEE;
  use work.utility.all;
  use ieee.std_logic_1164.all; 
  use IEEE.STD_LOGIC_UNSIGNED."-";
  use IEEE.STD_LOGIC_UNSIGNED."+";



  --*****************************************************************--
  
  entity BD is
    port (    
            ------------------------- common --------------------------
            -- transmit clock
            clk       : in  STD_LOGIC;
            -- reset
            rst       : in  STD_LOGIC;
            
            ---------------------- mii interface ----------------------
            -- mii collision
            col       : in  STD_LOGIC;
            -- mii carrier sense
            crs       : in  STD_LOGIC;
            
            -------------------- csr configuration --------------------
            -- full duplex mode
            fdp       : in  STD_LOGIC;
            
            ---------------------- transmit status --------------------
            -- transmit in progress
            tprog     : in  STD_LOGIC;
            -- preamble transmission in progress
            preamble  : in  STD_LOGIC;
            -- transmit pending
            tpend     : in  STD_LOGIC;
            -- collision window passed
            winp      : out STD_LOGIC;
            -- transmit interrupt acknowledge
            tiack     : in  STD_LOGIC;
            -- collision detected
            coll      : out STD_LOGIC;
            -- carrier sense
            carrier   : out STD_LOGIC;
            -- backoff in progress
            bkoff     : out STD_LOGIC;
            -- late collission
            lc        : out STD_LOGIC;
            -- loss of carrier
            lo        : out STD_LOGIC;
            -- no carrier
            nc        : out STD_LOGIC;
            -- excessive collisions
            ec        : out STD_LOGIC;
            -- collision counter
            cc        : out STD_LOGIC_VECTOR(3 downto 0)
    );
  end BD;
  
--*******************************************************************--
architecture RTL of BD is
  
  ---------------------------- deferring ------------------------------
  -- mii carrier sense registered
  signal crs_r       : STD_LOGIC;
  -- internal no carrier registered
  signal inc         : STD_LOGIC;
  
  
  ------------------------------ backoff ------------------------------
  -- internal backoff in progress registered
  signal ibkoff      : STD_LOGIC;
  -- internal backoff in progress double registered
  signal ibkoff_r    : STD_LOGIC;
  -- collision indication registered
  signal icoll       : STD_LOGIC;
  -- late collision
  signal ilc         : STD_LOGIC;
  -- collision counter registered
  signal ccnt        : STD_LOGIC_VECTOR(3 downto 0);
  -- backoff counter registered
  signal bkcnt       : STD_LOGIC_VECTOR(9 downto 0);
  -- slot counter registered
  signal slcnt       : STD_LOGIC_VECTOR(8 downto 0);
  -- backoff counter reload value combinatorial
  signal bkrel_c     : STD_LOGIC_VECTOR(9 downto 0);
  -- pseudo-random number generator registered
  signal rand        : STD_LOGIC_VECTOR(30 downto 0);
  -- collision window passed registered
  signal iwinp       : STD_LOGIC;
  

begin
          
          
--===================================================================--
--                            deferring                              --
--===================================================================--

  ---------------------------------------------------------------------
  -- carrier sense registered
  ---------------------------------------------------------------------
  crs_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        crs_r <= '0';
        lo    <= '0';
        inc   <= '0';
    elsif clk'event and clk='1' then

        -- carrier sense
        if fdp='1' then
          crs_r <= '0';
        else
          crs_r <= crs;
        end if;
        
        -- loss of carrier
        if tprog='1' and inc='0' and crs_r='0' then
          lo <= '1';
        elsif tpend='0' and tprog='0' then
          lo <= '0';
        end if;
        
        -- no carrier
        if tprog='1' and crs_r='1' then
          inc <= '0';
        elsif tpend='0' and tprog='0' then
          inc <= '1';
        end if;
    end if;
  end process; -- crs_reg_proc
  

  ---------------------------------------------------------------------
  -- no carrier
  -- registered output
  ---------------------------------------------------------------------
  nc_drv:
    nc <= inc;
    
    
--===================================================================--
--                               BACKOFF                             --
--===================================================================--
  
  ---------------------------------------------------------------------
  -- backoff preset value combinatorial
  ---------------------------------------------------------------------
  bkrel_proc:
  process(ccnt, rand)
  begin
    bkrel_c <= rand(9 downto 0);
    case ccnt is
      when "0000" => bkrel_c <= "000000000" & rand(0);
      when "0001" => bkrel_c <= "00000000" & rand(1 downto 0);
      when "0010" => bkrel_c <= "0000000" & rand(2 downto 0);
      when "0011" => bkrel_c <= "000000" & rand(3 downto 0);
      when "0100" => bkrel_c <= "00000" & rand(4 downto 0);
      when "0101" => bkrel_c <= "0000" & rand(5 downto 0);
      when "0110" => bkrel_c <= "000" & rand(6 downto 0);
      when "0111" => bkrel_c <= "00" & rand(7 downto 0);
      when "1000" => bkrel_c <= "0" & rand(8 downto 0);
      when others => null;
    end case;
  end process; -- bkrel_proc
  
  ---------------------------------------------------------------------
  -- slot counter registered
  ---------------------------------------------------------------------  
  slcnt_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        slcnt <= (others=>'1');
    elsif clk'event and clk='1' then
        if tprog='1' and preamble='0' and icoll='0' then
          if slcnt/="000000000" then
            slcnt <= slcnt-1;
          end if;
        elsif ibkoff='1' then
          if slcnt="000000000" or icoll='1' then
            slcnt <= SLOT_TIME;
          else
            slcnt <= slcnt-1;
          end if;
        else
          slcnt <= SLOT_TIME;
        end if;
    end if;
  end process; -- slcnt_reg_proc
  
  ---------------------------------------------------------------------
  -- backoff counter registered
  ---------------------------------------------------------------------  
  bkcnt_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        bkcnt <= (others=>'1');
    elsif clk'event and clk='1' then
        if icoll='1' and ibkoff='0' then
          bkcnt <= bkrel_c;
        elsif slcnt="000000000" then
          bkcnt <= bkcnt-1;
        end if;
    end if;
  end process; -- bkcnt_reg_proc
  
  ---------------------------------------------------------------------
  -- random number generator registered
  ---------------------------------------------------------------------
  rand_reg_proc:

process(clk,rst)
  variable i : INTEGER;  -- loop index
  begin
    if rst = '0' then
        rand <= (others=>'1');
    elsif clk'event and clk='1' then
          for i in 30 downto 1 loop
            rand(i) <= rand(i-1);
          end loop;
          rand(0)  <= rand(30) xor rand(28);
    end if;
  end process; -- rand_reg_proc
  
  ---------------------------------------------------------------------
  -- internal backoff indicator registered
  ---------------------------------------------------------------------
  ibkoff_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        ibkoff   <= '0';
        ibkoff_r <= '0';
    elsif clk'event and clk='1' then

        ibkoff_r <= ibkoff;
        if icoll='1' and ccnt/="1111" and iwinp='0' and ilc='0'
        then
          ibkoff <= '1';
        elsif bkcnt="0000000000" then
          ibkoff <= '0';
        end if;
    end if;
  end process; -- ibkoff_reg_proc
  
  ---------------------------------------------------------------------
  -- collision detected registered
  ---------------------------------------------------------------------
  coll_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        icoll <= '0';
        ilc   <= '0';
        ec    <= '0';
        iwinp <= '1';
        ccnt <= (others=>'0');
    elsif clk'event and clk='1' then

    
        -- collision detected
        if (preamble='1' or tprog='1') and col='1' and fdp='0' then
          icoll <= '1';
        elsif tprog='0' and preamble='0' then
          icoll <= '0';
        end if;
        
        -- late collision
        if tiack='1' then
          ilc <= '0';
        elsif tprog='1' and icoll='1' and iwinp='1' then
          ilc <= '1';
        end if;
        
        -- excessive collisions
        if tiack='1' then
          ec <= '0';
        elsif icoll='1' and ccnt="1111" and tprog='1' then
          ec <= '1';
        end if;
        
        -- collision window passed
        if slcnt="000000000" or tprog='0' then
          iwinp <= '1';
        else
          iwinp <= '0';
        end if;
        
        -- collision counter
        if (tpend='0' and tprog='0') then
          ccnt <= "0000";
        elsif ibkoff='1' and ibkoff_r='0' then
          ccnt <= ccnt+1;
        end if;
    end if;
  end process; -- coll_reg_proc
  ---------------------------------------------------------------------
  -- late collision
  -- registered output
  ---------------------------------------------------------------------
  lc_drv:
  	lc <= ilc;

  ---------------------------------------------------------------------
  -- collision window passed
  -- registered output
  ---------------------------------------------------------------------
  winp_drv:
    winp <= iwinp;
  
  ---------------------------------------------------------------------
  -- carrier sense
  -- registered output
  ---------------------------------------------------------------------
  carrier_drv:
    carrier <= crs_r;
  
  ---------------------------------------------------------------------
  -- collision detected
  -- registered output
  ---------------------------------------------------------------------
  coll_drv:
    coll <= icoll;
  
  ---------------------------------------------------------------------
  -- backoff in progress
  -- registered output
  ---------------------------------------------------------------------
  bkoff_drv:
    bkoff <= ibkoff;
  
  ---------------------------------------------------------------------
  -- collision count
  -- registered output
  ---------------------------------------------------------------------
  cc_drv:
    cc <= ccnt;
  
end RTL;
--*******************************************************************--
