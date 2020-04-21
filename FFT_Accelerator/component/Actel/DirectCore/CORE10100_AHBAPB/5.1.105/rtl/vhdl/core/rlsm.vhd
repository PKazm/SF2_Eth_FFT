-- ********************************************************************/ 
-- Copyright 2013 Actel Corporation.  All rights reserved.
-- IP Solutions Group
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED 
-- IN ADVANCE IN WRITING.  
--  
-- File:  rlsm.vhd
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
--  v3.0 Includes SARS 57010 and 57013
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
-- File name            : lsm.vhd
-- File contents        : Entity lsm
--                        Architecture RTL of lsm
-- Purpose              : Receive linked List Management for MAC
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
-- 2003.03.21 : T.K. - references to 64-bit wide data bus removed
-- 2003.03.21 : T.K. - watchdog functionality removed
-- 2003.03.21 : T.K. - missed frames counter added from rc.vhd
-- 2003.03.21 : T.K. - "own_proc" process changed
-- 2.00.E02   :
-- 2003.04.15 : T.K. - lsm proc changed for LSM_NXT state
-- 2003.04.15 : T.K. - fifolev unused port removed
-- 2003.04.15 : T.K. - synchronous processes merged
-- 2.00.E03   :
-- 2003.05.12 : T.K. - condition for entering stopped state changed
-- 2003.05.12 : T.K. - lsm_proc: condition for LSM_IDLE changed
-- 2003.05.12 : T.K. - stat_reg_proc: fbuf changed
-- 2.00.E06   :  
-- 2004.01.20 : T.K. - fixed mfc counter (F200.05.mfc) &
--              B.W.   statistical counters module integration
--                     support (I200.05.sc) :
--                      * cachenf input added 
--                      * mfc related ports removed
--                      * mfcnt_reg_proc process moved to RC component                    
--
-- 2004.01.20 : T.K. - fixed receive fifo data overwriting (F200.05.rfifo)
--                      * fifo level changed to combinatorial
--
-- 2004.01.20 : T.K. - fixed receive address changing in unstopped states 
--                     (F200.05.rxaddrchange):
--                      * lsm_proc: condition for LSM_BUF1 and LSM_BUF2 
--
-- 2004.01.20 : B.W. - RTL code changes due to VN Check
--                     and code coverage (I200.06.vn)
--                      * dmaaddro_proc process changed
--                      * own_proc process changed
--                      * whole_proc process changed
-- 
-- 2.00.E06a  :
-- 2004.02.20 : T.K. - cs collision seen functionality fixed (F200.06.cs)
--                      * cs port added
--                      * fstat_drv assignment changed
--
-- 2004.02.20 : T.K. - receive error summary fixed (F200.06.es)
--                      * res_drv assignment changed
-- 2.00.E07   :
-- 2004.03.22 : T.K. - unused comments removed
-- 2.00.E08   :
-- 2004.06.07 : T.K. - fifolev_r signal registered (F200.08.fivolev)
--                      * fbcnt_c signal added
--                      * length_r signal added
--                      * fbcnt_reg_proc process changed
--                      * fifolev_reg_proc process changed
--                      * fbcnt_proc process added
--                      * fifolev_drv assignment removed
--*******************************************************************--

library IEEE;
  use work.utility.all;
  use ieee.std_logic_1164.all; 
  use IEEE.STD_LOGIC_UNSIGNED."-";
  use IEEE.STD_LOGIC_UNSIGNED."+";



  --*****************************************************************--
  entity RLSM is
    generic(
            -- Data interface data bus width
            DATAWIDTH : INTEGER := 32; -- 8|16|32|64
            -- Data interface address bus width
            DATADEPTH : INTEGER := 32;
            -- Depth of FIFO memory
            FIFODEPTH : INTEGER := 9
    );
    port (  
            ------------------------ common ---------------------------
            -- global clock
            clk       : in  STD_LOGIC;
            -- hardware reset
            rst       : in  STD_LOGIC;
            
            ------------------------- fifo ----------------------------
            -- frame status cache not full
            cachenf   : in  STD_LOGIC;
            -- fifo data
            fifodata  : in  STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
            -- fifo read enable
            fifore    : out STD_LOGIC;
            -- status cache read enable
            cachere   : out STD_LOGIC;
            
            -------------------------- dma ----------------------------
            -- single transfer acknowledge
            dmaack    : in  STD_LOGIC;
            -- end of burst
            dmaeob    : in  STD_LOGIC;
            -- data input
            dmadatai  : in  STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
            -- current burst address
            dmaaddr   : in  STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
            -- request
            dmareq    : out STD_LOGIC;
            -- write selection
            dmawr     : out STD_LOGIC;
            -- transfer count
            dmacnt    : out STD_LOGIC_VECTOR(FIFODEPTH_MAX-1 downto 0);
            -- start address
            dmaaddro  : out STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
            -- data output
            dmadatao  : out STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
            
            --------------------- receive status ----------------------
            -- receive in progress
            rprog     : in  STD_LOGIC;
            -- rc poll
            rcpoll    : in  STD_LOGIC;
            -- frame cache not empty
            fifocne   : in  STD_LOGIC;
            -- filtering fail
            ff        : in  STD_LOGIC;
            -- runt frame
            rf        : in  STD_LOGIC;
            -- multicast frame
            mf        : in  STD_LOGIC;
            -- dribbling bit
            db        : in  STD_LOGIC;
            -- mii error
            re        : in  STD_LOGIC;
            -- crc error
            ce        : in  STD_LOGIC;
            -- frame too long
            tl        : in  STD_LOGIC;
            -- frame type
            ftp       : in  STD_LOGIC;
            -- fifo overflow
            ov        : in  STD_LOGIC;
            -- collision seen
            cs        : in  STD_LOGIC;
            -- length of frame
            length    : in  STD_LOGIC_VECTOR(13 downto 0);
            
            -------------------- csr configuration --------------------
            -- programmable burst length
            pbl       : in  STD_LOGIC_VECTOR(5 downto 0);
            -- descriptor skip length
            dsl       : in  STD_LOGIC_VECTOR(4 downto 0);
            -- receive pool demand
            rpoll     : in  STD_LOGIC;
            -- receive descriptor base address changed
            rdbadc    : in  STD_LOGIC;
            -- receive descriptors base address
            rdbad     : in  STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
            -- receive poll acknowledge
            rpollack  : out STD_LOGIC;
            
            ------------------------ csr status -----------------------
            -- receive completition acknowledge
            rcompack  : in  STD_LOGIC;
            -- buffer completition acknowledge
            bufack    : in  STD_LOGIC;
            -- fetching descriptor
            des       : out STD_LOGIC;
            -- fetching buffer
            fbuf      : out STD_LOGIC;
            -- writing descriptor status
            stat      : out STD_LOGIC;
            -- descriptor unavailable
            ru        : out STD_LOGIC;
            -- receive completition
            rcomp     : out STD_LOGIC;
            -- buffer completition
            bufcomp   : out STD_LOGIC;
            
            --------------------- power management --------------------
            -- stop receive process input
            stopi    : in  STD_LOGIC;
            -- stop receive process output
            stopo    : out STD_LOGIC
    );
  end RLSM;


--*******************************************************************--
architecture RTL of RLSM is  
  
  
  ------------------------------ lsm ----------------------------------
  -- receive linked list state machine combinatorial
  signal lsm_c       : LSMT;
  -- receive linked list state machine registered
  signal lsm         : LSMT;
  -- receive linked list state machine double registered
  signal lsm_r       : LSMT;
  -- ownership combinatorial
  signal own_c       : STD_LOGIC;
  -- ownership registered
  signal own         : STD_LOGIC;
  -- chained regsistered
  signal rch         : STD_LOGIC;
  -- end of ring registered
  signal rer         : STD_LOGIC;
  -- last segment registered
  signal rls         : STD_LOGIC;
  -- first segment registered
  signal rfs         : STD_LOGIC;
  -- receive descriptor error registered
  signal rde         : STD_LOGIC;
  -- receive error summary
  signal res_c       : STD_LOGIC;
  -- receive buffer 1 size registered
  signal bs1         : STD_LOGIC_VECTOR(10 downto 0);
  -- receive buffer 1 size registered
  signal bs2         : STD_LOGIC_VECTOR(10 downto 0);
  
  --------------------------- lsm addresses ---------------------------
  -- address write enabl
  signal adwrite     : STD_LOGIC;
  -- receive buffer address registered
  signal bad         : STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
  -- receive descriptor address registered
  signal dad         : STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
  -- receive buffer counter
  signal bcnt        : STD_LOGIC_VECTOR(10 downto 0);
  -- frame status
  signal statad      : STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
  -- temporary status address
  signal tstatad     : STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
  -- descriptor base address changed registered
  signal dbadc_r     : STD_LOGIC;
  
  -------------------------------- dma --------------------------------
  -- internal dma request combinatorial
  signal req_c       : STD_LOGIC;
  -- internal dma request registered
  signal req         : STD_LOGIC;
  -- 3 low significant bits of dma address
  signal dmaaddr20   : STD_LOGIC_VECTOR(2 downto 0);
  -- 2 least significant bits of dma address
  signal addr10      : STD_LOGIC_VECTOR(1 downto 0);
  -- dmadatai of maximum length
  signal dmadatai_max : STD_LOGIC_VECTOR(DATAWIDTH_MAX downto 0);
  -- data input extended to DATADEPTH_MAX registered
  signal dataimax_r  : STD_LOGIC_VECTOR(DATADEPTH_MAX-1 downto 0);
  -- frame status
  signal fstat       : STD_LOGIC_VECTOR(31 downto 0);
  
  -------------------------- receive control --------------------------
  -- receive in progress registered
  signal rprog_r     : STD_LOGIC;
  -- receive in progress registered
  signal rcpoll_r    : STD_LOGIC;
  -- receive in progress double registered
  signal rcpoll_r2   : STD_LOGIC;
  -- whole frame transferred
  signal whole       : STD_LOGIC;
  
  ------------------------------- fifo --------------------------------
  -- fifo level registered
  signal fifolev_r   : STD_LOGIC_VECTOR(13 downto 0);
  -- fifo byte counter registered
  signal fbcnt       : STD_LOGIC_VECTOR(13 downto 0);
  -- fifo byte counter combinatorial
  signal fbcnt_c     : STD_LOGIC_VECTOR(13 downto 0);
  -- length of the frame registered
  signal length_r    : STD_LOGIC_VECTOR(13 downto 0);
  -- internal fifo read enable
  signal ififore     : STD_LOGIC;
  -- internal fifo read enable registered
  signal ififore_r   : STD_LOGIC;
  -- internal cache read enable
  signal icachere    : STD_LOGIC;
  -- buffer byte size extended to FIFODEPTH_MAX
  signal bsmax       : STD_LOGIC_VECTOR(FIFODEPTH_MAX-1 downto 0);
  -- free space in fifo extended to FIFODEPTH_MAX
  signal flmax       : STD_LOGIC_VECTOR(FIFODEPTH_MAX-1 downto 0);
  -- programmable burst length extended to FIFODEPTH_MAX
  signal blmax       : STD_LOGIC_VECTOR(FIFODEPTH_MAX-1 downto 0);
  -- free space in fifo greater then 16
  signal fl_g_16     : STD_LOGIC;
  -- free space in fifo greater then buffer byte size
  signal fl_g_bs     : STD_LOGIC;
  -- free space in fifo greater then programmable burst length
  signal fl_g_bl     : STD_LOGIC;
  -- programmable burst length greater then buffer byte size
  signal bl_g_bs     : STD_LOGIC;
  -- programmable burst length=0 registered
  signal pblz        : STD_LOGIC;

  
  ------------------------- power management --------------------------
  -- stop receive process registered
  signal stop_r      : STD_LOGIC;
  
  ------------------------------ others -------------------------------
  -- zero vector of DATAWIDTH_MAX length
  signal dzero_max   : STD_LOGIC_VECTOR(DATAWIDTH_MAX downto 0);
  -- zero vector of FIFODEPTH_MAX length
  signal fzero_max   : STD_LOGIC_VECTOR(FIFODEPTH_MAX-1 downto 0);


begin

  --=================================================================--
  --                             dma                                 --
  --=================================================================--

  ---------------------------------------------------------------------
  -- dma data input registered
  ---------------------------------------------------------------------
  dataimax_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        dataimax_r <= (others=>'1');
    elsif clk'event and clk='1' then

        case DATAWIDTH is
          ---------------------------------------
          when 8 =>
          ---------------------------------------
            case dmaaddr20 is
              when "000" | "100" =>
                dataimax_r(7 downto 0) <= dmadatai;
              when "001" | "101" =>
                dataimax_r(15 downto 8) <= dmadatai;
              when "010" | "110" =>
                dataimax_r(23 downto 16) <= dmadatai;
              when others => -- "011"|"111"
                dataimax_r(31 downto 24) <= dmadatai;
            end case;
          ---------------------------------------
          when 16 =>
          ---------------------------------------
            if dmaaddr(1)='0' then
              dataimax_r(15 downto 0) <= dmadatai;
            else
              dataimax_r(31 downto 16) <= dmadatai;
            end if;
          ---------------------------------------
          when others => -- 32
          ---------------------------------------
            dataimax_r <= dmadatai(31 downto 0);
        end case;
    end if;
  end process; -- dataimax_r

  ---------------------------------------------------------------------
  -- fifo level registered
  ---------------------------------------------------------------------
  fifolev_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        fl_g_bs   <= '0';
        fl_g_16   <= '0';
        fl_g_bl   <= '0';
        bl_g_bs   <= '0';
        fifolev_r <= (others=>'0');
        length_r <= (others=>'0');
        pblz      <= '0';
    elsif clk'event and clk='1' then

        -- length of the frame registered
        length_r <= length;
        
        -- fifo level
        fifolev_r <= length_r - fbcnt_c;
        
        -- fifo level greater then buffer size
        if flmax >= bsmax then
          fl_g_bs <= '1';
        else
          fl_g_bs <= '0';
        end if;
        
        -- fifo level greater then 64 bytes
        case DATAWIDTH is
          ---------------------------------------
          when 8 =>
          ---------------------------------------
            if flmax > (fzero_max(FIFODEPTH_MAX-1 downto 6) & "111111")
            then
              fl_g_16 <= '1';
            else
              fl_g_16 <= '0';
            end if;
          ---------------------------------------
          when 16 =>
          ---------------------------------------
            if flmax > (fzero_max(FIFODEPTH_MAX-1 downto 5) & "11111")
            then
              fl_g_16 <= '1';
            else
              fl_g_16 <= '0';
            end if;
          ---------------------------------------
          when others => -- 32
          ---------------------------------------
            if flmax > (fzero_max(FIFODEPTH_MAX-1 downto 4) & "1111")
            then
              fl_g_16 <= '1';
            else
              fl_g_16 <= '0';
            end if;
        end case;
        
        -- fifo level greater then programmable burst length
        if flmax >= blmax+1 then
          fl_g_bl <= '1';
        else
          fl_g_bl <= '0';
        end if;
        
        -- programmable burst length greater then buffer size
        if blmax >= bsmax then
          bl_g_bs <= '1';
        else
          bl_g_bs <= '0';
        end if;
        
        -- programmable burst length=0
        if pbl="000000" then
          pblz <= '1';
        else
          pblz <= '0';
        end if;
    end if;
  end process; -- fifolev_reg_proc

  ---------------------------------------------------------------------
  -- fifo level extended to FIFODEPTH_MAX
  ---------------------------------------------------------------------
  flmax_drv:
    flmax <=
        fzero_max(FIFODEPTH_MAX-1 downto 14) & fifolev_r               when DATAWIDTH=8 else
        fzero_max(FIFODEPTH_MAX-1 downto 13) & fifolev_r(13 downto 1)  when DATAWIDTH=16 else
        fzero_max(FIFODEPTH_MAX-1 downto 12) & fifolev_r(13 downto 2);
  
  ---------------------------------------------------------------------
  -- programmable burst length extended to FIFODEPTH_MAX
  ---------------------------------------------------------------------
  blmax_drv:
    blmax <= fzero_max(FIFODEPTH_MAX-1 downto 6) & pbl;
  
  ---------------------------------------------------------------------
  -- buffer size extended to FIFODEPTH_MAX
  ---------------------------------------------------------------------
  bsmax_drv:
    bsmax <= fzero_max(FIFODEPTH_MAX-1 downto 11) & bcnt
               when DATAWIDTH=8 else
             fzero_max(FIFODEPTH_MAX-1 downto 10) & bcnt(10 downto 1)
               when DATAWIDTH=16 else
             fzero_max(FIFODEPTH_MAX-1 downto  9) & bcnt(10 downto 2);
  
  ---------------------------------------------------------------------
  -- dma counter
  -- combinatorial output
  ---------------------------------------------------------------------
  dmacnt_proc:
  process(
           lsm, fl_g_bs, fl_g_bl, bl_g_bs, pblz,
           blmax, bsmax, flmax, fzero_max
         )
  begin
    
    -- descriptor fetch -------------------------
    if lsm=LSM_DES0 or lsm=LSM_DES1 or
       lsm=LSM_DES2 or lsm=LSM_DES3 or
       lsm=LSM_STAT or lsm=LSM_FSTAT or
       lsm=LSM_DES0P
    then
      case DATAWIDTH is
        -----------------------------------------
        when  8     =>
        -----------------------------------------
          dmacnt <= fzero_max(FIFODEPTH_MAX-1 downto 3) & "100";
        -----------------------------------------
        when 16     =>
        -----------------------------------------
          dmacnt <= fzero_max(FIFODEPTH_MAX-1 downto 3) & "010";
        -----------------------------------------
        when others => -- 32
        -----------------------------------------
          dmacnt <= fzero_max(FIFODEPTH_MAX-1 downto 3) & "001";
      end case;
      
    -- buffer fetch -----------------------------
    else
      -- unlimited burst
      if pblz='1' then
        -- fifo level greater then buffer size
        if fl_g_bs='1' then
          dmacnt <= bsmax;
        -- fifo level less then buffer size
        else
          dmacnt <= flmax;
        end if;
      -- programmable burst length
      else
        -- fifo level greater then programmable burst length
        if fl_g_bl='1' then
          -- programmable burst length greater then buffer size
          if bl_g_bs='1' then
            dmacnt <= bsmax;
          -- programmable burst length less then buffer size
          else
            dmacnt <= blmax;
          end if;
        -- fifo level less then programmable burst length
        else
          -- fifo level greater then buffer size
          if fl_g_bs='1' then
            dmacnt <= bsmax;
          -- fifo level less then buffer size
          else
            dmacnt <= flmax;
          end if;
        end if;
      end if;
    end if;
  end process; -- dmacnt_proc
  
  ---------------------------------------------------------------------
  -- internal dma request combinatorial
  ---------------------------------------------------------------------
  req_proc:
  process(
           req, lsm, fifocne, fl_g_bl, fl_g_16, pblz,
           rprog_r, dmaack, dmaeob, whole, flmax, fzero_max
         )
  begin
  
    case lsm is
      -------------------------------------------
      when LSM_BUF1 | LSM_BUF2 =>
      -------------------------------------------
        if dmaack='1' and dmaeob='1' then
          req_c <= '0';
        elsif fifocne='1' or
              (
                rprog_r='1' and
                (
                  (fl_g_bl='1' and pblz='0') or
                  (fl_g_16='1' and pblz='1')
                )
              )
        then
          req_c <= '1';
        else
          req_c <= req;
        end if;
        
      -------------------------------------------
      when LSM_DES0 | LSM_DES1 | LSM_DES2 |
           LSM_DES3 | LSM_STAT | LSM_DES0P =>
      -------------------------------------------
        if dmaack='1' then
          req_c <= '0';
        else
          req_c <= '1';
        end if;
      
      -------------------------------------------
      when LSM_FSTAT =>
      -------------------------------------------
        if     dmaack='1' 
		  or   whole='0' 
		  -- SAR 57103
		  --  It is unclear why these two lines are needed. 
		  --  SAR57010 fixes the misaligned packet problem instead now
		  
		  --or ( DATAWIDTH=8 and flmax(1 downto 0) /= fzero_max(1 downto 0) )
          --or (DATAWIDTH=16 and flmax(1) /= fzero_max(1) )
        then
          req_c <= '0';
        else
          req_c <= '1';
        end if;
        
      -------------------------------------------
      when others => -- LSM_IDLE
      -------------------------------------------
        req_c <= '0';
    end case;
  end process; -- req_proc

  ---------------------------------------------------------------------
  -- dma request registered
  ---------------------------------------------------------------------
  req_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        req <= '0';
    elsif clk'event and clk='1' then

        req <= req_c;
    end if;
  end process; -- req_reg_proc

  ---------------------------------------------------------------------
  -- dma address
  -- combinatorial output
  ---------------------------------------------------------------------
  dmaaddro_proc:
  process(lsm, bad, dad, statad)
  begin
    dmaaddro <= dad;
    case lsm is
      -------------------------------------------
      when LSM_BUF1 | LSM_BUF2 =>
      -------------------------------------------
        dmaaddro <= bad;
      -------------------------------------------
      when LSM_STAT | LSM_FSTAT =>
      -------------------------------------------
        dmaaddro <= statad;
      -------------------------------------------
      when others => -- LSM_DES0|LSM_DES1|LSM_DES2|LSM_DES3|LSM_DES0P
      -------------------------------------------
        null;
    end case;
  end process; -- dmaaddro_proc
  
  ---------------------------------------------------------------------
  -- frame status
  ---------------------------------------------------------------------
  fstat_drv:
    fstat <= '0' & ff & length & res_c & rde &
             RDES0_RV(13 downto 12) & rf & mf & rfs & rls & tl &
             cs & ftp & RDES0_RV(4) & re & db & ce & ov;

  ---------------------------------------------------------------------
  -- dma write selection
  -- combinatorial output
  ---------------------------------------------------------------------
  dmawr_proc:
    dmawr <= '1' when lsm=LSM_STAT or lsm=LSM_FSTAT or
                      lsm=LSM_BUF1 or lsm=LSM_BUF2 else
             '0';
  
  ---------------------------------------------------------------------
  -- dma data output
  -- combinatorial output
  ---------------------------------------------------------------------
  dmadatao_proc:
  process(fifodata, lsm, addr10, fstat)
  begin
    if lsm=LSM_BUF1 or lsm=LSM_BUF2 then
        dmadatao <= fifodata;
    else
      case DATAWIDTH is
        -----------------------------------------
        when 8 =>
        -----------------------------------------
          case addr10 is
            when "00"   =>
              dmadatao <= fstat( 7 downto  0);
            when "01"   =>
              dmadatao <= fstat(15 downto  8);
            when "10"   =>
              dmadatao <= fstat(23 downto 16);
            when others =>
              dmadatao <= fstat(31 downto 24);
          end case;
          
        -----------------------------------------
        when 16 =>
        -----------------------------------------
          if addr10="00" then
            dmadatao <= fstat(15 downto  0);
          else
            dmadatao <= fstat(31 downto 16);
          end if;
          
        -----------------------------------------
        when others => -- 32
        -----------------------------------------
          dmadatao <= fstat;
      end case;
    end if;
  end process; -- dmadatao_proc
  
  ---------------------------------------------------------------------
  -- dma request
  -- registered output
  ---------------------------------------------------------------------
  dmareq_drv:
    dmareq <= req;
    



--===================================================================--
--                                 lsm                               --
--===================================================================--

  ---------------------------------------------------------------------
  -- receive linked list state machine combinatorial
  ---------------------------------------------------------------------
  lsm_proc:
  process(lsm, rcpoll_r, rcpoll_r2, rpoll, dmaack, dmaeob,
          own_c, bs1, bs2, whole, rch, stop_r, own, bcnt, dbadc_r)
  begin
    case lsm is
      -------------------------------------------
      when LSM_IDLE =>
      -------------------------------------------
        if dbadc_r='0' and stop_r='0' and
           (
             (rcpoll_r='1' and rcpoll_r2='0') or rpoll='1'
           )
        then
          lsm_c <= LSM_DES0;
        else
          lsm_c <= LSM_IDLE;
        end if;
      
      -------------------------------------------
      when LSM_DES0 =>
      -------------------------------------------
        if dmaack='1' and dmaeob='1' then
          if own_c='1' then
            lsm_c <= LSM_DES1;
          else
            lsm_c <= LSM_IDLE;
          end if;
        else
          lsm_c <= LSM_DES0;
        end if;
      
      -------------------------------------------
      when LSM_DES0P =>
      -------------------------------------------
        if dmaack='1' and dmaeob='1' then
          if own_c='0' or whole='1' then
            lsm_c <= LSM_FSTAT;
          else
            lsm_c <= LSM_STAT;
          end if;
        else
          lsm_c <= LSM_DES0P;
        end if;
      
      -------------------------------------------
      when LSM_DES1 =>
      -------------------------------------------
        if dmaack='1' and dmaeob='1' then
          lsm_c <= LSM_DES2;
        else
          lsm_c <= LSM_DES1;
        end if;
      
      -------------------------------------------
      when LSM_DES2 =>
      -------------------------------------------
        if dmaack='1' and dmaeob='1' then
          if bs1="00000000000" then
            lsm_c <= LSM_DES3;
          else
            lsm_c <= LSM_BUF1;
          end if;
        else
          lsm_c <= LSM_DES2;
        end if;
      
      -------------------------------------------
      when LSM_DES3 =>
      -------------------------------------------
        if dmaack='1' and dmaeob='1' then
          if bs2/="00000000000" and rch='0' then
            lsm_c <= LSM_BUF2;
          else
            lsm_c <= LSM_NXT;
          end if;
        else
          lsm_c <= LSM_DES3;
        end if;
      
      -------------------------------------------
      when LSM_BUF1 =>
      -------------------------------------------
        if whole='1' or bcnt="00000000000" then
          lsm_c <= LSM_DES3;
        elsif dbadc_r='1' then	
          lsm_c <= LSM_IDLE	;
        else
          lsm_c <= LSM_BUF1;
        end if;
      
      -------------------------------------------
      when LSM_BUF2 =>
      -------------------------------------------
        if whole='1' or bcnt="00000000000" then
          lsm_c <= LSM_NXT;
        elsif dbadc_r='1' then	
          lsm_c <= LSM_IDLE	;
        else
          lsm_c <= LSM_BUF2;
        end if;
      
      -------------------------------------------
      when LSM_NXT =>
      -------------------------------------------
        if whole='1' then
          if stop_r='1' then
            lsm_c <= LSM_FSTAT;
          else
            lsm_c <= LSM_DES0P;
          end if;
        else
          lsm_c <= LSM_DES0P;
        end if;
      
      -------------------------------------------
      when LSM_STAT =>
      -------------------------------------------
        if dmaack='1' and dmaeob='1' then
          lsm_c <= LSM_DES1;
        else
          lsm_c <= LSM_STAT;
        end if;
      
      -------------------------------------------
      when others => -- LSM_FSTAT
      -------------------------------------------
        if dmaack='1' and dmaeob='1' then
          if own='1' and stop_r='0' then
            lsm_c <= LSM_DES1;
          else
            lsm_c <= LSM_IDLE;
          end if;
        else
          lsm_c <= LSM_FSTAT;
        end if;
    end case;
  end process; -- lsm_proc
  
  ---------------------------------------------------------------------
  -- receive linked list manager registered
  ---------------------------------------------------------------------
  rlsm_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        lsm   <= LSM_IDLE;
        lsm_r <= LSM_IDLE;
    elsif clk'event and clk='1' then

        lsm   <= lsm_c;
        lsm_r <= lsm;
    end if;
  end process; -- rlsm_reg_proc
  
  ---------------------------------------------------------------------
  -- receive poll acknowledge
  -- registered output
  ---------------------------------------------------------------------
  rpollack_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        rpollack <= '0';
    elsif clk'event and clk='1' then

        if rpoll='1' and dbadc_r='0' then
          rpollack <= '1';
        elsif rpoll='0' then
          rpollack <= '0';
        end if;
    end if;
  end process; -- rpollack_reg_proc

  ---------------------------------------------------------------------
  -- buffer byte counter registered
  ---------------------------------------------------------------------
  
-- SAR57010
-- if the bcnt is a non multiple of datawidth then on the first transfer
-- the odd number of transfers is removed from the count.
-- 
  
  
  bcnt_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        bcnt <= (others=>'1');
    elsif clk'event and clk='1' then
        if lsm=LSM_DES2 then
		   bcnt <= bs1;
        elsif lsm=LSM_DES3 then
		   bcnt <= bs2;
		else
          if dmaack='1' then
            case DATAWIDTH is
              -----------------------------------
              when 8      =>
              -----------------------------------
                bcnt <= bcnt-1;
              -----------------------------------
              when 16     =>
              -----------------------------------
                if bcnt(0)='0' then
				  bcnt <= (bcnt(10 downto 1)-1) & '0';
				end if;
				bcnt(0) <= '0'; 
              -----------------------------------
              when others => -- 32
              -----------------------------------
                if bcnt(1 downto 0)="00" then
                  bcnt <= (bcnt(10 downto 2)-1) & "00";
				end if;
				bcnt(1 downto 0) <= "00"; 
            end case;
          end if;
        end if;
    end if;
  end process; -- bcnt_reg_proc
  
           
  ---------------------------------------------------------------------
  -- desriptor ownership bit combinatorial
  ---------------------------------------------------------------------
  own_proc:
  process(own, dmaack, dmaeob, lsm, dmadatai)
  begin
    own_c <= own;
    if dmaack='1' and dmaeob='1' and
       (lsm=LSM_DES0 or lsm=LSM_DES0P)
    then
      own_c <= dmadatai(DATAWIDTH-1);
    end if;
  end process; -- own_proc

  ---------------------------------------------------------------------
  -- des1 status registered
  ---------------------------------------------------------------------
  des1_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        rer  <= '0';
        rch  <= '0';
        bs2  <= (others=>'0');
        bs1  <= (others=>'0');
    elsif clk'event and clk='1' then

        if lsm=LSM_DES1 and dmaack='1' then
          case DATAWIDTH is
            ---------------------------------------
            when 8 =>
            ---------------------------------------
              case dmaaddr20 is
                when "000" | "100" =>
                  bs1(7 downto 0) <= dmadatai_max(7 downto 0);
                when "001" | "101" =>
                  bs1(10 downto 8) <= dmadatai_max(2 downto 0);
                  bs2(4 downto 0)  <= dmadatai_max(7 downto 3);
                when "010" | "110" =>
                  bs2(10 downto 5) <= dmadatai_max(5 downto 0);
                when others => -- "011" | "111";
                  rer  <= dmadatai_max(1);
                  rch  <= dmadatai_max(0);
              end case;
              
            ---------------------------------------
            when 16 =>
            ---------------------------------------
              case dmaaddr20 is
                when "000" | "100" =>
                  bs1(10 downto 0) <= dmadatai_max(10 downto 0);
                  bs2(4 downto 0) <= dmadatai_max(15 downto 11);
                when others => -- "010" | "110"
                  bs2(10 downto 5) <= dmadatai_max(5 downto 0);
                  rer <= dmadatai_max(9);
                  rch <= dmadatai_max(8);
              end case;
              
            ---------------------------------------
            when others => -- 32
            ---------------------------------------
              rer <= dmadatai_max(25);
              rch <= dmadatai_max(24);
              bs2 <= dmadatai_max(21 downto 11);
              bs1 <= dmadatai_max(10 downto 0);
          end case;
        end if;
    end if;
  end process; -- des1_reg_proc

  ---------------------------------------------------------------------
  -- dmadatai of DATAWIDTH_MAX length
  ---------------------------------------------------------------------
  dmadatai_max_drv:
    dmadatai_max <= dzero_max(DATAWIDTH_MAX downto DATAWIDTH) &
                    dmadatai;
  
  ---------------------------------------------------------------------
  -- receive descriptor control registered
  ---------------------------------------------------------------------
  rdes_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        own <= '0';
        rfs <= '1';
        rls <= '0';
        rde <= '0';
    elsif clk'event and clk='1' then

        -- receive first descriptor
        if lsm=LSM_FSTAT and dmaack='1' and dmaeob='1' then
          rfs <= '1';
        elsif lsm=LSM_STAT and dmaack='1' and dmaeob='1' then
          rfs <= '0';
        end if;
        
        -- receive last descriptor
        if lsm=LSM_FSTAT then
          rls <= '1';
        else
          rls <= '0';
        end if;
        
        -- receive descriptor error
        if lsm=LSM_FSTAT and whole='0' then
          rde <= '1';
        elsif lsm=LSM_IDLE then
          rde <= '0';
        end if;
        
        -- ownership bit
        own <= own_c;
    end if;
  end process; -- rdes_reg_proc
  
  ---------------------------------------------------------------------
  -- receive error summary combinatorial
  ---------------------------------------------------------------------
  res_drv:
    res_c <= rf or ce or rde or cs or tl;



--===================================================================--
--                             lsm addresses                         --
--===================================================================--
  
  ---------------------------------------------------------------------
  -- address write enable registered
  ---------------------------------------------------------------------
  adwrite_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        adwrite <= '0';
        dbadc_r <= '0';
    elsif clk'event and clk='1' then

        -- address write enable
        if dmaack='1' and dmaeob='1' then
          adwrite <= '1';
        else
          adwrite <= '0';
        end if;
        
        -- descriptor base address changed
        dbadc_r <= rdbadc;
    end if;
  end process; -- adwrite_reg_proc
  
  ---------------------------------------------------------------------
  -- descriptor addresses registered
  ---------------------------------------------------------------------
  dad_reg_proc:



process(clk,rst)
  begin
    if rst = '0' then
        dad <= (others=>'1');
    elsif clk'event and clk='1' then

        -- assign base address when it is changed
        if dbadc_r='1' then
          dad <= rdbad;
        elsif adwrite='1' and lsm=LSM_NXT and rch='1' then
          dad <= dataimax_r(DATADEPTH-1 downto 0);
        elsif adwrite='1' then
          case lsm_r is
            -- address of the next descriptor
            -------------------------------------
            when LSM_DES3 =>
            -------------------------------------
              if rer='1' then
                dad <= rdbad;
              else
                dad <= dmaaddr + (dsl & "00");
              end if;

            
            -------------------------------------
            when LSM_DES0 | LSM_DES0P =>
            -------------------------------------
              if own='1' then
                dad <= dmaaddr;
              end if;
              
            -------------------------------------
            when LSM_DES2 =>
            -------------------------------------
              dad <= dmaaddr;
            
            -------------------------------------
            when LSM_DES1 =>
            -------------------------------------
              dad <= dmaaddr;
              
            -------------------------------------
            when others => -- LSM_BUF1 | LSM_BUF2
            -------------------------------------
              dad <= dad;
          end case;
        end if;
    end if;
  end process; -- dad_reg_proc

  ---------------------------------------------------------------------
  -- buffer addresses registered
  ---------------------------------------------------------------------
  bad_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        bad <= (others=>'1');
    elsif clk'event and clk='1' then

        if adwrite='1' then
          if lsm_r=LSM_BUF1 or lsm_r=LSM_BUF2 then
            bad <= dmaaddr;
          else
            bad <= dataimax_r(DATADEPTH-1 downto 0);
          end if;
        end if;
    end if;
  end process; -- bad_reg_proc
  
  ---------------------------------------------------------------------
  -- descriptor status address registered
  ---------------------------------------------------------------------
  stataddr_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        statad  <= (others=>'1');
        tstatad <= (others=>'1');
    elsif clk'event and clk='1' then

        -- address of DES0 field is current status address
        if lsm=LSM_DES1 and adwrite='1' then
          statad <= tstatad;
        end if;
        
        -- temporary descriptor status address registered
        -- address of DES0 field is current status address
        if (lsm=LSM_DES0 or lsm=LSM_DES0P)
           and dmaack='1' and dmaeob='1'
        then
          tstatad <= dad;
        end if;
    end if;
  end process; -- stataddr_reg_proc



--===================================================================--
--                                fifo                               --
--===================================================================--
  
  ---------------------------------------------------------------------
  -- fifo byte counter registered
  ---------------------------------------------------------------------
  fbcnt_proc:
  process(fbcnt, icachere, ififore)
  begin
    if icachere='1' then
      fbcnt_c <= (others=>'0');
    else
      if ififore='1' then
        case DATAWIDTH is
          -----------------------------------
          when  8 =>
          -----------------------------------
            fbcnt_c <= fbcnt + 1;
          -----------------------------------
          when 16 =>
          -----------------------------------
            fbcnt_c <= fbcnt + "10";
          -----------------------------------
          when others => -- 32
          -----------------------------------
            fbcnt_c <= fbcnt + "100";
        end case;
      else
        fbcnt_c <= fbcnt;
      end if;
    end if;
  end process; -- fbcnt_reg_proc
  
  ---------------------------------------------------------------------
  -- fifo byte counter registered
  ---------------------------------------------------------------------
  fbcnt_reg_proc:
  process(clk, rst)
  begin
  	if rst='0' then
  		fbcnt <= (others=>'0');
  	elsif clk'event and clk='1' then 

        fbcnt <= fbcnt_c;

    end if;
  end process; -- fbcnt_reg_proc
  
  ---------------------------------------------------------------------
  -- whole frame transferred combinatorial
  ---------------------------------------------------------------------
  whole_proc:
  process(fbcnt, length, fifocne)
  begin
    whole <= '0';
    if fbcnt>=length and fifocne='1' then
      whole <= '1';
    end if;
  end process; -- whole_proc
  
  ---------------------------------------------------------------------
  -- internal fifo read enable combinatorial
  ---------------------------------------------------------------------
  ififore_drv:
    ififore <= '1' when (
                          (lsm=LSM_BUF1 or lsm=LSM_BUF2) and dmaack='1'
                        )
                        or
                        (
                          lsm=LSM_FSTAT and whole='0' and
                          flmax /= fzero_max(14 downto 0) and
                          ififore_r='0'
                        )
                        or
                        (
                          lsm=LSM_FSTAT and whole='0' and
                          fifocne='1' and ififore_r='0'
                        )
                     else
                 '0';
  
  ---------------------------------------------------------------------
  -- fifo/cache read enable registered
  ---------------------------------------------------------------------
  ififore_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        ififore_r <= '0';
        icachere  <= '0';
    elsif clk'event and clk='1' then

        -- fifo read enable
        ififore_r <= ififore;
        
        -- internal cache read enable
        if lsm=LSM_FSTAT and dmaack='1' and dmaeob='1' then
          icachere <= '1';
        else
          icachere <= '0';
        end if;
    end if;
  end process; -- ififore_reg_proc
  
  ---------------------------------------------------------------------
  -- fifo read enable
  -- combinatorial output
  ---------------------------------------------------------------------
  fifore_drv:
    fifore <= ififore;
  
  ---------------------------------------------------------------------
  -- status cache read enable
  -- registered output
  ---------------------------------------------------------------------
  cachere_drv:
    cachere <= icachere;
          
  
  
--===================================================================--
--                          receive control                          --
--===================================================================--

  ---------------------------------------------------------------------
  -- receive in progress registered
  ---------------------------------------------------------------------
  rprog_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        rprog_r  <= '0';
        rcpoll_r <= '0';
        rcpoll_r2 <= '0';
    elsif clk'event and clk='1' then

        rprog_r  <= rprog;
        rcpoll_r <= rcpoll;
        if lsm=LSM_IDLE then
          rcpoll_r2 <= rcpoll_r;
        end if;
    end if;
  end process; -- rprog_reg_proc
  
  ---------------------------------------------------------------------
  -- descriptor/buffer processing status registered
  ---------------------------------------------------------------------
  stat_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        des     <= '0';
        fbuf    <= '0';
        stat    <= '0';
        rcomp   <= '0';
        bufcomp <= '0';
        ru      <= '0';
    elsif clk'event and clk='1' then

        -- fetching receive descriptor
        if lsm=LSM_DES0 or lsm=LSM_DES1 or
           lsm=LSM_DES2 or lsm=LSM_DES3 or
           lsm=LSM_DES0P
        then
          des <= '1';
        else
          des <= '0';
        end if;
        
        -- fetching buffer
        if (lsm=LSM_BUF1 or lsm=LSM_BUF2) and req='1' then
          fbuf <= '1';
        else
          fbuf <= '0';
        end if;
        
        -- writting descriptor status
        if lsm=LSM_STAT or lsm=LSM_FSTAT then
          stat <= '1';
        else
          stat <= '0';
        end if;
        
        -- receive completition
        if lsm=LSM_FSTAT and dmaack='1' and dmaeob='1' then
          rcomp <= '1';
        elsif rcompack='1' then
          rcomp <= '0';
        end if;
        
        -- buffer completition
        if lsm=LSM_STAT and dmaack='1' and dmaeob='1' then
          bufcomp <= '1';
        elsif bufack='1' then
          bufcomp <= '0';
        end if;
        
        -- receive descriptor unavailable
        if own='1' and own_c='0' then
          ru <= '1';
        elsif own='1' then
          ru <= '0';
        end if;
    end if;
  end process; -- stat_reg_proc


   


  --=================================================================--
  --                       power management                          --
  --=================================================================--
  
  ---------------------------------------------------------------------
  -- stop receive process registered
  ---------------------------------------------------------------------
  stop_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        stop_r <= '1';
        stopo  <= '1';
    elsif clk'event and clk='1' then

        -- stop input
        stop_r <= stopi;
        
        -- stop output
        -- can enter stopped state if the linked list state machine
        -- is idle, or if it prefetched next descriptor
        -- but no frame is waiting for transfer into the host
        if stop_r='1' and 
           (lsm=LSM_IDLE or
             (
               (lsm=LSM_BUF1 or lsm=LSM_BUF2)
               and fifocne='0' and rprog_r='0'
             )
           )
        then
          stopo <= '1';
        else
          stopo <= '0';
        end if;
    end if;
  end process; -- stop_reg_proc


--===================================================================--
--                               others                              --
--===================================================================--
  
  ---------------------------------------------------------------------
  -- zero vector of DATAWIDTH_MAX length
  ---------------------------------------------------------------------
  dzero_max_drv:
    dzero_max <= (others=>'0');
  
  ---------------------------------------------------------------------
  -- zero vector of FIFODEPTH_MAX length
  ---------------------------------------------------------------------
  fzero_max_drv:
    fzero_max <= (others=>'0');
  
  ---------------------------------------------------------------------
  -- 3 least significant bits of dma address
  ---------------------------------------------------------------------
  dmaaddr20_drv:
    dmaaddr20 <= dmaaddr(2 downto 0);
  
  ---------------------------------------------------------------------
  -- 2 least significant bits of dma address
  ---------------------------------------------------------------------
  addr10_drv:
    addr10 <= dmaaddr(1 downto 0);

end RTL;
--*******************************************************************--
