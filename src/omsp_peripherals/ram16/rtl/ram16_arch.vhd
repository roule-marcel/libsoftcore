library ieee;
use ieee.std_logic_1164.all;

library work;
use work.log2_pkg.all;

--entity ram16 is
--	generic (
--		DEPTH : positive := 2048
--	);
--	port (
--		clk : std_logic;
--		cen : std_logic;
--		addr : std_logic_vector(log2ceil(DEPTH)-1 downto 0);
--		dout : std_logic_vector(15 downto 0);
--		din : std_logic_vector(15 downto 0);
--		wen : std_logic_vector(1 downto 0);
--	);
--end entity ram16;
architecture rtl of ram16 is
	type ram16_t is array (natural range <>) of std_logic_vector(15 downto 0);
	signal ram16 : ram16_t(0 to DEPTH-1); 
	signal rd_addr : std_logic_vector(addr'range);
begin
	p_write : process(clk) is
	begin
		if rising_edge(clk) then
			if cen = '0' then
--				if (wen(0) = '0') then
--					s_ram_l(to_integer(unsigned(addr)))<= din(7 downto 0);
--				end if;
--				if (wen(1) = '0') then
--					s_ram_h(to_integer(unsigned(addr)))<= din(15 downto 8);
--				end if;
				for byte_index in 0 to 1 loop
					if (wen(byte_index) = '0' ) then
						ram16(to_integer(unsigned(addr)))(byte_index*8+7 downto byte_index*8) <= din(byte_index*8+7 downto byte_index*8);
					end if;
				end loop;
			end if;
		end if;
	end process p_write;

	p_read : process(clk) is
	begin
		if rising_edge(clk) then
--			if cen = '0' then
			rd_addr <= addr;
--			end if;
		end if;
	end process p_read;
	dout <= s_ram_h(to_integer(unsigned(rd_addr))) & s_ram_l(to_integer(unsigned(rd_addr)));
end architecture rtl;
