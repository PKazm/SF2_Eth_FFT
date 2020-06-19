-- ********************************************************************/
-- Actel Corporation Proprietary and Confidential
--  Copyright 2011 Actel Corporation.  All rights reserved.
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
-- IN ADVANCE IN WRITING.
--
-- Description:  fifocore_sync_scntr.v
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

ENTITY COREFIFO_C0_COREFIFO_C0_0_corefifo_sync_scntr IS
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
      WCLK_HIGH                      :  integer := 1;    
      PIPE                           :  integer := 1;
      ECC                            :  integer := 1;	  
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
      READ_DVALID                    :  integer := 1;    
      WRITE_ACK                      :  integer := 1;    
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
      empty_top_fwft          : IN std_logic;  
      memre                   : OUT std_logic);   --  memory read enable
END ENTITY COREFIFO_C0_COREFIFO_C0_0_corefifo_sync_scntr;

ARCHITECTURE translated OF COREFIFO_C0_COREFIFO_C0_0_corefifo_sync_scntr IS


   -- --------------------------------------------------------------------------
   -- Internal signals
   -- --------------------------------------------------------------------------
   SIGNAL full_r                   :  std_logic;   
   SIGNAL full_reg                 :  std_logic;   
   SIGNAL afull_r                  :  std_logic;   
   SIGNAL empty_r                  :  std_logic;   
   SIGNAL empty_r_fwft             :  std_logic;   
   SIGNAL aempty_r_fwft            :  std_logic;   
   SIGNAL aempty_r                 :  std_logic;   
   SIGNAL memwaddr_r               :  std_logic_vector(ceil_log2t(FULL_WRITE_DEPTH) - 1 DOWNTO 0);
   SIGNAL memraddr_r               :  std_logic_vector(ceil_log2t(FULL_READ_DEPTH) - 1 DOWNTO 0);
   SIGNAL dvld_r                   :  std_logic;   
   SIGNAL dvld_r2                  :  std_logic;   
   SIGNAL underflow_r              :  std_logic;   
   SIGNAL wack_r                   :  std_logic;   
   SIGNAL overflow_r               :  std_logic;   
   SIGNAL sc_r                     :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL sc_r_fwft                :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL afthreshi                :  std_logic_vector(WRITE_DEPTH DOWNTO 0);   
   SIGNAL aethreshi                :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL fulli                    :  std_logic;   
   SIGNAL fulli_assert             :  std_logic;   
   SIGNAL fulli_assert_sig         :  std_logic;   
   SIGNAL fulli_deassert           :  std_logic;   
   SIGNAL almostfulli              :  std_logic;   
   SIGNAL almostfulli_assert       :  std_logic;   
   SIGNAL almostfulli_assert_sig   :  std_logic;   
   SIGNAL almostfulli_deassert     :  std_logic;   
   SIGNAL emptyi                   :  std_logic;   
   SIGNAL emptyi_fwft              :  std_logic;   
   SIGNAL almostemptyi             :  std_logic;   
   SIGNAL we_p                     :  std_logic;   
   SIGNAL re_p                     :  std_logic;   
   SIGNAL we_i                     :  std_logic;   
   SIGNAL re_i                     :  std_logic;   
   SIGNAL pos_clk                  :  std_logic;   
   SIGNAL neg_reset                :  std_logic;   
   SIGNAL temp_xhdl15              :  std_logic;   
   SIGNAL temp_xhdl16              :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   SIGNAL temp_xhdl17              :  std_logic_vector(READ_DEPTH DOWNTO 0);   
   -- threshold values 
   SIGNAL temp_xhdl18              :  integer;   
   SIGNAL temp_xhdl19              :  integer;   
   SIGNAL temp_xhdl181             :  integer;   
   SIGNAL temp_xhdl191             :  integer;   
   -- clock and enables 
   SIGNAL temp_xhdl20              :  std_logic;   
   SIGNAL temp_xhdl21              :  std_logic;   
   SIGNAL temp_xhdl22              :  std_logic;   
   SIGNAL temp_xhdl23              :  std_logic;   
   SIGNAL full_xhdl1               :  std_logic;   
   SIGNAL afull_xhdl2              :  std_logic;   
   SIGNAL wrcnt_xhdl3              :  std_logic_vector(WRITE_DEPTH DOWNTO 0);   
   SIGNAL empty_xhdl4              :  std_logic;   
   SIGNAL aempty_xhdl5             :  std_logic;   
   SIGNAL aempty_fwft_xhdl5        :  std_logic;   
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
   SIGNAL re_p_d1                  :  std_logic;   
   SIGNAL aresetn                  :  std_logic;   
   --SIGNAL sresetn                  :  std_logic;   
   SIGNAL re_top_p                 :  std_logic;   
   SIGNAL temp_xhdl22_top          :  std_logic;   
   SIGNAL aempty_fwft              :  std_logic;   
   SIGNAL empty_top_fwft_r         :  std_logic;   
   SIGNAL empty_f                  :  std_logic;---AI
   SIGNAL empty1                  :  std_logic;
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
   full <= full_xhdl1;
   afull <= afull_xhdl2;
   wrcnt <= wrcnt_xhdl3;
   empty <= empty_xhdl4;
   aempty <= aempty_xhdl5;
   aempty_fwft <= aempty_fwft_xhdl5;
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
   aempty_fwft_xhdl5 <= aempty_r ;
   underflow_xhdl7 <= underflow_r ;
   wack_xhdl10 <= wack_r ;
   overflow_xhdl8 <= overflow_r ;
   memwaddr_xhdl11 <= memwaddr_r ;
   memraddr_xhdl13 <= memraddr_r ;
   memwe_xhdl12 <= we_i ;
   memre_xhdl14 <= re_i;  

   -- --------------------------------------------------------------------------
   -- resets
   -- --------------------------------------------------------------------------
   temp_xhdl21 <= NOT reset WHEN RESET_LOW /= 0 ELSE reset;
   neg_reset <= temp_xhdl21 ;
   aresetn   <=  neg_reset;
  -- sresetn   <= neg_reset WHEN (SYNC_RESET = 1) ELSE '1';

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
   -- Write count generation
   -- --------------------------------------------------------------------------
   PROCESS (aresetn, pos_clk)
   BEGIN
      IF (NOT aresetn = '1') THEN
         temp_xhdl16 <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
      
         IF (WRCNT_EN = 1 AND PREFETCH = 0 AND FWFT = 0) THEN
            temp_xhdl16 <= sc_r;    
         ELSIF (WRCNT_EN = 1 AND (PREFETCH = 1 OR FWFT = 1)) THEN
            temp_xhdl16 <= sc_r_fwft;    
     	 ELSE 
            temp_xhdl16 <= (OTHERS => '0');    
         END IF;
      --END IF;
      END IF;
   END PROCESS;

   wrcnt_xhdl3 <= temp_xhdl16 ;

   -- --------------------------------------------------------------------------
   -- Read count generation
   -- --------------------------------------------------------------------------
   PROCESS (aresetn, pos_clk)
   BEGIN
      IF (NOT aresetn = '1') THEN
         temp_xhdl17 <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
     
         IF (RDCNT_EN = 1 AND PREFETCH = 0 AND FWFT = 0) THEN
            temp_xhdl17 <= sc_r;    
         ELSIF (RDCNT_EN = 1 AND (PREFETCH = 1 OR FWFT = 1)) THEN
            temp_xhdl17 <= sc_r_fwft;    
    	 ELSE 
            temp_xhdl17 <= (OTHERS => '0');    
         END IF;
     -- END IF;
      END IF;
   END PROCESS;

   rdcnt_xhdl6 <= temp_xhdl17 ;


   -- --------------------------------------------------------------------------
   -- Clock edge 
   -- --------------------------------------------------------------------------
   temp_xhdl20 <= clk WHEN WCLK_HIGH /= 0 ELSE NOT clk;
   pos_clk <= temp_xhdl20 ;

   -- --------------------------------------------------------------------------
   -- Read and Write enables
   -- --------------------------------------------------------------------------
   T1: IF (FWFT = 0 AND PREFETCH = 0) GENERATE
       temp_xhdl22 <= (NOT we) WHEN WRITE_LOW /= 0 ELSE (we);
       we_p <= temp_xhdl22 ;
       temp_xhdl23 <= (NOT re) WHEN READ_LOW /= 0 ELSE (re);
       re_p <= temp_xhdl23 ;
   END GENERATE T1;

   T2: IF ((FWFT = 1 OR PREFETCH = 1) AND PIPE = 1) GENERATE
       temp_xhdl22 <= (NOT we) WHEN WRITE_LOW /= 0 ELSE (we);
       we_p <= temp_xhdl22 ;
       re_p <= re ;
       temp_xhdl22_top <= (NOT re_top) WHEN READ_LOW /= 0 ELSE (re_top);
       re_top_p <= temp_xhdl22_top ;
   END GENERATE T2;

   we_i <= we_p AND NOT full_r ;
   re_i <= re_p AND NOT empty_r ;
   dvld_xhdl9_int <= dvld_r WHEN (REGISTER_RADDR = 1 AND PREFETCH = 0) ELSE re_i;
   dvld_xhdl9     <= dvld_r2 WHEN (REGISTER_RADDR = 2) ELSE dvld_xhdl9_int;


   -------------------------------
   -- FOR ECC PIPED and PIPED 
   -- 
   ----------------------------------
    P1: IF (ECC = 1 AND PIPE = 2 ) GENERATE
   
      -- emptyi <= ((sc_r = 1) AND re_i );
       emptyi <= (conv_std_logic(to_integer(sc_r) <= 1) ) AND re_i;

       PROCESS (aresetn, pos_clk)
       BEGIN
         IF (NOT aresetn = '1') THEN
         empty_f <=  '1';    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
     
		   IF( (re_i XOR we_i) = '1') THEN
		     empty_f <= emptyi;
		   END IF;
	  	 --END IF ;
       END IF;		 
	END PROCESS;
	empty1 <= '1' WHEN emptyi = '1' ELSE empty_f;
	 PROCESS (aresetn, pos_clk)
     BEGIN
       IF (NOT aresetn = '1') THEN
         empty_r <= '1';    
       ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
      
	      empty_r <= empty1;
	   END IF ;
	-- END IF;
	 END PROCESS;
	 
	END GENERATE P1;
		   
    P2 :  IF (NOT(ECC = 1 AND PIPE = 2 )) GENERATE 
	-- ELSE GENERATE 
	 
          --emptyi <= ((sc_r = 1) AND ( NOT we_i) AND re_i); 
           emptyi <= (conv_std_logic(to_integer(sc_r) <= 1) AND NOT we_i) AND re_i ;
		  
		PROCESS (aresetn, pos_clk)
        BEGIN
          IF (NOT aresetn = '1') THEN
            empty_r <= '1';    
          ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN    
	        IF ( (re_i XOR we_i)='1') THEN
		      empty_r <= emptyi;
		    END IF;
          END IF;    
        END PROCESS;
    END GENERATE P2;
     	
   ----------------------------------
   ----
   ---------------------------------
   
   
   
   
   
   -- --------------------------------------------------------------------------
   -- Binary counter
   -- The counter increments on Write and decrements on Read
   -- --------------------------------------------------------------------------
   
   PROCESS (aresetn, pos_clk)
   BEGIN
      IF (NOT aresetn = '1') THEN
         sc_r <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
      
         IF ((we_i XOR re_i) = '1') THEN
            IF (we_i = '1') THEN
               sc_r <= sc_r + '1';    
            ELSE
               IF (re_i = '1') THEN
                  sc_r <= sc_r - '1';    
               END IF;
            END IF;
         END IF;
      END IF;
      --END IF;
   END PROCESS;
   
   PROCESS (aresetn, pos_clk)
   BEGIN
      IF (NOT aresetn = '1') THEN
         sc_r_fwft <= (OTHERS => '0');    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
     
         IF ((we_i XOR ((re_top_p AND empty_top_fwft AND (NOT empty_top_fwft_r)) OR (re_top_p AND (NOT empty_top_fwft)))) = '1' ) THEN  
            IF (we_i = '1') THEN
               sc_r_fwft <= sc_r_fwft + '1';    
            ELSE
               IF (((re_top_p AND empty_top_fwft AND (NOT empty_top_fwft_r)) OR (re_top_p AND (NOT empty_top_fwft))) = '1') THEN  
                  sc_r_fwft <= sc_r_fwft - '1';    
               END IF;
            END IF;
         END IF;
      END IF;
      --END IF;
   END PROCESS;
   

   -- --------------------------------------------------------------------------
   -- Almost flag generations
   -- --------------------------------------------------------------------------
   T3: IF (FWFT = 0 AND PREFETCH = 0) GENERATE

   temp_xhdl18 <= (AFULL_VAL-1) WHEN AF_FLAG_STATIC /= 0 ELSE (FULL_WRITE_DEPTH); 
   afthreshi <= conv_std_logic_vector(temp_xhdl18, WRITE_DEPTH+1) ;

   --temp_xhdl19 <= AEMPTY_VAL+1 WHEN AE_FLAG_STATIC /= 0 ELSE 2;    --SAR#60185
   temp_xhdl19 <= AEMPTY_VAL WHEN AE_FLAG_STATIC = 1 ELSE 2;    --SAR#60185
   aethreshi   <= conv_std_logic_vector(temp_xhdl19, READ_DEPTH+1) ;


       --AHK almostfulli <= ((conv_std_logic(sc_r >= (afthreshi)) AND we_i) AND NOT re_i) OR ((conv_std_logic(sc_r > afthreshi) AND NOT we_i) AND re_i) ;
       almostfulli <= ((conv_std_logic(sc_r >= (afthreshi)) AND we_i) AND NOT re_i) OR ((conv_std_logic(sc_r-1 > afthreshi) AND NOT we_i) AND re_i) ;

       --AHK almostemptyi <= ((conv_std_logic(sc_r<=(aethreshi)) AND NOT we_i) AND re_i) OR ((conv_std_logic(sc_r < aethreshi) AND we_i) AND NOT re_i);
       almostemptyi <= ((conv_std_logic(sc_r<=(aethreshi)) AND NOT we_i) AND re_i) OR ((conv_std_logic(sc_r+1 < aethreshi) AND we_i) AND NOT re_i);

       fulli <= (conv_std_logic(sc_r = conv_std_logic_vector((FULL_WRITE_DEPTH - 1),
   WRITE_DEPTH+1)) AND we_i) AND NOT re_i ;
   END GENERATE T3;


   T4: IF ((FWFT = 1 OR PREFETCH = 1) AND PIPE = 1) GENERATE

   temp_xhdl181 <= (AFULL_VAL) WHEN AF_FLAG_STATIC = 1 ELSE (FULL_WRITE_DEPTH); 
   afthreshi <= conv_std_logic_vector(temp_xhdl181, WRITE_DEPTH+1) ;

   temp_xhdl191 <= AEMPTY_VAL WHEN AE_FLAG_STATIC = 1 ELSE 2;    --SAR#60185
   aethreshi   <= conv_std_logic_vector(temp_xhdl191, READ_DEPTH+1) ;


   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         almostemptyi  <= '1';    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
      
        IF ((conv_std_logic(sc_r_fwft >= aethreshi) AND we_i AND (NOT re_top_p)) = '1') THEN
           almostemptyi  <= '0';    
	ELSIF ((conv_std_logic(sc_r_fwft-1 <= aethreshi) AND conv_std_logic(sc_r_fwft > conv_std_logic_vector(0, READ_DEPTH)) AND (NOT we_i) AND re_top_p) = '1') THEN
           almostemptyi  <= '1';    
        END IF;
      END IF;
     -- END IF;
   END PROCESS;

         almostfulli_assert     <=  (conv_std_logic(sc_r_fwft >= (afthreshi-1)) AND we_i AND NOT(re_top_p AND NOT (empty_r_fwft)));  
         almostfulli_deassert   <=  (conv_std_logic(sc_r_fwft <= afthreshi) AND NOT (we_i) AND (re_top_p AND NOT(empty_r_fwft)));     
	 -- almostfulli_assert_sig <=  '1' WHEN almostfulli_assert = '1' ELSE afull_r;  
	 -- almostfulli            <=  '0' WHEN almostfulli_deassert = '1' ELSE almostfulli_assert_sig;  
	 almostfulli_assert_sig <=  '0' WHEN almostfulli_deassert = '1' ELSE afull_r;  
	 almostfulli            <=  '1' WHEN almostfulli_assert = '1' ELSE almostfulli_assert_sig;  

          fulli_assert   <=  (conv_std_logic(sc_r_fwft >= (FULL_WRITE_DEPTH-1)) AND we_i AND NOT(re_top_p AND NOT (empty_r_fwft)));  
          fulli_deassert <=  (conv_std_logic(sc_r_fwft < (FULL_WRITE_DEPTH-1 )) AND NOT(we_i) AND (re_top_p AND NOT(empty_r_fwft)));  
	  fulli_assert_sig <=  '1' WHEN fulli_assert = '1' ELSE full_r;  
	  fulli            <=  '0' WHEN fulli_deassert = '1' ELSE fulli_assert_sig;    
  END GENERATE T4;


   --emptyi <= (conv_std_logic(to_integer(sc_r) <= 1) AND NOT we_i) AND re_i ;
   emptyi_fwft <= (conv_std_logic(sc_r_fwft = conv_std_logic_vector(0, READ_DEPTH)));  



   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         dvld_r2  <= '0';    
         full_reg <= '1';    
         empty_top_fwft_r <= '1';    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
      
         dvld_r2  <= dvld_r;    
         full_reg <= full_r;    
         empty_top_fwft_r <= empty_top_fwft;    
      END IF;
      --END IF;
   END PROCESS;


   -- --------------------------------------------------------------------------    
   -- Generate the status flags - Empty/Full/Almost Empty/ Almost Full
   -- Generate the data handshaking flags - DVLD/WACK
   -- Generate error count flags - Underflow/Overflow
   -- Generate write and read address signals to the external memory
   -- --------------------------------------------------------------------------    
   
   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         --empty_r <= '1';    
         empty_r_fwft <= '1';    
         aempty_r_fwft <= '1';    
         dvld_r <= '0';    
         underflow_r <= '0';    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
     
       --  IF ((we_i XOR re_i) = '1') THEN
       --     empty_r <= emptyi;    
       --  END IF;
         IF ((we_i XOR (re_top_p AND (NOT empty_r_fwft))) = '1') THEN
            empty_r_fwft <= emptyi_fwft;    
         END IF;
   
         IF ((we_i XOR (re_top_p AND (NOT empty_r_fwft))) = '1') THEN
            aempty_r_fwft <= almostemptyi;    
         END IF;
   
         IF (re_i = '1' AND READ_DVALID = 1 AND (FWFT = 0 AND PREFETCH = 0)) THEN
            dvld_r <= '1';    
         ELSIF ((re_top_p AND (NOT empty_r_fwft)) = '1' AND READ_DVALID = 1  AND (FWFT = 1 OR PREFETCH = 1)) THEN
            dvld_r <= '1';    
         ELSE
            dvld_r <= '0';    
         END IF;
   
         IF ((re_p = '1' AND empty_r = '1') AND UNDERFLOW_EN = 1 AND (FWFT = 0 AND PREFETCH = 0)) THEN
            underflow_r <= '1';    
         ELSIF ((re_top_p = '1' AND empty_top_fwft = '1') AND UNDERFLOW_EN = 1 AND (FWFT = 1 OR PREFETCH = 1)) THEN
            underflow_r <= '1';    
         ELSE
            underflow_r <= '0';    
         END IF;
      END IF;
     -- END IF;
   END PROCESS;

   T5: IF (FWFT = 0 AND PREFETCH = 0) GENERATE
   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         aempty_r <= '1';    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
     
         IF ((we_i XOR re_i) = '1' ) THEN  
            aempty_r <= almostemptyi;    
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
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
     
         IF ((we_i XOR re_i) = '1') THEN
            full_r <= fulli;    
         END IF;

         IF ((we_i XOR re_i) = '1') THEN
            afull_r <= almostfulli;    
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
      END IF;
     -- END IF;
   END PROCESS;
   END GENERATE T5;

   T6: IF ((FWFT = 1 OR PREFETCH = 1) AND PIPE = 1) GENERATE
   
   PROCESS (almostemptyi)
   BEGIN
      aempty_r <= almostemptyi;    
   END PROCESS;

   PROCESS (pos_clk, aresetn)
   BEGIN
      IF (NOT aresetn = '1') THEN
         full_r <= '0';    
         afull_r <= '0';    
         wack_r <= '0';    
         overflow_r <= '0';    
      ELSIF (pos_clk'EVENT AND pos_clk = '1') THEN
     
         IF ((we_i XOR (re_top_p AND NOT empty_r_fwft)) = '1') THEN
            IF ((we_i AND NOT(re_top_p AND NOT empty_r_fwft)) = '1') THEN
               full_r <= fulli;    
            ELSIF ((NOT(we_i) AND (re_top_p AND NOT empty_r_fwft)) = '1') THEN
               full_r <= '0';    
            END IF;
         END IF;

         IF ((we_i XOR (re_top_p AND NOT empty_r_fwft)) = '1') THEN
            afull_r <= almostfulli;    
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
      END IF;
     -- END IF;
   END PROCESS;
   END GENERATE T6;

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

END ARCHITECTURE translated;
