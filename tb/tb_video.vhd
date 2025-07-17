--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   00:00:00 01/01/2025
-- Design Name:
-- Module Name:   tb_video.vhd
-- Project Name:  Atari System 2
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: Atari System 2
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes:
--
--------------------------------------------------------------------------------
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
--	use ieee.std_logic_arith.all;
--	use ieee.std_logic_unsigned.all;

entity tb_video is
end tb_video;

architecture RTL of tb_video is
	constant CLK14_period : TIME := 1000 ms / 14318180;
	constant CLK16_period : TIME := 1000 ms / 16000000;
	constant CLK20_period : TIME := 1000 ms / 20000000;
	signal	sl_CLK_20M,
			sl_CLK_14M,
			sl_CLK_16M,
			sl_RESET,
			sl_MEMREQn,
			sl_MEMDONE,
			sl_R_WLn,
			sl_COLORAMn,
			sl_VPACKn,
			sl_VMP0,
			sl_VMP1,
			sl_HSCROLLn,
			sl_VSCROLLn,
			sl_HSYNC,
			sl_VSYNC,
			sl_COUT			: std_logic := '1';
	signal	slv_VIDEO_R,
			slv_VIDEO_G,
			slv_VIDEO_B,
			slv_VIDEO_I		: std_logic_vector( 3 downto 0) := (others=>'0');
	signal	slv_R,
			slv_G,
			slv_B,
			slv_DATA_T06,
			slv_DATA_A06,
			slv_DATA_B06,
			slv_DATA_C06,
			slv_DATA_D06,
			slv_DATA_L06,
			slv_DATA_K06,
			slv_DATA_J06,
			slv_DATA_H06,
			slv_DATA_S06,
			slv_DATA_P06,
			slv_DATA_N06,
			slv_DATA_M06	: std_logic_vector( 7 downto 0) := (others=>'0');
	signal	slv_VPA			: std_logic_vector(12 downto 1);
	signal	slv_VPD,
			slv_MOROMD,
			slv_PFROMD		: std_logic_vector(15 downto 0) := (others=>'0');
	signal	slv_ANROMA		: std_logic_vector(15 downto 0) := (others=>'0');
	signal	slv_PFROMA		: std_logic_vector(17 downto 0) := (others=>'0');
	signal	slv_MOROMA		: std_logic_vector(19 downto 0) := (others=>'0');

begin
	-- generate clocks
	p_CLK14 : process begin wait for CLK14_period/2; sl_CLK_14M <= not sl_CLK_14M; end process;
	p_CLK16 : process begin wait for CLK16_period/2; sl_CLK_16M <= not sl_CLK_16M; end process;
	p_CLK20 : process begin wait for CLK20_period/2; sl_CLK_20M <= not sl_CLK_20M; end process;

	-- active high reset for DUT
	p_rst : process
	begin
		sl_RESET <= '0'; wait for CLK20_period*8;
		sl_RESET <= '1'; wait for CLK20_period*8;
		sl_RESET <= '0'; wait;
	end process;

	p_dut : process
	begin
		-- initialize default levels
		sl_VMP0     <= '0';
		sl_VMP1     <= '0';
		sl_R_WLn    <= '1';
		sl_MEMREQn  <= '1';
		sl_COLORAMn <= '1';
		sl_COUT     <= '1';
		sl_MEMDONE  <= '1';
		sl_HSCROLLn <= '1';
		sl_VSCROLLn <= '1';
		slv_VPA     <= x"000";

--		-- H scroll value
--		slv_VPD <= x"8000"; wait for CLK20_period*2;
--		-- toggle H scroll line to latch value
--		sl_HSCROLLn <= '0'; wait for CLK20_period*2;
--		sl_HSCROLLn <= '1'; wait for CLK20_period*2;
--
--		-- V scroll value
--		slv_VPD <= x"2013"; wait for CLK20_period*2;
--		-- toggle V scroll line to latch value
--		sl_VSCROLLn <= '0'; wait for CLK20_period*2;
--		sl_VSCROLLn <= '1'; wait for CLK20_period*2;
--
--		slv_VPD <= x"0000"; wait for CLK20_period*2;

		-- AN_MO palette: fill 1000,10, w.FFFF, 0000, F80F, FC0F, 0000, F00F, 0000, 00FF
--		sl_COLORAMn <= '0'; wait for CLK20_period*2; -- select color palette RAM, COUT used as write enable low
--		slv_VPA <= x"007"; slv_VPD <= x"FFFF"; sl_COUT <= '0'; wait for CLK20_period*2; sl_COUT <= '1'; wait for CLK20_period*2;
--		slv_VPA <= x"009"; slv_VPD <= x"F80F"; sl_COUT <= '0'; wait for CLK20_period*2; sl_COUT <= '1'; wait for CLK20_period*2;
--		slv_VPA <= x"00A"; slv_VPD <= x"FC0F"; sl_COUT <= '0'; wait for CLK20_period*2; sl_COUT <= '1'; wait for CLK20_period*2;
--		slv_VPA <= x"00C"; slv_VPD <= x"F00F"; sl_COUT <= '0'; wait for CLK20_period*2; sl_COUT <= '1'; wait for CLK20_period*2;
--		slv_VPA <= x"00E"; slv_VPD <= x"00FF"; sl_COUT <= '0'; wait for CLK20_period*2; sl_COUT <= '1'; wait for CLK20_period*2;
--		sl_COLORAMn <= '1'; wait for CLK20_period*2; -- deselect color palette RAM

		-- sprite: fill 3800, 40, w.7000, 1371, 0A2C, 6008, 7000, 1B74, 0E2C, 6010, 7000, 1B78, 122C, 6018, 7000, 1B7C, 162C, 6020, 7000, 1381, 1A2C, 6028, 6C00, 034B, 0E2C, 6030, 6C00, 03B7, 122C, 6038, 6C00, 03C7, 162C, 6040
		sl_VMP1     <= '0';
		sl_MEMREQn  <= '0';
		sl_MEMDONE  <= '0'; -- allow video memory selection

		sl_R_WLn <= '0'; -- position max size sprite at top left corner
		slv_VPA <= x"600"; slv_VPD <= x"5FC0"; wait until rising_edge(sl_VPACKn);
		slv_VPA <= x"601"; slv_VPD <= x"3B78"; wait until rising_edge(sl_VPACKn);
		slv_VPA <= x"602"; slv_VPD <= x"002C"; wait until rising_edge(sl_VPACKn);
		slv_VPA <= x"603"; slv_VPD <= x"8008"; wait until rising_edge(sl_VPACKn);
		sl_R_WLn <= '1';

--		slv_VPA <= x"C04"; slv_VPD <= x"7000"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--		slv_VPA <= x"C05"; slv_VPD <= x"1B74"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--		slv_VPA <= x"C06"; slv_VPD <= x"0E2C"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--		slv_VPA <= x"C07"; slv_VPD <= x"6010"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--
--		slv_VPA <= x"C08"; slv_VPD <= x"7000"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--		slv_VPA <= x"C09"; slv_VPD <= x"1B78"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--		slv_VPA <= x"C0A"; slv_VPD <= x"122C"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--		slv_VPA <= x"C0B"; slv_VPD <= x"6018"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--
--		slv_VPA <= x"C0C"; slv_VPD <= x"7000"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--		slv_VPA <= x"C0D"; slv_VPD <= x"1B7C"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--		slv_VPA <= x"C0E"; slv_VPD <= x"162C"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--		slv_VPA <= x"C0F"; slv_VPD <= x"6020"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--
--		slv_VPA <= x"C10"; slv_VPD <= x"7000"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--		slv_VPA <= x"C11"; slv_VPD <= x"1381"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--		slv_VPA <= x"C12"; slv_VPD <= x"1A2C"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--		slv_VPA <= x"C13"; slv_VPD <= x"6028"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--
--		slv_VPA <= x"C14"; slv_VPD <= x"6C00"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--		slv_VPA <= x"C15"; slv_VPD <= x"034B"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--		slv_VPA <= x"C16"; slv_VPD <= x"0E2C"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--		slv_VPA <= x"C17"; slv_VPD <= x"6030"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--
--		slv_VPA <= x"C18"; slv_VPD <= x"6C00"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--		slv_VPA <= x"C19"; slv_VPD <= x"03B7"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--		slv_VPA <= x"C1A"; slv_VPD <= x"122C"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--		slv_VPA <= x"C1B"; slv_VPD <= x"6038"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--
--		slv_VPA <= x"C1C"; slv_VPD <= x"6C00"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--		slv_VPA <= x"C1D"; slv_VPD <= x"03C7"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--		slv_VPA <= x"C1E"; slv_VPD <= x"162C"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';
--		slv_VPA <= x"C1F"; slv_VPD <= x"6040"; sl_R_WLn <= '1'; wait until sl_VPACKn = '0'; sl_R_WLn <= '0'; wait until sl_VPACKn = '1';

		sl_R_WLn    <= '1';
		sl_MEMREQn  <= '1';
		sl_MEMDONE  <= '1'; -- disable video memory selection

		wait;
	end process;

	-- PF ROM_REGION( 0x20000, "gfx1", 0 )
	ROM_VID_A06 : entity work.ROM_VID_A06 port map ( CLK => sl_CLK_16M, DATA => slv_DATA_A06, ADDR => slv_PFROMA(14 downto 0) ); -- "vid_a06.rv1", 0x000000, 0x008000
	ROM_VID_B06 : entity work.ROM_VID_B06 port map ( CLK => sl_CLK_16M, DATA => slv_DATA_B06, ADDR => slv_PFROMA(13 downto 0) ); -- "vid_b06.rv1", 0x00c000, 0x004000 16K
	ROM_VID_C06 : entity work.ROM_VID_C06 port map ( CLK => sl_CLK_16M, DATA => slv_DATA_C06, ADDR => slv_PFROMA(14 downto 0) ); -- "vid_c06.rv1", 0x010000, 0x008000
	ROM_VID_D06 : entity work.ROM_VID_D06 port map ( CLK => sl_CLK_16M, DATA => slv_DATA_D06, ADDR => slv_PFROMA(13 downto 0) ); -- "vid_d06.rv1", 0x01c000, 0x004000 16K

	-- MO ROM_REGION( 0x40000, "gfx2", ROMREGION_INVERT )
	ROM_VID_L06 : entity work.ROM_VID_L06 port map ( CLK => sl_CLK_16M, DATA => slv_DATA_L06, ADDR => slv_MOROMA(14 downto 0) ); -- "vid_l06.rv1", 0x000000, 0x008000
	ROM_VID_K06 : entity work.ROM_VID_K06 port map ( CLK => sl_CLK_16M, DATA => slv_DATA_K06, ADDR => slv_MOROMA(14 downto 0) ); -- "vid_k06.rv1", 0x008000, 0x008000
	ROM_VID_J06 : entity work.ROM_VID_J06 port map ( CLK => sl_CLK_16M, DATA => slv_DATA_J06, ADDR => slv_MOROMA(14 downto 0) ); -- "vid_j06.rv1", 0x010000, 0x008000
	ROM_VID_H06 : entity work.ROM_VID_H06 port map ( CLK => sl_CLK_16M, DATA => slv_DATA_H06, ADDR => slv_MOROMA(14 downto 0) ); -- "vid_h06.rv1", 0x018000, 0x008000

	ROM_VID_S06 : entity work.ROM_VID_S06 port map ( CLK => sl_CLK_16M, DATA => slv_DATA_S06, ADDR => slv_MOROMA(14 downto 0) ); -- "vid_s06.rv1", 0x020000, 0x008000
	ROM_VID_P06 : entity work.ROM_VID_P06 port map ( CLK => sl_CLK_16M, DATA => slv_DATA_P06, ADDR => slv_MOROMA(14 downto 0) ); -- "vid_p06.rv1", 0x028000, 0x008000
	ROM_VID_N06 : entity work.ROM_VID_N06 port map ( CLK => sl_CLK_16M, DATA => slv_DATA_N06, ADDR => slv_MOROMA(14 downto 0) ); -- "vid_n06.rv1", 0x030000, 0x008000
	ROM_VID_M06 : entity work.ROM_VID_M06 port map ( CLK => sl_CLK_16M, DATA => slv_DATA_M06, ADDR => slv_MOROMA(14 downto 0) ); -- "vid_m06.rv1", 0x038000, 0x008000

	-- AL ROM_REGION( 0x2000, "gfx3", 0 )
	ROM_VID_T06 : entity work.ROM_VID_T06 port map ( CLK => sl_CLK_16M, DATA => slv_DATA_T06, ADDR => slv_ANROMA(12 downto 0) ); -- "vid_t06.rv1", 0x000000, 0x002000

	slv_PFROMD <=
		slv_DATA_A06 & slv_DATA_C06 when slv_PFROMA(16) = '0' else
		slv_DATA_B06 & slv_DATA_D06 when slv_PFROMA(16) = '1' else
		(others=>'0');

	-- From MAME we see that "gfx2" region is ROMREGION_INVERT for all games
	-- ROM A14..0 direct, ROM A15 is inverted slv_MOROMA(17), then 18,16,15 generate /OE for each ROM
	slv_MOROMD <=
		not (slv_DATA_L06 & slv_DATA_S06) when slv_MOROMA(18) & slv_MOROMA(16 downto 15) = "000" else
		not (slv_DATA_K06 & slv_DATA_P06) when slv_MOROMA(18) & slv_MOROMA(16 downto 15) = "001" else
		not (slv_DATA_J06 & slv_DATA_N06) when slv_MOROMA(18) & slv_MOROMA(16 downto 15) = "010" else -- slv_MOROMA(19) to /CS of low ROM on Paperboy, Supersprint, Champ. Sprint
		not (slv_DATA_H06 & slv_DATA_M06) when slv_MOROMA(18) & slv_MOROMA(16 downto 15) = "011" else -- slv_MOROMA(18) to /CS of low ROM on Paperboy, Supersprint, Champ. Sprint
--		not (slv_DATA_    & slv_DATA_   ) when slv_MOROMA(18) & slv_MOROMA(16 downto 15) = "100" else
--		not (slv_DATA_    & slv_DATA_   ) when slv_MOROMA(18) & slv_MOROMA(16 downto 15) = "101" else
--		not (slv_DATA_    & slv_DATA_   ) when slv_MOROMA(18) & slv_MOROMA(16 downto 15) = "110" else -- slv_MOROMA(19) to /CS of these ROMs on 720, APB
--		not (slv_DATA_    & slv_DATA_   ) when slv_MOROMA(18) & slv_MOROMA(16 downto 15) = "111" else
		(others=>'0');

	DUT : entity work.VIDEO
	port map (
		I_CLK            => sl_CLK_16M,

		-- Interboard connector P18
		I_VMP0           => sl_VMP0,
		I_VMP1           => sl_VMP1,
		I_R_WLn          => sl_R_WLn,
		I_MEMREQn        => sl_MEMREQn,
		I_COLORAMn       => sl_COLORAMn,
		I_VSCROLLn       => sl_VSCROLLn,
		I_HSCROLLn       => sl_HSCROLLn,
		I_COUT           => sl_COUT,
		I_MEMDONE        => sl_MEMDONE,

		-- Video address and data bus
		I_VPA            => slv_VPA,
		I_VPD            => slv_VPD,
		O_VPD            => open,

		-- Video outbound control signals
		O_VPACKn         => sl_VPACKn,
		O_384VD4Hn       => open,
		O_32VDD4Hn       => open,
		O_STANDALONEn    => open,

		-- Interboard connector P18 end

		-- Video ROMs
		O_ANROMA        => slv_ANROMA,   -- out std_logic_vector(15 downto 0);
		I_ANROMD        => slv_DATA_T06, -- in  std_logic_vector( 7 downto 0); -- in order 7S 7T (ANPIX 1 0)
		O_MOROMA        => slv_MOROMA,   -- out std_logic_vector(19 downto 0);
		I_MOROMD        => slv_MOROMD,   -- in  std_logic_vector(15 downto 0); -- in order 7HJ 7J 7M 7M (MOPIX 3 2 1 0)
		O_PFROMA        => slv_PFROMA,   -- out std_logic_vector(17 downto 0);
		I_PFROMD        => slv_PFROMD,   -- in  std_logic_vector(15 downto 0); -- in order 8A 8B 8BC 8CD (PFPIX 3 2 1 0)

		-- Video picture and signals output
		O_VIDEO_I        => slv_VIDEO_I,
		O_VIDEO_R        => slv_VIDEO_R,
		O_VIDEO_G        => slv_VIDEO_G,
		O_VIDEO_B        => slv_VIDEO_B,
		O_COMPSYNCn      => open,
		O_HSYNC          => sl_HSYNC,
		O_VSYNC          => sl_VSYNC
	);

	RGBI : entity work.RGBI
	port map (
		I_CLK => sl_CLK_16M,
		I_I => slv_VIDEO_I,
		I_R => slv_VIDEO_R,
		I_G => slv_VIDEO_G,
		I_B => slv_VIDEO_B,
		O_R => slv_R,
		O_G => slv_G,
		O_B => slv_B
	);

	bmp_out : entity work.bmp_out generic map ( FILENAME => "BI" )
	port map (
		clk_i => sl_CLK_16M,
		dat_i(23 downto 16) => slv_R,
		dat_i(15 downto  8) => slv_G,
		dat_i( 7 downto  0) => slv_B,
		hs_i  => sl_HSYNC,
		vs_i  => sl_VSYNC
	);
end RTL;
