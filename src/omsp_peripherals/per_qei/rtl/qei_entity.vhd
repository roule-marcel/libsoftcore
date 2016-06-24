library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity qei is
	port (
		clock : in std_logic;
		reset : in std_logic;

		qei_a : in std_logic;
		qei_b : in std_logic;

		steps : out signed(15 downto 0)
	);
end entity qei;
