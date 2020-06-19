-- ********************************************************************/
-- Actel Corporation Proprietary and Confidential
--  Copyright 2011 Actel Corporation.  All rights reserved.
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
-- IN ADVANCE IN WRITING.
--
-- Description:  fifocore_sync.v
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

ENTITY COREFIFO_C0_COREFIFO_C0_0_corefifo_sync IS
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
      PIPE                           :  integer := 1;    
     -- SYNC_RESET                     :  integer := 1;    
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
      -- --------------------------------------------------------------------------
-- I/O Declaration
-- --------------------------------------------------------------------------
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
      memre                   : OUT std_logic);   --  memory read enable
END ENTITY COREFIFO_C0_COREFIFO_C0_0_corefifo_sync;

ARCHITECTURE translated OF COREFIFO_C0_COREFIFO_C0_0_corefifo_sync IS


   -- --------------------------------------------------------------------------
   -- Internal signals
   -- --------------------------------------------------------------------------
   SIGNAL full_r                   :  std_logic;   
   SIGNAL full_reg                 :  std_logic;   
   SIGNAL afull_r                  :  std_logic;   
   SIGNAL wrcnt_r                  :  std_logic_vector(WRITE_DEPTH DOWNTO 0);   
   SIGNAL empty_r                  :  std_logic;   
   SIGNAL aempty_r                 :  std_logic;   
   SIGNAL rdcnt_r                  :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL memwaddr_r               :  std_logic_vector(ceil_log2t(FULL_WRITE_DEPTH) - 1 DOWNTO 0);
   SIGNAL memraddr_r               :  std_logic_vector(ceil_log2t(FULL_READ_DEPTH) - 1 DOWNTO 0);
   SIGNAL dvld_r                   :  std_logic;   
   SIGNAL dvld_r2                  :  std_logic;   
   SIGNAL underflow_r              :  std_logic;   
   SIGNAL wack_r                   :  std_logic;   
   SIGNAL overflow_r               :  std_logic;   
   SIGNAL rptr                     :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL rptr_nxt                 :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL wptr                     :  std_logic_vector(WRITE_DEPTH DOWNTO 0);   
   SIGNAL wptr_nxt                 :  std_logic_vector(WRITE_DEPTH DOWNTO 0);   
   SIGNAL afthreshi                :  std_logic_vector(WRITE_DEPTH DOWNTO 0);   
   SIGNAL wdiff_bus                :  std_logic_vector(WRITE_DEPTH DOWNTO 0);   
   SIGNAL aethreshi                :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL rdiff_bus                :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL fulli                    :  std_logic;   
   SIGNAL fulli_int                :  std_logic;   
   SIGNAL almostfulli              :  std_logic;   
   SIGNAL emptyi                   :  std_logic;   
   SIGNAL temp_empty_int                   :  std_logic;   
   SIGNAL almostemptyi             :  std_logic;   
   SIGNAL wptrsync_shift           :  std_logic_vector(VAR_ASPECT_WRDEPTH DOWNTO 0);   
   SIGNAL rptrsync_shift           :  std_logic_vector(VAR_ASPECT_RDDEPTH DOWNTO 0);      
   SIGNAL we_p                     :  std_logic;   
   SIGNAL re_p                     :  std_logic;   
   SIGNAL we_i                     :  std_logic;   
   SIGNAL re_i                     :  std_logic;   
   SIGNAL pos_clk                  :  std_logic;   
   SIGNAL neg_reset                :  std_logic;   
   SIGNAL temp_xhdl15              :  std_logic;   
   -- threshold values 
   SIGNAL temp_xhdl16              :  integer;   
   SIGNAL temp_xhdl17              :  integer;   
   -- clock and enables 
   SIGNAL temp_xhdl18              :  std_logic;   
   SIGNAL temp_xhdl19              :  std_logic;   
   -- Status flags 
   SIGNAL temp_xhdl20              :  std_logic;   
   SIGNAL temp_xhdl21              :  std_logic;   
   SIGNAL full_xhdl1               :  std_logic;   
   SIGNAL afull_xhdl2              :  std_logic;   
   SIGNAL almostfulli_assert       :  std_logic;
   SIGNAL almostfulli_deassert     :  std_logic;
   SIGNAL almostfulli_deassert_sig :  std_logic;
   SIGNAL almostemptyi_assert      :  std_logic;
   SIGNAL almostemptyi_deassert    :  std_logic;
   SIGNAL almostemptyi_assert_sig  :  std_logic;
   SIGNAL wrcnt_xhdl3              :  std_logic_vector(WRITE_DEPTH DOWNTO 0);   
   SIGNAL empty_xhdl4              :  std_logic;   
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
   SIGNAL fulli_fstop              :  std_logic;  
   SIGNAL fulli_fstop_sig         :  std_logic;  
   SIGNAL emptyi_estop             :  std_logic; 
   SIGNAL re_p_d1                  :  std_logic;   
   SIGNAL aresetn                  :  std_logic;   
   --SIGNAL sresetn                  :  std_logic; 
    	

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

  FUNCTION to_integer (
      val      : std_logic_vector) RETURN integer IS

      CONSTANT vec      : std_logic_vector(val'high-val'low DOWNTO 0) := val;      
      VARIABLE rtn      : integer := 0;
   BEGIN
      FOR index IN vec'RANGE LOOP
         IF (vec(index) = '1') THEN
            rtn := rtn + (2**index);
         END IF;
      END LOOP;
      RETURN(rtn);
   END to_integer;

   FUNCTION to_stdlogicvector (
      val      : IN integer;
      len      : IN integer) RETURN std_logic_vector IS
      
      VARIABLE rtn  : std_logic_vector(len-1 DOWNTO 0) := (OTHERS => '0');
      VARIABLE num  : integer := val;
      VARIABLE r    : integer;
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
   full <= full_xhdl1;
   afull <= afull_xhdl2;
   wrcnt <= wrcnt_xhdl3;
   empty <= empty_xhdl4;
   aempty <= aempty_xhdl5;
   rdcnt <= rdcnt_xhdl6;
   underflow <= underflow_xhdl7;
   overflow <= overflow_xhdl8;
   dvld <= dvld_xhdl9;
   wack <= wack_xhdl10;
   memwaddr <= memwaddr_xhdl11;
   memwe <= memwe_xhdl12;
   memraddr <= memraddr_xhdl13;
   memre <= memre_xhdl14;

   -- output port mapping 
   full_xhdl1 <= full_r ;
   afull_xhdl2 <= afull_r ;
   empty_xhdl4 <= empty_r ;
   aempty_xhdl5 <= aempty_r ;
   underflow_xhdl7 <= underflow_r ;
   wack_xhdl10 <= wack_r ;
   overflow_xhdl8 <= overflow_r ;
   memwaddr_xhdl11 <= memwaddr_r ;
   memraddr_xhdl13 <= memraddr_r ;
   wrcnt_xhdl3 <= wrcnt_r ;
   rdcnt_xhdl6 <= rdcnt_r ;
   temp_xhdl16 <= (AFULL_VAL - 1) WHEN AF_FLAG_STATIC = 1 ELSE FULL_WRITE_DEPTH;          
   afthreshi <= conv_std_logic_vector(temp_xhdl16, WRITE_DEPTH+1) ;
   --AHK temp_xhdl17 <= (AEMPTY_VAL+1) WHEN AE_FLAG_STATIC = 1 ELSE 0;   
   temp_xhdl17 <= (AEMPTY_VAL) WHEN AE_FLAG_STATIC = 1 ELSE 2;   
   aethreshi <= conv_std_logic_vector(temp_xhdl17, READ_DEPTH+1) ;
   temp_xhdl18 <= clk WHEN WCLK_HIGH /= 0 ELSE NOT clk;
   pos_clk <= temp_xhdl18 ;
   temp_xhdl19 <= NOT reset WHEN RESET_LOW /= 0 ELSE reset;
   neg_reset <= temp_xhdl19 ;
   aresetn   <=  neg_reset;
   --sresetn   <= neg_reset WHEN (SYNC_RESET = 1) ELSE '1';

   temp_xhdl20 <= (NOT we) WHEN WRITE_LOW /= 0 ELSE (we);
   we_p <= temp_xhdl20 ;
   temp_xhdl21 <= (NOT re) WHEN READ_LOW /= 0 ELSE (re);
   re_p <= temp_xhdl21 ;
   we_i <= we_p AND NOT full_r ;
   re_i <= re_p AND NOT empty_r ;

   PROCESS (rptrsync_shift, wptr_nxt, wptrsync_shift, rptr_nxt)
   BEGIN
      IF (WRITE_DEPTH > READ_DEPTH) THEN
         wdiff_bus <= wptr_nxt - rptrsync_shift ;   
         rdiff_bus <= wptrsync_shift((VAR_ASPECT_WRDEPTH - (WRITE_DEPTH - READ_DEPTH)) downto 0) - rptr_nxt ;
      ELSE
         IF (READ_DEPTH > WRITE_DEPTH) THEN
           wdiff_bus <= wptr_nxt - rptrsync_shift((VAR_ASPECT_RDDEPTH - (READ_DEPTH-WRITE_DEPTH)) downto 0);   
           rdiff_bus <= wptrsync_shift - rptr_nxt ;
         ELSE
           wdiff_bus <= wptr_nxt - rptrsync_shift ;   
           rdiff_bus <= wptrsync_shift - rptr_nxt ;
         END IF;
      END IF;
   END PROCESS;

   dvld_xhdl9_int <= dvld_r WHEN (REGISTER_RADDR = 1 AND PREFETCH = 0) ELSE re_i;
   dvld_xhdl9 <= dvld_r2 WHEN (REGISTER_RADDR = 2) ELSE dvld_xhdl9_int;

   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         full_reg <= '0';    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
         
            full_reg <= full_r;    
      --END IF;
      END IF;
   END PROCESS;

   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         re_p_d1 <= '0';    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
         
            re_p_d1 <= re_p;    
     -- END IF;
      END IF;
   END PROCESS;

   -- --------------------------------------------------------------------------
   -- Read pointer binary counter
   -- --------------------------------------------------------------------------
   
   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         rptr <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
        
            rptr <= rptr_nxt;    
      --END IF;
      END IF;
   END PROCESS;

   -- --------------------------------------------------------------------------
   -- Write pointer binary counter
   -- --------------------------------------------------------------------------
   
   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         wptr <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
        
            wptr <= wptr_nxt;    
     -- END IF;
      END IF;
   END PROCESS;

   -- --------------------------------------------------------------------------
   -- For variable aspect ratios
   -- The variable aspect logic is handled by shifting the required bits of the
   -- read/write pointer so that they are of the same width.  
   -- --------------------------------------------------------------------------    
   
   PROCESS (rptr_nxt, wptr_nxt)
   BEGIN
      IF (WRITE_DEPTH > READ_DEPTH) THEN
         rptrsync_shift <= ((conv_std_logic_vector(0,WRITE_DEPTH - READ_DEPTH) & rptr_nxt) SLL (WRITE_DEPTH - READ_DEPTH));    
         wptrsync_shift <= (wptr_nxt SRL (WRITE_DEPTH - READ_DEPTH));    
      ELSE
         IF (READ_DEPTH > WRITE_DEPTH) THEN
            rptrsync_shift <= (rptr_nxt SRL (READ_DEPTH-WRITE_DEPTH));    
            wptrsync_shift <= ((conv_std_logic_vector(0,READ_DEPTH- WRITE_DEPTH) & wptr_nxt) SLL (READ_DEPTH-WRITE_DEPTH));    
         ELSE
            rptrsync_shift <= (rptr_nxt);    
            wptrsync_shift <= (wptr_nxt);    
         END IF;
      END IF;
   END PROCESS;

   --AHK almostfulli <= conv_std_logic(wdiff_bus >= afthreshi) ;
   --AHK almostemptyi <= conv_std_logic(aethreshi >= rdiff_bus) ;

   almostfulli_assert       <=  conv_std_logic(wdiff_bus >= afthreshi) AND we_p;
   almostfulli_deassert     <=  conv_std_logic(wdiff_bus <= afthreshi);
   almostfulli_deassert_sig <= '0' WHEN almostfulli_deassert = '1' ELSE afull_xhdl2 ;
   almostfulli              <= '1' WHEN almostfulli_assert = '1' ELSE almostfulli_deassert_sig ;
   
   almostemptyi_assert      <=  conv_std_logic(aethreshi >= rdiff_bus) AND re_p;
   almostemptyi_deassert    <=  conv_std_logic(aethreshi <= rdiff_bus) AND aempty_xhdl5;  
   almostemptyi_assert_sig   <=  '1' WHEN almostemptyi_assert = '1' ELSE aempty_xhdl5;
   almostemptyi             <=  '0' WHEN almostemptyi_deassert = '1' ELSE almostemptyi_assert_sig ;



   fulli <= conv_std_logic(wdiff_bus >= conv_std_logic_vector((FULL_WRITE_DEPTH - 1), WRITE_DEPTH+1)) WHEN temp_xhdl20 = '1' ELSE   conv_std_logic(wdiff_bus >= conv_std_logic_vector((FULL_WRITE_DEPTH), WRITE_DEPTH+1)); 

   --fulli_fstop <= conv_std_logic(wdiff_bus(WRITE_DEPTH-1 DOWNTO 0) >= conv_std_logic_vector((FULL_WRITE_DEPTH - 1), WRITE_DEPTH)) WHEN temp_xhdl20 = '1' ELSE   conv_std_logic(wdiff_bus(WRITE_DEPTH-1 DOWNTO 0) >= conv_std_logic_vector((FULL_WRITE_DEPTH), WRITE_DEPTH+1)); 
   fulli_fstop_sig <= '0' WHEN ((we_p XOR re_p) AND full_r) = '1' ELSE full_r;
   fulli_fstop  <= conv_std_logic(wdiff_bus(WRITE_DEPTH - 1 DOWNTO 0) = conv_std_logic_vector(FULL_WRITE_DEPTH-1, WRITE_DEPTH)) WHEN (we_p AND NOT(full_r)) = '1' ELSE fulli_fstop_sig;      -- Nov 6

   temp_empty_int <= conv_std_logic(rdiff_bus = conv_std_logic_vector(1,READ_DEPTH+1))  WHEN (temp_xhdl21 = '1') ELSE conv_std_logic((rdiff_bus) <= 0);  

   emptyi <=  conv_std_logic((rdiff_bus) <= 1); 

   emptyi_estop <= temp_empty_int;  

   fulli_int <= fulli WHEN (FSTOP = 1) ELSE fulli_fstop;  

   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         dvld_r2 <= '0';    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
         
            dvld_r2 <= dvld_r;    
      --END IF;
      END IF;
   END PROCESS;
   
   L1: IF (ESTOP = 1 AND FSTOP = 1) GENERATE

   -- --------------------------------------------------------------------------    
   -- Update the pointer values based in ESTOP and FSTOP parameters.
   -- Generate the status flags - Empty/Full/Almost Empty/ Almost Full
   -- Generate the data handshaking flags - DVLD/WACK
   -- Generate error count flags - Underflow/Overflow
   -- Generate write and read address signals to the external memory
   -- --------------------------------------------------------------------------    
   
   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         wptr_nxt <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
        
         IF (we_i = '1') THEN
            wptr_nxt <= wptr_nxt + '1';    
         END IF;
         --END IF;
      END IF;
   END PROCESS;

   
   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         rptr_nxt <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
         
         IF (re_i = '1') THEN
            rptr_nxt <= rptr_nxt + '1';    
         END IF;
      --END IF;
      END IF;
   END PROCESS;

   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         empty_r <= '1';    
         aempty_r <= '1';    
         dvld_r <= '0';    
         underflow_r <= '0';    
         rdcnt_r <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
         
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
   

   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         full_r <= '0';    
         afull_r <= '0';    
         wack_r <= '0';    
         overflow_r <= '0';    
         wrcnt_r <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
        
         full_r <= fulli_int;    

         afull_r <= almostfulli;    
         IF (full_r = '0' AND WRCNT_EN = 1) THEN
            wrcnt_r <= wdiff_bus;    
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
       --  END IF;
      END IF;
   END PROCESS;

   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         memwaddr_r <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
         
         IF (we_i = '1') THEN
            IF (((conv_std_logic(memwaddr_r = conv_std_logic_vector(FULL_WRITE_DEPTH-1,ceil_log2t(FULL_WRITE_DEPTH)))) = '1')) THEN   -- SAR#68070
               memwaddr_r <= (OTHERS => '0');    
            ELSE
               memwaddr_r <= memwaddr_r + '1';    
            END IF;
         END IF;
      END IF;
      --END IF;
   END PROCESS;

   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         memraddr_r <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
         
         IF (re_i = '1') THEN
            IF (((conv_std_logic(memraddr_r = conv_std_logic_vector(FULL_READ_DEPTH-1,ceil_log2t(FULL_READ_DEPTH)))) = '1')) THEN   -- SAR#68070
               memraddr_r <= (OTHERS => '0');    
            ELSE
               memraddr_r <= memraddr_r + '1';    
	    END IF;
         END IF;
      END IF;
     -- END IF;
   END PROCESS;
   memwe_xhdl12 <= we_i ;
   memre_xhdl14 <= re_i;  
   
   END GENERATE L1;
   
   L2: IF (ESTOP = 1 AND FSTOP = 0) GENERATE
   -- ESTOP is true and FSTOP is false 
   
   -- write pointer 
   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         wptr_nxt <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
        
         IF (we_p = '1') THEN
            wptr_nxt <= wptr_nxt + '1';    
         END IF;
      END IF;
      --END IF;
   END PROCESS;

   -- read pointer 
   
   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         rptr_nxt <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
        
         IF (re_i = '1') THEN
            rptr_nxt <= rptr_nxt + '1';    
         END IF;
      END IF;
     -- END IF;
   END PROCESS;

   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         empty_r <= '1';    
         aempty_r <= '1';    
         dvld_r <= '0';    
         underflow_r <= '0';    
         rdcnt_r <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
        
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
         END IF;
         IF (re_i = '1' AND READ_DVALID = 2#1#) THEN
            dvld_r <= '1';    
         ELSE
            dvld_r <= '0';    
         END IF;
         IF ((re_p = '1' AND empty_r = '1') AND UNDERFLOW_EN = 1) THEN
            underflow_r <= '1';    
         ELSE
            underflow_r <= '0';    
         END IF;
      END IF;
     -- END IF;
   END PROCESS;

   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         full_r <= '0';    
         afull_r <= '0';    
         wack_r <= '0';    
         overflow_r <= '0';    
         wrcnt_r <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
        
         full_r <= fulli_fstop;      
         afull_r <= almostfulli;    
         IF (WRCNT_EN = 1) THEN
            wrcnt_r <= wdiff_bus;    
         END IF;
         IF (we_p = '1' AND WRITE_ACK = 2#1#) THEN
            wack_r <= '1';    
         ELSE
            wack_r <= '0';    
         END IF;
         IF ((we_p = '1' AND full_r = '1') AND OVERFLOW_EN = 1) THEN
            overflow_r <= '1';    
         ELSE
            overflow_r <= '0';    
         END IF;
      END IF;
     -- END IF;
   END PROCESS;

   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         memwaddr_r <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
         
         IF (we_p = '1') THEN
            IF (((conv_std_logic(memwaddr_r = conv_std_logic_vector(FULL_WRITE_DEPTH-1,ceil_log2t(FULL_WRITE_DEPTH)))) = '1')) THEN   -- SAR#68070
               memwaddr_r <= (OTHERS => '0');    
            ELSE
               memwaddr_r <= memwaddr_r + '1';    
            END IF;
         END IF;
      END IF;
     -- END IF;
   END PROCESS;

   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         memraddr_r <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
         
         IF (re_i = '1') THEN
            IF (((conv_std_logic(memraddr_r = conv_std_logic_vector(FULL_READ_DEPTH-1,ceil_log2t(FULL_READ_DEPTH)))) = '1')) THEN   -- SAR#68070
               memraddr_r <= (OTHERS => '0');    
            ELSE
               memraddr_r <= memraddr_r + '1';    
	    END IF;
         END IF;
      END IF;
     -- END IF;
   END PROCESS;
   memwe_xhdl12 <= we_p ;
   memre_xhdl14 <= re_i;  

   END GENERATE L2;
      
         
   L3: IF (ESTOP = 0 AND FSTOP = 1) GENERATE
   -- FSTOP is true and ESTOP is false 
   
   -- write pointer
   
   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         wptr_nxt <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
        
         IF (we_i = '1') THEN
            wptr_nxt <= wptr_nxt + '1';    
         END IF;
      --END IF;
      END IF;
   END PROCESS;

   -- read pointer 
   
   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         rptr_nxt <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
         
         IF (re_p = '1') THEN
            rptr_nxt <= rptr_nxt + '1';    
         END IF;
     -- END IF;
      END IF;
   END PROCESS;

   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         empty_r <= '1';    
         aempty_r <= '1';    
         dvld_r <= '0';    
         underflow_r <= '0';    
         rdcnt_r <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
        
         empty_r <= emptyi_estop;     
         aempty_r <= almostemptyi;    
         IF (RDCNT_EN = 1) THEN
            rdcnt_r <= rdiff_bus;    
         END IF;
         IF (re_p = '1' AND READ_DVALID = 2#1#) THEN
            dvld_r <= '1';    
         ELSE
            dvld_r <= '0';    
         END IF;
         IF ((re_p = '1' AND empty_r = '1') AND UNDERFLOW_EN = 1) THEN
            underflow_r <= '1';    
         ELSE
            underflow_r <= '0';    
         END IF;
      END IF;
      --END IF;
   END PROCESS;

   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         full_r <= '0';    
         afull_r <= '0';    
         wack_r <= '0';    
         overflow_r <= '0';    
         wrcnt_r <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
         
         full_r <= fulli;    
         afull_r <= almostfulli;    
         IF (full_r = '0' AND WRCNT_EN = 1) THEN
            wrcnt_r <= wdiff_bus;    
         END IF;
         IF (we_i = '1' AND WRITE_ACK = 2#1#) THEN
            wack_r <= '1';    
         ELSE
            wack_r <= '0';    
         END IF;
         IF ((we_p = '1' AND full_r = '1') AND OVERFLOW_EN = 1) THEN
            overflow_r <= '1';    
         ELSE
            overflow_r <= '0';    
         END IF;
      END IF;
      --END IF;
   END PROCESS;

   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         memwaddr_r <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
        
         IF (we_i = '1') THEN
            IF (((conv_std_logic(memwaddr_r = conv_std_logic_vector(FULL_WRITE_DEPTH-1,ceil_log2t(FULL_WRITE_DEPTH)))) = '1')) THEN   -- SAR#68070
               memwaddr_r <= (OTHERS => '0');    
            ELSE
               memwaddr_r <= memwaddr_r + '1';    
            END IF;
         END IF;
      END IF;
      --END IF;
   END PROCESS;

   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         memraddr_r <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
        
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

   END GENERATE L3;
         
            
   L4: IF (ESTOP = 0 AND FSTOP = 0) GENERATE
   -- ESTOP and FSTOP are false 
   
   -- write pointer
   
   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         wptr_nxt <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
        
         IF (we_p = '1') THEN
            wptr_nxt <= wptr_nxt + '1';    
         END IF;
      END IF;
      --END IF;
   END PROCESS;

   -- read pointer 
   
   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         rptr_nxt <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
         
         IF (re_p = '1') THEN
            rptr_nxt <= rptr_nxt + '1';    
         END IF;
      END IF;
     -- END IF;
   END PROCESS;

   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         empty_r <= '1';    
         aempty_r <= '1';    
         dvld_r <= '0';    
         underflow_r <= '0';    
         rdcnt_r <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
        
         empty_r <= emptyi_estop; 
         aempty_r <= almostemptyi;    
         IF (RDCNT_EN = 1) THEN
            rdcnt_r <= rdiff_bus;    
         END IF;
         IF (re_p = '1' AND READ_DVALID = 2#1#) THEN
            dvld_r <= '1';    
         ELSE
            dvld_r <= '0';    
         END IF;
         IF ((re_p = '1' AND empty_r = '1') AND UNDERFLOW_EN = 1) THEN
            underflow_r <= '1';    
         ELSE
            underflow_r <= '0';    
         END IF;
      END IF;
      --END IF;
   END PROCESS;

   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         full_r <= '0';    
         afull_r <= '0';    
         wack_r <= '0';    
         overflow_r <= '0';    
         wrcnt_r <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
         
         full_r <= fulli_fstop;     
         afull_r <= almostfulli;    
         IF (WRCNT_EN = 1) THEN
            wrcnt_r <= wdiff_bus;    
         END IF;
         IF (we_p = '1' AND WRITE_ACK = 2#1#) THEN
            wack_r <= '1';    
         ELSE
            wack_r <= '0';    
         END IF;
         IF ((we_p = '1' AND full_r = '1') AND OVERFLOW_EN = 1) THEN
            overflow_r <= '1';    
         ELSE
            overflow_r <= '0';    
         END IF;
      END IF;
     -- END IF;
   END PROCESS;

   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         memwaddr_r <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
         
         IF (we_p = '1') THEN
            IF (((conv_std_logic(memwaddr_r = conv_std_logic_vector(FULL_WRITE_DEPTH-1,ceil_log2t(FULL_WRITE_DEPTH)))) = '1')) THEN   -- SAR#68070
               memwaddr_r <= (OTHERS => '0');    
            ELSE
               memwaddr_r <= memwaddr_r + '1';    
	    END IF;
         END IF;
      END IF;
      --END IF;
   END PROCESS;

   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         memraddr_r <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
         
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
   memwe_xhdl12 <= we_p ;
   memre_xhdl14 <= re_p;  
   END GENERATE L4;
END ARCHITECTURE translated;
