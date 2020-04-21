--
-- ********************************************************************/ 
-- Actel Corporation Proprietary and Confidential
-- Copyright 2013 Actel Corporation.  All rights reserved.
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED 
-- IN ADVANCE IN WRITING.  
--  
-- Description: Reset Controller
--                      
--
-- Revision Information:
-- Date     Description
-- 18Oct07  Initial Release 
--
-- SVN Revision Information:
-- SVN $Revision: 6737 $
-- SVN $Date $
--
-- Resolved SARs
-- SAR      Date     Who   Description
--
-- Notes: 
--        
-- *********************************************************************/
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;

entity RSTC is
   port (
      
      clkdma   : in std_logic;
      clkcsr   : in std_logic;
      clkr     : in std_logic;
      rstcsr   : in std_logic;
      rstsoft  : in std_logic;
      hrstn    : out std_logic;
      prstn    : out std_logic;
      rrstn    : out std_logic
   );
end entity RSTC;

architecture trans of RSTC is
   
   -- software reset registered in receive clock domain
   signal rstsoft_csr_syncr0   : std_logic;
   signal rstsoft_csr_syncr    : std_logic;
   signal rstcsr_syncr0        : std_logic;
   signal rstcsr_syncr         : std_logic;
   -- software reset registered in dma clock domain
   signal rstsoft_csr_syncdma0 : std_logic;
   signal rstsoft_csr_syncdma  : std_logic;
   signal rstcsr_syncdma0      : std_logic;
   signal rstcsr_syncdma       : std_logic;
   -- software reset registered in csr clock domain
   signal rstsoft_csr          : std_logic;
   signal rrstn_sync0          : std_logic;
   signal rrstn_sync           : std_logic;
   signal hrstn_sync0          : std_logic;
   signal hrstn_sync           : std_logic;
   signal count_csr            : std_logic_vector(4 downto 0);
   signal count_csrr           : std_logic_vector(4 downto 0);
   signal count_csrdma         : std_logic_vector(4 downto 0);
   signal rstcsr_en            : std_logic;
   signal rstcsrr_en           : std_logic;
   signal rstcsrdma_en         : std_logic;
   
   -- Declare intermediate signals for referenced outputs
   signal hrstn_xhdl0          : std_logic;
   signal prstn_xhdl1          : std_logic;
   signal rrstn_xhdl2          : std_logic;
begin
   -- Drive referenced outputs
   hrstn <= hrstn_xhdl0;
   prstn <= prstn_xhdl1;
   rrstn <= rrstn_xhdl2;
   --===================================================================--
   --                         csr clock domain                          --
   --===================================================================--
   ---------------------------------------------------------------------
   -- software reset registered in csr clock domain
   ---------------------------------------------------------------------
   process (clkcsr)
   begin
      if (clkcsr'event and clkcsr = '1') then
         if (rstcsr = '1') then
            rstsoft_csr <= '0';
         else
            -- synchronous reset ----------------------
            if (rstsoft = '1') then
               rstsoft_csr <= '1';
            elsif (prstn_xhdl1 = '1' and rrstn_sync = '1' and hrstn_sync = '1') then
               rstsoft_csr <= '0';
            end if;
         end if;
      end if;
   end process;
   
   -- rstsoft_csr_reg_proc
   
   ---------------------------------------------------------------------
   -- hardware/software reset registered in csr clock domain
   ---------------------------------------------------------------------
   process (clkcsr)
   begin
      if (clkcsr'event and clkcsr = '1') then
         prstn_xhdl1 <= (not((rstcsr or rstsoft_csr)) or rstcsr_en);
         count_csr <= "00000";
         rstcsr_en <= '0';
         if (rstsoft_csr = '1') then
            if (count_csr = "00100") then
               rstcsr_en <= '1';
               count_csr <= count_csr + "00001";
            elsif (count_csr = "11111") then
               count_csr <= "00000";
               rstcsr_en <= '0';
            else
               count_csr <= count_csr + "00001";
               rstcsr_en <= rstcsr_en;
            end if;
         end if;
      end if;
   end process;
   
   -- rstcsro_reg_proc
   
   ---------------------------------------------------------------------
   -- hardware/software reset registered in clkr clock domain
   ---------------------------------------------------------------------
   process (clkr)
   begin
      if (clkr'event and clkr = '1') then
         rstsoft_csr_syncr0 <= rstsoft_csr;
         rstsoft_csr_syncr <= rstsoft_csr_syncr0;
         rstcsr_syncr0 <= rstcsr;
         rstcsr_syncr <= rstcsr_syncr0;
         rrstn_xhdl2 <= (not((rstcsr_syncr or rstsoft_csr_syncr)) or rstcsrr_en);
         count_csrr <= "00000";
         rstcsrr_en <= '0';
         if (rstsoft_csr_syncr = '1') then
            if (count_csrr = "00100") then
               rstcsrr_en <= '1';
               count_csrr <= count_csrr + "00001";
            elsif (count_csrr = "11111") then
               count_csrr <= "00000";
               rstcsrr_en <= '0';
            else
               count_csrr <= count_csrr + "00001";
               rstcsrr_en <= rstcsrr_en;
            end if;
         end if;
      end if;
   end process;
   
   -- rstcsro_reg_proc
   
   ---------------------------------------------------------------------
   -- hardware/software reset registered in dma clock domain
   ---------------------------------------------------------------------
   process (clkdma)
   begin
      if (clkdma'event and clkdma = '1') then
         rstsoft_csr_syncdma0 <= rstsoft_csr;
         rstsoft_csr_syncdma <= rstsoft_csr_syncdma0;
         rstcsr_syncdma0 <= rstcsr;
         rstcsr_syncdma <= rstcsr_syncdma0;
         hrstn_xhdl0 <= (not((rstcsr_syncdma or rstsoft_csr_syncdma)) or rstcsrdma_en);
         count_csrdma <= "00000";
         rstcsrdma_en <= '0';
         if (rstsoft_csr_syncdma = '1') then
            if (count_csrdma = "00100") then
               rstcsrdma_en <= '1';
               count_csrdma <= count_csrdma + "00001";
            elsif (count_csrdma = "11111") then
               count_csrdma <= "00000";
               rstcsrdma_en <= '0';
            else
               count_csrdma <= count_csrdma + "00001";
               
               rstcsrdma_en <= rstcsrdma_en;
            end if;
         end if;
      end if;
   end process;
   
   -- rstcsro_reg_proc
   
   --===================================================================--
   ---------------------------------------------------------------------
   -- Synchronization of different resets in pclk domain
   ---------------------------------------------------------------------
   process (clkcsr)
   begin
      if (clkcsr'event and clkcsr = '1') then
         rrstn_sync0 <= rrstn_xhdl2;
         rrstn_sync <= rrstn_sync0;
         hrstn_sync0 <= hrstn_xhdl0;
         hrstn_sync <= hrstn_sync0;		-- rstrc_rst_proc
      end if;
   end process;
   
   
end architecture trans;


