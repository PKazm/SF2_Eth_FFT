-- ********************************************************************/ 
-- Copyright 2013 Actel Corporation.  All rights reserved.
-- IP Solutions Group
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED 
-- IN ADVANCE IN WRITING.  
--  
-- File:  tfifo.vhd
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
-- File name            : tfifo.vhd
-- File contents        : Entity TFIFO
--                        Architecture RTL of TFIFO
-- Purpose              : Transmit FIFO for MAC
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
-- 2003.03.21 : T.K. - references to 64-bit wide data bus removed
-- 2003.03.21 : T.K. - synchronous reset in CCMEM_REG_PROC added
-- 2003.03.21 : T.K. - synchronous reset in CSMEM_REG_PROC added
-- 2003.03.21 : T.K. - frame status read enable is now registered
-- 2.00.E02   :
-- 2003.04.15 : T.K. - csnf unused port removed
-- 2003.04.15 : T.K. - synchronous processes merged
-- 2.00.E03   :
-- 2003.05.12 : T.K. - fzero signal added
-- 2003.05.12 : T.K. - icsne signal added
-- 2003.05.12 : T.K. - condition for entering stopper state changed
-- 2.00.E06   :  
-- 2004.01.20 : B.W. - fixed transmit frame descriptor status
--                     assignment(F200.05.tx_status)
--                      * csmem_reg_proc process changed  
-- 2.00.E07   :
-- 2004.03.22 : T.K. - unused comments removed
--*******************************************************************--

library IEEE;
  use work.utility.all;
  use ieee.std_logic_1164.all; 
  use IEEE.STD_LOGIC_UNSIGNED."-";
  use IEEE.STD_LOGIC_UNSIGNED."+";
  use IEEE.STD_LOGIC_UNSIGNED.CONV_INTEGER;


  use work.utility.all;

  --*****************************************************************--
  entity TFIFO is
    generic(
            -- Data interface data bus width
            DATAWIDTH  : INTEGER := 32; -- 8|16|32
            -- Data interface address bus width
            DATADEPTH  : INTEGER := 32;
            -- Depth of the transmit and the receive FIFO memories
            FIFODEPTH  : INTEGER := 9;
            -- Depth of the frame cache for the transmit FIFO
            CACHEDEPTH : INTEGER := 1
    );
    port (  
            ---------------------- Common ports -----------------------
            -- global clock
            clk       : in  STD_LOGIC;
            -- hardware reset
            rst       : in  STD_LOGIC;
            
            ------------------------- DP RAM --------------------------
            -- ram write enable
            ramwe    : out STD_LOGIC;
            -- ram address
            ramaddr  : out STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
            -- ram data
            ramdata  : out STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
            
            -------------------------- TLSM ----------------------------
            -- fifo write enable
            fifowe   : in  STD_LOGIC;
            -- fifo end of frame
            fifoeof  : in  STD_LOGIC;
            -- fifo last byte enable
            fifobe   : in  STD_LOGIC_VECTOR(DATAWIDTH/8-1 downto 0);
            -- fifo data
            fifodata : in  STD_LOGIC_VECTOR(DATAWIDTH-1 downto 0);
            -- fifo not full
            fifonf   : out STD_LOGIC;
            -- frame cache not full
            fifocnf  : out STD_LOGIC;
            -- fifo valid
            fifoval  : out STD_LOGIC;
            -- fifo level
            flev     : out STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
            
            ------------------ frame configuration cache --------------
            -- interrupt on completition
            ici       : in  STD_LOGIC;
            -- disabled padding
            dpdi      : in  STD_LOGIC;
            -- add crc disable
            aci       : in  STD_LOGIC;
            -- frame status address (for TLSM only)
            statadi   : in  STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
            
            --------------------- frame status cache ------------------
            -- cache read enable
            cachere   : in  STD_LOGIC;
            -- deferred
            deo       : out STD_LOGIC;
            -- late collission
            lco       : out STD_LOGIC;
            -- loss of carrier
            loo       : out STD_LOGIC;
            -- no carrier
            nco       : out STD_LOGIC;
            -- excessive collisions
            eco       : out STD_LOGIC;
            -- cache not empty
            csne      : out STD_LOGIC;
            -- interrupt on completition
            ico       : out STD_LOGIC;
            -- underrun
            uro       : out STD_LOGIC;
            -- collision count
            cco       : out STD_LOGIC_VECTOR(3 downto 0);
            -- frame status address (for TLSM only)
            statado   : out STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
            
            
            ------------------------ TC control ------------------------
            -- start of frame request
            sofreq    : out STD_LOGIC;
            -- end of frame request
            eofreq    : out STD_LOGIC;
            -- disabled padding
            dpdo      : out STD_LOGIC;
            -- add crc disable
            aco       : out STD_LOGIC;
            -- last byte enable
            beo       : out STD_LOGIC_VECTOR(DATAWIDTH/8-1 downto 0);
            -- end of frame fifo address
            eofad     : out STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
            -- fifo write address grey coded
            wadg      : out STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
            
            ------------------------- TC status -----------------------
            -- transmit interrupt
            tireq     : in  STD_LOGIC;
            -- collision window passed
            winp      : in  STD_LOGIC;
            -- deferred
            dei       : in  STD_LOGIC;
            -- late collission
            lci       : in  STD_LOGIC;
            -- loss of carrier
            loi       : in  STD_LOGIC;
            -- no carrier
            nci       : in  STD_LOGIC;
            -- excessive collisions
            eci       : in  STD_LOGIC;
            -- underrun
            uri       : in  STD_LOGIC;
            -- collision count
            cci       : in  STD_LOGIC_VECTOR(3 downto 0);
            -- fifo read address grey coded
            radg      : in  STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
            -- transmit interrupt acknowledge
            tiack     : out STD_LOGIC;
            
            ------------------ CSR configuration data -----------------
            -- store and forward mode
            sf        : in  STD_LOGIC;
            -- full duplex mode
            fdp       : in  STD_LOGIC;
            -- treshold mode
            tm        : in  STD_LOGIC_VECTOR(2 downto 0);
            -- programmable burst length
            pbl       : in  STD_LOGIC_VECTOR(5 downto 0);
            
            ----------------------- CSR status ------------------------
            -- early transmit interrupt acknowledge
            etiack    : in  STD_LOGIC;
            -- early transmit interrupt request
            etireq    : out STD_LOGIC;
            
            --------------------- power management --------------------
            -- stop transmit process input
            stopi    : in  STD_LOGIC;
            -- stop transmit process output
            stopo    : out STD_LOGIC
    );
  end TFIFO;

--*******************************************************************--
architecture RTL of TFIFO is

  --------------------- frame configuration cache ---------------------
  -- frame configuration cache data width
  constant CCWIDTH : INTEGER
                   := (3 + DATADEPTH + DATAWIDTH/8 + FIFODEPTH);
  -- frame configuration cache type
  type CCMEMT is array (2**CACHEDEPTH-1 downto 0) of
                        STD_LOGIC_VECTOR(CCWIDTH-1 downto 0); 
  -- frame configuration cache
  signal ccmem     : CCMEMT;
  -- frame cache write enable
  signal ccwe      : STD_LOGIC;
  -- frame cache read enable
  signal ccre      : STD_LOGIC;
  -- frame cache not empty
  signal ccne      : STD_LOGIC;
  -- frame cache not full
  signal iccnf     : STD_LOGIC;
  -- frame cache read address combinatorial
  signal ccwad_c   : STD_LOGIC_VECTOR(CACHEDEPTH-1 downto 0);
  -- frame cache read address registered
  signal ccwad     : STD_LOGIC_VECTOR(CACHEDEPTH-1 downto 0);
  -- frame cache write address
  signal ccrad     : STD_LOGIC_VECTOR(CACHEDEPTH-1 downto 0);
  -- frame cache write enable double registered
  signal ccrad_r   : STD_LOGIC_VECTOR(CACHEDEPTH-1 downto 0);
  -- frame cache write data
  signal ccdi      : STD_LOGIC_VECTOR(CCWIDTH-1 downto 0);
  -- frame cache read data
  signal ccdo      : STD_LOGIC_VECTOR(CCWIDTH-1 downto 0);
  
  -------------------------- frame status cache -----------------------
  -- frame status cache data width
  constant CSWIDTH : INTEGER := (DATADEPTH + 11);
  -- frame status cache type
  type CSMEMT is array (2**CACHEDEPTH-1 downto 0) of
                        STD_LOGIC_VECTOR(CSWIDTH-1 downto 0); 
  -- frame status cache
  signal csmem    : CSMEMT;
  -- frame cache write enable
  signal cswe     : STD_LOGIC;
  -- frame cache read enable
  signal csre     : STD_LOGIC;
  -- frame cache read address
  signal cswad    : STD_LOGIC_VECTOR(CACHEDEPTH-1 downto 0);
  -- frame cache write address combinatorial
  signal csrad_c  : STD_LOGIC_VECTOR(CACHEDEPTH-1 downto 0);
  -- frame cache write address registered
  signal csrad    : STD_LOGIC_VECTOR(CACHEDEPTH-1 downto 0);
  -- frame cache write address registered
  signal csrad_r  : STD_LOGIC_VECTOR(CACHEDEPTH-1 downto 0);
  -- frame cache write data
  signal csdi     : STD_LOGIC_VECTOR(CSWIDTH-1 downto 0);
  -- frame cache read data
  signal csdo     : STD_LOGIC_VECTOR(CSWIDTH-1 downto 0);
  -- frame descriptor status address
  signal statad   : STD_LOGIC_VECTOR(DATADEPTH-1 downto 0);
  -- interrupt on completition
  signal ic       : STD_LOGIC;
  -- internal frame cache not empty
  signal icsne    : STD_LOGIC;
  
  -------------------------- transmit control -------------------------
  -- transmit in progress
  signal tprog    : STD_LOGIC;
  -- transmit in progress registered
  signal tprog_r  : STD_LOGIC;
  
  
  -------------------------------- FIFO -------------------------------
  -- collision window passed registered
  signal winp_r    : STD_LOGIC;
  -- fifo treshold level combinatorial
  signal tlev_c    : STD_LOGIC_VECTOR(FIFODEPTH_MAX-1 downto 0);
  -- fifo treshold level registered
  signal tresh     : STD_LOGIC;
  -- fifo status registered
  signal stat      : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- fifo write address registered
  signal wad       : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- fifo read address combinatorial
  signal rad_c     : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- fifo read address registered
  signal rad       : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- fifo read grey coded address registered
  signal radg_r    : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- fifo start address
  signal sad       : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- eond of frame address binary
  signal eofad_bin : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- programmable burst length=0 registered
  signal pblz      : STD_LOGIC;
  -- free fifo space combinatorial
  signal sflev_c   : STD_LOGIC_VECTOR(FIFODEPTH_MAX-1 downto 0);
  
  ------------------------- transmit control --------------------------
  -- transmit interrupt request registered
  signal tireq_r  : STD_LOGIC;
  -- transmit interrupt request double registered
  signal tireq_r2 : STD_LOGIC;
  
  ------------------------- power management --------------------------
  -- stop transmit process registered
  signal stop_r  : STD_LOGIC;
  
  ------------------------------ others -------------------------------
  -- all ones vector for fifo
  signal fone     : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  -- all zeros vector for fifo
  signal fzero    : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);


begin
  ---------------------------------------------------------------------
  --                    Frame configuration cache                    --
  ---------------------------------------------------------------------
  
  ---------------------------------------------------------------------
  -- frame configuration cache memory registered
  ---------------------------------------------------------------------
  ccmem_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        for i in 2**CACHEDEPTH-1 downto 0 loop
          ccmem(i) <= (others=>'0');
        end loop;
        ccrad_r <= (others=>'0');
    elsif clk'event and clk='1' then

        if fifowe='1' or fifoeof='1' then
          ccmem(CONV_INTEGER(ccwad)) <= ccdi;
        end if;
        ccrad_r <= ccrad;
    end if;
  end process; -- ccmem_reg_proc
  
  ---------------------------------------------------------------------
  -- frame configuration cache write address combinatorial
  ---------------------------------------------------------------------
  ccwad_drv:
    ccwad_c <= ccwad+1 when fifoeof='1' else ccwad;
  
  ---------------------------------------------------------------------
  -- frame configuration cache address registered
  ---------------------------------------------------------------------
  ccaddr_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        ccwad <= (others=>'0');
        ccrad <= (others=>'0');
    elsif clk'event and clk='1' then

        -- write address
        ccwad <= ccwad_c;
      
        -- read address
        if ccre='1' then
          ccrad <= ccrad+1;
        end if;
    end if;
  end process; -- ccaddr_reg_proc
  
  ---------------------------------------------------------------------
  -- frame configuration cache full/empty logic
  ---------------------------------------------------------------------
  ccfe_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        iccnf <= '1';
        ccne  <= '0';
    elsif clk'event and clk='1' then

        -- not full
        if (ccwad_c=ccrad) and ccwe='1' then
          iccnf <= '0';
        elsif ccre='1' then
          iccnf <= '1';
        end if;
        
        -- not empty
        if ccwad=ccrad and iccnf='1' then
          ccne <= '0';
        else
          ccne <= '1';
        end if;
    end if;
  end process; -- ccnf_reg_proc
  
  ---------------------------------------------------------------------
  -- frame configuration cache not full
  -- registered output
  ---------------------------------------------------------------------
  ccnf_drv:
    fifocnf <= iccnf;

  ---------------------------------------------------------------------
  -- frame configuration cache data output
  ---------------------------------------------------------------------
  ccdo_drv:
    ccdo <= ccmem(CONV_INTEGER(ccrad_r));

  ---------------------------------------------------------------------
  -- frame configuration cache data input
  ---------------------------------------------------------------------
  ccdi_drv:
    ccdi <= ici & aci & dpdi & wad & fifobe & statadi;
  
  ---------------------------------------------------------------------
  -- frame configuration cache write enable
  -- write configuration after end of fetching frame via dma
  ---------------------------------------------------------------------
  ccwe_drv:
    ccwe <= fifoeof;
  
  ---------------------------------------------------------------------
  -- frame configuration cache read enable
  -- read configuration after end of previous transmission
  ---------------------------------------------------------------------
  ccre_drv:
    ccre <= tireq_r and not tireq_r2;
    
  ---------------------------------------------------------------------
  -- interrupt on completition
  ---------------------------------------------------------------------
  ic_drv:
    ic <= ccdo(CCWIDTH-1);
  
  ---------------------------------------------------------------------
  -- add crc disable
  -- combinatorial output
  ---------------------------------------------------------------------
  aco_drv:
    aco <= ccdo(CCWIDTH-2);
  
  ---------------------------------------------------------------------
  -- disabled padding
  -- combinatorial output
  ---------------------------------------------------------------------
  dpdo_drv:
    dpdo <= ccdo(CCWIDTH-3);
  
  ---------------------------------------------------------------------
  -- end of frame fifo address binary
  ---------------------------------------------------------------------
  eofad_bin_drv:
    eofad_bin <= ccdo(CCWIDTH-4 downto CCWIDTH-3-FIFODEPTH);
  
  ---------------------------------------------------------------------
  -- internal fifo write address grey coded
  -- registered output
  ---------------------------------------------------------------------
  eofad_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        eofad <= (others=>'0');
    elsif clk'event and clk='1' then

        eofad(FIFODEPTH-1) <= eofad_bin(FIFODEPTH-1);
        for i in FIFODEPTH-2 downto 0 loop
          eofad(i) <= eofad_bin(i) xor eofad_bin(i+1);
        end loop;
    end if;
  end process; -- eofad_reg_proc
  
  ---------------------------------------------------------------------
  -- last fifo byte enable
  -- combinatorial output
  ---------------------------------------------------------------------
  beo_drv:
    beo <= ccdo(DATADEPTH+DATAWIDTH/8-1 downto DATADEPTH);
  
  ---------------------------------------------------------------------
  -- frame descriptor status
  -- combinatorial output
  ---------------------------------------------------------------------
  statad_drv:
    statad <= ccdo(DATADEPTH-1 downto 0);
  
  
  ---------------------------------------------------------------------
  --                        Frame status cache                       --
  ---------------------------------------------------------------------
  
  ---------------------------------------------------------------------
  -- frame status cache registered
  ---------------------------------------------------------------------
  csmem_reg_proc:

process(clk,rst)
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
  -- frame status cache address
  ---------------------------------------------------------------------
  csaddr_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        cswad <= (others=>'0');
        csrad <= (others=>'0');
    elsif clk'event and clk='1' then

        -- write address
        if cswe='1' then
          cswad <= cswad+1;
        end if;
        
        -- read address
        csrad <= csrad_c;
    end if;
  end process; -- csaddr_reg_proc
  
  ---------------------------------------------------------------------
  -- frame status cache read address combinatorial
  ---------------------------------------------------------------------
  csrad_drv:
    csrad_c <= csrad+1 when csre='1' else
               csrad;
  
  ---------------------------------------------------------------------
  -- frame status cache empty logic
  -- registered output
  ---------------------------------------------------------------------
  icsne_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        icsne <= '0';
    elsif clk'event and clk='1' then

        -- not empty
        if cswad=csrad or (csre='1' and cswad=csrad_c) then
          icsne <= '0';
        else
          icsne <= '1';
        end if;
    end if;
  end process; -- icsne_reg_proc
  
  ---------------------------------------------------------------------
  -- frame status cache not empty
  -- registered output
  ---------------------------------------------------------------------
  csne_drv:
    csne <= icsne;

  ---------------------------------------------------------------------
  -- frame status cache data output
  ---------------------------------------------------------------------
  csdo_drv:
    csdo <= csmem(CONV_INTEGER(csrad_r));

  ---------------------------------------------------------------------
  -- frame status cache data input
  ---------------------------------------------------------------------
  csdi_drv:
    csdi <= dei & lci & loi & nci & eci & ic & cci & uri & statad;
    
  ---------------------------------------------------------------------
  -- deferred
  -- combinatorial output
  ---------------------------------------------------------------------
  deo_drv:
    deo <= csdo(CSWIDTH-1);
  
  ---------------------------------------------------------------------
  -- late collision
  -- combinatorial output
  ---------------------------------------------------------------------
  lco_drv:
    lco <= csdo(CSWIDTH-2);
  
  ---------------------------------------------------------------------
  -- loss of carrier
  -- combinatorial output
  ---------------------------------------------------------------------
  loo_drv:
    loo <= csdo(CSWIDTH-3);
  
  ---------------------------------------------------------------------
  -- no carrier
  -- combinatorial output
  ---------------------------------------------------------------------
  nco_drv:
    nco <= csdo(CSWIDTH-4);
  
  ---------------------------------------------------------------------
  -- excessive collision
  -- combinatorial output
  ---------------------------------------------------------------------
  eco_drv:
    eco <= csdo(CSWIDTH-5);

  ---------------------------------------------------------------------
  -- interrupt on completition output
  -- combinatorial output
  ---------------------------------------------------------------------
  ico_drv:
    ico <= csdo(CSWIDTH-6);
  
  ---------------------------------------------------------------------
  -- collision count
  -- combinatorial output
  ---------------------------------------------------------------------
  cco_drv:
    cco <= csdo(CSWIDTH-7 downto CSWIDTH-10);
    
  ---------------------------------------------------------------------
  -- underrun
  -- combinatorial output
  ---------------------------------------------------------------------
  uro_drv:
    uro <= csdo(CSWIDTH-11);
  
  ---------------------------------------------------------------------
  -- frame descriptor address
  -- combinatorial output
  ---------------------------------------------------------------------
  statado_drv:
    statado <= csdo(DATADEPTH-1 downto 0);
  
  ---------------------------------------------------------------------
  -- frame status cache write enable
  ---------------------------------------------------------------------
  cswe_drv:
    cswe <= tireq_r and tprog;
  
  ---------------------------------------------------------------------
  -- frame status cache read enable registered
  ---------------------------------------------------------------------
  csre_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        csre <= '0';
    elsif clk'event and clk='1' then

        csre <= cachere;
    end if;
  end process; -- csre_reg_proc
  
  
  ---------------------------------------------------------------------
  --                           TC control                            --
  ---------------------------------------------------------------------
  
  ---------------------------------------------------------------------
  -- transmit in progress registered
  ---------------------------------------------------------------------
  tprog_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        tprog   <= '0';
        tprog_r <= '0';
    elsif clk'event and clk='1' then

        tprog_r <= tprog;
        if tireq_r='1' then
          tprog <= '0';
        elsif (sf='0' and tprog='0' and tireq_r='0' and tresh='1') or
            ccne='1'
        then
          tprog <= '1';
        end if;
    end if;
  end process; -- tprog_reg_proc
        
  
  ---------------------------------------------------------------------
  -- end of frame
  -- registered output
  ---------------------------------------------------------------------
  eofreq_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        eofreq <= '0';
    elsif clk'event and clk='1' then

        if tprog='1' and ccne='1' then
          eofreq <= '1';
        elsif tireq_r='1' then
          eofreq <= '0';
        end if;
    end if;
  end process; -- eofreq_reg_proc
  
  ---------------------------------------------------------------------
  -- transmit interrupt registered
  ---------------------------------------------------------------------
  tireq_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        tireq_r  <= '0';
        tireq_r2 <= '0';
    elsif clk'event and clk='1' then

        tireq_r  <= tireq;
        tireq_r2 <= tireq_r;
    end if;
  end process; -- tireq_reg_proc
  
  ---------------------------------------------------------------------
  -- early transmit interrupt request
  -- registered output
  ---------------------------------------------------------------------
  etireq_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        etireq <= '0';
    elsif clk'event and clk='1' then

        if fifoeof='1' then
          etireq <= '1';
        elsif etiack='1' then
          etireq <= '0';
        end if;
    end if;
  end process; -- etireq_reg_proc
  
  ---------------------------------------------------------------------
  -- transmit interrput acknowledge
  -- registered output
  ---------------------------------------------------------------------
  tiack_drv:
    tiack <= tireq_r2;
  
  ---------------------------------------------------------------------
  -- start of frame request
  -- registered output
  ---------------------------------------------------------------------
  sofreq_drv:
    sofreq <= tprog;
  
  

--===================================================================--
--                                FIFO                               --
--===================================================================--
  
  ---------------------------------------------------------------------
  -- fifo address registered
  ---------------------------------------------------------------------
  addr_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        wad    <= (others=>'0');
        wadg   <= (others=>'0');
        radg_r <= (others=>'0');
        rad    <= (others=>'0');
        sad    <= (others=>'0');
    elsif clk'event and clk='1' then

        -- write address
        if fifowe='1' then
          wad <= wad+1;
        end if;
        
        -- write address grey coded
        wadg(FIFODEPTH-1) <= wad(FIFODEPTH-1);
        for i in FIFODEPTH-2 downto 0 loop
          wadg(i) <= wad(i) xor wad(i+1);
        end loop;
        
        -- read address grey coded
        radg_r <= radg;
        
        -- read address binary
        rad <= rad_c;
        
        -- start of frame address
        -- the end address of the last transmitted frame
        if tprog='0' and tprog_r='1' then
          sad <= eofad_bin;
        end if;
    end if;
  end process; -- addr_reg_proc
  
  ---------------------------------------------------------------------
  -- read address binary combinatorial
  ---------------------------------------------------------------------
  rad_proc:
  process(radg_r)
    variable rad_v : STD_LOGIC_VECTOR(FIFODEPTH-1 downto 0);
  begin
    rad_v(FIFODEPTH-1) := radg_r(FIFODEPTH-1);
    for i in FIFODEPTH-2 downto 0 loop
      rad_v(i) := rad_v(i+1) xor radg_r(i);
    end loop;
    rad_c <= rad_v;
  end process; -- rad_proc
  
  ---------------------------------------------------------------------
  -- transmit fifo status registered
  ---------------------------------------------------------------------
  stat_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        stat <= (others=>'0');
    elsif clk'event and clk='1' then

        if (winp_r='0' and fdp='0' and tprog='1' and tireq_r='0') or
           tprog_r='0'
        then
          stat <= wad - sad;
        else
          stat <= wad - rad;
        end if;
    end if;
  end process; -- stat_reg_proc
  
  ---------------------------------------------------------------------
  -- collision window passed registered
  ---------------------------------------------------------------------
  winp_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        winp_r <= '0';
    elsif clk'event and clk='1' then

        winp_r <= winp;
    end if;
  end process; -- winp_reg_proc
  
  ---------------------------------------------------------------------
  -- fifo treshold level combinatorial
  ---------------------------------------------------------------------
  tresh_proc:
  process(tm)
  begin
    tlev_c <= (others=>'0');
    case DATAWIDTH is
      -------------------------------------------
      when 8 =>
      -------------------------------------------
        case tm is
          when "000" | "101" | "110" => --  128 bytes
            tlev_c(10 downto 0) <= "00010000000";
          when "001" | "111" => --  256 bytes
            tlev_c(10 downto 0) <= "00100000000";
          when "010" => --  512 bytes
            tlev_c(10 downto 0) <= "01000000000";
          when "011" => -- 1024 bytes
            tlev_c(10 downto 0) <= "10000000000";
          when others => --   64 bytes
            tlev_c(10 downto 0) <= "00001000000";
        end case;
        
      -------------------------------------------
      when 16 =>
      -------------------------------------------
        case tm is
          when "000" | "101" | "110" => --  128 bytes
            tlev_c(10 downto 0) <= "00001000000";
          when "001" | "111" => --  256 bytes
            tlev_c(10 downto 0) <= "00010000000";
          when "010" => --  512 bytes
            tlev_c(10 downto 0) <= "00100000000";
          when "011" => -- 1024 bytes
            tlev_c(10 downto 0) <= "01000000000";
          when others => --   64 bytes
            tlev_c(10 downto 0) <= "00000100000";
        end case;
        
      -------------------------------------------
      when others => -- 32
      -------------------------------------------
        case tm is
          when "000" | "101" | "110" => --  128 bytes
            tlev_c(10 downto 0) <= "00000100000";
          when "001" | "111" => --  256 bytes
            tlev_c(10 downto 0) <= "00001000000";
          when "010" => --  512 bytes
            tlev_c(10 downto 0) <= "00010000000";
          when "011" => -- 1024 bytes
            tlev_c(10 downto 0) <= "00100000000";
          when others => --   64 bytes
            tlev_c(10 downto 0) <= "00000010000";
        end case;
    end case;
  end process; -- tlev_proc
  
  ---------------------------------------------------------------------
  -- fifo treshold registered
  ---------------------------------------------------------------------
  tresh_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        tresh <= '0';
    elsif clk'event and clk='1' then

        if stat >= tlev_c(FIFODEPTH-1 downto 0) then
          tresh <= '1';
        else
          tresh <= '0';
        end if;
    end if;
  end process; -- tresh_reg_proc

  ---------------------------------------------------------------------
  -- free fifo space combinatorial
  ---------------------------------------------------------------------
  sflev_proc:
  process(pbl, pblz)
  begin
    sflev_c(FIFODEPTH_MAX-1 downto 6) <= (others=>'1');
    if pblz='1' then
      sflev_c(5 downto 0) <= "000000";
    else
      sflev_c(5 downto 0) <= not pbl;
    end if;
  end process; -- sflev_proc
  
  ---------------------------------------------------------------------
  -- fifo treshold level registered
  ---------------------------------------------------------------------
  fifoval_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        fifoval <= '0';
    elsif clk'event and clk='1' then

        if stat <= sflev_c(FIFODEPTH-1 downto 0) then
          fifoval <= '1';
        else
          fifoval <= '0';
        end if;
    end if;
  end process; -- fifoval_reg_proc
  
  ---------------------------------------------------------------------
  -- programmable burst length=0 registered
  ---------------------------------------------------------------------
  pblz_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        pblz <= '0';
    elsif clk'event and clk='1' then

        if pbl="000000" then
          pblz <= '1';
        else
          pblz <= '0';
        end if;
    end if;
  end process; -- pblz_reg_proc
    
  ---------------------------------------------------------------------
  -- fifo not full
  -- registered output
  ---------------------------------------------------------------------
  fifonf_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        fifonf <= '1';
    elsif clk'event and clk='1' then

        if (stat=fone(FIFODEPTH-1 downto 1) & '0' and fifowe='1') or
           (stat=fone)
        then
          fifonf <= '0';
        else
          fifonf <= '1';
        end if;
    end if;
  end process; -- fifonf_reg_proc
  
  ---------------------------------------------------------------------
  -- FIFO level
  -- registered output
  ---------------------------------------------------------------------
  flev_drv:
    flev <= stat;
  
  ---------------------------------------------------------------------
  -- DP RAM address
  -- registered output
  ---------------------------------------------------------------------
  ramaddr_drv:
    ramaddr <= wad;
  
  ---------------------------------------------------------------------
  -- DP RAM data
  -- redirection
  ---------------------------------------------------------------------
  ramdata_drv:
    ramdata <= fifodata;
  
  ---------------------------------------------------------------------
  -- DP RAM write enable
  -- redirection
  ---------------------------------------------------------------------
  ramwe_drv:
    ramwe <= fifowe;


  --=================================================================--
  --                       Power management                          --
  --=================================================================--

  ---------------------------------------------------------------------
  -- stop transmit process registered
  ---------------------------------------------------------------------
  tstop_reg_proc:

process(clk,rst)
  begin
    if rst = '0' then
        stop_r <= '1';
        stopo  <= '0';
    elsif clk'event and clk='1' then

        -- stop transmit input
        stop_r <= stopi;
        
        -- stop transmit output
        -- can enter stopped state only if
        -- transmit FIFO is empty and transmit cache is empty
        -- i.e no frame is pending for transmission
        -- and no transmission in progress
        if stop_r='1' and ccne='0' and icsne='0' and
           stat=fzero and tprog='0'
        then
          stopo <= '1';
        else
          stopo <= '0';
        end if;
    end if;
  end process; -- tstop_reg_proc
  
  
  
--===================================================================--
--                               others                              --
--===================================================================--
  
  ---------------------------------------------------------------------
  -- all ones vector of FIFODEPTH length
  ---------------------------------------------------------------------
  fone_drv:
    fone <= (others=>'1');

  ---------------------------------------------------------------------
  -- all zeros vector of FIFODEPTH length
  ---------------------------------------------------------------------
  fzero_drv:
    fzero <= (others=>'0');

end RTL;
--*******************************************************************--
