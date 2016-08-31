library ieee;
use ieee.std_logic_1164.all;

library work;
use work.per_buzzer_pkg.all;

entity per_buzzer_tb is
end entity per_buzzer_tb;

architecture testbench of per_buzzer_tb is
--	constant MCLK_FREQ : real := 24_000_000;

	constant TB_BASE_ADDR : std_logic_vector(14 downto 0) := 15x"0100";

	signal tb_per_dout : std_logic_vector(15 downto 0);   -- Peripheral data output
	signal tb_mclk : std_logic;                           -- Main system clock
	signal tb_per_addr : std_logic_vector(13 downto 0);   -- Peripheral address
	signal tb_per_din : std_logic_vector(15 downto 0);    -- Peripheral data input
	signal tb_per_en : std_logic;                         -- Peripheral enable (high active)
	signal tb_per_we : std_logic_vector(1 downto 0);      -- Peripheral write enable (high active)
	signal tb_puc_rst : std_logic;                        -- Main system reset

	signal tb_buzzer : std_logic;

	signal simu_ended : boolean := false;

begin
	-- @0x0180 -> 0x0187
	cut: per_buzzer
		generic map (
			-- Register base address (must be aligned to decoder bit width)
			BASE_ADDR => TB_BASE_ADDR
		)
		port map (
			per_dout => tb_per_dout,
	
			mclk => tb_mclk,
			per_addr => tb_per_addr,
			per_din => tb_per_din,
			per_en => tb_per_en,
			per_we => tb_per_we,
			puc_rst => tb_puc_rst,

			buzzer => tb_buzzer
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
	begin
		tb_puc_rst <= '0';

		tb_per_addr <= (others => '0');
		tb_per_din <= (others => '0');
		tb_per_en <= '0';
		tb_per_we <= (others => '0');

		tb_puc_rst <= '1' after 2 ns;

		for i in 0 to 9 loop
			wait until rising_edge(tb_mclk);
		end loop;

		tb_puc_rst <= '0' after 2 ns;

		for i in 0 to 9 loop
			wait until rising_edge(tb_mclk);
		end loop;

		per_write(15x"0100", x"0080");
		per_read(15x"0100");

		for i in 0 to 1024 loop
			wait until rising_edge(tb_mclk);
		end loop;

		per_write(15x"0100", x"0000");
		per_read(15x"0100");

		for i in 0 to 1024 loop
			wait until rising_edge(tb_mclk);
		end loop;
		
		simu_ended <= true;
		wait;
	end process p_testbench;
end architecture testbench;