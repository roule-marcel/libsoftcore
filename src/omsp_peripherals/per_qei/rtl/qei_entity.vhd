library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity qei is
	generic (
		STEPS_WIDTH : positive := 32
	);
	port (
		clock : in std_logic;
		reset : in std_logic;

		qei_a : in std_logic;
		qei_b : in std_logic;

		steps : out signed(STEPS_WIDTH-1 downto 0)
	);
end entity qei;
