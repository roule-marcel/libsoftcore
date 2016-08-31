library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.srf05_pkg.all;

entity srf05_tb is
end entity srf05_tb;

architecture test_bench of srf05_tb is
	constant TB_IN_CLK_FREQ : positive := 24_000_000;
	constant TB_SENSOR_NUMBER : positive := 5;
	
	signal tb_clock : std_logic;
	signal tb_reset : std_logic;
	signal tb_trigger : std_logic;
	signal tb_echo : std_logic_vector(TB_SENSOR_NUMBER-1 downto 0);
	signal tb_echo_duration : reg_file_t(TB_SENSOR_NUMBER-1 downto 0);

	signal simu_ended : boolean := false;
begin
	cut: srf05
		generic map (
			IN_CLK_FREQ => TB_IN_CLK_FREQ,
			SENSOR_NUMBER => TB_SENSOR_NUMBER
		)
		port map (
			clock => tb_clock,
			reset => tb_reset,
			
			trigger => tb_trigger,
			echo => tb_echo,
			
			echo_duration=> tb_echo_duration
		);

	p_clock: process
	begin
		while (simu_ended = false) loop
			-- 24MHz
			tb_clock <= '0'; wait for 20.83 ns;
			tb_clock <= '1'; wait for 20.83 ns;
		end loop;
		wait;
	end process p_clock;

	p_testbench: process
	begin
		tb_reset <= '0';
		tb_echo <= (others => '0');

		wait until rising_edge(tb_clock);
		wait until rising_edge(tb_clock);

		tb_reset <= '1' after 2 ns;

		for i in 0 to 3 loop
			wait until rising_edge(tb_clock);
		end loop;

		tb_reset <= '0' after 2 ns;

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

		simu_ended <= true;
		wait;
	end process p_testbench;
end architecture test_bench;
