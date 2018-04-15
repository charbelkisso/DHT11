library ieee;

use ieee.std_logic_1164.all;


entity clock is 
	port (
		clk_out : out std_logic 
	);
end clock;

architecture rtl of clock is
	signal temp : std_logic := '0';

begin

	process 
	begin
		temp <= not temp;
		wait for 10 ns;
	end process;
	clk_out <= temp;
	
	
end rtl;
