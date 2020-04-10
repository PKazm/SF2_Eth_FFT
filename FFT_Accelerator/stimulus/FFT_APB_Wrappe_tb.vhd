----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Thu Apr  9 18:24:51 2020
-- Testbench Template
-- This is a basic testbench that instantiates your design with basic 
-- clock and reset pins connected.  If your design has special
-- clock/reset or testbench driver requirements then you should 
-- copy this file and modify it. 
----------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: FFT_APB_Wrappe_tb.vhd
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

entity testbench is
end testbench;

architecture behavioral of testbench is

    constant SYSCLK_PERIOD : time := 10 ns; -- 100MHZ

    signal SYSCLK : std_logic := '0';
    signal NSYSRESET : std_logic := '0';

    constant SAMPLE_WIDTH_INT : natural := 9;
    constant SAMPLE_CNT_EXP : natural := 10;

    component FFT_APB_Wrapper
        -- ports
        port( 
            -- Inputs
            PCLK : in std_logic;
            RSTn : in std_logic;
            PADDR : in std_logic_vector(7 downto 0);
            PSEL : in std_logic;
            PENABLE : in std_logic;
            PWRITE : in std_logic;
            PWDATA : in std_logic_vector(15 downto 0);

            -- Outputs
            PREADY : out std_logic;
            PRDATA : out std_logic_vector(15 downto 0);
            PSLVERR : out std_logic

            -- Inouts

        );
    end component;


    -- APB connections
    signal PADDR : std_logic_vector(7 downto 0);
    signal PSEL : std_logic;
    signal PENABLE : std_logic;
    signal PWRITE : std_logic;
    signal PWDATA : std_logic_vector(15 downto 0);
    signal PREADY : std_logic;
    signal PRDATA : std_logic_vector(15 downto 0);
    signal PSLVERR : std_logic;

    signal INT : std_logic;
    -- APB connections

    signal next_PADDR : std_logic_vector(7 downto 0);
    signal next_PWRITE : std_logic;
    signal next_PWDATA : std_logic_vector(15 downto 0);
    signal last_PRDATA : std_logic_vector(15 downto 0);
    signal last_PSLVERR : std_logic;

    signal do_apb : std_logic;
    signal apb_done : std_logic;


    signal FFT_in_w_en_sig          : std_logic;
    signal FFT_in_w_data_real_sig   : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal FFT_in_w_data_imag_sig   : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal FFT_in_w_done_sig        : std_logic;
    signal FFT_in_w_ready_sig       : std_logic;
    signal FFT_in_full_sig          : std_logic;

    signal FFT_out_r_en_sig         : std_logic;
    signal FFT_out_data_adr_sig     : std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);
    signal FFT_out_read_done_sig    : std_logic;
    signal FFT_out_dat_real_sig     : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal FFT_out_dat_imag_sig     : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal FFT_out_data_ready_sig   : std_logic;
    signal FFT_out_valid_sig        : std_logic;


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

    -- Instantiate Unit Under Test:  FFT_APB_Wrapper
    FFT_APB_Wrapper_0 : FFT_APB_Wrapper
        -- port map
        port map( 
            -- Inputs
            PCLK => SYSCLK,
            RSTn => NSYSRESET,
            PADDR => PADDR,
            PSEL => PSEL,
            PENABLE => PENABLE,
            PWRITE => PWRITE,
            PWDATA => PWDATA,

            -- Outputs
            PREADY => PREADY,
            PRDATA => PRDATA,
            PSLVERR => PSLVERR

            -- Inouts

        );

    spy_process : process
    begin
        init_signal_spy("FFT_APB_Wrapper_0/FFT_in_w_en", "FFT_in_w_en_sig", 1, -1);
        init_signal_spy("FFT_APB_Wrapper_0/FFT_in_w_data_real", "FFT_in_w_data_real_sig", 1, -1);
        init_signal_spy("FFT_APB_Wrapper_0/FFT_in_w_data_imag", "FFT_in_w_data_imag_sig", 1, -1);
        init_signal_spy("FFT_APB_Wrapper_0/FFT_in_w_done", "FFT_in_w_done_sig", 1, -1);
        init_signal_spy("FFT_APB_Wrapper_0/FFT_in_w_ready", "FFT_in_w_ready_sig", 1, -1);
        init_signal_spy("FFT_APB_Wrapper_0/FFT_in_full", "FFT_in_full_sig", 1, -1);
        init_signal_spy("FFT_APB_Wrapper_0/FFT_out_r_en", "FFT_out_r_en_sig", 1, -1);
        init_signal_spy("FFT_APB_Wrapper_0/FFT_out_data_adr", "FFT_out_data_adr_sig", 1, -1);
        init_signal_spy("FFT_APB_Wrapper_0/FFT_out_read_done", "FFT_out_read_done_sig", 1, -1);
        init_signal_spy("FFT_APB_Wrapper_0/FFT_out_dat_real", "FFT_out_dat_real_sig", 1, -1);
        init_signal_spy("FFT_APB_Wrapper_0/FFT_out_dat_imag", "FFT_out_dat_imag_sig", 1, -1);
        init_signal_spy("FFT_APB_Wrapper_0/FFT_out_data_ready", "FFT_out_data_ready_sig", 1, -1);
        init_signal_spy("FFT_APB_Wrapper_0/FFT_out_valid", "FFT_out_valid_sig", 1, -1);
        init_signal_spy("FFT_APB_Wrapper_0/FFT_Core/ram_dist_state", "ram_dist_state_spy", 1, -1);
        init_signal_spy("FFT_APB_Wrapper_0/APB_regs", "APB_regs_spy", 1, -1);
        init_signal_spy("FFT_APB_Wrapper_0/FFT_Core/FFT_Sample_Loader_0/mem_adr", "mem_adr_spy", 1, -1);
        init_signal_spy("FFT_APB_Wrapper_0/FFT_Core/DPSRAM_0/DPSRAM_C0_0/DPSRAM_C0_DPSRAM_C0_0_DPSRAM_R0C0/MEM_1024_18", "FFT_mem_0", 1, -1);
        init_signal_spy("FFT_APB_Wrapper_0/FFT_Core/DPSRAM_1/DPSRAM_C0_0/DPSRAM_C0_DPSRAM_C0_0_DPSRAM_R0C0/MEM_1024_18", "FFT_mem_1", 1, -1);
        wait;
    end process;

    THE_STUFF : process
        variable r_val, i_val, abs_val : integer;
    begin

        next_PADDR <= (others => '0');
        next_PWRITE <= '0';
        next_PWDATA <= (others => '0');
        do_apb <= '0';

        if(NSYSRESET /= '1') then
            wait until (NSYSRESET = '1');
        end if;

        --wait for (SYSCLK_PERIOD * 1);
        
        -- load samples
        for i in 0 to TEST_SAMPLES'length - 1 loop
            
            report "i = " & integer'image(i) & "; mem_adr = " & integer'image(to_integer(unsigned(mem_adr_spy)));

            -- Load REAL sample

            next_PADDR <= X"08";
            next_PWRITE <= '1';
            next_PWDATA <= "00000000" & TEST_SAMPLES(i);
            do_apb <= '1';
    
            if(apb_done /= '1') then
                wait until (apb_done = '1');
            end if;
            wait for (SYSCLK_PERIOD * 1);

            do_apb <= '0';

            wait for (SYSCLK_PERIOD * 1);

            report "i = " & integer'image(i) & ": REAL load finished";

            -- Load IMAG sample

            next_PADDR <= X"0C";
            next_PWRITE <= '1';
            next_PWDATA <= (others => '0');
            do_apb <= '1';
    
            if(apb_done /= '1') then
                wait until (apb_done = '1');
            end if;
            wait for (SYSCLK_PERIOD * 1);

            do_apb <= '0';

            wait for (SYSCLK_PERIOD * 1);

            report "i = " & integer'image(i) & ": IMAG load finished";

            -- commit sample

            next_PADDR <= X"00";
            next_PWRITE <= '1';
            next_PWDATA <= X"0001";
            do_apb <= '1';
    
            if(apb_done /= '1') then
                wait until (apb_done = '1');
            end if;
            wait for (SYSCLK_PERIOD * 1);

            do_apb <= '0';

            wait for (SYSCLK_PERIOD * 1);

            report "i = " & integer'image(i) & ": WRITE en finished";

        end loop;

        -- begin FFT
        for i in 0 to 4 loop

            case i is
                when 1 =>
                    next_PADDR <= X"00";
                    next_PWRITE <= '1';
                    next_PWDATA <= X"0002";
                when 2 =>
                    next_PADDR <= X"00";
                    next_PWRITE <= '1';
                    next_PWDATA <= X"0006";
                when others =>  -- when nothing, read status
                    next_PADDR <= X"04";
                    next_PWRITE <= '0';
                    next_PWDATA <= (others => '0');
            end case;
            
            do_apb <= '1';
    
            if(apb_done /= '1') then
                wait until (apb_done = '1');
            end if;
            wait for (SYSCLK_PERIOD * 1);

            do_apb <= '0';

            wait for (SYSCLK_PERIOD * 1);

        end loop;


        
        if(APB_regs_spy(1)(2) /= '1') then
            wait until (APB_regs_spy(1)(2) = '1');
        end if;

        -- read back FFT
        for i in 0 to 512 loop

            -- set address I want

            next_PADDR <= X"1C";
            next_PWRITE <= '1';
            next_PWDATA <= std_logic_vector(to_unsigned(i, 16));
            do_apb <= '1';

            if(apb_done /= '1') then
                wait until (apb_done = '1');
            end if;
            wait for (SYSCLK_PERIOD * 1);

            do_apb <= '0';

            wait for (SYSCLK_PERIOD * 1);

            -- read real

            next_PADDR <= X"10";
            next_PWRITE <= '0';
            next_PWDATA <= (others => '0');
            do_apb <= '1';

            if(apb_done /= '1') then
                wait until (apb_done = '1');
            end if;

            wait for (SYSCLK_PERIOD * 1);

            r_val := to_integer(signed(last_PRDATA));

            do_apb <= '0';

            wait for (SYSCLK_PERIOD * 1);

            -- read imag

            next_PADDR <= X"14";
            next_PWRITE <= '0';
            next_PWDATA <= (others => '0');
            do_apb <= '1';

            if(apb_done /= '1') then
                wait until (apb_done = '1');
            end if;

            wait for (SYSCLK_PERIOD * 1);

            i_val := to_integer(signed(last_PRDATA));

            do_apb <= '0';

            wait for (SYSCLK_PERIOD * 1);

            -- read abs_val

            next_PADDR <= X"18";
            next_PWRITE <= '0';
            next_PWDATA <= (others => '0');
            do_apb <= '1';

            if(apb_done /= '1') then
                wait until (apb_done = '1');
            end if;

            wait for (SYSCLK_PERIOD * 1);

            abs_val := to_integer(signed(last_PRDATA));

            do_apb <= '0';

            report "result i = " & integer'image(i) & ": " & integer'image(r_val) & " + i" & integer'image(i_val) & " = " & integer'image(abs_val);

            wait for (SYSCLK_PERIOD * 1);

            
        end loop;

        wait;
    end process;

    APB_state : process
    begin

        if(NSYSRESET /= '1') then
            PADDR <= (others => '0');
            PWRITE <= '0';
            PWDATA <= (others => '0');
            PSEL <= '0';
            PENABLE <= '0';
            last_PRDATA <= (others => '0');
            last_PSLVERR <= '0';
            wait until (NSYSRESET = '1');
        end if;


        if(do_apb /= '1') then
            wait until (do_apb = '1');
        end if;

    
        PADDR <= next_PADDR;
        PWRITE <= next_PWRITE;
        PWDATA <= next_PWDATA;
        PSEL <= '1';
        -- paddr, pwrite, pwdata are set from another process
        wait for (SYSCLK_PERIOD * 1);
        
        PENABLE <= '1';

        if(PREADY /= '1') then
            wait until (PREADY = '1');
        end if;

        wait for (SYSCLK_PERIOD * 1);

        last_PRDATA <= PRDATA;
        last_PSLVERR <= PSLVERR;

        --PADDR   <= (others => '0');
        PSEL    <= '0';
        PENABLE <= '0';
        --PWRITE  <= '0';
        --PWDATA  <= (others => '0');
        --PREADY these are responses signals
        --PRDATA these are responses signals
        --PSLVERR these are responses signals

        apb_done <= '1';

        if(do_apb /= '0') then
            wait until (do_apb = '0');
        end if;

        apb_done <= '0';


        wait for (SYSCLK_PERIOD * 1);

        

    end process;

end behavioral;

