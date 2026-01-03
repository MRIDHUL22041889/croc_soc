# std cells
add_global_connection -net {VDD} -inst_pattern {.*} -pin_pattern {VDD} -power
add_global_connection -net {VSS} -inst_pattern {.*} -pin_pattern {VSS} -ground

# pads
add_global_connection -net {VDD} -inst_pattern {.*} -pin_pattern {vdd} -power
add_global_connection -net {VSS} -inst_pattern {.*} -pin_pattern {vss} -ground

# fix for bondpad/port naming
add_global_connection -net {VDDIO} -inst_pattern {.*} -pin_pattern {.*vdd_RING} -power
add_global_connection -net {VSSIO} -inst_pattern {.*} -pin_pattern {.*vss_RING} -ground

# rams
add_global_connection -net {VDD} -inst_pattern {.*} -pin_pattern {VDDARRAY} -power
add_global_connection -net {VDD} -inst_pattern {.*} -pin_pattern {VDDARRAY!} -power
add_global_connection -net {VDD} -inst_pattern {.*} -pin_pattern {VDD!} -power
add_global_connection -net {VSS} -inst_pattern {.*} -pin_pattern {VSS!} -ground

# pads
add_global_connection -net {VDDIO} -inst_pattern {.*} -pin_pattern {iovdd} -power
add_global_connection -net {VSSIO} -inst_pattern {.*} -pin_pattern {iovss} -ground

# fix for bondpad/port naming
add_global_connection -net {VDDIO} -inst_pattern {.*} -pin_pattern {.*iovdd_RING} -power
add_global_connection -net {VSSIO} -inst_pattern {.*} -pin_pattern {.*iovss_RING} -ground

# connection
global_connect

# voltage domains
set_voltage_domain -name {CORE} -power {VDD} -ground {VSS}
# standard cell grid and rings
define_pdn_grid -name {core_grid} -voltage_domains {CORE}

set macro RM_IHPSG13_1P_256x64_c2_bm_bist
set sram [[ord::get_db] findMaster $macro]
set sramHeight [ord::dbu_to_microns [$sram getHeight]]
set stripe_dist [expr $sramHeight - 50]

#defined pnd ring for macro
define_pdn_grid -macro -cells $macro -name sram_256x64_grid -orient "R0 R180 MY MX" \
        -grid_over_boundary -voltage_domains {CORE} \
        -halo {1 1}

#create power ring
add_pdn_ring -grid {core_grid}  -layer {TopMetal1 TopMetal2} -widths "10 10" -spacings "6 6" -pad_offsets  "6 6" -add_connect -connect_to_pads  -connect_to_pad_layers TopMetal2




# Macro Power Rings -> M3 and M2
## Spacing must be larger than pitch of M2/M3
set mprSpacing 0.6
## Width
set mprWidth 2
## Offset from Macro to power ring
set mprOffsetX 2.4
set mprOffsetY 0.6
set mpgWidth 6
set mpgSpacing 4
set mpgOffset 20;

#create power ring macro
    add_pdn_ring -grid  sram_256x64_grid -layer {Metal3 Metal4} -widths "$mprWidth $mprWidth" -spacings "$mprSpacing $mprSpacing" -core_offsets "$mprOffsetX $mprOffsetY"  -add_connect

#create power stripes
add_pdn_stripe -grid {core_grid} -layer {Metal1} -width {0.44} -offset {0} -followpins -extend_to_core_ring

#create power stripes macro 
set sramHeight  [ord::dbu_to_microns [$sram getHeight]]
set stripe_dist [expr $sramHeight - 2*$mpgOffset - $mpgWidth - $mpgSpacing]
add_pdn_stripe -grid  sram_256x64_grid  -layer {TopMetal1} -width $mpgWidth -spacing $mpgSpacing -pitch $stripe_dist -offset $mpgOffset -extend_to_core_ring -starts_with POWER -snap_to_grid

add_pdn_connect -grid  sram_256x64_grid -layers {Metal3 Metal1}
add_pdn_connect -grid  sram_256x64_grid -layers {TopMetal1 Metal3}
add_pdn_connect -grid  sram_256x64_grid -layers {TopMetal1 Metal4}
add_pdn_connect -grid  sram_256x64_grid -layers {TopMetal2 TopMetal1}


#create connections from the ring to stripes
add_pdn_connect -grid {core_grid} -layers {TopMetal2 Metal1}
add_pdn_connect -grid {core_grid} -layers {TopMetal2 Metal2}
add_pdn_connect -grid {core_grid} -layers {TopMetal2 Metal4}
add_pdn_connect -grid {core_grid} -layers {Metal3 Metal2}




#genration
pdngen
