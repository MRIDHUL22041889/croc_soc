# Clock
create_clock -name core_sys -period 10.0 [get_ports clk_i]

# Ideal clock for now (pre-layout)
set_clock_uncertainty 0.2 [get_clocks core_clk]

# Default input/output delays (safe placeholders)
set_input_delay  2.0 -clock core_clk [all_inputs]
set_output_delay 2.0 -clock core_clk [all_outputs]

# Exclude clock and reset from IO timing
#set_false_path -from [get_ports reset*]
#set_false_path -to   [get_ports reset*]

