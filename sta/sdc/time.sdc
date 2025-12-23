# Clock definition
create_clock -name clk_sys -period 10.0 [get_ports clk_i]

# Ideal clock uncertainty (pre-layout)
set_clock_uncertainty 0.2 [get_clocks clk_sys]

# Default input/output delays (relative to clk_sys)
set_input_delay  2.0 -clock clk_sys [all_inputs]
set_output_delay 2.0 -clock clk_sys [all_outputs]

