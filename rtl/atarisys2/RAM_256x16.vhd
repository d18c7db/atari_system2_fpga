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

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity RAM_256x16 is
	port(
		I_CLK   : in  std_logic;
		I_CEn   : in  std_logic;
		I_WEn   : in  std_logic;
		I_CRA   : in  std_logic_vector( 7 downto 0);
		I_CRD   : in  std_logic_vector(15 downto 0);
		O_CRD   : out std_logic_vector(15 downto 0)
	);
end RAM_256x16;

architecture RTL of RAM_256x16 is
	type RAM_ARRAY_256x16 is array (0 to 255) of std_logic_vector(15 downto 0);
	signal RAM : RAM_ARRAY_256x16:=(
--	(others=>(others=>'0'))

	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
	x"0000", x"0000", x"AAAA", x"2222", x"0000", x"F007", x"00FB", x"040B", x"0000", x"F00B", x"DB96", x"BDBB", x"0000", x"FFFB", x"FFF3", x"BBBB", 
	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
	x"00F4", x"EE0E", x"444A", x"FFF5", x"0C07", x"C426", x"0A03", x"5108", x"DDD8", x"0000", x"F00D", x"F007", x"0F07", x"FF08", x"FFF7", x"FFFB", 
	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
	x"06C7", x"1117", x"8347", x"C617", x"D827", x"E947", x"11F7", x"18F7", x"FFF7", x"DCF7", x"AA97", x"D5F7", x"C027", x"0807", x"FF07", x"F117", 
	x"2226", x"EE0E", x"444A", x"FFF5", x"0C07", x"C426", x"0A03", x"5108", x"FFFB", x"0000", x"F00D", x"F007", x"0F07", x"FF08", x"FFF7", x"FFFB", 
	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000"

--	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
--	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
--	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"FFFA", x"F80E", x"FD0F", x"0F06", x"F00E", x"F0FE", x"00FC", x"0000",
--	x"FFF4", x"4441", x"CCCC", x"F00A", x"0000", x"0000", x"0000", x"F409", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
--	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
--	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
--	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
--	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
--	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
--	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
--	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
--	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
--	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
--	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
--	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000",
--	x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000"

--	x"0F0F", x"1F0F", x"2F0F", x"3F0F", x"4F0F", x"5F0F", x"6F0F", x"7F0F", x"8F0F", x"9F0F", x"AF0F", x"BF0F", x"CF0F", x"DF0F", x"EF0F", x"FF0F",
--	x"0E1D", x"1E1D", x"2E1D", x"3E1D", x"4E1D", x"5E1D", x"6E1D", x"7E1D", x"8E1D", x"9E1D", x"AE1D", x"BE1D", x"CE1D", x"DE1D", x"EE1D", x"FE1D",
--	x"0D2B", x"1D2B", x"2D2B", x"3D2B", x"4D2B", x"5D2B", x"6D2B", x"7D2B", x"8D2B", x"9D2B", x"AD2B", x"BD2B", x"CD2B", x"DD2B", x"ED2B", x"FD2B",
--	x"0C39", x"1C39", x"2C39", x"3C39", x"4C39", x"5C39", x"6C39", x"7C39", x"8C39", x"9C39", x"AC39", x"BC39", x"CC39", x"DC39", x"EC39", x"FC39",
--	x"0B47", x"1B47", x"2B47", x"3B47", x"4B47", x"5B47", x"6B47", x"7B47", x"8B47", x"9B47", x"AB47", x"BB47", x"CB47", x"DB47", x"EB47", x"FB47",
--	x"0A55", x"1A55", x"2A55", x"3A55", x"4A55", x"5A55", x"6A55", x"7A55", x"8A55", x"9A55", x"AA55", x"BA55", x"CA55", x"DA55", x"EA55", x"FA55",
--	x"0963", x"1963", x"2963", x"3963", x"4963", x"5963", x"6963", x"7963", x"8963", x"9963", x"A963", x"B963", x"C963", x"D963", x"E963", x"F963",
--	x"0871", x"1871", x"2871", x"3871", x"4871", x"5871", x"6871", x"7871", x"8871", x"9871", x"A871", x"B871", x"C871", x"D871", x"E871", x"F871",
--	x"078F", x"178F", x"278F", x"378F", x"478F", x"578F", x"678F", x"778F", x"878F", x"978F", x"A78F", x"B78F", x"C78F", x"D78F", x"E78F", x"F78F",
--	x"069D", x"169D", x"269D", x"369D", x"469D", x"569D", x"669D", x"769D", x"869D", x"969D", x"A69D", x"B69D", x"C69D", x"D69D", x"E69D", x"F69D",
--	x"05AB", x"15AB", x"25AB", x"35AB", x"45AB", x"55AB", x"65AB", x"75AB", x"85AB", x"95AB", x"A5AB", x"B5AB", x"C5AB", x"D5AB", x"E5AB", x"F5AB",
--	x"04B9", x"14B9", x"24B9", x"34B9", x"44B9", x"54B9", x"64B9", x"74B9", x"84B9", x"94B9", x"A4B9", x"B4B9", x"C4B9", x"D4B9", x"E4B9", x"F4B9",
--	x"03C7", x"13C7", x"23C7", x"33C7", x"43C7", x"53C7", x"63C7", x"73C7", x"83C7", x"93C7", x"A3C7", x"B3C7", x"C3C7", x"D3C7", x"E3C7", x"F3C7",
--	x"02D5", x"12D5", x"22D5", x"32D5", x"42D5", x"52D5", x"62D5", x"72D5", x"82D5", x"92D5", x"A2D5", x"B2D5", x"C2D5", x"D2D5", x"E2D5", x"F2D5",
--	x"01E3", x"11E3", x"21E3", x"31E3", x"41E3", x"51E3", x"61E3", x"71E3", x"81E3", x"91E3", x"A1E3", x"B1E3", x"C1E3", x"D1E3", x"E1E3", x"F1E3",
--	x"00F1", x"10F1", x"20F1", x"30F1", x"40F1", x"50F1", x"60F1", x"70F1", x"80F1", x"90F1", x"A0F1", x"B0F1", x"C0F1", x"D0F1", x"E0F1", x"F0F1"

--	x"000F", x"111F", x"222F", x"333F", x"444F", x"555F", x"666F", x"777F", x"888F", x"999F", x"AAAF", x"BBBF", x"CCCF", x"DDDF", x"EEEF", x"FFFF",
--	x"000E", x"111E", x"222E", x"333E", x"444E", x"555E", x"666E", x"777E", x"888E", x"999E", x"AAAE", x"BBBE", x"CCCE", x"DDDE", x"EEEE", x"FFFE",
--	x"000D", x"111D", x"222D", x"333D", x"444D", x"555D", x"666D", x"777D", x"888D", x"999D", x"AAAD", x"BBBD", x"CCCD", x"DDDD", x"EEED", x"FFFD",
--	x"000C", x"111C", x"222C", x"333C", x"444C", x"555C", x"666C", x"777C", x"888C", x"999C", x"AAAC", x"BBBC", x"CCCC", x"DDDC", x"EEEC", x"FFFC",
--	x"000B", x"111B", x"222B", x"333B", x"444B", x"555B", x"666B", x"777B", x"888B", x"999B", x"AAAB", x"BBBB", x"CCCB", x"DDDB", x"EEEB", x"FFFB",
--	x"000A", x"111A", x"222A", x"333A", x"444A", x"555A", x"666A", x"777A", x"888A", x"999A", x"AAAA", x"BBBA", x"CCCA", x"DDDA", x"EEEA", x"FFFA",
--	x"0009", x"1119", x"2229", x"3339", x"4449", x"5559", x"6669", x"7779", x"8889", x"9999", x"AAA9", x"BBB9", x"CCC9", x"DDD9", x"EEE9", x"FFF9",
--	x"0008", x"1118", x"2228", x"3338", x"4448", x"5558", x"6668", x"7778", x"8888", x"9998", x"AAA8", x"BBB8", x"CCC8", x"DDD8", x"EEE8", x"FFF8",
--	x"0007", x"1117", x"2227", x"3337", x"4447", x"5557", x"6667", x"7777", x"8887", x"9997", x"AAA7", x"BBB7", x"CCC7", x"DDD7", x"EEE7", x"FFF7",
--	x"0006", x"1116", x"2226", x"3336", x"4446", x"5556", x"6666", x"7776", x"8886", x"9996", x"AAA6", x"BBB6", x"CCC6", x"DDD6", x"EEE6", x"FFF6",
--	x"0005", x"1115", x"2225", x"3335", x"4445", x"5555", x"6665", x"7775", x"8885", x"9995", x"AAA5", x"BBB5", x"CCC5", x"DDD5", x"EEE5", x"FFF5",
--	x"0004", x"1114", x"2224", x"3334", x"4444", x"5554", x"6664", x"7774", x"8884", x"9994", x"AAA4", x"BBB4", x"CCC4", x"DDD4", x"EEE4", x"FFF4",
--	x"0003", x"1113", x"2223", x"3333", x"4443", x"5553", x"6663", x"7773", x"8883", x"9993", x"AAA3", x"BBB3", x"CCC3", x"DDD3", x"EEE3", x"FFF3",
--	x"0002", x"1112", x"2222", x"3332", x"4442", x"5552", x"6662", x"7772", x"8882", x"9992", x"AAA2", x"BBB2", x"CCC2", x"DDD2", x"EEE2", x"FFF2",
--	x"0001", x"1111", x"2221", x"3331", x"4441", x"5551", x"6661", x"7771", x"8881", x"9991", x"AAA1", x"BBB1", x"CCC1", x"DDD1", x"EEE1", x"FFF1",
--	x"0000", x"1110", x"2220", x"3330", x"4440", x"5550", x"6660", x"7770", x"8880", x"9990", x"AAA0", x"BBB0", x"CCC0", x"DDD0", x"EEE0", x"FFF0"
	);
	-- Ask Xilinx synthesis to use block RAMs if possible
	attribute ram_style : string;
	attribute ram_style of RAM : signal is "block";
	-- Ask Quartus synthesis to use block RAMs if possible
	attribute ramstyle : string;
	attribute ramstyle of RAM : signal is "M10K";

begin
	p_CRAM : process
	begin
		wait until rising_edge(I_CLK);
		if I_CEn = '0' then
			if I_WEn = '0' then
				RAM(to_integer(unsigned(I_CRA))) <= I_CRD;
			else
				O_CRD <= RAM(to_integer(unsigned(I_CRA)));
			end if;
		end if;
	end process;
end RTL;
