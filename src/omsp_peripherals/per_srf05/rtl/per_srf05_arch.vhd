library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.per_iface_pkg.all;
use work.per_srf05_pkg.all;
use work.srf05_pkg.all;

architecture rtl of per_srf05 is
	signal reg_file_wren : std_logic_vector(0 to SENSOR_NUMBER-1);
	signal reg_out : std_logic_vector(15 downto 0);
	signal reg_file_in : reg_file_t(0 to SENSOR_NUMBER-1);

	signal echo_duration : reg_file_unsigned_t(0 to SENSOR_NUMBER-1);
begin
	interface: per_iface
		generic map (
			-- Register base address (must be aligned to decoder bit width)
			BASE_ADDR => BASE_ADDR,
			-- Number of registers
			REG_NB => SENSOR_NUMBER
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
	
	sensor0: srf05
		generic map (
			IN_CLK_FREQ => IN_CLK_FREQ,
			SENSOR_NUMBER => SENSOR_NUMBER
		)
		port map (
			clock => mclk,
			reset => puc_rst,
			
			trigger => trigger,
			echo => echo,
			
			echo_duration => echo_duration
		);

	echo_duration_g: for i in 0 to SENSOR_NUMBER-1 generate
		reg_file_in(i) <= std_logic_vector(echo_duration(i));
	end generate echo_duration_g;
end architecture rtl;
