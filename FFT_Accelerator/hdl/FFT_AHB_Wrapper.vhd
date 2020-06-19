--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: FFT_AHB_Wrapper.vhd
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

use work.FFT_Package.all;
use work.AHB_Package.all;

entity FFT_AHB_Wrapper is
port (
    CLK : in std_logic;
    RSTn : in std_logic;

    Data_i       : std_logic_vector(15 downto 0);
    Data_i_Valid : std_logic;

    -- AHB connections
    HADDR       : in std_logic_vector(7 downto 0);
    HWDATA      : in std_logic_vector(15 downto 0);
    HWRITE      : in std_logic;
    HSIZE       : in std_logic_vector(2 downto 0);
    HTRANS      : in std_logic_vector(1 downto 0);
    HSEL        : in std_logic;
    HMASTLOCK   : in std_logic;
    HBURST      : in std_logic_vector(2 downto 0);
    HPROT       : in std_logic_vector(3 downto 0);
    HREADYIN    : in std_logic;

    HRDATA      : out std_logic_vector(15 downto 0);
    HRESP       : out std_logic_vector(1 downto 0);
    HREADYOUT   : out std_logic;
    -- AHB connections

    INT : out std_logic
);
end FFT_AHB_Wrapper;
architecture architecture_FFT_AHB_Wrapper of FFT_AHB_Wrapper is

    constant CORE_REG_CNT : natural := 8;

    type core_register_type is array (CORE_REG_CNT - 1 downto 0) of std_logic_vector(15 downto 0);
    signal core_regs : core_register_type;

    constant FFT_CTRL_ADDR      : natural := 0;--std_logic_vector(7 downto 0) := X"00";
    constant FFT_STAT_ADDR      : natural := 1;--std_logic_vector(7 downto 0) := X"01";
    constant FFT_DIN_R_ADDR     : natural := 2;--std_logic_vector(7 downto 0) := X"02";
    constant FFT_DIN_I_ADDR     : natural := 3;--std_logic_vector(7 downto 0) := X"03";
    constant FFT_DOUT_R_ADDR    : natural := 4;--std_logic_vector(7 downto 0) := X"04";
    constant FFT_DOUT_I_ADDR    : natural := 5;--std_logic_vector(7 downto 0) := X"05";
    constant ABS_VAL_ADDR       : natural := 6;--std_logic_vector(7 downto 0) := X"06";
    constant FFT_DOUT_ADR_ADDR  : natural := 7;--std_logic_vector(7 downto 0) := X"07";


    type ahb_states is (nowait, waiting_int, waiting_ext);
    signal ahb_state : ahb_states;

    -- AHB signals
    signal HADDR_A_sig      : natural range 0 to 7;
    signal HADDR_S_sig      : natural range 0 to 7;
    signal HADDR_sig_use    : natural range 0 to 7;
    signal HSEL_sig         : std_logic;
    signal HSEL_sig_use     : std_logic;
    signal HWDATA_sig       : std_logic_vector(15 downto 0);
    signal HWRITE_sig       : std_logic;
    signal HWRITE_sig_use   : std_logic;
    signal HSIZE_sig        : std_logic_vector(2 downto 0);
    signal HTRANS_sig       : std_logic_vector(1 downto 0);
    signal HMASTLOCK_sig    : std_logic;
    signal HBURST_sig       : std_logic_vector(2 downto 0);
    signal HPROT_sig        : std_logic_vector(3 downto 0);
    signal HREADYIN_sig     : std_logic;
    signal HRDATA_sig       : std_logic_vector(15 downto 0);
    signal HRESP_sig        : std_logic_vector(1 downto 0);
    signal HREADYOUT_sig    : std_logic;

    signal INT_sig          : std_logic;
    -- AHB signals

    signal smpl_read : std_logic;
    signal smpl_data_stable : std_logic;
    signal abs_val_read : std_logic;
    signal abs_val_stable : std_logic;

    -- these experimentally determine the delay between setting the output address
    -- and the data being available on HRDATA
    constant SMPL_DELAY : natural := 4;
    constant ABSV_DELAY : natural := 8;
    signal delay_cnt : natural range 0 to ABSV_DELAY := 0;

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
    signal FFT_out_r_en_d         : std_logic;
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
    HADDR_A_sig <= to_integer(unsigned(HADDR(7 downto 2)));
    HWDATA_sig <= HWDATA;

    p_AHB_capture : process(CLK, RSTn)
        variable upcoming_notready : std_logic;
    begin
        if(RSTn = '0') then
            -- AHB inputs
            HADDR_S_sig     <= 0;
            HWRITE_sig      <= '0';
            --HSIZE_sig       <= (others => '0');
            --HTRANS_sig      <= HTRANS_IDLE;
            HSEL_sig        <= '0';
            --HMASTLOCK_sig   <= '0';
            --HBURST_sig      <= (others => '0');
            --HPROT_sig       <= (others => '0');
            HREADYIN_sig    <= '0';
            -- AHB outputs
            HRESP_sig       <= HRESP_OKAY;
            --HREADYOUT_sig   <= '1';

            ahb_state <= nowait;
        elsif(rising_edge(CLK)) then

            HRESP_sig <= HRESP_OKAY;
            HREADYIN_sig <= HREADYIN;

            -- this should fail to react to a single wait state.
            case ahb_state is
                when nowait =>
                    -- being in this state means the previous data phase has completed
                    -- the current data phase determines this slave's next state
                    if(HSEL_sig = '1' and HREADYIN = '1') then
                        -- previous address phase intended for this slave
                        -- current data phase completed successfully
                        ahb_state <= nowait;

                    elsif(HSEL_sig = '1' and HREADYIN = '0') then
                        -- previous address phase intended for this slave
                        -- current data phase NOT completed successfully
                        ahb_state <= waiting_int;

                    elsif(HSEL_sig = '0' and HREADYIN = '1') then
                        -- previous address phase NOT intended for this slave
                        -- current data phase completed successfully
                        ahb_state <= nowait;

                    elsif(HSEL_sig = '0' and HREADYIN = '0') then
                        -- previous address phase NOT intended for this slave
                        -- current data phase NOT completed successfully
                        ahb_state <= waiting_ext;

                    end if;

                when waiting_int =>
                    -- previous address phase was for this slave
                    -- data phase was not completed by this peripheral (still ongoing)
                    if(HREADYIN = '1') then
                        -- data phase complete
                        ahb_state <= nowait;

                    elsif(HREADYIN = '0') then
                        -- data phase still not complete
                        ahb_state <= waiting_int;

                    end if;

                when waiting_ext =>
                    -- previous address phase was NOT for this slave
                    -- data phase was not completed by other peripheral (still ongoing)
                    if(HREADYIN = '1') then
                        -- data phase complete
                        ahb_state <= nowait;

                    elsif(HREADYIN = '0') then
                        -- data phase still not complete
                        ahb_state <= waiting_ext;

                    end if;

                when others =>
                    ahb_state <= nowait;

            end case;

            if((smpl_read = '1' and smpl_data_stable = '0') or (abs_val_read = '1' and abs_val_stable = '0')) then
                upcoming_notready := '1';
            else
                upcoming_notready := '0';
            end if;

            if(((ahb_state = nowait) or (HREADYIN = '1' and (ahb_state = waiting_int or ahb_state = waiting_ext))) and (upcoming_notready = '0')) then
                HSEL_sig <= HSEL;
                HADDR_S_sig <= HADDR_A_sig;
                HWRITE_sig <= HWRITE;
            end if;

            --case ahb_state is
            --    when nowait =>
            --        HSEL_sig <= HSEL;
            --        HADDR_S_sig <= HADDR_A_sig;
            --        HWRITE_sig <= HWRITE;
            --    when waiting_int =>
            --        if(HREADYIN = '1') then
            --            HSEL_sig <= HSEL;
            --            HADDR_S_sig <= HADDR_A_sig;
            --            HWRITE_sig <= HWRITE;
            --        end if;
            --    when waiting_ext =>
            --        if(HREADYIN = '1') then
            --            HSEL_sig <= HSEL;
            --            HADDR_S_sig <= HADDR_A_sig;
            --            HWRITE_sig <= HWRITE;
            --        end if;
            --    when others =>
            --        HSEL_sig <= '0';
            --end case;

        end if;
    end process;

    -- use delayed values or current values depending on ahb_state and upcoming ready
    p_AHB_signals_to_use : process(ahb_state, HREADYIN, HSEL, HSEL_sig, HADDR_A_sig, HADDR_S_sig, HWRITE, HWRITE_sig, smpl_read, smpl_data_stable, abs_val_read, abs_val_stable)
        variable upcoming_notready : std_logic;
    begin
        if((smpl_read = '1' and smpl_data_stable = '0') or (abs_val_read = '1' and abs_val_stable = '0')) then
            upcoming_notready := '1';
        else
            upcoming_notready := '0';
        end if;
        -- test against current data phase from everywhere and upcoming data phase from this slave
        if(((ahb_state = nowait) or (HREADYIN = '1' and (ahb_state = waiting_int or ahb_state = waiting_ext))) and (upcoming_notready = '0')) then
            HSEL_sig_use <= HSEL;
            HADDR_sig_use <= HADDR_A_sig;
            HWRITE_sig_use <= HWRITE;
        else
            HSEL_sig_use <= HSEL_sig;
            HADDR_sig_use <= HADDR_S_sig;
            HWRITE_sig_use <= HWRITE_sig;
        end if;
    end process;

    -- BEGIN APB Register Read logic
    p_AHB_Reg_Read : process(CLK, RSTn)
    begin
        if(RSTn = '0') then
            HRDATA_sig <= (others => '0');
            smpl_read <= '0';
            abs_val_read <= '0';
        elsif(rising_edge(CLK)) then

            if(HWRITE_sig_use = '0' and HSEL_sig_use = '1') then
                case HADDR_sig_use is
                    when FFT_CTRL_ADDR =>
                        HRDATA_sig <= core_regs(FFT_CTRL_ADDR);
                    when FFT_STAT_ADDR =>
                        HRDATA_sig <= core_regs(FFT_STAT_ADDR);
                    when FFT_DIN_R_ADDR =>
                        HRDATA_sig <= core_regs(FFT_DIN_R_ADDR);
                    when FFT_DIN_I_ADDR =>
                        HRDATA_sig <= core_regs(FFT_DIN_I_ADDR);
                    when FFT_DOUT_R_ADDR =>
                        HRDATA_sig <= core_regs(FFT_DOUT_R_ADDR);
                        smpl_read <= '1';
                    when FFT_DOUT_I_ADDR =>
                        HRDATA_sig <= core_regs(FFT_DOUT_I_ADDR);
                        smpl_read <= '1';
                    when ABS_VAL_ADDR =>
                        HRDATA_sig <= core_regs(ABS_VAL_ADDR);
                        abs_val_read <= '1';
                    when FFT_DOUT_ADR_ADDR =>
                        HRDATA_sig <= core_regs(FFT_DOUT_ADR_ADDR);
                    when others =>
                        HRDATA_sig <= (others => '0');
                end case;
            else
                HRDATA_sig <= (others => '0');
                smpl_read <= '0';
                abs_val_read <= '0';
            end if;
                
        end if;
    end process;

    -- BEGIN AHB Return wires
    HRESP <= HRESP_sig;
    HRDATA <= HRDATA_sig;
    HREADYOUT_sig <= smpl_data_stable when smpl_read = '1' and abs_val_read = '0' else
                    abs_val_stable when smpl_read = '0' and abs_val_read = '1' else
                    abs_val_stable when smpl_read = '1' and abs_val_read = '1' else
                    '1';
    HREADYOUT <= HREADYOUT_sig;
    -- END AHB Return wires

    -- END AHB Register Read logic

    --=========================================================================

    p_FFT_CTRL_ADDR : process(CLK, RSTn)
    begin
        if(RSTn = '0') then
            core_regs(FFT_CTRL_ADDR) <= X"0000";
        elsif(rising_edge(CLK)) then
            if(HSEL_sig = '1' and HWRITE_sig = '1' and HADDR_S_sig = FFT_CTRL_ADDR) then
                -- 0bXXX..X & FFT_int_clr & FFT_r_done & FFT_w_done & FFT_w_en
                -- bit : description
                -- 0 : FFT_w_en
                -- 1 : FFT_w_done
                -- 2 : FFT_r_done
                -- 3 : FFT_int_clr
                -- 4 : FFT_w_direct; 0 : uses AHB, 1: uses Data_i
                core_regs(FFT_CTRL_ADDR) <= HWDATA_sig;
            else
                -- write enable only needs to be high for 1 cycle
                -- automatically deassert to reduce bus transactions
                core_regs(FFT_CTRL_ADDR)(0) <= '0';

                -- FFT in ready deasserted so deassert write done
                if(FFT_in_w_ready = '0') then
                    core_regs(FFT_CTRL_ADDR)(1) <= '0';
                end if;

                -- FFT out ready deasserted so deassert read done
                if(FFT_out_data_ready = '0') then
                    core_regs(FFT_CTRL_ADDR)(2) <= '0';
                end if;

                -- FFT_int_clr only needs to be high for 1 cycle
                -- automatically deassert
                core_regs(FFT_CTRL_ADDR)(3) <= '0';
            end if;
        end if;
    end process;

    FFT_in_w_en <= core_regs(FFT_CTRL_ADDR)(0) when core_regs(FFT_CTRL_ADDR)(4) = '0'
                    else Data_i_Valid;
    FFT_in_w_done <= core_regs(FFT_CTRL_ADDR)(1) when core_regs(FFT_CTRL_ADDR)(4) = '0'
                    else FFT_in_full;
    FFT_out_read_done <= core_regs(FFT_CTRL_ADDR)(2);

    --=========================================================================

    p_FFT_STAT_ADDR : process(CLK, RSTn)
    begin
        if(RSTn = '0') then
            INT_sig <= '0';
            FFT_out_data_ready_last <= '0';
        elsif(rising_edge(CLK)) then
            FFT_out_data_ready_last <= FFT_out_data_ready;
            if(FFT_out_data_ready_last = '0' and FFT_out_data_ready = '1') then
                INT_sig <= '1';
            elsif(core_regs(FFT_CTRL_ADDR)(3) = '1') then
                INT_sig <= '0';
            end if;
        end if;
    end process;

    INT <= INT_sig;

    core_regs(FFT_STAT_ADDR)(0) <= FFT_in_w_ready;
    core_regs(FFT_STAT_ADDR)(1) <= FFT_in_full;
    core_regs(FFT_STAT_ADDR)(2) <= FFT_out_data_ready;
    core_regs(FFT_STAT_ADDR)(3) <= FFT_out_valid;
    core_regs(FFT_STAT_ADDR)(4) <= AMpBM_0_out_valid_sig;
    core_regs(FFT_STAT_ADDR)(5) <= INT_sig;
    core_regs(FFT_STAT_ADDR)(6) <= '0';
    core_regs(FFT_STAT_ADDR)(7) <= '0';
    core_regs(FFT_STAT_ADDR)(8) <= '0';
    core_regs(FFT_STAT_ADDR)(9) <= '0';
    core_regs(FFT_STAT_ADDR)(10) <= '0';
    core_regs(FFT_STAT_ADDR)(11) <= '0';
    core_regs(FFT_STAT_ADDR)(12) <= '0';
    core_regs(FFT_STAT_ADDR)(13) <= '0';
    core_regs(FFT_STAT_ADDR)(14) <= '0';
    core_regs(FFT_STAT_ADDR)(15) <= '0';

    --=========================================================================

    p_FFT_DIN_R_ADDR : process(CLK, RSTn)
    begin
        if(RSTn = '0') then
            core_regs(FFT_DIN_R_ADDR) <= (others => '0');
        elsif(rising_edge(CLK)) then
            if(HSEL_sig = '1' and HWRITE_sig = '1' and HADDR_S_sig = FFT_DIN_R_ADDR) then
                core_regs(FFT_DIN_R_ADDR) <= HWDATA_sig;
            else
                null;
            end if;
        end if;
    end process;

    FFT_in_w_data_real <= core_regs(FFT_DIN_R_ADDR)(FFT_in_w_data_real'high downto 0) when core_regs(FFT_CTRL_ADDR)(4) = '0'
                            else Data_i(FFT_in_w_data_real'high downto 0);

    --=========================================================================

    p_FFT_DIN_I_ADDR : process(CLK, RSTn)
    begin
        if(RSTn = '0') then
            core_regs(FFT_DIN_I_ADDR) <= (others => '0');
        elsif(rising_edge(CLK)) then
            if(HSEL_sig = '1' and HWRITE_sig = '1' and HADDR_S_sig = FFT_DIN_I_ADDR) then
                core_regs(FFT_DIN_I_ADDR) <= HWDATA_sig;
            else
                null;
            end if;
        end if;
    end process;

    FFT_in_w_data_imag <= core_regs(FFT_DIN_I_ADDR)(FFT_in_w_data_imag'high downto 0);

    --=========================================================================

    p_FFT_DOUT_ADDR : process(CLK, RSTn)
    begin
        if(RSTn = '0') then
            core_regs(FFT_DOUT_R_ADDR) <= (others => '0');
            core_regs(FFT_DOUT_I_ADDR) <= (others => '0');
            core_regs(ABS_VAL_ADDR) <= (others => '0');
        elsif(rising_edge(CLK)) then
            if(FFT_out_valid = '1') then
                core_regs(FFT_DOUT_R_ADDR) <= "0000000" & FFT_out_dat_real;
                core_regs(FFT_DOUT_I_ADDR) <= "0000000" & FFT_out_dat_imag;
            end if;

            if(AMpBM_0_out_valid_sig = '1') then
                core_regs(ABS_VAL_ADDR) <= "00000000" & mag_result_corrected;
            end if;
        end if;
    end process;

    --=========================================================================

    p_FFT_DOUT_ADR_ADDR : process(CLK, RSTn)
    begin
        if(RSTn = '0') then
            core_regs(FFT_DOUT_ADR_ADDR) <= (others => '0');
            FFT_out_r_en <= '0';
            FFT_out_r_en_d <= '0';
            smpl_data_stable <= '1';
            abs_val_stable <= '1';
            delay_cnt <= 0;
        elsif(rising_edge(CLK)) then
            FFT_out_r_en_d <= FFT_out_r_en;
            if(HSEL_sig = '1' and HWRITE_sig = '1' and HADDR_S_sig = FFT_DOUT_ADR_ADDR) then
                core_regs(FFT_DOUT_ADR_ADDR) <= HWDATA_sig;
                -- comp_rstn requires FFT output to be buffered. output valid 2 clock cycles after adr in
                comp_rstn <= '0';       -- components are pipelined, this clears the pipe so no invalid data
                FFT_out_r_en <= '1';
            else
                comp_rstn <= '1';
                FFT_out_r_en <= '0';
            end if;

            -- set samples as not ready based on address phase
            if(HSEL = '1' and HWRITE = '1' and HADDR_A_sig = FFT_DOUT_ADR_ADDR) then
                smpl_data_stable <= '0';
                abs_val_stable <= '0';
            end if;

            -- set counter to start on data phase (and set ready signals low again)
            if(HSEL_sig = '1' and HWRITE_sig = '1' and HADDR_S_sig = FFT_DOUT_ADR_ADDR) then
                delay_cnt <= 0;
                smpl_data_stable <= '0';
                abs_val_stable <= '0';
            end if;

            -- ABSV_DELAY must be greater than SMPL_DELAY
            if(smpl_data_stable = '0' or abs_val_stable = '0') then
                if(delay_cnt /= ABSV_DELAY) then 
                    delay_cnt <= delay_cnt + 1;
                    smpl_data_stable <= '0';
                    abs_val_stable <= '0';
                else
                    delay_cnt <= 0;
                end if;
                if(delay_cnt >= SMPL_DELAY) then    -- i dislike using '>=', more logic than just '='
                    smpl_data_stable <= '1';
                end if;
                if(delay_cnt = ABSV_DELAY) then
                    abs_val_stable <= '1';
                end if;
            end if;
        end if;
    end process;

    FFT_out_data_adr <= core_regs(FFT_DOUT_ADR_ADDR)(FFT_out_data_adr'high downto 0);

    --=========================================================================



    FFT_Core : FFT
        port map(
            PCLK => CLK,
            RSTn => RSTn,

            in_w_en         => FFT_in_w_en,
            in_w_data_real  => FFT_in_w_data_real,
            in_w_data_imag  => FFT_in_w_data_imag,
            in_w_done       => FFT_in_w_done,
            in_w_ready      => FFT_in_w_ready,
            in_full         => FFT_in_full,

            out_r_en        => FFT_out_r_en_d,
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
            PCLK            => CLK,
            RSTn            => RSTn,--comp_rstn,
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
                                core_regs(FFT_DOUT_ADR_ADDR)(SAMPLE_CNT_EXP - 1 downto 0) = "0000000000" or
                                core_regs(FFT_DOUT_ADR_ADDR)(SAMPLE_CNT_EXP - 1 downto 0) = std_logic_vector(to_unsigned(SAMPLE_CNT, SAMPLE_CNT_EXP)) else
                            AMpBM_0_result_sig(6 downto 0) & '0';

   -- architecture body
end architecture_FFT_AHB_Wrapper;
