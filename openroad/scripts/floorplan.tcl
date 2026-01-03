

set chipH 1760
set chipW 1760

set padring 180
set coreMargin [expr $padring+35];

initialize_floorplan -die_area "0 0 $chipW $chipH" -core_area "$coreMargin $coreMargin [expr $chipW-$coreMargin] [expr $chipH-$coreMargin]" -site "CoreSite"




#initialize_floorplan -utilization 70 -aspect_ratio 1.0 -core_space 0.0 -site "CoreSite"
makeTracks
source pinplacement.tcl

rtl_macro_placer \
  -max_num_macro 2 \
  -coarsening_ratio 8.0 \
  -large_net_threshold 50 \
  -halo_width 5 \
  -halo_height 5 \
  -wirelength_weight 1.0 \
  -boundary_weight 0.3 \
  -report_directory reports/macro_placer \
  -write_macro_placement macros.pl

