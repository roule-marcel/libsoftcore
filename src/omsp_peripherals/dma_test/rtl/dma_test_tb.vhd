library ieee;
use ieee.std_logic_1164.all;

library work;
use work.dma_test_pkg.all;

entity dma_test_tb is
end entity dma_test_tb;

architecture test_bench of dma_test_tb is
	signal tb_mclk : std_logic;                           -- Main system clock
	signal tb_puc_rst : std_logic;                        -- Main system reset

	signal tb_trigger : std_logic;                        -- Trigger the memory erasure

	signal tb_dma_dout : std_logic_vector(15 downto 0);   -- Direct Memory Access data output
	signal tb_dma_ready : std_logic;                      -- Direct Memory Access is complete
	signal tb_dma_resp : std_logic;                       -- Direct Memory Access response (0:Okay / 1:Error)

	signal tb_dma_addr : std_logic_vector(15 downto 1);  -- Direct Memory Access address
	signal tb_dma_din : std_logic_vector(15 downto 0);   -- Direct Memory Access data input
	signal tb_dma_en : std_logic;                        -- Direct Memory Access enable (high active)
	signal tb_dma_priority : std_logic;                  -- Direct Memory Access priority (0:low / 1:high)
	signal tb_dma_we : std_logic_vector(1 downto 0);     -- Direct Memory Access write byte enable (high active)

	signal simu_ended : boolean := false;
begin
	cut: dma_test
		port map (
			mclk => tb_mclk,
			puc_rst => tb_puc_rst,
	
			trigger => tb_trigger,
	
			dma_dout => tb_dma_dout,
			dma_ready => tb_dma_ready,
			dma_resp => tb_dma_resp,
	
			dma_addr => tb_dma_addr,
			dma_din => tb_dma_din,
			dma_en => tb_dma_en,
			dma_priority => tb_dma_priority,
			dma_we => tb_dma_we
		);

	p_mclk: process
	begin
		while (simu_ended = false) loop
			tb_mclk <= '0'; wait for 5 ns;
			tb_mclk <= '1'; wait for 5 ns;
		end loop;
		wait;
	end process p_mclk;

	p_testbench: process
	begin
		tb_puc_rst <= '0';

		wait until rising_edge(tb_mclk);

		tb_puc_rst <= '1' after 2 ns;
		tb_trigger <= '0' after 2 ns;
		tb_dma_dout <= (others => '0') after 2 ns;
		tb_dma_ready <= '0' after 2 ns;
		tb_dma_resp <= '0' after 2 ns;

		wait until rising_edge(tb_mclk);
		wait until rising_edge(tb_mclk);

		tb_puc_rst <= '0' after 2 ns;

		wait until rising_edge(tb_mclk);
		wait until rising_edge(tb_mclk);

		tb_trigger <= '1' after 2 ns;

		wait until rising_edge(tb_mclk);
		wait until rising_edge(tb_mclk);
		wait until rising_edge(tb_mclk);
		wait until rising_edge(tb_mclk);
		wait until rising_edge(tb_mclk);
		wait until rising_edge(tb_mclk);

		tb_dma_ready <= '1' after 2 ns;

		wait until rising_edge(tb_mclk);
		wait until rising_edge(tb_mclk);
		wait until rising_edge(tb_mclk);
		wait until rising_edge(tb_mclk);

		tb_dma_ready <= '0' after 2 ns;

		wait until rising_edge(tb_mclk);
		wait until rising_edge(tb_mclk);

		simu_ended <= true;
		wait;
	end process p_testbench;
end architecture test_bench;
