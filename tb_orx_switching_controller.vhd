----------------------------------------------------------------------------------
-- Company: VTTEK   
-- Engineer: Nguyen Canh Trung (trungnc10@viettel.com.vn)
-- 
-- Create Date: 05/30/2018 01:44:15 PM
-- Design Name: 
-- Module Name: tb_orx_switching_controller - Behavioral
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


entity tb_orx_switching_controller is
--  Port ( );
end tb_orx_switching_controller;

architecture Behavioral of tb_orx_switching_controller is
component orx_switching_controller is
--    Generic(
--            PERIOD_1US       : natural := 304;      -- 1 us = 304 cycle of clock 307.2 MHz
--            T_MODE_SETUP     : natural := 1;        -- unit: us
--            T_MODE_HOLD      : natural := 2;
--            T_MODE_ACK       : natural := 2;
--            HIGH_US          : natural := 400;
--            LOW_US           : natural := 400;
--            ADJUSTED_DELAY   : natural := 0         -- unit clock cycle
--    );
    Port ( clk                      : in    STD_LOGIC;
           rst_n                    : in    STD_LOGIC;
           
           -- INTERFACE TO DPD m_axis_srx_ctrl
           s_axis_srx_ctrl_tdata     : in    STD_LOGIC_VECTOR (7 downto 0);
           s_axis_srx_ctrl_tvalid    : in    STD_LOGIC;
           s_axis_srx_ctrl_tready    : out   STD_LOGIC;
           
           -- INTERFACE to DPD s_axis_srx
           m_axis_srx_tuser          : out  STD_LOGIC_VECTOR( 7 downto 0 );
           
           -- INTERFACE to 4 AD9371s
           gpio_orx_mode            : out   STD_LOGIC_VECTOR (11 downto 0);
           gpio_orx_trigger         : out   STD_LOGIC_VECTOR (3 downto 0);
           gpio_orx_ack             : in    STD_LOGIC_VECTOR (11 downto 0));
end component;

-- SIGNAL declaration
signal clk                          : STD_LOGIC := '0';
signal rst_n                        : STD_LOGIC;
           
   -- INTERFACE TO DPD m_axis_srx_ctrl
signal s_axis_srx_ctrl_tdata        : STD_LOGIC_VECTOR (7 downto 0);
signal s_axis_srx_ctrl_tvalid       : STD_LOGIC;
signal s_axis_srx_ctrl_tready       : STD_LOGIC;
           
   -- INTERFACE to DPD s_axis_srx
signal m_axis_srx_tuser             : STD_LOGIC_VECTOR( 7 downto 0 );
           
   -- INTERFACE to 4 AD9371s
signal gpio_orx_mode                : STD_LOGIC_VECTOR (11 downto 0);
signal gpio_orx_trigger             : STD_LOGIC_VECTOR (3 downto 0);
signal gpio_orx_ack                 : STD_LOGIC_VECTOR (11 downto 0);
signal clk_1us                      : STD_LOGIC := '0';
signal clock_period     : time := 3.3 ns;
signal clock_1us        : time := 1 us;

begin
uut: orx_switching_controller 
    port map(
               clk,
               rst_n,
               
               -- INTERFACE TO DPD m_axis_srx_ctrl
               s_axis_srx_ctrl_tdata,
               s_axis_srx_ctrl_tvalid,
               s_axis_srx_ctrl_tready,
               
               -- INTERFACE to DPD s_axis_srx
               m_axis_srx_tuser,
               
               -- INTERFACE to 4 AD9371s
               gpio_orx_mode,
               gpio_orx_trigger,
               gpio_orx_ack  
    );

-- clock generation
clk     <= not clk after clock_period/2;
clk_1us <= not clk_1us after clock_1us/2;

-- reset generation
rst_gen: process
begin
    rst_n   <= '0';
    wait for clock_period * 10;
    rst_n   <= '1';
    wait;
end process rst_gen;



-- Input data
din_proc: process
begin
    s_axis_srx_ctrl_tvalid      <= '1';
    s_axis_srx_ctrl_tdata       <= x"00";
    wait until s_axis_srx_ctrl_tready = '1';
    s_axis_srx_ctrl_tvalid      <= '0';
    
    wait for 800 us;
    
    s_axis_srx_ctrl_tvalid      <= '1';
    s_axis_srx_ctrl_tdata       <= x"01";
    wait until s_axis_srx_ctrl_tready = '1';
    s_axis_srx_ctrl_tvalid      <= '0';
   
    wait for 800 us;
    
    s_axis_srx_ctrl_tvalid      <= '1';
    s_axis_srx_ctrl_tdata       <= x"02";
    wait until s_axis_srx_ctrl_tready = '1';
    s_axis_srx_ctrl_tvalid      <= '0';
    
    wait for 800 us;
        
    s_axis_srx_ctrl_tvalid      <= '1';
    s_axis_srx_ctrl_tdata       <= x"03";
    wait until s_axis_srx_ctrl_tready = '1';
    s_axis_srx_ctrl_tvalid      <= '0';
    
    wait for 800 us;
        
    s_axis_srx_ctrl_tvalid      <= '1';
    s_axis_srx_ctrl_tdata       <= x"04";
    wait until s_axis_srx_ctrl_tready = '1';
    s_axis_srx_ctrl_tvalid      <= '0';
   
    wait for 800 us;
    
    s_axis_srx_ctrl_tvalid      <= '1';
    s_axis_srx_ctrl_tdata       <= x"05";
    wait until s_axis_srx_ctrl_tready = '1';
    s_axis_srx_ctrl_tvalid      <= '0';
    
    wait for 800 us;
        
    s_axis_srx_ctrl_tvalid      <= '1';
    s_axis_srx_ctrl_tdata       <= x"06";
    wait until s_axis_srx_ctrl_tready = '1';
    s_axis_srx_ctrl_tvalid      <= '0';
    
    wait for 800 us;
            
    s_axis_srx_ctrl_tvalid      <= '1';
    s_axis_srx_ctrl_tdata       <= x"07";
    wait until s_axis_srx_ctrl_tready = '1';
    s_axis_srx_ctrl_tvalid      <= '0';
            
    wait;
end process din_proc;
end Behavioral;
