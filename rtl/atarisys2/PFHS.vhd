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
--
-- Play Field Horizontal Scroll

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;

entity PFHS is
	port(
		I_CLK    : in  std_logic;
		I_HSTC   : in  std_logic;
		I_HSLDn  : in  std_logic;
		I_421H   : in  std_logic_vector(2 downto 0);
		I_D      : in  std_logic_vector(8 downto 0);
		O_D      : out std_logic_vector(8 downto 0)
	);
end PFHS;

architecture RTL of PFHS is
	type RAM_ARRAY is array (0 to 7) of std_logic_vector(8 downto 0);
	signal RAMH : RAM_ARRAY := (others=>(others=>'0'));
	signal RAML : RAM_ARRAY := (others=>(others=>'0'));
	-- Ask Xilinx synthesis to use distributed logic RAMs if possible
	attribute ram_style : string;
	attribute ram_style of RAMH : signal is "distributed";
	attribute ram_style of RAML : signal is "distributed";
	-- Ask Quartus synthesis to use distributed logic RAMs if possible
	attribute ramstyle : string;
	attribute ramstyle of RAMH : signal is "logic";
	attribute ramstyle of RAML : signal is "logic";
	signal sl_HSPERIOD : std_logic := '0';

begin
	p_11BC : process
	begin
		wait until rising_edge(I_CLK); -- FIXME clock polarities
		if I_HSLDn = '0' then
			sl_HSPERIOD <= '0';
		else
			if I_HSTC = '1' then 
				sl_HSPERIOD <= not sl_HSPERIOD; -- toggle
			end if;
		end if;
	end process;

	-- three 74LS189 16x4 bit RAMs, arranged as one 8x9 RAM
	-- The 74LS189 (9E 11A 8BC 9a 9CD 9D) invert the data out but then the 74LS158 (11B 10A 9B) invert it again so overall they cancel out
	p_reg_in : process
	begin
		wait until falling_edge(I_CLK);
		if sl_HSPERIOD = '1' then
			RAMH(to_integer(unsigned(I_421H))) <= I_D; -- 9E 11A 9BC
		else
			RAML(to_integer(unsigned(I_421H))) <= I_D; -- 9A 9CD 9D
		end if;
	end process;

	-- 12A 10B
	p_reg_out : process
	begin
		wait until rising_edge(I_CLK);
		-- selectors 11B 10A 9B
		if sl_HSPERIOD = '0' then
			O_D <= RAMH(to_integer(unsigned(I_421H))); -- 9E 11A 9BC
		else
			O_D <= RAML(to_integer(unsigned(I_421H))); -- 9A 9CD 9D
		end if;
	end process;

end RTL;
