--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: FFT_APB_Wrapper.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--
-- Description: 
--
-- <Description here>
--
-- Targeted device: <Family::SmartFusion2> <Die::M2S010> <Package::144 TQ>
-- Author: <Name>
--
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.FFT_package.all;

entity FFT_APB_Wrapper is
port (
    PCLK : in std_logic;
    RSTn : in std_logic;

    -- APB connections
    PADDR   : in std_logic_vector(7 downto 0);
	PSEL    : in std_logic;
	PENABLE : in std_logic;
	PWRITE  : in std_logic;
	PWDATA  : in std_logic_vector(15 downto 0);
	PREADY  : out std_logic;
	PRDATA  : out std_logic_vector(15 downto 0);
	PSLVERR : out std_logic;

	INT : out std_logic
    -- APB connections
);
end FFT_APB_Wrapper;
architecture architecture_FFT_APB_Wrapper of FFT_APB_Wrapper is

    constant APB_REG_CNT : natural := 8;

    type APB_register_type is array (APB_REG_CNT - 1 downto 0) of std_logic_vector(15 downto 0);
    signal APB_regs : APB_register_type;

    constant FFT_CTRL_ADDR      : natural := 0;--std_logic_vector(7 downto 0) := X"00";
    constant FFT_STAT_ADDR      : natural := 1;--std_logic_vector(7 downto 0) := X"01";
    constant FFT_DIN_R_ADDR     : natural := 2;--std_logic_vector(7 downto 0) := X"02";
    constant FFT_DIN_I_ADDR     : natural := 3;--std_logic_vector(7 downto 0) := X"03";
    constant FFT_DOUT_R_ADDR    : natural := 4;--std_logic_vector(7 downto 0) := X"04";
    constant FFT_DOUT_I_ADDR    : natural := 5;--std_logic_vector(7 downto 0) := X"05";
    constant ABS_VAL_ADDR       : natural := 6;--std_logic_vector(7 downto 0) := X"06";
    constant FFT_DOUT_ADR_ADDR  : natural := 7;--std_logic_vector(7 downto 0) := X"07";


    signal PADDR_sig    : natural range 0 to 7; -- int because register addresses are array indexes
    signal PSEL_sig     : std_logic;
    signal PENABLE_sig  : std_logic;
    signal PWRITE_sig   : std_logic;
    signal PWDATA_sig   : std_logic_vector(15 downto 0);
    signal PREADY_sig   : std_logic;
    signal PRDATA_sig   : std_logic_vector(15 downto 0);
    signal PSLVERR_sig  : std_logic;
    signal INT_sig      : std_logic;
    
    signal smpl_read : std_logic;
    signal smpl_data_stable : std_logic;

    constant DELAY : natural := 5;
    signal delay_cnt : natural range 0 to DELAY - 1 := 0;

    signal comp_rstn : std_logic;

    component FFT
        port (
            PCLK : in std_logic;
            RSTn : in std_logic;
        
            -- ports related to writing samples into the FFT
            in_w_en         : in std_logic;        -- risinge edge: write data into current mem_loc, falling_edge: increment mem_adr
            in_w_data_real  : in std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
            in_w_data_imag  : in std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
            in_w_done       : in std_logic;
            in_w_ready      : out std_logic;      -- FFT memory is ready for sample data
            in_full         : out std_logic;       -- FFT memory is full and is now overwriting older samples circularly
            -- ports related to writing samples into the FFT
        
            -- ports related to reading results of FFT
            out_r_en        : in std_logic;           -- sets when to output data based on address
            out_data_adr    : in std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);     -- asynchronous memory address
            out_read_done   : in std_logic;   -- external device has read all the data it needed
            out_dat_real    : out std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
            out_dat_imag    : out std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
            out_data_ready  : out std_logic;     -- indicates when output data is ready to be read
            out_valid       : out std_logic        -- indicates when output data is accurate to input address
            -- ports related to reading results of FFT
        );
    end component;

    signal FFT_in_w_en          : std_logic;
    signal FFT_in_w_data_real   : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal FFT_in_w_data_imag   : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal FFT_in_w_done        : std_logic;
    signal FFT_in_w_ready       : std_logic;
    signal FFT_in_full          : std_logic;

    signal FFT_out_r_en         : std_logic;
    signal FFT_out_data_adr     : std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);
    signal FFT_out_read_done    : std_logic;
    signal FFT_out_dat_real     : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal FFT_out_dat_imag     : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal FFT_out_data_ready   : std_logic;
    signal FFT_out_data_ready_last   : std_logic;
    signal FFT_out_valid        : std_logic;


    component Alpha_Max_plus_Beta_Min
        generic (
            g_data_width    : natural;
            g_adr_width     : natural;
            g_adr_pipe      : natural
        );
        port( 
            -- Inputs
            PCLK            : in std_logic;
            RSTn            : in std_logic;
            assoc_adr_in    : in std_logic_vector(g_adr_width - 1 downto 0);
            val_A           : in std_logic_vector(g_data_width - 1 downto 0);
            val_B           : in std_logic_vector(g_data_width - 1 downto 0);
            in_valid        : in std_logic;

            -- Outputs
            assoc_adr_out   : out std_logic_vector(g_adr_width - 1 downto 0);
            o_flow          : out std_logic;
            out_valid       : out std_logic;
            result          : out std_logic_vector(g_data_width - 1 downto 0)

            -- Inouts

        );
    end component;

    signal AMpBM_0_assoc_adr_in_sig     : std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);
    signal AMpBM_0_val_A_sig            : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal AMpBM_0_val_B_sig            : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal AMpBM_0_in_valid_sig         : std_logic;
    signal AMpBM_0_out_valid_sig        : std_logic;
    signal AMpBM_0_assoc_adr_out_sig    : std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);
    signal AMpBM_0_o_flow_sig           : std_logic;
    signal AMpBM_0_result_sig           : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal mag_result_corrected         : std_logic_vector(7 downto 0);

begin

    -- addresses from ARM core adhere to 4 byte boundary rules
    PADDR_sig <= to_integer(unsigned(PADDR(7 downto 2)));
    PWDATA_sig <= PWDATA;

    -- BEGIN APB Register Read logic
    p_APB_Reg_Read : process(PCLK, RSTn)
    begin
        if(RSTn = '0') then
            PRDATA_sig <= (others => '0');
            smpl_read <= '0';
        elsif(rising_edge(PCLK)) then
            if(PWRITE = '0' and PSEL = '1') then
                case PADDR_sig is
                    when FFT_CTRL_ADDR =>
                        PRDATA_sig <= APB_regs(FFT_CTRL_ADDR);
                    when FFT_STAT_ADDR =>
                        PRDATA_sig <= APB_regs(FFT_STAT_ADDR);
                    when FFT_DIN_R_ADDR =>
                        PRDATA_sig <= APB_regs(FFT_DIN_R_ADDR);
                    when FFT_DIN_I_ADDR =>
                        PRDATA_sig <= APB_regs(FFT_DIN_I_ADDR);
                    when FFT_DOUT_R_ADDR =>
                        PRDATA_sig <= APB_regs(FFT_DOUT_R_ADDR);
                    when FFT_DOUT_I_ADDR =>
                        PRDATA_sig <= APB_regs(FFT_DOUT_I_ADDR);
                    when ABS_VAL_ADDR =>
                        PRDATA_sig <= APB_regs(ABS_VAL_ADDR);
                        smpl_read <= '1';
                    when FFT_DOUT_ADR_ADDR =>
                        PRDATA_sig <= APB_regs(FFT_DOUT_ADR_ADDR);
                    when others =>
                        PRDATA_sig <= (others => '0');
                end case;
            else
                PRDATA_sig <= (others => '0');
                smpl_read <= '0';
            end if;
        end if;
    end process;

    -- BEGIN APB Return wires
    PRDATA <= PRDATA_sig;
    PREADY <= smpl_data_stable when smpl_read = '1' else '1';
    PSLVERR <= '0';
    -- END APB Return wires

    -- END APB Register Read logic

    p_FFT_CTRL_ADDR : process(PCLK, RSTn)
    begin
        if(RSTn = '0') then
            APB_regs(FFT_CTRL_ADDR) <= X"0000";
        elsif(rising_edge(PCLK)) then
            if(PSEL = '1' and PENABLE = '1' and PWRITE = '1' and PADDR_sig = FFT_CTRL_ADDR) then
                -- 0bXXX..X & FFT_int_clr & FFT_r_done & FFT_w_done & FFT_w_en
                APB_regs(FFT_CTRL_ADDR) <= PWDATA_sig;
            else
                -- write enable only needs to be high for 1 cycle
                -- automatically deassert to reduce bus transactions
                APB_regs(FFT_CTRL_ADDR)(0) <= '0';

                -- FFT in ready deasserted so deassert write done
                if(FFT_in_w_ready = '0') then
                    APB_regs(FFT_CTRL_ADDR)(1) <= '0';
                end if;

                -- FFT out ready deasserted so deassert read done
                if(FFT_out_data_ready = '0') then
                    APB_regs(FFT_CTRL_ADDR)(2) <= '0';
                end if;

                -- FFT_int_clr only needs to be high for 1 cycle
                -- automatically deassert
                APB_regs(FFT_CTRL_ADDR)(3) <= '0';
            end if;
        end if;
    end process;

    FFT_in_w_en <= APB_regs(FFT_CTRL_ADDR)(0);
    FFT_in_w_done <= APB_regs(FFT_CTRL_ADDR)(1);
    FFT_out_read_done <= APB_regs(FFT_CTRL_ADDR)(2);

    --=========================================================================

    p_FFT_STAT_ADDR : process(PCLK, RSTn)
    begin
        if(RSTn = '0') then
            INT_sig <= '0';
            FFT_out_data_ready_last <= '0';
        elsif(rising_edge(PCLK)) then
            FFT_out_data_ready_last <= FFT_out_data_ready;
            if(FFT_out_data_ready_last = '0' and FFT_out_data_ready = '1') then
                INT_sig <= '1';
            elsif(APB_regs(FFT_CTRL_ADDR)(3) = '1') then
                INT_sig <= '0';
            end if;
        end if;
    end process;

    INT <= INT_sig;

    APB_regs(FFT_STAT_ADDR)(0) <= FFT_in_w_ready;
    APB_regs(FFT_STAT_ADDR)(1) <= FFT_in_full;
    APB_regs(FFT_STAT_ADDR)(2) <= FFT_out_data_ready;
    APB_regs(FFT_STAT_ADDR)(3) <= FFT_out_valid;
    APB_regs(FFT_STAT_ADDR)(4) <= AMpBM_0_out_valid_sig;
    APB_regs(FFT_STAT_ADDR)(5) <= INT_sig;
    APB_regs(FFT_STAT_ADDR)(6) <= '0';
    APB_regs(FFT_STAT_ADDR)(7) <= '0';
    APB_regs(FFT_STAT_ADDR)(8) <= '0';
    APB_regs(FFT_STAT_ADDR)(9) <= '0';
    APB_regs(FFT_STAT_ADDR)(10) <= '0';
    APB_regs(FFT_STAT_ADDR)(11) <= '0';
    APB_regs(FFT_STAT_ADDR)(12) <= '0';
    APB_regs(FFT_STAT_ADDR)(13) <= '0';
    APB_regs(FFT_STAT_ADDR)(14) <= '0';
    APB_regs(FFT_STAT_ADDR)(15) <= '0';

    --=========================================================================

    p_FFT_DIN_R_ADDR : process(PCLK, RSTn)
    begin
        if(RSTn = '0') then
            APB_regs(FFT_DIN_R_ADDR) <= (others => '0');
        elsif(rising_edge(PCLK)) then
            if(PSEL = '1' and PENABLE = '1' and PWRITE = '1' and PADDR_sig = FFT_DIN_R_ADDR) then
                APB_regs(FFT_DIN_R_ADDR) <= PWDATA_sig;
            else
                null;
            end if;
        end if;
    end process;

    FFT_in_w_data_real <= APB_regs(FFT_DIN_R_ADDR)(FFT_in_w_data_real'high downto 0);

    --=========================================================================

    p_FFT_DIN_I_ADDR : process(PCLK, RSTn)
    begin
        if(RSTn = '0') then
            APB_regs(FFT_DIN_I_ADDR) <= (others => '0');
        elsif(rising_edge(PCLK)) then
            if(PSEL = '1' and PENABLE = '1' and PWRITE = '1' and PADDR_sig = FFT_DIN_I_ADDR) then
                APB_regs(FFT_DIN_I_ADDR) <= PWDATA_sig;
            else
                null;
            end if;
        end if;
    end process;

    FFT_in_w_data_imag <= APB_regs(FFT_DIN_I_ADDR)(FFT_in_w_data_imag'high downto 0);

    --=========================================================================

    APB_regs(FFT_DOUT_R_ADDR) <= "0000000" & FFT_out_dat_real;
    APB_regs(FFT_DOUT_I_ADDR) <= "0000000" & FFT_out_dat_imag;

    APB_regs(ABS_VAL_ADDR) <= "00000000" & mag_result_corrected;

    --=========================================================================

    p_FFT_DOUT_ADR_ADDR : process(PCLK, RSTn)
    begin
        if(RSTn = '0') then
            APB_regs(FFT_DOUT_ADR_ADDR) <= (others => '0');
            FFT_out_r_en <= '0';
        elsif(rising_edge(PCLK)) then
            if(PSEL = '1' and PENABLE = '1' and PWRITE = '1' and PADDR_sig = FFT_DOUT_ADR_ADDR) then
                APB_regs(FFT_DOUT_ADR_ADDR) <= PWDATA_sig;
                smpl_data_stable <= '0';
                -- comp_rstn requires FFT output to be buffered. output valid 2 clock cycles after adr in
                comp_rstn <= '0';       -- components are pipelined, this clears the pipe so no invalid data
                delay_cnt <= 0;
                FFT_out_r_en <= '1';
            else
                comp_rstn <= '1';
                FFT_out_r_en <= '0';
            end if;

            if(smpl_data_stable = '0') then
                if(delay_cnt /= DELAY - 1) then
                    delay_cnt <= delay_cnt + 1;
                else
                    smpl_data_stable <= '1';
                end if;
            end if;
        end if;
    end process;

    FFT_out_data_adr <= APB_regs(FFT_DOUT_ADR_ADDR)(FFT_out_data_adr'high downto 0);



    --=========================================================================



    FFT_Core : FFT
        port map(
            PCLK => PCLK,
            RSTn => RSTn,

            in_w_en         => FFT_in_w_en,
            in_w_data_real  => FFT_in_w_data_real,
            in_w_data_imag  => FFT_in_w_data_imag,
            in_w_done       => FFT_in_w_done,
            in_w_ready      => FFT_in_w_ready,
            in_full         => FFT_in_full,

            out_r_en        => FFT_out_r_en,
            out_data_adr    => FFT_out_data_adr,
            out_read_done   => FFT_out_read_done,
            out_dat_real    => FFT_out_dat_real,
            out_dat_imag    => FFT_out_dat_imag,
            out_data_ready  => FFT_out_data_ready,
            out_valid       => FFT_out_valid
        );


    AMpBM_0_val_A_sig <= FFT_out_dat_real;
    AMpBM_0_val_B_sig <= FFT_out_dat_imag;
    AMpBM_0_in_valid_sig <= FFT_out_valid;


    Alpha_Max_plus_Beta_Min_0 : Alpha_Max_plus_Beta_Min
        generic map(
            g_data_width => SAMPLE_WIDTH_INT,
            g_adr_width => SAMPLE_CNT_EXP,
            g_adr_pipe => 1
        )
        -- port map
        port map( 
            -- Inputs
            PCLK            => PCLK,
            RSTn            => comp_rstn,
            in_valid        => AMpBM_0_in_valid_sig,
            assoc_adr_in    => AMpBM_0_assoc_adr_in_sig,
            val_A           => AMpBM_0_val_A_sig,
            val_B           => AMpBM_0_val_B_sig,
    
            -- Outputs
            assoc_adr_out   => open,--AMpBM_0_assoc_adr_out_sig,
            o_flow          => AMpBM_0_o_flow_sig,
            out_valid       => AMpBM_0_out_valid_sig,
            result          => AMpBM_0_result_sig
        );

    
    -- mult result by 2, except for first and last
    mag_result_corrected <= AMpBM_0_result_sig(7 downto 0) when
                                APB_regs(FFT_DOUT_ADR_ADDR)(SAMPLE_CNT_EXP - 1 downto 0) = "0000000000" or
                                APB_regs(FFT_DOUT_ADR_ADDR)(SAMPLE_CNT_EXP - 1 downto 0) = std_logic_vector(to_unsigned(SAMPLE_CNT, SAMPLE_CNT_EXP)) else
                            AMpBM_0_result_sig(6 downto 0) & '0';

   -- architecture body
end architecture_FFT_APB_Wrapper;
