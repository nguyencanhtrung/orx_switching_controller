#set_property  -dict {PACKAGE_PIN  G9        IOSTANDARD LVDS} [get_ports clk_clk_n]               ;
#set_property  -dict {PACKAGE_PIN  H9        IOSTANDARD LVDS} [get_ports clk_clk_p]               ;
#set_property  -dict {PACKAGE_PIN  AB17      IOSTANDARD LVCMOS25} [get_ports ext_reset_in]       ;

set_property  -dict {PACKAGE_PIN  AL7        IOSTANDARD DIFF_SSTL12} [get_ports clk_clk_n[0]]        ;
set_property  -dict {PACKAGE_PIN  AL8        IOSTANDARD DIFF_SSTL12} [get_ports clk_clk_p[0]]        ;
set_property  -dict {PACKAGE_PIN  AN14       IOSTANDARD LVCMOS25}    [get_ports ext_reset_in]     ;




#set_property  -dict {PACKAGE_PIN  Y21       IOSTANDARD LVCMOS25} [get_ports orx1_enable]        ; # LEFT
#set_property  -dict {PACKAGE_PIN  AH1   IOSTANDARD LVDS} [get_ports orx1_sel0]              ;
#set_property  -dict {PACKAGE_PIN  AH1   IOSTANDARD LVDS} [get_ports orx1_sel1]              ;
#set_property  -dict {PACKAGE_PIN  W21       IOSTANDARD LVCMOS25} [get_ports orx2_enable]        ; # RIGHT
#set_property  -dict {PACKAGE_PIN  AH1   IOSTANDARD LVDS} [get_ports orx2_sel0]              ;
#set_property  -dict {PACKAGE_PIN  AH1   IOSTANDARD LVDS} [get_ports orx2_sel1]              ;
#################################################################
set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]                       ;