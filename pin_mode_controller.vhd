----------------------------------------------------------------------------------
-- Company: VTTEK - VIETTEL
-- Engineer: Nguyen Canh Trung (trungnc10@viettel.com.vn)
-- 
-- Create Date: 11/27/2018 03:39:25 PM
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
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vt_orx_switch is
    Generic (
            NUM_IC                      : natural := 4;         -- range 1 to 4
            T_BUFFER                    : natural := 50;        -- unit cycle = 200 ns
            TWO_US                      : natural := 492;       -- unit cycle = 2 us
            ARM_WAIT                    : natural := 888        -- unit cycle = 554 ARM clock cycles (WC: 1 ARM cycle = 6.51 ns)
    );
    Port ( 
            clk                         : in STD_LOGIC;
            rst_n                       : in STD_LOGIC;
            tx_enable                   : in STD_LOGIC;
            
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

-- For report status
type channel_status_type is (Transmit, Receive, Observe);
attribute ENUM_ENCODING: STRING;
attribute ENUM_ENCODING of channel_status_type: type is ”00 01 10”; 

type channel_enum is array (0 to 7) of channel_status_type;
signal channel_status  : channel_enum;
--

signal channel_status_prev  : channel_enum;

component vt_orx_switch is
    Generic (
            NUM_IC                      : natural := 4;         -- range 1 to 4
            FREQ_MHZ                    : natural := 245        -- ONLY 2 OPTIONS - 245 = 245.76 MHz, else 307.2 MHz
    );
    Port ( 
            clk                         : in STD_LOGIC;
            rst_n                       : in STD_LOGIC;
            tx_enable                   : in STD_LOGIC;         -- input from Vanvt21
            
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

            -- Channel status
            channel_status              : in STD_LOGIC_VECTOR (15 downto 0);    -- old status
            
            -- DPD ORX selection
            orx1_sel0                   : out STD_LOGIC_VECTOR (NUM_IC - 1 downto 0);
            orx1_sel1                   : out STD_LOGIC_VECTOR (NUM_IC - 1 downto 0);
            orx1_enable                 : out STD_LOGIC_VECTOR (NUM_IC - 1 downto 0);
            
            orx2_sel0                   : out STD_LOGIC_VECTOR (NUM_IC - 1 downto 0);
            orx2_sel1                   : out STD_LOGIC_VECTOR (NUM_IC - 1 downto 0);
            orx2_enable                 : out STD_LOGIC_VECTOR (NUM_IC - 1 downto 0)
            );
end component;

begin
--------------------------------------------------------------------------------
-- ORX switching controller
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- Report Status
--------------------------------------------------------------------------------
status_define: process (tx_enable, orx1_enable, orx2_enable)
variable v_channel : channel_enum;   
begin
    if ( tx_enable = '1' ) then
        for i in 0 to 7 loop
            if (orx1_enable (i) = '1' OR orx2_enable (i) = '1') then
                v_channel (i) := Observe;
            else
                v_channel (i) := Transmit;
            end if;
        end loop;
    else
        v_channel (i) := Receive;
    end if;

    channel_status     <= v_channel;

end process status_define;
--------------------------------------------------------------------------------

store_prev_status:process (clk)
begin 
    if rising_edge (clk) then
        channel_status_prev <= channel_status;
    end if;
end process store_prev_status;  

end Behavioral;