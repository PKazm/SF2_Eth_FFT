-- ********************************************************************/ 
-- Copyright 2013 Actel Corporation.  All rights reserved.
-- IP Solutions Group
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED 
-- IN ADVANCE IN WRITING.  
--  
-- File:  csr.vhd
--     
-- Description: Core10100
--              See below  
--
-- SVN Revision Information:
-- SVN $Revision: 6737 $ 265 $
-- SVN $Date: 2009-02-20 23:42:36 +0530 (Fri, 20 Feb 2009) $  
--   
--
-- Notes: 
--	SAR 73687	  
--
-- *********************************************************************/ 
--
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
-- File name            : csr.vhd
-- File contents        : Entity CSR
--                        Architecture RTL of CSR
-- Purpose              : Control and Status Registers for MAC,
--                        Power state machines for MAC
--                        Interrupt control for MAC
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
-- 2003.03.21 : T.K. - unused CSR registers removed
-- 2003.03.21 : T.K. - flow control support removed
-- 2003.04.01 : T.K. - interrupt section changed
--                     ("csr5_reg_proc", "iint_proc")
-- 2.00.E02   :
-- 2003.04.15 : T.K. - csrdata_proc changed for 16-bit interface
-- 2003.04.15 : T.K. - behaviour of interrupt mitigation control
--                     counters/timers changed
-- 2003.04.15 : T.K. - csr8read_reg_proc changed
-- 2003.04.15 : T.K. - tap_reg_proc changed
-- 2003.04.15 : T.K. - mfcg_r, focg_r signal added
-- 2003.04.15 : T.K. - synchronous processes merged
-- 2.00.E03   :
-- 2003.05.12 : T.K. - csr0_drv changed
-- 2003.05.12 : T.K. - rs_drv: default value changed
-- 2003.05.12 : T.K. - csr6_sr_drv removed
-- 2003.05.12 : T.K. - csr6_reg_proc changed
-- 2.00.E05   :
-- 2003.08.10 : H.C. - csr8_mfo initialization fixed
-- 2003.08.10 : H.C. - csr8_oco initialization fixed
-- 2003.08.10 : H.C. - tcs128 initialization fixed
-- 2.00.E06   :  
-- 2004.01.20 : B.W. - fixed receive address changing possibility 
--                     in unstopped states (F200.05.rxaddrchange) :
--                      * rdbadc_reg_proc process modified
--
-- 2004.01.20 : B.W. - fixed foc counter (F200.05.foc) &
--                     fixed mfc counter (F200.05.mfc) &
--                     statistical counters module integration
--                     support (I200.05.sc) : 
--                      * csr8_reg_proc process modified
--                      * foc_proc process modified
--                      * mfc_proc process modified
--
-- 2004.01.20 : B.W. - fixed gpt timer (F200.05.gpt) :
--                      * gpt_reg_proc process modified
--
-- 2004.01.20 : B.W. - RTL code changes due to VN Check
--                     and code coverage (I200.06.vn):
--                      * csrmux_proc
-- 2.00.E06a  :
-- 2004.02.20 : T.K. - CSR11 reset value fixed (F200.06.gcnt) :
--                      * gpt_reg_proc process changed
-- 2.00.E07   :
-- 2004.03.22 : T.K. - unused comments removed
--*******************************************************************--

library IEEE;
  use work.utility.all;
  use ieee.std_logic_1164.all; 
  use IEEE.STD_LOGIC_UNSIGNED."-";


--*******************************************************************--
  entity CSR is
    generic(
            CSRWIDTH   : INTEGER; 
            ENDIANESS  : INTEGER range 0 to 2;
            DATAWIDTH  : INTEGER; 
            DATADEPTH  : INTEGER; 
            RCDEPTH    : INTEGER 
    );
    port (
            -------------------------- common -------------------------
            -- clock
            clk       : in  STD_LOGIC;
            -- reset
            rst       : in  STD_LOGIC;
            -- interrupt
            int       : out STD_LOGIC;
            
            ----------------------- csr interface ---------------------
            -- csr bus request
            csrreq    : in  STD_LOGIC;
            -- csr read / not write
            csrrw     : in  STD_LOGIC;
            -- csr byte enable
            csrbe     : in  STD_LOGIC_VECTOR(CSRWIDTH/8-1 downto 0);
            -- csr address bus
            csraddr   : in  STD_LOGIC_VECTOR(7 downto 0);
            -- csr data input bus
            csrdatai  : in  STD_LOGIC_VECTOR(CSRWIDTH-1 downto 0);
            -- csr acknowledge
            csrack    : out STD_LOGIC;
            -- csr data output bus
            csrdatao  : out STD_LOGIC_VECTOR(CSRWIDTH-1 downto 0);
            
            ---------------------- reset control ----------------------
            -- software reset output
            rstsofto  : out STD_LOGIC;
            
            ----------------------------- tc --------------------------
            -- transmit in progress
            tprog     : in  STD_LOGIC;
            -- interrupt request
            tireq     : in  STD_LOGIC;
            -- transmit underflow
            unf       : in  STD_LOGIC;
            -- transmit cycle size request
            tcsreq    : in  STD_LOGIC;
            -- interrupt acknowledge
            tiack     : out STD_LOGIC;
            -- transmit cycle size acknowledge
            tcsack    : out STD_LOGIC;
            -- full duplex mode
            fd        : out STD_LOGIC;
            
            --------------------------- tfifo -------------------------
            -- interrupt on completition
            ic        : in  STD_LOGIC;
            -- early transmit interrupt
            etireq    : in  STD_LOGIC;
            -- early transmit interrupt acknowledge
            etiack    : out STD_LOGIC;
            -- treshold mode
            tm        : out STD_LOGIC_VECTOR(2 downto 0);
            -- store and forward mode
            sf        : out STD_LOGIC;
            
            --------------------------- tlsm --------------------------
            -- setup frame processing
            tset      : in  STD_LOGIC;
            -- fetching transmit descriptor
            tdes      : in  STD_LOGIC;
            -- fetching transmit buffer
            tbuf      : in  STD_LOGIC;
            -- writing transmit descriptor status
            tstat     : in  STD_LOGIC;
            -- transmit buffer unavailable
            tu        : in  STD_LOGIC;
            -- transmit poll acknowledge
            tpollack  : in  STD_LOGIC;
            -- filtering type
            ft        : in  STD_LOGIC_VECTOR(1 downto 0);
            -- transmit poll demand
            tpoll     : out STD_LOGIC;
            -- transmit descriptor base address changed
            tdbadc    : out STD_LOGIC;
            -- transmit descriptor base address
            tdbad     : out STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
            
            --------------------------- rc ----------------------------
            -- receive cycle size request
            rcsreq    : in  STD_LOGIC;
            -- receive in progress
            rprog     : in  STD_LOGIC;
            -- receive cycle size acknowledge
            rcsack    : out STD_LOGIC;
            -- receive enable
            ren       : out STD_LOGIC;
            -- receive all
            ra        : out STD_LOGIC;
            -- pass all multicast
            pm        : out STD_LOGIC;
            -- promiscous mode
            pr        : out STD_LOGIC;
            -- pas bad frames
            pb        : out STD_LOGIC;
            -- inverse filtering
            rif       : out STD_LOGIC;
            -- hash only filtering
            ho        : out STD_LOGIC;
            -- hash/perfect filtering
            hp        : out STD_LOGIC;
            
            ------------------- statistical counters ------------------
            -- clear fifo overflow counter acknowledge
            foclack   : in  STD_LOGIC;
            -- clear missed frames counter acknowledge
            mfclack   : in  STD_LOGIC;
            -- fifo overflow counter overflow
            oco       : in  STD_LOGIC;
            -- missed frames counter overflow
            mfo       : in  STD_LOGIC;
            -- fifo overflow counter grey coded
            focg      : in  STD_LOGIC_VECTOR(10 downto 0);
            -- missed frames counter grey coded
            mfcg      : in  STD_LOGIC_VECTOR(15 downto 0);
            -- clear fifo overflow counter request
            focl      : out STD_LOGIC;
            -- clear missed frames counter
            mfcl      : out STD_LOGIC;
            
            ----------------------------- rlsm ------------------------
            -- receive interrupt request
            rireq     : in  STD_LOGIC;
            -- early receive interrupt
            erireq    : in  STD_LOGIC;
            -- receive buffer unavailable
            ru        : in  STD_LOGIC;
            -- receive pool acknowledge
            rpollack  : in  STD_LOGIC;
            -- fetching receive descriptor
            rdes      : in  STD_LOGIC;
            -- fetching receive buffer
            rbuf      : in  STD_LOGIC;
            -- writing receive descriptor status
            rstat     : in  STD_LOGIC;
            -- receive interrupt acknowledge
            riack     : out STD_LOGIC;
            -- early receive interrupt acknowledge
            eriack    : out STD_LOGIC;
            -- receive pool demand
            rpoll     : out STD_LOGIC;
            -- receive descriptor base address changed
            rdbadc    : out STD_LOGIC;
            -- receive descriptor base address
            rdbad     : out STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
            
            ---------------------------- dma --------------------------
            -- big / little endian selection
            ble       : out STD_LOGIC;
            -- descriptor byte ordering
            dbo       : out STD_LOGIC;
            -- transmit/receive priority
            priority  : out STD_LOGIC_VECTOR(1 downto 0);
            -- programmable burst length
            pbl       : out STD_LOGIC_VECTOR(5 downto 0);
            -- descriptor skip length
            dsl       : out STD_LOGIC_VECTOR(4 downto 0);
            
            ---------------- transmit power management ----------------
            -- tc component stopped
            stoptc     : in  STD_LOGIC;
            -- tlsm component stopped
            stoptlsm   : in  STD_LOGIC;
            -- tfifo component stopped
            stoptfifo  : in  STD_LOGIC;
            -- stop transmit request
            stopt      : out STD_LOGIC;
            -- transmit process stopped
            tps        : out STD_LOGIC;
            
            ---------------- transmit power management ----------------
            -- rc component stopped
            stoprc     : in  STD_LOGIC;
            -- rlsm component stopped
            stoprlsm   : in  STD_LOGIC;
            -- rfifo component stopped
            stoprfifo  : in  STD_LOGIC;
            -- stop receive request
            stopr      : out STD_LOGIC;
            -- receive process stopped
            rps        : out STD_LOGIC;
            
            -------------- serial micro-wire rom interface ------------
            -- rom data input
            sdi       : in  STD_LOGIC;
            -- rom clock
            sclk      : out STD_LOGIC;
            -- rom chip select
            scs       : out STD_LOGIC;
            -- rom data output
            sdo       : out STD_LOGIC;
            
            ----------------------- mii management --------------------
            -- mii management data input
            mdi       : in  STD_LOGIC;
            -- mii management clock
            mdc       : out STD_LOGIC;
            -- mii management data output
            mdo       : out STD_LOGIC;
            -- mii management tristate enable
            mden      : out STD_LOGIC;
            csr6_ttm  : out STD_LOGIC
    );
  end CSR;

--*******************************************************************--
architecture RTL of CSR is
    
  -------------------------- common csr -------------------------------
  -- internal csr data
  signal csrdata_c   : STD_LOGIC_VECTOR(31 downto 0);
  -- internal csr byte enable
  signal csrdbe_c    : STD_LOGIC_VECTOR(3 downto 0);  
  -- 2 least significant bits of CSR address
  signal csraddr10   : STD_LOGIC_VECTOR(1 downto 0);
  -- bits 7 downto 2 of CSR address
  signal csraddr72   : STD_LOGIC_VECTOR(5 downto 0);
  -- byte enable for 16-bit interface
  signal csrbe10     : STD_LOGIC_VECTOR(1 downto 0);
  -- CSR0 read value
  signal csr0        : STD_LOGIC_VECTOR(31 downto 0);
  -- CSR5 read value
  signal csr5        : STD_LOGIC_VECTOR(31 downto 0);
  -- CSR6 read value
  signal csr6        : STD_LOGIC_VECTOR(31 downto 0);
  -- CSR7 read value
  signal csr7        : STD_LOGIC_VECTOR(31 downto 0);
  -- CSR8 read value
  signal csr8        : STD_LOGIC_VECTOR(31 downto 0);
  -- CSR9 read value
  signal csr9        : STD_LOGIC_VECTOR(31 downto 0);
  -- CSR11 read value
  signal csr11       : STD_LOGIC_VECTOR(31 downto 0);
  
  ----------------------------- csr0 ----------------------------------
  -- descriptor byte ordering mode
  signal csr0_dbo    : STD_LOGIC;
  -- transmit automatic pooling
  signal csr0_tap    : STD_LOGIC_VECTOR(2 downto 0);
  -- programmable burst length
  signal csr0_pbl    : STD_LOGIC_VECTOR(5 downto 0);
  -- big/little endian
  signal csr0_ble    : STD_LOGIC;
  -- descriptor skip length
  signal csr0_dsl    : STD_LOGIC_VECTOR(4 downto 0);
  -- bus arbitration scheme
  signal csr0_bar    : STD_LOGIC;
  -- software reset
  signal csr0_swr    : STD_LOGIC; 
  
  ----------------------------- csr3 ----------------------------------
  -- receive descriptor base address
  signal csr3        : STD_LOGIC_VECTOR(31 downto 0);
  
  ----------------------------- csr4 ----------------------------------
  -- transmit descriptor base address
  signal csr4        : STD_LOGIC_VECTOR(31 downto 0);
  
  ----------------------------- csr5 ----------------------------------
  -- transmit process state
  signal csr5_ts     : STD_LOGIC_VECTOR(2 downto 0);
  -- receive process state
  signal csr5_rs     : STD_LOGIC_VECTOR(2 downto 0);
  -- normal interrupt summary
  signal csr5_nis    : STD_LOGIC;
  -- abnormal interrupt summary
  signal csr5_ais    : STD_LOGIC;
  -- early receive interrupt
  signal csr5_eri    : STD_LOGIC;
  -- general purpose timer expiration
  signal csr5_gte    : STD_LOGIC;
  -- early transmit interrupt
  signal csr5_eti    : STD_LOGIC;
  -- receive process stopped
  signal csr5_rps    : STD_LOGIC;
  -- receive buffer unavailable
  signal csr5_ru     : STD_LOGIC;
  -- receive interrupt
  signal csr5_ri     : STD_LOGIC;
  -- transmit underflow
  signal csr5_unf    : STD_LOGIC;
  -- transmit buffer unavailable
  signal csr5_tu     : STD_LOGIC;
  -- transmit process stopped
  signal csr5_tps    : STD_LOGIC;
  -- transmit interrupt
  signal csr5_ti     : STD_LOGIC;

  ----------------------------- csr6 ----------------------------------
  -- receive all
  signal csr6_ra     : STD_LOGIC;
  -- transmit treshold mode
  signal csr6_ttm_int : STD_LOGIC;
  -- store and forward
  signal csr6_sf     : STD_LOGIC;
  -- treshold control bits
  signal csr6_tr     : STD_LOGIC_VECTOR(1 downto 0);
  -- start/stop transmit command
  signal csr6_st     : STD_LOGIC;
  -- full duplex mode
  signal csr6_fd     : STD_LOGIC;
  -- pass all multicast
  signal csr6_pm     : STD_LOGIC;
  -- promiscous mode
  signal csr6_pr     : STD_LOGIC;
  -- inverse filtrering
  signal csr6_if     : STD_LOGIC;
  -- pass bad frames
  signal csr6_pb     : STD_LOGIC;
  -- hash only filtering mode
  signal csr6_ho     : STD_LOGIC;
  -- start/stop receive command
  signal csr6_sr     : STD_LOGIC;
  -- hash/perfect receive filtering mode
  signal csr6_hp     : STD_LOGIC;
  
  ----------------------------- csr7 ----------------------------------
  -- normal interrupt summary enable
  signal csr7_nie    : STD_LOGIC;
  -- abnormal interrupt enable
  signal csr7_aie    : STD_LOGIC;
  -- early receive interrupt enable
  signal csr7_ere    : STD_LOGIC;
  -- general purpose timer expiration enable
  signal csr7_gte    : STD_LOGIC;
  -- early transmit interrupt enable
  signal csr7_ete    : STD_LOGIC;
  -- receive stopped enable
  signal csr7_rse    : STD_LOGIC;
  -- receive buffer unavailable enable
  signal csr7_rue    : STD_LOGIC;
  -- receive interrupt enable
  signal csr7_rie    : STD_LOGIC;
  -- underflow interrupt enable
  signal csr7_une    : STD_LOGIC;
  -- transmit buffer unavailable enable
  signal csr7_tue    : STD_LOGIC;
  -- transmit stopped enable
  signal csr7_tse    : STD_LOGIC;
  -- transmit interrupt enable
  signal csr7_tie    : STD_LOGIC;
  
  ----------------------------- csr8 ----------------------------------
  -- fifo overflow counter
  signal csr8_foc    : STD_LOGIC_VECTOR(10 downto 0);
  -- fifo overflow counter overflow
  signal csr8_oco    : STD_LOGIC;
  -- missed frames counter
  signal csr8_mfc    : STD_LOGIC_VECTOR(15 downto 0);
  -- missed frames counter overflow
  signal csr8_mfo    : STD_LOGIC;
  -- csr8 read registered
  signal csr8read    : STD_LOGIC;
  
  
  ----------------------------- csr9 ----------------------------------
  -- mii management data in
  signal csr9_mdi    : STD_LOGIC;
  -- mii management operation mode
  signal csr9_mii    : STD_LOGIC;
  -- mii management write data
  signal csr9_mdo    : STD_LOGIC;
  -- mii management clock
  signal csr9_mdc    : STD_LOGIC; 
  -- serial rom data input
  signal csr9_sdi    : STD_LOGIC;
  -- serial rom clock
  signal csr9_sclk   : STD_LOGIC;
  -- serial rom chip select
  signal csr9_scs    : STD_LOGIC;
  -- serial rom data output
  signal csr9_sdo    : STD_LOGIC;
  
  
  ----------------------------- csr11 ---------------------------------
  -- cycle size
  signal csr11_cs    : STD_LOGIC;
  -- transmit timer
  signal csr11_tt    : STD_LOGIC_VECTOR(3 downto 0);
  -- number of transmit packets
  signal csr11_ntp   : STD_LOGIC_VECTOR(2 downto 0);
  -- receive timer
  signal csr11_rt    : STD_LOGIC_VECTOR(3 downto 0);
  -- number of receive packets
  signal csr11_nrp   : STD_LOGIC_VECTOR(2 downto 0);
  -- continous mode
  signal csr11_con   : STD_LOGIC;
  -- timer value
  signal csr11_tim   : STD_LOGIC_VECTOR(15 downto 0);
  -- csr11 write registered
  signal csr11wr     : STD_LOGIC;
  
  -------------------------------- tlsm -------------------------------
  -- transmit automatic pooling write
  signal tapwr       : STD_LOGIC;
  -- transmit poll command
  signal tpollcmd    : STD_LOGIC;
  -- internal transmit poll
  signal itpoll      : STD_LOGIC;
  -- transmit automatic pooling counter
  signal tapcnt      : STD_LOGIC_VECTOR(2 downto 0);
            
  ------------------------------- tpsm --------------------------------
  -- transmit process state machine combinatorial
  signal tpsm_c      : PSMT;
  -- transmit process state machine registered
  signal tpsm        : PSMT;
  -- stop transmit process
  signal tstopcmd    : STD_LOGIC;
  -- stop transmit process
  signal tstartcmd   : STD_LOGIC;
  -- tc component stopped registered
  signal stoptc_r    : STD_LOGIC;
  -- tlsm component stopped registered
  signal stoptlsm_r  : STD_LOGIC;
  -- tfifo component stopped registered
  signal stoptfifo_r : STD_LOGIC;
  -- internal transmit state
  signal ts_c        : STD_LOGIC_VECTOR(2 downto 0);
  
  ------------------------------- rpsm --------------------------------
  -- receive process state machine combinatorial
  signal rpsm_c      : PSMT;
  -- receive process state machine registered
  signal rpsm        : PSMT;
  -- stop receive process
  signal rstopcmd    : STD_LOGIC;
  -- stop receive process
  signal rstartcmd   : STD_LOGIC;
  -- rc component stopped registered
  signal stoprc_r    : STD_LOGIC;
  -- rlsm component stopped registered
  signal stoprlsm_r  : STD_LOGIC;
  -- rfifo component stopped registered
  signal stoprfifo_r : STD_LOGIC;
  -- receive state for csr combinatorial
  signal rs_c        : STD_LOGIC_VECTOR(2 downto 0);
  
  ------------------------------- rlsm --------------------------------
  -- receive poll command
  signal rpollcmd    : STD_LOGIC;
  
  -------------------------------- int --------------------------------
  -- csr5 write combinatorial
  signal csr5wr_c    : STD_LOGIC;
  -- csr5 write registered
  signal csr5wr      : STD_LOGIC;
  -- general purpose timer expired regsistered
  signal gte         : STD_LOGIC;
  -- interrupt registered
  signal iint        : STD_LOGIC;
  -- receive interrupt request registered
  signal rireq_r     : STD_LOGIC;
  -- receive interrupt request double registered
  signal rireq_r2    : STD_LOGIC;
  -- early receive interrupt
  signal eri         : STD_LOGIC;
  -- early receive interrupt request registered
  signal erireq_r    : STD_LOGIC;
  -- early receive interrupt request double registered
  signal erireq_r2   : STD_LOGIC;
  -- transmit interrupt request registered
  signal tireq_r     : STD_LOGIC;
  -- transmit interrupt request double registered
  signal tireq_r2    : STD_LOGIC;
  -- early transmit interrupt
  signal eti         : STD_LOGIC;
  -- early transmit interrupt request registered
  signal etireq_r    : STD_LOGIC;
  -- early transmit interrupt request double registered
  signal etireq_r2   : STD_LOGIC;
  -- transmit underflow interrupt
  signal unfi        : STD_LOGIC;
  -- transmit underflow interrupt registered
  signal unf_r       : STD_LOGIC;
  -- transmit underflow interrupt double registered
  signal unf_r2      : STD_LOGIC;
  -- transmit buffer unavailable interrupt
  signal tui         : STD_LOGIC;
  -- transmit buffer unavailable registered
  signal tu_r        : STD_LOGIC;
  -- transmit buffer unavailable double registered
  signal tu_r2       : STD_LOGIC;
  -- receive buffer unavailable interrupt
  signal rui         : STD_LOGIC;
  -- receive buffer unavailable registered
  signal ru_r        : STD_LOGIC;
  -- receive buffer unavailable double registered
  signal ru_r2       : STD_LOGIC;
  -- interrupt on completition registered
  signal iic         : STD_LOGIC;
  
  ---------------------------- receive tim ----------------------------
  -- receive cycle size request
  signal rcsreq_r    : STD_LOGIC;
  -- receive cycle size request phase 1
  signal rcsreq_r1   : STD_LOGIC;
  -- receive interrupt mitigation in progress
  signal rimprog     : STD_LOGIC;
  -- receive cycle size counter
  signal rcscnt      : STD_LOGIC_VECTOR(3 downto 0);
  -- receive cycle size=2048*clkr
  signal rcs2048     : STD_LOGIC;
  -- receive cycle size=128*clkr
  signal rcs128      : STD_LOGIC;
  -- receive interrupt mitigation timer
  signal rtcnt       : STD_LOGIC_VECTOR(3 downto 0);
  -- receive interrupt mitigation counter
  signal rcnt        : STD_LOGIC_VECTOR(2 downto 0);
  -- receive interrupt mitigation control expired
  signal rimex       : STD_LOGIC;
  --------------------------- transmit tim ----------------------------
  -- transmit interrupt mitigation in progress
  signal timprog     : STD_LOGIC;
  -- transmit interrupt mitigation timer
  signal ttcnt       : STD_LOGIC_VECTOR(7 downto 0);
  -- transmit interrupt mitigation counter
  signal tcnt        : STD_LOGIC_VECTOR(2 downto 0);
  -- transmit interrupt mitigation control expired
  signal timex       : STD_LOGIC;
  -- transmit cycle size request registered
  signal tcsreq_r1   : STD_LOGIC;
  -- transmit cycle size request double registered
  signal tcsreq_r2   : STD_LOGIC;
  -- transmit cycle size counter
  signal tcscnt      : STD_LOGIC_VECTOR(3 downto 0);
  -- transmit cycle size=2048*clkt
  signal tcs2048     : STD_LOGIC;
  -- transmit cycle size=128*clkt
  signal tcs128      : STD_LOGIC;
  
  ---------------------- statistical counters -------------------------
  -- fifo overflow counter binary combinatorial
  signal foc_c       : STD_LOGIC_VECTOR(10 downto 0);
  -- missed frames counter binary combinatorial
  signal mfc_c       : STD_LOGIC_VECTOR(15 downto 0);
  -- fifo overflow counter grey coded
  signal focg_r      : STD_LOGIC_VECTOR(10 downto 0);
  -- missed frames counter grey coded
  signal mfcg_r      : STD_LOGIC_VECTOR(15 downto 0);
  
  
  ----------------------------- others --------------------------------
  -- general purpose timer timer start command
  signal gstart      : STD_LOGIC;
  -- general purpose timer timer start command
  signal gstart_r    : STD_LOGIC;
  -- general purpose timer
  signal gcnt        : STD_LOGIC_VECTOR(15 downto 0);
  
  
  signal mcsr0_dbo    : STD_LOGIC;
  signal mcsr0_ble    : STD_LOGIC;


begin



--===================================================================--
--                               csr                                 --
--===================================================================--
 csr6_ttm <= csr6_ttm_int; 
  ---------------------------------------------------------------------
  -- 2 least significant bits of CSR address
  ---------------------------------------------------------------------
  csraddr10_drv:
    csraddr10 <= csraddr(1 downto 0);
  
  ---------------------------------------------------------------------
  -- bits 7 downto 2 of CSR address
  ---------------------------------------------------------------------
  csraddr72_drv:
    csraddr72 <= csraddr(7 downto 2);
    
  ---------------------------------------------------------------------
  -- CSR byte enable for 16-bit interface
  ---------------------------------------------------------------------
  csrbe10_drv:
    csrbe10 <= csrbe when CSRWIDTH=16 else (others=>'1');

  ---------------------------------------------------------------------
  -- csr data mux combinatorial
  ---------------------------------------------------------------------  
  csrdata_proc:
  process(csrdatai, csrbe, csraddr, csraddr10, csrbe10)
  begin
  
    csrdata_c <= (others=>'1');
    csrdbe_c  <= (others=>'1');
    
    case CSRWIDTH is
      -------------------------------------
      when 8 =>
      -------------------------------------
        if csrbe(0)='1' then
          case csraddr10 is
            when "00" =>
              csrdata_c(7 downto 0) <= csrdatai;
              csrdbe_c <= "0001";
            
            when "01" =>
              csrdata_c(15 downto 8) <= csrdatai;
              csrdbe_c <= "0010";
            
            when "10" =>
              csrdata_c(23 downto 16) <= csrdatai;
              csrdbe_c <= "0100";
            
            when others => --"11"
              csrdata_c(31 downto 24) <= csrdatai;
              csrdbe_c <= "1000";
          end case;
        else
          csrdbe_c <= "0000";
        end if;
      
      -------------------------------------
      when 16 =>
      -------------------------------------
        case csrbe10 is
          when "11" =>
            if csraddr(1)='1' then
              csrdata_c(31 downto 16) <= csrdatai;
              csrdbe_c <= "1100";
            else
              csrdata_c(15 downto 0) <= csrdatai;
              csrdbe_c <= "0011";
            end if;
            
          when "10" =>
            if csraddr(1)='1' then
              csrdata_c(31 downto 24) <=
                csrdatai(CSRWIDTH-1 downto CSRWIDTH/2);
              csrdbe_c <= "1000";
            else
              csrdata_c(23 downto 16) <=
                csrdatai(CSRWIDTH-1 downto CSRWIDTH/2);
              csrdbe_c <= "0010";
            end if;
          
          when "01" =>
            if csraddr(1)='1' then
              csrdata_c(15 downto 8) <= csrdatai(7 downto 0);
              csrdbe_c <= "0100";
            else
              csrdata_c(7 downto 0) <= csrdatai(7 downto 0);
              csrdbe_c <= "0001";
            end if;
          
          when others => --"00"
            csrdbe_c <= "0000";
        end case;
      
      -------------------------------------
      when others => -- 32
      -------------------------------------
        csrdata_c <= csrdatai(31 downto 0);
        csrdbe_c  <= csrbe(3 downto 0);
    end case;
  end process; -- csrdata_proc
  
  ---------------------------------------------------------------------
  -- csr0
  -- registered outputs
  ---------------------------------------------------------------------  
  csr0_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        mcsr0_dbo <= CSR0_RV(20);			 -- is zero
        csr0_tap  <= CSR0_RV(19 downto 17);
        csr0_pbl  <= CSR0_RV(13 downto 8);
        mcsr0_ble <= CSR0_RV(7);
        csr0_dsl  <= CSR0_RV(6 downto 2);
        csr0_bar  <= CSR0_RV(1);
        csr0_swr  <= CSR0_RV(0);
        tapwr     <= '0';
    elsif clk'event and clk='1' then

        -- Host write ---------------------------
        if  csrrw='0' and csrreq='1' and  csraddr72=CSR0_ID
        then
          
          if csrdbe_c(2)='1' then
            mcsr0_dbo <= csrdata_c(20);
            csr0_tap  <= csrdata_c(19 downto 17);
            tapwr     <= '1';
          else
            tapwr     <= '0';
          end if;
          
          if csrdbe_c(1)='1' then
            csr0_pbl <= csrdata_c(13 downto 8);
          end if;
          
          if csrdbe_c(0)='1' then
            mcsr0_ble <= csrdata_c(7);
            csr0_dsl  <= csrdata_c(6 downto 2);
            csr0_bar  <= csrdata_c(1);
            csr0_swr  <= csrdata_c(0);
          end if;
        else
          tapwr <= '0';
        end if;
    end if;
  end process; -- csr0_reg_proc 
  
 csr0_dbo <= '0' when ENDIANESS=1 else 
             '1' when ENDIANESS=2 else mcsr0_dbo;

 csr0_ble <= '0' when ENDIANESS=1 else 
 			 '1' when ENDIANESS=2 else mcsr0_ble;
			 
  ---------------------------------------------------------------------
  -- transmit pool command
  ---------------------------------------------------------------------
  tpoolcmd_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        tpollcmd <= '0';
    elsif clk'event and clk='1' then

        -- host write ---------------------------
        if csrrw='0' and csrreq='1' and csraddr72=CSR1_ID
        then
          tpollcmd <= '1';
        else
          tpollcmd <= '0';
        end if;
    end if;
  end process; -- tpoolcmd_reg_proc
  
  ---------------------------------------------------------------------
  -- receive pool command
  ---------------------------------------------------------------------
  rpoolcmd_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        rpollcmd <= '0';
    elsif clk'event and clk='1' then

        -- Host write ---------------------------
        if csrrw='0' and csrreq='1' and csraddr72=CSR2_ID then
          rpollcmd <= '1';
        else
          rpollcmd <= '0';
        end if;
    end if;
  end process; -- rpoolcmd_reg_proc
  
  ---------------------------------------------------------------------
  -- CSR3
  ---------------------------------------------------------------------  
  csr3_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        csr3  <= CSR3_RV;
    elsif clk'event and clk='1' then

        -- Host write ---------------------------
        if  csrrw='0' and csrreq='1' and 
            csraddr72=CSR3_ID
        then
          if csrdbe_c(0)='1' then
            csr3(7 downto 0) <= csrdata_c(7 downto 0);
          end if;
          if csrdbe_c(1)='1' then
            csr3(15 downto 8) <= csrdata_c(15 downto 8);
          end if;
          if csrdbe_c(2)='1' then
            csr3(23 downto 16) <= csrdata_c(23 downto 16);
          end if;
          if csrdbe_c(3)='1' then
            csr3(31 downto 24) <= csrdata_c(31 downto 24);
          end if;
        end if;
    end if;
  end process; -- rdbad_reg_proc
  
  ---------------------------------------------------------------------
  -- receive descriptor base address
  ---------------------------------------------------------------------
  rdbad_drv:
    rdbad <= csr3(DATADEPTH-1 downto 0);

  ---------------------------------------------------------------------
  -- receive descriptor base address changed
  -- registered output
  ---------------------------------------------------------------------
  rdbadc_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        rdbadc <= '1';
    elsif clk'event and clk='1' then

        if csrrw='0' and csrreq='1' and csraddr72=CSR3_ID
           and rpsm=PSM_STOP
        then
          rdbadc <= '1';
        elsif rpsm=PSM_RUN then
          rdbadc <= '0';
        end if;
    end if;
  end process; -- rdbadc_reg_proc
  
  ---------------------------------------------------------------------
  -- CSR4
  ---------------------------------------------------------------------  
  csr4_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        csr4  <= CSR4_RV;
    elsif clk'event and clk='1' then

        -- Host write ---------------------------
        if  csrrw='0' and csrreq='1' and csraddr72=CSR4_ID
        then
          if csrdbe_c(0)='1' then
            csr4(7 downto 0) <= csrdata_c(7 downto 0);
          end if;
          if csrdbe_c(1)='1' then
            csr4(15 downto 8) <= csrdata_c(15 downto 8);
          end if;
          if csrdbe_c(2)='1' then
            csr4(23 downto 16) <= csrdata_c(23 downto 16);
          end if;
          if csrdbe_c(3)='1' then
            csr4(31 downto 24) <= csrdata_c(31 downto 24);
          end if;
        end if;
    end if;
  end process; -- csr4_reg_proc
  
  ---------------------------------------------------------------------
  -- transmit descriptor base address changed
  -- registered output
  ---------------------------------------------------------------------
  tdbadc_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        tdbadc <= '1';
    elsif clk'event and clk='1' then

        if csrrw='0' and csrreq='1' and csraddr72=CSR4_ID then
          tdbadc <= '1';
        elsif tpsm=PSM_RUN then
          tdbadc <= '0';
        end if;
    end if;
  end process; -- tdbadc_reg_proc

  ---------------------------------------------------------------------
  -- csr5 host write combinatorial
  ---------------------------------------------------------------------
  csr5wr_drv:
    csr5wr_c <= '1' when csrrw='0' and csrreq='1' and
                         csraddr72=CSR5_ID
                else
                '0';
  
  ---------------------------------------------------------------------
  -- csr5 host write registered
  ---------------------------------------------------------------------
  csr5wr_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        csr5wr <= '0';
    elsif clk'event and clk='1' then

        csr5wr <= csr5wr_c;
    end if;
  end process; -- csr5wr_reg_proc

  ---------------------------------------------------------------------
  -- csr5
  ---------------------------------------------------------------------  
  csr5_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        csr5_ts  <= CSR5_RV(22 downto 20);
        csr5_rs  <= CSR5_RV(19 downto 17);
        csr5_nis <= CSR5_RV(16);
        csr5_ais <= CSR5_RV(15);
        csr5_eri <= CSR5_RV(14);
        csr5_gte <= CSR5_RV(11);
        csr5_eti <= CSR5_RV(10);
        csr5_rps <= CSR5_RV(8);
        csr5_ru  <= CSR5_RV(7);
        csr5_ri  <= CSR5_RV(6);
        csr5_unf <= CSR5_RV(5);
        csr5_tu  <= CSR5_RV(2);
        csr5_tps <= CSR5_RV(1);
        csr5_ti  <= CSR5_RV(0);
    elsif clk'event and clk='1' then

        -- Host write ---------------------------
        if  csr5wr_c='1' then
          if csrdbe_c(2)='1' then
            csr5_nis <= not csrdata_c(16) and csr5_nis;
          end if;
          
          if csrdbe_c(1)='1' then
            csr5_ais <= not csrdata_c(15) and csr5_ais;
            csr5_eri <= not csrdata_c(14) and csr5_eri;
            csr5_gte <= not csrdata_c(11) and csr5_gte;
            csr5_eti <= not csrdata_c(10) and csr5_eti;
            csr5_rps <= not csrdata_c(8)  and csr5_rps;
          end if;
            
          if csrdbe_c(0)='1' then
            csr5_ru  <= not csrdata_c(7)  and csr5_ru;
            csr5_ri  <= not csrdata_c(6)  and csr5_ri;
            csr5_unf <= not csrdata_c(5)  and csr5_unf;
            csr5_tu  <= not csrdata_c(2)  and csr5_tu;
            csr5_tps <= not csrdata_c(1)  and csr5_tps;
            csr5_ti  <= not csrdata_c(0)  and csr5_ti;
          end if;
          
        -- MACs write ---------------------------
        else
          -- interrupt sources
          if timex='1' then
            csr5_ti <= '1';
          end if;
          
          if rimex='1' then
            csr5_ri <= '1';
          end if;
          
          if eti='1' then
            csr5_eti <= '1';
          end if;
          
          if eri='1' then
            csr5_eri <= '1';
          end if;

          if gte='1' then
            csr5_gte <= '1';
          end if;
          
          if tpsm_c=PSM_STOP and (tpsm=PSM_RUN or tpsm=PSM_SUSPEND) then
            csr5_tps <= '1';
          end if;
          
          if rpsm_c=PSM_STOP and (rpsm=PSM_RUN or rpsm=PSM_SUSPEND) then
            csr5_rps <= '1';
          end if;
          
          if rui='1' then
            csr5_ru <= '1';
          end if;
          
          if tui='1' then
            csr5_tu <= '1';
          end if;
          
          if unfi='1' then
            csr5_unf <= '1';
          end if;
          
          -- normal interrupt summary
          if (csr5_ri='1' and csr7_rie='1') or
             (csr5_ti='1' and csr7_tie='1') or
             (csr5_eri='1' and csr7_ere='1') or
             (csr5_tu='1' and csr7_tue='1') or
             (csr5_gte='1' and csr7_gte='1')
          then
            csr5_nis <= '1';
          else
            csr5_nis <= '0';
          end if;
          
          -- abnormal interrupt summary
          if (csr5_eti='1' and csr7_ete='1') or
             (csr5_rps='1' and csr7_rse='1') or
             (csr5_ru='1' and csr7_rue='1') or
             (csr5_unf='1' and csr7_une='1') or
             (csr5_tps='1' and csr7_tse='1')
          then
            csr5_ais <= '1';
          else
            csr5_ais <= '0';
          end if;
          
          -- process states
          csr5_ts <= ts_c;
          csr5_rs <= rs_c;
          
        end if;
    end if;
  end process; -- csr5_reg_proc

  ---------------------------------------------------------------------
  -- csr6
  ---------------------------------------------------------------------  
  csr6_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        csr6_ra  <= CSR6_RV(30);
        csr6_ttm_int <= CSR6_RV(22);
        csr6_sf  <= CSR6_RV(21);
        csr6_tr  <= CSR6_RV(15 downto 14);
        csr6_st  <= CSR6_RV(13);
        csr6_fd  <= CSR6_RV(9);
        csr6_pm  <= CSR6_RV(7);
        csr6_pr  <= CSR6_RV(6);
        csr6_if  <= CSR6_RV(4);
        csr6_pb  <= CSR6_RV(3);
        csr6_ho  <= CSR6_RV(2);
        csr6_sr  <= CSR6_RV(1);
        csr6_hp  <= CSR6_RV(0);
        
    elsif clk'event and clk='1' then

        -- Host write ---------------------------
        if  csrrw='0' and csrreq='1' and
            csraddr72=CSR6_ID
        then
          if csrdbe_c(3)='1' then
            csr6_ra  <= csrdata_c(30);
          end if;
            
          if csrdbe_c(2)='1' then
            csr6_ttm_int <= csrdata_c(22);
            if tpsm=PSM_STOP then
              csr6_sf  <= csrdata_c(21);
            end if;
          end if;
            
          if csrdbe_c(1)='1' then
            csr6_tr  <= csrdata_c(15 downto 14);
            csr6_st  <= csrdata_c(13);
            csr6_fd  <= csrdata_c(9);
          end if;
            
          if csrdbe_c(0)='1' then
            csr6_pm  <= csrdata_c(7);
            csr6_pr  <= csrdata_c(6);
            csr6_pb  <= csrdata_c(3);
            csr6_sr  <= csrdata_c(1);
          end if;
        end if;
        
        -- mac write ----------------------------
        case ft is
          when FT_PERFECT =>
            csr6_ho  <= '0';
            csr6_if <= '0';
            csr6_hp  <= '0';
          
          when FT_HASH =>
            csr6_ho  <= '0';
            csr6_if <= '0';
            csr6_hp  <= '1';
          
          when FT_INVERSE =>
            csr6_ho  <= '0';
            csr6_if <= '1';
            csr6_hp  <= '0';
          
          when others => -- FT_HONLY
            csr6_ho  <= '1';
            csr6_if <= '0';
            csr6_hp  <= '1';
        end case;
    end if;
  end process; -- csr6_reg_proc
  
  
  ---------------------------------------------------------------------
  -- csr7
  ---------------------------------------------------------------------  
  csr7_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        csr7_nie <= CSR7_RV(16);
        csr7_aie <= CSR7_RV(15);
        csr7_ere <= CSR7_RV(14);
        csr7_gte <= CSR7_RV(11);
        csr7_ete <= CSR7_RV(10);
        csr7_rse <= CSR7_RV(8);
        csr7_rue <= CSR7_RV(7);
        csr7_rie <= CSR7_RV(6);
        csr7_une <= CSR7_RV(5);
        csr7_tue <= CSR7_RV(2);
        csr7_tse <= CSR7_RV(1);
        csr7_tie <= CSR7_RV(0);
    elsif clk'event and clk='1' then

        -- Host write ---------------------------
        if  csrrw='0' and csrreq='1' and
            csraddr72=CSR7_ID
        then  
          if csrdbe_c(2)='1' then
            csr7_nie <= csrdata_c(16);
          end if;
          
          if csrdbe_c(1)='1' then
            csr7_aie <= csrdata_c(15);
            csr7_ere <= csrdata_c(14);
            csr7_gte <= csrdata_c(11);
            csr7_ete <= csrdata_c(10);
            csr7_rse <= csrdata_c(8);
          end if;
            
          if csrdbe_c(0)='1' then
            csr7_rue <= csrdata_c(7);
            csr7_rie <= csrdata_c(6);
            csr7_une <= csrdata_c(5);
            csr7_tue <= csrdata_c(2);
            csr7_tse <= csrdata_c(1);
            csr7_tie <= csrdata_c(0);
          end if;
        end if;
    end if;
  end process; -- csr7_reg_proc

  ---------------------------------------------------------------------
  -- csr8 registered
  ---------------------------------------------------------------------
  csr8_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        csr8_oco <= '0';
        csr8_mfo <= '0';
        csr8_foc <= (others=>'0');
        csr8_mfc <= (others=>'0');
    elsif clk'event and clk='1' then

        -- host read ----------------------------
        if not (csrrw='1' and csrreq='1' and csraddr72=CSR8_ID)
        then
          -- MAC write --------------------------
          -- csr8 is updated only if
          -- host read operation is not in progress
          if csr8read='0' then
            csr8_foc <= foc_c;
            csr8_mfc <= mfc_c;
            csr8_oco <= oco;
            csr8_mfo <= mfo;
          end if;
        end if;
    end if;
  end process; -- csr8_reg_proc
  
  ---------------------------------------------------------------------
  -- csr8 read in progress registered
  ---------------------------------------------------------------------
  csr8read_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        csr8read <= '0';
    elsif clk'event and clk='1' then

        if csrrw='1' and csrreq='1' and csraddr72=CSR8_ID then
          csr8read <= csrdbe_c(3);
        else
          csr8read <= '0';
        end if;
    end if;
  end process; -- csr8read_reg_proc
  
  ---------------------------------------------------------------------
  -- csr9
  -- registered outputs
  ---------------------------------------------------------------------  
  csr9_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        csr9_mdi  <= CSR9_RV(19);
        csr9_mii  <= CSR9_RV(18);
        csr9_mdo  <= CSR9_RV(17);
        csr9_mdc  <= CSR9_RV(16);
        csr9_sdi  <= CSR9_RV(2);
        csr9_sclk <= CSR9_RV(1);
        csr9_scs  <= CSR9_RV(0);
        csr9_sdo  <= CSR9_RV(3);
    elsif clk'event and clk='1' then

        -- Host write ---------------------------
        if  csrrw='0' and csrreq='1' and
            csraddr72=CSR9_ID
        then
          if csrdbe_c(0)='1' then
            csr9_sclk <= csrdata_c(1);
            csr9_scs  <= csrdata_c(0);
            csr9_sdo  <= csrdata_c(3);
          end if;
          if csrdbe_c(2)='1' then
            csr9_mii <= csrdata_c(18);
            csr9_mdo <= csrdata_c(17);
            csr9_mdc <= csrdata_c(16);
          end if;
        end if;
        
        -- MACs write ---------------------------
        csr9_mdi <= mdi;
        csr9_sdi <= sdi;
    end if;
  end process; -- csr9_reg_proc

  ---------------------------------------------------------------------
  -- csr11
  ---------------------------------------------------------------------  
  csr11_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        csr11_cs  <= CSR11_RV(31);
        csr11_tt  <= CSR11_RV(30 downto 27);
        csr11_ntp <= CSR11_RV(26 downto 24);
        csr11_rt  <= CSR11_RV(23 downto 20);
        csr11_nrp <= CSR11_RV(19 downto 17);
        csr11_con <= CSR11_RV(16);
        csr11_tim <= CSR11_RV(15 downto 0);
    elsif clk'event and clk='1' then

      
        -- Host write ---------------------------
        if  csrrw='0' and csrreq='1' and
            csraddr72=CSR11_ID
        then
          if csrdbe_c(3)='1' then
            csr11_cs  <= csrdata_c(31);
            csr11_tt  <= csrdata_c(30 downto 27);
            csr11_ntp <= csrdata_c(26 downto 24);
          end if;
            
          if csrdbe_c(2)='1' then
            csr11_rt  <= csrdata_c(23 downto 20);
            csr11_nrp <= csrdata_c(19 downto 17);
            csr11_con <= csrdata_c(16);
          end if;
            
          if csrdbe_c(1)='1' then
            csr11_tim(15 downto 8) <= csrdata_c(15 downto 8);
          end if;
            
          if csrdbe_c(0)='1' then
            csr11_tim(7 downto 0) <= csrdata_c(7 downto 0);
          end if;
        end if;
    end if;
  end process; -- csr11_reg_proc
  
  ---------------------------------------------------------------------
  -- csr11 write registered
  ---------------------------------------------------------------------
  csr11wr_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        csr11wr <= '0';
    elsif clk'event and clk='1' then

        if csrrw='0' and csrreq='1' and
           csraddr72=CSR11_ID
        then
          csr11wr <= '1';
        else
          csr11wr <= '0';
        end if;
    end if;
  end process; -- csr11wr_reg_proc

  ---------------------------------------------------------------------
  -- csr0
  ---------------------------------------------------------------------
  csr0_drv:
    csr0 <= CSR0_RV(31 downto 26) &
            CSR0_RV(25 downto 21) &
            csr0_dbo &
            csr0_tap &
            CSR0_RV(16 downto 14) &
            csr0_pbl &
            csr0_ble &
            csr0_dsl &
            csr0_bar &
            -- add not to fix async reset
            ((not rst) or csr0_swr);
  
  ---------------------------------------------------------------------
  -- csr5
  ---------------------------------------------------------------------
  csr5_drv:
    csr5 <= CSR5_RV(31 downto 23) &
            csr5_ts &
            csr5_rs &
            csr5_nis &
            csr5_ais &
            csr5_eri &
            CSR5_RV(13 downto 12) &
            csr5_gte &
            csr5_eti &
            CSR5_RV(9) &
            csr5_rps &
            csr5_ru &
            csr5_ri &
            csr5_unf &
            CSR5_RV(4 downto 3) &
            csr5_tu &
            csr5_tps &
            csr5_ti;
  
  ---------------------------------------------------------------------
  -- csr6
  ---------------------------------------------------------------------
  csr6_drv:
    csr6 <= CSR6_RV(31) &
            csr6_ra &
            CSR6_RV(29 downto 26) &
            CSR6_RV(25 downto 23) &
            csr6_ttm_int &
            csr6_sf &
            CSR6_RV(20) &
            CSR6_RV(19) &
            CSR6_RV(18) &
            CSR6_RV(17) &
            CSR6_RV(16) &
            csr6_tr &
            csr6_st &
            CSR6_RV(13) &
            CSR6_RV(12 downto 11) &
            csr6_fd &
            CSR6_RV(8) &
            csr6_pm &
            csr6_pr &
            CSR6_RV(5) &
            csr6_if &
            csr6_pb &
            csr6_ho &
            csr6_sr &
            csr6_hp;
  
  ---------------------------------------------------------------------
  -- csr7
  ---------------------------------------------------------------------
  csr7_drv:
    csr7 <= CSR7_RV(31 downto 17) &
            csr7_nie &
            CSR7_aie &
            csr7_ere &
            CSR7_RV(13 downto 12) &
            csr7_gte &
            csr7_ete &
            CSR6_RV(9) &
            csr7_rse &
            csr7_rue &
            csr7_rie &
            csr7_une &
            CSR7_RV(4 downto 3) &
            csr7_tue &
            csr7_tse &
            csr7_tie;
  
  ---------------------------------------------------------------------
  -- csr8
  ---------------------------------------------------------------------
  csr8_drv:
    csr8 <= CSR8_RV(31 downto 29) &
            csr8_oco &
            csr8_foc &
            csr8_mfo &
            csr8_mfc;
  
  ---------------------------------------------------------------------
  -- csr9
  ---------------------------------------------------------------------
  csr9_drv:
    csr9 <= CSR9_RV(31 downto 20) &
            csr9_mdi &
            csr9_mii &
            csr9_mdo &
            csr9_mdc &
            CSR9_RV(15 downto 4) &
            csr9_sdo &
            csr9_sdi &
            csr9_sclk &
            csr9_scs;
        

  ---------------------------------------------------------------------
  -- csr11
  ---------------------------------------------------------------------
  csr11_drv:
    csr11 <= csr11_cs &
             ttcnt(7 downto 4) &
             tcnt(2 downto 0) &
             rtcnt(3 downto 0) &
             rcnt(2 downto 0) &
             csr11_con &
             gcnt;

  ---------------------------------------------------------------------
  -- output csr mux
  ---------------------------------------------------------------------
  csrmux_proc:
  process(
            csr0, csr3, csr4, csr5, csr6, csr7, csr8, csr9, csr11,
            csraddr, csraddr72, csraddr10
         )
  begin
    csrdatao <= (others=>'0');
    case CSRWIDTH is
      -------------------------------------------
      when 8 =>
      -------------------------------------------
        case csraddr10 is
          ---------------------------------------
          when "00" =>
          ---------------------------------------
            case csraddr72 is
              when CSR0_ID  => csrdatao <= csr0(7 downto 0);
              when CSR3_ID  => csrdatao <= csr3(7 downto 0);
              when CSR4_ID  => csrdatao <= csr4(7 downto 0);
              when CSR5_ID  => csrdatao <= csr5(7 downto 0);
              when CSR6_ID  => csrdatao <= csr6(7 downto 0);
              when CSR7_ID  => csrdatao <= csr7(7 downto 0);
              when CSR8_ID  => csrdatao <= csr8(7 downto 0);
              when CSR9_ID  => csrdatao <= csr9(7 downto 0);
              when CSR11_ID => csrdatao <= csr11(7 downto 0);
              when others   => csrdatao <= (others=>'0');
            end case;
          
          ---------------------------------------
          when "01" =>
          ---------------------------------------
            case csraddr72 is
              when CSR0_ID  => csrdatao <= csr0(15 downto 8);
              when CSR3_ID  => csrdatao <= csr3(15 downto 8);
              when CSR4_ID  => csrdatao <= csr4(15 downto 8);
              when CSR5_ID  => csrdatao <= csr5(15 downto 8);
              when CSR6_ID  => csrdatao <= csr6(15 downto 8);
              when CSR7_ID  => csrdatao <= csr7(15 downto 8);
              when CSR8_ID  => csrdatao <= csr8(15 downto 8);
              when CSR9_ID  => csrdatao <= csr9(15 downto 8);
              when CSR11_ID => csrdatao <= csr11(15 downto 8);
              when others   => csrdatao <= (others=>'0');
            end case;
          
          ---------------------------------------
          when "10" =>
          ---------------------------------------
            case csraddr72 is
              when CSR0_ID  => csrdatao <= csr0(23 downto 16);
              when CSR3_ID  => csrdatao <= csr3(23 downto 16);
              when CSR4_ID  => csrdatao <= csr4(23 downto 16);
              when CSR5_ID  => csrdatao <= csr5(23 downto 16);
              when CSR6_ID  => csrdatao <= csr6(23 downto 16);
              when CSR7_ID  => csrdatao <= csr7(23 downto 16);
              when CSR8_ID  => csrdatao <= csr8(23 downto 16);
              when CSR9_ID  => csrdatao <= csr9(23 downto 16);
              when CSR11_ID => csrdatao <= csr11(23 downto 16);
              when others   => csrdatao <= (others=>'0');
            end case;
          
          ---------------------------------------
          when "11" =>
          ---------------------------------------
            case csraddr72 is
              when CSR0_ID  => csrdatao <= csr0(31 downto 24);
              when CSR3_ID  => csrdatao <= csr3(31 downto 24);
              when CSR4_ID  => csrdatao <= csr4(31 downto 24);
              when CSR5_ID  => csrdatao <= csr5(31 downto 24);
              when CSR6_ID  => csrdatao <= csr6(31 downto 24);
              when CSR7_ID  => csrdatao <= csr7(31 downto 24);
              when CSR8_ID  => csrdatao <= csr8(31 downto 24);
              when CSR9_ID  => csrdatao <= csr9(31 downto 24);
              when CSR11_ID => csrdatao <= csr11(31 downto 24);
              when others   => csrdatao <= (others=>'0');
            end case;
          
          ---------------------------------------
          when others =>
          ---------------------------------------
            null;
        end case;
      
      -------------------------------------------
      when 16 =>
      -------------------------------------------
        case csraddr(1) is
          ---------------------------------------
          when '0' =>
          ---------------------------------------
            case csraddr72 is
              when CSR0_ID  => csrdatao <= csr0(15 downto 0);
              when CSR3_ID  => csrdatao <= csr3(15 downto 0);
              when CSR4_ID  => csrdatao <= csr4(15 downto 0);
              when CSR5_ID  => csrdatao <= csr5(15 downto 0);
              when CSR6_ID  => csrdatao <= csr6(15 downto 0);
              when CSR7_ID  => csrdatao <= csr7(15 downto 0);
              when CSR8_ID  => csrdatao <= csr8(15 downto 0);
              when CSR9_ID  => csrdatao <= csr9(15 downto 0);
              when CSR11_ID => csrdatao <= csr11(15 downto 0);
              when others   => csrdatao <= (others=>'0');
            end case;
          
          ---------------------------------------
          when '1' =>
          ---------------------------------------
            case csraddr72 is
              when CSR0_ID  => csrdatao <= csr0(31 downto 16);
              when CSR3_ID  => csrdatao <= csr3(31 downto 16);
              when CSR4_ID  => csrdatao <= csr4(31 downto 16);
              when CSR5_ID  => csrdatao <= csr5(31 downto 16);
              when CSR6_ID  => csrdatao <= csr6(31 downto 16);
              when CSR7_ID  => csrdatao <= csr7(31 downto 16);
              when CSR8_ID  => csrdatao <= csr8(31 downto 16);
              when CSR9_ID  => csrdatao <= csr9(31 downto 16);
              when CSR11_ID => csrdatao <= csr11(31 downto 16);
              when others   => csrdatao <= (others=>'0');
            end case;
          
          ---------------------------------------
          when others =>
          ---------------------------------------
            csrdatao <= (others=>'0');
        end case;
      
      -------------------------------------------
      when others => -- 32
      -------------------------------------------
        case csraddr72 is
          when CSR0_ID  => csrdatao <= csr0;
          when CSR3_ID  => csrdatao <= csr3;
          when CSR4_ID  => csrdatao <= csr4;
          when CSR5_ID  => csrdatao <= csr5;
          when CSR6_ID  => csrdatao <= csr6;
          when CSR7_ID  => csrdatao <= csr7;
          when CSR8_ID  => csrdatao <= csr8;
          when CSR9_ID  => csrdatao <= csr9;
          when CSR11_ID => csrdatao <= csr11;
          when others   => csrdatao <= (others=>'0');
        end case;
    end case;
  end process; -- csrmux_proc
  
  ---------------------------------------------------------------------
  -- csr acknowledge
  -- stuck at '1'
  ---------------------------------------------------------------------
  csrack_drv: csrack <= '1';
  
  
  

--===================================================================--
--                                 dma                               --
--===================================================================--

  ---------------------------------------------------------------------
  -- dma channel priority
  -- combinatorial output
  ---------------------------------------------------------------------
  priority_drv:
    priority <= "01" when (csr0_bar='1' and tprog='0') else
                "10" when (csr0_bar='1' and tprog='1') else
                "00";

  ---------------------------------------------------------------------
  -- descriptor byte ordering
  -- registered output
  ---------------------------------------------------------------------
  dbo_drv:
    dbo <= csr0_dbo;
  
  ---------------------------------------------------------------------
  -- programmable burst length
  -- registered output
  ---------------------------------------------------------------------
  pbl_drv:
    pbl <= csr0_pbl;
  
  ---------------------------------------------------------------------
  -- descriptor skip length
  -- registered output
  ---------------------------------------------------------------------
  dsl_drv:
    dsl <= csr0_dsl;
  
  ---------------------------------------------------------------------
  -- big/little endian for data buffers
  -- registered output
  ---------------------------------------------------------------------
  ble_drv:
    ble <= csr0_ble;


--===================================================================--
--                                tlsm                               --
--===================================================================--

  ---------------------------------------------------------------------
  -- transmit descriptor base address
  ---------------------------------------------------------------------
  tdbad_drv:
    tdbad <= csr4(DATADEPTH-1 downto 0);

  ---------------------------------------------------------------------
  -- internal transmit poll command registered
  ---------------------------------------------------------------------
  itpoll_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        itpoll <= '0';
    elsif clk'event and clk='1' then

        if(
            (
              (
                (csr0_tap="001" or csr0_tap="010" or csr0_tap="011")
                and tcs2048='1'
              )
              or
              (
                (csr0_tap="100" or csr0_tap="101" or
                 csr0_tap="110" or csr0_tap="111")
                and tcs128='1'
              )
            ) and tapcnt="000" and tpsm=PSM_SUSPEND
          )
          or tpollcmd='1' or tstartcmd='1'
        then
          itpoll <= '1';
        elsif tpollack='1' then
          itpoll <= '0';
      end if;
    end if;    
  end process; -- itpoll_reg_proc
  
  ---------------------------------------------------------------------
  -- transmit poll command
  -- registered output
  ---------------------------------------------------------------------
  tpoll_drv:
    tpoll <= itpoll;

  ---------------------------------------------------------------------
  -- tap counter
  ---------------------------------------------------------------------
  tap_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        tapcnt <= (others=>'1');
    elsif clk'event and clk='1' then

        if (
             (csr0_tap="001" or csr0_tap="010" or csr0_tap="011") and
             (tcs2048='1' or tapwr='1')
           )
           or
           (
             (csr0_tap="100" or csr0_tap="101" or
             csr0_tap="110" or csr0_tap="111") and
             (tcs128='1' or tapwr='1')
           )
        then
          if tapcnt="000" or tapwr='1' then
            case csr0_tap is
              when "001" => tapcnt <= "000";
              when "010" => tapcnt <= "010";
              when "011" => tapcnt <= "110";
              when "100" => tapcnt <= "000";
              when "101" => tapcnt <= "001";
              when "110" => tapcnt <= "010";
              when others => tapcnt <= "111";
            end case;
          else
            tapcnt <= tapcnt-1;
          end if;
        end if;
    end if;
  end process; -- tap_reg_proc
  
  

--===================================================================--
--                               tfifo                               --
--===================================================================--

  ---------------------------------------------------------------------
  -- treshold mode
  -- registered output
  ---------------------------------------------------------------------
  tm_drv:
    tm <= csr6_ttm_int & csr6_tr;
  
  ---------------------------------------------------------------------
  -- store and forward mode
  -- registered output
  ---------------------------------------------------------------------
  sf_drv:
    sf <= csr6_sf;


--===================================================================--
--             transmit interrupt mitigation control                 --
--===================================================================--
  
  ---------------------------------------------------------------------
  -- transmit interrupt mitigation
  ---------------------------------------------------------------------
  tim_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        timprog <= '0';
        timex   <= '0';
        ttcnt   <= (others=>'1');
        tcnt    <= (others=>'1');
    elsif clk'event and clk='1' then

        -- transmit interrupt mitigation in progress
        if csr5_ti='1' then
          timprog <= '0';
        elsif tireq_r='1' and tireq_r2='0' then
          timprog <= '1';
        end if;
        
        -- transmit interrupt mitigation expired
        if csr5_ti='1' then
          timex <= '0';
        elsif timprog='1' and
              (
                (ttcnt="00000000" and csr11_tt/="0000") or
                (tcnt="000" and csr11_ntp/="000") or
                (iic='1') or
                (csr11_tt="0000" and csr11_ntp="000")
              )
        then
          timex <= '1';
        end if;
        
        -- transmit timer
        if (tireq_r='1' and tireq_r2='0') or
            csr5_ti='1' or csr11wr='1'
        then
          ttcnt <= csr11_tt & "0000";
        elsif(
               (tcs128='1' and csr11_cs='1') or
               (tcs2048='1' and csr11_cs='0')
             )
             and ttcnt/="00000000" and timprog='1'
        then
          ttcnt <= ttcnt-1;
        end if;
        
        -- transmit counter
        if csr5_ti='1' or csr11wr='1' then
          tcnt <= csr11_ntp;
        elsif tireq_r='1' and tireq_r2='0' and
              tcnt/="000" and csr11_ntp/="000"
        then
          tcnt <= tcnt-1;
        end if;
    end if;
  end process; -- tim_reg_proc
  
  ---------------------------------------------------------------------
  -- transmit cycle size counter registered
  ---------------------------------------------------------------------
  tcscnt_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        tcsreq_r1 <= '0';
        tcsreq_r2 <= '0';
        tcs128    <= '0';
        tcs2048   <= '0';
        tcscnt    <= (others=>'1');
    elsif clk'event and clk='1' then

        tcsreq_r1 <= tcsreq;
        tcsreq_r2 <= tcsreq_r1;
        
        -- transmit cycle size counter
        if tcs128='1' then
          if tcscnt="0000" then
            tcscnt <= "1111";
          else
            tcscnt <= tcscnt-1;
          end if;
        end if;
        
        -- transmit cycle size=clkt/128
        if tcsreq_r1='1' and tcsreq_r2='0' then
          tcs128 <= '1';
        else
          tcs128 <= '0';
        end if;
        
        -- transmit cycle size=clkt/2048
        if tcscnt="0000" and tcs128='1' then
          tcs2048 <= '1';
        else
          tcs2048 <= '0';
        end if;
    end if;
  end process; -- tcscnt_reg_proc
  
  ---------------------------------------------------------------------
  -- transmit cycle size acknowledge
  -- registered output from rcsreq_r
  ---------------------------------------------------------------------
  tcsack_drv:
    tcsack <= tcsreq_r2;



--===================================================================--
--                                 tpsm                              --
--===================================================================--

  ---------------------------------------------------------------------
  -- start/stop transmit command registered
  ---------------------------------------------------------------------
  st_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        tstopcmd  <= '1';
        tstartcmd <= '0';
    elsif clk'event and clk='1' then

        -- stop transmit command
        if tstartcmd='1' then
          tstopcmd <= '0';
        elsif csrrw='0' and csrreq='1' and csrdata_c(13)='0' and
           csraddr72=CSR6_ID and csrdbe_c(1)='1'
        then
          tstopcmd <= '1';
        end if;
        
        -- start transmit command
        if tpsm=PSM_RUN or tpsm=PSM_SUSPEND then
          tstartcmd <= '0';
        elsif csrrw='0' and csrreq='1' and csrdata_c(13)='1' and
              csraddr72=CSR6_ID and csrdbe_c(1)='1'
        then
          tstartcmd <= '1';
        end if;
    end if;
  end process; -- st_reg_proc

  ---------------------------------------------------------------------
  -- Transmit state combinatorial
  ---------------------------------------------------------------------
  ts_drv:
    ts_c <= "000" when tpsm=PSM_STOP else
            "110" when tpsm=PSM_SUSPEND else
            "111" when tstat='1' else
            "001" when tdes='1' else
            "101" when tset='1' else
            "011" when tbuf='1' else
            "010" when tprog='1' else
            csr5_ts;

  ---------------------------------------------------------------------
  -- transmit process stopped registered
  ---------------------------------------------------------------------
  tpsack_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        stoptc_r    <= '0';
        stoptlsm_r  <= '0';
        stoptfifo_r <= '0';
    elsif clk'event and clk='1' then

        stoptc_r    <= stoptc;
        stoptlsm_r  <= stoptlsm;
        stoptfifo_r <= stoptfifo;
    end if;
  end process; -- tpsack_reg_proc
  
  ---------------------------------------------------------------------
  -- transmit process state machine combinatorial
  ---------------------------------------------------------------------
  tpsm_proc:
  process(
           tpsm, tstartcmd, tstopcmd, tu_r,
           stoptc_r, stoptlsm_r, stoptfifo_r
         )
  begin
    case tpsm is
      -------------------------------------------
      when PSM_STOP =>
      -------------------------------------------
        if tstartcmd='1' and stoptc_r='0' and
           stoptlsm_r='0' and stoptfifo_r='0'
        then
          tpsm_c <= PSM_RUN;
        else
          tpsm_c <= PSM_STOP;
        end if;
      
      -------------------------------------------
      when PSM_SUSPEND =>
      -------------------------------------------
        if tstopcmd='1' and stoptc_r='1' and
           stoptlsm_r='1' and stoptfifo_r='1'
        then
          tpsm_c <= PSM_STOP;
        elsif tu_r='0' then
          tpsm_c <= PSM_RUN;
        else
          tpsm_c <= PSM_SUSPEND;
        end if;
      
      -------------------------------------------
      when others => -- PSM_RUN
      -------------------------------------------
        if tstopcmd='1' and stoptc_r='1' and
           stoptlsm_r='1' and stoptfifo_r='1'
        then
          tpsm_c <= PSM_STOP;
        elsif tu_r='1' then
          tpsm_c <= PSM_SUSPEND;
        else
          tpsm_c <= PSM_RUN;
        end if;
    end case;
  end process; -- tpsm_proc  
  
  ---------------------------------------------------------------------
  -- transmit process state machine registered
  ---------------------------------------------------------------------
  tpsm_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        tpsm <= PSM_STOP;
    elsif clk'event and clk='1' then

        tpsm <= tpsm_c;
    end if;
  end process; -- tpsm_reg_proc
  
  ---------------------------------------------------------------------
  -- transmit process stopped
  -- registered output
  ---------------------------------------------------------------------
  tps_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        tps <= '0';
    elsif clk'event and clk='1' then

        if tstartcmd='1' then
          tps <= '0';
        elsif tpsm=PSM_STOP then
          tps <= '1';
        end if;
    end if;
  end process; -- tps_reg_proc
  
  ---------------------------------------------------------------------
  -- stop transmit process request
  -- registered output
  ---------------------------------------------------------------------
  stopt_drv:
    stopt <= tstopcmd;
  

--===================================================================--
--                                 rc                                --
--===================================================================--

  ---------------------------------------------------------------------
  -- receive enable
  -- registered output
  ---------------------------------------------------------------------
  ren_drv:
    ren <= csr6_sr;

  ---------------------------------------------------------------------
  -- full duplex mode
  -- registered output
  ---------------------------------------------------------------------
  fdp_drv:
    fd <= csr6_fd;
  
  ---------------------------------------------------------------------
  -- receive all
  -- registered output
  ---------------------------------------------------------------------
  ra_drv:
    ra <= csr6_ra;
  
  ---------------------------------------------------------------------
  -- pass all multicast
  -- registered output
  ---------------------------------------------------------------------
  pm_drv:
    pm <= csr6_pm;
  
  ---------------------------------------------------------------------
  -- promiscous mode
  -- registered output
  ---------------------------------------------------------------------
  pr_drv:
    pr <= csr6_pr;
  
  ---------------------------------------------------------------------
  -- inverse filtering
  -- registered output
  ---------------------------------------------------------------------
  rif_drv:
    rif <= csr6_if;
  
  ---------------------------------------------------------------------
  -- pass bad frame
  -- registered output
  ---------------------------------------------------------------------
  pb_drv:
    pb <= csr6_pb;
  
  ---------------------------------------------------------------------
  -- hash only filtering mode
  -- registered output
  ---------------------------------------------------------------------
  ho_drv:
    ho <= csr6_ho;
  
  ---------------------------------------------------------------------
  -- hash/perfect filtering mode
  -- registered output
  ---------------------------------------------------------------------
  hp_drv:
    hp <= csr6_hp;


--===================================================================--
--                                rlsm                               --
--===================================================================--

  ---------------------------------------------------------------------
  -- receive poll
  -- registered output
  ---------------------------------------------------------------------
  rpoll_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        rpoll <= '0';
    elsif clk'event and clk='1' then

        if rpollcmd='1' or rstartcmd='1' then
          rpoll <= '1';
        elsif rpollack='1' then
          rpoll <= '0';
        end if;
    end if;    
  end process; -- rpoll_reg_proc

  ---------------------------------------------------------------------
  -- Receive state combinatorial
  ---------------------------------------------------------------------
  rs_drv:
    rs_c <= "000" when rpsm=PSM_STOP else
            "100" when rpsm=PSM_SUSPEND else
            "101" when rstat='1' else
            "001" when rdes='1' else
            "111" when rbuf='1' else
            "010" when rprog='1' else
            "011";



--===================================================================--
--                                 rpsm                              --
--===================================================================--

  ---------------------------------------------------------------------
  -- receive process stopped registered
  ---------------------------------------------------------------------
  rpsack_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        stoprc_r    <= '0';
        stoprlsm_r  <= '0';
        stoprfifo_r <= '0';
    elsif clk'event and clk='1' then

        stoprc_r    <= stoprc;
        stoprlsm_r  <= stoprlsm;
        stoprfifo_r <= stoprfifo;
    end if;
  end process; -- rpsack_reg_proc
  
  ---------------------------------------------------------------------
  -- receive process state machine combinatorial
  ---------------------------------------------------------------------
  rpsm_proc:
  process(
           rpsm, rstartcmd, rstopcmd, rui, ru_r,
           stoprc_r, stoprlsm_r, stoprfifo_r
         )
  begin
    case rpsm is
      -------------------------------------------
      when PSM_STOP =>
      -------------------------------------------
        if rstartcmd='1' and stoprc_r='0' and
           stoprlsm_r='0' and stoprfifo_r='0'
        then
          rpsm_c <= PSM_RUN;
        else
          rpsm_c <= PSM_STOP;
        end if;
      
      -------------------------------------------
      when PSM_SUSPEND =>
      -------------------------------------------
        if rstopcmd='1' and stoprc_r='1' and
           stoprlsm_r='1' and stoprfifo_r='1'
        then
          rpsm_c <= PSM_STOP;
        elsif ru_r='0' then
          rpsm_c <= PSM_RUN;
        else
          rpsm_c <= PSM_SUSPEND;
        end if;
      
      -------------------------------------------
      when others => -- PSM_RUN
      -------------------------------------------
        if rstopcmd='1' and stoprc_r='1' and
           stoprlsm_r='1' and stoprfifo_r='1'
        then
          rpsm_c <= PSM_STOP;
        elsif rui='1' then
          rpsm_c <= PSM_SUSPEND;
        else
          rpsm_c <= PSM_RUN;
        end if;
    end case;
  end process; -- rpsm_proc  
  
  ---------------------------------------------------------------------
  -- receive process state machine registered
  ---------------------------------------------------------------------
  rpsm_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        rpsm <= PSM_STOP;
    elsif clk'event and clk='1' then

        rpsm <= rpsm_c;
    end if;
  end process; -- rpsm_reg_proc
    
  ---------------------------------------------------------------------
  -- receive process stopped
  -- registered output
  ---------------------------------------------------------------------
  rps_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        rps <= '0';
    elsif clk'event and clk='1' then

        if rstartcmd='1' then
          rps <= '0';
        elsif rpsm=PSM_STOP then
          rps <= '1';
        end if;
    end if;
  end process; -- rps_reg_proc

  ---------------------------------------------------------------------
  -- start/stop receive command registered
  ---------------------------------------------------------------------
  rstartcmd_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        rstartcmd <= '0';
        rstopcmd  <= '0';
    elsif clk'event and clk='1' then

        -- start receive command
        if rpsm=PSM_RUN then
          rstartcmd <= '0';
        elsif csrrw='0' and csrreq='1' and csrdata_c(1)='1' and
              csraddr72=CSR6_ID and csrdbe_c(0)='1'
        then
          rstartcmd <= '1';
        end if;
        
        -- stop receive command
        if rpsm=PSM_STOP then
          rstopcmd <= '0';
        elsif csrrw='0' and csrreq='1' and csrdata_c(1)='0' and
              csraddr72=CSR6_ID and csrdbe_c(0)='1'
        then
          rstopcmd <= '1';
        end if;
    end if;
  end process; -- rstartcmd_reg_proc
            
  ---------------------------------------------------------------------
  -- stop transmit process request
  -- registered output
  ---------------------------------------------------------------------
  stopr_drv:
    stopr <= rstopcmd;



--===================================================================--
--               receive interrupt mitigation control                --
--===================================================================--

  ---------------------------------------------------------------------
  -- receive interrupt mitigation registered
  ---------------------------------------------------------------------
  rim_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        rimex   <= '0';
        rimprog <= '0';
        rtcnt   <= (others=>'1');
        rcnt    <= (others=>'1');
    elsif clk'event and clk='1' then

        -- receive interrupt mitigation expired
        if csr5_ri='1' then
          rimex <= '0';
        elsif rimprog='1' and
              (
                (rtcnt="0000" and csr11_rt/="0000") or
                (rcnt="000" and csr11_nrp/="000") or
                (csr11_rt="0000" and csr11_nrp="000")
              )
        then
          rimex <= '1';
        end if;
        
        -- receive interrupt mitigation in progress
        if csr5_ri='1' then
          rimprog <= '0';
        elsif rireq_r='1' and rireq_r2='0' then
          rimprog <= '1';
        end if;
        
        -- receive timer
        if (rireq_r='1' and rireq_r2='0') or csr5_ri='1' then
          rtcnt <= csr11_rt;
        elsif(
               (rcs128='1' and csr11_cs='1') or
               (rcs2048='1' and csr11_cs='0')
             )
             and rtcnt/="0000" and rimprog='1'
        then
          rtcnt <= rtcnt-1;
        end if;
        
        -- receive counter
        if csr5_ri='1' or csr11wr='1' then
          rcnt <= csr11_nrp;
        elsif rireq_r='1' and rireq_r2='0' and
              rcnt/="000" and csr11_nrp/="000"
        then
          rcnt <= rcnt-1;
        end if;
        
    end if;
  end process; -- rim_reg_proc
  
  ---------------------------------------------------------------------
  -- receive cycle size counter registered
  ---------------------------------------------------------------------
  rcscnt_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        rcsreq_r  <= '0';
        rcsreq_r1 <= '0';
        rcs128    <= '0';
        rcs2048   <= '0';
        rcscnt    <= (others=>'1');
    elsif clk'event and clk='1' then

      
        rcsreq_r  <= rcsreq;
        rcsreq_r1 <= rcsreq_r;
      
        -- receive cycle size counter
        if rcs128='1' then
          if rcscnt="0000" then
            rcscnt <= "1111";
          else
            rcscnt <= rcscnt-1;
          end if;
        end if;
        
        -- receive cycle size=clkr/128
        if rcsreq_r='1' and rcsreq_r1='0' then
          rcs128 <= '1';
        else
          rcs128 <= '0';
        end if;

        -- receive cycle size=clkr/2048
        if rcscnt="0000" and rcs128='1' then
          rcs2048 <= '1';
        else
          rcs2048 <= '0';
        end if;
    end if;
  end process; -- rcscnt_reg_proc
  
  ---------------------------------------------------------------------
  -- receive cycle size acknowledge
  -- registered output from rcsreq_r
  ---------------------------------------------------------------------
  rcsack_drv:
    rcsack <= rcsreq_r;



--===================================================================--
--                        interrupt controller                       --
--===================================================================--
  
  ---------------------------------------------------------------------
  -- transmit interrupt requests registered
  ---------------------------------------------------------------------
  ireq_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        rireq_r   <= '0';
        rireq_r2  <= '0';
        erireq_r  <= '0';
        erireq_r2 <= '0';
        tireq_r   <= '0';
        tireq_r2  <= '0';
        etireq_r  <= '0';
        etireq_r2 <= '0';
        unf_r     <= '0';
        unf_r2    <= '0';
        tu_r      <= '0';
        tu_r2     <= '0';
        ru_r      <= '0';
        ru_r2     <= '0';
    elsif clk'event and clk='1' then

        rireq_r   <= rireq;
        rireq_r2  <= rireq_r;
        erireq_r  <= erireq;
        erireq_r2 <= erireq_r;
        tireq_r   <= tireq;
        tireq_r2  <= tireq_r;
        etireq_r  <= etireq;
        etireq_r2 <= etireq_r;
        unf_r     <= unf;
        unf_r2    <= unf_r;
        tu_r      <= tu;
        tu_r2     <= tu_r;
        ru_r      <= ru;
        ru_r2     <= ru_r;
    end if;
  end process; -- ireq_reg_proc

  ---------------------------------------------------------------------
  -- interrupt on completition registered
  ---------------------------------------------------------------------
  iic_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        iic <= '0';
    elsif clk'event and clk='1' then

        if tireq_r='1' and tireq_r2='0' then
          if ic='0' and iint='0' then
            iic <= '0';
          else
            iic <= '1';
          end if;
        end if;
    end if;
  end process; -- ici_reg_proc
  
  ---------------------------------------------------------------------
  -- early transmit interrupt registered
  ---------------------------------------------------------------------
  eti_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        eti <= '0';
    elsif clk'event and clk='1' then

        if etireq_r='1' and etireq_r2='0' then
          eti <= '1';
        elsif csr5wr_c='0' then
          eti <= '0';
        end if;
    end if;
  end process; -- eti_reg_proc
  
  ---------------------------------------------------------------------
  -- early transmit interrupt acknowledge
  -- registered output
  ---------------------------------------------------------------------
  etiack_drv:
    etiack <= etireq_r2;
  
  ---------------------------------------------------------------------
  -- early receive interrupt registered
  ---------------------------------------------------------------------
  eri_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        eri <= '0';
    elsif clk'event and clk='1' then

        if erireq_r='1' and erireq_r2='0' then
          eri <= '1';
        elsif csr5wr_c='0' then
          eri <= '0';
        end if;
    end if;
  end process; -- eri_reg_proc
  
  ---------------------------------------------------------------------
  -- transmit underflow registered
  ---------------------------------------------------------------------
  unfi_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        unfi <= '0';
    elsif clk'event and clk='1' then

        if unf_r='1' and unf_r2='0' then
          unfi <= '1';
        elsif csr5wr_c='0' then
          unfi <= '0';
        end if;
    end if;
  end process; -- unfi_reg_proc
  
  ---------------------------------------------------------------------
  -- transmit buffer unavailable
  ---------------------------------------------------------------------
  tui_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        tui <= '0';
    elsif clk'event and clk='1' then

        if tu_r='1' and tu_r2='0' then
          tui <= '1';
        elsif csr5wr_c='0' then
          tui <= '0';
        end if;
    end if;
  end process; -- tui_reg_proc
  
  ---------------------------------------------------------------------
  -- receive buffer unavailable
  ---------------------------------------------------------------------
  rui_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        rui <= '0';
    elsif clk'event and clk='1' then

        if ru_r='1' and ru_r2='0' then
          rui <= '1';
        elsif csr5wr_c='0' then
          rui <= '0';
        end if;
    end if;
  end process; -- rui_reg_proc

  ---------------------------------------------------------------------
  -- interrupt registered
  ---------------------------------------------------------------------  
  iint_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        iint <= '0';
    elsif clk'event and clk='1' then

        iint <= ((csr5_nis and csr7_nie) or (csr5_ais and csr7_aie)) ;
                -- SAR 73578 and not csr5wr;
    end if;
  end process; -- iint_reg_proc
  
  ---------------------------------------------------------------------
  -- interrupt
  -- registered output from iint
  ---------------------------------------------------------------------
  int_drv:
    int <= iint;
  
  ---------------------------------------------------------------------
  -- receive interrupt acknowledge
  -- registered output
  ---------------------------------------------------------------------
  riack_drv:
    riack <= rireq_r2;
    
  ---------------------------------------------------------------------
  -- early receive interrupt acknowledge
  -- registered output
  ---------------------------------------------------------------------
  eriack_drv:
    eriack <= erireq_r2;

  ---------------------------------------------------------------------
  -- transmit interrupt acknowledge
  -- registered output
  ---------------------------------------------------------------------
  tiack_drv:
    tiack <= tireq_r2;
    
  

--===================================================================--
--                      statistical counters                         --
--===================================================================--

  ---------------------------------------------------------------------
  -- fifo overflow counter binary combinatorial
  ---------------------------------------------------------------------
  foc_proc:
  process(focg_r)
  	variable foc_v : STD_LOGIC_VECTOR(10 downto 0);
  begin
    foc_v(10) := focg_r(10);
    for i in 9 downto 0 loop
      foc_v(i) := foc_v(i+1) xor focg_r(i);
    end loop;
	foc_c <= foc_v;
  end process; -- foc_proc
  
  ---------------------------------------------------------------------
  -- missed frames counter binary combinatorial
  ---------------------------------------------------------------------
  mfc_proc:
  process(mfcg_r)
    variable mfc_v : STD_LOGIC_VECTOR(15 downto 0);
  begin
    mfc_v(15) := mfcg_r(10);
    for i in 14 downto 0 loop
      mfc_v(i) := mfc_v(i+1) xor mfcg_r(i);
    end loop;
	mfc_c <= mfc_v;
  end process; -- mfc_proc
  
  ---------------------------------------------------------------------
  -- statistical counters registered
  ---------------------------------------------------------------------
  sc_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        focl   <= '0';
        mfcl   <= '0';
        focg_r <= (others=>'0');
        mfcg_r <= (others=>'0');
    elsif clk'event and clk='1' then

        -- clear fifo overflow counter
        if csr8read='1' then
          focl <= '1';
        elsif foclack='1' then
          focl <= '0';
        end if;
        
        -- clear missed frames counter
        if csr8read='1' then
          mfcl <= '1';
        elsif mfclack='1' then
          mfcl <= '0';
        end if;
        
        -- fifo overflow counter grey coded
        mfcg_r <= mfcg;
        
        -- missed frame counter
        focg_r <= focg;
    end if;
  end process; -- sc_reg_proc



--===================================================================--
--                          mii management                           --
--===================================================================--

  ---------------------------------------------------------------------
  -- mdo
  -- registered output
  ---------------------------------------------------------------------
  mdo_drv:
    mdo <= csr9_mdo;
  
  ---------------------------------------------------------------------
  -- mden
  -- registered output
  ---------------------------------------------------------------------
  mden_drv:
    mden <= csr9_mii;
  
  ---------------------------------------------------------------------
  -- mdc
  -- registered output
  ---------------------------------------------------------------------
  mdc_drv:
    mdc <= csr9_mdc;
  
  --=================================================================--
  --                           serial rom                            --
  --=================================================================--
  
  ---------------------------------------------------------------------
  -- serial rom clock
  -- registered output
  ---------------------------------------------------------------------
  sclk_drv:
    sclk <= csr9_sclk;
  
  ---------------------------------------------------------------------
  -- serial rom chip select
  -- registered output
  ---------------------------------------------------------------------
  scs_drv:
    scs <= csr9_scs;
  
  ---------------------------------------------------------------------
  -- serial rom data output
  -- registered output
  ---------------------------------------------------------------------
  sdo_drv:
    sdo <= csr9_sdo;
  



--===================================================================--
--                              others                               --
--===================================================================--

  ---------------------------------------------------------------------
  -- general-purpose timer registered
  ---------------------------------------------------------------------
  gpt_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        gstart   <= '0';
        gstart_r <= '0';
        gcnt     <= (others=>'0');
        gte      <= '0';
    elsif clk'event and clk='1' then

        -- general purpose timer start
        if csrrw='0' and csrreq='1' and csrdbe_c(3)='1' and
           csraddr72=CSR11_ID
        then
          gstart <= '1';
        elsif (csr11_con='0' and gte='1') or
               csr11_tim="0000000000000000" then
          gstart <= '0';
        end if;
        if csr11_tim/="0000000000000000" then 
        gstart_r <= gstart;
        else
          gstart_r <= '0';
        end if; 
        
        -- general purpose timer
        if gstart='1' and gstart_r='0' then
          gcnt <= csr11_tim;
        elsif gcnt="0000000000000000" then
          if csr11_con='1' then
            gcnt <= csr11_tim;
          end if;
        elsif tcs2048='1' then
          gcnt <= gcnt-1;
        end if;
        
        -- general purpose timer expired
        if csr5wr_c='1' then
          gte <= '0';
        elsif gstart_r='1' and gcnt="0000000000000000" and
              csr11_tim/="0000000000000000"
        then
          gte <= '1';
        end if;
    end if;
  end process; -- gpt_reg_proc
  
  ---------------------------------------------------------------------
  -- software reset output
  -- registered output
  ---------------------------------------------------------------------
  rstsofto_reg_proc:
  process(clk)
  begin
    if clk'event and clk='1' then
      rstsofto <= csr0_swr;
    end if;
  end process; -- rstsofto_reg_proc

end RTL;
--*******************************************************************--
