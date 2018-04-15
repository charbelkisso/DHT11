-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM		"Quartus II 64-Bit"
-- VERSION		"Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition"
-- CREATED		"Sun Apr 15 17:40:29 2018"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY dht11 IS 
	PORT
	(
		reset :  IN  STD_LOGIC;
		clk_in :  IN  STD_LOGIC;
		pin_name1 :  INOUT  STD_LOGIC;
		clk_50Mhz :  OUT  STD_LOGIC;
		clk_400hz :  OUT  STD_LOGIC;
		clk_1hz :  OUT  STD_LOGIC;
		pin_name2 :  OUT  STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END dht11;

ARCHITECTURE bdf_type OF dht11 IS 

COMPONENT clk_gen
	PORT(reset : IN STD_LOGIC;
		 clk_50Mhz : IN STD_LOGIC;
		 out_400hz : OUT STD_LOGIC;
		 out_1Mhz : OUT STD_LOGIC;
		 out_1hz : OUT STD_LOGIC;
		 out_50Mhz : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT strobe
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 strobe_o : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT controller
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 strobe : IN STD_LOGIC;
		 data : INOUT STD_LOGIC;
		 result_ready : OUT STD_LOGIC;
		 result : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC;


BEGIN 
clk_1hz <= SYNTHESIZED_WIRE_0;



b2v_inst : clk_gen
PORT MAP(reset => reset,
		 clk_50Mhz => clk_in,
		 out_400hz => clk_400hz,
		 out_1Mhz => SYNTHESIZED_WIRE_1,
		 out_1hz => SYNTHESIZED_WIRE_0,
		 out_50Mhz => clk_50Mhz);


b2v_inst1 : strobe
PORT MAP(clk => SYNTHESIZED_WIRE_0,
		 reset => reset,
		 strobe_o => SYNTHESIZED_WIRE_2);


b2v_inst2 : controller
PORT MAP(clk => SYNTHESIZED_WIRE_1,
		 reset => reset,
		 strobe => SYNTHESIZED_WIRE_2,
		 data => pin_name1,
		 result => pin_name2);


END bdf_type;