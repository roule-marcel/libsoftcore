library ieee;
use ieee.std_logic_1164.all;

-- Memory map:
-- 0 : CTRL -> CTRL.EN
-- 1 : CODE ADDRESS
-- 2 : BAUD FREQ
-- 3 : BAUD LIMIT

-- BAUD FREQ = 16*baud_rate / gcd(global_clock_freq, 16*baud_rate)
-- BAUD LIMIT = (global_clock_freq / gcd(global_clock_freq, 16*baud_rate)) - baud_freq

entity uart_bootloader is
	generic (
		-- Register base address (must be aligned to decoder bit width)
		BASE_ADDR : std_logic_vector(14 downto 0) := 15x"0100"
	);
	port (
		-- Memory mapped peripheral side
		-- Configure Code memory range and start re-programmation
		per_dout : out std_logic_vector(15 downto 0);  -- Peripheral data output

		mclk : in std_logic;                           -- Main system clock
		per_addr : in std_logic_vector(13 downto 0);   -- Peripheral address
		per_din : in std_logic_vector(15 downto 0);    -- Peripheral data input
		per_en : in std_logic;                         -- Peripheral enable (high active)
		per_we : in std_logic_vector(1 downto 0);      -- Peripheral write enable (high active)
		puc_rst : in std_logic;                        -- Main system reset

		-- DMA side
		-- Actually re-program the MCU
		dma_dout : in std_logic_vector(15 downto 0);   -- Direct Memory Access data output
		dma_ready : in std_logic;                      -- Direct Memory Access is complete
		dma_resp : in std_logic;                       -- Direct Memory Access response (0:Okay / 1:Error)

		dma_addr : out std_logic_vector(15 downto 1);  -- Direct Memory Access address
		dma_din : out std_logic_vector(15 downto 0);   -- Direct Memory Access data input
		dma_en : out std_logic;                        -- Direct Memory Access enable (high active)
		dma_priority : out std_logic;                  -- Direct Memory Access priority (0:low / 1:high)
		dma_we : out std_logic_vector(1 downto 0);     -- Direct Memory Access write byte enable (high active)

		uart_rxd : in std_logic
	);
end entity uart_bootloader;
