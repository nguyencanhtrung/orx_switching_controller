# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "NUM_ANTENNA" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SWITCH_PERIOD" -parent ${Page_0}


}

proc update_PARAM_VALUE.NUM_ANTENNA { PARAM_VALUE.NUM_ANTENNA } {
	# Procedure called to update NUM_ANTENNA when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_ANTENNA { PARAM_VALUE.NUM_ANTENNA } {
	# Procedure called to validate NUM_ANTENNA
	return true
}

proc update_PARAM_VALUE.SWITCH_PERIOD { PARAM_VALUE.SWITCH_PERIOD } {
	# Procedure called to update SWITCH_PERIOD when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SWITCH_PERIOD { PARAM_VALUE.SWITCH_PERIOD } {
	# Procedure called to validate SWITCH_PERIOD
	return true
}


proc update_MODELPARAM_VALUE.SWITCH_PERIOD { MODELPARAM_VALUE.SWITCH_PERIOD PARAM_VALUE.SWITCH_PERIOD } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SWITCH_PERIOD}] ${MODELPARAM_VALUE.SWITCH_PERIOD}
}

proc update_MODELPARAM_VALUE.NUM_ANTENNA { MODELPARAM_VALUE.NUM_ANTENNA PARAM_VALUE.NUM_ANTENNA } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_ANTENNA}] ${MODELPARAM_VALUE.NUM_ANTENNA}
}

