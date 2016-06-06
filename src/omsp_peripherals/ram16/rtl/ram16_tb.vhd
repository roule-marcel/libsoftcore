library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.log2_pkg.all;
use work.ram16_pkg.all;

entity ram16_tb is
end entity ram16_tb;

--entity ram16 is
--	generic (
--		DEPTH : positive := 2048
--	);
--	port (
--		clk : in std_logic;                                      -- Memory clock
--		cen : in std_logic;                                      -- Memory chip enable (low active)
--		addr : in std_logic_vector(log2ceil(DEPTH)-1 downto 0);  -- Memory address
--		din : in std_logic_vector(15 downto 0);                  -- Memory data input
--		wen : in std_logic_vector(1 downto 0);                   -- Memory write enable (low active)
--		dout : out std_logic_vector(15 downto 0)                 -- Memory data output
--	);
--end entity ram16;
architecture test_bench of ram16_tb is
	constant TB_DEPTH : positive := 16;

	signal tb_clk : std_logic;                                      -- Memory clock
	signal tb_cen : std_logic;                                      -- Memory chip enable (low active)
	signal tb_addr : std_logic_vector(log2ceil(TB_DEPTH)-1 downto 0);  -- Memory address
	signal tb_din : std_logic_vector(15 downto 0);                  -- Memory data input
	signal tb_wen : std_logic_vector(1 downto 0);                   -- Memory write enable (low active)
	signal tb_dout : std_logic_vector(15 downto 0);                 -- Memory data output

	signal simu_ended : boolean := false;
begin
	cut: ram16
		generic map (
			DEPTH => TB_DEPTH
		)
		port map (
			clk => tb_clk,
			cen => tb_cen,
			addr => tb_addr,
			din => tb_din,
			wen => tb_wen,
			dout => tb_dout
		);

	p_clk: process
	begin
		while (simu_ended = false) loop
			tb_clk <= '0'; wait for 5 ns;
			tb_clk <= '1'; wait for 5 ns;
		end loop;
		wait;
	end process p_clk;

	p_testbench: process
		procedure mem_write (
			mem_addr : integer;
			mem_din : std_logic_vector(15 downto 0)
		) is
		begin
			tb_addr <= std_logic_vector(to_unsigned(mem_addr, log2ceil(TB_DEPTH))) after 2 ns;
			tb_din <= mem_din after 2 ns;
			tb_cen <= '0' after 2 ns;
			tb_wen <= "00" after 2 ns;

			wait until rising_edge(tb_clk);

			tb_addr <= (others => '0') after 2 ns;
			tb_din <= (others => '0') after 2 ns;
			tb_cen <= '1' after 2 ns;
			tb_wen <= "11" after 2 ns;
		end procedure mem_write;

		procedure mem_read (
			mem_addr : integer
		) is
		begin
			tb_addr <= std_logic_vector(to_unsigned(mem_addr, log2ceil(TB_DEPTH))) after 2 ns;
			tb_cen <= '0' after 2 ns;
			tb_wen <= "11" after 2 ns;

			wait until rising_edge(tb_clk);

			tb_addr <= (others => '0') after 2 ns;
			tb_cen <= '1' after 2 ns;
			tb_wen <= "11" after 2 ns;
		end procedure mem_read;
	begin
		tb_cen <= '1';
		tb_addr <= (others => '0');
		tb_din <= (others => '0');
		tb_wen <= "11";

		wait until rising_edge(tb_clk);

		for i in 0 to TB_DEPTH-1 loop
			mem_write(i, std_logic_vector(to_unsigned(i, 16)));
		end loop;

		wait until rising_edge(tb_clk);

		for i in 0 to TB_DEPTH-1 loop
			mem_read(i);
		end loop;

		wait until rising_edge(tb_clk);

		simu_ended <= true;
		wait;
	end process p_testbench;
end architecture test_bench;
