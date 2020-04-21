-- ********************************************************************/ 
-- Copyright 2013 Actel Corporation.  All rights reserved.
-- IP Solutions Group
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED 
-- IN ADVANCE IN WRITING.  
--  
-- File:  rc.vhd
--     
-- Description: Core10100
--              See below  
--
-- SVN Revision Information:
-- SVN $Revision: 6737 $
-- SVN $Date: 2009-02-20 23:42:36 +0530 (Fri, 20 Feb 2009) $  
--   
--
-- Notes: Includes SAR73505
--		  
--
-- *********************************************************************/ 
--




--*******************************************************************--
-- Copyright (c) 2001-2003  Actel SA                             --
--*******************************************************************--
-- Please review the terms of the license agreement before using     --
-- this file. If you are not an authorized user, please destroy this --
-- source code file and notify Actel immediately that you     --
-- inadvertently received an unauthorized copy.                      --
--*******************************************************************--

-----------------------------------------------------------------------
-- Project name         : MAC
-- Project description  : Ethernet Media Access Controller
--
-- File name            : rc.vhd
-- File contents        : Entity RC
--                        Architecture RTL of RC
-- Purpose              : Receive Controller for MAC
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
-- 2003.03.21 : T.K. - watchdog functionality removed
-- 2003.03.21 : T.K. - missed frames counter moved to the rlsm.vhd
-- 2003.03.21 : T.K. - frame cache not full is now registered
-- 2003.03.21 : T.K. - "hash_reg_proc" simplified
-- 2003.03.21 : T.K. - external address matching interface modified
-- 2003.03.21 : T.K. - rcpoll port added
-- 2.00.E02   :
-- 2003.04.15 : T.K  - synchronous processes merged
-- 2.00.E05_ACTEL : H.C. - fix the dribbling error
-- 2004.01.20 : B.W. - fixed mfc counter (F200.05.mfc) &
--                     statistical counters module integration
--                     support (I200.05.sc) :
--						* mfc counter related ports added
--                      * cachenf_2r and eorfff signals added
--                      * fcgbcnt and fcgbcnt_r signals added
--                      * mfcnt and mfcl_r signals added
--                      * fifofull_reg_proc process changed
--                      * rsm_proc process changed
--                      * bncnt_reg_proc process modified
--                      * winp_reg_proc process modified
--                      * length_reg_proc process changed
--                      * fcfbcnt_reg_proc process added
--                      * eorfff_reg_proc process added
--                      * stat_reg_proc process changed
--                      * fsm_proc process modified
--                      * focnt_reg_proc process changed
--                      * mfcnt_reg_proc process moved from RLSM component
--                      * mfcnt_reg_proc process modified
--
-- 2004.01.20 : B.W. - fixed frame filtering in hash mode (F200.05.hash)
--                      * fa_reg_proc process modified
--
-- 2004.01.20 : B.W. - RTL code changes due to VN Check
--                     and code coverage (I200.06.vn):
--                      * crc_proc process changed
--                      * perfm_proc process changed
--
-- 
-- 2.00.E06a  :
-- 2004.02.20 : T.K. - cs collision seen functionality fixed (F200.06.cs) :
--                      * col port added
--                      * col_r signal added
--                      * mii_reg_proc process changed
--                      * stat_reg_proc process changed
--
-- 2004.02.20 : T.K. - fixed receive DATA RAM read/write address pointers
--                     when receiving a frame with dribbling bit
--                      * we_reg_proc process changed
-- 2.00.E09   :
-- 2004.06.23 : T.K. - dribbling bit in 32bit mode fixed (F200.09.db) :
--                      * we_reg_proc process changed
-- 2004.06.23 : B.W. - fifo control fixed (F200.09.cachenf) :
--                      * fifofull_reg_proc process changed
--*******************************************************************--

library IEEE;
  use work.utility.all;
  use ieee.std_logic_1164.all; 
  use IEEE.STD_LOGIC_UNSIGNED."-";
  use IEEE.STD_LOGIC_UNSIGNED."+";
  use IEEE.STD_LOGIC_UNSIGNED.CONV_INTEGER;
  


  --*****************************************************************--
  entity RC is
    generic (
              -- Depth of the FIFO
              FIFODEPTH : INTEGER := 9;
              -- Depth of the internal data path
              DATAWIDTH : INTEGER := 32 -- 8|16|32
    );
    port (
              ------------------------ common -------------------------
              -- clock
              clk       : in  STD_LOGIC;
              -- reset
              rst       : in  STD_LOGIC;
              
              -------------------------- mii --------------------------
              -- mii data valid
              rxdv      : in  STD_LOGIC;
              -- mii error
              rxer      : in  STD_LOGIC;
              -- collision detect
			  col       : in  STD_LOGIC;
              -- mii received data
              rxd       : in  STD_LOGIC_VECTOR(3 downto 0);
              
              ------------------------ DP RAM -------------------------
              -- receive ram write enable
              ramwe     : out STD_LOGIC;
              -- receive ram write address
              ramaddr   : out STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
              -- receive ram write data
              ramdata   : out STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
              
              --------------------- filtering RAM ---------------------
              -- filtering ram data
              fdata     : in  STD_LOGIC_VECTOR(ADDRWIDTH-1 downto 0);
              -- filtering ram address
              faddr     : out STD_LOGIC_VECTOR(ADDRDEPTH-1 downto 0);
              
              ---------------------- fifo control ---------------------
              -- frame cache not full
              cachenf : in  STD_LOGIC;
              -- fifo read address grey coded
              radg    : in  STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
              -- fifo write address grey coded
              wadg    : out STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
              -- receive in progress
              rprog   : out STD_LOGIC;
              -- rc poll
              rcpoll  : out STD_LOGIC;
              
              -------------------- receive control --------------------
              -- interrupt acknowledge from fifo
              riack     : in  STD_LOGIC;
              -- receive enable
              ren       : in  STD_LOGIC;
              -- receive all
              ra        : in  STD_LOGIC;
              -- pass all multicast
              pm        : in  STD_LOGIC;
              -- promiscous mode
              pr        : in  STD_LOGIC;
              -- pass bad frames
              pb        : in  STD_LOGIC;
              -- inverse filtering mode
              rif       : in  STD_LOGIC;
              -- hash only filtering mode
              ho        : in  STD_LOGIC;
              -- hash/perfect filtering mode
              hp        : in  STD_LOGIC;
              -- interrupt request
              rireq     : out STD_LOGIC;
              -- filtering fail
              ff        : out STD_LOGIC;
              -- runt frame
              rf        : out STD_LOGIC;
              -- multicast frame
              mf        : out STD_LOGIC;
              -- dribbling bit
              db        : out STD_LOGIC;
              -- mii error
              re        : out STD_LOGIC;
              -- crc error
              ce        : out STD_LOGIC;
              -- too long
              tl        : out STD_LOGIC;
              -- frame type
              ftp       : out STD_LOGIC;
              -- fifo overflow
              ov        : out STD_LOGIC;
              -- collision seen
              cs        : out STD_LOGIC;
              -- length of frame
              length    : out STD_LOGIC_VECTOR(13 downto 0);
              
              -------------------- external address filtering -----------------
              -- match input
              match      : in  STD_LOGIC;
              -- match valid
              matchval   : in  STD_LOGIC;
              -- match enable
              matchen    : out STD_LOGIC;
              -- match data
              matchdata  : out STD_LOGIC_VECTOR(47 downto 0);
              
              ------------------- statistical counters ----------------
              -- clear missed frames counter
              mfcl      : in  STD_LOGIC;
              -- clear fifo overflow counter request
              focl      : in  STD_LOGIC;
              -- clear fifo overflow counter acknowledge
              foclack   : out STD_LOGIC;
              -- fifo overflow counter overflow
              oco       : out STD_LOGIC;
              -- clear missed frames counter acknowledge
              mfclack   : out STD_LOGIC;
              -- missed frames counter overflow
              mfo       : out STD_LOGIC;
              -- fifo overflow counter grey coded
              focg      : out STD_LOGIC_VECTOR(10 downto 0);
              -- missed frames counter grey coded
              mfcg      : out STD_LOGIC_VECTOR(15 downto 0);
              
              ---------------------- power management -----------------
              -- stop input
              stopi     : in  STD_LOGIC;
              -- stop output
              stopo     : out STD_LOGIC;
              
              ------------------------ timers -------------------------
              -- cycle size acknowledge
              rcsack    : in  STD_LOGIC;
              -- cycle size request
              rcsreq    : out STD_LOGIC
    );
  end RC;


--*******************************************************************--
architecture RTL of RC is
  
  ------------------------------ fifo ---------------------------------
  -- frame cache not full registered
  signal cachenf_2r: STD_LOGIC;
  -- bytes counter when frame cache full
  signal fcfbcnt   : STD_LOGIC;
  -- bytes counter when frame cache full registered
  signal fcfbcnt_r : STD_LOGIC;
  -- end of receiving frame when frame cache full
  signal eorfff   : STD_LOGIC;
  -- fifo write enable registered
  signal we        : STD_LOGIC;
  -- fifo full registered
  signal full      : STD_LOGIC;
  -- fifo write address registered
  signal wad       : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- fifo write address incremented registered
  signal wadi      : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- fifo write address grey coded registered
  signal iwadg     : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- fifo write address incremented grey coded registered
  signal wadig     : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- collision detected
  signal col_r       : STD_LOGIC;
  -- fifo read address grey coded registered
  signal radg_r    : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- start of frame address registered
  signal isofad    : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- frame cache not full
  signal cachenf_r : STD_LOGIC;


  -------------------------------- mii --------------------------------
  -- mii data valid registered
  signal rxdv_r      : STD_LOGIC;
  -- mii error registered
  signal rxer_r      : STD_LOGIC;
  -- mii receive data registered
  signal rxd_r       : STD_LOGIC_VECTOR(3 downto 0);
  -- mii receive data 4 bit registered
  signal rxd_r4      : STD_LOGIC_VECTOR(3 downto 0);
  
  
  ----------------------------- framing -------------------------------
  -- frame sequencer state machine combinatorial
  signal rsm_c       : RCSMT;
  -- frame sequencer state machine registered
  signal rsm         : RCSMT;
  -- nibble counter
  signal ncnt        : STD_LOGIC_VECTOR(3 downto 0);
  -- 2 least significant bits of nibble counter
  signal ncnt10      : STD_LOGIC_VECTOR(1 downto 0);
  -- 3 least significant bits of nibble counter
  signal ncnt20      : STD_LOGIC_VECTOR(2 downto 0);
  -- data register combinatorial
  signal data_c      : STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
  -- data register registered
  signal data        : STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
  -- crc remainder combinatorial
  signal crc_c       : STD_LOGIC_VECTOR(31 downto 0);
  -- crc remainder registered
  signal crc         : STD_LOGIC_VECTOR(31 downto 0);
  -- byte counter
  signal bcnt        : STD_LOGIC_VECTOR(6 downto 0);
  -- 3 least significant bits of byte counter
  signal bcnt20      : STD_LOGIC_VECTOR(2 downto 0);
  -- byte counter = 0
  signal bz          : STD_LOGIC;
  -- collision window passed registered
  signal winp        : STD_LOGIC;
  -- interrupt request combinatorial
  signal iri_c       : STD_LOGIC;
  -- interrupt request registered
  signal iri         : STD_LOGIC;
  -- interrupt acknowledge registered
  signal riack_r     : STD_LOGIC;
  -- frame length counter
  signal lcnt        : STD_LOGIC_VECTOR(13 downto 0);
  -- LENGTH/TYPE field
  signal lfield      : STD_LOGIC_VECTOR(15 downto 0);
  -- receive enable registered
  signal ren_r       : STD_LOGIC;
  -- receive in progress
  signal irprog      : STD_LOGIC;
  
  
  ------------------------ address filtering --------------------------
  -- filtering state machine combinatorial
  signal fsm_c       : FSMT;
  -- filtering state machine registered
  signal fsm         : FSMT;
  -- perfect address match combinatorial
  signal perfm_c     : STD_LOGIC;
  -- perfect address match registered
  signal perfm       : STD_LOGIC;
  -- inverse match registered
  signal invm        : STD_LOGIC;
  -- crc value for hash table registered
  signal crchash     : STD_LOGIC_VECTOR(8 downto 0);
  -- hash table match registered
  signal hash        : STD_LOGIC;
  -- DA frame field
  signal dest        : STD_LOGIC_VECTOR(47 downto 0);
  -- counter for 16-bit words in 48-bit ethernet address
  signal flcnt       : STD_LOGIC_VECTOR(2 downto 0);
  -- filtering ram address
  signal fa          : STD_LOGIC_VECTOR(ADDRDEPTH-1 downto 0);
  -- filtering ram data registered
  signal fdata_r     : STD_LOGIC_VECTOR(15 downto 0);
  
  
  ------------------------------ timers -------------------------------
  -- cycle size request
  signal rcs         : STD_LOGIC;
  -- cycle size acknowledge registered
  signal rcsack_r    : STD_LOGIC;
  -- cycle size counter
  signal rcscnt      : STD_LOGIC_VECTOR(7 downto 0);
  
  ---------------------- statistical counters -------------------------
  -- fifo overflow counter
  signal focnt       : STD_LOGIC_VECTOR(10 downto 0);
  -- fifo overflow counter clear registered
  signal focl_r      : STD_LOGIC;
  -- missed frames counter
  signal mfcnt       : STD_LOGIC_VECTOR(15 downto 0);
  -- missed counter clear registered
  signal mfcl_r      : STD_LOGIC;
  
  -------------------------- power management -------------------------
  -- stop receive process registered
  signal stop_r      : STD_LOGIC;
  
  ------------------------------ others -------------------------------
  -- all zeros vector for fifo (predefined value)
  signal fzero       : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);

  
begin


--===================================================================--
--                                 mii                               --
--===================================================================--

  ---------------------------------------------------------------------
  -- mii interface registered
  ---------------------------------------------------------------------
  mii_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        rxdv_r <= '0';
        rxer_r <= '0';
        col_r  <= '0';
        rxd_r  <= (others=>'0');
        data   <= (others=>'1');
    elsif clk'event and clk='1' then

        rxdv_r <= rxdv;
        rxer_r <= rxer;
        col_r <= col;
        rxd_r  <= rxd;
        data   <= data_c;
    end if;
  end process; -- mii_reg_proc
  
  ---------------------------------------------------------------------
  -- mii receive data 4 bit
  ---------------------------------------------------------------------
  rxd_r4_drv:
    rxd_r4 <= rxd_r;
  
  ---------------------------------------------------------------------
  -- 2 least significant bits of nibble counter
  ---------------------------------------------------------------------
  ncnt10_drv:
    ncnt10 <= ncnt(1 downto 0);
  
  ---------------------------------------------------------------------
  -- 3 least significant bits of nibble counter
  ---------------------------------------------------------------------
  ncnt20_drv:
    ncnt20 <= ncnt(2 downto 0);

  ---------------------------------------------------------------------
  -- receive data combinatorial
  ---------------------------------------------------------------------
 
  -- Changes made to this process in v3.0 due to vector width misalignments SAR56860
 
 
  data_proc:
  process(ncnt, ncnt10, ncnt20, rxd_r, data)
    variable data16 : STD_LOGIC_VECTOR(31 downto 0);   -- only uses 15:0, other bits for alignment
    variable data32 : STD_LOGIC_VECTOR(31 downto 0);
  begin
    
	  data_c <= ( others => '0');
	  
      case DATAWIDTH is 
        -----------------------------------------
        when 8 =>
        -----------------------------------------
          data_c <= data;
          if ncnt(0)='0' then
            data_c(3 downto 0) <= rxd_r;
          else
            data_c(7 downto 4) <= rxd_r;
          end if;
          
        -----------------------------------------
        when 16 =>
        -----------------------------------------
	      data16 := ( others => '0');
          data16(15 downto 0) := data(15 downto 0);
          case ncnt10 is
            when "00"   => data16( 3 downto 0)  := rxd_r;
            when "01"   => data16( 7 downto 4)  := rxd_r;
            when "10"   => data16(11 downto 8)  := rxd_r;
            when others => data16(15 downto 12) := rxd_r;
          end case;
          data_c(DATAWIDTH-1 downto 0) <= data16(DATAWIDTH-1 downto 0);
          
        -----------------------------------------
        when others => -- 32
        -----------------------------------------
          data32 := data;
          case ncnt20 is
            when "000"  => data32( 3 downto  0) := rxd_r;
            when "001"  => data32( 7 downto  4) := rxd_r;
            when "010"  => data32(11 downto  8) := rxd_r;
            when "011"  => data32(15 downto 12) := rxd_r;
            when "100"  => data32(19 downto 16) := rxd_r;
            when "101"  => data32(23 downto 20) := rxd_r;
            when "110"  => data32(27 downto 24) := rxd_r;
            when others => data32(31 downto 28) := rxd_r;
          end case;
          data_c(DATAWIDTH-1 downto 0) <= data32(DATAWIDTH-1 downto 0);
      end case;
  end process; -- data_proc
  
  
--===================================================================--
--                               rfifo                               --
--===================================================================--
  
  ---------------------------------------------------------------------
  -- fifo full logic registered
  ---------------------------------------------------------------------  
  fifofull_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        cachenf_2r <= '1';
        cachenf_r <= '1';
        full      <= '0';
    elsif clk'event and clk='1' then

        -- frame chache not full
        cachenf_r <= cachenf;
        -- frame chache not full registered
        if cachenf_2r='1' or
          (
            (rxdv_r='0' and cachenf_r='1') or
            (rxdv_r='1' and cachenf_r='1' and
              (rsm=RSM_IDLE or rsm=RSM_SFD)
            )
          )
        then
          cachenf_2r <= cachenf_r;
        end if;
        
        -- fifo full
        if wadig=radg_r or (iwadg=radg_r and full='1') then
          full <= '1';
        else
          full <= '0';
        end if;
    end if;
  end process; -- fifofull_reg_proc
  
  ---------------------------------------------------------------------
  -- fifo address registered
  ---------------------------------------------------------------------  
  addr_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        wad    <= (others=>'0');
        wadi (FIFODEPTH-1 downto 1)  <= ( others => '0');
        wadig(FIFODEPTH-1 downto 1)  <= ( others => '0');
        wadi (0)  <=  '1';
        wadig(0)  <=  '1';
        iwadg  <= (others=>'0');
        isofad <= (others=>'0');
        radg_r <= (others=>'0');
    elsif clk'event and clk='1' then

        -- fifo write address
        if rsm=RSM_BAD then
          wad <= isofad;
        elsif we='1' then
          wad <= wad+1;
        end if;
        
        -- fifo write address incremented
        if rsm=RSM_BAD then
          wadi <= isofad+1;
        elsif we='1' then
          wadi <= wadi+1;
        end if;
        
        -- fifo write address grey coded
        iwadg(FIFODEPTH-1) <= wad(FIFODEPTH-1);
        for i in FIFODEPTH-2 downto 0 loop
          iwadg(i) <= wad(i+1) xor wad(i);
        end loop;
        
        -- fifo write address incremented grey coded
        wadig(FIFODEPTH-1) <= wadi(FIFODEPTH-1);
        for i in FIFODEPTH-2 downto 0 loop
          wadig(i) <= wadi(i+1) xor wadi(i);
        end loop;
        
        -- fifo start of frame address
        if rsm=RSM_IDLE then
          isofad <= wad;
        end if;
        
        -- fifo read address grey coded
        radg_r <= radg;
    end if;
  end process; -- addr_reg_proc
  
  ---------------------------------------------------------------------
  -- fifo write enable registered
  ---------------------------------------------------------------------
  we_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        we <= '0';
    elsif clk'event and clk='1' then

        if (
             rsm=RSM_INFO or rsm=RSM_DEST or rsm=RSM_LENGTH or 
             rsm=RSM_SOURCE
           )
           and
           (
             (rxdv_r='1' and
               (
                 (DATAWIDTH=8  and ncnt(0)='1') or
                 (DATAWIDTH=16 and ncnt(1 downto 0)="11") or
                 (DATAWIDTH=32 and ncnt(2 downto 0)="111")
               )
             )
             or (rxdv_r='0' and we='0' and (DATAWIDTH=32 and ncnt(2 downto 1)/="00"))
             or (rxdv_r='0' and we='0' and (DATAWIDTH=16 and ncnt(2 downto 1)/="00"))  --IPB SAR73505
             or (full='1'   and we='0')
           )
        then
          we <= '1';
        else
          we <= '0';
        end if;
    end if;
  end process; -- we_reg_proc
  
  ---------------------------------------------------------------------
  -- ram data
  -- registered output from data
  ---------------------------------------------------------------------
  ramdata_drv:
    ramdata <= data;
  
  ---------------------------------------------------------------------
  -- ram write enable
  -- registered output from we
  ---------------------------------------------------------------------
  ramwe_drv:
    ramwe <= we;
  
  ---------------------------------------------------------------------
  -- ram address
  -- registered output from wadddr
  ---------------------------------------------------------------------
  ramaddr_drv:
    ramaddr <= wad;
  
  ---------------------------------------------------------------------
  -- fifo write address
  -- registered output from iwadg
  ---------------------------------------------------------------------
  waddrg_drv:
    wadg <= iwadg;




--===================================================================--
--                                frame                              --
--===================================================================--

  ---------------------------------------------------------------------
  -- receive sequencer state machine combinatorial
  ---------------------------------------------------------------------
  rsm_proc:
  process(
            rsm, rxdv_r, rxd_r, rxd_r4, stop_r,
            bz, fsm, ra, pm, pb, dest, riack_r,
            full, ren_r, winp, irprog, cachenf_r
         )
  begin
  
    case rsm is
      -------------------------------------------
      when RSM_IDLE =>
      -------------------------------------------
        if rxdv_r='1' and stop_r='0' and ren_r='1' then
          if rxd_r="0101" then
            rsm_c <= RSM_SFD;
          else
            rsm_c <= RSM_IDLE;
          end if;
        else
          rsm_c <= RSM_IDLE;
        end if;
      
      -------------------------------------------
      when RSM_SFD =>
      -------------------------------------------
        if rxdv_r='1' and full='0' and cachenf_r='1' then
          case rxd_r4 is
            when "1101" => rsm_c <= RSM_DEST;
            when "0101" => rsm_c <= RSM_SFD;
            when others => rsm_c <= RSM_IDLE;
          end case;
        elsif full='1' or cachenf_r='0' then
          rsm_c <= RSM_BAD;
        else
          rsm_c <= RSM_IDLE;
        end if;
      
      -------------------------------------------
      when RSM_DEST =>
      -------------------------------------------
        if rxdv_r='0' or full='1' or cachenf_r='0' then
          rsm_c <= RSM_BAD;
        elsif bz='1' then
          rsm_c <= RSM_SOURCE;
        else
          rsm_c <= RSM_DEST;
        end if;
      
      -------------------------------------------
      when RSM_SOURCE =>
      -------------------------------------------
        if rxdv_r='0' then
          if (pb='1') and
             (
                fsm=FSM_MATCH or ra='1' or
                (pm='1' and dest(0)='1')
             )
          then
            rsm_c <= RSM_SUCC;
          else
            rsm_c <= RSM_BAD;
          end if;
        elsif full='1' or cachenf_r='0' then
          rsm_c <= RSM_BAD;
        elsif bz='1' then
          rsm_c <= RSM_LENGTH;
        else
          rsm_c <= RSM_SOURCE;
        end if;
      
      -------------------------------------------
      when RSM_LENGTH =>
      -------------------------------------------
        if rxdv_r='0' then
          if (pb='1') and
             (
               fsm=FSM_MATCH or ra='1' or
               (pm='1' and dest(0)='1')
             )
          then
            rsm_c <= RSM_SUCC;
          else
            rsm_c <= RSM_BAD;
          end if;
        elsif full='1' or cachenf_r='0' then
          rsm_c <= RSM_BAD;
        elsif bz='1' then
          rsm_c <= RSM_INFO;
        else
          rsm_c <= RSM_LENGTH;
        end if;
      
      -------------------------------------------
      when RSM_INFO =>
      -------------------------------------------
        if rxdv_r='0' then
          if (winp='1' or pb='1') and
             (
               fsm=FSM_MATCH or ra='1' or
               (pm='1' and dest(0)='1')
             )
          then
            rsm_c <= RSM_SUCC;
          else
            rsm_c <= RSM_BAD;
          end if;
        elsif full='1' or cachenf_r='0' then
          if winp='1' then
            rsm_c <= RSM_SUCC;
          else
            rsm_c <= RSM_BAD;
          end if;
        elsif fsm=FSM_FAIL and ra='0'and not (pm='1' and dest(0)='1')
        then
          rsm_c <= RSM_BAD;
        else
          rsm_c <= RSM_INFO;
        end if;
      
      -------------------------------------------
      when RSM_SUCC =>
      -------------------------------------------
        rsm_c <= RSM_INT;
      
      -------------------------------------------
      when RSM_INT =>
      -------------------------------------------
        if riack_r='1' then
          rsm_c <= RSM_INT1;
        else
          rsm_c <= RSM_INT;
        end if;
      
      -------------------------------------------
      when RSM_INT1 =>
      -------------------------------------------
        if rxdv_r='0' and riack_r='0'then
          rsm_c <= RSM_IDLE;
        else
          rsm_c <= RSM_INT1;
        end if;
      
      -------------------------------------------
      when others => -- RSM_BAD
      -------------------------------------------
        if rxdv_r='0' and riack_r='0' and irprog='0' then
          rsm_c <= RSM_IDLE;
        else
          rsm_c <= RSM_BAD;
        end if;
    end case;
  end process; -- rsm_proc
  
  ---------------------------------------------------------------------
  -- receive sequencer state machine registered
  ---------------------------------------------------------------------
  rsm_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        rsm <= RSM_IDLE;
    elsif clk'event and clk='1' then

        rsm <= rsm_c;
    end if;
  end process; -- rsm_reg_proc
  
  ---------------------------------------------------------------------
  -- receive in progress registered
  ---------------------------------------------------------------------
  rprog_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        irprog <= '0';
        rprog <= '0';
    elsif clk'event and clk='1' then

      
        -- internal receive in progress
        if rsm=RSM_IDLE or rsm=RSM_BAD or
           rsm=RSM_INT or rsm=RSM_INT1
        then
          irprog <= '0';
        else
          irprog <= '1';
        end if;
        
        -- receive in progress
        if winp='1' and irprog='1' then
          rprog <= '1';
        else
          rprog <= '0';
        end if;
    end if;
  end process; -- rprog_reg_proc

  ---------------------------------------------------------------------
  -- rc poll
  ---------------------------------------------------------------------
  rcpoll_drv:
    rcpoll <= irprog;
  
  ---------------------------------------------------------------------
  -- byte & nibble counter registered
  ---------------------------------------------------------------------
  bncnt_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        bcnt  <= (others=>'0');
        bz    <= '0';
        ncnt  <= "0000";
    elsif clk'event and clk='1' then

      
        -- byte counter
        if cachenf_r='1' then
        if bz='1' or rsm=RSM_IDLE then
          case rsm is
            -------------------------------------
            when RSM_IDLE   =>
            -------------------------------------
              bcnt <= "0000101"; -- 6B
            -------------------------------------
            when RSM_DEST   =>
            -------------------------------------
              bcnt <= "0000101"; -- 6B
            -------------------------------------
            when RSM_SOURCE =>
            -------------------------------------
              bcnt <= "0000001"; -- 2B
            -------------------------------------
            when others     => -- RSM_LENGTH
            -------------------------------------
              bcnt <= "0110001"; -- 50B
          end case;
        else
          if ncnt(0)='1' then
            bcnt <= bcnt-1;
          end if;
        end if;
        else
          if fcfbcnt_r='0' then
            bcnt <= "0111111"; -- 50+6+6+2
          else
            if ncnt(0)='0' then
             bcnt <= bcnt-1;
            end if;
          end if;
        end if;
        
        -- byte counter = 0
        if (bcnt="0000000" and ncnt(0)='0' and cachenf_2r='1') or
           (bcnt="0000000" and ncnt(0)='1' and cachenf_2r='0') 
        then
          bz <= '1';
        else
          bz <= '0';
        end if;
        
        -- nibble counter
        if rsm=RSM_SFD or rsm=RSM_IDLE then
          ncnt <= "0000";
        else
          ncnt <= ncnt + 1;
        end if;
    end if;
  end process; -- bcnt_reg_proc
  
  ---------------------------------------------------------------------
  -- 512-bit window passed registered
  ---------------------------------------------------------------------
  winp_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        winp <= '0';
    elsif clk'event and clk='1' then

        if rsm=RSM_IDLE then
          winp <= '0';
        else
          if(rsm=RSM_INFO and cachenf_2r='1' and bz='1') or
            (rsm=RSM_BAD  and cachenf_2r='0' and bz='1')
          then
          winp <= '1';
          end if;
        end if;
    end if;
  end process; -- winp_reg_proc

  ---------------------------------------------------------------------
  -- crc combinatorial
  ---------------------------------------------------------------------
  crc_proc:
  process(crc, rsm, rxd_r)
  begin
    crc_c <= crc;
  
    case rsm is
      -------------------------------------------
      when RSM_IDLE =>
      -------------------------------------------
        crc_c <= (others=>'1');
        
      -------------------------------------------
      when RSM_DEST | RSM_SOURCE | RSM_LENGTH | RSM_INFO =>
      -------------------------------------------
        crc_c(0)  <= crc(28) xor rxd_r(3);
        crc_c(1)  <= crc(28) xor crc(29) xor rxd_r(2) xor rxd_r(3);
        crc_c(2)  <= crc(28) xor crc(29) xor crc(30) xor rxd_r(1) xor
                      rxd_r(2) xor rxd_r(3);
        crc_c(3)  <= crc(29) xor crc(30) xor crc(31) xor rxd_r(0) xor
                      rxd_r(1) xor rxd_r(2);
        crc_c(4)  <= crc(0) xor crc(28) xor crc(30) xor crc(31) xor
                      rxd_r(0) xor rxd_r(1) xor rxd_r(3);
        crc_c(5)  <= crc(1) xor crc(28) xor crc(29) xor crc(31) xor
                      rxd_r(0) xor rxd_r(2) xor rxd_r(3);
        crc_c(6)  <= crc(2) xor crc(29) xor crc(30) xor rxd_r(1) xor
                      rxd_r(2);
        crc_c(7)  <= crc(3) xor crc(28) xor crc(30) xor crc(31) xor
                      rxd_r(0) xor rxd_r(1) xor rxd_r(3);
        crc_c(8)  <= crc(4) xor crc(28) xor crc(29) xor crc(31) xor
                      rxd_r(0) xor rxd_r(2) xor rxd_r(3);
        crc_c(9)  <= crc(5) xor crc(29) xor crc(30) xor rxd_r(1) xor
                      rxd_r(2);
        crc_c(10) <= crc(6) xor crc(28) xor crc(30) xor crc(31) xor
                      rxd_r(0) xor rxd_r(1) xor rxd_r(3);
        crc_c(11) <= crc(7) xor crc(28) xor crc(29) xor crc(31) xor
                      rxd_r(0) xor rxd_r(2) xor rxd_r(3);
        crc_c(12) <= crc(8) xor crc(28) xor crc(29) xor crc(30) xor
                      rxd_r(1) xor rxd_r(2) xor rxd_r(3);
        crc_c(13) <= crc(9) xor crc(29) xor crc(30) xor crc(31) xor
                      rxd_r(0) xor rxd_r(1) xor rxd_r(2);
        crc_c(14) <= crc(10) xor crc(30) xor crc(31) xor rxd_r(0) xor
                      rxd_r(1);
        crc_c(15) <= crc(11) xor crc(31) xor rxd_r(0);
        crc_c(16) <= crc(12) xor crc(28) xor rxd_r(3);
        crc_c(17) <= crc(13) xor crc(29) xor rxd_r(2);
        crc_c(18) <= crc(14) xor crc(30) xor rxd_r(1);
        crc_c(19) <= crc(15) xor crc(31) xor rxd_r(0);
        crc_c(20) <= crc(16);
        crc_c(21) <= crc(17);
        crc_c(22) <= crc(18) xor crc(28) xor rxd_r(3);
        crc_c(23) <= crc(19) xor crc(28) xor crc(29) xor rxd_r(2) xor
                      rxd_r(3);
        crc_c(24) <= crc(20) xor crc(29) xor crc(30) xor rxd_r(1) xor
                      rxd_r(2);
        crc_c(25) <= crc(21) xor crc(30) xor crc(31) xor rxd_r(0) xor
                      rxd_r(1);
        crc_c(26) <= crc(22) xor crc(28) xor crc(31) xor rxd_r(0) xor
                      rxd_r(3);
        crc_c(27) <= crc(23) xor crc(29) xor rxd_r(2);
        crc_c(28) <= crc(24) xor crc(30) xor rxd_r(1);
        crc_c(29) <= crc(25) xor crc(31) xor rxd_r(0);
        crc_c(30) <= crc(26);
        crc_c(31) <= crc(27);
      
      -------------------------------------------
      when others => -- RSM_CRC | RSM_SFD
      -------------------------------------------
	    null;
    end case;
  end process; -- crc_proc
  
  ---------------------------------------------------------------------
  -- crc registered
  ---------------------------------------------------------------------
  crc_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        crc <= (others=>'1');
    elsif clk'event and clk='1' then

        crc <= crc_c;
    end if;
  end process; -- crc_reg_proc

  ---------------------------------------------------------------------
  -- receive interrupts combinatorial
  ---------------------------------------------------------------------
  iri_drv:
    iri_c <= '1' when rsm=RSM_INT else '0';
  
  ---------------------------------------------------------------------
  -- receive interrupt control registered
  ---------------------------------------------------------------------
  rint_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        iri     <= '0';
        riack_r <= '0';
        rireq   <= '0';
    elsif clk'event and clk='1' then

        iri     <= iri_c;
        riack_r <= riack;
        rireq   <= iri;
    end if;
  end process; -- rint_reg_proc
  
  ---------------------------------------------------------------------
  -- receive length counter registered
  ---------------------------------------------------------------------
  length_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        lcnt   <= (others=>'0');
        length <= (others=>'0');
    elsif clk'event and clk='1' then

      
        -- frame length counter
        if (rsm=RSM_IDLE and cachenf_2r='1') or 
           (fcfbcnt='0' and cachenf_2r='0') or 
            rsm=RSM_INT1 
        then
          lcnt <= (others=>'0');
        elsif(
               (   
                 rsm=RSM_INFO or rsm=RSM_LENGTH or
                 rsm=RSM_DEST or rsm=RSM_SOURCE
               ) and rxdv_r='1'
             ) or
             (fcfbcnt='1' and cachenf_2r='0')
        then
          if ncnt(0)='1' then
            lcnt <= lcnt+1;
          end if;
        end if;
        
        -- frame length grey coded
        length(13) <= lcnt(13);
        for i in 12 downto 0 loop
          length(i) <= lcnt(i+1) xor lcnt(i);
        end loop;
    end if;
  end process; -- length_reg_proc
  ---------------------------------------------------------------------
  -- bytes counter when frame cache full
  ---------------------------------------------------------------------
  fcfbcnt_reg_proc:

  
  process(clk, rst)
  	begin
  		if rst = '0' then
  			fcfbcnt   <= '0';
  			fcfbcnt_r <= '0';
  		elsif clk'event and clk='1' then
          if(cachenf_2r='0')then
            if(rxdv_r='1' and rxd_r4="1101")then
              fcfbcnt <= '1';
            elsif(rxdv_r='0')then
              fcfbcnt <= '0';
            end if;
          else
            fcfbcnt <= '0';
          end if;
          
          fcfbcnt_r <= fcfbcnt;      
  		
  		end if;
  		
  	end process; -- fcfbcnt_reg_proc
  			
  			
  			
  
  ---------------------------------------------------------------------
  -- end of receiving frame when frame cache full
  ---------------------------------------------------------------------
  eorfff_reg_proc:

  
  process(clk, rst)
  begin
  	if rst='0' then
  		eorfff <= '0';
  	elsif clk'event and clk='1' then
  		if(rsm_c=RSM_IDLE and rsm=RSM_BAD and cachenf_2r='0')then
  			eorfff <= '1';
  		else
  			eorfff <= '0';
  		end if;
  	end if;
  		
  end process; -- eorfff_reg_proc
  
  ---------------------------------------------------------------------
  -- statistic informations registered
  ---------------------------------------------------------------------  
  stat_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        lfield <= (others=>'0');
        ftp <= '0';
        tl  <= '0';
        ff  <= '0';
        mf  <= '0';
        re  <= '0';
        ce  <= '0';
        db  <= '0';
        rf  <= '0';
        ov  <= '0';
        cs  <= '0';
    elsif clk'event and clk='1' then

        
        -- frame LENGTH/TYPE field
        if rsm=RSM_LENGTH then
          if bcnt(1 downto 0)="00" then
            if ncnt(0)='0' then
              lfield(3 downto 0) <= rxd_r;
            else
              lfield(7 downto 4) <= rxd_r;
            end if;
          else
            if ncnt(0)='0' then
              lfield(11 downto 8) <= rxd_r;
            else
              lfield(15 downto 12) <= rxd_r;
            end if;
          end if;
        end if;
        
        -- frame type
        if lfield > MAX_SIZE then
          ftp <= '1';
        else
          ftp <= '0';
        end if;
        
        -- frame too long
        if lcnt=MAX_FRAME and iri_c='0' then
          tl <= '1';
        elsif rsm=RSM_IDLE then
          tl <= '0';
        end if;
        
        -- filtering fail
        if iri_c='0' then
          if fsm=FSM_MATCH then
            ff <= '0';
          else
            ff <= '1';
          end if;
        end if;
        
        -- multicast frame
        if iri_c='0' then
          mf <= dest(0);
        end if;
        
        -- mii error
        if rxer_r='1' and iri_c='0' then
          re <= '1';
        elsif rsm=RSM_IDLE then
          re <= '0';
        end if;
        
        -- collision seen
        if col_r='1' and iri_c='0' then
          cs <= '1';
        elsif rsm=RSM_IDLE then
          cs <= '0';
        end if;
        -- crc error
        if rsm=RSM_INFO and ncnt(0)='0' then
          if crc=CRCVAL then
            ce <= '0';
          else
            ce <= '1';
          end if;
        end if;
        
        -- dribbling bit
        if rsm=RSM_INFO then
          if rxdv_r='0' and ncnt(0)='1' then
            db <= '1';
          else
            db <= '0';
          end if;
        end if;
        
        -- runt frame
        if winp='0' and iri_c='1' then
          rf <= '1';
        elsif rsm=RSM_IDLE then
          rf <= '0';
        end if;
        
        -- fifo overflow
        if rsm=RSM_IDLE then
          ov <= '0';
        elsif full='1' or cachenf_r='0' then
          ov <= '1';
        end if;
    end if;
  end process; -- stat_reg_proc
  
  ---------------------------------------------------------------------
  -- receive enable registered
  ---------------------------------------------------------------------
  ren_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        ren_r <= '0';
    elsif clk'event and clk='1' then

        if rsm=RSM_IDLE then
          ren_r <= ren;
        end if;
    end if;
  end process; -- ren_reg_proc



--===================================================================--
--                         address filtering                         --
--===================================================================--
    
  ---------------------------------------------------------------------
  -- address filtering state machine
  ---------------------------------------------------------------------
  fsm_proc:
  process(
            fsm, rsm, ho, hp, dest, lcnt, ncnt, flcnt,
            perfm, hash, pr, fa, invm, rif, matchval, match
         )
  begin
    case fsm is
      -------------------------------------------
      when FSM_IDLE =>
      -------------------------------------------
        if lcnt(2 downto 0)="101" and ncnt(0)='1' then
          if pr='1' then
            fsm_c <= FSM_MATCH;
          elsif ho='1' or (hp='1' and dest(0)='1') then
            fsm_c <= FSM_HASH;
          elsif hp='0' then
            fsm_c <= FSM_PERF16;
          else
            fsm_c <= FSM_PERF1;
          end if;
        else
          fsm_c <= FSM_IDLE;
        end if;
      
      -------------------------------------------
      when FSM_PERF1 =>
      -------------------------------------------
        if fa="101100" then
          if perfm='1' or (matchval='1' and match='1') then
            fsm_c <= FSM_MATCH;
          else
            fsm_c <= FSM_FAIL;
          end if;
        else
          fsm_c <= FSM_PERF1;
        end if;
      
      -------------------------------------------
      when FSM_PERF16 =>
      -------------------------------------------
        if (flcnt="010" and perfm='1' and rif='0') or
           (fa="110010" and rif='1' and invm='1') or
           (matchval='1' and match='1')
        then
          fsm_c <= FSM_MATCH;
        elsif fa="110010" then
          fsm_c <= FSM_FAIL;
        else
          fsm_c <= FSM_PERF16;
        end if;
      
      -------------------------------------------
      when FSM_HASH =>
      -------------------------------------------
        if matchval='1' and match='1' then
          fsm_c <= FSM_MATCH;
        elsif flcnt="101" then
          if hash='1' then
            fsm_c <= FSM_MATCH;
          else
            fsm_c <= FSM_FAIL;
          end if;
        else
          fsm_c <= FSM_HASH;
        end if;
      
      -------------------------------------------
      when FSM_MATCH =>
      -------------------------------------------
        if rsm=RSM_IDLE then
          fsm_c <= FSM_IDLE;
        else
          fsm_c <= FSM_MATCH;
        end if;
      
      -------------------------------------------
      when others => -- FSM_FAIL
      -------------------------------------------
        if rsm=RSM_IDLE then
          fsm_c <= FSM_IDLE;
        else
          fsm_c <= FSM_FAIL;
        end if;
    end case;
  end process; -- fsm_proc
  
  ---------------------------------------------------------------------
  -- address filtering state machine registered
  ---------------------------------------------------------------------  
  fsm_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        fsm <= FSM_IDLE;
    elsif clk'event and clk='1' then

        fsm <= fsm_c;
    end if;
  end process; -- fsm_reg_proc
  
  ---------------------------------------------------------------------
  -- 3 least significant bits of byte counter
  ---------------------------------------------------------------------
  bcnt20_drv:
    bcnt20 <= bcnt(2 downto 0);
  
  ---------------------------------------------------------------------
  -- destination address registered
  ---------------------------------------------------------------------
  dest_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        dest <= (others=>'0');
    elsif clk'event and clk='1' then

        if rsm=RSM_DEST then
          if ncnt(0)='0' then
            case bcnt20 is  
              when "101"  => dest( 3 downto  0) <= rxd_r;
              when "100"  => dest(11 downto  8) <= rxd_r;
              when "011"  => dest(19 downto 16) <= rxd_r;
              when "010"  => dest(27 downto 24) <= rxd_r;
              when "001"  => dest(35 downto 32) <= rxd_r;
              when others => dest(43 downto 40) <= rxd_r;
            end case;
          else
            case bcnt20 is  
              when "101"  => dest( 7 downto  4) <= rxd_r;
              when "100"  => dest(15 downto 12) <= rxd_r;
              when "011"  => dest(23 downto 20) <= rxd_r;
              when "010"  => dest(31 downto 28) <= rxd_r;
              when "001"  => dest(39 downto 36) <= rxd_r;
              when others => dest(47 downto 44) <= rxd_r;
            end case;
          end if;
        end if;
    end if;
  end process; -- dest_reg_proc;
  
  ---------------------------------------------------------------------
  -- hash filtering registered
  ---------------------------------------------------------------------
  hash_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        crchash <= (others=>'0');
        hash    <= '0';
        fdata_r <= (others=>'0');
    elsif clk'event and clk='1' then

        -- crc value for addressing hash table
        if fsm=FSM_HASH and flcnt="000" then
          crchash <= crc(23) &
                     crc(24) &
                     crc(25) &
                     crc(26) &
                     crc(27) &
                     crc(28) &
                     crc(29) &
                     crc(30) &
                     crc(31);
         end if;
         
         -- hash value
         hash <= fdata_r(CONV_INTEGER(crchash(3 downto 0)));
         
         -- filtering RAM data
         fdata_r <= fdata;
    end if;
  end process; -- crchash_reg_proc



  -- perfect filtering match combinatorial
  ---------------------------------------------------------------------
  perfm_proc:
  process(perfm, flcnt, fsm, fdata_r, dest)
  begin
    perfm_c <= perfm;
    if
      (flcnt="001" and fdata_r/=dest(47 downto 32)) or
      (flcnt="000" and fdata_r/=dest(31 downto 16)) or
      (flcnt="010" and fdata_r/=dest(15 downto 0)) or
      fsm=FSM_IDLE
    then
      perfm_c <= '0';
    elsif flcnt="010" and fdata_r=dest(15 downto 0) then
      perfm_c <= '1';
    end if;
  end process; -- perfm_proc
  
  ---------------------------------------------------------------------
  -- perfect match registered
  ---------------------------------------------------------------------  
  perfm_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        perfm <= '0';
        invm  <= '0';
    elsif clk'event and clk='1' then

      
        -- perfect match
        perfm <= perfm_c;
        
        -- inverse perfect match
        if fsm=FSM_IDLE then
          invm <= '1';
        elsif flcnt="001" and perfm_c='1' then
          invm <= '0';
        end if;
    end if;
  end process; -- perfm_reg_proc

  ---------------------------------------------------------------------
  -- filtering ram address registered
  ---------------------------------------------------------------------
  fa_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        flcnt <= (others=>'0');
        fa    <= (others=>'0');
    elsif clk'event and clk='1' then

        -- filtering ram address
        case fsm is
          ---------------------------------------
          when FSM_PERF1 | FSM_PERF16 =>
          ---------------------------------------
            fa <= fa+1;
          
          ---------------------------------------
          when FSM_HASH =>
          ---------------------------------------
            fa(5 downto 0) <= '0' & crchash(8 downto 4);
          
          ---------------------------------------
          when others =>
          ---------------------------------------
            if (hp='1' and dest(0)='0') then
              fa <= PERF1_ADDR;
            else
              fa <= (others=>'0');
            end if;
        end case;
        
        -- filtering ram 16-bit word counter
        if fsm_c=FSM_IDLE or
           (flcnt="010" and fsm_c=FSM_PERF16) or
           (flcnt="010" and fsm_c=FSM_PERF1)
        then
          flcnt <= (others=>'0');
        elsif fsm=FSM_PERF1 or fsm=FSM_PERF16 or fsm=FSM_HASH then
          flcnt <= flcnt+1;
        end if;
    end if;
  end process; -- fa_reg_proc

  ---------------------------------------------------------------------
  -- Filter address
  -- registered output
  ---------------------------------------------------------------------
  faddr_drv:
    faddr <= fa;



--===================================================================--
--                      external address filtering                   --
--===================================================================--
  
  ---------------------------------------------------------------------
  -- match data
  -- registered output
  ---------------------------------------------------------------------
  matchdata_drv:
    matchdata <= dest;
  
  ---------------------------------------------------------------------
  -- match enable
  -- registered output
  ---------------------------------------------------------------------
  matchen_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        matchen <= '0';
    elsif clk'event and clk='1' then

        if fsm=FSM_PERF1 or fsm=FSM_HASH or fsm=FSM_PERF16 then
          matchen <= '1';
        else
          matchen <= '0';
        end if;
    end if;
  end process; -- matchen_reg_proc
    


--===================================================================--
--                           power management                        --
--===================================================================--

  ---------------------------------------------------------------------
  -- stop registered
  ---------------------------------------------------------------------
  stop_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        stop_r <= '0';
        stopo  <= '0';
    elsif clk'event and clk='1' then

      
        -- stop input
        stop_r <= stopi;
        
        -- stop output
        if stop_r='1' and rsm=RSM_IDLE then
          stopo <= '1';
        else
          stopo <= '0';
        end if;
    end if;
  end process; -- stop_reg_proc



--===================================================================--
--                              timers                               --
--===================================================================--
  
  ---------------------------------------------------------------------
  -- receive cycle size counter registered
  ---------------------------------------------------------------------  
  rcscnt_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        rcscnt   <= (others=>'0');
        rcs      <= '0';
        rcsreq   <= '0';
        rcsack_r <= '0';
    elsif clk'event and clk='1' then

        -- receive cycle size counter registered
        if rcscnt="00000000" then
          rcscnt <= "10000000";
        else
          rcscnt <= rcscnt-1;
        end if;
        
        -- cycle size indicator
        if rcscnt="00000000" then
          rcs <= '1';
        elsif rcsack_r='1' then
          rcs <= '0';
        end if;
        
        -- cycle size request
        if rcs='1' and rcsack_r='0' then
          rcsreq <= '1';
        elsif rcsack_r='1' then
          rcsreq <= '0';
        end if;
        
        -- cycle size acknowledge
        rcsack_r <= rcsack;
    end if;
  end process; -- rcscnt_reg_proc
  
  
--===================================================================--
--                         statistical counters                      --
--===================================================================--

  ---------------------------------------------------------------------
  -- fifo overflow counter
  ---------------------------------------------------------------------
  focnt_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        focnt  <= (others=>'0');
        oco    <= '0';
        focl_r <= '0';
        focg   <= (others=>'0');
    elsif clk'event and clk='1' then

      
        -- fifo overflow counter
        if focl_r='1' then
          focnt <= (others=>'0');
        elsif (
                rsm=RSM_DEST or rsm=RSM_SOURCE or
                rsm=RSM_LENGTH or rsm=RSM_INFO or rsm=RSM_SFD
              ) and full='1' -- and   cachenf_2r='1'
        then
          focnt <= focnt + 1;
        end if;
        
        --vnavigatoroff
        -- fifo overflow counter overflow
        if focl_r='1' then
          oco <= '0';
        elsif (
                rsm=RSM_DEST or rsm=RSM_SOURCE or
                rsm=RSM_LENGTH or rsm=RSM_INFO
              ) and (full='1' or cachenf_r='0') and focnt="11111111111"
        then
          oco <= '1';
        end if;
        --vnavigatoron
        
        -- fifo overflow counter clear
        focl_r <= focl;
        
        -- fifo overflow counter grey coded
        focg(10) <= focnt(10);
        for i in 9 downto 0 loop
          focg(i) <= focnt(i) xor focnt(i+1);
        end loop;
    end if;
  end process; -- focnt_reg_proc
  ---------------------------------------------------------------------
  -- missed frames counter
  ---------------------------------------------------------------------
  mfcnt_reg_proc:


process(clk, rst)
begin
	if rst = '0' then
		mfcnt  <= (others=>'0');
		mfo    <= '0';
		mfcl_r <= '0';
		mfcg   <= (others=>'0');
	elsif clk'event and clk='1' then
		-- missed frames counter
		if mfcl_r='1' then
		       mfcnt <= (others=>'0');
		elsif eorfff='1' and (pb='1' or winp='1') and
		            (
		               fsm=FSM_MATCH or ra='1' or
		               (pm='1' and dest(0)='1')
		            )
		       then
		       mfcnt <= mfcnt + 1;
		end if;
		       
		--vnavigatoroff
		-- missed frames counter overflow
		if mfcl_r='1' then
			mfo <= '0';
		elsif mfcnt="1111111111111111" and pb='1' and
		            (
		               fsm=FSM_MATCH or ra='1' or
		               (pm='1' and dest(0)='1')
		            )
		       then
		  	mfo <= '1';
		end if;
		
		--vnavigatoron
		    
		-- missed frames counter clear
		mfcl_r <= mfcl;
		       
		-- missed frames counter grey coded
		mfcg(15) <= mfcnt(15);
		for i in 14 downto 0 loop
			mfcg(i) <= mfcnt(i) xor mfcnt(i+1);
		end loop;
  	end if;
	

end process; -- mfcnt_reg_proc

  ---------------------------------------------------------------------
  -- missed frames counter clear acknowledge
  ---------------------------------------------------------------------
  mfclack_drv:
    mfclack <= mfcl_r;
  
  ---------------------------------------------------------------------
  -- fifo overflow counter clear acknowledge
  ---------------------------------------------------------------------
  foclack_drv:
    foclack <= focl_r;
  


--===================================================================--
--                               others                              --
--===================================================================--

  ---------------------------------------------------------------------
  -- all zeros vector for fifo
  ---------------------------------------------------------------------
  fzero_drv:
    fzero <= (others=>'0');
  
end RTL;
--*******************************************************************--
