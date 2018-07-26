----------------------------------------------------------------------------------
-- Company: VTTEK
-- Engineer: Nguyen Canh Trung (trungnc10@viettel.com.vn)
-- 
-- Create Date: 07/26/2018 03:11:22 PM
-- Design Name: 
-- Module Name: orx_trigger_generator - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
--              Minimum duration between 2 orx_trigger = 800 us => HIGH_US + LOW_US > 800
--              Minimun duration of level high (orx_trigger) = 1 us => HIGH_US > 1
--              MORE information: Analog Devices AD9371 - UG-992 page 100
--
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--               - Changing to recommendation of circuit design
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity orx_trigger_generator is
    Generic(    PERIOD_1US : natural := 304;   -- 1 us = 304 cycle of clock 307.2 MHz
                HIGH_US    : natural := 400;   -- duty cycle = 50%
                LOW_US     : natural := 400);
    Port ( clk          : in STD_LOGIC;         
           rst_n        : in STD_LOGIC;
           enb          : in STD_LOGIC;
           orx_trigger  : out STD_LOGIC;
           ready2trigger: out STD_LOGIC);
end orx_trigger_generator;

architecture Behavioral of orx_trigger_generator is
-- State definition
type state is (init, high, low);
signal pre_state, nx_state  :   state;
attribute enum_encoding     :   string;
attribute enum_encoding of state: type is "sequential";

constant HIGH_US_CYCLES     :   integer := PERIOD_1US * HIGH_US;
constant LOW_US_CYCLES      :   integer := PERIOD_1US * LOW_US;

signal timer				:	integer range 0 to HIGH_US_CYCLES;

begin

state_logic:process( clk )
variable count:	natural;
begin
    if rising_edge(clk) then
        if( rst_n = '0' ) then
        	count 		:= 0;
            pre_state   <= init;

        elsif ( count >= timer ) then
        	count 		:= 0;
            pre_state   <= nx_state;
        else
        	count       := count + 1;
        end if;
    end if;
end process state_logic;

state_def:process( enb, pre_state )
begin
case pre_state is 
    when init   =>
                    if( enb = '1' ) then
                        nx_state    <= high;
                    else
                        nx_state    <= init;
                    end if;
                    
                    -- rst counter
                    timer			<= 1;
                    
                    -- output
                    ready2trigger   <= '1';
                    orx_trigger     <= '0';
    
    when high   => 
                    ready2trigger   <= '0';
                    orx_trigger     <= '1';
                    
                    nx_state    	<= low;
                    timer 			<= HIGH_US_CYCLES;
                    
    when low    =>      
                   	ready2trigger   <= '0';
                    orx_trigger     <= '0';

                    nx_state    	<= init;
                    timer 			<= LOW_US_CYCLES;

    when OTHERS => 
                    nx_state    	<= init;

                    ready2trigger   <= '0';
                    orx_trigger     <= '0';
end case;
end process state_def;
end Behavioral;
