-- ********************************************************************/
-- Actel Corporation Proprietary and Confidential
--  Copyright 2011 Actel Corporation.  All rights reserved.
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
-- IN ADVANCE IN WRITING.
--
-- Description:  CoreFIFO
--               CoreFIFO is a fully configurable Soft FIFO controller. 
--               It is designed to support SmartFusion2 device family.      
--
--
-- Revision Information:
-- Date     Description
--
-- SVN Revision Information:
-- SVN $Revision: 4805 $
-- SVN $Date: 2012-06-21 17:48:48 +0530 (Thu, 21 Jun 2012) $
--
-- Resolved SARs
-- SAR      Date     Who   Description
--
-- Notes:
--
-- ********************************************************************/
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_unsigned.all;
use     ieee.std_logic_misc.all;
use     work.fifo_pkg.all;
--use     work.component_ramwrapper.all;

ENTITY COREFIFO_C0_COREFIFO_C0_0_COREFIFO IS
   GENERIC (
      -- --------------------------------------------------------------------------
      -- PARAMETER Declaration
      -- --------------------------------------------------------------------------
      FAMILY                         :  integer := 19;    
      SYNC                           :  integer := 0;    --  Synchronous or Asynchronous operation | 1 - Single Clock, 0 - Dual clock
      RCLK_EDGE                      :  integer := 1;    --  Read  Clock Edge | 1 - Posedge, 0 - Negedge
      WCLK_EDGE                      :  integer := 1;    --  Write Clock Edge | 1 - Posedge, 0 - Negedge
      RE_POLARITY                    :  integer := 0;    --  Read  Enable Clock Edge | 1 - Active Low, 0 - Active High
      WE_POLARITY                    :  integer := 0;    --  Write Enable Clock Edge | 1 - Active Low, 0 - Active High
      RWIDTH                         :  integer := 18;   --  Read  port Data Width
      WWIDTH                         :  integer := 18;   --  Write port Data Width
      RDEPTH                         :  integer := 1024; --  Read  port Data Depth
      WDEPTH                         :  integer := 1024; --  Write port Data Depth
      READ_DVALID                    :  integer := 0;    --  Read Data Valid | 0 - Disable , 1 - Enable Read data valid generation
      WRITE_ACK                      :  integer := 0;    --  Write Data Ack  | 0 - Disable , 1 - Enable Write data ack generation
      CTRL_TYPE                      :  integer := 1;    --  Controller only options | 1 - Controller Only, 2 - RAM1Kx18, 3 - RAM64x18
      ESTOP                          :  integer := 1;    --  0 - Allow Reads when Empty, 1 - Disable Reads when Empty
      FSTOP                          :  integer := 1;    --  0 - Allow Writes when Full,  1 - Disable Writes when Full
      AE_STATIC_EN                   :  integer := 1;    --  Almost Empty Threshold Enable/Disable Static values
                                                         --  0 - Disable values, 1 - Enable Static values 
      AF_STATIC_EN                   :  integer := 1;    --  Almost Full Threshold Enable/Disable Static values
                                                         --  0 - Disable values, 1 - Enable Static values
      AEVAL                          :  integer := 4;    --  Almost Empty Threshold assert value
      AFVAL                          :  integer := 1020; --  Almost Full  Threshold assert value
      PIPE                           :  integer := 1;    --  Pipeline read data out
      PREFETCH                       :  integer := 0;    --  Prefetching of Read data | 0 - Disable Pre-fetching, 1 - Enable Pre-fetching only if PIPE=1
      FWFT                           :  integer := 0;    --  FWFT of Read data | 0 - Disable FWFT, 1 - Enable FWFT only if PIPE=1
      ECC                            :  integer := 0;    --  ECC | 0 - Disable ECC, 1 - Pipelined ECC, 2 - Non-pipelined ECC --SAR#68113
      RESET_POLARITY                 :  integer := 0;    --  Polarity of Reset | 0 - Active Low, 1 - Active High
      OVERFLOW_EN                    :  integer := 0;    --  Overflow Enable/Disable | 0 - Disable, 1 - Enable
      UNDERFLOW_EN                   :  integer := 0;    --  Underflow Enable/Disable | 0 - Disable, 1 - Enable
      WRCNT_EN                       :  integer := 0;    --  Write Count Enable/Disable | 0 - Disable, 1 - Enable
	  NUM_STAGES                     :  integer := 2;
      RDCNT_EN                       :  integer := 0);   --  Read Count Enable/Disable | 0 - Disable, 1 - Enable
   PORT (
      ----------
      -- Inputs
      ----------
      -- Clocks and Reset

      CLK                     : IN std_logic;   
      WCLOCK                  : IN std_logic;   
      RCLOCK                  : IN std_logic;   
      RESET                   : IN std_logic;   
      -- Input Data Bus and Control ports

      DATA                    : IN std_logic_vector(WWIDTH - 1 DOWNTO 0);   
      WE                      : IN std_logic;   
      RE                      : IN std_logic;   
      -----------
      -- Outputs
      -----------
      -- Output Data bus

      Q                       : OUT std_logic_vector(RWIDTH - 1 DOWNTO 0);   
      -- Output Status Flags

      FULL                    : OUT std_logic;   
      EMPTY                   : OUT std_logic;   
      AFULL                   : OUT std_logic;   
      AEMPTY                  : OUT std_logic;   
      OVERFLOW                : OUT std_logic;   
      UNDERFLOW               : OUT std_logic;   
      WACK                    : OUT std_logic;   
      DVLD                    : OUT std_logic;   
      WRCNT                   : OUT std_logic_vector(ceil_log2(WDEPTH) DOWNTO 0);   
      RDCNT                   : OUT std_logic_vector(ceil_log2(RDEPTH) DOWNTO 0);   
      -- Outputs For external memory

      MEMWE                   : OUT std_logic;   
      MEMRE                   : OUT std_logic;   
      MEMWADDR                : OUT std_logic_vector((ceil_log2t(WDEPTH) - 1) DOWNTO 0);
      MEMRADDR                : OUT std_logic_vector((ceil_log2t(RDEPTH) - 1) DOWNTO 0);
      MEMWD                   : OUT std_logic_vector(WWIDTH - 1 DOWNTO 0);   
      MEMRD                   : IN std_logic_vector(RWIDTH - 1 DOWNTO 0);   
      SB_CORRECT              : OUT std_logic;   
      DB_DETECT               : OUT std_logic);   
END ENTITY COREFIFO_C0_COREFIFO_C0_0_COREFIFO;

ARCHITECTURE translated OF COREFIFO_C0_COREFIFO_C0_0_COREFIFO IS

   -- Local parameter
   CONSTANT  WMSB_DEPTH            :  integer := (ceil_log2(WDEPTH));    
   CONSTANT  RMSB_DEPTH            :  integer := (ceil_log2(RDEPTH)); 
  -- CONSTANT  SYNC_RESET            :  integer := SYNC_MODE_SEL(FAMILY); 

   COMPONENT COREFIFO_C0_COREFIFO_C0_0_ram_wrapper
      GENERIC (
         -- --------------------------------------------------------------------------
         -- PARAMETER Declaration
         -- --------------------------------------------------------------------------
         RWIDTH                         :  integer := 32;    --  Read  port Data Width
         WWIDTH                         :  integer := 32;    --  Write port Data Width
         RDEPTH                         :  integer := 128;    --  Read  port Data Depth
         WDEPTH                         :  integer := 128;    --  Write port Data Depth
         SYNC                           :  integer := 0;    --  Synchronous or Asynchronous operation | 1 - Single Clock, 0 - Dual clock
         PIPE                           :  integer := 1;    --  Pipeline read data out
         CTRL_TYPE                      :  integer := 1);    --  Controller only options | 1 - Controller Only, 2 - RAM1Kx18, 3 - RAM64x18
      PORT (

-- --------------------------------------------------------------------------
-- I/O Declaration
-- --------------------------------------------------------------------------

         WDATA                   : IN std_logic_vector(WWIDTH - 1 DOWNTO 0);   
         WADDR                   : IN std_logic_vector(WDEPTH - 1 DOWNTO 0);   
         WEN                     : IN std_logic;   
         REN                     : IN std_logic;   
         RDATA                   : OUT std_logic_vector(RWIDTH - 1 DOWNTO 0);   
         RADDR                   : IN std_logic_vector(RDEPTH - 1 DOWNTO 0);
         RESET_N                 : IN std_logic;   
         CLOCK                   : IN std_logic;   
         WCLOCK                  : IN std_logic;   
         A_SB_CORRECT            : OUT std_logic;   
         B_SB_CORRECT            : OUT std_logic;   
         A_DB_DETECT             : OUT std_logic;   
         B_DB_DETECT             : OUT std_logic;   
         RCLOCK                  : IN std_logic);
   END COMPONENT;

   COMPONENT COREFIFO_C0_COREFIFO_C0_0_corefifo_async
      GENERIC (
         -- --------------------------------------------------------------------------
         -- PARAMETER Declaration
         -- --------------------------------------------------------------------------
         WRITE_WIDTH                    :  integer := 32;    
         WRITE_DEPTH                    :  integer := 1024;    
         FULL_WRITE_DEPTH               :  integer := 1024;    
         READ_WIDTH                     :  integer := 32;    
         READ_DEPTH                     :  integer := 1024;    
         FULL_READ_DEPTH                :  integer := 1024;    
         VAR_ASPECT_WRDEPTH             :  integer := 1024;    
         VAR_ASPECT_RDDEPTH             :  integer := 1024;    
         PREFETCH                       :  integer := 0;    
         FWFT                           :  integer := 0;    
         --SYNC_RESET                     :  integer := 0;    
         WCLK_HIGH                      :  integer := 1;    
         RCLK_HIGH                      :  integer := 1;    
         PIPE                           :  integer := 1;
         RESET_LOW                      :  integer := 1;    
         WRITE_LOW                      :  integer := 0;    
         READ_LOW                       :  integer := 0;    
         AF_FLAG_STATIC                 :  integer := 1;    
         AE_FLAG_STATIC                 :  integer := 1;    
         AFULL_VAL                      :  integer := 1016;    
         AEMPTY_VAL                     :  integer := 1000;    
         ESTOP                          :  integer := 1;    
         FSTOP                          :  integer := 1;    
         REGISTER_RADDR                 :  integer := 1;    
         READ_DVALID                    :  integer := 0;    
         WRITE_ACK                      :  integer := 0;    
         OVERFLOW_EN                    :  integer := 0;    
         UNDERFLOW_EN                   :  integer := 0;    
         WRCNT_EN                       :  integer := 0;
         NUM_STAGES                     :  integer := 2;		 
         RDCNT_EN                       :  integer := 0);    
      PORT (
         ----------
	 -- Inputs
	 ----------

         rclk                    : IN std_logic;   --  read clock
         wclk                    : IN std_logic;   --  write clock
         reset_rclk              : IN std_logic;   --  reset
         reset_wclk              : IN std_logic;   --  reset
         we                      : IN std_logic;   --  write enable to fifo
         re                      : IN std_logic;   --  read enable to fifo
         re_top                  : IN std_logic;   --  read enable to fifo
         -----------
	 -- Outputs
	 -----------

         full                    : OUT std_logic;   --  full status flag
         afull                   : OUT std_logic;   --  almost full status flag
         wrcnt                   : OUT std_logic_vector(WRITE_DEPTH DOWNTO 0);   --  number of elements remaining in write domain
         empty                   : OUT std_logic;   --  empty status flag
         aempty                  : OUT std_logic;   --  almost empty status flag
         rdcnt                   : OUT std_logic_vector(READ_DEPTH DOWNTO 0);   --  number of elements remaining in read domain
         underflow               : OUT std_logic;   --  underflow status flag
         overflow                : OUT std_logic;   --  overflow status flag
         dvld                    : OUT std_logic;   --  dvld status flag
         wack                    : OUT std_logic;   --  wack status flag
         memwaddr                : OUT std_logic_vector(ceil_log2t(FULL_WRITE_DEPTH) - 1 DOWNTO 0);   --  memory write address
         memwe                   : OUT std_logic;   --  memory write enable
         memraddr                : OUT std_logic_vector(ceil_log2t(FULL_READ_DEPTH) - 1 DOWNTO 0);   --  memory read address
         memre                   : OUT std_logic);
   END COMPONENT;

   COMPONENT COREFIFO_C0_COREFIFO_C0_0_corefifo_sync
      GENERIC (
         -- --------------------------------------------------------------------------
         -- PARAMETER Declaration
         -- --------------------------------------------------------------------------
         WRITE_WIDTH                    :  integer := 32;    
         WRITE_DEPTH                    :  integer := 10;    
         FULL_WRITE_DEPTH               :  integer := 1024;    
         READ_WIDTH                     :  integer := 32;    
         READ_DEPTH                     :  integer := 10;    
         FULL_READ_DEPTH                :  integer := 1024;    
         VAR_ASPECT_WRDEPTH             :  integer := 1024;    
         VAR_ASPECT_RDDEPTH             :  integer := 1024;    
         PREFETCH                       :  integer := 0;    
         FWFT                           :  integer := 0;    
        -- SYNC_RESET                     :  integer := 0;    
         WCLK_HIGH                      :  integer := 1;    
         PIPE                           :  integer := 1;
         RESET_LOW                      :  integer := 1;    
         WRITE_LOW                      :  integer := 1;    
         READ_LOW                       :  integer := 1;    
         AF_FLAG_STATIC                 :  integer := 1;    
         AE_FLAG_STATIC                 :  integer := 1;    
         AFULL_VAL                      :  integer := 1020;    
         AEMPTY_VAL                     :  integer := 4;    
         ESTOP                          :  integer := 1;    
         FSTOP                          :  integer := 1;    
         REGISTER_RADDR                 :  integer := 1;    
         READ_DVALID                    :  integer := 32;    
         WRITE_ACK                      :  integer := 32;    
         OVERFLOW_EN                    :  integer := 1;    
         UNDERFLOW_EN                   :  integer := 1;    
         WRCNT_EN                       :  integer := 1;    
         RDCNT_EN                       :  integer := 1);    
      PORT (
         ----------
	 -- Inputs
	 ----------

         clk                     : IN std_logic;   --  fifo clock
         reset                   : IN std_logic;   --  reset
         we                      : IN std_logic;   --  write enable to fifo
         re                      : IN std_logic;   --  read enable to fifo
         -----------
	 -- Outputs
	 -----------

         full                    : OUT std_logic;   --  full status flag
         afull                   : OUT std_logic;   --  almost full status flag
         wrcnt                   : OUT std_logic_vector(WRITE_DEPTH DOWNTO 0);   --  number of elements remaining in write domain
         empty                   : OUT std_logic;   --  empty status flag
         aempty                  : OUT std_logic;   --  almost empty status flag
         rdcnt                   : OUT std_logic_vector(READ_DEPTH DOWNTO 0);   --  number of elements remaining in read domain
         underflow               : OUT std_logic;   --  underflow status flag
         overflow                : OUT std_logic;   --  overflow status flag
         dvld                    : OUT std_logic;   --  dvld status flag
         wack                    : OUT std_logic;   --  wack status flag
         memwaddr                : OUT std_logic_vector(ceil_log2t(FULL_WRITE_DEPTH) - 1 DOWNTO 0);   --  memory write address
         memwe                   : OUT std_logic;   --  memory write enable
         memraddr                : OUT std_logic_vector(ceil_log2t(FULL_READ_DEPTH) - 1 DOWNTO 0);   --  memory read address
         memre                   : OUT std_logic);
   END COMPONENT;

   COMPONENT COREFIFO_C0_COREFIFO_C0_0_corefifo_sync_scntr
      GENERIC (
         -- --------------------------------------------------------------------------
         -- PARAMETER Declaration
         -- --------------------------------------------------------------------------
         WRITE_WIDTH                    :  integer := 18;    
         WRITE_DEPTH                    :  integer := 10;    
         FULL_WRITE_DEPTH               :  integer := 1024;    
         READ_WIDTH                     :  integer := 18;    
         READ_DEPTH                     :  integer := 10;    
         FULL_READ_DEPTH                :  integer := 1024;    
         PREFETCH                       :  integer := 0;    
         FWFT                           :  integer := 0;    
       --  SYNC_RESET                     :  integer := 0;    
         WCLK_HIGH                      :  integer := 1;    
         PIPE                           :  integer := 1;
		 ECC                           :  integer := 1;
         RESET_LOW                      :  integer := 1;    
         WRITE_LOW                      :  integer := 1;    
         READ_LOW                       :  integer := 1;    
         AF_FLAG_STATIC                 :  integer := 1;    
         AE_FLAG_STATIC                 :  integer := 1;    
         AFULL_VAL                      :  integer := 1020;    
         AEMPTY_VAL                     :  integer := 4;    
         ESTOP                          :  integer := 1;    
         FSTOP                          :  integer := 1;    
         REGISTER_RADDR                 :  integer := 1;    
         READ_DVALID                    :  integer := 1;    
         WRITE_ACK                      :  integer := 1;    
         OVERFLOW_EN                    :  integer := 1;    
         UNDERFLOW_EN                   :  integer := 1;    
         WRCNT_EN                       :  integer := 1;    
         RDCNT_EN                       :  integer := 1);    
      PORT (
         ----------
	 -- Inputs
	 ----------

         clk                     : IN std_logic;   --  fifo clock
         reset                   : IN std_logic;   --  reset
         we                      : IN std_logic;   --  write enable to fifo
         re                      : IN std_logic;   --  read enable to fifo
         re_top                  : IN std_logic;   --  read enable to fifo
         -----------
	 -- Outputs
	 -----------

         full                    : OUT std_logic;   --  full status flag
         afull                   : OUT std_logic;   --  almost full status flag
         wrcnt                   : OUT std_logic_vector(WRITE_DEPTH DOWNTO 0);   --  number of elements remaining in write domain
         empty                   : OUT std_logic;   --  empty status flag
         aempty                  : OUT std_logic;   --  almost empty status flag
         rdcnt                   : OUT std_logic_vector(READ_DEPTH DOWNTO 0);   --  number of elements remaining in read domain
         underflow               : OUT std_logic;   --  underflow status flag
         overflow                : OUT std_logic;   --  overflow status flag
         dvld                    : OUT std_logic;   --  dvld status flag
         wack                    : OUT std_logic;   --  wack status flag
         memwaddr                : OUT std_logic_vector(ceil_log2t(FULL_WRITE_DEPTH) - 1 DOWNTO 0);   --  memory write address
         memwe                   : OUT std_logic;   --  memory write enable
         memraddr                : OUT std_logic_vector(ceil_log2t(FULL_READ_DEPTH) - 1 DOWNTO 0);   --  memory read address
         empty_top_fwft          : IN  std_logic;   
	 memre                   : OUT std_logic);
   END COMPONENT;

   COMPONENT COREFIFO_C0_COREFIFO_C0_0_corefifo_fwft
      GENERIC (
         -- --------------------------------------------------------------------------
         -- PARAMETER Declaration
         -- --------------------------------------------------------------------------
         RDEPTH                         :  integer := 10;    
         RDEPTH_CAL                     :  integer := 10;    
         WWIDTH                         :  integer := 10;    
         RWIDTH                         :  integer := 10;    
         WCLK_HIGH                      :  integer := 1;    
         RCLK_HIGH                      :  integer := 1;    
         RESET_LOW                      :  integer := 1;    
         WRITE_LOW                      :  integer := 1;    
         READ_LOW                       :  integer := 1;    
         PREFETCH                       :  integer := 0;    
         FWFT                           :  integer := 0;    
         SYNC                           :  integer := 1);    
        -- SYNC_RESET                     :  integer := 0);    
      PORT (
         -- --------------------------------------------------------------------------
-- I/O Declaration
-- --------------------------------------------------------------------------
----------
-- Inputs
----------
-- Clocks and Reset

         wr_clk                  : IN std_logic;   
         rd_clk                  : IN std_logic;   
         clk                     : IN std_logic;   
         reset_rclk_top          : IN std_logic;   
         reset_wclk_top          : IN std_logic;   
-----------
-- Outputs
-----------

         empty                   : OUT std_logic;   
         aempty                  : OUT std_logic;   
         rd_en                   : IN std_logic;   
         fifo_rd_en              : OUT std_logic;   
         fifo_empty              : IN std_logic;   
         fifo_aempty             : IN std_logic;   
         fifo_dout               : IN std_logic_vector(RWIDTH - 1 DOWNTO 0);   
         wr_en                   : IN std_logic;   
         din                     : IN std_logic_vector(WWIDTH - 1 DOWNTO 0);   
         fwft_dvld               : OUT std_logic;   
         reg_valid               : OUT std_logic;   
         dout                    : OUT std_logic_vector(RWIDTH - 1 DOWNTO 0);   
         fifo_MEMRADDR           : IN std_logic_vector(RDEPTH - 1 DOWNTO 0);   
         fwft_MEMRADDR           : OUT std_logic_vector(RDEPTH - 1 DOWNTO 0));
   END COMPONENT;

   
   
   COMPONENT COREFIFO_C0_COREFIFO_C0_0_corefifo_resetSync
      GENERIC (
	    -------------
		--  PARAMETER
        -------------
       	NUM_STAGES                     :  integer := 2
              );

      PORT    (
	    ---------
        -- Inputs 
		---------
        clk                      : IN std_logic;   
        reset                    : IN std_logic; 
		
		-----------
        -- Outputs
        -----------

        reset_out                : OUT std_logic
	); 
		
  END COMPONENT;		
   -- Internal signals
   -- --------------------------------------------------------------------------
   SIGNAL reg_valid                :  std_logic;   
   SIGNAL reg_RD                   :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL fifo_MEMWADDR            :  std_logic_vector((ceil_log2t(WDEPTH) - 1) DOWNTO 0);   
   SIGNAL fifo_MEMRADDR            :  std_logic_vector((ceil_log2t(RDEPTH) - 1) DOWNTO 0);   
   SIGNAL fwft_MEMRADDR            :  std_logic_vector((ceil_log2t(RDEPTH) - 1) DOWNTO 0);   
   SIGNAL pf_dvld                  :  std_logic;   
   SIGNAL pf_MEMRADDR              :  std_logic_vector((ceil_log2t(RDEPTH) - 1) DOWNTO 0); 
   SIGNAL fifo_MEMWE               :  std_logic;   
   SIGNAL fifo_MEMRE               :  std_logic;   
   SIGNAL fifo_MEMRE_int           :  std_logic;   
   SIGNAL pf_Q                     :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL int_MEMRD                :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL mem_pf_RD                :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL fwft_Q                   :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL fwft_Q_r                 :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL ext_MEMRD                :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL temp_xhdl18              :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   -- --------------------------------------------------------------------------
   -- Generate top-level outputs to External memory
   -- --------------------------------------------------------------------------
   SIGNAL temp_xhdl19              :  std_logic_vector((ceil_log2t(WDEPTH) - 1) DOWNTO 0);
   SIGNAL temp_xhdl20              :  std_logic;   
   SIGNAL temp_xhdl21              :  std_logic_vector(WWIDTH - 1 DOWNTO 0);   
   SIGNAL temp_xhdl22              :  std_logic_vector((ceil_log2t(RDEPTH) - 1) DOWNTO 0);   
   SIGNAL temp_xhdl223             :  std_logic_vector((ceil_log2t(RDEPTH) - 1) DOWNTO 0);   
   SIGNAL temp_xhdl222             :  std_logic_vector((ceil_log2t(RDEPTH) - 1) DOWNTO 0);   
   SIGNAL temp_xhdl23              :  std_logic_vector((ceil_log2t(RDEPTH) - 1) DOWNTO 0);   
   SIGNAL temp_xhdl24              :  std_logic;   
   SIGNAL temp_xhdl25              :  std_logic;   
   SIGNAL temp_xhdl116             :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL xhdl_122                 :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL Q_xhdl2                  :  std_logic_vector(RWIDTH - 1 DOWNTO 0); 
   SIGNAL FULL_xhdl3               :  std_logic;   
   SIGNAL EMPTY_xhdl4              :  std_logic;   
   SIGNAL EMPTY2                   :  std_logic;   
   SIGNAL AEMPTY2                  :  std_logic;   
   SIGNAL AFULL_xhdl5              :  std_logic;   
   SIGNAL AEMPTY_xhdl6             :  std_logic;   
   SIGNAL AEMPTY1_r                :  std_logic;   
   SIGNAL AEMPTY1_r1               :  std_logic;   
   SIGNAL OVERFLOW_xhdl7           :  std_logic;   
   SIGNAL UNDERFLOW_xhdl8          :  std_logic;   
   SIGNAL WACK_xhdl9               :  std_logic;   
   SIGNAL DVLD_xhdl10              :  std_logic;   
   SIGNAL DVLD_xhdl10_scntr        :  std_logic;   
   SIGNAL DVLD_xhdl10_sync         :  std_logic;   
   SIGNAL DVLD_xhdl10_async        :  std_logic;   
   SIGNAL fwft_dvld                :  std_logic;   
   SIGNAL WRCNT_xhdl11             :  std_logic_vector(ceil_log2(WDEPTH) DOWNTO 0);   
   SIGNAL RDCNT_xhdl12             :  std_logic_vector(ceil_log2(RDEPTH) DOWNTO 0);   
   SIGNAL MEMWE_xhdl13             :  std_logic;   
   SIGNAL MEMRE_xhdl14             :  std_logic;   
   SIGNAL MEMWADDR_xhdl15          :  std_logic_vector((ceil_log2t(WDEPTH) - 1) DOWNTO 0);   
   SIGNAL MEMRADDR_xhdl16          :  std_logic_vector((ceil_log2t(RDEPTH) - 1) DOWNTO 0);   
   SIGNAL MEMWD_xhdl17             :  std_logic_vector(WWIDTH - 1 DOWNTO 0);   

   SIGNAL int_MEMRD_sig1           :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL int_MEMRD_sig2           :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL int_MEMRD_sig3           :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL int_MEMRD_sig4           :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL int_MEMRD_sig5           :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL int_MEMRD_sig6           :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL int_MEMRD_sig7           :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL int_MEMRD_sig8           :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL int_MEMRD_pre            :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL int_MEMRD_fwft           :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL int_MEMRD_pipe0          :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL int_MEMRD_pipe1          :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL int_MEMRD_pipe2          :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   

   SIGNAL ext_MEMRD_sig2           :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL ext_MEMRD_sig3           :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL ext_MEMRD_sig4           :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL ext_MEMRD_sig5           :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL ext_MEMRD_sig6           :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL ext_MEMRD_sig7           :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL ext_MEMRD_sig8           :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL ext_MEMRD_pre            :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL ext_MEMRD_fwft           :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL ext_MEMRD_pipe0          :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL ext_MEMRD_pipe1          :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL ext_MEMRD_pipe2          :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL RDATA_r                  :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL RDATA_r_pre              :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL RDATA_r1                 :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL RDATA_ext_r              :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL RDATA_ext_r1             :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL RDATA_int                :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL re_set                   :  std_logic;   
   SIGNAL re_pulse                 :  std_logic;   
   SIGNAL REN_d1                   :  std_logic;   
   SIGNAL REN_d2                   :  std_logic;   
   SIGNAL RE_d1                    :  std_logic;   
   SIGNAL RE_d2                    :  std_logic;   
   SIGNAL re_pulse_d1              :  std_logic;   
   SIGNAL re_pulse_d2              :  std_logic;   
   SIGNAL re_pulse_pre             :  std_logic;   
   SIGNAL RE_pol                   :  std_logic;   
   SIGNAL pos_rclk                 :  std_logic;   
   SIGNAL pos_wclk                 :  std_logic;   
   SIGNAL neg_reset                :  std_logic;   
   SIGNAL aresetn                  :  std_logic;   
  -- SIGNAL sresetn                  :  std_logic;   
   SIGNAL fifo_re_in               :  std_logic;
   SIGNAL fifo_rd_en               :  std_logic;
   SIGNAL fwft_reg_valid           :  std_logic;
   SIGNAL EMPTY_int                :  std_logic;

   SIGNAL RDATA_r2                 :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL DVLD_async_ecc           :  std_logic;
   SIGNAL DVLD_scntr_ecc           :  std_logic;
   SIGNAL DVLD_sync_ecc            :  std_logic;
   SIGNAL int_MEMRD_pipe1_ecc1     :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL int_MEMRD_pipe2_ecc1     :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL RE_d3                    :  std_logic;
   SIGNAL REN_d3                   :  std_logic;
   SIGNAL re_pulse_d3              :  std_logic;
   SIGNAL int_MEMRD_sig4_ecc1      :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL int_MEMRD_sig5_ecc1      :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   

   SIGNAL A_SB_CORRECT             : std_logic;
   SIGNAL B_SB_CORRECT             : std_logic;
   SIGNAL A_DB_DETECT              : std_logic;
   SIGNAL B_DB_DETECT              : std_logic;
   SIGNAL temp_A_SB_CORRECT        : std_logic;
   SIGNAL temp_B_SB_CORRECT        : std_logic;
   SIGNAL temp_A_DB_DETECT         : std_logic;
   SIGNAL temp_B_DB_DETECT         : std_logic;
   --SIGNAL DB_DETECT                : std_logic;
   --SIGNAL SB_CORRECT               : std_logic;
   SIGNAL SB_CORRECT_xhdl1         : std_logic;
   SIGNAL SB_CORRECT_xhdl2         : std_logic;
   SIGNAL DB_DETECT_xhdl1          : std_logic;
   SIGNAL DB_DETECT_xhdl2          : std_logic;
   SIGNAL reset_reg 			   : std_logic;
   SIGNAL reset_reg1               : std_logic;
   SIGNAL reset_rclk               : std_logic;
   SIGNAL reset_wclk               : std_logic;
   SIGNAL reset_syc_r              : std_logic;
   SIGNAL reset_syc_w              : std_logic;
 
   
BEGIN

   -- --------------------------------------------------------------------------
   -- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
   -- ||                                                                      ||
   -- ||                     Start - of - Code                                ||
   -- ||                                                                      ||
   -- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
   -- --------------------------------------------------------------------------


   -- --------------------------------------------------------------------------
   -- Resets
   -- --------------------------------------------------------------------------
   --neg_reset <= (NOT RESET) WHEN (RESET_POLARITY = 1) ELSE RESET;
      aresetn <= (NOT RESET) WHEN (RESET_POLARITY = 1) ELSE RESET;------------------new AI
  -- aresetn   <= '1' WHEN (SYNC_RESET = 1) ELSE neg_reset;
  -- sresetn   <= neg_reset WHEN (SYNC_RESET = 1) ELSE '1';
  
  -------RESET SYNCHRONIZER
 

	
		 
	R1 : IF (SYNC = 0) 
    GENERATE
	  w_corefifo_resetSync : COREFIFO_C0_COREFIFO_C0_0_corefifo_resetSync
        GENERIC MAP (	
                		
    	  NUM_STAGES => NUM_STAGES)
		PORT MAP (
		  clk => pos_wclk,
		  reset => aresetn,
		  reset_out => reset_syc_w );
		  
		r_corefifo_resetSync : COREFIFO_C0_COREFIFO_C0_0_corefifo_resetSync
        GENERIC MAP (	
                		
    	  NUM_STAGES => NUM_STAGES)
		PORT MAP (
		  clk => pos_rclk,
		  reset => aresetn,
		  reset_out => reset_syc_r );  
	
    END GENERATE R1;
	

	
		
	L40: IF (SYNC = 0)
	GENERATE 			
			reset_rclk <= reset_syc_r;
			reset_wclk <= reset_syc_w;
	END GENERATE L40;	

	L41 : IF (SYNC = 1 )
	GENERATE 
			reset_rclk <= aresetn;
			reset_wclk <= aresetn;
	END GENERATE L41;
	

   -- --------------------------------------------------------------------------
   -- clocks and enables
   -- --------------------------------------------------------------------------
   L14: IF (RCLK_EDGE = 1)    --SAR#60185
   GENERATE
      pos_rclk <= CLK WHEN SYNC = 1 ELSE RCLOCK;
   END GENERATE L14;

   L15: IF (RCLK_EDGE = 0)    --SAR#60185
   GENERATE
     pos_rclk <= NOT CLK WHEN SYNC = 1 ELSE NOT RCLOCK;
   END GENERATE L15;

   L16: IF (WCLK_EDGE = 1) 
   GENERATE
     pos_wclk <= CLK WHEN SYNC = 1 ELSE WCLOCK;
   END GENERATE L16;

   L17: IF (WCLK_EDGE = 0) 
   GENERATE
     pos_wclk <= NOT CLK WHEN SYNC = 1 ELSE NOT WCLOCK;
   END GENERATE L17;

   -- --------------------------------------------------------------------------
   -- Generate top-level read data output
   -- --------------------------------------------------------------------------         
   Q <= Q_xhdl2;
   FULL <= FULL_xhdl3;
   EMPTY <= EMPTY2 WHEN (FWFT = 1 OR PREFETCH = 1) ELSE EMPTY_xhdl4;
   EMPTY_int <= EMPTY2 WHEN (FWFT = 1 OR PREFETCH = 1) ELSE EMPTY_xhdl4;
   AFULL <= AFULL_xhdl5;
   --AEMPTY <= AEMPTY_xhdl6;
   L111: IF (FWFT = 0 AND PREFETCH = 0) 
   GENERATE
     AEMPTY <= AEMPTY_xhdl6;
   END GENERATE L111;

   L121: IF ((FWFT = 1 OR PREFETCH = 1) AND PIPE = 1) 
   GENERATE
     --AEMPTY <= AEMPTY1_r1 OR EMPTY_int;
     AEMPTY <= AEMPTY2;  --Oct 29
   END GENERATE L121;


   OVERFLOW <= OVERFLOW_xhdl7;
   UNDERFLOW <= UNDERFLOW_xhdl8;
   WACK <= WACK_xhdl9;
   DVLD <= DVLD_xhdl10;
   WRCNT <= WRCNT_xhdl11;
   RDCNT <= RDCNT_xhdl12;
   MEMWE <= MEMWE_xhdl13;
   MEMRE <= MEMRE_xhdl14 after 1 ns;
   MEMWADDR <= MEMWADDR_xhdl15;
   MEMRADDR <= MEMRADDR_xhdl16 after 1 ns;
   MEMWD <= MEMWD_xhdl17;

   --For ECC
   SB_CORRECT <= SB_CORRECT_xhdl1;
   DB_DETECT  <= DB_DETECT_xhdl1;

   L11: IF (FWFT = 0 AND PREFETCH = 0) 
   GENERATE
     temp_xhdl18 <= mem_pf_RD;
     Q_xhdl2 <= temp_xhdl18 ;
   END GENERATE L11;

   L12: IF (FWFT = 1 AND PREFETCH = 0 AND PIPE = 1) 
   GENERATE
     --temp_xhdl18 <= fwft_Q WHEN (fwft_dvld = '1' AND (RE_pol = '1' OR fwft_reg_valid = '1')) ELSE fwft_Q_r;
     temp_xhdl18 <= fwft_Q;
     Q_xhdl2 <= temp_xhdl18 ;
   END GENERATE L12;

   L13: IF (FWFT = 0 AND PREFETCH = 1 AND PIPE = 1) 
   GENERATE
     temp_xhdl18 <= fwft_Q WHEN (RE_pol = '1') ELSE fwft_Q_r;
     Q_xhdl2 <= temp_xhdl18 ;
   END GENERATE L13;

   -- Generate the top-level ECC ports for detect and correct flags
   E1: IF (ECC /= 0)
   GENERATE
      SB_CORRECT_xhdl1 <= A_SB_CORRECT WHEN CTRL_TYPE = 2 ELSE SB_CORRECT_xhdl2;
      SB_CORRECT_xhdl2 <= (A_SB_CORRECT OR B_SB_CORRECT) WHEN CTRL_TYPE = 3 ELSE '0';
      DB_DETECT_xhdl1 <= A_DB_DETECT WHEN CTRL_TYPE = 2 ELSE DB_DETECT_xhdl2;
      DB_DETECT_xhdl2 <= (A_DB_DETECT OR B_DB_DETECT) WHEN CTRL_TYPE = 3 ELSE '0';
   END GENERATE E1;   

   --For ECC
   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         DVLD_async_ecc  <= '0';    
         DVLD_sync_ecc   <= '0';    
         DVLD_scntr_ecc  <= '0';    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
         
             DVLD_async_ecc  <= DVLD_xhdl10_async;    
             DVLD_sync_ecc   <= DVLD_xhdl10_sync;    
             DVLD_scntr_ecc  <= DVLD_xhdl10_scntr;    
       
      END IF;
   END PROCESS;

   -- --------------------------------------------------------------------------
   -- Generate top-level read data valid output
   -- --------------------------------------------------------------------------         
   L51: IF (SYNC = 0 AND FWFT = 0 AND PREFETCH = 0) GENERATE
	  DVLD_xhdl10 <= DVLD_async_ecc WHEN (ECC = 1) ELSE DVLD_xhdl10_async;
   END GENERATE L51;
   
   L52: IF (SYNC = 1 AND (RDEPTH = WDEPTH) AND ESTOP = 1 AND FSTOP =  1 AND FWFT = 0 AND PREFETCH = 0) GENERATE
	DVLD_xhdl10 <= DVLD_scntr_ecc WHEN (ECC = 1) ELSE DVLD_xhdl10_scntr;
   END GENERATE L52;
   
   L521: IF (SYNC = 1 AND (RDEPTH = WDEPTH) AND (ESTOP = 0 OR FSTOP =  0) AND FWFT = 0 AND PREFETCH = 0) GENERATE
	DVLD_xhdl10 <= DVLD_sync_ecc WHEN (ECC = 1) ELSE DVLD_xhdl10_sync;
   END GENERATE L521;
   
   
   L53: IF (SYNC = 1 AND (RDEPTH /= WDEPTH) AND FWFT = 0 AND PREFETCH = 0) GENERATE
	DVLD_xhdl10 <= DVLD_sync_ecc WHEN (ECC = 1) ELSE DVLD_xhdl10_sync;
   END GENERATE L53;
   
   L54: IF ((FWFT = 1 OR PREFETCH = 1) AND PIPE = 1) GENERATE
        DVLD_xhdl10 <= fwft_dvld WHEN (READ_DVALID = 1) ELSE '0' ;
   END GENERATE L54;
   
   -- --------------------------------------------------------------------------
   -- Generate top-level outputs to External memory
   -- --------------------------------------------------------------------------
   temp_xhdl19     <= fifo_MEMWADDR WHEN (CTRL_TYPE = 1) ELSE (OTHERS => '0');
   MEMWADDR_xhdl15 <= temp_xhdl19 ;
   temp_xhdl20     <= fifo_MEMWE WHEN (CTRL_TYPE = 1) ELSE '0';
   MEMWE_xhdl13    <= temp_xhdl20 ;
   temp_xhdl21     <= DATA WHEN (CTRL_TYPE = 1) ELSE (OTHERS => '0');
   MEMWD_xhdl17    <= temp_xhdl21 ;

   temp_xhdl222    <= fwft_MEMRADDR WHEN (FWFT = 1 AND PIPE = 1) ELSE fifo_MEMRADDR;
   temp_xhdl22     <= fwft_MEMRADDR WHEN (PREFETCH = 1 AND PIPE = 1) ELSE temp_xhdl222 ;
   
   temp_xhdl223    <= temp_xhdl22 after 1 ns;
   temp_xhdl23     <= (temp_xhdl22) WHEN (CTRL_TYPE = 1) ELSE (OTHERS => '0');
   MEMRADDR_xhdl16 <= temp_xhdl23 ;

   temp_xhdl24     <= fifo_MEMRE;
   temp_xhdl25     <= (temp_xhdl24) WHEN (CTRL_TYPE = 1) ELSE '0';
   MEMRE_xhdl14    <= temp_xhdl25 ;
   
  

   -- v2.5 

   -- --------------------------------------------------------------------------
   -- Generate read enable to the FIFO controller based on whether FWFT/PREFETCH
   -- mode is selected or not.
   -- --------------------------------------------------------------------------         
   fifo_re_in   <= fifo_rd_en WHEN ((FWFT = 1 OR PREFETCH = 1) AND PIPE = 1) ELSE RE;

   
   -- --------------------------------------------------------------------------
   -- Generate ECC related flags - v2.5
   -- --------------------------------------------------------------------------
   A_SB_CORRECT <= temp_A_SB_CORRECT;
   B_SB_CORRECT <= temp_B_SB_CORRECT;
   A_DB_DETECT  <= temp_A_DB_DETECT;
   B_DB_DETECT  <= temp_B_DB_DETECT;

   -- --------------------------------------------------------------------------
   -- Instance:: Synchronous FIFO for equal depths
   -- --------------------------------------------------------------------------
   L1: IF ((SYNC = 1) AND (RDEPTH = WDEPTH) AND (ESTOP = 1) AND (FSTOP = 1)) 
   GENERATE
      fifo_corefifo_sync_scntr : COREFIFO_C0_COREFIFO_C0_0_corefifo_sync_scntr 
         GENERIC MAP (
            FSTOP => FSTOP,
            FULL_WRITE_DEPTH => WDEPTH,
            WRITE_DEPTH => WMSB_DEPTH,
            AE_FLAG_STATIC => AE_STATIC_EN,
     	    PREFETCH => PREFETCH,
     	    FWFT => FWFT,
            UNDERFLOW_EN => UNDERFLOW_EN,
            WRCNT_EN => WRCNT_EN,
            OVERFLOW_EN => OVERFLOW_EN,
            AEMPTY_VAL => AEVAL,
            READ_WIDTH => RWIDTH,
            PIPE => PIPE,
           -- SYNC_RESET => SYNC_RESET,
            REGISTER_RADDR => PIPE,
            FULL_READ_DEPTH => RDEPTH,
            WRITE_WIDTH => WWIDTH,
            AF_FLAG_STATIC => AF_STATIC_EN,
            AFULL_VAL => AFVAL,
            WRITE_ACK => WRITE_ACK,
            READ_LOW => RE_POLARITY,
            READ_DVALID => READ_DVALID,
            WRITE_LOW => WE_POLARITY,
            ESTOP => ESTOP,
            RDCNT_EN => RDCNT_EN,
            RESET_LOW => RESET_POLARITY,
            WCLK_HIGH => WCLK_EDGE,
			ECC  => ECC,
            READ_DEPTH => RMSB_DEPTH)
         PORT MAP (
            clk => CLK,
            reset => RESET,
            we => WE,
            re => fifo_re_in,
            re_top => RE,
            full => FULL_xhdl3,
            afull => AFULL_xhdl5,
            wrcnt => WRCNT_xhdl11,
            empty => EMPTY_xhdl4,
            aempty => AEMPTY_xhdl6,
            rdcnt => RDCNT_xhdl12,
            underflow => UNDERFLOW_xhdl8,
            overflow => OVERFLOW_xhdl7,
            dvld => DVLD_xhdl10_scntr,
            wack => WACK_xhdl9,
            memwaddr => fifo_MEMWADDR,
            memwe => fifo_MEMWE,
            memraddr => fifo_MEMRADDR,
            empty_top_fwft => EMPTY2,  -- Oct 29
            memre => fifo_MEMRE);   
   END GENERATE L1;
   
   -- --------------------------------------------------------------------------
   -- Instance:: Synchronous FIFO 
   -- --------------------------------------------------------------------------
      
   L21: IF ((SYNC = 1) AND ( (WDEPTH > RDEPTH) OR ((WDEPTH = RDEPTH) AND ((ESTOP /= 1) OR (FSTOP /= 1)) ))) GENERATE
         U_corefifo_sync : COREFIFO_C0_COREFIFO_C0_0_corefifo_sync 
            GENERIC MAP (
               FSTOP => FSTOP,
               FULL_WRITE_DEPTH => WDEPTH,
               WRITE_DEPTH => WMSB_DEPTH,
               AE_FLAG_STATIC => AE_STATIC_EN,
    	       PREFETCH => PREFETCH,
               UNDERFLOW_EN => UNDERFLOW_EN,
               WRCNT_EN => WRCNT_EN,
               OVERFLOW_EN => OVERFLOW_EN,
               AEMPTY_VAL => AEVAL,
               READ_WIDTH => RWIDTH,
               PIPE => PIPE,
              -- SYNC_RESET => SYNC_RESET,
               REGISTER_RADDR => PIPE,
               FULL_READ_DEPTH => RDEPTH,
               VAR_ASPECT_WRDEPTH => WMSB_DEPTH,
               VAR_ASPECT_RDDEPTH => WMSB_DEPTH,
               WRITE_WIDTH => WWIDTH,
               AF_FLAG_STATIC => AF_STATIC_EN,
               AFULL_VAL => AFVAL,
               WRITE_ACK => WRITE_ACK,
               READ_LOW => RE_POLARITY,
               READ_DVALID => READ_DVALID,
               WRITE_LOW => WE_POLARITY,
               ESTOP => ESTOP,
               RDCNT_EN => RDCNT_EN,
               RESET_LOW => RESET_POLARITY,
               WCLK_HIGH => WCLK_EDGE,
               READ_DEPTH => RMSB_DEPTH)
            PORT MAP (
               clk => CLK,
               reset => RESET,
               we => WE,
               re => RE,
               full => FULL_xhdl3,
               afull => AFULL_xhdl5,
               wrcnt => WRCNT_xhdl11,
               empty => EMPTY_xhdl4,
               aempty => AEMPTY_xhdl6,
               rdcnt => RDCNT_xhdl12,
               underflow => UNDERFLOW_xhdl8,
               overflow => OVERFLOW_xhdl7,
               dvld => DVLD_xhdl10_sync,
               wack => WACK_xhdl9,
               memwaddr => fifo_MEMWADDR,
               memwe => fifo_MEMWE,
               memraddr => fifo_MEMRADDR,
               memre => fifo_MEMRE);   
      END GENERATE L21;
 
   L22: IF ((SYNC = 1) AND (RDEPTH > WDEPTH)) GENERATE    -- v2.1 for variable aspect ratio
         U_corefifo_sync : COREFIFO_C0_COREFIFO_C0_0_corefifo_sync 
            GENERIC MAP (
               FSTOP => FSTOP,
               FULL_WRITE_DEPTH => WDEPTH,
               WRITE_DEPTH => WMSB_DEPTH,
               AE_FLAG_STATIC => AE_STATIC_EN,
	       PREFETCH => PREFETCH,
               UNDERFLOW_EN => UNDERFLOW_EN,
               WRCNT_EN => WRCNT_EN,
               OVERFLOW_EN => OVERFLOW_EN,
               AEMPTY_VAL => AEVAL,
               READ_WIDTH => RWIDTH,
               PIPE => PIPE,
              -- SYNC_RESET => SYNC_RESET,
               REGISTER_RADDR => PIPE,
               FULL_READ_DEPTH => RDEPTH,
               VAR_ASPECT_WRDEPTH => RMSB_DEPTH,
               VAR_ASPECT_RDDEPTH => RMSB_DEPTH,
               WRITE_WIDTH => WWIDTH,
               AF_FLAG_STATIC => AF_STATIC_EN,
               AFULL_VAL => AFVAL,
               WRITE_ACK => WRITE_ACK,
               READ_LOW => RE_POLARITY,
               READ_DVALID => READ_DVALID,
               WRITE_LOW => WE_POLARITY,
               ESTOP => ESTOP,
               RDCNT_EN => RDCNT_EN,
               RESET_LOW => RESET_POLARITY,
               WCLK_HIGH => WCLK_EDGE,
               READ_DEPTH => RMSB_DEPTH)
            PORT MAP (
               clk => CLK,
               reset => RESET,
               we => WE,
               re => RE,
               full => FULL_xhdl3,
               afull => AFULL_xhdl5,
               wrcnt => WRCNT_xhdl11,
               empty => EMPTY_xhdl4,
               aempty => AEMPTY_xhdl6,
               rdcnt => RDCNT_xhdl12,
               underflow => UNDERFLOW_xhdl8,
               overflow => OVERFLOW_xhdl7,
               dvld => DVLD_xhdl10_sync,
               wack => WACK_xhdl9,
               memwaddr => fifo_MEMWADDR,
               memwe => fifo_MEMWE,
               memraddr => fifo_MEMRADDR,
               memre => fifo_MEMRE);   
      END GENERATE L22;

   -- --------------------------------------------------------------------------
   -- Instance:: Asynchronous FIFO 
   -- --------------------------------------------------------------------------
      L31: IF ((SYNC = 0) AND (WDEPTH >= RDEPTH)) GENERATE
         U_corefifo_async : COREFIFO_C0_COREFIFO_C0_0_corefifo_async 
            GENERIC MAP (
               FSTOP            => FSTOP,
               FULL_WRITE_DEPTH => WDEPTH,
               WRITE_DEPTH      => WMSB_DEPTH,
               AE_FLAG_STATIC   => AE_STATIC_EN,
    	       PREFETCH => PREFETCH,
               FWFT => FWFT,
               UNDERFLOW_EN     => UNDERFLOW_EN,
               WRCNT_EN         => WRCNT_EN,
               OVERFLOW_EN      => OVERFLOW_EN,
               AEMPTY_VAL       => AEVAL,
               READ_WIDTH       => RWIDTH,
               PIPE => PIPE,
             --  SYNC_RESET => SYNC_RESET,
               REGISTER_RADDR => PIPE,
               FULL_READ_DEPTH  => RDEPTH,
               VAR_ASPECT_WRDEPTH => WMSB_DEPTH,
               VAR_ASPECT_RDDEPTH => WMSB_DEPTH,
               WRITE_WIDTH      => WWIDTH,
               AF_FLAG_STATIC   => AF_STATIC_EN,
               RCLK_HIGH        => RCLK_EDGE,
               AFULL_VAL        => AFVAL,
               WRITE_ACK        => WRITE_ACK,
               READ_LOW         => RE_POLARITY,
               READ_DVALID      => READ_DVALID,
               WRITE_LOW        => WE_POLARITY,
               ESTOP            => ESTOP,
               RDCNT_EN         => RDCNT_EN,
               RESET_LOW        => RESET_POLARITY,
               WCLK_HIGH        => WCLK_EDGE,
			   NUM_STAGES       => NUM_STAGES,
               READ_DEPTH       => RMSB_DEPTH)
            PORT MAP (
               rclk      => RCLOCK,
               wclk      => WCLOCK,
               reset_rclk     => reset_rclk,
               reset_wclk     => reset_wclk,
               we        => WE,
               re        => fifo_re_in,
               re_top    => RE,
               full      => FULL_xhdl3,
               afull     => AFULL_xhdl5,
               wrcnt     => WRCNT_xhdl11,
               empty     => EMPTY_xhdl4,
               aempty    => AEMPTY_xhdl6,
               rdcnt     => RDCNT_xhdl12,
               underflow => UNDERFLOW_xhdl8,
               overflow  => OVERFLOW_xhdl7,
               dvld      => DVLD_xhdl10_async,
               wack      => WACK_xhdl9,
               memwaddr  => fifo_MEMWADDR,
               memwe     => fifo_MEMWE,
               memraddr  => fifo_MEMRADDR,
               memre     => fifo_MEMRE);   
      END GENERATE L31;
 
      L32: IF ((SYNC = 0) AND (RDEPTH > WDEPTH)) GENERATE
         U_corefifo_async : COREFIFO_C0_COREFIFO_C0_0_corefifo_async 
            GENERIC MAP (
               FSTOP            => FSTOP,
               FULL_WRITE_DEPTH => WDEPTH,
               WRITE_DEPTH      => WMSB_DEPTH,
               AE_FLAG_STATIC   => AE_STATIC_EN,
    	       PREFETCH => PREFETCH,
               FWFT => FWFT,
               UNDERFLOW_EN     => UNDERFLOW_EN,
               WRCNT_EN         => WRCNT_EN,
               OVERFLOW_EN      => OVERFLOW_EN,
               AEMPTY_VAL       => AEVAL,
               READ_WIDTH       => RWIDTH,
               PIPE => PIPE,
               --SYNC_RESET => SYNC_RESET,
               REGISTER_RADDR => PIPE,
               FULL_READ_DEPTH  => RDEPTH,
               VAR_ASPECT_WRDEPTH => RMSB_DEPTH,
               VAR_ASPECT_RDDEPTH => RMSB_DEPTH,
               WRITE_WIDTH      => WWIDTH,
               AF_FLAG_STATIC   => AF_STATIC_EN,
               RCLK_HIGH        => RCLK_EDGE,
               AFULL_VAL        => AFVAL,
               WRITE_ACK        => WRITE_ACK,
               READ_LOW         => RE_POLARITY,
               READ_DVALID      => READ_DVALID,
               WRITE_LOW        => WE_POLARITY,
               ESTOP            => ESTOP,
               RDCNT_EN         => RDCNT_EN,
               RESET_LOW        => RESET_POLARITY,
               WCLK_HIGH        => WCLK_EDGE,
			   NUM_STAGES       => NUM_STAGES,
               READ_DEPTH       => RMSB_DEPTH)
            PORT MAP (
               rclk      => RCLOCK,
               wclk      => WCLOCK,
               reset_rclk     => reset_rclk,
               reset_wclk     => reset_wclk,
               we        => WE,
               re        => RE,
               re_top    => RE,
               full      => FULL_xhdl3,
               afull     => AFULL_xhdl5,
               wrcnt     => WRCNT_xhdl11,
               empty     => EMPTY_xhdl4,
               aempty    => AEMPTY_xhdl6,
               rdcnt     => RDCNT_xhdl12,
               underflow => UNDERFLOW_xhdl8,
               overflow  => OVERFLOW_xhdl7,
               dvld      => DVLD_xhdl10_async,
               wack      => WACK_xhdl9,
               memwaddr  => fifo_MEMWADDR,
               memwe     => fifo_MEMWE,
               memraddr  => fifo_MEMRADDR,
               memre     => fifo_MEMRE);   
      END GENERATE L32;

   L5: IF ((FWFT = 1 OR PREFETCH = 1) AND PIPE = 1) GENERATE
      u_corefifo_fwft : COREFIFO_C0_COREFIFO_C0_0_corefifo_fwft 
         GENERIC MAP (
            RDEPTH => (ceil_log2t(RDEPTH)),
            RDEPTH_CAL => (RDEPTH),
            WWIDTH => WWIDTH,
            RESET_LOW => RESET_POLARITY,
            WRITE_LOW => WE_POLARITY,
            READ_LOW => RE_POLARITY,
            PREFETCH => PREFETCH,
            FWFT => FWFT,
           -- SYNC_RESET => SYNC_RESET,
            RWIDTH => RWIDTH,
            WCLK_HIGH => WCLK_EDGE,
            RCLK_HIGH => RCLK_EDGE,
            SYNC => SYNC)
         PORT MAP (
            wr_clk => WCLOCK,
            rd_clk => RCLOCK,
            clk => CLK,
            reset_rclk_top => reset_rclk,
            reset_wclk_top => reset_wclk,
            empty => EMPTY2,
            aempty => AEMPTY2,
            rd_en => RE,
            fifo_rd_en => fifo_rd_en,
            fifo_dout => mem_pf_RD,
            fifo_empty => EMPTY_xhdl4,
            fifo_aempty => AEMPTY_xhdl6,
            wr_en => WE,
            din => DATA,
            fwft_dvld => fwft_dvld,
            reg_valid => fwft_reg_valid,
            fifo_MEMRADDR => fifo_MEMRADDR,
            fwft_MEMRADDR => fwft_MEMRADDR,
            dout => fwft_Q);   
   END GENERATE L5;
   
   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         AEMPTY1_r  <= '0';    
         AEMPTY1_r1 <= '0';    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
         
             AEMPTY1_r  <= AEMPTY_xhdl6;    
             AEMPTY1_r1 <= AEMPTY1_r;    
         
      END IF;
   END PROCESS;

   
   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         re_set <= '0';    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
        -- IF (NOT sresetn = '1') THEN
            --re_set <= '0';    
        IF ((fifo_MEMRE AND (NOT REN_d1)) = '1') THEN
            re_set <= '0';    
         ELSIF (((NOT fifo_MEMRE) AND REN_d1) = '1') THEN
            re_set <= '1';
         END IF;
      END IF;
   END PROCESS;

   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         RDATA_r <= (OTHERS => '0');    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
         --IF (NOT sresetn = '1') THEN
           -- RDATA_r <= (OTHERS => '0');    
         IF (((NOT fifo_MEMRE) AND REN_d1) = '1') THEN
            RDATA_r <= RDATA_int;    
         END IF;
      END IF;
   END PROCESS;

   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         RDATA_r_pre <= (OTHERS => '0');    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
         --IF (NOT sresetn = '1') THEN
          --  RDATA_r_pre <= (OTHERS => '0');    
         IF (fifo_MEMRE = '1') THEN
            RDATA_r_pre <= Q_xhdl2;    
         END IF;
      END IF;
   END PROCESS;

   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         RDATA_r1 <= (OTHERS => '0');    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
        -- IF (NOT sresetn = '1') THEN
          --  RDATA_r1 <= (OTHERS => '0');    
         IF (((NOT REN_d1) AND REN_d2) = '1') THEN
            RDATA_r1 <= RDATA_int;    
         END IF;
      END IF;
   END PROCESS;

   -- Jul 1: For ECC
   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         RDATA_r2 <= (OTHERS => '0');
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
         --IF (NOT sresetn = '1') THEN
           -- RDATA_r2 <= (OTHERS => '0');    
         IF (((NOT REN_d2) AND REN_d3) = '1') THEN
            RDATA_r2 <= RDATA_int;    
         END IF;
      END IF;
   END PROCESS;

   RE_pol <= NOT RE WHEN (RE_POLARITY = 1) ELSE RE;

   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         fwft_Q_r <= (OTHERS => '0');    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
         --IF (NOT sresetn = '1') THEN
           -- fwft_Q_r <= (OTHERS => '0');    
         --ELSE
            fwft_Q_r <= Q_xhdl2;    
        -- END IF;
      END IF;
   END PROCESS;

   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         REN_d1 <= '0';    
         REN_d2 <= '0';    
         REN_d3 <= '0';    
         RE_d1 <= '0';    
         RE_d2 <= '0';    
         RE_d3 <= '0';    
         re_pulse_d1 <= '0';    
         re_pulse_d2 <= '0';    
         re_pulse_d3 <= '0';    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
          
            REN_d1 <= fifo_MEMRE;    
            REN_d2 <= REN_d1;    
            REN_d3 <= REN_d2;      
            RE_d1 <= RE_pol;     
            RE_d2 <= RE_d1;    
            RE_d3 <= RE_d2;     
            re_pulse_d1 <= re_pulse;    
            re_pulse_d2 <= re_pulse_d1;    
            re_pulse_d3 <= re_pulse_d2;     
        -- END IF;
      END IF;
   END PROCESS;

   re_pulse <= ((NOT fifo_MEMRE) AND REN_d1) OR (re_set); 
   re_pulse_pre <= (NOT fifo_MEMRE);

   int_MEMRD_fwft <= RDATA_r WHEN (re_set = '1' AND RE_d1 = '0') ELSE RDATA_int;
   int_MEMRD_sig3 <= RDATA_r     WHEN (fifo_MEMRE   = '1' AND (NOT REN_d1) = '1') ELSE RDATA_int;
   int_MEMRD_pre  <= RDATA_r_pre WHEN (re_pulse_pre = '1' AND RE_pol = '0')       ELSE int_MEMRD_sig3;

   int_MEMRD_pipe0<= RDATA_r_pre WHEN (re_pulse     = '1' AND RE_pol = '0')        ELSE RDATA_int;
   int_MEMRD_pipe1<= RDATA_r     WHEN (re_pulse_d1 = '1'  AND RE_d1  = '0' AND (ECC /= 1))        ELSE RDATA_int;  -- For ECC
   int_MEMRD_pipe2<= RDATA_r1    WHEN (re_pulse_d2  = '1' AND RE_d2  = '0' AND (ECC /= 1))        ELSE RDATA_int;  -- For ECC

   int_MEMRD_pipe1_ecc1 <= RDATA_r1    WHEN (re_pulse_d2 = '1'  AND RE_d2  = '0' AND (ECC = 1))        ELSE RDATA_int;  -- For ECC
   int_MEMRD_pipe2_ecc1 <= RDATA_r2    WHEN (re_pulse_d3  = '1' AND RE_d3  = '0' AND (ECC = 1))        ELSE RDATA_int;  -- For ECC

   int_MEMRD_sig4 <= int_MEMRD_pipe2 WHEN (PIPE = 2 AND ECC /= 1 ) ELSE RDATA_int;
   int_MEMRD_sig5 <= int_MEMRD_pipe1 WHEN (PIPE = 1 AND ECC /= 1 ) ELSE int_MEMRD_sig4;
   int_MEMRD_sig4_ecc1 <= int_MEMRD_pipe2_ecc1 WHEN (PIPE = 2 AND ECC = 1 ) ELSE int_MEMRD_sig5;      -- For ECC
   int_MEMRD_sig5_ecc1 <= int_MEMRD_pipe1_ecc1 WHEN (PIPE = 1 AND ECC = 1 ) ELSE int_MEMRD_sig4_ecc1; -- For ECC
   int_MEMRD_sig6 <= int_MEMRD_pipe0 WHEN (PIPE = 0    ) ELSE int_MEMRD_sig5_ecc1;
   int_MEMRD_sig7 <= int_MEMRD_fwft  WHEN (PREFETCH = 1) ELSE int_MEMRD_sig6;
   int_MEMRD_sig8 <= int_MEMRD_fwft  WHEN (FWFT = 1    ) ELSE int_MEMRD_sig7;

   int_MEMRD <= int_MEMRD_sig8;

   ext_MEMRD_fwft <= RDATA_ext_r WHEN (re_set = '1' AND RE_d1 = '0')       ELSE MEMRD;

   ext_MEMRD_sig3 <= RDATA_ext_r     WHEN (fifo_MEMRE   = '1' AND (NOT REN_d1) = '1') ELSE MEMRD;
   ext_MEMRD_pre  <= RDATA_r_pre WHEN (re_pulse_pre = '1' AND RE_pol = '0')       ELSE ext_MEMRD_sig3;

   ext_MEMRD_pipe0<= RDATA_r_pre WHEN (re_pulse     = '1' AND RE_pol = '0')        ELSE MEMRD;
   ext_MEMRD_pipe1<= RDATA_ext_r     WHEN (re_pulse_d1  = '1' AND RE_d1  = '0')        ELSE MEMRD;
   ext_MEMRD_pipe2<= RDATA_ext_r1    WHEN (re_pulse_d2  = '1' AND RE_d2  = '0')        ELSE MEMRD;

   ext_MEMRD_sig4 <= ext_MEMRD_pipe2 WHEN (PIPE = 2    ) ELSE MEMRD;
   ext_MEMRD_sig5 <= ext_MEMRD_pipe1 WHEN (PIPE = 1    ) ELSE ext_MEMRD_sig4;
   ext_MEMRD_sig6 <= ext_MEMRD_pipe0 WHEN (PIPE = 0    ) ELSE ext_MEMRD_sig5;
   ext_MEMRD_sig7 <= ext_MEMRD_fwft  WHEN (PREFETCH = 1) ELSE ext_MEMRD_sig6;
   ext_MEMRD_sig8 <= ext_MEMRD_fwft  WHEN (FWFT = 1    ) ELSE ext_MEMRD_sig7;

   ext_MEMRD <= ext_MEMRD_sig8;

   -- --------------------------------------------------------------------------
   -- Get the READ Data from internal or external memory based on CTRL_TYPE
   -- --------------------------------------------------------------------------
   temp_xhdl116 <= ext_MEMRD WHEN (CTRL_TYPE = 1) ELSE int_MEMRD;
   mem_pf_RD <= temp_xhdl116 ;
   
   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         RDATA_ext_r <= (OTHERS => '0');    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
         
		 
         IF (((NOT fifo_MEMRE) AND REN_d1) = '1') THEN
            RDATA_ext_r <= MEMRD;    
         END IF;
      END IF;
   END PROCESS;


   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         RDATA_ext_r1 <= (OTHERS => '0');    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
            
         IF (((NOT REN_d1) AND REN_d2) = '1') THEN
            RDATA_ext_r1 <= MEMRD;    
         END IF;
      END IF;
   END PROCESS;

   fifo_MEMRE_int <= fifo_MEMRE after 1 ns;    

   -- -----------------------------------------------------------------------
   -- Memory wrapper instance
   -- -----------------------------------------------------------------------
-- v2.4
   RW1: IF (CTRL_TYPE /= 1 AND FAMILY /= 25) GENERATE
    UI_ram_wrapper_1 : COREFIFO_C0_COREFIFO_C0_0_ram_wrapper
       GENERIC MAP(
            RDEPTH => (ceil_log2t(RDEPTH)),
            WDEPTH => (ceil_log2t(WDEPTH)),
            WWIDTH => WWIDTH,
            RWIDTH => RWIDTH,
            CTRL_TYPE => CTRL_TYPE,
            PIPE => PIPE,
            SYNC => SYNC) 
       PORT MAP (
          WDATA  => DATA,
          WADDR  => fifo_MEMWADDR,
          WEN    => fifo_MEMWE,
          REN    => fifo_MEMRE_int,
          WCLOCK => WCLOCK,
          RDATA  => RDATA_int,
          RADDR  => temp_xhdl223,
          RCLOCK => RCLOCK,
          CLOCK  => CLK,
          A_SB_CORRECT=> OPEN,  
          B_SB_CORRECT=> OPEN,  
          A_DB_DETECT => OPEN,  
          B_DB_DETECT => OPEN,  
          RESET_N => RESET);   
   END GENERATE RW1;

-- v2.4 --- >
-- The following changes are done for RTG4 Family only.
-- When RESET_POLARITY = 1 (Active HIGH), the RAM memories must be applied
-- constant '0' de-asserted state .
-- When RESET_POLARITY = 0 (Active LOW), the RAM memories must be applied
-- constant '1' de-asserted state.   
-- v2.5: Added ECC functionality
   RW2: IF ((CTRL_TYPE /= 1 AND FAMILY = 25 AND RESET_POLARITY = 1 AND ECC = 0) OR (CTRL_TYPE = 3 AND FAMILY = 25 AND RESET_POLARITY = 1 AND ECC = 1 AND PIPE = 0)) GENERATE
    UI_ram_wrapper_2 : COREFIFO_C0_COREFIFO_C0_0_ram_wrapper
       GENERIC MAP(
            RDEPTH => (ceil_log2t(RDEPTH)),
            WDEPTH => (ceil_log2t(WDEPTH)),
            WWIDTH => WWIDTH,
            RWIDTH => RWIDTH,
            CTRL_TYPE => CTRL_TYPE,
            PIPE => PIPE,
            SYNC => SYNC) 
       PORT MAP (
          WDATA  => DATA,
          WADDR  => fifo_MEMWADDR,
          WEN    => fifo_MEMWE,
          REN    => fifo_MEMRE_int,
          WCLOCK => WCLOCK,
          RDATA  => RDATA_int,
          RADDR  => temp_xhdl223,
          RCLOCK => RCLOCK,
          CLOCK  => CLK,
          A_SB_CORRECT=> OPEN,  
          B_SB_CORRECT=> OPEN,  
          A_DB_DETECT => OPEN,  
          B_DB_DETECT => OPEN,  
          RESET_N => '0');   
   END GENERATE RW2;

   RW3: IF ((CTRL_TYPE /= 1 AND FAMILY = 25 AND RESET_POLARITY = 0 AND ECC = 0) OR (CTRL_TYPE = 3 AND FAMILY = 25 AND RESET_POLARITY = 0 AND ECC = 1 AND PIPE = 0)) GENERATE
    UI_ram_wrapper_3 : COREFIFO_C0_COREFIFO_C0_0_ram_wrapper
       GENERIC MAP(
            RDEPTH => (ceil_log2t(RDEPTH)),
            WDEPTH => (ceil_log2t(WDEPTH)),
            WWIDTH => WWIDTH,
            RWIDTH => RWIDTH,
            CTRL_TYPE => CTRL_TYPE,
            PIPE => PIPE,
            SYNC => SYNC) 
       PORT MAP (
          WDATA  => DATA,
          WADDR  => fifo_MEMWADDR,
          WEN    => fifo_MEMWE,
          REN    => fifo_MEMRE_int,
          WCLOCK => WCLOCK,
          RDATA  => RDATA_int,
          RADDR  => temp_xhdl223,
          RCLOCK => RCLOCK,
          CLOCK  => CLK,
          A_SB_CORRECT=> OPEN,  
          B_SB_CORRECT=> OPEN,  
          A_DB_DETECT => OPEN,  
          B_DB_DETECT => OPEN,  
          RESET_N => '1');   
   END GENERATE RW3;
--    


   RW4: IF (CTRL_TYPE = 2 AND FAMILY = 25 AND RESET_POLARITY = 1 AND ECC /= 0) GENERATE
    UI_ram_wrapper_4 : COREFIFO_C0_COREFIFO_C0_0_ram_wrapper
       GENERIC MAP(
            RDEPTH => (ceil_log2t(RDEPTH)),
            WDEPTH => (ceil_log2t(WDEPTH)),
            WWIDTH => WWIDTH,
            RWIDTH => RWIDTH,
            CTRL_TYPE => CTRL_TYPE,
            PIPE => PIPE,
            SYNC => SYNC) 
       PORT MAP (
          WDATA  => DATA,
          WADDR  => fifo_MEMWADDR,
          WEN    => fifo_MEMWE,
          REN    => fifo_MEMRE_int,
          WCLOCK => WCLOCK,
          RDATA  => RDATA_int,
          RADDR  => temp_xhdl223,
          RCLOCK => RCLOCK,
          CLOCK  => CLK,
          A_SB_CORRECT=> temp_A_SB_CORRECT,  
          B_SB_CORRECT=> OPEN,  -- v2.5
          A_DB_DETECT => temp_A_DB_DETECT,  
          B_DB_DETECT => OPEN,  
          RESET_N => '0');   
   END GENERATE RW4;

   RW5: IF (CTRL_TYPE = 2 AND FAMILY = 25 AND RESET_POLARITY = 0 AND ECC /= 0) GENERATE
    UI_ram_wrapper_5 : COREFIFO_C0_COREFIFO_C0_0_ram_wrapper
       GENERIC MAP(
            RDEPTH => (ceil_log2t(RDEPTH)),
            WDEPTH => (ceil_log2t(WDEPTH)),
            WWIDTH => WWIDTH,
            RWIDTH => RWIDTH,
            CTRL_TYPE => CTRL_TYPE,
            PIPE => PIPE,
            SYNC => SYNC) 
       PORT MAP (
          WDATA  => DATA,
          WADDR  => fifo_MEMWADDR,
          WEN    => fifo_MEMWE,
          REN    => fifo_MEMRE_int,
          WCLOCK => WCLOCK,
          RDATA  => RDATA_int,
          RADDR  => temp_xhdl223,
          RCLOCK => RCLOCK,
          CLOCK  => CLK,
          A_SB_CORRECT=> temp_A_SB_CORRECT,  
          B_SB_CORRECT=> OPEN,  
          A_DB_DETECT => temp_A_DB_DETECT,  
          B_DB_DETECT => OPEN,  
          RESET_N => '1');   
   END GENERATE RW5;

   RW6: IF (CTRL_TYPE = 3 AND FAMILY = 25 AND RESET_POLARITY = 1 AND ((ECC /= 0 AND PIPE /= 0) OR (ECC = 2 AND PIPE = 0)) ) GENERATE
    UI_ram_wrapper_6 : COREFIFO_C0_COREFIFO_C0_0_ram_wrapper
       GENERIC MAP(
            RDEPTH => (ceil_log2t(RDEPTH)),
            WDEPTH => (ceil_log2t(WDEPTH)),
            WWIDTH => WWIDTH,
            RWIDTH => RWIDTH,
            CTRL_TYPE => CTRL_TYPE,
            PIPE => PIPE,
            SYNC => SYNC) 
       PORT MAP (
          WDATA  => DATA,
          WADDR  => fifo_MEMWADDR,
          WEN    => fifo_MEMWE,
          REN    => fifo_MEMRE_int,
          WCLOCK => WCLOCK,
          RDATA  => RDATA_int,
          RADDR  => temp_xhdl223,
          RCLOCK => RCLOCK,
          CLOCK  => CLK,
          A_SB_CORRECT=> temp_A_SB_CORRECT,  
          B_SB_CORRECT=> temp_B_SB_CORRECT,  
          A_DB_DETECT => temp_A_DB_DETECT,  
          B_DB_DETECT => temp_B_DB_DETECT,  
          RESET_N => '0');   
   END GENERATE RW6;

   RW7: IF (CTRL_TYPE = 3 AND FAMILY = 25 AND RESET_POLARITY = 0 AND ((ECC /= 0 AND PIPE /= 0) OR (ECC = 2 AND PIPE = 0)) ) GENERATE
    UI_ram_wrapper_7 : COREFIFO_C0_COREFIFO_C0_0_ram_wrapper
       GENERIC MAP(
            RDEPTH => (ceil_log2t(RDEPTH)),
            WDEPTH => (ceil_log2t(WDEPTH)),
            WWIDTH => WWIDTH,
            RWIDTH => RWIDTH,
            CTRL_TYPE => CTRL_TYPE,
            PIPE => PIPE,
            SYNC => SYNC) 
       PORT MAP (
          WDATA  => DATA,
          WADDR  => fifo_MEMWADDR,
          WEN    => fifo_MEMWE,
          REN    => fifo_MEMRE_int,
          WCLOCK => WCLOCK,
          RDATA  => RDATA_int,
          RADDR  => temp_xhdl223,
          RCLOCK => RCLOCK,
          CLOCK  => CLK,
          A_SB_CORRECT=> temp_A_SB_CORRECT,  
          B_SB_CORRECT=> temp_B_SB_CORRECT,  
          A_DB_DETECT => temp_A_DB_DETECT,  
          B_DB_DETECT => temp_B_DB_DETECT,  
          RESET_N => '1');   
   END GENERATE RW7;

END ARCHITECTURE translated;
