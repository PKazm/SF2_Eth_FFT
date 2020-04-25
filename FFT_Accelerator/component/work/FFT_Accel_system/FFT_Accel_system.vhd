----------------------------------------------------------------------
-- Created by SmartDesign Tue Apr 21 16:56:03 2020
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
-- FFT_Accel_system entity declaration
----------------------------------------------------------------------
entity FFT_Accel_system is
    -- Port list
    port(
        -- Inputs
        Board_Buttons : in    std_logic_vector(1 downto 0);
        DEVRST_N      : in    std_logic;
        GMII_COL      : in    std_logic;
        GMII_CRS      : in    std_logic;
        GMII_RXD      : in    std_logic_vector(7 downto 0);
        GMII_RX_CLK   : in    std_logic;
        GMII_RX_DV    : in    std_logic;
        GMII_RX_ER    : in    std_logic;
        GMII_TX_CLK   : in    std_logic;
        MDINT         : in    std_logic;
        USB_UART_TXD  : in    std_logic;
        -- Outputs
        Board_LEDs    : out   std_logic_vector(7 downto 0);
        ETH_NRESET    : out   std_logic;
        GMII_GTX_CLK  : out   std_logic;
        GMII_MDC      : out   std_logic;
        GMII_TXD      : out   std_logic_vector(7 downto 0);
        GMII_TX_EN    : out   std_logic;
        GMII_TX_ER    : out   std_logic;
        REFCLK_SEL    : out   std_logic_vector(1 downto 0);
        USB_UART_RXD  : out   std_logic;
        -- Inouts
        COMA_MODE     : inout std_logic;
        GMII_MDIO     : inout std_logic
        );
end FFT_Accel_system;
----------------------------------------------------------------------
-- FFT_Accel_system architecture body
----------------------------------------------------------------------
architecture RTL of FFT_Accel_system is
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
-- CoreAHBLite_C0
component CoreAHBLite_C0
    -- Port list
    port(
        -- Inputs
        HADDR_M0     : in  std_logic_vector(31 downto 0);
        HBURST_M0    : in  std_logic_vector(2 downto 0);
        HCLK         : in  std_logic;
        HMASTLOCK_M0 : in  std_logic;
        HPROT_M0     : in  std_logic_vector(3 downto 0);
        HRDATA_S0    : in  std_logic_vector(31 downto 0);
        HRDATA_S1    : in  std_logic_vector(31 downto 0);
        HREADYOUT_S0 : in  std_logic;
        HREADYOUT_S1 : in  std_logic;
        HRESETN      : in  std_logic;
        HRESP_S0     : in  std_logic_vector(1 downto 0);
        HRESP_S1     : in  std_logic_vector(1 downto 0);
        HSIZE_M0     : in  std_logic_vector(2 downto 0);
        HTRANS_M0    : in  std_logic_vector(1 downto 0);
        HWDATA_M0    : in  std_logic_vector(31 downto 0);
        HWRITE_M0    : in  std_logic;
        REMAP_M0     : in  std_logic;
        -- Outputs
        HADDR_S0     : out std_logic_vector(31 downto 0);
        HADDR_S1     : out std_logic_vector(31 downto 0);
        HBURST_S0    : out std_logic_vector(2 downto 0);
        HBURST_S1    : out std_logic_vector(2 downto 0);
        HMASTLOCK_S0 : out std_logic;
        HMASTLOCK_S1 : out std_logic;
        HPROT_S0     : out std_logic_vector(3 downto 0);
        HPROT_S1     : out std_logic_vector(3 downto 0);
        HRDATA_M0    : out std_logic_vector(31 downto 0);
        HREADY_M0    : out std_logic;
        HREADY_S0    : out std_logic;
        HREADY_S1    : out std_logic;
        HRESP_M0     : out std_logic_vector(1 downto 0);
        HSEL_S0      : out std_logic;
        HSEL_S1      : out std_logic;
        HSIZE_S0     : out std_logic_vector(2 downto 0);
        HSIZE_S1     : out std_logic_vector(2 downto 0);
        HTRANS_S0    : out std_logic_vector(1 downto 0);
        HTRANS_S1    : out std_logic_vector(1 downto 0);
        HWDATA_S0    : out std_logic_vector(31 downto 0);
        HWDATA_S1    : out std_logic_vector(31 downto 0);
        HWRITE_S0    : out std_logic;
        HWRITE_S1    : out std_logic
        );
end component;
-- FFT_Accel_system_sb
component FFT_Accel_system_sb
    -- Port list
    port(
        -- Inputs
        DEVRST_N           : in  std_logic;
        FAB_RESET_N        : in  std_logic;
        FIC_0_AHB_M_HRDATA : in  std_logic_vector(31 downto 0);
        FIC_0_AHB_M_HREADY : in  std_logic;
        FIC_0_AHB_M_HRESP  : in  std_logic;
        GPIO_10_F2M        : in  std_logic;
        GPIO_11_F2M        : in  std_logic;
        GPIO_12_F2M        : in  std_logic;
        GPIO_13_F2M        : in  std_logic;
        GPIO_14_F2M        : in  std_logic;
        GPIO_15_F2M        : in  std_logic;
        GPIO_8_F2M         : in  std_logic;
        GPIO_9_F2M         : in  std_logic;
        MAC_GMII_COL       : in  std_logic;
        MAC_GMII_CRS       : in  std_logic;
        MAC_GMII_GTX_CLK   : in  std_logic;
        MAC_GMII_MDI       : in  std_logic;
        MAC_GMII_RXD       : in  std_logic_vector(7 downto 0);
        MAC_GMII_RX_CLK    : in  std_logic;
        MAC_GMII_RX_DV     : in  std_logic;
        MAC_GMII_RX_ER     : in  std_logic;
        MAC_GMII_TX_CLK    : in  std_logic;
        MMUART_0_RXD_F2M   : in  std_logic;
        MSS_INT_F2M        : in  std_logic_vector(15 downto 0);
        -- Outputs
        FAB_CCC_GL1        : out std_logic;
        FAB_CCC_LOCK       : out std_logic;
        FIC_0_AHB_M_HADDR  : out std_logic_vector(31 downto 0);
        FIC_0_AHB_M_HSIZE  : out std_logic_vector(1 downto 0);
        FIC_0_AHB_M_HTRANS : out std_logic_vector(1 downto 0);
        FIC_0_AHB_M_HWDATA : out std_logic_vector(31 downto 0);
        FIC_0_AHB_M_HWRITE : out std_logic;
        FIC_0_CLK          : out std_logic;
        FIC_0_LOCK         : out std_logic;
        GPIO_0_M2F         : out std_logic;
        GPIO_1_M2F         : out std_logic;
        GPIO_2_M2F         : out std_logic;
        GPIO_3_M2F         : out std_logic;
        GPIO_4_M2F         : out std_logic;
        GPIO_5_M2F         : out std_logic;
        GPIO_6_M2F         : out std_logic;
        GPIO_7_M2F         : out std_logic;
        INIT_DONE          : out std_logic;
        MAC_GMII_MDC       : out std_logic;
        MAC_GMII_MDO       : out std_logic;
        MAC_GMII_MDO_EN    : out std_logic;
        MAC_GMII_TXD       : out std_logic_vector(7 downto 0);
        MAC_GMII_TX_EN     : out std_logic;
        MAC_GMII_TX_ER     : out std_logic;
        MMUART_0_TXD_M2F   : out std_logic;
        MSS_READY          : out std_logic;
        POWER_ON_RESET_N   : out std_logic
        );
end component;
-- FFT_AHB_Wrapper
-- using entity instantiation for component FFT_AHB_Wrapper
-- LED_inverter_dimmer
component LED_inverter_dimmer
    -- Port list
    port(
        -- Inputs
        CLK         : in  std_logic;
        LED_toggles : in  std_logic_vector(7 downto 0);
        -- Outputs
        Board_LEDs  : out std_logic_vector(7 downto 0)
        );
end component;
-- MSS_to_IO_interpreter
component MSS_to_IO_interpreter
    -- Port list
    port(
        -- Inputs
        FLASH_MEM_SDI     : in    std_logic;
        GMII_COL          : in    std_logic;
        GMII_CRS          : in    std_logic;
        GMII_GTX_CLK_125  : in    std_logic;
        GMII_RXD          : in    std_logic_vector(7 downto 0);
        GMII_RX_CLK       : in    std_logic;
        GMII_RX_DV        : in    std_logic;
        GMII_RX_ER        : in    std_logic;
        GMII_TX_CLK       : in    std_logic;
        I2C_SCL_M2F       : in    std_logic;
        I2C_SCL_M2F_OE    : in    std_logic;
        I2C_SDA_M2F       : in    std_logic;
        I2C_SDA_M2F_OE    : in    std_logic;
        MAC_GMII_MDC      : in    std_logic;
        MAC_GMII_MDO      : in    std_logic;
        MAC_GMII_MDO_OE   : in    std_logic;
        MAC_GMII_TXD      : in    std_logic_vector(7 downto 0);
        MAC_GMII_TX_EN    : in    std_logic;
        MAC_GMII_TX_ER    : in    std_logic;
        MDINT             : in    std_logic;
        MMUART_TXD_M2F    : in    std_logic;
        MSS_READY         : in    std_logic;
        SPI_CLK_M2F       : in    std_logic;
        SPI_DO_M2F        : in    std_logic;
        SPI_SSO_M2F       : in    std_logic;
        USB_UART_TXD      : in    std_logic;
        -- Outputs
        ETH_NRESET        : out   std_logic;
        FLASH_MEM_CLK     : out   std_logic;
        FLASH_MEM_SDO     : out   std_logic;
        FLASH_MEM_SSO     : out   std_logic;
        GMII_GTX_CLK      : out   std_logic;
        GMII_MDC          : out   std_logic;
        GMII_TXD          : out   std_logic_vector(7 downto 0);
        GMII_TX_EN        : out   std_logic;
        GMII_TX_ER        : out   std_logic;
        I2C_SCL_F2M       : out   std_logic;
        I2C_SDA_F2M       : out   std_logic;
        MAC_GMII_COL      : out   std_logic;
        MAC_GMII_CRS      : out   std_logic;
        MAC_GMII_GTX_CLK  : out   std_logic;
        MAC_GMII_MDI      : out   std_logic;
        MAC_GMII_RXD      : out   std_logic_vector(7 downto 0);
        MAC_GMII_RX_CLK   : out   std_logic;
        MAC_GMII_RX_DV    : out   std_logic;
        MAC_GMII_RX_ER    : out   std_logic;
        MAC_GMII_TX_CLK   : out   std_logic;
        MDINT_MSS_INT_F2M : out   std_logic;
        MMUART_RXD_F2M    : out   std_logic;
        REFCLK_SEL        : out   std_logic_vector(1 downto 0);
        SPI_DI_F2M        : out   std_logic;
        USB_UART_RXD      : out   std_logic;
        -- Inouts
        COMA_MODE         : inout std_logic;
        GMII_MDIO         : inout std_logic;
        LIGHT_SCL         : inout std_logic;
        LIGHT_SDA         : inout std_logic
        );
end component;
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal Board_Buttons_slice_0                            : std_logic_vector(0 to 0);
signal Board_Buttons_slice_1                            : std_logic_vector(1 to 1);
signal Board_LEDs_net_0                                 : std_logic_vector(7 downto 0);
signal CoreAHBLite_C0_0_AHBmslave0_HBURST               : std_logic_vector(2 downto 0);
signal CoreAHBLite_C0_0_AHBmslave0_HMASTLOCK            : std_logic;
signal CoreAHBLite_C0_0_AHBmslave0_HPROT                : std_logic_vector(3 downto 0);
signal CoreAHBLite_C0_0_AHBmslave0_HREADY               : std_logic;
signal CoreAHBLite_C0_0_AHBmslave0_HREADYOUT            : std_logic;
signal CoreAHBLite_C0_0_AHBmslave0_HRESP                : std_logic_vector(1 downto 0);
signal CoreAHBLite_C0_0_AHBmslave0_HSELx                : std_logic;
signal CoreAHBLite_C0_0_AHBmslave0_HSIZE                : std_logic_vector(2 downto 0);
signal CoreAHBLite_C0_0_AHBmslave0_HTRANS               : std_logic_vector(1 downto 0);
signal CoreAHBLite_C0_0_AHBmslave0_HWRITE               : std_logic;
signal ETH_NRESET_net_0                                 : std_logic;
signal FFT_Accel_system_sb_0_FAB_CCC_GL1                : std_logic;
signal FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HADDR  : std_logic_vector(31 downto 0);
signal FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HRDATA : std_logic_vector(31 downto 0);
signal FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HREADY : std_logic;
signal FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HTRANS : std_logic_vector(1 downto 0);
signal FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HWDATA : std_logic_vector(31 downto 0);
signal FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HWRITE : std_logic;
signal FFT_Accel_system_sb_0_FIC_0_CLK                  : std_logic;
signal FFT_Accel_system_sb_0_MAC_GMII_MDC               : std_logic;
signal FFT_Accel_system_sb_0_MAC_GMII_MDO               : std_logic;
signal FFT_Accel_system_sb_0_MAC_GMII_MDO_EN            : std_logic;
signal FFT_Accel_system_sb_0_MAC_GMII_TX_EN             : std_logic;
signal FFT_Accel_system_sb_0_MAC_GMII_TX_ER             : std_logic;
signal FFT_Accel_system_sb_0_MAC_GMII_TXD               : std_logic_vector(7 downto 0);
signal FFT_Accel_system_sb_0_MMUART_0_TXD_M2F           : std_logic;
signal FFT_Accel_system_sb_0_MSS_READY                  : std_logic;
signal FFT_AHB_Wrapper_0_INT                            : std_logic;
signal GMII_GTX_CLK_net_0                               : std_logic;
signal GMII_MDC_net_0                                   : std_logic;
signal GMII_TX_EN_net_0                                 : std_logic;
signal GMII_TX_ER_net_0                                 : std_logic;
signal GMII_TXD_net_0                                   : std_logic_vector(7 downto 0);
signal MSS_to_IO_interpreter_0_MAC_GMII_COL             : std_logic;
signal MSS_to_IO_interpreter_0_MAC_GMII_CRS             : std_logic;
signal MSS_to_IO_interpreter_0_MAC_GMII_GTX_CLK         : std_logic;
signal MSS_to_IO_interpreter_0_MAC_GMII_MDI             : std_logic;
signal MSS_to_IO_interpreter_0_MAC_GMII_RX_CLK          : std_logic;
signal MSS_to_IO_interpreter_0_MAC_GMII_RX_DV           : std_logic;
signal MSS_to_IO_interpreter_0_MAC_GMII_RX_ER_0         : std_logic;
signal MSS_to_IO_interpreter_0_MAC_GMII_RXD             : std_logic_vector(7 downto 0);
signal MSS_to_IO_interpreter_0_MAC_GMII_TX_CLK          : std_logic;
signal MSS_to_IO_interpreter_0_MDINT_MSS_INT_F2M        : std_logic;
signal MSS_to_IO_interpreter_0_MMUART_RXD_F2M           : std_logic;
signal REFCLK_SEL_net_0                                 : std_logic_vector(1 downto 0);
signal USB_UART_RXD_net_0                               : std_logic;
signal GMII_TX_ER_net_1                                 : std_logic;
signal GMII_TX_EN_net_1                                 : std_logic;
signal ETH_NRESET_net_1                                 : std_logic;
signal GMII_MDC_net_1                                   : std_logic;
signal GMII_GTX_CLK_net_1                               : std_logic;
signal USB_UART_RXD_net_1                               : std_logic;
signal GMII_TXD_net_1                                   : std_logic_vector(7 downto 0);
signal REFCLK_SEL_net_1                                 : std_logic_vector(1 downto 0);
signal Board_LEDs_net_1                                 : std_logic_vector(7 downto 0);
signal MSS_INT_F2M_net_0                                : std_logic_vector(15 downto 0);
signal LED_toggles_net_0                                : std_logic_vector(7 downto 0);
----------------------------------------------------------------------
-- TiedOff Signals
----------------------------------------------------------------------
signal GND_net                                          : std_logic;
signal VCC_net                                          : std_logic;
signal MSS_INT_F2M_const_net_0                          : std_logic_vector(15 downto 2);
signal HBURST_M0_const_net_0                            : std_logic_vector(2 downto 0);
signal HPROT_M0_const_net_0                             : std_logic_vector(3 downto 0);
signal HRDATA_S1_const_net_0                            : std_logic_vector(31 downto 0);
signal HRESP_S1_const_net_0                             : std_logic_vector(1 downto 0);
----------------------------------------------------------------------
-- Bus Interface Nets Declarations - Unequal Pin Widths
----------------------------------------------------------------------
signal CoreAHBLite_C0_0_AHBmslave0_HADDR_0_7to0         : std_logic_vector(7 downto 0);
signal CoreAHBLite_C0_0_AHBmslave0_HADDR_0              : std_logic_vector(7 downto 0);
signal CoreAHBLite_C0_0_AHBmslave0_HADDR                : std_logic_vector(31 downto 0);

signal CoreAHBLite_C0_0_AHBmslave0_HRDATA               : std_logic_vector(15 downto 0);
signal CoreAHBLite_C0_0_AHBmslave0_HRDATA_0_31to16      : std_logic_vector(31 downto 16);
signal CoreAHBLite_C0_0_AHBmslave0_HRDATA_0_15to0       : std_logic_vector(15 downto 0);
signal CoreAHBLite_C0_0_AHBmslave0_HRDATA_0             : std_logic_vector(31 downto 0);

signal CoreAHBLite_C0_0_AHBmslave0_HWDATA_0_15to0       : std_logic_vector(15 downto 0);
signal CoreAHBLite_C0_0_AHBmslave0_HWDATA_0             : std_logic_vector(15 downto 0);
signal CoreAHBLite_C0_0_AHBmslave0_HWDATA               : std_logic_vector(31 downto 0);

signal FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HRESP  : std_logic_vector(1 downto 0);
signal FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HRESP_0_0to0: std_logic_vector(0 to 0);
signal FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HRESP_0: std_logic;

signal FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HSIZE  : std_logic_vector(1 downto 0);
signal FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HSIZE_0_2to2: std_logic_vector(2 to 2);
signal FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HSIZE_0_1to0: std_logic_vector(1 downto 0);
signal FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HSIZE_0: std_logic_vector(2 downto 0);


begin
----------------------------------------------------------------------
-- Constant assignments
----------------------------------------------------------------------
 GND_net                 <= '0';
 VCC_net                 <= '1';
 MSS_INT_F2M_const_net_0 <= B"00000000000000";
 HBURST_M0_const_net_0   <= B"000";
 HPROT_M0_const_net_0    <= B"0000";
 HRDATA_S1_const_net_0   <= B"00000000000000000000000000000000";
 HRESP_S1_const_net_0    <= B"00";
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 GMII_TX_ER_net_1       <= GMII_TX_ER_net_0;
 GMII_TX_ER             <= GMII_TX_ER_net_1;
 GMII_TX_EN_net_1       <= GMII_TX_EN_net_0;
 GMII_TX_EN             <= GMII_TX_EN_net_1;
 ETH_NRESET_net_1       <= ETH_NRESET_net_0;
 ETH_NRESET             <= ETH_NRESET_net_1;
 GMII_MDC_net_1         <= GMII_MDC_net_0;
 GMII_MDC               <= GMII_MDC_net_1;
 GMII_GTX_CLK_net_1     <= GMII_GTX_CLK_net_0;
 GMII_GTX_CLK           <= GMII_GTX_CLK_net_1;
 USB_UART_RXD_net_1     <= USB_UART_RXD_net_0;
 USB_UART_RXD           <= USB_UART_RXD_net_1;
 GMII_TXD_net_1         <= GMII_TXD_net_0;
 GMII_TXD(7 downto 0)   <= GMII_TXD_net_1;
 REFCLK_SEL_net_1       <= REFCLK_SEL_net_0;
 REFCLK_SEL(1 downto 0) <= REFCLK_SEL_net_1;
 Board_LEDs_net_1       <= Board_LEDs_net_0;
 Board_LEDs(7 downto 0) <= Board_LEDs_net_1;
----------------------------------------------------------------------
-- Slices assignments
----------------------------------------------------------------------
 Board_Buttons_slice_0(0) <= Board_Buttons(0);
 Board_Buttons_slice_1(1) <= Board_Buttons(1);
----------------------------------------------------------------------
-- Concatenation assignments
----------------------------------------------------------------------
 MSS_INT_F2M_net_0 <= ( B"00000000000000" & FFT_AHB_Wrapper_0_INT & MSS_to_IO_interpreter_0_MDINT_MSS_INT_F2M );
 LED_toggles_net_0 <= ( '0' & '0' & '0' & '0' & '0' & '0' & FFT_AHB_Wrapper_0_INT & MSS_to_IO_interpreter_0_MDINT_MSS_INT_F2M );
----------------------------------------------------------------------
-- Bus Interface Nets Assignments - Unequal Pin Widths
----------------------------------------------------------------------
 CoreAHBLite_C0_0_AHBmslave0_HADDR_0_7to0(7 downto 0) <= CoreAHBLite_C0_0_AHBmslave0_HADDR(7 downto 0);
 CoreAHBLite_C0_0_AHBmslave0_HADDR_0 <= ( CoreAHBLite_C0_0_AHBmslave0_HADDR_0_7to0(7 downto 0) );

 CoreAHBLite_C0_0_AHBmslave0_HRDATA_0_31to16(31 downto 16) <= B"0000000000000000";
 CoreAHBLite_C0_0_AHBmslave0_HRDATA_0_15to0(15 downto 0) <= CoreAHBLite_C0_0_AHBmslave0_HRDATA(15 downto 0);
 CoreAHBLite_C0_0_AHBmslave0_HRDATA_0 <= ( CoreAHBLite_C0_0_AHBmslave0_HRDATA_0_31to16(31 downto 16) & CoreAHBLite_C0_0_AHBmslave0_HRDATA_0_15to0(15 downto 0) );

 CoreAHBLite_C0_0_AHBmslave0_HWDATA_0_15to0(15 downto 0) <= CoreAHBLite_C0_0_AHBmslave0_HWDATA(15 downto 0);
 CoreAHBLite_C0_0_AHBmslave0_HWDATA_0 <= ( CoreAHBLite_C0_0_AHBmslave0_HWDATA_0_15to0(15 downto 0) );

 FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HRESP_0_0to0(0) <= FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HRESP(0);
 FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HRESP_0 <= ( FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HRESP_0_0to0(0) );

 FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HSIZE_0_2to2(2) <= '0';
 FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HSIZE_0_1to0(1 downto 0) <= FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HSIZE(1 downto 0);
 FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HSIZE_0 <= ( FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HSIZE_0_2to2(2) & FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HSIZE_0_1to0(1 downto 0) );

----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- CoreAHBLite_C0_0
CoreAHBLite_C0_0 : CoreAHBLite_C0
    port map( 
        -- Inputs
        HCLK         => FFT_Accel_system_sb_0_FIC_0_CLK,
        HRESETN      => FFT_Accel_system_sb_0_MSS_READY,
        REMAP_M0     => GND_net,
        HADDR_M0     => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HADDR,
        HTRANS_M0    => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HTRANS,
        HWRITE_M0    => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HWRITE,
        HSIZE_M0     => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HSIZE_0,
        HBURST_M0    => HBURST_M0_const_net_0, -- tied to X"0" from definition
        HPROT_M0     => HPROT_M0_const_net_0, -- tied to X"0" from definition
        HWDATA_M0    => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HWDATA,
        HMASTLOCK_M0 => GND_net, -- tied to '0' from definition
        HRDATA_S0    => CoreAHBLite_C0_0_AHBmslave0_HRDATA_0,
        HREADYOUT_S0 => CoreAHBLite_C0_0_AHBmslave0_HREADYOUT,
        HRESP_S0     => CoreAHBLite_C0_0_AHBmslave0_HRESP,
        HRDATA_S1    => HRDATA_S1_const_net_0, -- tied to X"0" from definition
        HREADYOUT_S1 => VCC_net, -- tied to '1' from definition
        HRESP_S1     => HRESP_S1_const_net_0, -- tied to X"0" from definition
        -- Outputs
        HRDATA_M0    => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HRDATA,
        HREADY_M0    => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HREADY,
        HRESP_M0     => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HRESP,
        HADDR_S0     => CoreAHBLite_C0_0_AHBmslave0_HADDR,
        HTRANS_S0    => CoreAHBLite_C0_0_AHBmslave0_HTRANS,
        HWRITE_S0    => CoreAHBLite_C0_0_AHBmslave0_HWRITE,
        HSIZE_S0     => CoreAHBLite_C0_0_AHBmslave0_HSIZE,
        HWDATA_S0    => CoreAHBLite_C0_0_AHBmslave0_HWDATA,
        HSEL_S0      => CoreAHBLite_C0_0_AHBmslave0_HSELx,
        HREADY_S0    => CoreAHBLite_C0_0_AHBmslave0_HREADY,
        HMASTLOCK_S0 => CoreAHBLite_C0_0_AHBmslave0_HMASTLOCK,
        HBURST_S0    => CoreAHBLite_C0_0_AHBmslave0_HBURST,
        HPROT_S0     => CoreAHBLite_C0_0_AHBmslave0_HPROT,
        HADDR_S1     => OPEN,
        HTRANS_S1    => OPEN,
        HWRITE_S1    => OPEN,
        HSIZE_S1     => OPEN,
        HWDATA_S1    => OPEN,
        HSEL_S1      => OPEN,
        HREADY_S1    => OPEN,
        HMASTLOCK_S1 => OPEN,
        HBURST_S1    => OPEN,
        HPROT_S1     => OPEN 
        );
-- FFT_Accel_system_sb_0
FFT_Accel_system_sb_0 : FFT_Accel_system_sb
    port map( 
        -- Inputs
        FAB_RESET_N        => VCC_net,
        DEVRST_N           => DEVRST_N,
        FIC_0_AHB_M_HREADY => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HREADY,
        FIC_0_AHB_M_HRESP  => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HRESP_0,
        MMUART_0_RXD_F2M   => MSS_to_IO_interpreter_0_MMUART_RXD_F2M,
        GPIO_8_F2M         => Board_Buttons_slice_0(0),
        GPIO_9_F2M         => Board_Buttons_slice_1(1),
        GPIO_10_F2M        => GND_net,
        GPIO_11_F2M        => GND_net,
        GPIO_12_F2M        => GND_net,
        GPIO_13_F2M        => GND_net,
        GPIO_14_F2M        => GND_net,
        GPIO_15_F2M        => GND_net,
        MAC_GMII_RX_ER     => MSS_to_IO_interpreter_0_MAC_GMII_RX_ER_0,
        MAC_GMII_RX_DV     => MSS_to_IO_interpreter_0_MAC_GMII_RX_DV,
        MAC_GMII_CRS       => MSS_to_IO_interpreter_0_MAC_GMII_CRS,
        MAC_GMII_COL       => MSS_to_IO_interpreter_0_MAC_GMII_COL,
        MAC_GMII_RX_CLK    => MSS_to_IO_interpreter_0_MAC_GMII_RX_CLK,
        MAC_GMII_TX_CLK    => MSS_to_IO_interpreter_0_MAC_GMII_TX_CLK,
        MAC_GMII_GTX_CLK   => MSS_to_IO_interpreter_0_MAC_GMII_GTX_CLK,
        MAC_GMII_MDI       => MSS_to_IO_interpreter_0_MAC_GMII_MDI,
        MSS_INT_F2M        => MSS_INT_F2M_net_0,
        FIC_0_AHB_M_HRDATA => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HRDATA,
        MAC_GMII_RXD       => MSS_to_IO_interpreter_0_MAC_GMII_RXD,
        -- Outputs
        POWER_ON_RESET_N   => OPEN,
        INIT_DONE          => OPEN,
        FIC_0_CLK          => FFT_Accel_system_sb_0_FIC_0_CLK,
        FIC_0_LOCK         => OPEN,
        FAB_CCC_GL1        => FFT_Accel_system_sb_0_FAB_CCC_GL1,
        FAB_CCC_LOCK       => OPEN,
        MSS_READY          => FFT_Accel_system_sb_0_MSS_READY,
        FIC_0_AHB_M_HWRITE => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HWRITE,
        MMUART_0_TXD_M2F   => FFT_Accel_system_sb_0_MMUART_0_TXD_M2F,
        GPIO_0_M2F         => OPEN,
        GPIO_1_M2F         => OPEN,
        GPIO_2_M2F         => OPEN,
        GPIO_3_M2F         => OPEN,
        GPIO_4_M2F         => OPEN,
        GPIO_5_M2F         => OPEN,
        GPIO_6_M2F         => OPEN,
        GPIO_7_M2F         => OPEN,
        MAC_GMII_TX_EN     => FFT_Accel_system_sb_0_MAC_GMII_TX_EN,
        MAC_GMII_TX_ER     => FFT_Accel_system_sb_0_MAC_GMII_TX_ER,
        MAC_GMII_MDC       => FFT_Accel_system_sb_0_MAC_GMII_MDC,
        MAC_GMII_MDO_EN    => FFT_Accel_system_sb_0_MAC_GMII_MDO_EN,
        MAC_GMII_MDO       => FFT_Accel_system_sb_0_MAC_GMII_MDO,
        FIC_0_AHB_M_HADDR  => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HADDR,
        FIC_0_AHB_M_HTRANS => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HTRANS,
        FIC_0_AHB_M_HSIZE  => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HSIZE,
        FIC_0_AHB_M_HWDATA => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_0_HWDATA,
        MAC_GMII_TXD       => FFT_Accel_system_sb_0_MAC_GMII_TXD 
        );
-- FFT_AHB_Wrapper_0
FFT_AHB_Wrapper_0 : entity work.FFT_AHB_Wrapper
    port map( 
        -- Inputs
        CLK       => FFT_Accel_system_sb_0_FIC_0_CLK,
        RSTn      => FFT_Accel_system_sb_0_MSS_READY,
        HWRITE    => CoreAHBLite_C0_0_AHBmslave0_HWRITE,
        HSEL      => CoreAHBLite_C0_0_AHBmslave0_HSELx,
        HMASTLOCK => CoreAHBLite_C0_0_AHBmslave0_HMASTLOCK,
        HREADYIN  => CoreAHBLite_C0_0_AHBmslave0_HREADY,
        HADDR     => CoreAHBLite_C0_0_AHBmslave0_HADDR_0,
        HWDATA    => CoreAHBLite_C0_0_AHBmslave0_HWDATA_0,
        HSIZE     => CoreAHBLite_C0_0_AHBmslave0_HSIZE,
        HTRANS    => CoreAHBLite_C0_0_AHBmslave0_HTRANS,
        HBURST    => CoreAHBLite_C0_0_AHBmslave0_HBURST,
        HPROT     => CoreAHBLite_C0_0_AHBmslave0_HPROT,
        -- Outputs
        HREADYOUT => CoreAHBLite_C0_0_AHBmslave0_HREADYOUT,
        INT       => FFT_AHB_Wrapper_0_INT,
        HRDATA    => CoreAHBLite_C0_0_AHBmslave0_HRDATA,
        HRESP     => CoreAHBLite_C0_0_AHBmslave0_HRESP 
        );
-- LED_inverter_dimmer_0
LED_inverter_dimmer_0 : LED_inverter_dimmer
    port map( 
        -- Inputs
        CLK         => GND_net,
        LED_toggles => LED_toggles_net_0,
        -- Outputs
        Board_LEDs  => Board_LEDs_net_0 
        );
-- MSS_to_IO_interpreter_0
MSS_to_IO_interpreter_0 : MSS_to_IO_interpreter
    port map( 
        -- Inputs
        MSS_READY         => FFT_Accel_system_sb_0_MSS_READY,
        SPI_CLK_M2F       => GND_net,
        SPI_DO_M2F        => GND_net,
        SPI_SSO_M2F       => GND_net,
        MMUART_TXD_M2F    => FFT_Accel_system_sb_0_MMUART_0_TXD_M2F,
        I2C_SCL_M2F       => GND_net,
        I2C_SCL_M2F_OE    => GND_net,
        I2C_SDA_M2F       => GND_net,
        I2C_SDA_M2F_OE    => GND_net,
        GMII_GTX_CLK_125  => FFT_Accel_system_sb_0_FAB_CCC_GL1,
        MAC_GMII_MDC      => FFT_Accel_system_sb_0_MAC_GMII_MDC,
        MAC_GMII_MDO      => FFT_Accel_system_sb_0_MAC_GMII_MDO,
        MAC_GMII_MDO_OE   => FFT_Accel_system_sb_0_MAC_GMII_MDO_EN,
        MAC_GMII_TX_EN    => FFT_Accel_system_sb_0_MAC_GMII_TX_EN,
        MAC_GMII_TX_ER    => FFT_Accel_system_sb_0_MAC_GMII_TX_ER,
        FLASH_MEM_SDI     => GND_net,
        USB_UART_TXD      => USB_UART_TXD,
        MDINT             => MDINT,
        GMII_COL          => GMII_COL,
        GMII_CRS          => GMII_CRS,
        GMII_RX_CLK       => GMII_RX_CLK,
        GMII_RX_DV        => GMII_RX_DV,
        GMII_RX_ER        => GMII_RX_ER,
        GMII_TX_CLK       => GMII_TX_CLK,
        MAC_GMII_TXD      => FFT_Accel_system_sb_0_MAC_GMII_TXD,
        GMII_RXD          => GMII_RXD,
        -- Outputs
        SPI_DI_F2M        => OPEN,
        MMUART_RXD_F2M    => MSS_to_IO_interpreter_0_MMUART_RXD_F2M,
        I2C_SCL_F2M       => OPEN,
        I2C_SDA_F2M       => OPEN,
        MDINT_MSS_INT_F2M => MSS_to_IO_interpreter_0_MDINT_MSS_INT_F2M,
        MAC_GMII_COL      => MSS_to_IO_interpreter_0_MAC_GMII_COL,
        MAC_GMII_CRS      => MSS_to_IO_interpreter_0_MAC_GMII_CRS,
        MAC_GMII_GTX_CLK  => MSS_to_IO_interpreter_0_MAC_GMII_GTX_CLK,
        MAC_GMII_MDI      => MSS_to_IO_interpreter_0_MAC_GMII_MDI,
        MAC_GMII_RX_CLK   => MSS_to_IO_interpreter_0_MAC_GMII_RX_CLK,
        MAC_GMII_RX_DV    => MSS_to_IO_interpreter_0_MAC_GMII_RX_DV,
        MAC_GMII_RX_ER    => MSS_to_IO_interpreter_0_MAC_GMII_RX_ER_0,
        MAC_GMII_TX_CLK   => MSS_to_IO_interpreter_0_MAC_GMII_TX_CLK,
        FLASH_MEM_CLK     => OPEN,
        FLASH_MEM_SDO     => OPEN,
        FLASH_MEM_SSO     => OPEN,
        USB_UART_RXD      => USB_UART_RXD_net_0,
        ETH_NRESET        => ETH_NRESET_net_0,
        GMII_GTX_CLK      => GMII_GTX_CLK_net_0,
        GMII_MDC          => GMII_MDC_net_0,
        GMII_TX_EN        => GMII_TX_EN_net_0,
        GMII_TX_ER        => GMII_TX_ER_net_0,
        MAC_GMII_RXD      => MSS_to_IO_interpreter_0_MAC_GMII_RXD,
        REFCLK_SEL        => REFCLK_SEL_net_0,
        GMII_TXD          => GMII_TXD_net_0,
        -- Inouts
        LIGHT_SCL         => GND_net,
        LIGHT_SDA         => GND_net,
        COMA_MODE         => COMA_MODE,
        GMII_MDIO         => GMII_MDIO 
        );

end RTL;
