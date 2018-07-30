----------------------------------------------------------------------------------
-- Company: VTTEK
-- Engineer: Nguyen Canh Trung (trungnc10@viettel.com.vn)
-- 
-- Create Date: 05/28/2018 04:56:38 PM
-- Design Name: 
-- Module Name: orx_mode_generator - Behavioral
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

entity orx_mode_generator is
    Generic(
           PERIOD_1US       : natural := 304;   -- 1 us = 304 cycle of clock 307.2 MHz
           T_MODE_SETUP     : natural := 1;     -- unit: us
           T_MODE_HOLD      : natural := 2;
           T_MODE_ACK       : natural := 2
    );
    Port ( rst_n            : in STD_LOGIC;
           clk              : in STD_LOGIC;
           
           -- Interface 2 orx_trigger_generator
           ready2trigger    : in STD_LOGIC;
           enb_trigger      : out STD_LOGIC;
           
           -- Interface 2 GPIO
           orx_mode         : out STD_LOGIC_VECTOR (2 downto 0);
           orx_ack          : in STD_LOGIC_VECTOR (2 downto 0);
           
           -- Interface 2 DPD core (m_axis_srx_ctrl)
           din_tready       : out STD_LOGIC;
           din_tvalid       : in STD_LOGIC;
           din_tdata        : in STD_LOGIC_VECTOR(1 downto 0); -- 00: ORX1, 01: ORX2, OTHERWISE: INTERNAL CALIB
           
           -- Interface 2 DPD core (s_axis_srx)
           dout_srx_tuser   : out STD_LOGIC;
           dout_srx_tvalid  : out STD_LOGIC;
           
           -- Interface 2 main controller
           err_no_ack       : out STD_LOGIC;
           ready4newrequest : out STD_LOGIC
           );
end orx_mode_generator;

architecture Behavioral of orx_mode_generator is
-- Type definition
type state is (init, mode, setup_time, enable_trigger, hold_time, wait_ack, wait_for_800us);
signal pre_state, nx_state  :   state;
attribute enum_encoding     :   string;
attribute enum_encoding of state: type is "sequential";

-- Constant definition
constant ORX1       :  std_logic_vector(2 downto 0) := "001";
constant ORX2       :  std_logic_vector(2 downto 0) := "010"; 
constant ARM_CALIB  :  std_logic_vector(2 downto 0) := "011";  

-- Timing
constant T_MODE_SETUP_IN_CYCLES : integer := T_MODE_SETUP * PERIOD_1US;
constant T_MODE_HOLD_IN_CYCLES  : integer := T_MODE_HOLD * PERIOD_1US;
constant T_MODE_ACK_IN_CYCLES   : integer := T_MODE_ACK * PERIOD_1US;

--
signal no_ack       : std_logic;

-- Register stores orx modes (00: ORX1, 01: ORX2, OTHERWISE: INTERNAL CALIB)
--signal mode_reg     : std_logic_vector( 1 downto 0 );
signal orx_mode_reg : std_logic_vector(2 downto 0);

-- Determine which antenna of AD9371 need to be observed (0: antenna 1, 1: antenna 2)
signal srx_user_reg : std_logic;
signal srx_valid_reg: std_logic;
signal din_ready_reg: std_logic;

signal timer        : integer range 0 to T_MODE_ACK_IN_CYCLES;
signal ready4newreq_reg :   std_logic;
begin
--------------------------------------------------------------------------------
-- FSM to control MODE generator
--------------------------------------------------------------------------------
state_logic:process( clk )
variable count      : integer range 0 to T_MODE_ACK_IN_CYCLES;
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
--                      FSM definition                                        --
--******************************************************************************
state_def:process( pre_state, din_tvalid, ready2trigger)
-- Register stores orx modes (00: ORX1, 01: ORX2, OTHERWISE: INTERNAL CALIB)
variable mode_reg   : std_logic_vector( 1 downto 0 );
begin
-------------------------------------------------------
-- default values - prevent infering unintended latches
-------------------------------------------------------
ready4newreq_reg            <= '0';
timer                       <= 0;

-------------------------------------------------------
-- state definition
-------------------------------------------------------
case pre_state is
    when init   =>
        ready4newreq_reg    <= '1';
        timer               <= 0;
        
        if( din_tvalid = '1' ) then     -- sampling input data
            nx_state        <= mode;
            --mode_reg        := din_tdata;
            case din_tdata is
                when "00"   =>
                    orx_mode_reg    <= ORX1;
                when "01"   => 
                    orx_mode_reg    <= ORX2;
                when others => 
                    orx_mode_reg    <= ARM_CALIB;
            end case;
        else
            nx_state        <= init;
            mode_reg        := "11";    -- default: arm calibration
        end if;
        
    when mode   => 
        ready4newreq_reg    <= '0';
        timer               <= 0;
        nx_state            <= setup_time;

        
        
    when setup_time =>
        timer       <= 1;
        enb_trigger <= '0';
        nx_state    <= setup_time;
        
        timer       <= T_MODE_SETUP_IN_CYCLES;
        if( ready2trigger = '1' ) then
            nx_state    <= enable_trigger;
        end if;
        
    when enable_trigger =>
        timer       <= 1;
        enb_trigger <= '1';
        
        nx_state   <= hold_time;
    
    when hold_time =>
        rst_counter <= '0';
        enb_cnt     <= '1';
        enb_trigger <= '1';
        nx_state    <= hold_time;
        
        if( cnt >=  T_MODE_HOLD_IN_CYCLES ) then
            rst_counter <= '1';
            enb_cnt     <= '0';
            nx_state    <= wait_ack;
        end if;   
    
    when wait_ack    =>
        rst_counter     <= '0';
        enb_cnt         <= '1';
        enb_trigger     <= '0';
        
        if( orx_ack /= "000" ) then -- detect acknowledge signal from AD9371
            rst_counter <= '1';
            enb_cnt     <= '0';
            
            -- signal for the main core
            srx_user_reg    <= mode_reg(0);
            srx_valid_reg   <= '1';
            
            no_ack          <= '0';
            
            -- signal for m_axis_srx_ctrl_tready
            din_ready_reg   <= '1';
            nx_state        <= wait_for_800us;
        
        elsif( cnt >=  T_MODE_ACK_IN_CYCLES ) then   -- time out !!!
            rst_counter <= '1';
            enb_cnt     <= '0';
            
            -- signal for the main core
            srx_user_reg    <= mode_reg(0);
            srx_valid_reg   <= '1';
            
            no_ack          <= '1';
            
            -- signal for m_axis_srx_ctrl_tready
            din_ready_reg   <= '1';
            nx_state        <= wait_for_800us;
        end if; 
        
    when wait_for_800us =>      -- wait for at least 800 us to accept a new request from DPD
        din_ready_reg       <= '1';
        if( ready2trigger = '1' ) then
            nx_state        <= init;
        end if;
    
    when set_all_2_arm_calib =>
        orx_mode            <= ARM_CALIB;

    when OTHERS =>  null;
        
end case;
end process state_def;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
output_free_glitches:process( clk )
begin
    if rising_edge( clk ) then
        ready4newrequest    <= ready4newreq_reg;
        orx_mode            <= orx_mode_reg;
    end if;
end process output_free_glitches;

din_tready      <= din_ready_reg;
dout_srx_tuser  <= srx_user_reg;
dout_srx_tvalid <= srx_valid_reg;
err_no_ack      <= no_ack;

end Behavioral;
