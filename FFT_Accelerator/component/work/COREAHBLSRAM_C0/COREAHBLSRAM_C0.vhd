----------------------------------------------------------------------
-- Created by SmartDesign Sat Apr 18 20:12:05 2020
-- Version: v12.1 12.600.0.14
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Libraries
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library smartfusion2;
use smartfusion2.all;
library COREAHBLSRAM_LIB;
use COREAHBLSRAM_LIB.all;
----------------------------------------------------------------------
-- COREAHBLSRAM_C0 entity declaration
----------------------------------------------------------------------
entity COREAHBLSRAM_C0 is
    -- Port list
    port(
        -- Inputs
        HADDR     : in  std_logic_vector(31 downto 0);
        HBURST    : in  std_logic_vector(2 downto 0);
        HCLK      : in  std_logic;
        HREADYIN  : in  std_logic;
        HRESETN   : in  std_logic;
        HSEL      : in  std_logic;
        HSIZE     : in  std_logic_vector(2 downto 0);
        HTRANS    : in  std_logic_vector(1 downto 0);
        HWDATA    : in  std_logic_vector(31 downto 0);
        HWRITE    : in  std_logic;
        -- Outputs
        HRDATA    : out std_logic_vector(31 downto 0);
        HREADYOUT : out std_logic;
        HRESP     : out std_logic_vector(1 downto 0)
        );
end COREAHBLSRAM_C0;
----------------------------------------------------------------------
-- COREAHBLSRAM_C0 architecture body
----------------------------------------------------------------------
architecture RTL of COREAHBLSRAM_C0 is
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
-- COREAHBLSRAM_C0_COREAHBLSRAM_C0_0_COREAHBLSRAM   -   Actel:DirectCore:COREAHBLSRAM:2.2.104
component COREAHBLSRAM_C0_COREAHBLSRAM_C0_0_COREAHBLSRAM
    generic( 
        AHB_AWIDTH                   : integer := 32 ;
        AHB_DWIDTH                   : integer := 32 ;
        FAMILY                       : integer := 19 ;
        LSRAM_NUM_LOCATIONS_DWIDTH32 : integer := 2048 ;
        SEL_SRAM_TYPE                : integer := 1 ;
        USRAM_NUM_LOCATIONS_DWIDTH32 : integer := 128 
        );
    -- Port list
    port(
        -- Inputs
        HADDR     : in  std_logic_vector(31 downto 0);
        HBURST    : in  std_logic_vector(2 downto 0);
        HCLK      : in  std_logic;
        HREADYIN  : in  std_logic;
        HRESETN   : in  std_logic;
        HSEL      : in  std_logic;
        HSIZE     : in  std_logic_vector(2 downto 0);
        HTRANS    : in  std_logic_vector(1 downto 0);
        HWDATA    : in  std_logic_vector(31 downto 0);
        HWRITE    : in  std_logic;
        -- Outputs
        HRDATA    : out std_logic_vector(31 downto 0);
        HREADYOUT : out std_logic;
        HRESP     : out std_logic_vector(1 downto 0)
        );
end component;
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal AHBSlaveInterface_HRDATA          : std_logic_vector(31 downto 0);
signal AHBSlaveInterface_HREADYOUT       : std_logic;
signal AHBSlaveInterface_HRESP           : std_logic_vector(1 downto 0);
signal AHBSlaveInterface_HRDATA_net_0    : std_logic_vector(31 downto 0);
signal AHBSlaveInterface_HREADYOUT_net_0 : std_logic;
signal AHBSlaveInterface_HRESP_net_0     : std_logic_vector(1 downto 0);

begin
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 AHBSlaveInterface_HRDATA_net_0    <= AHBSlaveInterface_HRDATA;
 HRDATA(31 downto 0)               <= AHBSlaveInterface_HRDATA_net_0;
 AHBSlaveInterface_HREADYOUT_net_0 <= AHBSlaveInterface_HREADYOUT;
 HREADYOUT                         <= AHBSlaveInterface_HREADYOUT_net_0;
 AHBSlaveInterface_HRESP_net_0     <= AHBSlaveInterface_HRESP;
 HRESP(1 downto 0)                 <= AHBSlaveInterface_HRESP_net_0;
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- COREAHBLSRAM_C0_0   -   Actel:DirectCore:COREAHBLSRAM:2.2.104
COREAHBLSRAM_C0_0 : COREAHBLSRAM_C0_COREAHBLSRAM_C0_0_COREAHBLSRAM
    generic map( 
        AHB_AWIDTH                   => ( 32 ),
        AHB_DWIDTH                   => ( 32 ),
        FAMILY                       => ( 19 ),
        LSRAM_NUM_LOCATIONS_DWIDTH32 => ( 2048 ),
        SEL_SRAM_TYPE                => ( 1 ),
        USRAM_NUM_LOCATIONS_DWIDTH32 => ( 128 )
        )
    port map( 
        -- Inputs
        HCLK      => HCLK,
        HRESETN   => HRESETN,
        HSEL      => HSEL,
        HREADYIN  => HREADYIN,
        HSIZE     => HSIZE,
        HTRANS    => HTRANS,
        HBURST    => HBURST,
        HADDR     => HADDR,
        HWRITE    => HWRITE,
        HWDATA    => HWDATA,
        -- Outputs
        HREADYOUT => AHBSlaveInterface_HREADYOUT,
        HRDATA    => AHBSlaveInterface_HRDATA,
        HRESP     => AHBSlaveInterface_HRESP 
        );

end RTL;
