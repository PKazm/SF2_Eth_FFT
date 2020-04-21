----------------------------------------------------------------------
-- Created by SmartDesign Sat Apr 18 02:13:28 2020
-- Version: v12.1 12.600.0.14
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Libraries
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library smartfusion2;
use smartfusion2.all;
library COREAHBLITE_LIB;
use COREAHBLITE_LIB.all;
use COREAHBLITE_LIB.CoreAHBLite_C0_CoreAHBLite_C0_0_components.all;
----------------------------------------------------------------------
-- CoreAHBLite_C0 entity declaration
----------------------------------------------------------------------
entity CoreAHBLite_C0 is
    -- Port list
    port(
        -- Inputs
        HADDR_M0     : in  std_logic_vector(31 downto 0);
        HBURST_M0    : in  std_logic_vector(2 downto 0);
        HCLK         : in  std_logic;
        HMASTLOCK_M0 : in  std_logic;
        HPROT_M0     : in  std_logic_vector(3 downto 0);
        HRDATA_S0    : in  std_logic_vector(31 downto 0);
        HREADYOUT_S0 : in  std_logic;
        HRESETN      : in  std_logic;
        HRESP_S0     : in  std_logic_vector(1 downto 0);
        HSIZE_M0     : in  std_logic_vector(2 downto 0);
        HTRANS_M0    : in  std_logic_vector(1 downto 0);
        HWDATA_M0    : in  std_logic_vector(31 downto 0);
        HWRITE_M0    : in  std_logic;
        REMAP_M0     : in  std_logic;
        -- Outputs
        HADDR_S0     : out std_logic_vector(31 downto 0);
        HBURST_S0    : out std_logic_vector(2 downto 0);
        HMASTLOCK_S0 : out std_logic;
        HPROT_S0     : out std_logic_vector(3 downto 0);
        HRDATA_M0    : out std_logic_vector(31 downto 0);
        HREADY_M0    : out std_logic;
        HREADY_S0    : out std_logic;
        HRESP_M0     : out std_logic_vector(1 downto 0);
        HSEL_S0      : out std_logic;
        HSIZE_S0     : out std_logic_vector(2 downto 0);
        HTRANS_S0    : out std_logic_vector(1 downto 0);
        HWDATA_S0    : out std_logic_vector(31 downto 0);
        HWRITE_S0    : out std_logic
        );
end CoreAHBLite_C0;
----------------------------------------------------------------------
-- CoreAHBLite_C0 architecture body
----------------------------------------------------------------------
architecture RTL of CoreAHBLite_C0 is
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
-- CoreAHBLite_C0_CoreAHBLite_C0_0_CoreAHBLite   -   Actel:DirectCore:CoreAHBLite:5.4.102
component CoreAHBLite_C0_CoreAHBLite_C0_0_CoreAHBLite
    generic( 
        FAMILY             : integer := 19 ;
        HADDR_SHG_CFG      : integer := 1 ;
        M0_AHBSLOT0ENABLE  : integer := 1 ;
        M0_AHBSLOT1ENABLE  : integer := 0 ;
        M0_AHBSLOT2ENABLE  : integer := 0 ;
        M0_AHBSLOT3ENABLE  : integer := 0 ;
        M0_AHBSLOT4ENABLE  : integer := 0 ;
        M0_AHBSLOT5ENABLE  : integer := 0 ;
        M0_AHBSLOT6ENABLE  : integer := 0 ;
        M0_AHBSLOT7ENABLE  : integer := 0 ;
        M0_AHBSLOT8ENABLE  : integer := 0 ;
        M0_AHBSLOT9ENABLE  : integer := 0 ;
        M0_AHBSLOT10ENABLE : integer := 0 ;
        M0_AHBSLOT11ENABLE : integer := 0 ;
        M0_AHBSLOT12ENABLE : integer := 0 ;
        M0_AHBSLOT13ENABLE : integer := 0 ;
        M0_AHBSLOT14ENABLE : integer := 0 ;
        M0_AHBSLOT15ENABLE : integer := 0 ;
        M0_AHBSLOT16ENABLE : integer := 0 ;
        M1_AHBSLOT0ENABLE  : integer := 0 ;
        M1_AHBSLOT1ENABLE  : integer := 0 ;
        M1_AHBSLOT2ENABLE  : integer := 0 ;
        M1_AHBSLOT3ENABLE  : integer := 0 ;
        M1_AHBSLOT4ENABLE  : integer := 0 ;
        M1_AHBSLOT5ENABLE  : integer := 0 ;
        M1_AHBSLOT6ENABLE  : integer := 0 ;
        M1_AHBSLOT7ENABLE  : integer := 0 ;
        M1_AHBSLOT8ENABLE  : integer := 0 ;
        M1_AHBSLOT9ENABLE  : integer := 0 ;
        M1_AHBSLOT10ENABLE : integer := 0 ;
        M1_AHBSLOT11ENABLE : integer := 0 ;
        M1_AHBSLOT12ENABLE : integer := 0 ;
        M1_AHBSLOT13ENABLE : integer := 0 ;
        M1_AHBSLOT14ENABLE : integer := 0 ;
        M1_AHBSLOT15ENABLE : integer := 0 ;
        M1_AHBSLOT16ENABLE : integer := 0 ;
        M2_AHBSLOT0ENABLE  : integer := 0 ;
        M2_AHBSLOT1ENABLE  : integer := 0 ;
        M2_AHBSLOT2ENABLE  : integer := 0 ;
        M2_AHBSLOT3ENABLE  : integer := 0 ;
        M2_AHBSLOT4ENABLE  : integer := 0 ;
        M2_AHBSLOT5ENABLE  : integer := 0 ;
        M2_AHBSLOT6ENABLE  : integer := 0 ;
        M2_AHBSLOT7ENABLE  : integer := 0 ;
        M2_AHBSLOT8ENABLE  : integer := 0 ;
        M2_AHBSLOT9ENABLE  : integer := 0 ;
        M2_AHBSLOT10ENABLE : integer := 0 ;
        M2_AHBSLOT11ENABLE : integer := 0 ;
        M2_AHBSLOT12ENABLE : integer := 0 ;
        M2_AHBSLOT13ENABLE : integer := 0 ;
        M2_AHBSLOT14ENABLE : integer := 0 ;
        M2_AHBSLOT15ENABLE : integer := 0 ;
        M2_AHBSLOT16ENABLE : integer := 0 ;
        M3_AHBSLOT0ENABLE  : integer := 0 ;
        M3_AHBSLOT1ENABLE  : integer := 0 ;
        M3_AHBSLOT2ENABLE  : integer := 0 ;
        M3_AHBSLOT3ENABLE  : integer := 0 ;
        M3_AHBSLOT4ENABLE  : integer := 0 ;
        M3_AHBSLOT5ENABLE  : integer := 0 ;
        M3_AHBSLOT6ENABLE  : integer := 0 ;
        M3_AHBSLOT7ENABLE  : integer := 0 ;
        M3_AHBSLOT8ENABLE  : integer := 0 ;
        M3_AHBSLOT9ENABLE  : integer := 0 ;
        M3_AHBSLOT10ENABLE : integer := 0 ;
        M3_AHBSLOT11ENABLE : integer := 0 ;
        M3_AHBSLOT12ENABLE : integer := 0 ;
        M3_AHBSLOT13ENABLE : integer := 0 ;
        M3_AHBSLOT14ENABLE : integer := 0 ;
        M3_AHBSLOT15ENABLE : integer := 0 ;
        M3_AHBSLOT16ENABLE : integer := 0 ;
        MASTER0_INTERFACE  : integer := 1 ;
        MASTER1_INTERFACE  : integer := 1 ;
        MASTER2_INTERFACE  : integer := 1 ;
        MASTER3_INTERFACE  : integer := 1 ;
        MEMSPACE           : integer := 6 ;
        SC_0               : integer := 0 ;
        SC_1               : integer := 0 ;
        SC_2               : integer := 0 ;
        SC_3               : integer := 0 ;
        SC_4               : integer := 0 ;
        SC_5               : integer := 0 ;
        SC_6               : integer := 0 ;
        SC_7               : integer := 0 ;
        SC_8               : integer := 0 ;
        SC_9               : integer := 0 ;
        SC_10              : integer := 0 ;
        SC_11              : integer := 0 ;
        SC_12              : integer := 0 ;
        SC_13              : integer := 0 ;
        SC_14              : integer := 0 ;
        SC_15              : integer := 0 ;
        SLAVE0_INTERFACE   : integer := 1 ;
        SLAVE1_INTERFACE   : integer := 1 ;
        SLAVE2_INTERFACE   : integer := 1 ;
        SLAVE3_INTERFACE   : integer := 1 ;
        SLAVE4_INTERFACE   : integer := 1 ;
        SLAVE5_INTERFACE   : integer := 1 ;
        SLAVE6_INTERFACE   : integer := 1 ;
        SLAVE7_INTERFACE   : integer := 1 ;
        SLAVE8_INTERFACE   : integer := 1 ;
        SLAVE9_INTERFACE   : integer := 1 ;
        SLAVE10_INTERFACE  : integer := 1 ;
        SLAVE11_INTERFACE  : integer := 1 ;
        SLAVE12_INTERFACE  : integer := 1 ;
        SLAVE13_INTERFACE  : integer := 1 ;
        SLAVE14_INTERFACE  : integer := 1 ;
        SLAVE15_INTERFACE  : integer := 1 ;
        SLAVE16_INTERFACE  : integer := 1 
        );
    -- Port list
    port(
        -- Inputs
        HADDR_M0      : in  std_logic_vector(31 downto 0);
        HADDR_M1      : in  std_logic_vector(31 downto 0);
        HADDR_M2      : in  std_logic_vector(31 downto 0);
        HADDR_M3      : in  std_logic_vector(31 downto 0);
        HBURST_M0     : in  std_logic_vector(2 downto 0);
        HBURST_M1     : in  std_logic_vector(2 downto 0);
        HBURST_M2     : in  std_logic_vector(2 downto 0);
        HBURST_M3     : in  std_logic_vector(2 downto 0);
        HCLK          : in  std_logic;
        HMASTLOCK_M0  : in  std_logic;
        HMASTLOCK_M1  : in  std_logic;
        HMASTLOCK_M2  : in  std_logic;
        HMASTLOCK_M3  : in  std_logic;
        HPROT_M0      : in  std_logic_vector(3 downto 0);
        HPROT_M1      : in  std_logic_vector(3 downto 0);
        HPROT_M2      : in  std_logic_vector(3 downto 0);
        HPROT_M3      : in  std_logic_vector(3 downto 0);
        HRDATA_S0     : in  std_logic_vector(31 downto 0);
        HRDATA_S1     : in  std_logic_vector(31 downto 0);
        HRDATA_S10    : in  std_logic_vector(31 downto 0);
        HRDATA_S11    : in  std_logic_vector(31 downto 0);
        HRDATA_S12    : in  std_logic_vector(31 downto 0);
        HRDATA_S13    : in  std_logic_vector(31 downto 0);
        HRDATA_S14    : in  std_logic_vector(31 downto 0);
        HRDATA_S15    : in  std_logic_vector(31 downto 0);
        HRDATA_S16    : in  std_logic_vector(31 downto 0);
        HRDATA_S2     : in  std_logic_vector(31 downto 0);
        HRDATA_S3     : in  std_logic_vector(31 downto 0);
        HRDATA_S4     : in  std_logic_vector(31 downto 0);
        HRDATA_S5     : in  std_logic_vector(31 downto 0);
        HRDATA_S6     : in  std_logic_vector(31 downto 0);
        HRDATA_S7     : in  std_logic_vector(31 downto 0);
        HRDATA_S8     : in  std_logic_vector(31 downto 0);
        HRDATA_S9     : in  std_logic_vector(31 downto 0);
        HREADYOUT_S0  : in  std_logic;
        HREADYOUT_S1  : in  std_logic;
        HREADYOUT_S10 : in  std_logic;
        HREADYOUT_S11 : in  std_logic;
        HREADYOUT_S12 : in  std_logic;
        HREADYOUT_S13 : in  std_logic;
        HREADYOUT_S14 : in  std_logic;
        HREADYOUT_S15 : in  std_logic;
        HREADYOUT_S16 : in  std_logic;
        HREADYOUT_S2  : in  std_logic;
        HREADYOUT_S3  : in  std_logic;
        HREADYOUT_S4  : in  std_logic;
        HREADYOUT_S5  : in  std_logic;
        HREADYOUT_S6  : in  std_logic;
        HREADYOUT_S7  : in  std_logic;
        HREADYOUT_S8  : in  std_logic;
        HREADYOUT_S9  : in  std_logic;
        HRESETN       : in  std_logic;
        HRESP_S0      : in  std_logic_vector(1 downto 0);
        HRESP_S1      : in  std_logic_vector(1 downto 0);
        HRESP_S10     : in  std_logic_vector(1 downto 0);
        HRESP_S11     : in  std_logic_vector(1 downto 0);
        HRESP_S12     : in  std_logic_vector(1 downto 0);
        HRESP_S13     : in  std_logic_vector(1 downto 0);
        HRESP_S14     : in  std_logic_vector(1 downto 0);
        HRESP_S15     : in  std_logic_vector(1 downto 0);
        HRESP_S16     : in  std_logic_vector(1 downto 0);
        HRESP_S2      : in  std_logic_vector(1 downto 0);
        HRESP_S3      : in  std_logic_vector(1 downto 0);
        HRESP_S4      : in  std_logic_vector(1 downto 0);
        HRESP_S5      : in  std_logic_vector(1 downto 0);
        HRESP_S6      : in  std_logic_vector(1 downto 0);
        HRESP_S7      : in  std_logic_vector(1 downto 0);
        HRESP_S8      : in  std_logic_vector(1 downto 0);
        HRESP_S9      : in  std_logic_vector(1 downto 0);
        HSIZE_M0      : in  std_logic_vector(2 downto 0);
        HSIZE_M1      : in  std_logic_vector(2 downto 0);
        HSIZE_M2      : in  std_logic_vector(2 downto 0);
        HSIZE_M3      : in  std_logic_vector(2 downto 0);
        HTRANS_M0     : in  std_logic_vector(1 downto 0);
        HTRANS_M1     : in  std_logic_vector(1 downto 0);
        HTRANS_M2     : in  std_logic_vector(1 downto 0);
        HTRANS_M3     : in  std_logic_vector(1 downto 0);
        HWDATA_M0     : in  std_logic_vector(31 downto 0);
        HWDATA_M1     : in  std_logic_vector(31 downto 0);
        HWDATA_M2     : in  std_logic_vector(31 downto 0);
        HWDATA_M3     : in  std_logic_vector(31 downto 0);
        HWRITE_M0     : in  std_logic;
        HWRITE_M1     : in  std_logic;
        HWRITE_M2     : in  std_logic;
        HWRITE_M3     : in  std_logic;
        REMAP_M0      : in  std_logic;
        -- Outputs
        HADDR_S0      : out std_logic_vector(31 downto 0);
        HADDR_S1      : out std_logic_vector(31 downto 0);
        HADDR_S10     : out std_logic_vector(31 downto 0);
        HADDR_S11     : out std_logic_vector(31 downto 0);
        HADDR_S12     : out std_logic_vector(31 downto 0);
        HADDR_S13     : out std_logic_vector(31 downto 0);
        HADDR_S14     : out std_logic_vector(31 downto 0);
        HADDR_S15     : out std_logic_vector(31 downto 0);
        HADDR_S16     : out std_logic_vector(31 downto 0);
        HADDR_S2      : out std_logic_vector(31 downto 0);
        HADDR_S3      : out std_logic_vector(31 downto 0);
        HADDR_S4      : out std_logic_vector(31 downto 0);
        HADDR_S5      : out std_logic_vector(31 downto 0);
        HADDR_S6      : out std_logic_vector(31 downto 0);
        HADDR_S7      : out std_logic_vector(31 downto 0);
        HADDR_S8      : out std_logic_vector(31 downto 0);
        HADDR_S9      : out std_logic_vector(31 downto 0);
        HBURST_S0     : out std_logic_vector(2 downto 0);
        HBURST_S1     : out std_logic_vector(2 downto 0);
        HBURST_S10    : out std_logic_vector(2 downto 0);
        HBURST_S11    : out std_logic_vector(2 downto 0);
        HBURST_S12    : out std_logic_vector(2 downto 0);
        HBURST_S13    : out std_logic_vector(2 downto 0);
        HBURST_S14    : out std_logic_vector(2 downto 0);
        HBURST_S15    : out std_logic_vector(2 downto 0);
        HBURST_S16    : out std_logic_vector(2 downto 0);
        HBURST_S2     : out std_logic_vector(2 downto 0);
        HBURST_S3     : out std_logic_vector(2 downto 0);
        HBURST_S4     : out std_logic_vector(2 downto 0);
        HBURST_S5     : out std_logic_vector(2 downto 0);
        HBURST_S6     : out std_logic_vector(2 downto 0);
        HBURST_S7     : out std_logic_vector(2 downto 0);
        HBURST_S8     : out std_logic_vector(2 downto 0);
        HBURST_S9     : out std_logic_vector(2 downto 0);
        HMASTLOCK_S0  : out std_logic;
        HMASTLOCK_S1  : out std_logic;
        HMASTLOCK_S10 : out std_logic;
        HMASTLOCK_S11 : out std_logic;
        HMASTLOCK_S12 : out std_logic;
        HMASTLOCK_S13 : out std_logic;
        HMASTLOCK_S14 : out std_logic;
        HMASTLOCK_S15 : out std_logic;
        HMASTLOCK_S16 : out std_logic;
        HMASTLOCK_S2  : out std_logic;
        HMASTLOCK_S3  : out std_logic;
        HMASTLOCK_S4  : out std_logic;
        HMASTLOCK_S5  : out std_logic;
        HMASTLOCK_S6  : out std_logic;
        HMASTLOCK_S7  : out std_logic;
        HMASTLOCK_S8  : out std_logic;
        HMASTLOCK_S9  : out std_logic;
        HPROT_S0      : out std_logic_vector(3 downto 0);
        HPROT_S1      : out std_logic_vector(3 downto 0);
        HPROT_S10     : out std_logic_vector(3 downto 0);
        HPROT_S11     : out std_logic_vector(3 downto 0);
        HPROT_S12     : out std_logic_vector(3 downto 0);
        HPROT_S13     : out std_logic_vector(3 downto 0);
        HPROT_S14     : out std_logic_vector(3 downto 0);
        HPROT_S15     : out std_logic_vector(3 downto 0);
        HPROT_S16     : out std_logic_vector(3 downto 0);
        HPROT_S2      : out std_logic_vector(3 downto 0);
        HPROT_S3      : out std_logic_vector(3 downto 0);
        HPROT_S4      : out std_logic_vector(3 downto 0);
        HPROT_S5      : out std_logic_vector(3 downto 0);
        HPROT_S6      : out std_logic_vector(3 downto 0);
        HPROT_S7      : out std_logic_vector(3 downto 0);
        HPROT_S8      : out std_logic_vector(3 downto 0);
        HPROT_S9      : out std_logic_vector(3 downto 0);
        HRDATA_M0     : out std_logic_vector(31 downto 0);
        HRDATA_M1     : out std_logic_vector(31 downto 0);
        HRDATA_M2     : out std_logic_vector(31 downto 0);
        HRDATA_M3     : out std_logic_vector(31 downto 0);
        HREADY_M0     : out std_logic;
        HREADY_M1     : out std_logic;
        HREADY_M2     : out std_logic;
        HREADY_M3     : out std_logic;
        HREADY_S0     : out std_logic;
        HREADY_S1     : out std_logic;
        HREADY_S10    : out std_logic;
        HREADY_S11    : out std_logic;
        HREADY_S12    : out std_logic;
        HREADY_S13    : out std_logic;
        HREADY_S14    : out std_logic;
        HREADY_S15    : out std_logic;
        HREADY_S16    : out std_logic;
        HREADY_S2     : out std_logic;
        HREADY_S3     : out std_logic;
        HREADY_S4     : out std_logic;
        HREADY_S5     : out std_logic;
        HREADY_S6     : out std_logic;
        HREADY_S7     : out std_logic;
        HREADY_S8     : out std_logic;
        HREADY_S9     : out std_logic;
        HRESP_M0      : out std_logic_vector(1 downto 0);
        HRESP_M1      : out std_logic_vector(1 downto 0);
        HRESP_M2      : out std_logic_vector(1 downto 0);
        HRESP_M3      : out std_logic_vector(1 downto 0);
        HSEL_S0       : out std_logic;
        HSEL_S1       : out std_logic;
        HSEL_S10      : out std_logic;
        HSEL_S11      : out std_logic;
        HSEL_S12      : out std_logic;
        HSEL_S13      : out std_logic;
        HSEL_S14      : out std_logic;
        HSEL_S15      : out std_logic;
        HSEL_S16      : out std_logic;
        HSEL_S2       : out std_logic;
        HSEL_S3       : out std_logic;
        HSEL_S4       : out std_logic;
        HSEL_S5       : out std_logic;
        HSEL_S6       : out std_logic;
        HSEL_S7       : out std_logic;
        HSEL_S8       : out std_logic;
        HSEL_S9       : out std_logic;
        HSIZE_S0      : out std_logic_vector(2 downto 0);
        HSIZE_S1      : out std_logic_vector(2 downto 0);
        HSIZE_S10     : out std_logic_vector(2 downto 0);
        HSIZE_S11     : out std_logic_vector(2 downto 0);
        HSIZE_S12     : out std_logic_vector(2 downto 0);
        HSIZE_S13     : out std_logic_vector(2 downto 0);
        HSIZE_S14     : out std_logic_vector(2 downto 0);
        HSIZE_S15     : out std_logic_vector(2 downto 0);
        HSIZE_S16     : out std_logic_vector(2 downto 0);
        HSIZE_S2      : out std_logic_vector(2 downto 0);
        HSIZE_S3      : out std_logic_vector(2 downto 0);
        HSIZE_S4      : out std_logic_vector(2 downto 0);
        HSIZE_S5      : out std_logic_vector(2 downto 0);
        HSIZE_S6      : out std_logic_vector(2 downto 0);
        HSIZE_S7      : out std_logic_vector(2 downto 0);
        HSIZE_S8      : out std_logic_vector(2 downto 0);
        HSIZE_S9      : out std_logic_vector(2 downto 0);
        HTRANS_S0     : out std_logic_vector(1 downto 0);
        HTRANS_S1     : out std_logic_vector(1 downto 0);
        HTRANS_S10    : out std_logic_vector(1 downto 0);
        HTRANS_S11    : out std_logic_vector(1 downto 0);
        HTRANS_S12    : out std_logic_vector(1 downto 0);
        HTRANS_S13    : out std_logic_vector(1 downto 0);
        HTRANS_S14    : out std_logic_vector(1 downto 0);
        HTRANS_S15    : out std_logic_vector(1 downto 0);
        HTRANS_S16    : out std_logic_vector(1 downto 0);
        HTRANS_S2     : out std_logic_vector(1 downto 0);
        HTRANS_S3     : out std_logic_vector(1 downto 0);
        HTRANS_S4     : out std_logic_vector(1 downto 0);
        HTRANS_S5     : out std_logic_vector(1 downto 0);
        HTRANS_S6     : out std_logic_vector(1 downto 0);
        HTRANS_S7     : out std_logic_vector(1 downto 0);
        HTRANS_S8     : out std_logic_vector(1 downto 0);
        HTRANS_S9     : out std_logic_vector(1 downto 0);
        HWDATA_S0     : out std_logic_vector(31 downto 0);
        HWDATA_S1     : out std_logic_vector(31 downto 0);
        HWDATA_S10    : out std_logic_vector(31 downto 0);
        HWDATA_S11    : out std_logic_vector(31 downto 0);
        HWDATA_S12    : out std_logic_vector(31 downto 0);
        HWDATA_S13    : out std_logic_vector(31 downto 0);
        HWDATA_S14    : out std_logic_vector(31 downto 0);
        HWDATA_S15    : out std_logic_vector(31 downto 0);
        HWDATA_S16    : out std_logic_vector(31 downto 0);
        HWDATA_S2     : out std_logic_vector(31 downto 0);
        HWDATA_S3     : out std_logic_vector(31 downto 0);
        HWDATA_S4     : out std_logic_vector(31 downto 0);
        HWDATA_S5     : out std_logic_vector(31 downto 0);
        HWDATA_S6     : out std_logic_vector(31 downto 0);
        HWDATA_S7     : out std_logic_vector(31 downto 0);
        HWDATA_S8     : out std_logic_vector(31 downto 0);
        HWDATA_S9     : out std_logic_vector(31 downto 0);
        HWRITE_S0     : out std_logic;
        HWRITE_S1     : out std_logic;
        HWRITE_S10    : out std_logic;
        HWRITE_S11    : out std_logic;
        HWRITE_S12    : out std_logic;
        HWRITE_S13    : out std_logic;
        HWRITE_S14    : out std_logic;
        HWRITE_S15    : out std_logic;
        HWRITE_S16    : out std_logic;
        HWRITE_S2     : out std_logic;
        HWRITE_S3     : out std_logic;
        HWRITE_S4     : out std_logic;
        HWRITE_S5     : out std_logic;
        HWRITE_S6     : out std_logic;
        HWRITE_S7     : out std_logic;
        HWRITE_S8     : out std_logic;
        HWRITE_S9     : out std_logic
        );
end component;
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal AHBmmaster0_HRDATA         : std_logic_vector(31 downto 0);
signal AHBmmaster0_HREADY         : std_logic;
signal AHBmmaster0_HRESP          : std_logic_vector(1 downto 0);
signal AHBmslave0_HADDR           : std_logic_vector(31 downto 0);
signal AHBmslave0_HBURST          : std_logic_vector(2 downto 0);
signal AHBmslave0_HMASTLOCK       : std_logic;
signal AHBmslave0_HPROT           : std_logic_vector(3 downto 0);
signal AHBmslave0_HREADY          : std_logic;
signal AHBmslave0_HSELx           : std_logic;
signal AHBmslave0_HSIZE           : std_logic_vector(2 downto 0);
signal AHBmslave0_HTRANS          : std_logic_vector(1 downto 0);
signal AHBmslave0_HWDATA          : std_logic_vector(31 downto 0);
signal AHBmslave0_HWRITE          : std_logic;
signal AHBmmaster0_HREADY_net_0   : std_logic;
signal AHBmslave0_HWRITE_net_0    : std_logic;
signal AHBmslave0_HSELx_net_0     : std_logic;
signal AHBmslave0_HREADY_net_0    : std_logic;
signal AHBmslave0_HMASTLOCK_net_0 : std_logic;
signal AHBmmaster0_HRDATA_net_0   : std_logic_vector(31 downto 0);
signal AHBmmaster0_HRESP_net_0    : std_logic_vector(1 downto 0);
signal AHBmslave0_HADDR_net_0     : std_logic_vector(31 downto 0);
signal AHBmslave0_HTRANS_net_0    : std_logic_vector(1 downto 0);
signal AHBmslave0_HSIZE_net_0     : std_logic_vector(2 downto 0);
signal AHBmslave0_HWDATA_net_0    : std_logic_vector(31 downto 0);
signal AHBmslave0_HBURST_net_0    : std_logic_vector(2 downto 0);
signal AHBmslave0_HPROT_net_0     : std_logic_vector(3 downto 0);
----------------------------------------------------------------------
-- TiedOff Signals
----------------------------------------------------------------------
signal HADDR_M1_const_net_0       : std_logic_vector(31 downto 0);
signal HTRANS_M1_const_net_0      : std_logic_vector(1 downto 0);
signal GND_net                    : std_logic;
signal HSIZE_M1_const_net_0       : std_logic_vector(2 downto 0);
signal HBURST_M1_const_net_0      : std_logic_vector(2 downto 0);
signal HPROT_M1_const_net_0       : std_logic_vector(3 downto 0);
signal HWDATA_M1_const_net_0      : std_logic_vector(31 downto 0);
signal HADDR_M2_const_net_0       : std_logic_vector(31 downto 0);
signal HTRANS_M2_const_net_0      : std_logic_vector(1 downto 0);
signal HSIZE_M2_const_net_0       : std_logic_vector(2 downto 0);
signal HBURST_M2_const_net_0      : std_logic_vector(2 downto 0);
signal HPROT_M2_const_net_0       : std_logic_vector(3 downto 0);
signal HWDATA_M2_const_net_0      : std_logic_vector(31 downto 0);
signal HADDR_M3_const_net_0       : std_logic_vector(31 downto 0);
signal HTRANS_M3_const_net_0      : std_logic_vector(1 downto 0);
signal HSIZE_M3_const_net_0       : std_logic_vector(2 downto 0);
signal HBURST_M3_const_net_0      : std_logic_vector(2 downto 0);
signal HPROT_M3_const_net_0       : std_logic_vector(3 downto 0);
signal HWDATA_M3_const_net_0      : std_logic_vector(31 downto 0);
signal HRDATA_S1_const_net_0      : std_logic_vector(31 downto 0);
signal HRESP_S1_const_net_0       : std_logic_vector(1 downto 0);
signal VCC_net                    : std_logic;
signal HRDATA_S2_const_net_0      : std_logic_vector(31 downto 0);
signal HRESP_S2_const_net_0       : std_logic_vector(1 downto 0);
signal HRDATA_S3_const_net_0      : std_logic_vector(31 downto 0);
signal HRESP_S3_const_net_0       : std_logic_vector(1 downto 0);
signal HRDATA_S4_const_net_0      : std_logic_vector(31 downto 0);
signal HRESP_S4_const_net_0       : std_logic_vector(1 downto 0);
signal HRDATA_S5_const_net_0      : std_logic_vector(31 downto 0);
signal HRESP_S5_const_net_0       : std_logic_vector(1 downto 0);
signal HRDATA_S6_const_net_0      : std_logic_vector(31 downto 0);
signal HRESP_S6_const_net_0       : std_logic_vector(1 downto 0);
signal HRDATA_S7_const_net_0      : std_logic_vector(31 downto 0);
signal HRESP_S7_const_net_0       : std_logic_vector(1 downto 0);
signal HRDATA_S8_const_net_0      : std_logic_vector(31 downto 0);
signal HRESP_S8_const_net_0       : std_logic_vector(1 downto 0);
signal HRDATA_S9_const_net_0      : std_logic_vector(31 downto 0);
signal HRESP_S9_const_net_0       : std_logic_vector(1 downto 0);
signal HRDATA_S10_const_net_0     : std_logic_vector(31 downto 0);
signal HRESP_S10_const_net_0      : std_logic_vector(1 downto 0);
signal HRDATA_S11_const_net_0     : std_logic_vector(31 downto 0);
signal HRESP_S11_const_net_0      : std_logic_vector(1 downto 0);
signal HRDATA_S12_const_net_0     : std_logic_vector(31 downto 0);
signal HRESP_S12_const_net_0      : std_logic_vector(1 downto 0);
signal HRDATA_S13_const_net_0     : std_logic_vector(31 downto 0);
signal HRESP_S13_const_net_0      : std_logic_vector(1 downto 0);
signal HRDATA_S14_const_net_0     : std_logic_vector(31 downto 0);
signal HRESP_S14_const_net_0      : std_logic_vector(1 downto 0);
signal HRDATA_S15_const_net_0     : std_logic_vector(31 downto 0);
signal HRESP_S15_const_net_0      : std_logic_vector(1 downto 0);
signal HRDATA_S16_const_net_0     : std_logic_vector(31 downto 0);
signal HRESP_S16_const_net_0      : std_logic_vector(1 downto 0);

begin
----------------------------------------------------------------------
-- Constant assignments
----------------------------------------------------------------------
 HADDR_M1_const_net_0   <= B"00000000000000000000000000000000";
 HTRANS_M1_const_net_0  <= B"00";
 GND_net                <= '0';
 HSIZE_M1_const_net_0   <= B"000";
 HBURST_M1_const_net_0  <= B"000";
 HPROT_M1_const_net_0   <= B"0000";
 HWDATA_M1_const_net_0  <= B"00000000000000000000000000000000";
 HADDR_M2_const_net_0   <= B"00000000000000000000000000000000";
 HTRANS_M2_const_net_0  <= B"00";
 HSIZE_M2_const_net_0   <= B"000";
 HBURST_M2_const_net_0  <= B"000";
 HPROT_M2_const_net_0   <= B"0000";
 HWDATA_M2_const_net_0  <= B"00000000000000000000000000000000";
 HADDR_M3_const_net_0   <= B"00000000000000000000000000000000";
 HTRANS_M3_const_net_0  <= B"00";
 HSIZE_M3_const_net_0   <= B"000";
 HBURST_M3_const_net_0  <= B"000";
 HPROT_M3_const_net_0   <= B"0000";
 HWDATA_M3_const_net_0  <= B"00000000000000000000000000000000";
 HRDATA_S1_const_net_0  <= B"00000000000000000000000000000000";
 HRESP_S1_const_net_0   <= B"00";
 VCC_net                <= '1';
 HRDATA_S2_const_net_0  <= B"00000000000000000000000000000000";
 HRESP_S2_const_net_0   <= B"00";
 HRDATA_S3_const_net_0  <= B"00000000000000000000000000000000";
 HRESP_S3_const_net_0   <= B"00";
 HRDATA_S4_const_net_0  <= B"00000000000000000000000000000000";
 HRESP_S4_const_net_0   <= B"00";
 HRDATA_S5_const_net_0  <= B"00000000000000000000000000000000";
 HRESP_S5_const_net_0   <= B"00";
 HRDATA_S6_const_net_0  <= B"00000000000000000000000000000000";
 HRESP_S6_const_net_0   <= B"00";
 HRDATA_S7_const_net_0  <= B"00000000000000000000000000000000";
 HRESP_S7_const_net_0   <= B"00";
 HRDATA_S8_const_net_0  <= B"00000000000000000000000000000000";
 HRESP_S8_const_net_0   <= B"00";
 HRDATA_S9_const_net_0  <= B"00000000000000000000000000000000";
 HRESP_S9_const_net_0   <= B"00";
 HRDATA_S10_const_net_0 <= B"00000000000000000000000000000000";
 HRESP_S10_const_net_0  <= B"00";
 HRDATA_S11_const_net_0 <= B"00000000000000000000000000000000";
 HRESP_S11_const_net_0  <= B"00";
 HRDATA_S12_const_net_0 <= B"00000000000000000000000000000000";
 HRESP_S12_const_net_0  <= B"00";
 HRDATA_S13_const_net_0 <= B"00000000000000000000000000000000";
 HRESP_S13_const_net_0  <= B"00";
 HRDATA_S14_const_net_0 <= B"00000000000000000000000000000000";
 HRESP_S14_const_net_0  <= B"00";
 HRDATA_S15_const_net_0 <= B"00000000000000000000000000000000";
 HRESP_S15_const_net_0  <= B"00";
 HRDATA_S16_const_net_0 <= B"00000000000000000000000000000000";
 HRESP_S16_const_net_0  <= B"00";
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 AHBmmaster0_HREADY_net_0   <= AHBmmaster0_HREADY;
 HREADY_M0                  <= AHBmmaster0_HREADY_net_0;
 AHBmslave0_HWRITE_net_0    <= AHBmslave0_HWRITE;
 HWRITE_S0                  <= AHBmslave0_HWRITE_net_0;
 AHBmslave0_HSELx_net_0     <= AHBmslave0_HSELx;
 HSEL_S0                    <= AHBmslave0_HSELx_net_0;
 AHBmslave0_HREADY_net_0    <= AHBmslave0_HREADY;
 HREADY_S0                  <= AHBmslave0_HREADY_net_0;
 AHBmslave0_HMASTLOCK_net_0 <= AHBmslave0_HMASTLOCK;
 HMASTLOCK_S0               <= AHBmslave0_HMASTLOCK_net_0;
 AHBmmaster0_HRDATA_net_0   <= AHBmmaster0_HRDATA;
 HRDATA_M0(31 downto 0)     <= AHBmmaster0_HRDATA_net_0;
 AHBmmaster0_HRESP_net_0    <= AHBmmaster0_HRESP;
 HRESP_M0(1 downto 0)       <= AHBmmaster0_HRESP_net_0;
 AHBmslave0_HADDR_net_0     <= AHBmslave0_HADDR;
 HADDR_S0(31 downto 0)      <= AHBmslave0_HADDR_net_0;
 AHBmslave0_HTRANS_net_0    <= AHBmslave0_HTRANS;
 HTRANS_S0(1 downto 0)      <= AHBmslave0_HTRANS_net_0;
 AHBmslave0_HSIZE_net_0     <= AHBmslave0_HSIZE;
 HSIZE_S0(2 downto 0)       <= AHBmslave0_HSIZE_net_0;
 AHBmslave0_HWDATA_net_0    <= AHBmslave0_HWDATA;
 HWDATA_S0(31 downto 0)     <= AHBmslave0_HWDATA_net_0;
 AHBmslave0_HBURST_net_0    <= AHBmslave0_HBURST;
 HBURST_S0(2 downto 0)      <= AHBmslave0_HBURST_net_0;
 AHBmslave0_HPROT_net_0     <= AHBmslave0_HPROT;
 HPROT_S0(3 downto 0)       <= AHBmslave0_HPROT_net_0;
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- CoreAHBLite_C0_0   -   Actel:DirectCore:CoreAHBLite:5.4.102
CoreAHBLite_C0_0 : CoreAHBLite_C0_CoreAHBLite_C0_0_CoreAHBLite
    generic map( 
        FAMILY             => ( 19 ),
        HADDR_SHG_CFG      => ( 1 ),
        M0_AHBSLOT0ENABLE  => ( 1 ),
        M0_AHBSLOT1ENABLE  => ( 0 ),
        M0_AHBSLOT2ENABLE  => ( 0 ),
        M0_AHBSLOT3ENABLE  => ( 0 ),
        M0_AHBSLOT4ENABLE  => ( 0 ),
        M0_AHBSLOT5ENABLE  => ( 0 ),
        M0_AHBSLOT6ENABLE  => ( 0 ),
        M0_AHBSLOT7ENABLE  => ( 0 ),
        M0_AHBSLOT8ENABLE  => ( 0 ),
        M0_AHBSLOT9ENABLE  => ( 0 ),
        M0_AHBSLOT10ENABLE => ( 0 ),
        M0_AHBSLOT11ENABLE => ( 0 ),
        M0_AHBSLOT12ENABLE => ( 0 ),
        M0_AHBSLOT13ENABLE => ( 0 ),
        M0_AHBSLOT14ENABLE => ( 0 ),
        M0_AHBSLOT15ENABLE => ( 0 ),
        M0_AHBSLOT16ENABLE => ( 0 ),
        M1_AHBSLOT0ENABLE  => ( 0 ),
        M1_AHBSLOT1ENABLE  => ( 0 ),
        M1_AHBSLOT2ENABLE  => ( 0 ),
        M1_AHBSLOT3ENABLE  => ( 0 ),
        M1_AHBSLOT4ENABLE  => ( 0 ),
        M1_AHBSLOT5ENABLE  => ( 0 ),
        M1_AHBSLOT6ENABLE  => ( 0 ),
        M1_AHBSLOT7ENABLE  => ( 0 ),
        M1_AHBSLOT8ENABLE  => ( 0 ),
        M1_AHBSLOT9ENABLE  => ( 0 ),
        M1_AHBSLOT10ENABLE => ( 0 ),
        M1_AHBSLOT11ENABLE => ( 0 ),
        M1_AHBSLOT12ENABLE => ( 0 ),
        M1_AHBSLOT13ENABLE => ( 0 ),
        M1_AHBSLOT14ENABLE => ( 0 ),
        M1_AHBSLOT15ENABLE => ( 0 ),
        M1_AHBSLOT16ENABLE => ( 0 ),
        M2_AHBSLOT0ENABLE  => ( 0 ),
        M2_AHBSLOT1ENABLE  => ( 0 ),
        M2_AHBSLOT2ENABLE  => ( 0 ),
        M2_AHBSLOT3ENABLE  => ( 0 ),
        M2_AHBSLOT4ENABLE  => ( 0 ),
        M2_AHBSLOT5ENABLE  => ( 0 ),
        M2_AHBSLOT6ENABLE  => ( 0 ),
        M2_AHBSLOT7ENABLE  => ( 0 ),
        M2_AHBSLOT8ENABLE  => ( 0 ),
        M2_AHBSLOT9ENABLE  => ( 0 ),
        M2_AHBSLOT10ENABLE => ( 0 ),
        M2_AHBSLOT11ENABLE => ( 0 ),
        M2_AHBSLOT12ENABLE => ( 0 ),
        M2_AHBSLOT13ENABLE => ( 0 ),
        M2_AHBSLOT14ENABLE => ( 0 ),
        M2_AHBSLOT15ENABLE => ( 0 ),
        M2_AHBSLOT16ENABLE => ( 0 ),
        M3_AHBSLOT0ENABLE  => ( 0 ),
        M3_AHBSLOT1ENABLE  => ( 0 ),
        M3_AHBSLOT2ENABLE  => ( 0 ),
        M3_AHBSLOT3ENABLE  => ( 0 ),
        M3_AHBSLOT4ENABLE  => ( 0 ),
        M3_AHBSLOT5ENABLE  => ( 0 ),
        M3_AHBSLOT6ENABLE  => ( 0 ),
        M3_AHBSLOT7ENABLE  => ( 0 ),
        M3_AHBSLOT8ENABLE  => ( 0 ),
        M3_AHBSLOT9ENABLE  => ( 0 ),
        M3_AHBSLOT10ENABLE => ( 0 ),
        M3_AHBSLOT11ENABLE => ( 0 ),
        M3_AHBSLOT12ENABLE => ( 0 ),
        M3_AHBSLOT13ENABLE => ( 0 ),
        M3_AHBSLOT14ENABLE => ( 0 ),
        M3_AHBSLOT15ENABLE => ( 0 ),
        M3_AHBSLOT16ENABLE => ( 0 ),
        MASTER0_INTERFACE  => ( 1 ),
        MASTER1_INTERFACE  => ( 1 ),
        MASTER2_INTERFACE  => ( 1 ),
        MASTER3_INTERFACE  => ( 1 ),
        MEMSPACE           => ( 6 ),
        SC_0               => ( 0 ),
        SC_1               => ( 0 ),
        SC_2               => ( 0 ),
        SC_3               => ( 0 ),
        SC_4               => ( 0 ),
        SC_5               => ( 0 ),
        SC_6               => ( 0 ),
        SC_7               => ( 0 ),
        SC_8               => ( 0 ),
        SC_9               => ( 0 ),
        SC_10              => ( 0 ),
        SC_11              => ( 0 ),
        SC_12              => ( 0 ),
        SC_13              => ( 0 ),
        SC_14              => ( 0 ),
        SC_15              => ( 0 ),
        SLAVE0_INTERFACE   => ( 1 ),
        SLAVE1_INTERFACE   => ( 1 ),
        SLAVE2_INTERFACE   => ( 1 ),
        SLAVE3_INTERFACE   => ( 1 ),
        SLAVE4_INTERFACE   => ( 1 ),
        SLAVE5_INTERFACE   => ( 1 ),
        SLAVE6_INTERFACE   => ( 1 ),
        SLAVE7_INTERFACE   => ( 1 ),
        SLAVE8_INTERFACE   => ( 1 ),
        SLAVE9_INTERFACE   => ( 1 ),
        SLAVE10_INTERFACE  => ( 1 ),
        SLAVE11_INTERFACE  => ( 1 ),
        SLAVE12_INTERFACE  => ( 1 ),
        SLAVE13_INTERFACE  => ( 1 ),
        SLAVE14_INTERFACE  => ( 1 ),
        SLAVE15_INTERFACE  => ( 1 ),
        SLAVE16_INTERFACE  => ( 1 )
        )
    port map( 
        -- Inputs
        HCLK          => HCLK,
        HRESETN       => HRESETN,
        REMAP_M0      => REMAP_M0,
        HMASTLOCK_M0  => HMASTLOCK_M0,
        HWRITE_M0     => HWRITE_M0,
        HMASTLOCK_M1  => GND_net, -- tied to '0' from definition
        HWRITE_M1     => GND_net, -- tied to '0' from definition
        HMASTLOCK_M2  => GND_net, -- tied to '0' from definition
        HWRITE_M2     => GND_net, -- tied to '0' from definition
        HMASTLOCK_M3  => GND_net, -- tied to '0' from definition
        HWRITE_M3     => GND_net, -- tied to '0' from definition
        HREADYOUT_S0  => HREADYOUT_S0,
        HREADYOUT_S1  => VCC_net, -- tied to '1' from definition
        HREADYOUT_S2  => VCC_net, -- tied to '1' from definition
        HREADYOUT_S3  => VCC_net, -- tied to '1' from definition
        HREADYOUT_S4  => VCC_net, -- tied to '1' from definition
        HREADYOUT_S5  => VCC_net, -- tied to '1' from definition
        HREADYOUT_S6  => VCC_net, -- tied to '1' from definition
        HREADYOUT_S7  => VCC_net, -- tied to '1' from definition
        HREADYOUT_S8  => VCC_net, -- tied to '1' from definition
        HREADYOUT_S9  => VCC_net, -- tied to '1' from definition
        HREADYOUT_S10 => VCC_net, -- tied to '1' from definition
        HREADYOUT_S11 => VCC_net, -- tied to '1' from definition
        HREADYOUT_S12 => VCC_net, -- tied to '1' from definition
        HREADYOUT_S13 => VCC_net, -- tied to '1' from definition
        HREADYOUT_S14 => VCC_net, -- tied to '1' from definition
        HREADYOUT_S15 => VCC_net, -- tied to '1' from definition
        HREADYOUT_S16 => VCC_net, -- tied to '1' from definition
        HADDR_M0      => HADDR_M0,
        HSIZE_M0      => HSIZE_M0,
        HTRANS_M0     => HTRANS_M0,
        HWDATA_M0     => HWDATA_M0,
        HBURST_M0     => HBURST_M0,
        HPROT_M0      => HPROT_M0,
        HADDR_M1      => HADDR_M1_const_net_0, -- tied to X"0" from definition
        HSIZE_M1      => HSIZE_M1_const_net_0, -- tied to X"0" from definition
        HTRANS_M1     => HTRANS_M1_const_net_0, -- tied to X"0" from definition
        HWDATA_M1     => HWDATA_M1_const_net_0, -- tied to X"0" from definition
        HBURST_M1     => HBURST_M1_const_net_0, -- tied to X"0" from definition
        HPROT_M1      => HPROT_M1_const_net_0, -- tied to X"0" from definition
        HADDR_M2      => HADDR_M2_const_net_0, -- tied to X"0" from definition
        HSIZE_M2      => HSIZE_M2_const_net_0, -- tied to X"0" from definition
        HTRANS_M2     => HTRANS_M2_const_net_0, -- tied to X"0" from definition
        HWDATA_M2     => HWDATA_M2_const_net_0, -- tied to X"0" from definition
        HBURST_M2     => HBURST_M2_const_net_0, -- tied to X"0" from definition
        HPROT_M2      => HPROT_M2_const_net_0, -- tied to X"0" from definition
        HADDR_M3      => HADDR_M3_const_net_0, -- tied to X"0" from definition
        HSIZE_M3      => HSIZE_M3_const_net_0, -- tied to X"0" from definition
        HTRANS_M3     => HTRANS_M3_const_net_0, -- tied to X"0" from definition
        HWDATA_M3     => HWDATA_M3_const_net_0, -- tied to X"0" from definition
        HBURST_M3     => HBURST_M3_const_net_0, -- tied to X"0" from definition
        HPROT_M3      => HPROT_M3_const_net_0, -- tied to X"0" from definition
        HRDATA_S0     => HRDATA_S0,
        HRESP_S0      => HRESP_S0,
        HRDATA_S1     => HRDATA_S1_const_net_0, -- tied to X"0" from definition
        HRESP_S1      => HRESP_S1_const_net_0, -- tied to X"0" from definition
        HRDATA_S2     => HRDATA_S2_const_net_0, -- tied to X"0" from definition
        HRESP_S2      => HRESP_S2_const_net_0, -- tied to X"0" from definition
        HRDATA_S3     => HRDATA_S3_const_net_0, -- tied to X"0" from definition
        HRESP_S3      => HRESP_S3_const_net_0, -- tied to X"0" from definition
        HRDATA_S4     => HRDATA_S4_const_net_0, -- tied to X"0" from definition
        HRESP_S4      => HRESP_S4_const_net_0, -- tied to X"0" from definition
        HRDATA_S5     => HRDATA_S5_const_net_0, -- tied to X"0" from definition
        HRESP_S5      => HRESP_S5_const_net_0, -- tied to X"0" from definition
        HRDATA_S6     => HRDATA_S6_const_net_0, -- tied to X"0" from definition
        HRESP_S6      => HRESP_S6_const_net_0, -- tied to X"0" from definition
        HRDATA_S7     => HRDATA_S7_const_net_0, -- tied to X"0" from definition
        HRESP_S7      => HRESP_S7_const_net_0, -- tied to X"0" from definition
        HRDATA_S8     => HRDATA_S8_const_net_0, -- tied to X"0" from definition
        HRESP_S8      => HRESP_S8_const_net_0, -- tied to X"0" from definition
        HRDATA_S9     => HRDATA_S9_const_net_0, -- tied to X"0" from definition
        HRESP_S9      => HRESP_S9_const_net_0, -- tied to X"0" from definition
        HRDATA_S10    => HRDATA_S10_const_net_0, -- tied to X"0" from definition
        HRESP_S10     => HRESP_S10_const_net_0, -- tied to X"0" from definition
        HRDATA_S11    => HRDATA_S11_const_net_0, -- tied to X"0" from definition
        HRESP_S11     => HRESP_S11_const_net_0, -- tied to X"0" from definition
        HRDATA_S12    => HRDATA_S12_const_net_0, -- tied to X"0" from definition
        HRESP_S12     => HRESP_S12_const_net_0, -- tied to X"0" from definition
        HRDATA_S13    => HRDATA_S13_const_net_0, -- tied to X"0" from definition
        HRESP_S13     => HRESP_S13_const_net_0, -- tied to X"0" from definition
        HRDATA_S14    => HRDATA_S14_const_net_0, -- tied to X"0" from definition
        HRESP_S14     => HRESP_S14_const_net_0, -- tied to X"0" from definition
        HRDATA_S15    => HRDATA_S15_const_net_0, -- tied to X"0" from definition
        HRESP_S15     => HRESP_S15_const_net_0, -- tied to X"0" from definition
        HRDATA_S16    => HRDATA_S16_const_net_0, -- tied to X"0" from definition
        HRESP_S16     => HRESP_S16_const_net_0, -- tied to X"0" from definition
        -- Outputs
        HREADY_M0     => AHBmmaster0_HREADY,
        HREADY_M1     => OPEN,
        HREADY_M2     => OPEN,
        HREADY_M3     => OPEN,
        HSEL_S0       => AHBmslave0_HSELx,
        HWRITE_S0     => AHBmslave0_HWRITE,
        HREADY_S0     => AHBmslave0_HREADY,
        HMASTLOCK_S0  => AHBmslave0_HMASTLOCK,
        HSEL_S1       => OPEN,
        HWRITE_S1     => OPEN,
        HREADY_S1     => OPEN,
        HMASTLOCK_S1  => OPEN,
        HSEL_S2       => OPEN,
        HWRITE_S2     => OPEN,
        HREADY_S2     => OPEN,
        HMASTLOCK_S2  => OPEN,
        HSEL_S3       => OPEN,
        HWRITE_S3     => OPEN,
        HREADY_S3     => OPEN,
        HMASTLOCK_S3  => OPEN,
        HSEL_S4       => OPEN,
        HWRITE_S4     => OPEN,
        HREADY_S4     => OPEN,
        HMASTLOCK_S4  => OPEN,
        HSEL_S5       => OPEN,
        HWRITE_S5     => OPEN,
        HREADY_S5     => OPEN,
        HMASTLOCK_S5  => OPEN,
        HSEL_S6       => OPEN,
        HWRITE_S6     => OPEN,
        HREADY_S6     => OPEN,
        HMASTLOCK_S6  => OPEN,
        HSEL_S7       => OPEN,
        HWRITE_S7     => OPEN,
        HREADY_S7     => OPEN,
        HMASTLOCK_S7  => OPEN,
        HSEL_S8       => OPEN,
        HWRITE_S8     => OPEN,
        HREADY_S8     => OPEN,
        HMASTLOCK_S8  => OPEN,
        HSEL_S9       => OPEN,
        HWRITE_S9     => OPEN,
        HREADY_S9     => OPEN,
        HMASTLOCK_S9  => OPEN,
        HSEL_S10      => OPEN,
        HWRITE_S10    => OPEN,
        HREADY_S10    => OPEN,
        HMASTLOCK_S10 => OPEN,
        HSEL_S11      => OPEN,
        HWRITE_S11    => OPEN,
        HREADY_S11    => OPEN,
        HMASTLOCK_S11 => OPEN,
        HSEL_S12      => OPEN,
        HWRITE_S12    => OPEN,
        HREADY_S12    => OPEN,
        HMASTLOCK_S12 => OPEN,
        HSEL_S13      => OPEN,
        HWRITE_S13    => OPEN,
        HREADY_S13    => OPEN,
        HMASTLOCK_S13 => OPEN,
        HSEL_S14      => OPEN,
        HWRITE_S14    => OPEN,
        HREADY_S14    => OPEN,
        HMASTLOCK_S14 => OPEN,
        HSEL_S15      => OPEN,
        HWRITE_S15    => OPEN,
        HREADY_S15    => OPEN,
        HMASTLOCK_S15 => OPEN,
        HSEL_S16      => OPEN,
        HWRITE_S16    => OPEN,
        HREADY_S16    => OPEN,
        HMASTLOCK_S16 => OPEN,
        HRESP_M0      => AHBmmaster0_HRESP,
        HRDATA_M0     => AHBmmaster0_HRDATA,
        HRESP_M1      => OPEN,
        HRDATA_M1     => OPEN,
        HRESP_M2      => OPEN,
        HRDATA_M2     => OPEN,
        HRESP_M3      => OPEN,
        HRDATA_M3     => OPEN,
        HADDR_S0      => AHBmslave0_HADDR,
        HSIZE_S0      => AHBmslave0_HSIZE,
        HTRANS_S0     => AHBmslave0_HTRANS,
        HWDATA_S0     => AHBmslave0_HWDATA,
        HBURST_S0     => AHBmslave0_HBURST,
        HPROT_S0      => AHBmslave0_HPROT,
        HADDR_S1      => OPEN,
        HSIZE_S1      => OPEN,
        HTRANS_S1     => OPEN,
        HWDATA_S1     => OPEN,
        HBURST_S1     => OPEN,
        HPROT_S1      => OPEN,
        HADDR_S2      => OPEN,
        HSIZE_S2      => OPEN,
        HTRANS_S2     => OPEN,
        HWDATA_S2     => OPEN,
        HBURST_S2     => OPEN,
        HPROT_S2      => OPEN,
        HADDR_S3      => OPEN,
        HSIZE_S3      => OPEN,
        HTRANS_S3     => OPEN,
        HWDATA_S3     => OPEN,
        HBURST_S3     => OPEN,
        HPROT_S3      => OPEN,
        HADDR_S4      => OPEN,
        HSIZE_S4      => OPEN,
        HTRANS_S4     => OPEN,
        HWDATA_S4     => OPEN,
        HBURST_S4     => OPEN,
        HPROT_S4      => OPEN,
        HADDR_S5      => OPEN,
        HSIZE_S5      => OPEN,
        HTRANS_S5     => OPEN,
        HWDATA_S5     => OPEN,
        HBURST_S5     => OPEN,
        HPROT_S5      => OPEN,
        HADDR_S6      => OPEN,
        HSIZE_S6      => OPEN,
        HTRANS_S6     => OPEN,
        HWDATA_S6     => OPEN,
        HBURST_S6     => OPEN,
        HPROT_S6      => OPEN,
        HADDR_S7      => OPEN,
        HSIZE_S7      => OPEN,
        HTRANS_S7     => OPEN,
        HWDATA_S7     => OPEN,
        HBURST_S7     => OPEN,
        HPROT_S7      => OPEN,
        HADDR_S8      => OPEN,
        HSIZE_S8      => OPEN,
        HTRANS_S8     => OPEN,
        HWDATA_S8     => OPEN,
        HBURST_S8     => OPEN,
        HPROT_S8      => OPEN,
        HADDR_S9      => OPEN,
        HSIZE_S9      => OPEN,
        HTRANS_S9     => OPEN,
        HWDATA_S9     => OPEN,
        HBURST_S9     => OPEN,
        HPROT_S9      => OPEN,
        HADDR_S10     => OPEN,
        HSIZE_S10     => OPEN,
        HTRANS_S10    => OPEN,
        HWDATA_S10    => OPEN,
        HBURST_S10    => OPEN,
        HPROT_S10     => OPEN,
        HADDR_S11     => OPEN,
        HSIZE_S11     => OPEN,
        HTRANS_S11    => OPEN,
        HWDATA_S11    => OPEN,
        HBURST_S11    => OPEN,
        HPROT_S11     => OPEN,
        HADDR_S12     => OPEN,
        HSIZE_S12     => OPEN,
        HTRANS_S12    => OPEN,
        HWDATA_S12    => OPEN,
        HBURST_S12    => OPEN,
        HPROT_S12     => OPEN,
        HADDR_S13     => OPEN,
        HSIZE_S13     => OPEN,
        HTRANS_S13    => OPEN,
        HWDATA_S13    => OPEN,
        HBURST_S13    => OPEN,
        HPROT_S13     => OPEN,
        HADDR_S14     => OPEN,
        HSIZE_S14     => OPEN,
        HTRANS_S14    => OPEN,
        HWDATA_S14    => OPEN,
        HBURST_S14    => OPEN,
        HPROT_S14     => OPEN,
        HADDR_S15     => OPEN,
        HSIZE_S15     => OPEN,
        HTRANS_S15    => OPEN,
        HWDATA_S15    => OPEN,
        HBURST_S15    => OPEN,
        HPROT_S15     => OPEN,
        HADDR_S16     => OPEN,
        HSIZE_S16     => OPEN,
        HTRANS_S16    => OPEN,
        HWDATA_S16    => OPEN,
        HBURST_S16    => OPEN,
        HPROT_S16     => OPEN 
        );

end RTL;
