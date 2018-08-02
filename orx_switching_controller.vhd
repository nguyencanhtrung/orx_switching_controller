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
--          30/05/2018: detect race condition between ready4newreq and cmd_tvalid_reg
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
            HIGH_US          : natural := 5;
            LOW_US           : natural := 5;
            ADJUSTED_DELAY   : natural := 0         -- unit clock cycle
    );
    Port ( clk                        : in    STD_LOGIC;
           rst_n                      : in    STD_LOGIC;
           
           -- INTERFACE TO DPD m_axis_srx_ctrl
           s_axis_srx_ctrl_tdata      : in    STD_LOGIC_VECTOR (7 downto 0);
           s_axis_srx_ctrl_tvalid     : in    STD_LOGIC;
           s_axis_srx_ctrl_tready     : out   STD_LOGIC;
           
           -- INTERFACE to DPD s_axis_srx
           m_axis_srx_tuser           : out  STD_LOGIC_VECTOR( 7 downto 0 );
           
           -- INTERFACE to 4 AD9371s
           gpio_orx_mode              : out   STD_LOGIC_VECTOR (11 downto 0);
           gpio_orx_trigger           : out   STD_LOGIC_VECTOR (3 downto 0);
           gpio_orx_ack               : in    STD_LOGIC_VECTOR (11 downto 0));
end orx_switching_controller;

architecture Behavioral of orx_switching_controller is
--=================================================================
-- COMPONENT definition
component pin_mode_controller is
    Generic(
            PERIOD_1US       : natural := 304;                                -- 1 us = 304 cycle of clock 307.2 MHz
            T_MODE_SETUP     : natural := 1;                                  -- unit: us
            T_MODE_HOLD      : natural := 2;
            T_MODE_ACK       : natural := 2;
            HIGH_US          : natural := 5;
            LOW_US           : natural := 5;
            ADJUSTED_DELAY   : natural := 0                                   -- unit clock cycle
    );
    Port ( clk                      : in    STD_LOGIC;
           rst_n                    : in    STD_LOGIC;
           
           cmd_tdata                : in    STD_LOGIC_VECTOR ( 1 downto 0 );  -- Command received from main controller
           cmd_tready               : out   STD_LOGIC;                        -- Ready to receive a new command
           cmd_tvalid               : in    STD_LOGIC;                        -- 
           
           -- INTERFACE to ONE AD9371
           gpio_orx_mode            : out   STD_LOGIC_VECTOR (2 downto 0);
           gpio_orx_trigger         : out   STD_LOGIC;
           gpio_orx_ack             : in    STD_LOGIC_VECTOR (2 downto 0)
    );
end component pin_mode_controller;
--=================================================================
-- STATE definition
type state is (arm_calib_state, init, assign_new_cmd, enable_send_command, wait4done, delay );
signal pre_state, nx_state      :   state;
attribute enum_encoding         :   string;
attribute enum_encoding of state:   type is "one-hot";                      -- "one-hot" or "sequential"
--=================================================================
-- SIGNAL DECLARATION
-- Interface to pin_mode_controller
signal cmd_tdata_reg            :   std_logic_vector( 7 downto 0 );         -- Registers to store command from DPD software
signal cmd_tvalid_reg           :   std_logic_vector( 3 downto 0 );
signal cmd_tready_reg           :   std_logic_vector( 3 downto 0 );
-------------------------------------------------------------------
--=================================================================
signal ant2calib                :   integer range 0 to 7 := 0;
signal ad2calib                 :   integer range 0 to 3 := 0;              -- calibrate this antenna

signal timer                    :   integer range 0 to 5;                   -- can phai sua lai
signal set_all_to_internal_calib:   std_logic_vector(3 downto 0)  ;
signal orx_switcher_tready_reg  :   std_logic;                              -- informing ORX SWITCHER has already received command
                                                                            -- from DPD software
signal ant2orx                  :   integer range 0 to 7 := 0;
signal ad2orx                   :   integer range 0 to 3 := 0;
begin
--------------------------------------------------------------------------------        
--============================= CONTROL PATH =================================== 
--------------------------------------------------------------------------------                                             
state_logic: process( clk )
variable count  : integer range 0 to 5;                                     -- can phai sua lai range
begin
  if rising_edge(clk) then
    if( rst_n = '0' ) then
      pre_state   <= arm_calib_state;
      count       := 0;
    elsif ( count >= timer ) then
      pre_state   <= nx_state;
      count       := 0;
    else
      count := count + 1;
    end if;
  end if;
end process state_logic;

comb_logic: process ( pre_state, s_axis_srx_ctrl_tvalid, cmd_tready_reg )
variable no_ad9371          :   std_logic_vector( 1 downto 0 );             -- get ORX data from which ad9371 board? - for ORX mode
variable no_anten           :   std_logic_vector( 2 downto 0 )  := "000";   -- in this ad9371, get ORX data from which antenna?

begin
-- default values to avoid inferring latches
cmd_temp_tvalid_reg               <= (OTHERS => '0');
cmd_temp_tdata_reg                <= (OTHERS => '1');
set_all_to_internal_calib         <= '0';
orx_switcher_tready_reg           <= '0';

read_cmd_from_dpd                 <= '0';
update_new_assignment             <= '0';
inform_dpd_cmd_receive            <= '0';

send_command                      <= '0';

case pre_state is
    when arm_calib_state =>
      if( s_axis_srx_ctrl_tvalid = '1' ) then                               -- As soon as detecting the first request from DPD, move to
          nx_state                <= init;                                  -- the normal operation.                     
                                                                            ------------------------
      else                                                                  -- Periodically, performing INTERNAL CALIB on ALL ANTENNAs
          nx_state                <= arm_calib_state;                       -- with the period of 800 us. Since, we don't know exactly
          if( cmd_tready_reg = "1111") then
            set_all_to_internal_calib <= '1';                               -- when ARM core finishes its setting from ARM-based to PIN
          end if;                                                           -- -based for handling ORX switching.
      end if;                                                               -- set INTERNAL ARM CALIB (00: ORX1; 01: ORX2, OTHERWISE:-
                                                                            -- - INTERNAL CALIB )

                                                                            -- In this case, wait for all ORX_SWITCHER READY before 
                                                                            -- starting a new process of triggering INTERNAL CALIBRATION 
    when init =>
      nx_state                    <= init;
      if( s_axis_srx_ctrl_tvalid = '1' ) then                               -- Write command from DPD to internal registers, and perfom
          read_cmd_from_dpd       <= '1';                                   -- parsing input to identify which ad9371 and which antenna
          nx_state                <= assign_new_cmd;                        -- need to be switched
      end if;                                                               
      
    when assign_new_cmd =>
      nx_state                    <= enable_send_command;      
      update_new_assignment       <= '1';                                   -- assign to all ORX_SWITCHERs
      inform_dpd_cmd_receive      <= '1';

    when enable_send_command   =>
      nx_state                    <= enable_send_command;                   -- Check availability of antenna that need to switch to ORX mode (ONLY)
                                                                            -- NOTE: CAN PHAI CHECK LAI FLOW CUA HE THONG, LIEU CO CAN PHAI CHO READY4NEWREQ ko hay la lap tuc yeu cau ngay he thong switch
      if( cmd_tready_reg( ad2orx ) = '1' and 
          cmd_tready_reg( ad2calib ) = '1' ) then                           -- synchronize
          nx_state                <= wait4done;
          send_command            <= '1';
      end if;

    when wait4done =>
      nx_state                    <= wait4done;
      
      if( cmd_tready_reg( ad2orx ) = '1' ) then                             -- no need to check ARM CALIB antenna
          s_axis_srx_ctrl_tready  <= '1';                                   -- trigger ready signal to dpd informing orx data is ready
          nx_state                <= delay;
          
          ad2calib                <= ad2orx;                                -- store previous orxmode antenna to switch it back to ARM Calib later
          ant2calib               <= ant2orx;
      end if;
            
    when delay  =>
      s_axis_srx_ctrl_tready      <= '0';
      nx_state                    <= delay;
      if( cnt >= ADJUSTED_DELAY) then
          m_axis_srx_tuser        <= "00000" & no_anten;
          nx_state                <= init;
      end if;
                    
    when OTHERS =>
end case;
end process comb_logic;
--------------------------------------------------------------------------------
--============================== DATA PATH =====================================
--------------------------------------------------------------------------------                                               
output_reg: process( clk )
variable no_ad9371  : std_logic_vector( 1 downto 0 );
variable no_anten   : std_logic_vector( 2 downto 0 );
begin
  if rising_edge( clk ) then
      --------------------------------------------------------------------------
      -- 01. parse input ONLY WHEN 
      --------------------------------------------------------------------------
      if( read_cmd_from_dpd = '1' ) then
          no_ad9371   := s_axis_srx_ctrl_tdata( 2 ) & s_axis_srx_ctrl_tdata( 0 );
          no_anten    := s_axis_srx_ctrl_tdata( 2 downto 0 );
          ad2orx      <= to_integer( unsigned(no_ad9371));
          ant2orx     <= to_integer( unsigned(no_anten) );
      end if;
      --------------------------------------------------------------------------
      -- 02. Assign new command
      --------------------------------------------------------------------------
      -- Default values
      cmd_tdata_reg   <= (OTHERS => '1');
      cmd_tvalid_reg  <= (OTHERS => '0');
      
      if( set_all_to_internal_calib = '1' ) then
          cmd_tdata_reg   <= (OTHERS => '1');
          cmd_tvalid_reg  <= (OTHERS => '1');
      elsif( update_new_assignment = '1' ) then
          -- SET arm calib first, since if there is a chance one antenna is chosen 
          -- as ARM calib and ORX mode simutaneously, 
          -- ORX should have higher priority.
          cmd_tdata_reg   <= (OTHERS => '1');

          case ant2calib is
            when 0  =>
                    cmd_tdata_reg(1 downto 0)   <= "11";    -- AD9371_1: Calib antenna 0
            when 1  =>
                    cmd_tdata_reg(3 downto 2)   <= "11";    -- AD9371_2: Calib antenna 0
            when 2 =>
                    cmd_tdata_reg(1 downto 0)   <= "11";    -- AD9371_1: Calib antenna 1
            when 3 =>
                    cmd_tdata_reg(3 downto 2)   <= "11";    
            when 4  =>
                    cmd_tdata_reg(5 downto 4)   <= "11";
            when 5  =>
                    cmd_tdata_reg(7 downto 6)   <= "11";
            when 6 =>
                    cmd_tdata_reg(5 downto 4)   <= "11";
            when 7 =>
                    cmd_tdata_reg(7 downto 6)   <= "11";
            when others => null;
          end case;
          
          case no_anten is
            when "000" =>
                    cmd_tdata_reg(1 downto 0)   <= "00";    -- AD9371_1: ORX antenna 0
            when "001" =>
                    cmd_tdata_reg(3 downto 2)   <= "00";    -- AD9371_2: ORX antenna 0
            when "010" =>
                    cmd_tdata_reg(1 downto 0)   <= "01";    -- AD9371_1: ORX antenna 1
            when "011" =>
                    cmd_tdata_reg(3 downto 2)   <= "01";    
            when "100" =>
                    cmd_tdata_reg(5 downto 4)   <= "00";
            when "101" =>
                    cmd_tdata_reg(7 downto 6)   <= "00";
            when "110" =>
                    cmd_tdata_reg(5 downto 4)   <= "01";
            when "111" =>
                    cmd_tdata_reg(7 downto 6)   <= "01";
            when others => null;
          end case;
      end if;

      --------------------------------------------------------------------------
      -- 03. Enable to send new command
      --------------------------------------------------------------------------
      if( send_command = '1' ) then
          cmd_tvalid_reg  <= '1';
          cmd_tvalid_reg  <= '1';
      end if;
      -- 
      if( inform_dpd_cmd_receive = '1' ) then 
          s_axis_srx_ctrl_tready  <= '1';
      else
          s_axis_srx_ctrl_tready  <= '0';
      end if;

      
  end if;
end process;
--========================= PORT MAP ==============================
-- AD9371 - 1
ad1: pin_mode_controller
    generic map (
            PERIOD_1US,     -- 1 us = 304 cycle of clock 307.2 MHz
            T_MODE_SETUP,   -- unit: us
            T_MODE_HOLD,
            T_MODE_ACK,
            HIGH_US,
            LOW_US,
            ADJUSTED_DELA ) -- unit clock cycle

    port map ( 
           clk                  => clk                        ,
           rst_n                => rst_n                      ,         
           
           cmd_tdata            => cmd_tdata_reg(1 downto 0)  ,         
           cmd_tready           => cmd_tready_reg(0)          ,      
           cmd_tvalid           => cmd_tvalid_reg(0)          ,                  
           
          
           gpio_orx_mode        => gpio_orx_mode(2 downto 0)  ,
           gpio_orx_trigger     => gpio_orx_trigger(0),
           gpio_orx_ack         => gpio_orx_ack(2 downto 0)   
    );
------------------------------------------
-- AD9371 - 2
ad2: pin_mode_controller
    generic map (
            PERIOD_1US,                      
            T_MODE_SETUP,                    
            T_MODE_HOLD,
            T_MODE_ACK,
            HIGH_US,
            LOW_US,
            ADJUSTED_DELA)                             
    
    port map ( 
           clk                  => clk                        ,
           rst_n                => rst_n                      ,         
           
           cmd_tdata            => cmd_tdata_reg (3 downto 2) ,         
           cmd_tready           => cmd_tready_reg (1)         ,      
           cmd_tvalid           => cmd_tvalid_reg (1)         ,                  
           
          
           gpio_orx_mode        => gpio_orx_mode (5 downto 3) ,
           gpio_orx_trigger     => gpio_orx_trigger (1),
           gpio_orx_ack         => gpio_orx_ack (5 downto 3)  
    );
------------------------------------------
-- AD9371 - 3
ad3: pin_mode_controller
    generic map (
            PERIOD_1US,                            
            T_MODE_SETUP,                           
            T_MODE_HOLD,
            T_MODE_ACK,
            HIGH_US,
            LOW_US,
            ADJUSTED_DELA)                         
    
    port map ( 
           clk                  => clk                        ,
           rst_n                => rst_n                      ,         
           
           cmd_tdata            => cmd_tdata_reg (5 downto 4) ,         
           cmd_tready           => cmd_tready_reg (2)         ,      
           cmd_tvalid           => cmd_tvalid_reg (2)         ,                  
           
          
           gpio_orx_mode        => gpio_orx_mode (8 downto 6) ,
           gpio_orx_trigger     => gpio_orx_trigger (2)       ,
           gpio_orx_ack         => gpio_orx_ack (8 downto 6)  
    );
------------------------------------------
-- AD9371 - 4
ad4: pin_mode_controller
    generic map (
            PERIOD_1US,                              
            T_MODE_SETUP,                            
            T_MODE_HOLD,
            T_MODE_ACK,
            HIGH_US,
            LOW_US,
            ADJUSTED_DELA)                                
    
    port map ( 
           clk                  => clk                        ,
           rst_n                => rst_n                      ,         
           
           cmd_tdata            => cmd_tdata_reg (7 downto 6) ,         
           cmd_tready           => cmd_tready_reg (3)         ,      
           cmd_tvalid           => cmd_tvalid_reg (3)         ,                  
           
          
           gpio_orx_mode        => gpio_orx_mode (11 downto 9),
           gpio_orx_trigger     => gpio_orx_trigger (3)       ,
           gpio_orx_ack         => gpio_orx_ack(11 downto 9)  
    );

end Behavioral;