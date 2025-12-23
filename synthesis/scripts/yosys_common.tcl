set variables {
    sv_flist    { SV_FLIST    "../croc.flist" }
    top_design  { TOP_DESIGN  "croc_chip"     }
    out_dir     { OUT         out             }
    tmp_dir     { TMP         tmp             }
    rep_dir     { REPORTS     reports         }
}
foreach {var spec} $variables {
    lassign $spec env_name default
    if {[info exists ::env($env_name)] && $::env($env_name) ne ""} {
        set $var $::env($env_name)
    } else {
        set $var $default
    }
}
proc processAbcScript {abc_script} {
    global tmp_dir
    file mkdir $tmp_dir

    set src_dir [file join [file dirname [info script]] ../src]
    set abc_out_path [file join $tmp_dir [file tail $abc_script]]

    set f [open $abc_script r]
    set raw [read -nonewline $f]
    close $f

    set abc_script_recaig [string map -nocase \
        [list "{REC_AIG}" "$src_dir/lazy_man_synth_library.aig"] $raw]

    set abc_out [open $abc_out_path w]
    puts -nonewline $abc_out $abc_script_recaig
    close $abc_out

    return $abc_out_path
}


