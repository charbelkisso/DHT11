library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity strobe is
	port(	
		clk: in std_logic; 			-- 1hz clock input
		reset : in std_logic;
		strobe_o: out std_logic
	);
end strobe;


architecture rtl of strobe is
	
	signal counter : std_logic_vector (7 downto 0);
	
	type state_type is (a, b);
	signal state : state_type := a;

begin 
	
	process(clk, reset)
	begin
		if ( reset = '1') then
			state <= a;
		elsif (falling_edge(clk)) then
			case state is 
				
				when a =>
					if ( counter = X"3B") then
						state <= b;
						counter <= X"00";
					else
						counter <= counter + 1;
					end if;
					
				when b =>
					if ( counter = X"01") then
						state <= a;
						counter <= X"00";
					else
						counter <= counter + 1;
					end if;				
			end case;
		end if;
	end process;
	
	
	process(state)
	begin
		case state is
			when a =>
				strobe_o <= '0';
			when b =>
				strobe_o <= '1';
		end case;
	
	end process;

end rtl;