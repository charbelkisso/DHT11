library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity clk_400hz is
	
	port (
		clk_in : in std_logic ;   -- clock source of 1Mhz
		reset : in std_logic;
		clk_out : out std_logic
	);

end clk_400hz;


architecture rtl of clk_400hz is
	
	signal counter : std_logic_vector (23 downto 0);
	signal temp : std_logic;

begin 

	process (clk_in, reset)
	begin
		
		if ( reset = '1') then
				
			temp <= '0';
		elsif (falling_edge(clk_in)) then

			if ( counter =	X"4E1" ) then			
				counter <= X"000000";
				temp <= not temp;
			else
				counter <= counter + 1;
			end if;
		end if;
	end process;
	
	clk_out <= temp;
	
end rtl;