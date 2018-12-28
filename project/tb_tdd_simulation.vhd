----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/28/2018 03:48:55 PM
-- Design Name: 
-- Module Name: tb_tdd_simulation - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_tdd_simulation is
end tb_tdd_simulation;

architecture Behavioral of tb_tdd_simulation is
component tdd_simulation is
    Generic (
            NUM_UL_SLOT :   natural := 10;
            NUM_DL_SLOT :   natural := 10
    );
    Port (
            clk_100M    :   in std_logic;
            rst_n       :   in std_logic;
            
            tx_enable   :   out std_logic
            
    );
end component tdd_simulation;
signal clk          : STD_LOGIC := '0';         -- clock 1 us
signal rst_n        : STD_LOGIC;
signal tx_enable    : STD_LOGIC;
signal clk_period   : time := 10 ns;

begin
    uut: tdd_simulation port map (
                                   clk,
                                   rst_n,
                                   tx_enable);

    clk <= not( clk ) after clk_period/2;
    
    rst_gen:process
    begin
        rst_n   <= '0';
        wait for clk_period * 10;
        rst_n   <= '1';
        wait;
    end process rst_gen;
end Behavioral;
