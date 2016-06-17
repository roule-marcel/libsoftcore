library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture rtl of dma_test is
	signal trigger_reg : std_logic := '0';

	signal address : unsigned(15 downto 0) := x"E000";
begin
	dma_addr <= std_logic_vector(address(15 downto 1));
	dma_din <= std_logic_vector(address);

	p_trigger_reg: process(mclk, puc_rst)
	begin
		if (puc_rst = '1') then
			trigger_reg <= '0';
		elsif rising_edge(mclk) then
			if (trigger = '1') then
				trigger_reg <= '1';
			else
				if (address = x"F000") then
					trigger_reg <= '0';
				end if;
			end if;
		end if;
	end process p_trigger_reg;
	
	p_dma: process(mclk, puc_rst)
	begin
		if (puc_rst = '1') then
			dma_en <= '0';
			dma_priority <= '0';
			dma_we <= "00";

			address <= x"E000";
		elsif rising_edge(mclk) then
			if (trigger_reg = '1') then
				dma_en <= '1';
				dma_priority <= '1';
				dma_we <= "11";
				if (dma_ready = '1') then
					address <= address + 2;
				end if;
			end if;
		end if;
	end process p_dma;
end architecture rtl;
