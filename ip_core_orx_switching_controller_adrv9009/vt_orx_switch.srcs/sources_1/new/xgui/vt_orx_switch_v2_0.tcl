# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  ipgui::add_param $IPINST -name "FREQ_MHZ" -widget comboBox
  ipgui::add_param $IPINST -name "NUM_IC"

}

proc update_PARAM_VALUE.FREQ_MHZ { PARAM_VALUE.FREQ_MHZ } {
	# Procedure called to update FREQ_MHZ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FREQ_MHZ { PARAM_VALUE.FREQ_MHZ } {
	# Procedure called to validate FREQ_MHZ
	return true
}

proc update_PARAM_VALUE.NUM_IC { PARAM_VALUE.NUM_IC } {
	# Procedure called to update NUM_IC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_IC { PARAM_VALUE.NUM_IC } {
	# Procedure called to validate NUM_IC
	return true
}


proc update_MODELPARAM_VALUE.NUM_IC { MODELPARAM_VALUE.NUM_IC PARAM_VALUE.NUM_IC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_IC}] ${MODELPARAM_VALUE.NUM_IC}
}

proc update_MODELPARAM_VALUE.FREQ_MHZ { MODELPARAM_VALUE.FREQ_MHZ PARAM_VALUE.FREQ_MHZ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FREQ_MHZ}] ${MODELPARAM_VALUE.FREQ_MHZ}
}

