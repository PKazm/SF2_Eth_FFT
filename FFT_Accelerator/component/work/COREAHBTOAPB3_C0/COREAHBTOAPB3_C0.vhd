----------------------------------------------------------------------
-- Created by SmartDesign Tue Apr 21 15:28:25 2020
-- Version: v12.1 12.600.0.14
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Libraries
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library smartfusion2;
use smartfusion2.all;
library COREAHBTOAPB3_LIB;
use COREAHBTOAPB3_LIB.all;
use COREAHBTOAPB3_LIB.components.all;
----------------------------------------------------------------------
-- COREAHBTOAPB3_C0 entity declaration
----------------------------------------------------------------------
entity COREAHBTOAPB3_C0 is
    -- Port list
    port(
        -- Inputs
        HADDR     : in  std_logic_vector(31 downto 0);
        HCLK      : in  std_logic;
        HREADY    : in  std_logic;
        HRESETN   : in  std_logic;
        HSEL      : in  std_logic;
        HTRANS    : in  std_logic_vector(1 downto 0);
        HWDATA    : in  std_logic_vector(31 downto 0);
        HWRITE    : in  std_logic;
        PRDATA    : in  std_logic_vector(31 downto 0);
        PREADY    : in  std_logic;
        PSLVERR   : in  std_logic;
        -- Outputs
        HRDATA    : out std_logic_vector(31 downto 0);
        HREADYOUT : out std_logic;
        HRESP     : out std_logic_vector(1 downto 0);
        PADDR     : out std_logic_vector(31 downto 0);
        PENABLE   : out std_logic;
        PSEL      : out std_logic;
        PWDATA    : out std_logic_vector(31 downto 0);
        PWRITE    : out std_logic
        );
end COREAHBTOAPB3_C0;
----------------------------------------------------------------------
-- COREAHBTOAPB3_C0 architecture body
----------------------------------------------------------------------
architecture RTL of COREAHBTOAPB3_C0 is
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
-- COREAHBTOAPB3   -   Actel:DirectCore:COREAHBTOAPB3:3.1.100
-- using entity instantiation for component COREAHBTOAPB3
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal AHBslave_HRDATA          : std_logic_vector(31 downto 0);
signal AHBslave_HREADYOUT       : std_logic;
signal AHBslave_HRESP           : std_logic_vector(1 downto 0);
signal APBmaster_PADDR          : std_logic_vector(31 downto 0);
signal APBmaster_PENABLE        : std_logic;
signal APBmaster_PSELx          : std_logic;
signal APBmaster_PWDATA         : std_logic_vector(31 downto 0);
signal APBmaster_PWRITE         : std_logic;
signal AHBslave_HRDATA_net_0    : std_logic_vector(31 downto 0);
signal AHBslave_HREADYOUT_net_0 : std_logic;
signal AHBslave_HRESP_net_0     : std_logic_vector(1 downto 0);
signal APBmaster_PADDR_net_0    : std_logic_vector(31 downto 0);
signal APBmaster_PSELx_net_0    : std_logic;
signal APBmaster_PENABLE_net_0  : std_logic;
signal APBmaster_PWRITE_net_0   : std_logic;
signal APBmaster_PWDATA_net_0   : std_logic_vector(31 downto 0);

begin
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 AHBslave_HRDATA_net_0    <= AHBslave_HRDATA;
 HRDATA(31 downto 0)      <= AHBslave_HRDATA_net_0;
 AHBslave_HREADYOUT_net_0 <= AHBslave_HREADYOUT;
 HREADYOUT                <= AHBslave_HREADYOUT_net_0;
 AHBslave_HRESP_net_0     <= AHBslave_HRESP;
 HRESP(1 downto 0)        <= AHBslave_HRESP_net_0;
 APBmaster_PADDR_net_0    <= APBmaster_PADDR;
 PADDR(31 downto 0)       <= APBmaster_PADDR_net_0;
 APBmaster_PSELx_net_0    <= APBmaster_PSELx;
 PSEL                     <= APBmaster_PSELx_net_0;
 APBmaster_PENABLE_net_0  <= APBmaster_PENABLE;
 PENABLE                  <= APBmaster_PENABLE_net_0;
 APBmaster_PWRITE_net_0   <= APBmaster_PWRITE;
 PWRITE                   <= APBmaster_PWRITE_net_0;
 APBmaster_PWDATA_net_0   <= APBmaster_PWDATA;
 PWDATA(31 downto 0)      <= APBmaster_PWDATA_net_0;
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- COREAHBTOAPB3_C0_0   -   Actel:DirectCore:COREAHBTOAPB3:3.1.100
COREAHBTOAPB3_C0_0 : entity COREAHBTOAPB3_LIB.COREAHBTOAPB3
    generic map( 
        FAMILY => ( 19 )
        )
    port map( 
        -- Inputs
        HCLK      => HCLK,
        HRESETN   => HRESETN,
        HADDR     => HADDR,
        HTRANS    => HTRANS,
        HWRITE    => HWRITE,
        HWDATA    => HWDATA,
        HSEL      => HSEL,
        HREADY    => HREADY,
        PRDATA    => PRDATA,
        PREADY    => PREADY,
        PSLVERR   => PSLVERR,
        -- Outputs
        HRDATA    => AHBslave_HRDATA,
        HREADYOUT => AHBslave_HREADYOUT,
        HRESP     => AHBslave_HRESP,
        PWDATA    => APBmaster_PWDATA,
        PENABLE   => APBmaster_PENABLE,
        PADDR     => APBmaster_PADDR,
        PWRITE    => APBmaster_PWRITE,
        PSEL      => APBmaster_PSELx 
        );

end RTL;
