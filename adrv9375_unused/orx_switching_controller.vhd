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
            PERIOD_1US                : natural := 304;                       -- 1 us = 304 cycle of clock 307.2 MHz
            T_MODE_SETUP              : natural := 1;                         -- unit: us
            T_MODE_HOLD               : natural := 2;
            T_MODE_ACK                : natural := 2;
            HIGH_US                   : natural := 5;
            LOW_US                    : natural := 5;
            ADJUSTED_DELAY            : natural := 0                          -- unit clock cycle
    );
    Port ( clk                        : in    STD_LOGIC;
           rst_n                      : in    STD_LOGIC;
           
           -- INTERFACE TO DPD m_axis_srx_ctrl
           s_axis_srx_ctrl_tdata      : in    STD_LOGIC_VECTOR (7 downto 0);
           s_axis_srx_ctrl_tvalid     : in    STD_LOGIC;
           s_axis_srx_ctrl_tready     : out   STD_LOGIC;
           
           -- INTERFACE to DPD s_axis_srx
           m_axis_srx_tuser           : out   STD_LOGIC_VECTOR( 7 downto 0 );
           
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
            PERIOD_1US                : natural := 304;                       -- 1 us = 304 cycle of clock 307.2 MHz
            T_MODE_SETUP              : natural := 1;                         -- unit: us
            T_MODE_HOLD               : natural := 2;
            T_MODE_ACK                : natural := 2;
            HIGH_US                   : natural := 5;
            LOW_US                    : natural := 5
    );
    Port ( clk                        : in    STD_LOGIC;
           rst_n                      : in    STD_LOGIC;
           
           cmd_tdata                  : in    STD_LOGIC_VECTOR ( 1 downto 0 );-- Command received from main controller
           cmd_tready                 : out   STD_LOGIC;                      -- Ready to receive a new command
           cmd_tvalid                 : in    STD_LOGIC;                      
           
           done_setup                 : out   STD_LOGIC;                      -- Done setup as soon as receiving ACK 
                                                                              -- from ARM on AD9371
           -- INTERFACE to ONE AD9371
           gpio_orx_mode              : out   STD_LOGIC_VECTOR ( 2 downto 0 );
           gpio_orx_trigger           : out   STD_LOGIC;
           gpio_orx_ack               : in    STD_LOGIC_VECTOR ( 2 downto 0 )
    );
end component pin_mode_controller;
--=================================================================
-- STATE definition
type state is (arm_calib_state, init, assign_new_cmd, enable_send_command, wait4ack, wait4done );
signal pre_state, nx_state      :   state;
attribute enum_encoding         :   string;
attribute enum_encoding of state:   type is "one-hot";                      -- "one-hot" or "sequential"
--=================================================================
-- SIGNAL DECLARATION
constant DELAY                  :   integer := ADJUSTED_DELAY * PERIOD_1US;
--
-- Interface to pin_mode_controller for 4 AD9371s
signal cmd_tdata_reg            :   std_logic_vector( 7 downto 0 );         -- Registers to store command from DPD software
signal cmd_tvalid_reg           :   std_logic_vector( 3 downto 0 );
signal cmd_tready_reg           :   std_logic_vector( 3 downto 0 );

signal done_setup               :   std_logic_vector( 3 downto 0 );
--=================================================================
-- Control signals
signal set_all_to_internal_calib:   std_logic_vector(3 downto 0)  ;
signal orx_switcher_tready_reg  :   std_logic;                              -- informing ORX SWITCHER has already received command

signal send_command             :   std_logic;
signal set_new_user             :   std_logic;

signal inform_dpd_cmd_receive   :   std_logic;                              -- inform dpd cmd receive by asserting m_srx_control_tready = '1'
signal keep_old_config          :   std_logic;

-- Parameters
signal timer                    :   integer range 0 to DELAY;               -- can phai sua lai
                                                                            -- from DPD software
signal ant2orx                  :   integer range 0 to 7 := 0;
signal ad2orx                   :   integer range 0 to 3 := 0;

signal no_ad9371                :   std_logic_vector( 1 downto 0 );
signal no_anten                 :   std_logic_vector( 2 downto 0 );

signal ant2calib                :   integer range 0 to 7 := 0;
signal ad2calib                 :   integer range 0 to 3 := 0;              -- calibrate this antenna

begin
--------------------------------------------------------------------------------        
--============================= CONTROL PATH =================================== 
--------------------------------------------------------------------------------                                             
state_logic: process( clk )
variable count  : integer range 0 to DELAY;                                 -- can phai sua lai range
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
---------------------------------
---------------------------------
comb_logic: process ( pre_state, s_axis_srx_ctrl_tvalid, cmd_tready_reg, orx_active )
variable no_ad9371          :   std_logic_vector( 1 downto 0 );             -- get ORX data from which ad9371 board? - for ORX mode
variable no_anten           :   std_logic_vector( 2 downto 0 )  := "000";   -- in this ad9371, get ORX data from which antenna?

begin
-- default values to avoid inferring latches
set_all_to_internal_calib         <= '0';
orx_switcher_tready_reg           <= '0';

read_cmd_from_dpd                 <= '0';
update_new_assignment             <= '0';
inform_dpd_cmd_receive            <= '0';

send_command                      <= '0';
set_new_user                      <= '0';

keep_old_config                   <= '0';

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
                                                                            -- NOTE: CAN PHAI CHECK LAI FLOW CUA HE THONG, LIEU CO CAN 
      if( cmd_tready_reg( ad2orx   ) = '1' and                              -- PHAI CHO READY4NEWREQ ko hay la lap tuc yeu cau ngay he thong switch
          cmd_tready_reg( ad2calib ) = '1' ) then                           -- synchronize
          nx_state                <= wait4done;
          send_command            <= '1';                                    
      end if;

    when wait4ack =>                                                        -- WAIT UNTIL RECEIVED ACK signal from an AD9371 informing that ORX 
      nx_state                    <= wait4ack;                              -- is switched successfully. Then, the controller need to tell DPD
      if( done_setup( ad2orx ) = '1' ) then                                 -- software that it will receive ORX data from WHICH antenna and
        nx_state                  <= wait4done;                             -- WHEN that data is valid via s_srx_tuser.
        set_new_user              <= '1'; 
      end if;                                                               -- QUESTTION: DO WE NEED TO CHECK HOW INTERNAL CALIB SETUP ?
                                                                            --       I haven't checked it here!
      --done_setup( ad2calib )  = '1'                                       

    when wait4done =>
      if( cmd_tready_reg( ad2orx   ) = '1' and 
          cmd_tready_reg( ad2calib ) = '1' ) then
          
          keep_old_config         <= '1';                                   -- store previous orxmode antenna to switch it back to ARM Calib later
      end if;
                    
    when OTHERS =>
end case;
end process comb_logic;
--------------------------------------------------------------------------------
--============================== DATA PATH =====================================
-------------------------------------------------------------------------------- 
-------------------------------------------------------
--  HANDLING S_AXIS_SRX_CTRL_TREADY
-------------------------------------------------------
s_axis_srx_ctrl_tready  <= inform_dpd_cmd_receive;                            -- tready informing ORX switcher has already received 
                                                                              -- command from DPD hardware

-------------------------------------------------------
--  HANDLING M_AXIS_SRX_TUSER
-------------------------------------------------------
control_srx_tuser:process( clk )
variable  new_antenna : std_logic_vector( 2 downto 0 );
variable  count       : integer range 0 to DELAY      ;
begin
    if(rst_n = '0') then
      count       := 0                ;
      new_antenna := (OTHERS => '0')  ;
    end if;

    if( set_new_user = '1' ) then                                             -- Update new user when receiving ack from AD9371
      new_antenna := no_anten         ;     
    end if;

    if( count >= DELAY ) then                                                 -- Using this parameter to align s_axis_srx_tuser
      count             := 0          ;                                       -- and s_axis_srx_tdata
      m_axis_srx_tuser  <= "00000" & new_antenna;
    else
      count             := count + 1  ;
    end if;
end process control_srx_tuser;

keep_prev_config: process( clk )
          ad2calib                <= ad2orx;                                
          ant2calib               <= ant2orx;

-------------------------------------------------------
--  HANDLING DATA PATH WITH PIN_MODE_CONTROLLER
-------------------------------------------------------
control_cmd_tvalid:process( send_command, set_all_to_internal_calib)
begin
    cmd_tvalid_reg  <= (OTHERS => '0');
    ----------------------------------
    -- 00. Enable to send new command
    ----------------------------------
    if( set_all_to_internal_calib = '1' ) then
      cmd_tvalid_reg  <= (OTHERS => '1');
    elsif( send_command = '1' ) then
      cmd_tvalid_reg( ad2orx )    <= '1';
      cmd_tvalid_reg( ad2calib )  <= '1';
    end if;
end process control_cmd_tvalid;

--                                               
output_reg: process( clk )
variable v_no_ad9371  : std_logic_vector( 1 downto 0 );
variable v_no_anten   : std_logic_vector( 2 downto 0 );
begin
  if rising_edge( clk ) then
      ----------------------------------
      -- 01. parse input ONLY WHEN 
      ----------------------------------
      if( read_cmd_from_dpd = '1' ) then
          no_ad9371   <= s_axis_srx_ctrl_tdata( 2 ) & s_axis_srx_ctrl_tdata( 0 );
          no_anten    <= s_axis_srx_ctrl_tdata( 2 downto 0 );

          v_no_ad9371 := s_axis_srx_ctrl_tdata( 2 ) & s_axis_srx_ctrl_tdata( 0 );
          v_no_anten  := s_axis_srx_ctrl_tdata( 2 downto 0 );

          ad2orx      <= to_integer( unsigned(v_no_ad9371));
          ant2orx     <= to_integer( unsigned(v_no_anten) );
      end if;
      ----------------------------------
      -- 02. Assign new command
      ----------------------------------
      -- Default values
      cmd_tdata_reg   <= (OTHERS => '1');
      
      if( set_all_to_internal_calib = '1' ) then
          cmd_tdata_reg   <= (OTHERS => '1');

      elsif( update_new_assignment = '1' ) then
          case ant2calib is                                                   -- SET arm calib first, since if there is a chance one antenna is chosen 
                                                                              -- as ARM calib and ORX mode simutaneously, 
                                                                              -- ORX should have higher priority.
            when 0  =>
                    cmd_tdata_reg(1 downto 0)   <= "11";                      -- AD9371_1: Calib antenna 0
            when 1  =>
                    cmd_tdata_reg(3 downto 2)   <= "11";                      -- AD9371_2: Calib antenna 0
            when 2  =>
                    cmd_tdata_reg(1 downto 0)   <= "11";                      -- AD9371_1: Calib antenna 1
            when 3  =>
                    cmd_tdata_reg(3 downto 2)   <= "11";    
            when 4  =>
                    cmd_tdata_reg(5 downto 4)   <= "11";
            when 5  =>
                    cmd_tdata_reg(7 downto 6)   <= "11";
            when 6  =>
                    cmd_tdata_reg(5 downto 4)   <= "11";
            when 7  =>
                    cmd_tdata_reg(7 downto 6)   <= "11";
            when others => null;
          end case;
          
          case no_anten is
            when "000" =>
                    cmd_tdata_reg(1 downto 0)   <= "00";                      -- AD9371_1: ORX antenna 0
            when "001" =>
                    cmd_tdata_reg(3 downto 2)   <= "00";                      -- AD9371_2: ORX antenna 0
            when "010" =>
                    cmd_tdata_reg(1 downto 0)   <= "01";                      -- AD9371_1: ORX antenna 1
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
  end if;
end process;





-------------------------------------------------------------------
--========================= PORT MAP ==============================
-------------------------------------------------------------------
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
           
           done_setup           => done_setup(0)              ,
          
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

           done_setup           => done_setup(1)              ,
          
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
           
           done_setup           => done_setup(2)              ,

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
           
           done_setup           => done_setup(3)              ,

           gpio_orx_mode        => gpio_orx_mode (11 downto 9),
           gpio_orx_trigger     => gpio_orx_trigger (3)       ,
           gpio_orx_ack         => gpio_orx_ack(11 downto 9)  
    );

end Behavioral;