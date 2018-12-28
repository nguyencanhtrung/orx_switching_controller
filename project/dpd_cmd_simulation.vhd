----------------------------------------------------------------------------------
-- Company: VTTEK
-- Engineer: Nguyen Canh Trung (trungnc10@viettel.com.vn)
-- 
-- Create Date: 11/28/2018 04:22:14 PM
-- Design Name: 
-- Module Name: dpd_cmd_simulation - Behavioral
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

entity dpd_cmd_simulation is
Generic (
        SWITCH_PERIOD           :   natural := 2000;
        NUM_ANTENNA             :   natural := 2
);

Port (
        db_state_value          :   out std_logic_vector (2 downto 0);
        db_sendcmd              :   out std_logic;
        db_antenna              :   out std_logic_vector (3 downto 0);
        
        clk                     :   in  std_logic;
        rst_n                   :   in  std_logic;
        
        m_axis_srx_ctrl_tdata   :   out std_logic_vector (7 downto 0);
        m_axis_srx_ctrl_tvalid  :   out std_logic;
        m_axis_srx_ctrl_tready  :   in  std_logic
);
end dpd_cmd_simulation;

architecture Behavioral of dpd_cmd_simulation is

signal need_data_from_antenna   :   natural;
signal send_cmd                 :   std_logic;
signal enable_update_index      :   std_logic;

type state is (RESET, INIT, SET_ANTENNA_INDEX, ENABLE_CMD);
attribute enum_encoding         :   string;
attribute enum_encoding of state: type is "sequential";
signal pre_state, nx_state      :   state;
signal timer                    :   integer;

begin
commander: process (clk)
variable count : integer;
begin
    if rising_edge (clk) then
        if rst_n = '0' then
            count                   := 0;
            pre_state               <= RESET;
            
        elsif (count >= timer) then
            count                   := 0;
            pre_state               <= nx_state;
            
        else
            count                   := count + 1;
        end if;
    end if;
end process commander;

state_logic: process (pre_state)
begin
case pre_state is
    when RESET =>
        enable_update_index     <= '0';
        
        send_cmd                <= '0';
        nx_state                <= INIT;
        timer                   <= 0;
        db_state_value          <= "000";
         
    when INIT => 
        enable_update_index     <= '0';
        
        send_cmd                <= '0';
        nx_state                <= SET_ANTENNA_INDEX;
        timer                   <= SWITCH_PERIOD;
        db_state_value          <= "001";
        
    when SET_ANTENNA_INDEX =>
        enable_update_index     <=  '1';
        
        send_cmd                <= '0';
        timer                   <= 0;
        nx_state                <= ENABLE_CMD;
        
        db_state_value          <= "010";
        
    when ENABLE_CMD =>
        enable_update_index     <=  '0';
    
        send_cmd                <= '1';
        timer                   <= 0;
        nx_state                <= INIT;
        db_state_value          <= "011";

    when OTHERS => 
        enable_update_index     <=  '0';
        
        send_cmd                <= '0';
        nx_state                <= INIT;
        timer                   <= 0;   
        db_state_value          <= "100";
             
end case;
end process state_logic;

update_antenna_index: process (clk)
begin
    if rising_edge (clk) then
        if (enable_update_index = '1') then
            if ( need_data_from_antenna >=  NUM_ANTENNA - 1 ) then
                need_data_from_antenna  <= 0;
            else 
                need_data_from_antenna  <= need_data_from_antenna + 1;
            end if;
        end if;
    end if;
end process update_antenna_index;

---------------
db_sendcmd                      <= send_cmd;
db_antenna                      <= std_logic_vector (to_unsigned(need_data_from_antenna,4));

-- Deassert tvalid
handle_t_valid: process (clk)
begin
    if rising_edge (clk) then
        if (send_cmd = '1') then
            m_axis_srx_ctrl_tvalid  <= '1';
            m_axis_srx_ctrl_tdata   <= std_logic_vector( to_unsigned (need_data_from_antenna, 8) );
        end if;
        
                    
        if (m_axis_srx_ctrl_tready = '1') then
            m_axis_srx_ctrl_tvalid  <= '0';
        end if;
    end if;
end process handle_t_valid;

end Behavioral;