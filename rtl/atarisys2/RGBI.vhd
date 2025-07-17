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
--

-- Analog simulation of the color and intensity output transistor drivers on sheets 15B, 16A shows that the output voltage during active video is between 1.1V and 3.6V into a 75ohm load
-- The voltage formula for each color output is the maximum(1.148 , 0.1195*(COLOR_INDEX + INTENSITY_INDEX) ) unless either COLOR_INDEX or INTENSITY_INDEX is 0, then the respective output voltage is clamped to 0V via 13E
-- If either COLOR_INDEX=0 or INTENSITY_INDEX=0 the color value is 0, otherwise the final color value can be computed as (COLOR_INDEX + INTENSITY_INDEX) index into the list below
-- 0   0  85  85  85  85  85  85  85  85  94 102 111 119 128 136 145 153 162 170 179 187 196 204 213 221 230 238 247 255

-- for example intensity=4 color=7 (4+7=11) produces the same output voltage as index=10 color=1 (10+1=11)
-- also index values less than 10 seem to be clamped to a min value so they don't add additional color resolution
-- Based on above this circuit seems overly engineered since the 4 bit intensity barely adds 1 extra bit of resolution to each 4 bit color value (22 distinct values total).

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;

-- RGBI to RGB conversion
-- Implements function (Intensity * Color) / 16 rounded to nearest integer
entity RGBI is
	port(
		I_CLK : in std_logic;
		I_I : in  std_logic_vector(3 downto 0);
		I_R : in  std_logic_vector(3 downto 0);
		I_G : in  std_logic_vector(3 downto 0);
		I_B : in  std_logic_vector(3 downto 0);
		O_R : out std_logic_vector(7 downto 0);
		O_G : out std_logic_vector(7 downto 0);
		O_B : out std_logic_vector(7 downto 0)
	);
end RGBI;

architecture RTL of RGBI is
	type ROM_ARRAY is array (0 to 255) of std_logic_vector(3 downto 0);
	signal ROMR : ROM_ARRAY := (
		x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0",
		x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"1", x"1", x"1", x"1", x"1", x"1", x"1", x"1",
		x"0", x"0", x"0", x"0", x"1", x"1", x"1", x"1", x"1", x"1", x"1", x"1", x"2", x"2", x"2", x"2",
		x"0", x"0", x"0", x"1", x"1", x"1", x"1", x"1", x"2", x"2", x"2", x"2", x"2", x"3", x"3", x"3",
		x"0", x"0", x"1", x"1", x"1", x"1", x"2", x"2", x"2", x"2", x"3", x"3", x"3", x"3", x"4", x"4",
		x"0", x"0", x"1", x"1", x"1", x"2", x"2", x"2", x"3", x"3", x"3", x"4", x"4", x"4", x"5", x"5",
		x"0", x"0", x"1", x"1", x"2", x"2", x"2", x"3", x"3", x"4", x"4", x"4", x"5", x"5", x"6", x"6",
		x"0", x"0", x"1", x"1", x"2", x"2", x"3", x"3", x"4", x"4", x"5", x"5", x"6", x"6", x"7", x"7",
		x"0", x"1", x"1", x"2", x"2", x"3", x"3", x"4", x"4", x"5", x"5", x"6", x"6", x"7", x"7", x"8",
		x"0", x"1", x"1", x"2", x"2", x"3", x"4", x"4", x"5", x"5", x"6", x"7", x"7", x"8", x"8", x"9",
		x"0", x"1", x"1", x"2", x"3", x"3", x"4", x"5", x"5", x"6", x"7", x"7", x"8", x"9", x"9", x"A",
		x"0", x"1", x"1", x"2", x"3", x"4", x"4", x"5", x"6", x"7", x"7", x"8", x"9", x"A", x"A", x"B",
		x"0", x"1", x"2", x"2", x"3", x"4", x"5", x"6", x"6", x"7", x"8", x"9", x"A", x"A", x"B", x"C",
		x"0", x"1", x"2", x"3", x"3", x"4", x"5", x"6", x"7", x"8", x"9", x"A", x"A", x"B", x"C", x"D",
		x"0", x"1", x"2", x"3", x"4", x"5", x"6", x"7", x"7", x"8", x"9", x"A", x"B", x"C", x"D", x"E",
		x"0", x"1", x"2", x"3", x"4", x"5", x"6", x"7", x"8", x"9", x"A", x"B", x"C", x"D", x"E", x"F"
	);
	signal ROMG : ROM_ARRAY := (
		x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0",
		x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"1", x"1", x"1", x"1", x"1", x"1", x"1", x"1",
		x"0", x"0", x"0", x"0", x"1", x"1", x"1", x"1", x"1", x"1", x"1", x"1", x"2", x"2", x"2", x"2",
		x"0", x"0", x"0", x"1", x"1", x"1", x"1", x"1", x"2", x"2", x"2", x"2", x"2", x"3", x"3", x"3",
		x"0", x"0", x"1", x"1", x"1", x"1", x"2", x"2", x"2", x"2", x"3", x"3", x"3", x"3", x"4", x"4",
		x"0", x"0", x"1", x"1", x"1", x"2", x"2", x"2", x"3", x"3", x"3", x"4", x"4", x"4", x"5", x"5",
		x"0", x"0", x"1", x"1", x"2", x"2", x"2", x"3", x"3", x"4", x"4", x"4", x"5", x"5", x"6", x"6",
		x"0", x"0", x"1", x"1", x"2", x"2", x"3", x"3", x"4", x"4", x"5", x"5", x"6", x"6", x"7", x"7",
		x"0", x"1", x"1", x"2", x"2", x"3", x"3", x"4", x"4", x"5", x"5", x"6", x"6", x"7", x"7", x"8",
		x"0", x"1", x"1", x"2", x"2", x"3", x"4", x"4", x"5", x"5", x"6", x"7", x"7", x"8", x"8", x"9",
		x"0", x"1", x"1", x"2", x"3", x"3", x"4", x"5", x"5", x"6", x"7", x"7", x"8", x"9", x"9", x"A",
		x"0", x"1", x"1", x"2", x"3", x"4", x"4", x"5", x"6", x"7", x"7", x"8", x"9", x"A", x"A", x"B",
		x"0", x"1", x"2", x"2", x"3", x"4", x"5", x"6", x"6", x"7", x"8", x"9", x"A", x"A", x"B", x"C",
		x"0", x"1", x"2", x"3", x"3", x"4", x"5", x"6", x"7", x"8", x"9", x"A", x"A", x"B", x"C", x"D",
		x"0", x"1", x"2", x"3", x"4", x"5", x"6", x"7", x"7", x"8", x"9", x"A", x"B", x"C", x"D", x"E",
		x"0", x"1", x"2", x"3", x"4", x"5", x"6", x"7", x"8", x"9", x"A", x"B", x"C", x"D", x"E", x"F"
	);
	signal ROMB : ROM_ARRAY := (
		x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0",
		x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"1", x"1", x"1", x"1", x"1", x"1", x"1", x"1",
		x"0", x"0", x"0", x"0", x"1", x"1", x"1", x"1", x"1", x"1", x"1", x"1", x"2", x"2", x"2", x"2",
		x"0", x"0", x"0", x"1", x"1", x"1", x"1", x"1", x"2", x"2", x"2", x"2", x"2", x"3", x"3", x"3",
		x"0", x"0", x"1", x"1", x"1", x"1", x"2", x"2", x"2", x"2", x"3", x"3", x"3", x"3", x"4", x"4",
		x"0", x"0", x"1", x"1", x"1", x"2", x"2", x"2", x"3", x"3", x"3", x"4", x"4", x"4", x"5", x"5",
		x"0", x"0", x"1", x"1", x"2", x"2", x"2", x"3", x"3", x"4", x"4", x"4", x"5", x"5", x"6", x"6",
		x"0", x"0", x"1", x"1", x"2", x"2", x"3", x"3", x"4", x"4", x"5", x"5", x"6", x"6", x"7", x"7",
		x"0", x"1", x"1", x"2", x"2", x"3", x"3", x"4", x"4", x"5", x"5", x"6", x"6", x"7", x"7", x"8",
		x"0", x"1", x"1", x"2", x"2", x"3", x"4", x"4", x"5", x"5", x"6", x"7", x"7", x"8", x"8", x"9",
		x"0", x"1", x"1", x"2", x"3", x"3", x"4", x"5", x"5", x"6", x"7", x"7", x"8", x"9", x"9", x"A",
		x"0", x"1", x"1", x"2", x"3", x"4", x"4", x"5", x"6", x"7", x"7", x"8", x"9", x"A", x"A", x"B",
		x"0", x"1", x"2", x"2", x"3", x"4", x"5", x"6", x"6", x"7", x"8", x"9", x"A", x"A", x"B", x"C",
		x"0", x"1", x"2", x"3", x"3", x"4", x"5", x"6", x"7", x"8", x"9", x"A", x"A", x"B", x"C", x"D",
		x"0", x"1", x"2", x"3", x"4", x"5", x"6", x"7", x"7", x"8", x"9", x"A", x"B", x"C", x"D", x"E",
		x"0", x"1", x"2", x"3", x"4", x"5", x"6", x"7", x"8", x"9", x"A", x"B", x"C", x"D", x"E", x"F"
	);
--	attribute ram_style : string; -- for Xilinx ISE
--	attribute ram_style of ROM : signal is "distributed";
--	attribute ramstyle : string; -- for Intel Quartus
--	attribute ramstyle of ROM : signal is "logic";
	signal slv_addR : std_logic_vector( 7 downto 0) := (others=>'0');
	signal slv_addG : std_logic_vector( 7 downto 0) := (others=>'0');
	signal slv_addB : std_logic_vector( 7 downto 0) := (others=>'0');

begin
	slv_addR <= I_I & I_R;
	slv_addG <= I_I & I_G;
	slv_addB <= I_I & I_B;

	p_IRGB : process
	begin
		wait until rising_edge(I_CLK);
		if (I_I or I_R) = x"0" then
			O_R <= x"00";
			O_G <= x"00";
			O_B <= x"00";
		else
			O_R <= ROMR(to_integer(unsigned(slv_addR))) & x"0";
			O_G <= ROMG(to_integer(unsigned(slv_addG))) & x"0";
			O_B <= ROMB(to_integer(unsigned(slv_addB))) & x"0";
		end if;
	end process;

end RTL;
