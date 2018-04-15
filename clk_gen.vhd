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
-- CREATED		"Thu Apr 05 21:33:45 2018"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY clk_gen IS 
	PORT
	(
		reset :  IN  STD_LOGIC;
		clk_50Mhz :  IN  STD_LOGIC;
		out_400hz :  OUT  STD_LOGIC;
		out_1Mhz :  OUT  STD_LOGIC;
		out_1hz :  OUT  STD_LOGIC;
		out_50Mhz :  OUT  STD_LOGIC
	);
END clk_gen;

ARCHITECTURE bdf_type OF clk_gen IS 

COMPONENT clk_src
	PORT(clk_in : IN STD_LOGIC;
		 rst : IN STD_LOGIC;
		 clk_1Mhz : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT clk_400hz
	PORT(clk_in : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 clk_out : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT clk_1hz
	PORT(clk_in : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 clk_out : OUT STD_LOGIC
	);
END COMPONENT;

SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC;


BEGIN 
out_50Mhz <= clk_50Mhz;
out_1Mhz <= SYNTHESIZED_WIRE_2;



b2v_inst : clk_src
PORT MAP(clk_in => clk_50Mhz,
		 rst => reset,
		 clk_1Mhz => SYNTHESIZED_WIRE_2);


b2v_inst1 : clk_400hz
PORT MAP(clk_in => SYNTHESIZED_WIRE_2,
		 reset => reset,
		 clk_out => out_400hz);


b2v_inst2 : clk_1hz
PORT MAP(clk_in => SYNTHESIZED_WIRE_2,
		 reset => reset,
		 clk_out => out_1hz);


END bdf_type;