library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ram16_pkg.all;
use work.log2_pkg.all;
use work.init_ram16_pkg.all;

architecture rtl of ram16 is
	signal ram8_l : ram8_t(0 to DEPTH-1) := init_ram8(DEPTH,'l', INIT_FILE) ; 
	signal ram8_h : ram8_t(0 to DEPTH-1) := init_ram8(DEPTH,'h', INIT_FILE); 
	signal rd_addr : std_logic_vector(addr'range);
begin
	p_write : process(clk) is
	begin
		if rising_edge(clk) then
			if cen = '0' then
				if (wen(0) = '0') then
					ram8_l(to_integer(unsigned(addr)))<= din(7 downto 0);
				end if;
				if (wen(1) = '0') then
					ram8_h(to_integer(unsigned(addr)))<= din(15 downto 8);
				end if;
--				for byte_index in 0 to 1 loop
--					if (wen(byte_index) = '0' ) then
--						ram16(to_integer(unsigned(addr)))(byte_index*8+7 downto byte_index*8) <= din(byte_index*8+7 downto byte_index*8);
--					end if;
--				end loop;

--				if (wen = "00") then
--					ram16(to_integer(unsigned(addr))) <= din;
--				end if;
			end if;
			
			rd_addr <= addr;
		end if;
	end process p_write;

--	p_read : process(clk) is
--	begin
--		if rising_edge(clk) then
----			if cen = '0' then
--			rd_addr <= addr;
----			end if;
--		end if;
--	end process p_read;
	dout <= ram8_h(to_integer(unsigned(rd_addr))) & ram8_l(to_integer(unsigned(rd_addr)));
end architecture rtl;
