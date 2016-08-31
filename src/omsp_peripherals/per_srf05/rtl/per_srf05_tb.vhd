library ieee;
use ieee.std_logic_1164.all;

library work;
use work.per_srf05_pkg.all;

entity per_srf05_tb is
end entity per_srf05_tb;

architecture testbench of per_srf05_tb is
	constant TB_BASE_ADDR : std_logic_vector(14 downto 0) := 15x"0100";
	constant TB_IN_CLK_FREQ : positive := 24_000_000;
	constant TB_SENSOR_NUMBER : positive := 5;

	signal tb_per_dout : std_logic_vector(15 downto 0);  -- Peripheral data output
	signal tb_mclk : std_logic;                           -- Main system clock
	signal tb_per_addr : std_logic_vector(13 downto 0);   -- Peripheral address
	signal tb_per_din : std_logic_vector(15 downto 0);    -- Peripheral data input
	signal tb_per_en : std_logic;                         -- Peripheral enable (high active)
	signal tb_per_we : std_logic_vector(1 downto 0);      -- Peripheral write enable (high active)
	signal tb_puc_rst : std_logic;                        -- Main system reset
	signal tb_trigger : std_logic;
	signal tb_echo : std_logic_vector(TB_SENSOR_NUMBER-1 downto 0);

	signal simu_ended : boolean := false;
begin
	cut: per_srf05
		generic map (
			-- Register base address (must be aligned to decoder bit width)
			BASE_ADDR => TB_BASE_ADDR,
			IN_CLK_FREQ => TB_IN_CLK_FREQ,
			SENSOR_NUMBER => TB_SENSOR_NUMBER
		)
		port map (
			per_dout => tb_per_dout,
	
			mclk => tb_mclk,
			per_addr => tb_per_addr,
			per_din => tb_per_din,
			per_en => tb_per_en,
			per_we => tb_per_we,
			puc_rst => tb_puc_rst,
	
			trigger => tb_trigger,
			echo => tb_echo
		);

	p_clock: process
	begin
		while (simu_ended = false) loop
			-- 24MHz
			tb_mclk <= '0'; wait for 20.83 ns;
			tb_mclk <= '1'; wait for 20.83 ns;
		end loop;
		wait;
	end process p_clock;

	p_testbench: process
		procedure per_read (
			per_addr : std_logic_vector(14 downto 0)
		) is
		begin
			wait until rising_edge(tb_mclk);
			wait until rising_edge(tb_mclk);

			tb_per_addr <= per_addr(14 downto 1) after 2 ns;
			tb_per_en <= '1' after 2 ns;
			tb_per_we <= "00" after 2 ns;

			wait until rising_edge(tb_mclk);

			tb_per_addr <= (others => '0') after 2 ns;
			tb_per_en <= '0' after 2 ns;
			tb_per_we <= "00" after 2 ns;
		end procedure per_read;
	begin
		tb_puc_rst <= '0';
		tb_per_addr <= (others => '0');
		tb_per_din <= (others => '0');
		tb_per_en <= '0';
		tb_per_we <= (others => '0');

		tb_echo <= (others => '0');

		tb_puc_rst <= '1' after 2 ns;

		for i in 0 to 9 loop
			wait until rising_edge(tb_mclk);
		end loop;

		tb_puc_rst <= '0' after 2 ns;

		for i in 0 to 9 loop
			wait until rising_edge(tb_mclk);
		end loop;

		for j in 0 to 1 loop
			wait until tb_trigger = '1';
			wait until tb_trigger = '0';

			wait for 1 ms;
			tb_echo <= (others => '1');
			wait for 10 ms;

			for i in 0 to TB_SENSOR_NUMBER-1 loop
				tb_echo(i) <= '0';
				wait for 2 ms;
			end loop;
		end loop;

		per_read(15x"0100");
		wait until rising_edge(tb_mclk);
		per_read(15x"0102");
		wait until rising_edge(tb_mclk);
		per_read(15x"0104");
		wait until rising_edge(tb_mclk);
		per_read(15x"0106");
		wait until rising_edge(tb_mclk);
		per_read(15x"0108");
		wait until rising_edge(tb_mclk);

		simu_ended <= true;
		wait;
	end process p_testbench;
end architecture testbench;
