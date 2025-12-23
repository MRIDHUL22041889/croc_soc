set top croc_chip

file mkdir reports

# Read libraries
read_liberty ../lib/sg13g2_stdcell_typ_1p20V_25C.lib
read_liberty ../lib/sg13g2_io_typ_1p2V_3p3V_25C.lib

foreach lib [glob ../lib/sram/*.lib] {
    read_liberty $lib
}

# Read design
read_verilog ../netlist/croc_chip_yosys.v
link_design $top

# Constraints
read_sdc ../sdc/time.sdc

# Reports
report_checks -path_group clk_sys -path_delay max > "reports/sta.rpt"

