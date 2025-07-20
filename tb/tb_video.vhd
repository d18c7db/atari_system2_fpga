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
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
--	use ieee.std_logic_arith.all;

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
			slv_ROM10D,
			slv_ROM20D,
			slv_ROM30D,
			slv_ROM38D,
			slv_PFROMD,
			slv_ANROMA		: std_logic_vector(15 downto 0) := (others=>'0');
	signal	slv_ctr			: std_logic_vector(15 downto 0) := (others=>'0');
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
		sl_RESET <= '0'; wait for CLK16_period*4;
		sl_RESET <= '1'; wait for CLK16_period*8;
		sl_RESET <= '0'; wait;
	end process;

	-- palette initialization ROM region 1000-11FF
	ROM_10 : entity work.ROM_10 port map ( I_CLK => sl_CLK_20M, O_DATA => slv_ROM10D, I_ADDR => slv_ctr( 9 downto 2) ); -- 256x16
	-- screen initialization ROMs region 2000-3FFF 20=AN/MO bank 20,  30,38=PF banks 30,38
	ROM_20 : entity work.ROM_20 port map ( I_CLK => sl_CLK_20M, O_DATA => slv_ROM20D, I_ADDR => slv_ctr(13 downto 2) ); -- 4Kx16
	ROM_30 : entity work.ROM_30 port map ( I_CLK => sl_CLK_20M, O_DATA => slv_ROM30D, I_ADDR => slv_ctr(13 downto 2) ); -- 4Kx16
	ROM_38 : entity work.ROM_38 port map ( I_CLK => sl_CLK_20M, O_DATA => slv_ROM38D, I_ADDR => slv_ctr(13 downto 2) ); -- 4Kx16

	p_dut : process
	begin
		wait until rising_edge(sl_CLK_20M);
		if sl_RESET = '1' then
			slv_ctr <= (others=>'0');
		else
			case slv_ctr(15 downto 14) is

			-- outer state 00 - init ANMO RAM 2000-3FFF bank 0
			when "00" =>
				-- counter bits ( 1 downto 0) select state
				-- counter bits (13 downto 2) are the ROM address
				case slv_ctr(1 downto 0) is
				when "00" =>
					sl_VMP0     <= '0'; -- top addr bit of PF
					sl_VMP1     <= '0'; -- selects ANMO when 0 or PF when 1
					sl_MEMREQn  <= '0';
					sl_MEMDONE  <= '0'; -- allow video memory selection
					sl_R_WLn    <= '0'; -- enable write
					slv_VPA <= slv_ctr(13 downto 2); -- address
					slv_ctr <= slv_ctr + 1;
				when "01" =>
					slv_VPD <= slv_ROM20D; -- data from intialization ROM
					slv_ctr <= slv_ctr + 1;
				when "10" =>
					if sl_VPACKn = '0' then
						slv_ctr <= slv_ctr + 1;
					end if;
				when "11" =>
					if sl_VPACKn = '1' then
						sl_R_WLn    <= '1';
						sl_MEMREQn  <= '1';
						sl_MEMDONE  <= '1'; -- disable video memory selection
						slv_ctr <= slv_ctr + 1;
					end if;
				when others => null;
				end case;

			-- outer state 01 - init PF RAM 2000-3FFF bank 2
			when "01" =>
				-- counter bits ( 1 downto 0) select state
				-- counter bits (13 downto 2) are the ROM address
				case slv_ctr(1 downto 0) is
				when "00" =>
					sl_VMP0     <= '0'; -- top addr bit of PF
					sl_VMP1     <= '1'; -- selects ANMO when 0 or PF when 1
					sl_MEMREQn  <= '0';
					sl_MEMDONE  <= '0'; -- allow video memory selection
					sl_R_WLn    <= '0'; -- enable write
					slv_ctr <= slv_ctr + 1;
				when "01" =>
					slv_VPA <= slv_ctr(13 downto 2); -- address
					slv_ctr <= slv_ctr + 1;
				when "10" =>
					slv_VPD <= slv_ROM30D; -- data from intialization ROM
					if sl_VPACKn = '0' then
						slv_ctr <= slv_ctr + 1;
					end if;
				when "11" =>
					if sl_VPACKn = '1' then
						sl_R_WLn    <= '1';
						sl_MEMREQn  <= '1';
						sl_MEMDONE  <= '1'; -- disable video memory selection
						slv_ctr <= slv_ctr + 1;
					end if;
				when others => null;
				end case;

			-- outer state 10 - init PF RAM 2000-3FFF bank 3
			when "10" =>
				-- counter bits ( 1 downto 0) select state
				-- counter bits (13 downto 2) are the ROM address
				case slv_ctr(1 downto 0) is
				when "00" =>
					sl_VMP0     <= '1'; -- top addr bit of PF
					sl_VMP1     <= '1'; -- selects ANMO when 0 or PF when 1
					sl_MEMREQn  <= '0';
					sl_MEMDONE  <= '0'; -- allow video memory selection
					sl_R_WLn    <= '0'; -- enable write
					slv_ctr <= slv_ctr + 1;
				when "01" =>
					slv_VPA <= slv_ctr(13 downto 2); -- address
					slv_ctr <= slv_ctr + 1;
				when "10" =>
					slv_VPD <= slv_ROM38D; -- data from intialization ROM
					if sl_VPACKn = '0' then
						slv_ctr <= slv_ctr + 1;
					end if;
				when "11" =>
					if sl_VPACKn = '1' then
						sl_R_WLn    <= '1';
						sl_MEMREQn  <= '1';
						sl_MEMDONE  <= '1'; -- disable video memory selection
						slv_ctr <= slv_ctr + 1;
					end if;
				when others => null;
				end case;

			-- outer state 11 - init palette RAM
			when "11" =>
				if slv_ctr < x"C400" then -- if in palette range
					-- counter bits ( 1 downto 0) select state
					-- counter bits ( 9 downto 2) are the ROM address
					case slv_ctr(1 downto 0) is
					when "00" =>
						sl_COLORAMn <= '0'; -- select color palette RAM
						sl_VMP0     <= '0'; -- top addr bit of PF
						sl_VMP1     <= '0'; -- selects ANMO when 0 or PF when 1
						slv_VPA <= slv_ctr(13 downto 2); -- address
						slv_ctr <= slv_ctr + 1;
					when "01" =>
						slv_VPD <= slv_ROM10D; -- data from intialization ROM
						sl_COUT <= '1'; -- write data
						slv_ctr <= slv_ctr + 1;
					when "10" =>
						slv_ctr <= slv_ctr + 1;
					when "11" =>
						sl_COUT <= '0';
						sl_COLORAMn <= '1'; -- restore to defaults
						slv_ctr <= slv_ctr + 1;
					when others => null;
					end case;
				else -- special cases
					case slv_ctr(2 downto 0) is
					when "000" =>
						-- H scroll value
						slv_VPD <= x"8000";
						slv_ctr <= slv_ctr + 1;
					when "001" =>
						-- toggle H scroll line to latch value
						sl_HSCROLLn <= '0';
						slv_ctr <= slv_ctr + 1;
					when "010" =>
						sl_HSCROLLn <= '1';
						slv_ctr <= slv_ctr + 1;

					when "011" =>
						-- V scroll value
						slv_VPD <= x"2013";
						slv_ctr <= slv_ctr + 1;
					when "100" =>
						-- toggle V scroll line to latch value
						sl_VSCROLLn <= '0';
						slv_ctr <= slv_ctr + 1;
					when "101" =>
						sl_VSCROLLn <= '1';
						slv_ctr <= slv_ctr + 1;
					when others => null; -- freeze state machine
					end case;
				end if;

			-- outer state never reached default state
			when others => null;
			end case;

		end if;
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
		I_VMP0           => sl_VMP0, -- top addr bit of PF
		I_VMP1           => sl_VMP1, -- selects ANMO when 0 or PF when 1
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
