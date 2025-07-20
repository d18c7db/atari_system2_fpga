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

entity RAM_8K16 is
	port(
		I_CLK  : in  std_logic;
		I_CEn  : in  std_logic;
		I_WEn  : in  std_logic;
		I_ADDR : in  std_logic_vector(12 downto 0);
		I_DATA : in  std_logic_vector(15 downto 0);
		O_DATA : out std_logic_vector(15 downto 0)
	);
end RAM_8K16;

architecture RTL of RAM_8K16 is
	type RAM_ARRAY_8Kx16 is array (0 to 8191) of std_logic_vector(15 downto 0);
	signal RAM : RAM_ARRAY_8Kx16 := (others=>(others=>'0'));

	-- Ask Xilinx synthesis to use block RAMs if possible
	attribute ram_style : string;
	attribute ram_style of RAM : signal is "block";
	-- Ask Quartus synthesis to use block RAMs if possible
	attribute ramstyle : string;
	attribute ramstyle of RAM : signal is "M10K";

begin
	p_RAM : process
	begin
		wait until rising_edge(I_CLK);
		if I_CEn = '0' then
			if I_WEn = '0' then
				RAM(to_integer(unsigned(I_ADDR))) <= I_DATA;
			else
				O_DATA <= RAM(to_integer(unsigned(I_ADDR)));
			end if;
		end if;
	end process;
end RTL;