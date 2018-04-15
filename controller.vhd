library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity controller is 
	
	port(
			clk 				: in 		std_logic;								-- 1Mhz Clock, period 1us
			reset 			: in 		std_logic;								-- reset signal
			strobe 			: in 		std_logic;								-- strobe signal
			data 				: inout 	std_logic;								-- 1-wire data
			result_ready	: out 	std_logic;								-- telling where is the result is ready or not
			result 			: out 	std_logic_vector (15 downto 0)	-- humidity data to LCD
	);
	
end controller;


architecture rtl of controller is
	
	--- 	internal data signal
	signal 	int_data_sig 		: std_logic;
	
	---	state machine for hand shaking
	type 		state_dht11_type is (	
													idle, 			-- idle state
													wait_strobe, 	-- wait for incoming storbe
													start_18ms, 	-- configure the timer, to count upto 18ms 
													end_18ms, 		-- timing and apply low value on the data wire
													start_20us,		-- configure the timer, 
													end_20us, 		-- timing and apply high value on the data wire, and wait for falling edge
													start_80us_1,
													end_80us_1,
													start_80us_2,
													end_80us_2,
													start_wait_rising,
													start_wait_falling,
													end_wait_falling,
													register_0,
													register_1,
													error_state,
													end_state
												);
												
	signal 	state_dht11 	: state_dht11_type;
	signal 	state_data_o 	: std_logic;
	signal 	data_ready 		: std_logic;
	
	---  	counter time signals
	signal	counter_time 		: std_logic_vector (23 downto 0);   -- the time counter
	signal	time_init 			: std_logic;								-- init signal
	signal	start_count			: std_logic;								-- start signal
	signal 	count_value			: std_logic_vector (23 downto 0);	-- count to specific value
	signal 	count_end			: std_logic;                        -- end signal
	
	---	compare signals
	signal 	compare_value		: std_logic_vector (7 downto 0);		-- compare count value, since all the values between 20 and 80 us
	signal 	margin				: std_logic_vector (7 downto 0);    -- allowed error margin
	signal 	compare_result		: std_logic;								-- when 1 the time is correct, when 0 is not
	
	--- 	shift register signals
	signal 	register_full		: std_logic;
	signal 	register_init 		: std_logic;
	signal	register_count		: std_logic_vector (7  downto 0);
	signal	enable_register	: std_logic;
	signal	data_register		: std_logic_vector (39 downto 0);
	
	---	edge detector signals
	signal 	rising, falling 	: std_logic;
	signal 	d_input				: std_logic_vector (1 downto 0);
	
begin 

	
	
	result_ready <= data_ready;
	
	shift_register_process:process(clk,reset)
	begin
		
		if(reset = '1') then
			register_full <= '0';
			register_count <= X"00";
			data_register <= X"0000000000";
			
		elsif (rising_edge(clk)) then
			if ( enable_register = '1') then
				if (register_count < 38) then
					data_register(39 downto 1) <= data_register (38 downto 0);
					data_register(0) <= state_data_o;

				elsif (register_count = 38 ) then
					data_register(39 downto 1) <= data_register (38 downto 0);
					data_register(0) <= state_data_o;
					register_full <= '1';
				end if;
				
			elsif(register_init = '1') then
				register_full <= '0';
				register_count <= X"00";
			end if;
		
		end if;
	
	end process shift_register_process;
	
	
	
	dht11_process: process(clk, reset)
	begin
	
		if ( reset = '1') then
			
			state_dht11 <= idle;
			
		elsif (rising_edge (clk)) then
			
			case state_dht11 is
			
				when idle => 
					state_dht11 <= wait_strobe;
					
				when wait_strobe =>
					if (strobe = '1') then
						state_dht11 <= start_18ms;
					else 
						state_dht11 <= wait_strobe;
					end if;
					
				when start_18ms =>
					state_dht11 <= end_18ms;
				
				when end_18ms =>
					if (count_end = '1') then
						state_dht11 <= start_20us;
					else
						state_dht11 <= end_18ms;
					end if;
					
				when start_20us =>
					state_dht11 <= end_20us;
					
				when end_20us =>
					if compare_result = '1' then
						if falling = '1' then
							state_dht11 <= start_80us_1;
						end if;
					else
						if counter_time >= compare_value + margin then
							state_dht11 <= error_state;
						else
							state_dht11 <= end_20us;
						end if;
					end if;
					
				when start_80us_1 =>
					state_dht11 <= end_80us_1;
					
				when end_80us_1 =>
					if compare_result = '1' then
						if rising = '1' then
							state_dht11 <= start_80us_2;
						end if;
					else
						if counter_time > compare_value + margin then
							state_dht11 <= error_state;
						else
							state_dht11 <= end_80us_1;
						end if;
					end if;
					
				when start_80us_2 =>
					state_dht11 <= end_80us_2;
					
				when end_80us_2 =>
					if compare_result = '1' then
						if falling = '1' then
							state_dht11 <= start_wait_rising;
						end if;
					else
						if counter_time > compare_value + margin then
							state_dht11 <= error_state;
						else
							state_dht11 <= end_80us_2;
						end if;
					end if;
					
				when start_wait_rising		=>
					if (rising = '1') then
						state_dht11 <= start_wait_falling;
					else
						state_dht11 <= start_wait_rising;
					end if;
					
				when start_wait_falling		=>
					state_dht11 <= end_wait_falling;
					
				when end_wait_falling		=>
					if (counter_time >= X"18" and counter_time <= X"1E") then		--- between 24us and 30us
						if (rising = '1') then
							state_dht11 <= register_0;
						end if;
					elsif (counter_time >= X"41" and counter_time <= X"4B") then	--- between 65us and 75us
						if (rising = '1') then
							state_dht11 <= register_1;
						end if;
					elsif (counter_time > X"4B") then										--- for error indication
						state_dht11 <= error_state;
					else
						state_dht11 <= end_wait_falling;
					end if;
					
				when register_0 =>
				when register_1 =>
				when error_state =>
					state_dht11 <= idle;
				when end_state =>
					state_dht11 <= idle;
				
			end case;
		end if;
	
	end process dht11_process;
	
	dht11_state_process: process(state_dht11)
	begin
	
		case state_dht11 is
			when idle 				=> NULL;
			
			when wait_strobe 		=> NULL;
			
			when start_18ms 		=> 
						start_count 	<= '0';
						time_init 		<= '1';
						count_value 	<= X"004650";   	  --- 18000 us 
						
			when end_18ms 			=>
						time_init 		<= '0';
						start_count 	<= '1';
						int_data_sig 	<= '0';
			
			when start_20us		=>
						start_count 	<= '0';
						time_init 		<= '1';				--- init the timer 
						count_value 	<= X"000000";	  	--- count forever aprox 16 sec
						compare_value  <= X"1E";		  	--- compare with 30 us
						margin			<= X"0A";			--- margin 10 us,  we set earlier the compare value to 30 to have range between 30-10 and 30+10   
						
			when end_20us			=>
						time_init 		<= '0';				--- release the timer 
						start_count 	<= '1';
						int_data_sig 	<= '1';
						
			when start_80us_1 	=>
						start_count 	<= '0';
						time_init 		<= '1';				--- init the timer 
						count_value 	<= X"000000";	  	--- count forever aprox 16 sec
						compare_value  <= X"50";		  	--- compare with 80 us
						margin			<= X"0A";			--- margin 5 us,  we set earlier the compare value to 80 to have range between 80-10 and 80+10
			
			when end_80us_1		=>
						time_init 		<= '0';				--- release the timer 
						start_count 	<= '1';
						
			when start_80us_2 	=>
						start_count 	<= '0';
						time_init 		<= '1';				--- init the timer 
						count_value 	<= X"000000";	  	--- count forever aprox 16 sec
						compare_value  <= X"50";		  	--- compare with 80 us
						margin			<= X"0A";			--- margin 5 us,  we set earlier the compare value to 80 to have range between 80-10 and 80+10
			
			when end_80us_2		=>
						time_init 		<= '0';				--- release the timer
						start_count 	<= '1';
			
			when start_wait_rising		=> NULL;
			
			when start_wait_falling		=>
						start_count 	<= '0';					-- hold the counter until configure end	
						time_init		<= '1';					-- configure the counter
						count_value		<= X"000000";			-- for counting forever aprox 16sec
						compare_value	<= X"00";				-- to disable the comparator
						
			when end_wait_falling		=>
						start_count		<= '1';					-- start count	
						time_init		<= '0';					-- release the timer, end of configuration
						
			when register_0				=>
			when register_1				=>
			when error_state		=> NULL;
			when end_state 		=>	NULL;
 						
						
		end case;
	end process dht11_state_process;
	
	
	compare_process:process(compare_value, margin, counter_time)
	begin
		if (compare_value /= X"00") then
			if (counter_time <= compare_value + margin  and  counter_time >= compare_value - margin) then
				compare_result <= '1';
			else
				compare_result <= '0';
			end if;
		end if;
	end process compare_process;
	
	counter_time_process:process(clk, reset)
	begin
		if (reset = '1') then
			counter_time <= X"000000";
		elsif (rising_edge(clk)) then
			if (time_init = '1') then
				counter_time <= X"000000";
			elsif (start_count = '1') then
				if (counter_time = count_value - 2) then    --  if reference value is 0 will count forever
						count_end <= '1';
						counter_time <= X"000000";
					else
						counter_time <= counter_time + 1;
					end if;
			end if;
		end if;
	end process counter_time_process;
	
	edge_detector: process (clk, reset)
	begin
		if (reset = '1') then
			d_input <= "00";
		elsif (rising_edge(clk)) then
			d_input(0) <= data;
			d_input(1) <= d_input(0);
		end if;
		rising 	<= not d_input(1) and d_input(0);
		falling 	<= not d_input(0) and d_input(1);
	end process edge_detector;
	
	
	data <= '0' when int_data_sig = '0' else 'Z';
	

end rtl;