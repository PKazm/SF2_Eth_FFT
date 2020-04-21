-- ********************************************************************/ 
-- Copyright 2013 Actel Corporation.  All rights reserved.
-- IP Solutions Group
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED 
-- IN ADVANCE IN WRITING.  
--  
-- File:  rfifo.vhd
--     
-- Description: Core10100
--              See below  
--
-- SVN Revision Information:
-- SVN $Revision: 6737 $
-- SVN $Date: 2009-02-20 23:42:36 +0530 (Fri, 20 Feb 2009) $  
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
-- File name            : rfifo.vhd
-- File contents        : Entity HC
--                        Architecture RTL of RFIFO
-- Purpose              : Receive FIFO for MAC
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
-- 2003.03.21 : T.K. - synchronous reset in CSMEM_REG_PROC added
-- 2003.03.21 : T.K. - watchdog functionality removed
-- 2.00.E02   :
-- 2003.04.15 : T.K. - flev unused port removed
-- 2.00.E03   :
-- 2003.05.12 : T.K. - fzero signal added
-- 2003.05.12 : T.K. - condition for entering stopped state changed
-- 2.00.E06   :  
-- 2004.01.20 : T.K. - fixed mfc counter (F200.05.mfc) &
--              B.W.   statistical counters module integration
--                     support (I200.05.sc) : 
--                      * cswadi signal added
--                      * csnf_reg_proc process changed  
--
-- 2004.01.20 : B.W. - RTL code chandes due to VN Check
--                     and code coverage (I200.06.vn) :
--                      * rad_proc process modified

-- 2.00.E06a  :
-- 2004.02.20 : T.K. - cs collision seen functionality fixed (F200.06.cs)
--*******************************************************************--

library IEEE;
  use ieee.std_logic_1164.all; 
  use IEEE.STD_LOGIC_UNSIGNED."-";
  use IEEE.STD_LOGIC_UNSIGNED."+";
  use IEEE.STD_LOGIC_UNSIGNED.CONV_INTEGER;

  --*****************************************************************--
  entity RFIFO is
    generic(
            -- Data interface data bus width
            DATAWIDTH  : INTEGER := 32; -- 8|16|32|64
            -- Data interface address bus width
            DATADEPTH  : INTEGER := 32;
            -- Depth of the FIFO memory
            FIFODEPTH  : INTEGER := 9;
            -- Depth of the frame cache for FIFO
            CACHEDEPTH : INTEGER := 2
    );
    port (  
            -------------------------- common -------------------------
            -- global clock
            clk       : in  STD_LOGIC;
            -- hardware reset
            rst       : in  STD_LOGIC;
            
            -------------------------- DP RAM -------------------------
            -- ram data
            ramdata  : in  STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
            -- ram address
            ramaddr  : out STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
            
            --------------------------- RLSM --------------------------
            -- fifo read enable
            fifore   : in  STD_LOGIC;
            -- filtering fail
            ffo      : out STD_LOGIC;
            -- runt frame
            rfo      : out STD_LOGIC;
            -- multicast frame
            mfo      : out STD_LOGIC;
            -- frame too long
            tlo      : out STD_LOGIC;
            -- report on mii error
            reo      : out STD_LOGIC;
            -- dribbling bit
            dbo      : out STD_LOGIC;
            -- crc error
            ceo      : out STD_LOGIC;
            -- fifo overflow
            ovo      : out STD_LOGIC;
            -- collision seen
			      cso      : out STD_LOGIC;
            -- frame length
            flo      : out STD_LOGIC_VECTOR(13 downto 0);
            -- fifo data
            fifodata : out STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
            
            --------------------- frame status cache ------------------
            -- cache read enable
            cachere   : in  STD_LOGIC;
            -- cache not empty
            cachene   : out STD_LOGIC;
            
            ------------------------ RC control -----------------------
            -- frame status cache not full
            cachenf   : out STD_LOGIC;
            -- fifo read address grey coded
            radg      : out STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
            
            ------------------------- RC status -----------------------
            -- interrupt request
            rireq     : in  STD_LOGIC;
            -- filtering fail
            ffi       : in  STD_LOGIC;
            -- runt frame
            rfi       : in  STD_LOGIC;
            -- multicast frame
            mfi       : in  STD_LOGIC;
            -- frame too long
            tli       : in  STD_LOGIC;
            -- report on mii/gmii error
            rei       : in  STD_LOGIC;
            -- dribbling bit
            dbi       : in  STD_LOGIC;
            -- crc error
            cei       : in  STD_LOGIC;
            -- fifo overflow
            ovi       : in  STD_LOGIC;
      			-- collision seen
      			csi       : in  STD_LOGIC;
            -- frame length
            fli       : in  STD_LOGIC_VECTOR(13 downto 0);
            -- fifo write address grey coded
            wadg      : in  STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
            -- interrupt acknowledge
            riack     : out STD_LOGIC;
            
            --------------------- power management --------------------
            -- stop receive process input
            stopi    : in  STD_LOGIC;
            -- stop receive process output
            stopo    : out STD_LOGIC
    );
  end RFIFO;

--*******************************************************************--
architecture RTL of RFIFO is

  
  ------------------------- frame status cache ------------------------
  -- frame cache data width      
  
  constant CSWIDTH : INTEGER := 23;
  -- frame configuration cache type
  type CSMEMT is array (2**CACHEDEPTH-1 downto 0) of
                        STD_LOGIC_VECTOR(CSWIDTH-1 downto 0); 
  -- frame configuration cache
  signal csmem     : CSMEMT;
  -- frame cache write enable
  signal cswe    : STD_LOGIC;
  -- frame cache read enable
  signal csre    : STD_LOGIC;
  -- frame cache not full
  signal csnf    : STD_LOGIC;
  -- frame cache not empty
  signal csne    : STD_LOGIC;
  -- frame cache write address
  signal cswad   : STD_LOGIC_VECTOR(CACHEDEPTH-1 downto 0);
  -- frame cache read address incremented
  signal cswad_i : STD_LOGIC_VECTOR(CACHEDEPTH-1 downto 0);
  -- frame cache read address
  signal csrad   : STD_LOGIC_VECTOR(CACHEDEPTH-1 downto 0);
  -- frame cache write address registered
  signal csrad_r : STD_LOGIC_VECTOR(CACHEDEPTH-1 downto 0);
  -- frame cache write data
  signal csdi    : STD_LOGIC_VECTOR(CSWIDTH-1 downto 0);
  -- frame cache read data
  signal csdo    : STD_LOGIC_VECTOR(CSWIDTH-1 downto 0);
  
  
  ------------------------------- fifo --------------------------------
  -- fifo status registered
  signal stat       : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- fifo read address combinatorial
  signal rad_c      : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- fifo read address registered
  signal rad        : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- fifo write address combinatorial
  signal wad_c      : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- fifo write address registered
  signal wad        : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- fifo write address grey coded registered
  signal wadg_r     : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- frame length binary combinatorial
  signal flibin_c   : STD_LOGIC_VECTOR(13 downto 0);
  -- frame length binary registered
  signal flibin     : STD_LOGIC_VECTOR(13 downto 0);
  
  -------------------------- receive status ---------------------------
  -- interrupt registered
  signal rireq_r    : STD_LOGIC;
  -- interrupt acknowledge
  signal iriack     : STD_LOGIC;
  
  -------------------------- power management -------------------------
  -- stop receive process registered
  signal stop_r      : STD_LOGIC;
  
  ----------------------------- others --------------------------------
  signal fzero       : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);

  -- frame length
  signal fli_r       : STD_LOGIC_VECTOR(13 downto 0);
begin
  
  
  ---------------------------------------------------------------------
  --                        frame status cache                       --
  ---------------------------------------------------------------------
  
  ---------------------------------------------------------------------
  -- frame status cache registered
  ---------------------------------------------------------------------
  csmem_reg_proc:

process(clk,rst,csrad)
  begin
    if rst = '0' then
        for i in 2**CACHEDEPTH-1 downto 0 loop
          csmem(i) <= (others=>'0');
        end loop;
        csrad_r <= (others=>'0');
    elsif clk'event and clk='1' then

        csmem(CONV_INTEGER(cswad)) <= csdi;
        csrad_r <= csrad;
    end if;
  end process; -- csmem_reg_proc
  
  ---------------------------------------------------------------------
  -- frame status cache write address
  ---------------------------------------------------------------------
  cswad_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        cswad <= (others=>'1');
    elsif clk'event and clk='1' then

        if cswe='1' then
          cswad <= cswad + 1;
        end if;
    end if;
  end process; -- cswad_reg_proc
  
  ---------------------------------------------------------------------
  -- frame ststus cache read address
  ---------------------------------------------------------------------
  csrad_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        csrad <= (others=>'1');
    elsif clk'event and clk='1' then

        if csre='1' then
          csrad <= csrad + 1;
        end if;
    end if;
  end process; -- csrad_reg_proc
  
  ---------------------------------------------------------------------
  -- frame status cache not empty registered
  ---------------------------------------------------------------------
  csne_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        csne <= '0';
    elsif clk'event and clk='1' then

        if cswad=csrad then
          csne <= '0';
        else
          csne <= '1';
        end if;
    end if;
  end process; -- csne_reg_proc
  ---------------------------------------------------------------------
  -- frame status cache not full incremented
  ---------------------------------------------------------------------
  csnf_drv:
    cswad_i <= cswad +1;
  
  ---------------------------------------------------------------------
  -- frame status cache not full registered
  ---------------------------------------------------------------------
  csnf_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        csnf <= '0';
    elsif clk'event and clk='1' then
        if cswad_i=csrad then
          csnf <= '0';
        else
          csnf <= '1';
        end if;
    end if;
  end process; -- csnf_reg_proc
  
  ---------------------------------------------------------------------
  -- frame length binary combinatorial
  ---------------------------------------------------------------------
  flibin_proc:
  process(fli_r)
    variable flibin_v : STD_LOGIC_VECTOR(13 downto 0);
  begin
    flibin_v(13) := fli_r(13);
    for i in 12 downto 0 loop
      flibin_v(i) := flibin_v(i+1) xor fli_r(i);
    end loop;
    flibin_c <= flibin_v;
  end process; -- flibin_proc
  
  ---------------------------------------------------------------------
  -- fifo addresses binary registered
  ---------------------------------------------------------------------
  flibin_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        fli_r <= (others=>'0');
        flibin <= (others=>'0');
    elsif clk'event and clk='1' then
        fli_r <= fli;
        flibin <= flibin_c;
    end if;
  end process; -- flibin_reg_proc
  
  ---------------------------------------------------------------------
  -- frame status cache not empty
  -- registered output
  ---------------------------------------------------------------------
  cachene_drv:
    cachene <= csne;
  
  ---------------------------------------------------------------------
  -- frame status cache not full
  -- registered output
  ---------------------------------------------------------------------
  cachenf_drv:
    cachenf <= csnf;
  
  ---------------------------------------------------------------------
  -- frame status cache write enable
  ---------------------------------------------------------------------
  cswe_drv:
    cswe <= rireq_r and not iriack;

  ---------------------------------------------------------------------
  -- frame status cache data output
  ---------------------------------------------------------------------
  csdo_drv:
    csdo <= csmem(CONV_INTEGER(csrad_r));

  ---------------------------------------------------------------------
  -- frame status cache data input
  ---------------------------------------------------------------------
  csdi_drv:
    csdi <= ffi & rfi & mfi & tli & rei &
            dbi & cei & ovi & csi & flibin;
    
  ---------------------------------------------------------------------
  -- filtering fail
  -- combinatorial output
  ---------------------------------------------------------------------
  ffo_drv:
    ffo <= csdo(CSWIDTH-1);
  
  ---------------------------------------------------------------------
  -- runt frame
  -- combinatorial output
  ---------------------------------------------------------------------
  rfo_drv:
    rfo <= csdo(CSWIDTH-2);
  
  ---------------------------------------------------------------------
  -- multicast frame
  -- combinatorial output
  ---------------------------------------------------------------------
  mfo_drv:
    mfo <= csdo(CSWIDTH-3);
  
  ---------------------------------------------------------------------
  -- too long
  -- combinatorial output
  ---------------------------------------------------------------------
  tlo_drv:
    tlo <= csdo(CSWIDTH-4);
  
  ---------------------------------------------------------------------
  -- report on mii error
  -- combinatorial output
  ---------------------------------------------------------------------
  reo_drv:
    reo <= csdo(CSWIDTH-5);
  
  
  ---------------------------------------------------------------------
  -- report on gmii/mii error
  -- combinatorial output
  ---------------------------------------------------------------------
  dbo_drv:
    dbo <= csdo(CSWIDTH-6);
  
  ---------------------------------------------------------------------
  -- crc error
  -- combinatorial output
  ---------------------------------------------------------------------
  ceo_drv:
    ceo <= csdo(CSWIDTH-7);
  
  ---------------------------------------------------------------------
  -- fifo overflow
  -- combinatorial output
  ---------------------------------------------------------------------
  ovo_drv:
    ovo <= csdo(CSWIDTH-8);
  
  ---------------------------------------------------------------------
  -- collision seen
  -- combinatorial output
  ---------------------------------------------------------------------
  cso_drv:
  	cso <= csdo(CSWIDTH-9);
  
  ---------------------------------------------------------------------
  -- frame length
  -- combinatorial output
  ---------------------------------------------------------------------
  flo_drv:
    flo <= csdo(13 downto 0);
  
  ---------------------------------------------------------------------
  -- frame status cache read enable
  ---------------------------------------------------------------------
  csre_drv:
    csre <= cachere;
  
  
  ---------------------------------------------------------------------
  --                            rc status                            --
  ---------------------------------------------------------------------
  
  ---------------------------------------------------------------------
  -- interrupt registered
  ---------------------------------------------------------------------
  rireq_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        rireq_r <= '0';
    elsif clk'event and clk='1' then

        rireq_r <= rireq;
    end if;
  end process; -- rireq_reg_proc
  
  ---------------------------------------------------------------------
  -- receive acknowledge
  ---------------------------------------------------------------------
  irecack_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        iriack <= '0';
    elsif clk'event and clk='1' then

        iriack <= rireq_r;
    end if;
  end process; -- irecack_reg_proc
  
  ---------------------------------------------------------------------
  -- interrupt acknowledge
  -- registered output
  ---------------------------------------------------------------------
  riack_drv:
    riack <= iriack;
  
  

--===================================================================--
--                                fifo                               --
--===================================================================--
  
  ---------------------------------------------------------------------
  -- fifo read address combinatorial
  ---------------------------------------------------------------------
  rad_proc:
  process(rad, fifore)
  begin
    rad_c <= rad;
    if fifore='1' then
      rad_c <= rad+1;
    end if;
  end process; -- rad_proc
  
  ---------------------------------------------------------------------
  -- fifo read address registered
  ---------------------------------------------------------------------
  rad_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        rad <= (others=>'0');
    elsif clk'event and clk='1' then

        rad <= rad_c;
    end if;
  end process;
  
  ---------------------------------------------------------------------
  -- fifo read address grey coded registered
  ---------------------------------------------------------------------
  radg_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        radg <= (others=>'0');
    elsif clk'event and clk='1' then

        radg(FIFODEPTH-1) <= rad(FIFODEPTH-1);
        for i in FIFODEPTH-2 downto 0 loop
          radg(i) <= rad(i) xor rad(i+1);
        end loop;
    end if;
  end process; -- radg_reg_proc
  
  ---------------------------------------------------------------------
  -- write address grey coded registered
  ---------------------------------------------------------------------
  wadg_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        wadg_r <= (others=>'0');
    elsif clk'event and clk='1' then

        wadg_r <= wadg;
    end if;
  end process; -- wad_reg_proc
  
  ---------------------------------------------------------------------
  -- write address binary combinatorial
  ---------------------------------------------------------------------
  wad_proc:
  process(wadg_r)
    variable wad_v : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  begin
    wad_v(FIFODEPTH-1) := wadg_r(FIFODEPTH-1);
    for i in FIFODEPTH-2 downto 0 loop
      wad_v(i) := wad_v(i+1) xor wadg_r(i);
    end loop;
    wad_c <= wad_v;
  end process; -- wad_proc
  
  ---------------------------------------------------------------------
  -- fifo addresses binary registered
  ---------------------------------------------------------------------
  ad_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        wad <= (others=>'0');
    elsif clk'event and clk='1' then

        wad <= wad_c;
    end if;
  end process; -- ad_reg_proc
  
  ---------------------------------------------------------------------
  -- fifo status registered
  ---------------------------------------------------------------------
  stat_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        stat <= (others=>'0');
    elsif clk'event and clk='1' then

        stat <= wad - rad;
    end if;
  end process; -- stat_reg_proc
  
  ---------------------------------------------------------------------
  -- DP RAM address
  -- combinatorial output
  ---------------------------------------------------------------------
  ramaddr_drv:
    ramaddr <= rad_c;
  
  ---------------------------------------------------------------------
  -- FIFO data
  -- redirection
  ---------------------------------------------------------------------
  ramdata_drv:
    fifodata <= ramdata;



  --=================================================================--
  --                       power management                          --
  --=================================================================--

  ---------------------------------------------------------------------
  -- stop receive process registered
  ---------------------------------------------------------------------
  stop_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        stop_r <= '1';
    elsif clk'event and clk='1' then

        stop_r <= stopi;
    end if;
  end process; -- stop_reg_proc
  
  ---------------------------------------------------------------------
  -- stop receive process output
  -- registered output
  ---------------------------------------------------------------------
  stopo_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        stopo <= '0';
    elsif clk'event and clk='1' then

        -- can enter stopped state if the receive fifo
        -- and the receive cache are both empty
        -- i.e no frame waiting for transfer to the host
        if stop_r='1' and stat=fzero and csne='0' then
          stopo <= '1';
        else
          stopo <= '0';
        end if;
    end if;
  end process; -- stopo_reg_proc
  
  
--===================================================================--
--                               others                              --
--===================================================================--

  fzero_drv:
    fzero <= (others=>'0');

end RTL;
--*******************************************************************--
