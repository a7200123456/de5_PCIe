create_clock -period 20 [get_ports clk]
create_clock -period 40 -name clk_25
derive_pll_clocks -create_base_clocks
derive_clock_uncertainty
set_false_path -from [get_registers *sv_xcvr_pipe_native*] -to [get_registers *altpcie_rs_serdes|*]
create_clock -period "125 MHz" -name {reconfig_xcvr_clk} {*reconfig_xcvr_clk*}