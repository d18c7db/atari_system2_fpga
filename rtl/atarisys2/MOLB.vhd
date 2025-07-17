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
-- Motion Object Line Buffer based on SP-308 schematic sheet 13B

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;

entity MOLB is
	port(
		I_CLK         : in  std_logic;
		I_IENn        : in  std_logic;
		I_OENn        : in  std_logic;
		I_MOHLDn      : in  std_logic;
		I_MOHRn       : in  std_logic;
		I_ADDR        : in  std_logic_vector(9 downto 0);
		I_DATA        : in  std_logic_vector(7 downto 0);
		O_DATA        : out std_logic_vector(7 downto 0)
	);
end MOLB;

architecture RTL of MOLB is
	signal
	sl_IENn,
	sl_OENn,
	sl_MOHLDn,
	sl_MOHRn,
	sl_MOCTHRUn,
	sl_LBWRn        : std_logic := '1';

	signal
	slv_RAMDO,
	slv_RAMDI,
	slv_DATAI,
	slv_DATAO       : std_logic_vector(7 downto 0) := (others=>'0');
	signal
	slv_ctr,
	slv_ADDR        : std_logic_vector(9 downto 0) := (others=>'0');

	type RAM_ARRAY is array (0 to 1023) of std_logic_vector(7 downto 0);
	signal RAMBUF : RAM_ARRAY := ((others=>(others=>'1')));
	attribute ram_style : string;
	attribute ram_style of RAMBUF : signal is "block";

begin
	O_DATA    <= slv_DATAO;

	slv_DATAI   <= I_DATA;
	slv_ADDR    <= I_ADDR;

	sl_IENn     <= I_IENn;
	sl_OENn     <= I_OENn;

	sl_MOHLDn   <= I_MOHLDn;
	sl_MOHRn    <= I_MOHRn;

	-- 11M
	sl_MOCTHRUn <= not (slv_DATAI(3) and slv_DATAI(2) and slv_DATAI(1) and slv_DATAI(0));

	-- 11L 11N
	sl_LBWRn    <= not (I_OENn and (I_IENn or sl_MOCTHRUn) );

	-- output registers like 9L 10K 10L
	p_OREG : process
	begin
		wait until rising_edge(I_CLK);
		slv_DATAO <= slv_RAMDO;
	end process;

	-- 10 bit counters like 8S 8T 8R, 10S 10T 10R, 9S 9T 9R
	p_CTR : process
	begin
		wait until rising_edge(I_CLK);
		if sl_MOHRn = '0' then -- reset
			slv_ctr <= (others=>'0');
		else
			if sl_MOHLDn = '0' then -- load
				slv_ctr <= slv_ADDR;
			else
				slv_ctr <= slv_ctr + 1; -- count
			end if;
		end if;
	end process;

	-- input buffers like 8M 9M 10M
	slv_RAMDI <= slv_DATAI when sl_IENn = '0' else (others=>'1'); -- RAM data pins pullups RN1 RN2

	-- local RAM buffer like 8P 8N, 10P 10N, 9P 9N
	p_RAMBUF : process
	begin
		wait until falling_edge(I_CLK);
		if sl_LBWRn = '0' then
			RAMBUF(to_integer(unsigned(slv_ctr))) <= slv_RAMDI; -- write
		else
			slv_RAMDO <= RAMBUF(to_integer(unsigned(slv_ctr))); -- read
		end if;
	end process;
end RTL;
