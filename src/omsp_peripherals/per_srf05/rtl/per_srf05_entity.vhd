library ieee;
use ieee.std_logic_1164.all;

entity per_srf05 is
	generic (
		-- Register base address (must be aligned to decoder bit width)
		BASE_ADDR : std_logic_vector(14 downto 0) := 15x"0100";
		IN_CLK_FREQ : positive := 24_000_000;
		SENSOR_NUMBER : positive := 5
	);
	port (
		per_dout : out std_logic_vector(15 downto 0);  -- Peripheral data output

		mclk : in std_logic;                           -- Main system clock
		per_addr : in std_logic_vector(13 downto 0);   -- Peripheral address
		per_din : in std_logic_vector(15 downto 0);    -- Peripheral data input
		per_en : in std_logic;                         -- Peripheral enable (high active)
		per_we : in std_logic_vector(1 downto 0);      -- Peripheral write enable (high active)
		puc_rst : in std_logic;                        -- Main system reset

		trigger : out std_logic;
		echo : in std_logic_vector(SENSOR_NUMBER-1 downto 0)
	);
end entity per_srf05;
