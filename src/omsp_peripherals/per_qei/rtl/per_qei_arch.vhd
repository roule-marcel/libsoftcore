library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.per_iface_pkg.all;
use work.per_qei_pkg.all;
use work.qei_pkg.all;

architecture rtl of per_qei is
	signal reg_file_wren : std_logic_vector(0 to 1);
	signal reg_out : std_logic_vector(15 downto 0);
	signal reg_file_in : reg_file_t(0 to 1);

	signal steps: signed(31 downto 0);
begin
	reg_file_in(0) <= std_logic_vector(steps(31 downto 16));
	reg_file_in(1) <= std_logic_vector(steps(15 downto 0));

	interface: per_iface
		generic map (
			-- Register base address (must be aligned to decoder bit width)
			BASE_ADDR => BASE_ADDR,
			-- Number of registers
			REG_NB => 2
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

	qei0: qei
		generic map (
			STEPS_WIDTH => 32
		)
		port map (
			clock => mclk,
			reset => puc_rst,
	
			qei_a => qei_a,
			qei_b => qei_b,
	
			steps => steps
		);
end architecture rtl;
