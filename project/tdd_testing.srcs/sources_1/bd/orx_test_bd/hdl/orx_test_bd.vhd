--Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2017.2.1 (lin64) Build 1957588 Wed Aug  9 16:32:10 MDT 2017
--Date        : Fri Dec 28 16:08:30 2018
--Host        : trungnguyen running 64-bit unknown
--Command     : generate_target orx_test_bd.bd
--Design      : orx_test_bd
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity orx_test_bd is
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
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of orx_test_bd : entity is "orx_test_bd,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=orx_test_bd,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=12,numReposBlks=12,numNonXlnxBlks=3,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=2,numPkgbdBlks=0,bdsource=USER,synth_mode=Global}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of orx_test_bd : entity is "orx_test_bd.hwdef";
end orx_test_bd;

architecture STRUCTURE of orx_test_bd is
  component orx_test_bd_tdd_simulation_1_0 is
  port (
    clk_100M : in STD_LOGIC;
    rst_n : in STD_LOGIC;
    tx_enable : out STD_LOGIC
  );
  end component orx_test_bd_tdd_simulation_1_0;
  component orx_test_bd_dpd_cmd_simulation_0_0 is
  port (
    db_state_value : out STD_LOGIC_VECTOR ( 2 downto 0 );
    db_sendcmd : out STD_LOGIC;
    db_antenna : out STD_LOGIC_VECTOR ( 3 downto 0 );
    clk : in STD_LOGIC;
    rst_n : in STD_LOGIC;
    m_axis_srx_ctrl_tdata : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_srx_ctrl_tvalid : out STD_LOGIC;
    m_axis_srx_ctrl_tready : in STD_LOGIC
  );
  end component orx_test_bd_dpd_cmd_simulation_0_0;
  component orx_test_bd_ic0_0 is
  port (
    dout : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component orx_test_bd_ic0_0;
  component orx_test_bd_ic0_1 is
  port (
    dout : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component orx_test_bd_ic0_1;
  component orx_test_bd_ic2_0 is
  port (
    dout : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component orx_test_bd_ic2_0;
  component orx_test_bd_proc_sys_reset_0_0 is
  port (
    slowest_sync_clk : in STD_LOGIC;
    ext_reset_in : in STD_LOGIC;
    aux_reset_in : in STD_LOGIC;
    mb_debug_sys_rst : in STD_LOGIC;
    dcm_locked : in STD_LOGIC;
    mb_reset : out STD_LOGIC;
    bus_struct_reset : out STD_LOGIC_VECTOR ( 0 to 0 );
    peripheral_reset : out STD_LOGIC_VECTOR ( 0 to 0 );
    interconnect_aresetn : out STD_LOGIC_VECTOR ( 0 to 0 );
    peripheral_aresetn : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component orx_test_bd_proc_sys_reset_0_0;
  component orx_test_bd_system_ila_1_0 is
  port (
    clk : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 3 downto 0 );
    probe1 : in STD_LOGIC_VECTOR ( 2 downto 0 );
    probe2 : in STD_LOGIC_VECTOR ( 0 to 0 );
    SLOT_0_AXIS_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    SLOT_0_AXIS_tlast : in STD_LOGIC;
    SLOT_0_AXIS_tvalid : in STD_LOGIC;
    SLOT_0_AXIS_tready : in STD_LOGIC;
    resetn : in STD_LOGIC
  );
  end component orx_test_bd_system_ila_1_0;
  component orx_test_bd_util_ds_buf_0_0 is
  port (
    IBUF_DS_P : in STD_LOGIC_VECTOR ( 0 to 0 );
    IBUF_DS_N : in STD_LOGIC_VECTOR ( 0 to 0 );
    IBUF_OUT : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component orx_test_bd_util_ds_buf_0_0;
  component orx_test_bd_xlconcat_0_0 is
  port (
    In0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    In1 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    In2 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    In3 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    dout : out STD_LOGIC_VECTOR ( 127 downto 0 )
  );
  end component orx_test_bd_xlconcat_0_0;
  component orx_test_bd_xlconstant_0_1 is
  port (
    dout : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component orx_test_bd_xlconstant_0_1;
  component orx_test_bd_system_ila_0_0 is
  port (
    clk : in STD_LOGIC;
    resetn : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 1 downto 0 );
    probe1 : in STD_LOGIC_VECTOR ( 1 downto 0 );
    probe2 : in STD_LOGIC_VECTOR ( 1 downto 0 );
    probe3 : in STD_LOGIC_VECTOR ( 1 downto 0 );
    probe4 : in STD_LOGIC_VECTOR ( 1 downto 0 );
    probe5 : in STD_LOGIC_VECTOR ( 1 downto 0 );
    SLOT_0_AXIS_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    SLOT_0_AXIS_tlast : in STD_LOGIC;
    SLOT_0_AXIS_tvalid : in STD_LOGIC;
    SLOT_0_AXIS_tready : in STD_LOGIC;
    SLOT_1_AXIS_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    SLOT_1_AXIS_tlast : in STD_LOGIC;
    SLOT_1_AXIS_tuser : in STD_LOGIC_VECTOR ( 7 downto 0 );
    SLOT_1_AXIS_tvalid : in STD_LOGIC;
    SLOT_1_AXIS_tready : in STD_LOGIC
  );
  end component orx_test_bd_system_ila_0_0;
  component orx_test_bd_vt_orx_switch_1_0 is
  port (
    clk : in STD_LOGIC;
    rst_n : in STD_LOGIC;
    tx_enable : in STD_LOGIC;
    s_axis_srx_ctrl_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axis_srx_ctrl_tvalid : in STD_LOGIC;
    s_axis_srx_ctrl_tready : out STD_LOGIC;
    m_axis_srx_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_srx_tvalid : out STD_LOGIC;
    m_axis_srx_tready : in STD_LOGIC;
    m_axis_srx_tuser : out STD_LOGIC_VECTOR ( 7 downto 0 );
    srx_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    orx1_sel0 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    orx1_sel1 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    orx1_enable : out STD_LOGIC_VECTOR ( 1 downto 0 );
    orx2_sel0 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    orx2_sel1 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    orx2_enable : out STD_LOGIC_VECTOR ( 1 downto 0 )
  );
  end component orx_test_bd_vt_orx_switch_1_0;
  signal CLK_IN_D_1_CLK_N : STD_LOGIC_VECTOR ( 0 to 0 );
  signal CLK_IN_D_1_CLK_P : STD_LOGIC_VECTOR ( 0 to 0 );
  signal clk_1 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal dpd_cmd_simulation_0_db_antenna : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal dpd_cmd_simulation_0_db_sendcmd : STD_LOGIC;
  signal dpd_cmd_simulation_0_db_state_value : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal dpd_cmd_simulation_0_m_axis_srx_ctrl_TDATA : STD_LOGIC_VECTOR ( 7 downto 0 );
  attribute CONN_BUS_INFO : string;
  attribute CONN_BUS_INFO of dpd_cmd_simulation_0_m_axis_srx_ctrl_TDATA : signal is "dpd_cmd_simulation_0_m_axis_srx_ctrl xilinx.com:interface:axis:1.0 None TDATA";
  attribute DONT_TOUCH : boolean;
  attribute DONT_TOUCH of dpd_cmd_simulation_0_m_axis_srx_ctrl_TDATA : signal is std.standard.true;
  signal dpd_cmd_simulation_0_m_axis_srx_ctrl_TREADY : STD_LOGIC;
  attribute CONN_BUS_INFO of dpd_cmd_simulation_0_m_axis_srx_ctrl_TREADY : signal is "dpd_cmd_simulation_0_m_axis_srx_ctrl xilinx.com:interface:axis:1.0 None TREADY";
  attribute DONT_TOUCH of dpd_cmd_simulation_0_m_axis_srx_ctrl_TREADY : signal is std.standard.true;
  signal dpd_cmd_simulation_0_m_axis_srx_ctrl_TVALID : STD_LOGIC;
  attribute CONN_BUS_INFO of dpd_cmd_simulation_0_m_axis_srx_ctrl_TVALID : signal is "dpd_cmd_simulation_0_m_axis_srx_ctrl xilinx.com:interface:axis:1.0 None TVALID";
  attribute DONT_TOUCH of dpd_cmd_simulation_0_m_axis_srx_ctrl_TVALID : signal is std.standard.true;
  signal ext_reset_in_1 : STD_LOGIC;
  signal ic1_dout : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal ic2_dout : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal ic3_dout : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal proc_sys_reset_0_peripheral_aresetn : STD_LOGIC_VECTOR ( 0 to 0 );
  signal tdd_simulation_1_tx_enable : STD_LOGIC;
  signal vt_orx_switch_0_m_axis_srx_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  attribute CONN_BUS_INFO of vt_orx_switch_0_m_axis_srx_TDATA : signal is "vt_orx_switch_0_m_axis_srx xilinx.com:interface:axis:1.0 None TDATA";
  attribute DONT_TOUCH of vt_orx_switch_0_m_axis_srx_TDATA : signal is std.standard.true;
  signal vt_orx_switch_0_m_axis_srx_TREADY : STD_LOGIC;
  attribute CONN_BUS_INFO of vt_orx_switch_0_m_axis_srx_TREADY : signal is "vt_orx_switch_0_m_axis_srx xilinx.com:interface:axis:1.0 None TREADY";
  attribute DONT_TOUCH of vt_orx_switch_0_m_axis_srx_TREADY : signal is std.standard.true;
  signal vt_orx_switch_0_m_axis_srx_TUSER : STD_LOGIC_VECTOR ( 7 downto 0 );
  attribute CONN_BUS_INFO of vt_orx_switch_0_m_axis_srx_TUSER : signal is "vt_orx_switch_0_m_axis_srx xilinx.com:interface:axis:1.0 None TUSER";
  attribute DONT_TOUCH of vt_orx_switch_0_m_axis_srx_TUSER : signal is std.standard.true;
  signal vt_orx_switch_0_m_axis_srx_TVALID : STD_LOGIC;
  attribute CONN_BUS_INFO of vt_orx_switch_0_m_axis_srx_TVALID : signal is "vt_orx_switch_0_m_axis_srx xilinx.com:interface:axis:1.0 None TVALID";
  attribute DONT_TOUCH of vt_orx_switch_0_m_axis_srx_TVALID : signal is std.standard.true;
  signal vt_orx_switch_0_orx1_enable : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal vt_orx_switch_0_orx1_sel0 : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal vt_orx_switch_0_orx1_sel1 : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal vt_orx_switch_0_orx2_enable : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal vt_orx_switch_0_orx2_sel0 : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal vt_orx_switch_0_orx2_sel1 : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal xlconcat_0_dout : STD_LOGIC_VECTOR ( 127 downto 0 );
  signal xlconstant_0_dout : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_proc_sys_reset_0_mb_reset_UNCONNECTED : STD_LOGIC;
  signal NLW_proc_sys_reset_0_bus_struct_reset_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_proc_sys_reset_0_interconnect_aresetn_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_proc_sys_reset_0_peripheral_reset_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
begin
  CLK_IN_D_1_CLK_N(0) <= clk_clk_n(0);
  CLK_IN_D_1_CLK_P(0) <= clk_clk_p(0);
  ext_reset_in_1 <= ext_reset_in;
  m_axis_srx_tdata(31 downto 0) <= vt_orx_switch_0_m_axis_srx_TDATA(31 downto 0);
  m_axis_srx_tuser(7 downto 0) <= vt_orx_switch_0_m_axis_srx_TUSER(7 downto 0);
  m_axis_srx_tvalid <= vt_orx_switch_0_m_axis_srx_TVALID;
  orx1_enable(1 downto 0) <= vt_orx_switch_0_orx1_enable(1 downto 0);
  orx1_sel0(1 downto 0) <= vt_orx_switch_0_orx1_sel0(1 downto 0);
  orx1_sel1(1 downto 0) <= vt_orx_switch_0_orx1_sel1(1 downto 0);
  orx2_enable(1 downto 0) <= vt_orx_switch_0_orx2_enable(1 downto 0);
  orx2_sel0(1 downto 0) <= vt_orx_switch_0_orx2_sel0(1 downto 0);
  orx2_sel1(1 downto 0) <= vt_orx_switch_0_orx2_sel1(1 downto 0);
  vt_orx_switch_0_m_axis_srx_TREADY <= m_axis_srx_tready;
dpd_cmd_simulation_0: component orx_test_bd_dpd_cmd_simulation_0_0
     port map (
      clk => clk_1(0),
      db_antenna(3 downto 0) => dpd_cmd_simulation_0_db_antenna(3 downto 0),
      db_sendcmd => dpd_cmd_simulation_0_db_sendcmd,
      db_state_value(2 downto 0) => dpd_cmd_simulation_0_db_state_value(2 downto 0),
      m_axis_srx_ctrl_tdata(7 downto 0) => dpd_cmd_simulation_0_m_axis_srx_ctrl_TDATA(7 downto 0),
      m_axis_srx_ctrl_tready => dpd_cmd_simulation_0_m_axis_srx_ctrl_TREADY,
      m_axis_srx_ctrl_tvalid => dpd_cmd_simulation_0_m_axis_srx_ctrl_TVALID,
      rst_n => proc_sys_reset_0_peripheral_aresetn(0)
    );
ic0: component orx_test_bd_xlconstant_0_1
     port map (
      dout(31 downto 0) => xlconstant_0_dout(31 downto 0)
    );
ic1: component orx_test_bd_ic0_0
     port map (
      dout(31 downto 0) => ic1_dout(31 downto 0)
    );
ic2: component orx_test_bd_ic0_1
     port map (
      dout(31 downto 0) => ic2_dout(31 downto 0)
    );
ic3: component orx_test_bd_ic2_0
     port map (
      dout(31 downto 0) => ic3_dout(31 downto 0)
    );
proc_sys_reset_0: component orx_test_bd_proc_sys_reset_0_0
     port map (
      aux_reset_in => '1',
      bus_struct_reset(0) => NLW_proc_sys_reset_0_bus_struct_reset_UNCONNECTED(0),
      dcm_locked => '1',
      ext_reset_in => ext_reset_in_1,
      interconnect_aresetn(0) => NLW_proc_sys_reset_0_interconnect_aresetn_UNCONNECTED(0),
      mb_debug_sys_rst => '0',
      mb_reset => NLW_proc_sys_reset_0_mb_reset_UNCONNECTED,
      peripheral_aresetn(0) => proc_sys_reset_0_peripheral_aresetn(0),
      peripheral_reset(0) => NLW_proc_sys_reset_0_peripheral_reset_UNCONNECTED(0),
      slowest_sync_clk => clk_1(0)
    );
system_ila_0: component orx_test_bd_system_ila_0_0
     port map (
      SLOT_0_AXIS_tdata(31 downto 8) => B"000000000000000000000000",
      SLOT_0_AXIS_tdata(7 downto 0) => dpd_cmd_simulation_0_m_axis_srx_ctrl_TDATA(7 downto 0),
      SLOT_0_AXIS_tlast => '0',
      SLOT_0_AXIS_tready => dpd_cmd_simulation_0_m_axis_srx_ctrl_TREADY,
      SLOT_0_AXIS_tvalid => dpd_cmd_simulation_0_m_axis_srx_ctrl_TVALID,
      SLOT_1_AXIS_tdata(31 downto 0) => vt_orx_switch_0_m_axis_srx_TDATA(31 downto 0),
      SLOT_1_AXIS_tlast => '0',
      SLOT_1_AXIS_tready => vt_orx_switch_0_m_axis_srx_TREADY,
      SLOT_1_AXIS_tuser(7 downto 0) => vt_orx_switch_0_m_axis_srx_TUSER(7 downto 0),
      SLOT_1_AXIS_tvalid => vt_orx_switch_0_m_axis_srx_TVALID,
      clk => clk_1(0),
      probe0(1 downto 0) => vt_orx_switch_0_orx1_sel0(1 downto 0),
      probe1(1 downto 0) => vt_orx_switch_0_orx1_sel1(1 downto 0),
      probe2(1 downto 0) => vt_orx_switch_0_orx1_enable(1 downto 0),
      probe3(1 downto 0) => vt_orx_switch_0_orx2_sel0(1 downto 0),
      probe4(1 downto 0) => vt_orx_switch_0_orx2_sel1(1 downto 0),
      probe5(1 downto 0) => vt_orx_switch_0_orx2_enable(1 downto 0),
      resetn => proc_sys_reset_0_peripheral_aresetn(0)
    );
system_ila_1: component orx_test_bd_system_ila_1_0
     port map (
      SLOT_0_AXIS_tdata(31 downto 8) => B"000000000000000000000000",
      SLOT_0_AXIS_tdata(7 downto 0) => dpd_cmd_simulation_0_m_axis_srx_ctrl_TDATA(7 downto 0),
      SLOT_0_AXIS_tlast => '0',
      SLOT_0_AXIS_tready => dpd_cmd_simulation_0_m_axis_srx_ctrl_TREADY,
      SLOT_0_AXIS_tvalid => dpd_cmd_simulation_0_m_axis_srx_ctrl_TVALID,
      clk => clk_1(0),
      probe0(3 downto 0) => dpd_cmd_simulation_0_db_antenna(3 downto 0),
      probe1(2 downto 0) => dpd_cmd_simulation_0_db_state_value(2 downto 0),
      probe2(0) => dpd_cmd_simulation_0_db_sendcmd,
      resetn => proc_sys_reset_0_peripheral_aresetn(0)
    );
tdd_simulation_1: component orx_test_bd_tdd_simulation_1_0
     port map (
      clk_100M => clk_1(0),
      rst_n => proc_sys_reset_0_peripheral_aresetn(0),
      tx_enable => tdd_simulation_1_tx_enable
    );
util_ds_buf_0: component orx_test_bd_util_ds_buf_0_0
     port map (
      IBUF_DS_N(0) => CLK_IN_D_1_CLK_N(0),
      IBUF_DS_P(0) => CLK_IN_D_1_CLK_P(0),
      IBUF_OUT(0) => clk_1(0)
    );
vt_orx_switch_1: component orx_test_bd_vt_orx_switch_1_0
     port map (
      clk => clk_1(0),
      m_axis_srx_tdata(31 downto 0) => vt_orx_switch_0_m_axis_srx_TDATA(31 downto 0),
      m_axis_srx_tready => vt_orx_switch_0_m_axis_srx_TREADY,
      m_axis_srx_tuser(7 downto 0) => vt_orx_switch_0_m_axis_srx_TUSER(7 downto 0),
      m_axis_srx_tvalid => vt_orx_switch_0_m_axis_srx_TVALID,
      orx1_enable(1 downto 0) => vt_orx_switch_0_orx1_enable(1 downto 0),
      orx1_sel0(1 downto 0) => vt_orx_switch_0_orx1_sel0(1 downto 0),
      orx1_sel1(1 downto 0) => vt_orx_switch_0_orx1_sel1(1 downto 0),
      orx2_enable(1 downto 0) => vt_orx_switch_0_orx2_enable(1 downto 0),
      orx2_sel0(1 downto 0) => vt_orx_switch_0_orx2_sel0(1 downto 0),
      orx2_sel1(1 downto 0) => vt_orx_switch_0_orx2_sel1(1 downto 0),
      rst_n => proc_sys_reset_0_peripheral_aresetn(0),
      s_axis_srx_ctrl_tdata(7 downto 0) => dpd_cmd_simulation_0_m_axis_srx_ctrl_TDATA(7 downto 0),
      s_axis_srx_ctrl_tready => dpd_cmd_simulation_0_m_axis_srx_ctrl_TREADY,
      s_axis_srx_ctrl_tvalid => dpd_cmd_simulation_0_m_axis_srx_ctrl_TVALID,
      srx_tdata(63 downto 0) => xlconcat_0_dout(63 downto 0),
      tx_enable => tdd_simulation_1_tx_enable
    );
xlconcat_0: component orx_test_bd_xlconcat_0_0
     port map (
      In0(31 downto 0) => xlconstant_0_dout(31 downto 0),
      In1(31 downto 0) => ic1_dout(31 downto 0),
      In2(31 downto 0) => ic2_dout(31 downto 0),
      In3(31 downto 0) => ic3_dout(31 downto 0),
      dout(127 downto 0) => xlconcat_0_dout(127 downto 0)
    );
end STRUCTURE;
