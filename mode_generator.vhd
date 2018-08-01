----------------------------------------------------------------------------------
-- Company: VTTEK
-- Engineer: Nguyen Canh Trung (trungnc10@viettel.com.vn)
-- 
-- Create Date: 05/28/2018 04:56:38 PM
-- Design Name: 
-- Module Name: mode_generator - Behavioral
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
--      0. In worst case scenario, communication between "counter_logic" and 
--         "state_def" might violate timing requirement, since they are belonging 
--          to different clock domains.
--
--          To avoid this issue, clk and clk_1us should be drived from the same source
--          and they should be aligned.
--          To be more secure, we should put synchronizer in between two clock domains. 
--
--      1. Using only 1 clock domain to simplify design
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mode_generator is
    Generic(
           PERIOD_1US       : natural := 304;   -- 1 us = 304 cycle of clock 307.2 MHz
           T_MODE_SETUP     : natural := 1;     -- min   -- unit: us
           T_MODE_HOLD      : natural := 2     -- min
           --T_MODE_ACK       : natural := 2      -- max
    );
    Port ( rst_n            : in STD_LOGIC;
           clk              : in STD_LOGIC;
           
           ready2trigger    : in STD_LOGIC;
           enb_trigger      : out STD_LOGIC;
           
           cmd_tvalid       : in STD_LOGIC;
           cmd_tdata        : in STD_LOGIC_VECTOR(1 downto 0);          -- 00: ORX1, 01: ORX2, OTHERWISE: INTERNAL CALIB
           cmd_tready       : out STD_LOGIC;                            -- IP ready for a new command

           -- Interface 2 GPIO
           orx_mode         : out STD_LOGIC_VECTOR (2 downto 0)
           );
end mode_generator;

architecture Behavioral of mode_generator is
-- Type definition
type state is (init, setup_time, enable_trigger, hold_time );
signal pre_state, nx_state      :   state;
attribute enum_encoding         :   string;
attribute enum_encoding of state: type is "sequential";

-- Constant definition
constant ORX1                   :  std_logic_vector(2 downto 0) := "001";
constant ORX2                   :  std_logic_vector(2 downto 0) := "010"; 
constant ARM_CALIB              :  std_logic_vector(2 downto 0) := "011";  

-- Timing
constant T_MODE_SETUP_IN_CYCLES : integer := T_MODE_SETUP * PERIOD_1US;
constant T_MODE_HOLD_IN_CYCLES  : integer := T_MODE_HOLD * PERIOD_1US;

-- Register stores orx modes (00: ORX1, 01: ORX2, OTHERWISE: INTERNAL CALIB)
signal orx_mode_reg             : std_logic_vector(2 downto 0);

signal din_ready_reg            : std_logic;

signal output_enb               : std_logic;

signal timer                    : integer range 0 to T_MODE_ACK_IN_CYCLES;
signal ready4newreq_reg         : std_logic;
begin
--------------------------------------------------------------------------------
-- FSM to control MODE generator
--------------------------------------------------------------------------------
state_logic:process( clk )
variable count          : integer range 0 to T_MODE_ACK_IN_CYCLES;
begin
    if rising_edge(clk) then
        if( rst_n = '0' ) then
            count       := 0;
            pre_state   <= init;
        elsif ( count >= timer ) then
            count       := 0;
            pre_state   <= nx_state;
        else
            count       := count + 1;
        end if;
    end if;
end process state_logic;

--******************************************************************************
--                      Combinational Circuit                                 --
--******************************************************************************
-- Note: Signals including cmd_tvalid, ready2trigger should be synchronous with
-- the same clock to avoid timing violation
--------------------------------------------------------------------------------
state_def:process( pre_state, cmd_tvalid, ready2trigger)
begin
-------------------------------------------------------
-- default values - prevent infering unintended latches
-------------------------------------------------------
ready4newreq_reg    <= '0';
timer               <= 0;
orx_mode_reg        <= ARM_CALIB;
output_enb          <= '0';
enb_trigger_reg     <= '0';
-------------------------------------------------------
-- state definition
-------------------------------------------------------
case pre_state is
    when init =>
        ready4newreq_reg    <= '1';
        
        if( cmd_tvalid = '1' ) then                         -- sampling input data
            nx_state        <= setup_time;
            output_enb      <= '1';

            case cmd_tdata is
                when "00"   =>
                    orx_mode_reg    <= ORX1;
                when "01"   => 
                    orx_mode_reg    <= ORX2;
                when others => 
                    orx_mode_reg    <= ARM_CALIB;
            end case;
        else
            nx_state                <= init;
        end if;
        
    when setup_time =>
        nx_state    <= setup_time;
        timer       <= T_MODE_SETUP_IN_CYCLES;
        if( ready2trigger = '1' ) then                      -- trigger ready to be run
            nx_state    <= enable_trigger;
        end if;
        
    when enable_trigger =>
        enb_trigger_reg <= '1'; 
        -- Someone could ask: should it wait until ensuring trigger is on to move
        -- to the next state
        ------------------------------------------------------------------------
        -- No need since in the previous state, we've already checked
        -- the availability of trigger.
        ------------------------------------------------------------------------
        nx_state   <= hold_time;
    
    when hold_time => 
        timer       <= T_MODE_HOLD_IN_CYCLES;
        nx_state    <= init;
        
end case;
end process state_def;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
output_free_glitches:process( clk )
begin
    if rising_edge( clk ) then
        cmd_tready      <= ready4newreq_reg;
        enb_trigger     <= enb_trigger_reg;
        if( output_enb = '1' ) then
            orx_mode    <= orx_mode_reg;
        end if;

    end if;
end process output_free_glitches;
end Behavioral;
