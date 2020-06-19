-- ********************************************************************/
-- Actel Corporation Proprietary and Confidential
--  Copyright 2011 Actel Corporation.  All rights reserved.
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
-- IN ADVANCE IN WRITING.
--
-- Description:  grayToBinConv.v
--               
--
--
-- Revision Information:
-- Date     Description
--
-- SVN Revision Information:
-- SVN $Revision: 4805 $
-- SVN $Date: 2012-06-21 17:48:48 +0530 (Thu, 21 Jun 2012) $
--
-- Resolved SARs
-- SAR      Date     Who   Description
--
-- Notes:
--
-- ********************************************************************/
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_unsigned.all;
use     ieee.std_logic_misc.all;


ENTITY COREFIFO_C0_COREFIFO_C0_0_corefifo_grayToBinConv IS
   GENERIC (
      -- --------------------------------------------------------------------------
      -- Parameter Declaration
      -- --------------------------------------------------------------------------
      ADDRWIDTH                      :  integer := 3);    
   PORT (
      -- --------------------------------------------------------------------------
      -- I/O Declaration
      -- --------------------------------------------------------------------------
      ----------
      -- Inputs
      ----------

      gray_in                 : IN std_logic_vector(ADDRWIDTH DOWNTO 0);   
      -----------
      -- Outputs
      -----------

      bin_out                 : OUT std_logic_vector(ADDRWIDTH DOWNTO 0));   
END ENTITY COREFIFO_C0_COREFIFO_C0_0_corefifo_grayToBinConv;

ARCHITECTURE translated OF COREFIFO_C0_COREFIFO_C0_0_corefifo_grayToBinConv IS

   -- --------------------------------------------------------------------------
   -- Internal signals
   -- --------------------------------------------------------------------------
   SIGNAL i                        :  integer;   
   SIGNAL bin_out_xhdl1            :  std_logic_vector(ADDRWIDTH DOWNTO 0);   

BEGIN
   -- --------------------------------------------------------------------------
   --                               Start - of - Code
   -- --------------------------------------------------------------------------

   bin_out <= bin_out_xhdl1;

   -- --------------------------------------------------------------------------
   -- Logic to Convert the Gray code to Binary
   -- --------------------------------------------------------------------------
   
   PROCESS (bin_out_xhdl1, gray_in, i)
      VARIABLE bin_out_xhdl1_xhdl2  : std_logic_vector(ADDRWIDTH DOWNTO 0);
   BEGIN
      bin_out_xhdl1_xhdl2(ADDRWIDTH) := gray_in(ADDRWIDTH);    
      FOR i IN ADDRWIDTH DOWNTO (0 + 1) LOOP
         bin_out_xhdl1_xhdl2(i - 1) := bin_out_xhdl1_xhdl2(i) XOR gray_in(i - 1)
         ;    
      END LOOP;
      bin_out_xhdl1 <= bin_out_xhdl1_xhdl2;
   END PROCESS;

END ARCHITECTURE translated;
