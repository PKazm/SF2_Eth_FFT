--*******************************************************************--
-- Copyright 2013 Actel Corporation.  All rights reserved.
-- IP Solutions Group
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED 
-- IN ADVANCE IN WRITING.  
--  
-- File:  tlsm.vhd
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
-- File name            : tlsm.vhd
-- File contents        : Entity TLSM
--                        Architecture RTL of TLSM
-- Purpose              : Transmit linked List Management for MAC
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
-- 2003.03.21 : T.K. - "own_proc" process changed
-- 2.00.E02   :
-- 2003.04.15 : T.K. - synchronous processes merged
-- 1.00.E03   :
-- 2003.05.12 : T.K. - lsm_proc: condition for LSM_IDLE changed
-- 1.00.E04   :
-- 2003.05.21 : T.K. - lsm_proc: condition for LSM_IDLE changed
-- 2.00.E05   :
-- 2003.08.10 : H.C. - dmadatai_max width fixes
-- 2.00.E06   : 
-- 2004.01.20 : B.W. - req_r signal removed
-- 2004.01.20 : B.W. - RTL code changes due to VN Check
--                     and code coverage (I200.06.vn) :
--                      * be_proc process changed
--                      * dmaaddro_proc process changed
--*******************************************************************--

library IEEE;
  use work.utility.all;
  use ieee.std_logic_1164.all; 
  use IEEE.STD_LOGIC_UNSIGNED."-";
  use IEEE.STD_LOGIC_UNSIGNED."+";



  --*****************************************************************--
  entity TLSM is
    generic(
            -- Data interface data bus width
            DATAWIDTH : INTEGER := 32; -- 8|16|32|64
            -- Data interface address bus width
            DATADEPTH : INTEGER := 32; -- 8-32
            -- Depth of the FIFO memory
            FIFODEPTH : INTEGER := 9   -- 6-16
    );
    port (  
            ---------------------- common ports -----------------------
            -- global clock
            clk       : in  STD_LOGIC;
            -- hardware reset
            rst       : in  STD_LOGIC;
            
            ----------------- transmit FIFO control -------------------
            -- fifo not full
            fifonf    : in  STD_LOGIC;
            -- frame cache not full
            fifocnf   : in  STD_LOGIC;
            -- fifo valid
            fifoval   : in  STD_LOGIC;
            -- fifo level
            fifolev   : in  STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
            -- write enable
            fifowe    : out STD_LOGIC;
            -- end of frame
            fifoeof   : out STD_LOGIC;
            -- last byte enable
            fifobe    : out STD_LOGIC_VECTOR(DATAWIDTH/8-1 downto 0);
            -- data output
            fifodata  : out STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
            
            ----------------- transmit configuration ------------------
            -- interrupt on completition
            ic        : out STD_LOGIC;
            -- add crc disable
            ac        : out STD_LOGIC;
            -- disable padding
            dpd       : out STD_LOGIC;
            -- frame status address (for TLSM use only)
            statado   : out STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
            
            ------------------- transmit status -----------------------
            -- cache not empty
            csne      : in  STD_LOGIC;
            -- loss of carrier
            lo        : in  STD_LOGIC;
            -- no carrier
            nc        : in  STD_LOGIC;
            -- late collision
            lc        : in  STD_LOGIC;
            -- excessive collision
            ec        : in  STD_LOGIC;
            -- deferred
            de        : in  STD_LOGIC;
            -- underrun error
            ur        : in  STD_LOGIC;
            -- collision count
            cc        : in  STD_LOGIC_VECTOR(3 downto 0);
            -- frame status address (for TLSM only)
            statadi   : in  STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
            -- cache read enable
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
            
            --------------------- address DP RAM ----------------------
            -- address ram write enable
            fwe       : out STD_LOGIC;
            -- address ram data
            fdata     : out STD_LOGIC_VECTOR(ADDRWIDTH-1 downto 0);
            -- address ram address
            faddr     : out STD_LOGIC_VECTOR(ADDRDEPTH-1 downto 0);
            
            
            ------------------ csr configuration data -----------------
            -- descriptor skip length
            dsl      : in  STD_LOGIC_VECTOR(4 downto 0);
            -- probrammable burst length
            pbl      : in  STD_LOGIC_VECTOR(5 downto 0);
            -- poll demand
            poll     : in  STD_LOGIC;
            -- descriptor base address changed
            dbadc    : in  STD_LOGIC;
            -- descriptors base address
            dbad     : in  STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
            -- poll acknowledge
            pollack  : out STD_LOGIC;
            
            ------------------- csr status data -----------------------
            -- transmit completition acknowledge
            tcompack  : in  STD_LOGIC;
            -- transmit completition
            tcomp     : out STD_LOGIC;
            -- fetching transmit descriptor
            des       : out STD_LOGIC;
            -- fetching transmit buffer
            fbuf      : out STD_LOGIC;
            -- writing transmit descriptor status
            stat      : out STD_LOGIC;
            -- setup frame processing
            setp      : out STD_LOGIC;
            -- transmit descriptor unavailable
            tu        : out STD_LOGIC;
            -- filtering type
            ft        : out STD_LOGIC_VECTOR(1 downto 0);
            
            --------------------- power management --------------------
            -- stop transmit process input
            stopi    : in  STD_LOGIC;
            -- stop transmit process output
            stopo    : out STD_LOGIC
    );
  end TLSM;

--*******************************************************************--
architecture RTL of TLSM is

  constant CWIDTH : INTEGER := DATAWIDTH*2-8;
  
  -------------------------- data interface ---------------------------
  -- dmadatai of maximum length
  signal dmadatai_max : STD_LOGIC_VECTOR(DATAWIDTH_MAX-1 downto 0);
  -- data input extended to DATADEPTH_MAX registered
  signal dataimax_r   : STD_LOGIC_VECTOR(DATAWIDTH_MAX-1 downto 0);
  -- data input extended to DATADEPTH_MAX registered 1..0
  signal dataimax_r10 : STD_LOGIC_VECTOR(1 downto 0);
  -- 3 least significant bits of dma address
  signal dmaaddr20  : STD_LOGIC_VECTOR(2 downto 0);
  -- dma request combinatorial
  signal req_c      : STD_LOGIC;
  -- dma request registered
  signal req        : STD_LOGIC;
  -- dma request double registered
  signal req_r      : STD_LOGIC;
  -- internal dma request registered
  signal idmareq    : STD_LOGIC;
  -- 32-bit data output
  signal datao32    : STD_LOGIC_VECTOR(31 downto 0);
  -- buffer byte size extended to FIFODEPTH_MAX
  signal bsmax       : STD_LOGIC_VECTOR(FIFODEPTH_MAX-1 downto 0);
  -- free space in fifo extended to FIFODEPTH_MAX
  signal flmax       : STD_LOGIC_VECTOR(FIFODEPTH_MAX-1 downto 0);
  -- programmable burst length extended to FIFODEPTH_MAX
  signal blmax       : STD_LOGIC_VECTOR(FIFODEPTH_MAX-1 downto 0);
  -- free space in fifo greater then buffer byte size
  signal fl_g_bs    : STD_LOGIC;
  -- free space in fifo greater then programmable burst length
  signal fl_g_bl    : STD_LOGIC;
  -- programmable burst length greater then buffer byte size
  signal bl_g_bs    : STD_LOGIC;
  -- programmable burst length=0 registered
  signal pblz       : STD_LOGIC;
  -- buffer fetching registered
  signal buffetch   : STD_LOGIC;
  -- internal dma transfer acknowledge registered
  signal dmaack_r   : STD_LOGIC;
  
  
  ------------------------------- lsm ---------------------------------
  -- linked list state machine combinatorial
  signal lsm_c      : LSMT;
  -- linked list state machine registered
  signal lsm        : LSMT;
  -- linked lit state machine registered
  signal lsm_r      : LSMT;
  -- control state machine combinatorial
  signal csm_c      : CSMT;
  -- control state machine registered
  signal csm        : CSMT;
  -- linked list machine wait state counter
  signal lsmcnt     : STD_LOGIC_VECTOR(2 downto 0);
  -- transmit frame status writing in progress
  signal tsprog     : STD_LOGIC;
  -- current descriptor's status address registered
  signal statad     : STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
  -- error summary
  signal es_c       : STD_LOGIC;
  -- ownership combinatorial
  signal own_c      : STD_LOGIC;
  -- ownership registered
  signal own        : STD_LOGIC;
  -- chained registered
  signal tch        : STD_LOGIC;
  -- end of ring registered
  signal ter        : STD_LOGIC;
  -- setup frame registered
  signal set        : STD_LOGIC;
  -- last segment registered
  signal tls         : STD_LOGIC;
  -- first segment registered
  signal tfs         : STD_LOGIC;
  -- buffer size (common for buffer1 & 2) combinatorial
  signal bs_c       : STD_LOGIC_VECTOR(10 downto 0);
  -- 2 least significant bits of buffer size
  signal bs_c10     : STD_LOGIC_VECTOR(1 downto 0);
  -- buffer 1 size registered
  signal bs1        : STD_LOGIC_VECTOR(10 downto 0);
  -- buffer 2 size registered
  signal bs2        : STD_LOGIC_VECTOR(10 downto 0);
  -- address write enable registered
  signal adwrite    : STD_LOGIC;
  -- buffer address registered
  signal bad        : STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
  -- descriptor address registered
  signal dad        : STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
  -- descriptor base address changed registered
  signal dbadc_r     : STD_LOGIC;
  -- transmit frame status
  signal tstat      : STD_LOGIC_VECTOR(31 downto 0);
  -- last dma transaction registered
  signal lastdma    : STD_LOGIC;
  -- internal frame cache read enable registered
  signal icachere   : STD_LOGIC;
  -- poll demand registered
  signal poll_r     : STD_LOGIC;
  
  ------------------------------ buffer -------------------------------
  -- buffer add value selection for DATAWIDTH=16
  signal addsel16   : STD_LOGIC_VECTOR(1 downto 0);
  -- buffer add value selection for DATAWIDTH=32
  signal addsel32   : STD_LOGIC_VECTOR(3 downto 0);
  -- temporary add value
  signal addv_c     : STD_LOGIC_VECTOR(3 downto 0);
  -- buffer add value
  signal badd_c     : STD_LOGIC_VECTOR(1 downto 0);
  -- buffer counter
  signal bcnt       : STD_LOGIC_VECTOR(11 downto 0);
  -- fifo write enable
  signal ififowe    : STD_LOGIC;
  -- buffer write enable registered
  signal bufwe      : STD_LOGIC;
  -- first data dword transfer combinatorial
  signal firstb_c   : STD_LOGIC;
  -- first data dword transfer registered
  signal firstb     : STD_LOGIC;
  -- fifo buffer0 (for 8/16/24/32/64-bit data alignment)
  signal buf0_c     : STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
  -- fifo buffer combinatorial
  signal buf_c      : STD_LOGIC_VECTOR(CWIDTH-1 downto 0);
  -- fifo buffer registered
  signal buf_r        : STD_LOGIC_VECTOR(CWIDTH-1 downto 0);
  -- fifo buffer level (words) combinatorial
  signal buflev_c   : STD_LOGIC_VECTOR(3 downto 0);
  -- fifo buffer level (words) registered
  signal buflev     : STD_LOGIC_VECTOR(3 downto 0);
  -- byte enable for the first data dword registered
  signal firstbe    : STD_LOGIC_VECTOR(DATAWIDTH/8-1 downto 0);
  -- byte enable for the last data dword registered
  signal lastbe     : STD_LOGIC_VECTOR(DATAWIDTH/8-1 downto 0);
  -- byte enable registered
  signal be         : STD_LOGIC_VECTOR(DATAWIDTH/8-1 downto 0);
  -- byte enable for DATAWIDTH=16
  signal be10       : STD_LOGIC_VECTOR(1 downto 0);
  -- byte enable for DATAWIDTH=32
  signal be30       : STD_LOGIC_VECTOR(3 downto 0);
  
  --------------------------- csr interrupts --------------------------
  -- internal transmit completition registered
  signal itcomp     : STD_LOGIC;
  -- transmit completition acknowledge registered
  signal tcompack_r : STD_LOGIC;
  
  --------------------------- filtering RAM ---------------------------
  -- filtering RAM write enable registered
  signal ifwe        : STD_LOGIC;
  -- filtering RAM address
  signal ifaddr      : STD_LOGIC_VECTOR(ADDRDEPTH-1 downto 0);
  
  -------------------------- Power management -------------------------
  -- stop transmit process registered
  signal stop_r     : STD_LOGIC;
  
  ------------------------------ others -------------------------------
  -- zero vector of FIFODEPTH_MAX length
  signal fzero_max : STD_LOGIC_VECTOR(FIFODEPTH_MAX-1 downto 0);
  -- zero vector of DATAWIDTH_MAX length
  signal dzero_max : STD_LOGIC_VECTOR(DATAWIDTH_MAX-1 downto 0);


begin

  ---------------------------------------------------------------------
  -- internal dma request registered
  ---------------------------------------------------------------------
  idmareq_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        idmareq <= '0';
    elsif clk'event and clk='1' then

        if req_c='1' then
          idmareq <= '1';
        elsif dmaack='1' and dmaeob='1' then
          idmareq <= '0';
        end if;
    end if;
  end process; -- idmareq_reg_proc

  
  ---------------------------------------------------------------------
  -- internal frame status cache read enable registered
  ---------------------------------------------------------------------
  cachere_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        icachere <= '0';
    elsif clk'event and clk='1' then

        if itcomp='1' and tcompack_r='1' then
          icachere <= '1';
        else
          icachere <= '0';
        end if;
    end if;
  end process; -- cachere_reg_proc
  
  ---------------------------------------------------------------------
  -- frame status read enable
  -- registered output
  ---------------------------------------------------------------------
  cachere_drv:
    cachere <= icachere;


--===================================================================--
--                                 lsm                               --
--===================================================================--
  
  ---------------------------------------------------------------------
  -- linked list state machine combinatorial
  ---------------------------------------------------------------------
  lsm_proc:
  process(
           lsm, csm, poll_r, dmaack, dmaeob, own_c, tch, bs1, bs2,
           stop_r, lsmcnt, fifocnf, tsprog, lastdma, dbadc_r
         )
  begin
    case lsm is
      -------------------------------------------
      when LSM_IDLE =>
      -------------------------------------------
        if dbadc_r='0' and stop_r='0' and fifocnf='1' and
           (poll_r='1' or (tsprog='1' and dmaack='1' and dmaeob='1'))
        then
          lsm_c <= LSM_DES0;
        else
          lsm_c <= LSM_IDLE;
        end if;
      
      -------------------------------------------
      when LSM_DES0 =>
      -------------------------------------------
        if dmaack='1' and dmaeob='1' and tsprog='0' then
          if own_c='1' then
            lsm_c <= LSM_DES1;
          else
            lsm_c <= LSM_IDLE;
          end if;
        else
          lsm_c <= LSM_DES0;
        end if;
      
      -------------------------------------------
      when LSM_DES1 =>
      -------------------------------------------
        if dmaack='1' and dmaeob='1' and tsprog='0' then
          lsm_c <= LSM_DES2;
        else
          lsm_c <= LSM_DES1;
        end if;
      
      -------------------------------------------
      when LSM_DES2 =>
      -------------------------------------------
        if dmaack='1' and dmaeob='1' and tsprog='0' then
          if bs1="00000000000" or csm=CSM_IDLE then
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
        if dmaack='1' and dmaeob='1' and tsprog='0' then
          if bs2="00000000000" or tch='1' or csm=CSM_IDLE then
            lsm_c <= LSM_NXT;
          else
            lsm_c <= LSM_BUF2;
          end if;
        else
          lsm_c <= LSM_DES3;
        end if;
      
      -------------------------------------------
      when LSM_BUF1 =>
      -------------------------------------------
        if tsprog='0' and dmaack='1' and dmaeob='1' and lastdma='1' then
          lsm_c <= LSM_DES3;
        else
          lsm_c <= LSM_BUF1;
        end if;
      
      -------------------------------------------
      when LSM_BUF2 =>
      -------------------------------------------
        if tsprog='0' and dmaack='1' and dmaeob='1' and lastdma='1' then
          lsm_c <= LSM_NXT;
        else
          lsm_c <= LSM_BUF2;
        end if;
      
      -------------------------------------------
      when LSM_NXT =>
      -------------------------------------------
        if lsmcnt="000" then
          if (csm=CSM_L or csm=CSM_FL) then
            if stop_r='1' or fifocnf='0' then
              lsm_c <= LSM_IDLE;
            else
              lsm_c <= LSM_DES0;
            end if;
          else
            lsm_c <= LSM_STAT;
          end if;
        else
          lsm_c <= LSM_NXT;
        end if;
      
      -------------------------------------------
      when others => -- LSM_STAT
      -------------------------------------------
        if dmaack='1' and dmaeob='1' and tsprog='0' then
          if stop_r='1' then
            lsm_c <= LSM_IDLE;
          else
            lsm_c <= LSM_DES0;
          end if;
        else
          lsm_c <= LSM_STAT;
        end if;
    end case;
  end process; -- lsm_proc
  
  ---------------------------------------------------------------------
  -- transmit linked list manager registered
  ---------------------------------------------------------------------
  lsm_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        lsm <= LSM_IDLE;
        lsm_r <= LSM_IDLE;
    elsif clk'event and clk='1' then

        lsm <= lsm_c;
        lsm_r <= lsm;
    end if;
  end process; -- lsm_reg_proc
  
  ---------------------------------------------------------------------
  -- control state machine combinatorial
  ---------------------------------------------------------------------
  csm_proc:
  process(csm, lsm, tfs, tls, own, set, bs1, bs2)
  begin
    case csm is
      -------------------------------------------
      when CSM_IDLE =>
      -------------------------------------------
        if lsm=LSM_DES2 and own='1' then
          if set='0' and tfs='1' and tls='1' then
            csm_c <= CSM_FL;
          elsif set='0' and tfs='1' and tls='0' then
            csm_c <= CSM_F;
          elsif set='1' and tfs='0' and tls='0' then
            csm_c <= CSM_SET;
          else
            csm_c <= CSM_IDLE;
          end if;
        else
          csm_c <= CSM_IDLE;
        end if;
      
      -------------------------------------------
      when CSM_FL =>
      -------------------------------------------
        if lsm=LSM_DES0 or lsm=LSM_IDLE then
          csm_c <= CSM_IDLE;
        elsif lsm=LSM_DES2 and bs1="00000000000" and bs2="00000000000" then
          csm_c <= CSM_BAD;
        else
          csm_c <= CSM_FL;
        end if;
      
      -------------------------------------------
      when CSM_F =>
      -------------------------------------------
        if lsm=LSM_DES2 and tls='1' then
          csm_c <= CSM_L;
        elsif lsm=LSM_DES1 and tfs='0' then
          csm_c <= CSM_I;
        else
          csm_c <= CSM_F;
        end if;
      
      -------------------------------------------
      when CSM_L =>
      -------------------------------------------
        if lsm=LSM_DES0 or lsm=LSM_IDLE then
          csm_c <= CSM_IDLE;
        else
          csm_c <= CSM_L;
        end if;
      
      -------------------------------------------
      when CSM_SET =>
      -------------------------------------------
        if lsm=LSM_DES0 or lsm=LSM_IDLE then
          csm_c <= CSM_IDLE;
        else
          csm_c <= CSM_SET;
        end if;
      
      -------------------------------------------
      when CSM_I =>
      -------------------------------------------
        if lsm=LSM_DES2 and tls='1' then
          csm_c <= CSM_L;
        else
          csm_c <= CSM_I;
        end if;
      
      -------------------------------------------
      when others => -- CSM_BAD
      -------------------------------------------
        if lsm=LSM_NXT then
          csm_c <= CSM_IDLE;
        else
          csm_c <= CSM_BAD;
        end if;
    end case;
  end process; -- csm_proc
  
  ---------------------------------------------------------------------
  -- control state machine registered
  ---------------------------------------------------------------------  
  csm_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        csm <= CSM_IDLE;
    elsif clk'event and clk='1' then

        csm <= csm_c;
    end if;
  end process; -- csm_reg_proc
  
  ---------------------------------------------------------------------
  -- linked list wait state counter
  ---------------------------------------------------------------------
  lsmcnt_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        lsmcnt <= (others=>'1');
    elsif clk'event and clk='1' then

        if lsm=LSM_NXT then
          lsmcnt <= lsmcnt-1;
        else
          lsmcnt <= (others=>'1');
        end if;
    end if;
  end process; -- lsmcnt_reg_proc
  
  ---------------------------------------------------------------------
  -- poll demand registered
  ---------------------------------------------------------------------
  poll_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        poll_r <= '0';
    elsif clk'event and clk='1' then

        if poll='1' then
          poll_r <= '1';
        elsif poll='0' and dbadc_r='0' then
          poll_r <= '0';
        end if;
    end if;
  end process; -- poll_reg_proc

  ---------------------------------------------------------------------
  -- poll acknowledge
  -- registered output
  ---------------------------------------------------------------------
  pollack_drv:
    pollack <= poll_r;
  
  ---------------------------------------------------------------------
  -- desriptor ownership bit combinatorial
  ---------------------------------------------------------------------
  own_proc:
  process(own, dmaack, dmaeob, lsm, dmadatai)
  begin
    own_c <= own;
    if dmaack='1' and dmaeob='1' and lsm=LSM_DES0 then
      own_c <= dmadatai(DATAWIDTH-1);
    end if;
  end process; -- own_proc
  
  ---------------------------------------------------------------------
  -- descriptor ownership registered
  ---------------------------------------------------------------------
  own_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        own <= '1';
    elsif clk'event and clk='1' then

        own <= own_c;
    end if;
  end process; -- own_reg_proc

  ---------------------------------------------------------------------
  -- des1 status registered
  ---------------------------------------------------------------------
  des1_reg_proc:

process(clk,rst)
    variable ft22 : STD_LOGIC;
  begin
    if rst = '0' then
        ft22 := '0';
        tls  <= '0';
        tfs  <= '0';
        set  <= '0';
        ac   <= '0';
        ter  <= '0';
        tch  <= '0';
        dpd  <= '0';
        ic   <= '0';
        bs2  <= (others=>'0');
        bs1  <= (others=>'0');
        ft   <= (others=>'0');
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
                  bs2(4 downto 0) <= dmadatai_max(7 downto 3);
                when "010" | "110" =>
                  bs2(10 downto 5) <= dmadatai_max(5 downto 0);
                  dpd <= dmadatai_max(7);
                  ft22 := dmadatai_max(6);
                when others => -- "011" | "111"
                  ic   <= dmadatai_max(7);
                  tls  <= dmadatai_max(6);
                  tfs  <= dmadatai_max(5);
                  set  <= dmadatai_max(3);
                  ac   <= dmadatai_max(2);
                  ter  <= dmadatai_max(1);
                  tch  <= dmadatai_max(0);
                  -- filtering type valid only for a setup frame
                  if dmadatai_max(3)='1' then
                    ft <= dmadatai_max(4) & ft22;
                  end if;
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
                  ic  <= dmadatai_max(15);
                  tls <= dmadatai_max(14);
                  tfs <= dmadatai_max(13);
                  set <= dmadatai_max(11);
                  ac  <= dmadatai_max(10);
                  ter <= dmadatai_max(9);
                  tch <= dmadatai_max(8);
                  dpd <= dmadatai_max(7);
                  -- filtering type valid only for a setup frame
                  if dmadatai_max(11)='1' then
                    ft <= dmadatai_max(12) & dmadatai_max(6);
                  end if;
              end case;
              
            ---------------------------------------
            when others => -- 32
            ---------------------------------------
              ic  <= dmadatai_max(31);
              tls <= dmadatai_max(30);
              tfs <= dmadatai_max(29);
              set <= dmadatai_max(27);
              ac  <= dmadatai_max(26);
              ter <= dmadatai_max(25);
              tch <= dmadatai_max(24);
              dpd <= dmadatai_max(23);
              bs2 <= dmadatai_max(21 downto 11);
              bs1 <= dmadatai_max(10 downto 0);
              -- filtering type valid only for a setup frame
              if dmadatai_max(27)='1' then
                ft <= dmadatai_max(28) & dmadatai_max(22);
              end if;
          end case;
        end if;
    end if;
  end process; -- des1_reg_proc
  
  ---------------------------------------------------------------------
  -- dmadatai of DATAWIDTH_MAX length
  ---------------------------------------------------------------------
  dmadatai_max_drv:
    dmadatai_max <= dzero_max(31 downto  8) & dmadatai when DATAWIDTH=8 
               else dzero_max(31 downto 16) & dmadatai when DATAWIDTH=16 
               else dmadatai; 
-----------------------------------------------------------------------
--                           lsm addresses                           --
-----------------------------------------------------------------------

  ---------------------------------------------------------------------
  -- address write enable registered
  ---------------------------------------------------------------------
  adwrite_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        adwrite <= '0';
    elsif clk'event and clk='1' then

        if dmaack='1' and dmaeob='1' and tsprog='0' then
          adwrite <= '1';
        else
          adwrite <= '0';
        end if;
    end if;
  end process; -- adwrite_reg_proc
  
  ---------------------------------------------------------------------
  -- descriptor base address changed registered
  ---------------------------------------------------------------------
  dbadc_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        dbadc_r <= '0';
    elsif clk'event and clk='1' then

        dbadc_r <= dbadc;
    end if;
  end process; -- dbadc_reg_proc
  
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
          dad <= dbad;
        elsif adwrite='1' then
          case lsm_r is
            -------------------------------------
            when LSM_DES3 =>
            -------------------------------------
              if ter='1' then
                dad <= dbad;
              elsif tch='1' then
                dad <= dataimax_r(DATADEPTH-1 downto 0);
              else
                dad <= dmaaddr + (dsl & "00");
              end if;
              
            -------------------------------------
            when LSM_DES0 =>
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
          if lsm_r=LSM_DES2 or lsm_r=LSM_DES3 then
            case DATAWIDTH is
              when 8 =>
                bad <= dataimax_r(DATADEPTH-1 downto 0);
              when 16 =>
                bad <= dataimax_r(DATADEPTH-1 downto 1) & '0';
              when others => -- 32
                bad <= dataimax_r(DATADEPTH-1 downto 2) & "00";
            end case;
          else
            bad <= dmaaddr;
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
        statad <= (others=>'1');
    elsif clk'event and clk='1' then

        -- address of DES0 field is current status address
        if lsm_r=LSM_DES0 and adwrite='1' and own='1' then
          statad <= dad;
        end if;
    end if;
  end process; -- stataddr_reg_proc
  
  ---------------------------------------------------------------------
  -- frame status address
  -- registered output
  ---------------------------------------------------------------------
  statado_drv:
    statado <= statad;
  
  
  
-----------------------------------------------------------------------
--                   Buffer byte counter for lsm                    --
-----------------------------------------------------------------------
  
  ---------------------------------------------------------------------
  -- buffer size combinatorial
  ---------------------------------------------------------------------
  bs_drv:
    bs_c <= bs1 when lsm_r=LSM_DES2 else bs2;
  
  ---------------------------------------------------------------------
  -- buffer add selection value for DATAWIDTH=16
  ---------------------------------------------------------------------
  addsel16_drv:
    addsel16 <= dataimax_r(0) & bs_c(0);
  
  ---------------------------------------------------------------------
  -- buffer add selection value for DATAWIDTH=32
  ---------------------------------------------------------------------
  addsel32_drv:
    addsel32 <= dataimax_r10 & bs_c10;
  
  ---------------------------------------------------------------------
  -- buffer byte counter add value combinatorial
  ---------------------------------------------------------------------
  badd_proc:
  process(addsel16, addsel32)
  begin
    case DATAWIDTH is
      -------------------------------------------
      when 8 =>
      -------------------------------------------
        badd_c <= "00";
      
      -------------------------------------------
      when 16 =>
      -------------------------------------------
        if addsel16="01" or addsel16="10" or addsel16="11" then
          badd_c <= "01";
        else
          badd_c <= "00";
        end if;
      
      -------------------------------------------
      when others => -- 32
      -------------------------------------------
        case addsel32 is
          when "0000" =>
            badd_c <= "00";
          when "1011" | "1110" | "1111" =>
            badd_c <= "10";
          when others =>
            badd_c <= "01";
        end case;
    end case;
  end process; -- badd_proc

  ---------------------------------------------------------------------
  -- buffer byte counter registered
  ---------------------------------------------------------------------
  bcnt_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        bcnt <= (others=>'1');
    elsif clk'event and clk='1' then

        case DATAWIDTH is
          ---------------------------------------
          when 8 =>
          ---------------------------------------
            if lsm_r=LSM_DES2 or lsm_r=LSM_DES3 then
              bcnt <= '0' & bs_c;
            elsif dmaack='1' and tsprog='0' then
              bcnt <= bcnt - 1;
            end if;
          
          ---------------------------------------
          when 16 =>
          ---------------------------------------
            if lsm_r=LSM_DES2 or lsm_r=LSM_DES3 then
              bcnt <= (('0' & bs_c(10 downto 1)) + badd_c) & '0';
            elsif dmaack='1' and tsprog='0' then
              bcnt <= (bcnt(11 downto 1) - 1) & '0';
            end if;
            
          ---------------------------------------
          when others => -- 32
          ---------------------------------------
            if lsm_r=LSM_DES2 or lsm_r=LSM_DES3 then
              bcnt <= (('0' & bs_c(10 downto 2)) + badd_c) & "00";
            elsif dmaack='1' and tsprog='0' then
              bcnt <= (bcnt(11 downto 2) - 1) & "00";
            end if;
        end case;
    end if;
  end process; -- bcnt_reg_proc


-----------------------------------------------------------------------
--                            TFIFO buffer                           --
-----------------------------------------------------------------------
  
  ---------------------------------------------------------------------
  -- 2 least significant bits of byte size
  ---------------------------------------------------------------------
  bs_c10_drv:
    bs_c10 <= bs_c(1 downto 0);
  
  ---------------------------------------------------------------------
  -- data input extended to DATADEPTH_MAX registered 1..0
  ---------------------------------------------------------------------
  dataimax_r10_drv:
    dataimax_r10 <= dataimax_r(1 downto 0);

  ---------------------------------------------------------------------
  -- first byte enable registered
  ---------------------------------------------------------------------
  firstbe_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        firstbe <= (others=>'1');
    elsif clk'event and clk='1' then

        if (lsm_r=LSM_DES2 or lsm_r=LSM_DES3) then
          case DATAWIDTH is
            -------------------------------------
            when 8 =>
            -------------------------------------
              firstbe <= "1";
              
            -------------------------------------
            when 16 =>
            -------------------------------------
              if dataimax_r(0)='1' then
                firstbe <= "10";
              else
                firstbe <= "11";
              end if;
              
            -------------------------------------
            when others => -- 32
            -------------------------------------
              case dataimax_r10 is
                when "00"   => firstbe <= "1111";
                when "01"   => firstbe <= "1110";
                when "10"   => firstbe <= "1100";
                when others => firstbe <= "1000";
              end case;
           end case;
        end if;
    end if;
  end process; -- firstbe_reg_proc
  
  ---------------------------------------------------------------------
  -- last byte enable registered
  ---------------------------------------------------------------------
  lastbe_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        lastbe <= (others=>'1');
    elsif clk'event and clk='1' then

        if lsm_r=LSM_DES2 or lsm_r=LSM_DES3 then
          case DATAWIDTH is
            -------------------------------------
            when 8 =>
            -------------------------------------
              lastbe <= "1";
            
            -------------------------------------
            when 16 =>
            -------------------------------------
              if (dataimax_r(0)='0' and bs_c(0)='0') or
                 (dataimax_r(0)='1' and bs_c(0)='1')
              then
                lastbe <= "11";
              else
                lastbe <= "01";
              end if;
              
            -------------------------------------
            when others => -- 32
            -------------------------------------
              case dataimax_r10 is
                when "00" =>
                  case bs_c10 is
                    when "00"   => lastbe <= "1111";
                    when "01"   => lastbe <= "0001";
                    when "10"   => lastbe <= "0011";
                    when others => lastbe <= "0111";
                  end case;
                when "01" =>
                  case bs_c10 is
                    when "00"   => lastbe <= "0001";
                    when "01"   => lastbe <= "0011";
                    when "10"   => lastbe <= "0111";
                    when others => lastbe <= "1111";
                  end case;
                when "10" =>
                  case bs_c10 is
                    when "00"   => lastbe <= "0011";
                    when "01"   => lastbe <= "0111";
                    when "10"   => lastbe <= "1111";
                    when others => lastbe <= "0001";
                  end case;
                when others => --"11"
                  case bs_c10 is
                    when "00"   => lastbe <= "0111";
                    when "01"   => lastbe <= "1111";
                    when "10"   => lastbe <= "0001";
                    when others => lastbe <= "0011";
                  end case;
              end case;
            end case;
        end if;
    end if;
  end process; -- lastbe_proc
  
  ---------------------------------------------------------------------
  -- transmit fifo write enable registered
  ---------------------------------------------------------------------
  tfwe_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        ififowe <= '0';
    elsif clk'event and clk='1' then

        if (
             (DATAWIDTH=8  and buflev_c>="0001" and bufwe='1') or
             (DATAWIDTH=16 and buflev_c>="0010" and bufwe='1') or
             (DATAWIDTH=32 and buflev_c>="0100" and bufwe='1') or
             (
               buflev_c/="0000" and lsm=LSM_NXT and
               (csm=CSM_L or csm=CSM_FL)
             )
           ) and fifonf='1'
        then
          ififowe <= '1';
        else
          ififowe <= '0';
        end if;
    end if;
  end process; -- tfwe_reg_proc
  
  ---------------------------------------------------------------------
  -- fifo end of frame
  ---------------------------------------------------------------------
  fifoeof_drv:
    fifoeof <= '1' when (csm=CSM_L or csm=CSM_FL) and
                        lsm=LSM_NXT and lsmcnt="001" else
               '0';
  
  ---------------------------------------------------------------------
  -- fifo write enable
  -- registered output
  ---------------------------------------------------------------------
  fifowe_drv:
    fifowe <= ififowe;

  ---------------------------------------------------------------------
  -- first TFIFO buffer transfer combinatorial
  --------------------------------------------------------------------
  firstb_drv:
    firstb_c <= '0' when bufwe='1' else
                '1' when lsm=LSM_DES2 or lsm=LSM_DES3 else
                firstb;
  
  ---------------------------------------------------------------------
  -- TFIFO byte enable combinatorial
  ---------------------------------------------------------------------
  be_proc:
  process(firstb, firstbe, lastbe, dmaeob, lastdma)
  begin
    be <= (others=>'1');
    if dmaeob='1' and lastdma='1' then
      be <= lastbe;
    elsif firstb='1' then
      be <= firstbe;
    end if;
  end process; -- be_proc
  
  ---------------------------------------------------------------------
  -- TFIFO buffer 0 combinatorial
  ---------------------------------------------------------------------
  tbuf0_proc:
  process(be, be30, dmadatai_max)
    variable buf0_16 : STD_LOGIC_VECTOR(15 downto 0);
    variable buf0_32 : STD_LOGIC_VECTOR(31 downto 0);
  begin
  
    buf0_c <= (others=>'0');
    
    case DATAWIDTH is
      -------------------------------------------
      when 8 =>
      -------------------------------------------
        buf0_c(DATAWIDTH-1 downto 0) <= dmadatai_max(7 downto 0);
        
      -------------------------------------------
      when 16 =>
      -------------------------------------------
        buf0_16 := (others=>'0');
        if be="10" then
          buf0_16(7 downto 0) := dmadatai_max(15 downto 8);
        else
          buf0_16 := dmadatai_max(15 downto 0);
        end if;
        buf0_c(DATAWIDTH-1 downto 0) <= buf0_16(DATAWIDTH-1 downto 0);
        
      -------------------------------------------
      when others => -- 32
      -------------------------------------------
        buf0_32 := (others=>'0');
        case be30 is
          when "1110" =>
            buf0_32(23  downto 0) := dmadatai_max(31 downto 8);
          when "1100" =>
            buf0_32(15 downto  0) := dmadatai_max(31 downto 16);
          when "1000" =>
            buf0_32( 7 downto  0) := dmadatai_max(31 downto 24);
          when others =>
            buf0_32 := dmadatai_max(31 downto 0);
        end case;
        buf0_c(DATAWIDTH-1 downto 0) <= buf0_32(DATAWIDTH-1 downto 0);
    end case;
  end process; -- tbuf0_proc
  
  ---------------------------------------------------------------------
  -- TFIFO buffer combinatorial
  ---------------------------------------------------------------------
  
  -- Changes made to this process in v3.0 due to vector width misalignments SAR56860
  
  tbuf_proc:
  process(buflev, buf_r, buf0_c, bufwe, ififowe)
    variable buf_16    : STD_LOGIC_VECTOR(55 downto 0);	 -- only actually uses 23:0, other bits for bus width matching
    variable buf_32    : STD_LOGIC_VECTOR(55 downto 0);
  begin
    
	buf_c <= ( others => '0'); -- default value	on all bits
    case DATAWIDTH is
      -------------------------------------------
      when 8 =>
      -------------------------------------------
        buf_c(CWIDTH-1 downto 0) <= buf0_c(CWIDTH-1 downto 0);
      
      -------------------------------------------
      when 16 =>
      -------------------------------------------
	    buf_16 := ( others => '0'); 
        buf_16(23 downto 0) := buf_r;
        if bufwe='1' then
          case buflev is
            when "0000" =>
              buf_16(15 downto 0) := buf0_c;
            when "0001" =>
              buf_16(23 downto 8) := buf0_c;
            when "0010" =>
              buf_16(15 downto 0) := buf0_c;
            when others =>
              buf_16(23 downto 8) := buf0_c;
              buf_16( 7 downto 0) := buf_r(23 downto 16);
          end case;
        elsif ififowe='1' then
          buf_16(23 downto 0) := buf_r(23 downto 8) & buf_r(23 downto 16);
        end if;
        buf_c(CWIDTH-1 downto 0) <= buf_16(CWIDTH-1 downto 0);	   
		      
      -------------------------------------------
      when others => -- 32
      -------------------------------------------
        buf_32 := buf_r;
        if bufwe='1' then
          case buflev is
            when "0000" =>
              buf_32(31 downto  0) := buf0_c;
            when "0001" =>
              buf_32(39 downto  8) := buf0_c;
            when "0010" =>
              buf_32(47 downto 16) := buf0_c;
            when "0011" =>
              buf_32(55 downto 24) := buf0_c;
            when "0100" =>
              buf_32(31 downto  0) := buf0_c;
            when "0101" =>
              buf_32(39 downto  8) := buf0_c;
              buf_32( 7 downto  0) := buf_r(39 downto 32);
            when "0110" =>
              buf_32(47 downto 16) := buf0_c;
              buf_32(15 downto  0) := buf_r(47 downto 32);
            when others => -- "0111"
              buf_32(55 downto 24) := buf0_c;
              buf_32(23 downto  0) := buf_r(55 downto 32);
          end case;
        elsif ififowe='1' then
          buf_32 := buf_r(55 downto 24) & buf_r(55 downto 32);
        end if;
        buf_c(CWIDTH-1 downto 0) <= buf_32(CWIDTH-1 downto 0);
    end case;
  end process; -- tbuf_proc
  
  ---------------------------------------------------------------------
  -- buffer write enable
  ---------------------------------------------------------------------
  bufwe_drv:
    bufwe <= '1' when dmaack='1' and set='0' and
                      fifonf='1' and tsprog='0' and
                      (lsm=LSM_BUF1 or lsm=LSM_BUF2) else
             '0';
  
  ---------------------------------------------------------------------
  -- fifo data
  -- registered output
  ---------------------------------------------------------------------
  fifodata_drv:
    fifodata <= buf_r(DATAWIDTH-1 downto 0);
  
  ---------------------------------------------------------------------
  -- fifo byte enable for DATAWIDTH  8 16 32   SAR 56860
  ---------------------------------------------------------------------
 
  be01_drv:	if DATAWIDTH=8  generate
	be10 <= ( others => '1');
	be30 <= ( others => '1');
  end generate;

  be10_drv:	if DATAWIDTH=16  generate
    be10 <= be(1 downto 0);
	be30 <= ( others => '1');
  end generate;

  be30_drv:	if DATAWIDTH=32  generate
	be10 <= ( others => '1');
    be30 <= be(3 downto 0);
  end generate;
  
 
 
    
  ---------------------------------------------------------------------
  -- temporary add value
  ---------------------------------------------------------------------
  addv_proc:
  process(be10, be30)
  begin
    case DATAWIDTH is
      -------------------------------------------
      when 8 =>
      -------------------------------------------
        addv_c <= "0000";
        
      -------------------------------------------
      when 16 =>
      -------------------------------------------
        case be10 is
          when "01" | "10" => addv_c <= "0001";
          when others      => addv_c <= "0010";
        end case;
        
      -------------------------------------------
      when others => -- 32
      -------------------------------------------
        case be30 is
          when "0001" | "1000" => addv_c <= "0001";
          when "0011" | "1100" => addv_c <= "0010";
          when "0111" | "1110" => addv_c <= "0011";
          when others          => addv_c <= "0100";
        end case;
    end case;
  end process; -- addv_proc
  
  ---------------------------------------------------------------------
  -- buffer level combinatorial
  ---------------------------------------------------------------------
  buflev_proc:
  process(buflev, bufwe, ififowe, addv_c)
  begin
    case DATAWIDTH is
      -------------------------------------------
      when 8 =>
      -------------------------------------------
        if bufwe='1' then
          buflev_c <= "0001";
        elsif ififowe='1' then
          buflev_c <= "0000";
        else
          buflev_c <= buflev;
        end if;
        
      -------------------------------------------
      when 16 =>
      -------------------------------------------
        if bufwe='1' then
          buflev_c <= (buflev(3 downto 2) & '0' & buflev(0)) + addv_c;
        elsif ififowe='1' and buflev(1)='1' then
          buflev_c <= buflev(3 downto 2) & '0' & buflev(0);
        elsif ififowe='1' and buflev(1)='0' then
          buflev_c <= buflev(3 downto 1) & '0';
        else
          buflev_c <= buflev;
        end if;
        
      -------------------------------------------
      when others => -- 32
      -------------------------------------------
        if bufwe='1' then
          buflev_c <= (buflev(3 downto 3) & '0' & buflev(1 downto 0))
                      + addv_c;
        elsif ififowe='1' and buflev(2)='1' then
          buflev_c <= buflev(3 downto 3) & '0' & buflev(1 downto 0);
        elsif ififowe='1' and buflev(2)='0' then
          buflev_c <= buflev(3 downto 2) & "00";
        else
          buflev_c <= buflev;
        end if;
    end case;
  end process; -- buflev_proc
  
  ---------------------------------------------------------------------
  -- fifo buffer registered
  ---------------------------------------------------------------------  
  buf_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        buflev  <= (others=>'0');
        firstb  <= '1';
        buf_r     <= (others=>'0');
    elsif clk'event and clk='1' then

        buflev  <= buflev_c;
        firstb  <= firstb_c;
        buf_r     <= buf_c;
    end if;
  end process; -- buf_reg_proc
  
  ---------------------------------------------------------------------
  -- transmit last byte enable
  -- registered output
  ---------------------------------------------------------------------
  lbe_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        fifobe <= (others=>'1');
    elsif clk'event and clk='1' then

        if ififowe='1' then
          case DATAWIDTH is
            -------------------------------------
            when 8 => 
            -------------------------------------
              fifobe <= "1";
              
            -------------------------------------
            when 16 =>
            -------------------------------------
              case buflev is
                when "0001" => fifobe <= "01";
                when others => fifobe <= "11";
              end case;
              
            -------------------------------------
            when others => -- 32
            -------------------------------------
              case buflev is
                when "0001" => fifobe <= "0001";
                when "0010" => fifobe <= "0011";
                when "0011" => fifobe <= "0111";
                when others => fifobe <= "1111";
              end case;
          end case;
        end if;
    end if;
  end process; -- lbe_drv
  
  ---------------------------------------------------------------------
  -- error summary combinatorial
  ---------------------------------------------------------------------
  es_drv:
    es_c <= ur or lc or lo or nc or ec;

  ---------------------------------------------------------------------
  -- transmit frame status
  ---------------------------------------------------------------------
  tstat_drv:
    tstat <= '0' &
             TDES0_RV(30 downto 16) &
             es_c &
             TDES0_RV(14 downto 12) &
             lo &
             nc &
             lc &
             ec &
             TDES0_RV(7) &
             cc &
             TDES0_RV(2) &
             ur &
             de;

  ---------------------------------------------------------------------
  -- 32-bit data output
  ---------------------------------------------------------------------
  datao32_drv:
    datao32 <= tstat     when tsprog='1' else
               SET0_RV   when set='1' else
               TDES0_RV;
  
  ---------------------------------------------------------------------
  -- dma interface
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
            dataimax_r <= dmadatai;
        end case;
    end if;
  end process; -- dataimax_r
              
  
  ---------------------------------------------------------------------
  -- data output
  -- combinatorial output
  ---------------------------------------------------------------------
  datao_proc:
  process(datao32, dmaaddr)
    variable addr10 : STD_LOGIC_VECTOR(1 downto 0);
  begin
    addr10 := dmaaddr(1 downto 0);
    case DATAWIDTH is
      -------------------------------------------
      when 8 =>
      -------------------------------------------
        case addr10 is
          when "00"   => dmadatao <= datao32( 7 downto  0);
          when "01"   => dmadatao <= datao32(15 downto  8);
          when "10"   => dmadatao <= datao32(23 downto 16);
          when others => dmadatao <= datao32(31 downto 24);
        end case;
      
      -------------------------------------------
      when 16 =>
      -------------------------------------------
        if addr10(1)='0' then
          dmadatao <= datao32(15 downto  0);
        else
          dmadatao <= datao32(31 downto 16);
        end if;
      
      -------------------------------------------
      when others => -- 32
      -------------------------------------------
        dmadatao <= datao32;
    end case;
  end process; -- datao_proc
  
  
  ---------------------------------------------------------------------
  -- free fifo space extended to FIFODEPTH_MAX
  ---------------------------------------------------------------------
  flmax_drv:
    flmax <= fzero_max(FIFODEPTH_MAX-1 downto FIFODEPTH) &
             (fzero_max(FIFODEPTH-1 downto 0)-1-fifolev);
  
  ---------------------------------------------------------------------
  -- programmable burst length extended to FIFODEPTH_MAX
  ---------------------------------------------------------------------
  blmax_drv:
    blmax <= fzero_max(FIFODEPTH_MAX-1 downto 6) & pbl;
  
  ---------------------------------------------------------------------
  -- buffer size extended to FIFODEPTH_MAX
  ---------------------------------------------------------------------
  bsmax_drv:
    bsmax <= fzero_max(FIFODEPTH_MAX-1 downto 12) & bcnt
               when DATAWIDTH=8 else
             fzero_max(FIFODEPTH_MAX-1 downto 11) & bcnt(11 downto 1)
               when DATAWIDTH=16 else
             fzero_max(FIFODEPTH_MAX-1 downto 10) & bcnt(11 downto 2);
  
  ---------------------------------------------------------------------
  -- free fifo space greater then buffer size
  ---------------------------------------------------------------------
  fifolev_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        fl_g_bs <= '0';
        fl_g_bl <= '0';
        bl_g_bs <= '0';
        pblz    <= '0';
    elsif clk'event and clk='1' then

        -- free fifo space greater then buffer size
        if flmax >= bsmax then
          fl_g_bs <= '1';
        else
          fl_g_bs <= '0';
        end if;
        
        -- free fifo space greater then programmable burst length
        if flmax >= blmax then
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
  end process; -- fl_g_bs_reg_proc
  
  ---------------------------------------------------------------------
  -- dma counter
  -- combinatorial output
  ---------------------------------------------------------------------
  dmacnt_proc:
  process(
           csm, lsm, pblz, tsprog, fl_g_bs, fl_g_bl, bl_g_bs,
           blmax, bsmax, flmax, fzero_max
         )
  begin
    
    -- descriptor fetch -------------------------
    if lsm=LSM_DES0 or lsm=LSM_DES1 or
       lsm=LSM_DES2 or lsm=LSM_DES3 or
       lsm=LSM_STAT or tsprog='1'
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
        -- fifo free space greater then buffer size
        -- or setup frame processing
        if fl_g_bs='1' or csm=CSM_SET then
          dmacnt <= bsmax;
        -- fifo free space less then buffer size
        else
          dmacnt <= flmax;
        end if;
      -- programmable burst length
      else
        -- fifo free space greater then programmable burst length
        -- or setup frame processing
        if fl_g_bl='1' or csm=CSM_SET then
          -- programmable burst length greater then buffer size
          if bl_g_bs='1' then
            dmacnt <= bsmax;
          -- programmable burst length less then buffer size
          else
            dmacnt <= blmax;
          end if;
        -- fifo free space less then programmable burst length
        else
          -- fifo free space greater then buffer size
          if fl_g_bs='1' then
            dmacnt <= bsmax;
          -- fifo free space less then buffer size
          else
            dmacnt <= flmax;
          end if;
        end if;
      end if;
    end if;
  end process; -- dmacnt_proc
  
  ---------------------------------------------------------------------
  -- last dma transaction registered
  ---------------------------------------------------------------------
  lastdma_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        lastdma <= '1';
    elsif clk'event and clk='1' then

        -- descriptor fetch -------------------------
        if lsm=LSM_DES0 or lsm=LSM_DES1 or
           lsm=LSM_DES2 or lsm=LSM_DES3 or
           lsm=LSM_STAT or tsprog='1'
        then
          lastdma <= '1';
        -- buffer fetch -----------------------------
        elsif buffetch='0' then
          -- unlimited burst
          if pblz='1' then
            -- fifo free space greater then buffer size
            -- or setup frame processing
            if fl_g_bs='1' or csm=CSM_SET then
              lastdma <= '1';
            -- fifo free space less then buffer size
            else
              lastdma <= '0';
            end if;
          -- programmable burst length
          else
            -- fifo free space greater then programmable burst length
            -- or setup frame processing
            if fl_g_bl='1' or csm=CSM_SET then
              -- programmable burst length greater then buffer size
              if bl_g_bs='1' then
                lastdma <= '1';
              -- programmable burst length less then buffer size
              else
                lastdma <= '0';
              end if;
            -- fifo free space less then programmable burst length
            else
              -- fifo free space greater then buffer size
              if fl_g_bs='1' then
                lastdma <= '1';
              -- fifo free space less then buffer size
              else
                lastdma <= '0';
              end if;
            end if;
          end if;
        end if;
    end if;
  end process; -- lastdma_reg_proc
  
  ---------------------------------------------------------------------
  -- dma address
  -- combinatorial output
  ---------------------------------------------------------------------
  dmaaddro_proc:
  process(tsprog, lsm, statadi, bad, dad, statad)
  begin
      dmaaddro <= statadi;
    if tsprog/='1' then
      case lsm is
        when LSM_BUF1 | LSM_BUF2 =>
          dmaaddro <= bad;
        when LSM_STAT =>
          dmaaddro <= statad;
        when others => -- LSM_DES0|LSM_DES1|LSM_DES2|LSM_DES3
          dmaaddro <= dad;
      end case;
    end if;
  end process; -- dmaaddro_proc
  
  ---------------------------------------------------------------------
  -- internal dma request combinatorial
  ---------------------------------------------------------------------
  req_proc:
  process(req, dmaack, dmaeob, lsm, tsprog, fifoval)
  begin
    case lsm is
      -------------------------------------------
      when LSM_BUF1 | LSM_BUF2 =>
      -------------------------------------------
        if dmaack='1' and dmaeob='1' then
          req_c <= '0';
        elsif fifoval='1' or tsprog='1' then
          req_c <= '1';
        else
          req_c <= req;
        end if;
        
      -------------------------------------------
      when LSM_DES0 | LSM_DES1 | LSM_DES2 |
           LSM_DES3 | LSM_STAT =>
      -------------------------------------------
        if dmaack='1' then
          req_c <= '0';
        else
          req_c <= '1';
        end if;
        
      -------------------------------------------
      when others => -- LSM_IDLE
      -------------------------------------------
        if dmaack='1' then
          req_c <= '0';
        elsif tsprog='1' then
          req_c <= '1';
        else
          req_c <= '0';
        end if;
    end case;
  end process; -- req_proc
  
  ---------------------------------------------------------------------
  -- dma request/acknowledge registered
  ---------------------------------------------------------------------
  req_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        req      <= '0';
        req_r    <= '0';
        dmaack_r <= '0';
    elsif clk'event and clk='1' then

        req      <= req_c;
        req_r    <= req;
        dmaack_r <= dmaack and dmaeob;
    end if;
  end process; -- req_reg_proc

  ---------------------------------------------------------------------
  -- dma write selection
  -- combinatorial output
  ---------------------------------------------------------------------
  dmawr_proc:
    dmawr <= '1' when tsprog='1' or lsm=LSM_STAT else
             '0';
  
  ---------------------------------------------------------------------
  -- dma request
  -- registered output
  ---------------------------------------------------------------------
  dmareq_drv:
    dmareq <= req;
    

--===================================================================--
--                         STATE MACHINE STATUS                      --
--===================================================================--

  ---------------------------------------------------------------------
  -- descriptor/buffer processing status registered
  ---------------------------------------------------------------------
  stat_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        des      <= '0';
        fbuf     <= '0';
        stat     <= '0';
        tsprog   <= '0';
        buffetch <= '0';
        tu       <= '0';
    elsif clk'event and clk='1' then

        -- fetching descriptor
        if lsm=LSM_DES0 or lsm=LSM_DES1 or
           lsm=LSM_DES2 or lsm=LSM_DES3
        then
          des <= '1';
        else
          des <= '0';
        end if;
        
        -- fetching buffer
        if lsm=LSM_BUF1 or lsm=LSM_BUF2 then
          fbuf <= '1';
        else
          fbuf <= '0';
        end if;
        
        -- writting status
        if tsprog='1' then
          stat <= '1';
        else
          stat <= '0';
        end if;
        
        -- transmit frame status writing in progress
        if (dmaeob='1' and dmaack='1') or itcomp='1' or tcompack_r='1' then
          tsprog <= '0';
        elsif csne='1' and idmareq='0' and icachere='0' then
          tsprog <= '1';
        end if;
        
        -- buffer fetching
        if dmaack_r='1' then
          buffetch <= '0';
        elsif req_r='1' and (lsm=LSM_BUF1 or lsm=LSM_BUF2) then
          buffetch <= '1';
        end if;
        
        -- transmit descriptor unavailable
        if lsm=LSM_IDLE and own='0' then
          tu <= '1';
        elsif own_c='1' then
          tu <= '0';
        end if;
    end if;
  end process; -- stat_reg_proc
  
  ---------------------------------------------------------------------
  -- transmit completition registered
  ---------------------------------------------------------------------
  tcompack_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        tcompack_r <= '0';
        itcomp     <= '0';
    elsif clk'event and clk='1' then

        -- transmit completition acknowledge
        tcompack_r <= tcompack;
        
        -- internal transmit completition
        if tsprog='1' and dmaeob='1' and dmaack='1' then
          itcomp <= '1';
        elsif tcompack_r='1' then
          itcomp <= '0';
        end if;
    end if;
  end process; -- tcompack_reg_proc
  
  ---------------------------------------------------------------------
  -- transmit completition
  -- registered output
  ---------------------------------------------------------------------
  tcomp_drv:
    tcomp <= itcomp;


  --=================================================================--
  --                         Filtering RAM                           --
  --=================================================================--

  ---------------------------------------------------------------------
  -- setup frame processing
  -- registered output
  ---------------------------------------------------------------------
  setp_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        setp <= '0';
    elsif clk'event and clk='1' then

        if csm=CSM_SET then
          setp <= '1';
        else
          setp <= '0';
        end if;
    end if;
  end process; -- setp_reg_proc

  ---------------------------------------------------------------------
  -- filtering ram address
  -- registered output
  ---------------------------------------------------------------------
  ifaddr_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        ifaddr <= (others=>'0');
    elsif clk'event and clk='1' then

        if csm=CSM_IDLE then
          ifaddr <= (others=>'0');
        elsif ifwe='1' then
          ifaddr <= ifaddr+1;
        end if;
    end if;
  end process; -- ifaddr_reg_proc
  
  ---------------------------------------------------------------------
  -- internal filtering ram write enable registered
  ---------------------------------------------------------------------
  ifwe_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        ifwe <= '0';
    elsif clk'event and clk='1' then

        case DATAWIDTH is
          ---------------------------------------
          when 8 =>
          ---------------------------------------
            if csm=CSM_SET and dmaack='1' and
               dmaaddr(1 downto 0)="11" and
               (lsm=LSM_BUF1 or lsm=LSM_BUF2)
            then
              ifwe <= '1';
            else
              ifwe <= '0';
            end if;
          
          ---------------------------------------
          when 16 =>
          ---------------------------------------
            if csm=CSM_SET and dmaack='1' and dmaaddr(1)='1' and
               (lsm=LSM_BUF1 or lsm=LSM_BUF2)
            then
              ifwe <= '1';
            else
              ifwe <= '0';
            end if;
          
          ---------------------------------------
          when others => -- 32
          ---------------------------------------
            if csm=CSM_SET and dmaack='1' and
               (lsm=LSM_BUF1 or lsm=LSM_BUF2)
            then
              ifwe <= '1';
            else
              ifwe <= '0';
            end if;
        end case;
    end if;
  end process; -- ifwe_reg_proc

  ---------------------------------------------------------------------
  -- fifo address
  -- registered output
  ---------------------------------------------------------------------
  faddr_drv:
    faddr <= ifaddr;
  
  ---------------------------------------------------------------------
  -- filtering ram write enable
  -- registered output
  ---------------------------------------------------------------------
  fwe_drv:
    fwe <= ifwe;
  
  ---------------------------------------------------------------------
  -- filtering RAM data
  -- registered output
  ---------------------------------------------------------------------
  fdata_drv:
    fdata <= dataimax_r(15 downto 0);
  

  --=================================================================--
  --                       Power management                          --
  --=================================================================--
  
  ---------------------------------------------------------------------
  -- stop transmit process registered
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
        
        -- stop acknowledge
        -- can enter stopped state only if
        -- descriptor/buffer processing state machine is idle
        if lsm=LSM_IDLE and stop_r='1' then
          stopo <= '1';
        else
          stopo <= '0';
        end if;
    end if;
  end process; -- stop_reg_proc
  

--===================================================================--
--                               OTHERS                              --
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

end RTL;
--*******************************************************************--
