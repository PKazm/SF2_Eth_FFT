----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Sat Apr 18 02:15:36 2020
-- Testbench Template
-- This is a basic testbench that instantiates your design with basic 
-- clock and reset pins connected.  If your design has special
-- clock/reset or testbench driver requirements then you should 
-- copy this file and modify it. 
----------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: FFT_AHB_Wrapper_tb.vhd
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library modelsim_lib;
use modelsim_lib.util.all;


use work.FFT_package.all;
use work.AHB_Package.all;


entity testbench is
end testbench;

architecture behavioral of testbench is

    constant SYSCLK_PERIOD : time := 10 ns; -- 100MHZ

    signal SYSCLK : std_logic := '0';
    signal NSYSRESET : std_logic := '0';


    constant SAMPLE_WIDTH_INT : natural := 9;
    constant SAMPLE_CNT_EXP : natural := 10;

    component FFT_AHB_Wrapper
        -- ports
        port( 
            CLK : in std_logic;
            RSTn : in std_logic;

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
    end component;

    -- AHB signals
    signal HADDR        : std_logic_vector(7 downto 0);
    signal HSEL         : std_logic;
    signal HWDATA       : std_logic_vector(15 downto 0);
    signal HWRITE       : std_logic;
    signal HSIZE        : std_logic_vector(2 downto 0);
    signal HTRANS       : std_logic_vector(1 downto 0);
    signal HMASTLOCK    : std_logic;
    signal HBURST       : std_logic_vector(2 downto 0);
    signal HPROT        : std_logic_vector(3 downto 0);
    signal HREADYIN     : std_logic;
    signal HRDATA       : std_logic_vector(15 downto 0);
    signal HRESP        : std_logic_vector(1 downto 0);
    signal HREADYOUT    : std_logic;

    signal INT          : std_logic;
    -- AHB signals

    signal next_HADDR : std_logic_vector(7 downto 0);
    signal next_HWRITE : std_logic;
    signal next_HWDATA : std_logic_vector(15 downto 0);
    --signal last_HRDATA : std_logic_vector(15 downto 0);

    type ahb_states is (nowait, waiting_int, waiting_ext);
    signal ahb_state : ahb_states;
    signal smpl_read : std_logic;
    signal smpl_data_stable : std_logic;
    signal abs_val_read : std_logic;
    signal abs_val_stable : std_logic;

    signal HADDR_A_sig      : natural range 0 to 7;
    signal HADDR_S_sig      : natural range 0 to 7;
    signal HADDR_sig_use    : natural range 0 to 7;


    signal FFT_in_w_en_sig          : std_logic;
    signal FFT_in_w_data_real_sig   : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal FFT_in_w_data_imag_sig   : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal FFT_in_w_done_sig        : std_logic;
    signal FFT_in_w_ready_sig       : std_logic;
    signal FFT_in_full_sig          : std_logic;

    signal i_comp_ram_w_en          : w_en_array_type;
    signal i_comp_ram_adr           : adr_array_type;
    signal i_comp_ram_dat_w         : ram_dat_array_type;
    signal i_comp_ram_dat_r         : ram_dat_array_type;
    signal i_comp_ram_adr_start     : std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);

    signal FFT_out_r_en_sig         : std_logic;
    signal FFT_out_data_adr_sig     : std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);
    signal FFT_out_read_done_sig    : std_logic;
    signal FFT_out_dat_real_sig     : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal FFT_out_dat_imag_sig     : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal FFT_out_data_ready_sig   : std_logic;
    signal FFT_out_valid_sig        : std_logic;

    signal o_comp_ram_w_en          : w_en_array_type;
    signal o_comp_ram_adr           : adr_array_type;
    signal o_comp_ram_dat_w         : ram_dat_array_type;
    signal o_comp_ram_dat_r         : ram_dat_array_type;

    signal AMpBM_0_val_A_sig        : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal AMpBM_0_val_B_sig        : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal AMpBM_0_in_valid_sig     : std_logic;
    signal AMpBM_0_out_valid_sig    : std_logic;
    signal in_valid_sig             : std_logic;
    signal valid_pipe               : std_logic_vector(5 - 1 downto 0);


    type ram_dist_states is(ram_to_io, ram_to_tf);
    signal ram_dist_state_spy : ram_dist_states;

    type APB_register_type is array (8 - 1 downto 0) of std_logic_vector(15 downto 0);
    signal APB_regs_spy : APB_register_type;

    type DPSRAM_type is array (0 to 1023) of std_logic_vector(17 downto 0);
    signal FFT_mem_0 : DPSRAM_type;
    signal FFT_mem_1 : DPSRAM_type;

    signal mem_adr_spy : unsigned(SAMPLE_CNT_EXP - 1 downto 0);

    type test_sample_mem is array (0 to (2**10) - 1) of std_logic_vector(7 downto 0);
    constant TEST_SAMPLES : test_sample_mem := (
        std_logic_vector(to_unsigned(127, 8)),
        std_logic_vector(to_unsigned(129, 8)),
        std_logic_vector(to_unsigned(130, 8)),
        std_logic_vector(to_unsigned(132, 8)),
        std_logic_vector(to_unsigned(133, 8)),
        std_logic_vector(to_unsigned(135, 8)),
        std_logic_vector(to_unsigned(136, 8)),
        std_logic_vector(to_unsigned(138, 8)),
        std_logic_vector(to_unsigned(139, 8)),
        std_logic_vector(to_unsigned(141, 8)),
        std_logic_vector(to_unsigned(143, 8)),
        std_logic_vector(to_unsigned(144, 8)),
        std_logic_vector(to_unsigned(146, 8)),
        std_logic_vector(to_unsigned(147, 8)),
        std_logic_vector(to_unsigned(149, 8)),
        std_logic_vector(to_unsigned(150, 8)),
        std_logic_vector(to_unsigned(152, 8)),
        std_logic_vector(to_unsigned(153, 8)),
        std_logic_vector(to_unsigned(155, 8)),
        std_logic_vector(to_unsigned(156, 8)),
        std_logic_vector(to_unsigned(158, 8)),
        std_logic_vector(to_unsigned(159, 8)),
        std_logic_vector(to_unsigned(161, 8)),
        std_logic_vector(to_unsigned(162, 8)),
        std_logic_vector(to_unsigned(164, 8)),
        std_logic_vector(to_unsigned(165, 8)),
        std_logic_vector(to_unsigned(167, 8)),
        std_logic_vector(to_unsigned(168, 8)),
        std_logic_vector(to_unsigned(170, 8)),
        std_logic_vector(to_unsigned(171, 8)),
        std_logic_vector(to_unsigned(173, 8)),
        std_logic_vector(to_unsigned(174, 8)),
        std_logic_vector(to_unsigned(176, 8)),
        std_logic_vector(to_unsigned(177, 8)),
        std_logic_vector(to_unsigned(178, 8)),
        std_logic_vector(to_unsigned(180, 8)),
        std_logic_vector(to_unsigned(181, 8)),
        std_logic_vector(to_unsigned(183, 8)),
        std_logic_vector(to_unsigned(184, 8)),
        std_logic_vector(to_unsigned(185, 8)),
        std_logic_vector(to_unsigned(187, 8)),
        std_logic_vector(to_unsigned(188, 8)),
        std_logic_vector(to_unsigned(190, 8)),
        std_logic_vector(to_unsigned(191, 8)),
        std_logic_vector(to_unsigned(192, 8)),
        std_logic_vector(to_unsigned(194, 8)),
        std_logic_vector(to_unsigned(195, 8)),
        std_logic_vector(to_unsigned(196, 8)),
        std_logic_vector(to_unsigned(198, 8)),
        std_logic_vector(to_unsigned(199, 8)),
        std_logic_vector(to_unsigned(200, 8)),
        std_logic_vector(to_unsigned(201, 8)),
        std_logic_vector(to_unsigned(203, 8)),
        std_logic_vector(to_unsigned(204, 8)),
        std_logic_vector(to_unsigned(205, 8)),
        std_logic_vector(to_unsigned(206, 8)),
        std_logic_vector(to_unsigned(208, 8)),
        std_logic_vector(to_unsigned(209, 8)),
        std_logic_vector(to_unsigned(210, 8)),
        std_logic_vector(to_unsigned(211, 8)),
        std_logic_vector(to_unsigned(212, 8)),
        std_logic_vector(to_unsigned(213, 8)),
        std_logic_vector(to_unsigned(215, 8)),
        std_logic_vector(to_unsigned(216, 8)),
        std_logic_vector(to_unsigned(217, 8)),
        std_logic_vector(to_unsigned(218, 8)),
        std_logic_vector(to_unsigned(219, 8)),
        std_logic_vector(to_unsigned(220, 8)),
        std_logic_vector(to_unsigned(221, 8)),
        std_logic_vector(to_unsigned(222, 8)),
        std_logic_vector(to_unsigned(223, 8)),
        std_logic_vector(to_unsigned(224, 8)),
        std_logic_vector(to_unsigned(225, 8)),
        std_logic_vector(to_unsigned(226, 8)),
        std_logic_vector(to_unsigned(227, 8)),
        std_logic_vector(to_unsigned(228, 8)),
        std_logic_vector(to_unsigned(229, 8)),
        std_logic_vector(to_unsigned(230, 8)),
        std_logic_vector(to_unsigned(231, 8)),
        std_logic_vector(to_unsigned(232, 8)),
        std_logic_vector(to_unsigned(233, 8)),
        std_logic_vector(to_unsigned(233, 8)),
        std_logic_vector(to_unsigned(234, 8)),
        std_logic_vector(to_unsigned(235, 8)),
        std_logic_vector(to_unsigned(236, 8)),
        std_logic_vector(to_unsigned(237, 8)),
        std_logic_vector(to_unsigned(238, 8)),
        std_logic_vector(to_unsigned(238, 8)),
        std_logic_vector(to_unsigned(239, 8)),
        std_logic_vector(to_unsigned(240, 8)),
        std_logic_vector(to_unsigned(240, 8)),
        std_logic_vector(to_unsigned(241, 8)),
        std_logic_vector(to_unsigned(242, 8)),
        std_logic_vector(to_unsigned(242, 8)),
        std_logic_vector(to_unsigned(243, 8)),
        std_logic_vector(to_unsigned(244, 8)),
        std_logic_vector(to_unsigned(244, 8)),
        std_logic_vector(to_unsigned(245, 8)),
        std_logic_vector(to_unsigned(245, 8)),
        std_logic_vector(to_unsigned(246, 8)),
        std_logic_vector(to_unsigned(247, 8)),
        std_logic_vector(to_unsigned(247, 8)),
        std_logic_vector(to_unsigned(248, 8)),
        std_logic_vector(to_unsigned(248, 8)),
        std_logic_vector(to_unsigned(249, 8)),
        std_logic_vector(to_unsigned(249, 8)),
        std_logic_vector(to_unsigned(249, 8)),
        std_logic_vector(to_unsigned(250, 8)),
        std_logic_vector(to_unsigned(250, 8)),
        std_logic_vector(to_unsigned(251, 8)),
        std_logic_vector(to_unsigned(251, 8)),
        std_logic_vector(to_unsigned(251, 8)),
        std_logic_vector(to_unsigned(252, 8)),
        std_logic_vector(to_unsigned(252, 8)),
        std_logic_vector(to_unsigned(252, 8)),
        std_logic_vector(to_unsigned(252, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(252, 8)),
        std_logic_vector(to_unsigned(252, 8)),
        std_logic_vector(to_unsigned(252, 8)),
        std_logic_vector(to_unsigned(252, 8)),
        std_logic_vector(to_unsigned(251, 8)),
        std_logic_vector(to_unsigned(251, 8)),
        std_logic_vector(to_unsigned(251, 8)),
        std_logic_vector(to_unsigned(250, 8)),
        std_logic_vector(to_unsigned(250, 8)),
        std_logic_vector(to_unsigned(249, 8)),
        std_logic_vector(to_unsigned(249, 8)),
        std_logic_vector(to_unsigned(249, 8)),
        std_logic_vector(to_unsigned(248, 8)),
        std_logic_vector(to_unsigned(248, 8)),
        std_logic_vector(to_unsigned(247, 8)),
        std_logic_vector(to_unsigned(247, 8)),
        std_logic_vector(to_unsigned(246, 8)),
        std_logic_vector(to_unsigned(245, 8)),
        std_logic_vector(to_unsigned(245, 8)),
        std_logic_vector(to_unsigned(244, 8)),
        std_logic_vector(to_unsigned(244, 8)),
        std_logic_vector(to_unsigned(243, 8)),
        std_logic_vector(to_unsigned(242, 8)),
        std_logic_vector(to_unsigned(242, 8)),
        std_logic_vector(to_unsigned(241, 8)),
        std_logic_vector(to_unsigned(240, 8)),
        std_logic_vector(to_unsigned(240, 8)),
        std_logic_vector(to_unsigned(239, 8)),
        std_logic_vector(to_unsigned(238, 8)),
        std_logic_vector(to_unsigned(238, 8)),
        std_logic_vector(to_unsigned(237, 8)),
        std_logic_vector(to_unsigned(236, 8)),
        std_logic_vector(to_unsigned(235, 8)),
        std_logic_vector(to_unsigned(234, 8)),
        std_logic_vector(to_unsigned(233, 8)),
        std_logic_vector(to_unsigned(233, 8)),
        std_logic_vector(to_unsigned(232, 8)),
        std_logic_vector(to_unsigned(231, 8)),
        std_logic_vector(to_unsigned(230, 8)),
        std_logic_vector(to_unsigned(229, 8)),
        std_logic_vector(to_unsigned(228, 8)),
        std_logic_vector(to_unsigned(227, 8)),
        std_logic_vector(to_unsigned(226, 8)),
        std_logic_vector(to_unsigned(225, 8)),
        std_logic_vector(to_unsigned(224, 8)),
        std_logic_vector(to_unsigned(223, 8)),
        std_logic_vector(to_unsigned(222, 8)),
        std_logic_vector(to_unsigned(221, 8)),
        std_logic_vector(to_unsigned(220, 8)),
        std_logic_vector(to_unsigned(219, 8)),
        std_logic_vector(to_unsigned(218, 8)),
        std_logic_vector(to_unsigned(217, 8)),
        std_logic_vector(to_unsigned(216, 8)),
        std_logic_vector(to_unsigned(215, 8)),
        std_logic_vector(to_unsigned(213, 8)),
        std_logic_vector(to_unsigned(212, 8)),
        std_logic_vector(to_unsigned(211, 8)),
        std_logic_vector(to_unsigned(210, 8)),
        std_logic_vector(to_unsigned(209, 8)),
        std_logic_vector(to_unsigned(208, 8)),
        std_logic_vector(to_unsigned(206, 8)),
        std_logic_vector(to_unsigned(205, 8)),
        std_logic_vector(to_unsigned(204, 8)),
        std_logic_vector(to_unsigned(203, 8)),
        std_logic_vector(to_unsigned(201, 8)),
        std_logic_vector(to_unsigned(200, 8)),
        std_logic_vector(to_unsigned(199, 8)),
        std_logic_vector(to_unsigned(198, 8)),
        std_logic_vector(to_unsigned(196, 8)),
        std_logic_vector(to_unsigned(195, 8)),
        std_logic_vector(to_unsigned(194, 8)),
        std_logic_vector(to_unsigned(192, 8)),
        std_logic_vector(to_unsigned(191, 8)),
        std_logic_vector(to_unsigned(190, 8)),
        std_logic_vector(to_unsigned(188, 8)),
        std_logic_vector(to_unsigned(187, 8)),
        std_logic_vector(to_unsigned(185, 8)),
        std_logic_vector(to_unsigned(184, 8)),
        std_logic_vector(to_unsigned(183, 8)),
        std_logic_vector(to_unsigned(181, 8)),
        std_logic_vector(to_unsigned(180, 8)),
        std_logic_vector(to_unsigned(178, 8)),
        std_logic_vector(to_unsigned(177, 8)),
        std_logic_vector(to_unsigned(176, 8)),
        std_logic_vector(to_unsigned(174, 8)),
        std_logic_vector(to_unsigned(173, 8)),
        std_logic_vector(to_unsigned(171, 8)),
        std_logic_vector(to_unsigned(170, 8)),
        std_logic_vector(to_unsigned(168, 8)),
        std_logic_vector(to_unsigned(167, 8)),
        std_logic_vector(to_unsigned(165, 8)),
        std_logic_vector(to_unsigned(164, 8)),
        std_logic_vector(to_unsigned(162, 8)),
        std_logic_vector(to_unsigned(161, 8)),
        std_logic_vector(to_unsigned(159, 8)),
        std_logic_vector(to_unsigned(158, 8)),
        std_logic_vector(to_unsigned(156, 8)),
        std_logic_vector(to_unsigned(155, 8)),
        std_logic_vector(to_unsigned(153, 8)),
        std_logic_vector(to_unsigned(152, 8)),
        std_logic_vector(to_unsigned(150, 8)),
        std_logic_vector(to_unsigned(149, 8)),
        std_logic_vector(to_unsigned(147, 8)),
        std_logic_vector(to_unsigned(146, 8)),
        std_logic_vector(to_unsigned(144, 8)),
        std_logic_vector(to_unsigned(143, 8)),
        std_logic_vector(to_unsigned(141, 8)),
        std_logic_vector(to_unsigned(139, 8)),
        std_logic_vector(to_unsigned(138, 8)),
        std_logic_vector(to_unsigned(136, 8)),
        std_logic_vector(to_unsigned(135, 8)),
        std_logic_vector(to_unsigned(133, 8)),
        std_logic_vector(to_unsigned(132, 8)),
        std_logic_vector(to_unsigned(130, 8)),
        std_logic_vector(to_unsigned(129, 8)),
        std_logic_vector(to_unsigned(127, 8)),
        std_logic_vector(to_unsigned(125, 8)),
        std_logic_vector(to_unsigned(124, 8)),
        std_logic_vector(to_unsigned(122, 8)),
        std_logic_vector(to_unsigned(121, 8)),
        std_logic_vector(to_unsigned(119, 8)),
        std_logic_vector(to_unsigned(118, 8)),
        std_logic_vector(to_unsigned(116, 8)),
        std_logic_vector(to_unsigned(115, 8)),
        std_logic_vector(to_unsigned(113, 8)),
        std_logic_vector(to_unsigned(111, 8)),
        std_logic_vector(to_unsigned(110, 8)),
        std_logic_vector(to_unsigned(108, 8)),
        std_logic_vector(to_unsigned(107, 8)),
        std_logic_vector(to_unsigned(105, 8)),
        std_logic_vector(to_unsigned(104, 8)),
        std_logic_vector(to_unsigned(102, 8)),
        std_logic_vector(to_unsigned(101, 8)),
        std_logic_vector(to_unsigned(99, 8)),
        std_logic_vector(to_unsigned(98, 8)),
        std_logic_vector(to_unsigned(96, 8)),
        std_logic_vector(to_unsigned(95, 8)),
        std_logic_vector(to_unsigned(93, 8)),
        std_logic_vector(to_unsigned(92, 8)),
        std_logic_vector(to_unsigned(90, 8)),
        std_logic_vector(to_unsigned(89, 8)),
        std_logic_vector(to_unsigned(87, 8)),
        std_logic_vector(to_unsigned(86, 8)),
        std_logic_vector(to_unsigned(84, 8)),
        std_logic_vector(to_unsigned(83, 8)),
        std_logic_vector(to_unsigned(81, 8)),
        std_logic_vector(to_unsigned(80, 8)),
        std_logic_vector(to_unsigned(78, 8)),
        std_logic_vector(to_unsigned(77, 8)),
        std_logic_vector(to_unsigned(76, 8)),
        std_logic_vector(to_unsigned(74, 8)),
        std_logic_vector(to_unsigned(73, 8)),
        std_logic_vector(to_unsigned(71, 8)),
        std_logic_vector(to_unsigned(70, 8)),
        std_logic_vector(to_unsigned(69, 8)),
        std_logic_vector(to_unsigned(67, 8)),
        std_logic_vector(to_unsigned(66, 8)),
        std_logic_vector(to_unsigned(64, 8)),
        std_logic_vector(to_unsigned(63, 8)),
        std_logic_vector(to_unsigned(62, 8)),
        std_logic_vector(to_unsigned(60, 8)),
        std_logic_vector(to_unsigned(59, 8)),
        std_logic_vector(to_unsigned(58, 8)),
        std_logic_vector(to_unsigned(56, 8)),
        std_logic_vector(to_unsigned(55, 8)),
        std_logic_vector(to_unsigned(54, 8)),
        std_logic_vector(to_unsigned(53, 8)),
        std_logic_vector(to_unsigned(51, 8)),
        std_logic_vector(to_unsigned(50, 8)),
        std_logic_vector(to_unsigned(49, 8)),
        std_logic_vector(to_unsigned(48, 8)),
        std_logic_vector(to_unsigned(46, 8)),
        std_logic_vector(to_unsigned(45, 8)),
        std_logic_vector(to_unsigned(44, 8)),
        std_logic_vector(to_unsigned(43, 8)),
        std_logic_vector(to_unsigned(42, 8)),
        std_logic_vector(to_unsigned(41, 8)),
        std_logic_vector(to_unsigned(39, 8)),
        std_logic_vector(to_unsigned(38, 8)),
        std_logic_vector(to_unsigned(37, 8)),
        std_logic_vector(to_unsigned(36, 8)),
        std_logic_vector(to_unsigned(35, 8)),
        std_logic_vector(to_unsigned(34, 8)),
        std_logic_vector(to_unsigned(33, 8)),
        std_logic_vector(to_unsigned(32, 8)),
        std_logic_vector(to_unsigned(31, 8)),
        std_logic_vector(to_unsigned(30, 8)),
        std_logic_vector(to_unsigned(29, 8)),
        std_logic_vector(to_unsigned(28, 8)),
        std_logic_vector(to_unsigned(27, 8)),
        std_logic_vector(to_unsigned(26, 8)),
        std_logic_vector(to_unsigned(25, 8)),
        std_logic_vector(to_unsigned(24, 8)),
        std_logic_vector(to_unsigned(23, 8)),
        std_logic_vector(to_unsigned(22, 8)),
        std_logic_vector(to_unsigned(21, 8)),
        std_logic_vector(to_unsigned(21, 8)),
        std_logic_vector(to_unsigned(20, 8)),
        std_logic_vector(to_unsigned(19, 8)),
        std_logic_vector(to_unsigned(18, 8)),
        std_logic_vector(to_unsigned(17, 8)),
        std_logic_vector(to_unsigned(16, 8)),
        std_logic_vector(to_unsigned(16, 8)),
        std_logic_vector(to_unsigned(15, 8)),
        std_logic_vector(to_unsigned(14, 8)),
        std_logic_vector(to_unsigned(14, 8)),
        std_logic_vector(to_unsigned(13, 8)),
        std_logic_vector(to_unsigned(12, 8)),
        std_logic_vector(to_unsigned(12, 8)),
        std_logic_vector(to_unsigned(11, 8)),
        std_logic_vector(to_unsigned(10, 8)),
        std_logic_vector(to_unsigned(10, 8)),
        std_logic_vector(to_unsigned(9, 8)),
        std_logic_vector(to_unsigned(9, 8)),
        std_logic_vector(to_unsigned(8, 8)),
        std_logic_vector(to_unsigned(7, 8)),
        std_logic_vector(to_unsigned(7, 8)),
        std_logic_vector(to_unsigned(6, 8)),
        std_logic_vector(to_unsigned(6, 8)),
        std_logic_vector(to_unsigned(5, 8)),
        std_logic_vector(to_unsigned(5, 8)),
        std_logic_vector(to_unsigned(5, 8)),
        std_logic_vector(to_unsigned(4, 8)),
        std_logic_vector(to_unsigned(4, 8)),
        std_logic_vector(to_unsigned(3, 8)),
        std_logic_vector(to_unsigned(3, 8)),
        std_logic_vector(to_unsigned(3, 8)),
        std_logic_vector(to_unsigned(2, 8)),
        std_logic_vector(to_unsigned(2, 8)),
        std_logic_vector(to_unsigned(2, 8)),
        std_logic_vector(to_unsigned(2, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(2, 8)),
        std_logic_vector(to_unsigned(2, 8)),
        std_logic_vector(to_unsigned(2, 8)),
        std_logic_vector(to_unsigned(2, 8)),
        std_logic_vector(to_unsigned(3, 8)),
        std_logic_vector(to_unsigned(3, 8)),
        std_logic_vector(to_unsigned(3, 8)),
        std_logic_vector(to_unsigned(4, 8)),
        std_logic_vector(to_unsigned(4, 8)),
        std_logic_vector(to_unsigned(5, 8)),
        std_logic_vector(to_unsigned(5, 8)),
        std_logic_vector(to_unsigned(5, 8)),
        std_logic_vector(to_unsigned(6, 8)),
        std_logic_vector(to_unsigned(6, 8)),
        std_logic_vector(to_unsigned(7, 8)),
        std_logic_vector(to_unsigned(7, 8)),
        std_logic_vector(to_unsigned(8, 8)),
        std_logic_vector(to_unsigned(9, 8)),
        std_logic_vector(to_unsigned(9, 8)),
        std_logic_vector(to_unsigned(10, 8)),
        std_logic_vector(to_unsigned(10, 8)),
        std_logic_vector(to_unsigned(11, 8)),
        std_logic_vector(to_unsigned(12, 8)),
        std_logic_vector(to_unsigned(12, 8)),
        std_logic_vector(to_unsigned(13, 8)),
        std_logic_vector(to_unsigned(14, 8)),
        std_logic_vector(to_unsigned(14, 8)),
        std_logic_vector(to_unsigned(15, 8)),
        std_logic_vector(to_unsigned(16, 8)),
        std_logic_vector(to_unsigned(16, 8)),
        std_logic_vector(to_unsigned(17, 8)),
        std_logic_vector(to_unsigned(18, 8)),
        std_logic_vector(to_unsigned(19, 8)),
        std_logic_vector(to_unsigned(20, 8)),
        std_logic_vector(to_unsigned(21, 8)),
        std_logic_vector(to_unsigned(21, 8)),
        std_logic_vector(to_unsigned(22, 8)),
        std_logic_vector(to_unsigned(23, 8)),
        std_logic_vector(to_unsigned(24, 8)),
        std_logic_vector(to_unsigned(25, 8)),
        std_logic_vector(to_unsigned(26, 8)),
        std_logic_vector(to_unsigned(27, 8)),
        std_logic_vector(to_unsigned(28, 8)),
        std_logic_vector(to_unsigned(29, 8)),
        std_logic_vector(to_unsigned(30, 8)),
        std_logic_vector(to_unsigned(31, 8)),
        std_logic_vector(to_unsigned(32, 8)),
        std_logic_vector(to_unsigned(33, 8)),
        std_logic_vector(to_unsigned(34, 8)),
        std_logic_vector(to_unsigned(35, 8)),
        std_logic_vector(to_unsigned(36, 8)),
        std_logic_vector(to_unsigned(37, 8)),
        std_logic_vector(to_unsigned(38, 8)),
        std_logic_vector(to_unsigned(39, 8)),
        std_logic_vector(to_unsigned(41, 8)),
        std_logic_vector(to_unsigned(42, 8)),
        std_logic_vector(to_unsigned(43, 8)),
        std_logic_vector(to_unsigned(44, 8)),
        std_logic_vector(to_unsigned(45, 8)),
        std_logic_vector(to_unsigned(46, 8)),
        std_logic_vector(to_unsigned(48, 8)),
        std_logic_vector(to_unsigned(49, 8)),
        std_logic_vector(to_unsigned(50, 8)),
        std_logic_vector(to_unsigned(51, 8)),
        std_logic_vector(to_unsigned(53, 8)),
        std_logic_vector(to_unsigned(54, 8)),
        std_logic_vector(to_unsigned(55, 8)),
        std_logic_vector(to_unsigned(56, 8)),
        std_logic_vector(to_unsigned(58, 8)),
        std_logic_vector(to_unsigned(59, 8)),
        std_logic_vector(to_unsigned(60, 8)),
        std_logic_vector(to_unsigned(62, 8)),
        std_logic_vector(to_unsigned(63, 8)),
        std_logic_vector(to_unsigned(64, 8)),
        std_logic_vector(to_unsigned(66, 8)),
        std_logic_vector(to_unsigned(67, 8)),
        std_logic_vector(to_unsigned(69, 8)),
        std_logic_vector(to_unsigned(70, 8)),
        std_logic_vector(to_unsigned(71, 8)),
        std_logic_vector(to_unsigned(73, 8)),
        std_logic_vector(to_unsigned(74, 8)),
        std_logic_vector(to_unsigned(76, 8)),
        std_logic_vector(to_unsigned(77, 8)),
        std_logic_vector(to_unsigned(78, 8)),
        std_logic_vector(to_unsigned(80, 8)),
        std_logic_vector(to_unsigned(81, 8)),
        std_logic_vector(to_unsigned(83, 8)),
        std_logic_vector(to_unsigned(84, 8)),
        std_logic_vector(to_unsigned(86, 8)),
        std_logic_vector(to_unsigned(87, 8)),
        std_logic_vector(to_unsigned(89, 8)),
        std_logic_vector(to_unsigned(90, 8)),
        std_logic_vector(to_unsigned(92, 8)),
        std_logic_vector(to_unsigned(93, 8)),
        std_logic_vector(to_unsigned(95, 8)),
        std_logic_vector(to_unsigned(96, 8)),
        std_logic_vector(to_unsigned(98, 8)),
        std_logic_vector(to_unsigned(99, 8)),
        std_logic_vector(to_unsigned(101, 8)),
        std_logic_vector(to_unsigned(102, 8)),
        std_logic_vector(to_unsigned(104, 8)),
        std_logic_vector(to_unsigned(105, 8)),
        std_logic_vector(to_unsigned(107, 8)),
        std_logic_vector(to_unsigned(108, 8)),
        std_logic_vector(to_unsigned(110, 8)),
        std_logic_vector(to_unsigned(111, 8)),
        std_logic_vector(to_unsigned(113, 8)),
        std_logic_vector(to_unsigned(115, 8)),
        std_logic_vector(to_unsigned(116, 8)),
        std_logic_vector(to_unsigned(118, 8)),
        std_logic_vector(to_unsigned(119, 8)),
        std_logic_vector(to_unsigned(121, 8)),
        std_logic_vector(to_unsigned(122, 8)),
        std_logic_vector(to_unsigned(124, 8)),
        std_logic_vector(to_unsigned(125, 8)),
        std_logic_vector(to_unsigned(127, 8)),
        std_logic_vector(to_unsigned(129, 8)),
        std_logic_vector(to_unsigned(130, 8)),
        std_logic_vector(to_unsigned(132, 8)),
        std_logic_vector(to_unsigned(133, 8)),
        std_logic_vector(to_unsigned(135, 8)),
        std_logic_vector(to_unsigned(136, 8)),
        std_logic_vector(to_unsigned(138, 8)),
        std_logic_vector(to_unsigned(139, 8)),
        std_logic_vector(to_unsigned(141, 8)),
        std_logic_vector(to_unsigned(143, 8)),
        std_logic_vector(to_unsigned(144, 8)),
        std_logic_vector(to_unsigned(146, 8)),
        std_logic_vector(to_unsigned(147, 8)),
        std_logic_vector(to_unsigned(149, 8)),
        std_logic_vector(to_unsigned(150, 8)),
        std_logic_vector(to_unsigned(152, 8)),
        std_logic_vector(to_unsigned(153, 8)),
        std_logic_vector(to_unsigned(155, 8)),
        std_logic_vector(to_unsigned(156, 8)),
        std_logic_vector(to_unsigned(158, 8)),
        std_logic_vector(to_unsigned(159, 8)),
        std_logic_vector(to_unsigned(161, 8)),
        std_logic_vector(to_unsigned(162, 8)),
        std_logic_vector(to_unsigned(164, 8)),
        std_logic_vector(to_unsigned(165, 8)),
        std_logic_vector(to_unsigned(167, 8)),
        std_logic_vector(to_unsigned(168, 8)),
        std_logic_vector(to_unsigned(170, 8)),
        std_logic_vector(to_unsigned(171, 8)),
        std_logic_vector(to_unsigned(173, 8)),
        std_logic_vector(to_unsigned(174, 8)),
        std_logic_vector(to_unsigned(176, 8)),
        std_logic_vector(to_unsigned(177, 8)),
        std_logic_vector(to_unsigned(178, 8)),
        std_logic_vector(to_unsigned(180, 8)),
        std_logic_vector(to_unsigned(181, 8)),
        std_logic_vector(to_unsigned(183, 8)),
        std_logic_vector(to_unsigned(184, 8)),
        std_logic_vector(to_unsigned(185, 8)),
        std_logic_vector(to_unsigned(187, 8)),
        std_logic_vector(to_unsigned(188, 8)),
        std_logic_vector(to_unsigned(190, 8)),
        std_logic_vector(to_unsigned(191, 8)),
        std_logic_vector(to_unsigned(192, 8)),
        std_logic_vector(to_unsigned(194, 8)),
        std_logic_vector(to_unsigned(195, 8)),
        std_logic_vector(to_unsigned(196, 8)),
        std_logic_vector(to_unsigned(198, 8)),
        std_logic_vector(to_unsigned(199, 8)),
        std_logic_vector(to_unsigned(200, 8)),
        std_logic_vector(to_unsigned(201, 8)),
        std_logic_vector(to_unsigned(203, 8)),
        std_logic_vector(to_unsigned(204, 8)),
        std_logic_vector(to_unsigned(205, 8)),
        std_logic_vector(to_unsigned(206, 8)),
        std_logic_vector(to_unsigned(208, 8)),
        std_logic_vector(to_unsigned(209, 8)),
        std_logic_vector(to_unsigned(210, 8)),
        std_logic_vector(to_unsigned(211, 8)),
        std_logic_vector(to_unsigned(212, 8)),
        std_logic_vector(to_unsigned(213, 8)),
        std_logic_vector(to_unsigned(215, 8)),
        std_logic_vector(to_unsigned(216, 8)),
        std_logic_vector(to_unsigned(217, 8)),
        std_logic_vector(to_unsigned(218, 8)),
        std_logic_vector(to_unsigned(219, 8)),
        std_logic_vector(to_unsigned(220, 8)),
        std_logic_vector(to_unsigned(221, 8)),
        std_logic_vector(to_unsigned(222, 8)),
        std_logic_vector(to_unsigned(223, 8)),
        std_logic_vector(to_unsigned(224, 8)),
        std_logic_vector(to_unsigned(225, 8)),
        std_logic_vector(to_unsigned(226, 8)),
        std_logic_vector(to_unsigned(227, 8)),
        std_logic_vector(to_unsigned(228, 8)),
        std_logic_vector(to_unsigned(229, 8)),
        std_logic_vector(to_unsigned(230, 8)),
        std_logic_vector(to_unsigned(231, 8)),
        std_logic_vector(to_unsigned(232, 8)),
        std_logic_vector(to_unsigned(233, 8)),
        std_logic_vector(to_unsigned(233, 8)),
        std_logic_vector(to_unsigned(234, 8)),
        std_logic_vector(to_unsigned(235, 8)),
        std_logic_vector(to_unsigned(236, 8)),
        std_logic_vector(to_unsigned(237, 8)),
        std_logic_vector(to_unsigned(238, 8)),
        std_logic_vector(to_unsigned(238, 8)),
        std_logic_vector(to_unsigned(239, 8)),
        std_logic_vector(to_unsigned(240, 8)),
        std_logic_vector(to_unsigned(240, 8)),
        std_logic_vector(to_unsigned(241, 8)),
        std_logic_vector(to_unsigned(242, 8)),
        std_logic_vector(to_unsigned(242, 8)),
        std_logic_vector(to_unsigned(243, 8)),
        std_logic_vector(to_unsigned(244, 8)),
        std_logic_vector(to_unsigned(244, 8)),
        std_logic_vector(to_unsigned(245, 8)),
        std_logic_vector(to_unsigned(245, 8)),
        std_logic_vector(to_unsigned(246, 8)),
        std_logic_vector(to_unsigned(247, 8)),
        std_logic_vector(to_unsigned(247, 8)),
        std_logic_vector(to_unsigned(248, 8)),
        std_logic_vector(to_unsigned(248, 8)),
        std_logic_vector(to_unsigned(249, 8)),
        std_logic_vector(to_unsigned(249, 8)),
        std_logic_vector(to_unsigned(249, 8)),
        std_logic_vector(to_unsigned(250, 8)),
        std_logic_vector(to_unsigned(250, 8)),
        std_logic_vector(to_unsigned(251, 8)),
        std_logic_vector(to_unsigned(251, 8)),
        std_logic_vector(to_unsigned(251, 8)),
        std_logic_vector(to_unsigned(252, 8)),
        std_logic_vector(to_unsigned(252, 8)),
        std_logic_vector(to_unsigned(252, 8)),
        std_logic_vector(to_unsigned(252, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(252, 8)),
        std_logic_vector(to_unsigned(252, 8)),
        std_logic_vector(to_unsigned(252, 8)),
        std_logic_vector(to_unsigned(252, 8)),
        std_logic_vector(to_unsigned(251, 8)),
        std_logic_vector(to_unsigned(251, 8)),
        std_logic_vector(to_unsigned(251, 8)),
        std_logic_vector(to_unsigned(250, 8)),
        std_logic_vector(to_unsigned(250, 8)),
        std_logic_vector(to_unsigned(249, 8)),
        std_logic_vector(to_unsigned(249, 8)),
        std_logic_vector(to_unsigned(249, 8)),
        std_logic_vector(to_unsigned(248, 8)),
        std_logic_vector(to_unsigned(248, 8)),
        std_logic_vector(to_unsigned(247, 8)),
        std_logic_vector(to_unsigned(247, 8)),
        std_logic_vector(to_unsigned(246, 8)),
        std_logic_vector(to_unsigned(245, 8)),
        std_logic_vector(to_unsigned(245, 8)),
        std_logic_vector(to_unsigned(244, 8)),
        std_logic_vector(to_unsigned(244, 8)),
        std_logic_vector(to_unsigned(243, 8)),
        std_logic_vector(to_unsigned(242, 8)),
        std_logic_vector(to_unsigned(242, 8)),
        std_logic_vector(to_unsigned(241, 8)),
        std_logic_vector(to_unsigned(240, 8)),
        std_logic_vector(to_unsigned(240, 8)),
        std_logic_vector(to_unsigned(239, 8)),
        std_logic_vector(to_unsigned(238, 8)),
        std_logic_vector(to_unsigned(238, 8)),
        std_logic_vector(to_unsigned(237, 8)),
        std_logic_vector(to_unsigned(236, 8)),
        std_logic_vector(to_unsigned(235, 8)),
        std_logic_vector(to_unsigned(234, 8)),
        std_logic_vector(to_unsigned(233, 8)),
        std_logic_vector(to_unsigned(233, 8)),
        std_logic_vector(to_unsigned(232, 8)),
        std_logic_vector(to_unsigned(231, 8)),
        std_logic_vector(to_unsigned(230, 8)),
        std_logic_vector(to_unsigned(229, 8)),
        std_logic_vector(to_unsigned(228, 8)),
        std_logic_vector(to_unsigned(227, 8)),
        std_logic_vector(to_unsigned(226, 8)),
        std_logic_vector(to_unsigned(225, 8)),
        std_logic_vector(to_unsigned(224, 8)),
        std_logic_vector(to_unsigned(223, 8)),
        std_logic_vector(to_unsigned(222, 8)),
        std_logic_vector(to_unsigned(221, 8)),
        std_logic_vector(to_unsigned(220, 8)),
        std_logic_vector(to_unsigned(219, 8)),
        std_logic_vector(to_unsigned(218, 8)),
        std_logic_vector(to_unsigned(217, 8)),
        std_logic_vector(to_unsigned(216, 8)),
        std_logic_vector(to_unsigned(215, 8)),
        std_logic_vector(to_unsigned(213, 8)),
        std_logic_vector(to_unsigned(212, 8)),
        std_logic_vector(to_unsigned(211, 8)),
        std_logic_vector(to_unsigned(210, 8)),
        std_logic_vector(to_unsigned(209, 8)),
        std_logic_vector(to_unsigned(208, 8)),
        std_logic_vector(to_unsigned(206, 8)),
        std_logic_vector(to_unsigned(205, 8)),
        std_logic_vector(to_unsigned(204, 8)),
        std_logic_vector(to_unsigned(203, 8)),
        std_logic_vector(to_unsigned(201, 8)),
        std_logic_vector(to_unsigned(200, 8)),
        std_logic_vector(to_unsigned(199, 8)),
        std_logic_vector(to_unsigned(198, 8)),
        std_logic_vector(to_unsigned(196, 8)),
        std_logic_vector(to_unsigned(195, 8)),
        std_logic_vector(to_unsigned(194, 8)),
        std_logic_vector(to_unsigned(192, 8)),
        std_logic_vector(to_unsigned(191, 8)),
        std_logic_vector(to_unsigned(190, 8)),
        std_logic_vector(to_unsigned(188, 8)),
        std_logic_vector(to_unsigned(187, 8)),
        std_logic_vector(to_unsigned(185, 8)),
        std_logic_vector(to_unsigned(184, 8)),
        std_logic_vector(to_unsigned(183, 8)),
        std_logic_vector(to_unsigned(181, 8)),
        std_logic_vector(to_unsigned(180, 8)),
        std_logic_vector(to_unsigned(178, 8)),
        std_logic_vector(to_unsigned(177, 8)),
        std_logic_vector(to_unsigned(176, 8)),
        std_logic_vector(to_unsigned(174, 8)),
        std_logic_vector(to_unsigned(173, 8)),
        std_logic_vector(to_unsigned(171, 8)),
        std_logic_vector(to_unsigned(170, 8)),
        std_logic_vector(to_unsigned(168, 8)),
        std_logic_vector(to_unsigned(167, 8)),
        std_logic_vector(to_unsigned(165, 8)),
        std_logic_vector(to_unsigned(164, 8)),
        std_logic_vector(to_unsigned(162, 8)),
        std_logic_vector(to_unsigned(161, 8)),
        std_logic_vector(to_unsigned(159, 8)),
        std_logic_vector(to_unsigned(158, 8)),
        std_logic_vector(to_unsigned(156, 8)),
        std_logic_vector(to_unsigned(155, 8)),
        std_logic_vector(to_unsigned(153, 8)),
        std_logic_vector(to_unsigned(152, 8)),
        std_logic_vector(to_unsigned(150, 8)),
        std_logic_vector(to_unsigned(149, 8)),
        std_logic_vector(to_unsigned(147, 8)),
        std_logic_vector(to_unsigned(146, 8)),
        std_logic_vector(to_unsigned(144, 8)),
        std_logic_vector(to_unsigned(143, 8)),
        std_logic_vector(to_unsigned(141, 8)),
        std_logic_vector(to_unsigned(139, 8)),
        std_logic_vector(to_unsigned(138, 8)),
        std_logic_vector(to_unsigned(136, 8)),
        std_logic_vector(to_unsigned(135, 8)),
        std_logic_vector(to_unsigned(133, 8)),
        std_logic_vector(to_unsigned(132, 8)),
        std_logic_vector(to_unsigned(130, 8)),
        std_logic_vector(to_unsigned(129, 8)),
        std_logic_vector(to_unsigned(127, 8)),
        std_logic_vector(to_unsigned(125, 8)),
        std_logic_vector(to_unsigned(124, 8)),
        std_logic_vector(to_unsigned(122, 8)),
        std_logic_vector(to_unsigned(121, 8)),
        std_logic_vector(to_unsigned(119, 8)),
        std_logic_vector(to_unsigned(118, 8)),
        std_logic_vector(to_unsigned(116, 8)),
        std_logic_vector(to_unsigned(115, 8)),
        std_logic_vector(to_unsigned(113, 8)),
        std_logic_vector(to_unsigned(111, 8)),
        std_logic_vector(to_unsigned(110, 8)),
        std_logic_vector(to_unsigned(108, 8)),
        std_logic_vector(to_unsigned(107, 8)),
        std_logic_vector(to_unsigned(105, 8)),
        std_logic_vector(to_unsigned(104, 8)),
        std_logic_vector(to_unsigned(102, 8)),
        std_logic_vector(to_unsigned(101, 8)),
        std_logic_vector(to_unsigned(99, 8)),
        std_logic_vector(to_unsigned(98, 8)),
        std_logic_vector(to_unsigned(96, 8)),
        std_logic_vector(to_unsigned(95, 8)),
        std_logic_vector(to_unsigned(93, 8)),
        std_logic_vector(to_unsigned(92, 8)),
        std_logic_vector(to_unsigned(90, 8)),
        std_logic_vector(to_unsigned(89, 8)),
        std_logic_vector(to_unsigned(87, 8)),
        std_logic_vector(to_unsigned(86, 8)),
        std_logic_vector(to_unsigned(84, 8)),
        std_logic_vector(to_unsigned(83, 8)),
        std_logic_vector(to_unsigned(81, 8)),
        std_logic_vector(to_unsigned(80, 8)),
        std_logic_vector(to_unsigned(78, 8)),
        std_logic_vector(to_unsigned(77, 8)),
        std_logic_vector(to_unsigned(76, 8)),
        std_logic_vector(to_unsigned(74, 8)),
        std_logic_vector(to_unsigned(73, 8)),
        std_logic_vector(to_unsigned(71, 8)),
        std_logic_vector(to_unsigned(70, 8)),
        std_logic_vector(to_unsigned(69, 8)),
        std_logic_vector(to_unsigned(67, 8)),
        std_logic_vector(to_unsigned(66, 8)),
        std_logic_vector(to_unsigned(64, 8)),
        std_logic_vector(to_unsigned(63, 8)),
        std_logic_vector(to_unsigned(62, 8)),
        std_logic_vector(to_unsigned(60, 8)),
        std_logic_vector(to_unsigned(59, 8)),
        std_logic_vector(to_unsigned(58, 8)),
        std_logic_vector(to_unsigned(56, 8)),
        std_logic_vector(to_unsigned(55, 8)),
        std_logic_vector(to_unsigned(54, 8)),
        std_logic_vector(to_unsigned(53, 8)),
        std_logic_vector(to_unsigned(51, 8)),
        std_logic_vector(to_unsigned(50, 8)),
        std_logic_vector(to_unsigned(49, 8)),
        std_logic_vector(to_unsigned(48, 8)),
        std_logic_vector(to_unsigned(46, 8)),
        std_logic_vector(to_unsigned(45, 8)),
        std_logic_vector(to_unsigned(44, 8)),
        std_logic_vector(to_unsigned(43, 8)),
        std_logic_vector(to_unsigned(42, 8)),
        std_logic_vector(to_unsigned(41, 8)),
        std_logic_vector(to_unsigned(39, 8)),
        std_logic_vector(to_unsigned(38, 8)),
        std_logic_vector(to_unsigned(37, 8)),
        std_logic_vector(to_unsigned(36, 8)),
        std_logic_vector(to_unsigned(35, 8)),
        std_logic_vector(to_unsigned(34, 8)),
        std_logic_vector(to_unsigned(33, 8)),
        std_logic_vector(to_unsigned(32, 8)),
        std_logic_vector(to_unsigned(31, 8)),
        std_logic_vector(to_unsigned(30, 8)),
        std_logic_vector(to_unsigned(29, 8)),
        std_logic_vector(to_unsigned(28, 8)),
        std_logic_vector(to_unsigned(27, 8)),
        std_logic_vector(to_unsigned(26, 8)),
        std_logic_vector(to_unsigned(25, 8)),
        std_logic_vector(to_unsigned(24, 8)),
        std_logic_vector(to_unsigned(23, 8)),
        std_logic_vector(to_unsigned(22, 8)),
        std_logic_vector(to_unsigned(21, 8)),
        std_logic_vector(to_unsigned(21, 8)),
        std_logic_vector(to_unsigned(20, 8)),
        std_logic_vector(to_unsigned(19, 8)),
        std_logic_vector(to_unsigned(18, 8)),
        std_logic_vector(to_unsigned(17, 8)),
        std_logic_vector(to_unsigned(16, 8)),
        std_logic_vector(to_unsigned(16, 8)),
        std_logic_vector(to_unsigned(15, 8)),
        std_logic_vector(to_unsigned(14, 8)),
        std_logic_vector(to_unsigned(14, 8)),
        std_logic_vector(to_unsigned(13, 8)),
        std_logic_vector(to_unsigned(12, 8)),
        std_logic_vector(to_unsigned(12, 8)),
        std_logic_vector(to_unsigned(11, 8)),
        std_logic_vector(to_unsigned(10, 8)),
        std_logic_vector(to_unsigned(10, 8)),
        std_logic_vector(to_unsigned(9, 8)),
        std_logic_vector(to_unsigned(9, 8)),
        std_logic_vector(to_unsigned(8, 8)),
        std_logic_vector(to_unsigned(7, 8)),
        std_logic_vector(to_unsigned(7, 8)),
        std_logic_vector(to_unsigned(6, 8)),
        std_logic_vector(to_unsigned(6, 8)),
        std_logic_vector(to_unsigned(5, 8)),
        std_logic_vector(to_unsigned(5, 8)),
        std_logic_vector(to_unsigned(5, 8)),
        std_logic_vector(to_unsigned(4, 8)),
        std_logic_vector(to_unsigned(4, 8)),
        std_logic_vector(to_unsigned(3, 8)),
        std_logic_vector(to_unsigned(3, 8)),
        std_logic_vector(to_unsigned(3, 8)),
        std_logic_vector(to_unsigned(2, 8)),
        std_logic_vector(to_unsigned(2, 8)),
        std_logic_vector(to_unsigned(2, 8)),
        std_logic_vector(to_unsigned(2, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(2, 8)),
        std_logic_vector(to_unsigned(2, 8)),
        std_logic_vector(to_unsigned(2, 8)),
        std_logic_vector(to_unsigned(2, 8)),
        std_logic_vector(to_unsigned(3, 8)),
        std_logic_vector(to_unsigned(3, 8)),
        std_logic_vector(to_unsigned(3, 8)),
        std_logic_vector(to_unsigned(4, 8)),
        std_logic_vector(to_unsigned(4, 8)),
        std_logic_vector(to_unsigned(5, 8)),
        std_logic_vector(to_unsigned(5, 8)),
        std_logic_vector(to_unsigned(5, 8)),
        std_logic_vector(to_unsigned(6, 8)),
        std_logic_vector(to_unsigned(6, 8)),
        std_logic_vector(to_unsigned(7, 8)),
        std_logic_vector(to_unsigned(7, 8)),
        std_logic_vector(to_unsigned(8, 8)),
        std_logic_vector(to_unsigned(9, 8)),
        std_logic_vector(to_unsigned(9, 8)),
        std_logic_vector(to_unsigned(10, 8)),
        std_logic_vector(to_unsigned(10, 8)),
        std_logic_vector(to_unsigned(11, 8)),
        std_logic_vector(to_unsigned(12, 8)),
        std_logic_vector(to_unsigned(12, 8)),
        std_logic_vector(to_unsigned(13, 8)),
        std_logic_vector(to_unsigned(14, 8)),
        std_logic_vector(to_unsigned(14, 8)),
        std_logic_vector(to_unsigned(15, 8)),
        std_logic_vector(to_unsigned(16, 8)),
        std_logic_vector(to_unsigned(16, 8)),
        std_logic_vector(to_unsigned(17, 8)),
        std_logic_vector(to_unsigned(18, 8)),
        std_logic_vector(to_unsigned(19, 8)),
        std_logic_vector(to_unsigned(20, 8)),
        std_logic_vector(to_unsigned(21, 8)),
        std_logic_vector(to_unsigned(21, 8)),
        std_logic_vector(to_unsigned(22, 8)),
        std_logic_vector(to_unsigned(23, 8)),
        std_logic_vector(to_unsigned(24, 8)),
        std_logic_vector(to_unsigned(25, 8)),
        std_logic_vector(to_unsigned(26, 8)),
        std_logic_vector(to_unsigned(27, 8)),
        std_logic_vector(to_unsigned(28, 8)),
        std_logic_vector(to_unsigned(29, 8)),
        std_logic_vector(to_unsigned(30, 8)),
        std_logic_vector(to_unsigned(31, 8)),
        std_logic_vector(to_unsigned(32, 8)),
        std_logic_vector(to_unsigned(33, 8)),
        std_logic_vector(to_unsigned(34, 8)),
        std_logic_vector(to_unsigned(35, 8)),
        std_logic_vector(to_unsigned(36, 8)),
        std_logic_vector(to_unsigned(37, 8)),
        std_logic_vector(to_unsigned(38, 8)),
        std_logic_vector(to_unsigned(39, 8)),
        std_logic_vector(to_unsigned(41, 8)),
        std_logic_vector(to_unsigned(42, 8)),
        std_logic_vector(to_unsigned(43, 8)),
        std_logic_vector(to_unsigned(44, 8)),
        std_logic_vector(to_unsigned(45, 8)),
        std_logic_vector(to_unsigned(46, 8)),
        std_logic_vector(to_unsigned(48, 8)),
        std_logic_vector(to_unsigned(49, 8)),
        std_logic_vector(to_unsigned(50, 8)),
        std_logic_vector(to_unsigned(51, 8)),
        std_logic_vector(to_unsigned(53, 8)),
        std_logic_vector(to_unsigned(54, 8)),
        std_logic_vector(to_unsigned(55, 8)),
        std_logic_vector(to_unsigned(56, 8)),
        std_logic_vector(to_unsigned(58, 8)),
        std_logic_vector(to_unsigned(59, 8)),
        std_logic_vector(to_unsigned(60, 8)),
        std_logic_vector(to_unsigned(62, 8)),
        std_logic_vector(to_unsigned(63, 8)),
        std_logic_vector(to_unsigned(64, 8)),
        std_logic_vector(to_unsigned(66, 8)),
        std_logic_vector(to_unsigned(67, 8)),
        std_logic_vector(to_unsigned(69, 8)),
        std_logic_vector(to_unsigned(70, 8)),
        std_logic_vector(to_unsigned(71, 8)),
        std_logic_vector(to_unsigned(73, 8)),
        std_logic_vector(to_unsigned(74, 8)),
        std_logic_vector(to_unsigned(76, 8)),
        std_logic_vector(to_unsigned(77, 8)),
        std_logic_vector(to_unsigned(78, 8)),
        std_logic_vector(to_unsigned(80, 8)),
        std_logic_vector(to_unsigned(81, 8)),
        std_logic_vector(to_unsigned(83, 8)),
        std_logic_vector(to_unsigned(84, 8)),
        std_logic_vector(to_unsigned(86, 8)),
        std_logic_vector(to_unsigned(87, 8)),
        std_logic_vector(to_unsigned(89, 8)),
        std_logic_vector(to_unsigned(90, 8)),
        std_logic_vector(to_unsigned(92, 8)),
        std_logic_vector(to_unsigned(93, 8)),
        std_logic_vector(to_unsigned(95, 8)),
        std_logic_vector(to_unsigned(96, 8)),
        std_logic_vector(to_unsigned(98, 8)),
        std_logic_vector(to_unsigned(99, 8)),
        std_logic_vector(to_unsigned(101, 8)),
        std_logic_vector(to_unsigned(102, 8)),
        std_logic_vector(to_unsigned(104, 8)),
        std_logic_vector(to_unsigned(105, 8)),
        std_logic_vector(to_unsigned(107, 8)),
        std_logic_vector(to_unsigned(108, 8)),
        std_logic_vector(to_unsigned(110, 8)),
        std_logic_vector(to_unsigned(111, 8)),
        std_logic_vector(to_unsigned(113, 8)),
        std_logic_vector(to_unsigned(115, 8)),
        std_logic_vector(to_unsigned(116, 8)),
        std_logic_vector(to_unsigned(118, 8)),
        std_logic_vector(to_unsigned(119, 8)),
        std_logic_vector(to_unsigned(121, 8)),
        std_logic_vector(to_unsigned(122, 8)),
        std_logic_vector(to_unsigned(124, 8)),
        std_logic_vector(to_unsigned(125, 8))
    );

begin

    process
        variable vhdl_initial : BOOLEAN := TRUE;

    begin
        if ( vhdl_initial ) then
            -- Assert Reset
            NSYSRESET <= '0';
            wait for ( SYSCLK_PERIOD * 10 );
            
            NSYSRESET <= '1';
            wait;
        end if;
    end process;

    -- Clock Driver
    SYSCLK <= not SYSCLK after (SYSCLK_PERIOD / 2.0 );

    -- Instantiate Unit Under Test:  FFT_AHB_Wrapper
    FFT_AHB_Wrapper_0 : FFT_AHB_Wrapper
        -- port map
        port map( 
            CLK => SYSCLK,
            RSTn => NSYSRESET,

            -- AHB connections
            HADDR       => HADDR,
            HWDATA      => HWDATA,
            HWRITE      => HWRITE,
            HSIZE       => HSIZE,
            HTRANS      => HTRANS,
            HSEL        => HSEL,
            HMASTLOCK   => HMASTLOCK,
            HBURST      => HBURST,
            HPROT       => HPROT,
            HREADYIN    => HREADYIN,

            HRDATA      => HRDATA,
            HRESP       => HRESP,
            HREADYOUT   => HREADYOUT,
            -- AHB connections

            INT => INT
        );



    spy_process : process
    begin
        init_signal_spy("FFT_AHB_Wrapper_0/ahb_state", "ahb_state", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/smpl_read", "smpl_read", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/smpl_data_stable", "smpl_data_stable", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/abs_val_read", "abs_val_read", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/abs_val_stable", "abs_val_stable", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/HADDR_A_sig", "HADDR_A_sig", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/HADDR_S_sig", "HADDR_S_sig", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/HADDR_sig_use", "HADDR_sig_use", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_in_w_en", "FFT_in_w_en_sig", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_in_w_data_real", "FFT_in_w_data_real_sig", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_in_w_data_imag", "FFT_in_w_data_imag_sig", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_in_w_done", "FFT_in_w_done_sig", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_in_w_ready", "FFT_in_w_ready_sig", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_in_full", "FFT_in_full_sig", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_Core/FFT_in_full", "FFT_in_full_sig", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_Core/i_comp_ram_w_en", "i_comp_ram_w_en", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_Core/i_comp_ram_adr", "i_comp_ram_adr", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_Core/i_comp_ram_dat_w", "i_comp_ram_dat_w", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_Core/i_comp_ram_dat_r", "i_comp_ram_dat_r", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_Core/i_comp_ram_adr_start", "i_comp_ram_adr_start", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_out_r_en", "FFT_out_r_en_sig", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_out_data_adr", "FFT_out_data_adr_sig", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_out_read_done", "FFT_out_read_done_sig", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_out_dat_real", "FFT_out_dat_real_sig", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_out_dat_imag", "FFT_out_dat_imag_sig", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_out_data_ready", "FFT_out_data_ready_sig", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_out_valid", "FFT_out_valid_sig", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_Core/o_comp_ram_w_en", "o_comp_ram_w_en", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_Core/o_comp_ram_adr", "o_comp_ram_adr", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_Core/o_comp_ram_dat_w", "o_comp_ram_dat_w", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_Core/o_comp_ram_dat_r", "o_comp_ram_dat_r", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/AMpBM_0_val_A_sig", "AMpBM_0_val_A_sig", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/AMpBM_0_val_B_sig", "AMpBM_0_val_B_sig", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/AMpBM_0_in_valid_sig", "AMpBM_0_in_valid_sig", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/AMpBM_0_out_valid_sig", "AMpBM_0_out_valid_sig", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/Alpha_Max_plus_Beta_Min_0/in_valid_sig", "in_valid_sig", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/Alpha_Max_plus_Beta_Min_0/valid_pipe", "valid_pipe", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_Core/ram_dist_state", "ram_dist_state_spy", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/core_regs", "APB_regs_spy", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_Core/FFT_Sample_Loader_0/mem_adr", "mem_adr_spy", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_Core/DPSRAM_0/DPSRAM_C0_0/DPSRAM_C0_DPSRAM_C0_0_DPSRAM_R0C0/MEM_1024_18", "FFT_mem_0", 1, -1);
        init_signal_spy("FFT_AHB_Wrapper_0/FFT_Core/DPSRAM_1/DPSRAM_C0_0/DPSRAM_C0_DPSRAM_C0_0_DPSRAM_R0C0/MEM_1024_18", "FFT_mem_1", 1, -1);
        wait;
    end process;

    HREADYIN <= HREADYOUT;

    THE_STUFF : process
        variable r_val, i_val, abs_val : integer;
    begin

        next_HADDR <= (others => '0');
        next_HWRITE <= '0';
        next_HWDATA <= (others => '0');

        HADDR <= (others => '0');
        HWDATA <= (others => '0');
        HWRITE <= '0';
        HSIZE <= HSIZE_16;
        HTRANS <= HTRANS_IDLE;
        HSEL <= '0';
        HMASTLOCK <= '0';
        HBURST <= HBURST_SINGLE;
        HPROT <= (others => '0');
        --HREADYIN <= '1';

        if(NSYSRESET /= '1') then
            wait until (NSYSRESET = '1');
        end if;

        --wait until (SYSCLK = '1');

        -- load samples
        for i in 0 to TEST_SAMPLES'length - 1 loop
            report "i = " & integer'image(i) & "; mem_adr = " & integer'image(to_integer(unsigned(mem_adr_spy)));

            -- Load REAL sample
            HTRANS <= HTRANS_NONSEQ;
            HADDR <= X"08";
            HSEL <= '1';
            HWRITE <= '1';
            next_HWDATA <= "00000000" & TEST_SAMPLES(i);

            report "real sample = " & integer'image(to_integer(unsigned(TEST_SAMPLES(i))));

            -- data transfer next cycle
            
            wait for (SYSCLK_PERIOD * 1);

            if(HREADYOUT /= '1') then
                wait until (HREADYOUT = '1');
                wait for (SYSCLK_PERIOD * 1);
            end if;

            HWDATA <= next_HWDATA; -- data phase for prev transfer
            -- Load IMAGINARY sample
            HTRANS <= HTRANS_NONSEQ;
            HADDR <= X"0C";
            HSEL <= '1';
            HWRITE <= '1';
            next_HWDATA <= (others => '0');


            wait for (SYSCLK_PERIOD * 1);

            if(HREADYOUT /= '1') then
                wait until (HREADYOUT = '1');
                wait for (SYSCLK_PERIOD * 1);
            end if;

            HWDATA <= next_HWDATA; -- data phase for prev transfer
            -- commit sample
            HTRANS <= HTRANS_NONSEQ;
            HADDR <= X"00";
            HSEL <= '1';
            HWRITE <= '1';
            next_HWDATA <= X"0001";


            wait for (SYSCLK_PERIOD * 1);

            if(HREADYOUT /= '1') then
                wait until (HREADYOUT = '1');
                wait for (SYSCLK_PERIOD * 1);
            end if;

            HWDATA <= next_HWDATA; -- data phase for prev transfer
            -- idle transfer thing for data phase
            HTRANS <= HTRANS_IDLE;
            HADDR <= (others => '0');
            HSEL <= '0';
            HWRITE <= '0';
            next_HWDATA <= (others => '0');

        end loop;


        HWDATA <= next_HWDATA;
        -- begin FFT
        HTRANS <= HTRANS_NONSEQ;
        HADDR <= X"00";
        HSEL <= '1';
        HWRITE <= '1';
        next_HWDATA <= X"0006";
        
        wait for (SYSCLK_PERIOD * 1);

        if(HREADYOUT /= '1') then
            wait until (HREADYOUT = '1');
            wait for (SYSCLK_PERIOD * 1);
        end if;

        HWDATA <= next_HWDATA;
        -- read status out
        HTRANS <= HTRANS_NONSEQ;
        HADDR <= X"04";
        HSEL <= '1';
        HWRITE <= '0';
        next_HWDATA <= (others => '0');

        wait for (SYSCLK_PERIOD * 1);

        if(HREADYOUT /= '1') then
            wait until (HREADYOUT = '1');
            wait for (SYSCLK_PERIOD * 1);
        end if;

        HWDATA <= next_HWDATA;
        -- idle
        HTRANS <= HTRANS_IDLE;
        HADDR <= (others => '0');
        HSEL <= '0';
        HWRITE <= '0';
        next_HWDATA <= (others => '0');


        wait for (SYSCLK_PERIOD * 1);

        if(HREADYOUT /= '1') then
            wait until (HREADYOUT = '1');
            wait for (SYSCLK_PERIOD * 1);
        end if;


        if(INT /= '1') then
            wait until (INT = '1');
        end if;

        -- read back FFT
        for i in 0 to 512 loop

            HWDATA <= next_HWDATA;
            -- set address
            HTRANS <= HTRANS_NONSEQ;
            HADDR <= X"1C";
            HSEL <= '1';
            HWRITE <= '1';
            next_HWDATA <= std_logic_vector(to_unsigned(i, 16));

            wait for (SYSCLK_PERIOD * 1);

            if(HREADYOUT /= '1') then
                wait until (HREADYOUT = '1');
                wait for (SYSCLK_PERIOD * 1);
            end if;

            HWDATA <= next_HWDATA;
            -- read real
            HTRANS <= HTRANS_NONSEQ;
            HADDR <= X"10";
            HSEL <= '1';
            HWRITE <= '0';
            next_HWDATA <= (others => '0');


            wait for (SYSCLK_PERIOD * 1);

            if(HREADYOUT /= '1') then
                wait until (HREADYOUT = '1');
                wait for (SYSCLK_PERIOD * 1);
            end if;

            wait for (SYSCLK_PERIOD * 1);

            r_val := to_integer(signed(HRDATA));

            HWDATA <= next_HWDATA;
            -- read imag
            HTRANS <= HTRANS_NONSEQ;
            HADDR <= X"14";
            HSEL <= '1';
            HWRITE <= '0';
            next_HWDATA <= (others => '0');


            wait for (SYSCLK_PERIOD * 1);

            if(HREADYOUT /= '1') then
                wait until (HREADYOUT = '1');
                wait for (SYSCLK_PERIOD * 1);
            end if;

            i_val := to_integer(signed(HRDATA));

            HWDATA <= next_HWDATA;
            -- read abs_val
            HTRANS <= HTRANS_NONSEQ;
            HADDR <= X"18";
            HSEL <= '1';
            HWRITE <= '0';
            next_HWDATA <= (others => '0');


            wait for (SYSCLK_PERIOD * 1);

            if(HREADYOUT /= '1') then
                wait until (HREADYOUT = '1');
                wait for (SYSCLK_PERIOD * 1);
            end if;

            abs_val := to_integer(signed(HRDATA));

            HWDATA <= next_HWDATA;
            -- idle transaction
            HTRANS <= HTRANS_IDLE;
            HADDR <= X"00";
            HSEL <= '0';
            HWRITE <= '0';
            next_HWDATA <= (others => '0');

            report "result i = " & integer'image(i) & ": " & integer'image(r_val) & " + i" & integer'image(i_val) & " = " & integer'image(abs_val);

            wait for (SYSCLK_PERIOD * 1);

            if(HREADYOUT /= '1') then
                wait until (HREADYOUT = '1');
                wait for (SYSCLK_PERIOD * 1);
            end if;

        end loop;



        HWDATA <= next_HWDATA;
        -- read status out
        HTRANS <= HTRANS_NONSEQ;
        HADDR <= X"04";
        HSEL <= '1';
        HWRITE <= '0';
        next_HWDATA <= (others => '0');

        wait for (SYSCLK_PERIOD * 1);

        if(HREADYOUT /= '1') then
            wait until (HREADYOUT = '1');
            wait for (SYSCLK_PERIOD * 1);
        end if;

        HWDATA <= next_HWDATA;
        -- idle
        HTRANS <= HTRANS_IDLE;
        HADDR <= (others => '0');
        HSEL <= '0';
        HWRITE <= '0';
        next_HWDATA <= (others => '0');


        wait for (SYSCLK_PERIOD * 1);

        if(HREADYOUT /= '1') then
            wait until (HREADYOUT = '1');
            wait for (SYSCLK_PERIOD * 1);
        end if;

        wait;
    end process;

end behavioral;

