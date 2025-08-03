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
-- Atari System-2 Main CPU circuit, all chip designations are based on SP-308 schematic

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
-- synthesis translate_off
	use ieee.std_logic_textio.all;
	use std.textio.all;
-- synthesis translate_on

entity MAIN is
	port(
		I_SLAP_TYPE      : in  integer range 100 to 118; -- slapstic type can be changed dynamically
		I_CLK            : in  std_logic; -- 20MHz
		I_PWRONRST       : in  std_logic; -- Power On Reset active high
		I_SELFTESTn      : in  std_logic; -- Places board in Self Test mode when low
		I_SW             : in  std_logic_vector( 6 downto 1);
		I_WDISn          : in  std_logic; -- Watchdog disable active low
		I_SPEED          : in  std_logic; -- TMS clock speed selector 0=625Khz 1=833Khz
		O_TMS_CLK_ENA    : out std_logic; -- TMS clock enable selectable 625Khz or 833Khz
		O_LETA_CLK_ENA   : out std_logic; -- LETA clock enable 156Khz

		-- external ROMs
		O_ROM_ADDR       : out std_logic_vector(15 downto 1);
		I_ROM_DATA       : in  std_logic_vector(15 downto 0);

		-- External ADC
		O_ADC_ADDR       : out std_logic_vector( 2 downto 0);
		I_ADC_DATA       : in  std_logic_vector( 7 downto 0);

		-- Inter-processor data bus and comms signalling
		O_P1TALK         : out std_logic;
		O_P2TALK         : out std_logic;

		I_P2PORTRDn      : in  std_logic;
		I_P2PORTWRn      : in  std_logic;

		O_P2RESETn       : out std_logic; -- 6502 misc reset
		O_RST6502n       : out std_logic; -- 6502 CPU reset
		O_P2IRQn         : out std_logic;
		I_P2IRQCLRn      : in  std_logic;

		I_6502_DB        : in  std_logic_vector( 7 downto 0); -- 6502 to T-11
		O_T11_DB         : out std_logic_vector( 7 downto 0); -- T-11 to 6502

		-- Video Board Connector P18
		O_VMP0           : out std_logic;
		O_VMP1           : out std_logic;
		O_R_WLn          : out std_logic;
		O_MEMREQn        : out std_logic;
		O_COLORAMn       : out std_logic;
		O_VSCROLLn       : out std_logic;
		O_HSCROLLn       : out std_logic;
		O_COUT           : out std_logic;
		O_MEMDONE        : out std_logic;

		-- Video address and data bus
		O_VPA            : out std_logic_vector(12 downto 1);
		O_VPD            : out std_logic_vector(15 downto 0);
		I_VPD            : in  std_logic_vector(15 downto 0);

		-- Video outbound control signals
		I_VIDMEMACKn     : in  std_logic;
		I_VBLANK         : in  std_logic;
		I_32V            : in  std_logic;
		I_STANDALONE     : in  std_logic := '1' -- has a pullup here but shorted to GND on video board
	);
end MAIN;

architecture RTL of MAIN is
signal
	sl_STANDALONEn,
	sl_2M1Qn,
	sl_2M2Qn,
	sl_32Vn,
	sl_32Vn_last,
	sl_3L_Qn,
	sl_3N1Qn,
	sl_3N2Qn,
	sl_ADCSTARTn,
	sl_ADCn,
	sl_BCLRn,
	sl_CASn,
	sl_CASn_last,
	sl_COLORAMn,
	sl_CONTROLSn,
	sl_HALTn,
	sl_HSCROLLn,
	sl_MEMREQn,
	sl_MIENn,
	sl_MISCn,
	sl_P1IRQ0CLRn,
	sl_P1IRQ2CLRn,
	sl_P1IRQ3CLRn,
	sl_P1IRQCLRn,
	sl_P1IRQENn,
	sl_P1IRQENn_last,
	sl_P1PORTRDn,
	sl_P1PORTRDn_last,
	sl_P1PORTWRn,
	sl_P1PORTWRn_last,
	sl_P2IRQCLRn,
	sl_P2IRQCLRn_last,
	sl_P2IRQn,
	sl_P2PORTRDn,
	sl_P2PORTRDn_last,
	sl_P2PORTWRn,
	sl_P2PORTWRn_last,
	sl_P2RESETn,
	sl_P2RESETn_last,
	sl_PAGEDMEMn,
	sl_PFAILn,
	sl_PMMUn,
	sl_PORn,
	sl_RASn,
	sl_RASn_last,
	sl_RST6502n,
	sl_R_WHn,
	sl_R_WLn,
	sl_SLAPSTICn,
	sl_SRAMCEn,
	sl_VIDMEMACKn,
	sl_VIDMEMACKn_last,
	sl_VIDMEMn,
	sl_VSCROLLn,
	sl_P1TALK,
	sl_P2TALK,
	sl_WDCLRn		: std_logic := '1';
signal
	sl_3MY1,
	sl_CLK,
	sl_CLK_ENA,
	sl_CPU_ENA,
	sl_COUT,
	sl_SPEED,
	sl_P1IRQ0EN,
	sl_P1IRQ1EN,
	sl_P1IRQ2EN,
	sl_P1IRQ3EN,
	sl_RESET,
	sl_TMS_CLK_ENA,
	sl_VBLANK,
	sl_VBLANK_last,
	sl_VMP0,
	sl_VMP1,
	sl_MEMDONE			: std_logic := '0';
signal
	slv_SEL_last,
	slv_SEL				: std_logic_vector( 1 downto 0) := (others=>'0');
signal
	slv_ADC_ADDR
						: std_logic_vector( 2 downto 0) := (others=>'0');
signal
	slv_ctr_3F,
	slv_ctr_4D			: std_logic_vector( 3 downto 0) := (others=>'0');
signal
	slv_PAD,
	slv_PAD0,
	slv_PAD1			: std_logic_vector( 5 downto 0) := (others=>'0');
signal
	slv_6502_DATA,
	slv_T11_DBO,
	slv_6502_DBI,
	slv_AII				: std_logic_vector( 7 downto 0) := (others=>'0');
signal
	slv_ROMADDR			: std_logic_vector(13 downto 0) := (others=>'0');
signal
	slv_LA				: std_logic_vector(15 downto 1) := (others=>'0');
signal
	slv_CTRL,
	slv_MID,
	slv_ROM_DI,
	slv_RAM_DO,
	slv_DALI,
	slv_DALO			: std_logic_vector(15 downto 0) := (others=>'0');
signal
	slv_RWD_ctr			: std_logic_vector(19 downto 0) := (others=>'0');
begin
	sl_STANDALONEn <= not I_STANDALONE; -- transistor Q6 inverts signal
	sl_CLK         <= I_CLK;
	O_P2RESETn     <= sl_P2RESETn;
	O_RST6502n     <= sl_RST6502n;
	sl_P2PORTRDn   <= I_P2PORTRDn;
	sl_P2PORTWRn   <= I_P2PORTWRn;

	O_TMS_CLK_ENA  <= sl_TMS_CLK_ENA;
	sl_SPEED       <= I_SPEED;
	sl_P2IRQCLRn   <= I_P2IRQCLRn;
	O_P1TALK       <= sl_P1TALK;
	O_P2TALK       <= sl_P2TALK;
	O_LETA_CLK_ENA <= slv_RWD_ctr(5);
	O_P2IRQn       <= sl_P2IRQn;
	O_T11_DB       <= slv_T11_DBO;
	slv_6502_DBI   <= I_6502_DB;
	O_ADC_ADDR <= slv_ADC_ADDR;
	sl_PORn        <= not I_PWRONRST; -- Power On Reset

	-- edge detectors
	p_edgedetect : process
	begin
		wait until rising_edge(sl_CLK);
		sl_32Vn_last       <= sl_32Vn;
		sl_CASn_last       <= sl_CASn;
		sl_RASn_last       <= sl_RASn;
		sl_VBLANK_last     <= sl_VBLANK;
		sl_P1IRQENn_last   <= sl_P1IRQENn;
		sl_P1PORTRDn_last  <= sl_P1PORTRDn;
		sl_P1PORTWRn_last  <= sl_P1PORTWRn;
		sl_P2PORTRDn_last  <= sl_P2PORTRDn;
		sl_P2PORTWRn_last  <= sl_P2PORTWRn;
		sl_P2IRQCLRn_last  <= sl_P2IRQCLRn;
		sl_P2RESETn_last   <= sl_P2RESETn;
		sl_VIDMEMACKn_last <= sl_VIDMEMACKn;
	end process;

-------- Sheet 4B --------

	-- T-11 clock enable
	sl_CPU_ENA <= sl_CLK_ENA and not sl_3L_Qn; -- 1R (CPU enable is active high so we invert the Qn used as a clock gate)

	-- Generate 10Mhz clock enable from 20Mhz clock
	p_clk10M : process
	begin
		wait until rising_edge(sl_CLK);
		sl_CLK_ENA <= not sl_CLK_ENA; -- 3P
	end process;

	-- Clock Stretching
	p_3L : process
	begin
		wait until rising_edge(sl_CLK);
		if sl_CLK_ENA = '1' then
			sl_3L_Qn <= not (sl_MEMREQn or sl_MEMDONE); -- 1R
		end if;
	end process;

	p_3P : process
	begin
		wait until rising_edge(sl_CLK);
		if (sl_RASn = '1' or sl_BCLRn = '0') then
			sl_MEMDONE <= '0';
		elsif (sl_STANDALONEn = '0') or (sl_VIDMEMACKn_last = '0' and sl_VIDMEMACKn = '1') then
			sl_MEMDONE <= '1';
		end if;
	end process;

	-- Interrupt Logic
	p_3N1 : process
	begin
		wait until rising_edge(sl_CLK);
		if sl_P1IRQ3CLRn = '0' then
			sl_3N1Qn <= '1';
		elsif (sl_VBLANK_last = '0') and (sl_VBLANK = '1') then
			sl_3N1Qn <= not sl_P1IRQ3EN;
		end if;
	end process;

	p_2M1 : process
	begin
		wait until rising_edge(sl_CLK);
		if sl_P1IRQ2CLRn = '0' then
			sl_2M1Qn <= '1';
		elsif (sl_32Vn_last = '0') and (sl_32Vn = '1') then
			sl_2M1Qn <= not sl_P1IRQ2EN;
		end if;
	end process;

	p_2M2 : process
	begin
		wait until rising_edge(sl_CLK);
		if sl_P1PORTRDn = '0' then
			sl_2M2Qn <= '1';
		elsif (sl_P2PORTWRn_last = '0') and (sl_P2PORTWRn = '1') then
			sl_2M2Qn <= not sl_P1IRQ1EN;
		end if;
	end process;

	p_3N2 : process
	begin
		wait until rising_edge(sl_CLK);
		if sl_P1IRQ0CLRn = '0' then
			sl_3N2Qn <= '1';
		elsif (sl_P2PORTRDn_last = '0') and (sl_P2PORTRDn = '1') then
			sl_3N2Qn <= not sl_P1IRQ0EN;
		end if;
	end process;

	p_2L : process
	begin
		wait until rising_edge(sl_CLK);
		if (sl_CASn_last = '1' and sl_CASn = '0') then
			slv_AII <= (sl_HALTn, sl_PFAILn, '1', sl_3N2Qn, sl_2M2Qn, sl_2M1Qn, sl_3N1Qn, '1');
		end if;
	end process;

	p_5N : process
	begin
		wait until rising_edge(sl_CLK);
		if sl_BCLRn = '0' then
			sl_P1IRQ3EN <= '0';
			sl_P1IRQ2EN <= '0';
			sl_P1IRQ1EN <= '0';
			sl_P1IRQ0EN <= '0';
		elsif sl_P1IRQENn_last = '0' and sl_P1IRQENn = '1' then
			sl_P1IRQ3EN <= slv_DALO(3);
			sl_P1IRQ2EN <= slv_DALO(2);
			sl_P1IRQ1EN <= slv_DALO(1);
			sl_P1IRQ0EN <= slv_DALO(0);
		end if;
	end process;

	-- T-11 Microprocessor and Address Latches
	p_4K_5M : process
	begin
		wait until rising_edge(sl_CLK);
--		if (sl_RASn_last = '1' and sl_RASn = '0') then -- latch addr on falling /RAS
		if (sl_RASn = '1') then
			slv_LA <= slv_DALO(15 downto 1); -- holds last address when RAS goes low
		end if;
	end process;

	-- Processor Input Data Bus Multiplexer
	slv_DALI <=
		slv_ROM_DI            when (sl_SLAPSTICn and sl_PAGEDMEMn) = '0' else -- ROM Data Bus Transceivers from 4N 5H sheet 5B
		slv_RAM_DO            when sl_SRAMCEn                      = '0' else -- RAM Data Bus Transceivers from 4N 5H sheet 5B
		slv_CTRL              when sl_CONTROLSn                    = '0' else -- Control Panel Input Buffers 2F, 5F sheet 6A
		x"00" & slv_6502_DATA when sl_P1PORTRDn                    = '0' else -- 6502 Microprocessor Comms Latches 6E, 5E sheet 6A
		x"00" & I_ADC_DATA    when sl_ADCn                         = '0' else -- ADC Converter Buffer 4P sheet 7B
		x"36FF"               when sl_BCLRn                        = '0' else -- Mode Register as per chip 2F sheet 4B ("0011 0110 1111 1111")
		I_VPD                 when sl_VIDMEMn                      = '0' else -- Video Transceivers 1K 1J sheet 6B
		(others=>'0');

	-- T-11 Microprocessor
	u_cpu : entity work.T11                   -- pins 8, 20 GND, 40 VCC
	port map (
		pin_ad_in   => slv_DALI,              -- in  DAL bus (pins 1-7, 9-17 with pullups when BCLRn active)
		pin_ad_out  => slv_DALO,              -- out DAL bus (pins 1-7, 9-17)
		pin_bclr_n  => sl_BCLRn,              -- out bus clear (pin 18)
		pin_dclo    => sl_RESET,              -- in  power-up/reset active high (pin 19)

		pin_cout    => sl_COUT,               -- out COUT clock output (pin 21)
		clk_ena     => sl_CPU_ENA,            -- in  CPU clock enable
		pin_clk_p   => sl_CLK,                -- in  processor clock (pin 22)
		pin_clk_n   => '0',                   -- in  processor clock (pin 23 tied low)
		pin_sel     => slv_SEL,               -- out select flag (pins 24, 25)
		pin_ready   => '1',                   -- in  bus ready (pin 26 tied high)

		pin_wb_n(1) => sl_R_WHn,              -- out read/write high byte (pin 27)
		pin_wb_n(0) => sl_R_WLn,              -- out read/write low  byte (pin 28)
		pin_ras_n   => sl_RASn,               -- out RASn (pin 29)
		pin_cas_n   => sl_CASn,               -- out CASn (pin 30)
		pin_pi      => open,                  -- out priority in strobe (pin 31, unused)
		pin_ai      => slv_AII                -- in  coded interrupt priority (pin 32,33,34,35,36,37,38,39)
	);

-------- Sheet 5A --------

	-- Address Decoders

	-- 5L
	sl_PAGEDMEMn <= sl_CASn or slv_LA(15) or not slv_LA(14)                  ; -- 4000-7FFF Processor ROM region
	sl_MEMREQn   <= sl_CASn or slv_LA(15) or     slv_LA(14) or not slv_LA(13); -- 2000-3FFF Video RAM region (Banked)
	sl_MISCn     <= sl_CASn or slv_LA(15) or     slv_LA(14) or     slv_LA(13); -- 0000-1FFF Local RAM and MISC I/O region

	-- 3M
	sl_P1PORTRDn <= sl_MISCn or sl_CASn or not sl_R_WLn or not slv_LA(12) or not slv_LA(11) or not slv_LA(10); -- 1C00-1FFF read  (Sound Response)
	sl_CONTROLSn <= sl_MISCn or sl_CASn or not sl_R_WLn or not slv_LA(12) or not slv_LA(11) or     slv_LA(10); -- 1800-1BFF read  (Switch Inputs)
	sl_ADCn      <= sl_MISCn or sl_CASn or not sl_R_WLn or not slv_LA(12) or     slv_LA(11) or not slv_LA(10); -- 1400-17FF read  (ADC)
	--           <= sl_MISCn or sl_CASn or not sl_R_WLn or not slv_LA(12) or     slv_LA(11) or     slv_LA(10); -- 1000-13FF read  (Unused)
	--           <= sl_MISCn or sl_CASn or     sl_R_WLn or not slv_LA(12) or not slv_LA(11) or not slv_LA(10); -- 1C00-1FFF write (Unused)
	sl_WDCLRn    <= sl_MISCn or sl_CASn or     sl_R_WLn or not slv_LA(12) or not slv_LA(11) or     slv_LA(10); -- 1800-1BFF write (Watchdog Reset)
	sl_3MY1      <= sl_MISCn or sl_CASn or     sl_R_WLn or not slv_LA(12) or     slv_LA(11) or not slv_LA(10); -- 1400-17FF write (ROM bank selects and Memory Mapped Registers)
	sl_COLORAMn  <= sl_MISCn or sl_CASn or     sl_R_WLn or not slv_LA(12) or     slv_LA(11) or     slv_LA(10); -- 1000-13FF write (Palette RAM)

	-- 4L
	sl_VSCROLLn  <= sl_3MY1 or sl_CASn or not slv_LA(9) or not slv_LA(8) or not slv_LA(7); -- 1780-17FF V Scroll register
	sl_HSCROLLn  <= sl_3MY1 or sl_CASn or not slv_LA(9) or not slv_LA(8) or     slv_LA(7); -- 1700-177F H Scroll Register
	sl_P1PORTWRn <= sl_3MY1 or sl_CASn or not slv_LA(9) or     slv_LA(8) or not slv_LA(7); -- 1680-16FF Processor 1 Data Write Signal
	sl_P1IRQENn  <= sl_3MY1 or sl_CASn or not slv_LA(9) or     slv_LA(8) or     slv_LA(7); -- 1600-167F Processor 1 IRQ Enables
	sl_P1IRQCLRn <= sl_3MY1 or sl_CASn or     slv_LA(9) or not slv_LA(8) or not slv_LA(7); -- 1580-15FF Processor 1 IRQ Clear
	--           <= sl_3MY1 or sl_CASn or     slv_LA(9) or not slv_LA(8) or     slv_LA(7); -- 1500-157F Unused
	sl_ADCSTARTn <= sl_3MY1 or sl_CASn or     slv_LA(9) or     slv_LA(8) or not slv_LA(7); -- 1480-14FF ADC Start Conversion
	sl_PMMUn     <= sl_3MY1 or sl_CASn or     slv_LA(9) or     slv_LA(8) or     slv_LA(7); -- 1400-147F Bank Selects

	-- 3J
	sl_P1IRQ3CLRn <= sl_P1IRQCLRn or not slv_LA(6) or not slv_LA(5); -- 15E0-15FF VBLANK IRQ reset
	sl_P1IRQ2CLRn <= sl_P1IRQCLRn or not slv_LA(6) or     slv_LA(5); -- 15C0-15DF 32V IRQ reset
	sl_P2RESETn   <= sl_P1IRQCLRn or     slv_LA(6) or not slv_LA(5); -- 15A0-15BF Sound CPU reset
	sl_P1IRQ0CLRn <= sl_P1IRQCLRn or     slv_LA(6) or     slv_LA(5); -- 1580-159F Sound command read IRQ reset

	sl_VIDMEMn <= sl_MEMREQn and sl_COLORAMn and sl_VSCROLLn and sl_HSCROLLn; -- 2P 5K

	-- SLAPSTIC
	p_4M : entity work.SLAPSTIC
	port map (
		I_SLAP_TYPE => I_SLAP_TYPE,
		I_CK        => sl_CLK,
		I_ASn       => sl_CASn,
		I_CSn       => sl_SLAPSTICn,
		I_A         => slv_LA(14 downto 1),
		O_BS(1)     => sl_VMP1,
		O_BS(0)     => sl_VMP0
	);

	-- Used In Development Only
	-- PAD decoder circuit 11B 11C/D not implemented

	-- 6502 Microprocessor Communication Flags
	p_4J : process
	begin
		wait until rising_edge(sl_CLK);
		if (sl_P2PORTRDn_last = '0') and (sl_P2PORTRDn = '1') then
			sl_P1TALK <= '0';
		elsif sl_P1PORTWRn_last = '0' and sl_P1PORTWRn = '1' then
			sl_P1TALK <= '1';
		end if;

		if (sl_P1PORTRDn_last = '0') and (sl_P1PORTRDn = '1') then
			sl_P2TALK <= '0';
		elsif sl_P2PORTWRn_last = '0' and sl_P2PORTWRn = '1' then
			sl_P2TALK <= '1';
		end if;
	end process;

-------- Sheet 5B --------

	-- Paged Program ROM

	-- ROMs moved outside this module
	-- decoder 5L sheet 5B unused here
	slv_ROM_DI <= I_ROM_DATA;
	-- when LA15 is set send SLAPSTIC ROM address, else send PAGED ADDRESS
	O_ROM_ADDR <= slv_LA(15 downto 1) when sl_SLAPSTICn = '0' else slv_LA(15) & slv_PAD(5 downto 4) & slv_LA(12 downto 1);

	-- 2N 2P Paged Address Read
	slv_PAD <= slv_PAD0 when slv_LA(13) = '0' else slv_PAD1;

	-- 2N 2P Paged Address Write
	p_2N_2P : process
	begin
		wait until rising_edge(sl_CLK);
		if sl_PMMUn = '0' then
			if SLV_LA(1) = '0' then
				slv_PAD0 <= slv_DALO(15 downto 10);
			else
				slv_PAD1 <= slv_DALO(15 downto 10);
			end if;
		end if;
	end process;

	slv_MID <= slv_DALO when sl_MIENn = '0' and (sl_R_WHn = '0' or sl_R_WLn = '0') else (others=>'0'); -- 4N 5H

	-- Reset and Watchdog Clear

	-- 20-bit counter chain dividing the 10MHz clock down
	p_8B_4F_3K : process
	begin
		wait until rising_edge(sl_CLK);
		if sl_CLK_ENA = '1' then
			if (sl_PORn and sl_WDCLRn) = '0' then
				slv_RWD_ctr(7 downto 0) <= (others=>'0');
			else
				-- slv_RWD_ctr( 0) is 5.00 MHz
				-- slv_RWD_ctr( 1) is 2.50 MHz
				-- slv_RWD_ctr( 2) is 1.25 MHz
				-- slv_RWD_ctr( 3) is 625.000 Khz
				-- slv_RWD_ctr( 4) is 312.500 Khz
				-- slv_RWD_ctr( 5) is 156.250 KHz
				-- slv_RWD_ctr(11) is 2441 Hz
				-- slv_RWD_ctr(19) is  9.5 Hz <- watchdog timout
				slv_RWD_ctr <= slv_RWD_ctr + 1;
			end if;
		end if;
	end process;

	-- Generates a RESET pulse on Watchdog timeout (1/9.5Hz = 105ms)
	p_5J_3L : process
	begin
		wait until rising_edge(sl_CLK);
		sl_RESET <= not sl_PORn; -- FIXME for simulation debugging only, speeds up reset
--		if sl_PORn = '0' then
--			sl_RESET <= '1';
--		elsif slv_RWD_ctr(19) = '1' then
--			sl_RESET <= (not sl_RESET) and I_WDISn;
--		end if;
	end process;

-------- Sheet 6A --------

	-- Fixed Program ROM
	
	-- ROMs moved outside this module

	sl_SLAPSTICn <= sl_CASn or not slv_LA(15); -- 3H

	-- Zero-Page RAM
	RAM_7P : entity work.RAM_2K8 port map (I_CLK => sl_CLK, I_CEn => sl_SRAMCEn, I_WEn => sl_R_WHn, I_ADDR => slv_LA(11 downto 1), I_DATA => slv_MID(15 downto 8), O_DATA => slv_RAM_DO(15 downto 8) );
	RAM_7K : entity work.RAM_2K8 port map (I_CLK => sl_CLK, I_CEn => sl_SRAMCEn, I_WEn => sl_R_WLn, I_ADDR => slv_LA(11 downto 1), I_DATA => slv_MID( 7 downto 0), O_DATA => slv_RAM_DO( 7 downto 0) );

	sl_SRAMCEn <= sl_MISCn or slv_LA(12); -- 1L
	sl_MIENn <= sl_SRAMCEn and sl_SLAPSTICn and sl_PAGEDMEMn; -- 7J 5K

	-- 6502 Microprocessor Communication Latches
	p_6E_5E : process
	begin
		wait until rising_edge(sl_CLK);
		if sl_P2PORTWRn_last = '0' and sl_P2PORTWRn = '1' then
			slv_6502_DATA <= slv_6502_DBI; -- 6E
		end if;
		if sl_P1PORTWRn_last = '0' and sl_P1PORTWRn = '1' then
			slv_T11_DBO <= slv_DALO(7 downto 0); -- 5E
		end if;
	end process;

	-- Control Panel inputs
	slv_CTRL <= I_SELFTESTn & "1111111" & I_SW(1) & I_SW(2) & sl_P1TALK & sl_P2TALK & I_SW(3) & I_SW(4) & I_SW(5) & I_SW(6); -- 2F 5P

-------- Sheet 6B --------

	-- 1M 1N 1P 1K 1J buffers/transceivers
	O_R_WLn       <= sl_R_WLn;
	O_MEMREQn     <= sl_MEMREQn;
	O_COLORAMn    <= sl_COLORAMn;
	O_VSCROLLn    <= sl_VSCROLLn;
	O_HSCROLLn    <= sl_HSCROLLn;
	O_COUT        <= sl_COUT;
	O_MEMDONE     <= sl_MEMDONE;
	O_VPA         <= slv_LA(12 downto 1);
	O_VPD         <= slv_DALO when sl_VIDMEMn = '0' and sl_R_WLn = '0' else (others=>'0');
	O_VMP0        <= sl_VMP0;
	O_VMP1        <= sl_VMP1;
	sl_VIDMEMACKn <= I_VIDMEMACKn;
	sl_VBLANK     <= I_VBLANK;
	sl_32Vn       <= I_32V;

	-- resettable counter, generates IRQ
	p_3F : process
	begin
		wait until rising_edge(sl_CLK);
		if sl_CLK_ENA = '1' then
			if sl_P2IRQCLRn_last = '1' and sl_P2IRQCLRn = '0' then
				slv_ctr_3F <= (others => '0');
			elsif slv_RWD_ctr = x"00FFF" then -- 10M/4096 = 2441 Hz clock enable
				slv_ctr_3F <= slv_ctr_3F + 1;
			end if;
		end if;
	end process;

	sl_P2IRQn   <= not (slv_ctr_3F(3) and slv_ctr_3F(1)); -- 3F 3H

-------- Sheet 7A --------

	p_4H1 : process
	begin
		wait until rising_edge(sl_CLK);
		if sl_RESET = '1' then
			sl_RST6502n <= '0';
		elsif sl_P2RESETn_last = '0' and sl_P2RESETn = '1' then
			sl_RST6502n <= slv_DALO(0);
		end if;
	end process;

-------- Sheet 7B --------

	-- A/D Converter
	-- ADC0809 data already comes to us digitised so here we just latch which input we want
	p_1S : process
	begin
		wait until rising_edge(sl_CLK);
		if sl_ADCSTARTn = '0' then
			slv_ADC_ADDR <= slv_LA(3 downto 1);
		end if;
	end process;

-------- Sheet 8A --------

	-- counter generates 625KHz when sl_SPEED is 0 else 833.3KHz
	p_4D_4CD : process
	begin
		wait until rising_edge(sl_CLK);
		if sl_CLK_ENA = '1' then
			if slv_ctr_4D = "1111" then
				sl_TMS_CLK_ENA <= '1';
				-- preset to "0000" (10M/16) or "0100" (10M/12) depending on SPEED
				slv_ctr_4D <= '0' & sl_SPEED & "00";
			else
				sl_TMS_CLK_ENA <= '0';
				slv_ctr_4D <= slv_ctr_4D + 1;
			end if;
		end if;
	end process;

-- print out cpu instruction fetch address for debugging
-- synthesis translate_off
	p_DBG : process
		type myfile is file of integer;
		file		ofile			: TEXT open WRITE_MODE is "T11.log";
		variable	s				: line;
	begin
		wait until rising_edge(sl_CLK);
		slv_SEL_last <= slv_SEL;
		if slv_SEL_last = "01" and slv_SEL = "00" then
			HWRITE(s, "000" & slv_DALO(15));
			HWRITE(s,   '0' & slv_DALO(14 downto 12));
			HWRITE(s,   '0' & slv_DALO(11 downto  9));
			HWRITE(s,   '0' & slv_DALO( 8 downto  6));
			HWRITE(s,   '0' & slv_DALO( 5 downto  3));
			HWRITE(s,   '0' & slv_DALO( 2 downto  0));
			WRITE(s, string'(" ## ")); WRITE(s, now);
			WRITELINE(ofile, s);
		end if;
	end process;
-- synthesis translate_on
end RTL;
