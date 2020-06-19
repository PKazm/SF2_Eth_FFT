library ieee;                   
library ieee, std, work;              
use ieee.std_logic_1164.all;    
use work.all;                   
use std.textio.all;             
use ieee.std_logic_textio.all;  
use ieee.std_logic_arith.all;   
use ieee.std_logic_unsigned.all;

use work.coreparameters.all;

ENTITY g4_dp_ext_mem IS
   GENERIC (
      -- Memory parameters
      RAM_RW                         :  integer := 18;    
      RAM_WW                         :  integer := 18;    
      RAM_WD                         :  integer := 10;    
      RAM_RD                         :  integer := 10;    
      RAM_ADDRESS_END                :  integer := 1024;    
      WRITE_CLK                      :  integer := 1;    
      READ_CLK                       :  integer := 1;    
      SYNC                           :  integer := 1;    
      FWFT                           :  integer := 1;    
      PREFETCH                       :  integer := 1;    
      WRITE_ENABLE                   :  integer := 0;    
      READ_ENABLE                    :  integer := 0;    
      RESET_POLARITY                 :  integer := 0);    
   PORT (
      -- local inputs

      clk                     : IN std_logic;   
      wclk                    : IN std_logic;   
      rclk                    : IN std_logic;   
      rst_n                   : IN std_logic;   
      -- local inputs - memory functional bus

      waddr                   : IN std_logic_vector(RAM_WD - 1 DOWNTO 0);   
      raddr                   : IN std_logic_vector(RAM_RD - 1 DOWNTO 0);   
      data                    : IN std_logic_vector(RAM_WW - 1 DOWNTO 0);   
      we                      : IN std_logic;   
      re                      : IN std_logic;   
      --OUTPUTS
      q                       : OUT std_logic_vector(RAM_RW - 1 DOWNTO 0));   
END ENTITY g4_dp_ext_mem;

ARCHITECTURE translated OF g4_dp_ext_mem IS

   TYPE xhdl_2 IS ARRAY (RAM_ADDRESS_END - 1 DOWNTO 0) OF 
   std_logic_vector(RAM_WW - 1 DOWNTO 0);

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


   SIGNAL clk_int                  :  std_logic;   
   SIGNAL wclk_int                 :  std_logic;   
   SIGNAL rclk_int                 :  std_logic;   
   SIGNAL we_int                   :  std_logic;   
   SIGNAL re_int                   :  std_logic;   
   SIGNAL waddr_int                :  std_logic_vector(RAM_WD - 1 DOWNTO 0);   
   SIGNAL rst_int                  :  std_logic;   
   SIGNAL wdone                    :  std_logic;   
   SIGNAL temp                     :  std_logic;   
   -- ** MEM DECLARATION **
   SIGNAL MEM                      :  xhdl_2;   
   SIGNAL i                        :  integer;   
   SIGNAL temp_xhdl3               :  std_logic;   
   SIGNAL temp_xhdl4               :  std_logic;   
   SIGNAL temp_xhdl5               :  std_logic;   
   SIGNAL temp_xhdl6               :  std_logic;   
   SIGNAL temp_xhdl7               :  std_logic;   
   SIGNAL temp_xhdl8               :  std_logic;   
   SIGNAL temp_xhdl9               :  std_logic;   
   SIGNAL temp_xhdl10              :  std_logic;   
   SIGNAL q_xhdl1                  :  std_logic_vector(RAM_RW - 1 DOWNTO 0);   
   SIGNAL q_xhdl2                  :  std_logic_vector(RAM_RW - 1 DOWNTO 0);   
   SIGNAL q_d0                  :  std_logic_vector(RAM_RW - 1 DOWNTO 0);   
   SIGNAL q_d1                  :  std_logic_vector(RAM_RW - 1 DOWNTO 0);   
   SIGNAL q_d2                  :  std_logic_vector(RAM_RW - 1 DOWNTO 0);   
   SIGNAL re_int_d1                :  std_logic; 
   SIGNAL re_int_d2                :  std_logic; 
   SIGNAL we_d1                    :  std_logic; 
   signal prefetch_data            : std_logic_vector(RAM_RW - 1 DOWNTO 0);
BEGIN
   --q <= q_xhdl1;
   temp_xhdl3 <= clk WHEN WRITE_CLK /= 0 ELSE NOT clk;
   clk_int <= temp_xhdl3 ;
   temp_xhdl4 <= wclk WHEN WRITE_CLK /= 0 ELSE NOT wclk;
   wclk_int <= temp_xhdl4 ;
   temp_xhdl5 <= rclk WHEN READ_CLK /= 0 ELSE NOT rclk;
   rclk_int <= temp_xhdl5 ;
   temp_xhdl6 <= wclk WHEN WRITE_CLK /= 0 ELSE NOT wclk;
   temp_xhdl7 <= clk_int WHEN SYNC /= 0 ELSE (temp_xhdl6);
   wclk_int <= temp_xhdl7 ;
   temp_xhdl8 <= rclk WHEN READ_CLK /= 0 ELSE NOT rclk;
   temp_xhdl9 <= clk_int WHEN SYNC /= 0 ELSE (temp_xhdl8);
   rclk_int <= temp_xhdl9 ;
   we_int <= we ;
   re_int <= re ;
   waddr_int <= waddr;
   temp_xhdl10 <= NOT rst_n WHEN RESET_POLARITY /= 0 ELSE rst_n;
   rst_int <= temp_xhdl10 ;

   PROCESS
      VARIABLE xhdl_initial : BOOLEAN := TRUE;
      VARIABLE q_xhdl1_xhdl11  : std_logic_vector(RAM_RW - 1 DOWNTO 0);
      VARIABLE wdone_xhdl12  : std_logic;
      VARIABLE temp_xhdl13  : std_logic;
   BEGIN
      IF (xhdl_initial) THEN
         q_xhdl1_xhdl11 := (OTHERS => '0');    
         wdone_xhdl12 := '0';    
         temp_xhdl13 := '0';    
         q_xhdl1 <= q_xhdl1_xhdl11;
         wdone <= wdone_xhdl12;
         temp <= temp_xhdl13;
         xhdl_initial := FALSE;
      ELSE
         WAIT;
      END IF;
   END PROCESS;

--   PROCESS(we_int,wclk_int)
--   BEGIN
--        IF (we_int = '1') THEN
--           MEM(to_integer(waddr_int)) <= data;    
--        END IF;
--   END PROCESS;

   PROCESS (clk_int, rst_int)
   BEGIN
      IF (NOT rst_int = '1') THEN
      ELSIF (clk_int'EVENT AND clk_int = '0') THEN
           we_d1 <= we ;    
      END IF;
   END PROCESS;

   PROCESS (clk_int, rst_int)
   BEGIN
      IF (NOT rst_int = '1') THEN
      ELSIF (clk_int'EVENT AND clk_int = '0') THEN
         IF( we = '1' and we_d1 <= '0') THEN    
            prefetch_data <= data ;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_int, rst_int)
   BEGIN
      IF (NOT rst_int = '1') THEN
      ELSIF (clk_int'EVENT AND clk_int = '1') THEN
           re_int_d1 <= re_int ;    
      END IF;
   END PROCESS;

   PROCESS (clk_int, rst_int)
   BEGIN
      IF (NOT rst_int = '1') THEN
      ELSIF (clk_int'EVENT AND clk_int = '0') THEN
        IF (we_int = '1') THEN
           MEM(to_integer(waddr_int)) <= data;    
        END IF;
      END IF;
   END PROCESS;


   PROCESS (clk_int, rst_int)
   VARIABLE q1_xhdl1  : std_logic_vector(RAM_RW - 1 DOWNTO 0);
   BEGIN
      IF (NOT rst_int = '1') THEN
         q_xhdl2 <= (OTHERS => '0');
      ELSIF (clk_int'EVENT AND clk_int = '1') THEN
               IF(re_int = '1' ) THEN
                  q1_xhdl1 := MEM(to_integer(raddr));    
               END IF ;

      END IF;
      q_xhdl2 <= q1_xhdl1 ;

   END PROCESS;

   q_d0 <= prefetch_data when ( (re_int = '1' and re_int_d1 = '0') ) ELSE q_xhdl2 ;

   PROCESS (clk_int, rst_int)
   BEGIN
      IF (NOT rst_int = '1') THEN
	      q_d1 <= (OTHERS => '0');
	      q_d2 <= (OTHERS => '0');
      ELSIF (clk_int'EVENT AND clk_int = '1') THEN
	      q_d1 <= q_d0 ;
	      q_d2 <= q_d1 ;
      END IF;
   END PROCESS;

   q <= q_d0 when ( (PREFETCH = 1 or FWFT = 1) ) ELSE q_xhdl2 ;

END ARCHITECTURE translated;
