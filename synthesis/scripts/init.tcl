set pdk_dir "../../IHP-Open-PDK"

set pdk_cells_lib ${pdk_dir}/ihp-sg13g2/libs.ref/sg13g2_stdcell/lib
set pdk_sram_lib  ${pdk_dir}/ihp-sg13g2/libs.ref/sg13g2_sram/lib
set pdk_io_lib    ${pdk_dir}/ihp-sg13g2/libs.ref/sg13g2_io/lib


set tech_cells [list "$pdk_cells_lib/sg13g2_stdcell_typ_1p20V_25C.lib"]
set tech_macros [glob -directory $pdk_sram_lib *_typ_1p20V_25C.lib]
lappend tech_macros "$pdk_io_lib/sg13g2_io_typ_1p2V_3p3V_25C.lib"


set tech_cell_tiehi {sg13g2_tiehi L_HI}
set tech_cell_tielo {sg13g2_tielo L_LO}


set lib_list [concat [split $tech_cells] [split $tech_macros] ]
set liberty_args_list [lmap lib $lib_list {concat "-liberty" $lib}]
set liberty_args [concat {*}$liberty_args_list]
set tech_cells_args_list [lmap lib $tech_cells {concat "-liberty" $lib}]
set tech_cells_args [concat {*}$tech_cells_args_list]


foreach file $lib_list {
	yosys read_liberty -lib "$file"
}
