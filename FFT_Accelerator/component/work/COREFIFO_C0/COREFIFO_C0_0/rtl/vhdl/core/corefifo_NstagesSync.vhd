-- ********************************************************************/
-- Actel Corporation Proprietary and Confidential
--  Copyright 2011 Actel Corporation.  All rights reserved.
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
-- IN ADVANCE IN WRITING.
--
-- Description: doubleSync.v
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

ENTITY COREFIFO_C0_COREFIFO_C0_0_corefifo_NstagesSync IS 
   GENERIC (
      -- --------------------------------------------------------------------------
      -- PARAMETER Declaration
      -- --------------------------------------------------------------------------
       NUM_STAGES  : integer := 2;    
      ADDRWIDTH    :  integer := 3);    
   PORT (
      clk                     : IN std_logic;   
      rstn                    : IN std_logic;   
-- --------------------------------------------------------------------------
-- I/O Declaration
-- --------------------------------------------------------------------------
----------
-- Inputs
----------

      inp                     : IN std_logic_vector(ADDRWIDTH DOWNTO 0);   
----------
-- Outputs
----------

      sync_out                : OUT std_logic_vector(ADDRWIDTH DOWNTO 0));   
END ENTITY COREFIFO_C0_COREFIFO_C0_0_corefifo_NstagesSync;

ARCHITECTURE translated OF COREFIFO_C0_COREFIFO_C0_0_corefifo_NstagesSync IS
     type mem_array_type is array (NUM_STAGES - 1 downto 0) of std_logic_vector(ADDRWIDTH  downto 0);
	signal shift_array : mem_array_type; 

 

begin
process(clk, rstn)
begin
    if( not rstn = '1') then
        shift_array <= (others => (others => '0'));
       -- sync_out <= (others => '0');
    elsif(clk'event and clk = '1') then
        shift_array(0) <= inp;
        shift_array(NUM_STAGES - 1 downto 1) <= shift_array(NUM_STAGES - 2 downto 0);
       -- sync_out <= shift_array(NUM_STAGES - 1);
    end if;
end process;
 
sync_out <= shift_array(NUM_STAGES - 1);
  

END ARCHITECTURE translated;
