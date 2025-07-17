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
-- Atari System-2 Audio CPU circuit, based on SP-308 schematic

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;

entity AUDIO is
	port(
		I_CLK           : in  std_logic -- 14.31818MHz
	);
end AUDIO;

architecture RTL of AUDIO is
signal
	slv_ctr_7R			: std_logic_vector( 3 downto 0) := (others=>'0');
signal
	slv_ctr_3F			: std_logic_vector( 3 downto 0) := (others=>'0');
signal
	sl_R_nWB,
	sl_P2WRITEn,
	sl_P2IRQn,
	sl_CLK_2400_ena,
	sl_CLK_1M8_ena,
	sl_CLK_3M6_ena,
	sl_P2IRQCLRn		: std_logic;

begin

-------- Sheet 6B --------

	-- resettable counter, generates 9.5Hz watchdog strobe from 10M clock
	p_3F : process
	begin
		wait until rising_edge(I_CLK);
		if sl_P2IRQCLRn = '0' then
			slv_ctr_3F <= (others => '0');
		elsif sl_CLK_2400_ena = '1' then
			slv_ctr_3F <= slv_ctr_3F + 1;
		end if;
	end process;

	-- 3H
	sl_P2IRQn <= not (slv_ctr_3F(3) and slv_ctr_3F(1));

	-- non resettable counter, generates 3.6MHz and 1.8MHz clock strobes from 14.3M clock
	p_7R : process
	begin
		wait until rising_edge(I_CLK);
		slv_ctr_7R <= slv_ctr_7R + 1;
	end process;

	sl_CLK_1M8_ena <= slv_ctr_7R(2);
	sl_CLK_3M6_ena <= slv_ctr_7R(1);


	sl_P2WRITEn <= not (slv_ctr_7R(2) and not sl_R_nWB);


-------- Sheet 7A --------

-------- Sheet 7B --------

-------- Sheet 8A --------

-------- Sheet 8B --------

end RTL;
