-- (c) 2025 d18c7db(a)hotmail
--
-- This program is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License version 3 or, at your option,
-- any later version as published by the Free Software Foundation.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
--
-- For full details, see the GNU General Public License at www.gnu.org/licenses
-- Atari System-2 Video circuit, based on SP-308 schematic

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
-- synthesis translate_off
	use ieee.std_logic_textio.all;
	use std.textio.all;
-- synthesis translate_on
entity VIDEO is
	port(
		I_CLK            : in  std_logic; -- 16MHz

		-- Interboard connector P18 start

		-- Video inbound control signals
		I_VMP0           : in  std_logic;
		I_VMP1           : in  std_logic;
		I_R_WLn          : in  std_logic;
		I_MEMREQn        : in  std_logic;
		I_COLORAMn       : in  std_logic;
		I_VSCROLLn       : in  std_logic;
		I_HSCROLLn       : in  std_logic;
		I_COUT           : in  std_logic;
		I_MEMDONE        : in  std_logic;

		-- Video address and data bus
		I_VPA            : in  std_logic_vector(12 downto 1);
		I_VPD            : in  std_logic_vector(15 downto 0);
		O_VPD            : out std_logic_vector(15 downto 0);

		-- Video outbound control signals
		O_VPACKn         : out std_logic; -- VIDMEMACKn
		O_384VD4Hn       : out std_logic; -- VBLANK
		O_32VDD4Hn       : out std_logic; -- 32V
		O_STANDALONEn    : out std_logic; -- Pulled low on this board

		-- Interboard connector P18 end

		-- Video ROMs
		O_ANROMA         : out std_logic_vector(15 downto 0);
		I_ANROMD         : in  std_logic_vector( 7 downto 0); -- in order 7S 7T (ANPIX 1 0)
		O_MOROMA         : out std_logic_vector(19 downto 0);
		I_MOROMD         : in  std_logic_vector(15 downto 0); -- in order 7HJ 7J 7M 7M (MOPIX 3 2 1 0)
		O_PFROMA         : out std_logic_vector(17 downto 0);
		I_PFROMD         : in  std_logic_vector(15 downto 0); -- in order 8A 8B 8BC 8CD (PFPIX 3 2 1 0)

		-- Video picture and signals output
		O_VIDEO_I        : out std_logic_vector(3 downto 0);
		O_VIDEO_R        : out std_logic_vector(3 downto 0);
		O_VIDEO_G        : out std_logic_vector(3 downto 0);
		O_VIDEO_B        : out std_logic_vector(3 downto 0);
		O_COMPSYNCn      : out std_logic;
		O_HSYNC          : out std_logic;
		O_VSYNC          : out std_logic
	);
end VIDEO;

architecture RTL of VIDEO is
signal sl_STANDALONEn : std_logic := '0'; -- tied low on video processor board

signal
	sl_0OF3Vn,
	sl_1OF3Vn,
	sl_2OF3Vn,
	sl_32VD4Hn,
	sl_32VDD4Hn,
	sl_384VD4Hn,
	sl_5CD_3CD_4DE_LDENn,
	sl_ANMORAMn,
	sl_ANMORDHn,
	sl_ANMORDLn,
	sl_ANMOREQn,
	sl_ANMOWRHn,
	sl_ANMOWRLn,
	sl_BLANKn,
	sl_BONDn,
	sl_BONn,
	sl_BYTELDn,
	sl_COLORAMn,
	sl_CRAMENn,
	sl_FIRSTWORDn,
	sl_GONDn,
	sl_GONn,
	sl_HSCROLLn,
	sl_HSLDn,
	sl_HSYNCn,
	sl_MEMREQn,
	sl_MOHLD0n,
	sl_MOHLD1n,
	sl_MOHLD2n,
	sl_MOHR0n,
	sl_MOHR1n,
	sl_MOHR2n,
	sl_MOVMATCHn,
	sl_PFRAMn,
	sl_PFRDn,
	sl_PFREQn,
	sl_PFWRITEn,
	sl_PFWRn,
	sl_PF_ANMOn,
	sl_RONDn,
	sl_RONn,
	sl_VPACKCLRn,
	sl_VPACKn,
	sl_VP_R_Wn,
	sl_VRESETn,
	sl_VSCROLLn,
	sl_WORDn,
	sl_ZONDn,
	sl_ZONn
	: std_logic := '1';

signal
	sl_1H,
	sl_2H,
	sl_4H,
	sl_8H,
	sl_16H,
	sl_32H,
	sl_64H,
	sl_128H,
	sl_256H,
	sl_512H,
	sl_1V,
	sl_2V,
	sl_4V,
	sl_8V,
	sl_16V,
	sl_32V,
	sl_64V,
	sl_128V,
	sl_256V,
	sl_2H_strobe,
	sl_4H_strobe,
	sl_8H_strobe,
	sl_16H_strobe,
	sl_32H_strobe,
	sl_512H_strobe,
	sl_4Hn_strobe,
	sl_8Hn_strobe,
	sl_13A_Q,
	sl_2T,
	sl_32VDD4H,
	sl_384V,
	sl_4H8H,
	sl_4Hn_8H_CLK,
	sl_4Hn_8Hn_CLK,
	sl_512HD16H,
	sl_512HD4H,
	sl_8HD4H,
	sl_ANCOL0,
	sl_ANCOL0D,
	sl_ANCOL1,
	sl_ANCOL1D,
	sl_ANCOL2,
	sl_ANCOL2D,
	sl_ANPIX0,
	sl_ANPIX0D,
	sl_ANPIX1,
	sl_ANPIX1D,
	sl_BLNKCLK,
	sl_COUT,
	sl_HRIPPLE,
	sl_HSPERIOD,
	sl_HSTC,
	sl_HSYNCn_last,
	sl_LBCOL0,
	sl_LBCOL1,
	sl_LBPIX0,
	sl_LBPIX1,
	sl_LBPIX2,
	sl_LBPIX3,
	sl_LBPRI0,
	sl_LBPRI1,
	sl_MEMDONE,
	sl_MOCOL0,
	sl_MOCOL1,
	sl_MOHFLIP,
	sl_MOHFLIPD,
	sl_MOHLDIS,
	sl_MOPRI0,
	sl_MOPRI1,
	sl_NIBLOAD,
	sl_PFCOL0D,
	sl_PFCOL1D,
	sl_PFCOL2D,
	sl_PFPIX0D,
	sl_PFPIX1D,
	sl_PFPIX2D,
	sl_PFPIX3D,
	sl_PFPRI0D,
	sl_PFPRI1D,
	sl_VMP0,
	sl_VMP1,
	sl_VPULSE,
	sl_VSYNC
	: std_logic := '0';
signal
	slv_PFP,
	slv_PFPRIO,
	slv_PRI_sel,
	slv_8J_sel          : std_logic_vector( 1 downto 0) := (others=>'0');
signal
	slv_MOSIZ,
	slv_2DE,
	slv_PFC,
	slv_PFCOL,
	slv_ANC,
	slv_8J_reg          : std_logic_vector( 2 downto 0) := "110";
signal
	slv_10CD,
	slv_7HJ,
	slv_7J,
	slv_7K,
	slv_7L,
	slv_7M,
	slv_7N,
	slv_7P,
	slv_7R,
	slv_7S,
	slv_7T,
	slv_8A,
	slv_8B,
	slv_8BC,
	slv_8CD,
	slv_PFBS,
	slv_PFB0,
	slv_PFB1,
--	slv_PFROMSELn,
	slv_PROM_4MN_DATA,
	slv_R, slv_G, slv_B,
	slv_Z        : std_logic_vector( 3 downto 0) := (others=>'0');
signal
	slv_MOLBO,
	slv_12H,
	slv_12J,
	slv_CRA,
	slv_10J_Q,
	slv_PRIO_LOGIC,
	slv_ANROMD,
--	slv_MOROMOEn,
	slv_MOLB0_DO,
	slv_MOLB1_DO,
	slv_MOLB2_DO,
	slv_LLA             : std_logic_vector( 7 downto 0) := (others=>'0');
signal
	slv_PROM_4MN_ADDR,
	slv_sum_4J_4K,
	slv_VSx,
	slv_xVS,
	slv_MOV             : std_logic_vector( 8 downto 0) := (others=>'0');
signal
	slv_V_ctr           : std_logic_vector( 8 downto 0) := (others=>'0');
signal
	slv_H_ctr           : std_logic_vector( 9 downto 0) := (others=>'0'); -- resets at "1001111111" x27F 639
signal
	slv_HSx,
	slv_xHS,
	slv_MOPIC           : std_logic_vector(10 downto 0) := (others=>'0');
signal
	slv_ANMOA           : std_logic_vector(10 downto 0) := (others=>'0');
signal
	slv_PFA             : std_logic_vector(12 downto 0) := (others=>'0');
signal
	slv_VPA             : std_logic_vector(12 downto 1) := (others=>'0');
signal
	slv_PFROMA          : std_logic_vector(14 downto 0) := (others=>'0');
signal
	slv_1K_2BC,
	slv_2P_1N,
	slv_2R_2S,
	slv_3P_3T,
	slv_3R_4R_S,
	slv_ANROMA,
	slv_CRD,
	slv_MOROMD,
	slv_PFROMD,
	slv_PFDI,
	slv_PFDO,
	slv_VPDI,
	slv_VPDO            : std_logic_vector(15 downto 0) := (others=>'0');
signal
	slv_MOROMA          : std_logic_vector(19 downto 0) := (others=>'0');
signal
	slv_ANMOD           : std_logic_vector(31 downto 0) := (others=>'0');

	type PROM_ARRAY is array (0 to 511) of std_logic_vector(3 downto 0);
	signal PROM_4MN : PROM_ARRAY := ((others=>(others=>'1'))); -- FIXME put contents of PROM here
begin
	O_VPD         <= slv_VPDO;
	O_STANDALONEn <= sl_STANDALONEn;
	O_VPACKn      <= sl_VPACKn;
	O_384VD4Hn    <= sl_384VD4Hn;
	O_32VDD4Hn    <= sl_32VDD4Hn;

	-- AlphaNumeric  ROMs
	O_ANROMA      <= (not slv_ANROMA(15 downto 14)) & slv_ANROMA(13 downto 4) & sl_4V & sl_2V & sl_1V & (not sl_4H);
	slv_ANROMD    <= I_ANROMD;

	-- Motion object ROMs
	O_MOROMA      <= slv_MOROMA;
	slv_MOROMD    <= I_MOROMD;

	-- Play Field ROMs
	O_PFROMA      <=  slv_PFBS(2 downto 1) & ( not slv_PFBS(3)) & slv_PFBS(0) & slv_PFROMA(13 downto 4) & slv_xVS(2 downto 0) & (not sl_4H);
	slv_PFROMD    <= I_PFROMD;

	sl_VMP0       <= I_VMP0;
	sl_VMP1       <= I_VMP1;
	sl_VP_R_Wn    <= I_R_WLn;
	sl_MEMREQn    <= I_MEMREQn;
	sl_COLORAMn   <= I_COLORAMn;
	sl_VSCROLLn   <= I_VSCROLLn;
	sl_HSCROLLn   <= I_HSCROLLn;
	sl_COUT       <= I_COUT;
	sl_MEMDONE    <= I_MEMDONE;
	slv_VPA       <= I_VPA;
	slv_VPDI      <= I_VPD;

-------- Sheet 9B --------

	p_2K : process
	begin
		wait until rising_edge(I_CLK);
		if sl_VPACKCLRn = '0' then
			sl_PFRAMn <= '1';
		elsif sl_4H_strobe = '1' then
			sl_PFRAMn <= sl_PFREQn or sl_MEMDONE;
		end if;
	end process;

	-- 7FH
	sl_VPACKn <= sl_PFRAMn and sl_ANMORAMn;

	p_4EF_1 : process
	begin
		wait until falling_edge(I_CLK);
		if sl_VPACKCLRn = '0' then
			sl_ANMORAMn <= '1';
		elsif sl_4Hn_8Hn_CLK = '0' then
			sl_ANMORAMn <= sl_ANMOREQn or sl_MEMDONE;
		end if;
	end process;

	p_4EF_2 : process
	begin
		wait until rising_edge(I_CLK);
		sl_VPACKCLRn <= (not sl_1H) or (not sl_2H) or sl_VPACKn;
	end process;

	sl_ANMOREQn <= sl_MEMREQn or     sl_VMP1; -- AN MO memory select
	sl_PFREQn   <= sl_MEMREQn or not sl_VMP1; -- PF memory select

-------- Sheet 10A --------

	-- Video Clock
	-- 9K clock buffer and distribution not required here

	-- Sync Chain and Timing Strobes

	-- Horizontal counter 8H resets from 9 to 0 because it is a DECADE counter
	-- this generates 16Mhz/640 = 25000 Hz Hsync and NOT the more common 15625 Hz
	-- V counter then counts 0...416 and is reset by /VRESET which generates 25000/417 = 59.95 Hz Vsync
	sl_HRIPPLE <= '1' when slv_H_ctr = "1001111111" else '0';

	-- Vertical and Horizontal counter chain 13B 11BC 8D 8H 8E 6EF 5A
	p_V_H_ctr : process
	begin
		wait until rising_edge(I_CLK);
		slv_H_ctr <= slv_H_ctr + 1;
		if sl_HRIPPLE = '1' then
			slv_H_ctr <= (others=>'0');
			if sl_VRESETn = '0' then 
				-- Vertical counter reset
				slv_V_ctr <= (others=>'0');
			else
				slv_V_ctr <= slv_V_ctr + 1;
			end if;
		end if;
	end process;

	sl_512H <= slv_H_ctr(9);	--
	sl_256H <= slv_H_ctr(8);	sl_256V <= slv_V_ctr(8);
	sl_128H <= slv_H_ctr(7);	sl_128V <= slv_V_ctr(7);
	sl_64H  <= slv_H_ctr(6);	sl_64V  <= slv_V_ctr(6);
	sl_32H  <= slv_H_ctr(5);	sl_32V  <= slv_V_ctr(5);
	sl_16H  <= slv_H_ctr(4);	sl_16V  <= slv_V_ctr(4);
	sl_8H   <= slv_H_ctr(3);	sl_8V   <= slv_V_ctr(3);
	sl_4H   <= slv_H_ctr(2);	sl_4V   <= slv_V_ctr(2);
	sl_2H   <= slv_H_ctr(1);	sl_2V   <= slv_V_ctr(1);
	sl_1H   <= slv_H_ctr(0);	sl_1V   <= slv_V_ctr(0);

	-- for when we need to trigger on the exact rising or falling edge of a signal
	-- strobes must only be active for one I_CLK cycle
	sl_2H_strobe   <= '1' when slv_H_ctr(1 downto 0) =         "01" else '0';
	sl_4H_strobe   <= '1' when slv_H_ctr(2 downto 0) =        "011" else '0';
	sl_4Hn_strobe  <= '1' when slv_H_ctr(2 downto 0) =        "111" else '0';
	sl_8H_strobe   <= '1' when slv_H_ctr(3 downto 0) =       "0111" else '0';
	sl_8Hn_strobe  <= '1' when slv_H_ctr(3 downto 0) =       "1111" else '0';
	sl_16H_strobe  <= '1' when slv_H_ctr(4 downto 0) =      "01111" else '0';
	sl_32H_strobe  <= '1' when slv_H_ctr(5 downto 0) =     "011111" else '0';
	sl_512H_strobe <= '1' when slv_H_ctr(9 downto 0) = "0111111111" else '0';

	sl_NIBLOAD     <= sl_1H   and sl_2H  ; -- 11D NIBLOAD*A and NIBLOAD*B are the same exact signal
	sl_4H8H        <= sl_4H   and sl_8H  ; -- 11D
	sl_BLNKCLK     <= not ((not sl_1H) and sl_2H); -- 12B also gated by /CLK
	sl_384V        <= sl_128V and sl_256V; -- 5BC

--	sl_4Hn_8Hn_CLK <= not (sl_NIBLOAD and (not sl_4H) and (not sl_8H)); -- 12D also gated by /CLK FIXME ORIGINAL, see below change
	sl_4Hn_8H_CLK  <= not (sl_NIBLOAD and (not sl_4H) and (    sl_8H)); -- 11M also gated by /CLK
	sl_4Hn_8Hn_CLK <= not (sl_NIBLOAD and (    sl_4H) and (not sl_8H)); -- T11 to ANMO RAM writes occur too early, this delays the /WE signal
	sl_WORDn       <= not (sl_NIBLOAD and (    sl_4H) and (    sl_8H)); -- 11CD

	sl_FIRSTWORDn  <= not (sl_NIBLOAD and (    sl_4H) and (    sl_8H) and (not sl_512H) and sl_512HD16H); -- 12D
	sl_BYTELDn     <= not (sl_NIBLOAD and (    sl_4H)  ); -- 10BC
	sl_VRESETn     <= not (sl_32V and sl_384V); -- 7EF
	sl_HSLDn       <= not (sl_64H and sl_512H); -- 7EF
	sl_VPULSE      <= (sl_4V) and (not sl_8V) and (not sl_16V); -- 5BC
	sl_2T          <= sl_WORDn or sl_MOHLDIS; -- 2T
	sl_MOHLD2n     <= sl_2T or sl_1OF3Vn; -- 11R
	sl_MOHLD1n     <= sl_2T or sl_0OF3Vn; -- 11R
	sl_MOHLD0n     <= sl_2T or sl_2OF3Vn; -- 11T
	sl_MOHR0n      <= sl_FIRSTWORDn or (sl_0OF3Vn and sl_1OF3Vn); -- I15 11T
	sl_MOHR1n      <= sl_FIRSTWORDn or (sl_1OF3Vn and sl_2OF3Vn); -- I15 11T
	sl_MOHR2n      <= sl_FIRSTWORDn or (sl_0OF3Vn and sl_2OF3Vn); -- I15 11T
	slv_8J_sel     <= (sl_1H and sl_HRIPPLE and (not sl_VRESETn)) & (sl_1H and sl_HRIPPLE); -- 5FH 7FH
	sl_2OF3Vn      <= slv_8J_reg(2);
	sl_1OF3Vn      <= slv_8J_reg(1);
	sl_0OF3Vn      <= slv_8J_reg(0);

	p_8F : process
	begin
		wait until rising_edge(I_CLK);
		if sl_512H = '0' then
			sl_HSYNCn <= '1';
		elsif sl_32H_strobe = '1' then
			sl_HSYNCn <= sl_64H;
		end if;

		if sl_384V = '0' then 
			sl_VSYNC <= '0';
		elsif sl_32H_strobe = '1' then
			sl_VSYNC <= sl_VPULSE;
		end if;
	end process;

	p_8J : process
	begin
		wait until rising_edge(I_CLK);
		case(slv_8J_sel) is
			-- hold
			when "00" => null;
			-- shift up
			when "01" => slv_8J_reg <= slv_8J_reg(1 downto 0) & sl_2OF3Vn;
			-- shift down
			when "10" => slv_8J_reg <= '1' & slv_8J_reg(2 downto 1);
			-- load
			when "11" => slv_8J_reg <= "110";
			-- all other cases
			when others => null;
		end case;
	end process;

	p_1T : process
	begin
		wait until rising_edge(I_CLK);
		if sl_4H_strobe = '1' then
			sl_8HD4H <= sl_8H;
		end if;
	end process;

	p_12CD_1 : process
	begin
		wait until rising_edge(I_CLK);
		if sl_4H_strobe = '1' then
			sl_512HD4H <= sl_512H;
		end if;
	end process;

	p_12CD_2 : process
	begin
		wait until rising_edge(I_CLK);
		if sl_16H_strobe = '1' then
			sl_512HD16H <= sl_512H;
		end if;
	end process;

-------- Sheet 10B --------

	-- Alphanumeric/Motion Object RAM

	-- 2B 2FH 2EF 2N 2H 2M
	slv_ANMOA <=
		"11" & slv_LLA & '0'                          when sl_8H = '0' and sl_4H = '0' else -- 00 -> in0 Linked List Address with lsb=0
		slv_VPA(12 downto 2)                          when sl_8H = '0' and sl_4H = '1' else -- 01 -> in1 T11 address for read/write ANMO RAM
		slv_V_ctr(8 downto 3) & slv_H_ctr(8 downto 4) when sl_8H = '1' and sl_4H = '0' else -- 10 -> in2 Address from H/V counters
		"11" & slv_LLA & '1'                          when sl_8H = '1' and sl_4H = '1' else -- 11 -> in3 Linked List Address with lsb=1
		(others=>'0');

	RAM_3H : entity work.RAM_2K8 port map (I_CLK => I_CLK, I_CEn => '0', I_WEn => sl_ANMOWRLn, I_ADDR => slv_ANMOA, I_DATA => slv_VPDI( 7 downto  0), O_DATA => slv_ANMOD( 7 downto  0) );
	RAM_3K : entity work.RAM_2K8 port map (I_CLK => I_CLK, I_CEn => '0', I_WEn => sl_ANMOWRLn, I_ADDR => slv_ANMOA, I_DATA => slv_VPDI(15 downto  8), O_DATA => slv_ANMOD(15 downto  8) );
	RAM_3L : entity work.RAM_2K8 port map (I_CLK => I_CLK, I_CEn => '0', I_WEn => sl_ANMOWRHn, I_ADDR => slv_ANMOA, I_DATA => slv_VPDI( 7 downto  0), O_DATA => slv_ANMOD(23 downto 16) );
	RAM_3M : entity work.RAM_2K8 port map (I_CLK => I_CLK, I_CEn => '0', I_WEn => sl_ANMOWRHn, I_ADDR => slv_ANMOA, I_DATA => slv_VPDI(15 downto  8), O_DATA => slv_ANMOD(31 downto 24) );

	-- 1M 1P 1R 1S buffers integrated into RAMs above

	p_2P_1N_2R_2S : process
	begin
		wait until rising_edge(I_CLK);
		if sl_8H_strobe = '1' then
			slv_2P_1N <= slv_ANMOD(15 downto  0);
			slv_2R_2S <= slv_ANMOD(31 downto 16);
		end if;
	end process;

	-- 2L
	sl_ANMORDHn <= sl_ANMOREQn or not (sl_ANMORAMn or sl_VP_R_Wn) or not slv_VPA(1);
	sl_ANMORDLn <= sl_ANMOREQn or not (sl_ANMORAMn or sl_VP_R_Wn) or     slv_VPA(1);
	sl_ANMOWRHn <= sl_ANMOREQn or     (sl_ANMORAMn or sl_VP_R_Wn) or not slv_VPA(1) or (not sl_2H); -- 2T
	sl_ANMOWRLn <= sl_ANMOREQn or     (sl_ANMORAMn or sl_VP_R_Wn) or     slv_VPA(1) or (not sl_2H); -- 2T

-------- Sheet 11A --------

	-- Motion Object ROM Addressing

	-- 4KL 3S 4PR 2DE
	p_4KL_3S_4PR_2DE : process
	begin
		wait until falling_edge(I_CLK);
		if sl_4Hn_8Hn_CLK = '0' then
			sl_MOHLDIS   <= slv_ANMOD(31);
			sl_MOHFLIP   <= slv_ANMOD(30);
			slv_MOSIZ(2) <= slv_ANMOD(29); -- 2DE
			slv_MOSIZ(1) <= slv_ANMOD(28);
			slv_MOSIZ(0) <= slv_ANMOD(27);
			slv_MOPIC    <= slv_ANMOD(26 downto 16);
			slv_MOV      <= slv_ANMOD(14 downto  6);
			slv_2DE      <= slv_ANMOD( 2 downto  0); -- 2DE
		end if;
	end process;

	p_3N : process
	begin
		wait until rising_edge(I_CLK);
		if sl_8Hn_strobe = '1' then
			sl_MOPRI1 <= slv_ANMOD(31);
			sl_MOPRI0 <= slv_ANMOD(30);
			sl_MOCOL1 <= slv_ANMOD(29);
			sl_MOCOL0 <= slv_ANMOD(28);
		end if;
	end process;

	-- Adders 4J 4K and gate 11R
	slv_sum_4J_4K <= slv_MOV(8 downto 1) + (slv_V_ctr(8 downto 1) + (x"00" & (sl_1V or slv_MOV(0))) );

	-- PROM 4M7N 82S131, output affects sl_MOVMATCHn and MOROMA(8 downto 6)
	slv_PROM_4MN_ADDR <= slv_MOSIZ(2 downto 0) & slv_sum_4J_4K(5 downto 3) & slv_MOPIC(2 downto 0);
	slv_PROM_4MN_DATA <= PROM_4MN(to_integer(unsigned(slv_PROM_4MN_ADDR)));

	p_4NP_4M_2K : process
	begin
		wait until falling_edge(I_CLK);
		if sl_4Hn_8H_CLK = '0' then
			sl_MOVMATCHn <= not (slv_sum_4J_4K(7) and slv_sum_4J_4K(6) and slv_PROM_4MN_DATA(3) and not sl_384V);
			sl_MOHFLIPD <= sl_MOHFLIP;
			slv_MOROMA(16 downto 2) <= slv_MOPIC(10 downto 3) & slv_PROM_4MN_DATA(2 downto 0) & slv_sum_4J_4K(2 downto 0) & (slv_MOV(0) xor (not sl_1V)); -- 11P
		end if;
	end process;

	slv_MOROMA(1) <= sl_MOHFLIPD xor (not sl_8HD4H); -- 11P
	slv_MOROMA(0) <= sl_MOHFLIPD xor (not    sl_4H); -- 11P

	p_2J : process
	begin
		wait until falling_edge(I_CLK);
		if sl_4Hn_8H_CLK = '0' then
			slv_MOROMA(19 downto 17) <= slv_2DE;
		end if;
	end process;

	-- 6F ROM selectors (unused here)
--	slv_MOROMOEn(7) <= (not slv_MOROMA(18)) or (not slv_MOROMA(16)) or (not slv_MOROMA(15));
--	slv_MOROMOEn(6) <= (not slv_MOROMA(18)) or (not slv_MOROMA(16)) or (    slv_MOROMA(15));
--	slv_MOROMOEn(5) <= (not slv_MOROMA(18)) or (    slv_MOROMA(16)) or (not slv_MOROMA(15));
--	slv_MOROMOEn(4) <= (not slv_MOROMA(18)) or (    slv_MOROMA(16)) or (    slv_MOROMA(15));
--	slv_MOROMOEn(3) <= (    slv_MOROMA(18)) or (not slv_MOROMA(16)) or (not slv_MOROMA(15));
--	slv_MOROMOEn(2) <= (    slv_MOROMA(18)) or (not slv_MOROMA(16)) or (    slv_MOROMA(15));
--	slv_MOROMOEn(1) <= (    slv_MOROMA(18)) or (    slv_MOROMA(16)) or (not slv_MOROMA(15));
--	slv_MOROMOEn(0) <= (    slv_MOROMA(18)) or (    slv_MOROMA(16)) or (    slv_MOROMA(15));

	-- Link List Address Latch
	p_4H : process
	begin
		wait until rising_edge(I_CLK);
		if (sl_512HD4H and (not sl_512H)) = '1' then -- 11CD
			slv_LLA <= (others=>'0');
		elsif sl_8Hn_strobe = '1' then
			slv_LLA <= slv_ANMOD(26 downto 19);
		end if;
	end process;

-------- Sheet 11B --------

	-- Alphanumeric ROM Addressing
	p_3P_3T_3R_4RS : process
	begin
		wait until falling_edge(I_CLK);
		if sl_4Hn_8H_CLK = '0' then
			slv_3P_3T   <= slv_ANMOD(15 downto  0);
			slv_3R_4R_S <= slv_ANMOD(31 downto 16);
		end if;
	end process;

	-- 3P 3T vs 3R 4RS Output Control
	slv_ANC(2 downto 0)     <=        slv_3R_4R_S(15 downto 13) when sl_8HD4H = '0' else slv_3P_3T(15 downto 13);
	slv_ANROMA(15 downto 4) <= "00" & slv_3R_4R_S( 9 downto  0) when sl_8HD4H = '0' else slv_3P_3T(11 downto  0);  -- FIXME only slv_3R_4R_S(9 downto 0) connected in schema

	-- Playfield Data Latch
	sl_PFWRn    <= sl_PFRAMn or (    sl_VP_R_Wn); -- 2CD
	sl_PFRDn    <= sl_PFREQn or (not sl_VP_R_Wn); -- 2CD
	sl_PFWRITEn <= sl_PFWRn  or (not sl_2H     ); -- 2CD

	-- Playfield Bank Select
	slv_PFBS <= slv_PFB0 when slv_PFROMA(14) = '0' else slv_PFB1;

	p_3A : process
	begin
		wait until rising_edge(I_CLK);
		if sl_4Hn_strobe = '1' then
			sl_32VDD4Hn <= sl_32VD4Hn;
			sl_32VD4Hn  <= sl_32V;
			sl_384VD4Hn <= sl_384V;
			slv_PFCOL( 2 downto 0) <= slv_PFC(2 downto 0);
			slv_PFPRIO(1 downto 0) <= slv_PFP(1 downto 0);
		end if;
	end process;


-------- Sheet 12A --------
	-- output data bus muxer
	slv_VPDO <=
		slv_2R_2S  when sl_ANMORDHn = '0' else -- from 2R 2S
		slv_2P_1N  when sl_ANMORDLn = '0' else -- from 2P 1N
		slv_1K_2BC when sl_PFRDn    = '0' else -- from 1K 2BC
		(others=>'0');

	-- Playfield RAM Addressing
	-- 5BC 67EF 11S 1A 1B
	slv_PFA <= slv_xVS(8 downto 3) & slv_xHS(9 downto 3) when sl_4H = '0' else sl_VMP0 & slv_VPA(12 downto 1);

	-- Playfield RAM
	RAM_4BC_4CD : entity work.RAM_8K16 port map (I_CLK => I_CLK, I_CEn => '0', I_WEn => sl_PFWRITEn, I_ADDR => slv_PFA, I_DATA => slv_PFDI, O_DATA => slv_PFDO);

	-- Playfield RAM Data Latches
	slv_PFDI <= slv_VPDI when sl_PFWRn = '0' else (others=>'0'); -- 1J 2A

	p_1K_2BC : process
	begin
		wait until rising_edge(I_CLK);
		if sl_4Hn_strobe = '1' then
			slv_1K_2BC <= slv_PFDO;
		end if;
	end process;

	-- Alphanumeric ROM
	-- ROMs moved outside this module

	-- loadable serial shifters preset to always shift up
	p_7S_7T : process
	begin
		wait until rising_edge(I_CLK);
		if sl_NIBLOAD = '1' then
			slv_7S <= slv_ANROMD(7 downto 4);
			slv_7T <= slv_ANROMD(3 downto 0);
		else
			slv_7S <= slv_7S(2 downto 0) & '0'; -- ANPIX1
			slv_7T <= slv_7T(2 downto 0) & '0'; -- ANPIX0
		end if;
	end process;

	-- Playfield ROM Addressing
	p_3B_3BC : process
	begin
		wait until rising_edge(I_CLK);
		if sl_4H_strobe = '1' then
			slv_PFP(1 downto 0)     <= slv_PFDO(15 downto 14);
			slv_PFC(2 downto 0)     <= slv_PFDO(13 downto 11);
			slv_PFROMA(14 downto 4) <= slv_PFDO(10 downto  0);
		end if;
	end process;

	sl_ANPIX1 <= slv_7S(3);
	sl_ANPIX0 <= slv_7T(3);

-------- Sheet 12B --------

	-- Motion Object ROM
	-- ROMs moved outside this module

	-- when MOVMATCHn high all outputs are high
	-- when MOHFLIPD high we bit reverse or else straight through
	-- the 74LS158 is an inverting muxer so we must also invert the input data
	slv_7HJ <=
		(sl_MOVMATCHn & sl_MOVMATCHn & sl_MOVMATCHn & sl_MOVMATCHn) or not (slv_MOROMD(12) & slv_MOROMD(13) & slv_MOROMD(14) & slv_MOROMD(15)) when sl_MOHFLIPD = '1' else
		(sl_MOVMATCHn & sl_MOVMATCHn & sl_MOVMATCHn & sl_MOVMATCHn) or not slv_MOROMD(15 downto 12);
	slv_7J  <= 
		(sl_MOVMATCHn & sl_MOVMATCHn & sl_MOVMATCHn & sl_MOVMATCHn) or not (slv_MOROMD( 8) & slv_MOROMD( 9) & slv_MOROMD(10) & slv_MOROMD(11)) when sl_MOHFLIPD = '1' else
		(sl_MOVMATCHn & sl_MOVMATCHn & sl_MOVMATCHn & sl_MOVMATCHn) or not slv_MOROMD(11 downto  8);

	slv_7M <=
		(sl_MOVMATCHn & sl_MOVMATCHn & sl_MOVMATCHn & sl_MOVMATCHn) or not (slv_MOROMD( 4) & slv_MOROMD( 5) & slv_MOROMD( 6) & slv_MOROMD( 7)) when sl_MOHFLIPD = '1' else
		(sl_MOVMATCHn & sl_MOVMATCHn & sl_MOVMATCHn & sl_MOVMATCHn) or not slv_MOROMD( 7 downto  4);
	slv_7N  <= 
		(sl_MOVMATCHn & sl_MOVMATCHn & sl_MOVMATCHn & sl_MOVMATCHn) or not (slv_MOROMD( 0) & slv_MOROMD( 1) & slv_MOROMD( 2) & slv_MOROMD( 3)) when sl_MOHFLIPD = '1' else
		(sl_MOVMATCHn & sl_MOVMATCHn & sl_MOVMATCHn & sl_MOVMATCHn) or not slv_MOROMD( 3 downto  0);

	-- loadable serial shifters preset to always shift up
	p_7K_7L_7P_7R : process
	begin
		wait until rising_edge(I_CLK);
		if sl_NIBLOAD = '1' then
			slv_7K <= slv_7HJ;
			slv_7L <= slv_7J;
			slv_7P <= slv_7M;
			slv_7R <= slv_7N;
		else
			slv_7K <= slv_7K(2 downto 0) & '1'; -- MOPIX3
			slv_7L <= slv_7L(2 downto 0) & '1'; -- MOPIX2
			slv_7P <= slv_7P(2 downto 0) & '1'; -- MOPIX1
			slv_7R <= slv_7R(2 downto 0) & '1'; -- MOPIX0
		end if;
	end process;

-------- Sheet 13A --------

	-- Playfield ROM
	-- ROMs moved outside this module

	-- loadable serial shifters preset to always shift up
	p_8A_8B_8BC_8CD : process
	begin
		wait until falling_edge(I_CLK); -- inverted by 10BC
		if sl_NIBLOAD = '1' then
			slv_8A  <= slv_PFROMD(15 downto 12);
			slv_8B  <= slv_PFROMD(11 downto  8);
			slv_8BC <= slv_PFROMD( 7 downto  4);
			slv_8CD <= slv_PFROMD( 3 downto  0);
		else
			slv_8A  <= slv_8A( 2 downto 0) & '1'; -- PFPIX3
			slv_8B  <= slv_8B( 2 downto 0) & '1'; -- PFPIX2
			slv_8BC <= slv_8BC(2 downto 0) & '1'; -- PFPIX1
			slv_8CD <= slv_8CD(2 downto 0) & '1'; -- PFPIX0
		end if;
	end process;

	-- 2l ROM selector (unused here)
--	slv_PFROMSELn(3) <= (not slv_PFBS(2)) or (not slv_PFBS(1));
--	slv_PFROMSELn(2) <= (not slv_PFBS(2)) or (    slv_PFBS(1));
--	slv_PFROMSELn(1) <= (    slv_PFBS(2)) or (not slv_PFBS(1));
--	slv_PFROMSELn(0) <= (    slv_PFBS(2)) or (    slv_PFBS(1));

-------- Sheet 13B --------

	-- Motion Objects Line Buffers

	-- 8S 8T 8R 8P 8N 8M 9L 11L 11N
	MOLB0 : entity work.MOLB port map (
		I_CLK         => I_CLK,
		I_IENn        => sl_2OF3Vn,
		I_OENn        => sl_0OF3Vn,
		I_MOHLDn      => sl_MOHLD0n,
		I_MOHRn       => sl_MOHR0n,
		I_ADDR        => slv_ANMOD(15 downto 6),
		I_DATA(7)     => sl_MOPRI1, -- MOPRI1
		I_DATA(6)     => sl_MOPRI0, -- MOPRI0
		I_DATA(5)     => sl_MOCOL1, -- MOCOL1
		I_DATA(4)     => sl_MOCOL0, -- MOCOL0
		I_DATA(3)     => slv_7K(3), -- MOPIX3
		I_DATA(2)     => slv_7L(3), -- MOPIX2
		I_DATA(1)     => slv_7P(3), -- MOPIX1
		I_DATA(0)     => slv_7R(3), -- MOPIX0
		O_DATA        => slv_MOLB0_DO
	);

	-- 9S 9T 9R 9P 9N 9M 10L 11L 11N
	MOLB1 : entity work.MOLB port map (
		I_CLK         => I_CLK,
		I_IENn        => sl_0OF3Vn,
		I_OENn        => sl_1OF3Vn,
		I_MOHLDn      => sl_MOHLD1n,
		I_MOHRn       => sl_MOHR1n,
		I_ADDR        => slv_ANMOD(15 downto 6),
		I_DATA(7)     => sl_MOPRI1, -- MOPRI1
		I_DATA(6)     => sl_MOPRI0, -- MOPRI0
		I_DATA(5)     => sl_MOCOL1, -- MOCOL1
		I_DATA(4)     => sl_MOCOL0, -- MOCOL0
		I_DATA(3)     => slv_7K(3), -- MOPIX3
		I_DATA(2)     => slv_7L(3), -- MOPIX2
		I_DATA(1)     => slv_7P(3), -- MOPIX1
		I_DATA(0)     => slv_7R(3), -- MOPIX0
		O_DATA        => slv_MOLB1_DO
	);

	-- 10S 10T 10R 10P 10N 10M 10K 11L 11N
	MOLB2 : entity work.MOLB port map (
		I_CLK         => I_CLK,
		I_IENn        => sl_1OF3Vn,
		I_OENn        => sl_2OF3Vn,
		I_MOHLDn      => sl_MOHLD2n,
		I_MOHRn       => sl_MOHR2n,
		I_ADDR        => slv_ANMOD(15 downto 6),
		I_DATA(7)     => sl_MOPRI1, -- MOPRI1
		I_DATA(6)     => sl_MOPRI0, -- MOPRI0
		I_DATA(5)     => sl_MOCOL1, -- MOCOL1
		I_DATA(4)     => sl_MOCOL0, -- MOCOL0
		I_DATA(3)     => slv_7K(3), -- MOPIX3
		I_DATA(2)     => slv_7L(3), -- MOPIX2
		I_DATA(1)     => slv_7P(3), -- MOPIX1
		I_DATA(0)     => slv_7R(3), -- MOPIX0
		O_DATA        => slv_MOLB2_DO
	);

	-- demux outputs
	slv_MOLBO <=
		slv_MOLB0_DO when sl_0OF3Vn = '0' else
		slv_MOLB1_DO when sl_1OF3Vn = '0' else
		slv_MOLB2_DO when sl_2OF3Vn = '0' else
		(others=>'1');

-------- Sheet 14A --------

	-- Playfield Horizontal Scroll Registers
	p_3FH_67FH : process
	begin
		wait until rising_edge(I_CLK);
		if sl_HSCROLLn = '0' then
			slv_HSx(9 downto 0) <= slv_VPDI(15 downto 6);
			slv_PFB0            <= slv_VPDI( 3 downto 0);
		end if;
	end process;

	sl_HSTC <= slv_xHS(2) and slv_xHS(1) and slv_xHS(0); -- 12BC 7FH (HSTC)

	-- 3 bit counter
	p_5EF : process
	begin
		wait until rising_edge(I_CLK);
		if sl_HSLDn = '0' or sl_HSTC = '1' then
			slv_xHS(2 downto 0) <= slv_HSx(2 downto 0);
		else
			slv_xHS(2 downto 0) <= slv_xHS(2 downto 0) + 1;
		end if;
	end process;

	-- 7 bit counter
	p_5DE_3DE : process
	begin
		wait until rising_edge(I_CLK);
		if sl_HSLDn = '0' then
			slv_xHS(9 downto 3) <= slv_HSx(9 downto 3);
		else
			if sl_BYTELDn = '0' then
				slv_xHS(9 downto 3) <= slv_xHS(9 downto 3) + 1;
			end if;
		end if;
	end process;

	-- Playfield Vertical Scroll Registers
	p_3H_4FH : process
	begin
		wait until rising_edge(I_CLK);
		if sl_VSCROLLn = '0' then
			slv_VSx( 8 downto  0) <= slv_VPDI(14 downto 6);
			sl_5CD_3CD_4DE_LDENn  <= slv_VPDI( 4);
			slv_PFB1              <= slv_VPDI( 3 downto 0);
		end if;
	end process;

	p_5CD_3CD_4DE : process
	begin
		wait until rising_edge(I_CLK);
		sl_HSYNCn_last <= sl_HSYNCn;
		if sl_HSYNCn_last = '0' and sl_HSYNCn = '1' then
			if (sl_5CD_3CD_4DE_LDENn and sl_VRESETn) = '0' then
				slv_xVS <= slv_VSx;     -- load
			else
				slv_xVS <= slv_xVS + 1; -- count
			end if;
		end if;
	end process;

-------- Sheet 14B --------

	-- Playfield Scrolling

	-- PFHS
	PFHS : entity work.PFHS port map (
		I_CLK   => I_CLK,
		I_HSTC  => sl_HSTC,
		I_HSLDn => sl_HSLDn,
		I_421H  => slv_xHS(2 downto 0),

		I_D(8)  => slv_PFPRIO(1),
		I_D(7)  => slv_PFPRIO(0),
		I_D(6)  => slv_PFCOL(2),
		I_D(5)  => slv_PFCOL(1),
		I_D(4)  => slv_PFCOL(0),
		I_D(3)  => slv_8A(3),  -- PFPIX3
		I_D(2)  => slv_8B(3),  -- PFPIX2
		I_D(1)  => slv_8BC(3), -- PFPIX1
		I_D(0)  => slv_8CD(3), -- PFPIX0

		O_D(8) => sl_PFPRI1D,
		O_D(7) => sl_PFPRI0D,
		O_D(6) => sl_PFCOL2D,
		O_D(5) => sl_PFCOL1D,
		O_D(4) => sl_PFCOL0D,
		O_D(3) => sl_PFPIX3D,
		O_D(2) => sl_PFPIX2D,
		O_D(1) => sl_PFPIX1D,
		O_D(0) => sl_PFPIX0D
	);

	-- Prioritizing Logic

	sl_LBPRI1 <= slv_MOLBO(7);
	sl_LBPRI0 <= slv_MOLBO(6);
	sl_LBCOL1 <= slv_MOLBO(5);
	sl_LBCOL0 <= slv_MOLBO(4);
	sl_LBPIX3 <= slv_MOLBO(3);
	sl_LBPIX2 <= slv_MOLBO(2);
	sl_LBPIX1 <= slv_MOLBO(1);
	sl_LBPIX0 <= slv_MOLBO(0);

	slv_10CD <= ('0' & sl_LBPRI1 & sl_LBPRI0 & '0') + not ('1' & sl_PFPRI1D & sl_PFPRI0D & '0'); -- adder 10CD

	-- 11D 9F 10BC 8L 11R
	sl_PF_ANMOn <= (not slv_PRI_sel(0) ) and  ( (sl_LBPIX3 and sl_LBPIX2 and sl_LBPIX1 and sl_LBPIX0) or (sl_PFPIX3D and slv_10CD(2)) );

	slv_PRI_sel <= sl_PF_ANMOn & (sl_ANPIX1D or sl_ANPIX0D);

	-- 9H 10E 10D 11E
	slv_PRIO_LOGIC <=
		(sl_PF_ANMOn)    &    (slv_PRI_sel(0) & sl_LBCOL1  & sl_LBCOL0  & not sl_LBPIX3  & not sl_LBPIX2  & not sl_LBPIX1  & not sl_LBPIX0) when slv_PRI_sel = "00" else -- MO
		(sl_PF_ANMOn)    &    ('1'            & '0'        & sl_ANCOL2D &     sl_ANCOL1D &     sl_ANCOL0D &     sl_ANPIX1D &    sl_ANPIX0D) when slv_PRI_sel = "01" else -- AN FIXME 10E pin 1 is floating but drives CRA5 !!!
		(sl_PF_ANMOn)    &    (sl_PFCOL2D     & sl_PFCOL1D & sl_PFCOL0D &     sl_PFPIX3D &     sl_PFPIX2D &     sl_PFPIX1D &    sl_PFPIX0D);                             -- PF

-------- Sheet 15A --------

	-- Color RAM
	RAM_11F_11K_11J_11H : entity work.RAM_256x16 port map (I_CLK => I_CLK, I_CEn => '0', I_WEn => sl_CRAMENn, I_ADDR => slv_CRA, I_DATA => slv_VPDI, O_DATA => slv_CRD);

	sl_CRAMENn <= sl_COLORAMn or not sl_COUT;

	-- Color RAM Addressing and Data Buffers
	p_10J : process
	begin
		wait until rising_edge(I_CLK);
		slv_10J_Q <= slv_PRIO_LOGIC;
	end process;

	-- selects between 9J and 10J
	slv_CRA <= slv_VPA(8 downto 1) when sl_COLORAMn = '0' else slv_10J_Q;

	-- Alphanumeric Color Palettes Selects

	p_12E : process
	begin
		wait until rising_edge(I_CLK);
		sl_ANPIX1D <= sl_ANPIX1;
		sl_ANPIX0D <= sl_ANPIX0;
		sl_ANCOL2D <= sl_ANCOL2;
		sl_ANCOL1D <= sl_ANCOL1;
		sl_ANCOL0D <= sl_ANCOL0;
	end process;

	p_12F : process
	begin
		wait until rising_edge(I_CLK);
		if sl_4Hn_strobe = '1' then
			sl_ANCOL2 <= slv_ANC(2);
			sl_ANCOL1 <= slv_ANC(1);
			sl_ANCOL0 <= slv_ANC(0);
		end if;
	end process;

-------- Sheet 15B --------

	-- Video Intensity and Driver Enables
	-- 13J 13CD
	sl_RONn <= '0' when slv_12J(7 downto 4) /= "0000" and   sl_ZONn = '0' else '1';
	sl_GONn <= '0' when slv_12J(3 downto 0) /= "0000" and   sl_ZONn = '0' else '1';
	sl_BONn <= '0' when slv_12H(7 downto 4) /= "0000" and   sl_ZONn = '0' else '1';
	sl_ZONn <= '0' when slv_12H(3 downto 0) /= "0000" and sl_BLANKn = '1' else '1';

	p_13E : process
	begin
		wait until rising_edge(I_CLK);
		sl_RONDn <= sl_RONn;
		sl_GONDn <= sl_GONn;
		sl_BONDn <= sl_BONn;
		sl_ZONDn <= sl_ZONn;
	end process;

	-- Data Latches and Blanking
	p_12J_12H : process
	begin
		wait until rising_edge(I_CLK);
		slv_12J <= slv_CRD(15 downto 8);
		slv_12H <= slv_CRD( 7 downto 0);
	end process;

	p_12K_13H : process
	begin
		wait until rising_edge(I_CLK);
		slv_R <= slv_12J(7 downto 4);
		slv_G <= slv_12J(3 downto 0);
		slv_B <= slv_12H(7 downto 4);
		slv_Z <= slv_12H(3 downto 0) and (sl_BLANKn & sl_BLANKn & sl_BLANKn & sl_BLANKn);
	end process;

	p_13A : process
	begin
		wait until rising_edge(I_CLK);
		if sl_16H_strobe = '1' then
			sl_13A_Q <= sl_512H or sl_384V;
		end if;
	end process;

	p_12A : process
	begin
		wait until falling_edge(I_CLK);
		if sl_BLNKCLK = '0'  then
			sl_BLANKn <= not sl_13A_Q;
		end if;
	end process;

-------- Sheet 16A --------

	-- Output Drivers
	O_VIDEO_R   <= slv_R when sl_RONDn = '0' else (others=>'0');
	O_VIDEO_G   <= slv_G when sl_GONDn = '0' else (others=>'0');
	O_VIDEO_B   <= slv_B when sl_BONDn = '0' else (others=>'0');
	O_VIDEO_I   <= slv_Z when sl_ZONDn = '0' else (others=>'0');
	O_COMPSYNCn <= not (sl_VSYNC or not sl_HSYNCn); -- open collector inverter with 220R pullup
	O_HSYNC     <= not sl_HSYNCn; -- open collector buffer with 220R pullup
	O_VSYNC     <=     sl_VSYNC;  -- open collector buffer with 220R pullup

-- synthesis translate_off
	p_DBG : process
		type myfile is file of integer;
		file		ofile			: TEXT open WRITE_MODE is "ANMO.log";
		variable	s				: line;
	begin
		wait until rising_edge(I_CLK);
		if (sl_1H and sl_2H) = '1' then
			HWRITE(s, slv_ANMOA);
			WRITE(s, string'(": "));
			HWRITE(s, slv_ANMOD);

			WRITE(s, string'(" PROM "));
			HWRITE(s, '0' & slv_PROM_4MN_ADDR(5 downto 3));
			WRITE(s, string'(": "));
			HWRITE(s, slv_PROM_4MN_DATA);

			WRITE(s, string'(" ## ")); WRITE(s, now);
			WRITELINE(ofile, s);
		end if;
	end process;
-- synthesis translate_on

end RTL;
