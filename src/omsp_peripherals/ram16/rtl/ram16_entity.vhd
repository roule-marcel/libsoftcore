library ieee;
use ieee.std_logic_1164.all;

library work;
use work.log2_pkg.all;

entity ram16 is
	generic (
		DEPTH : positive := 2048
	);
	port (
		clk : in std_logic;                                      -- Memory clock
		cen : in std_logic;                                      -- Memory chip enable (low active)
		addr : in std_logic_vector(log2ceil(DEPTH)-1 downto 0);  -- Memory address
		din : in std_logic_vector(15 downto 0);                  -- Memory data input
		wen : in std_logic_vector(1 downto 0);                   -- Memory write enable (low active)
		dout : out std_logic_vector(15 downto 0)                 -- Memory data output
	);
end entity ram16;
