----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/28/2018 05:32:11 PM
-- Design Name: 
-- Module Name: tb_orx_test_bd_wrapper - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_orx_test_bd_wrapper is
end tb_orx_test_bd_wrapper;

architecture Behavioral of tb_orx_test_bd_wrapper is

constant NUM_IC            :   integer := 1;
component orx_test_bd_wrapper is
  port (
    clk_clk_n           : in STD_LOGIC_VECTOR ( 0 to 0 );
    clk_clk_p           : in STD_LOGIC_VECTOR ( 0 to 0 );
    ext_reset_in        : in STD_LOGIC;
    m_axis_srx_tdata    : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_srx_tready   : in STD_LOGIC;
    m_axis_srx_tuser    : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_srx_tvalid   : out STD_LOGIC;
    orx1_enable         : out STD_LOGIC_VECTOR ( NUM_IC - 1 downto 0 );
    orx1_sel0           : out STD_LOGIC_VECTOR ( NUM_IC - 1 downto 0 );
    orx1_sel1           : out STD_LOGIC_VECTOR ( NUM_IC - 1 downto 0 );
    orx2_enable         : out STD_LOGIC_VECTOR ( NUM_IC - 1 downto 0 );
    orx2_sel0           : out STD_LOGIC_VECTOR ( NUM_IC - 1 downto 0 );
    orx2_sel1           : out STD_LOGIC_VECTOR ( NUM_IC - 1 downto 0 )
  );
end component orx_test_bd_wrapper;


signal clk_clk_n            :   STD_LOGIC_VECTOR ( 0 to 0 ) := (OTHERS => '0');
signal clk_clk_p            :   STD_LOGIC_VECTOR ( 0 to 0 ) := (OTHERS => '1');           
signal ext_reset_in         :   STD_LOGIC;
signal m_axis_srx_tready    :   STD_LOGIC;
signal clk_period           :   time := 10 ns;

signal m_axis_srx_tdata     :   STD_LOGIC_VECTOR ( 31 downto 0 );
signal m_axis_srx_tuser     :   STD_LOGIC_VECTOR ( 7 downto 0 );
signal m_axis_srx_tvalid    :   STD_LOGIC;
signal orx1_enable          :   STD_LOGIC_VECTOR ( NUM_IC - 1 downto 0 );
signal orx1_sel0            :   STD_LOGIC_VECTOR ( NUM_IC - 1 downto 0 );
signal orx1_sel1            :   STD_LOGIC_VECTOR ( NUM_IC - 1 downto 0 );
signal orx2_enable          :   STD_LOGIC_VECTOR ( NUM_IC - 1 downto 0 );
signal orx2_sel0            :   STD_LOGIC_VECTOR ( NUM_IC - 1 downto 0 );
signal orx2_sel1            :   STD_LOGIC_VECTOR ( NUM_IC - 1 downto 0 );
begin
uut: orx_test_bd_wrapper port map (     clk_clk_n,
                                        clk_clk_p,
                                        ext_reset_in,
                                        m_axis_srx_tdata,
                                        m_axis_srx_tready,
                                        m_axis_srx_tuser,
                                        m_axis_srx_tvalid,
                                        orx1_enable,
                                        orx1_sel0,
                                        orx1_sel1,
                                        orx2_enable,
                                        orx2_sel0,
                                        orx2_sel1 
                        );

clk_clk_n (0) <= not( clk_clk_n (0)) after clk_period/2;
clk_clk_p (0) <= not( clk_clk_n (0));
    
rst_gen:process
begin
    ext_reset_in   <= '0';
    wait for clk_period * 10;
    ext_reset_in   <= '1';
    wait;
end process rst_gen;

end Behavioral;
