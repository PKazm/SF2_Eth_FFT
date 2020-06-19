-- ********************************************************************/
-- Actel Corporation Proprietary and Confidential
--  Copyright 2011 Actel Corporation.  All rights reserved.
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
-- IN ADVANCE IN WRITING.
--
-- Description:  fwft.v
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


ENTITY COREFIFO_C0_COREFIFO_C0_0_corefifo_fwft IS
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
     --SYNC_RESET                     :  integer := 0);    
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
      fifo_MEMRADDR           : IN std_logic_vector(RDEPTH-1 DOWNTO 0);   
      fwft_MEMRADDR           : OUT std_logic_vector(RDEPTH-1 DOWNTO 0));   
END ENTITY COREFIFO_C0_COREFIFO_C0_0_corefifo_fwft;

ARCHITECTURE translated OF COREFIFO_C0_COREFIFO_C0_0_corefifo_fwft IS


   -- --------------------------------------------------------------------------
   -- Internal signals
   -- --------------------------------------------------------------------------
   SIGNAL fifo_valid               :  std_logic;   
   SIGNAL dout_valid               :  std_logic;   
   SIGNAL middle_valid             :  std_logic;   
   SIGNAL middle_dout              :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL update_dout              :  std_logic;   
   SIGNAL update_middle            :  std_logic;   
   SIGNAL fifo_empty_r             :  std_logic;   
   SIGNAL empty_r                  :  std_logic;   
   SIGNAL wr_p_r                   :  std_logic;   
   SIGNAL reg_valid_xhdl4_r        :  std_logic;   
   SIGNAL we_p                     :  std_logic;   
   SIGNAL we_p_r                   :  std_logic;   
   SIGNAL re_p                     :  std_logic;   
   SIGNAL fwft_MEMRE_tgl           :  std_logic;   
   SIGNAL fwft_MEMRE_tgl_r         :  std_logic;   
   SIGNAL fwft_MEMRE_tgl_pos       :  std_logic;   
   SIGNAL fwft_MEMRE_tgl_neg       :  std_logic;   
   SIGNAL fwft_MEMRE_tgl_sync1     :  std_logic;   
   SIGNAL fwft_MEMRE_tgl_sync2     :  std_logic;   
   SIGNAL aresetn                  :  std_logic;   
  -- SIGNAL sresetn                  :  std_logic;   

   -- clocks and enables 
   SIGNAL temp_xhdl6               :  std_logic;   
   SIGNAL temp_xhdl7               :  std_logic;   
   SIGNAL temp_xhdl8               :  std_logic;   
   SIGNAL temp_xhdl9               :  std_logic;   
   SIGNAL temp_xhdl10              :  std_logic;   
   SIGNAL temp_xhdl11              :  std_logic;   
   SIGNAL temp_xhdl12              :  std_logic;   
   SIGNAL temp_xhdl13              :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL empty_xhdl1              :  std_logic;   
   SIGNAL aempty_xhdl1             :  std_logic;   
   SIGNAL dout_xhdl2               :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   
   SIGNAL fwft_dvld_xhdl3          :  std_logic;   
   SIGNAL reg_valid_xhdl4          :  std_logic;   
   SIGNAL fwft_MEMRADDR_xhdl5      :  std_logic_vector(RDEPTH - 1 DOWNTO 0);   
   SIGNAL neg_reset                :  std_logic;   
   SIGNAL pos_rclk                 :  std_logic;   
   SIGNAL pos_wclk                 :  std_logic;   
   SIGNAL fifo_rd_en_int           :  std_logic; 
  
   SIGNAL reset_wclk               : std_logic;
   SIGNAL reset_rclk                : std_logic;
 
   


   -- --------------------------------------------------------------------------
   -- Function Declarations
   -- --------------------------------------------------------------------------
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
   empty <= empty_xhdl1;
   aempty <= aempty_xhdl1;
   dout <= dout_xhdl2;
   fwft_dvld <= fwft_dvld_xhdl3;
   reg_valid <= reg_valid_xhdl4;
   fwft_MEMRADDR <= fwft_MEMRADDR_xhdl5;

   -- --------------------------------------------------------------------------
   -- Clocks, resets and enables
   -- --------------------------------------------------------------------------
   T11: IF (SYNC = 1) GENERATE
      temp_xhdl6 <= clk WHEN RCLK_HIGH /= 0 ELSE NOT clk;
      pos_rclk <= temp_xhdl6 ;
      temp_xhdl7 <= clk WHEN WCLK_HIGH /= 0 ELSE NOT clk;
      pos_wclk <= temp_xhdl7 ;
   END GENERATE T11;

   T12: IF (SYNC = 0) GENERATE
      temp_xhdl6 <= rd_clk WHEN RCLK_HIGH /= 0 ELSE NOT rd_clk;
      pos_rclk <= temp_xhdl6 ;
      temp_xhdl7 <= wr_clk WHEN WCLK_HIGH /= 0 ELSE NOT wr_clk;
      pos_wclk <= temp_xhdl7 ;
   END GENERATE T12;

  -- temp_xhdl8 <= NOT rst WHEN RESET_LOW /= 0 ELSE rst;
  -- neg_reset <= temp_xhdl8 ;
  -- temp_xhdl9 <= '1' WHEN (SYNC_RESET = 1) ELSE neg_reset;
  ---- aresetn <= neg_reset ;
  -- temp_xhdl10 <= neg_reset WHEN (SYNC_RESET = 1) ELSE '1';
  -- sresetn <= temp_xhdl10 ;
   temp_xhdl11 <= (NOT wr_en) WHEN WRITE_LOW /= 0 ELSE (wr_en);
   we_p <= temp_xhdl11 ;
   temp_xhdl12 <= (NOT rd_en) WHEN READ_LOW /= 0 ELSE (rd_en);
   re_p <= temp_xhdl12 ;
  
 
	
reset_rclk <= reset_rclk_top;
reset_wclk <= reset_wclk_top;
-----------------------------------	
-----------------------------------	
		

   -- --------------------------------------------------------------------------   
   -- Generate addresses to the memory
   -- --------------------------------------------------------------------------
   fwft_MEMRADDR_xhdl5 <= fifo_MEMRADDR ;
   update_middle <= fifo_valid AND conv_std_logic(middle_valid = update_dout);
   update_dout <= (fifo_valid OR middle_valid) AND (re_p OR NOT dout_valid) ;
   fifo_rd_en_int <= NOT (fifo_empty) AND NOT (middle_valid AND dout_valid AND fifo_valid); 
   fifo_rd_en <= fifo_rd_en_int;
   
   -- --------------------------------------------------------------------------
   -- Generate Empty signal
   -- --------------------------------------------------------------------------
   --empty_xhdl1  <= NOT dout_valid OR (NOT(fifo_valid) AND NOT(middle_valid) AND dout_valid AND NOT(update_dout) AND re_p); 
    -- empty_xhdl1 <= NOT dout_valid;
   aempty_xhdl1 <= fifo_aempty OR empty_xhdl1 ;  
   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF ((NOT reset_rclk) = '1') THEN
         empty_xhdl1 <='1';
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
          IF (update_dout = '1') THEN
              empty_xhdl1 <= '0';    
           ELSE
              IF (re_p = '1') THEN
                 empty_xhdl1 <= '1';    
              END IF;
           END IF;
      END IF;
   END PROCESS;
   -- --------------------------------------------------------------------------
   -- Register empty signal
   -- --------------------------------------------------------------------------
   
   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF ((NOT reset_rclk) = '1') THEN
         fifo_empty_r <= '0';    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
        
           fifo_empty_r <= fifo_empty;    
        -- END IF;
      END IF;
   END PROCESS;
   
   temp_xhdl13 <= middle_dout WHEN middle_valid = '1' ELSE fifo_dout;

   -- --------------------------------------------------------------------------
   -- FWFT logic
   -- --------------------------------------------------------------------------
   
   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF ((NOT reset_rclk) = '1') THEN
         fifo_valid   <= '0';    
         middle_valid <= '0';    
         dout_valid   <= '0';    
         dout_xhdl2   <= (OTHERS => '0');    
         middle_dout  <= (OTHERS => '0');    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
        
           IF (update_middle = '1') THEN
              middle_dout <= fifo_dout;    
           END IF;
           IF (update_dout = '1') THEN
              dout_xhdl2 <= temp_xhdl13;    
           END IF;
           IF (fifo_rd_en_int = '1') THEN
              fifo_valid <= '1';    
           ELSE
              IF ((update_middle OR update_dout) = '1') THEN
                 fifo_valid <= '0';    
              END IF;
           END IF;
           IF (update_middle = '1') THEN
              middle_valid <= '1';    
           ELSE
              IF (update_dout = '1') THEN
                 middle_valid <= '0';    
              END IF;
           END IF;
           IF (update_dout = '1') THEN
              dout_valid <= '1';    
           ELSE
              IF (re_p = '1') THEN
                 dout_valid <= '0';    
              END IF;
           END IF;
        -- END IF;
      END IF;
   END PROCESS;
   
   -- --------------------------------------------------------------------------
   -- Generate the data valid signal
   -- --------------------------------------------------------------------------
   P1: IF (FWFT = 1) GENERATE
     -- fwft_dvld_xhdl3 <= reg_valid_xhdl4 OR (re_p AND NOT empty_r) ; 
	    fwft_dvld_xhdl3 <= dout_valid;
   END GENERATE P1;
   
   P2: IF (PREFETCH = 1) GENERATE
     -- fwft_dvld_xhdl3 <= re_p AND NOT empty_r ; 
       	fwft_dvld_xhdl3 <= re_p AND dout_valid;
   END GENERATE P2;

   -- --------------------------------------------------------------------------
   -- Generate the qualifying signal for generating data valid in case of FWFT
   -- --------------------------------------------------------------------------
   PROCESS (re_p, empty_xhdl1, empty_r, reg_valid_xhdl4_r)
   BEGIN
     IF (re_p = '1') THEN
        reg_valid_xhdl4 <= '0';    
     ELSIF (empty_xhdl1 = '0' AND empty_r = '1') THEN
        reg_valid_xhdl4 <= '1';    
     ELSE
        reg_valid_xhdl4 <= reg_valid_xhdl4_r;    
     END IF;
   END PROCESS;

   PROCESS (pos_rclk, reset_rclk)
   BEGIN
      IF ((NOT reset_rclk) = '1') THEN
         reg_valid_xhdl4_r <= '0';    
         empty_r           <= '0';    
      ELSIF (pos_rclk'EVENT AND pos_rclk = '1') THEN
         
            reg_valid_xhdl4_r <= reg_valid_xhdl4;    
            empty_r           <= empty_xhdl1;    
        -- END IF;
      END IF;
   END PROCESS;

   PROCESS (pos_wclk, reset_wclk)
   BEGIN
      IF ((NOT reset_wclk) = '1') THEN
         we_p_r <= '0';    
      ELSIF (pos_wclk'EVENT AND pos_wclk = '1') THEN
        
            we_p_r <= we_p;    
         --END IF;
      END IF;
   END PROCESS;

END ARCHITECTURE translated;
