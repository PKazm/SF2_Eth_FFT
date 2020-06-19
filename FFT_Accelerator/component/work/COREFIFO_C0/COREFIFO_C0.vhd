----------------------------------------------------------------------
-- Created by SmartDesign Wed Jun 10 01:38:17 2020
-- Version: v12.4 12.900.0.16
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Libraries
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library smartfusion2;
use smartfusion2.all;
library COREFIFO_LIB;
use COREFIFO_LIB.all;
----------------------------------------------------------------------
-- COREFIFO_C0 entity declaration
----------------------------------------------------------------------
entity COREFIFO_C0 is
    -- Port list
    port(
        -- Inputs
        DATA   : in  std_logic_vector(7 downto 0);
        RCLOCK : in  std_logic;
        RE     : in  std_logic;
        RESET  : in  std_logic;
        WCLOCK : in  std_logic;
        WE     : in  std_logic;
        -- Outputs
        DVLD   : out std_logic;
        EMPTY  : out std_logic;
        FULL   : out std_logic;
        Q      : out std_logic_vector(15 downto 0)
        );
end COREFIFO_C0;
----------------------------------------------------------------------
-- COREFIFO_C0 architecture body
----------------------------------------------------------------------
architecture RTL of COREFIFO_C0 is
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
-- COREFIFO_C0_COREFIFO_C0_0_COREFIFO   -   Actel:DirectCore:COREFIFO:2.7.105
component COREFIFO_C0_COREFIFO_C0_0_COREFIFO
    generic( 
        AE_STATIC_EN   : integer := 0 ;
        AEVAL          : integer := 4 ;
        AF_STATIC_EN   : integer := 0 ;
        AFVAL          : integer := 60 ;
        CTRL_TYPE      : integer := 3 ;
        ECC            : integer := 0 ;
        ESTOP          : integer := 1 ;
        FAMILY         : integer := 19 ;
        FSTOP          : integer := 1 ;
        FWFT           : integer := 0 ;
        NUM_STAGES     : integer := 2 ;
        OVERFLOW_EN    : integer := 0 ;
        PIPE           : integer := 1 ;
        PREFETCH       : integer := 0 ;
        RCLK_EDGE      : integer := 1 ;
        RDCNT_EN       : integer := 0 ;
        RDEPTH         : integer := 64 ;
        RE_POLARITY    : integer := 0 ;
        READ_DVALID    : integer := 1 ;
        RESET_POLARITY : integer := 0 ;
        RWIDTH         : integer := 16 ;
        SYNC           : integer := 0 ;
        UNDERFLOW_EN   : integer := 0 ;
        WCLK_EDGE      : integer := 1 ;
        WDEPTH         : integer := 128 ;
        WE_POLARITY    : integer := 0 ;
        WRCNT_EN       : integer := 0 ;
        WRITE_ACK      : integer := 0 ;
        WWIDTH         : integer := 8 
        );
    -- Port list
    port(
        -- Inputs
        CLK        : in  std_logic;
        DATA       : in  std_logic_vector(7 downto 0);
        MEMRD      : in  std_logic_vector(15 downto 0);
        RCLOCK     : in  std_logic;
        RE         : in  std_logic;
        RESET      : in  std_logic;
        WCLOCK     : in  std_logic;
        WE         : in  std_logic;
        -- Outputs
        AEMPTY     : out std_logic;
        AFULL      : out std_logic;
        DB_DETECT  : out std_logic;
        DVLD       : out std_logic;
        EMPTY      : out std_logic;
        FULL       : out std_logic;
        MEMRADDR   : out std_logic_vector(5 downto 0);
        MEMRE      : out std_logic;
        MEMWADDR   : out std_logic_vector(6 downto 0);
        MEMWD      : out std_logic_vector(7 downto 0);
        MEMWE      : out std_logic;
        OVERFLOW   : out std_logic;
        Q          : out std_logic_vector(15 downto 0);
        RDCNT      : out std_logic_vector(6 downto 0);
        SB_CORRECT : out std_logic;
        UNDERFLOW  : out std_logic;
        WACK       : out std_logic;
        WRCNT      : out std_logic_vector(7 downto 0)
        );
end component;
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal DVLD_net_0  : std_logic;
signal EMPTY_net_0 : std_logic;
signal FULL_net_0  : std_logic;
signal Q_1         : std_logic_vector(15 downto 0);
signal FULL_net_1  : std_logic;
signal EMPTY_net_1 : std_logic;
signal DVLD_net_1  : std_logic;
signal Q_1_net_0   : std_logic_vector(15 downto 0);
----------------------------------------------------------------------
-- TiedOff Signals
----------------------------------------------------------------------
signal GND_net     : std_logic;
signal MEMRD_const_net_0: std_logic_vector(15 downto 0);

begin
----------------------------------------------------------------------
-- Constant assignments
----------------------------------------------------------------------
 GND_net           <= '0';
 MEMRD_const_net_0 <= B"0000000000000000";
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 FULL_net_1     <= FULL_net_0;
 FULL           <= FULL_net_1;
 EMPTY_net_1    <= EMPTY_net_0;
 EMPTY          <= EMPTY_net_1;
 DVLD_net_1     <= DVLD_net_0;
 DVLD           <= DVLD_net_1;
 Q_1_net_0      <= Q_1;
 Q(15 downto 0) <= Q_1_net_0;
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- COREFIFO_C0_0   -   Actel:DirectCore:COREFIFO:2.7.105
COREFIFO_C0_0 : COREFIFO_C0_COREFIFO_C0_0_COREFIFO
    generic map( 
        AE_STATIC_EN   => ( 0 ),
        AEVAL          => ( 4 ),
        AF_STATIC_EN   => ( 0 ),
        AFVAL          => ( 60 ),
        CTRL_TYPE      => ( 3 ),
        ECC            => ( 0 ),
        ESTOP          => ( 1 ),
        FAMILY         => ( 19 ),
        FSTOP          => ( 1 ),
        FWFT           => ( 0 ),
        NUM_STAGES     => ( 2 ),
        OVERFLOW_EN    => ( 0 ),
        PIPE           => ( 1 ),
        PREFETCH       => ( 0 ),
        RCLK_EDGE      => ( 1 ),
        RDCNT_EN       => ( 0 ),
        RDEPTH         => ( 64 ),
        RE_POLARITY    => ( 0 ),
        READ_DVALID    => ( 1 ),
        RESET_POLARITY => ( 0 ),
        RWIDTH         => ( 16 ),
        SYNC           => ( 0 ),
        UNDERFLOW_EN   => ( 0 ),
        WCLK_EDGE      => ( 1 ),
        WDEPTH         => ( 128 ),
        WE_POLARITY    => ( 0 ),
        WRCNT_EN       => ( 0 ),
        WRITE_ACK      => ( 0 ),
        WWIDTH         => ( 8 )
        )
    port map( 
        -- Inputs
        CLK        => GND_net, -- tied to '0' from definition
        WCLOCK     => WCLOCK,
        RCLOCK     => RCLOCK,
        RESET      => RESET,
        WE         => WE,
        RE         => RE,
        DATA       => DATA,
        MEMRD      => MEMRD_const_net_0, -- tied to X"0" from definition
        -- Outputs
        FULL       => FULL_net_0,
        EMPTY      => EMPTY_net_0,
        AFULL      => OPEN,
        AEMPTY     => OPEN,
        OVERFLOW   => OPEN,
        UNDERFLOW  => OPEN,
        WACK       => OPEN,
        DVLD       => DVLD_net_0,
        MEMWE      => OPEN,
        MEMRE      => OPEN,
        SB_CORRECT => OPEN,
        DB_DETECT  => OPEN,
        Q          => Q_1,
        WRCNT      => OPEN,
        RDCNT      => OPEN,
        MEMWADDR   => OPEN,
        MEMRADDR   => OPEN,
        MEMWD      => OPEN 
        );

end RTL;
