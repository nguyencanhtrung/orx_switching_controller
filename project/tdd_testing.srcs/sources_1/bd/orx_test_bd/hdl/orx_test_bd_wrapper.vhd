--Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2017.2.1 (lin64) Build 1957588 Wed Aug  9 16:32:10 MDT 2017
--Date        : Fri Dec 28 16:08:30 2018
--Host        : trungnguyen running 64-bit unknown
--Command     : generate_target orx_test_bd_wrapper.bd
--Design      : orx_test_bd_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity orx_test_bd_wrapper is
  port (
    clk_clk_n : in STD_LOGIC_VECTOR ( 0 to 0 );
    clk_clk_p : in STD_LOGIC_VECTOR ( 0 to 0 );
    ext_reset_in : in STD_LOGIC;
    m_axis_srx_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_srx_tready : in STD_LOGIC;
    m_axis_srx_tuser : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_srx_tvalid : out STD_LOGIC;
    orx1_enable : out STD_LOGIC_VECTOR ( 1 downto 0 );
    orx1_sel0 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    orx1_sel1 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    orx2_enable : out STD_LOGIC_VECTOR ( 1 downto 0 );
    orx2_sel0 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    orx2_sel1 : out STD_LOGIC_VECTOR ( 1 downto 0 )
  );
end orx_test_bd_wrapper;

architecture STRUCTURE of orx_test_bd_wrapper is
  component orx_test_bd is
  port (
    clk_clk_p : in STD_LOGIC_VECTOR ( 0 to 0 );
    clk_clk_n : in STD_LOGIC_VECTOR ( 0 to 0 );
    m_axis_srx_tuser : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_srx_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_srx_tvalid : out STD_LOGIC;
    m_axis_srx_tready : in STD_LOGIC;
    ext_reset_in : in STD_LOGIC;
    orx1_sel0 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    orx1_sel1 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    orx1_enable : out STD_LOGIC_VECTOR ( 1 downto 0 );
    orx2_sel0 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    orx2_sel1 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    orx2_enable : out STD_LOGIC_VECTOR ( 1 downto 0 )
  );
  end component orx_test_bd;
begin
orx_test_bd_i: component orx_test_bd
     port map (
      clk_clk_n(0) => clk_clk_n(0),
      clk_clk_p(0) => clk_clk_p(0),
      ext_reset_in => ext_reset_in,
      m_axis_srx_tdata(31 downto 0) => m_axis_srx_tdata(31 downto 0),
      m_axis_srx_tready => m_axis_srx_tready,
      m_axis_srx_tuser(7 downto 0) => m_axis_srx_tuser(7 downto 0),
      m_axis_srx_tvalid => m_axis_srx_tvalid,
      orx1_enable(1 downto 0) => orx1_enable(1 downto 0),
      orx1_sel0(1 downto 0) => orx1_sel0(1 downto 0),
      orx1_sel1(1 downto 0) => orx1_sel1(1 downto 0),
      orx2_enable(1 downto 0) => orx2_enable(1 downto 0),
      orx2_sel0(1 downto 0) => orx2_sel0(1 downto 0),
      orx2_sel1(1 downto 0) => orx2_sel1(1 downto 0)
    );
end STRUCTURE;
