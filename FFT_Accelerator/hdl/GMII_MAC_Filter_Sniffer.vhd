--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: GMII_MAC_Filter_Sniffer.vhd
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

use work.ETH_pkg.all;

entity GMII_MAC_Filter_Sniffer is
port (
    RXCLK : in std_logic;
    PCLK : in std_logic;
	RSTn : in std_logic;

	-- APB connections
	-- These are in the PCLK domain
    PADDR   : in std_logic_vector(7 downto 0);
	PSEL    : in std_logic;
	PENABLE : in std_logic;
	PWRITE  : in std_logic;
	PWDATA  : in std_logic_vector(31 downto 0);
	PREADY  : out std_logic;
	PRDATA  : out std_logic_vector(31 downto 0);
	PSLVERR : out std_logic;

	--INT : out std_logic;
	-- APB connections
	
	-- GMII connections
	-- These are in the RXCLK domain
	GMII_RX_ER_i	: in std_logic;
	GMII_RX_ER_o	: out std_logic;
	GMII_RXD		: in std_logic_vector(7 downto 0);
	GMII_RX_DV		: in std_logic;
	-- GMII connections

	-- Direct data connections
	-- These are in the PCLK domain
	Data_o			: out std_logic_vector(15 downto 0);
	Data_o_Valid	: out std_logic;
	-- Direct data connections

	rx_is_on : out std_logic
);
end GMII_MAC_Filter_Sniffer;
architecture architecture_GMII_MAC_Filter_Sniffer of GMII_MAC_Filter_Sniffer is

	constant APB_REG_CNT : natural := 8;
	constant APB_REG_SIZE : natural := 32;
	constant SYNC_DEPTH : natural := 2;

	--=========================================================================
    -- Signals for logic in the PCLK domain
    --=========================================================================

    type APB_register_type is array (APB_REG_CNT - 1 downto 0) of std_logic_vector(APB_REG_SIZE - 1 downto 0);
    signal APB_regs : APB_register_type;
	
	constant APB_CTRL_ADDR      : natural := 0;
	constant APB_STAT_ADDR      : natural := 1;
	constant APB_MAC0_ADDR      : natural := 2;
	constant APB_MAC1_ADDR      : natural := 3;
	constant APB_IPAD_ADDR		: natural := 4;
	constant APB_PORT_ADDR		: natural := 5;
	constant APB_TRAP_CNT_ADDR	: natural := 6;
	constant APB_BLOCK_CNT_ADDR	: natural := 7;

	signal PADDR_sig    : natural range 0 to APB_REG_CNT - 1;
	signal PSEL_sig     : std_logic;
    signal PENABLE_sig  : std_logic;
    signal PWRITE_sig   : std_logic;
    signal PWDATA_sig   : std_logic_vector(31 downto 0);
    signal PREADY_sig   : std_logic;
    signal PRDATA_sig   : std_logic_vector(31 downto 0);
    signal PSLVERR_sig  : std_logic;
	signal INT_sig      : std_logic;

	signal RXCLK_set_off_tx : std_logic;
	signal RXCLK_is_off_rx : std_logic;

	-- state machine for controlling RXCLK domain control register updates with handshakes
	type PCLK_cmd_states is (set_off, is_off, set_on, is_on);
	signal PCLK_cmd_state : PCLK_cmd_states;


	--=========================================================================
    -- Signals for logic in the RXCLK domain
    --=========================================================================

	-- control stuff
	signal gmii_reg_ctrl : std_logic_vector(31 downto 0);
	signal my_stuff		: my_identity;
	signal eth_stuff	: eth_header;
	signal ipv4_stuff	: ipv4_header;
	signal udp_stuff	: udp_header;

	signal RXCLK_set_off_rx : std_logic;
	signal RXCLK_is_off_tx	: std_logic;


	signal byte_counter : natural range 0 to ETH_PACKET_MAX - 1;

	-- RXCLK domain states 
	-- idle : initial state out of reset, continuously tests input for start of ethernet frame
	-- off : induced by PCLK (master) domain, disables ethernet frame sniffing, updates control registers
	-- frame_active : ethernet preamble and SFD happened, we have a frame now boys
	-- frame_trap : siphon frame payload to send to async FIFO for FPGA processing
	-- frame_ignore : frame header does not match items we're looking for, pass it on untouched
	-- frame_error : Something wrong with frame. e.g. PHY error = 1, error detected by this core,
	--					or configured to ignore packets intended for other devices.
	type RXCLK_states is (idle, off, frame_active, frame_trap, frame_ignore, frame_error);
	signal RXCLK_state : RXCLK_states;
	signal RXCLK_state_next : RXCLK_states;
	type header_decode_states is (eth, ipv4, udp);
	signal header_decode_state : header_decode_states;

	-- input buffer is sized to identify Frame Start condition (preamble + SFD)
	constant GMII_BUF_DEPTH : natural := 8;
	type GMII_input_buffer_type is array (0 to GMII_BUF_DEPTH - 1) of std_logic_vector(7 downto 0);
	signal GMII_in_buf : GMII_input_buffer_type;
	signal GMII_in_buf_1d : std_logic_vector((GMII_BUF_DEPTH * 8) - 1 downto 0);
	signal GMII_dv_buf : std_logic;

	-- FRAME_FLAG_CNT bit flags
	-- 0 : MAC address match
	-- 1 : IPv4 protocol match
	-- 2 : IP address match
	-- 3 : UDP protocol match
	-- 4 : UDP Port match
	constant FRAME_FLAG_CNT : natural := 5;
	constant FLAG_MAC_ADR		: natural := 0;
	constant FLAG_IPV4_PRTCL	: natural := 1;
	constant FLAG_IP_ADR		: natural := 2;
	constant FLAG_UDP_PRTCL		: natural := 3;
	constant FLAG_PORT_MATCH	: natural := 4;

	signal frame_flag_status : std_logic_vector(FRAME_FLAG_CNT - 1 downto 0);


	
	--=========================================================================
    -- Components and their signals
    --=========================================================================
	
	component COREFIFO_C0
		port (
			WCLOCK		: in std_logic;
			RCLOCK		: in std_logic;
			RESET		: in std_logic;
			WE			: in std_logic;
			RE			: in std_logic;
			FULL		: out std_logic;
			EMPTY		: out std_logic;
			OVERFLOW	: out std_logic;
			UNDERFLOW	: out std_logic;
			DATA		: in std_logic_vector(7 downto 0);
			Q			: out std_logic_vector(15 downto 0);
			DVLD		: out std_logic
		);
	end component;

	signal FIFO_C0_WE			: std_logic;
	signal FIFO_C0_RE			: std_logic;
	signal FIFO_C0_FULL			: std_logic;
	signal FIFO_C0_EMPTY		: std_logic;
	signal FIFO_C0_OVERFLOW		: std_logic;
	signal FIFO_C0_UNDERFLOW	: std_logic;
	signal FIFO_C0_DATA			: std_logic_vector(7 downto 0);
	signal FIFO_C0_Q			: std_logic_vector(15 downto 0);
	signal FIFO_C0_DVLD			: std_logic;

begin


	--=========================================================================
    -- LOGIC USING PCLK BELOW
	-- APB interface
	-- master CDC for RXCLK domain
    --=========================================================================

	-- addresses from ARM core adhere to 4 byte boundary rules
	PADDR_sig <= to_integer(unsigned(PADDR(7 downto 2)));
	PWDATA_sig <= PWDATA;
	PREADY <= '1';
	PSLVERR <= '0';
	
	-- BEGIN APB Register Read logic
	p_APB_Reg_Read : process(PCLK, RSTn)
    begin
        if(RSTn = '0') then
            PRDATA_sig <= (others => '0');
        elsif(rising_edge(PCLK)) then
            if(PWRITE = '0' and PSEL = '1') then
                case PADDR_sig is
					when APB_CTRL_ADDR =>
						PRDATA_sig <= APB_regs(APB_CTRL_ADDR);
					when APB_STAT_ADDR =>
						PRDATA_sig <= APB_regs(APB_STAT_ADDR);
					when APB_MAC0_ADDR =>
						PRDATA_sig <= APB_regs(APB_MAC0_ADDR);
					when APB_MAC1_ADDR =>
						PRDATA_sig <= APB_regs(APB_MAC1_ADDR);
					when APB_IPAD_ADDR =>
						PRDATA_sig <= APB_regs(APB_IPAD_ADDR);
					when APB_PORT_ADDR =>
						PRDATA_sig <= APB_regs(APB_PORT_ADDR);
					when APB_TRAP_CNT_ADDR =>
						PRDATA_sig <= APB_regs(APB_TRAP_CNT_ADDR);
					when APB_BLOCK_CNT_ADDR =>
						PRDATA_sig <= APB_regs(APB_BLOCK_CNT_ADDR);
                    when others =>
                        PRDATA_sig <= (others => '0');
                end case;
            else
                PRDATA_sig <= (others => '0');
            end if;
        end if;
    end process;
	-- END APB Register Read logic

	-- BEGIN APB Register Write logic
	p_APB_reg_ctrl_write : process(PCLK, RSTn)
	begin
		if(RSTn = '0') then
            APB_regs(APB_CTRL_ADDR) <= (0 => '1', others => '0');
        elsif(rising_edge(PCLK)) then
			if(PSEL = '1' and PENABLE = '1' and PWRITE = '1' and PADDR_sig = APB_CTRL_ADDR) then
				-- bit 	: description
				-- 0	: GMII trap enable. default 0; 0: off, 1: on
				-- 1	: Filter on MAC address. default 1; 0: filter off, 1: filter on
				-- 2	: Update config. Pause GMIICLK domain and passes config signals. default 0; auto reset to 0 upon completion
				-- 3	: 
                APB_regs(APB_CTRL_ADDR) <= PWDATA_sig;
            else
				if(RXCLK_is_off_rx = '1') then
					-- RXCLK domain is 'off'.
					APB_regs(APB_CTRL_ADDR)(2) <= '0';
				end if;
            end if;
        end if;
	end process;



	p_APB_reg_stat_write : process(PCLK, RSTn)
	begin
		if(RSTn = '0') then
            APB_regs(APB_STAT_ADDR) <= (others => '0');
        elsif(rising_edge(PCLK)) then
            if(PSEL = '1' and PENABLE = '1' and PWRITE = '1' and PADDR_sig = APB_STAT_ADDR) then
                null;
			else
				-- bit 	: description
				-- 0	: GMII trap is active. default 0; 0: off, 1: on
				-- 1	: 
				-- 2	: 
				-- 3	: 
				APB_regs(APB_STAT_ADDR)(0) <= not RXCLK_is_off_rx;
            end if;
        end if;
	end process;

	rx_is_on <= APB_regs(APB_STAT_ADDR)(0);
	--p_APB_reg_stat_comb : process()
	--begin
	--	
	--end process;

	p_APB_reg_mac0_write : process(PCLK, RSTn)
	begin
		if(RSTn = '0') then
            APB_regs(APB_MAC0_ADDR) <= X"22" & X"22" & X"22" & X"22";
        elsif(rising_edge(PCLK)) then
			if(PSEL = '1' and PENABLE = '1' and PWRITE = '1' and PADDR_sig = APB_MAC0_ADDR) then
				-- bit 	: description
				-- 31-0	: Lower 4 bytes of MAC address
                APB_regs(APB_MAC0_ADDR) <= PWDATA_sig;
            else
                null;
            end if;
        end if;
	end process;

	p_APB_reg_mac1_write : process(PCLK, RSTn)
	begin
		if(RSTn = '0') then
            APB_regs(APB_MAC1_ADDR) <= X"0000" & X"22" & X"22";
        elsif(rising_edge(PCLK)) then
			if(PSEL = '1' and PENABLE = '1' and PWRITE = '1' and PADDR_sig = APB_MAC1_ADDR) then
				-- bit 	: description
				-- 15-0	: Upper 2 bytes of MAC address
                APB_regs(APB_MAC1_ADDR) <= X"0000" & PWDATA_sig(15 downto 0);
            else
                null;
            end if;
        end if;
	end process;

	p_APB_reg_ip_addr_write : process(PCLK, RSTn)
	begin
		if(RSTn = '0') then
            APB_regs(APB_IPAD_ADDR) <= X"64" & X"64" & X"64" & X"C8";
        elsif(rising_edge(PCLK)) then
			if(PSEL = '1' and PENABLE = '1' and PWRITE = '1' and PADDR_sig = APB_IPAD_ADDR) then
				-- bit 	: description
				-- 31-0	: 4 bytes of IP address
                APB_regs(APB_IPAD_ADDR) <= PWDATA_sig;
            else
                null;
            end if;
        end if;
	end process;

	p_APB_reg_udp_port_write : process(PCLK, RSTn)
	begin
		if(RSTn = '0') then
            APB_regs(APB_PORT_ADDR) <= X"0000" & X"DA7A";
        elsif(rising_edge(PCLK)) then
			if(PSEL = '1' and PENABLE = '1' and PWRITE = '1' and PADDR_sig = APB_PORT_ADDR) then
				-- bit 	: description
				-- 15-0	: 2 bytes of UDP port
                APB_regs(APB_PORT_ADDR) <= X"0000" & PWDATA_sig(15 downto 0);
            else
                null;
            end if;
        end if;
	end process;

	p_APB_reg_trap_cnt_write : process(PCLK, RSTn)
	begin
		if(RSTn = '0') then
            APB_regs(APB_TRAP_CNT_ADDR) <= (others => '0');
        elsif(rising_edge(PCLK)) then
            if(PSEL = '1' and PENABLE = '1' and PWRITE = '1' and PADDR_sig = APB_TRAP_CNT_ADDR) then
                --APB_regs(APB_TRAP_CNT_ADDR) <= PWDATA_sig;
            else
                null;
            end if;
        end if;
	end process;

	p_APB_reg_block_cnt_write : process(PCLK, RSTn)
	begin
		if(RSTn = '0') then
            APB_regs(APB_BLOCK_CNT_ADDR) <= (others => '0');
        elsif(rising_edge(PCLK)) then
            if(PSEL = '1' and PENABLE = '1' and PWRITE = '1' and PADDR_sig = APB_BLOCK_CNT_ADDR) then
                --APB_regs(APB_BLOCK_CNT_ADDR) <= PWDATA_sig;
            else
                null;
            end if;
        end if;
	end process;
	-- END APB Register Write logic


	p_PCLK_ctrl_cmd : process(PCLK, RSTn)
	begin
		if(RSTn = '0') then
			RXCLK_set_off_tx <= '1';
			-- PCLK_cmd_state reset must match APB_CTRL_ADDR
			PCLK_cmd_state <= set_off;
		elsif(rising_edge(PCLK)) then
			case PCLK_cmd_state is
				when set_off =>

					RXCLK_set_off_tx <= '1';

					if(APB_regs(APB_CTRL_ADDR)(0) = '1' and APB_regs(APB_CTRL_ADDR)(2) = '0') then
						PCLK_cmd_state <= set_on;
					elsif(RXCLK_is_off_rx = '1') then
						PCLK_cmd_state <= is_off;
					end if;
				when is_off =>
					RXCLK_set_off_tx <= '1';

					if(APB_regs(APB_CTRL_ADDR)(0) = '1' and APB_regs(APB_CTRL_ADDR)(2) = '0') then
						PCLK_cmd_state <= set_on;
					elsif(RXCLK_is_off_rx = '0') then
						PCLK_cmd_state <= set_off;
					end if;
				when set_on =>
					RXCLK_set_off_tx <= '0';

					if(APB_regs(APB_CTRL_ADDR)(0) = '0' or APB_regs(APB_CTRL_ADDR)(2) = '1') then
						PCLK_cmd_state <= set_off;
					elsif(RXCLK_is_off_rx = '0') then
						PCLK_cmd_state <= is_on;
					end if;
				when is_on =>
					RXCLK_set_off_tx <= '0';

					if(APB_regs(APB_CTRL_ADDR)(0) = '0' or APB_regs(APB_CTRL_ADDR)(2) = '1') then
						PCLK_cmd_state <= set_off;
					elsif(RXCLK_is_off_rx = '1') then
						PCLK_cmd_state <= set_on;
					end if;
				when others =>
			end case;
		end if;
	end process;


	p_PCLK_cdc_sync : process(PCLK, RSTn)
		variable RXCLK_is_off_rx_var : std_logic_vector(SYNC_DEPTH - 1 downto 0);
	begin
		if(RSTn = '0') then
			RXCLK_is_off_rx_var := (others => '0');
			RXCLK_is_off_rx <= '0';
		elsif(rising_edge(PCLK)) then
			-- sync the off status from RXCLK domain
			RXCLK_is_off_rx_var := RXCLK_is_off_tx & RXCLK_is_off_rx_var(RXCLK_is_off_rx_var'high downto 1);
			RXCLK_is_off_rx <= RXCLK_is_off_rx_var(0);
		end if;
	end process;


	p_FIFO_extracter_sync : process(PCLK, RSTn)
	begin
		if(RSTn = '0') then
			--FIFO_C0_RE <= '0';
			Data_o <= (others => '0');
			Data_o_Valid <= '0';
		elsif(rising_edge(PCLK)) then
			--if(FIFO_C0_EMPTY = '0') then
			--	FIFO_C0_RE <= '1';
			--else
			--	FIFO_C0_RE <= '0';
			--end if;

			Data_o <= FIFO_C0_Q(7 downto 0) & FIFO_C0_Q(15 downto 8);
			Data_o_Valid <= FIFO_C0_DVLD;
		end if;
	end process;

	p_FIFO_extracter_comb : process(FIFO_C0_EMPTY)
	begin
		FIFO_C0_RE <= not FIFO_C0_EMPTY;
	end process;
	


	--=========================================================================
    -- FIFO
	-- data is written to the FIFO from RXCLK domain from the GMII interface
	-- data is read from the FIFO in the PCLK domain and output directly to pins
    --=========================================================================

	COREFIFO_C0_0 : COREFIFO_C0
		port map(
			WCLOCK	=> RXCLK,
			RCLOCK	=> PCLK,
			RESET	=> RSTn,
			WE			=> FIFO_C0_WE,
			RE			=> FIFO_C0_RE,
			FULL		=> FIFO_C0_FULL,
			EMPTY		=> FIFO_C0_EMPTY,
			OVERFLOW	=> FIFO_C0_OVERFLOW,
			UNDERFLOW	=> FIFO_C0_UNDERFLOW,
			DATA		=> FIFO_C0_DATA,
			Q			=> FIFO_C0_Q,
			DVLD		=> FIFO_C0_DVLD
		);

	--=========================================================================
    -- LOGIC USING RXCLK BELOW
	-- receive from GMII interface and store in async FIFO
	-- slave CDC from PCLK domain and APB registers
    --=========================================================================

	p_RXCLK_cdc_sync : process(RXCLK, RSTn)
		-- sync vectors use index 0 as fully synced and index 'high as input
		variable RXCLK_set_off_rx_var : std_logic_vector(SYNC_DEPTH - 1 downto 0);
	begin
		if(RStn = '0') then

			RXCLK_set_off_rx_var := (others => '0');
			RXCLK_set_off_rx <= '0';
		elsif(rising_edge(RXCLK)) then
			-- sync the off command from PCLK domain
			RXCLK_set_off_rx_var := RXCLK_set_off_tx & RXCLK_set_off_rx_var(RXCLK_set_off_rx_var'high downto 1);
			RXCLK_set_off_rx <= RXCLK_set_off_rx_var(0);
		end if;
	end process;


	p_RXCLK_ctrl : process(RXCLK, RSTn)
	begin
		if(RSTn = '0') then

			my_stuff.mac_adr	<= (others => '0');
			my_stuff.ip_adr		<= (others => '0');
			my_stuff.udp_port	<= (others => '0');
		elsif(rising_edge(RXCLK)) then

			-- if RXCLK domain is off (paused) update RXCLK control registers
			if(RXCLK_is_off_tx = '1') then
				-- These signals will be stable for a long time and unused when crossing is enabled so no sync
				gmii_reg_ctrl 		<= APB_regs(APB_CTRL_ADDR);
				my_stuff.mac_adr	<= APB_regs(APB_MAC1_ADDR)(15 downto 0) & APB_regs(APB_MAC0_ADDR);
				my_stuff.ip_adr		<= APB_regs(APB_IPAD_ADDR);
				my_stuff.udp_port	<= APB_regs(APB_PORT_ADDR)(15 downto 0);
			else
				null;
			end if;

		end if;
	end process;

		
	-- GMII receive logic

	p_GMII_injest : process(RXCLK, RSTn)
	begin
		if(RSTn = '0') then
			GMII_in_buf <= (others => (others => '0'));
			GMII_dv_buf <= '0';
		elsif(rising_edge(RXCLK)) then
			if(RXCLK_is_off_tx = '1') then
				GMII_in_buf <= (others => (others => '0'));
				GMII_dv_buf <= '0';
			else
				GMII_in_buf <= GMII_RXD & GMII_in_buf(0 to GMII_in_buf'high - 1);
				GMII_dv_buf <= GMII_RX_DV;
			end if;
		end if;
	end process;

	--=========================================================================
	-- Convert:
	-- GMII_in_buf : (0 to GMII_BUF_DEPTH - 1) of std_logic_vector(7 downto 0)
	-- to:
	-- GMII_in_buf_1d : std_logic_vector((GMII_BUF_DEPTH * 8) - 1 downto 0)
	--
	-- GMII_in_buf_1d(7 downto 0) <= GMII_in_buf(0);
	-- GMII_in_buf_1d(15 downto 8) <= GMII_in_buf(1);
	-- etc.
	p_GMII_injest_comb : process(GMII_in_buf)
	begin
		for i in 0 to (GMII_BUF_DEPTH - 1) loop
			GMII_in_buf_1d((i + 1) * 8 - 1 downto i * 8) <= GMII_in_buf(i);
		end loop;
	end process;

	-- type RXCLK_states is (idle, off, frame_active, frame_trap, frame_ignore, frame_error);
	-- type header_decode_states is (eth, ipv4, udp);
	p_GMII_processing_seq : process(RXCLK, RSTn)
		--variable RXCLK_state_next_var : RXCLK_states;
		--variable header_decode_state_next_var : header_decode_states;
		variable header_flags_var : std_logic_vector(FRAME_FLAG_CNT - 1 downto 0);
	begin
		if(RSTn = '0') then
			RXCLK_state <= idle;
			header_decode_state <= eth;
			byte_counter <= 0;
			header_flags_var := (others => '0');
			frame_flag_status <= (others => '0');
			FIFO_C0_DATA <= (others => '0');
			FIFO_C0_WE <= '0';
		elsif(rising_edge(RXCLK)) then

			-- byte_counter is synched with the GMII_in_buf input. output requires + 1 (when spec is start 0 indexed)
			if(RXCLK_state = frame_active or RXCLK_state = frame_trap) then
				if(byte_counter = ETH_PACKET_MAX - 1) then
					null; -- maybe set error due to packet oversize
				else
					byte_counter <= byte_counter + 1;
				end if;
			else
				byte_counter <= 0;
			end if;

			case RXCLK_state is
				when idle =>
					if(RXCLK_set_off_rx = '1') then
						RXCLK_state <= off;
					elsif(GMII_in_buf(1) = ETH_PREAMBLE(7 downto 0) and GMII_in_buf(0) = ETH_SFD and GMII_dv_buf = '1') then
						RXCLK_state <= frame_active;
					end if;
					header_decode_state <= eth;
					header_flags_var := (others => '0');
					FIFO_C0_WE <= '0';
				when off =>
					if(RXCLK_set_off_rx = '0') then
						RXCLK_state <= idle;
					end if;
					header_decode_state <= eth;
					byte_counter <= 0;
					header_flags_var := (others => '0');
					FIFO_C0_WE <= '0';
				when frame_active =>
					case header_decode_state is
						when eth =>
							if(byte_counter = 5) then
								-- Compare destination MAC address
								if(GMII_in_buf_1d(6*8-1 downto 0) = my_stuff.mac_adr) then
									header_flags_var(FLAG_MAC_ADR) := '1';
								elsif(GMII_in_buf_1d(6*8-1 downto 0) = X"FFFFFFFFFFFF") then
									-- broadcast
									header_flags_var(FLAG_MAC_ADR) := '1';
								else
									header_flags_var(FLAG_MAC_ADR) := '0';
								end if;
							elsif(byte_counter = 13) then
								-- check Ethertype
								if(GMII_in_buf_1d(2*8-1 downto 0) = ETH_TYPE_IPV4) then
									header_flags_var(FLAG_IPV4_PRTCL) := '1';
								else
									header_flags_var(FLAG_IPV4_PRTCL) := '0';
								end if;

								-- last byte in Ethernet Header, prep for next header
								if(header_flags_var(FLAG_MAC_ADR) = '1' and header_flags_var(FLAG_IPV4_PRTCL) = '1') then
									-- flags are good, check next steps
									header_decode_state <= ipv4;
									RXCLK_state <= frame_active;
								elsif(header_flags_var(FLAG_MAC_ADR) = '1' and header_flags_var(FLAG_IPV4_PRTCL) = '0') then
									-- flags mismatch, wrong protocol, ignore
									header_decode_state <= eth;
									RXCLK_state <= frame_ignore;
								elsif(header_flags_var(FLAG_MAC_ADR) = '0') then
									-- flags mismatch, wrong MAC address, this packet's not for me
									header_decode_state <= eth;
									RXCLK_state <= frame_error;
								end if;
								byte_counter <= 0;
							end if;
						when ipv4 =>
							if(byte_counter = 3) then
								-- store ipv4 length
								ipv4_stuff.length <= GMII_in_buf(1) & GMII_in_buf(0);
							elsif(byte_counter = 9) then
								-- check ipv4 protocol
								if(GMII_in_buf(0) = IPV4_PRTCL_UDP) then
									header_flags_var(FLAG_UDP_PRTCL) := '1';
								else
									header_flags_var(FLAG_UDP_PRTCL) := '0';
								end if;
							elsif(byte_counter = 11) then
								-- store ipv4 checksum
								ipv4_stuff.checksum <= GMII_in_buf(1) & GMII_in_buf(0);
							elsif(byte_counter = 19) then
								-- check destination IP address
								if(GMII_in_buf_1d(4*8-1 downto 0) = my_stuff.ip_adr) then
									header_flags_var(FLAG_IP_ADR) := '1';
								elsif(GMII_in_buf_1d(4*8-1 downto 0) = X"FFFFFFFF") then
									header_flags_var(FLAG_IP_ADR) := '1';
								elsif(GMII_in_buf_1d(4*8-1 downto 0) = X"646464FF") then
									header_flags_var(FLAG_IP_ADR) := '1';
								else
									header_flags_var(FLAG_IP_ADR) := '0';
								end if;

								-- last byte in ipv4 Header, prep for next header
								if(header_flags_var(FLAG_IP_ADR) = '1' and header_flags_var(FLAG_UDP_PRTCL) = '1') then
									-- flags are good, check next steps
									header_decode_state <= udp;
									RXCLK_state <= frame_active;
								elsif(header_flags_var(FLAG_IP_ADR) = '1' and header_flags_var(FLAG_UDP_PRTCL) = '0') then
									-- flags mismatch, wrong protocol, ignore
									header_decode_state <= eth;
									RXCLK_state <= frame_ignore;
								elsif(header_flags_var(FLAG_IP_ADR) = '0') then
									-- flags mismatch, wrong IP address, this packet's not for me
									header_decode_state <= eth;
									RXCLK_state <= frame_error;
								end if;
								byte_counter <= 0;
							end if;
						when udp =>
							if(byte_counter = 3) then
								-- check udp port
								if(GMII_in_buf_1d(2*8-1 downto 0) = my_stuff.udp_port) then
									header_flags_var(FLAG_PORT_MATCH) := '1';
								else
									header_flags_var(FLAG_PORT_MATCH) := '0';
								end if;
							elsif(byte_counter = 5) then
								-- record udp length
								udp_stuff.length <= GMII_in_buf(1) & GMII_in_buf(0);
							elsif(byte_counter = 7) then
								-- udp checksum, ignore this
								--udp_stuff.checksum <= GMII_in_buf(1) & GMII_in_buf(0);

								-- last byte in udp Header, prep for next thing
								if(header_flags_var(FLAG_PORT_MATCH) = '1') then
									-- flags are good, check next steps
									header_decode_state <= eth;
									RXCLK_state <= frame_trap;
								elsif(header_flags_var(FLAG_PORT_MATCH) = '0') then
									-- flags mismatch, wrong UDP port, ignore
									header_decode_state <= eth;
									RXCLK_state <= frame_ignore;
									byte_counter <= 0;
								end if;
							end if;
						when others =>
							header_decode_state <= eth;
					end case;

					FIFO_C0_WE <= '0';
					if(GMII_dv_buf = '0') then
						RXCLK_state <= idle;
					end if;
				when frame_trap =>
					if(byte_counter /= to_integer(unsigned(udp_stuff.length)) + 1 ) then
						byte_counter <= byte_counter + 1;
						FIFO_C0_DATA <= GMII_in_buf(0);
						FIFO_C0_WE <= '1';
					else
						RXCLK_state <= idle;
						FIFO_C0_WE <= '0';
					end if;
				when frame_ignore =>
					FIFO_C0_WE <= '0';
					if(GMII_dv_buf = '0') then
						RXCLK_state <= idle;
					end if;
				when frame_error =>
					FIFO_C0_WE <= '0';
					if(GMII_dv_buf = '0') then
						RXCLK_state <= idle;
					end if;
				when others =>
					if(RXCLK_set_off_rx = '1') then
						RXCLK_state <= off;
					else
						RXCLK_state <= idle;
					end if;
					FIFO_C0_WE <= '0';
			end case;

			frame_flag_status <= header_flags_var;
		end if;
	end process;

	p_GMII_processing_comb : process(RXCLK_state, GMII_RX_ER_i)
	begin
		if(RXCLK_state = off) then
			RXCLK_is_off_tx <= '1';
		else
			RXCLK_is_off_tx <= '0';
		end if;

		case RXCLK_state is
			when frame_trap =>
				GMII_RX_ER_o <= '1';
			when frame_error =>
				GMII_RX_ER_o <= '1';
			when others =>
				GMII_RX_ER_o <= GMII_RX_ER_i;
		end case;
	end process;
	

   -- architecture body
end architecture_GMII_MAC_Filter_Sniffer;