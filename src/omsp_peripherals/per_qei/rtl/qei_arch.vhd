library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.qei_pkg.all;

architecture rtl of qei is
	signal steps_reg : signed (steps'range) := (others => '0');
	signal qei_a_reg : std_logic_vector(2 downto 0) := (others => '0');
	signal qei_b_reg : std_logic_vector(2 downto 0) := (others => '0');

	signal count_enable : std_logic;
	signal count_direction : std_logic;
begin
	steps <= steps_reg;

	p_qei_regs : process(clock, reset)
	begin
		if (reset = '1') then
			qei_a_reg <= (others => '0');
			qei_b_reg <= (others => '0');
		elsif rising_edge(clock) then
			qei_a_reg <= qei_a_reg(1 downto 0) & qei_a;
			qei_b_reg <= qei_b_reg(1 downto 0) & qei_b;
		end if;
	end process p_qei_regs;

	count_enable <= qei_a_reg(1) xor qei_a_reg(2) xor qei_b_reg(1) xor qei_b_reg(2);
	count_direction <= qei_a_reg(1) xor qei_b_reg(2);
	
	p_steps_reg : process(clock, reset)
	begin
		if (reset = '1') then
			steps_reg <= (others => '0');
		elsif rising_edge(clock) then
			if (count_enable = '1') then
				if (count_direction = '1') then
					steps_reg <= steps_reg + 1;
				else
					steps_reg <= steps_reg - 1;
				end if;
			end if;
		end if;
	end process p_steps_reg;
end architecture rtl;
