-- ********************************************************************/ 
-- Copyright 2013 Actel Corporation.  All rights reserved.
-- IP Solutions Group
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED 
-- IN ADVANCE IN WRITING.  
--  
-- File:  tc.vhd
--     
-- Description: Core10100
--              See below  
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
-- File name            : tc.vhd
-- File contents        : Entity TC
--                        Architecture RTL of TC
-- Purpose              : Transmit Controller for MAC
--
-- Destination library  : work
-- Dependencies         : work.UTILITY
--                        IEEE.STD_LOGIC_1164
--                        IEEE.STD_LOGIC_UNSIGNED
--
-- Design Engineer      : T.K.
-- Quality Engineer     : M.B.
-- Version              : 2.00.E07a
-- Last modification    : 2004-03-26
-----------------------------------------------------------------------

--*******************************************************************--
-- Modifications with respect to Version 2.00.E00:
-- 2.00.E01   :
-- 2003.03.21 : T.K. - MIIWIDTH generic removed
-- 2003.03.21 : T.K. - references to 64-bit wide data bus removed
-- 2003.03.21 : T.K. - references to flow control removed
-- 2003.03.21 : T.K. - txer is now stuck at '0'
-- 2.00.E02   :
-- 2003.04.15 : T.K. - synchronous processes merged
-- 2.00.E03   :
-- 2003.05.12 : T.K. - stop_r signal added
-- 2003.05.12 : T.K. - tsm_proc: condition for TSM_IDLE changed
-- 2.00.E05   :
-- 2003.08.10 : H.C. - eofreq_r2 redundant signal removed
-- 2.00.E06   :  
-- 2004.01.20 : B.W. - fixed transmit frame descriptor status
--                     assignment(F200.05.tx_status)
--                      * de_reg_proc process changed
--
-- 2004.01.20 : B.W. - fixed retransmission error (F200.05.rettx)
--                      * tstate_reg_proc process changed
--
-- 2004.01.20 : B.W. - RTL code chandes due to VN Check
--                     and code coverage (I200.06.vn) :
--                      * empty_proc process changed
--                      * re_proc process changed
--                      * bset_reg_proc process changed
--                      * nset_proc process changed
--                      * crc_proc process changed
--                      * datamux_proc process changed
-- 2.00.E07   :
-- 2004.03.22 : L.C. - fixed backoff algorithm (F200.06.backoff)
--                      * crco port width changed
--                      * crco_drv assignment changed
-- 2004.03.22 : T.K. - fixed collision during SFD (F200.06.col)
--                      * bcnt_reg_proc process changed
-- 2004.03.22 : T.K. - fixed collision functionality (F200.06.retry)
--                      * tstate_reg_proc process changed
-- 2.00.E08   :
-- 2004.06.07 : T.K. - modified backoff algorithm (F200.08.backoff)
--                      * crco port removed
--                      * crco_drv assignment removed
--*******************************************************************--

library IEEE;
  use work.utility.all;
  use ieee.std_logic_1164.all; 
  use IEEE.STD_LOGIC_UNSIGNED."-";
  use IEEE.STD_LOGIC_UNSIGNED."+";



  --*****************************************************************--
  entity TC is
    generic (
              -- Depth of the FIFO memory
              FIFODEPTH : INTEGER := 9;
              -- Depth of the internal data path
              DATAWIDTH : INTEGER := 32 -- 8|16|32
    );
    port (    
              -------------------- common signals ---------------------
              -- transmit clock
              clk       : in  STD_LOGIC;
              -- reset
              rst       : in  STD_LOGIC;
              
              ------------------------- mii ---------------------------
              -- mii transmit data valid
              txen      : out STD_LOGIC;
              -- mii transmit error
              txer      : out STD_LOGIC;
              -- mii transmit data
              txd       : out STD_LOGIC_VECTOR(3 downto 0);
              
              ----------------------- DP RAM --------------------------
              -- transmit ram data
              ramdata   : in  STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
              -- transmit ram address
              ramaddr   : out STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
              
              -------------------- FIFO control -----------------------
              -- fifo write address grey coded
              wadg    : in  STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
              -- fifo read address grey coded
              radg    : out STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
              
              ------------------- transmit control --------------------
              -- disabled padding
              dpd       : in  STD_LOGIC;
              -- add crc disable
              ac        : in  STD_LOGIC;
              -- start of frame request
              sofreq    : in  STD_LOGIC;
              -- end of frame request
              eofreq    : in  STD_LOGIC;
              -- interrupt acknowledge
              tiack     : in  STD_LOGIC;
              -- last byte enable
              lastbe    : in  STD_LOGIC_VECTOR(DATAWIDTH/8-1 downto 0);
              -- end of frame address grey coded
              eofadg    : in  STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
              -- interrupt request
              tireq     : out STD_LOGIC;
              -- fifo underrun
              ur        : out STD_LOGIC;
              -- deferred
              de        : out STD_LOGIC;
              
              ------------------ half duplex procedures ---------------
              -- collision detected
              coll      : in  STD_LOGIC;
              -- deferring in progress
              carrier   : in  STD_LOGIC;
              -- backoff in progress
              bkoff     : in  STD_LOGIC;
              -- transmission pending
              tpend     : out STD_LOGIC;
              -- transmission in progress
              tprog     : out STD_LOGIC;
              -- preamble transmission in progress
              preamble  : out STD_LOGIC;
              
              ---------------------- power management -----------------
              -- stop input
              stopi     : in  STD_LOGIC;
              -- stop output
              stopo     : out STD_LOGIC;
              
              ------------------------- timers ------------------------
              -- cycle size acknowledge
              tcsack    : in  STD_LOGIC;
              -- cycle size request
              tcsreq    : out STD_LOGIC
    );
  end TC;
  
--*******************************************************************--
architecture RTL of TC is

  ------------------------------ fifo ---------------------------------
  -- fifo read enable combinatorial
  signal re_c        : STD_LOGIC;
  -- fifo read enable registered
  signal re          : STD_LOGIC;
  -- fifo empty combinatorial
  signal empty_c     : STD_LOGIC;
  -- fifo empty registered
  signal empty       : STD_LOGIC;
  -- fifo read address registered
  signal rad_r       : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- fifo read address double registered
  signal rad         : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- fifo read address grey coded registered
  signal iradg       : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- fifo write address grey coded registered
  signal iwadg       : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- fifo write address combinatorial
  signal iwad_c      : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- fifo write address registered
  signal iwad        : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- fifo start of frame address registered
  signal sofad       : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- fifo end of frame address grey coded registered
  signal eofadg_r    : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- start of frame request registered
  signal sofreq_r    : STD_LOGIC;
  -- end of frame request registered
  signal eofreq_r    : STD_LOGIC;
  signal eofreq_r1    : STD_LOGIC;
    -- end of frame request double registered
  -- whole frame in fifo registered
  signal whole       : STD_LOGIC;
  -- end of frame registered
  signal eof         : STD_LOGIC;
  -- ram data registered
  signal ramdata_r   : STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
  
  
  ------------------------------- mii ---------------------------------
  -- mii transmit data phase 0 registered
  signal itxd0       : STD_LOGIC_VECTOR(3 downto 0);
  -- predefined frame fields multiplexor registered
  signal pmux        : STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
  -- transmit data multiplexor
  signal datamux_c   : STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
  -- transmit data multiplexor max
  signal datamux_c_max : STD_LOGIC_VECTOR(DATAWIDTH_MAX downto 0);
  -- transmit enable 1 registered
  signal txen1       : STD_LOGIC;
  
  
  ------------------------------ frame --------------------------------
  -- frame sequencer state machine combinatorial
  signal tsm_c       : TCSMT;
  -- frame sequencer state machine registered
  signal tsm         : TCSMT;
  -- nibble counter set registered
  signal nset        : STD_LOGIC;
  -- nibble counter
  signal ncnt        : STD_LOGIC_VECTOR(3 downto 0);
  -- nibble counter 1 downto 0
  signal ncnt10      : STD_LOGIC_VECTOR(1 downto 0);
  -- nibble counter 2 downto 0
  signal ncnt20      : STD_LOGIC_VECTOR(2 downto 0);
  -- byte counter reload value registered
  signal brel        : STD_LOGIC_VECTOR(6 downto 0);
  -- byte counter set registered
  signal bset        : STD_LOGIC;
  -- byte counter registered
  signal bcnt        : STD_LOGIC_VECTOR(6 downto 0);
  -- byte counter = 0 combinatorial
  signal bz          : STD_LOGIC;
  -- no padding registered
  signal nopad       : STD_LOGIC;
  -- crc generating registered
  signal crcgen      : STD_LOGIC;
  -- crc transmission registered
  signal crcsend     : STD_LOGIC;
  -- crc remainder combinatorial
  signal crc_c       : STD_LOGIC_VECTOR(31 downto 0);
  -- crc remainder registered
  signal crc         : STD_LOGIC_VECTOR(31 downto 0);
  -- crc remainder inverted combinatorial
  signal crcneg_c    : STD_LOGIC_VECTOR(31 downto 0);
  -- transmit in progress registered
  signal itprog      : STD_LOGIC;
  -- transmit pending registered
  signal itpend      : STD_LOGIC;
  -- fifo underrun registered
  signal iur         : STD_LOGIC;
  -- interrupt request registered
  signal iti         : STD_LOGIC;
  -- interrupt acknowledge registered
  signal tiack_r     : STD_LOGIC;
  -- interframe space counter registered
  signal ifscnt      : STD_LOGIC_VECTOR(3 downto 0);
  
  ----------------------------- timers --------------------------------
  -- cycle size acknowledge registered
  signal tcsack_r    : STD_LOGIC;
  -- cycle size counter
  signal tcscnt      : STD_LOGIC_VECTOR(7 downto 0);
  -- cycle size request
  signal tcs         : STD_LOGIC;
  
  ------------------------- interframe spacing ------------------------
  -- interframe space period 1 in progress
  signal ifs1p       : STD_LOGIC;
  -- interframe space period 2 in progress
  signal ifs2p       : STD_LOGIC;
  -- deferring in progress
  signal defer       : STD_LOGIC;
  
  ----------------------------- backoff -------------------------------
  -- backoff registered
  signal bkoff_r     : STD_LOGIC;
  
  ------------------------------ others -------------------------------
  -- stop input registered
  signal stop_r      : STD_LOGIC;
  -- highest nibble (predefined value)
  signal hnibble     : STD_LOGIC_VECTOR(3 downto 0);
  -- zero vactor max
  signal dzero_max   : STD_LOGIC_VECTOR(DATAWIDTH_MAX downto 0);
  signal coll_r      : STD_LOGIC;

begin

--===================================================================--
--                                fifo                               --
--===================================================================--
  
  ---------------------------------------------------------------------
  -- fifo address registered
  ---------------------------------------------------------------------
  faddr_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        rad      <= (others=>'0');
        rad_r    <= (others=>'0');
        iradg    <= (others=>'0');
        sofad    <= (others=>'0');
        eofadg_r <= (others=>'0');
        iwad     <= (others=>'0');
        iwadg    <= (others=>'0');
    elsif clk'event and clk='1' then

      
        -- fifo read address
        if bkoff_r='1' then
          rad <= sofad;
        elsif re_c='1' then
          rad <= rad+1;
        elsif eof='1' and tsm=TSM_FLUSH then
          rad <= iwad;
        end if;
        
        -- fifo read address double registered
        rad_r <= rad;
        
        -- fifo read address grey coded
        iradg <= rad xor '0' & rad(FIFODEPTH-1 downto 1);
        
        -- start of frame address
        if tsm=TSM_IDLE then
          sofad <= rad_r;
        end if;
        
        -- end of frame address grey coded
        if eofreq_r='1' then
          eofadg_r <= eofadg;
        end if;
        
        -- fifo write addresses binary
        iwad <= iwad_c;
        
        -- fifo write address grey coded
        if eofreq_r1='1' then
          iwadg <= eofadg_r;
        else
          iwadg <= wadg;
        end if;
    end if;
  end process; -- faddr_reg_proc
  
  ---------------------------------------------------------------------
  -- fifo write address binary combinatorial
  ---------------------------------------------------------------------
  iwad_proc:
  process(iwadg)
    variable wad_v : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  begin
    wad_v(FIFODEPTH-1) := iwadg(FIFODEPTH-1);
    for i in FIFODEPTH-2 downto 0 loop
      wad_v(i) := wad_v(i+1) xor iwadg(i);
    end loop;
    iwad_c <= wad_v;
  end process; -- iwad_proc
  
  ---------------------------------------------------------------------
  -- fifo empty combinatorial
  ---------------------------------------------------------------------
  empty_proc:
  process(rad, iwad)
  begin
    empty_c <= '0';
    if rad=iwad then
      empty_c <= '1';
    end if;
  end process; -- empty_proc
  
  ---------------------------------------------------------------------
  -- fifo empty registered
  ---------------------------------------------------------------------
  empty_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        empty <= '1';
    elsif clk'event and clk='1' then

        empty <= empty_c;
    end if;
  end process; -- empty_reg_proc
  
  ---------------------------------------------------------------------
  --  fifo read enable combinatorial
  ---------------------------------------------------------------------
  re_proc:
  process(tsm, empty_c, ncnt)
  begin
    re_c <= '0';
    if (tsm=TSM_INFO or tsm=TSM_SFD or tsm=TSM_FLUSH) and
     empty_c='0' and
     (
       (DATAWIDTH=8 and ncnt(0)='0') or
       (DATAWIDTH=16 and ncnt(1 downto 0)="10") or
       (DATAWIDTH=32 and ncnt(2 downto 0)="110")
     )
    then
      re_c <= '1';
    end if;
  end process; -- re_reg_proc

  ---------------------------------------------------------------------
  --  fifo read enable registered
  ---------------------------------------------------------------------
  re_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        re <= '0';
    elsif clk'event and clk='1' then

        re <= re_c;
    end if;
  end process; -- re_reg_proc
  
  ---------------------------------------------------------------------
  -- ram address
  -- registered output
  ---------------------------------------------------------------------
  ramaddr_drv:
    ramaddr <= rad;
  
  ---------------------------------------------------------------------
  -- fifo read address
  -- registered output
  ---------------------------------------------------------------------
  radg_drv:
    radg <= iradg;



--===================================================================--
--                          transmit control                         --
--===================================================================--
  
  ---------------------------------------------------------------------
  -- end of frame registered
  ---------------------------------------------------------------------
  whole_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        whole <= '0';
    elsif clk'event and clk='1' then

        if iti='1' then
          whole <= '0';
        elsif eofreq_r='1' then
          whole <= '1';
        end if;
    end if;
  end process; -- whole_reg_proc
  
  ---------------------------------------------------------------------
  -- start/end of frame registered
  ---------------------------------------------------------------------
  se_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        sofreq_r <= '0';
        eofreq_r <= '0';
        eofreq_r1 <= '0';
    elsif clk'event and clk='1' then

        sofreq_r <= sofreq;
        eofreq_r <= eofreq;
        eofreq_r1 <= eofreq_r;
    end if;
  end process; -- se_reg_proc
 
-- This block registers the collision signal  
   process (clk, rst)
   begin
      if (rst = '0') then
         coll_r <= '0';
      elsif (clk'event and clk = '1') then
         coll_r <= coll;
      end if;
   end process; 

--===================================================================--
--                                frame                              --
--===================================================================--

  ---------------------------------------------------------------------
  -- sequencer state machine combinatorial
  ---------------------------------------------------------------------
  --Added check for ncnt[0] = 1 to ensure that the state machine should toggle
  --only on byte boundaries. This will make sure that the collision is also
  --captured at the byte boundaries. Also added check for collision registered
  --to ensure that the collision for odd/even nibbles is captured.
  tsm_proc:
  process(tsm, itpend, bkoff_r, defer, bz, ncnt, dpd, iur, hnibble,
          ac, empty, whole, tiack_r, nopad, coll, eof, coll_r)
  begin
    
    case tsm is
      -------------------------------------------
      when TSM_IDLE =>
      -------------------------------------------
        if itpend='1' and bkoff_r='0' and defer='0' then
          tsm_c <= TSM_PREA;
        else
          tsm_c <= TSM_IDLE;
        end if;
      
      -------------------------------------------
      when TSM_PREA =>
      -------------------------------------------
        if bz='1' and ncnt(0)='1' then
          tsm_c <= TSM_SFD;
        else
          tsm_c <= TSM_PREA;
        end if;
      
      -------------------------------------------
      when TSM_SFD =>
      -------------------------------------------
            if (bz = '1' and coll = '0' and (ncnt(0)) = '1') then
               tsm_c <= TSM_INFO;
            elsif (bz = '1' and coll = '1' and (ncnt(0)) = '1') then
               tsm_c <= TSM_JAM;
            else
               tsm_c <= TSM_SFD;
            end if;
      
      -------------------------------------------
      when TSM_INFO =>
      -------------------------------------------
        if ((coll = '1' or coll_r = '1') and (ncnt(0)) = '1') then
          tsm_c <= TSM_JAM;
        elsif empty='1' then
          if whole='0' and ncnt=hnibble then
            tsm_c <= TSM_JAM;
          elsif eof='1' and (nopad='1' or dpd='1') then
            if ac='1' then
              tsm_c <= TSM_INT;
            else
              tsm_c <= TSM_CRC;
            end if;
          elsif eof='1' then
            tsm_c <= TSM_PAD;
          else
            tsm_c <= TSM_INFO;
          end if;
        else
          tsm_c <= TSM_INFO;
        end if;
      
      -------------------------------------------
      when TSM_PAD =>
      -------------------------------------------
        if ((coll = '1' or coll_r = '1') and (ncnt(0)) = '1') then
          tsm_c <= TSM_JAM;
        elsif nopad='1' and ncnt(0)='1' then
          tsm_c <= TSM_CRC;
        else
          tsm_c <= TSM_PAD;
        end if;
    
      -------------------------------------------
      when TSM_CRC =>
      -------------------------------------------
        if ((coll = '1' or coll_r = '1') and (ncnt(0)) = '1') then
          tsm_c <= TSM_JAM;
        elsif bz='1' and ncnt(0)='1' then
          tsm_c <= TSM_INT;
        else
          tsm_c <= TSM_CRC;
        end if;
    
      -------------------------------------------
      when TSM_JAM =>
      -------------------------------------------
        if bz='1' and ncnt(0)='1' then
          if bkoff_r='0' or iur='1' then
            tsm_c <= TSM_FLUSH;
          else
            tsm_c <= TSM_IDLE;
          end if;
        else
          tsm_c <= TSM_JAM;
        end if;
      
      -------------------------------------------
      when TSM_FLUSH =>
      -------------------------------------------
        if whole='1' and empty='1' then
          tsm_c <= TSM_INT;
        else
          tsm_c <= TSM_FLUSH;
        end if;
      
      -------------------------------------------
      when others => -- TSM_INT
      -------------------------------------------
        if tiack_r='1' then
          tsm_c <= TSM_IDLE;
        else
          tsm_c <= TSM_INT;
        end if;
    end case;
  end process; -- tsm_proc
  
  ---------------------------------------------------------------------
  -- transmit sequencer state machine registered
  ---------------------------------------------------------------------
  tsm_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        tsm <= TSM_IDLE;
    elsif clk'event and clk='1' then

        tsm <= tsm_c;
    end if;
  end process; -- tcnt_reg_proc

  ---------------------------------------------------------------------
  -- deferring in progress
  ---------------------------------------------------------------------
  defer_drv:
    defer <= ifs1p or ifs2p;
  
  ---------------------------------------------------------------------
  -- interframe space
  ---------------------------------------------------------------------
  ifs_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        ifs1p  <= '0';
        ifs2p  <= '0';
        ifscnt <=  IFS1_TIME;
    elsif clk'event and clk='1' then

      
        -- interframe space period 1 in progress
        if itprog='0' and ifs1p='0' and ifs2p='0' and ifscnt/="0000"
        then
          ifs1p <= '1';
        elsif ifscnt="0000" or ifs2p='1' then
          ifs1p <= '0';
        end if;
        
        -- interframe space period 2 in progress
        if ifs1p='1' and ifscnt="0000" then
          ifs2p <= '1';
        elsif ifs2p='1' and ifscnt="0000" then
          ifs2p <= '0';
        end if;
        
        -- interframe space counter
        if itprog='1' or
           (carrier='1' and ifs1p='1') or
           (carrier='1' and ifscnt="0000" and itpend='0')
        then
          ifscnt <= IFS1_TIME;
        elsif ifs1p='1' and ifscnt="0000" then
          ifscnt <= IFS2_TIME;
        elsif ifscnt/="0000" then
          ifscnt <= ifscnt-1;
        end if;
    end if;
  end process; -- ifs_reg_proc

  ---------------------------------------------------------------------
  -- deferred
  -- registered output
  ---------------------------------------------------------------------
  de_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        de <= '0';
    elsif clk'event and clk='1' then
        if ifs1p='1' and itpend='1' and carrier='1' and tsm=TSM_IDLE 
        then
          de <= '1';
        elsif tiack_r='1' then
          de <= '0';
        end if;
    end if;
  end process; -- de_reg_proc
  
  ---------------------------------------------------------------------
  -- end of frame registered
  ---------------------------------------------------------------------
  eof_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        eof <= '0';
    elsif clk'event and clk='1' then

        case DATAWIDTH is
          ---------------------------------------
          when 8 =>
          ---------------------------------------
            if whole='1' and ncnt(0)='0' then
              eof <= '1';
            else
              eof <= '0';
            end if;
          
          ---------------------------------------
          when 16 =>
          ---------------------------------------
            if whole='1' and
               (
                 (lastbe="11" and ncnt(1 downto 0)="10") or
                 (lastbe="01" and ncnt(1 downto 0)="00")
               )
            then
              eof <= '1';
            else
              eof <= '0';
            end if;
          
          ---------------------------------------
          when others => -- 32
          ---------------------------------------
            if whole='1' and
               (
                 (lastbe="1111" and ncnt(2 downto 0)="110") or
                 (lastbe="0111" and ncnt(2 downto 0)="100") or
                 (lastbe="0011" and ncnt(2 downto 0)="010") or
                 (lastbe="0001" and ncnt(2 downto 0)="000")
               )
            then
              eof <= '1';
            else
              eof <= '0';
            end if;
        end case;
    end if;
  end process; -- eof_reg_proc

  ---------------------------------------------------------------------
  -- byte count set combinatorial
  ---------------------------------------------------------------------
  bset_reg_proc:
  process(coll, tsm, ncnt, bz, empty, eof, nopad)
  begin
    bset <= '0';
    if (coll='1' and (tsm=TSM_INFO or tsm=TSM_PAD or tsm=TSM_CRC)) or
       (tsm=TSM_PAD and nopad='1' and ncnt(0)='0') or
       (tsm=TSM_PREA and bz='1' and ncnt(0)='0') or
       (tsm=TSM_SFD and ncnt(0)='1') or
       (tsm=TSM_INFO and empty='1' and eof='1' and nopad='1') or
       (tsm=TSM_IDLE)
    then
      bset <= '1';
    end if;
  end process; -- bset_reg_proc
           
  ---------------------------------------------------------------------
  -- byte counter registered
  ---------------------------------------------------------------------  
  bcnt_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        bcnt <= (others=>'1');
        brel <= "0000110";
        bz   <= '0';
    elsif clk'event and clk='1' then

        if bset='1' then
          if coll='1' and TSM=TSM_INFO then
            bcnt <= "0000011";
          else
            bcnt <= brel;
          end if;
        elsif ncnt(0)='1' and bz='0' then
          bcnt <= bcnt-1;
        end if;
        
        -- byte count reload value
        case tsm is
          when TSM_IDLE =>
            brel <= "0000110";
          when TSM_PREA =>
            brel <= "0000000";
          when TSM_SFD =>
            if coll='1' then
              brel <= "0000011";
            else
              brel <= MIN_FRAME-1;
            end if;
          when others =>
            brel <= "0000011";
        end case;
        
        -- byte count = 0
        if bset='1' and brel/="0000000" then
          bz <= '0';
        elsif bcnt="0000001" and ncnt(0)='1' and bz='0' then
          bz <= '1';
        end if;
    end if;
  end process; -- bcnt_reg_proc
  
  ---------------------------------------------------------------------
  -- no padding registered
  ---------------------------------------------------------------------  
  nopad_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        nopad <= '0';
    elsif clk'event and clk='1' then

        if (tsm=TSM_INFO and bcnt="0000100" and ac='0') or
           (tsm=TSM_INFO and bcnt="0000001" and ac='1') or
           (tsm=TSM_PAD  and bcnt="0000100") or
           (dpd='1' and ac='0')
        then
          nopad <= '1';
        elsif tsm=TSM_IDLE then
          nopad <= '0';
        end if;
    end if;
  end process; -- nopad_reg_proc

  ---------------------------------------------------------------------
  -- nibble set combinatorial
  ---------------------------------------------------------------------
  nset_proc:
  process(
           tsm, itpend, bkoff_r, defer, ncnt, eof, empty, nopad
         )
  begin
    nset <= '0';
    if (
         tsm=TSM_IDLE and
         not (itpend='1' and bkoff_r='0' and defer='0')
       )
       or
       (
         tsm=TSM_INFO and empty='1' and
         eof='1'
       )
       or
       (tsm=TSM_PAD and nopad='1' and ncnt(0)='1')
    then
      nset <= '1';
    end if;
  end process; -- nset_proc
  
  ---------------------------------------------------------------------
  -- nibble counter registered
  ---------------------------------------------------------------------  
  ncnt_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        ncnt <= (others=>'0');
    elsif clk'event and clk='1' then

        if nset='1' then
          ncnt <= (others=>'0');
        elsif tsm/=TSM_IDLE then
          ncnt <= ncnt+1;
        end if;
    end if;
  end process; -- ncnt_reg_proc
  
  ---------------------------------------------------------------------
  -- transmit crc combinatorial
  ---------------------------------------------------------------------
  crc_proc:
  process(tsm, crc, itxd0, crcgen)
  begin
    
    crc_c <= crc;
    if tsm=TSM_PREA then
      crc_c <= (others=>'1');

    elsif crcgen='1' then
      crc_c(0)  <= crc(28) xor itxd0(3);
      crc_c(1)  <= crc(28) xor crc(29) xor itxd0(2) xor itxd0(3);
      crc_c(2)  <= crc(28) xor crc(29) xor crc(30) xor itxd0(1) xor
                    itxd0(2) xor itxd0(3);
      crc_c(3)  <= crc(29) xor crc(30) xor crc(31) xor itxd0(0) xor
                    itxd0(1) xor itxd0(2);
      crc_c(4)  <= crc(0) xor crc(28) xor crc(30) xor crc(31) xor
                    itxd0(0) xor itxd0(1) xor itxd0(3);
      crc_c(5)  <= crc(1) xor crc(28) xor crc(29) xor crc(31) xor
                    itxd0(0) xor itxd0(2) xor itxd0(3);
      crc_c(6)  <= crc(2) xor crc(29) xor crc(30) xor itxd0(1) xor
                    itxd0(2);
      crc_c(7)  <= crc(3) xor crc(28) xor crc(30) xor crc(31) xor
                    itxd0(0) xor itxd0(1) xor itxd0(3);
      crc_c(8)  <= crc(4) xor crc(28) xor crc(29) xor crc(31) xor
                    itxd0(0) xor itxd0(2) xor itxd0(3);
      crc_c(9)  <= crc(5) xor crc(29) xor crc(30) xor itxd0(1) xor
                    itxd0(2);
      crc_c(10) <= crc(6) xor crc(28) xor crc(30) xor crc(31) xor
                    itxd0(0) xor itxd0(1) xor itxd0(3);
      crc_c(11) <= crc(7) xor crc(28) xor crc(29) xor crc(31) xor
                    itxd0(0) xor itxd0(2) xor itxd0(3);
      crc_c(12) <= crc(8) xor crc(28) xor crc(29) xor crc(30) xor
                    itxd0(1) xor itxd0(2) xor itxd0(3);
      crc_c(13) <= crc(9) xor crc(29) xor crc(30) xor crc(31) xor
                    itxd0(0) xor itxd0(1) xor itxd0(2);
      crc_c(14) <= crc(10) xor crc(30) xor crc(31) xor itxd0(0) xor
                    itxd0(1);
      crc_c(15) <= crc(11) xor crc(31) xor itxd0(0);
      crc_c(16) <= crc(12) xor crc(28) xor itxd0(3);
      crc_c(17) <= crc(13) xor crc(29) xor itxd0(2);
      crc_c(18) <= crc(14) xor crc(30) xor itxd0(1);
      crc_c(19) <= crc(15) xor crc(31) xor itxd0(0);
      crc_c(20) <= crc(16);
      crc_c(21) <= crc(17);
      crc_c(22) <= crc(18) xor crc(28) xor itxd0(3);
      crc_c(23) <= crc(19) xor crc(28) xor crc(29) xor itxd0(2) xor
                    itxd0(3);
      crc_c(24) <= crc(20) xor crc(29) xor crc(30) xor itxd0(1) xor
                    itxd0(2);
      crc_c(25) <= crc(21) xor crc(30) xor crc(31) xor itxd0(0) xor
                    itxd0(1);
      crc_c(26) <= crc(22) xor crc(28) xor crc(31) xor itxd0(0) xor
                    itxd0(3);
      crc_c(27) <= crc(23) xor crc(29) xor itxd0(2);
      crc_c(28) <= crc(24) xor crc(30) xor itxd0(1);
      crc_c(29) <= crc(25) xor crc(31) xor itxd0(0);
      crc_c(30) <= crc(26);
      crc_c(31) <= crc(27);
    end if;
  end process; -- crc_proc
  
  ---------------------------------------------------------------------
  -- crc registered
  ---------------------------------------------------------------------
  crc_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        crcgen  <= '0';
        crcsend <= '0';
        crc     <= (others=>'1');
    elsif clk'event and clk='1' then

        -- crc registered
        crc <= crc_c;
        
        -- crc generate
        if tsm=TSM_INFO or tsm=TSM_PAD then
          crcgen <= '1';
        else
          crcgen <= '0';
        end if;
        
        -- crc send
        if tsm=TSM_CRC then
          crcsend <= '1';
        else
          crcsend <= '0';
        end if;
    end if;
  end process; -- crc_reg_proc
  
  ---------------------------------------------------------------------
  -- transmit state registered
  ---------------------------------------------------------------------
  tstate_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        itprog   <= '0';
        itpend   <= '0';
        tprog    <= '0';
        preamble <= '0';
    elsif clk'event and clk='1' then

      
        -- internal transmit in progress
        if tsm=TSM_INFO or tsm=TSM_PAD or tsm=TSM_CRC or tsm=TSM_JAM then
          itprog <= '1';
        else
          itprog <= '0';
        end if;
        
        -- transmit pending
        if sofreq_r='1' then
          itpend <= '1';
        else
        --elsif iti='1' then
          itpend <= '0';
        end if;
        
        -- transmit in progress
        if (
             tsm=TSM_PREA or tsm=TSM_SFD or tsm=TSM_INFO or tsm=TSM_PAD or tsm=TSM_CRC or tsm=TSM_JAM
           )
        then
          tprog <= '1';
        else
          tprog <= '0';
        end if;
        
        -- preamble transmission in progress
        if tsm=TSM_PREA or tsm=TSM_SFD then
          preamble <= '1';
        else
          preamble <= '0';
        end if;
    end if;
  end process; -- tstate_reg_proc
  
  ---------------------------------------------------------------------
  -- transmit pending
  -- registered output
  ---------------------------------------------------------------------
  tpend_drv:
    tpend <= itpend;

  ---------------------------------------------------------------------
  -- transmit interrupt registered
  ---------------------------------------------------------------------
  iti_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        iti     <= '0';
        tireq   <= '0';
        tiack_r <= '0';
    elsif clk'event and clk='1' then

        -- internal transmit interrupt
        if tsm=TSM_INT then
          iti <= '1';
        elsif tiack='1' then
          iti <= '0';
        end if;
        
        -- transmit interrupt
        tireq   <= iti;
        tiack_r <= tiack;
    end if;
  end process; -- iti_reg_proc
  
  ---------------------------------------------------------------------
  -- fifo underrun registered
  ---------------------------------------------------------------------
  iur_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        iur <= '0';
    elsif clk'event and clk='1' then

        if itprog='1' and empty='1' and whole='0' then
          iur <= '1';
        elsif tiack_r='1' then
          iur <= '0';
        end if;
    end if;
  end process; -- iur_reg_proc
  
  ---------------------------------------------------------------------
  -- fifo underrun
  -- registered output
  ---------------------------------------------------------------------
  ur_drv:
    ur <= iur;
  
  
  

--===================================================================--
--                                  mii                              --
--===================================================================--
  
  ---------------------------------------------------------------------
  -- transmit data mux
  ---------------------------------------------------------------------
  datamux_proc:
  process(tsm, ramdata_r, pmux)
  begin
    datamux_c <= pmux;
    if tsm=TSM_INFO then
      datamux_c <= ramdata_r;
    end if;
  end process; -- datamux_proc
  
  ---------------------------------------------------------------------
  -- ncnt 1 downto 0
  ---------------------------------------------------------------------
  ncnt10_drv:
    ncnt10 <= ncnt(1 downto 0);
  
  ---------------------------------------------------------------------
  -- ncnt 2 downto 0
  ---------------------------------------------------------------------
  ncnt20_drv:
    ncnt20 <= ncnt(2 downto 0);
  
  ---------------------------------------------------------------------
  -- Data mux extended to maximum length
  ---------------------------------------------------------------------
  datamux_c_max_drv:
    datamux_c_max <= dzero_max(DATAWIDTH_MAX downto DATAWIDTH) &
                     datamux_c;
  
  ---------------------------------------------------------------------
  -- crc remainder inverted combinatorial
  ---------------------------------------------------------------------
  crcneg_proc:
  process(crc)
  begin
    for i in 31 downto 0 loop
      crcneg_c(i) <= not crc(31-i);
    end loop;
  end process; -- crcneg_proc
  
  ---------------------------------------------------------------------
  -- mii transmit data
  -- registered output
  ---------------------------------------------------------------------
  txd_proc:

process(clk,rst)
  begin
    if rst = '0' then
        txd       <= (others=>'1');
        pmux      <= (others=>'1');
        itxd0     <= (others=>'1');
        ramdata_r <= (others=>'0');
    elsif clk'event and clk='1' then

        -- predefined frame field data mux
        case tsm_c is
          when TSM_PAD =>
            pmux <= PAD_PATTERN(63 downto 64-DATAWIDTH);
          when TSM_JAM =>
            pmux <= JAM_PATTERN(63 downto 64-DATAWIDTH);
          when TSM_PREA =>
            pmux <= PRE_PATTERN(63 downto 64-DATAWIDTH);
          when TSM_SFD =>
            pmux <= SFD_PATTERN(63 downto 64-DATAWIDTH);
          when others =>
            pmux <= (others=>'1');
        end case;
        
        -- mii data mux
        case DATAWIDTH is
          -------------------------------------------
          when 32 =>
          -------------------------------------------
            case ncnt20 is
              when "000"  => itxd0 <= datamux_c_max( 3 downto  0);
              when "001"  => itxd0 <= datamux_c_max( 7 downto  4);
              when "010"  => itxd0 <= datamux_c_max(11 downto  8);
              when "011"  => itxd0 <= datamux_c_max(15 downto 12);
              when "100"  => itxd0 <= datamux_c_max(19 downto 16);
              when "101"  => itxd0 <= datamux_c_max(23 downto 20);
              when "110"  => itxd0 <= datamux_c_max(27 downto 24);
              when others => itxd0 <= datamux_c_max(31 downto 28);
            end case;
          
          -------------------------------------------
          when 16 =>
          -------------------------------------------
            case ncnt10 is
              when "00"   => itxd0 <= datamux_c_max( 3 downto  0);
              when "01"   => itxd0 <= datamux_c_max( 7 downto  4);
              when "10"   => itxd0 <= datamux_c_max(11 downto  8);
              when others => itxd0 <= datamux_c_max(15 downto 12);
            end case;
            
          -------------------------------------------
          when others => -- 8
          -------------------------------------------
            if ncnt(0)='0' then
              itxd0 <= datamux_c_max( 3 downto  0);
            else
              itxd0 <= datamux_c_max( 7 downto  4);
            end if;
        end case;
        
        -- ram data
        if re='1' then
          ramdata_r <= ramdata;
        end if;
        
        -- mii transmit data
        if crcsend='1' then
          case ncnt is
            when "0001"  => txd <= crcneg_c( 3 downto  0);
            when "0010"  => txd <= crcneg_c( 7 downto  4);
            when "0011"  => txd <= crcneg_c(11 downto  8);
            when "0100"  => txd <= crcneg_c(15 downto 12);
            when "0101"  => txd <= crcneg_c(19 downto 16);
            when "0110"  => txd <= crcneg_c(23 downto 20);
            when "0111"  => txd <= crcneg_c(27 downto 24);
            when others  => txd <= crcneg_c(31 downto 28);
          end case;
        else
          txd <= itxd0;
        end if;
    end if;
  end process; -- txd_proc
    
  ---------------------------------------------------------------------
  -- mii transmit enable registered
  -- registered output
  ---------------------------------------------------------------------
  txen_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        txen1 <= '0';
        txen  <= '0';
    elsif clk'event and clk='1' then

        txen <= txen1;
        if tsm=TSM_IDLE or tsm=TSM_INT or tsm=TSM_FLUSH then
          txen1 <= '0';
        else
          txen1 <= '1';
        end if;
    end if;
  end process; -- txen_reg_proc
  
  ---------------------------------------------------------------------
  -- transmit error
  -- stuck at '0'
  ---------------------------------------------------------------------
  txer_drv:
    txer <= '0';
  

--===================================================================--
--                             backoff                               --
--===================================================================--

  ---------------------------------------------------------------------
  -- backoff in progress registered
  ---------------------------------------------------------------------
  bkoff_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        bkoff_r <= '0';
    elsif clk'event and clk='1' then

        if bkoff='1' then
          bkoff_r <= '1';
        elsif tsm/=TSM_JAM then
          bkoff_r <= '0';
        end if;
    end if;
  end process; -- bkoff_reg_proc
  

--===================================================================--
--                           power management                        --
--===================================================================--

  ---------------------------------------------------------------------
  -- stop output
  -- registered output
  ---------------------------------------------------------------------
  stopo_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        stop_r <= '0';
        stopo  <= '0';
    elsif clk'event and clk='1' then

        -- stop transmit input
        stop_r <= stopi;
        
        -- stop transmit output
        if stop_r='1' and tsm=TSM_IDLE and itpend='0' then
          stopo <= '1';
        else
          stopo <= '0';
        end if;
    end if;
  end process; -- stopo_reg_proc


--===================================================================--
--                               timers                              --
--===================================================================--

  ---------------------------------------------------------------------
  -- cycle size counter registered
  ---------------------------------------------------------------------  
  cscnt_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        tcscnt   <= (others=>'0');
        tcs      <= '0';
        tcsreq   <= '0';
        tcsack_r <= '0';
    elsif clk'event and clk='1' then

        -- cycle size counter registered
        if tcscnt="00000000" then
          tcscnt <= "10000000";
        else
          tcscnt <= tcscnt-1;
        end if;
        
        -- cycle size indicator
        if tcscnt="00000000" then
          tcs <= '1';
        elsif tcsack_r='1' then
          tcs <= '0';
        end if;
        
        -- cycle size request
        if tcs='1' and tcsack_r='0' then
          tcsreq <= '1';
        elsif tcsack_r='1' then
          tcsreq <= '0';
        end if;
        
        -- cycle size acknowledge
        tcsack_r <= tcsack;
    end if;
  end process; -- cscnt_reg_proc
  
  
--===================================================================--
--                              others                               --
--===================================================================--


  ---------------------------------------------------------------------
  -- Highest nibble
  -- Predefined value
  ---------------------------------------------------------------------
  hnibble_drv:
    hnibble <= "0111" when DATAWIDTH=32 else
               "0011" when DATAWIDTH=16 else
               "0001";

  ---------------------------------------------------------------------
  -- zero vactor max
  ---------------------------------------------------------------------
  dzero_max_drv:
    dzero_max <= (others=>'0');
  
end RTL;
--*******************************************************************--
