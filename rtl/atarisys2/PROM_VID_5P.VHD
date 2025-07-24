-- PROM dumped on 2025-07-23 by Colin Davies (ColinD - UKVAC) from a Atari 1986 Championship Sprint Video PCB

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity PROM_5P is
port (
	CLK  : in  std_logic;
	ADDR : in  std_logic_vector(8 downto 0);
	DATA : out std_logic_vector(3 downto 0)
	);
end PROM_5P;

architecture RTL of PROM_5P is
	type ROM_ARRAY is array (0 to 511) of std_logic_vector(3 downto 0);
	signal ROM : ROM_ARRAY := (
	x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0",
	x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0",
	x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0",
	x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"8", x"9", x"A", x"B", x"C", x"D", x"E", x"F",
	x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0",
	x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0",
	x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0",
	x"8", x"9", x"A", x"B", x"C", x"D", x"E", x"F", x"9", x"A", x"B", x"C", x"D", x"E", x"F", x"8",
	x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0",
	x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0",
	x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"8", x"9", x"A", x"B", x"C", x"D", x"E", x"F",
	x"9", x"A", x"B", x"C", x"D", x"E", x"F", x"8", x"A", x"B", x"C", x"D", x"E", x"F", x"8", x"9",
	x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0",
	x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0",
	x"8", x"9", x"A", x"B", x"C", x"D", x"E", x"F", x"9", x"A", x"B", x"C", x"D", x"E", x"F", x"8",
	x"A", x"B", x"C", x"D", x"E", x"F", x"8", x"9", x"B", x"C", x"D", x"E", x"F", x"8", x"9", x"A",
	x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0",
	x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"8", x"9", x"A", x"B", x"C", x"D", x"E", x"F",
	x"9", x"A", x"B", x"C", x"D", x"E", x"F", x"8", x"A", x"B", x"C", x"D", x"E", x"F", x"8", x"9",
	x"B", x"C", x"D", x"E", x"F", x"8", x"9", x"A", x"C", x"D", x"E", x"F", x"8", x"9", x"A", x"B",
	x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0",
	x"8", x"9", x"A", x"B", x"C", x"D", x"E", x"F", x"9", x"A", x"B", x"C", x"D", x"E", x"F", x"8",
	x"A", x"B", x"C", x"D", x"E", x"F", x"8", x"9", x"B", x"C", x"D", x"E", x"F", x"8", x"9", x"A",
	x"C", x"D", x"E", x"F", x"8", x"9", x"A", x"B", x"D", x"E", x"F", x"8", x"9", x"A", x"B", x"C",
	x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"8", x"9", x"A", x"B", x"C", x"D", x"E", x"F",
	x"9", x"A", x"B", x"C", x"D", x"E", x"F", x"8", x"A", x"B", x"C", x"D", x"E", x"F", x"8", x"9",
	x"B", x"C", x"D", x"E", x"F", x"8", x"9", x"A", x"C", x"D", x"E", x"F", x"8", x"9", x"A", x"B",
	x"D", x"E", x"F", x"8", x"9", x"A", x"B", x"C", x"E", x"F", x"8", x"9", x"A", x"B", x"C", x"D",
	x"8", x"9", x"A", x"B", x"C", x"D", x"E", x"F", x"9", x"A", x"B", x"C", x"D", x"E", x"F", x"8",
	x"A", x"B", x"C", x"D", x"E", x"F", x"8", x"9", x"B", x"C", x"D", x"E", x"F", x"8", x"9", x"A",
	x"C", x"D", x"E", x"F", x"8", x"9", x"A", x"B", x"D", x"E", x"F", x"8", x"9", x"A", x"B", x"C",
	x"E", x"F", x"8", x"9", x"A", x"B", x"C", x"D", x"F", x"8", x"9", x"A", x"B", x"C", x"D", x"E"
	);
	attribute ram_style : string;
	attribute ram_style of ROM : signal is "auto";
begin
	mem_proc : process
	begin
		wait until rising_edge(CLK);
		DATA <= ROM(to_integer(unsigned(ADDR)));
	end process;
end RTL;
