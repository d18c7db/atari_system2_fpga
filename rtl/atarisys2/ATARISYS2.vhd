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
		I_SLAP_TYPE : in  integer range 100 to 118; -- slapstic type can be changed dynamically 		-- 105:paperboy, 107:720 degrees, 108:ssprint, 109:csprint, 110:apb
		-- System Clocks
		I_CLK_14M3  : in  std_logic; -- 14.3 MHz
		I_CLK_16M0  : in  std_logic; -- 16.0 Mhz
		I_CLK_20M0  : in  std_logic; -- 20.0 MHz

		-- Active high reset
		I_RESET     : in  std_logic;

		O_ADC_ADDR  : out std_logic_vector( 2 downto 0);
		I_ADC_DATA  : in  std_logic_vector( 7 downto 0);
--		-- Trackball inputs active low:
		I_CLK       : in  std_logic_vector(3 downto 0); -- HCLK2,VCLK2,HCLK1,VCLK1
		I_DIR       : in  std_logic_vector(3 downto 0); -- HDIR2,VDIR2,HDIR1,VDIR1
--		-- System inputs active low
		I_SELFTESTn : in  std_logic;                    -- SELFTEST
		I_SW        : in  std_logic_vector(6 downto 1); -- SW[6:1]
		I_COIN_L    : in  std_logic;
		I_COIN_R    : in  std_logic;
		I_COIN_AUX  : in  std_logic;
		I_WDISn     : in  std_logic;                    -- Watchdog Disable when low
		O_LEDS      : out std_logic_vector(2 downto 1);
--
--		-- Audio out
		O_AUDIO_L   : out std_logic_vector(15 downto 0) := (others=>'0');
		O_AUDIO_R   : out std_logic_vector(15 downto 0) := (others=>'0');
--
--		-- Monitor output
		O_VIDEO_R   : out std_logic_vector(3 downto 0);
		O_VIDEO_G   : out std_logic_vector(3 downto 0);
		O_VIDEO_B   : out std_logic_vector(3 downto 0);
		O_HSYNC     : out std_logic;
		O_VSYNC     : out std_logic;
		O_CSYNC     : out std_logic;

--		-- EEPROM data bus
		O_EEPDATA   : out std_logic_vector( 7 downto 0);
		I_EEPDATA   : in  std_logic_vector( 7 downto 0);
		O_EEPWR     : out std_logic;
--
		I_ROM_DATA  : in  std_logic_vector(15 downto 0);
		O_ROM_ADDR  : out std_logic_vector(19 downto 1);

		I_ANROMD    : in  std_logic_vector( 7 downto 0);
		O_ANROMA    : out std_logic_vector(15 downto 0);
		I_MOROMD    : in  std_logic_vector(15 downto 0);
		O_MOROMA    : out std_logic_vector(19 downto 0);
		I_PFROMD    : in  std_logic_vector(15 downto 0);
		O_PFROMA    : out std_logic_vector(17 downto 0)
	);
end FPGA_ATARISYS2;

architecture RTL of FPGA_ATARISYS2 is
signal
	sl_P2IRQCLRn,
	sl_P2IRQn,
	sl_P2PORTRDn,
	sl_P2PORTWRn,
	sl_RST6502n,
	sl_P2RESETn,
	sl_VMP0,
	sl_VMP1,
	sl_R_WLn,
	sl_MEMREQn,
	sl_COLORAMn,
	sl_VSCROLLn,
	sl_HSCROLLn,
	sl_COUT,
	sl_COIN_L,
	sl_COIN_R,
	sl_COIN_AUX,
	sl_MEMDONE,
	sl_STANDALONE,
	sl_VIDMEMACKn,
	sl_HBLANK,
	sl_VBLANK,
	sl_32V,
	sl_EEPWR
						: std_logic := '1';
signal
	sl_TMS_CLK_ENA,
	sl_LETA_CLK_ENA,
	sl_P1TALK,
	sl_P2TALK,
	sl_SPEED,
	sl_HSYNC,
	sl_VSYNC,
	sl_CSYNCn
						: std_logic := '0';
signal slv_adc_addr		: std_logic_vector( 2 downto 0) := (others=>'0');
signal
	slv_CLK,
	slv_DIR,
	slv_R,
	slv_G,
	slv_B,
	slv_VIDEO_R,
	slv_VIDEO_G,
	slv_VIDEO_B,
	slv_VIDEO_I
						: std_logic_vector( 3 downto 0) := (others=>'0');
signal
	slv_ANROMD,
	slv_EEPDI,
	slv_EEPDO,
	slv_T11_DB,
	slv_6502_DB,
	slv_adc_data
						: std_logic_vector( 7 downto 0) := (others=>'0');
signal slv_VPA			: std_logic_vector(12 downto 1) := (others=>'0');
signal
	slv_AUDIO_L,
	slv_AUDIO_R,
	slv_VPDI,
	slv_VPDO,
	slv_ANROMA,
	slv_MOROMD,
	slv_PFROMD,
	slv_ROM_DATA
	: std_logic_vector(15 downto 0) := (others=>'0');
signal slv_ROM_ADDR		: std_logic_vector(19 downto 1) := (others=>'0');
signal slv_PFROMA		: std_logic_vector(17 downto 0) := (others=>'0');
signal slv_MOROMA		: std_logic_vector(19 downto 0) := (others=>'0');
begin
	slv_adc_data <= I_ADC_DATA;
	O_ADC_ADDR   <= slv_adc_addr;
	slv_ROM_DATA <= I_ROM_DATA;
	O_ROM_ADDR   <= slv_ROM_ADDR;

	O_ANROMA     <= slv_ANROMA;
	O_MOROMA     <= slv_MOROMA;
	O_PFROMA     <= slv_PFROMA;

	slv_ANROMD   <= I_ANROMD;
	slv_MOROMD   <= I_MOROMD;
	slv_PFROMD   <= I_PFROMD;

	O_EEPDATA    <= slv_EEPDO;
	slv_EEPDI    <= I_EEPDATA;
	O_EEPWR      <= sl_EEPWR;

	O_AUDIO_L    <= slv_AUDIO_L;
	O_AUDIO_R    <= slv_AUDIO_R;

	slv_CLK      <= I_CLK;
	slv_DIR      <= I_DIR;

	O_VIDEO_R    <= slv_R;
	O_VIDEO_G    <= slv_G;
	O_VIDEO_B    <= slv_B;
	O_HSYNC      <= sl_HSYNC;
	O_VSYNC      <= sl_VSYNC;
	O_CSYNC      <= not sl_CSYNCn;

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
		O_LETA_CLK_ENA => sl_LETA_CLK_ENA,
		O_P2IRQn       => sl_P2IRQn,

		I_ROM_DATA     => slv_ROM_DATA,
		O_ROM_ADDR     => slv_ROM_ADDR,

		O_ADC_ADDR     => slv_adc_addr,
		I_ADC_DATA     => slv_adc_data,

		O_T11_DB       => slv_T11_DB,
		I_6502_DB      => slv_6502_DB,

		O_P2RESETn     => sl_P2RESETn,
		O_RST6502n     => sl_RST6502n,
		I_P2PORTRDn    => sl_P2PORTRDn,
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
		I_STANDALONE   => sl_STANDALONE,
		I_VIDMEMACKn   => sl_VIDMEMACKn,
		I_VBLANK       => sl_VBLANK,
		I_32V          => sl_32V
	);

	CMAPR : entity work.CMAP port map (I_CLK => I_CLK_16M0, I_I => slv_VIDEO_I, I_C => slv_VIDEO_R, O_C => slv_R, I_S => '1'); -- 0=MAME 1=SIM
	CMAPG : entity work.CMAP port map (I_CLK => I_CLK_16M0, I_I => slv_VIDEO_I, I_C => slv_VIDEO_G, O_C => slv_G, I_S => '1'); -- 0=MAME 1=SIM
	CMAPB : entity work.CMAP port map (I_CLK => I_CLK_16M0, I_I => slv_VIDEO_I, I_C => slv_VIDEO_B, O_C => slv_B, I_S => '1'); -- 0=MAME 1=SIM

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
		O_384VD_4Hn    => sl_VBLANK,
		O_HBLANK       => sl_HBLANK,
		O_32VDD_4Hn    => sl_32V,
		O_STANDALONE   => sl_STANDALONE,

		O_ANROMA       => slv_ANROMA,
		I_ANROMD       => slv_ANROMD,
		O_MOROMA       => slv_MOROMA,
		I_MOROMD       => slv_MOROMD,
		O_PFROMA       => slv_PFROMA,
		I_PFROMD       => slv_PFROMD,
		O_VIDEO_I      => slv_VIDEO_I,
		O_VIDEO_R      => slv_VIDEO_R,
		O_VIDEO_G      => slv_VIDEO_G,
		O_VIDEO_B      => slv_VIDEO_B,
		O_COMPSYNCn    => sl_CSYNCn,
		O_HSYNC        => sl_HSYNC,
		O_VSYNC        => sl_VSYNC
	);

--	u_audio : entity work.AUDIO
--	port map (
--		I_CLK_14M3     => I_CLK_14M3,
--		I_TMS_CLK_ENA  => sl_TMS_CLK_ENA,
--		I_LETA_CLK_ENA => sl_TMS_CLK_ENA,
--		I_COINL        => sl_COIN_L,
--		I_COINR        => sl_COIN_R,
--		I_COINAUX      => sl_COIN_AUX,
--		I_SELFTESTn    => '1',
--		I_P1TALK       => sl_P1TALK,
--		I_P2TALK       => sl_P2TALK,
--
--		O_SNDROMA      => open, --: out std_logic_vector(15 downto 0); -- address 4000-FFFF
--		I_SNDROMD      => (others=>'0'),--: in  std_logic_vector( 7 downto 0);
--		O_P2PORTRDn    => sl_P2PORTRDn,
--		O_P2PORTWRn    => sl_P2PORTWRn,
--
--		O_SPEED        => sl_SPEED,
--		O_P2IRQCLRn    => sl_P2IRQCLRn,
--		I_P2IRQn       => sl_P2IRQn,
--
--		O_6502_DB      => slv_6502_DB,
--		I_T11_DB       => slv_T11_DB,
--
--		O_CNTRL        => open,
--		O_CNTRR        => open,
--		O_LED1         => O_LEDS(1),
--		O_LED2         => O_LEDS(2),
--
--		O_AUDIO_L      => slv_AUDIO_L,
--		O_AUDIO_R      => slv_AUDIO_R,
--
--		I_P2RESETn     => sl_P2RESETn,
--		I_RST6502n     => sl_RST6502n,
--
--		-- 8 position switches to Pokey 1 and 2 parallel port
--		I_SW8P1        => (others=>'1'), -- : in  std_logic_vector(7 downto 0);
--		I_SW8P2        => (others=>'1'), -- : in  std_logic_vector(7 downto 0);
--
--		-- quadrature encoders to LETA
--		I_LETA_CLK     => slv_CLK,
--		I_LETA_DIR     => slv_DIR
--	);

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
