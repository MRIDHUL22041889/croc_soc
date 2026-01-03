source ./init_tech.tcl

read_verilog /home/marshall/croc/yosys/out/croc_chip_yosys.v
link_design croc_chip

#makeTracks

source floorplan.tcl
source power.tcl


#global placement
set_thread_count 8
global_placement
report_cell_usage
detailed_placement

read_sdc constraints.sdc


#cts


set clock_nets [get_nets -of_objects [get_pins -of_objects "*_reg" -filter "name == CLK"]]
set_wire_rc -clock -layer Metal4
set_wire_rc -signal -layer Metal4
estimate_parasitics -placement
unset_dont_touch $clock_nets
repair_clock_inverters

clock_tree_synthesis -buf_list $ctsBuf -root_buf $ctsBufRoot -obstruction_aware -sink_clustering_enable -balance_levels -repair_clock_nets


repair_design -verbose
repair_timing -setup -skip_pin_swap -verbose
check_placement -verbose
detailed_placement
check_placement -verbose
