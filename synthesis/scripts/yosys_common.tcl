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

