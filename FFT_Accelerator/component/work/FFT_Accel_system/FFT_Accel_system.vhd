----------------------------------------------------------------------
-- Created by SmartDesign Mon Apr 13 18:16:16 2020
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
-- CoreAPB3_C0
component CoreAPB3_C0
    -- Port list
    port(
        -- Inputs
        PADDR     : in  std_logic_vector(31 downto 0);
        PENABLE   : in  std_logic;
        PRDATAS0  : in  std_logic_vector(31 downto 0);
        PRDATAS1  : in  std_logic_vector(31 downto 0);
        PREADYS0  : in  std_logic;
        PREADYS1  : in  std_logic;
        PSEL      : in  std_logic;
        PSLVERRS0 : in  std_logic;
        PSLVERRS1 : in  std_logic;
        PWDATA    : in  std_logic_vector(31 downto 0);
        PWRITE    : in  std_logic;
        -- Outputs
        PADDRS    : out std_logic_vector(31 downto 0);
        PENABLES  : out std_logic;
        PRDATA    : out std_logic_vector(31 downto 0);
        PREADY    : out std_logic;
        PSELS0    : out std_logic;
        PSELS1    : out std_logic;
        PSLVERR   : out std_logic;
        PWDATAS   : out std_logic_vector(31 downto 0);
        PWRITES   : out std_logic
        );
end component;
-- FFT_Accel_system_sb
component FFT_Accel_system_sb
    -- Port list
    port(
        -- Inputs
        DEVRST_N            : in  std_logic;
        FAB_RESET_N         : in  std_logic;
        FIC_0_APB_M_PRDATA  : in  std_logic_vector(31 downto 0);
        FIC_0_APB_M_PREADY  : in  std_logic;
        FIC_0_APB_M_PSLVERR : in  std_logic;
        GPIO_10_F2M         : in  std_logic;
        GPIO_11_F2M         : in  std_logic;
        GPIO_12_F2M         : in  std_logic;
        GPIO_13_F2M         : in  std_logic;
        GPIO_14_F2M         : in  std_logic;
        GPIO_15_F2M         : in  std_logic;
        GPIO_8_F2M          : in  std_logic;
        GPIO_9_F2M          : in  std_logic;
        MAC_GMII_COL        : in  std_logic;
        MAC_GMII_CRS        : in  std_logic;
        MAC_GMII_GTX_CLK    : in  std_logic;
        MAC_GMII_MDI        : in  std_logic;
        MAC_GMII_RXD        : in  std_logic_vector(7 downto 0);
        MAC_GMII_RX_CLK     : in  std_logic;
        MAC_GMII_RX_DV      : in  std_logic;
        MAC_GMII_RX_ER      : in  std_logic;
        MAC_GMII_TX_CLK     : in  std_logic;
        MMUART_0_RXD_F2M    : in  std_logic;
        MSS_INT_F2M         : in  std_logic_vector(15 downto 0);
        -- Outputs
        FAB_CCC_GL1         : out std_logic;
        FAB_CCC_LOCK        : out std_logic;
        FIC_0_APB_M_PADDR   : out std_logic_vector(31 downto 0);
        FIC_0_APB_M_PENABLE : out std_logic;
        FIC_0_APB_M_PSEL    : out std_logic;
        FIC_0_APB_M_PWDATA  : out std_logic_vector(31 downto 0);
        FIC_0_APB_M_PWRITE  : out std_logic;
        FIC_0_CLK           : out std_logic;
        FIC_0_LOCK          : out std_logic;
        GPIO_0_M2F          : out std_logic;
        GPIO_1_M2F          : out std_logic;
        GPIO_2_M2F          : out std_logic;
        GPIO_3_M2F          : out std_logic;
        GPIO_4_M2F          : out std_logic;
        GPIO_5_M2F          : out std_logic;
        GPIO_6_M2F          : out std_logic;
        GPIO_7_M2F          : out std_logic;
        INIT_DONE           : out std_logic;
        MAC_GMII_MDC        : out std_logic;
        MAC_GMII_MDO        : out std_logic;
        MAC_GMII_MDO_EN     : out std_logic;
        MAC_GMII_TXD        : out std_logic_vector(7 downto 0);
        MAC_GMII_TX_EN      : out std_logic;
        MAC_GMII_TX_ER      : out std_logic;
        MMUART_0_TXD_M2F    : out std_logic;
        MSS_READY           : out std_logic;
        POWER_ON_RESET_N    : out std_logic
        );
end component;
-- FFT_APB_Wrapper
-- using entity instantiation for component FFT_APB_Wrapper
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
signal Board_Buttons_slice_0                           : std_logic_vector(0 to 0);
signal Board_Buttons_slice_1                           : std_logic_vector(1 to 1);
signal Board_LEDs_net_0                                : std_logic_vector(7 downto 0);
signal CoreAPB3_C0_0_APBmslave0_PENABLE                : std_logic;
signal CoreAPB3_C0_0_APBmslave0_PREADY                 : std_logic;
signal CoreAPB3_C0_0_APBmslave0_PSELx                  : std_logic;
signal CoreAPB3_C0_0_APBmslave0_PSLVERR                : std_logic;
signal CoreAPB3_C0_0_APBmslave0_PWRITE                 : std_logic;
signal ETH_NRESET_net_0                                : std_logic;
signal FFT_Accel_system_sb_0_FAB_CCC_GL1               : std_logic;
signal FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PADDR   : std_logic_vector(31 downto 0);
signal FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PENABLE : std_logic;
signal FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PRDATA  : std_logic_vector(31 downto 0);
signal FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PREADY  : std_logic;
signal FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PSELx   : std_logic;
signal FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PSLVERR : std_logic;
signal FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PWDATA  : std_logic_vector(31 downto 0);
signal FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PWRITE  : std_logic;
signal FFT_Accel_system_sb_0_FIC_0_CLK                 : std_logic;
signal FFT_Accel_system_sb_0_MAC_GMII_MDC              : std_logic;
signal FFT_Accel_system_sb_0_MAC_GMII_MDO              : std_logic;
signal FFT_Accel_system_sb_0_MAC_GMII_MDO_EN           : std_logic;
signal FFT_Accel_system_sb_0_MAC_GMII_TX_EN            : std_logic;
signal FFT_Accel_system_sb_0_MAC_GMII_TX_ER            : std_logic;
signal FFT_Accel_system_sb_0_MAC_GMII_TXD              : std_logic_vector(7 downto 0);
signal FFT_Accel_system_sb_0_MMUART_0_TXD_M2F          : std_logic;
signal FFT_Accel_system_sb_0_MSS_READY                 : std_logic;
signal FFT_APB_Wrapper_0_INT                           : std_logic;
signal GMII_GTX_CLK_net_0                              : std_logic;
signal GMII_MDC_net_0                                  : std_logic;
signal GMII_TX_EN_net_0                                : std_logic;
signal GMII_TX_ER_net_0                                : std_logic;
signal GMII_TXD_net_0                                  : std_logic_vector(7 downto 0);
signal MSS_to_IO_interpreter_0_MAC_GMII_COL            : std_logic;
signal MSS_to_IO_interpreter_0_MAC_GMII_CRS            : std_logic;
signal MSS_to_IO_interpreter_0_MAC_GMII_GTX_CLK        : std_logic;
signal MSS_to_IO_interpreter_0_MAC_GMII_MDI            : std_logic;
signal MSS_to_IO_interpreter_0_MAC_GMII_RX_CLK         : std_logic;
signal MSS_to_IO_interpreter_0_MAC_GMII_RX_DV          : std_logic;
signal MSS_to_IO_interpreter_0_MAC_GMII_RX_ER          : std_logic;
signal MSS_to_IO_interpreter_0_MAC_GMII_RXD            : std_logic_vector(7 downto 0);
signal MSS_to_IO_interpreter_0_MAC_GMII_TX_CLK         : std_logic;
signal MSS_to_IO_interpreter_0_MDINT_MSS_INT_F2M       : std_logic;
signal MSS_to_IO_interpreter_0_MMUART_RXD_F2M          : std_logic;
signal REFCLK_SEL_net_0                                : std_logic_vector(1 downto 0);
signal USB_UART_RXD_net_0                              : std_logic;
signal GMII_TX_ER_net_1                                : std_logic;
signal GMII_TX_EN_net_1                                : std_logic;
signal ETH_NRESET_net_1                                : std_logic;
signal GMII_MDC_net_1                                  : std_logic;
signal GMII_GTX_CLK_net_1                              : std_logic;
signal USB_UART_RXD_net_1                              : std_logic;
signal GMII_TXD_net_1                                  : std_logic_vector(7 downto 0);
signal REFCLK_SEL_net_1                                : std_logic_vector(1 downto 0);
signal Board_LEDs_net_1                                : std_logic_vector(7 downto 0);
signal MSS_INT_F2M_net_0                               : std_logic_vector(15 downto 0);
signal LED_toggles_net_0                               : std_logic_vector(7 downto 0);
----------------------------------------------------------------------
-- TiedOff Signals
----------------------------------------------------------------------
signal VCC_net                                         : std_logic;
signal MSS_INT_F2M_const_net_0                         : std_logic_vector(15 downto 2);
signal GND_net                                         : std_logic;
signal PRDATAS1_const_net_0                            : std_logic_vector(31 downto 0);
----------------------------------------------------------------------
-- Bus Interface Nets Declarations - Unequal Pin Widths
----------------------------------------------------------------------
signal CoreAPB3_C0_0_APBmslave0_PADDR_0_7to0           : std_logic_vector(7 downto 0);
signal CoreAPB3_C0_0_APBmslave0_PADDR_0                : std_logic_vector(7 downto 0);
signal CoreAPB3_C0_0_APBmslave0_PADDR                  : std_logic_vector(31 downto 0);

signal CoreAPB3_C0_0_APBmslave0_PRDATA                 : std_logic_vector(15 downto 0);
signal CoreAPB3_C0_0_APBmslave0_PRDATA_0_31to16        : std_logic_vector(31 downto 16);
signal CoreAPB3_C0_0_APBmslave0_PRDATA_0_15to0         : std_logic_vector(15 downto 0);
signal CoreAPB3_C0_0_APBmslave0_PRDATA_0               : std_logic_vector(31 downto 0);

signal CoreAPB3_C0_0_APBmslave0_PWDATA_0_15to0         : std_logic_vector(15 downto 0);
signal CoreAPB3_C0_0_APBmslave0_PWDATA_0               : std_logic_vector(15 downto 0);
signal CoreAPB3_C0_0_APBmslave0_PWDATA                 : std_logic_vector(31 downto 0);


begin
----------------------------------------------------------------------
-- Constant assignments
----------------------------------------------------------------------
 VCC_net                 <= '1';
 MSS_INT_F2M_const_net_0 <= B"00000000000000";
 GND_net                 <= '0';
 PRDATAS1_const_net_0    <= B"00000000000000000000000000000000";
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
 MSS_INT_F2M_net_0 <= ( B"00000000000000" & FFT_APB_Wrapper_0_INT & MSS_to_IO_interpreter_0_MDINT_MSS_INT_F2M );
 LED_toggles_net_0 <= ( '0' & '0' & '0' & '0' & '0' & '0' & FFT_APB_Wrapper_0_INT & MSS_to_IO_interpreter_0_MDINT_MSS_INT_F2M );
----------------------------------------------------------------------
-- Bus Interface Nets Assignments - Unequal Pin Widths
----------------------------------------------------------------------
 CoreAPB3_C0_0_APBmslave0_PADDR_0_7to0(7 downto 0) <= CoreAPB3_C0_0_APBmslave0_PADDR(7 downto 0);
 CoreAPB3_C0_0_APBmslave0_PADDR_0 <= ( CoreAPB3_C0_0_APBmslave0_PADDR_0_7to0(7 downto 0) );

 CoreAPB3_C0_0_APBmslave0_PRDATA_0_31to16(31 downto 16) <= B"0000000000000000";
 CoreAPB3_C0_0_APBmslave0_PRDATA_0_15to0(15 downto 0) <= CoreAPB3_C0_0_APBmslave0_PRDATA(15 downto 0);
 CoreAPB3_C0_0_APBmslave0_PRDATA_0 <= ( CoreAPB3_C0_0_APBmslave0_PRDATA_0_31to16(31 downto 16) & CoreAPB3_C0_0_APBmslave0_PRDATA_0_15to0(15 downto 0) );

 CoreAPB3_C0_0_APBmslave0_PWDATA_0_15to0(15 downto 0) <= CoreAPB3_C0_0_APBmslave0_PWDATA(15 downto 0);
 CoreAPB3_C0_0_APBmslave0_PWDATA_0 <= ( CoreAPB3_C0_0_APBmslave0_PWDATA_0_15to0(15 downto 0) );

----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- CoreAPB3_C0_0
CoreAPB3_C0_0 : CoreAPB3_C0
    port map( 
        -- Inputs
        PSEL      => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PSELx,
        PENABLE   => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PENABLE,
        PWRITE    => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PWRITE,
        PREADYS0  => CoreAPB3_C0_0_APBmslave0_PREADY,
        PSLVERRS0 => CoreAPB3_C0_0_APBmslave0_PSLVERR,
        PREADYS1  => VCC_net, -- tied to '1' from definition
        PSLVERRS1 => GND_net, -- tied to '0' from definition
        PADDR     => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PADDR,
        PWDATA    => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PWDATA,
        PRDATAS0  => CoreAPB3_C0_0_APBmslave0_PRDATA_0,
        PRDATAS1  => PRDATAS1_const_net_0, -- tied to X"0" from definition
        -- Outputs
        PREADY    => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PREADY,
        PSLVERR   => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PSLVERR,
        PSELS0    => CoreAPB3_C0_0_APBmslave0_PSELx,
        PENABLES  => CoreAPB3_C0_0_APBmslave0_PENABLE,
        PWRITES   => CoreAPB3_C0_0_APBmslave0_PWRITE,
        PSELS1    => OPEN,
        PRDATA    => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PRDATA,
        PADDRS    => CoreAPB3_C0_0_APBmslave0_PADDR,
        PWDATAS   => CoreAPB3_C0_0_APBmslave0_PWDATA 
        );
-- FFT_Accel_system_sb_0
FFT_Accel_system_sb_0 : FFT_Accel_system_sb
    port map( 
        -- Inputs
        FAB_RESET_N         => VCC_net,
        DEVRST_N            => DEVRST_N,
        MSS_INT_F2M         => MSS_INT_F2M_net_0,
        FIC_0_APB_M_PRDATA  => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PRDATA,
        FIC_0_APB_M_PREADY  => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PREADY,
        FIC_0_APB_M_PSLVERR => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PSLVERR,
        MMUART_0_RXD_F2M    => MSS_to_IO_interpreter_0_MMUART_RXD_F2M,
        GPIO_8_F2M          => Board_Buttons_slice_0(0),
        GPIO_9_F2M          => Board_Buttons_slice_1(1),
        GPIO_10_F2M         => GND_net,
        GPIO_11_F2M         => GND_net,
        GPIO_12_F2M         => GND_net,
        GPIO_13_F2M         => GND_net,
        GPIO_14_F2M         => GND_net,
        GPIO_15_F2M         => GND_net,
        MAC_GMII_RX_ER      => MSS_to_IO_interpreter_0_MAC_GMII_RX_ER,
        MAC_GMII_RX_DV      => MSS_to_IO_interpreter_0_MAC_GMII_RX_DV,
        MAC_GMII_CRS        => MSS_to_IO_interpreter_0_MAC_GMII_CRS,
        MAC_GMII_COL        => MSS_to_IO_interpreter_0_MAC_GMII_COL,
        MAC_GMII_RX_CLK     => MSS_to_IO_interpreter_0_MAC_GMII_RX_CLK,
        MAC_GMII_TX_CLK     => MSS_to_IO_interpreter_0_MAC_GMII_TX_CLK,
        MAC_GMII_GTX_CLK    => MSS_to_IO_interpreter_0_MAC_GMII_GTX_CLK,
        MAC_GMII_MDI        => MSS_to_IO_interpreter_0_MAC_GMII_MDI,
        MAC_GMII_RXD        => MSS_to_IO_interpreter_0_MAC_GMII_RXD,
        -- Outputs
        POWER_ON_RESET_N    => OPEN,
        INIT_DONE           => OPEN,
        FIC_0_CLK           => FFT_Accel_system_sb_0_FIC_0_CLK,
        FIC_0_LOCK          => OPEN,
        FAB_CCC_GL1         => FFT_Accel_system_sb_0_FAB_CCC_GL1,
        FAB_CCC_LOCK        => OPEN,
        MSS_READY           => FFT_Accel_system_sb_0_MSS_READY,
        FIC_0_APB_M_PADDR   => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PADDR,
        FIC_0_APB_M_PSEL    => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PSELx,
        FIC_0_APB_M_PENABLE => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PENABLE,
        FIC_0_APB_M_PWRITE  => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PWRITE,
        FIC_0_APB_M_PWDATA  => FFT_Accel_system_sb_0_FIC_0_AMBA_MASTER_PWDATA,
        MMUART_0_TXD_M2F    => FFT_Accel_system_sb_0_MMUART_0_TXD_M2F,
        GPIO_0_M2F          => OPEN,
        GPIO_1_M2F          => OPEN,
        GPIO_2_M2F          => OPEN,
        GPIO_3_M2F          => OPEN,
        GPIO_4_M2F          => OPEN,
        GPIO_5_M2F          => OPEN,
        GPIO_6_M2F          => OPEN,
        GPIO_7_M2F          => OPEN,
        MAC_GMII_TX_EN      => FFT_Accel_system_sb_0_MAC_GMII_TX_EN,
        MAC_GMII_TX_ER      => FFT_Accel_system_sb_0_MAC_GMII_TX_ER,
        MAC_GMII_MDC        => FFT_Accel_system_sb_0_MAC_GMII_MDC,
        MAC_GMII_MDO_EN     => FFT_Accel_system_sb_0_MAC_GMII_MDO_EN,
        MAC_GMII_MDO        => FFT_Accel_system_sb_0_MAC_GMII_MDO,
        MAC_GMII_TXD        => FFT_Accel_system_sb_0_MAC_GMII_TXD 
        );
-- FFT_APB_Wrapper_0
FFT_APB_Wrapper_0 : entity work.FFT_APB_Wrapper
    port map( 
        -- Inputs
        PCLK    => FFT_Accel_system_sb_0_FIC_0_CLK,
        RSTn    => FFT_Accel_system_sb_0_MSS_READY,
        PSEL    => CoreAPB3_C0_0_APBmslave0_PSELx,
        PENABLE => CoreAPB3_C0_0_APBmslave0_PENABLE,
        PWRITE  => CoreAPB3_C0_0_APBmslave0_PWRITE,
        PADDR   => CoreAPB3_C0_0_APBmslave0_PADDR_0,
        PWDATA  => CoreAPB3_C0_0_APBmslave0_PWDATA_0,
        -- Outputs
        PREADY  => CoreAPB3_C0_0_APBmslave0_PREADY,
        PSLVERR => CoreAPB3_C0_0_APBmslave0_PSLVERR,
        INT     => FFT_APB_Wrapper_0_INT,
        PRDATA  => CoreAPB3_C0_0_APBmslave0_PRDATA 
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
        MAC_GMII_RX_ER    => MSS_to_IO_interpreter_0_MAC_GMII_RX_ER,
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
