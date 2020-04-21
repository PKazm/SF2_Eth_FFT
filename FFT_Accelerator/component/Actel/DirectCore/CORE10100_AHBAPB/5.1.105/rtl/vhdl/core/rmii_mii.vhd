library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;

-- ********************************************************************/ 
-- Actel Corporation Proprietary and Confidential
-- Copyright 2013 Actel Corporation.  All rights reserved.
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED 
-- IN ADVANCE IN WRITING.  
--  
-- Description: RMII to MII interface
--                     
--
-- Revision Information:
-- Date     Description
-- 18Oct07  Initial Release 
--
-- SVN Revision Information:
-- SVN $Revision: 2622 $
-- SVN $Date $
--
-- Resolved SARs
-- SAR      Date     Who   Description
-- 77068    05/25/2008 PS   Added the fix for the dribble error & suspected crc error from Hari;
--                          Also replaced CLK_TX_RX clocked circuit with CLK_TX_RX_ENB ("sync RX RMII signals to MII interface");
-- 77068    06/03/2008 PS   Added the 2nd fix for the dribble error & suspected crc error from Hari;
--                          This has been verified by WIPRO.
-- Notes: 
--        
-- *********************************************************************/
entity RMII_MII is
   port (
      
      -- Ports declaration
      RMII_CLK         : in std_logic;		-- REF. 50 Mhz clock
      RESETN           : in std_logic;		-- active low reset for RMII clock domain
      -- Carrier Sense/receive data valid
      SPEED            : in std_logic;		-- when 0, 10 Mb/s is selected; when 1, 100 Mb/s is selected
      CRS_DV           : in std_logic;
      RX_ER            : in std_logic;		-- PHY detected error from PHY
      RXD              : in std_logic_vector(1 downto 0);		-- receive data from PHY
      TXD              : out std_logic_vector(1 downto 0);		-- transmit data to PHY
      TX_EN            : out std_logic;		-- Transmit enable to PHY
      CLK_TX_RX        : out std_logic;		-- Transmit Clock and Receive Clock
      MII_TX_EN        : in std_logic;		-- Transmit enable to MAC
      MII_TXD          : in std_logic_vector(3 downto 0);		-- transmit data to MAC
      RX_DV            : out std_logic;		-- Receive data valid signal
      MII_RX_ER        : out std_logic;		-- PHY detected error to MAC
      MII_RXD          : out std_logic_vector(3 downto 0);		-- receive data to MAC
      CRS              : out std_logic;		-- Carrier Sense
      COL              : out std_logic		-- Collision detected
   );
end entity RMII_MII;

architecture trans of RMII_MII is
   
   -- State machine parameters 
   constant state0             : std_logic_vector(2 downto 0) := "000";
   constant state1             : std_logic_vector(2 downto 0) := "001";
   constant state2             : std_logic_vector(2 downto 0) := "010";
   constant state3             : std_logic_vector(2 downto 0) := "011";
   constant state4             : std_logic_vector(2 downto 0) := "100";
   constant state5             : std_logic_vector(2 downto 0) := "101";
   constant state6             : std_logic_vector(2 downto 0) := "110";
   constant state7             : std_logic_vector(2 downto 0) := "111";
   
   signal clktr                : std_logic;
   signal RMII_RX_DV           : std_logic;		-- Receive data valid signal
   signal RMII_RX_DV_reg       : std_logic;		-- Receive data valid signal
   signal RMII_RX_DV_0         : std_logic;		-- Receive data valid signal
   signal RMII_RX_DV_1         : std_logic;		-- Receive data valid signal
   signal RMII_RX_DV_2         : std_logic;		-- Receive data valid signal
   signal RMII_RX_DV_3         : std_logic;		-- Receive data valid signal
   signal RMII_CRS             : std_logic;		-- Carrier Sense
   signal RMII_CRS_0           : std_logic;		-- Receive data valid signal
   signal RMII_CRS_1           : std_logic;		-- Receive data valid signal
   signal RMII_CRS_2           : std_logic;		-- Receive data valid signal
   signal RMII_CRS_3           : std_logic;		-- Receive data valid signal
   signal RMII_CRS_reg         : std_logic;		-- Carrier Sense
   signal RX_ER_reg0           : std_logic;		-- PHY detected error from PHY
   signal RX_ER_reg1           : std_logic;		-- PHY detected error from PHY
   signal MII_RX_ER_reg0       : std_logic;		-- PHY detected error from PHY
   -- PHY detected error from PHY
   signal RX_ER_flag           : std_logic;		-- PHY detected error from PHY flag
   signal clk_2pt5             : std_logic;
   signal clk_25               : std_logic;
   signal clk_25_next          : std_logic;
   signal clk_2pt5_next        : std_logic;
   -- Transmit Clock and Receive Clock
   signal CRS_DV_reg           : std_logic;
   signal rate_cnt             : std_logic_vector(3 downto 0);
   signal count                : std_logic_vector(3 downto 0);
   signal count_next           : std_logic_vector(3 downto 0);
   signal fifo_present_state   : std_logic_vector(2 downto 0);
   signal fifo_next_state      : std_logic_vector(2 downto 0);
   -- transmit data to MAC
   signal TXD_sync0            : std_logic_vector(3 downto 0);		-- transmit data to MAC
   signal TXD_sync1            : std_logic_vector(3 downto 0);		-- transmit data to MAC
   signal TX_EN_sync0          : std_logic;		-- transmit data to MAC Enable RMII interface register
   signal TX_EN_sync1          : std_logic;		-- transmit data to MAC Enable RMII interface register
   -- transmit data to MAC Enable
   signal tx_data_en           : std_logic;		-- rmii tx enable to ping pong data
   signal rx_data_en           : std_logic;		-- rmii rx enable to ping pong data
   signal RXD_reg0             : std_logic_vector(1 downto 0);
   signal RXD_reg1             : std_logic_vector(1 downto 0);
   signal RXD_reg2             : std_logic_vector(1 downto 0);
   signal RXD_reg3             : std_logic_vector(1 downto 0);
   signal RMII_RXD             : std_logic_vector(3 downto 0);
   signal RMII_RXD_reg         : std_logic_vector(3 downto 0);
   signal RMII_RXD_reg0        : std_logic_vector(3 downto 0);
   signal RMII_RXD_reg1        : std_logic_vector(3 downto 0);
   signal RMII_RXD_reg2        : std_logic_vector(3 downto 0);
   signal RMII_RXD_reg3        : std_logic_vector(3 downto 0);
   signal RX_DV_EN             : std_logic;
   signal phase_en             : std_logic;
   signal phase_en_int         : std_logic;
   signal phase_en_reg         : std_logic;
   signal RX_DV_reg            : std_logic;
   signal CRS_reg              : std_logic;
   signal rx_dv_count          : std_logic_vector(4 downto 0);
   signal tx_count             : std_logic_vector(3 downto 0);
   signal MII_RX_ER0           : std_logic;
   signal RMRESETN             : std_logic;
   
   signal preamble_count_next  : std_logic_vector(31 downto 0);
   signal preamble_count       : std_logic_vector(31 downto 0);
   signal preamble_en          : std_logic;
   signal pream_ok             : std_logic;
   signal pream_ok_reg         : std_logic;
   signal SPEED_SYNC           : std_logic;
   signal SPEED_META           : std_logic;
  

   signal MII_RXD_int          : std_logic_vector(3 downto 0);

   -- Declare intermediate signals for referenced outputs
   signal TXD_xhdl4            : std_logic_vector(1 downto 0);
   signal TX_EN_xhdl5          : std_logic;
   signal CLK_TX_RX_xhdl0      : std_logic;
   ---------------------------------------------------------------------------
-- should be assigned to global clock network
	attribute syn_maxfan			: integer;
	attribute syn_maxfan of CLK_TX_RX_xhdl0	: signal is 1000;
---------------------------------------------------------------------------
	attribute syn_keep			: boolean;
	attribute syn_keep of CLK_TX_RX_xhdl0	: signal is true;
---------------------------------------------------------------------------
   signal RX_DV_xhdl3          : std_logic;
   signal MII_RX_ER_xhdl2      : std_logic;
   signal CRS_xhdl1            : std_logic;
begin
   -- Drive referenced outputs
   TXD <= TXD_xhdl4;
   TX_EN <= TX_EN_xhdl5;
   CLK_TX_RX <= CLK_TX_RX_xhdl0;
   RX_DV <= RX_DV_xhdl3;
   MII_RX_ER <= MII_RX_ER_xhdl2;
   CRS <= CRS_xhdl1;
   clktr <= clk_25 when (SPEED_SYNC = '1') else		-- generation of CLKT and CLKR
            clk_2pt5;
   COL <= MII_TX_EN and CRS_xhdl1;		-- generation of COL
  
   MII_RXD <= MII_RXD_int;
   -- Counters to generate sampling for 25 MHz and 2.5 MHz frequencies
   -- Generation of 2.5MHz and 25MHz clocks	
   process (rate_cnt, SPEED_SYNC, clk_25, clk_2pt5)
   begin
      clk_25_next <= clk_25;
      clk_2pt5_next <= clk_2pt5;
      case SPEED_SYNC is
         -- selects the 10 Mbits/sec rate for 2.5 MHz frequency
         when '0' =>
            if (rate_cnt = "1001") then
               clk_2pt5_next <= not(clk_2pt5);
            end if;
         -- selects the 100 Mbits/sec rate for 25 MHz frequency
         when '1' =>
            clk_25_next <= not(clk_25);
         when others => 
            clk_25_next <= not(clk_25);
      end case;
   end process;
   
   
   -- counter
   process (RMII_CLK, RMRESETN)
   begin
      if (RMRESETN = '0') then
         rate_cnt <= "0000";
         clk_2pt5 <= '0';
         clk_25 <= '0';
         SPEED_SYNC <= '0';
         SPEED_META <= '0';
      elsif (RMII_CLK'event and RMII_CLK = '1') then
         SPEED_META <= SPEED;
         SPEED_SYNC <= SPEED_META;
         clk_25 <= clk_25_next;
         clk_2pt5 <= clk_2pt5_next;
         rate_cnt <= rate_cnt + "0001";
         case SPEED_SYNC is
            --  10 Mbits/sec rate for 50 MHZ frequency
            when '0' =>
               if (rate_cnt = "1001") then
                  rate_cnt <= "0000";
               end if;
            --  100 Mbits/sec rate for 50 MHz frequency 
            
            when '1' =>
               if (rate_cnt = "0001") then
                  rate_cnt <= "0000";
               end if;
            when others =>
               if (rate_cnt = "0001") then
                  rate_cnt <= "0000";
               end if;
         end case;
      end if;
   end process;
   
   
   -- Synchronization of 2.5MHz and 25MHz clocks
   process (RMII_CLK, RMRESETN)
   begin
      if (RMRESETN = '0') then
         CLK_TX_RX_xhdl0 <= '0';
      elsif (RMII_CLK'event and RMII_CLK = '0') then
         CLK_TX_RX_xhdl0 <= clktr;		-- synchronization of CLKT and CLKR
      end if;
   end process;
   
   
   -- Synchronization of RESET
   process (RMII_CLK)
   begin
      if (RMII_CLK'event and RMII_CLK = '0') then
         RMRESETN <= RESETN;		-- synchronization of RESETN to RMRESETN
      end if;
   end process;
   
   
   --**********************************************************************
   --State machine to generate RMII_CRS and RMII_RX_DV - async portion
   process (fifo_present_state, CRS_DV_reg, count, SPEED_SYNC, RXD_reg0, RXD_reg1, preamble_count, pream_ok_reg, RX_DV_xhdl3, rx_dv_count)
   begin
      RMII_CRS_reg <= '0';
      RMII_RX_DV_reg <= '0';
      count_next <= "0000";
      preamble_count_next <= "00000000000000000000000000000000";
      pream_ok <= '0';
      fifo_next_state <= fifo_present_state;
      case fifo_present_state is
         -- Preamble detection logic 
         -- CRS detection logic 
         when state0 =>
            RMII_RX_DV_reg <= '0';
            RMII_CRS_reg <= '0';
            preamble_en <= '0';
            pream_ok <= '0';
            if ((CRS_DV_reg = '1') and (RXD_reg0 = "01")) then
               pream_ok <= '0';
               count_next <= count + "0001";
               preamble_count_next <= preamble_count + "00000000000000000000000000000001";
               preamble_en <= '0';
               RMII_RX_DV_reg <= '1';
               fifo_next_state <= state5;
               if (SPEED_SYNC = '0') then
                  count_next <= "0000";
               else
                  count_next <= "0000";
               end if;
            else
               fifo_next_state <= state0;
               count_next <= "0000";
            end if;
            if (CRS_DV_reg = '1') then
               RMII_CRS_reg <= '1';
            end if;
         
         when state1 =>
            RMII_RX_DV_reg <= '1';
            RMII_CRS_reg <= '1';
            count_next <= count + "0001";
            pream_ok <= '0';
            if (pream_ok_reg = '1') then
               pream_ok <= '1';
            end if;
            if (CRS_DV_reg = '0') then
               fifo_next_state <= state2;
               RMII_CRS_reg <= '0';
               if (SPEED_SYNC = '0') then
                  count_next <= "0000";
               else
                  count_next <= "0000";
               end if;
            else
               fifo_next_state <= state1;
               if (SPEED_SYNC = '0') then
                  if (count = "1001") then
                     count_next <= "0000";
                  end if;
               else
                  count_next <= "0000";
               end if;
            end if;
         when state2 =>
            RMII_RX_DV_reg <= '1';
            preamble_en <= '1';
            pream_ok <= '0';
            if (pream_ok_reg = '1') then
               pream_ok <= '1';
            end if;
            if (SPEED_SYNC = '1') then
               if (CRS_DV_reg = '1') then
                  RMII_CRS_reg <= '0';
                  fifo_next_state <= state3;
                  count_next <= "0000";
               else
                  fifo_next_state <= state7;
                  RMII_CRS_reg <= '0';
                  RMII_RX_DV_reg <= '0';
                  count_next <= "0000";
               end if;
            else
               count_next <= count + "0001";
               if (count = "1001") then
                  if (CRS_DV_reg = '1') then
                     RMII_CRS_reg <= '0';
                     fifo_next_state <= state3;
                     count_next <= "0000";
                  else
                     fifo_next_state <= state7;
                     RMII_CRS_reg <= '0';
                     RMII_RX_DV_reg <= '0';
                     count_next <= "0000";
                  end if;
               end if;
            end if;
         when state3 =>
            RMII_RX_DV_reg <= '1';
            preamble_en <= '1';
            pream_ok <= '0';
            if (pream_ok_reg = '1') then
               pream_ok <= '1';
            end if;
            if (SPEED_SYNC = '1') then
               if (CRS_DV_reg = '0') then
                  RMII_CRS_reg <= '0';
                  RMII_RX_DV_reg <= '1';
                  fifo_next_state <= state2;
               else
                  RMII_CRS_reg <= '0';
                  RMII_RX_DV_reg <= '0';
                  fifo_next_state <= state0;
               end if;
            else
               count_next <= count + "0001";
               if (count = "1001") then
                  if (CRS_DV_reg = '0') then
                     RMII_CRS_reg <= '0';
                     fifo_next_state <= state2;
                     RMII_RX_DV_reg <= '1';
                     count_next <= "0000";
                  else
                     fifo_next_state <= state0;
                     RMII_CRS_reg <= '0';
                     RMII_RX_DV_reg <= '0';
                     count_next <= "0000";
                  end if;
               end if;
            end if;
         --10mbps modification
         -- SFD detection logic 
         --(CRS_DV_reg == 1'b1)
         when state5 =>
            pream_ok <= '0';
            RMII_RX_DV_reg <= '1';
            RMII_CRS_reg <= '1';
            if (pream_ok_reg = '1') then
               pream_ok <= '1';
            end if;
            if (CRS_DV_reg = '1') then
               if (SPEED_SYNC = '1') then
                  RMII_CRS_reg <= '1';
                  preamble_count_next <= preamble_count + "00000000000000000000000000000001";
                  count_next <= "0000";
                  if ((RXD_reg0 = "11") and (RXD_reg1 = "01")) then
                     preamble_en <= '1';
                     RMII_RX_DV_reg <= '1';
                     fifo_next_state <= state1;
                     RMII_CRS_reg <= '1';
                     preamble_count_next <= "00000000000000000000000000000000";
                     if (preamble_count(0) = '0') then
                        fifo_next_state <= state1;
                        pream_ok <= '1';
                     else
                        fifo_next_state <= state6;
                        pream_ok <= '0';
                     end if;
                  else
                     fifo_next_state <= state5;
                     count_next <= "0000";
                  end if;
               else
                  count_next <= count + "0001";
                  if (count = "1001") then
                     RMII_RX_DV_reg <= '1';
                     RMII_CRS_reg <= '1';
                     preamble_count_next <= preamble_count + "00000000000000000000000000000001";
                     count_next <= "0000";
                     if ((RXD_reg0 = "11") and (RXD_reg1 = "01")) then
                        preamble_en <= '1';
                        RMII_RX_DV_reg <= '1';
                        fifo_next_state <= state1;
                        RMII_CRS_reg <= '1';
                        preamble_count_next <= "00000000000000000000000000000000";
                        if (rx_dv_count = "10011") then
                           fifo_next_state <= state1;
                           pream_ok <= '1';
                        else
                           fifo_next_state <= state6;
                           pream_ok <= '0';
                        end if;
                     else
                        fifo_next_state <= state5;
                        count_next <= "0000";
                     end if;
                  end if;
               end if;
            else
               fifo_next_state <= state0;
               RMII_RX_DV_reg <= '0';
               RMII_CRS_reg <= '0';
               count_next <= "0000";
               preamble_en <= '0';
               pream_ok <= '0';
            end if;
         --else for 10mbps
         when state6 =>
            RMII_RX_DV_reg <= '1';
            pream_ok <= '0';
            if (pream_ok_reg = '1') then
               pream_ok <= '1';
            end if;
            if (SPEED_SYNC = '1') then
               preamble_en <= '1';
               RMII_RX_DV_reg <= '1';
               RMII_CRS_reg <= '1';
               count_next <= "0000";
               fifo_next_state <= state1;
            else
               count_next <= count + "0001";
               if (count = "1001") then
                  preamble_en <= '1';
                  RMII_RX_DV_reg <= '1';
                  RMII_CRS_reg <= '1';
                  count_next <= "0000";
                  fifo_next_state <= state1;
               end if;
            end if;
         --else for 10mbps
         when state7 =>
            pream_ok <= '0';
            if (pream_ok_reg = '1') then
               pream_ok <= '1';
            end if;
            if (SPEED_SYNC = '1') then
               preamble_en <= '1';
               RMII_RX_DV_reg <= '0';
               RMII_CRS_reg <= '0';
               count_next <= "0000";
               if ((RX_DV_xhdl3 = '1') and (pream_ok_reg = '1')) then
                  fifo_next_state <= state7;
                  pream_ok <= '1';
               else
                  fifo_next_state <= state0;
                  pream_ok <= '0';
               end if;
            else
               count_next <= count + "0001";
               if (count = "1001") then
                  preamble_en <= '1';
                  RMII_RX_DV_reg <= '0';
                  RMII_CRS_reg <= '0';
                  count_next <= "0000";
                  if ((RX_DV_xhdl3 = '1') and (pream_ok_reg = '1')) then
                     fifo_next_state <= state7;
                     pream_ok <= '1';
                  else
                     fifo_next_state <= state0;
                     pream_ok <= '0';
                  end if;
               end if;
            end if;
         when others =>
            fifo_next_state <= state0;
            RMII_RX_DV_reg <= '0';
            RMII_CRS_reg <= '0';
            count_next <= "0000";
            preamble_en <= '0';
            pream_ok <= '0';
      end case;
   end process;
   
   
   -- sync portion of RMII_CRS_DV state machine			
   process (RMII_CLK, RMRESETN)
   begin
      if (RMRESETN = '0') then
         fifo_present_state <= state0;
         RMII_RX_DV_0 <= '0';
         RMII_CRS_0 <= '0';
         RX_ER_reg0 <= '0';
         RX_ER_reg1 <= '0';
         RX_ER_flag <= '0';
         count <= "0000";
         preamble_count <= "00000000000000000000000000000000";
         pream_ok_reg <= '0';
      elsif (RMII_CLK'event and RMII_CLK = '1') then
         pream_ok_reg <= pream_ok;
         preamble_count <= preamble_count_next;
         fifo_present_state <= fifo_next_state;
         RMII_RX_DV_0 <= RMII_RX_DV_reg;
         RMII_CRS_0 <= RMII_CRS_reg;
         count <= count_next;
         RX_ER_reg0 <= MII_RX_ER_xhdl2;
         RX_ER_reg1 <= RX_ER_reg0;
         if (RX_ER = '1') then
            RX_ER_flag <= '1';
         elsif (RX_ER_reg1 = '1') then
            RX_ER_flag <= '0';
         end if;
      end if;
   end process;
   
   
   -- sync RX RMII signals to MII interface
   process (CLK_TX_RX_xhdl0, RMRESETN)
   begin
      if (RMRESETN = '0') then
         RX_DV_xhdl3 <= '0';
         CRS_xhdl1 <= '0';
         CRS_reg <= '0';
         MII_RX_ER_reg0 <= '0';
         MII_RX_ER_xhdl2 <= '0';
         MII_RX_ER0 <= '0';
         MII_RXD_int <= "0000";
         RX_DV_reg <= '0';
      elsif (CLK_TX_RX_xhdl0'event and CLK_TX_RX_xhdl0 = '1') then
         RX_DV_reg <= RMII_RX_DV;
         if (SPEED_SYNC = '0') then
            MII_RX_ER_reg0 <= RX_ER_flag;
            MII_RX_ER0 <= MII_RX_ER_reg0;
            --Modified for multiple CRS_DV toggle 
            --RX_DV <=  RX_DV_reg;
            MII_RX_ER_xhdl2 <= MII_RX_ER0;
            RX_DV_xhdl3 <= RMII_RX_DV;
         else
            MII_RX_ER_reg0 <= RX_ER_flag;
            MII_RX_ER_xhdl2 <= MII_RX_ER_reg0;
            RX_DV_xhdl3 <= RX_DV_reg;
         end if;
         CRS_reg <= RMII_CRS;
         CRS_xhdl1 <= CRS_reg;
         if (pream_ok = '1') then
            MII_RXD_int <= RMII_RXD_reg;
         else
            MII_RXD_int <= RMII_RXD;		-- else 
         end if;
      end if;
   end process;
   
   -- always
   
   -- sync TX RMII signals to MII interface
   -- TX data transfer from MAC to PHY
   process (RMII_CLK, RMRESETN)
   begin
      if (RMRESETN = '0') then
         TX_EN_xhdl5 <= '0';
         TX_EN_sync0 <= '0';
         TX_EN_sync1 <= '0';
         TXD_xhdl4 <= "00";
         TXD_sync0 <= "0000";
         TXD_sync1 <= "0000";		-- Generate rmii ping pong enable
         tx_data_en <= '0';
         tx_count <= "0000";
      elsif (RMII_CLK'event and RMII_CLK = '1') then
         TXD_sync0 <= MII_TXD;
         TXD_sync1 <= TXD_sync0;		-- sync enable to RMII domain
         TX_EN_sync0 <= MII_TX_EN;		-- sync enable to RMII domain
         TX_EN_sync1 <= TX_EN_sync0;
         TX_EN_xhdl5 <= '0';
         TXD_xhdl4 <= "00";
         tx_count <= "0000";		-- Generate rmii ping pong enable
         tx_data_en <= '0';
         if (TX_EN_sync1 = '1') then
            if (tx_data_en = '0') then
               if (SPEED_SYNC = '0') then
                  if (tx_count = "1001") then
                     tx_data_en <= '1';		-- Generate rmii ping pong enable
                     tx_count <= "0000";		-- sync enable to RMII domain
                     TX_EN_xhdl5 <= TX_EN_xhdl5;		-- data to RMII domain
                     TXD_xhdl4 <= TXD_xhdl4;
                  else
                     TXD_xhdl4 <= TXD_sync1(1 downto 0);		-- data to RMII domain
                     tx_count <= tx_count + "0001";		-- Generate rmii ping pong enable
                     tx_data_en <= '0';		-- sync enable to RMII domain
                     TX_EN_xhdl5 <= TX_EN_sync1;
                  end if;
               else
                  -- data to RMII domain
                  TXD_xhdl4 <= TXD_sync1(1 downto 0);		-- Generate rmii ping pong enable
                  tx_data_en <= '1';		-- sync enable to RMII domain
                  TX_EN_xhdl5 <= TX_EN_sync1;
               end if;
            else
               if (SPEED_SYNC = '0') then
                  if (tx_count = "1001") then
                     tx_data_en <= '0';		-- Generate rmii ping pong enable
                     tx_count <= "0000";		-- sync enable to RMII domain
                     TX_EN_xhdl5 <= TX_EN_xhdl5;		-- data to RMII domain
                     TXD_xhdl4 <= TXD_xhdl4;
                  else
                     TXD_xhdl4 <= TXD_sync1(3 downto 2);		-- data to RMII domain
                     tx_count <= tx_count + "0001";		-- Generate rmii ping pong enable
                     tx_data_en <= '1';		-- sync enable to RMII domain
                     TX_EN_xhdl5 <= TX_EN_sync1;
                  end if;
               else
                  -- data to RMII domain
                  TXD_xhdl4 <= TXD_sync1(3 downto 2);		-- Generate rmii ping pong enable
                  tx_data_en <= '0';		-- sync enable to RMII domain
                  TX_EN_xhdl5 <= TX_EN_sync1;
               end if;
            end if;
         end if;
      end if;
   end process;
   
   
   -- RX data transfer from PHY to MAC
   process (RMII_CLK, RMRESETN)
   begin
      if (RMRESETN = '0') then
         RXD_reg0 <= "00";
         RXD_reg1 <= "00";
         RXD_reg2 <= "00";
         RXD_reg3 <= "00";
         CRS_DV_reg <= '0';
         rx_data_en <= '0';
         RMII_RXD <= "0000";
         RMII_RXD_reg <= "0000";
         RMII_RXD_reg0 <= "0000";
         RMII_RXD_reg1 <= "0000";
         RMII_RXD_reg2 <= "0000";
         RMII_RXD_reg3 <= "0000";
         RMII_RX_DV <= '0';
         RMII_RX_DV_1 <= '0';
         RMII_RX_DV_2 <= '0';
         RMII_RX_DV_3 <= '0';
         RMII_CRS <= '0';
         RMII_CRS_1 <= '0';
         RMII_CRS_2 <= '0';
         RMII_CRS_3 <= '0';
         rx_dv_count <= "00000";
         phase_en_reg <= '0';
      elsif (RMII_CLK'event and RMII_CLK = '1') then
         RMII_RXD_reg <= RMII_RXD;
         phase_en_reg <= phase_en;
         rx_dv_count <= "00000";
         --RXD_reg1 <= pream_ok ? RXD_reg3 : RXD_reg0;
         RXD_reg0 <= RXD;
         RXD_reg1 <= RXD_reg0;
         RXD_reg2 <= RXD_reg0;
         RXD_reg3 <= RXD_reg2;
         CRS_DV_reg <= CRS_DV;
         rx_data_en <= '0';
         if (SPEED_SYNC = '1') then
            RMII_RXD_reg1 <= RMII_RXD_reg0;
            if (pream_ok = '1') then
               if (rx_data_en = '0') then
                  RMII_RXD_reg2 <= RMII_RXD_reg1;
               end if;
            else
               RMII_RXD_reg2 <= RMII_RXD_reg1;
            end if;
         else
            RMII_RXD_reg2 <= RMII_RXD_reg1;
         end if;
         --Modified for multiple CRS_DV toggle 
         -- RMII_RX_DV_1 <= RMII_RX_DV_0;
         RMII_RXD_reg3 <= RMII_RXD_reg2;
         if (SPEED_SYNC = '1') then
            --if ((fifo_next_state != 1'b0) || (pream_ok == 1'b1))
            if ((fifo_next_state /= state7) or (pream_ok = '1')) then
               RMII_RX_DV_1 <= RMII_RX_DV_0;
            else
               RMII_RX_DV_1 <= '0';
            end if;
         elsif ((pream_ok = '1') and rx_dv_count = "01001") then
            RMII_RX_DV_1 <= RMII_RX_DV_0;
            RMII_RXD_reg1 <= RMII_RXD_reg0;
         elsif ((pream_ok = '0') and rx_dv_count = "10011") then
            RMII_RX_DV_1 <= RMII_RX_DV_0;
            RMII_RXD_reg1 <= RMII_RXD_reg0;
         end if;
         RMII_RX_DV_2 <= RMII_RX_DV_1;
         RMII_RX_DV_3 <= RMII_RX_DV_2;
         RMII_CRS_1 <= RMII_CRS_0;
         RMII_CRS_2 <= RMII_CRS_1;
         --Modified for multiple CRS_DV toggle 
         RMII_CRS_3 <= RMII_CRS_2;
         if (RMII_RX_DV_0 = '1' or RMII_RX_DV_1 = '1') then
            if (rx_data_en = '0') then
               if (SPEED_SYNC = '0') then
                  if (rx_dv_count = "01001") then
                     rx_dv_count <= rx_dv_count + "00001";
                     -- RMII_RXD_reg0 <= RMII_RXD_reg0;
                     rx_data_en <= '1';
                  else
                     rx_dv_count <= rx_dv_count + "00001";
                     if (pream_ok = '1') then
                        RMII_RXD_reg0 <= (RXD_reg1 & RMII_RXD_reg0(1 downto 0));
                     else
                        RMII_RXD_reg0 <= (RMII_RXD_reg0(3 downto 2) & RXD_reg1);
                     end if;
                     
                     rx_data_en <= '0';
                  end if;
               else
                  rx_data_en <= '1';
                  if (pream_ok = '1') then
                     RMII_RXD_reg0 <= (RXD_reg1 & RMII_RXD_reg0(1 downto 0));
                  else
                     RMII_RXD_reg0 <= (RMII_RXD_reg0(3 downto 2) & RXD_reg1);
                  end if;
               end if;
            else
               if (SPEED_SYNC = '0') then
                  if (rx_dv_count = "10011") then
                     rx_dv_count <= "00000";
                     -- RMII_RXD_reg0 <= RMII_RXD_reg0;
                     -- RMII_RXD_reg1 <= RMII_RXD_reg0;
                     --Modified for multiple CRS_DV toggle 
                     -- RMII_RX_DV_1 <= RMII_RX_DV_0;
                     rx_data_en <= '0';
                  else
                     rx_dv_count <= rx_dv_count + "00001";
                     rx_data_en <= '1';
                     if (pream_ok = '1') then
                        RMII_RXD_reg0 <= (RMII_RXD_reg0(3 downto 2) & RXD_reg1);
                     else
                        RMII_RXD_reg0 <= (RXD_reg1 & RMII_RXD_reg0(1 downto 0));
                     end if;
                  end if;
               else
                  rx_data_en <= '0';
                  if (pream_ok = '1') then
                     RMII_RXD_reg0 <= (RMII_RXD_reg0(3 downto 2) & RXD_reg1);
                  else
                     RMII_RXD_reg0 <= (RXD_reg1 & RMII_RXD_reg0(1 downto 0));
                  end if;
               end if;
            end if;
         end if;
         -- Align the phase
         if (SPEED_SYNC = '1') then
            if ((phase_en = '1') or ((phase_en_reg = '1') and (pream_ok = '1'))) then
               RMII_RX_DV <= RMII_RX_DV_2;
               RMII_CRS <= RMII_CRS_2;		-- Changed from stage1 to stage2
               RMII_RXD <= RMII_RXD_reg2;
            else
               RMII_RX_DV <= RMII_RX_DV_3;
               RMII_CRS <= RMII_CRS_3;		--Changed from stage2 to stage3
               RMII_RXD <= RMII_RXD_reg3;
            end if;
         else
            RMII_RX_DV <= RMII_RX_DV_3;
            RMII_CRS <= RMII_CRS_3;		-- Changed from stage1 to stage2
            RMII_RXD <= RMII_RXD_reg3;
         end if;
      end if;
   end process;
   
   
   -- Generate phase enable logic
   process (RMII_CLK, RMRESETN)
   begin
      if (RMRESETN = '0') then
         phase_en <= '0';
         phase_en_int <= '0';
      elsif (RMII_CLK'event and RMII_CLK = '1') then
         phase_en <= phase_en_int;
         if ((RX_DV_EN = '1') and (CLK_TX_RX_xhdl0 = '0')) then
            phase_en_int <= '1';		-- sync enable to RMII domain
         elsif (RMII_RX_DV_1 = '0') then
            phase_en_int <= '0';		-- sync enable to RMII domain
         end if;
      end if;
   end process;
   
   
   -- generate RX_DV Enable
   RX_DV_EN <= (RMII_RX_DV_0 and (not(RMII_RX_DV_1)));
   
end architecture trans;


