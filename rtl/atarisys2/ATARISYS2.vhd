--	(c) 2024 d18c7db(a)hotmail
--
--	This program is free software; you can redistribute it and/or modify it under
--	the terms of the GNU General Public License version 3 or, at your option,
--	any later version as published by the Free Software Foundation.
--
--	This program is distributed in the hope that it will be useful,
--	but WITHOUT ANY WARRANTY; without even the implied warranty of
--	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
--
--	For full details, see the GNU General Public License at www.gnu.org/licenses
--
--	Atari Games Arcade, Release: 1984
--	Main PCB : A042571 ATARI SYSTEM II CPU
--	Main CPU : DEC T11 @ 10 MHz (DEC 21-17311-02)
--	Sound CPU : MOS Technology M6502 2.2 MHz
--	Sound Chips : Yamaha YM2151 @ 3.579545 MHz, 2 x Atari Pokey @ 1.789772 MHz, Texas Instruments TMS5220 @ 625 KHz
--	Crystal Oscillators : 32MHz, 20MHz, 14.31818MHz
--	VLSI : 645 V D727B, VGC7205-0672, 137304-2002 Atari-LETA
--	Other Chips : 8645 137430-001 Atari-POKEY
--	Protection Chip : Slapstic
--	Video Resolution : 512 x 384
--
--	Based on following game schematics
--	Accelerator         unreleased
--	Gremlins            unreleased
--	Paperboy            (1984) Slapstic chip: 137412-105, Schematic: SP-275
--	Super Sprint        (1986) Slapstic chip: 137412-108, Schematic: SP-290
--	Championship Sprint (1986) Slapstic chip: 137412-109, Schematic: SP-292
--	720                 (1986) Slapstic chip: 137412-107, Schematic: SP-294
--	APB                 (1987) Slapstic chip: 137412-110, Schematic: SP-308

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;

entity FPGA_ATARISYS2 is
	port (
		I_SLAP_TYPE: in  integer range 100 to 118; -- slapstic type can be changed dynamically 		-- 105:paperboy, 107:720 degrees, 108:ssprint, 109:csprint, 110:apb
		-- System Clocks
		I_CLK_14M3 : in  std_logic; -- 14.3 MHz
		I_CLK_16M0 : in  std_logic; -- 16.0 Mhz
		I_CLK_20M0 : in  std_logic; -- 20.0 MHz

		-- Active low reset
		I_RESET    : in  std_logic;

		O_ADC_ADDR : out std_logic_vector( 2 downto 0);
		I_ADC_DATA : in  std_logic_vector( 7 downto 0);
--		-- Trackball inputs active low:
--		I_CLK      : in  std_logic_vector(3 downto 0); -- HCLK2,VCLK2,HCLK1,VCLK1
--		I_DIR      : in  std_logic_vector(3 downto 0); -- HDIR2,VDIR2,HDIR1,VDIR1
--		-- System inputs active low
		I_SELFTESTn: in  std_logic;                    -- SELFTEST
		I_SW       : in  std_logic_vector(6 downto 1); -- SW[6:1]
--		I_COIN     : in  std_logic_vector(2 downto 0); -- COIN_AUX, COIN_R, COIN_L
		I_WDISn    : in  std_logic                     -- Watchdog Disable when low
--		O_LEDS     : out std_logic_vector(2 downto 1);
--
--		-- Audio out
--		O_AUDIO_L  : out std_logic_vector(15 downto 0) := (others=>'0');
--		O_AUDIO_R  : out std_logic_vector(15 downto 0) := (others=>'0');
--
--		-- Monitor output
--		O_VIDEO_I  : out std_logic_vector(3 downto 0);
--		O_VIDEO_R  : out std_logic_vector(3 downto 0);
--		O_VIDEO_G  : out std_logic_vector(3 downto 0);
--		O_VIDEO_B  : out std_logic_vector(3 downto 0);
--		O_HSYNC    : out std_logic;
--		O_VSYNC    : out std_logic;
--		O_CSYNC    : out std_logic;
--
--		O_HBLANK   : out std_logic;
--		O_VBLANK   : out std_logic;
--
--		O_ADDR2B   : out std_logic_vector(13 downto 0);
--		I_DATA2B   : in  std_logic_vector( 7 downto 0);
--
--		-- EEPROM data bus
--		O_EEPDATA  : out std_logic_vector( 7 downto 0);
--		I_EEPDATA  : in  std_logic_vector( 7 downto 0);
--		O_EEPWR    : out std_logic;
--
--		-- CART interface
--		O_ROMn     : out std_logic_vector( 4 downto 0);
--		O_MA18n    : out std_logic;
--		O_MADEC    : out std_logic_vector(15 downto 1);
--		I_MDATA    : in  std_logic_vector(15 downto 0);
--
--		O_SROMn    : out std_logic_vector( 2 downto 0);
--		O_SBA      : out std_logic_vector(13 downto 0);
--
--		O_PADDR    : out std_logic_vector( 8 downto 0);
--		I_PD4A     : in  std_logic_vector( 7 downto 0);
--		I_PD7A     : in  std_logic_vector( 7 downto 0);
--		I_SDATA    : in  std_logic_vector( 7 downto 0);
--
--		O_VADDR    : out std_logic_vector(18 downto 0);
--		I_VDATA    : in  std_logic_vector(63 downto 0)
	);
end FPGA_ATARISYS2;

architecture RTL of FPGA_ATARISYS2 is
signal slv_adc_data : std_logic_vector( 7 downto 0);
signal slv_adc_addr : std_logic_vector( 2 downto 0);
signal
	slv_VPDI,
	slv_VPDO,
	slv_ROM_DATA,
	slv_data_SLAPS,
	slv_data_PAGE0,
	slv_data_PAGE1,
	slv_data_PAGE2,
	slv_data_PAGE3	: std_logic_vector(15 downto 0);
signal slv_VPA      : std_logic_vector(12 downto 1);
signal slv_ROM_ADDR : std_logic_vector(16 downto 1);
signal
	sl_SPEED,
	sl_P2IRQCLRn,
	sl_VMP0,
	sl_VMP1,
	sl_R_WLn,
	sl_MEMREQn,
	sl_TMS_CLK_ENA,
	sl_COLORAMn,
	sl_VSCROLLn,
	sl_HSCROLLn,
	sl_COUT,
	sl_P1TALK,
	sl_P2TALK,
	sl_P2PORTWRn,
	sl_RST6502n,
	sl_P2RESETn,
	sl_MEMDONE,
	sl_STANDALONEn,
	sl_VIDMEMACKn,
	sl_VBLANK,
	sl_32V,
	sl_ROM_SLAPn,
	sl_ROM_PAGEn
	: std_logic := '1';
begin
	-- ROMs
	ROM_SLAPSH : entity work.ROM_CPU_N07 port map ( CLK => I_CLK_20M0, DATA => slv_data_SLAPS(15 downto 8), ADDR => slv_ROM_ADDR(14 downto 1) ); --n07 0x008001 HI
	ROM_SLAPSL : entity work.ROM_CPU_L07 port map ( CLK => I_CLK_20M0, DATA => slv_data_SLAPS( 7 downto 0), ADDR => slv_ROM_ADDR(14 downto 1) ); --l07 0x008000 LO
	ROM_PAGE0H : entity work.ROM_CPU_N06 port map ( CLK => I_CLK_20M0, DATA => slv_data_PAGE0(15 downto 8), ADDR => slv_ROM_ADDR(14 downto 1) ); --n06 0x010001 HI
	ROM_PAGE0L : entity work.ROM_CPU_F06 port map ( CLK => I_CLK_20M0, DATA => slv_data_PAGE0( 7 downto 0), ADDR => slv_ROM_ADDR(14 downto 1) ); --f06 0x010000 LO
	ROM_PAGE1H : entity work.ROM_CPU_P06 port map ( CLK => I_CLK_20M0, DATA => slv_data_PAGE1(15 downto 8), ADDR => slv_ROM_ADDR(14 downto 1) ); --p06 0x030001 HI
	ROM_PAGE1L : entity work.ROM_CPU_J06 port map ( CLK => I_CLK_20M0, DATA => slv_data_PAGE1( 7 downto 0), ADDR => slv_ROM_ADDR(14 downto 1) ); --j06 0x030000 LO
	ROM_PAGE2H : entity work.ROM_CPU_R06 port map ( CLK => I_CLK_20M0, DATA => slv_data_PAGE2(15 downto 8), ADDR => slv_ROM_ADDR(14 downto 1) ); --r06 0x050001 HI
	ROM_PAGE2L : entity work.ROM_CPU_K06 port map ( CLK => I_CLK_20M0, DATA => slv_data_PAGE2( 7 downto 0), ADDR => slv_ROM_ADDR(14 downto 1) ); --k06 0x050000 LO
	ROM_PAGE3H : entity work.ROM_CPU_S06 port map ( CLK => I_CLK_20M0, DATA => slv_data_PAGE3(15 downto 8), ADDR => slv_ROM_ADDR(14 downto 1) ); --s06 0x070001 HI
	ROM_PAGE3L : entity work.ROM_CPU_L06 port map ( CLK => I_CLK_20M0, DATA => slv_data_PAGE3( 7 downto 0), ADDR => slv_ROM_ADDR(14 downto 1) ); --l06 0x070000 LO

	slv_ROM_DATA <=
		slv_data_SLAPS when sl_ROM_SLAPn = '0'                                     else -- SLAP
		slv_data_PAGE0 when sl_ROM_PAGEn = '0' and slv_ROM_ADDR(16 downto 15) = "00" else -- PAGE0
		slv_data_PAGE1 when sl_ROM_PAGEn = '0' and slv_ROM_ADDR(16 downto 15) = "01" else -- PAGE1
		slv_data_PAGE2 when sl_ROM_PAGEn = '0' and slv_ROM_ADDR(16 downto 15) = "10" else -- PAGE2
		slv_data_PAGE3 when sl_ROM_PAGEn = '0' and slv_ROM_ADDR(16 downto 15) = "11" else -- PAGE3
		(others=>'0');

	u_main : entity work.MAIN
	port map (
		I_SLAP_TYPE    => I_SLAP_TYPE,
		I_CLK          => I_CLK_20M0,
		I_PWRONRST     => I_RESET,
		I_SELFTESTn    => I_SELFTESTn,
		I_WDISn        => I_WDISn,
		I_SW           => I_SW,
		I_SPEED        => sl_SPEED,
		I_P2IRQCLRn    => sl_P2IRQCLRn,
		O_TMS_CLK_ENA  => sl_TMS_CLK_ENA,
		O_LETA_CLK_ENA => sl_TMS_CLK_ENA,

		I_ROM_DATA     => slv_ROM_DATA,
		O_ROM_ADDR     => slv_ROM_ADDR,
--		O_ROM_SLAPn    => sl_ROM_SLAPn,
--		O_ROM_PAGEn    => sl_ROM_PAGEn,

		O_ADC_ADDR     => slv_adc_addr,
		I_ADC_DATA     => slv_adc_data,

		O_P2RESETn     => sl_P2RESETn,
		O_RST6502n     => sl_RST6502n,
		I_P2PORTWRn    => sl_P2PORTWRn,
		O_P1TALK       => sl_P1TALK,
		O_P2TALK       => sl_P2TALK,

		O_VMP0         => sl_VMP0,
		O_VMP1         => sl_VMP1,
		O_R_WLn        => sl_R_WLn,
		O_MEMREQn      => sl_MEMREQn,
		O_COLORAMn     => sl_COLORAMn,
		O_VSCROLLn     => sl_VSCROLLn,
		O_HSCROLLn     => sl_HSCROLLn,
		O_COUT         => sl_COUT,
		O_MEMDONE      => sl_MEMDONE,
		O_VPA          => slv_VPA,
		O_VPD          => slv_VPDO,
		I_VPD          => slv_VPDI,
		I_STANDALONEn  => sl_STANDALONEn,
		I_VIDMEMACKn   => sl_VIDMEMACKn,
		I_VBLANK       => sl_VBLANK,
		I_32V          => sl_32V
	);

	u_video : entity work.VIDEO
	port map (
		I_CLK          => I_CLK_16M0,
		I_VMP0         => sl_VMP0,
		I_VMP1         => sl_VMP1,
		I_R_WLn        => sl_R_WLn,
		I_MEMREQn      => sl_MEMREQn,
		I_COLORAMn     => sl_COLORAMn,
		I_VSCROLLn     => sl_VSCROLLn,
		I_HSCROLLn     => sl_HSCROLLn,
		I_COUT         => sl_COUT,
		I_MEMDONE      => sl_MEMDONE,
		I_VPA          => slv_VPA,
		I_VPD          => slv_VPDO,
		O_VPD          => slv_VPDI,

		O_VPACKn       => sl_VIDMEMACKn,
		O_384VD4Hn     => sl_VBLANK,
		O_32VDD4Hn     => sl_32V,
		O_STANDALONEn  => sl_STANDALONEn,

		O_ANROMA       => open,
		I_ANROMD       => (others=>'0'),
		O_MOROMA       => open,
		I_MOROMD       => (others=>'0'),
		O_PFROMA       => open,
		I_PFROMD       => (others=>'0'),
		O_VIDEO_I      => open,
		O_VIDEO_R      => open,
		O_VIDEO_G      => open,
		O_VIDEO_B      => open,
		O_COMPSYNCn    => open,
		O_HSYNC        => open,
		O_VSYNC        => open
	);

	u_audio : entity work.AUDIO
	port map (
		I_CLK_14M3     => I_CLK_14M3,
		I_TMS_CLK_ENA  => sl_TMS_CLK_ENA,
		I_LETA_CLK_ENA => sl_TMS_CLK_ENA,
		I_COINR        => '1',
		I_COINL        => '1',
		I_COINAUX      => '1',
		I_SELFTESTn    => '1',
		I_P1TALK       => sl_P1TALK,
		I_P2TALK       => sl_P2TALK,

		O_SNDROMA      => open, --: out std_logic_vector(15 downto 0); -- address 4000-FFFF
		I_SNDROMD      => (others=>'0'),--: in  std_logic_vector( 7 downto 0);
		O_P2PORTWRn    => sl_P2PORTWRn,

		O_SPEED        => sl_SPEED,
		O_P2IRQCLRn    => sl_P2IRQCLRn,

		O_CNTRL        => open,
		O_CNTRR        => open,
		O_LED1         => open,
		O_LED2         => open,

		O_AUDIO1       => open,
		O_AUDIO2       => open,

		I_P2RESETn     => sl_P2RESETn,
		I_RST6502n     => sl_RST6502n,

		-- 8 position switches to Pokey 1 and 2 parallel port
		I_SW8P1        => (others=>'1'),-- : in  std_logic_vector(7 downto 0);
		I_SW8P2        => (others=>'1'),-- : in  std_logic_vector(7 downto 0);

		-- quadrature encoders to LETA
		I_LETA_CLK     => (others=>'0'),-- : in  std_logic_vector(3 downto 0);
		I_LETA_DIR     => (others=>'0')-- : in  std_logic_vector(3 downto 0);
	);

--	p_volmux : process
--	begin
--		wait until rising_edge(I_CLK_20M0);
--		-- add signed outputs together, already have extra spare bits for overflow
--		s_chan_l <= ( ((s_snd & "00") + s_audio_YML) + (s_POK_out(s_POK_out'left) & s_POK_out & "000000000") );
--		s_chan_r <= ( ((s_snd & "00") + s_audio_YMR) + (s_POK_out(s_POK_out'left) & s_POK_out & "000000000") );
--
--		-- convert to unsigned slv for DAC usage
--		O_AUDIO_L <= std_logic_vector(s_chan_l + 16383);
--		O_AUDIO_R <= std_logic_vector(s_chan_r + 16383);
--	end process;
end RTL;
