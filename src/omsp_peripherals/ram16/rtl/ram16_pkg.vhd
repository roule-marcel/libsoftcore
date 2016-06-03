library ieee;
use ieee.std_logic_1164.all;

library work;
use work.log2_pkg.all;

package ram16_pkg is
	component ram16 is
		generic (
			DEPTH : positive := 2048
		);
		port (
			clk : std_logic;
			cen : std_logic;
			addr : std_logic_vector(log2ceil(DEPTH)-1 downto 0);
			dout : std_logic_vector(15 downto 0);
			din : std_logic_vector(15 downto 0);
			wen : std_logic_vector(1 downto 0)
		);
	end component ram16;
end package ram16_pkg;
