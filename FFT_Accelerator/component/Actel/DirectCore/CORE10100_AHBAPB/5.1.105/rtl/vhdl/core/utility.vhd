-- ********************************************************************/ 
-- Copyright 2013 Actel Corporation.  All rights reserved.
-- IP Solutions Group
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED 
-- IN ADVANCE IN WRITING.  
--  
-- File:  utility.vhd
--     
-- Description: Core10100
--              See below  
--
-- SVN Revision Information:
-- SVN $Revision: 6868 $
-- SVN $Date: 2009-02-25 04:07:01 +0530 (Wed, 25 Feb 2009) $  
--   
--
-- Notes: 
--		  
--
-- *********************************************************************/ 
--


--*******************************************************************--
-- Copyright (c) 2001-2003  Actel Corp.                             --
--*******************************************************************--
-- Please review the terms of the license agreement before using     --
-- this file. If you are not an authorized user, please destroy this --
-- source code file and notify Actel Corp. immediately that you     --
-- inadvertently received an unauthorized copy.                      --
--*******************************************************************--

-----------------------------------------------------------------------
-- Project name         : MAC
-- Project description  : Media Access Controller
--
-- File name            : utility.vhd
-- File contents        : Package UTILITY
-- Purpose              : Constants for MAC
--
-- Destination library  : work 
-- Dependencies         : IEEE.STD_LOGIC_1164
--
-- Design Engineer      : T.K.
-- Quality Engineer     : M.B.
-- Version              : 2.00.E04
-- Last modification    : 2003-05-22
-----------------------------------------------------------------------

--*******************************************************************--
-- Modifications with respect to Version 2.00.E00:
-- 2.00.E01   :
-- 2003.03.21 : T.K. - references to MIIWIDTH=8 removed
-- 2003.03.21 : T.K. - unused CSR declarations removed
-- 2003.03.21 : T.K. - transmit state machine declaration removed
-- 2.00.E03   :
-- 2003.08.01 : T.K. - comments added    
-- 2.00.E06
-- 2004.01.20 : L.C. - SET0_RV set to 0x00000000 (F200.05.setup_status)
--*******************************************************************--

library IEEE;
  use ieee.std_logic_1164.all; 
  use ieee.numeric_std.all;

  --*****************************************************************--
  package UTILITY IS
  
  
     function to_std_logic( x: UNSIGNED ) return std_logic_vector;
     function to_unsigned( x: std_logic_vector ) return UNSIGNED;
     function to_logic( x: BOOLEAN) return std_logic;
     function to_logic( x: INTEGER) return std_logic;
     function to_integer( x: BOOLEAN) return integer;
  
    -------------------------------------------------------------------
    -- 802.3 parameters
    -------------------------------------------------------------------
    -- interframe space 1 interval = 60 bit times
    constant IFS1_TIME   : STD_LOGIC_VECTOR(3 downto 0)
                             := "1110";
    -- interframe space 2 interval = 36 bit times
    constant IFS2_TIME   : STD_LOGIC_VECTOR(3 downto 0)
                             := "1000";
    -- slot time interfal =  512 bit times
    constant SLOT_TIME   : STD_LOGIC_VECTOR(8 downto 0)
                             := "001111111";
    -- maximum number of retransmission attempts = 16
    constant ATT_MAX     : STD_LOGIC_VECTOR(4 downto 0)
                             := "10000";
    -- proper crc remainder value = 0xc704dd7b
    constant CRCVAL      : STD_LOGIC_VECTOR(31 downto 0)
                             := "11000111000001001101110101111011";
    -- minimum frame size = 64
    constant MIN_FRAME   : STD_LOGIC_VECTOR(6 downto 0)
                             := "1000000";
    -- maximum ethernet frame length field value = 1500
    constant MAX_SIZE    : STD_LOGIC_VECTOR(15 downto 0)
                             := "0000010111011100";
    -- maximum frame size
    constant MAX_FRAME   : STD_LOGIC_VECTOR(13 downto 0)
                             := "00010111101111"; -- 1519
  
    --_________________________________________________________________
    -- Control and Status Register summary
    --_________________________________________________________________
    -- Register | ID  |      RV       | Description
    --_________________________________________________________________
    -- CSR0     | 00h | fe000000h     | Bus mode
    -- CSR1     | 08h | ffffffffh     | Transmit pool demand
    -- CSR2     | 10h | ffffffffh     | Teceive pool demand
    -- CSR3     | 18h | ffffffffh     | Receive list base address
    -- CSR4     | 20h | ffffffffh     | Rransmit list base address
    -- CSR5     | 28h | f0000000h     | Status
    -- CSR6     | 30h | 32000040h     | Operation mode
    -- CSR7     | 38h | f3fe0000h     | Interrupt enable
    -- CSR8     | 40h | e0000000h     | Missed frames and overflow cnt
    -- CSR9     | 48h | fff483ffh     | MII management
    -- CSR11    | 58h | fffe0000h     | Timer and interrupt mitigation
    --_________________________________________________________________
      
    -------------------------------------------------------------------
    -- Special Function Register locations and reset values
    -------------------------------------------------------------------
    
    -- CSR0     : 00h : fe000000h     : Bus mode
    constant CSR0_ID  : STD_LOGIC_VECTOR(5 downto 0) := "000000";
  -- CSR0 reset value
    constant CSR0_RV  : STD_LOGIC_VECTOR(31 downto 0) 
                      := "11111110000000000000000000000000";
    
    -- CSR1     : 08h : ffffffffh     : Transmit pool demand
    constant CSR1_ID  : STD_LOGIC_VECTOR(5 downto 0) := "000010";
  -- CSR1 reset value
    constant CSR1_RV  : STD_LOGIC_VECTOR(31 downto 0) 
                      := "11111111111111111111111111111111";
    
    -- CSR2     : 10h : ffffffffh     : Receive pool demand
    constant CSR2_ID  : STD_LOGIC_VECTOR(5 downto 0) := "000100";
  -- CSR2 reset value
    constant CSR2_RV  : STD_LOGIC_VECTOR(31 downto 0) 
                      := "11111111111111111111111111111111";
    
    -- CSR3     : 18h : ffffffffh     : Receive list base address
    constant CSR3_ID  : STD_LOGIC_VECTOR(5 downto 0) := "000110";
  -- CSR3 reset value
    constant CSR3_RV  : STD_LOGIC_VECTOR(31 downto 0) 
                      := "11111111111111111111111111111111";
    
    -- CSR4     : 20h : ffffffffh     : Transmit list base address
    constant CSR4_ID  : STD_LOGIC_VECTOR(5 downto 0) := "001000";
  -- CSR4 reset value
    constant CSR4_RV  : STD_LOGIC_VECTOR(31 downto 0) 
                      := "11111111111111111111111111111111";
    
    -- CSR5     : 28h : f0000000h     : Status
    constant CSR5_ID  : STD_LOGIC_VECTOR(5 downto 0) := "001010";
  -- CSR5 reset value
    constant CSR5_RV  : STD_LOGIC_VECTOR(31 downto 0) 
                      := "11110000000000000000000000000000";
    
    -- CSR6     : 30h : 32000040h     : Operation mode
    constant CSR6_ID  : STD_LOGIC_VECTOR(5 downto 0) := "001100";
  -- CSR6 reset value
    constant CSR6_RV  : STD_LOGIC_VECTOR(31 downto 0) 
                      := "00110010000000000000000001000000";
    
    -- CSR7     : 38h : f3fe0000h     : Interrupt enable
    constant CSR7_ID  : STD_LOGIC_VECTOR(5 downto 0) := "001110";
  -- CSR7 reset value
    constant CSR7_RV  : STD_LOGIC_VECTOR(31 downto 0) 
                      := "11110011111111100000000000000000";
    
    -- CSR8     : 40h : e0000000h     : Missed frames and overflow cnt
    constant CSR8_ID  : STD_LOGIC_VECTOR(5 downto 0) := "010000";
  -- CSR8 reset value
    constant CSR8_RV  : STD_LOGIC_VECTOR(31 downto 0) 
                      := "11100000000000000000000000000000";
    
    -- CSR9     : 48h : fff483ffh     : MII menagement
    constant CSR9_ID  : STD_LOGIC_VECTOR(5 downto 0) := "010010";
  -- CSR9 reset value
    constant CSR9_RV  : STD_LOGIC_VECTOR(31 downto 0) 
	                  --  10987654321098765432109876543210           
                      := "11111111111101001000001111111111";
    
    -- CSR11    : 58h : fffe0000h     : Timer and interrupt mitigation
    constant CSR11_ID : STD_LOGIC_VECTOR(5 downto 0) := "010110";
  -- CSR11 reset value
    constant CSR11_RV : STD_LOGIC_VECTOR(31 downto 0) 
                      := "11111111111111100000000000000000";
    
    -- TDES0
    constant TDES0_RV : STD_LOGIC_VECTOR(31 downto 0)
                      := "00000000000000000000000000000000";
    
    -- SET0
    constant SET0_RV : STD_LOGIC_VECTOR(31 downto 0)
                    := "00000000000000000000000000000000";
    
    -- RDES0
    constant RDES0_RV : STD_LOGIC_VECTOR(31 downto 0)
                      := "00000000000000000000000000000000";
    
    -------------------------------------------------------------------
    -- Internal interface parameters
    -------------------------------------------------------------------
    -- Filtering RAM address width NOTE THESE ARE HARD CODED AT TOP LEVELS
    constant ADDRDEPTH     : INTEGER := 6;
    -- Filtering RAM data width
    constant ADDRWIDTH     : INTEGER := 16;
    -- Maximum FIFO depth
    constant FIFODEPTH_MAX : INTEGER := 15;
    -- Maximum Data interface address width
    constant DATADEPTH_MAX : INTEGER := 32;
    -- Maximum Data interface width
    constant DATAWIDTH_MAX : INTEGER := 32;
    
    
    -------------------------------------------------------------------
    -- Filtering modes
    -------------------------------------------------------------------
  -- Filtering mode - PREFECT --
    constant FT_PERFECT : STD_LOGIC_VECTOR(1 downto 0) := "00";
  -- Filtering mode - HASH --
    constant FT_HASH    : STD_LOGIC_VECTOR(1 downto 0) := "01";
  -- Filtering mode - INVERSE --
    constant FT_INVERSE : STD_LOGIC_VECTOR(1 downto 0) := "10";
  -- Filtering mode - HONLY --
    constant FT_HONLY   : STD_LOGIC_VECTOR(1 downto 0) := "11";
    
    -------------------------------------------------------------------
    -- Phisical address position in setup frame
    -------------------------------------------------------------------
    constant PERF1_ADDR  : STD_LOGIC_VECTOR(5 downto 0) := "100111";
    
    -------------------------------------------------------------------
    -- Ethernet frame fields
    -------------------------------------------------------------------
    -- jam field pattern
    constant JAM_PATTERN : STD_LOGIC_VECTOR(63 downto 0)
 := "1010101010101010101010101010101010101010101010101010101010101010";
    -- preamble field pattern
    constant PRE_PATTERN : STD_LOGIC_VECTOR(63 downto 0)
 := "0101010101010101010101010101010101010101010101010101010101010101";
    -- start of frame delimiter pattern
    constant SFD_PATTERN : STD_LOGIC_VECTOR(63 downto 0)
 := "1101010111010101110101011101010111010101110101011101010111010101";
    -- padding field pattern
    constant PAD_PATTERN : STD_LOGIC_VECTOR(63 downto 0)
 := "0000000000000000000000000000000000000000000000000000000000000000";
    -- carrier extension pattern
    constant EXT_PATTERN : STD_LOGIC_VECTOR(63 downto 0)
 := "0000111100001111000011110000111100001111000011110000111100001111";
    
    -------------------------------------------------------------------
    -- Enumeration types
    -------------------------------------------------------------------
    
    -- DMA state machine
    type DMASMT is (
                  DSM_IDLE,
                  DSM_CH1,
                  DSM_CH2
               );
    
    -- process state machine type for HC
    type PSMT is (
                  PSM_RUN,
                  PSM_SUSPEND,
                  PSM_STOP
               );
    
    -- receive state machine for HC
    type RSMT is (
                  RSM_IDLE,
                  RSM_ACQ1,  -- trying to acquire free descriptor
                  RSM_ACQ2,  -- trying to acquire free descriptor
                  RSM_REC,   -- receiving frame
                  RSM_STORE, -- storing frame
                  RSM_STAT   -- status of the frame
               );
    
    -- linked list state machine for HC
    type LSMT is (
                  LSM_IDLE,
                  LSM_DES0P, -- des0 prefetching
                  LSM_DES0,  -- des0 fetching
                  LSM_DES1,  -- des1 fetching
                  LSM_DES2,  -- des2 fetching
                  LSM_DES3,  -- des3 fetching
                  LSM_BUF1,  -- buffer 1 fetching
                  LSM_BUF2,  -- buffer 2 fetching
                  LSM_STAT,  -- descriptor status storing
                  LSM_FSTAT, -- frame status storing
                  LSM_NXT    -- next descriptor's address computing
                );
                
  -- descriptor's control state machine for HC
  type CSMT is (
                  CSM_IDLE,
                  CSM_F,     -- first descriptor
                  CSM_I,     -- intermediate descriptor
                  CSM_L,     -- last descriptor
                  CSM_FL,    -- first and last descriptor
                  CSM_SET,   -- setup frame descriptor
                  CSM_BAD    -- invalid descriptor
               );
  
  -- master interface state machine for HC
  type MSMT is (
                  MSM_IDLE,
                  MSM_REQ,
                  MSM_BURST
               );
  
  -- receive state machine for RC
  type RCSMT is (             
                  RSM_IDLE,
                  RSM_SFD,
                  RSM_DEST,
                  RSM_SOURCE,
                  RSM_LENGTH,
                  RSM_INFO,
                  RSM_SUCC,
                  RSM_INT,
                  RSM_INT1,
                  RSM_BAD    -- flushing received frame from fifo
                );
  
  -- address filtering state machine
  type FSMT is (
                  FSM_IDLE,
                  FSM_PERF1, -- checking single physical address
                  FSM_PERF16,-- checking 16 addresses
                  FSM_HASH,  -- hash fitering
                  FSM_MATCH, -- address match
                  FSM_FAIL   -- address failed
               );
  
  -- deffering state machine for TC
  type DSMT is (
                  DSM_WAIT,  -- end of IFS, waiting for pending frame
                  DSM_IFS1,  -- calculating interframe space time 1
                  DSM_IFS2   -- calculating interframe space time 2
               );
  
  -- transmit state machine for TC
  type TCSMT is (  
                  TSM_IDLE, 
                  TSM_PREA, 
                  TSM_SFD, 
                  TSM_INFO,
                  TSM_PAD,
                  TSM_CRC,
                  TSM_BURST,
                  TSM_JAM,
                  TSM_FLUSH,
                  TSM_INT
                );
    
  end UTILITY;
  

library IEEE;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

 
package body utility is


---------------------------------------------------------------------
-- Handle UNSIGNED to std_logic_vector conversions
--

function to_std_logic( x: UNSIGNED ) return std_logic_vector is
variable y: std_logic_vector(x'range);
begin
   for i in x'range loop
     y(i) := x(i);
   end loop;
   return(y);
end to_std_logic;

function to_unsigned( x: std_logic_vector ) return UNSIGNED is
variable y: UNSIGNED(x'range);
begin
   for i in x'range loop
     y(i) := x(i);
   end loop;
   return(y);
end to_unsigned;


function to_logic( x: BOOLEAN) return std_logic is
 variable y : std_logic;
 begin
  if x then y:='1';
       else y:='0';
  end if;
  return(y);
end to_logic;

function to_logic( x: INTEGER) return std_logic is
 variable y : std_logic;
 begin
  y:='0';
  if x=1 then 
    y:='1';
  end if;
  return(y);
end to_logic;

 function to_integer( x: BOOLEAN) return integer is 
  variable y : integer;                             
  begin                                             
   if x then y:=1;                                  
        else y:=0;                                  
   end if;                                          
   return(y);                                       
 end to_integer;                                    




end utility;
  
--*******************************************************************--
