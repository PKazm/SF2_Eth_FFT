-- *********************************************************************/ 
-- Copyright 2013 Actel Corporation.  All rights reserved.
-- IP Solutions Group
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED 
-- IN ADVANCE IN WRITING.  
--  
-- File:  corecomps.vhd
--     
-- Description: Core10100
--              Low Level Component Declarations  
--
-- SVN Revision Information:
-- SVN $Revision: 6737 $
-- SVN $Date: 2009-02-20 23:42:36 +0530 (Fri, 20 Feb 2009) $  
--   
--
-- Notes: SAR73352
--		  
--
-- *********************************************************************/ 
--


library IEEE;
use ieee.std_logic_1164.all; 

--use work.utility.all;

package corecomps is

 -- THIS SHOULD BE REFERENCED IN UTILITY BUT DUE TO A LIBERO BUG IS 
 -- DECLARED LOCALLY WITH A DIFFERENT NAME
 
 --   constant FIFODEPTH_MAX : INTEGER := 15;
    constant FIFODEPTH_MAXX : INTEGER := 15;

  ---------------------------------------------------------------------
  -- Direct Memory Access
  ---------------------------------------------------------------------
  component DMA
    generic(
            DATAWIDTH : INTEGER; 
            DATADEPTH : INTEGER;
            ENDIANESS : integer range 0 to 2
    );
    port (  
            ---------------------- Common ports -----------------------
            -- global clock
            clk       : in  STD_LOGIC;
            -- hardware reset
            rst       : in  STD_LOGIC;
            
            ---------------------- Configuration ----------------------
            -- channel priority
            priority  : in  STD_LOGIC_VECTOR(1 downto 0);
            -- big / little endian selection
            ble       : in  STD_LOGIC;
            -- descriptor byte ordering
            dbo       : in  STD_LOGIC;
            -- fetching receive descriptor
            rdes      : in  STD_LOGIC;
            -- fetching receive buffer
            rbuf      : in  STD_LOGIC;
            -- writing receive descriptor status
            rstat     : in  STD_LOGIC;
            -- fetching transmit descriptor
            tdes      : in  STD_LOGIC;
            -- fetching transmit buffer
            tbuf      : in  STD_LOGIC;
            -- writing transmit descriptor status
            tstat     : in  STD_LOGIC;
            
            --------------------- Data interface ----------------------
            -- data acknowledge
            dataack   : in  STD_LOGIC;
            -- data input bus
            datai     : in  STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
            -- data request
            datareq   : out STD_LOGIC;
            -- data read / not write
            datarw    : out STD_LOGIC;
            -- data end of burst
            dataeob   : out STD_LOGIC;
            dataeobe  : out STD_LOGIC;
            -- data output bus
            datao     : out STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
            -- data address
            dataaddr  : out STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
            -- internal data address
            idataaddr : out STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
            
            --------------------- Channel 1 ---------------------------
            -- request
            req1      : in  STD_LOGIC;
            -- write selection
            write1    : in  STD_LOGIC;
            -- transfer count
            tcnt1     : in  STD_LOGIC_VECTOR(FIFODEPTH_MAXX-1 downto 0);
            -- start address
            addr1     : in  STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
            -- data input
            datai1    : in  STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
            -- single transfer acknowledge
            ack1      : out STD_LOGIC;
            -- end of burst
            eob1      : out STD_LOGIC;
            -- data output
            datao1    : out STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
            
            --------------------- Channel 2 ---------------------------
            -- request
            req2      : in  STD_LOGIC;
            -- write selection
            write2    : in  STD_LOGIC;
            -- transfer count
            tcnt2     : in  STD_LOGIC_VECTOR(FIFODEPTH_MAXX-1 downto 0);
            -- start address
            addr2     : in  STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
            -- data input
            datai2    : in  STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
            -- single transfer acknowledge
            ack2      : out STD_LOGIC;
            -- end of burst
            eob2      : out STD_LOGIC;
            -- data output
            datao2    : out STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0)
    );
  end component;

  ---------------------------------------------------------------------
  -- Backoff and deferring
  ---------------------------------------------------------------------
  component BD
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
  end component;

  ---------------------------------------------------------------------
  -- Transmit FIFO
  ---------------------------------------------------------------------
  component TFIFO
    generic(
            -- Data interface data bus width
            DATAWIDTH  : INTEGER := 32; -- 8|16|32|64
            -- Data interface address bus width
            DATADEPTH  : INTEGER := 32;
            -- Depth of the transmit and receive FIFO memories
            FIFODEPTH  : INTEGER := 9;
            -- Depth of the frame cache for transmit FIFO
            CACHEDEPTH : INTEGER := 1
    );
    port (  
            ---------------------- Common ports -----------------------
            -- global clock
            clk       : in  STD_LOGIC;
            -- hardware reset
            rst       : in  STD_LOGIC;
            
            ------------------------- DP RAM --------------------------
            -- ram write enable
            ramwe    : out STD_LOGIC;
            -- ram address
            ramaddr  : out STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
            -- ram data
            ramdata  : out STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
            
            -------------------------- TLSM ----------------------------
            -- fifo write enable
            fifowe   : in  STD_LOGIC;
            -- fifo end of frame
            fifoeof  : in  STD_LOGIC;
            -- fifo last byte enable
            fifobe   : in  STD_LOGIC_VECTOR(DATAWIDTH/8-1 downto 0);
            -- fifo data
            fifodata : in  STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
            -- fifo not full
            fifonf   : out STD_LOGIC;
            -- frame cache not full
            fifocnf  : out STD_LOGIC;
            -- fifo valid
            fifoval  : out STD_LOGIC;
            -- fifo level
            flev     : out STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
            
            ------------------ frame configuration cache --------------
            -- interrupt on completition
            ici       : in  STD_LOGIC;
            -- disabled padding
            dpdi      : in  STD_LOGIC;
            -- add crc disable
            aci       : in  STD_LOGIC;
            -- frame status address (for TLSM only)
            statadi   : in  STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
            
            --------------------- frame status cache ------------------
            -- cache read enable
            cachere   : in  STD_LOGIC;
            -- deferred
            deo       : out STD_LOGIC;
            -- late collission
            lco       : out STD_LOGIC;
            -- loss of carrier
            loo       : out STD_LOGIC;
            -- no carrier
            nco       : out STD_LOGIC;
            -- excessive collisions
            eco       : out STD_LOGIC;
            -- cache not empty
            csne      : out STD_LOGIC;
            -- interrupt on completition
            ico       : out STD_LOGIC;
            -- underrun
            uro       : out STD_LOGIC;
            -- collision count
            cco       : out STD_LOGIC_VECTOR(3 downto 0);
            -- frame status address (for TLSM only)
            statado   : out STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
            
            
            ------------------------ TC control ------------------------
            -- start of frame request
            sofreq    : out STD_LOGIC;
            -- end of frame request
            eofreq    : out STD_LOGIC;
            -- disabled padding
            dpdo      : out STD_LOGIC;
            -- add crc disable
            aco       : out STD_LOGIC;
            -- last byte enable
            beo       : out STD_LOGIC_VECTOR(DATAWIDTH/8-1 downto 0);
            -- end of frame fifo address
            eofad     : out STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
            -- fifo write address grey coded
            wadg      : out STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
            
            ------------------------- TC status -----------------------
            -- transmit interrupt
            tireq     : in  STD_LOGIC;
            -- collision window passed
            winp      : in  STD_LOGIC;
            -- deferred
            dei       : in  STD_LOGIC;
            -- late collission
            lci       : in  STD_LOGIC;
            -- loss of carrier
            loi       : in  STD_LOGIC;
            -- no carrier
            nci       : in  STD_LOGIC;
            -- excessive collisions
            eci       : in  STD_LOGIC;
            -- underrun
            uri       : in  STD_LOGIC;
            -- collision count
            cci       : in  STD_LOGIC_VECTOR(3 downto 0);
            -- fifo read address grey coded
            radg      : in  STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
            -- transmit interrupt acknowledge
            tiack     : out STD_LOGIC;
            
            ------------------ CSR configuration data -----------------
            -- store and forward mode
            sf        : in  STD_LOGIC;
            -- full duplex mode
            fdp       : in  STD_LOGIC;
            -- treshold mode
            tm        : in  STD_LOGIC_VECTOR(2 downto 0);
            -- programmable burst length
            pbl       : in  STD_LOGIC_VECTOR(5 downto 0);
            
            ----------------------- CSR status ------------------------
            -- early transmit interrupt acknowledge
            etiack    : in  STD_LOGIC;
            -- early transmit interrupt request
            etireq    : out STD_LOGIC;
            
            --------------------- power management --------------------
            -- stop transmit process input
            stopi    : in  STD_LOGIC;
            -- stop transmit process output
            stopo    : out STD_LOGIC
    );
  end component;
  
  ---------------------------------------------------------------------
  -- Transmit linked List Management
  ---------------------------------------------------------------------
  component TLSM
    generic(
            -- Data interface data bus width
            DATAWIDTH : INTEGER := 32; -- 8|16|32|64
            -- Data interface address bus width
            DATADEPTH : INTEGER := 32;
            -- Depth of the FIFO memory
            FIFODEPTH : INTEGER := 9
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
            dmacnt    : out STD_LOGIC_VECTOR(FIFODEPTH_MAXX-1 downto 0);
            -- start address
            dmaaddro  : out STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
            -- data output
            dmadatao  : out STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
            
            --------------------- address DP RAM ----------------------
            -- address ram write enable
            fwe       : out STD_LOGIC;
            -- address ram data
            fdata     : out STD_LOGIC_VECTOR(15 downto 0);
            -- address ram address
            faddr     : out STD_LOGIC_VECTOR(5 downto 0);
            
            
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
            stopi     : in  STD_LOGIC;
            -- stop transmit process output
            stopo     : out STD_LOGIC
    );
  end component;

  ---------------------------------------------------------------------
  -- Transmit controller
  ---------------------------------------------------------------------
  component TC
    generic (
              -- Depth of the transmit FIFO memory
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
              wadg      : in  STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
              -- fifo read address grey coded
              radg      : out STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
              
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
              -- end of frame address
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
              -- carrier sense
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
  end component;

  ---------------------------------------------------------------------
  -- Control and Status Registers
  ---------------------------------------------------------------------
  component CSR
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
	    -- used as speed bit for RMII
            csr6_ttm  : out STD_LOGIC
    );
  end component;

  ---------------------------------------------------------------------
  -- Receive Controller
  ---------------------------------------------------------------------
  component RC
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
              fdata     : in  STD_LOGIC_VECTOR(15 downto 0);
              -- filtering ram address
              faddr     : out STD_LOGIC_VECTOR(5 downto 0);
              
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
              -- interrupt acknowledge
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
              
              ---------------- external address filtering -------------
              -- match input
              match      : in  STD_LOGIC;
              -- match valid
              matchval   : in  STD_LOGIC;
              -- match enable
              matchen    : out STD_LOGIC;
              -- match data
              matchdata  : out STD_LOGIC_VECTOR(47 downto 0);
              
              ------------------- statistical counters ----------------
              -- clear fifo overflow counter request
              focl      : in  STD_LOGIC;
              -- clear missed frames counter
              mfcl      : in  STD_LOGIC;
              -- clear missed frames counter acknowledge
              mfclack   : out STD_LOGIC;
              -- missed frames counter overflow
              mfo       : out STD_LOGIC;
              -- clear fifo overflow counter acknowledge
              foclack   : out STD_LOGIC;
              -- fifo overflow counter overflow
              oco       : out STD_LOGIC;
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
  end component;
  
  ---------------------------------------------------------------------
  -- Receive FIFO Controller
  ---------------------------------------------------------------------
  component RFIFO
    generic(
            -- Data interface data bus width
            DATAWIDTH  : INTEGER := 32; -- 8|16|32|64
            -- Data interface address bus width
            DATADEPTH  : INTEGER := 32;
            -- Depth of the FIFO memory
            FIFODEPTH  : INTEGER := 9;
            -- Depth of the frame cache for FIFO
            CACHEDEPTH : INTEGER := 2
    );
    port (  
            -------------------------- common -------------------------
            -- global clock
            clk       : in  STD_LOGIC;
            -- hardware reset
            rst       : in  STD_LOGIC;
            
            ------------------------- DP RAM --------------------------
            -- ram data
            ramdata  : in  STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
            -- ram address
            ramaddr  : out STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
            
            -------------------------- RLSM ---------------------------
            -- fifo read enable
            fifore   : in  STD_LOGIC;
            -- filtering fail
            ffo      : out STD_LOGIC;
            -- runt frame
            rfo      : out STD_LOGIC;
            -- multicast frame
            mfo      : out STD_LOGIC;
            -- frame too long
            tlo      : out STD_LOGIC;
            -- report on mii error
            reo      : out STD_LOGIC;
            -- dribbling bit
            dbo      : out STD_LOGIC;
            -- crc error
            ceo      : out STD_LOGIC;
            -- fifo overflow
            ovo      : out STD_LOGIC;
			-- collision seen
            cso      : out STD_LOGIC;
            -- frame length
            flo      : out STD_LOGIC_VECTOR(13 downto 0);
            -- fifo data
            fifodata : out STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
            
            --------------------- frame status cache ------------------
            -- cache read enable
            cachere   : in  STD_LOGIC;
            -- cache not empty
            cachene   : out STD_LOGIC;
            
            ------------------------ RC control ------------------------
            -- frame status cache not full
            cachenf   : out STD_LOGIC;
            -- fifo read address grey coded
            radg      : out STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
            
            ------------------------- RC status -----------------------
            -- interrupt request
            rireq     : in  STD_LOGIC;
            -- filtering fail
            ffi       : in  STD_LOGIC;
            -- runt frame
            rfi       : in  STD_LOGIC;
            -- multicast frame
            mfi       : in  STD_LOGIC;
            -- frame too long
            tli       : in  STD_LOGIC;
            -- report on mii/gmii error
            rei       : in  STD_LOGIC;
            -- dribbling bit
            dbi       : in  STD_LOGIC;
            -- crc error
            cei       : in  STD_LOGIC;
            -- fifo overflow
            ovi       : in  STD_LOGIC;
			-- collision seen
            csi       : in  STD_LOGIC;
            -- frame length
            fli       : in  STD_LOGIC_VECTOR(13 downto 0);
            -- fifo write address grey coded
            wadg      : in  STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
            -- interrupt acknowledge
            riack     : out STD_LOGIC;
            
            --------------------- power management --------------------
            -- stop receive process input
            stopi    : in  STD_LOGIC;
            -- stop receive process output
            stopo    : out STD_LOGIC
    );
  end component;

  ---------------------------------------------------------------------
  -- Receive linked list management
  ---------------------------------------------------------------------
  component RLSM
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
            dmacnt    : out STD_LOGIC_VECTOR(FIFODEPTH_MAXX-1 downto 0);
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
            -- receive poll demand
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
  end component;
  
  ---------------------------------------------------------------------
  -- Reset controller
  ---------------------------------------------------------------------
  component RSTC
    port (
            ------------------------ clocks ---------------------------
            -- dma clock
            clkdma      : in  STD_LOGIC;
            -- csr clock
            clkcsr      : in  STD_LOGIC;
            -- receive clock
            clkr        : in  STD_LOGIC;
            
            ------------------------- reset ---------------------------
            -- csr reset
            rstcsr      : in  STD_LOGIC;
            -- software reset
            rstsoft     : in  STD_LOGIC;
            -- global reset  active low
            hrstn     : out STD_LOGIC;
            prstn     : out STD_LOGIC;
            rrstn     : out STD_LOGIC
            
    );
  end component;

 



end corecomps;



