----------------------------------------------------------------------------------
-- Company: VTTEK - VIETTEL
-- Engineer: Nguyen Canh Trung (trungnc10@viettel.com.vn)
-- 
-- Create Date: 11/27/2018 03:39:25 PM
-- Design Name: 
-- Module Name: vt_orx_switch - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
--              SRX_TDATA (127 downto 96 )  <= IC4
--              SRX_TDATA (95 downto 64)    <= IC3
--              SRX_TDATA (63 downto 32)    <= IC2
--              SRX_TDATA (31 downto 0)     <= IC1
--              ---------------------------------------------------
--              channel_status(15 downto 14)    <=  antenna 1 - IC4 
--              channel_status(13 downto 12)    <=  antenna 0 - IC4 
--              channel_status(11 downto 10)    <=  antenna 1 - IC3 
--              channel_status(9 downto 8)      <=  antenna 0 - IC3 
--              channel_status(7 downto 6)      <=  antenna 1 - IC2 
--              channel_status(5 downto 4)      <=  antenna 0 - IC2 
--              channel_status(3 downto 2)      <=  antenna 1 - IC1 
--              channel_status(1 downto 0)      <=  antenna 0 - IC1
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

entity vt_orx_switch is
    Generic (
            NUM_IC                      : natural := 4;                             -- range 1 to 4
            FREQ_MHZ                    : natural := 245                            -- ONLY 2 OPTIONS - 245 = 245.76 MHz, else 307.2 MHz
    );
    Port ( 
--            db_state                    : out STD_LOGIC_VECTOR ( 7 downto 0 );
--            db_send2ic                  : out STD_LOGIC;
--            db_trigger2switch           : out STD_LOGIC;
--            db_antenna                  : out STD_LOGIC_VECTOR (3 downto 0);
--            db_orx1_enable_reg 			: out STD_LOGIC_VECTOR (NUM_IC - 1 downto 0);
--            db_orx2_enable_reg 			: out STD_LOGIC_VECTOR (NUM_IC - 1 downto 0);

            clk                         : in STD_LOGIC;
            rst_n                       : in STD_LOGIC;
            tx_enable                   : in STD_LOGIC;                             -- read_enable from TDD controller - ensure RF's already ON
            
            -- Input command from DPD
            s_axis_srx_ctrl_tdata       : in STD_LOGIC_VECTOR (7 downto 0);
            s_axis_srx_ctrl_tvalid      : in STD_LOGIC;
            s_axis_srx_ctrl_tready      : out STD_LOGIC;
            
            -- Output SRX data to DPD
            m_axis_srx_tdata            : out STD_LOGIC_VECTOR (31 downto 0);         
            m_axis_srx_tvalid           : out STD_LOGIC;
            m_axis_srx_tready           : in STD_LOGIC;
            m_axis_srx_tuser            : out STD_LOGIC_VECTOR (7 downto 0);
            
            -- SRX data
            srx_tdata                   : in STD_LOGIC_VECTOR (32 * NUM_IC - 1 downto 0); 
            
            -- DPD ORX selection
            orx1_sel0                   : out STD_LOGIC_VECTOR (NUM_IC - 1 downto 0);
            orx1_sel1                   : out STD_LOGIC_VECTOR (NUM_IC - 1 downto 0);
            orx1_enable                 : out STD_LOGIC_VECTOR (NUM_IC - 1 downto 0);
            
            orx2_sel0                   : out STD_LOGIC_VECTOR (NUM_IC - 1 downto 0);
            orx2_sel1                   : out STD_LOGIC_VECTOR (NUM_IC - 1 downto 0);
            orx2_enable                 : out STD_LOGIC_VECTOR (NUM_IC - 1 downto 0)
            );
end vt_orx_switch;

architecture Behavioral of vt_orx_switch is
-- constant

constant ORX_HIGH_ARM_CYCLE     : natural := 138;
constant RX_TO_ORX_ARM_CYCLE    : natural := 554;

--constant FLOAT_PERIOD           : real    := (FREQ_MHZ == 245) ? real(4.069) : real(3.255);
--constant ORX_HIGH_ARM_WAIT      : integer := integer (CEIL ( ORX_HIGH_ARM_CYCLE * 6.51 / FLOAT_PERIOD));
constant ORX_HIGH_ARM_WAIT      : integer := 222;       -- 138 ARM clock cycle - Quy doi theo tan so 245.76 MHz
--constant RX_TO_ORX_ARM_WAIT     : integer := 888;       -- unit cycle = 554 ARM clock cycles (WC: 1 ARM cycle = 6.51 ns)
constant TWO_US                 : integer := 492;       -- unit cycle = 2 us
constant T_BUFFER               : integer := 50;        -- unit cycle = 200 ns

-- state definition
type state is (INIT, WAIT_CMD_FROM_DPD, READ_DPD_CMD, STORE_ANTEN_INDEX, SETUP, ENABLE_ORX2, ENABLE_ORX1, SEND2IC, WAIT_STATE, SRX_STREAM);
signal pre_state, nx_state  :   state;
attribute enum_encoding     :   string;
attribute enum_encoding of state: type is "gray";

--type channel_status_type is (transmit, receive, observation);
--attribute enum_encoding of channel_status_type: type is "00 01 10";

--type channel_enum is array (0 to 7) of channel_status_type;
--signal channel_status_reg   : channel_enum;


-- reg
signal orx1_sel0_reg                    : STD_LOGIC_VECTOR (NUM_IC - 1 downto 0);
signal orx1_sel1_reg                    : STD_LOGIC_VECTOR (NUM_IC - 1 downto 0);
signal orx1_enable_reg                  : STD_LOGIC_VECTOR (NUM_IC - 1 downto 0);

signal orx2_sel0_reg                    : STD_LOGIC_VECTOR (NUM_IC - 1 downto 0);
signal orx2_sel1_reg                    : STD_LOGIC_VECTOR (NUM_IC - 1 downto 0);
signal orx2_enable_reg                  : STD_LOGIC_VECTOR (NUM_IC - 1 downto 0);

signal confirm_received_cmd_from_dpd    : STD_LOGIC;

signal antenna_sel                      : unsigned (2 downto 0);                     -- Extract antenna number from input data
signal srx_data_from_antenna			: STD_LOGIC_VECTOR (7 downto 0);
signal inform_dpd_about_antenna_info	: STD_LOGIC;

signal srx_data_valid_reg               : STD_LOGIC;
signal trigger2switch                   : STD_LOGIC;
signal send_cmd_to_ic					: STD_LOGIC;

signal ctrl_store_antenna_index         : STD_LOGIC;
signal ctrl_index_extract_1             : STD_LOGIC;
signal ctrl_index_extract_2             : STD_LOGIC;
signal ctrl_set_gpio_orx1               : STD_LOGIC;
signal ctrl_set_gpio_orx2               : STD_LOGIC;
signal ctrl_reset_gpio_to_default       : STD_LOGIC;

--
signal timer							: integer;

-- Boundary of srx data
signal high                             : natural := 31;

signal antenna_dpd_need                 : integer range 0 to 7;

begin
--------------------------------------------------------------------------------
-- MAPPING channel 
--  channel_status_reg(0) : channel0_status     IC1
--  channel_status_reg(1) : channel2_status     IC2
--  channel_status_reg(2) : channel4_status     IC3   antenna 0
--  channel_status_reg(3) : channel6_status     IC4

--  channel_status_reg(4) : channel1_status     IC1
--  channel_status_reg(5) : channel3_status     IC2   antenna 1
--  channel_status_reg(6) : channel5_status     IC3
--  channel_status_reg(7) : channel7_status     IC4
--------------------------------------------------------------------------------
--channel_status_reg (0)  <= channel_status(1 downto 0);
--channel_status_reg (1)  <= channel_status (5 downto 4);
--channel_status_reg (2)  <= channel_status (9 downto 8);
--channel_status_reg (3)  <= channel_status (13 downto 12);

--channel_status_reg (4)  <= channel_status (3 downto 2);
--channel_status_reg (5)  <= channel_status (7 downto 6);
--channel_status_reg (6)  <= channel_status (11 downto 10);
--channel_status_reg (7)  <= channel_status (15 downto 14);

--------------------------------------------------------------------------------
-- Enable ORX enable switch 
-- Assume tx_enable is synchronous to clk; if not we need an synchronizer
trigger2switch  <= s_axis_srx_ctrl_tvalid AND tx_enable;
--
--
antenna_sel     <= unsigned( s_axis_srx_ctrl_tdata( 2 downto 0) );


--db_send2ic          <= send_cmd_to_ic;
--db_trigger2switch   <= trigger2switch;
--db_antenna          <= std_logic_vector (to_unsigned( antenna_dpd_need, 4) );
--db_orx1_enable_reg 	<= orx1_enable_reg;
--db_orx2_enable_reg	<= orx2_enable_reg;
--------------------------------------------------------------------------------
-- Flipflops
--------------------------------------------------------------------------------
state_flipflop: process (clk)
variable count : integer;
begin
    if rising_edge (clk) then
        if( rst_n = '0' ) then                                                      --  synchronous reset
            pre_state           <= INIT;
            count				:= 0;
        elsif (count >= timer) then
            pre_state           <= nx_state;
            count 				:= 0;
        else 
        	count 				:= count + 1;
        end if; 
    end if;
end process state_flipflop;

--------------------------------------------------------------------------------
state_logic: process (pre_state, trigger2switch)
begin
    case pre_state is
        when INIT   =>        
            nx_state        <= WAIT_CMD_FROM_DPD;

        when WAIT_CMD_FROM_DPD   =>
            if trigger2switch = '1' then
                nx_state    <= READ_DPD_CMD;
            else
                nx_state    <= WAIT_CMD_FROM_DPD;
            end if; 
             
        when READ_DPD_CMD => 
            nx_state        <= STORE_ANTEN_INDEX;
        
        when STORE_ANTEN_INDEX =>
            nx_state        <= SETUP;
            
        when SETUP  =>
            if (antenna_dpd_need > NUM_IC - 1) then
                nx_state    <= ENABLE_ORX2;
            else
                nx_state    <= ENABLE_ORX1;
            end if;
            
        when ENABLE_ORX2 =>
            nx_state        <= SEND2IC;
            
        when ENABLE_ORX1 =>
            nx_state        <= SEND2IC;
        
        when SEND2IC =>
            nx_state        <= WAIT_STATE;
        
        when WAIT_STATE =>
            nx_state        <= SRX_STREAM;      

        when SRX_STREAM =>
            nx_state        <= WAIT_CMD_FROM_DPD;
 
        when OTHERS =>
            nx_state        <= INIT;
    end case;
end process state_logic;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Timer setting
timer_setting: process(pre_state)
begin
    case pre_state is        
        when WAIT_STATE =>
            timer   <= T_BUFFER + TWO_US + ORX_HIGH_ARM_WAIT;
        	
        when OTHERS =>
            timer   <= 0;
    end case;
end process timer_setting;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Interface with DPD
-- 1.   Capture antenna index ( HANDSHAKE PROTOCOL)
-- 1.1. Generate trigger to capture cmd from dpd
trigger_store_ant_index: process (pre_state)
begin
    case pre_state is
        when READ_DPD_CMD  =>
            -- Antenna index which DPD needs ORX data
            ctrl_store_antenna_index    <= '1';
            
        when OTHERS =>
            ctrl_store_antenna_index    <= '0';      
    end case;
end process trigger_store_ant_index;

-- 1.2. Infer flipflop to avoid latch
read_antenna_index: process (clk)
begin
    if rising_edge (clk) then
        if (ctrl_store_antenna_index = '1') then
            antenna_dpd_need    <= to_integer( antenna_sel );
        end if;
    end if;
end process read_antenna_index;

-- 1.3. Inform DPD 
inform_dpd: process (pre_state)
begin
    case pre_state is
        when READ_DPD_CMD  =>
            -- Inform DPD that I've already read its command
            confirm_received_cmd_from_dpd     <= '1';
            
        when OTHERS =>
            confirm_received_cmd_from_dpd     <= '0';      
    end case;
end process inform_dpd;

-------------------------------
-- SRX DATA validity
-------------------------------
srx_data_validate: process (pre_state)
--variable antenna_number     : NATURAL range 0 to 7;   -- DPD requires data from this antenna 
begin
    case pre_state is
        when WAIT_CMD_FROM_DPD   =>
            srx_data_valid_reg  <= '1';
 
        when READ_DPD_CMD  => 
            srx_data_valid_reg  <= '1';
            
        when STORE_ANTEN_INDEX  => 
            srx_data_valid_reg  <= '1';
        
        when SETUP  =>
            srx_data_valid_reg  <= '1';
            
        when ENABLE_ORX1 =>
            srx_data_valid_reg  <= '1';
            
        when ENABLE_ORX2 =>
            srx_data_valid_reg  <= '1';
            
        when SEND2IC =>
            srx_data_valid_reg  <= '1';
            
        when WAIT_STATE =>
            srx_data_valid_reg  <= '1';

        when SRX_STREAM =>
            srx_data_valid_reg  <= '1';
         
        when OTHERS =>
            srx_data_valid_reg  <= '0';	
            
    end case;
end process srx_data_validate;

-------------------------------
-- switch to a new ORX
-------------------------------
enable_orx_stream: process (pre_state)
--variable antenna_number     : NATURAL range 0 to 7;   -- DPD requires data from this antenna 
begin
    case pre_state is
        when SRX_STREAM =>
            inform_dpd_about_antenna_info     <= '1';
         
        when OTHERS =>	
            inform_dpd_about_antenna_info     <= '0';
            
    end case;
end process enable_orx_stream;

--------------------------------------------------------------------------------
-- Output logic
--------------------------------------------------------------------------------
trigger_setup_gpio: process(pre_state)
begin
    case pre_state is
        when INIT   =>
            -- Set all in TX tracking calibration
            ctrl_set_gpio_orx1          <= '0';
            ctrl_set_gpio_orx2          <= '0'; 
            ctrl_reset_gpio_to_default  <= '1';

        when SETUP  =>
            -- RESET all setting to default
            ctrl_set_gpio_orx1          <= '0';
            ctrl_set_gpio_orx2          <= '0'; 
            ctrl_reset_gpio_to_default  <= '1';  
            
         when ENABLE_ORX2   =>                      
            ctrl_set_gpio_orx1          <= '0';
            ctrl_set_gpio_orx2          <= '1'; 
            ctrl_reset_gpio_to_default  <= '0'; 
            
         when ENABLE_ORX1   =>     
            ctrl_set_gpio_orx1          <= '1';
            ctrl_set_gpio_orx2          <= '0';   
            ctrl_reset_gpio_to_default  <= '0';  
                
         when OTHERS        => 
            ctrl_set_gpio_orx1          <= '0';
            ctrl_set_gpio_orx2          <= '0'; 
            ctrl_reset_gpio_to_default  <= '0';  
    end case;
end process trigger_setup_gpio;

---
setup_gpio2ic: process (clk)
begin
    if rising_edge (clk) then
        send_cmd_to_ic                     <= '0';
        
        if (ctrl_set_gpio_orx1 = '1') then
            orx1_enable_reg (antenna_dpd_need)  <= '1';
            send_cmd_to_ic                 <= '1';
        end if;
            
        if (ctrl_set_gpio_orx2 = '1') then
            orx2_enable_reg (antenna_dpd_need - NUM_IC)  <= '1';
            send_cmd_to_ic                 <= '1';
        end if;
        
        if (ctrl_reset_gpio_to_default = '1') then
            orx1_sel0_reg                  <= (OTHERS => '0');                                  
            orx1_sel1_reg                  <= (OTHERS => '1');                                  
            orx1_enable_reg                <= (OTHERS => '0');                              
            
            orx2_sel0_reg                  <= (OTHERS => '1');                                  
            orx2_sel1_reg                  <= (OTHERS => '1');
            orx2_enable_reg                <= (OTHERS => '0');
            
            send_cmd_to_ic                 <= '1';
        end if; 
    end if;
end process setup_gpio2ic;

-- setup ORXx_SELx to inform ARM on ADRV9009
orx1_sel0_reg                  <= (OTHERS => '0');      -- TX1 is routed to ORX1                   
orx1_sel1_reg                  <= (OTHERS => '1');                                                                

orx2_sel0_reg                  <= (OTHERS => '1');      -- TX2 is routed to ORX2                     
orx2_sel1_reg                  <= (OTHERS => '1');

---
trigger_orx_index_calculation: process(pre_state)
begin
    case pre_state is
         when ENABLE_ORX2   =>
            ctrl_index_extract_2  <= '1';
            ctrl_index_extract_1  <= '0';
            
         when ENABLE_ORX1   =>
            ctrl_index_extract_2  <= '0';
            ctrl_index_extract_1  <= '1';
            
         when OTHERS        =>
            ctrl_index_extract_1  <= '0';
            ctrl_index_extract_2  <= '0';   
    end case;
end process trigger_orx_index_calculation;

-- 
index_to_extract_orx_data: process ( clk )
begin
    if rising_edge (clk) then
        if (ctrl_index_extract_1 = '1') then
            high    <= (antenna_dpd_need + 1)*32 - 1;
        end if;
        
        if (ctrl_index_extract_2 = '1') then
            high    <= (antenna_dpd_need - NUM_IC + 1)*32 - 1;
        end if;
    end if;
end process index_to_extract_orx_data;
-------------------------------
-- enable send command to ic
-------------------------------
--send_cmd2ic: process(pre_state)
--begin
--    case pre_state is
--        when INIT   =>
--            send_cmd_to_ic  <= '1';

--        when SEND2IC =>
--            send_cmd_to_ic  <= '1';

--        when OTHERS =>
--            send_cmd_to_ic  <= '0';
--    end case;
--end process send_cmd2ic;

--------------------------------------------------------------------------------
-- IC interface
-- First test: OK
--------------------------------------------------------------------------------
ic_interface: process (clk)
begin
	if rising_edge (clk) then
    	if send_cmd_to_ic = '1' then
	        orx1_sel0               <= orx1_sel0_reg;
	        orx1_sel1               <= orx1_sel1_reg;
	        orx1_enable             <= orx1_enable_reg;
	        
	        orx2_sel0               <= orx2_sel0_reg;
	        orx2_sel1               <= orx2_sel1_reg;
	        orx2_enable             <= orx2_enable_reg;
	    end if;
	    
	    if (tx_enable = '0') then
	       orx1_enable             <= (others => '0');
	       orx2_enable             <= (others => '0');
	    end if;
	 end if;
end process ic_interface;

--------------------------------------------------------------------------------
-- DPD interface
--------------------------------------------------------------------------------
s_axis_srx_ctrl_tready  <= confirm_received_cmd_from_dpd;

to_dpd: process (clk)
begin
	if rising_edge (clk) then
		if inform_dpd_about_antenna_info = '1' then
			m_axis_srx_tuser         <= std_logic_vector (to_unsigned( antenna_dpd_need, 8) );  
		end if;
		
		m_axis_srx_tdata             <= srx_tdata (high downto high - 31);
        m_axis_srx_tvalid            <= srx_data_valid_reg;
	end if;
end process to_dpd;

end Behavioral;