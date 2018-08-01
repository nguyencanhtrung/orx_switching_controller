----------------------------------------------------------------------------------
-- Company: VTTEK
-- Engineer: Nguyen Canh Trung  (trungnc10@viettel.com.vn)
-- 
-- Create Date: 05/29/2018 03:25:18 PM
-- Design Name: 
-- Module Name: pin_mode_controller - Behavioral
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

entity pin_mode_controller is
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
end pin_mode_controller;

architecture Behavioral of pin_mode_controller is
--=================================================================
-- COMPONENT DEFINITION
-------------------------------------------------------------------
component mode_generator is
    Generic(
           PERIOD_1US       : natural := 304;   
           T_MODE_SETUP     : natural := 1;
           T_MODE_HOLD      : natural := 2
          );
    Port ( rst_n            : in STD_LOGIC;
           clk              : in STD_LOGIC;
           
           ready2trigger    : in STD_LOGIC;
           enb_trigger      : out STD_LOGIC;
           
           cmd_tvalid       : in STD_LOGIC;
           cmd_tdata        : in STD_LOGIC_VECTOR(1 downto 0);                -- 00: ORX1, 01: ORX2, OTHERWISE: INTERNAL CALIB
           cmd_tready       : out STD_LOGIC;                                  -- IP ready for a new command

           -- Interface 2 GPIO
           orx_mode         : out STD_LOGIC_VECTOR (2 downto 0)
           );
end component mode_generator;

--
component trigger_generator is
    Generic(    
            PERIOD_1US      : natural := 304;                           
            HIGH_US         : natural := 5;
            LOW_US          : natural := 5
            );
    Port (    
            clk             : in STD_LOGIC;                                
            rst_n           : in STD_LOGIC;
            enb             : in STD_LOGIC;
            orx_trigger     : out STD_LOGIC;
            ready2trigger   : out STD_LOGIC
          );
end component trigger_generator;
--=================================================================
-- STATE definition
-------------------------------------------------------------------
type state is (init, mode_gen, trigger_gen, wait_ack, delay );
signal pre_state, nx_state      :   state;
attribute enum_encoding         :   string;
attribute enum_encoding of state:   type is "one-hot";                      -- "one-hot" or "sequential"
--=================================================================
-- SIGNAL DECLARATION
-------------------------------------------------------------------
constant T_MODE_ACK_IN_CYCLES   : integer := T_MODE_ACK * PERIOD_1US;
constant T_800US 				: integer := 800 * PERIOD_1US;
----------------------
-- MODE GENERATOR 
----------------------
signal cmd2modegen_tdata        :   std_logic_vector( 1 downto 0 );
signal cmd2modegen_tready       :   std_logic                     ;
signal cmd2modegen_tvalid       :   std_logic                     ;

--
signal cmd2modegen_tdata_reg    :   std_logic_vector( 1 downto 0 );
--signal cmd2modegen_tready_reg   :   std_logic                     ;
signal cmd2modegen_tvalid_reg   :   std_logic                     ;

--
signal trigger_gen_ready        :   std_logic;
signal trigger_gen_enb          :   std_logic;
----------------------
-- TRIGGER GENERATOR
----------------------
signal trigger_enable 			:	std_logic;
signal trigger_enable_reg 		:	std_logic;
--signal trigger_ready 			: 	std_logic;
-------------------------------------------------------------------

signal timer                    :   integer range 0 to T_MODE_ACK_IN_CYCLES;                   -- can phai sua lai
signal cmd_tready_reg 			:	std_logic;
-------------------------------------------------------------------
-- ================================================================
-------------------------------------------------------------------
begin       
state_logic: process( clk )
variable count  : integer range 0 to T_MODE_ACK_IN_CYCLES;                                     -- can phai sua lai range
begin
  if rising_edge(clk) then
    if( rst_n = '0' ) then
      pre_state   <= mode_gen;
      count       := 0;
    elsif ( count >= timer ) then
      pre_state   <= nx_state;
      count       := 0;
    else
      count := count + 1;
    end if;
  end if;
end process state_logic;

comb_logic: process ( pre_state, cmd_tvalid, cmd2modegen_tready, trigger_gen_enb )
variable cmd : std_logic_vector( 1 downto 0 );
begin
--------------------
-- Default values
--------------------
timer         			<= 0;
cmd_tready_reg 			<= '0';

cmd2modegen_tvalid_reg	<= '0';
cmd2modegen_tdata_reg	<= cmd_tdata;
wr2reg					<= '0';

trigger_enable_reg 		<= '0';
--
case pre_state is  
  when init 	=>
  	nx_state 					<= init;
  	
  	cmd_tready_reg				<= '1';
  	
	-- What happens if cmd2modegen_tready = '0' for too long
  	if( cmd_tvalid = '1' and cmd2modegen_tready = '1' ) then
  		wr2reg					<= '1';
  		cmd2modegen_tvalid_reg	<= '1';
	    cmd2modegen_tdata_reg	<= cmd_tdata;
  		nx_state    			<= mode_gen;
  	end if;

  when mode_gen =>
	nx_state                  	<= mode_gen;
	-- de-assert valid when mode_generator has already read command.
	if( cmd2modegen_tready = '0' ) then
	    wr2reg					<= '1';
  		cmd2modegen_tvalid_reg	<= '0';				
	    nx_state                <= trigger_gen;
	end if;
          
  when trigger_gen =>
    nx_state               	<= trigger_gen;
    
    -- No need to check trigger_gen_ready, it is checked inside module mode_generator
    if( trigger_gen_enb = '1' ) then
		trigger_enable_reg	<= '1';
		nx_state			<= wait_ack;
    end if;
          
  when wait_ack =>
      nx_state      <= no_ack;
      
      timer 		<=  T_MODE_ACK_IN_CYCLES;
      if( orx_ack /= "000" ) then -- detect acknowledge signal from AD9371
        timer	<= 0;
        nx_state        <= wait_for_800us;
	end if;
      
  when no_ack    =>   
        
  when wait_for_800us =>      -- wait for at least 800 us to accept a new request from DPD
		nx_state 	<= init;
		timer 		<= T_800US;
		
  when OTHERS =>  null;              
end case;
end process comb_logic;


output_reg: process( clk )
begin
  if rising_edge (clk) then
  	if( wr2reg = '1' ) then
     cmd2modegen_tdata    <= cmd2modegen_tdata_reg;
     cmd2modegen_tvalid   <= cmd2modegen_tvalid_reg;
    end if;
    
    trigger_enable		  <= trigger_enable_reg;
    cmd_tready 			  <= cmd_tready_reg;
  end if;
end process;
--========================= PORT MAP ==============================
-- AD9371 - 0
mode_gen_unit: mode_generator 
    generic map (
                    PERIOD_1US,
                    T_MODE_SETUP,
                    T_MODE_HOLD 
                )
    port map (
               rst_n          =>  rst_n,
               clk            =>  clk,
               
               ready2trigger  =>  trigger_gen_ready,
               enb_trigger    =>  trigger_gen_enb,
               
               cmd_tdata      =>  cmd2modegen_tdata,
               cmd_tready     =>  cmd2modegen_tready,
               cmd_tvalid     =>  cmd2modegen_tvalid,
               
               orx_mode       =>  gpio_orx_mode                         
    );
    
trigger_gen_unit: trigger_generator
    generic map ( 
                    PERIOD_1US,  
                    HIGH_US,
                    LOW_US
                )
    port map ( 
                clk           =>  clk,
                rst_n         =>  rst_n,
                enb           =>  trigger_enable,
                orx_trigger   =>  gpio_orx_trigger,
                ready2trigger =>  trigger_gen_ready
            );
end Behavioral;