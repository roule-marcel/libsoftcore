library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.uart_bootloader_pkg.all;
use work.per_iface_pkg.all;
use work.uart2BusTop_pkg.all;

architecture rtl of uart_bootloader is
	signal reg_file_wren : std_logic_vector(0 to 3);
	signal reg_out : std_logic_vector(15 downto 0);
	signal reg_file_in : reg_file_t(0 to 3);

	signal ctrl_wren : std_logic;
	signal address_wren : std_logic;
	signal freq_wren : std_logic;
	signal limit_wren : std_logic;

	signal reg_ctrl : std_logic_vector(15 downto 0);
	signal reg_address : std_logic_vector(15 downto 0);
	signal reg_freq : std_logic_vector(15 downto 0);
	signal reg_limit : std_logic_vector(15 downto 0);

	signal address : unsigned(15 downto 0);

	signal rxData : std_logic_vector(7 downto 0);
	signal newRxData : std_logic;
begin
	interface: per_iface
		generic map (
			-- Register base address (must be aligned to decoder bit width)
			BASE_ADDR => BASE_ADDR,
			-- Number of registers
			REG_NB => 4
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

	ctrl_wren <= reg_file_wren(0);
	address_wren <= reg_file_wren(1);
	freq_wren <= reg_file_wren(2);
	limit_wren <= reg_file_wren(3);

	p_regs : process(puc_rst, mclk)
	begin
		if (puc_rst = '1') then
			reg_ctrl <= (others => '0');
			reg_address <= (others => '0');
			reg_freq <= (others => '0');
			reg_limit <= (others => '0');
		elsif rising_edge(mclk) then
			if (ctrl_wren = '1') then
				reg_ctrl <= reg_out;
			end if;
			if (address_wren = '1') then
				reg_address <= reg_out;
			end if;
			if (freq_wren = '1') then
				reg_freq <= reg_out;
			end if;
			if (limit_wren = '1') then
				reg_limit <= reg_out;
			end if;
		end if;
	end process p_regs;

	reg_file_in(0) <= reg_ctrl;
	reg_file_in(1) <= reg_address;
	reg_file_in(2) <= reg_freq;
	reg_file_in(3) <= reg_limit;

	uart0: uartTop
		port map (
			clr => puc_rst,
			clk => mclk,
			
			serIn => uart_rxd,
			serOut => open,
			
			txData => (others => '0'),
			newTxData => '0',
			txBusy => open,
			rxData => rxData,
			newRxData => newRxData,
			
			baudFreq => reg_freq(11 downto 0),
			baudLimit => reg_limit(15 downto 0),
			baudClk => open
		);

	p_dma: process(mclk, puc_rst)
	begin
		if (puc_rst = '1') then
			dma_en <= '0';
			dma_priority <= '0';
			dma_din <= (others => '0');

			address <= (others => '0');
		elsif rising_edge(mclk) then
			if (reg_ctrl(0) = '0') then
				address <= unsigned(reg_address);
			else
				dma_priority <= '1';
				if (newRxData) then
					dma_en <= '1';
					dma_din <= rxData & rxData;
				end if;
				if (dma_ready = '1') then
					address <= address + 1;
					dma_en <= '0';
				end if;
			end if;
		end if;
	end process p_dma;

	dma_we(0) <= '1' when address(0) = '0' else '0';
	dma_we(1) <= '1' when address(0) = '1' else '0';
   	dma_addr <= std_logic_vector(address(15 downto 1));
end architecture rtl;
