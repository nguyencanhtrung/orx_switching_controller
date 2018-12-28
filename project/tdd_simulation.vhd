----------------------------------------------------------------------------------
-- Company: VTTEK
-- Engineer: Nguyen Canh Trung (trungnc10@viettel.com.vn)
-- 
-- Create Date: 11/28/2018 11:15:52 AM
-- Design Name: 
-- Module Name: tdd_simulation - Behavioral
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

entity tdd_simulation is
    Generic (
            NUM_UL_SLOT :   natural := 1;
            NUM_DL_SLOT :   natural := 19
    );
    Port (
            clk_100M    :   in std_logic;
            rst_n       :   in std_logic;
            
            tx_enable   :   out std_logic
            
    );
end tdd_simulation;

architecture Behavioral of tdd_simulation is
constant DL_TIME        : integer := NUM_DL_SLOT * 50000;
constant UL_TIME        : integer := NUM_UL_SLOT * 50000;

type state is (UPLINK, DOWNLINK);
signal pre_state, nx_state : state;

signal timer            : integer;
signal tx_enb_reg       : std_logic;
begin

process (clk_100M)
variable count  : integer;
begin
    if rising_edge (clk_100M) then
        if rst_n = '0' then
            count       := 0;
            pre_state   <= UPLINK;
            
        elsif (count >= timer) then
            pre_state   <= nx_state;
            count       := 0;
        else
            count       := count + 1;
        end if;
    end if;
end process;

ul_dl_transition: process (pre_state)
begin
    case pre_state is
        when UPLINK =>
            timer       <=  UL_TIME;     
            nx_state    <=  DOWNLINK;
            tx_enb_reg  <= '0';
                    
        when DOWNLINK =>
            timer       <= DL_TIME;
            nx_state    <=  UPLINK;
            tx_enb_reg  <= '1';
                    
        when OTHERS =>
            timer       <=  0;
            nx_state    <=  UPLINK;
            tx_enb_reg  <= '0';
    end case;
end process ul_dl_transition;

tx_enable   <= tx_enb_reg;

end Behavioral;
