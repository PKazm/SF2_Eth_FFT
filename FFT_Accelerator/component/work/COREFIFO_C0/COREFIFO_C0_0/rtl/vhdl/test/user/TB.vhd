-- ********************************************************************/
-- Actel Corporation Proprietary and Confidential
--  Copyright 2011 Actel Corporation.  All rights reserved.
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
-- IN ADVANCE IN WRITING.
--
-- Description:  testbench
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
library ieee, std, work;              
use ieee.std_logic_1164.all;    

use work.coreparameters.all;
use work.all;                   
use std.textio.all;             
use ieee.std_logic_textio.all;  
use ieee.std_logic_arith.all;   
use ieee.std_logic_unsigned.all;


entity  testbench is
end testbench;
     
architecture architecture_tb of testbench is    
    FUNCTION log2 (x : natural) RETURN natural is 
    BEGIN
	--IF x <= 1 THEN  -- This change below is made to accomodate WDEPTH/RDEPTH value of 1, else MEMWADDR/MEMRADDR goes negative for value '1'
        IF x <= 1 THEN
            RETURN 0;
        ELSE
            RETURN log2 (x / 2) + 1;
        END IF;
    END FUNCTION log2;

    FUNCTION ceil_log2 (t : natural) RETURN natural is
        VARIABLE RetVal:    natural;
    BEGIN
        RetVal := log2(t);
        IF (t > (2**RetVal)) THEN
            RETURN(RetVal + 1); -- RetVal is too small, so bump it up by 1 and return
        ELSE
            RETURN(RetVal); -- Just right
        END IF;
    END FUNCTION ceil_log2;


component COREFIFO_C0_COREFIFO_C0_0_COREFIFO
                  generic(
      FAMILY                         :  integer := 19;    
      SYNC                           :  integer := 0;    --  Synchronous or Asynchronous operation | 1 - Single Clock, 0 - Dual clock
      RCLK_EDGE                      :  integer := 1;    --  Read  Clock Edge | 1 - Posedge, 0 - Negedge
      WCLK_EDGE                      :  integer := 1;    --  Write Clock Edge | 1 - Posedge, 0 - Negedge
      RE_POLARITY                    :  integer := 0;    --  Read  Enable Clock Edge | 1 - Active Low, 0 - Active High
      WE_POLARITY                    :  integer := 0;    --  Write Enable Clock Edge | 1 - Active Low, 0 - Active High
      RWIDTH                         :  integer := 32;   --  Read  port Data Width
      WWIDTH                         :  integer := 32;   --  Write port Data Width
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
      AEVAL                          :  integer := 1000; --  Almost Empty Threshold assert value
      AFVAL                          :  integer := 1016; --  Almost Full  Threshold assert value
      PIPE                           :  integer := 1;    --  Pipeline read data out
      PREFETCH                       :  integer := 0;    --  Prefetching of Read data | 0 - Disable Pre-fetching, 1 - Enable Pre-fetching only if PIPE=1
      FWFT                           :  integer := 0;    --  FWFT of Read data | 0 - Disable FWFT, 1 - Enable FWFT only if PIPE=1
      RESET_POLARITY                 :  integer := 0;    --  Polarity of Reset | 0 - Active Low, 1 - Active High
      OVERFLOW_EN                    :  integer := 0;    --  Overflow Enable/Disable | 0 - Disable, 1 - Enable
      UNDERFLOW_EN                   :  integer := 0;    --  Underflow Enable/Disable | 0 - Disable, 1 - Enable
      WRCNT_EN                       :  integer := 0;    --  Write Count Enable/Disable | 0 - Disable, 1 - Enable
	  NUM_STAGES                     :  integer := 0;    --  Number of synchroniser stages
      RDCNT_EN                       :  integer := 0);
		  port(
      ----------
      -- Inputs
      ----------
      -- Clocks and Reset

      CLK                     : IN std_logic;   
      WCLOCK                  : IN std_logic;   
      RCLOCK                  : IN std_logic;   
      RESET                   : IN std_logic;   
      -- Input Data Bus and Control ports

      DATA                    : IN std_logic_vector(17 DOWNTO 0);   
      WE                      : IN std_logic;   
      RE                      : IN std_logic;   
      -----------
      -- Outputs
      -----------
      -- Output Data bus

      Q                       : OUT std_logic_vector(17 DOWNTO 0);   
      -- Output Status Flags

      FULL                    : OUT std_logic;   
      EMPTY                   : OUT std_logic;   
      AFULL                   : OUT std_logic;   
      AEMPTY                  : OUT std_logic;   
      OVERFLOW                : OUT std_logic;   
      UNDERFLOW               : OUT std_logic;   
      WACK                    : OUT std_logic;   
      DVLD                    : OUT std_logic;   
      WRCNT                   : OUT std_logic_vector(10 DOWNTO 0);   
      RDCNT                   : OUT std_logic_vector(10 DOWNTO 0);   
      -- Outputs For external memory

      SB_CORRECT              : OUT std_logic;   
      DB_DETECT               : OUT std_logic;   
      MEMWE                   : OUT std_logic;   
      MEMRE                   : OUT std_logic;   
      MEMWADDR                : OUT std_logic_vector(9 DOWNTO 0);
      MEMRADDR                : OUT std_logic_vector(9 DOWNTO 0);
      MEMWD                   : OUT std_logic_vector(17 DOWNTO 0);   
      MEMRD                   : IN std_logic_vector(17 DOWNTO 0));   
end component;

   COMPONENT g4_dp_ext_mem
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
         PREFETCH                       :  integer := 1;    
         FWFT                           :  integer := 1;    
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
   END COMPONENT;


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

   FUNCTION conv_std_logic_vector (
      val      : IN integer;
      len      : IN integer) RETURN std_logic_vector IS
   BEGIN
	   RETURN(to_stdlogicvector(val, len));
	END conv_std_logic_vector;


     signal wclk           	: std_logic := '0';	
     constant WCLK_PERIOD	: time := 5.0 ns;	
     signal rclk           	: std_logic := '0';	
     constant RCLK_PERIOD	: time := 5.0 ns;	
     signal reset_n         	: std_logic;                               
     signal we			: std_logic;
     signal re	     	: std_logic; 
     signal wdata	     	: std_logic_vector(17 downto 0);
     signal wdata_incr	     	: std_logic_vector(17 downto 0):="000000000000000001";
     signal rdata		: std_logic_vector(17  downto 0);
     signal fifo_rdata		: std_logic_vector(17  downto 0);
     signal data_out_exp		: std_logic_vector(17  downto 0);
     signal full		: std_logic;   -- 0 = not full;  1 = full 
     signal empty		: std_logic;   -- 0 = not empty; 1 = empty 
     signal aempty		: std_logic;	    	  
     signal afull	     : std_logic;
     signal delay			: std_logic := '0';
     signal skip			: std_logic := '0';	            
     signal FIFO_dir_ext	     : std_logic;            		
     signal error_flag  		: std_logic	:= '0'; 
     signal END_OF_SIMULATION        : boolean:=FALSE;

--******************* External memory ****************************************

     signal ext_waddr : std_logic_vector(9 downto 0) ;
     signal ext_raddr : std_logic_vector(9 downto 0)  ;
     signal ext_data  : std_logic_vector(17 downto 0) ;
     signal ext_rd    : std_logic_vector(17 downto 0) ;
     signal ext_we : std_logic;
     signal ext_re : std_logic;
     signal err_flag : std_logic;
     signal clk : std_logic;
     signal waddr : integer;
     signal j : integer;
     signal t : integer;
     signal raddr : integer;
     signal n : integer;
     signal dly : integer;
     signal re_d1 : std_logic;
     signal re_int : std_logic;
     signal re_d2 : std_logic;
     signal err_count : integer;
     signal SB_CORRECT : std_logic;
     signal DB_DETECT  : std_logic;
 
-- FIFO driver signals
  TYPE xhdl_2 IS ARRAY (1024 DOWNTO 0) OF std_logic_vector(17 DOWNTO 0);
  TYPE xhdl_3 IS ARRAY (1026 DOWNTO 0) OF std_logic_vector(17 DOWNTO 0);

  SIGNAL wdata_xhdl4              :  std_logic_vector(17 DOWNTO 0);
   -- ** MEM DECLARATION **
   SIGNAL MEM_WR                      :  xhdl_2; 
   SIGNAL MEM_RD                      :  xhdl_2; 
   PROCEDURE WRITE (
      val      : IN string) IS
      VARIABLE ptr        : line;
   BEGIN
      WRITE(OUTPUT, val);
      WRITELINE(OUTPUT, ptr);
   END WRITE;
--                   		 
----------------------------------------------------------------------------- 
-- Write fifo process
-----------------------------------------------------------------------------
begin

 test_wclk : process
       variable fifo_din		: std_logic_vector(17  downto 0);
       variable wgood			: boolean;
       variable fifo_exp		: std_logic_vector(17  downto 0);       
		
 begin
       we			<= '0';
       re			<= '0';
       wdata		<= (others=>'0');
       reset_n		<= '1';
       --err_flag          <= '0';
   	wait for 50 ns;
          wait until(wclk'event and wclk = '1');	
       reset_n		<=	'0';
   	wait for 1500 ns; 
          wait until(wclk'event and wclk = '1');	
       reset_n		<=	'1';
       waddr <= 0;
       j <= 0;
       t <= 0;

    wait for 100 ns;

         WRITE(" ");    
         WRITE("--------------------------------------");   
         WRITE(" Microsemi CoreFIFO Testbench  v2.2 ");   
         WRITE("--------------------------------------");   
         WRITE(" ");    
       ----------------------------------------------------------------
       -- Start filling the fifo
       ----------------------------------------------------------------
         WRITE(" ");    
         WRITE("--------------------------------------");   
         WRITE(" Write FIFO ");   
         WRITE("--------------------------------------");   
         WRITE(" ");   

    LP1: loop
	        exit LP1 when waddr = 1024;
       		we	<= '1'; -- write last read from file
       		wdata 	<= wdata_incr ;
       		wait until rising_edge(wclk);
                MEM_WR((waddr)) <= wdata_incr;
       		wdata_incr 	<= wdata_incr + "00000000000000001" ;
		waddr <= waddr + 1;
       end loop;	
       we	<= '0';

                                             
       wait for 1000 ns;                           

       ----------------------------------------------------------------------------- 
       -- Read fifo 
       -----------------------------------------------------------------------------
         WRITE(" ");    
         WRITE("--------------------------------------");   
         WRITE(" Read FIFO ");   
         WRITE("--------------------------------------");   
         WRITE(" ");   
    LP2: loop
	        exit LP2 when j = 1024;
	       
       		data_out_exp	<= ext_rd; 
       		re	<= '1';-- write last read from file
      		wait until rising_edge(rclk);

	        j <= j + 1;
       end loop;	
       re	<= '0' ; 

       wait for 1000 ns;                           

    LP4: loop
	        exit LP4 when dly = 1025;
	       
      		wait until rising_edge(rclk);
       end loop;       


 
 end process;

       ----------------------------------------------------------------------------- 
       -- Compare fifo contents
       -----------------------------------------------------------------------------
   PROCESS (rclk, reset_n)
   BEGIN
      IF (NOT reset_n = '1') THEN
	 raddr <= 0;
               END_OF_SIMULATION <= FALSE;       
      ELSIF (rclk'EVENT AND rclk = '1') THEN
        IF(raddr = 1024) THEN
               END_OF_SIMULATION <= TRUE;       
               IF(err_flag = '1') THEN
                  WRITE(" FIFO TEST FAILED \n");
	       ELSE 	  
                  WRITE(" ALL TESTS PASSED \n");
               END IF;
         END IF;
	 IF (re = '1' ) THEN
            raddr <= raddr + 1;
         END IF ;
      END IF;
   END PROCESS;
   PROCESS (rclk, reset_n)
   BEGIN
      IF (NOT reset_n = '1') THEN
	 err_flag  <= '0';
	 err_count <= 0;
      ELSIF (rclk'EVENT AND rclk = '1') THEN
	 IF(FWFT = 1 or PREFETCH = 1) THEN
           IF (re_int = '1') THEN
             IF ( rdata = fifo_rdata) THEN
               --  WRITE(" FIFO TEST PASS \n");
             ELSE 
               WRITE(" FIFO TEST FAIL \n");
	       err_flag  <= '1';
	       err_count <= err_count + 1;
            END IF;	    
           END IF;
         END IF;

 	 IF(FWFT = 0 and PREFETCH = 0) THEN
	   IF (re_d1 = '1') THEN
             IF ( rdata = ext_rd) THEN
               --  WRITE(" FIFO TEST PASS \n");
             ELSE 
               WRITE(" FIFO TEST FAIL \n");
	       err_flag  <= '1';
	       err_count <= err_count + 1;
             END IF;	    
           END IF;
         END IF;

      END IF;
   END PROCESS;

   PROCESS (rclk, reset_n)
   BEGIN
      IF (NOT reset_n = '1') THEN
	 re_d1 <= '0';
	 re_d2 <= '0';
      ELSIF (rclk'EVENT AND rclk = '1') THEN
	 re_d1 <= re_int;
	 re_d2 <= re_d1;
      END IF;
   END PROCESS;

   re_int <= re after 1 ns;

   PROCESS
   BEGIN
      wclk <= '0';
      WAIT FOR 10 ns;
      wclk <= '1';    
      WAIT FOR 10 ns;
      IF(END_OF_SIMULATION) THEN
           WAIT;
      END IF;
   END PROCESS;
   PROCESS
   BEGIN
      rclk <= '0';
      WAIT FOR 10 ns;
      rclk <= '1';    
      WAIT FOR 10 ns;
      IF(END_OF_SIMULATION) THEN
           WAIT;
      END IF;
   END PROCESS;
   PROCESS
   BEGIN
      clk <= '0';
      WAIT FOR 10 ns;
      clk <= '1';    
      WAIT FOR 10 ns;
      IF(END_OF_SIMULATION) THEN
           WAIT;
      END IF;
   END PROCESS;


       ----------------------------------------------------------------------------- 
       -- FIFO Instance 
       -----------------------------------------------------------------------------

   fifo : COREFIFO_C0_COREFIFO_C0_0_COREFIFO
          GENERIC MAP(
                       FAMILY         =>  19,          
                       SYNC           =>  SYNC,           
                       RCLK_EDGE      =>  1,
                       WCLK_EDGE      =>  1,      
                       RE_POLARITY    =>  0,    
                       WE_POLARITY    =>  0,    
                       RWIDTH         =>  18,         
                       WWIDTH         =>  18,         
                       RDEPTH         =>  1024,         
                       WDEPTH         =>  1024,         
                       READ_DVALID    =>  1,    
                       WRITE_ACK      =>  1,      
                       CTRL_TYPE      =>  1,      
                       ESTOP          =>  1,          
                       FSTOP          =>  1,          
                       AE_STATIC_EN   =>  1,   
                       AF_STATIC_EN   =>  1,   
                       AEVAL          =>  4,          
                       AFVAL          =>  1020,          
                       PIPE           =>  1,           
                       PREFETCH       =>  PREFETCH,       
                       FWFT           =>  FWFT,       
                       RESET_POLARITY =>  0, 
                       OVERFLOW_EN    =>  0,    
                       UNDERFLOW_EN   =>  0,   
                       WRCNT_EN       =>  0, 
                       NUM_STAGES     => NUM_STAGES,					   
                       RDCNT_EN       =>  0      
		     )
	  PORT MAP (
                       CLK       => wclk,     
                       WCLOCK    => wclk,    
                       RCLOCK    => rclk,    
                       RESET     => reset_n,    
                       DATA      => wdata,   
                       WE        => we,    
                       RE        => re,   
                       Q         => rdata,    
                       FULL      => full,    
                       EMPTY     => empty,    
                       AFULL     => afull,    
                       AEMPTY    => aempty,    
                       OVERFLOW  =>  open    
                       ,UNDERFLOW => open    
                       ,WACK      => open
                       ,DVLD      => open
                       ,WRCNT     => open    
                       ,RDCNT     => open    
                       ,MEMWE     => ext_we    
                       ,MEMRE     => ext_re  
                       ,MEMWADDR  => ext_waddr    
		       ,MEMRADDR  => ext_raddr    
                       ,MEMWD     => ext_data    
                       ,MEMRD     => ext_rd 
                       ,SB_CORRECT=> SB_CORRECT 
                       ,DB_DETECT => DB_DETECT 
	       );

    fifo_rdata <= rdata WHEN (PREFETCH = 1 OR FWFT = 1) ELSE ext_rd;

       ----------------------------------------------------------------------------- 
       -- External memory Instance 
       -----------------------------------------------------------------------------
   ext_mem : g4_dp_ext_mem 
      GENERIC MAP (
         WRITE_ENABLE => 0,
         RAM_ADDRESS_END => 1024,
         RAM_WD => 10,
         RESET_POLARITY => 0,
         RAM_WW => 18,
         READ_CLK => 1,
         RAM_RD => 10,
         RAM_RW => 18,
         WRITE_CLK => 1,
         READ_ENABLE => 0,
         PREFETCH => PREFETCH,
         FWFT    => FWFT,
         SYNC => SYNC)
      PORT MAP (
         clk => clk,
         wclk => wclk,
         rclk => rclk,
         rst_n => reset_n,
         waddr => ext_waddr,
         raddr => ext_raddr,
         data => ext_data,
         we => ext_we,
         re => ext_re,
         q => ext_rd);   


end architecture_tb;
