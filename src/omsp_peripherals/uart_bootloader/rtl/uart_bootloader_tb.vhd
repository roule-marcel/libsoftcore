library ieee;
use ieee.std_logic_1164.all;

library work;
use work.uart_bootloader_pkg.all;

use work.helpers_pkg.all;

entity uart_bootloader_tb is
end entity uart_bootloader_tb;

architecture testbench of uart_bootloader_tb is
	constant TB_BASE_ADDR : std_logic_vector(14 downto 0) := 15x"0100";

	signal tb_per_dout : std_logic_vector(15 downto 0);  -- Peripheral data output

	signal tb_mclk : std_logic;                           -- Main system clock
	signal tb_per_addr : std_logic_vector(13 downto 0);   -- Peripheral address
	signal tb_per_din : std_logic_vector(15 downto 0);    -- Peripheral data input
	signal tb_per_en : std_logic;                         -- Peripheral enable (high active)
	signal tb_per_we : std_logic_vector(1 downto 0);      -- Peripheral write enable (high active)
	signal tb_puc_rst : std_logic;                        -- Main system reset

	signal tb_dma_dout : std_logic_vector(15 downto 0);   -- Direct Memory Access data output
	signal tb_dma_ready : std_logic;                      -- Direct Memory Access is complete
	signal tb_dma_resp : std_logic;                       -- Direct Memory Access response (0:Okay / 1:Error)

	signal tb_dma_addr : std_logic_vector(15 downto 1);  -- Direct Memory Access address
	signal tb_dma_din : std_logic_vector(15 downto 0);   -- Direct Memory Access data input
	signal tb_dma_en : std_logic;                        -- Direct Memory Access enable (high active)
	signal tb_dma_priority : std_logic;                  -- Direct Memory Access priority (0:low / 1:high)
	signal tb_dma_we : std_logic_vector(1 downto 0);     -- Direct Memory Access write byte enable (high active)

	signal tb_cpu_reset_n : std_logic;

	signal tb_uart_rxd : std_logic;

	signal simu_ended : boolean := false;
begin
	cut: uart_bootloader
		generic map (
			-- Register base address (must be aligned to decoder bit width)
			BASE_ADDR => TB_BASE_ADDR
		)
		port map (
			-- Memory mapped peripheral side
			-- Configure Code memory range and start re-programmation
			per_dout => tb_per_dout,
	
			mclk => tb_mclk,
			per_addr => tb_per_addr,
			per_din => tb_per_din,
			per_en => tb_per_en,
			per_we => tb_per_we,
			puc_rst => tb_puc_rst,
	
			-- DMA side
			-- Actually re-program the MCU
			dma_dout => tb_dma_dout,
			dma_ready => tb_dma_ready,
			dma_resp => tb_dma_resp,
	
			dma_addr => tb_dma_addr,
			dma_din => tb_dma_din,
			dma_en => tb_dma_en,
			dma_priority => tb_dma_priority,
			dma_we => tb_dma_we,

			cpu_reset_n => tb_cpu_reset_n,
	
			uart_rxd => tb_uart_rxd
		);

	p_mclk: process
	begin
		while (simu_ended = false) loop
			-- 24 MHz
			tb_mclk <= '0'; wait for 20.833 ns;
			tb_mclk <= '1'; wait for 20.833 ns;
		end loop;
		wait;
	end process p_mclk;

	p_testbench: process
		procedure per_write (
			per_addr : std_logic_vector(14 downto 0);
			per_din : std_logic_vector(15 downto 0)
		) is
		begin
			tb_per_addr <= per_addr(14 downto 1) after 2 ns;
			tb_per_din <= per_din after 2 ns;
			tb_per_en <= '1' after 2 ns;
			tb_per_we <= "11" after 2 ns;

			wait until rising_edge(tb_mclk);

			tb_per_addr <= (others => '0') after 2 ns;
			tb_per_din <= (others => '0') after 2 ns;
			tb_per_en <= '0' after 2 ns;
			tb_per_we <= "00" after 2 ns;
		end procedure per_write;

		procedure per_read (
			per_addr : std_logic_vector(14 downto 0)
		) is
		begin
			tb_per_addr <= per_addr(14 downto 1) after 2 ns;
			tb_per_en <= '1' after 2 ns;
			tb_per_we <= "00" after 2 ns;

			wait until rising_edge(tb_mclk);

			tb_per_addr <= (others => '0') after 2 ns;
			tb_per_en <= '0' after 2 ns;
			tb_per_we <= "00" after 2 ns;
		end procedure per_read;

		procedure dma_ack is
		begin
			while (tb_dma_en = '0') loop
				wait until rising_edge(tb_mclk);
			end loop;

			wait until rising_edge(tb_mclk);
			tb_dma_ready <= '1' after 2 ns;
			wait until rising_edge(tb_mclk);
			tb_dma_ready <= '0' after 2 ns;
		end procedure dma_ack;
	begin
		tb_puc_rst <= '0';

		wait until rising_edge(tb_mclk);

		tb_puc_rst <= '1';

		tb_per_addr <= (others => '0');
		tb_per_din <= (others => '0');
		tb_per_en <= '0';
		tb_per_we <= "00";

		tb_dma_dout <= (others => '0');
		tb_dma_ready <= '0';
		tb_dma_resp <= '0';

		tb_uart_rxd <= '0';

		for i in 0 to 3 loop
			wait until rising_edge(tb_mclk);
		end loop;


		tb_puc_rst <= '0' after 2 ns;
		tb_uart_rxd <= '1' after 2 ns;

		for i in 0 to 3 loop
			wait until rising_edge(tb_mclk);
		end loop;

		-- ADDRESS
		per_write(15x"0102", x"E000");
		-- BAUD FREQ = 16*baud_rate / gcd(global_clock_freq, 16*baud_rate) = 16*115200/38400 = 48 = 0x30
		per_write(15x"0104", x"0030");
		-- BAUD LIMIT = (global_clock_freq / gcd(global_clock_freq, 16*baud_rate)) - baud_freq = 24000000/38400 - 48 = 577 = 0x241
		per_write(15x"0106", x"0241");
		-- EN
		per_write(15x"0100", x"0001");

		for i in 0 to 3 loop
			wait until rising_edge(tb_mclk);
		end loop;

        sendSerial(10, 115200.0, 0, 1.0, 7, 0.0, tb_uart_rxd);
		dma_ack;
        sendSerial(11, 115200.0, 0, 1.0, 7, 0.0, tb_uart_rxd);
		dma_ack;
        sendSerial(12, 115200.0, 0, 1.0, 7, 0.0, tb_uart_rxd);
		dma_ack;
        sendSerial(13, 115200.0, 0, 1.0, 7, 0.0, tb_uart_rxd);
		dma_ack;
        sendSerial(14, 115200.0, 0, 1.0, 7, 0.0, tb_uart_rxd);
		dma_ack;
        sendSerial(15, 115200.0, 0, 1.0, 7, 0.0, tb_uart_rxd);
		dma_ack;

		for i in 0 to 3 loop
			wait until rising_edge(tb_mclk);
		end loop;
	
		simu_ended <= true;
		wait;
	end process p_testbench;
end architecture testbench;
