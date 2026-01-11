source ./init_tech.tcl

set_thread_count 10
read_verilog /home/marshall/croc/yosys/out/croc_chip_yosys.v
link_design croc_chip


set CROC            i_croc_soc/i_croc
set USER            i_croc_soc/i_user
set IBEX            $CROC/i_core_wrap.i_ibex
set SRAM            $CROC/gen_sram_bank
set JTAG            $CROC/i_dmi_jtag
set SRAM_512x32     gen_512x32xBx1.i_cut

# memory banks
set sram {\[0\].i_sram/}
set bank0_sram0 $SRAM$sram$SRAM_512x32
set sram {\[1\].i_sram/}
set bank1_sram0 $SRAM$sram$SRAM_512x32
set sram {\[2\].i_sram/}
set bank2_sram0 $SRAM$sram$SRAM_512x32

set JTAG_ASYNC_REQ [get_nets $JTAG/i_dmi_cdc.i_cdc_req/*async_*]
set JTAG_ASYNC_RSP [get_nets $JTAG/i_dmi_cdc.i_cdc_resp/*async_*]

read_sdc constraints.sdc

#makeTracks

source floorplan.tcl
source power.tcl


#global placement
set_wire_rc -signal -layer Metal4
set_wire_rc -clock  -layer Metal4
global_placement \
  -routability_driven \
  -enable_routing_congestion \
  -density 0.45 \
  -overflow 0.10 \
  -bin_grid_count 128 \
  -routability_target_rc_metric 1.05 \
  -routability_check_overflow 0.25 \
  -routability_max_density 0.65 \
  -routability_inflation_ratio_coef 2.0 \
  -routability_max_inflation_ratio 1.6 \
  -routability_rc_coefficients {1.0 1.0 0.5 0.25}


estimate_parasitics -placement

set_ideal_network [get_ports clk_i]

repair_design  -verbose
repair_timing -setup -skip_pin_swap -verbose

global_placement \
  -routability_driven \
  -enable_routing_congestion \
  -density 0.45 
report_cell_usage
detailed_placement
optimize_mirroring
estimate_parasitics -placement

set_wire_rc -clock -layer Metal4
set_wire_rc -signal -layer Metal4
estimate_parasitics -placement
repair_design -verbose


#cts


set clock_nets [get_nets -of_objects [get_pins -of_objects "*_reg" -filter "name == CLK"]]
set_wire_rc -clock -layer Metal4
set_wire_rc -signal -layer Metal4
estimate_parasitics -placement
unset_dont_touch $clock_nets
repair_clock_inverters

clock_tree_synthesis -buf_list $ctsBuf -root_buf $ctsBufRoot -obstruction_aware -sink_clustering_enable -balance_levels -repair_clock_nets

set_dont_touch  [get_nets -of_objects [get_pins -of_objects "*_reg" -filter "name == CLK"]]

repair_design -verbose
repair_timing -setup -skip_pin_swap -verbose
#check_placement -verbose
detailed_placement
check_placement -verbose

makeTracks

#routing
make_tracks Metal2 -y_offset 0.24 -x_offset 0.24
set_global_routing_layer_adjustment Metal2 0.6
set_global_routing_layer_adjustment Metal3 1.2
set_global_routing_layer_adjustment Metal4 1.5
set_routing_layers -signal Metal2-TopMetal1
global_route -verbose



estimate_parasitics -global_routing
repair_timing -setup -repair_tns 100

global_route -start_incremental
detailed_placement
global_route -end_incremental
estimate_parasitics -global_routing

estimate_parasitics -placement


#deailed routing
set_thread_count 11




detailed_route  -droute_end_iter 6 \
  -clean_patches \
  -verbose 1

filler_placement {sg13g2_fill_8 sg13g2_fill_4 sg13g2_fill_2 sg13g2_fill_1}
global_connect


write_verilog results/croc.v
write_verilog -include_pwr_gnd results/croc_lvs.v
write_sdc results/croc.sdc
write_db results/croc.odb
write_def results/croc.def


set extrule $pdk_dir/ihp-sg13g2/libs.tech/librelane/IHP_rcx_patterns.rules
define_process_corner -ext_model_index 0 tt
extract_parasitics -ext_model_file $extrule


#Statistical power analysis
