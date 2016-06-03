library ieee;
use ieee.std_logic_1164.all;

library work;
use work.log2_pkg.all;

entity ram16_tb is
end entity ram16_tb;

--entity ram16 is
--	generic (
--		DEPTH : positive := 2048
--	);
--	port (
--		clk : std_logic;
--		cen : std_logic;
--		addr : std_logic_vector(log2ceil(DEPTH)-1 downto 0);
--		dout : std_logic_vector(15 downto 0);
--		din : std_logic_vector(15 downto 0);
--		wen : std_logic_vector(1 downto 0)
--	);
--end entity ram16;
architecture test_bench of ram16_tb is
begin

end architecture test_bench;
