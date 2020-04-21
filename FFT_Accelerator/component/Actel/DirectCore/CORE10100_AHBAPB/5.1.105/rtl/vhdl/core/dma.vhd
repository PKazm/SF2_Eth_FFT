-- ********************************************************************/ 
-- Copyright 2013 Actel Corporation.  All rights reserved.
-- IP Solutions Group
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED 
-- IN ADVANCE IN WRITING.  
--  
-- File:  dma.vhd
--     
-- Description: Core10100
--              See below  
--
-- SVN Revision Information:
-- SVN $Revision: 6932 $
-- SVN $Date: 2009-02-26 12:26:59 +0530 (Thu, 26 Feb 2009) $  
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
-- Project description  : Ethernet Media Access Controller
--
-- File name            : dma.vhd
-- File contents        : Entity DMA
--                        Architecture RTL of HC
-- Purpose              : DMA Controller for MAC
--
-- Destination library  : work
-- Dependencies         : work.UTILITY
--                        IEEE.STD_LOGIC_1164
--                        IEEE.STD_LOGIC_UNSIGNED
--
-- Design Engineer      : T.K.
-- Quality Engineer     : M.B.
-- Version              : 2.00.E07a
-- Last modification    : 2004-03-26
-----------------------------------------------------------------------

--*******************************************************************--
-- Modifications with respect to Version 2.00.E00:
-- 2.00.E01   :
-- 2003.03.21 : T.K. - big/little endian support added
-- 2.00.E02   :
-- 2003.04.15 : T.K. - dataible_proc changed
-- 2003.04.15 : T.K. - dataoble_proc changed
-- 2.00.E03   :
-- 2003.05.12 : T.K. - datarw signal is now registered
-- 2003.05.12 : T.K. - dataeob signal is now registered  
-- 2.00.E06   :  
-- 2004.01.20 : B.W. - RTL code chandes due to VN Check
--                     and code coverage (I200.06.vn):
--                      * chmux_proc process modified
--*******************************************************************--

library IEEE;
  use work.utility.all;
  use ieee.std_logic_1164.all; 
  use IEEE.STD_LOGIC_UNSIGNED."-";
  use IEEE.STD_LOGIC_UNSIGNED."+";


  --*****************************************************************--
  entity DMA is
    generic(
            DATAWIDTH : INTEGER; 
            DATADEPTH : INTEGER;
            ENDIANESS : integer range 0 to 2
    );
    port (  
            ---------------------- Common ports -----------------------
            -- global clock
            clk       : in  STD_LOGIC;
            -- hardware reset
            rst       : in  STD_LOGIC;
            
            ---------------------- Configuration ----------------------
            -- channel priority
            priority  : in  STD_LOGIC_VECTOR(1 downto 0);
            -- big / little endian selection
            ble       : in  STD_LOGIC;
            -- descriptor byte ordering
            dbo       : in  STD_LOGIC;
            -- fetching receive descriptor
            rdes      : in  STD_LOGIC;
            -- fetching receive buffer
            rbuf      : in  STD_LOGIC;
            -- writing receive descriptor status
            rstat     : in  STD_LOGIC;
            -- fetching transmit descriptor
            tdes      : in  STD_LOGIC;
            -- fetching transmit buffer
            tbuf      : in  STD_LOGIC;
            -- writing transmit descriptor status
            tstat     : in  STD_LOGIC;
            
            --------------------- Data interface ----------------------
            -- data acknowledge
            dataack   : in  STD_LOGIC;
            -- data input bus
            datai     : in  STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
            -- data request
            datareq   : out STD_LOGIC;
            -- data read / not write
            datarw    : out STD_LOGIC;
            -- data end of burst
            dataeob   : out STD_LOGIC;
            dataeobe  : out STD_LOGIC;
            -- data output bus
            datao     : out STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
            -- data address
            dataaddr  : out STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
            -- internal data address
            idataaddr : out STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
            
            --------------------- Channel 1 ---------------------------
            -- request
            req1      : in  STD_LOGIC;
            -- write selection
            write1    : in  STD_LOGIC;
            -- transfer count
            tcnt1     : in  STD_LOGIC_VECTOR(FIFODEPTH_MAX-1 downto 0);
            -- start address
            addr1     : in  STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
            -- data input
            datai1    : in  STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
            -- single transfer acknowledge
            ack1      : out STD_LOGIC;
            -- end of burst
            eob1      : out STD_LOGIC;
            -- data output
            datao1    : out STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
            
            --------------------- Channel 2 ---------------------------
            -- request
            req2      : in  STD_LOGIC;
            -- write selection
            write2    : in  STD_LOGIC;
            -- transfer count
            tcnt2     : in  STD_LOGIC_VECTOR(FIFODEPTH_MAX-1 downto 0);
            -- start address
            addr2     : in  STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
            -- data input
            datai2    : in  STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
            -- single transfer acknowledge
            ack2      : out STD_LOGIC;
            -- end of burst
            eob2      : out STD_LOGIC;
            -- data output
            datao2    : out STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0)
    );
  end DMA;

--*******************************************************************--
architecture RTL of DMA is 
  
  
  -- dma state machine combinatorial
  signal dsm_c       : DMASMT;
  -- dma state machine registered
  signal dsm         : DMASMT;
  -- dma history1 registered
  signal hist1       : STD_LOGIC;
  -- dma history2 registered
  signal hist2       : STD_LOGIC;
  -- dma requests
  signal dmareq      : STD_LOGIC_VECTOR(1 downto 0);
  -- burst transfer word counter
  signal msmbcnt     : STD_LOGIC_VECTOR(FIFODEPTH_MAX-1 downto 0);
  constant msmbcnt_0 : STD_LOGIC_VECTOR(FIFODEPTH_MAX-1 downto 0) := (others=>'0');
  -- data request registered
  signal idatareq    : STD_LOGIC;
  signal idatareq_r1 : STD_LOGIC;
  signal idatareq_r2 : STD_LOGIC;
  -- end of burst registered
  signal eob         : STD_LOGIC;
  signal eobe        : STD_LOGIC;
  -- data address combinatorial
  signal addr_c      : STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
  -- data address registered
  signal addr        : STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
  -- big/little endian selection
  signal blesel_c    : STD_LOGIC;
  -- data input after big/little endian conversion
  signal dataible_c  : STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
  -- data output after big/little endian conversion
  signal dataoble_c  : STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
  -- datai of maximum length
  signal datai_max   : STD_LOGIC_VECTOR(DATAWIDTH_MAX downto 0);
  -- request combinatorial
  signal req_c       : STD_LOGIC;
  -- write selection combinatorial
  signal write_c     : STD_LOGIC;
  -- transfer count combinatorial
  signal tcnt_c      : STD_LOGIC_VECTOR(FIFODEPTH_MAX-1 downto 0);
  -- start address combinatorial
  signal saddr_c     : STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
  -- data input combinatorial
  signal datai_c     : STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
  -- data input combinatorial of maximum length
  signal datai_max_c : STD_LOGIC_VECTOR(DATAWIDTH_MAX downto 0);
  -- zero vector of FIFODEPTH_MAX length
  signal fzero       : STD_LOGIC_VECTOR(FIFODEPTH_MAX-1 downto 0);
  -- zero vector of DATAWIDTH_MAX length
  signal dzero_max   : STD_LOGIC_VECTOR(DATAWIDTH_MAX downto 0);

  signal ZERO        : STD_LOGIC_VECTOR(FIFODEPTH_MAX-1 downto 0);
  signal ONE         : STD_LOGIC_VECTOR(FIFODEPTH_MAX-1 downto 0);
  signal TWO         : STD_LOGIC_VECTOR(FIFODEPTH_MAX-1 downto 0);
  signal THREE       : STD_LOGIC_VECTOR(FIFODEPTH_MAX-1 downto 0);

begin

  ZERO   <= ( others => '0');
  ONE    <= ( 0 => '1', others => '0');
  TWO    <= ( 1 => '1', others => '0');
  THREE  <= ( 0 => '1', 1 => '1' , others => '0');

  ---------------------------------------------------------------------
  -- dma requests
  ---------------------------------------------------------------------
  dmareq_drv:
    dmareq <= req2 & req1;
  
  ---------------------------------------------------------------------
  -- dma state machine combinatorial
  ---------------------------------------------------------------------
  dsm_proc:
  process(dsm, dmareq, hist1, hist2, priority, eob, dataack)
  begin
    case dsm is
      -------------------------------------------
      when DSM_IDLE =>
      -------------------------------------------
        case dmareq is
          when "11" =>
            case priority is
              -----------------------------------
              when "01" =>
              -----------------------------------
                if hist1='0' and hist2='0' then
                  dsm_c <= DSM_CH2;
                else
                  dsm_c <= DSM_CH1;
                end if;
              -----------------------------------
              when "10" =>
              -----------------------------------
                if hist1='1' and hist2='1' then
                  dsm_c <= DSM_CH1;
                else
                  dsm_c <= DSM_CH2;
                end if;
              -----------------------------------
              when others => -- "00"
              -----------------------------------
                if hist1='1' then
                  dsm_c <= DSM_CH1;
                else
                  dsm_c <= DSM_CH2;
                end if;
            end case;
          when "01" =>
            dsm_c <= DSM_CH1;
          when "10" =>
            dsm_c <= DSM_CH2;
          when others =>
            dsm_c <= DSM_IDLE;
        end case;
      
      -------------------------------------------
      when DSM_CH1 =>
      -------------------------------------------
        if eob='1' and dataack='1' then
          dsm_c <= DSM_IDLE;
        else
          dsm_c <= DSM_CH1;
        end if;
      
      -------------------------------------------
      when others => -- DSM_CH2
      -------------------------------------------
        if eob='1' and dataack='1' then
          dsm_c <= DSM_IDLE;
        else
          dsm_c <= DSM_CH2;
        end if;
    end case;
  end process; -- dsm_proc
  
  --------------------------------------------------------------------
  -- dma state machine registered
  ---------------------------------------------------------------------
  dsm_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        dsm <= DSM_IDLE;
    elsif clk'event and clk='1' then

        dsm <= dsm_c;
    end if;
  end process; -- dsm_proc
  
  ---------------------------------------------------------------------
  -- dma history registered
  ---------------------------------------------------------------------
  hist_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        hist1 <= '1';
        hist2 <= '1';
    elsif clk'event and clk='1' then

        if eob='1' then
          case dsm is
            when DSM_CH1 => hist1 <= '1';
            when DSM_CH2 => hist1 <= '0';
            when others  => hist1 <= hist1;
          end case;
        end if;
        hist2 <= hist1;
    end if;
  end process; -- hist_reg_proc
  
  ---------------------------------------------------------------------
  -- big/little endian selection
  ---------------------------------------------------------------------
  blesel_proc:
  process(dbo, ble, dsm_c, dsm, tdes, tbuf, tstat, rdes, rbuf, rstat)
  begin
    if dsm_c=DSM_CH1 or dsm=DSM_CH1 then
      if (tbuf='1' and ble='1') or
         ((tdes='1' or tstat='1') and dbo='1')
      then
        blesel_c <= '1';
      else
        blesel_c <= '0';
      end if;
    else
      if (rbuf='1' and ble='1') or
         ((rdes='1' or rstat='1') and dbo='1')
      then
        blesel_c <= '1';
      else
        blesel_c <= '0';
      end if;
    end if;
   	case  ENDIANESS is	   -- force endianess setting
   	  when 1 => blesel_c <= '0';
   	  when 2 => blesel_c <= '1';
	  when others =>
    end case;		
  end process; -- blesel_proc

  
  ---------------------------------------------------------------------
  -- channel mux combinatorial
  ---------------------------------------------------------------------
  chmux_proc:
  process(
           dsm_c, dsm,
           req1, write1, tcnt1, addr1, datai1,
           req2, write2, tcnt2, addr2, datai2
         )
  begin
    req_c   <= req2;
    write_c <= write2;
    tcnt_c  <= tcnt2;
    saddr_c <= addr2;
    datai_c <= datai2;
    if dsm_c=DSM_CH1 or dsm=DSM_CH1 then
      req_c   <= req1;
      write_c <= write1;
      tcnt_c  <= tcnt1;
      saddr_c <= addr1;
      datai_c <= datai1;
    end if;
  end process; -- chmux_proc

  ---------------------------------------------------------------------
  -- data input combinatorial of maximum length
  ---------------------------------------------------------------------
  datai_max_c_drv:
    datai_max_c <= dzero_max(DATAWIDTH_MAX downto DATAWIDTH) & datai_c;
  
  ---------------------------------------------------------------------
  -- data output big/little endian
  ---------------------------------------------------------------------
  dataoble_proc:
  process(datai_max_c, blesel_c)
  begin
    case DATAWIDTH is
      -------------------------------------------
      when 32 =>
      -------------------------------------------
        if blesel_c='1' then
          dataoble_c <= datai_max_c( 7 downto  0) &
                        datai_max_c(15 downto  8) &
                        datai_max_c(23 downto 16) &
                        datai_max_c(31 downto 24);
        else
          dataoble_c <= datai_max_c(31 downto 0);
        end if;
        
      -------------------------------------------
      when 16 =>
      -------------------------------------------
        if blesel_c='1' then
          dataoble_c <= datai_max_c(7 downto  0) &
                        datai_max_c(15 downto 8);
        else
          dataoble_c <= datai_max_c(15 downto 0);
        end if;

      -------------------------------------------
      when others => -- 8
      -------------------------------------------
        dataoble_c <= datai_max_c(7 downto 0);
    end case;
  end process; -- dataoble_proc

  ---------------------------------------------------------------------
  -- datai of maximum length
  ---------------------------------------------------------------------
  datai_max_drv:
    datai_max <= dzero_max(DATAWIDTH_MAX downto DATAWIDTH) & datai;

  ---------------------------------------------------------------------
  -- data input big/little endian
  ---------------------------------------------------------------------
  dataible_proc:
  process(datai_max, blesel_c)
  begin
    case DATAWIDTH is
      -------------------------------------------
      when 32 =>
      -------------------------------------------
        if blesel_c='1' then
          dataible_c <= datai_max( 7 downto  0) &
                        datai_max(15 downto  8) &
                        datai_max(23 downto 16) &
                        datai_max(31 downto 24);
        else
         dataible_c <= datai_max(31 downto 0);
        end if;
        
      -------------------------------------------
      when 16 =>
      -------------------------------------------
        if blesel_c='1' then
          dataible_c <= datai_max(7  downto  0) &
                        datai_max(15 downto  8);
        else
          dataible_c <= datai_max(15 downto 0);
        end if;

      -------------------------------------------
      when others => -- 8
      -------------------------------------------
        dataible_c <= datai_max(7 downto 0);
    end case;
  end process; -- dataible_proc
  
  ---------------------------------------------------------------------
  -- master burst counter registered
  ---------------------------------------------------------------------
  msmbcnt_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        msmbcnt <= (others=>'0');
	idatareq_r1 <= '0';
        idatareq_r2 <= '0';
    elsif clk'event and clk='1' then
        idatareq_r1 <= idatareq;
        idatareq_r2 <= idatareq_r1;
        if (idatareq = '0' OR idatareq_r2 = '0') then
          msmbcnt <= tcnt_c;
        elsif ((dataack = '1') AND (idatareq = '1') AND (msmbcnt /= msmbcnt_0)) then
          msmbcnt <= msmbcnt-1;
        end if;
    end if;
  end process; -- msmbcnt_reg_proc
  
  ---------------------------------------------------------------------
  -- data read/write
  -- registered output
  ---------------------------------------------------------------------
  datarw_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        datarw <= '1';
    elsif clk'event and clk='1' then

        if req_c='1' then
          datarw <= not write_c;
        end if;
    end if;
  end process; -- datarw_reg_proc
    
  ---------------------------------------------------------------------
  -- bus request registered
  ---------------------------------------------------------------------
  idatareq_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        idatareq <= '0';
    elsif clk'event and clk='1' then

        if eob='1' and dataack='1' and idatareq='1' then
          idatareq <= '0';
        elsif req1='1' or req2='1' then
          idatareq <= '1';
        end if;
    end if;
  end process; -- idatareq_reg_proc
  
  ---------------------------------------------------------------------
  -- data request
  -- registered output
  ---------------------------------------------------------------------
  datareq_drv:
    datareq <= idatareq;
   
  
  ---------------------------------------------------------------------
  -- data end of burst
  -- registered output
  ---------------------------------------------------------------------
  dataeob_drv:
    dataeob <= eob;
  
  ---------------------------------------------------------------------
  -- data output channel1
  -- combinatorial output
  ---------------------------------------------------------------------
  datao1_drv:
    datao1 <= dataible_c;
  
  ---------------------------------------------------------------------
  -- data output channel2
  -- combinatorial output
  ---------------------------------------------------------------------
  datao2_drv:
    datao2 <= dataible_c;
  
  ---------------------------------------------------------------------
  -- data host output
  -- combinatorial output
  ---------------------------------------------------------------------
  datao_drv:
    datao <= dataoble_c;
  
  ---------------------------------------------------------------------
  -- data address combinatorial
  ---------------------------------------------------------------------
  addr_proc:
  process(dataack, idatareq, addr, saddr_c, req_c, dsm)
  begin
    if dataack='1' and idatareq='1' then
      case DATAWIDTH is
        -------------------------------------
        when 8 =>
        -------------------------------------
          addr_c <= addr+1;
        -------------------------------------
        when 16 =>
        -------------------------------------
          addr_c <= addr(DATADEPTH-1 downto 1)+1 & '0';
        -------------------------------------
        when others => -- 32
        -------------------------------------
          addr_c <= addr(DATADEPTH-1 downto 2)+1 & "00";
      end case;
    elsif req_c='1' and dsm=DSM_IDLE then
      addr_c <= saddr_c;
    else
      addr_c <= addr;
    end if;
  end process; -- addr_proc
  
  ---------------------------------------------------------------------
  -- data address registered
  ---------------------------------------------------------------------
  addr_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        addr <= (others=>'1');
    elsif clk'event and clk='1' then

        addr <= addr_c;
    end if;
  end process; -- addr_proc
  
  ---------------------------------------------------------------------
  -- data address
  -- registered output
  ---------------------------------------------------------------------
  dataaddr_drv:
    dataaddr <= addr;
  
  ---------------------------------------------------------------------
  -- internal data address
  -- combinatorial output
  ---------------------------------------------------------------------
  idataaddr_drv:
    idataaddr <= addr;

  ---------------------------------------------------------------------
  -- channel 1 acknowledge
  -- combinatorial output
  ---------------------------------------------------------------------
  ack1_drv:
    ack1 <= '1' when dataack='1' and dsm=DSM_CH1 else '0';
  
  ---------------------------------------------------------------------
  -- channel 2 acknowledge
  -- combinatorial output
  ---------------------------------------------------------------------
  ack2_drv:
    ack2 <= '1' when dataack='1' and dsm=DSM_CH2 else '0';
  
  ---------------------------------------------------------------------
  -- end of burst registered
  ---------------------------------------------------------------------
  eob_reg_proc:
    
 process(clk,rst)
  begin
    if rst = '0' then
        eob <= '0';
    elsif clk'event and clk='1' then
      if (req_c='1' or idatareq='1') then
        if (idatareq='1' and
             (
                   msmbcnt=ZERO
               or  msmbcnt=ONE
			   or (msmbcnt=TWO and dataack='1' )
             )
           )
           or
           (idatareq='0' and
             (
                   tcnt_c=ZERO 
                or tcnt_c=ONE 
             )
           )
        then
          eob <= '1';
        else
          eob <= '0';
        end if;      
       end if;
    end if;
  end process; -- eob_reg_proc
  
 -- early eob signal to allow AHB master to stop 
 -- Inserted for v3.0 of code
  
 process(clk,rst)
  begin
    if rst = '0' then
        eobe <= '0';
    elsif clk'event and clk='1' then
      if (req_c='1' or idatareq='1') then
        if (idatareq='1' and		-- during burst
             (
                    msmbcnt=ZERO 
               or   msmbcnt=ONE  
               or   msmbcnt=TWO  
               or ( msmbcnt=THREE and dataack='1' )
             )
           )
           or  (idatareq='0' and  -- starting transfer count
		     (      tcnt_c=ZERO
			    or  tcnt_c=ONE    
			    or  tcnt_c=TWO    
             )
			) 	 
        then
          eobe <= '1';
        else
          eobe <= '0';
        end if;      
       end if;
    end if;
  end process; -- eob_reg_proc
  
  dataeobe <= eobe;
  
  ---------------------------------------------------------------------
  -- channel 1 end of burst
  -- combinatorial output
  ---------------------------------------------------------------------
  eob1_drv:
    eob1 <= eob;

  ---------------------------------------------------------------------
  -- channel 2 end of burst
  -- combinatorial output
  ---------------------------------------------------------------------
  eob2_drv:
    eob2 <= eob;

  ---------------------------------------------------------------------
  -- zero vector of FIFODEPTH_MAX length
  ---------------------------------------------------------------------
  fzero_drv:
    fzero <= (others=>'0');

  ---------------------------------------------------------------------
  -- zero vector of DATAWIDTH_MAX length
  ---------------------------------------------------------------------
  dzero_max_drv:
    dzero_max <= (others=>'0');

end RTL;
--*******************************************************************--
