#Read_Design
source yosys_common.tcl
source init.tcl

yosys read_slang --top croc_chip -F ../../croc.flist \
    --compat-mode --keep-hierarchy \
    --allow-use-before-declare --ignore-unknown-modules


# Preserve hierarchy and blackboxes
yosys setattr -set keep_hierarchy 1 "t:croc_soc$*"
yosys setattr -set keep_hierarchy 1 "t:croc_domain$*"
yosys setattr -set keep_hierarchy 1 "t:user_domain$*"
yosys setattr -set keep_hierarchy 1 "t:core_wrap$*"
yosys setattr -set keep_hierarchy 1 "t:cve2_register_file_ff$*"
yosys setattr -set keep_hierarchy 1 "t:cve2_cs_registers$*"
yosys setattr -set keep_hierarchy 1 "t:dmi_jtag$*"
yosys setattr -set keep_hierarchy 1 "t:dm_top$*"
yosys setattr -set keep_hierarchy 1 "t:gpio$*"
yosys setattr -set keep_hierarchy 1 "t:clint$*"
yosys setattr -set keep_hierarchy 1 "t:obi_timer$*"
yosys setattr -set keep_hierarchy 1 "t:reg_uart_wrap$*"
yosys setattr -set keep_hierarchy 1 "t:soc_ctrl_regs$*"
yosys setattr -set keep_hierarchy 1 "t:tc_clk*$*"
yosys setattr -set keep_hierarchy 1 "t:tc_sram_impl$*"
yosys setattr -set keep_hierarchy 1 "t:cdc_reset*$*"
yosys setattr -set keep_hierarchy 1 "t:cdc*phase_*$*"
yosys setattr -set keep_hierarchy 1 "t:cdc*_src*$*"
yosys setattr -set keep_hierarchy 1 "t:cdc*_dst*$*"
yosys setattr -set keep_hierarchy 1 "t:sync$*"

yosys blackbox "t:tc_sram_blackbox$*"
yosys attrmap -rename dont_touch keep
yosys attrmap -tocase keep -imap keep="true" keep=1
yosys attrmvcp -copy -attr keep

# Elaboration
yosys hierarchy -top $top_design
yosys check
yosys proc

#Coarse synthesis
yosys opt_expr
yosys opt -noff
yosys fsm
yosys memory -nomap
yosys memory_map

yosys wreduce
yosys peepopt
yosys opt_clean
yosys booth
yosys share
yosys opt -full
yosys clean -purge

yosys tee -q -o "${rep_dir}/${top_design}_generic.rpt" stat -tech cmos
yosys clean -purge
yosys opt_dff -sat -nodffe -nosdff


yosys techmap
yosys opt -fast
yosys clean -purge

yosys dfflibmap {*}$tech_cells_args

#ABC
set period_ps 10000
yosys abc {*}$tech_cells_args -D $period_ps
yosys dfflibmap {*}$tech_cells_args
yosys clean -purge

#Post-mapping cleanup

yosys splitnets -format __v
yosys rename -wire -suffix _reg t:*DFF*
yosys select -write ${rep_dir}/${top_design}_registers.rpt t:*DFF*
yosys autoname t:*DFF* %n
yosys clean -purge

yosys tee -q -o ${rep_dir}/${top_design}_instances.rpt  select -list "t:RM_IHPSG13_*"
yosys tee -q -a ${rep_dir}/${top_design}_instances.rpt  select -list "t:tc_clk*$*"
yosys flatten
yosys clean -purge

# -----------------------------------------------------------------------------
# prep for openROAD
yosys splitnets -ports -format __v
yosys setundef -zero
yosys  clean -purge
# map constants to tie cells
yosys hilomap -singleton -hicell {*}$tech_cell_tiehi -locell {*}$tech_cell_tielo

# final reports
yosys  tee -q -o "${rep_dir}/${top_design}_synth.rpt" check
yosys  tee -q -o "${rep_dir}/${top_design}_area.rpt" stat -top $top_design {*}$liberty_args
yosys  tee -q -o "${rep_dir}/${top_design}_area_logic.rpt" stat -top $top_design {*}$tech_cells_args

# final netlist
yosys  write_verilog -noattr -noexpr -nohex -nodec ${out_dir}/${top_design}_yosys.v


