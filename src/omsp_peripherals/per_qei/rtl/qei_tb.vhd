library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.qei_pkg.all;

entity qei_tb is
end entity qei_tb;

architecture testbench of qei_tb is
	constant TB_STEPS_WIDTH : positive := 32;

	signal tb_clock : std_logic;
	signal tb_reset : std_logic;

	signal tb_qei_a : std_logic;
	signal tb_qei_b : std_logic;

	signal tb_steps : signed(TB_STEPS_WIDTH-1 downto 0);

	signal simu_ended : boolean := false;
begin
	cut: qei
		generic map (
			STEPS_WIDTH => TB_STEPS_WIDTH
		)
		port map (
			clock => tb_clock,
			reset => tb_reset,
	
			qei_a => tb_qei_a,
			qei_b => tb_qei_b,
	
			steps => tb_steps
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

		wait until rising_edge(tb_clock);
		wait until rising_edge(tb_clock);

		tb_reset <= '1' after 2 ns;

		for i in 0 to 3 loop
			wait until rising_edge(tb_clock);
		end loop;

		tb_reset <= '0' after 2 ns;

		for i in 0 to 9 loop
			tb_qei_a <= '0';
			tb_qei_b <= '0';
			wait for 2 ms;
			tb_qei_a <= '1';
			tb_qei_b <= '0';
			wait for 2 ms;
			tb_qei_a <= '1';
			tb_qei_b <= '1';
			wait for 2 ms;
			tb_qei_a <= '0';
			tb_qei_b <= '1';
			wait for 2 ms;
		end loop;

		for i in 0 to 9 loop
			tb_qei_a <= '0';
			tb_qei_b <= '0';
			wait for 2 ms;
			tb_qei_a <= '0';
			tb_qei_b <= '1';
			wait for 2 ms;
			tb_qei_a <= '1';
			tb_qei_b <= '1';
			wait for 2 ms;
			tb_qei_a <= '1';
			tb_qei_b <= '0';
			wait for 2 ms;
		end loop;

		simu_ended <= true;
		wait;
	end process p_testbench;
end architecture testbench;
