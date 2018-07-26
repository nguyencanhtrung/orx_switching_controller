----------------------------------------------------------------------------------
-- Company: VTTEK
-- Engineer: Nguyen Canh Trung  (trungnc10@viettel.com.vn)
-- 
-- Create Date: 05/29/2018 03:25:18 PM
-- Design Name: 
-- Module Name: orx_switching_controller - Behavioral
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
--          30/05/2018: detect race condition between ready4newreq and din_tvalid_reg
--                      solved by: delete ready4newreq out of sensitivity list
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity orx_switching_controller is
    Generic(
            PERIOD_1US       : natural := 304;      -- 1 us = 304 cycle of clock 307.2 MHz
            T_MODE_SETUP     : natural := 1;        -- unit: us
            T_MODE_HOLD      : natural := 2;
            T_MODE_ACK       : natural := 2;
            HIGH_US          : natural := 400;
            LOW_US           : natural := 400;
            ADJUSTED_DELAY   : natural := 0         -- unit clock cycle
    );
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
end orx_switching_controller;

architecture Behavioral of orx_switching_controller is
--=================================================================
-- COMPONENT definition
component orx_mode_generator is
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
end component orx_mode_generator;


component orx_trigger_generator is
    Generic(    PERIOD_1US : natural := 304;   -- 1 us = 304 cycle of clock 307.2 MHz
                HIGH_US    : natural := 400;
                LOW_US     : natural := 400);
    Port ( clk          : in STD_LOGIC;         -- clock 1 us
           rst_n        : in STD_LOGIC;
           enb          : in STD_LOGIC;
           orx_trigger  : out STD_LOGIC;
           ready2trigger: out STD_LOGIC);
end component orx_trigger_generator;
--=================================================================
-- STATE definition
type state is (init, newrequest, wait4modegen, wait4ready, delay );
signal pre_state, nx_state      :   state;
attribute enum_encoding         :   string;
attribute enum_encoding of state:   type is "one-hot";              -- "one-hot" or "sequential"
--=================================================================
-- SIGNAL DECLARATION
signal mode_reg                 :   std_logic_vector( 1 downto 0 );
-------------------------------------------------------------------
-- MODE GENERATOR 
signal mode_gen_err_no_ack_reg  :   std_logic_vector( 3 downto 0 );

signal mode_gen_user_reg        :   std_logic_vector( 3 downto 0 ); -- each ad9371 signals 1 bit ( 0 - antenna 0; 1- antenna 1)
signal mode_gen_valid_reg       :   std_logic_vector( 3 downto 0 ); -- each ad9371 signals 1 bit

signal ready4newreq             :   std_logic_vector( 3 downto 0 );

-- interface to srx_ctrl
signal din_tdata_reg            :   std_logic_vector( 7 downto 0 ); -- for 4 ad9371 data
signal din_tvalid_reg           :   std_logic_vector( 3 downto 0 );
signal din_tready_reg           :   std_logic_vector( 3 downto 0 );
-------------------------------------------------------------------
-- TRIGGER GENERATOR
signal trigger_gen_ready        :   std_logic_vector( 3 downto 0 );
signal trigger_gen_enb          :   std_logic_vector( 3 downto 0 );
-------------------------------------------------------------------
-- PROGRAMMABLE DELAY
signal cnt                      :   integer;
signal enb_cnt                  :   std_logic;
signal rst_counter              :   std_logic;
--=================================================================
signal ant2calib                :   integer range 0 to 7 := 0;
signal ad2calib                 :   integer range 0 to 3 := 0; -- calibrate this antenna

begin           
--========================= CONTROL ==============================                                               
counter_logic: process(clk)
begin
    if rising_edge( clk ) then
        if rst_counter  = '1' then
            cnt <= 0;
        elsif enb_cnt = '1' then
            cnt <= cnt + 1;
        else
            cnt <= cnt;
        end if;
    end if;
end process counter_logic;

state_logic: process( clk, rst_n )
begin
    if rising_edge(clk) then
        if( rst_n = '0' ) then
            pre_state   <= init;
        else
            pre_state   <= nx_state;
        end if;
    end if;
end process state_logic;

comb_logic: process (pre_state, s_axis_srx_ctrl_tvalid, din_tready_reg, cnt )
variable no_ad9371          :   std_logic_vector( 1 downto 0 ); -- get ORX data from which ad9371 board? - for ORX mode
variable no_anten           :   std_logic_vector( 2 downto 0 )  := "000"; -- in this ad9371, get ORX data from which antenna?

--variable ant2calib          :   integer range 0 to 7 := 0;
variable ant2orx            :   integer range 0 to 7 := 0;

--variable ad2calib           :   integer range 0 to 3 := 0; -- calibrate this antenna
variable ad2orx             :   integer range 0 to 3 := 0;
begin
case pre_state is
    when init =>
            din_tdata_reg   <= (OTHERS => '0');
            din_tvalid_reg  <= (OTHERS => '0');
            nx_state        <= init;
            
            rst_counter     <= '1';
            enb_cnt         <= '0';
            
            if( s_axis_srx_ctrl_tvalid = '1' ) then
                nx_state    <= newrequest;
                no_ad9371       := s_axis_srx_ctrl_tdata( 2 ) & s_axis_srx_ctrl_tdata( 0 );
                no_anten        := s_axis_srx_ctrl_tdata( 2 downto 0 );
                ad2orx          := to_integer( unsigned(no_ad9371));
                ant2orx         := to_integer( unsigned(no_anten));
            end if;
            
    when newrequest =>
            nx_state        <= wait4modegen;
            
            -- SET arm calib first, since if there is a chance one antenna is chosen 
            -- as ARM calib and ORX mode simutaneously, 
            -- ORX should have higher priority.
                        
            case ant2calib is
            when 0  =>
                    din_tdata_reg(1 downto 0)   <= "11";    -- AD9371_1: Calib antenna 0
            when 1  =>
                    din_tdata_reg(3 downto 2)   <= "11";    -- AD9371_2: Calib antenna 0
            when 2 =>
                    din_tdata_reg(1 downto 0)   <= "11";    -- AD9371_1: Calib antenna 1
            when 3 =>
                    din_tdata_reg(3 downto 2)   <= "11";    
            when 4  =>
                    din_tdata_reg(5 downto 4)   <= "11";
            when 5  =>
                    din_tdata_reg(7 downto 6)   <= "11";
            when 6 =>
                    din_tdata_reg(5 downto 4)   <= "11";
            when 7 =>
                    din_tdata_reg(7 downto 6)   <= "11";
            when others => null;
            end case;
            
            
            case no_anten is
            when "000" =>
                    din_tdata_reg(1 downto 0)   <= "00";    -- AD9371_1: ORX antenna 0
            when "001" =>
                    din_tdata_reg(3 downto 2)   <= "00";    -- AD9371_2: ORX antenna 0
            when "010" =>
                    din_tdata_reg(1 downto 0)   <= "01";    -- AD9371_1: ORX antenna 1
            when "011" =>
                    din_tdata_reg(3 downto 2)   <= "01";    
            when "100" =>
                    din_tdata_reg(5 downto 4)   <= "00";
            when "101" =>
                    din_tdata_reg(7 downto 6)   <= "00";
            when "110" =>
                    din_tdata_reg(5 downto 4)   <= "01";
            when "111" =>
                    din_tdata_reg(7 downto 6)   <= "01";
            when others => null;
            end case;
            
            --din_tdata_reg( ad2calib * 2 + 1 downto ad2calib * 2)    <= "11";            -- set ARM Calib
            --din_tdata_reg( ad2orx * 2 + 1 downto ad2orx * 2)        <= '0' & no_anten;  -- set ORX mode
            
            
            
    when wait4modegen   =>
            nx_state                        <= newrequest;
            -- Check availability of antenna that need to switch to ORX mode (ONLY)
            -- NOTE: CAN PHAI CHECK LAI FLOW CUA HE THONG, LIEU CO CAN PHAI CHO READY4NEWREQ ko hay la lap tuc yeu cau ngay he thong switch
            if( ready4newreq( ad2orx ) = '1' ) and ( ready4newreq( ad2calib ) = '1' ) then -- synchronize
                din_tvalid_reg(ad2calib)    <= '1';
                din_tvalid_reg(ad2orx)      <= '1';
                nx_state                    <= wait4ready;
            end if;
            
            
    when wait4ready =>
            nx_state                        <= wait4ready;
            -- no need to check ARM CALIB antenna
            if( din_tready_reg( ad2orx ) = '1' ) then
                -- trigger ready signal to dpd informing orx data is ready
                s_axis_srx_ctrl_tready      <= '1';
                nx_state                    <= delay;
                
                rst_counter                 <= '0';
                enb_cnt                     <= '1';
                
                -- store previous orxmode antenna to switch it back to ARM Calib later
                ad2calib        <= ad2orx;
                ant2calib       <= ant2orx;
            end if;
            
    when delay  =>
            s_axis_srx_ctrl_tready          <= '0';
            nx_state                        <= delay;
            if( cnt >= ADJUSTED_DELAY) then
                m_axis_srx_tuser           <= "00000" & no_anten;
                nx_state                   <= init;
            end if;
                    
    when OTHERS =>
end case;
end process comb_logic;

--========================= PORT MAP ==============================
-- AD9371 - 0
ad9371_0_m: orx_mode_generator 
    generic map (
                    PERIOD_1US,
                    T_MODE_SETUP,
                    T_MODE_HOLD,
                    T_MODE_ACK)
    port map (
               rst_n,
               clk,
               
               -- Interface 2 orx_trigger_generator
               trigger_gen_ready(0),
               trigger_gen_enb(0),
               
               -- Interface 2 GPIO
               gpio_orx_mode(2 downto 0),
               gpio_orx_ack(2 downto 0),
               
               -- Interface 2 DPD core (m_axis_srx_ctrl)
               din_tready_reg(0),
               din_tvalid_reg(0),
               din_tdata_reg(1 downto 0),
               
               -- Interface 2 DPD core (s_axis_srx)
               mode_gen_user_reg(0),
               mode_gen_valid_reg(0),
               
               -- Interface 2 main controller
               mode_gen_err_no_ack_reg(0),
               ready4newreq(0)                           
    );
    
ad9371_0_t: orx_trigger_generator
        generic map ( 
                        PERIOD_1US,  
                        HIGH_US,
                        LOW_US)
        port map ( 
                clk,
                rst_n,
                trigger_gen_enb(0),
                gpio_orx_trigger(0),
                trigger_gen_ready(0)
                );
------------------------------------------
-- AD9371 - 1
ad9371_1_m: orx_mode_generator 
    generic map (
                    PERIOD_1US,
                    T_MODE_SETUP,
                    T_MODE_HOLD,
                    T_MODE_ACK)
    port map (
               rst_n,
               clk,
               
               -- Interface 2 orx_trigger_generator
               trigger_gen_ready(1),
               trigger_gen_enb(1),
               
               -- Interface 2 GPIO
               gpio_orx_mode(5 downto 3),
               gpio_orx_ack(5 downto 3),
               
               -- Interface 2 DPD core (m_axis_srx_ctrl)
               din_tready_reg(1),
               din_tvalid_reg(1),
               din_tdata_reg(3 downto 2),
               
               -- Interface 2 DPD core (s_axis_srx)
               mode_gen_user_reg(1),
               mode_gen_valid_reg(1),
               
               -- Interface 2 main controller
               mode_gen_err_no_ack_reg(1),
               ready4newreq(1)                           
    );
    
ad9371_1_t: orx_trigger_generator
        generic map ( 
                       PERIOD_1US,    
                       HIGH_US,
                       LOW_US)
        port map ( 
                clk,
                rst_n,
                trigger_gen_enb(1),
                gpio_orx_trigger(1),
                trigger_gen_ready(1)
                );
------------------------------------------
-- AD9371 - 2
ad9371_2_m: orx_mode_generator 
    generic map (
                    PERIOD_1US,
                    T_MODE_SETUP,
                    T_MODE_HOLD,
                    T_MODE_ACK)
    port map (
               rst_n,
               clk,
               
               -- Interface 2 orx_trigger_generator
               trigger_gen_ready(2),
               trigger_gen_enb(2),
               
               -- Interface 2 GPIO
               gpio_orx_mode(8 downto 6),
               gpio_orx_ack(8 downto 6),
               
               -- Interface 2 DPD core (m_axis_srx_ctrl)
               din_tready_reg(2),
               din_tvalid_reg(2),
               din_tdata_reg(5 downto 4),
               
               -- Interface 2 DPD core (s_axis_srx)
               mode_gen_user_reg(2),
               mode_gen_valid_reg(2),
               
               -- Interface 2 main controller
               mode_gen_err_no_ack_reg(2),
               ready4newreq(2)                           
    );
    
ad9371_2_t: orx_trigger_generator
        generic map (    
                        PERIOD_1US, 
                        HIGH_US,
                        LOW_US)
        port map ( 
                clk,
                rst_n,
                trigger_gen_enb(2),
                gpio_orx_trigger(2),
                trigger_gen_ready(2)
                );
------------------------------------------
-- AD9371 - 3
ad9371_3_m: orx_mode_generator 
    generic map (
                    PERIOD_1US,
                    T_MODE_SETUP,
                    T_MODE_HOLD,
                    T_MODE_ACK)
    port map (
               rst_n,
               clk,
               
               -- Interface 2 orx_trigger_generator
               trigger_gen_ready(3),
               trigger_gen_enb(3),
               
               -- Interface 2 GPIO
               gpio_orx_mode(11 downto 9),
               gpio_orx_ack(11 downto 9),
               
               -- Interface 2 DPD core (m_axis_srx_ctrl)
               din_tready_reg(3),
               din_tvalid_reg(3),
               din_tdata_reg(7 downto 6),
               
               -- Interface 2 DPD core (s_axis_srx)
               mode_gen_user_reg(3),
               mode_gen_valid_reg(3),
               
               -- Interface 2 main controller
               mode_gen_err_no_ack_reg(3),
               ready4newreq(3)                           
    );
    
ad9371_3_t: orx_trigger_generator
        generic map ( 
                        PERIOD_1US,    
                        HIGH_US,
                        LOW_US)
        port map ( 
                clk,
                rst_n,
                trigger_gen_enb(3),
                gpio_orx_trigger(3),
                trigger_gen_ready(3));

end Behavioral;