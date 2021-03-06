-- (c) Copyright 1995-2018 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: vttek.com.vn:user:vt_orx_switch:2.0
-- IP Revision: 13

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY orx_test_bd_vt_orx_switch_1_0 IS
  PORT (
    clk : IN STD_LOGIC;
    rst_n : IN STD_LOGIC;
    tx_enable : IN STD_LOGIC;
    s_axis_srx_ctrl_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axis_srx_ctrl_tvalid : IN STD_LOGIC;
    s_axis_srx_ctrl_tready : OUT STD_LOGIC;
    m_axis_srx_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_srx_tvalid : OUT STD_LOGIC;
    m_axis_srx_tready : IN STD_LOGIC;
    m_axis_srx_tuser : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    srx_tdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    orx1_sel0 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    orx1_sel1 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    orx1_enable : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    orx2_sel0 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    orx2_sel1 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    orx2_enable : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
  );
END orx_test_bd_vt_orx_switch_1_0;

ARCHITECTURE orx_test_bd_vt_orx_switch_1_0_arch OF orx_test_bd_vt_orx_switch_1_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF orx_test_bd_vt_orx_switch_1_0_arch: ARCHITECTURE IS "yes";
  COMPONENT vt_orx_switch IS
    GENERIC (
      NUM_IC : INTEGER;
      FREQ_MHZ : INTEGER
    );
    PORT (
      clk : IN STD_LOGIC;
      rst_n : IN STD_LOGIC;
      tx_enable : IN STD_LOGIC;
      s_axis_srx_ctrl_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      s_axis_srx_ctrl_tvalid : IN STD_LOGIC;
      s_axis_srx_ctrl_tready : OUT STD_LOGIC;
      m_axis_srx_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_axis_srx_tvalid : OUT STD_LOGIC;
      m_axis_srx_tready : IN STD_LOGIC;
      m_axis_srx_tuser : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      srx_tdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      orx1_sel0 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      orx1_sel1 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      orx1_enable : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      orx2_sel0 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      orx2_sel1 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      orx2_enable : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
  END COMPONENT vt_orx_switch;
  ATTRIBUTE X_CORE_INFO : STRING;
  ATTRIBUTE X_CORE_INFO OF orx_test_bd_vt_orx_switch_1_0_arch: ARCHITECTURE IS "vt_orx_switch,Vivado 2017.2.1";
  ATTRIBUTE CHECK_LICENSE_TYPE : STRING;
  ATTRIBUTE CHECK_LICENSE_TYPE OF orx_test_bd_vt_orx_switch_1_0_arch : ARCHITECTURE IS "orx_test_bd_vt_orx_switch_1_0,vt_orx_switch,{}";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF clk: SIGNAL IS "xilinx.com:signal:clock:1.0 clk CLK";
  ATTRIBUTE X_INTERFACE_INFO OF rst_n: SIGNAL IS "xilinx.com:signal:reset:1.0 rst_n RST";
  ATTRIBUTE X_INTERFACE_INFO OF s_axis_srx_ctrl_tdata: SIGNAL IS "xilinx.com:interface:axis:1.0 s_axis_srx_ctrl TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s_axis_srx_ctrl_tvalid: SIGNAL IS "xilinx.com:interface:axis:1.0 s_axis_srx_ctrl TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axis_srx_ctrl_tready: SIGNAL IS "xilinx.com:interface:axis:1.0 s_axis_srx_ctrl TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_srx_tdata: SIGNAL IS "xilinx.com:interface:axis:1.0 m_axis_srx TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_srx_tvalid: SIGNAL IS "xilinx.com:interface:axis:1.0 m_axis_srx TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_srx_tready: SIGNAL IS "xilinx.com:interface:axis:1.0 m_axis_srx TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_srx_tuser: SIGNAL IS "xilinx.com:interface:axis:1.0 m_axis_srx TUSER";
BEGIN
  U0 : vt_orx_switch
    GENERIC MAP (
      NUM_IC => 2,
      FREQ_MHZ => 245
    )
    PORT MAP (
      clk => clk,
      rst_n => rst_n,
      tx_enable => tx_enable,
      s_axis_srx_ctrl_tdata => s_axis_srx_ctrl_tdata,
      s_axis_srx_ctrl_tvalid => s_axis_srx_ctrl_tvalid,
      s_axis_srx_ctrl_tready => s_axis_srx_ctrl_tready,
      m_axis_srx_tdata => m_axis_srx_tdata,
      m_axis_srx_tvalid => m_axis_srx_tvalid,
      m_axis_srx_tready => m_axis_srx_tready,
      m_axis_srx_tuser => m_axis_srx_tuser,
      srx_tdata => srx_tdata,
      orx1_sel0 => orx1_sel0,
      orx1_sel1 => orx1_sel1,
      orx1_enable => orx1_enable,
      orx2_sel0 => orx2_sel0,
      orx2_sel1 => orx2_sel1,
      orx2_enable => orx2_enable
    );
END orx_test_bd_vt_orx_switch_1_0_arch;
