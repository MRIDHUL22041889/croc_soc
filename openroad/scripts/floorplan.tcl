proc placeInstance { name x y orient } {
  puts "placing $name at {$x $y} $orient"

  set block [ord::get_db_block]
  set inst [$block findInst $name]
  if {$inst == "NULL"} {
    error "Cannot find instance $name"
  }

  $inst setLocationOrient $orient
  $inst setLocation [ord::microns_to_dbu $x] [ord::microns_to_dbu $y]
  $inst setPlacementStatus FIRM
}

# Add placement blockage over two macros (ie block channels and so on)
proc add_macro_blockage {negative_padding name1 name2} {
  set block [ord::get_db_block]
  set inst1 [odb::dbBlock_findInst $block $name1]
  set inst2 [odb::dbBlock_findInst $block $name2]
  set bb1 [odb::dbInst_getBBox $inst1]
  set bb2 [odb::dbInst_getBBox $inst2]
  # Find min max of X and Y
  set minx [expr min( [odb::dbBox_xMin $bb1], [odb::dbBox_xMin $bb2]) + [ord::microns_to_dbu $negative_padding]]
  set miny [expr min( [odb::dbBox_yMin $bb1], [odb::dbBox_yMin $bb2]) + [ord::microns_to_dbu $negative_padding]]
  set maxx [expr max( [odb::dbBox_xMax $bb1], [odb::dbBox_xMax $bb2]) - [ord::microns_to_dbu $negative_padding]]
  set maxy [expr max( [odb::dbBox_yMax $bb1], [odb::dbBox_yMax $bb2]) - [ord::microns_to_dbu $negative_padding]]

  set blockage [odb::dbBlockage_create [ord::get_db_block] $minx $miny $maxx $maxy]
  return $blockage
}


#Actual Flow startproc placeInstance { name x y orient } {

set chipH    1930; # OR die height (top to bottom)
set chipW    1930; # OR die width (left to right)
set padD      180; # pad depth (edge to core)
set padW       80; # pad width (beachfront)
set padBond    70; # bonding pad size
set powerRing  80; # reserved space for power ring


set coreMargin [expr {$padD + $padBond + $powerRing}];

initialize_floorplan -die_area "0 0 $chipW $chipH" \
                     -core_area "$coreMargin $coreMargin [expr $chipW-$coreMargin] [expr $chipH-$coreMargin]" \
                     -site "CoreSite"



#initialize_floorplan -utilization 70 -aspect_ratio 1.0 -core_space 0.0 -site "CoreSite"
#makeTracks
source pinplacement.tcl

set RamMaster256x64   [[ord::get_db] findMaster "RM_IHPSG13_1P_256x64_c2_bm_bist"]
set RamSize256x64_W   [ord::dbu_to_microns [$RamMaster256x64 getWidth]]
set RamSize256x64_H   [ord::dbu_to_microns [$RamMaster256x64 getHeight]]


set coreArea      [ord::get_core_area]
set core_leftX    [lindex $coreArea 0]
set core_bottomY  [lindex $coreArea 1]
set core_rightX   [lindex $coreArea 2]
set core_topY     [lindex $coreArea 3]



makeTracks

set siteHeight        [ord::dbu_to_microns [[dpl::get_row_site] getHeight]]




set floorPaddingX      20.0
set floorPaddingY      20.0
set floor_leftX       [expr $core_leftX + $floorPaddingX]
set floor_bottomY     [expr $core_bottomY + $floorPaddingY]
set floor_rightX      [expr $core_rightX - $floorPaddingX]
set floor_topY        [expr $core_topY - $floorPaddingY]
set floor_midpointX   [expr $floor_leftX + ($floor_rightX - $floor_leftX)/2]
set floor_midpointY   [expr $floor_bottomY + ($floor_topY - $floor_bottomY)/2]

utl::report "Place Macros"

# Bank0
set X [expr $floor_midpointX - $RamSize256x64_W/2]
set Y [expr $floor_topY - $RamSize256x64_H]
placeInstance {i_croc_soc/i_croc/gen_sram_bank\[0\].i_sram/gen_512x32xBx1.i_cut}  $X $Y R0

# Bank1
set X [expr $X]
set Y [expr $Y - $RamSize256x64_H - 15]
placeInstance {i_croc_soc/i_croc/gen_sram_bank\[1\].i_sram/gen_512x32xBx1.i_cut} $X $Y R0


cut_rows -halo_width_x 10 -halo_width_y 10
