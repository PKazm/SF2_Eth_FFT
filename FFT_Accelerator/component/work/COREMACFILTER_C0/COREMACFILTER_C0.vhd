----------------------------------------------------------------------
-- Created by SmartDesign Tue Apr 21 15:28:02 2020
-- Version: v12.1 12.600.0.14
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Libraries
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library smartfusion2;
use smartfusion2.all;
----------------------------------------------------------------------
-- COREMACFILTER_C0 entity declaration
----------------------------------------------------------------------
entity COREMACFILTER_C0 is
    -- Port list
    port(
        -- Inputs
        PADDR   : in  std_logic_vector(31 downto 0);
        PCLK    : in  std_logic;
        PENABLE : in  std_logic;
        PRESETN : in  std_logic;
        PSEL    : in  std_logic;
        PWDATA  : in  std_logic_vector(31 downto 0);
        PWRITE  : in  std_logic;
        RESETN  : in  std_logic;
        RXCLK   : in  std_logic;
        RXD     : in  std_logic_vector(7 downto 0);
        RXDV    : in  std_logic;
        RXERI   : in  std_logic;
        -- Outputs
        PRDATA  : out std_logic_vector(31 downto 0);
        PREADY  : out std_logic;
        PSLVERR : out std_logic;
        RXERO   : out std_logic
        );
end COREMACFILTER_C0;
----------------------------------------------------------------------
-- COREMACFILTER_C0 architecture body
----------------------------------------------------------------------
architecture RTL of COREMACFILTER_C0 is
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
-- COREMACFILTER_C0_COREMACFILTER_C0_0_COREMACFILTER   -   Actel:DirectCore:COREMACFILTER:2.0.207
component COREMACFILTER_C0_COREMACFILTER_C0_0_COREMACFILTER
    generic( 
        FAMILY     : integer := 19 ;
        GMII_SGMII : integer := 0 
        );
    -- Port list
    port(
        -- Inputs
        PADDR       : in  std_logic_vector(31 downto 0);
        PCLK        : in  std_logic;
        PENABLE     : in  std_logic;
        PMA_RX_CLK0 : in  std_logic;
        PRESETN     : in  std_logic;
        PSEL        : in  std_logic;
        PWDATA      : in  std_logic_vector(31 downto 0);
        PWRITE      : in  std_logic;
        RCGI        : in  std_logic_vector(9 downto 0);
        RESETN      : in  std_logic;
        RXCLK       : in  std_logic;
        RXD         : in  std_logic_vector(7 downto 0);
        RXDV        : in  std_logic;
        RXERI       : in  std_logic;
        -- Outputs
        PRDATA      : out std_logic_vector(31 downto 0);
        PREADY      : out std_logic;
        PSLVERR     : out std_logic;
        RCGO        : out std_logic_vector(9 downto 0);
        RXCLK_SEL0  : out std_logic;
        RXERO       : out std_logic
        );
end component;
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal APBS_PRDATA        : std_logic_vector(31 downto 0);
signal APBS_PREADY        : std_logic;
signal APBS_PSLVERR       : std_logic;
signal RXERO_net_0        : std_logic;
signal APBS_PRDATA_net_0  : std_logic_vector(31 downto 0);
signal APBS_PREADY_net_0  : std_logic;
signal APBS_PSLVERR_net_0 : std_logic;
signal RXERO_net_1        : std_logic;
----------------------------------------------------------------------
-- TiedOff Signals
----------------------------------------------------------------------
signal RCGI_const_net_0   : std_logic_vector(9 downto 0);
signal GND_net            : std_logic;

begin
----------------------------------------------------------------------
-- Constant assignments
----------------------------------------------------------------------
 RCGI_const_net_0 <= B"0000000000";
 GND_net          <= '0';
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 APBS_PRDATA_net_0   <= APBS_PRDATA;
 PRDATA(31 downto 0) <= APBS_PRDATA_net_0;
 APBS_PREADY_net_0   <= APBS_PREADY;
 PREADY              <= APBS_PREADY_net_0;
 APBS_PSLVERR_net_0  <= APBS_PSLVERR;
 PSLVERR             <= APBS_PSLVERR_net_0;
 RXERO_net_1         <= RXERO_net_0;
 RXERO               <= RXERO_net_1;
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- COREMACFILTER_C0_0   -   Actel:DirectCore:COREMACFILTER:2.0.207
COREMACFILTER_C0_0 : COREMACFILTER_C0_COREMACFILTER_C0_0_COREMACFILTER
    generic map( 
        FAMILY     => ( 19 ),
        GMII_SGMII => ( 0 )
        )
    port map( 
        -- Inputs
        RESETN      => RESETN,
        RXCLK       => RXCLK,
        RCGI        => RCGI_const_net_0, -- tied to X"0" from definition
        PMA_RX_CLK0 => GND_net, -- tied to '0' from definition
        RXDV        => RXDV,
        RXD         => RXD,
        RXERI       => RXERI,
        PCLK        => PCLK,
        PRESETN     => PRESETN,
        PWRITE      => PWRITE,
        PADDR       => PADDR,
        PSEL        => PSEL,
        PENABLE     => PENABLE,
        PWDATA      => PWDATA,
        -- Outputs
        RXCLK_SEL0  => OPEN,
        RCGO        => OPEN,
        RXERO       => RXERO_net_0,
        PRDATA      => APBS_PRDATA,
        PSLVERR     => APBS_PSLVERR,
        PREADY      => APBS_PREADY 
        );

end RTL;
