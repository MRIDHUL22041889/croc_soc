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

# Sanity check
if {[sizeof_collection [get_ports *]] == 0} {
    puts "FATAL: No ports found"
    exit 1
}

# Constraints
read_sdc ../sdc/time.sdc

# Reports
report_clocks > reports/clocks.rpt
report_checks -path_delay max -fields {slew cap input} -digits 3 > reports/setup.rpt
report_checks -path_delay min -fields {slew cap input} -digits 3 > reports/hold.rpt
report_clock_skew > reports/clock_skew.rpt
report_constraint -all_violators > reports/constraints.rpt

