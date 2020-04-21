-- Version: v11.1 SP2 11.1.2.11

library ieee;
use ieee.std_logic_1164.all;
library SmartFusion2;
use SmartFusion2.all;

entity RAMBLOCK1024X16 is

    port( DATA     : in    std_logic_vector(15 downto 0);
          Q        : out   std_logic_vector(15 downto 0);
          WADDRESS : in    std_logic_vector(9 downto 0);
          RADDRESS : in    std_logic_vector(9 downto 0);
          WE       : in    std_logic;
          RE       : in    std_logic;
          WCLOCK   : in    std_logic;
          RCLOCK   : in    std_logic
        );

end RAMBLOCK1024X16;

architecture DEF_ARCH of RAMBLOCK1024X16 is 

  component RAM1K18
    generic (MEMORYFILE:string := "");

    port( A_DOUT        : out   std_logic_vector(17 downto 0);
          B_DOUT        : out   std_logic_vector(17 downto 0);
          BUSY          : out   std_logic;
          A_CLK         : in    std_logic := 'U';
          A_DOUT_CLK    : in    std_logic := 'U';
          A_ARST_N      : in    std_logic := 'U';
          A_DOUT_EN     : in    std_logic := 'U';
          A_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_DOUT_ARST_N : in    std_logic := 'U';
          A_DOUT_SRST_N : in    std_logic := 'U';
          A_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          A_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          A_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_CLK         : in    std_logic := 'U';
          B_DOUT_CLK    : in    std_logic := 'U';
          B_ARST_N      : in    std_logic := 'U';
          B_DOUT_EN     : in    std_logic := 'U';
          B_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_DOUT_ARST_N : in    std_logic := 'U';
          B_DOUT_SRST_N : in    std_logic := 'U';
          B_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          B_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          B_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_EN          : in    std_logic := 'U';
          A_DOUT_LAT    : in    std_logic := 'U';
          A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_WMODE       : in    std_logic := 'U';
          B_EN          : in    std_logic := 'U';
          B_DOUT_LAT    : in    std_logic := 'U';
          B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_WMODE       : in    std_logic := 'U';
          SII_LOCK      : in    std_logic := 'U'
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc1, nc8, nc13, nc16, nc19, nc20, nc9, nc14, nc5, nc15, 
        nc3, nc10, nc7, nc17, nc4, nc12, nc2, nc18, nc6, nc11
         : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    RAMBLOCK1024X16_R0C0 : RAM1K18
      port map(A_DOUT(17) => nc1, A_DOUT(16) => Q(15), A_DOUT(15)
         => Q(14), A_DOUT(14) => Q(13), A_DOUT(13) => Q(12), 
        A_DOUT(12) => Q(11), A_DOUT(11) => Q(10), A_DOUT(10) => 
        Q(9), A_DOUT(9) => Q(8), A_DOUT(8) => nc8, A_DOUT(7) => 
        Q(7), A_DOUT(6) => Q(6), A_DOUT(5) => Q(5), A_DOUT(4) => 
        Q(4), A_DOUT(3) => Q(3), A_DOUT(2) => Q(2), A_DOUT(1) => 
        Q(1), A_DOUT(0) => Q(0), B_DOUT(17) => nc13, B_DOUT(16)
         => nc16, B_DOUT(15) => nc19, B_DOUT(14) => nc20, 
        B_DOUT(13) => nc9, B_DOUT(12) => nc14, B_DOUT(11) => nc5, 
        B_DOUT(10) => nc15, B_DOUT(9) => nc3, B_DOUT(8) => nc10, 
        B_DOUT(7) => nc7, B_DOUT(6) => nc17, B_DOUT(5) => nc4, 
        B_DOUT(4) => nc12, B_DOUT(3) => nc2, B_DOUT(2) => nc18, 
        B_DOUT(1) => nc6, B_DOUT(0) => nc11, BUSY => OPEN, A_CLK
         => RCLOCK, A_DOUT_CLK => \VCC\, A_ARST_N => \VCC\, 
        A_DOUT_EN => \VCC\, A_BLK(2) => RE, A_BLK(1) => \VCC\, 
        A_BLK(0) => \VCC\, A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N
         => \VCC\, A_DIN(17) => \GND\, A_DIN(16) => \GND\, 
        A_DIN(15) => \GND\, A_DIN(14) => \GND\, A_DIN(13) => 
        \GND\, A_DIN(12) => \GND\, A_DIN(11) => \GND\, A_DIN(10)
         => \GND\, A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7)
         => \GND\, A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4)
         => \GND\, A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1)
         => \GND\, A_DIN(0) => \GND\, A_ADDR(13) => RADDRESS(9), 
        A_ADDR(12) => RADDRESS(8), A_ADDR(11) => RADDRESS(7), 
        A_ADDR(10) => RADDRESS(6), A_ADDR(9) => RADDRESS(5), 
        A_ADDR(8) => RADDRESS(4), A_ADDR(7) => RADDRESS(3), 
        A_ADDR(6) => RADDRESS(2), A_ADDR(5) => RADDRESS(1), 
        A_ADDR(4) => RADDRESS(0), A_ADDR(3) => \GND\, A_ADDR(2)
         => \GND\, A_ADDR(1) => \GND\, A_ADDR(0) => \GND\, 
        A_WEN(1) => \GND\, A_WEN(0) => \GND\, B_CLK => WCLOCK, 
        B_DOUT_CLK => \VCC\, B_ARST_N => \VCC\, B_DOUT_EN => 
        \VCC\, B_BLK(2) => WE, B_BLK(1) => \VCC\, B_BLK(0) => 
        \VCC\, B_DOUT_ARST_N => \GND\, B_DOUT_SRST_N => \VCC\, 
        B_DIN(17) => \GND\, B_DIN(16) => DATA(15), B_DIN(15) => 
        DATA(14), B_DIN(14) => DATA(13), B_DIN(13) => DATA(12), 
        B_DIN(12) => DATA(11), B_DIN(11) => DATA(10), B_DIN(10)
         => DATA(9), B_DIN(9) => DATA(8), B_DIN(8) => \GND\, 
        B_DIN(7) => DATA(7), B_DIN(6) => DATA(6), B_DIN(5) => 
        DATA(5), B_DIN(4) => DATA(4), B_DIN(3) => DATA(3), 
        B_DIN(2) => DATA(2), B_DIN(1) => DATA(1), B_DIN(0) => 
        DATA(0), B_ADDR(13) => WADDRESS(9), B_ADDR(12) => 
        WADDRESS(8), B_ADDR(11) => WADDRESS(7), B_ADDR(10) => 
        WADDRESS(6), B_ADDR(9) => WADDRESS(5), B_ADDR(8) => 
        WADDRESS(4), B_ADDR(7) => WADDRESS(3), B_ADDR(6) => 
        WADDRESS(2), B_ADDR(5) => WADDRESS(1), B_ADDR(4) => 
        WADDRESS(0), B_ADDR(3) => \GND\, B_ADDR(2) => \GND\, 
        B_ADDR(1) => \GND\, B_ADDR(0) => \GND\, B_WEN(1) => \VCC\, 
        B_WEN(0) => \VCC\, A_EN => \VCC\, A_DOUT_LAT => \VCC\, 
        A_WIDTH(2) => \VCC\, A_WIDTH(1) => \GND\, A_WIDTH(0) => 
        \GND\, A_WMODE => \GND\, B_EN => \VCC\, B_DOUT_LAT => 
        \VCC\, B_WIDTH(2) => \VCC\, B_WIDTH(1) => \GND\, 
        B_WIDTH(0) => \GND\, B_WMODE => \GND\, SII_LOCK => \GND\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 
-- Version: v11.1 SP2 11.1.2.11

library ieee;
use ieee.std_logic_1164.all;
library SmartFusion2;
use SmartFusion2.all;

entity RAMBLOCK1024X32 is

    port( DATA     : in    std_logic_vector(31 downto 0);
          Q        : out   std_logic_vector(31 downto 0);
          WADDRESS : in    std_logic_vector(9 downto 0);
          RADDRESS : in    std_logic_vector(9 downto 0);
          WE       : in    std_logic;
          RE       : in    std_logic;
          WCLOCK   : in    std_logic;
          RCLOCK   : in    std_logic
        );

end RAMBLOCK1024X32;

architecture DEF_ARCH of RAMBLOCK1024X32 is 

  component RAM1K18
    generic (MEMORYFILE:string := "");

    port( A_DOUT        : out   std_logic_vector(17 downto 0);
          B_DOUT        : out   std_logic_vector(17 downto 0);
          BUSY          : out   std_logic;
          A_CLK         : in    std_logic := 'U';
          A_DOUT_CLK    : in    std_logic := 'U';
          A_ARST_N      : in    std_logic := 'U';
          A_DOUT_EN     : in    std_logic := 'U';
          A_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_DOUT_ARST_N : in    std_logic := 'U';
          A_DOUT_SRST_N : in    std_logic := 'U';
          A_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          A_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          A_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_CLK         : in    std_logic := 'U';
          B_DOUT_CLK    : in    std_logic := 'U';
          B_ARST_N      : in    std_logic := 'U';
          B_DOUT_EN     : in    std_logic := 'U';
          B_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_DOUT_ARST_N : in    std_logic := 'U';
          B_DOUT_SRST_N : in    std_logic := 'U';
          B_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          B_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          B_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_EN          : in    std_logic := 'U';
          A_DOUT_LAT    : in    std_logic := 'U';
          A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_WMODE       : in    std_logic := 'U';
          B_EN          : in    std_logic := 'U';
          B_DOUT_LAT    : in    std_logic := 'U';
          B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_WMODE       : in    std_logic := 'U';
          SII_LOCK      : in    std_logic := 'U'
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc34, nc9, nc13, nc23, nc33, nc16, nc26, nc27, nc17, 
        nc36, nc37, nc5, nc4, nc25, nc15, nc35, nc28, nc18, nc38, 
        nc1, nc2, nc22, nc12, nc21, nc11, nc3, nc32, nc40, nc31, 
        nc7, nc6, nc19, nc29, nc39, nc8, nc20, nc10, nc24, nc14, 
        nc30 : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    RAMBLOCK1024X32_R0C1 : RAM1K18
      port map(A_DOUT(17) => nc34, A_DOUT(16) => Q(31), 
        A_DOUT(15) => Q(30), A_DOUT(14) => Q(29), A_DOUT(13) => 
        Q(28), A_DOUT(12) => Q(27), A_DOUT(11) => Q(26), 
        A_DOUT(10) => Q(25), A_DOUT(9) => Q(24), A_DOUT(8) => nc9, 
        A_DOUT(7) => Q(23), A_DOUT(6) => Q(22), A_DOUT(5) => 
        Q(21), A_DOUT(4) => Q(20), A_DOUT(3) => Q(19), A_DOUT(2)
         => Q(18), A_DOUT(1) => Q(17), A_DOUT(0) => Q(16), 
        B_DOUT(17) => nc13, B_DOUT(16) => nc23, B_DOUT(15) => 
        nc33, B_DOUT(14) => nc16, B_DOUT(13) => nc26, B_DOUT(12)
         => nc27, B_DOUT(11) => nc17, B_DOUT(10) => nc36, 
        B_DOUT(9) => nc37, B_DOUT(8) => nc5, B_DOUT(7) => nc4, 
        B_DOUT(6) => nc25, B_DOUT(5) => nc15, B_DOUT(4) => nc35, 
        B_DOUT(3) => nc28, B_DOUT(2) => nc18, B_DOUT(1) => nc38, 
        B_DOUT(0) => nc1, BUSY => OPEN, A_CLK => RCLOCK, 
        A_DOUT_CLK => \VCC\, A_ARST_N => \VCC\, A_DOUT_EN => 
        \VCC\, A_BLK(2) => RE, A_BLK(1) => \VCC\, A_BLK(0) => 
        \VCC\, A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N => \VCC\, 
        A_DIN(17) => \GND\, A_DIN(16) => \GND\, A_DIN(15) => 
        \GND\, A_DIN(14) => \GND\, A_DIN(13) => \GND\, A_DIN(12)
         => \GND\, A_DIN(11) => \GND\, A_DIN(10) => \GND\, 
        A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7) => \GND\, 
        A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4) => \GND\, 
        A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1) => \GND\, 
        A_DIN(0) => \GND\, A_ADDR(13) => RADDRESS(9), A_ADDR(12)
         => RADDRESS(8), A_ADDR(11) => RADDRESS(7), A_ADDR(10)
         => RADDRESS(6), A_ADDR(9) => RADDRESS(5), A_ADDR(8) => 
        RADDRESS(4), A_ADDR(7) => RADDRESS(3), A_ADDR(6) => 
        RADDRESS(2), A_ADDR(5) => RADDRESS(1), A_ADDR(4) => 
        RADDRESS(0), A_ADDR(3) => \GND\, A_ADDR(2) => \GND\, 
        A_ADDR(1) => \GND\, A_ADDR(0) => \GND\, A_WEN(1) => \GND\, 
        A_WEN(0) => \GND\, B_CLK => WCLOCK, B_DOUT_CLK => \VCC\, 
        B_ARST_N => \VCC\, B_DOUT_EN => \VCC\, B_BLK(2) => WE, 
        B_BLK(1) => \VCC\, B_BLK(0) => \VCC\, B_DOUT_ARST_N => 
        \GND\, B_DOUT_SRST_N => \VCC\, B_DIN(17) => \GND\, 
        B_DIN(16) => DATA(31), B_DIN(15) => DATA(30), B_DIN(14)
         => DATA(29), B_DIN(13) => DATA(28), B_DIN(12) => 
        DATA(27), B_DIN(11) => DATA(26), B_DIN(10) => DATA(25), 
        B_DIN(9) => DATA(24), B_DIN(8) => \GND\, B_DIN(7) => 
        DATA(23), B_DIN(6) => DATA(22), B_DIN(5) => DATA(21), 
        B_DIN(4) => DATA(20), B_DIN(3) => DATA(19), B_DIN(2) => 
        DATA(18), B_DIN(1) => DATA(17), B_DIN(0) => DATA(16), 
        B_ADDR(13) => WADDRESS(9), B_ADDR(12) => WADDRESS(8), 
        B_ADDR(11) => WADDRESS(7), B_ADDR(10) => WADDRESS(6), 
        B_ADDR(9) => WADDRESS(5), B_ADDR(8) => WADDRESS(4), 
        B_ADDR(7) => WADDRESS(3), B_ADDR(6) => WADDRESS(2), 
        B_ADDR(5) => WADDRESS(1), B_ADDR(4) => WADDRESS(0), 
        B_ADDR(3) => \GND\, B_ADDR(2) => \GND\, B_ADDR(1) => 
        \GND\, B_ADDR(0) => \GND\, B_WEN(1) => \VCC\, B_WEN(0)
         => \VCC\, A_EN => \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2)
         => \VCC\, A_WIDTH(1) => \GND\, A_WIDTH(0) => \GND\, 
        A_WMODE => \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, 
        B_WIDTH(2) => \VCC\, B_WIDTH(1) => \GND\, B_WIDTH(0) => 
        \GND\, B_WMODE => \GND\, SII_LOCK => \GND\);
    
    RAMBLOCK1024X32_R0C0 : RAM1K18
      port map(A_DOUT(17) => nc2, A_DOUT(16) => Q(15), A_DOUT(15)
         => Q(14), A_DOUT(14) => Q(13), A_DOUT(13) => Q(12), 
        A_DOUT(12) => Q(11), A_DOUT(11) => Q(10), A_DOUT(10) => 
        Q(9), A_DOUT(9) => Q(8), A_DOUT(8) => nc22, A_DOUT(7) => 
        Q(7), A_DOUT(6) => Q(6), A_DOUT(5) => Q(5), A_DOUT(4) => 
        Q(4), A_DOUT(3) => Q(3), A_DOUT(2) => Q(2), A_DOUT(1) => 
        Q(1), A_DOUT(0) => Q(0), B_DOUT(17) => nc12, B_DOUT(16)
         => nc21, B_DOUT(15) => nc11, B_DOUT(14) => nc3, 
        B_DOUT(13) => nc32, B_DOUT(12) => nc40, B_DOUT(11) => 
        nc31, B_DOUT(10) => nc7, B_DOUT(9) => nc6, B_DOUT(8) => 
        nc19, B_DOUT(7) => nc29, B_DOUT(6) => nc39, B_DOUT(5) => 
        nc8, B_DOUT(4) => nc20, B_DOUT(3) => nc10, B_DOUT(2) => 
        nc24, B_DOUT(1) => nc14, B_DOUT(0) => nc30, BUSY => OPEN, 
        A_CLK => RCLOCK, A_DOUT_CLK => \VCC\, A_ARST_N => \VCC\, 
        A_DOUT_EN => \VCC\, A_BLK(2) => RE, A_BLK(1) => \VCC\, 
        A_BLK(0) => \VCC\, A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N
         => \VCC\, A_DIN(17) => \GND\, A_DIN(16) => \GND\, 
        A_DIN(15) => \GND\, A_DIN(14) => \GND\, A_DIN(13) => 
        \GND\, A_DIN(12) => \GND\, A_DIN(11) => \GND\, A_DIN(10)
         => \GND\, A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7)
         => \GND\, A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4)
         => \GND\, A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1)
         => \GND\, A_DIN(0) => \GND\, A_ADDR(13) => RADDRESS(9), 
        A_ADDR(12) => RADDRESS(8), A_ADDR(11) => RADDRESS(7), 
        A_ADDR(10) => RADDRESS(6), A_ADDR(9) => RADDRESS(5), 
        A_ADDR(8) => RADDRESS(4), A_ADDR(7) => RADDRESS(3), 
        A_ADDR(6) => RADDRESS(2), A_ADDR(5) => RADDRESS(1), 
        A_ADDR(4) => RADDRESS(0), A_ADDR(3) => \GND\, A_ADDR(2)
         => \GND\, A_ADDR(1) => \GND\, A_ADDR(0) => \GND\, 
        A_WEN(1) => \GND\, A_WEN(0) => \GND\, B_CLK => WCLOCK, 
        B_DOUT_CLK => \VCC\, B_ARST_N => \VCC\, B_DOUT_EN => 
        \VCC\, B_BLK(2) => WE, B_BLK(1) => \VCC\, B_BLK(0) => 
        \VCC\, B_DOUT_ARST_N => \GND\, B_DOUT_SRST_N => \VCC\, 
        B_DIN(17) => \GND\, B_DIN(16) => DATA(15), B_DIN(15) => 
        DATA(14), B_DIN(14) => DATA(13), B_DIN(13) => DATA(12), 
        B_DIN(12) => DATA(11), B_DIN(11) => DATA(10), B_DIN(10)
         => DATA(9), B_DIN(9) => DATA(8), B_DIN(8) => \GND\, 
        B_DIN(7) => DATA(7), B_DIN(6) => DATA(6), B_DIN(5) => 
        DATA(5), B_DIN(4) => DATA(4), B_DIN(3) => DATA(3), 
        B_DIN(2) => DATA(2), B_DIN(1) => DATA(1), B_DIN(0) => 
        DATA(0), B_ADDR(13) => WADDRESS(9), B_ADDR(12) => 
        WADDRESS(8), B_ADDR(11) => WADDRESS(7), B_ADDR(10) => 
        WADDRESS(6), B_ADDR(9) => WADDRESS(5), B_ADDR(8) => 
        WADDRESS(4), B_ADDR(7) => WADDRESS(3), B_ADDR(6) => 
        WADDRESS(2), B_ADDR(5) => WADDRESS(1), B_ADDR(4) => 
        WADDRESS(0), B_ADDR(3) => \GND\, B_ADDR(2) => \GND\, 
        B_ADDR(1) => \GND\, B_ADDR(0) => \GND\, B_WEN(1) => \VCC\, 
        B_WEN(0) => \VCC\, A_EN => \VCC\, A_DOUT_LAT => \VCC\, 
        A_WIDTH(2) => \VCC\, A_WIDTH(1) => \GND\, A_WIDTH(0) => 
        \GND\, A_WMODE => \GND\, B_EN => \VCC\, B_DOUT_LAT => 
        \VCC\, B_WIDTH(2) => \VCC\, B_WIDTH(1) => \GND\, 
        B_WIDTH(0) => \GND\, B_WMODE => \GND\, SII_LOCK => \GND\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 
-- Version: v11.1 SP2 11.1.2.11

library ieee;
use ieee.std_logic_1164.all;
library SmartFusion2;
use SmartFusion2.all;

entity RAMBLOCK1024X8 is

    port( DATA     : in    std_logic_vector(7 downto 0);
          Q        : out   std_logic_vector(7 downto 0);
          WADDRESS : in    std_logic_vector(9 downto 0);
          RADDRESS : in    std_logic_vector(9 downto 0);
          WE       : in    std_logic;
          RE       : in    std_logic;
          WCLOCK   : in    std_logic;
          RCLOCK   : in    std_logic
        );

end RAMBLOCK1024X8;

architecture DEF_ARCH of RAMBLOCK1024X8 is 

  component RAM1K18
    generic (MEMORYFILE:string := "");

    port( A_DOUT        : out   std_logic_vector(17 downto 0);
          B_DOUT        : out   std_logic_vector(17 downto 0);
          BUSY          : out   std_logic;
          A_CLK         : in    std_logic := 'U';
          A_DOUT_CLK    : in    std_logic := 'U';
          A_ARST_N      : in    std_logic := 'U';
          A_DOUT_EN     : in    std_logic := 'U';
          A_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_DOUT_ARST_N : in    std_logic := 'U';
          A_DOUT_SRST_N : in    std_logic := 'U';
          A_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          A_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          A_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_CLK         : in    std_logic := 'U';
          B_DOUT_CLK    : in    std_logic := 'U';
          B_ARST_N      : in    std_logic := 'U';
          B_DOUT_EN     : in    std_logic := 'U';
          B_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_DOUT_ARST_N : in    std_logic := 'U';
          B_DOUT_SRST_N : in    std_logic := 'U';
          B_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          B_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          B_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_EN          : in    std_logic := 'U';
          A_DOUT_LAT    : in    std_logic := 'U';
          A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_WMODE       : in    std_logic := 'U';
          B_EN          : in    std_logic := 'U';
          B_DOUT_LAT    : in    std_logic := 'U';
          B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_WMODE       : in    std_logic := 'U';
          SII_LOCK      : in    std_logic := 'U'
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc24, nc1, nc8, nc13, nc16, nc19, nc25, nc20, nc27, 
        nc9, nc22, nc28, nc14, nc5, nc21, nc15, nc3, nc10, nc7, 
        nc17, nc4, nc12, nc2, nc23, nc18, nc26, nc6, nc11
         : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    RAMBLOCK1024X8_R0C0 : RAM1K18
      port map(A_DOUT(17) => nc24, A_DOUT(16) => nc1, A_DOUT(15)
         => nc8, A_DOUT(14) => nc13, A_DOUT(13) => nc16, 
        A_DOUT(12) => nc19, A_DOUT(11) => nc25, A_DOUT(10) => 
        nc20, A_DOUT(9) => nc27, A_DOUT(8) => nc9, A_DOUT(7) => 
        Q(7), A_DOUT(6) => Q(6), A_DOUT(5) => Q(5), A_DOUT(4) => 
        Q(4), A_DOUT(3) => Q(3), A_DOUT(2) => Q(2), A_DOUT(1) => 
        Q(1), A_DOUT(0) => Q(0), B_DOUT(17) => nc22, B_DOUT(16)
         => nc28, B_DOUT(15) => nc14, B_DOUT(14) => nc5, 
        B_DOUT(13) => nc21, B_DOUT(12) => nc15, B_DOUT(11) => nc3, 
        B_DOUT(10) => nc10, B_DOUT(9) => nc7, B_DOUT(8) => nc17, 
        B_DOUT(7) => nc4, B_DOUT(6) => nc12, B_DOUT(5) => nc2, 
        B_DOUT(4) => nc23, B_DOUT(3) => nc18, B_DOUT(2) => nc26, 
        B_DOUT(1) => nc6, B_DOUT(0) => nc11, BUSY => OPEN, A_CLK
         => RCLOCK, A_DOUT_CLK => \VCC\, A_ARST_N => \VCC\, 
        A_DOUT_EN => \VCC\, A_BLK(2) => RE, A_BLK(1) => \VCC\, 
        A_BLK(0) => \VCC\, A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N
         => \VCC\, A_DIN(17) => \GND\, A_DIN(16) => \GND\, 
        A_DIN(15) => \GND\, A_DIN(14) => \GND\, A_DIN(13) => 
        \GND\, A_DIN(12) => \GND\, A_DIN(11) => \GND\, A_DIN(10)
         => \GND\, A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7)
         => \GND\, A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4)
         => \GND\, A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1)
         => \GND\, A_DIN(0) => \GND\, A_ADDR(13) => \GND\, 
        A_ADDR(12) => RADDRESS(9), A_ADDR(11) => RADDRESS(8), 
        A_ADDR(10) => RADDRESS(7), A_ADDR(9) => RADDRESS(6), 
        A_ADDR(8) => RADDRESS(5), A_ADDR(7) => RADDRESS(4), 
        A_ADDR(6) => RADDRESS(3), A_ADDR(5) => RADDRESS(2), 
        A_ADDR(4) => RADDRESS(1), A_ADDR(3) => RADDRESS(0), 
        A_ADDR(2) => \GND\, A_ADDR(1) => \GND\, A_ADDR(0) => 
        \GND\, A_WEN(1) => \GND\, A_WEN(0) => \GND\, B_CLK => 
        WCLOCK, B_DOUT_CLK => \VCC\, B_ARST_N => \VCC\, B_DOUT_EN
         => \VCC\, B_BLK(2) => WE, B_BLK(1) => \VCC\, B_BLK(0)
         => \VCC\, B_DOUT_ARST_N => \GND\, B_DOUT_SRST_N => \VCC\, 
        B_DIN(17) => \GND\, B_DIN(16) => \GND\, B_DIN(15) => 
        \GND\, B_DIN(14) => \GND\, B_DIN(13) => \GND\, B_DIN(12)
         => \GND\, B_DIN(11) => \GND\, B_DIN(10) => \GND\, 
        B_DIN(9) => \GND\, B_DIN(8) => \GND\, B_DIN(7) => DATA(7), 
        B_DIN(6) => DATA(6), B_DIN(5) => DATA(5), B_DIN(4) => 
        DATA(4), B_DIN(3) => DATA(3), B_DIN(2) => DATA(2), 
        B_DIN(1) => DATA(1), B_DIN(0) => DATA(0), B_ADDR(13) => 
        \GND\, B_ADDR(12) => WADDRESS(9), B_ADDR(11) => 
        WADDRESS(8), B_ADDR(10) => WADDRESS(7), B_ADDR(9) => 
        WADDRESS(6), B_ADDR(8) => WADDRESS(5), B_ADDR(7) => 
        WADDRESS(4), B_ADDR(6) => WADDRESS(3), B_ADDR(5) => 
        WADDRESS(2), B_ADDR(4) => WADDRESS(1), B_ADDR(3) => 
        WADDRESS(0), B_ADDR(2) => \GND\, B_ADDR(1) => \GND\, 
        B_ADDR(0) => \GND\, B_WEN(1) => \GND\, B_WEN(0) => \VCC\, 
        A_EN => \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2) => \GND\, 
        A_WIDTH(1) => \VCC\, A_WIDTH(0) => \VCC\, A_WMODE => 
        \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => 
        \GND\, B_WIDTH(1) => \VCC\, B_WIDTH(0) => \VCC\, B_WMODE
         => \GND\, SII_LOCK => \GND\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 
-- Version: v11.1 SP2 11.1.2.11

library ieee;
use ieee.std_logic_1164.all;
library SmartFusion2;
use SmartFusion2.all;

entity RAMBLOCK128X16 is

    port( DATA     : in    std_logic_vector(15 downto 0);
          Q        : out   std_logic_vector(15 downto 0);
          WADDRESS : in    std_logic_vector(6 downto 0);
          RADDRESS : in    std_logic_vector(6 downto 0);
          WE       : in    std_logic;
          RE       : in    std_logic;
          WCLOCK   : in    std_logic;
          RCLOCK   : in    std_logic
        );

end RAMBLOCK128X16;

architecture DEF_ARCH of RAMBLOCK128X16 is 

  component RAM1K18
    generic (MEMORYFILE:string := "");

    port( A_DOUT        : out   std_logic_vector(17 downto 0);
          B_DOUT        : out   std_logic_vector(17 downto 0);
          BUSY          : out   std_logic;
          A_CLK         : in    std_logic := 'U';
          A_DOUT_CLK    : in    std_logic := 'U';
          A_ARST_N      : in    std_logic := 'U';
          A_DOUT_EN     : in    std_logic := 'U';
          A_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_DOUT_ARST_N : in    std_logic := 'U';
          A_DOUT_SRST_N : in    std_logic := 'U';
          A_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          A_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          A_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_CLK         : in    std_logic := 'U';
          B_DOUT_CLK    : in    std_logic := 'U';
          B_ARST_N      : in    std_logic := 'U';
          B_DOUT_EN     : in    std_logic := 'U';
          B_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_DOUT_ARST_N : in    std_logic := 'U';
          B_DOUT_SRST_N : in    std_logic := 'U';
          B_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          B_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          B_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_EN          : in    std_logic := 'U';
          A_DOUT_LAT    : in    std_logic := 'U';
          A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_WMODE       : in    std_logic := 'U';
          B_EN          : in    std_logic := 'U';
          B_DOUT_LAT    : in    std_logic := 'U';
          B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_WMODE       : in    std_logic := 'U';
          SII_LOCK      : in    std_logic := 'U'
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc1, nc8, nc13, nc16, nc19, nc20, nc9, nc14, nc5, nc15, 
        nc3, nc10, nc7, nc17, nc4, nc12, nc2, nc18, nc6, nc11
         : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    RAMBLOCK128X16_R0C0 : RAM1K18
      port map(A_DOUT(17) => nc1, A_DOUT(16) => Q(15), A_DOUT(15)
         => Q(14), A_DOUT(14) => Q(13), A_DOUT(13) => Q(12), 
        A_DOUT(12) => Q(11), A_DOUT(11) => Q(10), A_DOUT(10) => 
        Q(9), A_DOUT(9) => Q(8), A_DOUT(8) => nc8, A_DOUT(7) => 
        Q(7), A_DOUT(6) => Q(6), A_DOUT(5) => Q(5), A_DOUT(4) => 
        Q(4), A_DOUT(3) => Q(3), A_DOUT(2) => Q(2), A_DOUT(1) => 
        Q(1), A_DOUT(0) => Q(0), B_DOUT(17) => nc13, B_DOUT(16)
         => nc16, B_DOUT(15) => nc19, B_DOUT(14) => nc20, 
        B_DOUT(13) => nc9, B_DOUT(12) => nc14, B_DOUT(11) => nc5, 
        B_DOUT(10) => nc15, B_DOUT(9) => nc3, B_DOUT(8) => nc10, 
        B_DOUT(7) => nc7, B_DOUT(6) => nc17, B_DOUT(5) => nc4, 
        B_DOUT(4) => nc12, B_DOUT(3) => nc2, B_DOUT(2) => nc18, 
        B_DOUT(1) => nc6, B_DOUT(0) => nc11, BUSY => OPEN, A_CLK
         => RCLOCK, A_DOUT_CLK => \VCC\, A_ARST_N => \VCC\, 
        A_DOUT_EN => \VCC\, A_BLK(2) => RE, A_BLK(1) => \VCC\, 
        A_BLK(0) => \VCC\, A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N
         => \VCC\, A_DIN(17) => \GND\, A_DIN(16) => \GND\, 
        A_DIN(15) => \GND\, A_DIN(14) => \GND\, A_DIN(13) => 
        \GND\, A_DIN(12) => \GND\, A_DIN(11) => \GND\, A_DIN(10)
         => \GND\, A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7)
         => \GND\, A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4)
         => \GND\, A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1)
         => \GND\, A_DIN(0) => \GND\, A_ADDR(13) => \GND\, 
        A_ADDR(12) => \GND\, A_ADDR(11) => \GND\, A_ADDR(10) => 
        RADDRESS(6), A_ADDR(9) => RADDRESS(5), A_ADDR(8) => 
        RADDRESS(4), A_ADDR(7) => RADDRESS(3), A_ADDR(6) => 
        RADDRESS(2), A_ADDR(5) => RADDRESS(1), A_ADDR(4) => 
        RADDRESS(0), A_ADDR(3) => \GND\, A_ADDR(2) => \GND\, 
        A_ADDR(1) => \GND\, A_ADDR(0) => \GND\, A_WEN(1) => \GND\, 
        A_WEN(0) => \GND\, B_CLK => WCLOCK, B_DOUT_CLK => \VCC\, 
        B_ARST_N => \VCC\, B_DOUT_EN => \VCC\, B_BLK(2) => WE, 
        B_BLK(1) => \VCC\, B_BLK(0) => \VCC\, B_DOUT_ARST_N => 
        \GND\, B_DOUT_SRST_N => \VCC\, B_DIN(17) => \GND\, 
        B_DIN(16) => DATA(15), B_DIN(15) => DATA(14), B_DIN(14)
         => DATA(13), B_DIN(13) => DATA(12), B_DIN(12) => 
        DATA(11), B_DIN(11) => DATA(10), B_DIN(10) => DATA(9), 
        B_DIN(9) => DATA(8), B_DIN(8) => \GND\, B_DIN(7) => 
        DATA(7), B_DIN(6) => DATA(6), B_DIN(5) => DATA(5), 
        B_DIN(4) => DATA(4), B_DIN(3) => DATA(3), B_DIN(2) => 
        DATA(2), B_DIN(1) => DATA(1), B_DIN(0) => DATA(0), 
        B_ADDR(13) => \GND\, B_ADDR(12) => \GND\, B_ADDR(11) => 
        \GND\, B_ADDR(10) => WADDRESS(6), B_ADDR(9) => 
        WADDRESS(5), B_ADDR(8) => WADDRESS(4), B_ADDR(7) => 
        WADDRESS(3), B_ADDR(6) => WADDRESS(2), B_ADDR(5) => 
        WADDRESS(1), B_ADDR(4) => WADDRESS(0), B_ADDR(3) => \GND\, 
        B_ADDR(2) => \GND\, B_ADDR(1) => \GND\, B_ADDR(0) => 
        \GND\, B_WEN(1) => \VCC\, B_WEN(0) => \VCC\, A_EN => 
        \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2) => \VCC\, 
        A_WIDTH(1) => \GND\, A_WIDTH(0) => \GND\, A_WMODE => 
        \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => 
        \VCC\, B_WIDTH(1) => \GND\, B_WIDTH(0) => \GND\, B_WMODE
         => \GND\, SII_LOCK => \GND\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 
-- Version: v11.1 SP2 11.1.2.11

library ieee;
use ieee.std_logic_1164.all;
library SmartFusion2;
use SmartFusion2.all;

entity RAMBLOCK128X32 is

    port( DATA     : in    std_logic_vector(31 downto 0);
          Q        : out   std_logic_vector(31 downto 0);
          WADDRESS : in    std_logic_vector(6 downto 0);
          RADDRESS : in    std_logic_vector(6 downto 0);
          WE       : in    std_logic;
          RE       : in    std_logic;
          WCLOCK   : in    std_logic;
          RCLOCK   : in    std_logic
        );

end RAMBLOCK128X32;

architecture DEF_ARCH of RAMBLOCK128X32 is 

  component RAM1K18
    generic (MEMORYFILE:string := "");

    port( A_DOUT        : out   std_logic_vector(17 downto 0);
          B_DOUT        : out   std_logic_vector(17 downto 0);
          BUSY          : out   std_logic;
          A_CLK         : in    std_logic := 'U';
          A_DOUT_CLK    : in    std_logic := 'U';
          A_ARST_N      : in    std_logic := 'U';
          A_DOUT_EN     : in    std_logic := 'U';
          A_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_DOUT_ARST_N : in    std_logic := 'U';
          A_DOUT_SRST_N : in    std_logic := 'U';
          A_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          A_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          A_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_CLK         : in    std_logic := 'U';
          B_DOUT_CLK    : in    std_logic := 'U';
          B_ARST_N      : in    std_logic := 'U';
          B_DOUT_EN     : in    std_logic := 'U';
          B_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_DOUT_ARST_N : in    std_logic := 'U';
          B_DOUT_SRST_N : in    std_logic := 'U';
          B_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          B_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          B_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_EN          : in    std_logic := 'U';
          A_DOUT_LAT    : in    std_logic := 'U';
          A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_WMODE       : in    std_logic := 'U';
          B_EN          : in    std_logic := 'U';
          B_DOUT_LAT    : in    std_logic := 'U';
          B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_WMODE       : in    std_logic := 'U';
          SII_LOCK      : in    std_logic := 'U'
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc2, nc4, nc3, nc1 : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    RAMBLOCK128X32_R0C0 : RAM1K18
      port map(A_DOUT(17) => nc2, A_DOUT(16) => Q(31), A_DOUT(15)
         => Q(30), A_DOUT(14) => Q(29), A_DOUT(13) => Q(28), 
        A_DOUT(12) => Q(27), A_DOUT(11) => Q(26), A_DOUT(10) => 
        Q(25), A_DOUT(9) => Q(24), A_DOUT(8) => nc4, A_DOUT(7)
         => Q(23), A_DOUT(6) => Q(22), A_DOUT(5) => Q(21), 
        A_DOUT(4) => Q(20), A_DOUT(3) => Q(19), A_DOUT(2) => 
        Q(18), A_DOUT(1) => Q(17), A_DOUT(0) => Q(16), B_DOUT(17)
         => nc3, B_DOUT(16) => Q(15), B_DOUT(15) => Q(14), 
        B_DOUT(14) => Q(13), B_DOUT(13) => Q(12), B_DOUT(12) => 
        Q(11), B_DOUT(11) => Q(10), B_DOUT(10) => Q(9), B_DOUT(9)
         => Q(8), B_DOUT(8) => nc1, B_DOUT(7) => Q(7), B_DOUT(6)
         => Q(6), B_DOUT(5) => Q(5), B_DOUT(4) => Q(4), B_DOUT(3)
         => Q(3), B_DOUT(2) => Q(2), B_DOUT(1) => Q(1), B_DOUT(0)
         => Q(0), BUSY => OPEN, A_CLK => RCLOCK, A_DOUT_CLK => 
        \VCC\, A_ARST_N => \VCC\, A_DOUT_EN => \VCC\, A_BLK(2)
         => RE, A_BLK(1) => \VCC\, A_BLK(0) => \VCC\, 
        A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N => \VCC\, A_DIN(17)
         => \GND\, A_DIN(16) => DATA(31), A_DIN(15) => DATA(30), 
        A_DIN(14) => DATA(29), A_DIN(13) => DATA(28), A_DIN(12)
         => DATA(27), A_DIN(11) => DATA(26), A_DIN(10) => 
        DATA(25), A_DIN(9) => DATA(24), A_DIN(8) => \GND\, 
        A_DIN(7) => DATA(23), A_DIN(6) => DATA(22), A_DIN(5) => 
        DATA(21), A_DIN(4) => DATA(20), A_DIN(3) => DATA(19), 
        A_DIN(2) => DATA(18), A_DIN(1) => DATA(17), A_DIN(0) => 
        DATA(16), A_ADDR(13) => \GND\, A_ADDR(12) => \GND\, 
        A_ADDR(11) => RADDRESS(6), A_ADDR(10) => RADDRESS(5), 
        A_ADDR(9) => RADDRESS(4), A_ADDR(8) => RADDRESS(3), 
        A_ADDR(7) => RADDRESS(2), A_ADDR(6) => RADDRESS(1), 
        A_ADDR(5) => RADDRESS(0), A_ADDR(4) => \GND\, A_ADDR(3)
         => \GND\, A_ADDR(2) => \GND\, A_ADDR(1) => \GND\, 
        A_ADDR(0) => \GND\, A_WEN(1) => \VCC\, A_WEN(0) => \VCC\, 
        B_CLK => WCLOCK, B_DOUT_CLK => \VCC\, B_ARST_N => \VCC\, 
        B_DOUT_EN => \VCC\, B_BLK(2) => WE, B_BLK(1) => \VCC\, 
        B_BLK(0) => \VCC\, B_DOUT_ARST_N => \VCC\, B_DOUT_SRST_N
         => \VCC\, B_DIN(17) => \GND\, B_DIN(16) => DATA(15), 
        B_DIN(15) => DATA(14), B_DIN(14) => DATA(13), B_DIN(13)
         => DATA(12), B_DIN(12) => DATA(11), B_DIN(11) => 
        DATA(10), B_DIN(10) => DATA(9), B_DIN(9) => DATA(8), 
        B_DIN(8) => \GND\, B_DIN(7) => DATA(7), B_DIN(6) => 
        DATA(6), B_DIN(5) => DATA(5), B_DIN(4) => DATA(4), 
        B_DIN(3) => DATA(3), B_DIN(2) => DATA(2), B_DIN(1) => 
        DATA(1), B_DIN(0) => DATA(0), B_ADDR(13) => \GND\, 
        B_ADDR(12) => \GND\, B_ADDR(11) => WADDRESS(6), 
        B_ADDR(10) => WADDRESS(5), B_ADDR(9) => WADDRESS(4), 
        B_ADDR(8) => WADDRESS(3), B_ADDR(7) => WADDRESS(2), 
        B_ADDR(6) => WADDRESS(1), B_ADDR(5) => WADDRESS(0), 
        B_ADDR(4) => \GND\, B_ADDR(3) => \GND\, B_ADDR(2) => 
        \GND\, B_ADDR(1) => \GND\, B_ADDR(0) => \GND\, B_WEN(1)
         => \VCC\, B_WEN(0) => \VCC\, A_EN => \VCC\, A_DOUT_LAT
         => \VCC\, A_WIDTH(2) => \VCC\, A_WIDTH(1) => \GND\, 
        A_WIDTH(0) => \VCC\, A_WMODE => \GND\, B_EN => \VCC\, 
        B_DOUT_LAT => \VCC\, B_WIDTH(2) => \VCC\, B_WIDTH(1) => 
        \GND\, B_WIDTH(0) => \VCC\, B_WMODE => \GND\, SII_LOCK
         => \GND\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 
-- Version: v11.1 SP2 11.1.2.11

library ieee;
use ieee.std_logic_1164.all;
library SmartFusion2;
use SmartFusion2.all;

entity RAMBLOCK128X8 is

    port( DATA     : in    std_logic_vector(7 downto 0);
          Q        : out   std_logic_vector(7 downto 0);
          WADDRESS : in    std_logic_vector(6 downto 0);
          RADDRESS : in    std_logic_vector(6 downto 0);
          WE       : in    std_logic;
          RE       : in    std_logic;
          WCLOCK   : in    std_logic;
          RCLOCK   : in    std_logic
        );

end RAMBLOCK128X8;

architecture DEF_ARCH of RAMBLOCK128X8 is 

  component RAM1K18
    generic (MEMORYFILE:string := "");

    port( A_DOUT        : out   std_logic_vector(17 downto 0);
          B_DOUT        : out   std_logic_vector(17 downto 0);
          BUSY          : out   std_logic;
          A_CLK         : in    std_logic := 'U';
          A_DOUT_CLK    : in    std_logic := 'U';
          A_ARST_N      : in    std_logic := 'U';
          A_DOUT_EN     : in    std_logic := 'U';
          A_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_DOUT_ARST_N : in    std_logic := 'U';
          A_DOUT_SRST_N : in    std_logic := 'U';
          A_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          A_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          A_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_CLK         : in    std_logic := 'U';
          B_DOUT_CLK    : in    std_logic := 'U';
          B_ARST_N      : in    std_logic := 'U';
          B_DOUT_EN     : in    std_logic := 'U';
          B_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_DOUT_ARST_N : in    std_logic := 'U';
          B_DOUT_SRST_N : in    std_logic := 'U';
          B_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          B_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          B_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_EN          : in    std_logic := 'U';
          A_DOUT_LAT    : in    std_logic := 'U';
          A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_WMODE       : in    std_logic := 'U';
          B_EN          : in    std_logic := 'U';
          B_DOUT_LAT    : in    std_logic := 'U';
          B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_WMODE       : in    std_logic := 'U';
          SII_LOCK      : in    std_logic := 'U'
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc24, nc1, nc8, nc13, nc16, nc19, nc25, nc20, nc27, 
        nc9, nc22, nc28, nc14, nc5, nc21, nc15, nc3, nc10, nc7, 
        nc17, nc4, nc12, nc2, nc23, nc18, nc26, nc6, nc11
         : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    RAMBLOCK128X8_R0C0 : RAM1K18
      port map(A_DOUT(17) => nc24, A_DOUT(16) => nc1, A_DOUT(15)
         => nc8, A_DOUT(14) => nc13, A_DOUT(13) => nc16, 
        A_DOUT(12) => nc19, A_DOUT(11) => nc25, A_DOUT(10) => 
        nc20, A_DOUT(9) => nc27, A_DOUT(8) => nc9, A_DOUT(7) => 
        Q(7), A_DOUT(6) => Q(6), A_DOUT(5) => Q(5), A_DOUT(4) => 
        Q(4), A_DOUT(3) => Q(3), A_DOUT(2) => Q(2), A_DOUT(1) => 
        Q(1), A_DOUT(0) => Q(0), B_DOUT(17) => nc22, B_DOUT(16)
         => nc28, B_DOUT(15) => nc14, B_DOUT(14) => nc5, 
        B_DOUT(13) => nc21, B_DOUT(12) => nc15, B_DOUT(11) => nc3, 
        B_DOUT(10) => nc10, B_DOUT(9) => nc7, B_DOUT(8) => nc17, 
        B_DOUT(7) => nc4, B_DOUT(6) => nc12, B_DOUT(5) => nc2, 
        B_DOUT(4) => nc23, B_DOUT(3) => nc18, B_DOUT(2) => nc26, 
        B_DOUT(1) => nc6, B_DOUT(0) => nc11, BUSY => OPEN, A_CLK
         => RCLOCK, A_DOUT_CLK => \VCC\, A_ARST_N => \VCC\, 
        A_DOUT_EN => \VCC\, A_BLK(2) => RE, A_BLK(1) => \VCC\, 
        A_BLK(0) => \VCC\, A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N
         => \VCC\, A_DIN(17) => \GND\, A_DIN(16) => \GND\, 
        A_DIN(15) => \GND\, A_DIN(14) => \GND\, A_DIN(13) => 
        \GND\, A_DIN(12) => \GND\, A_DIN(11) => \GND\, A_DIN(10)
         => \GND\, A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7)
         => \GND\, A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4)
         => \GND\, A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1)
         => \GND\, A_DIN(0) => \GND\, A_ADDR(13) => \GND\, 
        A_ADDR(12) => \GND\, A_ADDR(11) => \GND\, A_ADDR(10) => 
        \GND\, A_ADDR(9) => RADDRESS(6), A_ADDR(8) => RADDRESS(5), 
        A_ADDR(7) => RADDRESS(4), A_ADDR(6) => RADDRESS(3), 
        A_ADDR(5) => RADDRESS(2), A_ADDR(4) => RADDRESS(1), 
        A_ADDR(3) => RADDRESS(0), A_ADDR(2) => \GND\, A_ADDR(1)
         => \GND\, A_ADDR(0) => \GND\, A_WEN(1) => \GND\, 
        A_WEN(0) => \GND\, B_CLK => WCLOCK, B_DOUT_CLK => \VCC\, 
        B_ARST_N => \VCC\, B_DOUT_EN => \VCC\, B_BLK(2) => WE, 
        B_BLK(1) => \VCC\, B_BLK(0) => \VCC\, B_DOUT_ARST_N => 
        \GND\, B_DOUT_SRST_N => \VCC\, B_DIN(17) => \GND\, 
        B_DIN(16) => \GND\, B_DIN(15) => \GND\, B_DIN(14) => 
        \GND\, B_DIN(13) => \GND\, B_DIN(12) => \GND\, B_DIN(11)
         => \GND\, B_DIN(10) => \GND\, B_DIN(9) => \GND\, 
        B_DIN(8) => \GND\, B_DIN(7) => DATA(7), B_DIN(6) => 
        DATA(6), B_DIN(5) => DATA(5), B_DIN(4) => DATA(4), 
        B_DIN(3) => DATA(3), B_DIN(2) => DATA(2), B_DIN(1) => 
        DATA(1), B_DIN(0) => DATA(0), B_ADDR(13) => \GND\, 
        B_ADDR(12) => \GND\, B_ADDR(11) => \GND\, B_ADDR(10) => 
        \GND\, B_ADDR(9) => WADDRESS(6), B_ADDR(8) => WADDRESS(5), 
        B_ADDR(7) => WADDRESS(4), B_ADDR(6) => WADDRESS(3), 
        B_ADDR(5) => WADDRESS(2), B_ADDR(4) => WADDRESS(1), 
        B_ADDR(3) => WADDRESS(0), B_ADDR(2) => \GND\, B_ADDR(1)
         => \GND\, B_ADDR(0) => \GND\, B_WEN(1) => \GND\, 
        B_WEN(0) => \VCC\, A_EN => \VCC\, A_DOUT_LAT => \VCC\, 
        A_WIDTH(2) => \GND\, A_WIDTH(1) => \VCC\, A_WIDTH(0) => 
        \VCC\, A_WMODE => \GND\, B_EN => \VCC\, B_DOUT_LAT => 
        \VCC\, B_WIDTH(2) => \GND\, B_WIDTH(1) => \VCC\, 
        B_WIDTH(0) => \VCC\, B_WMODE => \GND\, SII_LOCK => \GND\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 
-- Version: v11.1 SP2 11.1.2.11

library ieee;
use ieee.std_logic_1164.all;
library SmartFusion2;
use SmartFusion2.all;

entity RAMBLOCK2048X16 is

    port( DATA     : in    std_logic_vector(15 downto 0);
          Q        : out   std_logic_vector(15 downto 0);
          WADDRESS : in    std_logic_vector(10 downto 0);
          RADDRESS : in    std_logic_vector(10 downto 0);
          WE       : in    std_logic;
          RE       : in    std_logic;
          WCLOCK   : in    std_logic;
          RCLOCK   : in    std_logic
        );

end RAMBLOCK2048X16;

architecture DEF_ARCH of RAMBLOCK2048X16 is 

  component RAM1K18
    generic (MEMORYFILE:string := "");

    port( A_DOUT        : out   std_logic_vector(17 downto 0);
          B_DOUT        : out   std_logic_vector(17 downto 0);
          BUSY          : out   std_logic;
          A_CLK         : in    std_logic := 'U';
          A_DOUT_CLK    : in    std_logic := 'U';
          A_ARST_N      : in    std_logic := 'U';
          A_DOUT_EN     : in    std_logic := 'U';
          A_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_DOUT_ARST_N : in    std_logic := 'U';
          A_DOUT_SRST_N : in    std_logic := 'U';
          A_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          A_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          A_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_CLK         : in    std_logic := 'U';
          B_DOUT_CLK    : in    std_logic := 'U';
          B_ARST_N      : in    std_logic := 'U';
          B_DOUT_EN     : in    std_logic := 'U';
          B_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_DOUT_ARST_N : in    std_logic := 'U';
          B_DOUT_SRST_N : in    std_logic := 'U';
          B_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          B_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          B_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_EN          : in    std_logic := 'U';
          A_DOUT_LAT    : in    std_logic := 'U';
          A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_WMODE       : in    std_logic := 'U';
          B_EN          : in    std_logic := 'U';
          B_DOUT_LAT    : in    std_logic := 'U';
          B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_WMODE       : in    std_logic := 'U';
          SII_LOCK      : in    std_logic := 'U'
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc47, nc34, nc9, nc13, nc23, nc55, nc33, nc16, nc26, 
        nc45, nc27, nc17, nc36, nc48, nc37, nc5, nc52, nc51, nc4, 
        nc42, nc41, nc25, nc15, nc35, nc49, nc28, nc18, nc38, nc1, 
        nc2, nc50, nc22, nc12, nc21, nc11, nc54, nc3, nc32, nc40, 
        nc31, nc44, nc7, nc6, nc19, nc29, nc53, nc39, nc8, nc43, 
        nc56, nc20, nc10, nc24, nc14, nc46, nc30 : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    RAMBLOCK2048X16_R0C1 : RAM1K18
      port map(A_DOUT(17) => nc47, A_DOUT(16) => nc34, A_DOUT(15)
         => nc9, A_DOUT(14) => nc13, A_DOUT(13) => nc23, 
        A_DOUT(12) => nc55, A_DOUT(11) => nc33, A_DOUT(10) => 
        nc16, A_DOUT(9) => nc26, A_DOUT(8) => nc45, A_DOUT(7) => 
        Q(15), A_DOUT(6) => Q(14), A_DOUT(5) => Q(13), A_DOUT(4)
         => Q(12), A_DOUT(3) => Q(11), A_DOUT(2) => Q(10), 
        A_DOUT(1) => Q(9), A_DOUT(0) => Q(8), B_DOUT(17) => nc27, 
        B_DOUT(16) => nc17, B_DOUT(15) => nc36, B_DOUT(14) => 
        nc48, B_DOUT(13) => nc37, B_DOUT(12) => nc5, B_DOUT(11)
         => nc52, B_DOUT(10) => nc51, B_DOUT(9) => nc4, B_DOUT(8)
         => nc42, B_DOUT(7) => nc41, B_DOUT(6) => nc25, B_DOUT(5)
         => nc15, B_DOUT(4) => nc35, B_DOUT(3) => nc49, B_DOUT(2)
         => nc28, B_DOUT(1) => nc18, B_DOUT(0) => nc38, BUSY => 
        OPEN, A_CLK => RCLOCK, A_DOUT_CLK => \VCC\, A_ARST_N => 
        \VCC\, A_DOUT_EN => \VCC\, A_BLK(2) => RE, A_BLK(1) => 
        \VCC\, A_BLK(0) => \VCC\, A_DOUT_ARST_N => \VCC\, 
        A_DOUT_SRST_N => \VCC\, A_DIN(17) => \GND\, A_DIN(16) => 
        \GND\, A_DIN(15) => \GND\, A_DIN(14) => \GND\, A_DIN(13)
         => \GND\, A_DIN(12) => \GND\, A_DIN(11) => \GND\, 
        A_DIN(10) => \GND\, A_DIN(9) => \GND\, A_DIN(8) => \GND\, 
        A_DIN(7) => \GND\, A_DIN(6) => \GND\, A_DIN(5) => \GND\, 
        A_DIN(4) => \GND\, A_DIN(3) => \GND\, A_DIN(2) => \GND\, 
        A_DIN(1) => \GND\, A_DIN(0) => \GND\, A_ADDR(13) => 
        RADDRESS(10), A_ADDR(12) => RADDRESS(9), A_ADDR(11) => 
        RADDRESS(8), A_ADDR(10) => RADDRESS(7), A_ADDR(9) => 
        RADDRESS(6), A_ADDR(8) => RADDRESS(5), A_ADDR(7) => 
        RADDRESS(4), A_ADDR(6) => RADDRESS(3), A_ADDR(5) => 
        RADDRESS(2), A_ADDR(4) => RADDRESS(1), A_ADDR(3) => 
        RADDRESS(0), A_ADDR(2) => \GND\, A_ADDR(1) => \GND\, 
        A_ADDR(0) => \GND\, A_WEN(1) => \GND\, A_WEN(0) => \GND\, 
        B_CLK => WCLOCK, B_DOUT_CLK => \VCC\, B_ARST_N => \VCC\, 
        B_DOUT_EN => \VCC\, B_BLK(2) => WE, B_BLK(1) => \VCC\, 
        B_BLK(0) => \VCC\, B_DOUT_ARST_N => \GND\, B_DOUT_SRST_N
         => \VCC\, B_DIN(17) => \GND\, B_DIN(16) => \GND\, 
        B_DIN(15) => \GND\, B_DIN(14) => \GND\, B_DIN(13) => 
        \GND\, B_DIN(12) => \GND\, B_DIN(11) => \GND\, B_DIN(10)
         => \GND\, B_DIN(9) => \GND\, B_DIN(8) => \GND\, B_DIN(7)
         => DATA(15), B_DIN(6) => DATA(14), B_DIN(5) => DATA(13), 
        B_DIN(4) => DATA(12), B_DIN(3) => DATA(11), B_DIN(2) => 
        DATA(10), B_DIN(1) => DATA(9), B_DIN(0) => DATA(8), 
        B_ADDR(13) => WADDRESS(10), B_ADDR(12) => WADDRESS(9), 
        B_ADDR(11) => WADDRESS(8), B_ADDR(10) => WADDRESS(7), 
        B_ADDR(9) => WADDRESS(6), B_ADDR(8) => WADDRESS(5), 
        B_ADDR(7) => WADDRESS(4), B_ADDR(6) => WADDRESS(3), 
        B_ADDR(5) => WADDRESS(2), B_ADDR(4) => WADDRESS(1), 
        B_ADDR(3) => WADDRESS(0), B_ADDR(2) => \GND\, B_ADDR(1)
         => \GND\, B_ADDR(0) => \GND\, B_WEN(1) => \GND\, 
        B_WEN(0) => \VCC\, A_EN => \VCC\, A_DOUT_LAT => \VCC\, 
        A_WIDTH(2) => \GND\, A_WIDTH(1) => \VCC\, A_WIDTH(0) => 
        \VCC\, A_WMODE => \GND\, B_EN => \VCC\, B_DOUT_LAT => 
        \VCC\, B_WIDTH(2) => \GND\, B_WIDTH(1) => \VCC\, 
        B_WIDTH(0) => \VCC\, B_WMODE => \GND\, SII_LOCK => \GND\);
    
    RAMBLOCK2048X16_R0C0 : RAM1K18
      port map(A_DOUT(17) => nc1, A_DOUT(16) => nc2, A_DOUT(15)
         => nc50, A_DOUT(14) => nc22, A_DOUT(13) => nc12, 
        A_DOUT(12) => nc21, A_DOUT(11) => nc11, A_DOUT(10) => 
        nc54, A_DOUT(9) => nc3, A_DOUT(8) => nc32, A_DOUT(7) => 
        Q(7), A_DOUT(6) => Q(6), A_DOUT(5) => Q(5), A_DOUT(4) => 
        Q(4), A_DOUT(3) => Q(3), A_DOUT(2) => Q(2), A_DOUT(1) => 
        Q(1), A_DOUT(0) => Q(0), B_DOUT(17) => nc40, B_DOUT(16)
         => nc31, B_DOUT(15) => nc44, B_DOUT(14) => nc7, 
        B_DOUT(13) => nc6, B_DOUT(12) => nc19, B_DOUT(11) => nc29, 
        B_DOUT(10) => nc53, B_DOUT(9) => nc39, B_DOUT(8) => nc8, 
        B_DOUT(7) => nc43, B_DOUT(6) => nc56, B_DOUT(5) => nc20, 
        B_DOUT(4) => nc10, B_DOUT(3) => nc24, B_DOUT(2) => nc14, 
        B_DOUT(1) => nc46, B_DOUT(0) => nc30, BUSY => OPEN, A_CLK
         => RCLOCK, A_DOUT_CLK => \VCC\, A_ARST_N => \VCC\, 
        A_DOUT_EN => \VCC\, A_BLK(2) => RE, A_BLK(1) => \VCC\, 
        A_BLK(0) => \VCC\, A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N
         => \VCC\, A_DIN(17) => \GND\, A_DIN(16) => \GND\, 
        A_DIN(15) => \GND\, A_DIN(14) => \GND\, A_DIN(13) => 
        \GND\, A_DIN(12) => \GND\, A_DIN(11) => \GND\, A_DIN(10)
         => \GND\, A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7)
         => \GND\, A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4)
         => \GND\, A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1)
         => \GND\, A_DIN(0) => \GND\, A_ADDR(13) => RADDRESS(10), 
        A_ADDR(12) => RADDRESS(9), A_ADDR(11) => RADDRESS(8), 
        A_ADDR(10) => RADDRESS(7), A_ADDR(9) => RADDRESS(6), 
        A_ADDR(8) => RADDRESS(5), A_ADDR(7) => RADDRESS(4), 
        A_ADDR(6) => RADDRESS(3), A_ADDR(5) => RADDRESS(2), 
        A_ADDR(4) => RADDRESS(1), A_ADDR(3) => RADDRESS(0), 
        A_ADDR(2) => \GND\, A_ADDR(1) => \GND\, A_ADDR(0) => 
        \GND\, A_WEN(1) => \GND\, A_WEN(0) => \GND\, B_CLK => 
        WCLOCK, B_DOUT_CLK => \VCC\, B_ARST_N => \VCC\, B_DOUT_EN
         => \VCC\, B_BLK(2) => WE, B_BLK(1) => \VCC\, B_BLK(0)
         => \VCC\, B_DOUT_ARST_N => \GND\, B_DOUT_SRST_N => \VCC\, 
        B_DIN(17) => \GND\, B_DIN(16) => \GND\, B_DIN(15) => 
        \GND\, B_DIN(14) => \GND\, B_DIN(13) => \GND\, B_DIN(12)
         => \GND\, B_DIN(11) => \GND\, B_DIN(10) => \GND\, 
        B_DIN(9) => \GND\, B_DIN(8) => \GND\, B_DIN(7) => DATA(7), 
        B_DIN(6) => DATA(6), B_DIN(5) => DATA(5), B_DIN(4) => 
        DATA(4), B_DIN(3) => DATA(3), B_DIN(2) => DATA(2), 
        B_DIN(1) => DATA(1), B_DIN(0) => DATA(0), B_ADDR(13) => 
        WADDRESS(10), B_ADDR(12) => WADDRESS(9), B_ADDR(11) => 
        WADDRESS(8), B_ADDR(10) => WADDRESS(7), B_ADDR(9) => 
        WADDRESS(6), B_ADDR(8) => WADDRESS(5), B_ADDR(7) => 
        WADDRESS(4), B_ADDR(6) => WADDRESS(3), B_ADDR(5) => 
        WADDRESS(2), B_ADDR(4) => WADDRESS(1), B_ADDR(3) => 
        WADDRESS(0), B_ADDR(2) => \GND\, B_ADDR(1) => \GND\, 
        B_ADDR(0) => \GND\, B_WEN(1) => \GND\, B_WEN(0) => \VCC\, 
        A_EN => \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2) => \GND\, 
        A_WIDTH(1) => \VCC\, A_WIDTH(0) => \VCC\, A_WMODE => 
        \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => 
        \GND\, B_WIDTH(1) => \VCC\, B_WIDTH(0) => \VCC\, B_WMODE
         => \GND\, SII_LOCK => \GND\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 
-- Version: v11.1 SP2 11.1.2.11

library ieee;
use ieee.std_logic_1164.all;
library SmartFusion2;
use SmartFusion2.all;

entity RAMBLOCK2048X32 is

    port( DATA     : in    std_logic_vector(31 downto 0);
          Q        : out   std_logic_vector(31 downto 0);
          WADDRESS : in    std_logic_vector(10 downto 0);
          RADDRESS : in    std_logic_vector(10 downto 0);
          WE       : in    std_logic;
          RE       : in    std_logic;
          WCLOCK   : in    std_logic;
          RCLOCK   : in    std_logic
        );

end RAMBLOCK2048X32;

architecture DEF_ARCH of RAMBLOCK2048X32 is 

  component RAM1K18
    generic (MEMORYFILE:string := "");

    port( A_DOUT        : out   std_logic_vector(17 downto 0);
          B_DOUT        : out   std_logic_vector(17 downto 0);
          BUSY          : out   std_logic;
          A_CLK         : in    std_logic := 'U';
          A_DOUT_CLK    : in    std_logic := 'U';
          A_ARST_N      : in    std_logic := 'U';
          A_DOUT_EN     : in    std_logic := 'U';
          A_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_DOUT_ARST_N : in    std_logic := 'U';
          A_DOUT_SRST_N : in    std_logic := 'U';
          A_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          A_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          A_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_CLK         : in    std_logic := 'U';
          B_DOUT_CLK    : in    std_logic := 'U';
          B_ARST_N      : in    std_logic := 'U';
          B_DOUT_EN     : in    std_logic := 'U';
          B_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_DOUT_ARST_N : in    std_logic := 'U';
          B_DOUT_SRST_N : in    std_logic := 'U';
          B_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          B_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          B_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_EN          : in    std_logic := 'U';
          A_DOUT_LAT    : in    std_logic := 'U';
          A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_WMODE       : in    std_logic := 'U';
          B_EN          : in    std_logic := 'U';
          B_DOUT_LAT    : in    std_logic := 'U';
          B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_WMODE       : in    std_logic := 'U';
          SII_LOCK      : in    std_logic := 'U'
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc47, nc111, nc34, nc98, nc89, nc70, nc60, nc105, nc74, 
        nc64, nc110, nc9, nc92, nc91, nc13, nc23, nc55, nc80, 
        nc33, nc84, nc16, nc26, nc45, nc73, nc58, nc63, nc27, 
        nc17, nc99, nc36, nc48, nc37, nc5, nc103, nc101, nc52, 
        nc76, nc51, nc66, nc77, nc67, nc4, nc109, nc42, nc100, 
        nc83, nc41, nc90, nc94, nc112, nc86, nc59, nc25, nc15, 
        nc87, nc35, nc49, nc28, nc18, nc107, nc106, nc75, nc65, 
        nc38, nc93, nc1, nc2, nc50, nc22, nc12, nc21, nc11, nc78, 
        nc54, nc68, nc3, nc32, nc104, nc40, nc31, nc96, nc44, nc7, 
        nc97, nc85, nc72, nc6, nc71, nc62, nc61, nc102, nc19, 
        nc29, nc88, nc53, nc39, nc8, nc82, nc108, nc81, nc79, 
        nc43, nc69, nc56, nc20, nc10, nc57, nc95, nc24, nc14, 
        nc46, nc30 : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    RAMBLOCK2048X32_R0C2 : RAM1K18
      port map(A_DOUT(17) => nc47, A_DOUT(16) => nc111, 
        A_DOUT(15) => nc34, A_DOUT(14) => nc98, A_DOUT(13) => 
        nc89, A_DOUT(12) => nc70, A_DOUT(11) => nc60, A_DOUT(10)
         => nc105, A_DOUT(9) => nc74, A_DOUT(8) => nc64, 
        A_DOUT(7) => Q(23), A_DOUT(6) => Q(22), A_DOUT(5) => 
        Q(21), A_DOUT(4) => Q(20), A_DOUT(3) => Q(19), A_DOUT(2)
         => Q(18), A_DOUT(1) => Q(17), A_DOUT(0) => Q(16), 
        B_DOUT(17) => nc110, B_DOUT(16) => nc9, B_DOUT(15) => 
        nc92, B_DOUT(14) => nc91, B_DOUT(13) => nc13, B_DOUT(12)
         => nc23, B_DOUT(11) => nc55, B_DOUT(10) => nc80, 
        B_DOUT(9) => nc33, B_DOUT(8) => nc84, B_DOUT(7) => nc16, 
        B_DOUT(6) => nc26, B_DOUT(5) => nc45, B_DOUT(4) => nc73, 
        B_DOUT(3) => nc58, B_DOUT(2) => nc63, B_DOUT(1) => nc27, 
        B_DOUT(0) => nc17, BUSY => OPEN, A_CLK => RCLOCK, 
        A_DOUT_CLK => \VCC\, A_ARST_N => \VCC\, A_DOUT_EN => 
        \VCC\, A_BLK(2) => RE, A_BLK(1) => \VCC\, A_BLK(0) => 
        \VCC\, A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N => \VCC\, 
        A_DIN(17) => \GND\, A_DIN(16) => \GND\, A_DIN(15) => 
        \GND\, A_DIN(14) => \GND\, A_DIN(13) => \GND\, A_DIN(12)
         => \GND\, A_DIN(11) => \GND\, A_DIN(10) => \GND\, 
        A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7) => \GND\, 
        A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4) => \GND\, 
        A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1) => \GND\, 
        A_DIN(0) => \GND\, A_ADDR(13) => RADDRESS(10), A_ADDR(12)
         => RADDRESS(9), A_ADDR(11) => RADDRESS(8), A_ADDR(10)
         => RADDRESS(7), A_ADDR(9) => RADDRESS(6), A_ADDR(8) => 
        RADDRESS(5), A_ADDR(7) => RADDRESS(4), A_ADDR(6) => 
        RADDRESS(3), A_ADDR(5) => RADDRESS(2), A_ADDR(4) => 
        RADDRESS(1), A_ADDR(3) => RADDRESS(0), A_ADDR(2) => \GND\, 
        A_ADDR(1) => \GND\, A_ADDR(0) => \GND\, A_WEN(1) => \GND\, 
        A_WEN(0) => \GND\, B_CLK => WCLOCK, B_DOUT_CLK => \VCC\, 
        B_ARST_N => \VCC\, B_DOUT_EN => \VCC\, B_BLK(2) => WE, 
        B_BLK(1) => \VCC\, B_BLK(0) => \VCC\, B_DOUT_ARST_N => 
        \GND\, B_DOUT_SRST_N => \VCC\, B_DIN(17) => \GND\, 
        B_DIN(16) => \GND\, B_DIN(15) => \GND\, B_DIN(14) => 
        \GND\, B_DIN(13) => \GND\, B_DIN(12) => \GND\, B_DIN(11)
         => \GND\, B_DIN(10) => \GND\, B_DIN(9) => \GND\, 
        B_DIN(8) => \GND\, B_DIN(7) => DATA(23), B_DIN(6) => 
        DATA(22), B_DIN(5) => DATA(21), B_DIN(4) => DATA(20), 
        B_DIN(3) => DATA(19), B_DIN(2) => DATA(18), B_DIN(1) => 
        DATA(17), B_DIN(0) => DATA(16), B_ADDR(13) => 
        WADDRESS(10), B_ADDR(12) => WADDRESS(9), B_ADDR(11) => 
        WADDRESS(8), B_ADDR(10) => WADDRESS(7), B_ADDR(9) => 
        WADDRESS(6), B_ADDR(8) => WADDRESS(5), B_ADDR(7) => 
        WADDRESS(4), B_ADDR(6) => WADDRESS(3), B_ADDR(5) => 
        WADDRESS(2), B_ADDR(4) => WADDRESS(1), B_ADDR(3) => 
        WADDRESS(0), B_ADDR(2) => \GND\, B_ADDR(1) => \GND\, 
        B_ADDR(0) => \GND\, B_WEN(1) => \GND\, B_WEN(0) => \VCC\, 
        A_EN => \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2) => \GND\, 
        A_WIDTH(1) => \VCC\, A_WIDTH(0) => \VCC\, A_WMODE => 
        \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => 
        \GND\, B_WIDTH(1) => \VCC\, B_WIDTH(0) => \VCC\, B_WMODE
         => \GND\, SII_LOCK => \GND\);
    
    RAMBLOCK2048X32_R0C0 : RAM1K18
      port map(A_DOUT(17) => nc99, A_DOUT(16) => nc36, A_DOUT(15)
         => nc48, A_DOUT(14) => nc37, A_DOUT(13) => nc5, 
        A_DOUT(12) => nc103, A_DOUT(11) => nc101, A_DOUT(10) => 
        nc52, A_DOUT(9) => nc76, A_DOUT(8) => nc51, A_DOUT(7) => 
        Q(7), A_DOUT(6) => Q(6), A_DOUT(5) => Q(5), A_DOUT(4) => 
        Q(4), A_DOUT(3) => Q(3), A_DOUT(2) => Q(2), A_DOUT(1) => 
        Q(1), A_DOUT(0) => Q(0), B_DOUT(17) => nc66, B_DOUT(16)
         => nc77, B_DOUT(15) => nc67, B_DOUT(14) => nc4, 
        B_DOUT(13) => nc109, B_DOUT(12) => nc42, B_DOUT(11) => 
        nc100, B_DOUT(10) => nc83, B_DOUT(9) => nc41, B_DOUT(8)
         => nc90, B_DOUT(7) => nc94, B_DOUT(6) => nc112, 
        B_DOUT(5) => nc86, B_DOUT(4) => nc59, B_DOUT(3) => nc25, 
        B_DOUT(2) => nc15, B_DOUT(1) => nc87, B_DOUT(0) => nc35, 
        BUSY => OPEN, A_CLK => RCLOCK, A_DOUT_CLK => \VCC\, 
        A_ARST_N => \VCC\, A_DOUT_EN => \VCC\, A_BLK(2) => RE, 
        A_BLK(1) => \VCC\, A_BLK(0) => \VCC\, A_DOUT_ARST_N => 
        \VCC\, A_DOUT_SRST_N => \VCC\, A_DIN(17) => \GND\, 
        A_DIN(16) => \GND\, A_DIN(15) => \GND\, A_DIN(14) => 
        \GND\, A_DIN(13) => \GND\, A_DIN(12) => \GND\, A_DIN(11)
         => \GND\, A_DIN(10) => \GND\, A_DIN(9) => \GND\, 
        A_DIN(8) => \GND\, A_DIN(7) => \GND\, A_DIN(6) => \GND\, 
        A_DIN(5) => \GND\, A_DIN(4) => \GND\, A_DIN(3) => \GND\, 
        A_DIN(2) => \GND\, A_DIN(1) => \GND\, A_DIN(0) => \GND\, 
        A_ADDR(13) => RADDRESS(10), A_ADDR(12) => RADDRESS(9), 
        A_ADDR(11) => RADDRESS(8), A_ADDR(10) => RADDRESS(7), 
        A_ADDR(9) => RADDRESS(6), A_ADDR(8) => RADDRESS(5), 
        A_ADDR(7) => RADDRESS(4), A_ADDR(6) => RADDRESS(3), 
        A_ADDR(5) => RADDRESS(2), A_ADDR(4) => RADDRESS(1), 
        A_ADDR(3) => RADDRESS(0), A_ADDR(2) => \GND\, A_ADDR(1)
         => \GND\, A_ADDR(0) => \GND\, A_WEN(1) => \GND\, 
        A_WEN(0) => \GND\, B_CLK => WCLOCK, B_DOUT_CLK => \VCC\, 
        B_ARST_N => \VCC\, B_DOUT_EN => \VCC\, B_BLK(2) => WE, 
        B_BLK(1) => \VCC\, B_BLK(0) => \VCC\, B_DOUT_ARST_N => 
        \GND\, B_DOUT_SRST_N => \VCC\, B_DIN(17) => \GND\, 
        B_DIN(16) => \GND\, B_DIN(15) => \GND\, B_DIN(14) => 
        \GND\, B_DIN(13) => \GND\, B_DIN(12) => \GND\, B_DIN(11)
         => \GND\, B_DIN(10) => \GND\, B_DIN(9) => \GND\, 
        B_DIN(8) => \GND\, B_DIN(7) => DATA(7), B_DIN(6) => 
        DATA(6), B_DIN(5) => DATA(5), B_DIN(4) => DATA(4), 
        B_DIN(3) => DATA(3), B_DIN(2) => DATA(2), B_DIN(1) => 
        DATA(1), B_DIN(0) => DATA(0), B_ADDR(13) => WADDRESS(10), 
        B_ADDR(12) => WADDRESS(9), B_ADDR(11) => WADDRESS(8), 
        B_ADDR(10) => WADDRESS(7), B_ADDR(9) => WADDRESS(6), 
        B_ADDR(8) => WADDRESS(5), B_ADDR(7) => WADDRESS(4), 
        B_ADDR(6) => WADDRESS(3), B_ADDR(5) => WADDRESS(2), 
        B_ADDR(4) => WADDRESS(1), B_ADDR(3) => WADDRESS(0), 
        B_ADDR(2) => \GND\, B_ADDR(1) => \GND\, B_ADDR(0) => 
        \GND\, B_WEN(1) => \GND\, B_WEN(0) => \VCC\, A_EN => 
        \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2) => \GND\, 
        A_WIDTH(1) => \VCC\, A_WIDTH(0) => \VCC\, A_WMODE => 
        \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => 
        \GND\, B_WIDTH(1) => \VCC\, B_WIDTH(0) => \VCC\, B_WMODE
         => \GND\, SII_LOCK => \GND\);
    
    RAMBLOCK2048X32_R0C1 : RAM1K18
      port map(A_DOUT(17) => nc49, A_DOUT(16) => nc28, A_DOUT(15)
         => nc18, A_DOUT(14) => nc107, A_DOUT(13) => nc106, 
        A_DOUT(12) => nc75, A_DOUT(11) => nc65, A_DOUT(10) => 
        nc38, A_DOUT(9) => nc93, A_DOUT(8) => nc1, A_DOUT(7) => 
        Q(15), A_DOUT(6) => Q(14), A_DOUT(5) => Q(13), A_DOUT(4)
         => Q(12), A_DOUT(3) => Q(11), A_DOUT(2) => Q(10), 
        A_DOUT(1) => Q(9), A_DOUT(0) => Q(8), B_DOUT(17) => nc2, 
        B_DOUT(16) => nc50, B_DOUT(15) => nc22, B_DOUT(14) => 
        nc12, B_DOUT(13) => nc21, B_DOUT(12) => nc11, B_DOUT(11)
         => nc78, B_DOUT(10) => nc54, B_DOUT(9) => nc68, 
        B_DOUT(8) => nc3, B_DOUT(7) => nc32, B_DOUT(6) => nc104, 
        B_DOUT(5) => nc40, B_DOUT(4) => nc31, B_DOUT(3) => nc96, 
        B_DOUT(2) => nc44, B_DOUT(1) => nc7, B_DOUT(0) => nc97, 
        BUSY => OPEN, A_CLK => RCLOCK, A_DOUT_CLK => \VCC\, 
        A_ARST_N => \VCC\, A_DOUT_EN => \VCC\, A_BLK(2) => RE, 
        A_BLK(1) => \VCC\, A_BLK(0) => \VCC\, A_DOUT_ARST_N => 
        \VCC\, A_DOUT_SRST_N => \VCC\, A_DIN(17) => \GND\, 
        A_DIN(16) => \GND\, A_DIN(15) => \GND\, A_DIN(14) => 
        \GND\, A_DIN(13) => \GND\, A_DIN(12) => \GND\, A_DIN(11)
         => \GND\, A_DIN(10) => \GND\, A_DIN(9) => \GND\, 
        A_DIN(8) => \GND\, A_DIN(7) => \GND\, A_DIN(6) => \GND\, 
        A_DIN(5) => \GND\, A_DIN(4) => \GND\, A_DIN(3) => \GND\, 
        A_DIN(2) => \GND\, A_DIN(1) => \GND\, A_DIN(0) => \GND\, 
        A_ADDR(13) => RADDRESS(10), A_ADDR(12) => RADDRESS(9), 
        A_ADDR(11) => RADDRESS(8), A_ADDR(10) => RADDRESS(7), 
        A_ADDR(9) => RADDRESS(6), A_ADDR(8) => RADDRESS(5), 
        A_ADDR(7) => RADDRESS(4), A_ADDR(6) => RADDRESS(3), 
        A_ADDR(5) => RADDRESS(2), A_ADDR(4) => RADDRESS(1), 
        A_ADDR(3) => RADDRESS(0), A_ADDR(2) => \GND\, A_ADDR(1)
         => \GND\, A_ADDR(0) => \GND\, A_WEN(1) => \GND\, 
        A_WEN(0) => \GND\, B_CLK => WCLOCK, B_DOUT_CLK => \VCC\, 
        B_ARST_N => \VCC\, B_DOUT_EN => \VCC\, B_BLK(2) => WE, 
        B_BLK(1) => \VCC\, B_BLK(0) => \VCC\, B_DOUT_ARST_N => 
        \GND\, B_DOUT_SRST_N => \VCC\, B_DIN(17) => \GND\, 
        B_DIN(16) => \GND\, B_DIN(15) => \GND\, B_DIN(14) => 
        \GND\, B_DIN(13) => \GND\, B_DIN(12) => \GND\, B_DIN(11)
         => \GND\, B_DIN(10) => \GND\, B_DIN(9) => \GND\, 
        B_DIN(8) => \GND\, B_DIN(7) => DATA(15), B_DIN(6) => 
        DATA(14), B_DIN(5) => DATA(13), B_DIN(4) => DATA(12), 
        B_DIN(3) => DATA(11), B_DIN(2) => DATA(10), B_DIN(1) => 
        DATA(9), B_DIN(0) => DATA(8), B_ADDR(13) => WADDRESS(10), 
        B_ADDR(12) => WADDRESS(9), B_ADDR(11) => WADDRESS(8), 
        B_ADDR(10) => WADDRESS(7), B_ADDR(9) => WADDRESS(6), 
        B_ADDR(8) => WADDRESS(5), B_ADDR(7) => WADDRESS(4), 
        B_ADDR(6) => WADDRESS(3), B_ADDR(5) => WADDRESS(2), 
        B_ADDR(4) => WADDRESS(1), B_ADDR(3) => WADDRESS(0), 
        B_ADDR(2) => \GND\, B_ADDR(1) => \GND\, B_ADDR(0) => 
        \GND\, B_WEN(1) => \GND\, B_WEN(0) => \VCC\, A_EN => 
        \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2) => \GND\, 
        A_WIDTH(1) => \VCC\, A_WIDTH(0) => \VCC\, A_WMODE => 
        \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => 
        \GND\, B_WIDTH(1) => \VCC\, B_WIDTH(0) => \VCC\, B_WMODE
         => \GND\, SII_LOCK => \GND\);
    
    RAMBLOCK2048X32_R0C3 : RAM1K18
      port map(A_DOUT(17) => nc85, A_DOUT(16) => nc72, A_DOUT(15)
         => nc6, A_DOUT(14) => nc71, A_DOUT(13) => nc62, 
        A_DOUT(12) => nc61, A_DOUT(11) => nc102, A_DOUT(10) => 
        nc19, A_DOUT(9) => nc29, A_DOUT(8) => nc88, A_DOUT(7) => 
        Q(31), A_DOUT(6) => Q(30), A_DOUT(5) => Q(29), A_DOUT(4)
         => Q(28), A_DOUT(3) => Q(27), A_DOUT(2) => Q(26), 
        A_DOUT(1) => Q(25), A_DOUT(0) => Q(24), B_DOUT(17) => 
        nc53, B_DOUT(16) => nc39, B_DOUT(15) => nc8, B_DOUT(14)
         => nc82, B_DOUT(13) => nc108, B_DOUT(12) => nc81, 
        B_DOUT(11) => nc79, B_DOUT(10) => nc43, B_DOUT(9) => nc69, 
        B_DOUT(8) => nc56, B_DOUT(7) => nc20, B_DOUT(6) => nc10, 
        B_DOUT(5) => nc57, B_DOUT(4) => nc95, B_DOUT(3) => nc24, 
        B_DOUT(2) => nc14, B_DOUT(1) => nc46, B_DOUT(0) => nc30, 
        BUSY => OPEN, A_CLK => RCLOCK, A_DOUT_CLK => \VCC\, 
        A_ARST_N => \VCC\, A_DOUT_EN => \VCC\, A_BLK(2) => RE, 
        A_BLK(1) => \VCC\, A_BLK(0) => \VCC\, A_DOUT_ARST_N => 
        \VCC\, A_DOUT_SRST_N => \VCC\, A_DIN(17) => \GND\, 
        A_DIN(16) => \GND\, A_DIN(15) => \GND\, A_DIN(14) => 
        \GND\, A_DIN(13) => \GND\, A_DIN(12) => \GND\, A_DIN(11)
         => \GND\, A_DIN(10) => \GND\, A_DIN(9) => \GND\, 
        A_DIN(8) => \GND\, A_DIN(7) => \GND\, A_DIN(6) => \GND\, 
        A_DIN(5) => \GND\, A_DIN(4) => \GND\, A_DIN(3) => \GND\, 
        A_DIN(2) => \GND\, A_DIN(1) => \GND\, A_DIN(0) => \GND\, 
        A_ADDR(13) => RADDRESS(10), A_ADDR(12) => RADDRESS(9), 
        A_ADDR(11) => RADDRESS(8), A_ADDR(10) => RADDRESS(7), 
        A_ADDR(9) => RADDRESS(6), A_ADDR(8) => RADDRESS(5), 
        A_ADDR(7) => RADDRESS(4), A_ADDR(6) => RADDRESS(3), 
        A_ADDR(5) => RADDRESS(2), A_ADDR(4) => RADDRESS(1), 
        A_ADDR(3) => RADDRESS(0), A_ADDR(2) => \GND\, A_ADDR(1)
         => \GND\, A_ADDR(0) => \GND\, A_WEN(1) => \GND\, 
        A_WEN(0) => \GND\, B_CLK => WCLOCK, B_DOUT_CLK => \VCC\, 
        B_ARST_N => \VCC\, B_DOUT_EN => \VCC\, B_BLK(2) => WE, 
        B_BLK(1) => \VCC\, B_BLK(0) => \VCC\, B_DOUT_ARST_N => 
        \GND\, B_DOUT_SRST_N => \VCC\, B_DIN(17) => \GND\, 
        B_DIN(16) => \GND\, B_DIN(15) => \GND\, B_DIN(14) => 
        \GND\, B_DIN(13) => \GND\, B_DIN(12) => \GND\, B_DIN(11)
         => \GND\, B_DIN(10) => \GND\, B_DIN(9) => \GND\, 
        B_DIN(8) => \GND\, B_DIN(7) => DATA(31), B_DIN(6) => 
        DATA(30), B_DIN(5) => DATA(29), B_DIN(4) => DATA(28), 
        B_DIN(3) => DATA(27), B_DIN(2) => DATA(26), B_DIN(1) => 
        DATA(25), B_DIN(0) => DATA(24), B_ADDR(13) => 
        WADDRESS(10), B_ADDR(12) => WADDRESS(9), B_ADDR(11) => 
        WADDRESS(8), B_ADDR(10) => WADDRESS(7), B_ADDR(9) => 
        WADDRESS(6), B_ADDR(8) => WADDRESS(5), B_ADDR(7) => 
        WADDRESS(4), B_ADDR(6) => WADDRESS(3), B_ADDR(5) => 
        WADDRESS(2), B_ADDR(4) => WADDRESS(1), B_ADDR(3) => 
        WADDRESS(0), B_ADDR(2) => \GND\, B_ADDR(1) => \GND\, 
        B_ADDR(0) => \GND\, B_WEN(1) => \GND\, B_WEN(0) => \VCC\, 
        A_EN => \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2) => \GND\, 
        A_WIDTH(1) => \VCC\, A_WIDTH(0) => \VCC\, A_WMODE => 
        \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => 
        \GND\, B_WIDTH(1) => \VCC\, B_WIDTH(0) => \VCC\, B_WMODE
         => \GND\, SII_LOCK => \GND\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 
-- Version: v11.1 SP2 11.1.2.11

library ieee;
use ieee.std_logic_1164.all;
library SmartFusion2;
use SmartFusion2.all;

entity RAMBLOCK2048X8 is

    port( DATA     : in    std_logic_vector(7 downto 0);
          Q        : out   std_logic_vector(7 downto 0);
          WADDRESS : in    std_logic_vector(10 downto 0);
          RADDRESS : in    std_logic_vector(10 downto 0);
          WE       : in    std_logic;
          RE       : in    std_logic;
          WCLOCK   : in    std_logic;
          RCLOCK   : in    std_logic
        );

end RAMBLOCK2048X8;

architecture DEF_ARCH of RAMBLOCK2048X8 is 

  component RAM1K18
    generic (MEMORYFILE:string := "");

    port( A_DOUT        : out   std_logic_vector(17 downto 0);
          B_DOUT        : out   std_logic_vector(17 downto 0);
          BUSY          : out   std_logic;
          A_CLK         : in    std_logic := 'U';
          A_DOUT_CLK    : in    std_logic := 'U';
          A_ARST_N      : in    std_logic := 'U';
          A_DOUT_EN     : in    std_logic := 'U';
          A_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_DOUT_ARST_N : in    std_logic := 'U';
          A_DOUT_SRST_N : in    std_logic := 'U';
          A_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          A_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          A_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_CLK         : in    std_logic := 'U';
          B_DOUT_CLK    : in    std_logic := 'U';
          B_ARST_N      : in    std_logic := 'U';
          B_DOUT_EN     : in    std_logic := 'U';
          B_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_DOUT_ARST_N : in    std_logic := 'U';
          B_DOUT_SRST_N : in    std_logic := 'U';
          B_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          B_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          B_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_EN          : in    std_logic := 'U';
          A_DOUT_LAT    : in    std_logic := 'U';
          A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_WMODE       : in    std_logic := 'U';
          B_EN          : in    std_logic := 'U';
          B_DOUT_LAT    : in    std_logic := 'U';
          B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_WMODE       : in    std_logic := 'U';
          SII_LOCK      : in    std_logic := 'U'
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc24, nc1, nc8, nc13, nc16, nc19, nc25, nc20, nc27, 
        nc9, nc22, nc28, nc14, nc5, nc21, nc15, nc3, nc10, nc7, 
        nc17, nc4, nc12, nc2, nc23, nc18, nc26, nc6, nc11
         : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    RAMBLOCK2048X8_R0C0 : RAM1K18
      port map(A_DOUT(17) => nc24, A_DOUT(16) => nc1, A_DOUT(15)
         => nc8, A_DOUT(14) => nc13, A_DOUT(13) => nc16, 
        A_DOUT(12) => nc19, A_DOUT(11) => nc25, A_DOUT(10) => 
        nc20, A_DOUT(9) => nc27, A_DOUT(8) => nc9, A_DOUT(7) => 
        Q(7), A_DOUT(6) => Q(6), A_DOUT(5) => Q(5), A_DOUT(4) => 
        Q(4), A_DOUT(3) => Q(3), A_DOUT(2) => Q(2), A_DOUT(1) => 
        Q(1), A_DOUT(0) => Q(0), B_DOUT(17) => nc22, B_DOUT(16)
         => nc28, B_DOUT(15) => nc14, B_DOUT(14) => nc5, 
        B_DOUT(13) => nc21, B_DOUT(12) => nc15, B_DOUT(11) => nc3, 
        B_DOUT(10) => nc10, B_DOUT(9) => nc7, B_DOUT(8) => nc17, 
        B_DOUT(7) => nc4, B_DOUT(6) => nc12, B_DOUT(5) => nc2, 
        B_DOUT(4) => nc23, B_DOUT(3) => nc18, B_DOUT(2) => nc26, 
        B_DOUT(1) => nc6, B_DOUT(0) => nc11, BUSY => OPEN, A_CLK
         => RCLOCK, A_DOUT_CLK => \VCC\, A_ARST_N => \VCC\, 
        A_DOUT_EN => \VCC\, A_BLK(2) => RE, A_BLK(1) => \VCC\, 
        A_BLK(0) => \VCC\, A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N
         => \VCC\, A_DIN(17) => \GND\, A_DIN(16) => \GND\, 
        A_DIN(15) => \GND\, A_DIN(14) => \GND\, A_DIN(13) => 
        \GND\, A_DIN(12) => \GND\, A_DIN(11) => \GND\, A_DIN(10)
         => \GND\, A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7)
         => \GND\, A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4)
         => \GND\, A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1)
         => \GND\, A_DIN(0) => \GND\, A_ADDR(13) => RADDRESS(10), 
        A_ADDR(12) => RADDRESS(9), A_ADDR(11) => RADDRESS(8), 
        A_ADDR(10) => RADDRESS(7), A_ADDR(9) => RADDRESS(6), 
        A_ADDR(8) => RADDRESS(5), A_ADDR(7) => RADDRESS(4), 
        A_ADDR(6) => RADDRESS(3), A_ADDR(5) => RADDRESS(2), 
        A_ADDR(4) => RADDRESS(1), A_ADDR(3) => RADDRESS(0), 
        A_ADDR(2) => \GND\, A_ADDR(1) => \GND\, A_ADDR(0) => 
        \GND\, A_WEN(1) => \GND\, A_WEN(0) => \GND\, B_CLK => 
        WCLOCK, B_DOUT_CLK => \VCC\, B_ARST_N => \VCC\, B_DOUT_EN
         => \VCC\, B_BLK(2) => WE, B_BLK(1) => \VCC\, B_BLK(0)
         => \VCC\, B_DOUT_ARST_N => \GND\, B_DOUT_SRST_N => \VCC\, 
        B_DIN(17) => \GND\, B_DIN(16) => \GND\, B_DIN(15) => 
        \GND\, B_DIN(14) => \GND\, B_DIN(13) => \GND\, B_DIN(12)
         => \GND\, B_DIN(11) => \GND\, B_DIN(10) => \GND\, 
        B_DIN(9) => \GND\, B_DIN(8) => \GND\, B_DIN(7) => DATA(7), 
        B_DIN(6) => DATA(6), B_DIN(5) => DATA(5), B_DIN(4) => 
        DATA(4), B_DIN(3) => DATA(3), B_DIN(2) => DATA(2), 
        B_DIN(1) => DATA(1), B_DIN(0) => DATA(0), B_ADDR(13) => 
        WADDRESS(10), B_ADDR(12) => WADDRESS(9), B_ADDR(11) => 
        WADDRESS(8), B_ADDR(10) => WADDRESS(7), B_ADDR(9) => 
        WADDRESS(6), B_ADDR(8) => WADDRESS(5), B_ADDR(7) => 
        WADDRESS(4), B_ADDR(6) => WADDRESS(3), B_ADDR(5) => 
        WADDRESS(2), B_ADDR(4) => WADDRESS(1), B_ADDR(3) => 
        WADDRESS(0), B_ADDR(2) => \GND\, B_ADDR(1) => \GND\, 
        B_ADDR(0) => \GND\, B_WEN(1) => \GND\, B_WEN(0) => \VCC\, 
        A_EN => \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2) => \GND\, 
        A_WIDTH(1) => \VCC\, A_WIDTH(0) => \VCC\, A_WMODE => 
        \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => 
        \GND\, B_WIDTH(1) => \VCC\, B_WIDTH(0) => \VCC\, B_WMODE
         => \GND\, SII_LOCK => \GND\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 
-- Version: v11.1 SP2 11.1.2.11

-- Version: v11.1 SP2 11.1.2.11

library ieee;
use ieee.std_logic_1164.all;
library SmartFusion2;
use SmartFusion2.all;

entity RAMBLOCK256X16 is

    port( DATA     : in    std_logic_vector(15 downto 0);
          Q        : out   std_logic_vector(15 downto 0);
          WADDRESS : in    std_logic_vector(7 downto 0);
          RADDRESS : in    std_logic_vector(7 downto 0);
          WE       : in    std_logic;
          RE       : in    std_logic;
          WCLOCK   : in    std_logic;
          RCLOCK   : in    std_logic
        );

end RAMBLOCK256X16;

architecture DEF_ARCH of RAMBLOCK256X16 is 

  component RAM1K18
    generic (MEMORYFILE:string := "");

    port( A_DOUT        : out   std_logic_vector(17 downto 0);
          B_DOUT        : out   std_logic_vector(17 downto 0);
          BUSY          : out   std_logic;
          A_CLK         : in    std_logic := 'U';
          A_DOUT_CLK    : in    std_logic := 'U';
          A_ARST_N      : in    std_logic := 'U';
          A_DOUT_EN     : in    std_logic := 'U';
          A_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_DOUT_ARST_N : in    std_logic := 'U';
          A_DOUT_SRST_N : in    std_logic := 'U';
          A_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          A_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          A_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_CLK         : in    std_logic := 'U';
          B_DOUT_CLK    : in    std_logic := 'U';
          B_ARST_N      : in    std_logic := 'U';
          B_DOUT_EN     : in    std_logic := 'U';
          B_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_DOUT_ARST_N : in    std_logic := 'U';
          B_DOUT_SRST_N : in    std_logic := 'U';
          B_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          B_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          B_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_EN          : in    std_logic := 'U';
          A_DOUT_LAT    : in    std_logic := 'U';
          A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_WMODE       : in    std_logic := 'U';
          B_EN          : in    std_logic := 'U';
          B_DOUT_LAT    : in    std_logic := 'U';
          B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_WMODE       : in    std_logic := 'U';
          SII_LOCK      : in    std_logic := 'U'
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc1, nc8, nc13, nc16, nc19, nc20, nc9, nc14, nc5, nc15, 
        nc3, nc10, nc7, nc17, nc4, nc12, nc2, nc18, nc6, nc11
         : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    RAMBLOCK256X16_R0C0 : RAM1K18
      port map(A_DOUT(17) => nc1, A_DOUT(16) => Q(15), A_DOUT(15)
         => Q(14), A_DOUT(14) => Q(13), A_DOUT(13) => Q(12), 
        A_DOUT(12) => Q(11), A_DOUT(11) => Q(10), A_DOUT(10) => 
        Q(9), A_DOUT(9) => Q(8), A_DOUT(8) => nc8, A_DOUT(7) => 
        Q(7), A_DOUT(6) => Q(6), A_DOUT(5) => Q(5), A_DOUT(4) => 
        Q(4), A_DOUT(3) => Q(3), A_DOUT(2) => Q(2), A_DOUT(1) => 
        Q(1), A_DOUT(0) => Q(0), B_DOUT(17) => nc13, B_DOUT(16)
         => nc16, B_DOUT(15) => nc19, B_DOUT(14) => nc20, 
        B_DOUT(13) => nc9, B_DOUT(12) => nc14, B_DOUT(11) => nc5, 
        B_DOUT(10) => nc15, B_DOUT(9) => nc3, B_DOUT(8) => nc10, 
        B_DOUT(7) => nc7, B_DOUT(6) => nc17, B_DOUT(5) => nc4, 
        B_DOUT(4) => nc12, B_DOUT(3) => nc2, B_DOUT(2) => nc18, 
        B_DOUT(1) => nc6, B_DOUT(0) => nc11, BUSY => OPEN, A_CLK
         => RCLOCK, A_DOUT_CLK => \VCC\, A_ARST_N => \VCC\, 
        A_DOUT_EN => \VCC\, A_BLK(2) => RE, A_BLK(1) => \VCC\, 
        A_BLK(0) => \VCC\, A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N
         => \VCC\, A_DIN(17) => \GND\, A_DIN(16) => \GND\, 
        A_DIN(15) => \GND\, A_DIN(14) => \GND\, A_DIN(13) => 
        \GND\, A_DIN(12) => \GND\, A_DIN(11) => \GND\, A_DIN(10)
         => \GND\, A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7)
         => \GND\, A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4)
         => \GND\, A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1)
         => \GND\, A_DIN(0) => \GND\, A_ADDR(13) => \GND\, 
        A_ADDR(12) => \GND\, A_ADDR(11) => RADDRESS(7), 
        A_ADDR(10) => RADDRESS(6), A_ADDR(9) => RADDRESS(5), 
        A_ADDR(8) => RADDRESS(4), A_ADDR(7) => RADDRESS(3), 
        A_ADDR(6) => RADDRESS(2), A_ADDR(5) => RADDRESS(1), 
        A_ADDR(4) => RADDRESS(0), A_ADDR(3) => \GND\, A_ADDR(2)
         => \GND\, A_ADDR(1) => \GND\, A_ADDR(0) => \GND\, 
        A_WEN(1) => \GND\, A_WEN(0) => \GND\, B_CLK => WCLOCK, 
        B_DOUT_CLK => \VCC\, B_ARST_N => \VCC\, B_DOUT_EN => 
        \VCC\, B_BLK(2) => WE, B_BLK(1) => \VCC\, B_BLK(0) => 
        \VCC\, B_DOUT_ARST_N => \GND\, B_DOUT_SRST_N => \VCC\, 
        B_DIN(17) => \GND\, B_DIN(16) => DATA(15), B_DIN(15) => 
        DATA(14), B_DIN(14) => DATA(13), B_DIN(13) => DATA(12), 
        B_DIN(12) => DATA(11), B_DIN(11) => DATA(10), B_DIN(10)
         => DATA(9), B_DIN(9) => DATA(8), B_DIN(8) => \GND\, 
        B_DIN(7) => DATA(7), B_DIN(6) => DATA(6), B_DIN(5) => 
        DATA(5), B_DIN(4) => DATA(4), B_DIN(3) => DATA(3), 
        B_DIN(2) => DATA(2), B_DIN(1) => DATA(1), B_DIN(0) => 
        DATA(0), B_ADDR(13) => \GND\, B_ADDR(12) => \GND\, 
        B_ADDR(11) => WADDRESS(7), B_ADDR(10) => WADDRESS(6), 
        B_ADDR(9) => WADDRESS(5), B_ADDR(8) => WADDRESS(4), 
        B_ADDR(7) => WADDRESS(3), B_ADDR(6) => WADDRESS(2), 
        B_ADDR(5) => WADDRESS(1), B_ADDR(4) => WADDRESS(0), 
        B_ADDR(3) => \GND\, B_ADDR(2) => \GND\, B_ADDR(1) => 
        \GND\, B_ADDR(0) => \GND\, B_WEN(1) => \VCC\, B_WEN(0)
         => \VCC\, A_EN => \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2)
         => \VCC\, A_WIDTH(1) => \GND\, A_WIDTH(0) => \GND\, 
        A_WMODE => \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, 
        B_WIDTH(2) => \VCC\, B_WIDTH(1) => \GND\, B_WIDTH(0) => 
        \GND\, B_WMODE => \GND\, SII_LOCK => \GND\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 
-- Version: v11.1 SP2 11.1.2.11

library ieee;
use ieee.std_logic_1164.all;
library SmartFusion2;
use SmartFusion2.all;

entity RAMBLOCK256X32 is

    port( DATA     : in    std_logic_vector(31 downto 0);
          Q        : out   std_logic_vector(31 downto 0);
          WADDRESS : in    std_logic_vector(7 downto 0);
          RADDRESS : in    std_logic_vector(7 downto 0);
          WE       : in    std_logic;
          RE       : in    std_logic;
          WCLOCK   : in    std_logic;
          RCLOCK   : in    std_logic
        );

end RAMBLOCK256X32;

architecture DEF_ARCH of RAMBLOCK256X32 is 

  component RAM1K18
    generic (MEMORYFILE:string := "");

    port( A_DOUT        : out   std_logic_vector(17 downto 0);
          B_DOUT        : out   std_logic_vector(17 downto 0);
          BUSY          : out   std_logic;
          A_CLK         : in    std_logic := 'U';
          A_DOUT_CLK    : in    std_logic := 'U';
          A_ARST_N      : in    std_logic := 'U';
          A_DOUT_EN     : in    std_logic := 'U';
          A_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_DOUT_ARST_N : in    std_logic := 'U';
          A_DOUT_SRST_N : in    std_logic := 'U';
          A_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          A_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          A_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_CLK         : in    std_logic := 'U';
          B_DOUT_CLK    : in    std_logic := 'U';
          B_ARST_N      : in    std_logic := 'U';
          B_DOUT_EN     : in    std_logic := 'U';
          B_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_DOUT_ARST_N : in    std_logic := 'U';
          B_DOUT_SRST_N : in    std_logic := 'U';
          B_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          B_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          B_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_EN          : in    std_logic := 'U';
          A_DOUT_LAT    : in    std_logic := 'U';
          A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_WMODE       : in    std_logic := 'U';
          B_EN          : in    std_logic := 'U';
          B_DOUT_LAT    : in    std_logic := 'U';
          B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_WMODE       : in    std_logic := 'U';
          SII_LOCK      : in    std_logic := 'U'
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc2, nc4, nc3, nc1 : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    RAMBLOCK256X32_R0C0 : RAM1K18
      port map(A_DOUT(17) => nc2, A_DOUT(16) => Q(31), A_DOUT(15)
         => Q(30), A_DOUT(14) => Q(29), A_DOUT(13) => Q(28), 
        A_DOUT(12) => Q(27), A_DOUT(11) => Q(26), A_DOUT(10) => 
        Q(25), A_DOUT(9) => Q(24), A_DOUT(8) => nc4, A_DOUT(7)
         => Q(23), A_DOUT(6) => Q(22), A_DOUT(5) => Q(21), 
        A_DOUT(4) => Q(20), A_DOUT(3) => Q(19), A_DOUT(2) => 
        Q(18), A_DOUT(1) => Q(17), A_DOUT(0) => Q(16), B_DOUT(17)
         => nc3, B_DOUT(16) => Q(15), B_DOUT(15) => Q(14), 
        B_DOUT(14) => Q(13), B_DOUT(13) => Q(12), B_DOUT(12) => 
        Q(11), B_DOUT(11) => Q(10), B_DOUT(10) => Q(9), B_DOUT(9)
         => Q(8), B_DOUT(8) => nc1, B_DOUT(7) => Q(7), B_DOUT(6)
         => Q(6), B_DOUT(5) => Q(5), B_DOUT(4) => Q(4), B_DOUT(3)
         => Q(3), B_DOUT(2) => Q(2), B_DOUT(1) => Q(1), B_DOUT(0)
         => Q(0), BUSY => OPEN, A_CLK => RCLOCK, A_DOUT_CLK => 
        \VCC\, A_ARST_N => \VCC\, A_DOUT_EN => \VCC\, A_BLK(2)
         => RE, A_BLK(1) => \VCC\, A_BLK(0) => \VCC\, 
        A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N => \VCC\, A_DIN(17)
         => \GND\, A_DIN(16) => DATA(31), A_DIN(15) => DATA(30), 
        A_DIN(14) => DATA(29), A_DIN(13) => DATA(28), A_DIN(12)
         => DATA(27), A_DIN(11) => DATA(26), A_DIN(10) => 
        DATA(25), A_DIN(9) => DATA(24), A_DIN(8) => \GND\, 
        A_DIN(7) => DATA(23), A_DIN(6) => DATA(22), A_DIN(5) => 
        DATA(21), A_DIN(4) => DATA(20), A_DIN(3) => DATA(19), 
        A_DIN(2) => DATA(18), A_DIN(1) => DATA(17), A_DIN(0) => 
        DATA(16), A_ADDR(13) => \GND\, A_ADDR(12) => RADDRESS(7), 
        A_ADDR(11) => RADDRESS(6), A_ADDR(10) => RADDRESS(5), 
        A_ADDR(9) => RADDRESS(4), A_ADDR(8) => RADDRESS(3), 
        A_ADDR(7) => RADDRESS(2), A_ADDR(6) => RADDRESS(1), 
        A_ADDR(5) => RADDRESS(0), A_ADDR(4) => \GND\, A_ADDR(3)
         => \GND\, A_ADDR(2) => \GND\, A_ADDR(1) => \GND\, 
        A_ADDR(0) => \GND\, A_WEN(1) => \VCC\, A_WEN(0) => \VCC\, 
        B_CLK => WCLOCK, B_DOUT_CLK => \VCC\, B_ARST_N => \VCC\, 
        B_DOUT_EN => \VCC\, B_BLK(2) => WE, B_BLK(1) => \VCC\, 
        B_BLK(0) => \VCC\, B_DOUT_ARST_N => \VCC\, B_DOUT_SRST_N
         => \VCC\, B_DIN(17) => \GND\, B_DIN(16) => DATA(15), 
        B_DIN(15) => DATA(14), B_DIN(14) => DATA(13), B_DIN(13)
         => DATA(12), B_DIN(12) => DATA(11), B_DIN(11) => 
        DATA(10), B_DIN(10) => DATA(9), B_DIN(9) => DATA(8), 
        B_DIN(8) => \GND\, B_DIN(7) => DATA(7), B_DIN(6) => 
        DATA(6), B_DIN(5) => DATA(5), B_DIN(4) => DATA(4), 
        B_DIN(3) => DATA(3), B_DIN(2) => DATA(2), B_DIN(1) => 
        DATA(1), B_DIN(0) => DATA(0), B_ADDR(13) => \GND\, 
        B_ADDR(12) => WADDRESS(7), B_ADDR(11) => WADDRESS(6), 
        B_ADDR(10) => WADDRESS(5), B_ADDR(9) => WADDRESS(4), 
        B_ADDR(8) => WADDRESS(3), B_ADDR(7) => WADDRESS(2), 
        B_ADDR(6) => WADDRESS(1), B_ADDR(5) => WADDRESS(0), 
        B_ADDR(4) => \GND\, B_ADDR(3) => \GND\, B_ADDR(2) => 
        \GND\, B_ADDR(1) => \GND\, B_ADDR(0) => \GND\, B_WEN(1)
         => \VCC\, B_WEN(0) => \VCC\, A_EN => \VCC\, A_DOUT_LAT
         => \VCC\, A_WIDTH(2) => \VCC\, A_WIDTH(1) => \GND\, 
        A_WIDTH(0) => \VCC\, A_WMODE => \GND\, B_EN => \VCC\, 
        B_DOUT_LAT => \VCC\, B_WIDTH(2) => \VCC\, B_WIDTH(1) => 
        \GND\, B_WIDTH(0) => \VCC\, B_WMODE => \GND\, SII_LOCK
         => \GND\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 
-- Version: v11.1 SP2 11.1.2.11

library ieee;
use ieee.std_logic_1164.all;
library SmartFusion2;
use SmartFusion2.all;

entity RAMBLOCK256X8 is

    port( DATA     : in    std_logic_vector(7 downto 0);
          Q        : out   std_logic_vector(7 downto 0);
          WADDRESS : in    std_logic_vector(7 downto 0);
          RADDRESS : in    std_logic_vector(7 downto 0);
          WE       : in    std_logic;
          RE       : in    std_logic;
          WCLOCK   : in    std_logic;
          RCLOCK   : in    std_logic
        );

end RAMBLOCK256X8;

architecture DEF_ARCH of RAMBLOCK256X8 is 

  component RAM1K18
    generic (MEMORYFILE:string := "");

    port( A_DOUT        : out   std_logic_vector(17 downto 0);
          B_DOUT        : out   std_logic_vector(17 downto 0);
          BUSY          : out   std_logic;
          A_CLK         : in    std_logic := 'U';
          A_DOUT_CLK    : in    std_logic := 'U';
          A_ARST_N      : in    std_logic := 'U';
          A_DOUT_EN     : in    std_logic := 'U';
          A_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_DOUT_ARST_N : in    std_logic := 'U';
          A_DOUT_SRST_N : in    std_logic := 'U';
          A_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          A_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          A_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_CLK         : in    std_logic := 'U';
          B_DOUT_CLK    : in    std_logic := 'U';
          B_ARST_N      : in    std_logic := 'U';
          B_DOUT_EN     : in    std_logic := 'U';
          B_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_DOUT_ARST_N : in    std_logic := 'U';
          B_DOUT_SRST_N : in    std_logic := 'U';
          B_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          B_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          B_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_EN          : in    std_logic := 'U';
          A_DOUT_LAT    : in    std_logic := 'U';
          A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_WMODE       : in    std_logic := 'U';
          B_EN          : in    std_logic := 'U';
          B_DOUT_LAT    : in    std_logic := 'U';
          B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_WMODE       : in    std_logic := 'U';
          SII_LOCK      : in    std_logic := 'U'
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc24, nc1, nc8, nc13, nc16, nc19, nc25, nc20, nc27, 
        nc9, nc22, nc28, nc14, nc5, nc21, nc15, nc3, nc10, nc7, 
        nc17, nc4, nc12, nc2, nc23, nc18, nc26, nc6, nc11
         : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    RAMBLOCK256X8_R0C0 : RAM1K18
      port map(A_DOUT(17) => nc24, A_DOUT(16) => nc1, A_DOUT(15)
         => nc8, A_DOUT(14) => nc13, A_DOUT(13) => nc16, 
        A_DOUT(12) => nc19, A_DOUT(11) => nc25, A_DOUT(10) => 
        nc20, A_DOUT(9) => nc27, A_DOUT(8) => nc9, A_DOUT(7) => 
        Q(7), A_DOUT(6) => Q(6), A_DOUT(5) => Q(5), A_DOUT(4) => 
        Q(4), A_DOUT(3) => Q(3), A_DOUT(2) => Q(2), A_DOUT(1) => 
        Q(1), A_DOUT(0) => Q(0), B_DOUT(17) => nc22, B_DOUT(16)
         => nc28, B_DOUT(15) => nc14, B_DOUT(14) => nc5, 
        B_DOUT(13) => nc21, B_DOUT(12) => nc15, B_DOUT(11) => nc3, 
        B_DOUT(10) => nc10, B_DOUT(9) => nc7, B_DOUT(8) => nc17, 
        B_DOUT(7) => nc4, B_DOUT(6) => nc12, B_DOUT(5) => nc2, 
        B_DOUT(4) => nc23, B_DOUT(3) => nc18, B_DOUT(2) => nc26, 
        B_DOUT(1) => nc6, B_DOUT(0) => nc11, BUSY => OPEN, A_CLK
         => RCLOCK, A_DOUT_CLK => \VCC\, A_ARST_N => \VCC\, 
        A_DOUT_EN => \VCC\, A_BLK(2) => RE, A_BLK(1) => \VCC\, 
        A_BLK(0) => \VCC\, A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N
         => \VCC\, A_DIN(17) => \GND\, A_DIN(16) => \GND\, 
        A_DIN(15) => \GND\, A_DIN(14) => \GND\, A_DIN(13) => 
        \GND\, A_DIN(12) => \GND\, A_DIN(11) => \GND\, A_DIN(10)
         => \GND\, A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7)
         => \GND\, A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4)
         => \GND\, A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1)
         => \GND\, A_DIN(0) => \GND\, A_ADDR(13) => \GND\, 
        A_ADDR(12) => \GND\, A_ADDR(11) => \GND\, A_ADDR(10) => 
        RADDRESS(7), A_ADDR(9) => RADDRESS(6), A_ADDR(8) => 
        RADDRESS(5), A_ADDR(7) => RADDRESS(4), A_ADDR(6) => 
        RADDRESS(3), A_ADDR(5) => RADDRESS(2), A_ADDR(4) => 
        RADDRESS(1), A_ADDR(3) => RADDRESS(0), A_ADDR(2) => \GND\, 
        A_ADDR(1) => \GND\, A_ADDR(0) => \GND\, A_WEN(1) => \GND\, 
        A_WEN(0) => \GND\, B_CLK => WCLOCK, B_DOUT_CLK => \VCC\, 
        B_ARST_N => \VCC\, B_DOUT_EN => \VCC\, B_BLK(2) => WE, 
        B_BLK(1) => \VCC\, B_BLK(0) => \VCC\, B_DOUT_ARST_N => 
        \GND\, B_DOUT_SRST_N => \VCC\, B_DIN(17) => \GND\, 
        B_DIN(16) => \GND\, B_DIN(15) => \GND\, B_DIN(14) => 
        \GND\, B_DIN(13) => \GND\, B_DIN(12) => \GND\, B_DIN(11)
         => \GND\, B_DIN(10) => \GND\, B_DIN(9) => \GND\, 
        B_DIN(8) => \GND\, B_DIN(7) => DATA(7), B_DIN(6) => 
        DATA(6), B_DIN(5) => DATA(5), B_DIN(4) => DATA(4), 
        B_DIN(3) => DATA(3), B_DIN(2) => DATA(2), B_DIN(1) => 
        DATA(1), B_DIN(0) => DATA(0), B_ADDR(13) => \GND\, 
        B_ADDR(12) => \GND\, B_ADDR(11) => \GND\, B_ADDR(10) => 
        WADDRESS(7), B_ADDR(9) => WADDRESS(6), B_ADDR(8) => 
        WADDRESS(5), B_ADDR(7) => WADDRESS(4), B_ADDR(6) => 
        WADDRESS(3), B_ADDR(5) => WADDRESS(2), B_ADDR(4) => 
        WADDRESS(1), B_ADDR(3) => WADDRESS(0), B_ADDR(2) => \GND\, 
        B_ADDR(1) => \GND\, B_ADDR(0) => \GND\, B_WEN(1) => \GND\, 
        B_WEN(0) => \VCC\, A_EN => \VCC\, A_DOUT_LAT => \VCC\, 
        A_WIDTH(2) => \GND\, A_WIDTH(1) => \VCC\, A_WIDTH(0) => 
        \VCC\, A_WMODE => \GND\, B_EN => \VCC\, B_DOUT_LAT => 
        \VCC\, B_WIDTH(2) => \GND\, B_WIDTH(1) => \VCC\, 
        B_WIDTH(0) => \VCC\, B_WMODE => \GND\, SII_LOCK => \GND\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 
-- Version: v11.1 SP2 11.1.2.11

library ieee;
use ieee.std_logic_1164.all;
library SmartFusion2;
use SmartFusion2.all;

entity RAMBLOCK4096X16 is

    port( DATA     : in    std_logic_vector(15 downto 0);
          Q        : out   std_logic_vector(15 downto 0);
          WADDRESS : in    std_logic_vector(11 downto 0);
          RADDRESS : in    std_logic_vector(11 downto 0);
          WE       : in    std_logic;
          RE       : in    std_logic;
          WCLOCK   : in    std_logic;
          RCLOCK   : in    std_logic
        );

end RAMBLOCK4096X16;

architecture DEF_ARCH of RAMBLOCK4096X16 is 

  component RAM1K18
    generic (MEMORYFILE:string := "");

    port( A_DOUT        : out   std_logic_vector(17 downto 0);
          B_DOUT        : out   std_logic_vector(17 downto 0);
          BUSY          : out   std_logic;
          A_CLK         : in    std_logic := 'U';
          A_DOUT_CLK    : in    std_logic := 'U';
          A_ARST_N      : in    std_logic := 'U';
          A_DOUT_EN     : in    std_logic := 'U';
          A_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_DOUT_ARST_N : in    std_logic := 'U';
          A_DOUT_SRST_N : in    std_logic := 'U';
          A_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          A_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          A_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_CLK         : in    std_logic := 'U';
          B_DOUT_CLK    : in    std_logic := 'U';
          B_ARST_N      : in    std_logic := 'U';
          B_DOUT_EN     : in    std_logic := 'U';
          B_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_DOUT_ARST_N : in    std_logic := 'U';
          B_DOUT_SRST_N : in    std_logic := 'U';
          B_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          B_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          B_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_EN          : in    std_logic := 'U';
          A_DOUT_LAT    : in    std_logic := 'U';
          A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_WMODE       : in    std_logic := 'U';
          B_EN          : in    std_logic := 'U';
          B_DOUT_LAT    : in    std_logic := 'U';
          B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_WMODE       : in    std_logic := 'U';
          SII_LOCK      : in    std_logic := 'U'
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc123, nc121, nc47, nc113, nc111, nc34, nc98, nc89, 
        nc70, nc60, nc105, nc74, nc120, nc119, nc64, nc110, nc9, 
        nc92, nc91, nc13, nc23, nc55, nc80, nc33, nc84, nc16, 
        nc26, nc45, nc73, nc58, nc63, nc27, nc17, nc127, nc99, 
        nc126, nc117, nc36, nc116, nc48, nc37, nc5, nc103, nc101, 
        nc52, nc76, nc51, nc66, nc77, nc67, nc4, nc124, nc109, 
        nc42, nc114, nc100, nc83, nc41, nc90, nc94, nc122, nc112, 
        nc86, nc59, nc25, nc15, nc87, nc35, nc49, nc28, nc18, 
        nc128, nc107, nc118, nc106, nc75, nc65, nc38, nc93, nc1, 
        nc2, nc50, nc22, nc12, nc21, nc11, nc78, nc54, nc68, nc3, 
        nc32, nc104, nc40, nc31, nc96, nc44, nc7, nc97, nc85, 
        nc72, nc6, nc71, nc62, nc61, nc125, nc115, nc102, nc19, 
        nc29, nc88, nc53, nc39, nc8, nc82, nc108, nc81, nc79, 
        nc43, nc69, nc56, nc20, nc10, nc57, nc95, nc24, nc14, 
        nc46, nc30 : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    RAMBLOCK4096X16_R0C2 : RAM1K18
      port map(A_DOUT(17) => nc123, A_DOUT(16) => nc121, 
        A_DOUT(15) => nc47, A_DOUT(14) => nc113, A_DOUT(13) => 
        nc111, A_DOUT(12) => nc34, A_DOUT(11) => nc98, A_DOUT(10)
         => nc89, A_DOUT(9) => nc70, A_DOUT(8) => nc60, A_DOUT(7)
         => nc105, A_DOUT(6) => nc74, A_DOUT(5) => nc120, 
        A_DOUT(4) => nc119, A_DOUT(3) => Q(11), A_DOUT(2) => 
        Q(10), A_DOUT(1) => Q(9), A_DOUT(0) => Q(8), B_DOUT(17)
         => nc64, B_DOUT(16) => nc110, B_DOUT(15) => nc9, 
        B_DOUT(14) => nc92, B_DOUT(13) => nc91, B_DOUT(12) => 
        nc13, B_DOUT(11) => nc23, B_DOUT(10) => nc55, B_DOUT(9)
         => nc80, B_DOUT(8) => nc33, B_DOUT(7) => nc84, B_DOUT(6)
         => nc16, B_DOUT(5) => nc26, B_DOUT(4) => nc45, B_DOUT(3)
         => nc73, B_DOUT(2) => nc58, B_DOUT(1) => nc63, B_DOUT(0)
         => nc27, BUSY => OPEN, A_CLK => RCLOCK, A_DOUT_CLK => 
        \VCC\, A_ARST_N => \VCC\, A_DOUT_EN => \VCC\, A_BLK(2)
         => RE, A_BLK(1) => \VCC\, A_BLK(0) => \VCC\, 
        A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N => \VCC\, A_DIN(17)
         => \GND\, A_DIN(16) => \GND\, A_DIN(15) => \GND\, 
        A_DIN(14) => \GND\, A_DIN(13) => \GND\, A_DIN(12) => 
        \GND\, A_DIN(11) => \GND\, A_DIN(10) => \GND\, A_DIN(9)
         => \GND\, A_DIN(8) => \GND\, A_DIN(7) => \GND\, A_DIN(6)
         => \GND\, A_DIN(5) => \GND\, A_DIN(4) => \GND\, A_DIN(3)
         => \GND\, A_DIN(2) => \GND\, A_DIN(1) => \GND\, A_DIN(0)
         => \GND\, A_ADDR(13) => RADDRESS(11), A_ADDR(12) => 
        RADDRESS(10), A_ADDR(11) => RADDRESS(9), A_ADDR(10) => 
        RADDRESS(8), A_ADDR(9) => RADDRESS(7), A_ADDR(8) => 
        RADDRESS(6), A_ADDR(7) => RADDRESS(5), A_ADDR(6) => 
        RADDRESS(4), A_ADDR(5) => RADDRESS(3), A_ADDR(4) => 
        RADDRESS(2), A_ADDR(3) => RADDRESS(1), A_ADDR(2) => 
        RADDRESS(0), A_ADDR(1) => \GND\, A_ADDR(0) => \GND\, 
        A_WEN(1) => \GND\, A_WEN(0) => \GND\, B_CLK => WCLOCK, 
        B_DOUT_CLK => \VCC\, B_ARST_N => \VCC\, B_DOUT_EN => 
        \VCC\, B_BLK(2) => WE, B_BLK(1) => \VCC\, B_BLK(0) => 
        \VCC\, B_DOUT_ARST_N => \GND\, B_DOUT_SRST_N => \VCC\, 
        B_DIN(17) => \GND\, B_DIN(16) => \GND\, B_DIN(15) => 
        \GND\, B_DIN(14) => \GND\, B_DIN(13) => \GND\, B_DIN(12)
         => \GND\, B_DIN(11) => \GND\, B_DIN(10) => \GND\, 
        B_DIN(9) => \GND\, B_DIN(8) => \GND\, B_DIN(7) => \GND\, 
        B_DIN(6) => \GND\, B_DIN(5) => \GND\, B_DIN(4) => \GND\, 
        B_DIN(3) => DATA(11), B_DIN(2) => DATA(10), B_DIN(1) => 
        DATA(9), B_DIN(0) => DATA(8), B_ADDR(13) => WADDRESS(11), 
        B_ADDR(12) => WADDRESS(10), B_ADDR(11) => WADDRESS(9), 
        B_ADDR(10) => WADDRESS(8), B_ADDR(9) => WADDRESS(7), 
        B_ADDR(8) => WADDRESS(6), B_ADDR(7) => WADDRESS(5), 
        B_ADDR(6) => WADDRESS(4), B_ADDR(5) => WADDRESS(3), 
        B_ADDR(4) => WADDRESS(2), B_ADDR(3) => WADDRESS(1), 
        B_ADDR(2) => WADDRESS(0), B_ADDR(1) => \GND\, B_ADDR(0)
         => \GND\, B_WEN(1) => \GND\, B_WEN(0) => \VCC\, A_EN => 
        \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2) => \GND\, 
        A_WIDTH(1) => \VCC\, A_WIDTH(0) => \GND\, A_WMODE => 
        \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => 
        \GND\, B_WIDTH(1) => \VCC\, B_WIDTH(0) => \GND\, B_WMODE
         => \GND\, SII_LOCK => \GND\);
    
    RAMBLOCK4096X16_R0C0 : RAM1K18
      port map(A_DOUT(17) => nc17, A_DOUT(16) => nc127, 
        A_DOUT(15) => nc99, A_DOUT(14) => nc126, A_DOUT(13) => 
        nc117, A_DOUT(12) => nc36, A_DOUT(11) => nc116, 
        A_DOUT(10) => nc48, A_DOUT(9) => nc37, A_DOUT(8) => nc5, 
        A_DOUT(7) => nc103, A_DOUT(6) => nc101, A_DOUT(5) => nc52, 
        A_DOUT(4) => nc76, A_DOUT(3) => Q(3), A_DOUT(2) => Q(2), 
        A_DOUT(1) => Q(1), A_DOUT(0) => Q(0), B_DOUT(17) => nc51, 
        B_DOUT(16) => nc66, B_DOUT(15) => nc77, B_DOUT(14) => 
        nc67, B_DOUT(13) => nc4, B_DOUT(12) => nc124, B_DOUT(11)
         => nc109, B_DOUT(10) => nc42, B_DOUT(9) => nc114, 
        B_DOUT(8) => nc100, B_DOUT(7) => nc83, B_DOUT(6) => nc41, 
        B_DOUT(5) => nc90, B_DOUT(4) => nc94, B_DOUT(3) => nc122, 
        B_DOUT(2) => nc112, B_DOUT(1) => nc86, B_DOUT(0) => nc59, 
        BUSY => OPEN, A_CLK => RCLOCK, A_DOUT_CLK => \VCC\, 
        A_ARST_N => \VCC\, A_DOUT_EN => \VCC\, A_BLK(2) => RE, 
        A_BLK(1) => \VCC\, A_BLK(0) => \VCC\, A_DOUT_ARST_N => 
        \VCC\, A_DOUT_SRST_N => \VCC\, A_DIN(17) => \GND\, 
        A_DIN(16) => \GND\, A_DIN(15) => \GND\, A_DIN(14) => 
        \GND\, A_DIN(13) => \GND\, A_DIN(12) => \GND\, A_DIN(11)
         => \GND\, A_DIN(10) => \GND\, A_DIN(9) => \GND\, 
        A_DIN(8) => \GND\, A_DIN(7) => \GND\, A_DIN(6) => \GND\, 
        A_DIN(5) => \GND\, A_DIN(4) => \GND\, A_DIN(3) => \GND\, 
        A_DIN(2) => \GND\, A_DIN(1) => \GND\, A_DIN(0) => \GND\, 
        A_ADDR(13) => RADDRESS(11), A_ADDR(12) => RADDRESS(10), 
        A_ADDR(11) => RADDRESS(9), A_ADDR(10) => RADDRESS(8), 
        A_ADDR(9) => RADDRESS(7), A_ADDR(8) => RADDRESS(6), 
        A_ADDR(7) => RADDRESS(5), A_ADDR(6) => RADDRESS(4), 
        A_ADDR(5) => RADDRESS(3), A_ADDR(4) => RADDRESS(2), 
        A_ADDR(3) => RADDRESS(1), A_ADDR(2) => RADDRESS(0), 
        A_ADDR(1) => \GND\, A_ADDR(0) => \GND\, A_WEN(1) => \GND\, 
        A_WEN(0) => \GND\, B_CLK => WCLOCK, B_DOUT_CLK => \VCC\, 
        B_ARST_N => \VCC\, B_DOUT_EN => \VCC\, B_BLK(2) => WE, 
        B_BLK(1) => \VCC\, B_BLK(0) => \VCC\, B_DOUT_ARST_N => 
        \GND\, B_DOUT_SRST_N => \VCC\, B_DIN(17) => \GND\, 
        B_DIN(16) => \GND\, B_DIN(15) => \GND\, B_DIN(14) => 
        \GND\, B_DIN(13) => \GND\, B_DIN(12) => \GND\, B_DIN(11)
         => \GND\, B_DIN(10) => \GND\, B_DIN(9) => \GND\, 
        B_DIN(8) => \GND\, B_DIN(7) => \GND\, B_DIN(6) => \GND\, 
        B_DIN(5) => \GND\, B_DIN(4) => \GND\, B_DIN(3) => DATA(3), 
        B_DIN(2) => DATA(2), B_DIN(1) => DATA(1), B_DIN(0) => 
        DATA(0), B_ADDR(13) => WADDRESS(11), B_ADDR(12) => 
        WADDRESS(10), B_ADDR(11) => WADDRESS(9), B_ADDR(10) => 
        WADDRESS(8), B_ADDR(9) => WADDRESS(7), B_ADDR(8) => 
        WADDRESS(6), B_ADDR(7) => WADDRESS(5), B_ADDR(6) => 
        WADDRESS(4), B_ADDR(5) => WADDRESS(3), B_ADDR(4) => 
        WADDRESS(2), B_ADDR(3) => WADDRESS(1), B_ADDR(2) => 
        WADDRESS(0), B_ADDR(1) => \GND\, B_ADDR(0) => \GND\, 
        B_WEN(1) => \GND\, B_WEN(0) => \VCC\, A_EN => \VCC\, 
        A_DOUT_LAT => \VCC\, A_WIDTH(2) => \GND\, A_WIDTH(1) => 
        \VCC\, A_WIDTH(0) => \GND\, A_WMODE => \GND\, B_EN => 
        \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => \GND\, 
        B_WIDTH(1) => \VCC\, B_WIDTH(0) => \GND\, B_WMODE => 
        \GND\, SII_LOCK => \GND\);
    
    RAMBLOCK4096X16_R0C1 : RAM1K18
      port map(A_DOUT(17) => nc25, A_DOUT(16) => nc15, A_DOUT(15)
         => nc87, A_DOUT(14) => nc35, A_DOUT(13) => nc49, 
        A_DOUT(12) => nc28, A_DOUT(11) => nc18, A_DOUT(10) => 
        nc128, A_DOUT(9) => nc107, A_DOUT(8) => nc118, A_DOUT(7)
         => nc106, A_DOUT(6) => nc75, A_DOUT(5) => nc65, 
        A_DOUT(4) => nc38, A_DOUT(3) => Q(7), A_DOUT(2) => Q(6), 
        A_DOUT(1) => Q(5), A_DOUT(0) => Q(4), B_DOUT(17) => nc93, 
        B_DOUT(16) => nc1, B_DOUT(15) => nc2, B_DOUT(14) => nc50, 
        B_DOUT(13) => nc22, B_DOUT(12) => nc12, B_DOUT(11) => 
        nc21, B_DOUT(10) => nc11, B_DOUT(9) => nc78, B_DOUT(8)
         => nc54, B_DOUT(7) => nc68, B_DOUT(6) => nc3, B_DOUT(5)
         => nc32, B_DOUT(4) => nc104, B_DOUT(3) => nc40, 
        B_DOUT(2) => nc31, B_DOUT(1) => nc96, B_DOUT(0) => nc44, 
        BUSY => OPEN, A_CLK => RCLOCK, A_DOUT_CLK => \VCC\, 
        A_ARST_N => \VCC\, A_DOUT_EN => \VCC\, A_BLK(2) => RE, 
        A_BLK(1) => \VCC\, A_BLK(0) => \VCC\, A_DOUT_ARST_N => 
        \VCC\, A_DOUT_SRST_N => \VCC\, A_DIN(17) => \GND\, 
        A_DIN(16) => \GND\, A_DIN(15) => \GND\, A_DIN(14) => 
        \GND\, A_DIN(13) => \GND\, A_DIN(12) => \GND\, A_DIN(11)
         => \GND\, A_DIN(10) => \GND\, A_DIN(9) => \GND\, 
        A_DIN(8) => \GND\, A_DIN(7) => \GND\, A_DIN(6) => \GND\, 
        A_DIN(5) => \GND\, A_DIN(4) => \GND\, A_DIN(3) => \GND\, 
        A_DIN(2) => \GND\, A_DIN(1) => \GND\, A_DIN(0) => \GND\, 
        A_ADDR(13) => RADDRESS(11), A_ADDR(12) => RADDRESS(10), 
        A_ADDR(11) => RADDRESS(9), A_ADDR(10) => RADDRESS(8), 
        A_ADDR(9) => RADDRESS(7), A_ADDR(8) => RADDRESS(6), 
        A_ADDR(7) => RADDRESS(5), A_ADDR(6) => RADDRESS(4), 
        A_ADDR(5) => RADDRESS(3), A_ADDR(4) => RADDRESS(2), 
        A_ADDR(3) => RADDRESS(1), A_ADDR(2) => RADDRESS(0), 
        A_ADDR(1) => \GND\, A_ADDR(0) => \GND\, A_WEN(1) => \GND\, 
        A_WEN(0) => \GND\, B_CLK => WCLOCK, B_DOUT_CLK => \VCC\, 
        B_ARST_N => \VCC\, B_DOUT_EN => \VCC\, B_BLK(2) => WE, 
        B_BLK(1) => \VCC\, B_BLK(0) => \VCC\, B_DOUT_ARST_N => 
        \GND\, B_DOUT_SRST_N => \VCC\, B_DIN(17) => \GND\, 
        B_DIN(16) => \GND\, B_DIN(15) => \GND\, B_DIN(14) => 
        \GND\, B_DIN(13) => \GND\, B_DIN(12) => \GND\, B_DIN(11)
         => \GND\, B_DIN(10) => \GND\, B_DIN(9) => \GND\, 
        B_DIN(8) => \GND\, B_DIN(7) => \GND\, B_DIN(6) => \GND\, 
        B_DIN(5) => \GND\, B_DIN(4) => \GND\, B_DIN(3) => DATA(7), 
        B_DIN(2) => DATA(6), B_DIN(1) => DATA(5), B_DIN(0) => 
        DATA(4), B_ADDR(13) => WADDRESS(11), B_ADDR(12) => 
        WADDRESS(10), B_ADDR(11) => WADDRESS(9), B_ADDR(10) => 
        WADDRESS(8), B_ADDR(9) => WADDRESS(7), B_ADDR(8) => 
        WADDRESS(6), B_ADDR(7) => WADDRESS(5), B_ADDR(6) => 
        WADDRESS(4), B_ADDR(5) => WADDRESS(3), B_ADDR(4) => 
        WADDRESS(2), B_ADDR(3) => WADDRESS(1), B_ADDR(2) => 
        WADDRESS(0), B_ADDR(1) => \GND\, B_ADDR(0) => \GND\, 
        B_WEN(1) => \GND\, B_WEN(0) => \VCC\, A_EN => \VCC\, 
        A_DOUT_LAT => \VCC\, A_WIDTH(2) => \GND\, A_WIDTH(1) => 
        \VCC\, A_WIDTH(0) => \GND\, A_WMODE => \GND\, B_EN => 
        \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => \GND\, 
        B_WIDTH(1) => \VCC\, B_WIDTH(0) => \GND\, B_WMODE => 
        \GND\, SII_LOCK => \GND\);
    
    RAMBLOCK4096X16_R0C3 : RAM1K18
      port map(A_DOUT(17) => nc7, A_DOUT(16) => nc97, A_DOUT(15)
         => nc85, A_DOUT(14) => nc72, A_DOUT(13) => nc6, 
        A_DOUT(12) => nc71, A_DOUT(11) => nc62, A_DOUT(10) => 
        nc61, A_DOUT(9) => nc125, A_DOUT(8) => nc115, A_DOUT(7)
         => nc102, A_DOUT(6) => nc19, A_DOUT(5) => nc29, 
        A_DOUT(4) => nc88, A_DOUT(3) => Q(15), A_DOUT(2) => Q(14), 
        A_DOUT(1) => Q(13), A_DOUT(0) => Q(12), B_DOUT(17) => 
        nc53, B_DOUT(16) => nc39, B_DOUT(15) => nc8, B_DOUT(14)
         => nc82, B_DOUT(13) => nc108, B_DOUT(12) => nc81, 
        B_DOUT(11) => nc79, B_DOUT(10) => nc43, B_DOUT(9) => nc69, 
        B_DOUT(8) => nc56, B_DOUT(7) => nc20, B_DOUT(6) => nc10, 
        B_DOUT(5) => nc57, B_DOUT(4) => nc95, B_DOUT(3) => nc24, 
        B_DOUT(2) => nc14, B_DOUT(1) => nc46, B_DOUT(0) => nc30, 
        BUSY => OPEN, A_CLK => RCLOCK, A_DOUT_CLK => \VCC\, 
        A_ARST_N => \VCC\, A_DOUT_EN => \VCC\, A_BLK(2) => RE, 
        A_BLK(1) => \VCC\, A_BLK(0) => \VCC\, A_DOUT_ARST_N => 
        \VCC\, A_DOUT_SRST_N => \VCC\, A_DIN(17) => \GND\, 
        A_DIN(16) => \GND\, A_DIN(15) => \GND\, A_DIN(14) => 
        \GND\, A_DIN(13) => \GND\, A_DIN(12) => \GND\, A_DIN(11)
         => \GND\, A_DIN(10) => \GND\, A_DIN(9) => \GND\, 
        A_DIN(8) => \GND\, A_DIN(7) => \GND\, A_DIN(6) => \GND\, 
        A_DIN(5) => \GND\, A_DIN(4) => \GND\, A_DIN(3) => \GND\, 
        A_DIN(2) => \GND\, A_DIN(1) => \GND\, A_DIN(0) => \GND\, 
        A_ADDR(13) => RADDRESS(11), A_ADDR(12) => RADDRESS(10), 
        A_ADDR(11) => RADDRESS(9), A_ADDR(10) => RADDRESS(8), 
        A_ADDR(9) => RADDRESS(7), A_ADDR(8) => RADDRESS(6), 
        A_ADDR(7) => RADDRESS(5), A_ADDR(6) => RADDRESS(4), 
        A_ADDR(5) => RADDRESS(3), A_ADDR(4) => RADDRESS(2), 
        A_ADDR(3) => RADDRESS(1), A_ADDR(2) => RADDRESS(0), 
        A_ADDR(1) => \GND\, A_ADDR(0) => \GND\, A_WEN(1) => \GND\, 
        A_WEN(0) => \GND\, B_CLK => WCLOCK, B_DOUT_CLK => \VCC\, 
        B_ARST_N => \VCC\, B_DOUT_EN => \VCC\, B_BLK(2) => WE, 
        B_BLK(1) => \VCC\, B_BLK(0) => \VCC\, B_DOUT_ARST_N => 
        \GND\, B_DOUT_SRST_N => \VCC\, B_DIN(17) => \GND\, 
        B_DIN(16) => \GND\, B_DIN(15) => \GND\, B_DIN(14) => 
        \GND\, B_DIN(13) => \GND\, B_DIN(12) => \GND\, B_DIN(11)
         => \GND\, B_DIN(10) => \GND\, B_DIN(9) => \GND\, 
        B_DIN(8) => \GND\, B_DIN(7) => \GND\, B_DIN(6) => \GND\, 
        B_DIN(5) => \GND\, B_DIN(4) => \GND\, B_DIN(3) => 
        DATA(15), B_DIN(2) => DATA(14), B_DIN(1) => DATA(13), 
        B_DIN(0) => DATA(12), B_ADDR(13) => WADDRESS(11), 
        B_ADDR(12) => WADDRESS(10), B_ADDR(11) => WADDRESS(9), 
        B_ADDR(10) => WADDRESS(8), B_ADDR(9) => WADDRESS(7), 
        B_ADDR(8) => WADDRESS(6), B_ADDR(7) => WADDRESS(5), 
        B_ADDR(6) => WADDRESS(4), B_ADDR(5) => WADDRESS(3), 
        B_ADDR(4) => WADDRESS(2), B_ADDR(3) => WADDRESS(1), 
        B_ADDR(2) => WADDRESS(0), B_ADDR(1) => \GND\, B_ADDR(0)
         => \GND\, B_WEN(1) => \GND\, B_WEN(0) => \VCC\, A_EN => 
        \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2) => \GND\, 
        A_WIDTH(1) => \VCC\, A_WIDTH(0) => \GND\, A_WMODE => 
        \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => 
        \GND\, B_WIDTH(1) => \VCC\, B_WIDTH(0) => \GND\, B_WMODE
         => \GND\, SII_LOCK => \GND\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 
-- Version: v11.1 SP2 11.1.2.11

library ieee;
use ieee.std_logic_1164.all;
library SmartFusion2;
use SmartFusion2.all;

entity RAMBLOCK4096X32 is

    port( DATA     : in    std_logic_vector(31 downto 0);
          Q        : out   std_logic_vector(31 downto 0);
          WADDRESS : in    std_logic_vector(11 downto 0);
          RADDRESS : in    std_logic_vector(11 downto 0);
          WE       : in    std_logic;
          RE       : in    std_logic;
          WCLOCK   : in    std_logic;
          RCLOCK   : in    std_logic
        );

end RAMBLOCK4096X32;

architecture DEF_ARCH of RAMBLOCK4096X32 is 

  component RAM1K18
    generic (MEMORYFILE:string := "");

    port( A_DOUT        : out   std_logic_vector(17 downto 0);
          B_DOUT        : out   std_logic_vector(17 downto 0);
          BUSY          : out   std_logic;
          A_CLK         : in    std_logic := 'U';
          A_DOUT_CLK    : in    std_logic := 'U';
          A_ARST_N      : in    std_logic := 'U';
          A_DOUT_EN     : in    std_logic := 'U';
          A_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_DOUT_ARST_N : in    std_logic := 'U';
          A_DOUT_SRST_N : in    std_logic := 'U';
          A_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          A_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          A_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_CLK         : in    std_logic := 'U';
          B_DOUT_CLK    : in    std_logic := 'U';
          B_ARST_N      : in    std_logic := 'U';
          B_DOUT_EN     : in    std_logic := 'U';
          B_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_DOUT_ARST_N : in    std_logic := 'U';
          B_DOUT_SRST_N : in    std_logic := 'U';
          B_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          B_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          B_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_EN          : in    std_logic := 'U';
          A_DOUT_LAT    : in    std_logic := 'U';
          A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_WMODE       : in    std_logic := 'U';
          B_EN          : in    std_logic := 'U';
          B_DOUT_LAT    : in    std_logic := 'U';
          B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_WMODE       : in    std_logic := 'U';
          SII_LOCK      : in    std_logic := 'U'
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc228, nc203, nc216, nc194, nc151, nc23, nc175, nc250, 
        nc58, nc116, nc74, nc133, nc238, nc167, nc84, nc39, nc72, 
        nc256, nc212, nc205, nc82, nc145, nc181, nc160, nc57, 
        nc156, nc125, nc211, nc73, nc107, nc66, nc83, nc9, nc252, 
        nc171, nc54, nc135, nc41, nc100, nc52, nc251, nc186, nc29, 
        nc118, nc60, nc141, nc193, nc214, nc240, nc45, nc53, 
        nc121, nc176, nc220, nc158, nc209, nc246, nc162, nc11, 
        nc131, nc254, nc96, nc79, nc226, nc146, nc230, nc89, 
        nc119, nc48, nc213, nc126, nc195, nc188, nc242, nc15, 
        nc236, nc102, nc3, nc207, nc47, nc90, nc222, nc159, nc136, 
        nc241, nc253, nc178, nc215, nc59, nc221, nc232, nc18, 
        nc44, nc117, nc189, nc164, nc148, nc42, nc231, nc191, 
        nc255, nc17, nc2, nc110, nc128, nc244, nc43, nc179, nc157, 
        nc36, nc224, nc61, nc104, nc138, nc14, nc150, nc196, 
        nc234, nc149, nc12, nc219, nc30, nc243, nc187, nc65, nc7, 
        nc129, nc8, nc223, nc13, nc180, nc26, nc177, nc139, nc245, 
        nc233, nc163, nc112, nc68, nc49, nc217, nc170, nc91, 
        nc225, nc5, nc20, nc198, nc147, nc67, nc152, nc127, nc103, 
        nc235, nc76, nc208, nc140, nc86, nc95, nc120, nc165, 
        nc137, nc64, nc19, nc70, nc182, nc62, nc199, nc80, nc130, 
        nc98, nc249, nc114, nc56, nc105, nc63, nc172, nc229, nc97, 
        nc161, nc31, nc154, nc50, nc239, nc142, nc247, nc94, 
        nc197, nc122, nc35, nc4, nc227, nc92, nc101, nc184, nc200, 
        nc190, nc166, nc132, nc21, nc237, nc93, nc69, nc206, 
        nc174, nc38, nc113, nc218, nc106, nc25, nc1, nc37, nc202, 
        nc144, nc153, nc46, nc71, nc124, nc81, nc201, nc168, nc34, 
        nc28, nc115, nc192, nc134, nc32, nc40, nc99, nc75, nc183, 
        nc85, nc27, nc108, nc16, nc155, nc51, nc33, nc204, nc173, 
        nc169, nc78, nc24, nc88, nc111, nc55, nc10, nc22, nc210, 
        nc185, nc143, nc248, nc77, nc6, nc109, nc87, nc123
         : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    RAMBLOCK4096X32_R0C1 : RAM1K18
      port map(A_DOUT(17) => nc228, A_DOUT(16) => nc203, 
        A_DOUT(15) => nc216, A_DOUT(14) => nc194, A_DOUT(13) => 
        nc151, A_DOUT(12) => nc23, A_DOUT(11) => nc175, 
        A_DOUT(10) => nc250, A_DOUT(9) => nc58, A_DOUT(8) => 
        nc116, A_DOUT(7) => nc74, A_DOUT(6) => nc133, A_DOUT(5)
         => nc238, A_DOUT(4) => nc167, A_DOUT(3) => Q(7), 
        A_DOUT(2) => Q(6), A_DOUT(1) => Q(5), A_DOUT(0) => Q(4), 
        B_DOUT(17) => nc84, B_DOUT(16) => nc39, B_DOUT(15) => 
        nc72, B_DOUT(14) => nc256, B_DOUT(13) => nc212, 
        B_DOUT(12) => nc205, B_DOUT(11) => nc82, B_DOUT(10) => 
        nc145, B_DOUT(9) => nc181, B_DOUT(8) => nc160, B_DOUT(7)
         => nc57, B_DOUT(6) => nc156, B_DOUT(5) => nc125, 
        B_DOUT(4) => nc211, B_DOUT(3) => nc73, B_DOUT(2) => nc107, 
        B_DOUT(1) => nc66, B_DOUT(0) => nc83, BUSY => OPEN, A_CLK
         => RCLOCK, A_DOUT_CLK => \VCC\, A_ARST_N => \VCC\, 
        A_DOUT_EN => \VCC\, A_BLK(2) => RE, A_BLK(1) => \VCC\, 
        A_BLK(0) => \VCC\, A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N
         => \VCC\, A_DIN(17) => \GND\, A_DIN(16) => \GND\, 
        A_DIN(15) => \GND\, A_DIN(14) => \GND\, A_DIN(13) => 
        \GND\, A_DIN(12) => \GND\, A_DIN(11) => \GND\, A_DIN(10)
         => \GND\, A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7)
         => \GND\, A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4)
         => \GND\, A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1)
         => \GND\, A_DIN(0) => \GND\, A_ADDR(13) => RADDRESS(11), 
        A_ADDR(12) => RADDRESS(10), A_ADDR(11) => RADDRESS(9), 
        A_ADDR(10) => RADDRESS(8), A_ADDR(9) => RADDRESS(7), 
        A_ADDR(8) => RADDRESS(6), A_ADDR(7) => RADDRESS(5), 
        A_ADDR(6) => RADDRESS(4), A_ADDR(5) => RADDRESS(3), 
        A_ADDR(4) => RADDRESS(2), A_ADDR(3) => RADDRESS(1), 
        A_ADDR(2) => RADDRESS(0), A_ADDR(1) => \GND\, A_ADDR(0)
         => \GND\, A_WEN(1) => \GND\, A_WEN(0) => \GND\, B_CLK
         => WCLOCK, B_DOUT_CLK => \VCC\, B_ARST_N => \VCC\, 
        B_DOUT_EN => \VCC\, B_BLK(2) => WE, B_BLK(1) => \VCC\, 
        B_BLK(0) => \VCC\, B_DOUT_ARST_N => \GND\, B_DOUT_SRST_N
         => \VCC\, B_DIN(17) => \GND\, B_DIN(16) => \GND\, 
        B_DIN(15) => \GND\, B_DIN(14) => \GND\, B_DIN(13) => 
        \GND\, B_DIN(12) => \GND\, B_DIN(11) => \GND\, B_DIN(10)
         => \GND\, B_DIN(9) => \GND\, B_DIN(8) => \GND\, B_DIN(7)
         => \GND\, B_DIN(6) => \GND\, B_DIN(5) => \GND\, B_DIN(4)
         => \GND\, B_DIN(3) => DATA(7), B_DIN(2) => DATA(6), 
        B_DIN(1) => DATA(5), B_DIN(0) => DATA(4), B_ADDR(13) => 
        WADDRESS(11), B_ADDR(12) => WADDRESS(10), B_ADDR(11) => 
        WADDRESS(9), B_ADDR(10) => WADDRESS(8), B_ADDR(9) => 
        WADDRESS(7), B_ADDR(8) => WADDRESS(6), B_ADDR(7) => 
        WADDRESS(5), B_ADDR(6) => WADDRESS(4), B_ADDR(5) => 
        WADDRESS(3), B_ADDR(4) => WADDRESS(2), B_ADDR(3) => 
        WADDRESS(1), B_ADDR(2) => WADDRESS(0), B_ADDR(1) => \GND\, 
        B_ADDR(0) => \GND\, B_WEN(1) => \GND\, B_WEN(0) => \VCC\, 
        A_EN => \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2) => \GND\, 
        A_WIDTH(1) => \VCC\, A_WIDTH(0) => \GND\, A_WMODE => 
        \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => 
        \GND\, B_WIDTH(1) => \VCC\, B_WIDTH(0) => \GND\, B_WMODE
         => \GND\, SII_LOCK => \GND\);
    
    RAMBLOCK4096X32_R0C5 : RAM1K18
      port map(A_DOUT(17) => nc9, A_DOUT(16) => nc252, A_DOUT(15)
         => nc171, A_DOUT(14) => nc54, A_DOUT(13) => nc135, 
        A_DOUT(12) => nc41, A_DOUT(11) => nc100, A_DOUT(10) => 
        nc52, A_DOUT(9) => nc251, A_DOUT(8) => nc186, A_DOUT(7)
         => nc29, A_DOUT(6) => nc118, A_DOUT(5) => nc60, 
        A_DOUT(4) => nc141, A_DOUT(3) => Q(23), A_DOUT(2) => 
        Q(22), A_DOUT(1) => Q(21), A_DOUT(0) => Q(20), B_DOUT(17)
         => nc193, B_DOUT(16) => nc214, B_DOUT(15) => nc240, 
        B_DOUT(14) => nc45, B_DOUT(13) => nc53, B_DOUT(12) => 
        nc121, B_DOUT(11) => nc176, B_DOUT(10) => nc220, 
        B_DOUT(9) => nc158, B_DOUT(8) => nc209, B_DOUT(7) => 
        nc246, B_DOUT(6) => nc162, B_DOUT(5) => nc11, B_DOUT(4)
         => nc131, B_DOUT(3) => nc254, B_DOUT(2) => nc96, 
        B_DOUT(1) => nc79, B_DOUT(0) => nc226, BUSY => OPEN, 
        A_CLK => RCLOCK, A_DOUT_CLK => \VCC\, A_ARST_N => \VCC\, 
        A_DOUT_EN => \VCC\, A_BLK(2) => RE, A_BLK(1) => \VCC\, 
        A_BLK(0) => \VCC\, A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N
         => \VCC\, A_DIN(17) => \GND\, A_DIN(16) => \GND\, 
        A_DIN(15) => \GND\, A_DIN(14) => \GND\, A_DIN(13) => 
        \GND\, A_DIN(12) => \GND\, A_DIN(11) => \GND\, A_DIN(10)
         => \GND\, A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7)
         => \GND\, A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4)
         => \GND\, A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1)
         => \GND\, A_DIN(0) => \GND\, A_ADDR(13) => RADDRESS(11), 
        A_ADDR(12) => RADDRESS(10), A_ADDR(11) => RADDRESS(9), 
        A_ADDR(10) => RADDRESS(8), A_ADDR(9) => RADDRESS(7), 
        A_ADDR(8) => RADDRESS(6), A_ADDR(7) => RADDRESS(5), 
        A_ADDR(6) => RADDRESS(4), A_ADDR(5) => RADDRESS(3), 
        A_ADDR(4) => RADDRESS(2), A_ADDR(3) => RADDRESS(1), 
        A_ADDR(2) => RADDRESS(0), A_ADDR(1) => \GND\, A_ADDR(0)
         => \GND\, A_WEN(1) => \GND\, A_WEN(0) => \GND\, B_CLK
         => WCLOCK, B_DOUT_CLK => \VCC\, B_ARST_N => \VCC\, 
        B_DOUT_EN => \VCC\, B_BLK(2) => WE, B_BLK(1) => \VCC\, 
        B_BLK(0) => \VCC\, B_DOUT_ARST_N => \GND\, B_DOUT_SRST_N
         => \VCC\, B_DIN(17) => \GND\, B_DIN(16) => \GND\, 
        B_DIN(15) => \GND\, B_DIN(14) => \GND\, B_DIN(13) => 
        \GND\, B_DIN(12) => \GND\, B_DIN(11) => \GND\, B_DIN(10)
         => \GND\, B_DIN(9) => \GND\, B_DIN(8) => \GND\, B_DIN(7)
         => \GND\, B_DIN(6) => \GND\, B_DIN(5) => \GND\, B_DIN(4)
         => \GND\, B_DIN(3) => DATA(23), B_DIN(2) => DATA(22), 
        B_DIN(1) => DATA(21), B_DIN(0) => DATA(20), B_ADDR(13)
         => WADDRESS(11), B_ADDR(12) => WADDRESS(10), B_ADDR(11)
         => WADDRESS(9), B_ADDR(10) => WADDRESS(8), B_ADDR(9) => 
        WADDRESS(7), B_ADDR(8) => WADDRESS(6), B_ADDR(7) => 
        WADDRESS(5), B_ADDR(6) => WADDRESS(4), B_ADDR(5) => 
        WADDRESS(3), B_ADDR(4) => WADDRESS(2), B_ADDR(3) => 
        WADDRESS(1), B_ADDR(2) => WADDRESS(0), B_ADDR(1) => \GND\, 
        B_ADDR(0) => \GND\, B_WEN(1) => \GND\, B_WEN(0) => \VCC\, 
        A_EN => \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2) => \GND\, 
        A_WIDTH(1) => \VCC\, A_WIDTH(0) => \GND\, A_WMODE => 
        \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => 
        \GND\, B_WIDTH(1) => \VCC\, B_WIDTH(0) => \GND\, B_WMODE
         => \GND\, SII_LOCK => \GND\);
    
    RAMBLOCK4096X32_R0C2 : RAM1K18
      port map(A_DOUT(17) => nc146, A_DOUT(16) => nc230, 
        A_DOUT(15) => nc89, A_DOUT(14) => nc119, A_DOUT(13) => 
        nc48, A_DOUT(12) => nc213, A_DOUT(11) => nc126, 
        A_DOUT(10) => nc195, A_DOUT(9) => nc188, A_DOUT(8) => 
        nc242, A_DOUT(7) => nc15, A_DOUT(6) => nc236, A_DOUT(5)
         => nc102, A_DOUT(4) => nc3, A_DOUT(3) => Q(11), 
        A_DOUT(2) => Q(10), A_DOUT(1) => Q(9), A_DOUT(0) => Q(8), 
        B_DOUT(17) => nc207, B_DOUT(16) => nc47, B_DOUT(15) => 
        nc90, B_DOUT(14) => nc222, B_DOUT(13) => nc159, 
        B_DOUT(12) => nc136, B_DOUT(11) => nc241, B_DOUT(10) => 
        nc253, B_DOUT(9) => nc178, B_DOUT(8) => nc215, B_DOUT(7)
         => nc59, B_DOUT(6) => nc221, B_DOUT(5) => nc232, 
        B_DOUT(4) => nc18, B_DOUT(3) => nc44, B_DOUT(2) => nc117, 
        B_DOUT(1) => nc189, B_DOUT(0) => nc164, BUSY => OPEN, 
        A_CLK => RCLOCK, A_DOUT_CLK => \VCC\, A_ARST_N => \VCC\, 
        A_DOUT_EN => \VCC\, A_BLK(2) => RE, A_BLK(1) => \VCC\, 
        A_BLK(0) => \VCC\, A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N
         => \VCC\, A_DIN(17) => \GND\, A_DIN(16) => \GND\, 
        A_DIN(15) => \GND\, A_DIN(14) => \GND\, A_DIN(13) => 
        \GND\, A_DIN(12) => \GND\, A_DIN(11) => \GND\, A_DIN(10)
         => \GND\, A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7)
         => \GND\, A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4)
         => \GND\, A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1)
         => \GND\, A_DIN(0) => \GND\, A_ADDR(13) => RADDRESS(11), 
        A_ADDR(12) => RADDRESS(10), A_ADDR(11) => RADDRESS(9), 
        A_ADDR(10) => RADDRESS(8), A_ADDR(9) => RADDRESS(7), 
        A_ADDR(8) => RADDRESS(6), A_ADDR(7) => RADDRESS(5), 
        A_ADDR(6) => RADDRESS(4), A_ADDR(5) => RADDRESS(3), 
        A_ADDR(4) => RADDRESS(2), A_ADDR(3) => RADDRESS(1), 
        A_ADDR(2) => RADDRESS(0), A_ADDR(1) => \GND\, A_ADDR(0)
         => \GND\, A_WEN(1) => \GND\, A_WEN(0) => \GND\, B_CLK
         => WCLOCK, B_DOUT_CLK => \VCC\, B_ARST_N => \VCC\, 
        B_DOUT_EN => \VCC\, B_BLK(2) => WE, B_BLK(1) => \VCC\, 
        B_BLK(0) => \VCC\, B_DOUT_ARST_N => \GND\, B_DOUT_SRST_N
         => \VCC\, B_DIN(17) => \GND\, B_DIN(16) => \GND\, 
        B_DIN(15) => \GND\, B_DIN(14) => \GND\, B_DIN(13) => 
        \GND\, B_DIN(12) => \GND\, B_DIN(11) => \GND\, B_DIN(10)
         => \GND\, B_DIN(9) => \GND\, B_DIN(8) => \GND\, B_DIN(7)
         => \GND\, B_DIN(6) => \GND\, B_DIN(5) => \GND\, B_DIN(4)
         => \GND\, B_DIN(3) => DATA(11), B_DIN(2) => DATA(10), 
        B_DIN(1) => DATA(9), B_DIN(0) => DATA(8), B_ADDR(13) => 
        WADDRESS(11), B_ADDR(12) => WADDRESS(10), B_ADDR(11) => 
        WADDRESS(9), B_ADDR(10) => WADDRESS(8), B_ADDR(9) => 
        WADDRESS(7), B_ADDR(8) => WADDRESS(6), B_ADDR(7) => 
        WADDRESS(5), B_ADDR(6) => WADDRESS(4), B_ADDR(5) => 
        WADDRESS(3), B_ADDR(4) => WADDRESS(2), B_ADDR(3) => 
        WADDRESS(1), B_ADDR(2) => WADDRESS(0), B_ADDR(1) => \GND\, 
        B_ADDR(0) => \GND\, B_WEN(1) => \GND\, B_WEN(0) => \VCC\, 
        A_EN => \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2) => \GND\, 
        A_WIDTH(1) => \VCC\, A_WIDTH(0) => \GND\, A_WMODE => 
        \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => 
        \GND\, B_WIDTH(1) => \VCC\, B_WIDTH(0) => \GND\, B_WMODE
         => \GND\, SII_LOCK => \GND\);
    
    RAMBLOCK4096X32_R0C7 : RAM1K18
      port map(A_DOUT(17) => nc148, A_DOUT(16) => nc42, 
        A_DOUT(15) => nc231, A_DOUT(14) => nc191, A_DOUT(13) => 
        nc255, A_DOUT(12) => nc17, A_DOUT(11) => nc2, A_DOUT(10)
         => nc110, A_DOUT(9) => nc128, A_DOUT(8) => nc244, 
        A_DOUT(7) => nc43, A_DOUT(6) => nc179, A_DOUT(5) => nc157, 
        A_DOUT(4) => nc36, A_DOUT(3) => Q(31), A_DOUT(2) => Q(30), 
        A_DOUT(1) => Q(29), A_DOUT(0) => Q(28), B_DOUT(17) => 
        nc224, B_DOUT(16) => nc61, B_DOUT(15) => nc104, 
        B_DOUT(14) => nc138, B_DOUT(13) => nc14, B_DOUT(12) => 
        nc150, B_DOUT(11) => nc196, B_DOUT(10) => nc234, 
        B_DOUT(9) => nc149, B_DOUT(8) => nc12, B_DOUT(7) => nc219, 
        B_DOUT(6) => nc30, B_DOUT(5) => nc243, B_DOUT(4) => nc187, 
        B_DOUT(3) => nc65, B_DOUT(2) => nc7, B_DOUT(1) => nc129, 
        B_DOUT(0) => nc8, BUSY => OPEN, A_CLK => RCLOCK, 
        A_DOUT_CLK => \VCC\, A_ARST_N => \VCC\, A_DOUT_EN => 
        \VCC\, A_BLK(2) => RE, A_BLK(1) => \VCC\, A_BLK(0) => 
        \VCC\, A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N => \VCC\, 
        A_DIN(17) => \GND\, A_DIN(16) => \GND\, A_DIN(15) => 
        \GND\, A_DIN(14) => \GND\, A_DIN(13) => \GND\, A_DIN(12)
         => \GND\, A_DIN(11) => \GND\, A_DIN(10) => \GND\, 
        A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7) => \GND\, 
        A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4) => \GND\, 
        A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1) => \GND\, 
        A_DIN(0) => \GND\, A_ADDR(13) => RADDRESS(11), A_ADDR(12)
         => RADDRESS(10), A_ADDR(11) => RADDRESS(9), A_ADDR(10)
         => RADDRESS(8), A_ADDR(9) => RADDRESS(7), A_ADDR(8) => 
        RADDRESS(6), A_ADDR(7) => RADDRESS(5), A_ADDR(6) => 
        RADDRESS(4), A_ADDR(5) => RADDRESS(3), A_ADDR(4) => 
        RADDRESS(2), A_ADDR(3) => RADDRESS(1), A_ADDR(2) => 
        RADDRESS(0), A_ADDR(1) => \GND\, A_ADDR(0) => \GND\, 
        A_WEN(1) => \GND\, A_WEN(0) => \GND\, B_CLK => WCLOCK, 
        B_DOUT_CLK => \VCC\, B_ARST_N => \VCC\, B_DOUT_EN => 
        \VCC\, B_BLK(2) => WE, B_BLK(1) => \VCC\, B_BLK(0) => 
        \VCC\, B_DOUT_ARST_N => \GND\, B_DOUT_SRST_N => \VCC\, 
        B_DIN(17) => \GND\, B_DIN(16) => \GND\, B_DIN(15) => 
        \GND\, B_DIN(14) => \GND\, B_DIN(13) => \GND\, B_DIN(12)
         => \GND\, B_DIN(11) => \GND\, B_DIN(10) => \GND\, 
        B_DIN(9) => \GND\, B_DIN(8) => \GND\, B_DIN(7) => \GND\, 
        B_DIN(6) => \GND\, B_DIN(5) => \GND\, B_DIN(4) => \GND\, 
        B_DIN(3) => DATA(31), B_DIN(2) => DATA(30), B_DIN(1) => 
        DATA(29), B_DIN(0) => DATA(28), B_ADDR(13) => 
        WADDRESS(11), B_ADDR(12) => WADDRESS(10), B_ADDR(11) => 
        WADDRESS(9), B_ADDR(10) => WADDRESS(8), B_ADDR(9) => 
        WADDRESS(7), B_ADDR(8) => WADDRESS(6), B_ADDR(7) => 
        WADDRESS(5), B_ADDR(6) => WADDRESS(4), B_ADDR(5) => 
        WADDRESS(3), B_ADDR(4) => WADDRESS(2), B_ADDR(3) => 
        WADDRESS(1), B_ADDR(2) => WADDRESS(0), B_ADDR(1) => \GND\, 
        B_ADDR(0) => \GND\, B_WEN(1) => \GND\, B_WEN(0) => \VCC\, 
        A_EN => \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2) => \GND\, 
        A_WIDTH(1) => \VCC\, A_WIDTH(0) => \GND\, A_WMODE => 
        \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => 
        \GND\, B_WIDTH(1) => \VCC\, B_WIDTH(0) => \GND\, B_WMODE
         => \GND\, SII_LOCK => \GND\);
    
    RAMBLOCK4096X32_R0C6 : RAM1K18
      port map(A_DOUT(17) => nc223, A_DOUT(16) => nc13, 
        A_DOUT(15) => nc180, A_DOUT(14) => nc26, A_DOUT(13) => 
        nc177, A_DOUT(12) => nc139, A_DOUT(11) => nc245, 
        A_DOUT(10) => nc233, A_DOUT(9) => nc163, A_DOUT(8) => 
        nc112, A_DOUT(7) => nc68, A_DOUT(6) => nc49, A_DOUT(5)
         => nc217, A_DOUT(4) => nc170, A_DOUT(3) => Q(27), 
        A_DOUT(2) => Q(26), A_DOUT(1) => Q(25), A_DOUT(0) => 
        Q(24), B_DOUT(17) => nc91, B_DOUT(16) => nc225, 
        B_DOUT(15) => nc5, B_DOUT(14) => nc20, B_DOUT(13) => 
        nc198, B_DOUT(12) => nc147, B_DOUT(11) => nc67, 
        B_DOUT(10) => nc152, B_DOUT(9) => nc127, B_DOUT(8) => 
        nc103, B_DOUT(7) => nc235, B_DOUT(6) => nc76, B_DOUT(5)
         => nc208, B_DOUT(4) => nc140, B_DOUT(3) => nc86, 
        B_DOUT(2) => nc95, B_DOUT(1) => nc120, B_DOUT(0) => nc165, 
        BUSY => OPEN, A_CLK => RCLOCK, A_DOUT_CLK => \VCC\, 
        A_ARST_N => \VCC\, A_DOUT_EN => \VCC\, A_BLK(2) => RE, 
        A_BLK(1) => \VCC\, A_BLK(0) => \VCC\, A_DOUT_ARST_N => 
        \VCC\, A_DOUT_SRST_N => \VCC\, A_DIN(17) => \GND\, 
        A_DIN(16) => \GND\, A_DIN(15) => \GND\, A_DIN(14) => 
        \GND\, A_DIN(13) => \GND\, A_DIN(12) => \GND\, A_DIN(11)
         => \GND\, A_DIN(10) => \GND\, A_DIN(9) => \GND\, 
        A_DIN(8) => \GND\, A_DIN(7) => \GND\, A_DIN(6) => \GND\, 
        A_DIN(5) => \GND\, A_DIN(4) => \GND\, A_DIN(3) => \GND\, 
        A_DIN(2) => \GND\, A_DIN(1) => \GND\, A_DIN(0) => \GND\, 
        A_ADDR(13) => RADDRESS(11), A_ADDR(12) => RADDRESS(10), 
        A_ADDR(11) => RADDRESS(9), A_ADDR(10) => RADDRESS(8), 
        A_ADDR(9) => RADDRESS(7), A_ADDR(8) => RADDRESS(6), 
        A_ADDR(7) => RADDRESS(5), A_ADDR(6) => RADDRESS(4), 
        A_ADDR(5) => RADDRESS(3), A_ADDR(4) => RADDRESS(2), 
        A_ADDR(3) => RADDRESS(1), A_ADDR(2) => RADDRESS(0), 
        A_ADDR(1) => \GND\, A_ADDR(0) => \GND\, A_WEN(1) => \GND\, 
        A_WEN(0) => \GND\, B_CLK => WCLOCK, B_DOUT_CLK => \VCC\, 
        B_ARST_N => \VCC\, B_DOUT_EN => \VCC\, B_BLK(2) => WE, 
        B_BLK(1) => \VCC\, B_BLK(0) => \VCC\, B_DOUT_ARST_N => 
        \GND\, B_DOUT_SRST_N => \VCC\, B_DIN(17) => \GND\, 
        B_DIN(16) => \GND\, B_DIN(15) => \GND\, B_DIN(14) => 
        \GND\, B_DIN(13) => \GND\, B_DIN(12) => \GND\, B_DIN(11)
         => \GND\, B_DIN(10) => \GND\, B_DIN(9) => \GND\, 
        B_DIN(8) => \GND\, B_DIN(7) => \GND\, B_DIN(6) => \GND\, 
        B_DIN(5) => \GND\, B_DIN(4) => \GND\, B_DIN(3) => 
        DATA(27), B_DIN(2) => DATA(26), B_DIN(1) => DATA(25), 
        B_DIN(0) => DATA(24), B_ADDR(13) => WADDRESS(11), 
        B_ADDR(12) => WADDRESS(10), B_ADDR(11) => WADDRESS(9), 
        B_ADDR(10) => WADDRESS(8), B_ADDR(9) => WADDRESS(7), 
        B_ADDR(8) => WADDRESS(6), B_ADDR(7) => WADDRESS(5), 
        B_ADDR(6) => WADDRESS(4), B_ADDR(5) => WADDRESS(3), 
        B_ADDR(4) => WADDRESS(2), B_ADDR(3) => WADDRESS(1), 
        B_ADDR(2) => WADDRESS(0), B_ADDR(1) => \GND\, B_ADDR(0)
         => \GND\, B_WEN(1) => \GND\, B_WEN(0) => \VCC\, A_EN => 
        \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2) => \GND\, 
        A_WIDTH(1) => \VCC\, A_WIDTH(0) => \GND\, A_WMODE => 
        \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => 
        \GND\, B_WIDTH(1) => \VCC\, B_WIDTH(0) => \GND\, B_WMODE
         => \GND\, SII_LOCK => \GND\);
    
    RAMBLOCK4096X32_R0C4 : RAM1K18
      port map(A_DOUT(17) => nc137, A_DOUT(16) => nc64, 
        A_DOUT(15) => nc19, A_DOUT(14) => nc70, A_DOUT(13) => 
        nc182, A_DOUT(12) => nc62, A_DOUT(11) => nc199, 
        A_DOUT(10) => nc80, A_DOUT(9) => nc130, A_DOUT(8) => nc98, 
        A_DOUT(7) => nc249, A_DOUT(6) => nc114, A_DOUT(5) => nc56, 
        A_DOUT(4) => nc105, A_DOUT(3) => Q(19), A_DOUT(2) => 
        Q(18), A_DOUT(1) => Q(17), A_DOUT(0) => Q(16), B_DOUT(17)
         => nc63, B_DOUT(16) => nc172, B_DOUT(15) => nc229, 
        B_DOUT(14) => nc97, B_DOUT(13) => nc161, B_DOUT(12) => 
        nc31, B_DOUT(11) => nc154, B_DOUT(10) => nc50, B_DOUT(9)
         => nc239, B_DOUT(8) => nc142, B_DOUT(7) => nc247, 
        B_DOUT(6) => nc94, B_DOUT(5) => nc197, B_DOUT(4) => nc122, 
        B_DOUT(3) => nc35, B_DOUT(2) => nc4, B_DOUT(1) => nc227, 
        B_DOUT(0) => nc92, BUSY => OPEN, A_CLK => RCLOCK, 
        A_DOUT_CLK => \VCC\, A_ARST_N => \VCC\, A_DOUT_EN => 
        \VCC\, A_BLK(2) => RE, A_BLK(1) => \VCC\, A_BLK(0) => 
        \VCC\, A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N => \VCC\, 
        A_DIN(17) => \GND\, A_DIN(16) => \GND\, A_DIN(15) => 
        \GND\, A_DIN(14) => \GND\, A_DIN(13) => \GND\, A_DIN(12)
         => \GND\, A_DIN(11) => \GND\, A_DIN(10) => \GND\, 
        A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7) => \GND\, 
        A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4) => \GND\, 
        A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1) => \GND\, 
        A_DIN(0) => \GND\, A_ADDR(13) => RADDRESS(11), A_ADDR(12)
         => RADDRESS(10), A_ADDR(11) => RADDRESS(9), A_ADDR(10)
         => RADDRESS(8), A_ADDR(9) => RADDRESS(7), A_ADDR(8) => 
        RADDRESS(6), A_ADDR(7) => RADDRESS(5), A_ADDR(6) => 
        RADDRESS(4), A_ADDR(5) => RADDRESS(3), A_ADDR(4) => 
        RADDRESS(2), A_ADDR(3) => RADDRESS(1), A_ADDR(2) => 
        RADDRESS(0), A_ADDR(1) => \GND\, A_ADDR(0) => \GND\, 
        A_WEN(1) => \GND\, A_WEN(0) => \GND\, B_CLK => WCLOCK, 
        B_DOUT_CLK => \VCC\, B_ARST_N => \VCC\, B_DOUT_EN => 
        \VCC\, B_BLK(2) => WE, B_BLK(1) => \VCC\, B_BLK(0) => 
        \VCC\, B_DOUT_ARST_N => \GND\, B_DOUT_SRST_N => \VCC\, 
        B_DIN(17) => \GND\, B_DIN(16) => \GND\, B_DIN(15) => 
        \GND\, B_DIN(14) => \GND\, B_DIN(13) => \GND\, B_DIN(12)
         => \GND\, B_DIN(11) => \GND\, B_DIN(10) => \GND\, 
        B_DIN(9) => \GND\, B_DIN(8) => \GND\, B_DIN(7) => \GND\, 
        B_DIN(6) => \GND\, B_DIN(5) => \GND\, B_DIN(4) => \GND\, 
        B_DIN(3) => DATA(19), B_DIN(2) => DATA(18), B_DIN(1) => 
        DATA(17), B_DIN(0) => DATA(16), B_ADDR(13) => 
        WADDRESS(11), B_ADDR(12) => WADDRESS(10), B_ADDR(11) => 
        WADDRESS(9), B_ADDR(10) => WADDRESS(8), B_ADDR(9) => 
        WADDRESS(7), B_ADDR(8) => WADDRESS(6), B_ADDR(7) => 
        WADDRESS(5), B_ADDR(6) => WADDRESS(4), B_ADDR(5) => 
        WADDRESS(3), B_ADDR(4) => WADDRESS(2), B_ADDR(3) => 
        WADDRESS(1), B_ADDR(2) => WADDRESS(0), B_ADDR(1) => \GND\, 
        B_ADDR(0) => \GND\, B_WEN(1) => \GND\, B_WEN(0) => \VCC\, 
        A_EN => \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2) => \GND\, 
        A_WIDTH(1) => \VCC\, A_WIDTH(0) => \GND\, A_WMODE => 
        \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => 
        \GND\, B_WIDTH(1) => \VCC\, B_WIDTH(0) => \GND\, B_WMODE
         => \GND\, SII_LOCK => \GND\);
    
    RAMBLOCK4096X32_R0C0 : RAM1K18
      port map(A_DOUT(17) => nc101, A_DOUT(16) => nc184, 
        A_DOUT(15) => nc200, A_DOUT(14) => nc190, A_DOUT(13) => 
        nc166, A_DOUT(12) => nc132, A_DOUT(11) => nc21, 
        A_DOUT(10) => nc237, A_DOUT(9) => nc93, A_DOUT(8) => nc69, 
        A_DOUT(7) => nc206, A_DOUT(6) => nc174, A_DOUT(5) => nc38, 
        A_DOUT(4) => nc113, A_DOUT(3) => Q(3), A_DOUT(2) => Q(2), 
        A_DOUT(1) => Q(1), A_DOUT(0) => Q(0), B_DOUT(17) => nc218, 
        B_DOUT(16) => nc106, B_DOUT(15) => nc25, B_DOUT(14) => 
        nc1, B_DOUT(13) => nc37, B_DOUT(12) => nc202, B_DOUT(11)
         => nc144, B_DOUT(10) => nc153, B_DOUT(9) => nc46, 
        B_DOUT(8) => nc71, B_DOUT(7) => nc124, B_DOUT(6) => nc81, 
        B_DOUT(5) => nc201, B_DOUT(4) => nc168, B_DOUT(3) => nc34, 
        B_DOUT(2) => nc28, B_DOUT(1) => nc115, B_DOUT(0) => nc192, 
        BUSY => OPEN, A_CLK => RCLOCK, A_DOUT_CLK => \VCC\, 
        A_ARST_N => \VCC\, A_DOUT_EN => \VCC\, A_BLK(2) => RE, 
        A_BLK(1) => \VCC\, A_BLK(0) => \VCC\, A_DOUT_ARST_N => 
        \VCC\, A_DOUT_SRST_N => \VCC\, A_DIN(17) => \GND\, 
        A_DIN(16) => \GND\, A_DIN(15) => \GND\, A_DIN(14) => 
        \GND\, A_DIN(13) => \GND\, A_DIN(12) => \GND\, A_DIN(11)
         => \GND\, A_DIN(10) => \GND\, A_DIN(9) => \GND\, 
        A_DIN(8) => \GND\, A_DIN(7) => \GND\, A_DIN(6) => \GND\, 
        A_DIN(5) => \GND\, A_DIN(4) => \GND\, A_DIN(3) => \GND\, 
        A_DIN(2) => \GND\, A_DIN(1) => \GND\, A_DIN(0) => \GND\, 
        A_ADDR(13) => RADDRESS(11), A_ADDR(12) => RADDRESS(10), 
        A_ADDR(11) => RADDRESS(9), A_ADDR(10) => RADDRESS(8), 
        A_ADDR(9) => RADDRESS(7), A_ADDR(8) => RADDRESS(6), 
        A_ADDR(7) => RADDRESS(5), A_ADDR(6) => RADDRESS(4), 
        A_ADDR(5) => RADDRESS(3), A_ADDR(4) => RADDRESS(2), 
        A_ADDR(3) => RADDRESS(1), A_ADDR(2) => RADDRESS(0), 
        A_ADDR(1) => \GND\, A_ADDR(0) => \GND\, A_WEN(1) => \GND\, 
        A_WEN(0) => \GND\, B_CLK => WCLOCK, B_DOUT_CLK => \VCC\, 
        B_ARST_N => \VCC\, B_DOUT_EN => \VCC\, B_BLK(2) => WE, 
        B_BLK(1) => \VCC\, B_BLK(0) => \VCC\, B_DOUT_ARST_N => 
        \GND\, B_DOUT_SRST_N => \VCC\, B_DIN(17) => \GND\, 
        B_DIN(16) => \GND\, B_DIN(15) => \GND\, B_DIN(14) => 
        \GND\, B_DIN(13) => \GND\, B_DIN(12) => \GND\, B_DIN(11)
         => \GND\, B_DIN(10) => \GND\, B_DIN(9) => \GND\, 
        B_DIN(8) => \GND\, B_DIN(7) => \GND\, B_DIN(6) => \GND\, 
        B_DIN(5) => \GND\, B_DIN(4) => \GND\, B_DIN(3) => DATA(3), 
        B_DIN(2) => DATA(2), B_DIN(1) => DATA(1), B_DIN(0) => 
        DATA(0), B_ADDR(13) => WADDRESS(11), B_ADDR(12) => 
        WADDRESS(10), B_ADDR(11) => WADDRESS(9), B_ADDR(10) => 
        WADDRESS(8), B_ADDR(9) => WADDRESS(7), B_ADDR(8) => 
        WADDRESS(6), B_ADDR(7) => WADDRESS(5), B_ADDR(6) => 
        WADDRESS(4), B_ADDR(5) => WADDRESS(3), B_ADDR(4) => 
        WADDRESS(2), B_ADDR(3) => WADDRESS(1), B_ADDR(2) => 
        WADDRESS(0), B_ADDR(1) => \GND\, B_ADDR(0) => \GND\, 
        B_WEN(1) => \GND\, B_WEN(0) => \VCC\, A_EN => \VCC\, 
        A_DOUT_LAT => \VCC\, A_WIDTH(2) => \GND\, A_WIDTH(1) => 
        \VCC\, A_WIDTH(0) => \GND\, A_WMODE => \GND\, B_EN => 
        \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => \GND\, 
        B_WIDTH(1) => \VCC\, B_WIDTH(0) => \GND\, B_WMODE => 
        \GND\, SII_LOCK => \GND\);
    
    RAMBLOCK4096X32_R0C3 : RAM1K18
      port map(A_DOUT(17) => nc134, A_DOUT(16) => nc32, 
        A_DOUT(15) => nc40, A_DOUT(14) => nc99, A_DOUT(13) => 
        nc75, A_DOUT(12) => nc183, A_DOUT(11) => nc85, A_DOUT(10)
         => nc27, A_DOUT(9) => nc108, A_DOUT(8) => nc16, 
        A_DOUT(7) => nc155, A_DOUT(6) => nc51, A_DOUT(5) => nc33, 
        A_DOUT(4) => nc204, A_DOUT(3) => Q(15), A_DOUT(2) => 
        Q(14), A_DOUT(1) => Q(13), A_DOUT(0) => Q(12), B_DOUT(17)
         => nc173, B_DOUT(16) => nc169, B_DOUT(15) => nc78, 
        B_DOUT(14) => nc24, B_DOUT(13) => nc88, B_DOUT(12) => 
        nc111, B_DOUT(11) => nc55, B_DOUT(10) => nc10, B_DOUT(9)
         => nc22, B_DOUT(8) => nc210, B_DOUT(7) => nc185, 
        B_DOUT(6) => nc143, B_DOUT(5) => nc248, B_DOUT(4) => nc77, 
        B_DOUT(3) => nc6, B_DOUT(2) => nc109, B_DOUT(1) => nc87, 
        B_DOUT(0) => nc123, BUSY => OPEN, A_CLK => RCLOCK, 
        A_DOUT_CLK => \VCC\, A_ARST_N => \VCC\, A_DOUT_EN => 
        \VCC\, A_BLK(2) => RE, A_BLK(1) => \VCC\, A_BLK(0) => 
        \VCC\, A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N => \VCC\, 
        A_DIN(17) => \GND\, A_DIN(16) => \GND\, A_DIN(15) => 
        \GND\, A_DIN(14) => \GND\, A_DIN(13) => \GND\, A_DIN(12)
         => \GND\, A_DIN(11) => \GND\, A_DIN(10) => \GND\, 
        A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7) => \GND\, 
        A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4) => \GND\, 
        A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1) => \GND\, 
        A_DIN(0) => \GND\, A_ADDR(13) => RADDRESS(11), A_ADDR(12)
         => RADDRESS(10), A_ADDR(11) => RADDRESS(9), A_ADDR(10)
         => RADDRESS(8), A_ADDR(9) => RADDRESS(7), A_ADDR(8) => 
        RADDRESS(6), A_ADDR(7) => RADDRESS(5), A_ADDR(6) => 
        RADDRESS(4), A_ADDR(5) => RADDRESS(3), A_ADDR(4) => 
        RADDRESS(2), A_ADDR(3) => RADDRESS(1), A_ADDR(2) => 
        RADDRESS(0), A_ADDR(1) => \GND\, A_ADDR(0) => \GND\, 
        A_WEN(1) => \GND\, A_WEN(0) => \GND\, B_CLK => WCLOCK, 
        B_DOUT_CLK => \VCC\, B_ARST_N => \VCC\, B_DOUT_EN => 
        \VCC\, B_BLK(2) => WE, B_BLK(1) => \VCC\, B_BLK(0) => 
        \VCC\, B_DOUT_ARST_N => \GND\, B_DOUT_SRST_N => \VCC\, 
        B_DIN(17) => \GND\, B_DIN(16) => \GND\, B_DIN(15) => 
        \GND\, B_DIN(14) => \GND\, B_DIN(13) => \GND\, B_DIN(12)
         => \GND\, B_DIN(11) => \GND\, B_DIN(10) => \GND\, 
        B_DIN(9) => \GND\, B_DIN(8) => \GND\, B_DIN(7) => \GND\, 
        B_DIN(6) => \GND\, B_DIN(5) => \GND\, B_DIN(4) => \GND\, 
        B_DIN(3) => DATA(15), B_DIN(2) => DATA(14), B_DIN(1) => 
        DATA(13), B_DIN(0) => DATA(12), B_ADDR(13) => 
        WADDRESS(11), B_ADDR(12) => WADDRESS(10), B_ADDR(11) => 
        WADDRESS(9), B_ADDR(10) => WADDRESS(8), B_ADDR(9) => 
        WADDRESS(7), B_ADDR(8) => WADDRESS(6), B_ADDR(7) => 
        WADDRESS(5), B_ADDR(6) => WADDRESS(4), B_ADDR(5) => 
        WADDRESS(3), B_ADDR(4) => WADDRESS(2), B_ADDR(3) => 
        WADDRESS(1), B_ADDR(2) => WADDRESS(0), B_ADDR(1) => \GND\, 
        B_ADDR(0) => \GND\, B_WEN(1) => \GND\, B_WEN(0) => \VCC\, 
        A_EN => \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2) => \GND\, 
        A_WIDTH(1) => \VCC\, A_WIDTH(0) => \GND\, A_WMODE => 
        \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => 
        \GND\, B_WIDTH(1) => \VCC\, B_WIDTH(0) => \GND\, B_WMODE
         => \GND\, SII_LOCK => \GND\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 
-- Version: v11.1 SP2 11.1.2.11

library ieee;
use ieee.std_logic_1164.all;
library SmartFusion2;
use SmartFusion2.all;

entity RAMBLOCK4096X8 is

    port( DATA     : in    std_logic_vector(7 downto 0);
          Q        : out   std_logic_vector(7 downto 0);
          WADDRESS : in    std_logic_vector(11 downto 0);
          RADDRESS : in    std_logic_vector(11 downto 0);
          WE       : in    std_logic;
          RE       : in    std_logic;
          WCLOCK   : in    std_logic;
          RCLOCK   : in    std_logic
        );

end RAMBLOCK4096X8;

architecture DEF_ARCH of RAMBLOCK4096X8 is 

  component RAM1K18
    generic (MEMORYFILE:string := "");

    port( A_DOUT        : out   std_logic_vector(17 downto 0);
          B_DOUT        : out   std_logic_vector(17 downto 0);
          BUSY          : out   std_logic;
          A_CLK         : in    std_logic := 'U';
          A_DOUT_CLK    : in    std_logic := 'U';
          A_ARST_N      : in    std_logic := 'U';
          A_DOUT_EN     : in    std_logic := 'U';
          A_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_DOUT_ARST_N : in    std_logic := 'U';
          A_DOUT_SRST_N : in    std_logic := 'U';
          A_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          A_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          A_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_CLK         : in    std_logic := 'U';
          B_DOUT_CLK    : in    std_logic := 'U';
          B_ARST_N      : in    std_logic := 'U';
          B_DOUT_EN     : in    std_logic := 'U';
          B_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_DOUT_ARST_N : in    std_logic := 'U';
          B_DOUT_SRST_N : in    std_logic := 'U';
          B_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          B_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          B_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_EN          : in    std_logic := 'U';
          A_DOUT_LAT    : in    std_logic := 'U';
          A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_WMODE       : in    std_logic := 'U';
          B_EN          : in    std_logic := 'U';
          B_DOUT_LAT    : in    std_logic := 'U';
          B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_WMODE       : in    std_logic := 'U';
          SII_LOCK      : in    std_logic := 'U'
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc47, nc34, nc60, nc64, nc9, nc13, nc23, nc55, nc33, 
        nc16, nc26, nc45, nc58, nc63, nc27, nc17, nc36, nc48, 
        nc37, nc5, nc52, nc51, nc4, nc42, nc41, nc59, nc25, nc15, 
        nc35, nc49, nc28, nc18, nc38, nc1, nc2, nc50, nc22, nc12, 
        nc21, nc11, nc54, nc3, nc32, nc40, nc31, nc44, nc7, nc6, 
        nc62, nc61, nc19, nc29, nc53, nc39, nc8, nc43, nc56, nc20, 
        nc10, nc57, nc24, nc14, nc46, nc30 : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    RAMBLOCK4096X8_R0C0 : RAM1K18
      port map(A_DOUT(17) => nc47, A_DOUT(16) => nc34, A_DOUT(15)
         => nc60, A_DOUT(14) => nc64, A_DOUT(13) => nc9, 
        A_DOUT(12) => nc13, A_DOUT(11) => nc23, A_DOUT(10) => 
        nc55, A_DOUT(9) => nc33, A_DOUT(8) => nc16, A_DOUT(7) => 
        nc26, A_DOUT(6) => nc45, A_DOUT(5) => nc58, A_DOUT(4) => 
        nc63, A_DOUT(3) => Q(3), A_DOUT(2) => Q(2), A_DOUT(1) => 
        Q(1), A_DOUT(0) => Q(0), B_DOUT(17) => nc27, B_DOUT(16)
         => nc17, B_DOUT(15) => nc36, B_DOUT(14) => nc48, 
        B_DOUT(13) => nc37, B_DOUT(12) => nc5, B_DOUT(11) => nc52, 
        B_DOUT(10) => nc51, B_DOUT(9) => nc4, B_DOUT(8) => nc42, 
        B_DOUT(7) => nc41, B_DOUT(6) => nc59, B_DOUT(5) => nc25, 
        B_DOUT(4) => nc15, B_DOUT(3) => nc35, B_DOUT(2) => nc49, 
        B_DOUT(1) => nc28, B_DOUT(0) => nc18, BUSY => OPEN, A_CLK
         => RCLOCK, A_DOUT_CLK => \VCC\, A_ARST_N => \VCC\, 
        A_DOUT_EN => \VCC\, A_BLK(2) => RE, A_BLK(1) => \VCC\, 
        A_BLK(0) => \VCC\, A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N
         => \VCC\, A_DIN(17) => \GND\, A_DIN(16) => \GND\, 
        A_DIN(15) => \GND\, A_DIN(14) => \GND\, A_DIN(13) => 
        \GND\, A_DIN(12) => \GND\, A_DIN(11) => \GND\, A_DIN(10)
         => \GND\, A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7)
         => \GND\, A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4)
         => \GND\, A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1)
         => \GND\, A_DIN(0) => \GND\, A_ADDR(13) => RADDRESS(11), 
        A_ADDR(12) => RADDRESS(10), A_ADDR(11) => RADDRESS(9), 
        A_ADDR(10) => RADDRESS(8), A_ADDR(9) => RADDRESS(7), 
        A_ADDR(8) => RADDRESS(6), A_ADDR(7) => RADDRESS(5), 
        A_ADDR(6) => RADDRESS(4), A_ADDR(5) => RADDRESS(3), 
        A_ADDR(4) => RADDRESS(2), A_ADDR(3) => RADDRESS(1), 
        A_ADDR(2) => RADDRESS(0), A_ADDR(1) => \GND\, A_ADDR(0)
         => \GND\, A_WEN(1) => \GND\, A_WEN(0) => \GND\, B_CLK
         => WCLOCK, B_DOUT_CLK => \VCC\, B_ARST_N => \VCC\, 
        B_DOUT_EN => \VCC\, B_BLK(2) => WE, B_BLK(1) => \VCC\, 
        B_BLK(0) => \VCC\, B_DOUT_ARST_N => \GND\, B_DOUT_SRST_N
         => \VCC\, B_DIN(17) => \GND\, B_DIN(16) => \GND\, 
        B_DIN(15) => \GND\, B_DIN(14) => \GND\, B_DIN(13) => 
        \GND\, B_DIN(12) => \GND\, B_DIN(11) => \GND\, B_DIN(10)
         => \GND\, B_DIN(9) => \GND\, B_DIN(8) => \GND\, B_DIN(7)
         => \GND\, B_DIN(6) => \GND\, B_DIN(5) => \GND\, B_DIN(4)
         => \GND\, B_DIN(3) => DATA(3), B_DIN(2) => DATA(2), 
        B_DIN(1) => DATA(1), B_DIN(0) => DATA(0), B_ADDR(13) => 
        WADDRESS(11), B_ADDR(12) => WADDRESS(10), B_ADDR(11) => 
        WADDRESS(9), B_ADDR(10) => WADDRESS(8), B_ADDR(9) => 
        WADDRESS(7), B_ADDR(8) => WADDRESS(6), B_ADDR(7) => 
        WADDRESS(5), B_ADDR(6) => WADDRESS(4), B_ADDR(5) => 
        WADDRESS(3), B_ADDR(4) => WADDRESS(2), B_ADDR(3) => 
        WADDRESS(1), B_ADDR(2) => WADDRESS(0), B_ADDR(1) => \GND\, 
        B_ADDR(0) => \GND\, B_WEN(1) => \GND\, B_WEN(0) => \VCC\, 
        A_EN => \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2) => \GND\, 
        A_WIDTH(1) => \VCC\, A_WIDTH(0) => \GND\, A_WMODE => 
        \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => 
        \GND\, B_WIDTH(1) => \VCC\, B_WIDTH(0) => \GND\, B_WMODE
         => \GND\, SII_LOCK => \GND\);
    
    RAMBLOCK4096X8_R0C1 : RAM1K18
      port map(A_DOUT(17) => nc38, A_DOUT(16) => nc1, A_DOUT(15)
         => nc2, A_DOUT(14) => nc50, A_DOUT(13) => nc22, 
        A_DOUT(12) => nc12, A_DOUT(11) => nc21, A_DOUT(10) => 
        nc11, A_DOUT(9) => nc54, A_DOUT(8) => nc3, A_DOUT(7) => 
        nc32, A_DOUT(6) => nc40, A_DOUT(5) => nc31, A_DOUT(4) => 
        nc44, A_DOUT(3) => Q(7), A_DOUT(2) => Q(6), A_DOUT(1) => 
        Q(5), A_DOUT(0) => Q(4), B_DOUT(17) => nc7, B_DOUT(16)
         => nc6, B_DOUT(15) => nc62, B_DOUT(14) => nc61, 
        B_DOUT(13) => nc19, B_DOUT(12) => nc29, B_DOUT(11) => 
        nc53, B_DOUT(10) => nc39, B_DOUT(9) => nc8, B_DOUT(8) => 
        nc43, B_DOUT(7) => nc56, B_DOUT(6) => nc20, B_DOUT(5) => 
        nc10, B_DOUT(4) => nc57, B_DOUT(3) => nc24, B_DOUT(2) => 
        nc14, B_DOUT(1) => nc46, B_DOUT(0) => nc30, BUSY => OPEN, 
        A_CLK => RCLOCK, A_DOUT_CLK => \VCC\, A_ARST_N => \VCC\, 
        A_DOUT_EN => \VCC\, A_BLK(2) => RE, A_BLK(1) => \VCC\, 
        A_BLK(0) => \VCC\, A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N
         => \VCC\, A_DIN(17) => \GND\, A_DIN(16) => \GND\, 
        A_DIN(15) => \GND\, A_DIN(14) => \GND\, A_DIN(13) => 
        \GND\, A_DIN(12) => \GND\, A_DIN(11) => \GND\, A_DIN(10)
         => \GND\, A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7)
         => \GND\, A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4)
         => \GND\, A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1)
         => \GND\, A_DIN(0) => \GND\, A_ADDR(13) => RADDRESS(11), 
        A_ADDR(12) => RADDRESS(10), A_ADDR(11) => RADDRESS(9), 
        A_ADDR(10) => RADDRESS(8), A_ADDR(9) => RADDRESS(7), 
        A_ADDR(8) => RADDRESS(6), A_ADDR(7) => RADDRESS(5), 
        A_ADDR(6) => RADDRESS(4), A_ADDR(5) => RADDRESS(3), 
        A_ADDR(4) => RADDRESS(2), A_ADDR(3) => RADDRESS(1), 
        A_ADDR(2) => RADDRESS(0), A_ADDR(1) => \GND\, A_ADDR(0)
         => \GND\, A_WEN(1) => \GND\, A_WEN(0) => \GND\, B_CLK
         => WCLOCK, B_DOUT_CLK => \VCC\, B_ARST_N => \VCC\, 
        B_DOUT_EN => \VCC\, B_BLK(2) => WE, B_BLK(1) => \VCC\, 
        B_BLK(0) => \VCC\, B_DOUT_ARST_N => \GND\, B_DOUT_SRST_N
         => \VCC\, B_DIN(17) => \GND\, B_DIN(16) => \GND\, 
        B_DIN(15) => \GND\, B_DIN(14) => \GND\, B_DIN(13) => 
        \GND\, B_DIN(12) => \GND\, B_DIN(11) => \GND\, B_DIN(10)
         => \GND\, B_DIN(9) => \GND\, B_DIN(8) => \GND\, B_DIN(7)
         => \GND\, B_DIN(6) => \GND\, B_DIN(5) => \GND\, B_DIN(4)
         => \GND\, B_DIN(3) => DATA(7), B_DIN(2) => DATA(6), 
        B_DIN(1) => DATA(5), B_DIN(0) => DATA(4), B_ADDR(13) => 
        WADDRESS(11), B_ADDR(12) => WADDRESS(10), B_ADDR(11) => 
        WADDRESS(9), B_ADDR(10) => WADDRESS(8), B_ADDR(9) => 
        WADDRESS(7), B_ADDR(8) => WADDRESS(6), B_ADDR(7) => 
        WADDRESS(5), B_ADDR(6) => WADDRESS(4), B_ADDR(5) => 
        WADDRESS(3), B_ADDR(4) => WADDRESS(2), B_ADDR(3) => 
        WADDRESS(1), B_ADDR(2) => WADDRESS(0), B_ADDR(1) => \GND\, 
        B_ADDR(0) => \GND\, B_WEN(1) => \GND\, B_WEN(0) => \VCC\, 
        A_EN => \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2) => \GND\, 
        A_WIDTH(1) => \VCC\, A_WIDTH(0) => \GND\, A_WMODE => 
        \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => 
        \GND\, B_WIDTH(1) => \VCC\, B_WIDTH(0) => \GND\, B_WMODE
         => \GND\, SII_LOCK => \GND\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 
-- Version: v11.1 SP2 11.1.2.11

library ieee;
use ieee.std_logic_1164.all;
library SmartFusion2;
use SmartFusion2.all;

entity RAMBLOCK512X16 is

    port( DATA     : in    std_logic_vector(15 downto 0);
          Q        : out   std_logic_vector(15 downto 0);
          WADDRESS : in    std_logic_vector(8 downto 0);
          RADDRESS : in    std_logic_vector(8 downto 0);
          WE       : in    std_logic;
          RE       : in    std_logic;
          WCLOCK   : in    std_logic;
          RCLOCK   : in    std_logic
        );

end RAMBLOCK512X16;

architecture DEF_ARCH of RAMBLOCK512X16 is 

  component RAM1K18
    generic (MEMORYFILE:string := "");

    port( A_DOUT        : out   std_logic_vector(17 downto 0);
          B_DOUT        : out   std_logic_vector(17 downto 0);
          BUSY          : out   std_logic;
          A_CLK         : in    std_logic := 'U';
          A_DOUT_CLK    : in    std_logic := 'U';
          A_ARST_N      : in    std_logic := 'U';
          A_DOUT_EN     : in    std_logic := 'U';
          A_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_DOUT_ARST_N : in    std_logic := 'U';
          A_DOUT_SRST_N : in    std_logic := 'U';
          A_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          A_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          A_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_CLK         : in    std_logic := 'U';
          B_DOUT_CLK    : in    std_logic := 'U';
          B_ARST_N      : in    std_logic := 'U';
          B_DOUT_EN     : in    std_logic := 'U';
          B_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_DOUT_ARST_N : in    std_logic := 'U';
          B_DOUT_SRST_N : in    std_logic := 'U';
          B_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          B_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          B_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_EN          : in    std_logic := 'U';
          A_DOUT_LAT    : in    std_logic := 'U';
          A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_WMODE       : in    std_logic := 'U';
          B_EN          : in    std_logic := 'U';
          B_DOUT_LAT    : in    std_logic := 'U';
          B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_WMODE       : in    std_logic := 'U';
          SII_LOCK      : in    std_logic := 'U'
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc1, nc8, nc13, nc16, nc19, nc20, nc9, nc14, nc5, nc15, 
        nc3, nc10, nc7, nc17, nc4, nc12, nc2, nc18, nc6, nc11
         : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    RAMBLOCK512X16_R0C0 : RAM1K18
      port map(A_DOUT(17) => nc1, A_DOUT(16) => Q(15), A_DOUT(15)
         => Q(14), A_DOUT(14) => Q(13), A_DOUT(13) => Q(12), 
        A_DOUT(12) => Q(11), A_DOUT(11) => Q(10), A_DOUT(10) => 
        Q(9), A_DOUT(9) => Q(8), A_DOUT(8) => nc8, A_DOUT(7) => 
        Q(7), A_DOUT(6) => Q(6), A_DOUT(5) => Q(5), A_DOUT(4) => 
        Q(4), A_DOUT(3) => Q(3), A_DOUT(2) => Q(2), A_DOUT(1) => 
        Q(1), A_DOUT(0) => Q(0), B_DOUT(17) => nc13, B_DOUT(16)
         => nc16, B_DOUT(15) => nc19, B_DOUT(14) => nc20, 
        B_DOUT(13) => nc9, B_DOUT(12) => nc14, B_DOUT(11) => nc5, 
        B_DOUT(10) => nc15, B_DOUT(9) => nc3, B_DOUT(8) => nc10, 
        B_DOUT(7) => nc7, B_DOUT(6) => nc17, B_DOUT(5) => nc4, 
        B_DOUT(4) => nc12, B_DOUT(3) => nc2, B_DOUT(2) => nc18, 
        B_DOUT(1) => nc6, B_DOUT(0) => nc11, BUSY => OPEN, A_CLK
         => RCLOCK, A_DOUT_CLK => \VCC\, A_ARST_N => \VCC\, 
        A_DOUT_EN => \VCC\, A_BLK(2) => RE, A_BLK(1) => \VCC\, 
        A_BLK(0) => \VCC\, A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N
         => \VCC\, A_DIN(17) => \GND\, A_DIN(16) => \GND\, 
        A_DIN(15) => \GND\, A_DIN(14) => \GND\, A_DIN(13) => 
        \GND\, A_DIN(12) => \GND\, A_DIN(11) => \GND\, A_DIN(10)
         => \GND\, A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7)
         => \GND\, A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4)
         => \GND\, A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1)
         => \GND\, A_DIN(0) => \GND\, A_ADDR(13) => \GND\, 
        A_ADDR(12) => RADDRESS(8), A_ADDR(11) => RADDRESS(7), 
        A_ADDR(10) => RADDRESS(6), A_ADDR(9) => RADDRESS(5), 
        A_ADDR(8) => RADDRESS(4), A_ADDR(7) => RADDRESS(3), 
        A_ADDR(6) => RADDRESS(2), A_ADDR(5) => RADDRESS(1), 
        A_ADDR(4) => RADDRESS(0), A_ADDR(3) => \GND\, A_ADDR(2)
         => \GND\, A_ADDR(1) => \GND\, A_ADDR(0) => \GND\, 
        A_WEN(1) => \GND\, A_WEN(0) => \GND\, B_CLK => WCLOCK, 
        B_DOUT_CLK => \VCC\, B_ARST_N => \VCC\, B_DOUT_EN => 
        \VCC\, B_BLK(2) => WE, B_BLK(1) => \VCC\, B_BLK(0) => 
        \VCC\, B_DOUT_ARST_N => \GND\, B_DOUT_SRST_N => \VCC\, 
        B_DIN(17) => \GND\, B_DIN(16) => DATA(15), B_DIN(15) => 
        DATA(14), B_DIN(14) => DATA(13), B_DIN(13) => DATA(12), 
        B_DIN(12) => DATA(11), B_DIN(11) => DATA(10), B_DIN(10)
         => DATA(9), B_DIN(9) => DATA(8), B_DIN(8) => \GND\, 
        B_DIN(7) => DATA(7), B_DIN(6) => DATA(6), B_DIN(5) => 
        DATA(5), B_DIN(4) => DATA(4), B_DIN(3) => DATA(3), 
        B_DIN(2) => DATA(2), B_DIN(1) => DATA(1), B_DIN(0) => 
        DATA(0), B_ADDR(13) => \GND\, B_ADDR(12) => WADDRESS(8), 
        B_ADDR(11) => WADDRESS(7), B_ADDR(10) => WADDRESS(6), 
        B_ADDR(9) => WADDRESS(5), B_ADDR(8) => WADDRESS(4), 
        B_ADDR(7) => WADDRESS(3), B_ADDR(6) => WADDRESS(2), 
        B_ADDR(5) => WADDRESS(1), B_ADDR(4) => WADDRESS(0), 
        B_ADDR(3) => \GND\, B_ADDR(2) => \GND\, B_ADDR(1) => 
        \GND\, B_ADDR(0) => \GND\, B_WEN(1) => \VCC\, B_WEN(0)
         => \VCC\, A_EN => \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2)
         => \VCC\, A_WIDTH(1) => \GND\, A_WIDTH(0) => \GND\, 
        A_WMODE => \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, 
        B_WIDTH(2) => \VCC\, B_WIDTH(1) => \GND\, B_WIDTH(0) => 
        \GND\, B_WMODE => \GND\, SII_LOCK => \GND\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 
-- Version: v11.1 SP2 11.1.2.11

library ieee;
use ieee.std_logic_1164.all;
library SmartFusion2;
use SmartFusion2.all;

entity RAMBLOCK512X32 is

    port( DATA     : in    std_logic_vector(31 downto 0);
          Q        : out   std_logic_vector(31 downto 0);
          WADDRESS : in    std_logic_vector(8 downto 0);
          RADDRESS : in    std_logic_vector(8 downto 0);
          WE       : in    std_logic;
          RE       : in    std_logic;
          WCLOCK   : in    std_logic;
          RCLOCK   : in    std_logic
        );

end RAMBLOCK512X32;

architecture DEF_ARCH of RAMBLOCK512X32 is 

  component RAM1K18
    generic (MEMORYFILE:string := "");

    port( A_DOUT        : out   std_logic_vector(17 downto 0);
          B_DOUT        : out   std_logic_vector(17 downto 0);
          BUSY          : out   std_logic;
          A_CLK         : in    std_logic := 'U';
          A_DOUT_CLK    : in    std_logic := 'U';
          A_ARST_N      : in    std_logic := 'U';
          A_DOUT_EN     : in    std_logic := 'U';
          A_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_DOUT_ARST_N : in    std_logic := 'U';
          A_DOUT_SRST_N : in    std_logic := 'U';
          A_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          A_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          A_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_CLK         : in    std_logic := 'U';
          B_DOUT_CLK    : in    std_logic := 'U';
          B_ARST_N      : in    std_logic := 'U';
          B_DOUT_EN     : in    std_logic := 'U';
          B_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_DOUT_ARST_N : in    std_logic := 'U';
          B_DOUT_SRST_N : in    std_logic := 'U';
          B_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          B_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          B_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_EN          : in    std_logic := 'U';
          A_DOUT_LAT    : in    std_logic := 'U';
          A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_WMODE       : in    std_logic := 'U';
          B_EN          : in    std_logic := 'U';
          B_DOUT_LAT    : in    std_logic := 'U';
          B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_WMODE       : in    std_logic := 'U';
          SII_LOCK      : in    std_logic := 'U'
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc2, nc4, nc3, nc1 : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    RAMBLOCK512X32_R0C0 : RAM1K18
      port map(A_DOUT(17) => nc2, A_DOUT(16) => Q(31), A_DOUT(15)
         => Q(30), A_DOUT(14) => Q(29), A_DOUT(13) => Q(28), 
        A_DOUT(12) => Q(27), A_DOUT(11) => Q(26), A_DOUT(10) => 
        Q(25), A_DOUT(9) => Q(24), A_DOUT(8) => nc4, A_DOUT(7)
         => Q(23), A_DOUT(6) => Q(22), A_DOUT(5) => Q(21), 
        A_DOUT(4) => Q(20), A_DOUT(3) => Q(19), A_DOUT(2) => 
        Q(18), A_DOUT(1) => Q(17), A_DOUT(0) => Q(16), B_DOUT(17)
         => nc3, B_DOUT(16) => Q(15), B_DOUT(15) => Q(14), 
        B_DOUT(14) => Q(13), B_DOUT(13) => Q(12), B_DOUT(12) => 
        Q(11), B_DOUT(11) => Q(10), B_DOUT(10) => Q(9), B_DOUT(9)
         => Q(8), B_DOUT(8) => nc1, B_DOUT(7) => Q(7), B_DOUT(6)
         => Q(6), B_DOUT(5) => Q(5), B_DOUT(4) => Q(4), B_DOUT(3)
         => Q(3), B_DOUT(2) => Q(2), B_DOUT(1) => Q(1), B_DOUT(0)
         => Q(0), BUSY => OPEN, A_CLK => RCLOCK, A_DOUT_CLK => 
        \VCC\, A_ARST_N => \VCC\, A_DOUT_EN => \VCC\, A_BLK(2)
         => RE, A_BLK(1) => \VCC\, A_BLK(0) => \VCC\, 
        A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N => \VCC\, A_DIN(17)
         => \GND\, A_DIN(16) => DATA(31), A_DIN(15) => DATA(30), 
        A_DIN(14) => DATA(29), A_DIN(13) => DATA(28), A_DIN(12)
         => DATA(27), A_DIN(11) => DATA(26), A_DIN(10) => 
        DATA(25), A_DIN(9) => DATA(24), A_DIN(8) => \GND\, 
        A_DIN(7) => DATA(23), A_DIN(6) => DATA(22), A_DIN(5) => 
        DATA(21), A_DIN(4) => DATA(20), A_DIN(3) => DATA(19), 
        A_DIN(2) => DATA(18), A_DIN(1) => DATA(17), A_DIN(0) => 
        DATA(16), A_ADDR(13) => RADDRESS(8), A_ADDR(12) => 
        RADDRESS(7), A_ADDR(11) => RADDRESS(6), A_ADDR(10) => 
        RADDRESS(5), A_ADDR(9) => RADDRESS(4), A_ADDR(8) => 
        RADDRESS(3), A_ADDR(7) => RADDRESS(2), A_ADDR(6) => 
        RADDRESS(1), A_ADDR(5) => RADDRESS(0), A_ADDR(4) => \GND\, 
        A_ADDR(3) => \GND\, A_ADDR(2) => \GND\, A_ADDR(1) => 
        \GND\, A_ADDR(0) => \GND\, A_WEN(1) => \VCC\, A_WEN(0)
         => \VCC\, B_CLK => WCLOCK, B_DOUT_CLK => \VCC\, B_ARST_N
         => \VCC\, B_DOUT_EN => \VCC\, B_BLK(2) => WE, B_BLK(1)
         => \VCC\, B_BLK(0) => \VCC\, B_DOUT_ARST_N => \VCC\, 
        B_DOUT_SRST_N => \VCC\, B_DIN(17) => \GND\, B_DIN(16) => 
        DATA(15), B_DIN(15) => DATA(14), B_DIN(14) => DATA(13), 
        B_DIN(13) => DATA(12), B_DIN(12) => DATA(11), B_DIN(11)
         => DATA(10), B_DIN(10) => DATA(9), B_DIN(9) => DATA(8), 
        B_DIN(8) => \GND\, B_DIN(7) => DATA(7), B_DIN(6) => 
        DATA(6), B_DIN(5) => DATA(5), B_DIN(4) => DATA(4), 
        B_DIN(3) => DATA(3), B_DIN(2) => DATA(2), B_DIN(1) => 
        DATA(1), B_DIN(0) => DATA(0), B_ADDR(13) => WADDRESS(8), 
        B_ADDR(12) => WADDRESS(7), B_ADDR(11) => WADDRESS(6), 
        B_ADDR(10) => WADDRESS(5), B_ADDR(9) => WADDRESS(4), 
        B_ADDR(8) => WADDRESS(3), B_ADDR(7) => WADDRESS(2), 
        B_ADDR(6) => WADDRESS(1), B_ADDR(5) => WADDRESS(0), 
        B_ADDR(4) => \GND\, B_ADDR(3) => \GND\, B_ADDR(2) => 
        \GND\, B_ADDR(1) => \GND\, B_ADDR(0) => \GND\, B_WEN(1)
         => \VCC\, B_WEN(0) => \VCC\, A_EN => \VCC\, A_DOUT_LAT
         => \VCC\, A_WIDTH(2) => \VCC\, A_WIDTH(1) => \GND\, 
        A_WIDTH(0) => \VCC\, A_WMODE => \GND\, B_EN => \VCC\, 
        B_DOUT_LAT => \VCC\, B_WIDTH(2) => \VCC\, B_WIDTH(1) => 
        \GND\, B_WIDTH(0) => \VCC\, B_WMODE => \GND\, SII_LOCK
         => \GND\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 
-- Version: v11.1 SP2 11.1.2.11

library ieee;
use ieee.std_logic_1164.all;
library SmartFusion2;
use SmartFusion2.all;

entity RAMBLOCK512X8 is

    port( DATA     : in    std_logic_vector(7 downto 0);
          Q        : out   std_logic_vector(7 downto 0);
          WADDRESS : in    std_logic_vector(8 downto 0);
          RADDRESS : in    std_logic_vector(8 downto 0);
          WE       : in    std_logic;
          RE       : in    std_logic;
          WCLOCK   : in    std_logic;
          RCLOCK   : in    std_logic
        );

end RAMBLOCK512X8;

architecture DEF_ARCH of RAMBLOCK512X8 is 

  component RAM1K18
    generic (MEMORYFILE:string := "");

    port( A_DOUT        : out   std_logic_vector(17 downto 0);
          B_DOUT        : out   std_logic_vector(17 downto 0);
          BUSY          : out   std_logic;
          A_CLK         : in    std_logic := 'U';
          A_DOUT_CLK    : in    std_logic := 'U';
          A_ARST_N      : in    std_logic := 'U';
          A_DOUT_EN     : in    std_logic := 'U';
          A_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_DOUT_ARST_N : in    std_logic := 'U';
          A_DOUT_SRST_N : in    std_logic := 'U';
          A_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          A_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          A_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_CLK         : in    std_logic := 'U';
          B_DOUT_CLK    : in    std_logic := 'U';
          B_ARST_N      : in    std_logic := 'U';
          B_DOUT_EN     : in    std_logic := 'U';
          B_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_DOUT_ARST_N : in    std_logic := 'U';
          B_DOUT_SRST_N : in    std_logic := 'U';
          B_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          B_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          B_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_EN          : in    std_logic := 'U';
          A_DOUT_LAT    : in    std_logic := 'U';
          A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_WMODE       : in    std_logic := 'U';
          B_EN          : in    std_logic := 'U';
          B_DOUT_LAT    : in    std_logic := 'U';
          B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_WMODE       : in    std_logic := 'U';
          SII_LOCK      : in    std_logic := 'U'
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc24, nc1, nc8, nc13, nc16, nc19, nc25, nc20, nc27, 
        nc9, nc22, nc28, nc14, nc5, nc21, nc15, nc3, nc10, nc7, 
        nc17, nc4, nc12, nc2, nc23, nc18, nc26, nc6, nc11
         : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    RAMBLOCK512X8_R0C0 : RAM1K18
      port map(A_DOUT(17) => nc24, A_DOUT(16) => nc1, A_DOUT(15)
         => nc8, A_DOUT(14) => nc13, A_DOUT(13) => nc16, 
        A_DOUT(12) => nc19, A_DOUT(11) => nc25, A_DOUT(10) => 
        nc20, A_DOUT(9) => nc27, A_DOUT(8) => nc9, A_DOUT(7) => 
        Q(7), A_DOUT(6) => Q(6), A_DOUT(5) => Q(5), A_DOUT(4) => 
        Q(4), A_DOUT(3) => Q(3), A_DOUT(2) => Q(2), A_DOUT(1) => 
        Q(1), A_DOUT(0) => Q(0), B_DOUT(17) => nc22, B_DOUT(16)
         => nc28, B_DOUT(15) => nc14, B_DOUT(14) => nc5, 
        B_DOUT(13) => nc21, B_DOUT(12) => nc15, B_DOUT(11) => nc3, 
        B_DOUT(10) => nc10, B_DOUT(9) => nc7, B_DOUT(8) => nc17, 
        B_DOUT(7) => nc4, B_DOUT(6) => nc12, B_DOUT(5) => nc2, 
        B_DOUT(4) => nc23, B_DOUT(3) => nc18, B_DOUT(2) => nc26, 
        B_DOUT(1) => nc6, B_DOUT(0) => nc11, BUSY => OPEN, A_CLK
         => RCLOCK, A_DOUT_CLK => \VCC\, A_ARST_N => \VCC\, 
        A_DOUT_EN => \VCC\, A_BLK(2) => RE, A_BLK(1) => \VCC\, 
        A_BLK(0) => \VCC\, A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N
         => \VCC\, A_DIN(17) => \GND\, A_DIN(16) => \GND\, 
        A_DIN(15) => \GND\, A_DIN(14) => \GND\, A_DIN(13) => 
        \GND\, A_DIN(12) => \GND\, A_DIN(11) => \GND\, A_DIN(10)
         => \GND\, A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7)
         => \GND\, A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4)
         => \GND\, A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1)
         => \GND\, A_DIN(0) => \GND\, A_ADDR(13) => \GND\, 
        A_ADDR(12) => \GND\, A_ADDR(11) => RADDRESS(8), 
        A_ADDR(10) => RADDRESS(7), A_ADDR(9) => RADDRESS(6), 
        A_ADDR(8) => RADDRESS(5), A_ADDR(7) => RADDRESS(4), 
        A_ADDR(6) => RADDRESS(3), A_ADDR(5) => RADDRESS(2), 
        A_ADDR(4) => RADDRESS(1), A_ADDR(3) => RADDRESS(0), 
        A_ADDR(2) => \GND\, A_ADDR(1) => \GND\, A_ADDR(0) => 
        \GND\, A_WEN(1) => \GND\, A_WEN(0) => \GND\, B_CLK => 
        WCLOCK, B_DOUT_CLK => \VCC\, B_ARST_N => \VCC\, B_DOUT_EN
         => \VCC\, B_BLK(2) => WE, B_BLK(1) => \VCC\, B_BLK(0)
         => \VCC\, B_DOUT_ARST_N => \GND\, B_DOUT_SRST_N => \VCC\, 
        B_DIN(17) => \GND\, B_DIN(16) => \GND\, B_DIN(15) => 
        \GND\, B_DIN(14) => \GND\, B_DIN(13) => \GND\, B_DIN(12)
         => \GND\, B_DIN(11) => \GND\, B_DIN(10) => \GND\, 
        B_DIN(9) => \GND\, B_DIN(8) => \GND\, B_DIN(7) => DATA(7), 
        B_DIN(6) => DATA(6), B_DIN(5) => DATA(5), B_DIN(4) => 
        DATA(4), B_DIN(3) => DATA(3), B_DIN(2) => DATA(2), 
        B_DIN(1) => DATA(1), B_DIN(0) => DATA(0), B_ADDR(13) => 
        \GND\, B_ADDR(12) => \GND\, B_ADDR(11) => WADDRESS(8), 
        B_ADDR(10) => WADDRESS(7), B_ADDR(9) => WADDRESS(6), 
        B_ADDR(8) => WADDRESS(5), B_ADDR(7) => WADDRESS(4), 
        B_ADDR(6) => WADDRESS(3), B_ADDR(5) => WADDRESS(2), 
        B_ADDR(4) => WADDRESS(1), B_ADDR(3) => WADDRESS(0), 
        B_ADDR(2) => \GND\, B_ADDR(1) => \GND\, B_ADDR(0) => 
        \GND\, B_WEN(1) => \GND\, B_WEN(0) => \VCC\, A_EN => 
        \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2) => \GND\, 
        A_WIDTH(1) => \VCC\, A_WIDTH(0) => \VCC\, A_WMODE => 
        \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => 
        \GND\, B_WIDTH(1) => \VCC\, B_WIDTH(0) => \VCC\, B_WMODE
         => \GND\, SII_LOCK => \GND\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 
-- Version: v11.1 SP2 11.1.2.11

library ieee;
use ieee.std_logic_1164.all;
library SmartFusion2;
use SmartFusion2.all;

entity RAMBLOCK64X16 is

    port( DATA     : in    std_logic_vector(15 downto 0);
          Q        : out   std_logic_vector(15 downto 0);
          WADDRESS : in    std_logic_vector(5 downto 0);
          RADDRESS : in    std_logic_vector(5 downto 0);
          WE       : in    std_logic;
          RE       : in    std_logic;
          WCLOCK   : in    std_logic;
          RCLOCK   : in    std_logic
        );

end RAMBLOCK64X16;

architecture DEF_ARCH of RAMBLOCK64X16 is 

  component RAM1K18
    generic (MEMORYFILE:string := "");

    port( A_DOUT        : out   std_logic_vector(17 downto 0);
          B_DOUT        : out   std_logic_vector(17 downto 0);
          BUSY          : out   std_logic;
          A_CLK         : in    std_logic := 'U';
          A_DOUT_CLK    : in    std_logic := 'U';
          A_ARST_N      : in    std_logic := 'U';
          A_DOUT_EN     : in    std_logic := 'U';
          A_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_DOUT_ARST_N : in    std_logic := 'U';
          A_DOUT_SRST_N : in    std_logic := 'U';
          A_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          A_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          A_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_CLK         : in    std_logic := 'U';
          B_DOUT_CLK    : in    std_logic := 'U';
          B_ARST_N      : in    std_logic := 'U';
          B_DOUT_EN     : in    std_logic := 'U';
          B_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_DOUT_ARST_N : in    std_logic := 'U';
          B_DOUT_SRST_N : in    std_logic := 'U';
          B_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          B_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          B_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_EN          : in    std_logic := 'U';
          A_DOUT_LAT    : in    std_logic := 'U';
          A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_WMODE       : in    std_logic := 'U';
          B_EN          : in    std_logic := 'U';
          B_DOUT_LAT    : in    std_logic := 'U';
          B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_WMODE       : in    std_logic := 'U';
          SII_LOCK      : in    std_logic := 'U'
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc1, nc8, nc13, nc16, nc19, nc20, nc9, nc14, nc5, nc15, 
        nc3, nc10, nc7, nc17, nc4, nc12, nc2, nc18, nc6, nc11
         : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    RAMBLOCK64X16_R0C0 : RAM1K18
      port map(A_DOUT(17) => nc1, A_DOUT(16) => Q(15), A_DOUT(15)
         => Q(14), A_DOUT(14) => Q(13), A_DOUT(13) => Q(12), 
        A_DOUT(12) => Q(11), A_DOUT(11) => Q(10), A_DOUT(10) => 
        Q(9), A_DOUT(9) => Q(8), A_DOUT(8) => nc8, A_DOUT(7) => 
        Q(7), A_DOUT(6) => Q(6), A_DOUT(5) => Q(5), A_DOUT(4) => 
        Q(4), A_DOUT(3) => Q(3), A_DOUT(2) => Q(2), A_DOUT(1) => 
        Q(1), A_DOUT(0) => Q(0), B_DOUT(17) => nc13, B_DOUT(16)
         => nc16, B_DOUT(15) => nc19, B_DOUT(14) => nc20, 
        B_DOUT(13) => nc9, B_DOUT(12) => nc14, B_DOUT(11) => nc5, 
        B_DOUT(10) => nc15, B_DOUT(9) => nc3, B_DOUT(8) => nc10, 
        B_DOUT(7) => nc7, B_DOUT(6) => nc17, B_DOUT(5) => nc4, 
        B_DOUT(4) => nc12, B_DOUT(3) => nc2, B_DOUT(2) => nc18, 
        B_DOUT(1) => nc6, B_DOUT(0) => nc11, BUSY => OPEN, A_CLK
         => RCLOCK, A_DOUT_CLK => \VCC\, A_ARST_N => \VCC\, 
        A_DOUT_EN => \VCC\, A_BLK(2) => RE, A_BLK(1) => \VCC\, 
        A_BLK(0) => \VCC\, A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N
         => \VCC\, A_DIN(17) => \GND\, A_DIN(16) => \GND\, 
        A_DIN(15) => \GND\, A_DIN(14) => \GND\, A_DIN(13) => 
        \GND\, A_DIN(12) => \GND\, A_DIN(11) => \GND\, A_DIN(10)
         => \GND\, A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7)
         => \GND\, A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4)
         => \GND\, A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1)
         => \GND\, A_DIN(0) => \GND\, A_ADDR(13) => \GND\, 
        A_ADDR(12) => \GND\, A_ADDR(11) => \GND\, A_ADDR(10) => 
        \GND\, A_ADDR(9) => RADDRESS(5), A_ADDR(8) => RADDRESS(4), 
        A_ADDR(7) => RADDRESS(3), A_ADDR(6) => RADDRESS(2), 
        A_ADDR(5) => RADDRESS(1), A_ADDR(4) => RADDRESS(0), 
        A_ADDR(3) => \GND\, A_ADDR(2) => \GND\, A_ADDR(1) => 
        \GND\, A_ADDR(0) => \GND\, A_WEN(1) => \GND\, A_WEN(0)
         => \GND\, B_CLK => WCLOCK, B_DOUT_CLK => \VCC\, B_ARST_N
         => \VCC\, B_DOUT_EN => \VCC\, B_BLK(2) => WE, B_BLK(1)
         => \VCC\, B_BLK(0) => \VCC\, B_DOUT_ARST_N => \GND\, 
        B_DOUT_SRST_N => \VCC\, B_DIN(17) => \GND\, B_DIN(16) => 
        DATA(15), B_DIN(15) => DATA(14), B_DIN(14) => DATA(13), 
        B_DIN(13) => DATA(12), B_DIN(12) => DATA(11), B_DIN(11)
         => DATA(10), B_DIN(10) => DATA(9), B_DIN(9) => DATA(8), 
        B_DIN(8) => \GND\, B_DIN(7) => DATA(7), B_DIN(6) => 
        DATA(6), B_DIN(5) => DATA(5), B_DIN(4) => DATA(4), 
        B_DIN(3) => DATA(3), B_DIN(2) => DATA(2), B_DIN(1) => 
        DATA(1), B_DIN(0) => DATA(0), B_ADDR(13) => \GND\, 
        B_ADDR(12) => \GND\, B_ADDR(11) => \GND\, B_ADDR(10) => 
        \GND\, B_ADDR(9) => WADDRESS(5), B_ADDR(8) => WADDRESS(4), 
        B_ADDR(7) => WADDRESS(3), B_ADDR(6) => WADDRESS(2), 
        B_ADDR(5) => WADDRESS(1), B_ADDR(4) => WADDRESS(0), 
        B_ADDR(3) => \GND\, B_ADDR(2) => \GND\, B_ADDR(1) => 
        \GND\, B_ADDR(0) => \GND\, B_WEN(1) => \VCC\, B_WEN(0)
         => \VCC\, A_EN => \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2)
         => \VCC\, A_WIDTH(1) => \GND\, A_WIDTH(0) => \GND\, 
        A_WMODE => \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, 
        B_WIDTH(2) => \VCC\, B_WIDTH(1) => \GND\, B_WIDTH(0) => 
        \GND\, B_WMODE => \GND\, SII_LOCK => \GND\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 
-- Version: v11.1 SP2 11.1.2.11

library ieee;
use ieee.std_logic_1164.all;
library SmartFusion2;
use SmartFusion2.all;

entity RAMBLOCK64X32 is

    port( DATA     : in    std_logic_vector(31 downto 0);
          Q        : out   std_logic_vector(31 downto 0);
          WADDRESS : in    std_logic_vector(5 downto 0);
          RADDRESS : in    std_logic_vector(5 downto 0);
          WE       : in    std_logic;
          RE       : in    std_logic;
          WCLOCK   : in    std_logic;
          RCLOCK   : in    std_logic
        );

end RAMBLOCK64X32;

architecture DEF_ARCH of RAMBLOCK64X32 is 

  component RAM1K18
    generic (MEMORYFILE:string := "");

    port( A_DOUT        : out   std_logic_vector(17 downto 0);
          B_DOUT        : out   std_logic_vector(17 downto 0);
          BUSY          : out   std_logic;
          A_CLK         : in    std_logic := 'U';
          A_DOUT_CLK    : in    std_logic := 'U';
          A_ARST_N      : in    std_logic := 'U';
          A_DOUT_EN     : in    std_logic := 'U';
          A_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_DOUT_ARST_N : in    std_logic := 'U';
          A_DOUT_SRST_N : in    std_logic := 'U';
          A_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          A_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          A_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_CLK         : in    std_logic := 'U';
          B_DOUT_CLK    : in    std_logic := 'U';
          B_ARST_N      : in    std_logic := 'U';
          B_DOUT_EN     : in    std_logic := 'U';
          B_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_DOUT_ARST_N : in    std_logic := 'U';
          B_DOUT_SRST_N : in    std_logic := 'U';
          B_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          B_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          B_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_EN          : in    std_logic := 'U';
          A_DOUT_LAT    : in    std_logic := 'U';
          A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_WMODE       : in    std_logic := 'U';
          B_EN          : in    std_logic := 'U';
          B_DOUT_LAT    : in    std_logic := 'U';
          B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_WMODE       : in    std_logic := 'U';
          SII_LOCK      : in    std_logic := 'U'
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc2, nc4, nc3, nc1 : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    RAMBLOCK64X32_R0C0 : RAM1K18
      port map(A_DOUT(17) => nc2, A_DOUT(16) => Q(31), A_DOUT(15)
         => Q(30), A_DOUT(14) => Q(29), A_DOUT(13) => Q(28), 
        A_DOUT(12) => Q(27), A_DOUT(11) => Q(26), A_DOUT(10) => 
        Q(25), A_DOUT(9) => Q(24), A_DOUT(8) => nc4, A_DOUT(7)
         => Q(23), A_DOUT(6) => Q(22), A_DOUT(5) => Q(21), 
        A_DOUT(4) => Q(20), A_DOUT(3) => Q(19), A_DOUT(2) => 
        Q(18), A_DOUT(1) => Q(17), A_DOUT(0) => Q(16), B_DOUT(17)
         => nc3, B_DOUT(16) => Q(15), B_DOUT(15) => Q(14), 
        B_DOUT(14) => Q(13), B_DOUT(13) => Q(12), B_DOUT(12) => 
        Q(11), B_DOUT(11) => Q(10), B_DOUT(10) => Q(9), B_DOUT(9)
         => Q(8), B_DOUT(8) => nc1, B_DOUT(7) => Q(7), B_DOUT(6)
         => Q(6), B_DOUT(5) => Q(5), B_DOUT(4) => Q(4), B_DOUT(3)
         => Q(3), B_DOUT(2) => Q(2), B_DOUT(1) => Q(1), B_DOUT(0)
         => Q(0), BUSY => OPEN, A_CLK => RCLOCK, A_DOUT_CLK => 
        \VCC\, A_ARST_N => \VCC\, A_DOUT_EN => \VCC\, A_BLK(2)
         => RE, A_BLK(1) => \VCC\, A_BLK(0) => \VCC\, 
        A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N => \VCC\, A_DIN(17)
         => \GND\, A_DIN(16) => DATA(31), A_DIN(15) => DATA(30), 
        A_DIN(14) => DATA(29), A_DIN(13) => DATA(28), A_DIN(12)
         => DATA(27), A_DIN(11) => DATA(26), A_DIN(10) => 
        DATA(25), A_DIN(9) => DATA(24), A_DIN(8) => \GND\, 
        A_DIN(7) => DATA(23), A_DIN(6) => DATA(22), A_DIN(5) => 
        DATA(21), A_DIN(4) => DATA(20), A_DIN(3) => DATA(19), 
        A_DIN(2) => DATA(18), A_DIN(1) => DATA(17), A_DIN(0) => 
        DATA(16), A_ADDR(13) => \GND\, A_ADDR(12) => \GND\, 
        A_ADDR(11) => \GND\, A_ADDR(10) => RADDRESS(5), A_ADDR(9)
         => RADDRESS(4), A_ADDR(8) => RADDRESS(3), A_ADDR(7) => 
        RADDRESS(2), A_ADDR(6) => RADDRESS(1), A_ADDR(5) => 
        RADDRESS(0), A_ADDR(4) => \GND\, A_ADDR(3) => \GND\, 
        A_ADDR(2) => \GND\, A_ADDR(1) => \GND\, A_ADDR(0) => 
        \GND\, A_WEN(1) => \VCC\, A_WEN(0) => \VCC\, B_CLK => 
        WCLOCK, B_DOUT_CLK => \VCC\, B_ARST_N => \VCC\, B_DOUT_EN
         => \VCC\, B_BLK(2) => WE, B_BLK(1) => \VCC\, B_BLK(0)
         => \VCC\, B_DOUT_ARST_N => \VCC\, B_DOUT_SRST_N => \VCC\, 
        B_DIN(17) => \GND\, B_DIN(16) => DATA(15), B_DIN(15) => 
        DATA(14), B_DIN(14) => DATA(13), B_DIN(13) => DATA(12), 
        B_DIN(12) => DATA(11), B_DIN(11) => DATA(10), B_DIN(10)
         => DATA(9), B_DIN(9) => DATA(8), B_DIN(8) => \GND\, 
        B_DIN(7) => DATA(7), B_DIN(6) => DATA(6), B_DIN(5) => 
        DATA(5), B_DIN(4) => DATA(4), B_DIN(3) => DATA(3), 
        B_DIN(2) => DATA(2), B_DIN(1) => DATA(1), B_DIN(0) => 
        DATA(0), B_ADDR(13) => \GND\, B_ADDR(12) => \GND\, 
        B_ADDR(11) => \GND\, B_ADDR(10) => WADDRESS(5), B_ADDR(9)
         => WADDRESS(4), B_ADDR(8) => WADDRESS(3), B_ADDR(7) => 
        WADDRESS(2), B_ADDR(6) => WADDRESS(1), B_ADDR(5) => 
        WADDRESS(0), B_ADDR(4) => \GND\, B_ADDR(3) => \GND\, 
        B_ADDR(2) => \GND\, B_ADDR(1) => \GND\, B_ADDR(0) => 
        \GND\, B_WEN(1) => \VCC\, B_WEN(0) => \VCC\, A_EN => 
        \VCC\, A_DOUT_LAT => \VCC\, A_WIDTH(2) => \VCC\, 
        A_WIDTH(1) => \GND\, A_WIDTH(0) => \VCC\, A_WMODE => 
        \GND\, B_EN => \VCC\, B_DOUT_LAT => \VCC\, B_WIDTH(2) => 
        \VCC\, B_WIDTH(1) => \GND\, B_WIDTH(0) => \VCC\, B_WMODE
         => \GND\, SII_LOCK => \GND\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 
-- Version: v11.1 SP2 11.1.2.11

library ieee;
use ieee.std_logic_1164.all;
library SmartFusion2;
use SmartFusion2.all;

entity RAMBLOCK64X8 is

    port( DATA     : in    std_logic_vector(7 downto 0);
          Q        : out   std_logic_vector(7 downto 0);
          WADDRESS : in    std_logic_vector(5 downto 0);
          RADDRESS : in    std_logic_vector(5 downto 0);
          WE       : in    std_logic;
          RE       : in    std_logic;
          WCLOCK   : in    std_logic;
          RCLOCK   : in    std_logic
        );

end RAMBLOCK64X8;

architecture DEF_ARCH of RAMBLOCK64X8 is 

  component RAM1K18
    generic (MEMORYFILE:string := "");

    port( A_DOUT        : out   std_logic_vector(17 downto 0);
          B_DOUT        : out   std_logic_vector(17 downto 0);
          BUSY          : out   std_logic;
          A_CLK         : in    std_logic := 'U';
          A_DOUT_CLK    : in    std_logic := 'U';
          A_ARST_N      : in    std_logic := 'U';
          A_DOUT_EN     : in    std_logic := 'U';
          A_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_DOUT_ARST_N : in    std_logic := 'U';
          A_DOUT_SRST_N : in    std_logic := 'U';
          A_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          A_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          A_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_CLK         : in    std_logic := 'U';
          B_DOUT_CLK    : in    std_logic := 'U';
          B_ARST_N      : in    std_logic := 'U';
          B_DOUT_EN     : in    std_logic := 'U';
          B_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_DOUT_ARST_N : in    std_logic := 'U';
          B_DOUT_SRST_N : in    std_logic := 'U';
          B_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
          B_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          B_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_EN          : in    std_logic := 'U';
          A_DOUT_LAT    : in    std_logic := 'U';
          A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_WMODE       : in    std_logic := 'U';
          B_EN          : in    std_logic := 'U';
          B_DOUT_LAT    : in    std_logic := 'U';
          B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_WMODE       : in    std_logic := 'U';
          SII_LOCK      : in    std_logic := 'U'
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc24, nc1, nc8, nc13, nc16, nc19, nc25, nc20, nc27, 
        nc9, nc22, nc28, nc14, nc5, nc21, nc15, nc3, nc10, nc7, 
        nc17, nc4, nc12, nc2, nc23, nc18, nc26, nc6, nc11
         : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    RAMBLOCK64X8_R0C0 : RAM1K18
      port map(A_DOUT(17) => nc24, A_DOUT(16) => nc1, A_DOUT(15)
         => nc8, A_DOUT(14) => nc13, A_DOUT(13) => nc16, 
        A_DOUT(12) => nc19, A_DOUT(11) => nc25, A_DOUT(10) => 
        nc20, A_DOUT(9) => nc27, A_DOUT(8) => nc9, A_DOUT(7) => 
        Q(7), A_DOUT(6) => Q(6), A_DOUT(5) => Q(5), A_DOUT(4) => 
        Q(4), A_DOUT(3) => Q(3), A_DOUT(2) => Q(2), A_DOUT(1) => 
        Q(1), A_DOUT(0) => Q(0), B_DOUT(17) => nc22, B_DOUT(16)
         => nc28, B_DOUT(15) => nc14, B_DOUT(14) => nc5, 
        B_DOUT(13) => nc21, B_DOUT(12) => nc15, B_DOUT(11) => nc3, 
        B_DOUT(10) => nc10, B_DOUT(9) => nc7, B_DOUT(8) => nc17, 
        B_DOUT(7) => nc4, B_DOUT(6) => nc12, B_DOUT(5) => nc2, 
        B_DOUT(4) => nc23, B_DOUT(3) => nc18, B_DOUT(2) => nc26, 
        B_DOUT(1) => nc6, B_DOUT(0) => nc11, BUSY => OPEN, A_CLK
         => RCLOCK, A_DOUT_CLK => \VCC\, A_ARST_N => \VCC\, 
        A_DOUT_EN => \VCC\, A_BLK(2) => RE, A_BLK(1) => \VCC\, 
        A_BLK(0) => \VCC\, A_DOUT_ARST_N => \VCC\, A_DOUT_SRST_N
         => \VCC\, A_DIN(17) => \GND\, A_DIN(16) => \GND\, 
        A_DIN(15) => \GND\, A_DIN(14) => \GND\, A_DIN(13) => 
        \GND\, A_DIN(12) => \GND\, A_DIN(11) => \GND\, A_DIN(10)
         => \GND\, A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7)
         => \GND\, A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4)
         => \GND\, A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1)
         => \GND\, A_DIN(0) => \GND\, A_ADDR(13) => \GND\, 
        A_ADDR(12) => \GND\, A_ADDR(11) => \GND\, A_ADDR(10) => 
        \GND\, A_ADDR(9) => \GND\, A_ADDR(8) => RADDRESS(5), 
        A_ADDR(7) => RADDRESS(4), A_ADDR(6) => RADDRESS(3), 
        A_ADDR(5) => RADDRESS(2), A_ADDR(4) => RADDRESS(1), 
        A_ADDR(3) => RADDRESS(0), A_ADDR(2) => \GND\, A_ADDR(1)
         => \GND\, A_ADDR(0) => \GND\, A_WEN(1) => \GND\, 
        A_WEN(0) => \GND\, B_CLK => WCLOCK, B_DOUT_CLK => \VCC\, 
        B_ARST_N => \VCC\, B_DOUT_EN => \VCC\, B_BLK(2) => WE, 
        B_BLK(1) => \VCC\, B_BLK(0) => \VCC\, B_DOUT_ARST_N => 
        \GND\, B_DOUT_SRST_N => \VCC\, B_DIN(17) => \GND\, 
        B_DIN(16) => \GND\, B_DIN(15) => \GND\, B_DIN(14) => 
        \GND\, B_DIN(13) => \GND\, B_DIN(12) => \GND\, B_DIN(11)
         => \GND\, B_DIN(10) => \GND\, B_DIN(9) => \GND\, 
        B_DIN(8) => \GND\, B_DIN(7) => DATA(7), B_DIN(6) => 
        DATA(6), B_DIN(5) => DATA(5), B_DIN(4) => DATA(4), 
        B_DIN(3) => DATA(3), B_DIN(2) => DATA(2), B_DIN(1) => 
        DATA(1), B_DIN(0) => DATA(0), B_ADDR(13) => \GND\, 
        B_ADDR(12) => \GND\, B_ADDR(11) => \GND\, B_ADDR(10) => 
        \GND\, B_ADDR(9) => \GND\, B_ADDR(8) => WADDRESS(5), 
        B_ADDR(7) => WADDRESS(4), B_ADDR(6) => WADDRESS(3), 
        B_ADDR(5) => WADDRESS(2), B_ADDR(4) => WADDRESS(1), 
        B_ADDR(3) => WADDRESS(0), B_ADDR(2) => \GND\, B_ADDR(1)
         => \GND\, B_ADDR(0) => \GND\, B_WEN(1) => \GND\, 
        B_WEN(0) => \VCC\, A_EN => \VCC\, A_DOUT_LAT => \VCC\, 
        A_WIDTH(2) => \GND\, A_WIDTH(1) => \VCC\, A_WIDTH(0) => 
        \VCC\, A_WMODE => \GND\, B_EN => \VCC\, B_DOUT_LAT => 
        \VCC\, B_WIDTH(2) => \GND\, B_WIDTH(1) => \VCC\, 
        B_WIDTH(0) => \VCC\, B_WMODE => \GND\, SII_LOCK => \GND\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 
