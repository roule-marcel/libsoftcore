library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.srf05_pkg.all;

architecture rtl of srf05 is
	-- SRF05 are trigged once every 50ms (20Hz)
	-- With an internal frequency of 1MHz, trigger and echo timer have to count to max 50k
   	-- It is ok for a 16bit architecture
	constant INTERNAL_CLK_FREQ : positive := 1_000_000;
	
	--------------------------------------------------------------------------------
	-- Constants for the trigger counter
	--------------------------------------------------------------------------------
	constant TRIG_FREQ : natural := 20; 									-- 20Hz
	constant TRIG_MAX : natural := INTERNAL_CLK_FREQ / TRIG_FREQ;			-- 50k
	constant TRIG_PULSE : natural := INTERNAL_CLK_FREQ * 10 / 1_000_000;	-- 10us

	signal internal_clk : std_logic;

	signal trig_counter : unsigned (15 downto 0) := x"0000";
	signal echo_counters : reg_file_t(SENSOR_NUMBER-1 downto 0);
	signal echo_old : std_logic_vector(echo'range);
begin
	internal_clk_p : process (clock, reset)
		variable clk_counter : natural range 0 to (IN_CLK_FREQ/INTERNAL_CLK_FREQ)/2-1 := 0;
	begin
		if (reset = '1') then
			internal_clk <= '0';
			clk_counter := 0;
		elsif rising_edge(clock) then
			if (clk_counter = (IN_CLK_FREQ/INTERNAL_CLK_FREQ)/2-1) then
				clk_counter := 0;
				internal_clk <= not internal_clk;
			else
				clk_counter := clk_counter + 1;
			end if;
		end if ;
	end process internal_clk_p;

	trig_counter_p : process (internal_clk, reset)
	begin
		if reset = '1' then
			trig_counter <= (others => '0');
		elsif rising_edge(internal_clk) then
			if trig_counter < TRIG_MAX then
				trig_counter <= trig_counter + 1;
			else
				trig_counter <= (others => '0');
			end if;
		end if;
	end process trig_counter_p;
	trigger <= '1' when trig_counter < TRIG_PULSE else '0';

	echo_counter_g : for i in 0 to SENSOR_NUMBER-1 generate
		echo_counter_p : process (internal_clk, reset)
		begin
			if (reset = '1') then
				echo_counters(i) <= (others => '0');
				echo_duration(i) <= (others => '0');
				echo_old(i) <= '0';
			elsif rising_edge(internal_clk) then
				echo_old(i) <= echo(i);

				if echo(i) = '1' then
					echo_counters(i) <= echo_counters(i) + 1;
				else
					echo_counters(i) <= (others => '0');
				end if;

				if echo(i) = '0' and echo_old(i) = '1' then
					echo_duration(i) <= echo_counters(i);
				end if;
			end if;
		end process echo_counter_p;
	end generate echo_counter_g;
end architecture rtl;
