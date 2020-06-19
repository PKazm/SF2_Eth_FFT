-- This is automatically generated file --

LIBRARY ieee; 
  USE ieee.std_logic_1164.all; 
  USE ieee.numeric_std.all; 
  

ENTITY COREFIFO_C0_COREFIFO_C0_0_ram_wrapper IS 
  GENERIC( RWIDTH    : integer := 18;   
           WWIDTH    : integer := 18;   
           RDEPTH    : integer := 1024; 
           WDEPTH    : integer :=1024;  
           SYNC      : integer :=0;     
           CTRL_TYPE : integer :=1;     
           PIPE      : integer := 1 );  
  PORT( 
    WDATA  : IN std_logic_vector(WWIDTH -1 downto 0); 
    WADDR  : IN std_logic_vector(WDEPTH -1 downto 0); 
    WEN    : IN std_logic; 
    REN    : IN std_logic; 
    RDATA  : OUT std_logic_vector(RWIDTH -1 downto 0); 
    RADDR  : IN std_logic_vector(RDEPTH -1 downto 0); 
    RESET_N: IN std_logic; 
    CLOCK  : IN std_logic; 
    RCLOCK : IN std_logic; 
A_SB_CORRECT         : OUT std_logic;   
B_SB_CORRECT         : OUT std_logic;   
A_DB_DETECT          : OUT std_logic;   
B_DB_DETECT          : OUT std_logic;   
    WCLOCK : IN std_logic 
  ); 
END COREFIFO_C0_COREFIFO_C0_0_ram_wrapper; 

ARCHITECTURE generated OF COREFIFO_C0_COREFIFO_C0_0_ram_wrapper IS 

COMPONENT COREFIFO_C0_COREFIFO_C0_0_USRAM_top
PORT (
A_DOUT                  : OUT std_logic_vector(RWIDTH-1 DOWNTO 0);   
B_DOUT                  : OUT std_logic_vector(RWIDTH-1 DOWNTO 0);   
C_DIN                   : IN std_logic_vector(WWIDTH-1 DOWNTO 0);   
A_ADDR                  : IN std_logic_vector(RDEPTH-1 DOWNTO 0);   
B_ADDR                  : IN std_logic_vector(RDEPTH-1 DOWNTO 0);   
C_ADDR                  : IN std_logic_vector(WDEPTH-1 DOWNTO 0);   
A_BLK                   : IN std_logic;   
B_BLK                   : IN std_logic;   
C_BLK                   : IN std_logic;   
C_WEN                   : IN std_logic;  
C_CLK                   : IN std_logic;   
A_CLK                   : IN std_logic;   
B_CLK                   : IN std_logic;   
A_ADDR_EN               : IN std_logic;   
B_ADDR_EN               : IN std_logic;   
A_ADDR_SRST_N           : IN std_logic;   
B_ADDR_SRST_N           : IN std_logic;   
A_ADDR_ARST_N           : IN std_logic;   
B_ADDR_ARST_N           : IN std_logic);   
END COMPONENT;
SIGNAL RDATA_xhdl1              :  std_logic_vector(RWIDTH - 1 DOWNTO 0);   

BEGIN 

RDATA <= RDATA_xhdl1;

U2_asyncnonpipe : COREFIFO_C0_COREFIFO_C0_0_USRAM_top 
PORT MAP (
A_DOUT => RDATA_xhdl1,
B_DOUT => open,       
C_DIN => WDATA,       
A_ADDR => RADDR,      
B_ADDR => RADDR,      
C_ADDR => WADDR,      
A_BLK => REN,         
B_BLK => REN,         
C_BLK => '1',         
C_WEN => WEN,         
C_CLK => WCLOCK,      
A_CLK => RCLOCK,      
B_CLK => RCLOCK,      
A_ADDR_EN => REN,     
B_ADDR_EN => REN,        
A_ADDR_SRST_N => RESET_N, 
B_ADDR_SRST_N => RESET_N, 
A_ADDR_ARST_N => RESET_N, 
B_ADDR_ARST_N => RESET_N);


END ARCHITECTURE generated;
