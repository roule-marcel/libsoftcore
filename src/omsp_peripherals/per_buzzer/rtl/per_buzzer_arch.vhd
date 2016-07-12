library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.per_buzzer_pkg.all;
use work.per_iface_pkg.all;

architecture rtl of per_buzzer is
	signal reg_file_wren : std_logic_vector(0 to 0);
	signal reg_out : std_logic_vector(15 downto 0);
	signal reg_file_in : reg_file_t(0 to 0);

	signal period_wren : std_logic;

	signal reg_period : std_logic_vector(15 downto 0) := (others => '0');
	signal buzzer_reg : std_logic := '0';

	signal counter_reg : unsigned(15 downto 0) := (others => '0');
begin
	interface: per_iface
		generic map (
			-- Register base address (must be aligned to decoder bit width)
			BASE_ADDR => BASE_ADDR,
			-- Number of registers
			REG_NB => 1
		)
		port map (
			per_dout => per_dout,
	
			mclk => mclk,
			per_addr => per_addr,
			per_din => per_din,
			per_en => per_en,
			per_we => per_we,
			puc_rst => puc_rst,

			reg_file_wren => reg_file_wren,
			reg_out => reg_out,
			reg_file_in => reg_file_in
		);

	period_wren <= reg_file_wren(0);

	p_regs : process(puc_rst, mclk)
	begin
		if (puc_rst = '1') then
			reg_period <= (others => '0');
		elsif rising_edge(mclk) then
			if (period_wren = '1') then
				reg_period <= reg_out;
			end if;
		end if;
	end process p_regs;

	reg_file_in(0) <= reg_period;

	counter_p : process (mclk, puc_rst)
	begin
		if (puc_rst = '1') then
			counter_reg <= (others => '0');
		elsif rising_edge(mclk) then
			if ((counter_reg = unsigned(reg_period)) or (period_wren = '1')) then
				counter_reg <= (others => '0');
			else
				counter_reg <= counter_reg + 1;
			end if;
		end if;
	end process counter_p;

	buzzer_p : process (mclk, puc_rst)
	begin
		if (puc_rst= '1') then
			buzzer_reg <= '0';
		elsif rising_edge(mclk) then
			if (counter_reg = unsigned(reg_period)) then
				buzzer_reg <= not buzzer_reg;
			end if;
		end if;
	end process buzzer_p;

	buzzer <= 'Z' when reg_period = x"0000" else buzzer_reg;
end architecture rtl;
