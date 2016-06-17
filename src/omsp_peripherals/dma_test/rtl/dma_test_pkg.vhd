library ieee;
use ieee.std_logic_1164.all;

package dma_test_pkg is
	component dma_test is
		port (
			mclk : in std_logic;                           -- Main system clock
			puc_rst : in std_logic;                        -- Main system reset
	
			trigger : in std_logic;                        -- Trigger the memory erasure
	
			dma_dout : in std_logic_vector(15 downto 0);   -- Direct Memory Access data output
			dma_ready : in std_logic;                      -- Direct Memory Access is complete
			dma_resp : in std_logic;                       -- Direct Memory Access response (0:Okay / 1:Error)
	
			dma_addr : out std_logic_vector(15 downto 1);  -- Direct Memory Access address
			dma_din : out std_logic_vector(15 downto 0);   -- Direct Memory Access data input
			dma_en : out std_logic;                        -- Direct Memory Access enable (high active)
			dma_priority : out std_logic;                  -- Direct Memory Access priority (0:low / 1:high)
			dma_we : out std_logic_vector(1 downto 0)      -- Direct Memory Access write byte enable (high active)
		);
	end component dma_test;
end package dma_test_pkg;
