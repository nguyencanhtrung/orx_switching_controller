
################################################################
# This is a generated script based on design: orx_test_bd
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2017.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source orx_test_bd_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# dpd_cmd_simulation, tdd_simulation

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xczu9eg-ffvb1156-2-e
   set_property BOARD_PART xilinx.com:zcu102:part0:3.1 [current_project]
}


# CHANGE DESIGN NAME HERE
set design_name orx_test_bd

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 clk ]
  set m_axis_srx [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_srx ]

  # Create ports
  set ext_reset_in [ create_bd_port -dir I -type rst ext_reset_in ]
  set_property -dict [ list \
CONFIG.POLARITY {ACTIVE_LOW} \
 ] $ext_reset_in
  set orx1_enable [ create_bd_port -dir O -from 1 -to 0 orx1_enable ]
  set orx1_sel0 [ create_bd_port -dir O -from 1 -to 0 orx1_sel0 ]
  set orx1_sel1 [ create_bd_port -dir O -from 1 -to 0 orx1_sel1 ]
  set orx2_enable [ create_bd_port -dir O -from 1 -to 0 orx2_enable ]
  set orx2_sel0 [ create_bd_port -dir O -from 1 -to 0 orx2_sel0 ]
  set orx2_sel1 [ create_bd_port -dir O -from 1 -to 0 orx2_sel1 ]

  # Create instance: dpd_cmd_simulation_0, and set properties
  set block_name dpd_cmd_simulation
  set block_cell_name dpd_cmd_simulation_0
  if { [catch {set dpd_cmd_simulation_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $dpd_cmd_simulation_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
CONFIG.NUM_ANTENNA {4} \
CONFIG.SWITCH_PERIOD {1000} \
 ] $dpd_cmd_simulation_0

  # Create instance: ic0, and set properties
  set ic0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 ic0 ]
  set_property -dict [ list \
CONFIG.CONST_VAL {0} \
CONFIG.CONST_WIDTH {32} \
 ] $ic0

  # Create instance: ic1, and set properties
  set ic1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 ic1 ]
  set_property -dict [ list \
CONFIG.CONST_VAL {1} \
CONFIG.CONST_WIDTH {32} \
 ] $ic1

  # Create instance: ic2, and set properties
  set ic2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 ic2 ]
  set_property -dict [ list \
CONFIG.CONST_VAL {2} \
CONFIG.CONST_WIDTH {32} \
 ] $ic2

  # Create instance: ic3, and set properties
  set ic3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 ic3 ]
  set_property -dict [ list \
CONFIG.CONST_VAL {3} \
CONFIG.CONST_WIDTH {32} \
 ] $ic3

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]
  set_property -dict [ list \
CONFIG.C_AUX_RESET_HIGH {0} \
 ] $proc_sys_reset_0

  # Create instance: system_ila_0, and set properties
  set system_ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.0 system_ila_0 ]
  set_property -dict [ list \
CONFIG.C_BRAM_CNT {60} \
CONFIG.C_DATA_DEPTH {32768} \
CONFIG.C_MON_TYPE {MIX} \
CONFIG.C_NUM_MONITOR_SLOTS {2} \
CONFIG.C_NUM_OF_PROBES {6} \
CONFIG.C_PROBE0_WIDTH {2} \
CONFIG.C_PROBE1_WIDTH {2} \
CONFIG.C_PROBE2_WIDTH {2} \
CONFIG.C_PROBE3_WIDTH {2} \
CONFIG.C_PROBE4_WIDTH {2} \
CONFIG.C_PROBE5_WIDTH {2} \
CONFIG.C_PROBE_WIDTH_PROPAGATION {MANUAL} \
CONFIG.C_SLOT {1} \
CONFIG.C_SLOT_0_AXIS_TDATA_WIDTH {8} \
CONFIG.C_SLOT_0_AXIS_TDEST_WIDTH {0} \
CONFIG.C_SLOT_0_AXIS_TID_WIDTH {0} \
CONFIG.C_SLOT_0_AXIS_TUSER_WIDTH {0} \
CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
CONFIG.C_SLOT_1_AXIS_TDATA_WIDTH {32} \
CONFIG.C_SLOT_1_AXIS_TDEST_WIDTH {0} \
CONFIG.C_SLOT_1_AXIS_TID_WIDTH {0} \
CONFIG.C_SLOT_1_AXIS_TUSER_WIDTH {8} \
CONFIG.C_SLOT_1_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
 ] $system_ila_0

  # Create instance: system_ila_1, and set properties
  set system_ila_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.0 system_ila_1 ]
  set_property -dict [ list \
CONFIG.C_BRAM_CNT {16} \
CONFIG.C_DATA_DEPTH {65536} \
CONFIG.C_MON_TYPE {MIX} \
CONFIG.C_NUM_OF_PROBES {3} \
CONFIG.C_PROBE0_WIDTH {4} \
CONFIG.C_PROBE1_WIDTH {3} \
CONFIG.C_PROBE2_WIDTH {1} \
CONFIG.C_PROBE_WIDTH_PROPAGATION {MANUAL} \
CONFIG.C_SLOT_0_AXIS_TDATA_WIDTH {8} \
CONFIG.C_SLOT_0_AXIS_TDEST_WIDTH {0} \
CONFIG.C_SLOT_0_AXIS_TID_WIDTH {0} \
CONFIG.C_SLOT_0_AXIS_TUSER_WIDTH {0} \
CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
 ] $system_ila_1

  # Create instance: tdd_simulation_1, and set properties
  set block_name tdd_simulation
  set block_cell_name tdd_simulation_1
  if { [catch {set tdd_simulation_1 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $tdd_simulation_1 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
CONFIG.NUM_DL_SLOT {10} \
CONFIG.NUM_UL_SLOT {10} \
 ] $tdd_simulation_1

  # Create instance: util_ds_buf_0, and set properties
  set util_ds_buf_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_0 ]
  set_property -dict [ list \
CONFIG.DIFF_CLK_IN_BOARD_INTERFACE {Custom} \
 ] $util_ds_buf_0

  # Create instance: vt_orx_switch_1, and set properties
  set vt_orx_switch_1 [ create_bd_cell -type ip -vlnv vttek.com.vn:user:vt_orx_switch:2.0 vt_orx_switch_1 ]
  set_property -dict [ list \
CONFIG.NUM_IC {2} \
 ] $vt_orx_switch_1

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list \
CONFIG.IN0_WIDTH {32} \
CONFIG.IN1_WIDTH {32} \
CONFIG.IN2_WIDTH {32} \
CONFIG.IN3_WIDTH {32} \
CONFIG.NUM_PORTS {4} \
 ] $xlconcat_0

  # Create interface connections
  connect_bd_intf_net -intf_net CLK_IN_D_1 [get_bd_intf_ports clk] [get_bd_intf_pins util_ds_buf_0/CLK_IN_D]
  connect_bd_intf_net -intf_net dpd_cmd_simulation_0_m_axis_srx_ctrl [get_bd_intf_pins dpd_cmd_simulation_0/m_axis_srx_ctrl] [get_bd_intf_pins vt_orx_switch_1/s_axis_srx_ctrl]
connect_bd_intf_net -intf_net [get_bd_intf_nets dpd_cmd_simulation_0_m_axis_srx_ctrl] [get_bd_intf_pins dpd_cmd_simulation_0/m_axis_srx_ctrl] [get_bd_intf_pins system_ila_1/SLOT_0_AXIS]
connect_bd_intf_net -intf_net [get_bd_intf_nets dpd_cmd_simulation_0_m_axis_srx_ctrl] [get_bd_intf_pins dpd_cmd_simulation_0/m_axis_srx_ctrl] [get_bd_intf_pins system_ila_0/SLOT_0_AXIS]
  connect_bd_intf_net -intf_net vt_orx_switch_0_m_axis_srx [get_bd_intf_ports m_axis_srx] [get_bd_intf_pins vt_orx_switch_1/m_axis_srx]
connect_bd_intf_net -intf_net [get_bd_intf_nets vt_orx_switch_0_m_axis_srx] [get_bd_intf_ports m_axis_srx] [get_bd_intf_pins system_ila_0/SLOT_1_AXIS]

  # Create port connections
  connect_bd_net -net clk_1 [get_bd_pins dpd_cmd_simulation_0/clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins system_ila_0/clk] [get_bd_pins system_ila_1/clk] [get_bd_pins tdd_simulation_1/clk_100M] [get_bd_pins util_ds_buf_0/IBUF_OUT] [get_bd_pins vt_orx_switch_1/clk]
  connect_bd_net -net dpd_cmd_simulation_0_db_antenna [get_bd_pins dpd_cmd_simulation_0/db_antenna] [get_bd_pins system_ila_1/probe0]
  connect_bd_net -net dpd_cmd_simulation_0_db_sendcmd [get_bd_pins dpd_cmd_simulation_0/db_sendcmd] [get_bd_pins system_ila_1/probe2]
  connect_bd_net -net dpd_cmd_simulation_0_db_state_value [get_bd_pins dpd_cmd_simulation_0/db_state_value] [get_bd_pins system_ila_1/probe1]
  connect_bd_net -net ext_reset_in_1 [get_bd_ports ext_reset_in] [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net ic1_dout [get_bd_pins ic1/dout] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net ic2_dout [get_bd_pins ic2/dout] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net ic3_dout [get_bd_pins ic3/dout] [get_bd_pins xlconcat_0/In3]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins dpd_cmd_simulation_0/rst_n] [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins system_ila_0/resetn] [get_bd_pins system_ila_1/resetn] [get_bd_pins tdd_simulation_1/rst_n] [get_bd_pins vt_orx_switch_1/rst_n]
  connect_bd_net -net tdd_simulation_1_tx_enable [get_bd_pins tdd_simulation_1/tx_enable] [get_bd_pins vt_orx_switch_1/tx_enable]
  connect_bd_net -net vt_orx_switch_0_orx1_enable [get_bd_ports orx1_enable] [get_bd_pins system_ila_0/probe2] [get_bd_pins vt_orx_switch_1/orx1_enable]
  connect_bd_net -net vt_orx_switch_0_orx1_sel0 [get_bd_ports orx1_sel0] [get_bd_pins system_ila_0/probe0] [get_bd_pins vt_orx_switch_1/orx1_sel0]
  connect_bd_net -net vt_orx_switch_0_orx1_sel1 [get_bd_ports orx1_sel1] [get_bd_pins system_ila_0/probe1] [get_bd_pins vt_orx_switch_1/orx1_sel1]
  connect_bd_net -net vt_orx_switch_0_orx2_enable [get_bd_ports orx2_enable] [get_bd_pins system_ila_0/probe5] [get_bd_pins vt_orx_switch_1/orx2_enable]
  connect_bd_net -net vt_orx_switch_0_orx2_sel0 [get_bd_ports orx2_sel0] [get_bd_pins system_ila_0/probe3] [get_bd_pins vt_orx_switch_1/orx2_sel0]
  connect_bd_net -net vt_orx_switch_0_orx2_sel1 [get_bd_ports orx2_sel1] [get_bd_pins system_ila_0/probe4] [get_bd_pins vt_orx_switch_1/orx2_sel1]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins vt_orx_switch_1/srx_tdata] [get_bd_pins xlconcat_0/dout]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins ic0/dout] [get_bd_pins xlconcat_0/In0]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


