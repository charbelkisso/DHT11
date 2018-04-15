library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity clk_src is

	port(
	
		clk_in : in std_logic;     -- clock source in 50Mhz	
		rst : in std_logic;        -- reset 
		clk_1Mhz : out std_logic   -- 1 Mhz clock source, period 1us		
	);
	
end clk_src;


architecture rtl of clk_src is 

	signal counter : std_logic_vector (7 downto 0) := "00000000";
	signal temp : std_logic := '0';
	
begin 
	
	clk_1Mhz_process:process (clk_in, rst)	
	begin
	
		if (rst = '1') then
			temp <= '0';
		elsif (falling_edge(clk_in)) then
		
			if ( counter =	"0011000" ) then			
				counter <= "00000000";
				temp <= not temp;
			else
				counter <= counter + 1;
			end if;
		end if;
		
	end process clk_1Mhz_process;
	clk_1Mhz <= temp;
	
	
end rtl;