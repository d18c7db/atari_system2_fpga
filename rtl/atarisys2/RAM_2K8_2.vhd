--	(c) 2020 d18c7db(a)hotmail
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
-- generic 2K x 8 RAM definition

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity RAM_2K8_2 is
	port(
		I_MCKR : in  std_logic;
		I_En   : in  std_logic;
		I_Wn   : in  std_logic;
		I_ADDR : in  std_logic_vector(10 downto 0);
		I_DATA : in  std_logic_vector( 7 downto 0);
		O_DATA : out std_logic_vector( 7 downto 0)
	);
end RAM_2K8_2;

architecture RTL of RAM_2K8_2 is
	type RAM_ARRAY_2Kx8 is array (0 to 2047) of std_logic_vector(7 downto 0);
	signal RAM : RAM_ARRAY_2Kx8 := (
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"F7", x"F7", x"F7", x"F7", x"F7", x"F7", x"F7", x"F7", x"F7", x"F7", x"F7", x"F7", x"F7", x"F7", x"F7",
	x"F7", x"F7", x"F7", x"F7", x"F7", x"F7", x"F7", x"F7", x"F7", x"F7", x"F7", x"F7", x"F7", x"F7", x"F7", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA",
	x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"FF", x"FF", x"FF", x"DC", x"E8", x"DE", x"00", x"DA", x"DE",
	x"DB", x"F2", x"E8", x"00", x"E1", x"00", x"E8", x"ED", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA",
	x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"00", x"00",
	x"00", x"2D", x"70", x"63", x"2D", x"29", x"82", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"2F", x"72", x"43", x"3B", x"2B", x"83", x"00", x"00", x"AF", x"B1", x"00", x"00", x"B9", x"BB", x"00",
	x"BE", x"00", x"00", x"C3", x"00", x"00", x"00", x"00", x"00", x"00", x"E6", x"EB", x"E2", x"E0", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"B3", x"B5", x"B1", x"B5", x"BC", x"BE", x"B9",
	x"BF", x"C4", x"00", x"C6", x"CA", x"CE", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"2D", x"70", x"63", x"2D", x"29", x"82", x"00", x"00", x"B6", x"B8", x"B2", x"B6", x"BF", x"C1", x"BA",
	x"C0", x"C5", x"00", x"C9", x"CB", x"CF", x"00", x"00", x"00", x"00", x"00", x"E2", x"DA", x"00", x"00", x"00",
	x"00", x"2F", x"72", x"43", x"3B", x"2B", x"83", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"C6", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA",
	x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"86", x"D1", x"D8", x"00", x"ED", x"EB", x"00", x"DA", x"DE", x"7E", x"E2", x"DC",
	x"00", x"DA", x"E5", x"EB", x"E0", x"ED", x"00", x"DE", x"DE", x"EF", x"DD", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA",
	x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"00", x"00",
	x"00", x"00", x"29", x"4E", x"29", x"78", x"41", x"52", x"31", x"00", x"58", x"29", x"58", x"2D", x"2D", x"2D",
	x"31", x"74", x"00", x"35", x"2D", x"45", x"41", x"68", x"2D", x"2D", x"5F", x"82", x"00", x"00", x"00", x"00",
	x"00", x"00", x"2B", x"50", x"2B", x"7A", x"43", x"54", x"33", x"00", x"5A", x"2B", x"5A", x"2F", x"3B", x"2F",
	x"33", x"76", x"00", x"37", x"2F", x"4C", x"43", x"6A", x"2F", x"3B", x"61", x"83", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"E9", x"EB", x"DE", x"ED", x"EC", x"EB", x"E2", x"DE", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"F8", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"F9", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"F9", x"F2", x"ED", x"EB", x"E8", x"EC", x"EF", x"E7", x"DA", x"E2", x"E6", x"00", x"00", x"F9", x"00",
	x"00", x"DE", x"EB", x"EC", x"E1", x"E7", x"EB", x"7E", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"F9", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"F9", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"F9", x"DA", x"DF", x"DE", x"00", x"E8", x"E2", x"DE", x"00", x"DE", x"E2", x"DE", x"ED", x"F9", x"00",
	x"00", x"DB", x"E0", x"DB", x"DC", x"EC", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"F9", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"F9", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"F9", x"A3", x"A3", x"A3", x"A3", x"A3", x"00", x"00", x"AD", x"AD", x"00", x"AD", x"00", x"F9", x"00",
	x"00", x"00", x"AD", x"AD", x"00", x"AD", x"00", x"AD", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"F9", x"A7", x"A5", x"A5", x"A7", x"A5", x"00", x"A6", x"A4", x"A4", x"A6", x"A4", x"A6", x"F9", x"00",
	x"00", x"A6", x"A4", x"A4", x"A6", x"A4", x"A6", x"A4", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"F9", x"AC", x"A9", x"A9", x"AC", x"A9", x"00", x"A8", x"AA", x"A8", x"AA", x"A8", x"A8", x"F9", x"00",
	x"00", x"A8", x"AA", x"A8", x"AA", x"A8", x"A8", x"AA", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"F9", x"A1", x"A1", x"A1", x"A3", x"A3", x"00", x"A2", x"A0", x"A0", x"A2", x"A0", x"00", x"F9", x"00",
	x"00", x"A0", x"A0", x"A0", x"A2", x"A0", x"A2", x"A0", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"F9", x"A7", x"A5", x"A5", x"A7", x"A5", x"00", x"A6", x"A4", x"A4", x"A6", x"A4", x"A6", x"F9", x"00",
	x"00", x"A4", x"A4", x"A4", x"A6", x"A4", x"A6", x"A4", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"F9", x"AC", x"A9", x"A9", x"AC", x"A9", x"00", x"A8", x"AA", x"A8", x"AA", x"A8", x"A8", x"F9", x"00",
	x"00", x"A8", x"AA", x"A8", x"AA", x"A8", x"A8", x"AA", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"F9", x"A1", x"A1", x"A1", x"A3", x"A3", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"F9", x"00",
	x"00", x"A2", x"A0", x"A0", x"A2", x"A0", x"00", x"AD", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"F9", x"A7", x"A5", x"A5", x"A7", x"A5", x"F8", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"F9", x"00",
	x"00", x"A6", x"A4", x"A4", x"A6", x"A4", x"A6", x"A4", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"F9", x"AC", x"A9", x"A9", x"AC", x"A9", x"F9", x"DE", x"E8", x"E9", x"E9", x"EB", x"E8", x"F9", x"00",
	x"00", x"A8", x"AA", x"A8", x"AA", x"A8", x"A8", x"AA", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"F9", x"A1", x"A1", x"A1", x"A3", x"A3", x"F9", x"00", x"00", x"00", x"00", x"00", x"00", x"F9", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"F9", x"A7", x"A5", x"A5", x"A7", x"A5", x"F9", x"ED", x"E9", x"00", x"E1", x"DE", x"FE", x"F9", x"00",
	x"00", x"00", x"FA", x"FA", x"FA", x"FA", x"FA", x"00", x"00", x"A0", x"A0", x"A0", x"A2", x"A0", x"A0", x"A3",
	x"00", x"F9", x"AC", x"A9", x"A9", x"AC", x"A9", x"F9", x"00", x"00", x"00", x"00", x"00", x"00", x"F9", x"00",
	x"00", x"00", x"00", x"00", x"7E", x"00", x"00", x"00", x"00", x"AE", x"AE", x"AE", x"00", x"AE", x"AE", x"A7",
	x"00", x"F9", x"A1", x"A1", x"A1", x"A3", x"A3", x"F9", x"A3", x"A3", x"A3", x"A3", x"A3", x"A3", x"F9", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA",
	x"FA", x"F9", x"A7", x"A5", x"A5", x"A7", x"A5", x"F9", x"A7", x"A5", x"A5", x"A7", x"A5", x"A7", x"F9", x"00",
	x"00", x"DE", x"EB", x"00", x"EE", x"E7", x"EB", x"EE", x"00", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA", x"FA",
	x"FA", x"F9", x"AC", x"A9", x"A9", x"AC", x"A9", x"F9", x"AC", x"A9", x"A9", x"AC", x"A9", x"AC", x"F9", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"A2", x"ED", x"EC", x"DA", x"EB", x"EE", x"E1",
	x"00", x"F9", x"A1", x"A1", x"A1", x"A3", x"A3", x"F9", x"A1", x"A1", x"A1", x"A3", x"A3", x"A1", x"F9", x"00",
	x"00", x"DA", x"DA", x"DD", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"F9", x"A7", x"A5", x"A5", x"A7", x"A5", x"F9", x"A7", x"A5", x"A5", x"A7", x"A5", x"A7", x"F9", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"E3", x"DB", x"00", x"EE", x"FF", x"FF", x"00",
	x"00", x"F9", x"AC", x"A9", x"A9", x"AC", x"A9", x"F9", x"AC", x"A9", x"A9", x"AC", x"A9", x"AC", x"F9", x"00",
	x"00", x"00", x"AD", x"AD", x"00", x"AD", x"00", x"AD", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"F9", x"A1", x"A1", x"A1", x"A3", x"A3", x"F9", x"A1", x"A1", x"A1", x"A3", x"A3", x"A3", x"F9", x"00",
	x"00", x"A6", x"A4", x"A4", x"A6", x"A4", x"A6", x"A4", x"00", x"00", x"AD", x"AD", x"00", x"AD", x"00", x"AD",
	x"AD", x"F9", x"A7", x"A5", x"A5", x"A7", x"A5", x"F9", x"A7", x"A5", x"A5", x"A7", x"A5", x"A7", x"F9", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"F8"
	);

	-- Ask Xilinx synthesis to use block RAMs if possible
	attribute ram_style : string;
	attribute ram_style of RAM : signal is "block";
	-- Ask Quartus synthesis to use block RAMs if possible
	attribute ramstyle : string;
	attribute ramstyle of RAM : signal is "M10K";

begin
	p_RAM : process
	begin
		wait until rising_edge(I_MCKR);
		if I_En ='0' then
			if I_Wn = '0' then
				RAM(to_integer(unsigned(I_ADDR))) <= I_DATA;
			else
				O_DATA <= RAM(to_integer(unsigned(I_ADDR)));
			end if;
		end if;
	end process;
end RTL;