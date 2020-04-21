
-- *********************************************************************/ 
-- Copyright 2013 Actel Corporation.  All rights reserved.
-- IP Solutions Group
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED 
-- IN ADVANCE IN WRITING.  
--  
-- File:  mac.vhd
--     
-- Description: Core10100
--              MAC Core Engine   
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
-- File name            : MAC.VHD
-- File contents        : Entity MAC
--                        Architecture STR of MAC
-- Purpose              : Top level structure of MAC
--
-- Destination library  : work
-- Dependencies         : work.UTILITY
--                        IEEE.STD_LOGIC_1164
--
-- Design Engineer      : T.K.
-- Quality Engineer     : M.B.
-- Version              : 2.00.E08
-- Last modification    : 2004-06-07
-----------------------------------------------------------------------

--*******************************************************************--
-- Modifications with respect to Version 2.00.E00:
-- 2.00.E01   :
-- 2003.03.21 : T.K. - MIIWIDTH generic parameter removed
-- 2003.04.01 : T.K. - components/port mappings changed
-- 2.00.E02   :
-- 2003.04.15 : T.K  - unused signals removed
-- 2.00.E06   :  
-- 2004.01.20 : B.W. - statistical counters module integration
--                     support (I200.05.sc) 
--                      * mfcnt_reg_proc process moved from RLSM to RC 
--                      * changed port mapping
--
-- 2.00.E06a  :
-- 2004.02.20 : T.K. - cs collision seen functionality fixed (F200.06.cs) :
--                      * cs and cs_o signals added
--                      * cs related port mapping changed
-- 2.00.E07   :
-- 2004.03.22 : T.K. - unused comments removed
-- 2004.03.22 : L.C. - fixed backoff algorithm (F200.06.backoff)
--                      * crc signal width changed
-- 2.00.E08   :
-- 2004.05.16 : T.K. - modified "BD disable uncomment" section
-- 2004.06.07 : T.K. - modified backoff algorithm (F200.08.backoff)
--                      * crc signal removed
--                      * port mapping for TC and BD components changed
--*******************************************************************--

library IEEE;
use ieee.std_logic_1164.all; 

use work.utility.all;
use work.corecomps.all;

entity MAC is
    generic ( FAMILY     : INTEGER range 0 to 24;
              FULLDUPLEX : INTEGER range 0 to 1;
              ENDIANESS  : INTEGER range 0 to 2;
              CSRWIDTH   : INTEGER range 8 to 32;
              DATAWIDTH  : INTEGER range 8 to 32;
              DATADEPTH  : INTEGER range 8 to 32;
              TFIFODEPTH : INTEGER range 6 to 16;
              RFIFODEPTH : INTEGER range 6 to 16;
              TCDEPTH    : INTEGER range 1 to 8; 
              RCDEPTH    : INTEGER range 1 to 8;
  	          RMII       : integer range 0 to 1  
    );
    port (

    
      ------------------------- clocks / resets -----------------------
      CLKDMA    : in  STD_LOGIC;
      CLKCSR    : in  STD_LOGIC;
      RSTCSR    : in  STD_LOGIC;
      CLKT      : in  STD_LOGIC;
      CLKR      : in  STD_LOGIC;
      RSTTCO    : out STD_LOGIC;
      RSTRCO    : out STD_LOGIC;
      
      ---------------------------- interrupt --------------------------
      INT       : out STD_LOGIC;
      
      -------------------------- clock control ------------------------
      TPS       : out STD_LOGIC;
      RPS       : out STD_LOGIC;
      
      -------------------------- csr interface ------------------------
      CSRREQ    : in  STD_LOGIC;
      CSRRW     : in  STD_LOGIC;
      CSRBE     : in  STD_LOGIC_VECTOR(CSRWIDTH/8-1 downto 0);
      CSRDATAI  : in  STD_LOGIC_VECTOR(CSRWIDTH-1 downto 0);
      CSRADDR   : in  STD_LOGIC_VECTOR(7 downto 0);
      CSRACK    : out STD_LOGIC;
      CSRDATAO  : out STD_LOGIC_VECTOR(CSRWIDTH-1 downto 0);
      
      ----------------------- host data interface ---------------------
      DATAACK    : in  STD_LOGIC;
      DATAREQ    : out STD_LOGIC;
      DATARW     : out STD_LOGIC;
      DATAEOB    : out STD_LOGIC;
      DATAEOBE   : out STD_LOGIC;
      DATAI      : in  STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
      DATAADDR   : out STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
      DATAO      : out STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
      
      ---------------- transmit dual port ram interface ---------------
      TRDATA     : in  STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
      TWE        : out STD_LOGIC;
      TWADDR     : out STD_LOGIC_VECTOR(TFIFODEPTH-1 downto 0);
      TRADDR     : out STD_LOGIC_VECTOR(TFIFODEPTH-1 downto 0);
      TWDATA     : out STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
      
      ------------------ receive dual port ram interface --------------
      RRDATA     : in  STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
      RWE        : out STD_LOGIC;
      RWADDR     : out STD_LOGIC_VECTOR(RFIFODEPTH-1 downto 0);
      RRADDR     : out STD_LOGIC_VECTOR(RFIFODEPTH-1 downto 0);
      RWDATA     : out STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
      
      ------------------ address filtering ram interface --------------
      FRDATA     : in  STD_LOGIC_VECTOR(15 downto 0);
      FWE        : out STD_LOGIC;
      FWADDR     : out STD_LOGIC_VECTOR(5 downto 0);
      FRADDR     : out STD_LOGIC_VECTOR(5 downto 0);
      FWDATA     : out STD_LOGIC_VECTOR(15 downto 0);
      
      -------------------- external address filtering -----------------
      MATCH      : in  STD_LOGIC;
      MATCHVAL   : in  STD_LOGIC;
      MATCHEN    : out STD_LOGIC;
      MATCHDATA  : out STD_LOGIC_VECTOR(47 downto 0);
      
      -------------------- serial micro-wire interface ----------------
      SDI        : in  STD_LOGIC;
      SCLK       : out STD_LOGIC;
      SCS        : out STD_LOGIC;
      SDO        : out STD_LOGIC;
      
      --------------------------- mii interface -----------------------
      RXER       : in  STD_LOGIC;
      RXDV       : in  STD_LOGIC;
      COL        : in  STD_LOGIC;
      CRS        : in  STD_LOGIC;
      RXD        : in  STD_LOGIC_VECTOR(3 downto 0);
      TXEN       : out STD_LOGIC;
      TXER       : out STD_LOGIC;
      TXD        : out STD_LOGIC_VECTOR(3 downto 0);
      MDC        : out STD_LOGIC;
      MDI        : in  STD_LOGIC;
      MDO        : out STD_LOGIC;
      MDEN       : out STD_LOGIC;
      SPEED           : out std_logic;
      RMII_CLK        : in std_logic;
      rrstn           : out std_logic
    );
  end MAC;
  
  
  

--*******************************************************************--
architecture RTL of MAC is


  -------------------------- internal reset ---------------------------
  -- software reset
  signal rstsoft  : STD_LOGIC;
  -- global reset active low
  signal rstn     : STD_LOGIC;
  
  ------------------------- csr configuration -------------------------
  -- programmable burst length
  signal pbl      : STD_LOGIC_VECTOR(5 downto 0);
  -- add crc disable
  signal ac       : STD_LOGIC;
  -- disable padding
  signal dpd      : STD_LOGIC;
  -- descriptor skip length
  signal dsl      : STD_LOGIC_VECTOR(4 downto 0);
  -- transmit pool demand
  signal tpoll    : STD_LOGIC;
  -- transmit descriptors base address
  signal tdbad    : STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
  -- store and forward mode
  signal sf       : STD_LOGIC;
  -- transmit treshold mode
  signal tm       : STD_LOGIC_VECTOR(2 downto 0);
  -- full duplex
  signal fd       : STD_LOGIC;
  -- big/little endian for data buffers
  signal ble      : STD_LOGIC;
  -- descriptor byte ordering
  signal dbo      : STD_LOGIC;
    -- receive all
  signal ra        : STD_LOGIC;
  -- pass all multicast
  signal pm        : STD_LOGIC;
  -- promiscous mode
  signal pr        : STD_LOGIC;
  -- pass bad frames
  signal pb        : STD_LOGIC;
  -- inverse filtering mode
  signal rif       : STD_LOGIC;
  -- hash only filtering mode
  signal ho        : STD_LOGIC;
  -- hash/perfect filtering mode
  signal hp        : STD_LOGIC;
  -- receive poll demand
  signal rpoll    : STD_LOGIC;
  -- receive poll acknowledge
  signal rpollack : STD_LOGIC;
  -- receive descriptors base address
  signal rdbad    : STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
  
  ------------------- csr status data -----------------------
  -- fetching transmit descriptor
  signal tdes     : STD_LOGIC;
  -- fetching transmit buffer
  signal tbuf     : STD_LOGIC;
  -- processing setup frame
  signal tset     : STD_LOGIC;
  -- writing transmit descriptor status
  signal tstat    : STD_LOGIC;
  -- transmit descriptor unavailable
  signal tu       : STD_LOGIC;
  -- filtering type
  signal ft       : STD_LOGIC_VECTOR(1 downto 0);
  -- fetching receive descriptor
  signal rdes     : STD_LOGIC;
  -- writing receive descriptor status
  signal rstat    : STD_LOGIC;
  -- receive descriptor unavailable
  signal ru       : STD_LOGIC;
  -- receive completition
  signal rcomp    : STD_LOGIC;
  -- receive completition acknowledge
  signal rcompack : STD_LOGIC;
  -- transmit completition
  signal tcomp    : STD_LOGIC;
  -- transmit completition acknowledge
  signal tcompack : STD_LOGIC;

  -------------------------------- dma --------------------------------
  -- dma priority scheme
  signal priority : STD_LOGIC_VECTOR(1 downto 0);
  -- transmit request
  signal treq     : STD_LOGIC;
  -- transmit write selection
  signal twrite   : STD_LOGIC;
  -- transmit transfer count
  signal tcnt     : STD_LOGIC_VECTOR(FIFODEPTH_MAX-1 downto 0);
  -- transmit start address
  signal taddr    : STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
  -- transmit data input
  signal tdatai   : STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
  -- transmit single transfer acknowledge
  signal tack     : STD_LOGIC;
  -- transmit end of burst
  signal teob     : STD_LOGIC;
  -- transmit data output
  signal tdatao   : STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
  -- receive request
  signal rreq     : STD_LOGIC;
  -- receive write selection
  signal rwrite   : STD_LOGIC;
  -- receive transfer count
  signal rcnt     : STD_LOGIC_VECTOR(FIFODEPTH_MAX-1 downto 0);
  -- receive start address
  signal raddr    : STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
  -- receive data input
  signal rdatai   : STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
  -- receive single transfer acknowledge
  signal rack     : STD_LOGIC;
  -- receive end of burst
  signal reob     : STD_LOGIC;
  -- receive data output
  signal rdatao   : STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
  -- internal data interface address
  signal idataaddr : STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
  
  --------------------------- transmit FIFO ---------------------------
  -- transmit fifo not full
  signal tfifonf    : STD_LOGIC;
  -- transmit frame cache not full
  signal tfifocnf   : STD_LOGIC;
  -- transmit fifo valid
  signal tfifoval   : STD_LOGIC;
  -- transmit write enable
  signal tfifowe    : STD_LOGIC;
  -- transmit end of frame
  signal tfifoeof   : STD_LOGIC;
  -- transmit last byte enable
  signal tfifobe    : STD_LOGIC_VECTOR(DATAWIDTH/8-1 downto 0);
  -- transmit data output
  signal tfifodata  : STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
  -- transmit fifo level
  signal tfifolev   : STD_LOGIC_VECTOR(TFIFODEPTH-1 downto 0);
  -- transmit fifo read address grey coded
  signal tradg      : STD_LOGIC_VECTOR(TFIFODEPTH-1 downto 0);
  
  ------------------------ transmit frame cache -----------------------
  -- early transmit interrupt acknowledge
  signal etiack    : STD_LOGIC;
  -- early transmit interrupt request
  signal etireq    : STD_LOGIC;
  -- transmit cache not empty
  signal tcsne     : STD_LOGIC;
  -- transmit cache read enable
  signal tcachere  : STD_LOGIC;
  -- interrupt on completition input
  signal ic        : STD_LOGIC;
  -- interrupt on completition input
  signal ici       : STD_LOGIC;
  -- add carry disable input
  signal aci       : STD_LOGIC;
  -- disable padding input
  signal dpdi      : STD_LOGIC;
  -- loss of carrier output
  signal lo_o      : STD_LOGIC;
  -- no carrier output
  signal nc_o      : STD_LOGIC;
  -- late collision output
  signal lc_o      : STD_LOGIC;
  -- excessive collision output
  signal ec_o      : STD_LOGIC;
  -- deferred output
  signal de_o      : STD_LOGIC;
  -- underrun error output
  signal ur_o      : STD_LOGIC;
  -- collision count output
  signal cc_o      : STD_LOGIC_VECTOR(3 downto 0);
  -- loss of carrier input
  signal lo_i      : STD_LOGIC;
  -- no carrier input
  signal nc_i      : STD_LOGIC;
  -- late collision input
  signal lc_i      : STD_LOGIC;
  -- excessive collision input
  signal ec_i      : STD_LOGIC;
  -- deferred input
  signal de_i      : STD_LOGIC;
  -- underrun error input
  signal ur_i      : STD_LOGIC;
  -- collision count input
  signal cc_i      : STD_LOGIC_VECTOR(3 downto 0);
  
  ------------------ transmit linked list management ------------------
  -- transmit poll acknowldge
  signal tpollack : STD_LOGIC;
  -- transmit descriptor base address changed
  signal tdbadc   : STD_LOGIC;
  -- frame status address output
  signal statado  : STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
  -- frame status address input
  signal statadi  : STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
  
  ------------------------- transmit control --------------------------
  -- start of frame request
  signal sofreq    : STD_LOGIC;
  -- end of frame request
  signal eofreq    : STD_LOGIC;
  -- last byte enable
  signal be        : STD_LOGIC_VECTOR(DATAWIDTH/8-1 downto 0);
  -- end of frame fifo address
  signal eofad     : STD_LOGIC_VECTOR(TFIFODEPTH-1 downto 0);
  -- transmit fifo write address grey coded
  signal twadg     : STD_LOGIC_VECTOR(TFIFODEPTH-1 downto 0);
  -- transmit interrupt request
  signal tireq     : STD_LOGIC;
  -- transmit interrupt acknowledge
  signal tiack     : STD_LOGIC;
  -- collision window passed
  signal winp      : STD_LOGIC;
  
  ----------------------- half duplex procedures ----------------------
  -- collision detected
  signal coll      : STD_LOGIC;
  -- carrier sense
  signal carrier   : STD_LOGIC;
  -- backoff in progress
  signal bkoff     : STD_LOGIC;
  -- transmission pending
  signal tpend     : STD_LOGIC;
  -- transmission in progress
  signal tprog     : STD_LOGIC;
  -- preamble transmission in progress
  signal preamble  : STD_LOGIC;
  
  -------------------------- transmit timers --------------------------
  -- transmit timer request
  signal tcsreq    : STD_LOGIC;
  -- transmit timer acknowledge
  signal tcsack    : STD_LOGIC;
  
  --------------------- transmit process management -------------------
  -- stop transmit process
  signal stopt     : STD_LOGIC;
  -- tc component stopped
  signal stoptc    : STD_LOGIC;
  -- tfifo component stopped
  signal stoptfifo : STD_LOGIC;
  -- tlsm component stopped
  signal stoptlsm  : STD_LOGIC;
  
  -------------------------- receive fifo -----------------------------
  -- fifo read address grey coded
  signal rradg     : STD_LOGIC_VECTOR(RFIFODEPTH-1 downto 0);
  -- fifo write address grey coded
  signal rwadg     : STD_LOGIC_VECTOR(RFIFODEPTH-1 downto 0);
  -- fifo read enable
  signal rfifore   : STD_LOGIC;
  -- fifo data
  signal rfifodata : STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
  -- cache read enable
  signal rcachere  : STD_LOGIC;
  -- cache not empty
  signal rcachene  : STD_LOGIC;
  -- cache not full
  signal rcachenf  : STD_LOGIC;
  -- internal write receive data
  signal irwdata   : STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
  -- internal receieve write enable
  signal irwe      : STD_LOGIC;
              
              
  ------------------------- receive control ---------------------------
  -- interrupt acknowledge from csr
  signal riack     : STD_LOGIC;
  -- receive enable
  signal ren       : STD_LOGIC;
  -- receive interrupt request
  signal rireq     : STD_LOGIC;
  -- filtering fail
  signal ff        : STD_LOGIC;
  -- runt frame
  signal rf        : STD_LOGIC;
  -- multicast frame
  signal mf        : STD_LOGIC;
  -- dribbling bit
  signal db        : STD_LOGIC;
  -- mii error
  signal re        : STD_LOGIC;
  -- crc error
  signal ce        : STD_LOGIC;
  -- too long
  signal tl        : STD_LOGIC;
  -- frame type
  signal ftp       : STD_LOGIC;
  -- fifo overflow
  signal ov        : STD_LOGIC;
  -- collision seen
  signal cs        : STD_LOGIC;
  -- length of frame
  signal length    : STD_LOGIC_VECTOR(13 downto 0);
  -- receive in progress
  signal rprog     : STD_LOGIC;
  -- rc poll
  signal rcpoll    : STD_LOGIC;
  
  ------------------------ receive frame cache ------------------------
  -- filtering fail
  signal ff_o      : STD_LOGIC;
  -- runt frame
  signal rf_o      : STD_LOGIC;
  -- multicast frame
  signal mf_o     : STD_LOGIC;
  -- frame too long
  signal tl_o     : STD_LOGIC;
  -- report on mii error
  signal re_o     : STD_LOGIC;
  -- dribbling bit
  signal db_o     : STD_LOGIC;
  -- crc error
  signal ce_o     : STD_LOGIC;
  -- fifo overflow
  signal ov_o     : STD_LOGIC;
  -- collision seen
  signal cs_o     : STD_LOGIC;
  -- frame length
  signal fl_o     : STD_LOGIC_VECTOR(13 downto 0);
  
  ------------------- receive linked list management ------------------
  -- receive descriptor base address changed
  signal rdbadc   : STD_LOGIC;
  -- early receive interrupt request
  signal erireq   : STD_LOGIC;
  -- early receive interrupt acknowledge
  signal eriack   : STD_LOGIC;
  -- fetching receive buffer
  signal rbuf     : STD_LOGIC;

  ------------------- statistical counters ----------------
  -- clear fifo overflow counter acknowledge
  signal foclack   : STD_LOGIC;
  -- clear missed frames counter acknowledge
  signal mfclack   : STD_LOGIC;
  -- fifo overflow counter overflow
  signal oco       : STD_LOGIC;
  -- missed frames counter overflow
  signal mfo       : STD_LOGIC;
  -- fifo overflow counter grey coded
  signal focg      : STD_LOGIC_VECTOR(10 downto 0);
  -- missed frames counter grey coded
  signal mfcg      : STD_LOGIC_VECTOR(15 downto 0);
  -- clear fifo overflow counter request
  signal focl      : STD_LOGIC;
  -- clear missed frames counter
  signal mfcl      : STD_LOGIC;
  
  --------------------- receive process management --------------------
  -- stop receive process
  signal stopr     : STD_LOGIC;
  -- rc component stopped
  signal stoprc    : STD_LOGIC;
  -- rfifo component stopped
  signal stoprfifo : STD_LOGIC;
  -- rlsm component stopped
  signal stoprlsm  : STD_LOGIC;
  
  -------------------------- receive timers ---------------------------
  -- cycle size acknowledge
  signal rcsack    : STD_LOGIC;
  -- cycle size request
  signal rcsreq    : STD_LOGIC;
  signal hrstn     : STD_LOGIC;
  signal prstn     : STD_LOGIC;
  signal rrstn_int : STD_LOGIC;

begin
  rrstn <= rrstn_int;
  ---------------------------------------------------------------------
  -- Direct Memory Access Controller
  ---------------------------------------------------------------------
  U_DMA : DMA
    generic map(
            DATAWIDTH   => DATAWIDTH,
            ENDIANESS   => ENDIANESS,
            DATADEPTH   => DATADEPTH
    )
    port map(  
            ------------------------- common --------------------------
            clk         => clkdma,
            rst         => hrstn,
            
            ---------------------- configuration ----------------------
            priority    => priority,
            ble         => ble,
            dbo         => dbo,
            rdes        => rdes,
            rbuf        => rbuf,
            rstat       => rstat,
            tdes        => tdes,
            tbuf        => tbuf,
            tstat       => tstat,
            
            ---------------------- data interface ---------------------
            dataack     => dataack,
            datai       => datai,
            datareq     => datareq,
            datarw      => datarw,
            dataeob     => dataeob,
            dataeobe    => dataeobe,
            datao       => datao,
            dataaddr    => dataaddr,
            idataaddr   => idataaddr,
            
            ------------------------- channel 1 -----------------------
            req1        => treq,
            write1      => twrite,
            tcnt1       => tcnt,
            addr1       => taddr,
            datai1      => tdatao,
            ack1        => tack,
            eob1        => teob,
            datao1      => tdatai,
            
            ------------------------- channel 2 -----------------------
            req2        => rreq,
            write2      => rwrite,
            tcnt2       => rcnt,
            addr2       => raddr,
            datai2      => rdatao,
            ack2        => rack,
            eob2        => reob,
            datao2      => rdatai
    );

  ---------------------------------------------------------------------
  -- Transmit linked List Management
  ---------------------------------------------------------------------
  U_TLSM : TLSM
    generic map (
            DATAWIDTH  => DATAWIDTH,
            DATADEPTH  => DATADEPTH,
            FIFODEPTH  => TFIFODEPTH
    )
    port map(  
            ---------------------- common ports -----------------------
            clk        => clkdma,
            rst        => hrstn,
            
            ----------------- transmit FIFO control -------------------
            fifonf     => tfifonf,
            fifocnf    => tfifocnf,
            fifoval    => tfifoval,
            fifowe     => tfifowe,
            fifoeof    => tfifoeof,
            fifobe     => tfifobe,
            fifodata   => tfifodata,
            fifolev    => tfifolev,
            
            ----------------- transmit configuration ------------------
            ic         => ici,
            ac         => aci,
            dpd        => dpdi,
            statado    => statadi,
            
            -------------------- transmit status ----------------------
            csne       => tcsne,
            lo         => lo_i,
            nc         => nc_i,
            lc         => lc_i,
            ec         => ec_i,
            de         => de_i,
            ur         => ur_i,
            cc         => cc_i,
            cachere    => tcachere,
            statadi    => statado,
            
            --------------------------- dma ---------------------------
            dmaack     => tack,
            dmaeob     => teob,
            dmadatai   => tdatai,
            dmaaddr    => idataaddr,
            dmareq     => treq,
            dmawr      => twrite,
            dmacnt     => tcnt,
            dmaaddro   => taddr,
            dmadatao   => tdatao,
            
            --------------------- address DP RAM ----------------------
            fwe        => fwe,
            fdata      => fwdata,
            faddr      => fwaddr,
            
            ------------------ csr configuration data -----------------
            dsl        => dsl,
            pbl        => pbl,
            poll       => tpoll,
            dbadc      => tdbadc,
            dbad       => tdbad,
            pollack    => tpollack,
            
            --------------------- csr status data ---------------------
            tcompack   => tcompack,
            tcomp      => tcomp,
            des        => tdes,
            fbuf       => tbuf,
            stat       => tstat,
            setp       => tset,
            tu         => tu,
            ft         => ft,
            
            --------------------- power management --------------------
            stopi      => stopt,
            stopo      => stoptlsm
    );

  ---------------------------------------------------------------------
  -- Transmit FIFO
  ---------------------------------------------------------------------
  U_TFIFO : TFIFO
    generic map (
            DATAWIDTH  => DATAWIDTH,
            DATADEPTH  => DATADEPTH,
            FIFODEPTH  => TFIFODEPTH,
            CACHEDEPTH => TCDEPTH
    )
    port map (  
            ------------------------- Common --------------------------
            clk       => clkdma,
            rst       => hrstn,
            
            ------------------------- DP RAM --------------------------
            ramwe     => twe,
            ramaddr   => twaddr,
            ramdata   => twdata,
            
            -------------------------- tlsm ---------------------------
            fifowe    => tfifowe,
            fifoeof   => tfifoeof,
            fifobe    => tfifobe,
            fifodata  => tfifodata,
            fifonf    => tfifonf,
            fifocnf   => tfifocnf,
            fifoval   => tfifoval,
            flev      => tfifolev,
            
            ------------------ frame configuration cache --------------
            ici       => ici,
            dpdi      => dpdi,
            aci       => aci,
            statadi   => statadi,
            
            --------------------- frame status cache ------------------
            cachere   => tcachere,
            deo       => de_i,
            lco       => lc_i,
            loo       => lo_i,
            nco       => nc_i,
            eco       => ec_i,
            ico       => ic,
            uro       => ur_i,
            csne      => tcsne,
            cco       => cc_i,
            statado   => statado,
            
            ------------------------ tc control -----------------------
            sofreq    => sofreq,
            eofreq    => eofreq,
            dpdo      => dpd,
            aco       => ac,
            beo       => be,
            eofad     => eofad,
            wadg      => twadg,
            
            ------------------------- tc status -----------------------
            tireq     => tireq,
            winp      => winp,
            dei       => de_o,
            lci       => lc_o,
            loi       => lo_o,
            nci       => nc_o,
            eci       => ec_o,
            uri       => ur_o,
            cci       => cc_o,
            radg      => tradg,
            tiack     => tiack,
            
            ------------------ CSR configuration data -----------------
            sf        => sf,
            fdp       => fd,
            tm        => tm,
            pbl       => pbl,
            
            ----------------------- CSR status ------------------------
            etiack    => etiack,
            etireq    => etireq,
            
            --------------------- power management --------------------
            stopi     => stopt,
            stopo     => stoptfifo
    );
  
  ---------------------------------------------------------------------
  -- Transmit controller
  ---------------------------------------------------------------------
  U_TC : TC
    generic map(
              FIFODEPTH => TFIFODEPTH,
              DATAWIDTH => DATAWIDTH
    )
    port map(
              ------------------------ common -------------------------
              clk       => clkt,
              rst       => rrstn_int,
              
              -------------------------- mii --------------------------
              txen      => txen,
              txer      => txer,
              txd       => txd,
              
              ------------------------ DP RAM -------------------------
              ramdata   => trdata,
              ramaddr   => traddr,
              
              ---------------------- fifo control ---------------------
              wadg      => twadg,
              radg      => tradg,
              
              -------------------- transmit control -------------------
              dpd       => dpd,
              ac        => ac,
              sofreq    => sofreq,
              eofreq    => eofreq,
              tiack     => tiack,
              lastbe    => be,
              eofadg    => eofad,
              tireq     => tireq,
              ur        => ur_o,
              de        => de_o,
              
              ------------------ half duplex procedures ---------------
              coll      => coll,
              carrier   => carrier,
              bkoff     => bkoff,
              tpend     => tpend,
              tprog     => tprog,
              preamble  => preamble,
              
              ---------------------- power management -----------------
              stopi     => stopt,
              stopo     => stoptc,
              
              ------------------------- timers ------------------------
              tcsack    => tcsack,
              tcsreq    => tcsreq
    );

UBD1: if FULLDUPLEX=0 generate

    -------------------------------------------------------------------
    -- Backoff and deferring procedures
    
    U : BD
      port map(
                clk       => clkt,
                rst       => rrstn_int,
                col       => col,
                crs       => crs,
                fdp       => fd,
                tprog     => tprog,
                preamble  => preamble,
                tpend     => tpend,
                winp      => winp,
                tiack     => tiack,
                coll      => coll,
                carrier   => carrier,
                bkoff     => bkoff,
                lc        => lc_o,
                lo        => lo_o,
                nc        => nc_o,
                ec        => ec_o,
                cc        => cc_o
      );
end generate;

UBD0: if FULLDUPLEX=1 generate
 
   -------------------------------------------------------------------
   -- deferring disabled
   -- backoff disabled
   -- retry transmission disabled
   -- collision detection disabled
   -- late collision detection disabled
   -- loss of carrier detection disabled
   -- no carrier detection disabled
   -- excessive collision detection disabled
   -- collision counter disabled
 
   carrier <= '0';
   bkoff <= '0';
   winp  <= '1';
   coll  <= '0';
   lc_o  <= '0';
   lo_o  <= '0';
   nc_o  <= '0';
   ec_o  <= '0';
   cc_o  <= (others=>'0');
end generate;

      
    
      
    -------------------------------------------------------------------
    -- Receive Controller
    -------------------------------------------------------------------
    U_RC : RC
      generic map(
              FIFODEPTH => RFIFODEPTH,
              DATAWIDTH => DATAWIDTH
      )
      port map(
              ------------------------ common -------------------------
              clk       => clkr,
              rst       => rrstn_int,
              
              -------------------------- mii --------------------------
              rxdv      => rxdv,
              rxer      => rxer,
              col       => col,
              rxd       => rxd,
              
              ------------------------ dp ram -------------------------
              ramwe     => irwe,
              ramaddr   => rwaddr,
              ramdata   => irwdata,
              
              --------------------- filtering RAM ---------------------
              fdata     => frdata,
              faddr     => fraddr,
              
              ---------------------- fifo control ---------------------
              cachenf   => rcachenf,
              radg      => rradg,
              wadg      => rwadg,
              rprog     => rprog,
              rcpoll    => rcpoll,
              
              -------------------- receive control --------------------
              riack     => riack,
              ren       => ren,
              ra        => ra,
              pm        => pm,
              pr        => pr,
              pb        => pb,
              rif       => rif,
              ho        => ho,
              hp        => hp,
              rireq     => rireq,
              ff        => ff,
              rf        => rf,
              mf        => mf,
              db        => db,
              re        => re,
              ce        => ce,
              tl        => tl,
              ftp       => ftp,
              ov        => ov,
              cs        => cs,
              length    => length,
              
              ---------------- external address filtering -------------
              match     => match,
              matchval  => matchval,
              matchen   => matchen,
              matchdata => matchdata,
              
              ------------------- statistical counters ----------------
              focl      => focl,
              foclack   => foclack,
              oco       => oco,
              focg      => focg,
              mfcl      => mfcl,
              mfclack   => mfclack,
              mfo       => mfo,
              mfcg      => mfcg,
              
              --------------------- power management ------------------
              stopi     => stopr,
              stopo     => stoprc,
              
              ------------------------- timers ------------------------
              rcsack    => rcsack,
              rcsreq    => rcsreq
      );

    -------------------------------------------------------------------
    -- Receive FIFO Controller
    -------------------------------------------------------------------
    U_RFIFO : RFIFO
    generic map(
            DATAWIDTH  => DATAWIDTH,
            DATADEPTH  => DATADEPTH,
            FIFODEPTH  => RFIFODEPTH,
            CACHEDEPTH => RCDEPTH
    )
    port map(
            ------------------------- common --------------------------
            clk       => clkdma,
            rst       => hrstn,
            
            ------------------------- dp ram --------------------------
            ramdata   => rrdata,
            ramaddr   => rraddr,
            
            -------------------------- rlsm ---------------------------
            fifore    => rfifore,
            ffo       => ff_o,
            rfo       => rf_o,
            mfo       => mf_o,
            tlo       => tl_o,
            reo       => re_o,
            dbo       => db_o,
            ceo       => ce_o,
            ovo       => ov_o,
            cso       => cs_o,
            flo       => fl_o,
            fifodata  => rfifodata,
            
            --------------------- frame status cache ------------------
            cachere   => rcachere,
            cachene   => rcachene,
            
            ------------------------ rc control -----------------------
            cachenf   => rcachenf,
            radg      => rradg,
            
            ------------------------- rc status -----------------------
            rireq     => rireq,
            ffi       => ff,
            rfi       => rf,
            mfi       => mf,
            tli       => tl,
            rei       => re,
            dbi       => db,
            cei       => ce,
            ovi       => ov,
            csi       => cs,
            fli       => length,
            wadg      => rwadg,
            riack     => riack,
            
            --------------------- power management --------------------
            stopi     => stopr,
            stopo     => stoprfifo
    );
    
    -------------------------------------------------------------------
    -- Receive linked list management
    -------------------------------------------------------------------
    U_RLSM : RLSM
    generic map(
            DATAWIDTH => DATAWIDTH,
            DATADEPTH => DATADEPTH,
            FIFODEPTH => RFIFODEPTH
    )
    port map(  
            ------------------------ common ---------------------------
            clk       => clkdma,
            rst       => hrstn,
            
            ------------------------- fifo ----------------------------
            cachenf   => rcachenf,
            fifodata  => rfifodata,
            fifore    => rfifore,
            cachere   => rcachere,
            
            -------------------------- dma ----------------------------
            dmaack    => rack,
            dmaeob    => reob,
            dmadatai  => rdatai,
            dmaaddr   => idataaddr,
            dmareq    => rreq,
            dmawr     => rwrite,
            dmacnt    => rcnt,
            dmaaddro  => raddr,
            dmadatao  => rdatao,
            
            --------------------- receive status ----------------------
            rprog     => rprog,
            rcpoll    => rcpoll,
            fifocne   => rcachene,
            ff        => ff_o,
            rf        => rf_o,
            mf        => mf_o,
            db        => db_o,
            re        => re_o,
            ce        => ce_o,
            tl        => tl_o,
            ftp       => ftp,
            ov        => ov_o,
            cs        => cs_o,
            length    => fl_o,

            -------------------- csr configuration --------------------
            pbl       => pbl,
            dsl       => dsl,
            rpoll     => rpoll,
            rdbadc    => rdbadc,
            rdbad     => rdbad,
            rpollack  => rpollack,
            
            ------------------------ csr status -----------------------
            bufack    => eriack,
            rcompack  => rcompack,
            des       => rdes,
            fbuf      => rbuf,
            stat      => rstat,
            ru        => ru,
            rcomp     => rcomp,
            bufcomp   => erireq,
            
            --------------------- power management --------------------
            stopi     => stopr,
            stopo     => stoprlsm
    );
    
    -------------------------------------------------------------------
    -- Control and Status Registers
    -------------------------------------------------------------------
    U_CSR : CSR
    generic map(
            CSRWIDTH   => CSRWIDTH,
            ENDIANESS  => ENDIANESS,
            DATAWIDTH  => DATAWIDTH,
            DATADEPTH  => DATADEPTH,
            RCDEPTH    => RCDEPTH
    )
    port map(
            -------------------------- common -------------------------
            clk       => clkcsr,
            rst       => prstn,
            int       => int,
            
            ----------------------- reset control ---------------------
            rstsofto  => rstsoft,
            
            ----------------------- csr interface ---------------------
            csrreq    => csrreq,
            csrrw     => csrrw,
            csrbe     => csrbe,
            csraddr   => csraddr,
            csrdatai  => csrdatai,
            csrack    => csrack,
            csrdatao  => csrdatao,
            
            ----------------------------- tc --------------------------
            tprog     => tprog,
            tireq     => tcomp,
            unf       => ur_i,
            tiack     => tcompack,
            tcsreq    => tcsreq,
            tcsack    => tcsack,
            fd        => fd,
            
            --------------------------- tfifo -------------------------
            ic        => ic,
            etireq    => etireq,
            etiack    => etiack,
            tm        => tm,
            sf        => sf,
            
            --------------------------- tlsm --------------------------
            tset      => tset,
            tdes      => tdes,
            tbuf      => tbuf,
            tstat     => tstat,
            tu        => tu,
            tpollack  => tpollack,
            ft        => ft,
            tpoll     => tpoll,
            tdbadc    => tdbadc,
            tdbad     => tdbad,
            
            --------------------------- rc ----------------------------
            rireq     => rcomp,
            rcsreq    => rcsreq,
            rprog     => rprog,
            riack     => rcompack,
            rcsack    => rcsack,
            ren       => ren,
            ra        => ra,
            pm        => pm,
            pr        => pr,
            pb        => pb,
            rif       => rif,
            ho        => ho,
            hp        => hp,

            ------------------- statistical counters ------------------
            foclack   => foclack,
            mfclack   => mfclack,
            oco       => oco,
            mfo       => mfo,
            focg      => focg,
            mfcg      => mfcg,
            focl      => focl,
            mfcl      => mfcl,
            
            ---------------------------- rlsm -------------------------
            erireq    => erireq,
            ru        => ru,
            rpollack  => rpollack,
            rdes      => rdes,
            rbuf      => rbuf,
            rstat     => rstat,
            eriack    => eriack,
            rpoll     => rpoll,
            rdbadc    => rdbadc,
            rdbad     => rdbad,
            
            ---------------------------- dma --------------------------
            ble       => ble,
            dbo       => dbo,
            priority  => priority,
            pbl       => pbl,
            dsl       => dsl,
            
            ---------------- transmit power management ----------------
            stoptc    => stoptc,
            stoptlsm  => stoptlsm,
            stoptfifo => stoptfifo,
            stopt     => stopt,
            tps       => tps,
            
            ---------------- recieve power management ----------------
            stoprc    => stoprc,
            stoprlsm  => stoprlsm,
            stoprfifo => stoprfifo,
            stopr     => stopr,
            rps       => rps,
            
            -------------- serial micro-wire rom interface ------------
            sdi       => sdi,
            sclk      => sclk,
            scs       => scs,
            sdo       => sdo,
            
            ---------------------- mii management ---------------------
            mdi       => mdi,
            mdc       => mdc,
            mdo       => mdo,
            mden      => mden,
	    csr6_ttm  => SPEED
	    
    );

  ---------------------------------------------------------------------
  -- Reset controller
  ---------------------------------------------------------------------
 
  URSTCMII: if RMII=0 generate

    -------------------------------------------------------------------
    -- Backoff and deferring procedures
    
  UMII_RSTC : RSTC
    port map (
            ------------------------ clocks ---------------------------
            clkdma      => clkdma,
            clkcsr      => clkcsr,
            clkr        => CLKT,
            
            ------------------------- reset ---------------------------
            rstcsr      => rstcsr,
            rstsoft     => rstsoft,
	    hrstn    => hrstn,
            prstn    => prstn,
            rrstn    => rrstn_int
            
    );
end generate;
 URSTCRMII: if RMII=1 generate

    -------------------------------------------------------------------
    -- Backoff and deferring procedures
    
  URMII_RSTC : RSTC
    port map (
            ------------------------ clocks ---------------------------
            clkdma      => clkdma,
            clkcsr      => clkcsr,
            clkr        => RMII_CLK,
            
            ------------------------- reset ---------------------------
            rstcsr      => rstcsr,
            rstsoft     => rstsoft,
	    hrstn    => hrstn,
            prstn    => prstn,
            rrstn    => rrstn_int
            
    );
end generate;

  
  
  -- U_RSTC : RSTC
 --   port map (
 --           ------------------------ clocks ---------------------------
 --           clkdma      => clkdma,
 --           clkcsr      => clkcsr,
 --           clkr        => RMII_CLK,
 --           
 --           ------------------------- reset ---------------------------
 --           rstcsr      => rstcsr,
 --           rstsoft     => rstsoft,
	--    hrstn    => hrstn,
        --    prstn    => prstn,
        --    rrstn    => rrstn_int
            
  --  );
  
  ---------------------------------------------------------------------
  -- receive dp ram write enable
  -- registered output
  ---------------------------------------------------------------------
  rwe_drv:
    rwe <= irwe;
  
  ---------------------------------------------------------------------
  -- receive dp ram write data
  -- registered output
  ---------------------------------------------------------------------
  rwdata_drv:
    rwdata <= irwdata;
  
  ---------------------------------------------------------------------
  -- transmit reset output
  -- registered output
  ---------------------------------------------------------------------
  rsttco_drv:
    rsttco <= rrstn_int;
  
  ---------------------------------------------------------------------
  -- receive reset output
  -- registered output
  ---------------------------------------------------------------------
  rstrco_drv:
    rstrco <= rrstn_int;
  
end RTL;

--*******************************************************************--
