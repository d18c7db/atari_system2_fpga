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
-- Color intensity conversion

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;

-- Convert a Color and Intensity into a standard color
entity CMAP is
	port(
		I_CLK : in std_logic;
		I_I : in  std_logic_vector(3 downto 0);	-- intensity
		I_C : in  std_logic_vector(3 downto 0);	-- color
		O_C : out std_logic_vector(3 downto 0);	-- converted output
		I_S : in std_logic -- color map selector 0=MAME 1=SIM
	);
end CMAP;

architecture RTL of CMAP is
	type CMAP_SIM_ARRAY is array (0 to 255) of std_logic_vector(3 downto 0);

	-- Color map from circuit simulation
	signal CMAP_SIM : CMAP_SIM_ARRAY := (
	x"0",  x"0",  x"0",  x"0",  x"0",  x"0",  x"0",  x"0",  x"0",  x"0",  x"0",  x"0",  x"0",  x"0",  x"0",  x"0",
	x"0",  x"0",  x"1",  x"1",  x"2",  x"2",  x"3",  x"3",  x"3",  x"4",  x"4",  x"4",  x"5",  x"5",  x"6",  x"6",
	x"0",  x"0",  x"1",  x"1",  x"2",  x"2",  x"3",  x"3",  x"4",  x"4",  x"4",  x"5",  x"5",  x"6",  x"6",  x"7",
	x"0",  x"0",  x"1",  x"1",  x"2",  x"2",  x"3",  x"3",  x"4",  x"4",  x"5",  x"5",  x"6",  x"6",  x"7",  x"7",
	x"0",  x"1",  x"1",  x"2",  x"2",  x"3",  x"3",  x"4",  x"4",  x"5",  x"5",  x"6",  x"6",  x"7",  x"8",  x"8",
	x"0",  x"1",  x"1",  x"2",  x"2",  x"3",  x"4",  x"4",  x"5",  x"5",  x"6",  x"6",  x"7",  x"7",  x"8",  x"9",
	x"0",  x"1",  x"1",  x"2",  x"3",  x"3",  x"4",  x"4",  x"5",  x"5",  x"6",  x"7",  x"7",  x"8",  x"9",  x"9",
	x"0",  x"1",  x"1",  x"2",  x"3",  x"3",  x"4",  x"5",  x"5",  x"6",  x"7",  x"7",  x"8",  x"9",  x"9",  x"A",
	x"0",  x"1",  x"2",  x"2",  x"3",  x"4",  x"4",  x"5",  x"6",  x"6",  x"7",  x"8",  x"9",  x"9",  x"A",  x"B",
	x"0",  x"1",  x"2",  x"2",  x"3",  x"4",  x"5",  x"5",  x"6",  x"7",  x"8",  x"8",  x"9",  x"A",  x"B",  x"B",
	x"0",  x"1",  x"2",  x"2",  x"3",  x"4",  x"5",  x"6",  x"6",  x"7",  x"8",  x"9",  x"A",  x"A",  x"B",  x"C",
	x"0",  x"1",  x"2",  x"3",  x"3",  x"4",  x"5",  x"6",  x"7",  x"7",  x"8",  x"9",  x"A",  x"B",  x"C",  x"D",
	x"0",  x"1",  x"2",  x"3",  x"4",  x"5",  x"5",  x"6",  x"7",  x"8",  x"9",  x"A",  x"B",  x"B",  x"C",  x"D",
	x"0",  x"1",  x"2",  x"3",  x"4",  x"5",  x"6",  x"7",  x"7",  x"8",  x"9",  x"A",  x"B",  x"C",  x"D",  x"E",
	x"0",  x"1",  x"2",  x"3",  x"4",  x"5",  x"6",  x"7",  x"8",  x"9",  x"A",  x"B",  x"C",  x"C",  x"E",  x"E",
	x"0",  x"1",  x"2",  x"3",  x"4",  x"5",  x"6",  x"7",  x"8",  x"9",  x"A",  x"B",  x"C",  x"D",  x"E",  x"F"
	);

-- rgb_t atarisy2_state::RGBI(uint32_t raw) {
-- 	static constexpr int ZB = 115, Z3 = 78, Z2 = 37, Z1 = 17, Z0 = 9;
-- 
-- 	static constexpr int intensity_table[16] ={  0, ZB+Z0, ZB+Z1, ZB+Z1+Z0, ZB+Z2, ZB+Z2+Z0, ZB+Z2+Z1, ZB+Z2+Z1+Z0, ZB+Z3, ZB+Z3+Z0, ZB+Z3+Z1, ZB+Z3+Z1+Z0, ZB+Z3+Z2, ZB+Z3+Z2+Z0, ZB+Z3+Z2+Z1, ZB+Z3+Z2+Z1+Z0};
-- 	static constexpr int color_table[16]     ={0x0,   0x3,   0x4,      0x5,   0x6,      0x7,      0x8,         0x9,   0xa,      0xb,      0xc,         0xd,      0xe,         0xe,         0xf,            0xf};
-- 	int const i = intensity_table[raw & 15];
-- 	uint8_t const r = (color_table[(raw >> 12) & 15] * i) >> 4;
-- 	uint8_t const g = (color_table[(raw >> 8) & 15] * i) >> 4;
-- 	uint8_t const b = (color_table[(raw >> 4) & 15] * i) >> 4;
-- 
-- 	return rgb_t(r, g, b);
-- }
	-- Color map from MAME (seems to have a higher gamma, brightened darker shades)
	type CMAP_MAME_ARRAY is array (0 to 255) of std_logic_vector(3 downto 0);
	signal CMAP_MAME : CMAP_MAME_ARRAY := (
	x"0",  x"0",  x"0",  x"0",  x"0",  x"0",  x"0",  x"0",  x"0",  x"0",  x"0",  x"0",  x"0",  x"0",  x"0",  x"0",
	x"0",  x"1",  x"2",  x"2",  x"3",  x"3",  x"4",  x"4",  x"5",  x"5",  x"6",  x"6",  x"7",  x"7",  x"7",  x"7",
	x"0",  x"2",  x"2",  x"3",  x"3",  x"4",  x"4",  x"5",  x"5",  x"6",  x"6",  x"7",  x"7",  x"7",  x"8",  x"8",
	x"0",  x"2",  x"2",  x"3",  x"3",  x"4",  x"4",  x"5",  x"6",  x"6",  x"7",  x"7",  x"8",  x"8",  x"8",  x"8",
	x"0",  x"2",  x"2",  x"3",  x"4",  x"4",  x"5",  x"5",  x"6",  x"7",  x"7",  x"8",  x"8",  x"8",  x"9",  x"9",
	x"0",  x"2",  x"3",  x"3",  x"4",  x"4",  x"5",  x"6",  x"6",  x"7",  x"8",  x"8",  x"9",  x"9",  x"9",  x"9",
	x"0",  x"2",  x"3",  x"3",  x"4",  x"5",  x"5",  x"6",  x"7",  x"7",  x"8",  x"9",  x"9",  x"9",  x"A",  x"A",
	x"0",  x"2",  x"3",  x"3",  x"4",  x"5",  x"6",  x"6",  x"7",  x"8",  x"8",  x"9",  x"A",  x"A",  x"A",  x"A",
	x"0",  x"2",  x"3",  x"4",  x"5",  x"5",  x"6",  x"7",  x"8",  x"8",  x"9",  x"A",  x"B",  x"B",  x"B",  x"B",
	x"0",  x"2",  x"3",  x"4",  x"5",  x"6",  x"6",  x"7",  x"8",  x"9",  x"9",  x"A",  x"B",  x"B",  x"C",  x"C",
	x"0",  x"2",  x"3",  x"4",  x"5",  x"6",  x"7",  x"7",  x"8",  x"9",  x"A",  x"B",  x"B",  x"B",  x"C",  x"C",
	x"0",  x"3",  x"3",  x"4",  x"5",  x"6",  x"7",  x"8",  x"9",  x"9",  x"A",  x"B",  x"C",  x"C",  x"D",  x"D",
	x"0",  x"3",  x"4",  x"4",  x"5",  x"6",  x"7",  x"8",  x"9",  x"A",  x"B",  x"C",  x"D",  x"D",  x"D",  x"D",
	x"0",  x"3",  x"4",  x"5",  x"6",  x"7",  x"7",  x"8",  x"9",  x"A",  x"B",  x"C",  x"D",  x"D",  x"E",  x"E",
	x"0",  x"3",  x"4",  x"5",  x"6",  x"7",  x"8",  x"9",  x"A",  x"B",  x"C",  x"D",  x"E",  x"E",  x"E",  x"E",
	x"0",  x"3",  x"4",  x"5",  x"6",  x"7",  x"8",  x"9",  x"A",  x"B",  x"C",  x"D",  x"E",  x"E",  x"F",  x"F"
	);

	signal slv_concat : std_logic_vector( 7 downto 0) := (others=>'0');

begin
	slv_concat <= I_I & I_C;

	p_IRGB : process
	begin
		wait until rising_edge(I_CLK);
		if I_S = '0' then
			O_C <= CMAP_MAME(to_integer(unsigned(slv_concat)));
		else
			O_C <= CMAP_SIM(to_integer(unsigned(slv_concat)));
		end if;
	end process;

end RTL;
