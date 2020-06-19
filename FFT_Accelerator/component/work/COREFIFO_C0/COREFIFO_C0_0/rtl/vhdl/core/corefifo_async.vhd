-- ********************************************************************/
-- Actel Corporation Proprietary and Confidential
--  Copyright 2011 Actel Corporation.  All rights reserved.
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
-- IN ADVANCE IN WRITING.
--
-- Description:  fifocore_async.v
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
use     ieee.std_logic_arith.all;
use     work.fifo_pkg.all;


ENTITY COREFIFO_C0_COREFIFO_C0_0_corefifo_async IS
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
      WCLK_HIGH                      :  integer := 1;    
      RCLK_HIGH                      :  integer := 1;    
      PIPE                           :  integer := 1;    
      --SYNC_RESET                     :  integer := 1;    
      RESET_LOW                      :  integer := 0;    
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
      -- --------------------------------------------------------------------------
      -- I/O Declaration
      -- --------------------------------------------------------------------------
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
      memre                   : OUT std_logic);   --  memory read enable
END ENTITY COREFIFO_C0_COREFIFO_C0_0_corefifo_async;

ARCHITECTURE translated OF COREFIFO_C0_COREFIFO_C0_0_corefifo_async IS

   --AHK CONSTANT HIGH_FREQUENCY : integer :=  (t_fwft(FWFT, PREFETCH));
   CONSTANT HIGH_FREQUENCY : integer := 0;

   COMPONENT COREFIFO_C0_COREFIFO_C0_0_corefifo_NstagesSync --
      GENERIC (
         --SYNC_RESET                     :  integer := 0; 
         NUM_STAGES                     :  integer := 2;		 
         ADDRWIDTH                      :  integer := 3);    
      PORT (
         clk                     : IN std_logic;   
         rstn                    : IN std_logic;   
         inp                     : IN std_logic_vector(ADDRWIDTH DOWNTO 0);   
         sync_out                : OUT std_logic_vector(ADDRWIDTH DOWNTO 0));
   END COMPONENT;

   COMPONENT COREFIFO_C0_COREFIFO_C0_0_corefifo_grayToBinConv
      GENERIC (
         ADDRWIDTH                      :  integer := 3);    
      PORT (
         gray_in                 : IN std_logic_vector(ADDRWIDTH DOWNTO 0);   
         bin_out                 : OUT std_logic_vector(ADDRWIDTH DOWNTO 0));
   END COMPONENT;

   -- --------------------------------------------------------------------------
   -- Internal signals
   -- --------------------------------------------------------------------------
   SIGNAL wptr                     :  std_logic_vector(WRITE_DEPTH DOWNTO 0);   
   SIGNAL rptr                     :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL rptr_fwft                :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL wrcnt_r                  :  std_logic_vector(WRITE_DEPTH DOWNTO 0);   
   SIGNAL rdcnt_r                  :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL full_r                   :  std_logic;   
   SIGNAL afull_r                  :  std_logic;   
   SIGNAL empty_r                  :  std_logic;   
   SIGNAL empty_r_fwft             :  std_logic;   
   SIGNAL emptyi_fwft              :  std_logic;   
   SIGNAL aempty_r_fwft            :  std_logic;   
   SIGNAL aempty_r                 :  std_logic;   
   SIGNAL memwaddr_r               :  std_logic_vector(ceil_log2t(FULL_WRITE_DEPTH) - 1 DOWNTO 0);   
   SIGNAL memraddr_r               :  std_logic_vector(ceil_log2t(FULL_READ_DEPTH) - 1 DOWNTO 0);   
   SIGNAL dvld_r                   :  std_logic;   
   SIGNAL dvld_r2                  :  std_logic;   
   SIGNAL underflow_r              :  std_logic;   
   SIGNAL wack_r                   :  std_logic;   
   SIGNAL overflow_r               :  std_logic;   
   SIGNAL wptr_bin_sync2           :  std_logic_vector(WRITE_DEPTH DOWNTO 0);   
   SIGNAL rptr_bin_sync2           :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL rptr_bin_sync2_fwft      :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL wptrsync_shift           :  std_logic_vector(VAR_ASPECT_WRDEPTH DOWNTO 0);   
   SIGNAL rptrsync_shift           :  std_logic_vector(VAR_ASPECT_RDDEPTH DOWNTO 0);   
   SIGNAL rptrsync_shift_fwft      :  std_logic_vector(VAR_ASPECT_RDDEPTH DOWNTO 0);   
   SIGNAL wptr_gray_sync           :  std_logic_vector(WRITE_DEPTH DOWNTO 0);   
   SIGNAL rptr_gray_sync           :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL rptr_gray_sync_fwft      :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL wptr_bin_sync            :  std_logic_vector(WRITE_DEPTH DOWNTO 0);   
   SIGNAL rptr_bin_sync            :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL rptr_bin_sync_fwft       :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL wptr_gray                :  std_logic_vector(WRITE_DEPTH DOWNTO 0);   
   SIGNAL rptr_gray                :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL rptr_gray_fwft           :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL afthreshi                :  std_logic_vector(WRITE_DEPTH DOWNTO 0);   
   SIGNAL wdiff_bus                :  std_logic_vector(WRITE_DEPTH DOWNTO 0);   
   SIGNAL wdiff_bus_fwft           :  std_logic_vector(WRITE_DEPTH DOWNTO 0);   
   SIGNAL aethreshi                :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL rdiff_bus                :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL rdiff_bus_fwft           :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL fulli                    :  std_logic;   
   SIGNAL fulli_int                :  std_logic;   
   SIGNAL almostfulli              :  std_logic;   
   SIGNAL almostemptyi             :  std_logic;   
   SIGNAL almostemptyi_assert      :  std_logic;   
   SIGNAL almostemptyi_assert_sig  :  std_logic;   
   SIGNAL almostfulli_assert       :  std_logic;   
   SIGNAL almostfulli_deassert     :  std_logic;   
   SIGNAL almostfulli_deassert_sig :  std_logic;   
   SIGNAL almostemptyi_deassert    :  std_logic;   
   SIGNAL almostemptyi_fwft        :  std_logic;   
   SIGNAL emptyi                   :  std_logic;   
   SIGNAL temp_empty_int           :  std_logic;   
   SIGNAL temp_xhdl15              :  std_logic;   
   SIGNAL temp_xhdl16              :  integer;   
   SIGNAL temp_xhdl17              :  integer;   
   SIGNAL temp_xhdl18              :  std_logic;   
   SIGNAL temp_xhdl19              :  std_logic;   
   SIGNAL temp_xhdl20              :  std_logic;   
   SIGNAL temp_xhdl21              :  std_logic;   
   SIGNAL temp_xhdl22              :  std_logic;   
   SIGNAL temp_xhdl22_top          :  std_logic;   
   SIGNAL re_top_p                 :  std_logic;   
   SIGNAL full_xhdl1               :  std_logic;   
   SIGNAL full_reg                 :  std_logic;   
   SIGNAL afull_xhdl2              :  std_logic;   
   SIGNAL wrcnt_xhdl3              :  std_logic_vector(WRITE_DEPTH DOWNTO 0);   
   SIGNAL empty_xhdl4              :  std_logic;   
   SIGNAL empty_reg                :  std_logic;   
   SIGNAL aempty_xhdl5             :  std_logic;   
   SIGNAL rdcnt_xhdl6              :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL underflow_xhdl7          :  std_logic;   
   SIGNAL overflow_xhdl8           :  std_logic;   
   SIGNAL dvld_xhdl9               :  std_logic;   
   SIGNAL dvld_xhdl9_int           :  std_logic;   
   SIGNAL wack_xhdl10              :  std_logic;   
   SIGNAL memwaddr_xhdl11          :  std_logic_vector(ceil_log2t(FULL_WRITE_DEPTH) - 1 DOWNTO 0);   
   SIGNAL memwe_xhdl12             :  std_logic;   
   SIGNAL memraddr_xhdl13          :  std_logic_vector(ceil_log2t(FULL_READ_DEPTH) - 1 DOWNTO 0);   
   SIGNAL memre_xhdl14             :  std_logic;   
   SIGNAL neg_reset                :  std_logic;   
   SIGNAL pos_rclk                 :  std_logic;   
   SIGNAL pos_wclk                 :  std_logic;   
   SIGNAL re_i                     :  std_logic;   
   SIGNAL re_p                     :  std_logic;   
   SIGNAL we_i                     :  std_logic;   
   SIGNAL we_p                     :  std_logic;   
   SIGNAL we_p_r                   :  std_logic;   
   SIGNAL we_p_xor                 :  std_logic;   
   SIGNAL fulli_fstop              :  std_logic;   
   SIGNAL fulli_fstop_assert       :  std_logic;   
   SIGNAL fulli_fstop_deassert     :  std_logic;   
   SIGNAL fulli_fstop_sig          :  std_logic;   
   SIGNAL emptyi_estop             :  std_logic;    
   SIGNAL re_p_d1                  :  std_logic;   
   SIGNAL aresetn                  :  std_logic;   
 
   
   -- --------------------------------------------------------------------------
   -- Function Declarations
   -- --------------------------------------------------------------------------
   FUNCTION ShiftRight (
      val      : std_logic_vector;
      shft     : integer) RETURN std_logic_vector IS
      
      VARIABLE int      : std_logic_vector(val'LENGTH+shft-1 DOWNTO 0);
      VARIABLE rtn      : std_logic_vector(val'RANGE);
      VARIABLE fill     : std_logic_vector(shft-1 DOWNTO 0) := (others => '0');
   BEGIN
      int := fill & val;
      rtn := int(val'LENGTH+shft-1 DOWNTO shft);
      RETURN(rtn);
   END ShiftRight;  

   FUNCTION "SRL" (
      l        : std_logic_vector;
      r        : integer) RETURN std_logic_vector IS
   BEGIN
      RETURN(ShiftRight(l, r));
   END "SRL";

    FUNCTION ShiftLeft (
      val      : std_logic_vector;
      shft     : integer) RETURN std_logic_vector IS
      
      VARIABLE int      : std_logic_vector(val'LENGTH+shft-1 DOWNTO 0);
      VARIABLE rtn      : std_logic_vector(val'RANGE);
      VARIABLE fill     : std_logic_vector(shft-1 DOWNTO 0) := (others => '0');
   BEGIN
      int := val & fill;
      rtn := int(val'LENGTH-1 DOWNTO 0);
      RETURN(rtn);
   END ShiftLeft;

   FUNCTION "SLL" (
      l        : std_logic_vector;
      r        : integer) RETURN std_logic_vector IS
   BEGIN
      RETURN(ShiftLeft(l, r));
   END "SLL";
   
   FUNCTION to_stdlogicvector (
      val      : IN integer;
      len      : IN integer) RETURN std_logic_vector IS
      
      VARIABLE rtn      : std_logic_vector(len-1 DOWNTO 0) := (OTHERS => '0');
      VARIABLE num  : integer := val;
      VARIABLE r       : integer;
   BEGIN
      FOR index IN 0 TO len-1 LOOP
         r := num rem 2;
         num := num/2;
         IF (r = 1) THEN
            rtn(index) := '1';
         ELSE
            rtn(index) := '0';
         END IF;
      END LOOP;
      RETURN(rtn);
   END to_stdlogicvector;

    FUNCTION conv_std_logic_vector (
      val      : IN integer;
      len      : IN integer) RETURN std_logic_vector IS
   BEGIN
	   RETURN(to_stdlogicvector(val, len));
	END conv_std_logic_vector;        
   
   FUNCTION to_stdlogic (
      val      : IN boolean) RETURN std_logic IS
   BEGIN
      IF (val) THEN
         RETURN('1');
      ELSE
         RETURN('0');
      END IF;
   END to_stdlogic;
   
   FUNCTION conv_std_logic (
      val      : IN boolean) RETURN std_logic IS
   BEGIN
      RETURN(to_stdlogic(val));
   END conv_std_logic;   


BEGIN

   -- --------------------------------------------------------------------------
   -- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
   -- ||                                                                      ||
   -- ||                     Start - of - Code                                ||
   -- ||                                                                      ||
   -- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
   -- --------------------------------------------------------------------------

   -- --------------------------------------------------------------------------
   -- Top-level outputs
   -- --------------------------------------------------------------------------
   full      <= full_xhdl1;
   afull     <= afull_xhdl2;
   wrcnt     <= wrcnt_xhdl3;
   empty     <= empty_xhdl4;
   aempty    <= aempty_xhdl5;
   rdcnt     <= rdcnt_xhdl6;
   underflow <= underflow_xhdl7;
   overflow  <= overflow_xhdl8;
   dvld      <= dvld_xhdl9;
   wack      <= wack_xhdl10;
   memwaddr  <= memwaddr_xhdl11;
   memwe     <= memwe_xhdl12;
   memraddr  <= memraddr_xhdl13;
   memre     <= memre_xhdl14;

   full_xhdl1 <= full_r ;
   afull_xhdl2 <= afull_r ;
   empty_xhdl4 <= empty_r ;
   aempty_xhdl5 <= aempty_r ;
   underflow_xhdl7 <= underflow_r ;
   wack_xhdl10 <= wack_r ;
   dvld_xhdl9_int <= dvld_r WHEN (REGISTER_RADDR = 1 AND PREFETCH = 0) ELSE re_i;
   dvld_xhdl9 <= dvld_r2 WHEN (REGISTER_RADDR = 2) ELSE dvld_xhdl9_int;
   overflow_xhdl8 <= overflow_r ;
   memwaddr_xhdl11 <= memwaddr_r ;
   memraddr_xhdl13 <= memraddr_r ;
   wrcnt_xhdl3 <= wrcnt_r ;
   rdcnt_xhdl6 <= rdcnt_r ;

   -- --------------------------------------------------------------------------
   -- Clock edge based on clock polarity
   -- --------------------------------------------------------------------------
   temp_xhdl18 <= rclk WHEN RCLK_HIGH /= 0 ELSE NOT rclk;
   pos_rclk <= temp_xhdl18 ;
   temp_xhdl19 <= wclk WHEN WCLK_HIGH /= 0 ELSE NOT wclk;
   pos_wclk <= temp_xhdl19 ;
  -- temp_xhdl20 <= NOT reset WHEN RESET_LOW /= 0 ELSE reset;
  -- neg_reset <= temp_xhdl20 ;

   
 
	

  

   -- --------------------------------------------------------------------------
   -- Read and Write enables
   -- --------------------------------------------------------------------------
   T1: IF (FWFT = 0 AND PREFETCH = 0) GENERATE
       temp_xhdl21 <= (NOT we) WHEN WRITE_LOW /= 0 ELSE (we);
       we_p <= temp_xhdl21 ;
       temp_xhdl22 <= (NOT re) WHEN READ_LOW /= 0 ELSE (re);
       re_p <= temp_xhdl22 ;
   END GENERATE T1;

   T2: IF ((FWFT = 1 OR PREFETCH = 1) AND PIPE = 1) GENERATE
       temp_xhdl21 <= (NOT we) WHEN WRITE_LOW /= 0 ELSE (we);
       we_p <= temp_xhdl21 ;
       re_p <= re ;
       temp_xhdl22_top <= (NOT re_top) WHEN READ_LOW /= 0 ELSE (re_top);
       re_top_p <= temp_xhdl22_top ;
   END GENERATE T2;

   we_i <= we_p AND NOT full_r ;
   re_i <= re_p AND NOT empty_r ;

   -- --------------------------------------------------------------------------
   -- Empty/Full FIFO flags
   -- --------------------------------------------------------------------------
   T11: IF (FWFT = 0 AND PREFETCH = 0) GENERATE
        fulli <= conv_std_logic(wdiff_bus >= conv_std_logic_vector((FULL_WRITE_DEPTH - 1), WRITE_DEPTH+1)) WHEN temp_xhdl21 = '1' ELSE   conv_std_logic(wdiff_bus >= conv_std_logic_vector((FULL_WRITE_DEPTH), WRITE_DEPTH+1)); 
   END GENERATE T11;

   T12: IF ((FWFT = 1 OR PREFETCH = 1) AND PIPE = 1) GENERATE
        fulli <= conv_std_logic(wdiff_bus_fwft >= conv_std_logic_vector((FULL_WRITE_DEPTH - 1), WRITE_DEPTH+1)) WHEN temp_xhdl21 = '1' ELSE   conv_std_logic(wdiff_bus_fwft >= conv_std_logic_vector((FULL_WRITE_DEPTH), WRITE_DEPTH+1)); 
   END GENERATE T12;


   --fulli_fstop <= conv_std_logic(wdiff_bus(WRITE_DEPTH-1 DOWNTO 0) >= conv_std_logic_vector((FULL_WRITE_DEPTH - 1), WRITE_DEPTH)) WHEN temp_xhdl21 = '1' ELSE   conv_std_logic(wdiff_bus(WRITE_DEPTH-1 DOWNTO 0) >= conv_std_logic_vector((FULL_WRITE_DEPTH), WRITE_DEPTH+1));
   fulli_fstop_assert   <= '1' WHEN (conv_std_logic(wdiff_bus(WRITE_DEPTH-1 DOWNTO 0) = conv_std_logic_vector((FULL_WRITE_DEPTH - 1), WRITE_DEPTH)) AND NOT(full_r) AND we_p) = '1' ELSE '0';  -- Nov 6
   fulli_fstop_deassert <= '1' WHEN ((we_p AND full_r) OR (conv_std_logic(wdiff_bus < conv_std_logic_vector((FULL_WRITE_DEPTH - 1), WRITE_DEPTH)))) = '1' ELSE '0';  -- Nov 6
   fulli_fstop_sig      <= '0' WHEN (fulli_fstop_deassert = '1') ELSE full_r;  -- Nov 6
   fulli_fstop          <= '1' WHEN (fulli_fstop_assert = '1') ELSE fulli_fstop_sig;  -- Nov 6

   temp_empty_int <= conv_std_logic(rdiff_bus = conv_std_logic_vector(1,READ_DEPTH+1))  WHEN (temp_xhdl22 = '1') ELSE conv_std_logic((rdiff_bus) <= 0);  

   EPT1: IF (HIGH_FREQUENCY = 1 ) GENERATE
     emptyi <=  ( conv_std_logic((rdiff_bus) <= 2) AND re_p AND re_p_d1 ) OR (conv_std_logic((rdiff_bus <= 1))  AND (re_p OR re_p_d1) ) OR conv_std_logic(rdiff_bus = 0); 
   END GENERATE EPT1;

   EPT2: IF(HIGH_FREQUENCY = 0) GENERATE
     emptyi <=  conv_std_logic((rdiff_bus) <= 1); 
   END GENERATE EPT2;

   --emptyi <=  conv_std_logic((rdiff_bus) <= 1); 
   
   emptyi_fwft <= conv_std_logic(rdiff_bus_fwft <= 1);  
   emptyi_estop <= temp_empty_int;  


   -- --------------------------------------------------------------------------
   -- Set threshold values
   -- --------------------------------------------------------------------------
   temp_xhdl16 <= (AFULL_VAL - 1) WHEN AF_FLAG_STATIC = 1 ELSE FULL_WRITE_DEPTH;  
   afthreshi <= conv_std_logic_vector(temp_xhdl16, WRITE_DEPTH+1) ;

   temp_xhdl17 <= (AEMPTY_VAL) WHEN AE_FLAG_STATIC = 1 ELSE 2; 
   aethreshi <= conv_std_logic_vector(temp_xhdl17, READ_DEPTH+1)  ;

   -- --------------------------------------------------------------------------
   -- Generate almost flags
   -- --------------------------------------------------------------------------
   T3: IF (FWFT = 0 AND PREFETCH = 0 AND HIGH_FREQUENCY = 0 ) GENERATE
       --AHK almostfulli  <= conv_std_logic(wdiff_bus >= afthreshi) ;
       almostfulli_assert <= conv_std_logic( wdiff_bus >= afthreshi) AND we_p;
       almostfulli_deassert <= conv_std_logic(wdiff_bus <= afthreshi);
       almostfulli_deassert_sig <= '0' WHEN almostfulli_deassert = '1' ELSE afull_xhdl2;
       almostfulli <= '1' WHEN almostfulli_assert = '1' ELSE almostfulli_deassert_sig;

       almostemptyi_assert     <= conv_std_logic(aethreshi >= rdiff_bus) AND re_p;  
       almostemptyi_assert_sig <= '1' WHEN almostemptyi_assert = '1' ELSE aempty_xhdl5;  
       almostemptyi_deassert   <= conv_std_logic(aethreshi <= rdiff_bus) AND aempty_r;  
       almostemptyi            <= '0' WHEN almostemptyi_deassert = '1' ELSE almostemptyi_assert_sig; 
   END GENERATE T3;

   T5: IF (FWFT = 0 AND PREFETCH = 0 AND HIGH_FREQUENCY = 1 ) GENERATE
       almostfulli  <= conv_std_logic(wdiff_bus >= afthreshi) ;

       almostemptyi_assert     <= conv_std_logic(aethreshi >= rdiff_bus) AND re_p;  
       almostemptyi_assert_sig <= '1' WHEN almostemptyi_assert = '1' ELSE aempty_r;  
       almostemptyi_deassert   <= conv_std_logic(aethreshi <= rdiff_bus) AND aempty_r;  
       almostemptyi            <=  conv_std_logic(aethreshi >= rdiff_bus); 
   END GENERATE T5;


   T4: IF ((FWFT = 1 OR PREFETCH = 1) AND PIPE = 1) GENERATE
       --AHK almostfulli  <= conv_std_logic(wdiff_bus_fwft >= afthreshi) ;
       almostfulli_assert    <=  conv_std_logic(wdiff_bus_fwft >= afthreshi) AND we_p;
       almostfulli_deassert  <=  conv_std_logic(wdiff_bus_fwft <= afthreshi);
       almostfulli_deassert_sig <= '0' WHEN almostfulli_deassert = '1' ELSE afull_xhdl2 ;
       almostfulli           <=  '1' WHEN almostfulli_assert = '1' ELSE almostfulli_deassert_sig ;

       almostemptyi_assert     <= conv_std_logic(aethreshi+1 >= rdiff_bus_fwft) AND re_top_p;  
       almostemptyi_deassert   <= conv_std_logic(aethreshi+1 <=  rdiff_bus_fwft) AND aempty_xhdl5;  
       almostemptyi_assert_sig <= '1' WHEN almostemptyi_assert = '1' ELSE aempty_xhdl5 ;    
       almostemptyi            <= '0' WHEN almostemptyi_deassert = '1' ELSE almostemptyi_assert_sig;

       almostemptyi_fwft <= conv_std_logic(aethreshi >= rdiff_bus_fwft) ;
   END GENERATE T4;

   -- --------------------------------------------------------------------------
   -- Difference between write pointer and read pointer
   -- --------------------------------------------------------------------------
   
   DIFFW1 : IF (HIGH_FREQUENCY = 1) GENERATE
   
    PROCESS (pos_rclk, reset_rclk)
    BEGIN
      IF (NOT reset_rclk = '1') THEN
         wdiff_bus <= (OTHERS => '0') ;   
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
         
            IF (WRITE_DEPTH > READ_DEPTH) THEN
              wdiff_bus <= wptr - rptrsync_shift ;   
            ELSE
              IF (READ_DEPTH > WRITE_DEPTH) THEN
                wdiff_bus <= wptr - rptrsync_shift((VAR_ASPECT_RDDEPTH - (READ_DEPTH-WRITE_DEPTH)) downto 0);   
	      ELSE
                wdiff_bus <= wptr - rptrsync_shift ;   
	     -- END IF;
	    END IF; 
         END IF;
      END IF;
    END PROCESS;

   END GENERATE DIFFW1; 

   DIFFR1 : IF (HIGH_FREQUENCY = 1) GENERATE
    PROCESS (pos_rclk, reset_rclk)
    BEGIN
      IF (NOT reset_rclk = '1') THEN
         rdiff_bus <= (OTHERS => '0') ;   
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
         
          
            IF (WRITE_DEPTH > READ_DEPTH) THEN
                rdiff_bus <= wptrsync_shift((VAR_ASPECT_WRDEPTH - (WRITE_DEPTH - READ_DEPTH)) downto 0) - rptr ;
            ELSE
              IF (READ_DEPTH > WRITE_DEPTH) THEN
                rdiff_bus <= wptrsync_shift - rptr ;
	      ELSE
                rdiff_bus <= wptrsync_shift - rptr ;
	      END IF;
	    END IF; 
        -- END IF;
      END IF;
    END PROCESS;
   END GENERATE DIFFR1; 


   DIFFT2 : IF (HIGH_FREQUENCY = 0) GENERATE
     PROCESS (rptrsync_shift, wptr, wptrsync_shift, rptr)
     BEGIN
        IF (WRITE_DEPTH > READ_DEPTH) THEN
           wdiff_bus <= wptr - rptrsync_shift ;   
           rdiff_bus <= wptrsync_shift((VAR_ASPECT_WRDEPTH - (WRITE_DEPTH - READ_DEPTH)) downto 0) - rptr ;
        ELSE
           IF (READ_DEPTH > WRITE_DEPTH) THEN
             wdiff_bus <= wptr - rptrsync_shift((VAR_ASPECT_RDDEPTH - (READ_DEPTH-WRITE_DEPTH)) downto 0);   
             rdiff_bus <= wptrsync_shift - rptr ;
           ELSE
             wdiff_bus <= wptr - rptrsync_shift ;   
             rdiff_bus <= wptrsync_shift - rptr ;
           END IF;
        END IF;
     END PROCESS;
    END GENERATE DIFFT2;


    --PROCESS (rptrsync_shift, wptr, wptrsync_shift, rptr)
    --BEGIN
    --   IF (WRITE_DEPTH > READ_DEPTH) THEN
    --      wdiff_bus <= wptr - rptrsync_shift ;   
    --      rdiff_bus <= wptrsync_shift((VAR_ASPECT_WRDEPTH - (WRITE_DEPTH - READ_DEPTH)) downto 0) - rptr ;
    --   ELSE
    --      IF (READ_DEPTH > WRITE_DEPTH) THEN
    --        wdiff_bus <= wptr - rptrsync_shift((VAR_ASPECT_RDDEPTH - (READ_DEPTH-WRITE_DEPTH)) downto 0);   
    --        rdiff_bus <= wptrsync_shift - rptr ;
    --      ELSE
    --        wdiff_bus <= wptr - rptrsync_shift ;   
    --        rdiff_bus <= wptrsync_shift - rptr ;
    --      END IF;
    --   END IF;
    --END PROCESS;

   PROCESS (rptrsync_shift_fwft, wptr, wptrsync_shift, rptr_fwft)
   BEGIN
      IF (WRITE_DEPTH > READ_DEPTH) THEN
         wdiff_bus_fwft <= wptr - rptrsync_shift_fwft ;   
         rdiff_bus_fwft <= wptrsync_shift((VAR_ASPECT_WRDEPTH - (WRITE_DEPTH - READ_DEPTH)) downto 0) - rptr_fwft ;
      ELSE
         IF (READ_DEPTH > WRITE_DEPTH) THEN
           wdiff_bus_fwft <= wptr - rptrsync_shift_fwft((VAR_ASPECT_RDDEPTH - (READ_DEPTH-WRITE_DEPTH)) downto 0);   
           rdiff_bus_fwft <= wptrsync_shift - rptr_fwft ;
         ELSE
           wdiff_bus_fwft <= wptr - rptrsync_shift_fwft ;   
           rdiff_bus_fwft <= wptrsync_shift - rptr_fwft ;
         END IF;
      END IF;
   END PROCESS;


   -- --------------------------------------------------------------------------
   -- Instance::Sync Write gray pointer
   -- --------------------------------------------------------------------------
   Wr_corefifo_NstagesSync : COREFIFO_C0_COREFIFO_C0_0_corefifo_NstagesSync --
      GENERIC MAP (
            --SYNC_RESET => SYNC_RESET,
		 NUM_STAGES => NUM_STAGES,
         ADDRWIDTH => WRITE_DEPTH)
      PORT MAP (
         clk => pos_rclk,
         rstn => reset_rclk,
         inp => wptr_gray,
         sync_out => wptr_gray_sync);   
   
   
   -- --------------------------------------------------------------------------
   -- Instance::Sync Read gray pointer
   -- --------------------------------------------------------------------------
   Rd_corefifo_NstagesSync : COREFIFO_C0_COREFIFO_C0_0_corefifo_NstagesSync --
      GENERIC MAP (
           -- SYNC_RESET => SYNC_RESET,
		   NUM_STAGES => NUM_STAGES,
         ADDRWIDTH => READ_DEPTH)
      PORT MAP (
         clk => pos_wclk,
         rstn => reset_wclk,
         inp => rptr_gray,
         sync_out => rptr_gray_sync);   
   
   
   -- --------------------------------------------------------------------------
   -- Instance::Read gray-to-binary conversion logic
   -- --------------------------------------------------------------------------
   Rd_corefifo_grayToBinConv : COREFIFO_C0_COREFIFO_C0_0_corefifo_grayToBinConv 
      GENERIC MAP (
         ADDRWIDTH => READ_DEPTH)
      PORT MAP (
         gray_in => rptr_gray_sync,
         bin_out => rptr_bin_sync);   
   
   
   -- --------------------------------------------------------------------------
   -- Instance::Write gray-to-binary conversion logic
   -- --------------------------------------------------------------------------
   Wr_corefifo_grayToBinConv : COREFIFO_C0_COREFIFO_C0_0_corefifo_grayToBinConv 
      GENERIC MAP (
         ADDRWIDTH => WRITE_DEPTH)
      PORT MAP (
         gray_in => wptr_gray_sync,
         bin_out => wptr_bin_sync);   
   

   -- --------------------------------------------------------------------------
   -- Register the binary write pointer value
   -- --------------------------------------------------------------------------

   PROCESS (pos_rclk, reset_rclk)  --SAR#60021
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         wptr_bin_sync2 <= (OTHERS => '0');    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
        
            wptr_bin_sync2 <= wptr_bin_sync;    
         --END IF;   
      END IF;
   END PROCESS;

   -- --------------------------------------------------------------------------
   -- Register the binary read pointer value
   -- --------------------------------------------------------------------------

   PROCESS (pos_wclk, reset_wclk)  --SAR#60021
   BEGIN
      IF (NOT reset_wclk = '1') THEN
         rptr_bin_sync2 <= (OTHERS => '0');    
      ELSIF (pos_wclk'EVENT AND pos_wclk = '1') THEN
         
            rptr_bin_sync2 <= rptr_bin_sync;    
        -- END IF;   
      END IF;
   END PROCESS;

   -- --------------------------------------------------------------------------
   -- Instance::Sync Read gray pointer
   -- --------------------------------------------------------------------------
   Rd_NstagesSync_fwft : COREFIFO_C0_COREFIFO_C0_0_corefifo_NstagesSync --
      GENERIC MAP (
            --SYNC_RESET => SYNC_RESET,
		NUM_STAGES => NUM_STAGES,
         ADDRWIDTH => READ_DEPTH)
      PORT MAP (
         clk => pos_wclk,
         rstn => reset_wclk,
         inp => rptr_gray_fwft,
         sync_out => rptr_gray_sync_fwft);   
   
   
   -- --------------------------------------------------------------------------
   -- Instance::Read gray-to-binary conversion logic
   -- --------------------------------------------------------------------------
   Rd_grayToBinConv_fwft : COREFIFO_C0_COREFIFO_C0_0_corefifo_grayToBinConv 
      GENERIC MAP (
         ADDRWIDTH => READ_DEPTH)
      PORT MAP (
         gray_in => rptr_gray_sync_fwft,
         bin_out => rptr_bin_sync_fwft);   
   
   -- --------------------------------------------------------------------------
   -- Register the binary read pointer value
   -- --------------------------------------------------------------------------
   
   PROCESS (pos_wclk, reset_wclk)    --SAR#60021
   BEGIN
      IF (NOT reset_wclk = '1') THEN
         rptr_bin_sync2_fwft <= (OTHERS => '0');    
      ELSIF (pos_wclk'EVENT AND pos_wclk = '1') THEN
       
            rptr_bin_sync2_fwft <= rptr_bin_sync_fwft;    
       --  END IF;   
      END IF;
   END PROCESS;

   -- --------------------------------------------------------------------------
   -- For variable aspect ratios
   -- The variable aspect logic is handled by shifting the required bits of the
   -- read/write pointer so that they are of the same width. 
   -- --------------------------------------------------------------------------

   PROCESS (rptr_bin_sync2, wptr_bin_sync2)
   BEGIN
      IF (WRITE_DEPTH > READ_DEPTH) THEN
         rptrsync_shift <= ((conv_std_logic_vector(0,WRITE_DEPTH - READ_DEPTH) & rptr_bin_sync2) SLL (WRITE_DEPTH - READ_DEPTH));    
         wptrsync_shift <= (wptr_bin_sync2 SRL (WRITE_DEPTH - READ_DEPTH));    
      ELSE
         IF (READ_DEPTH > WRITE_DEPTH) THEN
            rptrsync_shift <= (rptr_bin_sync2 SRL (READ_DEPTH-WRITE_DEPTH));    
            wptrsync_shift <= ((conv_std_logic_vector(0,READ_DEPTH- WRITE_DEPTH) & wptr_bin_sync2) SLL (READ_DEPTH-WRITE_DEPTH));    
         ELSE
            rptrsync_shift <= (rptr_bin_sync2);    
            wptrsync_shift <= (wptr_bin_sync2);    
         END IF;
      END IF;
   END PROCESS;


   PROCESS (rptr_bin_sync2_fwft, wptr_bin_sync2)
   BEGIN
      IF (WRITE_DEPTH > READ_DEPTH) THEN
         rptrsync_shift_fwft <= ((conv_std_logic_vector(0,WRITE_DEPTH - READ_DEPTH) & rptr_bin_sync2_fwft) SLL (WRITE_DEPTH - READ_DEPTH));    
      ELSE
         IF (READ_DEPTH > WRITE_DEPTH) THEN
            rptrsync_shift_fwft <= (rptr_bin_sync2_fwft SRL (READ_DEPTH-WRITE_DEPTH));    
         ELSE
            rptrsync_shift_fwft <= rptr_bin_sync2_fwft;    
         END IF;
      END IF;
   END PROCESS;


   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         re_p_d1 <= '0';    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
         
            re_p_d1 <= re_p;    
        -- END IF;
      END IF;
   END PROCESS;

   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         dvld_r2   <= '0';    
         empty_reg <= '0';    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
         
            dvld_r2   <= dvld_r;    
            empty_reg <= empty_xhdl4;    
         --END IF;
      END IF;
   END PROCESS;
   
   PROCESS (pos_wclk, reset_wclk)  
   BEGIN
      IF (NOT reset_wclk = '1') THEN
         full_reg <= '0';    
         we_p_r   <= '0';    
      ELSIF (pos_wclk'EVENT AND pos_wclk = '1') THEN
        
            full_reg <= full_xhdl1;    
            we_p_r   <= we_p;    
         --END IF;
      END IF;
   END PROCESS;
  
   we_p_xor <= we_p xor we_p_r;

   -- Generation of full, almost full, write acknowledge flags and write count on write clock
   fulli_int <= fulli WHEN (FSTOP = 1) ELSE fulli_fstop;

   -- --------------------------------------------------------------------------    
   -- Update the pointer values based in ESTOP and FSTOP parameters.
   -- Generate the status flags - Empty/Full/Almost Empty/ Almost Full
   -- Generate the data handshaking flags - DVLD/WACK
   -- Generate error count flags - Underflow/Overflow
   -- Generate control signals to the external memory
   -- --------------------------------------------------------------------------    
   -- --------------------------------------------------------------------------
   -- Write pointer Binary counter
   -- --------------------------------------------------------------------------
   L1: IF (ESTOP = 1 AND FSTOP = 1) GENERATE

   PROCESS (pos_wclk, reset_wclk)
   BEGIN
      IF (NOT reset_wclk = '1') THEN
         wptr <= (OTHERS => '0');    
         wptr_gray <= (OTHERS => '0');    
      ELSIF (pos_wclk'EVENT AND pos_wclk = '1') THEN
          
            IF (we_i = '1') THEN   
              wptr <= wptr + '1';    
              wptr_gray <= (wptr SRL 1) XOR wptr;    
            ELSE 
              wptr_gray <= (wptr SRL 1) XOR wptr;    
            END IF;
        -- END IF;
      END IF;
   END PROCESS;

   -- --------------------------------------------------------------------------
   -- Read pointer Binary counter
   -- --------------------------------------------------------------------------
   
   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         rptr <= (OTHERS => '0');    
         rptr_gray <= (OTHERS => '0');    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
         
            IF (re_i = '1') THEN 
               rptr <= rptr + '1';    
               rptr_gray <= (rptr SRL 1) XOR rptr;    
            ELSE 
               rptr_gray <= (rptr SRL 1) XOR rptr;    
            END IF;
         --END IF;
      END IF;
   END PROCESS;

   
   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         rptr_fwft <= (OTHERS => '0');    
         rptr_gray_fwft <= (OTHERS => '0');    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
         
            IF (re_top_p = '1' AND (NOT empty_r_fwft) = '1' AND (FWFT = 1 OR PREFETCH = 1)) THEN 
               rptr_fwft <= rptr_fwft + '1';    
               rptr_gray_fwft <= (rptr_fwft SRL 1) XOR rptr_fwft;    
            ELSE 
               rptr_gray_fwft <= (rptr_fwft SRL 1) XOR rptr_fwft;    
            END IF;
         --END IF;
      END IF;
   END PROCESS;

   -- --------------------------------------------------------------------------
   -- Generation of empty, almost empty, read data valid flags and read count on read clock
   -- --------------------------------------------------------------------------
   
   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         empty_r <= '1';    
         empty_r_fwft <= '1';    
         aempty_r_fwft <= '1';    
         aempty_r <= '1';    
         dvld_r <= '0';    
         rdcnt_r <= (OTHERS => '0');    
         underflow_r <= '0';    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
        
	      IF((conv_std_logic(rdiff_bus = conv_std_logic_vector(1,READ_DEPTH+1))) = '1') THEN
    		 IF(re_p = '1') THEN
    	           empty_r <= '1';
               ELSE 
    	           empty_r <= '0';
               END IF;
             ELSE
                   empty_r <= emptyi; 
             END IF;
    
	      IF((conv_std_logic(rdiff_bus_fwft = conv_std_logic_vector(1,READ_DEPTH+1))) = '1') THEN
    		 IF(re_top_p = '1') THEN
    	           empty_r_fwft <= '1';
               ELSE 
    	           empty_r_fwft <= '0';
               END IF;
             ELSE
                   empty_r_fwft <= emptyi_fwft; 
             END IF;
    
           aempty_r <= almostemptyi;    
           aempty_r_fwft <= almostemptyi_fwft;    
    
           IF (RDCNT_EN = 1 AND FWFT = 0 AND PREFETCH = 0) THEN
              rdcnt_r <= rdiff_bus;    
           ELSIF (RDCNT_EN = 1 AND (FWFT = 1 OR PREFETCH = 1)) THEN
              rdcnt_r <= rdiff_bus_fwft;    
           ELSE
              rdcnt_r <= rdcnt_r;    
           END IF;
    
           IF (re_i = '1' AND READ_DVALID = 1) THEN
              dvld_r <= '1';    
           ELSE
              dvld_r <= '0';    
           END IF;
    
           IF ((re_p = '1' AND empty_r = '1') AND UNDERFLOW_EN = 1 AND FWFT = 0 AND PREFETCH = 0) THEN
              underflow_r <= '1';    
           ELSIF ((re_top_p = '1' AND empty_r_fwft = '1') AND UNDERFLOW_EN = 1 AND (FWFT = 1 OR PREFETCH = 1)) THEN
              underflow_r <= '1';    
           ELSE
              underflow_r <= '0';    
           END IF;
        --END IF;
      END IF;
   END PROCESS;


   PROCESS (pos_wclk, reset_wclk)
   BEGIN
      IF (NOT reset_wclk = '1') THEN
         full_r <= '0';    
         afull_r <= '0';    
         wack_r <= '0';    
         wrcnt_r<= (OTHERS => '0');    
         overflow_r <= '0';    
      ELSIF (pos_wclk'EVENT AND pos_wclk = '1') THEN
      
         full_r <= fulli_int;    
         afull_r <= almostfulli;    
         
         IF (WRCNT_EN = 1 AND FWFT = 0 AND PREFETCH = 0) THEN
            wrcnt_r <= wdiff_bus;    
         ELSIF (WRCNT_EN = 1 AND (FWFT = 1 OR PREFETCH = 1)) THEN
            wrcnt_r <= wdiff_bus_fwft;    
         ELSE
            wrcnt_r <= wrcnt_r;    
         END IF;
         
         IF (we_i = '1' AND WRITE_ACK = 1) THEN
            wack_r <= '1';    
         ELSE
            wack_r <= '0';    
         END IF;
         
         IF ((we_p = '1' AND full_r = '1') AND OVERFLOW_EN = 1) THEN  
            overflow_r <= '1';    
         ELSE
            overflow_r <= '0';    
         END IF;
     -- END IF;
      END IF;
   END PROCESS;

   -- Generation of write address to external memory
   
   PROCESS (pos_wclk, reset_wclk)
   BEGIN
      IF (NOT reset_wclk = '1') THEN
         memwaddr_r <= (OTHERS => '0');    
      ELSIF (pos_wclk'EVENT AND pos_wclk = '1') THEN
      
         --IF (we_i = '1') THEN  
         IF (we_i = '1') THEN   -- SAR#68070
            IF (((conv_std_logic(memwaddr_r = conv_std_logic_vector(FULL_WRITE_DEPTH-1,ceil_log2t(FULL_WRITE_DEPTH)))) = '1')) THEN   -- SAR#68070
               memwaddr_r <= (OTHERS => '0');    
            ELSE
               memwaddr_r <= memwaddr_r + '1';    
            END IF;
         END IF;
      --END IF;
      END IF;
   END PROCESS;

   -- Generation of read address to external memory
   
   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         memraddr_r <= (OTHERS => '0');    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
      
         IF (re_i = '1') THEN   
            IF (((conv_std_logic(memraddr_r = conv_std_logic_vector(FULL_READ_DEPTH-1,ceil_log2t(FULL_READ_DEPTH)))) = '1')) THEN   -- SAR#68070
               memraddr_r <= (OTHERS => '0');    
            ELSE
               memraddr_r <= memraddr_r + '1';    
            END IF;
         END IF;
      --END IF;
      END IF;
   END PROCESS;

   memwe_xhdl12 <= we_i;  
   memre_xhdl14 <= re_i;  

   END GENERATE L1;

  L3: IF (ESTOP = 1 AND FSTOP = 0) GENERATE

   -- --------------------------------------------------------------------------
   -- Write pointer Binary counter
   -- --------------------------------------------------------------------------
   
   PROCESS (pos_wclk, reset_wclk)
   BEGIN
      IF (NOT reset_wclk = '1') THEN
         wptr <= (OTHERS => '0');    
         wptr_gray <= (OTHERS => '0');    
      ELSIF (pos_wclk'EVENT AND pos_wclk = '1') THEN
      
         IF (we_p = '1') THEN
            wptr <= wptr + '1';    
            wptr_gray <= (wptr SRL 1) XOR wptr;    
         ELSE
            wptr_gray <= (wptr SRL 1) XOR wptr;    
         END IF;
     -- END IF;
      END IF;
   END PROCESS;

   -- --------------------------------------------------------------------------
   -- Read pointer Binary counter
   -- --------------------------------------------------------------------------
   
   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         rptr <= (OTHERS => '0');    
         rptr_gray <= (OTHERS => '0');    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
      
         IF (re_i = '1') THEN
            rptr <= rptr + '1';    
            rptr_gray <= (rptr SRL 1) XOR rptr;    
         ELSE
            rptr_gray <= (rptr SRL 1) XOR rptr;    
         END IF;
      --END IF;
      END IF;
   END PROCESS;

   -- Generation of empty, almost empty, read data valid flags and read count on read clock
   
   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         empty_r <= '1';    
         aempty_r <= '1';    
         dvld_r <= '0';    
         rdcnt_r <= (OTHERS => '0');    
         underflow_r <= '0';    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
     
	      IF((conv_std_logic(rdiff_bus = conv_std_logic_vector(1,READ_DEPTH+1))) = '1') THEN
		 IF(re_p = '1') THEN
  	           empty_r <= '1';
	         ELSE 
  	           empty_r <= '0';
	         END IF;
	       ELSE
                 empty_r <= emptyi; 
	       END IF; 
         aempty_r <= almostemptyi;    
         IF (RDCNT_EN = 1) THEN
            rdcnt_r <= rdiff_bus;    
         ELSE
            rdcnt_r <= rdcnt_r;    
         END IF;
         IF (re_i = '1' AND READ_DVALID = 1) THEN
            dvld_r <= '1';    
         ELSE
            dvld_r <= '0';    
         END IF;
         IF ((re_p = '1' AND empty_r = '1') AND UNDERFLOW_EN = 1) THEN
            underflow_r <= '1';    
         ELSE
            underflow_r <= '0';    
         END IF;
      --END IF;
      END IF;
   END PROCESS;

   -- Generation of full, almost full, write acknowledge flags and write count on write clock
   
   PROCESS (pos_wclk, reset_wclk)
   BEGIN
      IF (NOT reset_wclk = '1') THEN
         full_r <= '0';    
         afull_r <= '0';    
         wack_r <= '0';    
         wrcnt_r <= (OTHERS => '0');    
         overflow_r <= '0';    
      ELSIF (pos_wclk'EVENT AND pos_wclk = '1') THEN
      
         full_r <= fulli_fstop;     
         afull_r <= almostfulli;    
         IF (we_p = '1' AND WRITE_ACK = 1) THEN
            wack_r <= '1';    
         ELSE
            wack_r <= '0';    
         END IF;
         IF (WRCNT_EN = 1) THEN
            wrcnt_r <= wdiff_bus;    
         ELSE
            wrcnt_r <= wrcnt_r;    
         END IF;
         IF ((we_p = '1' AND full_r = '1') AND OVERFLOW_EN = 1) THEN
            overflow_r <= '1';    
         ELSE
            overflow_r <= '0';    
         END IF;
      --END IF;
      END IF;
   END PROCESS;

   -- Generation of write address to external memory
   PROCESS (pos_wclk, reset_wclk)
   BEGIN
      IF (NOT reset_wclk = '1') THEN
         memwaddr_r <= (OTHERS => '0');    
      ELSIF (pos_wclk'EVENT AND pos_wclk = '1') THEN
      
         IF (we_p = '1') THEN
            IF (((conv_std_logic(memwaddr_r = conv_std_logic_vector(FULL_WRITE_DEPTH-1,ceil_log2t(FULL_WRITE_DEPTH)))) = '1')) THEN   -- SAR#68070
               memwaddr_r <= (OTHERS => '0');    
            ELSE
               memwaddr_r <= memwaddr_r + '1';    
            END IF;
         END IF;
      --END IF;
      END IF;
   END PROCESS;

   -- Generation of read address to external memory
   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         memraddr_r <= (OTHERS => '0');    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
      
         IF (re_i = '1') THEN    
            IF (((conv_std_logic(memraddr_r = conv_std_logic_vector(FULL_READ_DEPTH-1,ceil_log2t(FULL_READ_DEPTH)))) = '1')) THEN   -- SAR#68070
               memraddr_r <= (OTHERS => '0');    
            ELSE
               memraddr_r <= memraddr_r + '1';    
            END IF;
         END IF;
     -- END IF;
      END IF;
   END PROCESS;

   memwe_xhdl12 <= we_p ;  
   memre_xhdl14 <= re_i;  

  END GENERATE L3;

  L5: IF (ESTOP = 0 AND FSTOP = 1) GENERATE
   -- --------------------------------------------------------------------------
   -- Write pointer Binary counter
   -- --------------------------------------------------------------------------
   
   PROCESS (pos_wclk, reset_wclk)
   BEGIN
      IF (NOT reset_wclk = '1') THEN
         wptr <= (OTHERS => '0');    
         wptr_gray <= (OTHERS => '0');    
      ELSIF (pos_wclk'EVENT AND pos_wclk = '1') THEN
     
         IF (we_i = '1') THEN
            wptr <= wptr + '1';    
            wptr_gray <= (wptr SRL 1) XOR wptr;    
         ELSE
            wptr_gray <= (wptr SRL 1) XOR wptr;    
         END IF;
      --END IF;
      END IF;
   END PROCESS;

   -- --------------------------------------------------------------------------
   -- Read pointer Binary counter
   -- --------------------------------------------------------------------------
   
   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         rptr <= (OTHERS => '0');    
         rptr_gray <= (OTHERS => '0');    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
      
         IF (re_p = '1') THEN
            rptr <= rptr + '1';    
            rptr_gray <= (rptr SRL 1) XOR rptr;    
         ELSE
            rptr_gray <= (rptr SRL 1) XOR rptr;    
         END IF;
     -- END IF;
      END IF;
   END PROCESS;

   -- Generation of empty, almost empty, read data valid flags and read count on read clock
   
   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         empty_r <= '1';    
         aempty_r <= '1';    
         dvld_r <= '0';    
         rdcnt_r <= (OTHERS => '0');    
         underflow_r <= '0';    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
      
         empty_r <= emptyi_estop;    
         aempty_r <= almostemptyi;    
         IF (RDCNT_EN = 1) THEN
            rdcnt_r <= rdiff_bus;    
         ELSE
            rdcnt_r <= rdcnt_r;    
         END IF;
         IF (re_p = '1' AND READ_DVALID = 1) THEN
            dvld_r <= '1';    
         ELSE
            dvld_r <= '0';    
         END IF;
         IF ((re_p = '1' AND empty_r = '1') AND UNDERFLOW_EN = 1) THEN
            underflow_r <= '1';    
         ELSE
            underflow_r <= '0';    
         END IF;
     -- END IF;
      END IF;
   END PROCESS;

   -- Generation of full, almost full, write acknowledge flags and write count on write clock
   
   PROCESS (pos_wclk, reset_wclk)
   BEGIN
      IF (NOT reset_wclk = '1') THEN
         full_r <= '0';    
         afull_r <= '0';    
         wack_r <= '0';    
         wrcnt_r <= (OTHERS => '0');    
         overflow_r <= '0';    
      ELSIF (pos_wclk'EVENT AND pos_wclk = '1') THEN
      
         full_r <= fulli;    
         afull_r <= almostfulli;    
         
         IF (WRCNT_EN = 1) THEN
            wrcnt_r <= wdiff_bus;    
         ELSE
            wrcnt_r <= wrcnt_r;    
         END IF;
         IF (we_i = '1' AND WRITE_ACK = 1) THEN
            wack_r <= '1';    
         ELSE
            wack_r <= '0';    
         END IF;
         IF ((we_p = '1' AND full_r = '1') AND OVERFLOW_EN = 1) THEN
            overflow_r <= '1';    
         ELSE
            overflow_r <= '0';    
         END IF;
     -- END IF;
      END IF;
   END PROCESS;

   -- Generation of write address to external memory
   
   PROCESS (pos_wclk, reset_wclk)
   BEGIN
      IF (NOT reset_wclk = '1') THEN
         memwaddr_r <= (OTHERS => '0');    
      ELSIF (pos_wclk'EVENT AND pos_wclk = '1') THEN
      
         IF (we_i = '1') THEN     
            IF (((conv_std_logic(memwaddr_r = conv_std_logic_vector(FULL_WRITE_DEPTH-1,ceil_log2t(FULL_WRITE_DEPTH)))) = '1')) THEN   -- SAR#68070
               memwaddr_r <= (OTHERS => '0');    
            ELSE
               memwaddr_r <= memwaddr_r + '1';    
            END IF;
         END IF;
      --END IF;
      END IF;
   END PROCESS;

   -- Generation of read address to external memory
   
   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         memraddr_r <= (OTHERS => '0');    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
      
         IF (re_p = '1') THEN
            IF (((conv_std_logic(memraddr_r = conv_std_logic_vector(FULL_READ_DEPTH-1,ceil_log2t(FULL_READ_DEPTH)))) = '1')) THEN   -- SAR#68070
               memraddr_r <= (OTHERS => '0');    
            ELSE
               memraddr_r <= memraddr_r + '1';    
            END IF;
         END IF;
     --END IF;
      END IF;
   END PROCESS;
   memwe_xhdl12 <= we_i ; 
   memre_xhdl14 <= re_p;  

   END GENERATE L5;
         
            
   L7: IF (ESTOP = 0 AND FSTOP = 0) GENERATE
   -- --------------------------------------------------------------------------
   -- Write pointer Binary counter
   -- --------------------------------------------------------------------------
   
   PROCESS (pos_wclk, reset_wclk)
   BEGIN
      IF (NOT reset_wclk = '1') THEN
         wptr <= (OTHERS => '0');    
         wptr_gray <= (OTHERS => '0');    
      ELSIF (pos_wclk'EVENT AND pos_wclk = '1') THEN
     
         IF (we_p = '1') THEN
            wptr <= wptr + '1';    
            wptr_gray <= (wptr SRL 1) XOR wptr;    
         ELSE
            wptr_gray <= (wptr SRL 1) XOR wptr;    
         END IF;
      --END IF;
      END IF;
   END PROCESS;

   -- --------------------------------------------------------------------------
   -- Read pointer Binary counter
   -- --------------------------------------------------------------------------
   
   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         rptr <= (OTHERS => '0');    
         rptr_gray <= (OTHERS => '0');    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
     
         IF (re_p = '1') THEN
            rptr <= rptr + '1';    
            rptr_gray <= (rptr SRL 1) XOR rptr;    
         ELSE
            rptr_gray <= (rptr SRL 1) XOR rptr;    
         END IF;
     -- END IF;
      END IF;
   END PROCESS;

   -- Generation of empty, almost empty, read data valid flags and read count on read clock
   
   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         empty_r <= '1';    
         aempty_r <= '1';    
         dvld_r <= '0';    
         rdcnt_r <= (OTHERS => '0');    
         underflow_r <= '0';    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
      
         empty_r <= emptyi_estop;    
         aempty_r <= almostemptyi;    
         IF (RDCNT_EN = 1) THEN
            rdcnt_r <= rdiff_bus;    
         ELSE
            rdcnt_r <= rdcnt_r;    
         END IF;
         IF (re_p = '1' AND READ_DVALID = 1) THEN
            dvld_r <= '1';    
         ELSE
            dvld_r <= '0';    
         END IF;
         IF ((re_p = '1' AND empty_r = '1') AND UNDERFLOW_EN = 1) THEN
            underflow_r <= '1';    
         ELSE
            underflow_r <= '0';    
         END IF;
     -- END IF;
      END IF;
   END PROCESS;

   -- Generation of full, almost full, write acknowledge flags and write count on write clock
   PROCESS (pos_wclk, reset_wclk)
   BEGIN
      IF (NOT reset_wclk = '1') THEN
         full_r <= '0';    
         afull_r <= '0';    
         wack_r <= '0';    
         wrcnt_r <= (OTHERS => '0');    
         overflow_r <= '0';    
      ELSIF (pos_wclk'EVENT AND pos_wclk = '1') THEN
     
         full_r <= fulli_fstop;   
         afull_r <= almostfulli;    
         IF (WRCNT_EN = 1) THEN
            wrcnt_r <= wdiff_bus;    
         ELSE
            wrcnt_r <= wrcnt_r;    
         END IF;
         IF (we_p = '1' AND WRITE_ACK = 1) THEN
            wack_r <= '1';    
         ELSE
            wack_r <= '0';    
         END IF;
         IF ((we_p = '1' AND full_r = '1') AND OVERFLOW_EN = 1) THEN
            overflow_r <= '1';    
         ELSE
            overflow_r <= '0';    
         END IF;
      --END IF;
      END IF;
   END PROCESS;

   -- Generation of write address to external memory
   
   PROCESS (pos_wclk, reset_wclk)
   BEGIN
      IF (NOT reset_wclk = '1') THEN
         memwaddr_r <= (OTHERS => '0');    
      ELSIF (pos_wclk'EVENT AND pos_wclk = '1') THEN
     
         IF (we_p = '1') THEN
            IF (((conv_std_logic(memwaddr_r = conv_std_logic_vector(FULL_WRITE_DEPTH-1,ceil_log2t(FULL_WRITE_DEPTH)))) = '1')) THEN   -- SAR#68070
               memwaddr_r <= (OTHERS => '0');    
            ELSE
               memwaddr_r <= memwaddr_r + '1';    
            END IF;
         END IF;
     -- END IF;
      END IF;
   END PROCESS;

   -- Generation of read address to external memory
   
   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF (NOT reset_rclk = '1') THEN
         memraddr_r <= (OTHERS => '0');    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
      
         IF (re_p = '1') THEN
            IF (((conv_std_logic(memraddr_r = conv_std_logic_vector(FULL_READ_DEPTH-1,ceil_log2t(FULL_READ_DEPTH)))) = '1')) THEN   -- SAR#68070
               memraddr_r <= (OTHERS => '0');    
            ELSE
               memraddr_r <= memraddr_r + '1';    
            END IF;
         END IF;
     -- END IF;
      END IF;
   END PROCESS;
   memwe_xhdl12 <= we_p ;    
   memre_xhdl14 <= re_p;  


   END GENERATE L7;

END ARCHITECTURE translated;
