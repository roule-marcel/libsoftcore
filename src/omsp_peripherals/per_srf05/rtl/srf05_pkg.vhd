library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package srf05_pkg is
	type reg_file_t is array (natural range <>) of unsigned(15 downto 0);

	component srf05 is
		generic (
			IN_CLK_FREQ : positive := 24_000_000;
			SENSOR_NUMBER : positive := 5
		);
		port (
			clock : in std_logic;
			reset : in std_logic;
			
			trigger : out std_logic;
			echo : in std_logic_vector(SENSOR_NUMBER-1 downto 0);
			
			echo_duration : out reg_file_t(SENSOR_NUMBER-1 downto 0)
		);
	end component srf05;
end package srf05_pkg;
