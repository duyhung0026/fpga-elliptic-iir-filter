set_property PACKAGE_PIN N18 [get_ports clk]
    set_property IOSTANDARD LVCMOS33 [get_ports clk]
    create_clock -name sys_clk_pin -period 20.000 -waveform {0 10} [get_ports clk]

create_generated_clock -name ADCclk \
    -source [get_ports clk] \
    -divide_by 64 \
    [get_pins adc0/counter/out_reg[5]/Q]

set_false_path -from [get_clocks ADCclk] -to [get_clocks sys_clk_pin]

set_property PACKAGE_PIN R18 [get_ports conv]
set_property IOSTANDARD LVCMOS33 [get_ports conv]

set_property PACKAGE_PIN R19 [get_ports ADC_in]
set_property IOSTANDARD LVCMOS33 [get_ports ADC_in]

set_property PACKAGE_PIN P19 [get_ports ADC_out]
set_property IOSTANDARD LVCMOS33 [get_ports ADC_out]

set_property PACKAGE_PIN T20 [get_ports ADCclk]
set_property IOSTANDARD LVCMOS33 [get_ports ADCclk]

set_property PACKAGE_PIN U20 [get_ports Tx]
set_property IOSTANDARD LVCMOS33 [get_ports Tx]
