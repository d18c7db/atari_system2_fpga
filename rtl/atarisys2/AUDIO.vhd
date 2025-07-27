--	(c) 2025 d18c7db(a)hotmail
--
--	This program is free software; you can redistribute it and/or modify it under
--	the terms of the GNU General Public License version 3 or, at your option,
--	any later version as published by the Free Software Foundation.
--
--	This program is distributed in the hope that it will be useful,
--	but WITHOUT ANY WARRANTY; without even the implied warranty of
--	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
--
-- For full details, see the GNU General Public License at www.gnu.org/licenses
-- Atari System-2 Audio CPU circuit, all chip designations are based on SP-308 schematic

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
-- synthesis translate_off
	use ieee.std_logic_textio.all;
	use std.textio.all;
-- synthesis translate_on

entity AUDIO is
	port(
		-- Clocks and Clock Enables
		I_CLK_14M3      : in  std_logic; -- 14.31818MHz

		I_COINR         : in  std_logic;
		I_COINL         : in  std_logic;
		I_COINAUX       : in  std_logic;
		I_SELFTESTn     : in  std_logic;

		-- Inter-processor comms
		I_P1TALK        : in  std_logic;
		I_P2TALK        : in  std_logic;

		O_P2PORTRDn     : out std_logic;
		O_P2PORTWRn     : out std_logic;

		I_P2RESETn      : in  std_logic;
		I_RST6502n      : in  std_logic;
		I_P2IRQn        : in  std_logic;
		O_P2IRQCLRn     : out std_logic;

		O_6502_DB       : out std_logic_vector( 7 downto 0); -- 6502 to T-11
		I_T11_DB        : in  std_logic_vector( 7 downto 0); -- T-11 to 6502

		-- external ROMs
		O_SNDROMA       : out std_logic_vector(15 downto 0); -- address 4000-FFFF
		I_SNDROMD       : in  std_logic_vector( 7 downto 0);

		-- Speech Synth Clock Selection
		I_TMS_CLK_ENA   : in  std_logic; -- selectable 625Khz or 833Khz
		O_SPEED         : out std_logic; -- selects 625Khz when low or 833Khz when high

		-- Coin counters and LEDs
		O_CNTRL         : out std_logic; -- Coin Counter logic levels before the open collector transistor outputs
		O_CNTRR         : out std_logic; -- Coin Counter logic levels before the open collector transistor outputs
		O_LED1          : out std_logic; -- LEDs Outputs logic levels before the open collector transistor outputs
		O_LED2          : out std_logic; -- LEDs Outputs logic levels before the open collector transistor outputs

		-- 8 position switches to Pokey 1 and 2 parallel port
		I_SW8P1         : in  std_logic_vector(7 downto 0);
		I_SW8P2         : in  std_logic_vector(7 downto 0);

		-- quadrature encoders to LETA
		I_LETA_CLK_ENA  : in  std_logic; -- 156Khz
		I_LETA_CLK      : in  std_logic_vector(3 downto 0);
		I_LETA_DIR      : in  std_logic_vector(3 downto 0);

		-- Stereo Sound Output
		O_AUDIO_L       : out std_logic_vector(15 downto 0) := (others=>'0');
		O_AUDIO_R       : out std_logic_vector(15 downto 0) := (others=>'0')
	);
end AUDIO;

architecture RTL of AUDIO is
	component jt51
	port (
		rst    : in  std_logic;
		clk    : in  std_logic;
		cen    : in  std_logic;
		cen_p1 : in  std_logic;
		cs_n   : in  std_logic;
		wr_n   : in  std_logic;
		a0     : in  std_logic;
		din    : in  std_logic_vector( 7 downto 0);
		dout   : out std_logic_vector( 7 downto 0);
		ct1    : out std_logic;
		ct2    : out std_logic;
		irq_n  : out std_logic;
		sample : out std_logic;
		left   : out std_logic_vector(15 downto 0);
		right  : out std_logic_vector(15 downto 0);
		xleft  : out signed(15 downto 0);
		xright : out signed(15 downto 0)
	);
	end component;

signal
	sl_CLK_14M3,
	sl_CLK_3M6_ENA,
	sl_CLK_1M8_ENA,
	sl_TMS_CLK_ENA,
	sl_TMS_CLK_ENA_last,
	sl_TMS_ENA,
	sl_POKEY1n,
	sl_POKEY2n,
	sl_CNTRL,
	sl_CNTRR,
	sl_3E_Y7,
	sl_PH2B,
	sl_RST6502n,
	sl_LETAn,
	sl_TBRESn,
	sl_156khz,
	sl_R_WBn,
	sl_COINR,
	sl_COINL,
	sl_LED1,
	sl_LED2,
	sl_MIXERn,
	sl_MIXERn_last,
	sl_NMI6502n,
	sl_COINAUX,
	sl_SELFTESTn,
	sl_LEDSn,
	sl_T1DATAn,
	sl_T1DATAn_last,
	sl_T1WRn,
	sl_T1WRENn,
	sl_T1WRENn_last,
	sl_LEDSn_last,
	sl_P2RESETn,
	sl_SPEED,
	sl_SNDRSTn,
	sl_P2INPUTSn,
	sl_TBRES,
	sl_T1RDY,
	sl_P1TALK,
	sl_P2TALK,
	sl_P2PORTWRn,
	sl_P2WRITEn,
	sl_P2IRQn,
	sl_YAMAHAn,
	sl_P2ROM18n,
	sl_P2ROM10n,
	sl_P2ROM8n,
	sl_DECENAn,
	sl_P2MISCn,
	sl_EEROMn,
	sl_P2ZRAM1n,
	sl_P2ZRAM0n,
	sl_POKEY2,
	sl_sync,
	sl_ANMOWRLn,
	sl_COUNTERSn,
	sl_COUNTERSn_last,
	sl_P2PORTRDn,
	sl_P2STROBESn,
	sl_P2IRQCLRn		: std_logic := '1';

signal
	slv_LETA_CLK,
	slv_LETA_DIR,
	slv_ctr_7R			: std_logic_vector( 3 downto 0) := (others=>'0');

signal
	s_PAUD1,
	s_PAUD2				: signed( 5 downto 0) := (others=>'0');

signal
	slv_RAM_1A_DO,
	slv_RAM_1B_DO,
	slv_RAM_1D_DO,
	slv_LETADO,
	slv_T11_DB,
	slv_8F,
	slv_8D,
	slv_SNDROMD,
	slv_YAM_DO,
	slv_RAMDO,
	slv_INPUTS,
	slv_MIXER,
	slv_DATAI,
	slv_DATAO,
	slv_POKEY1D,
	slv_POKEY2D,
	slv_PSW8P1,
	slv_PSW8P2			: std_logic_vector( 7 downto 0) := (others=>'1');

signal
	slv_AUDIO_L,
	slv_AUDIO_R			: std_logic_vector(15 downto 0) := (others=>'1');

signal
	s_TMSAUDIO			: signed(13 downto 0) := (others=>'0');

signal
	slv_SNDROMA 		: std_logic_vector(15 downto 0) := (others=>'0');

signal
	s_CHAN_L,
	s_CHAN_R,
	s_YAMAHA_L,
	s_YAMAHA_R			: signed(15 downto 0) := (others=>'0');

signal
	slv_ADDR			: std_logic_vector(23 downto 0) := (others=>'0');

begin
	O_AUDIO_L       <= slv_AUDIO_L;
	O_AUDIO_R       <= slv_AUDIO_R;

	O_CNTRL         <= sl_CNTRL;
	O_CNTRR         <= sl_CNTRR;
	O_LED1          <= sl_LED1;
	O_LED2          <= sl_LED2;

	sl_P1TALK       <= I_P1TALK;
	sl_P2TALK       <= I_P2TALK;

	slv_PSW8P1      <= I_SW8P1;
	slv_PSW8P2      <= I_SW8P2;
	slv_LETA_CLK    <= I_LETA_CLK;
	slv_LETA_DIR    <= I_LETA_DIR;

	sl_TMS_CLK_ENA  <= I_TMS_CLK_ENA;
	sl_156khz       <= I_LETA_CLK_ENA;
	sl_COINR        <= I_COINR;
	sl_COINL        <= I_COINL;
	sl_COINAUX      <= I_COINAUX;
	sl_SELFTESTn    <= I_SELFTESTn;
	O_SPEED         <= sl_SPEED;
	O_P2IRQCLRn     <= sl_P2IRQCLRn;
	sl_P2IRQn       <= I_P2IRQn;

	slv_SNDROMD     <= I_SNDROMD;
	O_SNDROMA       <= slv_SNDROMA;
	O_P2PORTWRn     <= sl_P2PORTWRn;
	O_P2PORTRDn     <= sl_P2PORTRDn;

	sl_P2RESETn     <= I_P2RESETn;
	sl_RST6502n     <= I_RST6502n;

	sl_CLK_14M3     <= I_CLK_14M3;
	O_6502_DB       <= slv_DATAO;
	slv_T11_DB      <= I_T11_DB;

-------- Sheet 6B --------

	-- Clock and Control Signals
	sl_P2WRITEn <= not (sl_CLK_1M8_ENA and not sl_R_WBn); -- 3H

	-- 3F is in MAIN as it needs 10Mhz clock

	p_edges : process
	begin
		wait until rising_edge(sl_CLK_14M3);
		sl_TMS_CLK_ENA_last <= sl_TMS_CLK_ENA;
		sl_COUNTERSn_last   <= sl_COUNTERSn;
		sl_T1DATAn_last     <= sl_T1DATAn;
		sl_T1WRENn_last     <= sl_T1WRENn;
		sl_MIXERn_last      <= sl_MIXERn;
		sl_LEDSn_last       <= sl_LEDSn;
	end process;

	-- non resettable counter, generates 3.6MHz and 1.8MHz clock strobes from 14.3M clock
	p_7R : process
	begin
		wait until rising_edge(sl_CLK_14M3);
		slv_ctr_7R <= slv_ctr_7R + 1;
	end process;

	-- Clock Enables
	sl_CLK_1M8_ENA <= slv_ctr_7R(2) and slv_ctr_7R(1) and slv_ctr_7R(0);
	sl_CLK_3M6_ENA <= slv_ctr_7R(1) and slv_ctr_7R(0);

-------- Sheet 7A --------

	sl_NMI6502n <= not sl_P1TALK; -- 2DE
	sl_PH2B <= slv_ctr_7R(2); -- 1.8Mhz

	-- 6502 Microprocessor
	u_5B : entity work.T65
	port map (
		MODE    => "00",             -- "00" => 6502, "01" => 65C02, "10" => 65C816
		Enable  => sl_CLK_1M8_ENA,   -- clock enable to run at 1.8MHz

		CLK     => sl_CLK_14M3,      -- in, system clock
		IRQ_n   => sl_P2IRQn,        -- in, active low irq
		NMI_n   => sl_NMI6502n,      -- in, active low nmi
		RES_n   => sl_RST6502n,      -- in, active low reset
		RDY     => '1',              -- in, ready
		SO_n    => '1',              -- in, set overflow
		DI      => slv_DATAI,        -- in, data 8-bit

		A       => slv_ADDR,         -- out, address 16-bit
		DO      => slv_DATAO,        -- out, data 8-bit
		R_W_n   => sl_R_WBn,         -- out, read /write
		SYNC    => sl_sync           -- out, sync
	);

	-- 5D 6D
	slv_DATAI <=
		slv_SNDROMD   when (sl_P2ROM8n and sl_P2ROM10n and sl_P2ROM18n) = '0' else
		slv_RAM_1A_DO when sl_P2ZRAM0n  = '0' else
		slv_RAM_1B_DO when sl_P2ZRAM1n  = '0' else
		slv_RAM_1D_DO when sl_EEROMn    = '0' else
		slv_INPUTS    when sl_P2INPUTSn = '0' else
		slv_YAM_DO    when sl_YAMAHAn   = '0' else
		slv_POKEY1D   when sl_POKEY1n   = '0' else
		slv_POKEY2D   when sl_POKEY2n   = '0' else
		slv_LETADO    when sl_LETAn     = '0' else
		slv_T11_DB    when sl_P2PORTRDn = '0' else
		(others=>'0');

	-- Address Decoding 4E
	sl_P2STROBESn <= sl_P2MISCn or (not slv_ADDR(6)) or (not slv_ADDR(5)) or (not slv_ADDR(4)); -- 1870-187F aliased TMS, MIXER, MISC
	sl_P2PORTRDn  <= sl_P2MISCn or (not slv_ADDR(6)) or (not slv_ADDR(5)) or (    slv_ADDR(4)) or (not sl_PH2B); -- 4E 1E  -- 1860-186F aliased Sound Command
	sl_YAMAHAn    <= sl_P2MISCn or (not slv_ADDR(6)) or (    slv_ADDR(5)) or (not slv_ADDR(4)) or (not sl_PH2B); -- 4E 1E  -- 1850-185F aliased YM2151
	sl_P2INPUTSn  <= sl_P2MISCn or (not slv_ADDR(6)) or (    slv_ADDR(5)) or (    slv_ADDR(4)); -- 1840-184F aliased INPUTS
	sl_POKEY2     <= sl_P2MISCn or (    slv_ADDR(6)) or (not slv_ADDR(5)) or (not slv_ADDR(4)); -- 1830-183F aliased POKEY2
--	sl_UNUSED     <= sl_P2MISCn or (    slv_ADDR(6)) or (not slv_ADDR(5)) or (    slv_ADDR(4)); -- 1820-182F aliased UNUSED
	sl_LETAn      <= sl_P2MISCn or (    slv_ADDR(6)) or (    slv_ADDR(5)) or (not slv_ADDR(4)); -- 1810-181F aliased LETA
	sl_POKEY1n    <= sl_P2MISCn or (    slv_ADDR(6)) or (    slv_ADDR(5)) or (    slv_ADDR(4)); -- 1800-180F aliased POKEY1

	-- Program Memory

	-- these ROMs moved outside this module
	slv_SNDROMA <= slv_ADDR(15 downto 0);

	-- Zero Page RAM and EEROM
	RAM_1A : entity work.RAM_2K8   port map (I_CLK => sl_CLK_14M3, I_CEn => sl_P2ZRAM0n, I_WEn => sl_P2WRITEn, I_ADDR => slv_ADDR(10 downto 0), I_DATA => slv_DATAO, O_DATA => slv_RAM_1A_DO);
	RAM_1B : entity work.RAM_2K8   port map (I_CLK => sl_CLK_14M3, I_CEn => sl_P2ZRAM1n, I_WEn => sl_P2WRITEn, I_ADDR => slv_ADDR(10 downto 0), I_DATA => slv_DATAO, O_DATA => slv_RAM_1B_DO);

	-- FIXME this should be nonvolatile and maybe external
	EEROM_1D : entity work.RAM_2K8 port map (I_CLK => sl_CLK_14M3, I_CEn => sl_EEROMn, I_WEn => sl_P2WRITEn, I_ADDR => slv_ADDR(10 downto 0), I_DATA => slv_DATAO, O_DATA => slv_RAM_1D_DO);

-------- Sheet 7B --------

	-- A/D Converter in is MAIN module because it's addressed by the T-11

	-- Coin Counters
	p_7H : process
	begin
		wait until rising_edge(sl_CLK_14M3);
		if sl_P2RESETn = '0' then
			sl_CNTRR <= '0'; -- logic levels before the open collector transistor outputs
			sl_CNTRL <= '0'; -- logic levels before the open collector transistor outputs
		elsif sl_COUNTERSn_last = '0' and sl_COUNTERSn = '1' then
			sl_CNTRR <= slv_DATAO(0);
			sl_CNTRL <= slv_DATAO(1);
		end if;
	end process;

	-- LED Drivers
	p_5F1 : process
	begin
		wait until rising_edge(sl_CLK_14M3);
		if sl_P2RESETn = '0' then
			sl_LED1 <= '0'; -- logic levels before the open collector transistor outputs
			sl_LED2 <= '0'; -- logic levels before the open collector transistor outputs
		elsif sl_LEDSn_last = '0' and sl_LEDSn = '1' then
			sl_LED1 <= slv_DATAO(2);
			sl_LED2 <= slv_DATAO(3);
		end if;
	end process;

	-- Address Decoding 4BC
	sl_P2ROM18n <= (not slv_ADDR(15)) or (not slv_ADDR(14)); -- C000-FFFF
	sl_P2ROM10n <= (not slv_ADDR(15)) or (    slv_ADDR(14)); -- 8000-BFFF
	sl_P2ROM8n  <= (    slv_ADDR(15)) or (not slv_ADDR(14)); -- 4000-7FFF
	sl_DECENAn  <= (    slv_ADDR(15)) or (    slv_ADDR(14)); -- 0000-3FFF

	sl_P2MISCn  <= (not slv_ADDR(12)) or (not slv_ADDR(11)) or sl_DECENAn; -- 1800-1FFF
	sl_EEROMn   <= (not slv_ADDR(12)) or (    slv_ADDR(11)) or sl_DECENAn; -- 1000-17FF
	sl_P2ZRAM1n <= (    slv_ADDR(12)) or (not slv_ADDR(11)) or sl_DECENAn; -- 0800-0FFF
	sl_P2ZRAM0n <= (    slv_ADDR(12)) or (    slv_ADDR(11)) or sl_DECENAn; -- 0000-07FF

	-- Address Decoding 3E
	sl_3E_Y7     <= sl_PH2B or sl_P2WRITEn or sl_P2STROBESn or (not slv_ADDR(3)) or (not slv_ADDR(2)) or (not slv_ADDR(1)); -- 187E aliased Sound enable
	sl_LEDSn     <= sl_PH2B or sl_P2WRITEn or sl_P2STROBESn or (not slv_ADDR(3)) or (not slv_ADDR(2)) or (    slv_ADDR(1)); -- 187C aliased Misc control bits
	sl_MIXERn    <= sl_PH2B or sl_P2WRITEn or sl_P2STROBESn or (not slv_ADDR(3)) or (    slv_ADDR(2)) or (not slv_ADDR(1)); -- 187A aliased Mixer control
	sl_P2IRQCLRn <= sl_PH2B or sl_P2WRITEn or sl_P2STROBESn or (not slv_ADDR(3)) or (    slv_ADDR(2)) or (    slv_ADDR(1)); -- 1878 aliased Interrupt acknowledge
	sl_COUNTERSn <= sl_PH2B or sl_P2WRITEn or sl_P2STROBESn or (    slv_ADDR(3)) or (not slv_ADDR(2)) or (not slv_ADDR(1)); -- 1876 aliased Coin counters
	sl_P2PORTWRn <= sl_PH2B or sl_P2WRITEn or sl_P2STROBESn or (    slv_ADDR(3)) or (not slv_ADDR(2)) or (    slv_ADDR(1)); -- 1874 aliased Sound response write
	sl_T1WRENn   <= sl_PH2B or sl_P2WRITEn or sl_P2STROBESn or (    slv_ADDR(3)) or (    slv_ADDR(2)) or (not slv_ADDR(1)); -- 1872 aliased TMS5220 data strobe
	sl_T1DATAn   <= sl_PH2B or sl_P2WRITEn or sl_P2STROBESn or (    slv_ADDR(3)) or (    slv_ADDR(2)) or (    slv_ADDR(1)); -- 1870 aliased TMS Data Latch

	p_4H2 : process
	begin
		wait until rising_edge(sl_CLK_14M3);
		if sl_P2RESETn = '0' then
			sl_SNDRSTn <= '1';
		elsif sl_3E_Y7 = '0' then
			-- memory mapped to x187E
			sl_SNDRSTn <= slv_DATAO(0);
		end if;
	end process;

-------- Sheet 8A --------
	-- Coin Door and Status Inputs
	slv_INPUTS <= sl_COINR & sl_COINL & sl_COINAUX & sl_SELFTESTn & '0' & sl_T1RDY & sl_P2TALK & sl_P1TALK; -- 8F

	-- Speech
	p_8D : process
	begin
		wait until rising_edge(sl_CLK_14M3);
		if sl_SNDRSTn = '0' then
			slv_8D <= (others=>'0');
		elsif sl_T1DATAn_last = '0' and sl_T1DATAn = '1' then
			slv_8D <= slv_DATAO;
		end if;
	end process;

	p_TMS_clk : process
	begin
		wait until rising_edge(sl_CLK_14M3);
		if sl_TMS_CLK_ENA_last = '0' and sl_TMS_CLK_ENA = '1' then
			sl_TMS_ENA <= '1';
		else
			sl_TMS_ENA <= '0';
		end if;
	end process;

	-- Speech Chip
	u_14E : entity work.TMS5220
	port map (
		I_OSC    => sl_CLK_14M3, -- FIXME clk ena is based on a 10Mhz clock but here we run at 14M3, check pulse widths
		I_ENA    => sl_TMS_ENA, -- selectable clock enable at 625Khz or 833Khz
		I_WSn    => sl_T1WRn, -- schematic shows the WS and OSC pins unconnected but common sense must prevail
		I_RSn    => '1',
		I_DATA   => '1',
		I_TEST   => '1',
		I_DBUS   => slv_8D,

		O_DBUS   => open,
		O_RDYn   => sl_T1RDY,
		O_INTn   => open,

		O_M0     => open,
		O_M1     => open,
		O_ADD8   => open,
		O_ADD4   => open,
		O_ADD2   => open,
		O_ADD1   => open,
		O_ROMCLK => open,

		O_T11    => open,
		O_IO     => open,
		O_PRMOUT => open,
		O_SPKR   => s_TMSAUDIO -- signed 14 bit output
	);

	p_4CD : process
	begin
		wait until rising_edge(sl_CLK_14M3);
		if sl_SNDRSTn = '0' then
			sl_T1WRn <= '1';
		elsif sl_T1WRENn_last = '0' and sl_T1WRENn = '1' then
			sl_T1WRn <= slv_DATAO(0);
		end if;
	end process;

	-- 2DE seems to reset the TMS5220 by disconnecting its negative supply TVSS, no need to do anything here
	-- 11M generates the T1CLK with positive to negative voltage swing

	-- 4D 4CD are in MAIN as they need 10MHz clock

	-- Music

	-- Mixer does 3-bit volume control of TMS and YM audio sources through LF13201 analog switches
	p_8C : process
	begin
		wait until rising_edge(sl_CLK_14M3);
		if sl_SNDRSTn = '0' then
			slv_MIXER <= (others=>'0');
		elsif sl_MIXERn_last = '0' and sl_MIXERn = '1' then
			slv_MIXER <= slv_DATAO;
		end if;
	end process;

	-- YM2151 sound
	u_15R : jt51
	port map(
		-- inputs
		rst      => sl_SNDRSTn,
		clk      => sl_CLK_14M3,
		cen      => sl_CLK_3M6_ENA, -- seemingly unused by jt51 internally
		cen_p1   => sl_CLK_1M8_ENA,
		cs_n     => sl_YAMAHAn,
		wr_n     => sl_R_WBn,
		a0       => slv_ADDR(0),
		din      => slv_DATAO,

		-- outputs
		dout     => slv_YAM_DO,
		irq_n    => open,

		ct1      => open,
		ct2      => open,

		--	 Low resolution outputs (same as real chip)
		sample   => open,
		left     => open,
		right    => open,

		--	 signed 16 bit outputs
		xleft    => s_YAMAHA_L,
		xright   => s_YAMAHA_R
	);

-------- Sheet 8B --------

	-- Sound Effects Option Switches
	u_7B : entity work.POKEY
	port map (
		CLK       => sl_CLK_14M3,
		ADDR      => slv_ADDR(3 downto 0),
		DIN       => slv_DATAO,
		DOUT      => slv_POKEY1D,
		DOUT_OE_L => open,
		CS        => '1',
		CS_L      => sl_POKEY1n,
		RW_L      => sl_R_WBn,

		PIN       => slv_PSW8P1,
		ENA       => sl_CLK_1M8_ENA, -- phi2

		AUDIO_OUT => s_PAUD1
	);

	u_6B : entity work.POKEY
	port map (
		CLK       => sl_CLK_14M3,
		ADDR      => slv_ADDR(3 downto 0),
		DIN       => slv_DATAO,
		DOUT      => slv_POKEY2D,
		DOUT_OE_L => open,
		CS        => '1',
		CS_L      => sl_POKEY2n,
		RW_L      => sl_R_WBn,

		PIN       => slv_PSW8P2,
		ENA       => sl_CLK_1M8_ENA, -- phi2

		AUDIO_OUT => s_PAUD2
	);

-- Steering Wheel Inputs
	p_5F2 : process
	begin
		wait until rising_edge(sl_CLK_14M3);
		if sl_P2RESETn = '0' then
			sl_TBRES <= '1';
		elsif sl_LEDSn_last = '0' and sl_LEDSn = '1' then
			sl_TBRES <= slv_addr(4);
			sl_SPEED <= slv_addr(5); -- 5F on sheet 8A
		end if;
	end process;

	p_LETA	: entity work.LETA_REP
	port map (
		clk     => sl_CLK_14M3,
		ck      => I_LETA_CLK_ENA, -- 156KHz
		resoln  => sl_TBRESn,
		cs      => sl_LETAn,
		ad      => slv_ADDR(1 downto 0),
		clks    => slv_LETA_CLK,
		dirs    => slv_LETA_DIR,
		db      => slv_LETADO,
		test    => '0'
	);

	-- Audio Output Drivers

	-- FIXME mixer and (not yet implemented) volume control for all sound sources based on slv_MIXER
	-- The mixer uses LF13201 "normally closed" analog switches to implement a 3-bit DAC control of the volume
	-- Control input logical 0 leaves the switch closed, input of logical 1 opens the switch
	-- MIXER7,6,5 controls TMS output             (DAC volume divider is 100K input with 22K on MIX7, 47K on MIX6 and 100K on MIX5)
	-- MIXER4,3   controls POKEY outputs          (DAC volume divider is 100K input with 47K on MIX4 and 100K on MIX3)
	-- MIXER2,1,0 control both L and R YM outputs (DAC volume divider is 100K input with 22K on MIX2, 47K on MIX1 and 100K on MIX0)
	p_volmix : process
	begin
		wait until rising_edge(sl_CLK_14M3);
		if sl_CLK_1M8_ENA = '1' then
			-- add signed outputs together
			s_CHAN_L <= ( ((s_TMSAUDIO & "00") + s_YAMAHA_L) + (s_PAUD1(s_PAUD1'left) & s_PAUD1 & "000000000") );
			s_CHAN_R <= ( ((s_TMSAUDIO & "00") + s_YAMAHA_R) + (s_PAUD2(s_PAUD2'left) & s_PAUD2 & "000000000") );
	-- 16 bit signed     14 bit signed        16 bit signed                        6 bit signed

			-- convert to unsigned slv for DAC usage
			slv_AUDIO_L <= std_logic_vector(s_CHAN_L + 16383);
			slv_AUDIO_R <= std_logic_vector(s_CHAN_R + 16383);
		end if;
	end process;

-- print out cpu instruction fetch address for debugging
-- synthesis translate_off
	p_DBG : process
		type myfile is file of integer;
		file		ofile			: TEXT open WRITE_MODE is "6502.log";
		variable	s				: line;
	begin
		wait until rising_edge(sl_CLK_14M3);
		if (sl_CLK_1M8_ENA and sl_sync) = '1' then
			HWRITE(s,slv_ADDR(15 downto 0));
			WRITE(s, string'(" ## "));
			HWRITE(s,slv_DATAI);
			WRITE(s, string'(" ## ")); WRITE(s, now);
			WRITELINE(ofile, s);
		end if;
	end process;
-- synthesis translate_on
end RTL;
