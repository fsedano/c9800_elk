::cisco::eem::event_register_none tag ev_none maxrun 2000

namespace import ::cisco::eem::*
namespace import ::cisco::lib::*


set DEBUG_FLAG         0

# ### Put debug logs to syslog when debug flag is set
proc debug {str} {
    global DEBUG_FLAG
    if {$DEBUG_FLAG == 1} {
        action_syslog msg "$str\n"
		puts "Debug: $str"
    }
}

proc p_error {str} {
    action_syslog msg "ERROR: $str\n"
}

# ### Execute commands (non-interactive) present in the given list
proc execute_command_list {sess cmds} {
    upvar $sess cli_sess
    upvar $cmds cmd_list

    set ret(rc)     0
    set ret(rbuf)   ""

    foreach cmd $cmd_list {
        if {[catch {cli_exec $cli_sess(fd) $cmd} result]} {
            append ret(rbuf) "Command: '$cmd', Result:\n$result\n"
            set ret(rc) -1
            return [array get ret]
        } elseif {[string first "Invalid input detected" $result] != -1 ||
                  [string first "Incomplete command" $result] != -1} {
            append ret(rbuf) "Command: '$cmd' is invalid. Result:\n$result\n"
            set ret(rc) -1
            return [array get ret]
        }
        append ret(rbuf) "Command: '$cmd', Result:\n$result\n"
    }

    return [array get ret]
}

# ### Generate unique file name based on system clock
proc generate_file_name {cli} {
    upvar $cli cli_sess

    set cmd "show clock"
    if {[catch {cli_exec $cli_sess(fd) $cmd} sh_cl_out]} {
        p_error "Error while executing command: '$cmd', Result:\n$sh_cl_out"
        return ""
    }
    debug "Command: '$cmd', Result:\n$sh_cl_out"

    # Split output by CR, Last line is always device hostname trim it
    set split_list [lrange [split $sh_cl_out "\n\r"] 0 end-1]
    foreach ele $split_list {
        set ele [string trim $ele " \r\n"]
        if {[string length $ele] > 0} {
            set clock $ele
            break
        }
    }
    debug "Clock time: $clock"

    set cl_out [join [regexp -inline -all -- {\S+} $clock] "_"]
    regsub -all ":" $cl_out "" cl_out
    set file "wncd_$cl_out.log"

    return $file
}


# ### Start new CLI session and move to enable mode
proc cli_session_start {} {
    debug "Opening CLI TTY1 line"

    if [catch {cli_open} result] {
        p_error "Unable to open a CLI session, Result: $result"
        exit 1
    }
    array set cli_sess $result

    debug "CLI session created - entering enabled mode"

    if [catch {cli_exec $cli_sess(fd) "enable"} result] {
        p_error "Unable to enter enabled mode, Result: $result"
        cli_close $cli_sess(fd) $cli_sess(tty_id)
        exit 1
    }

    return [array get cli_sess]
}


proc stop_cndtn_and_rotate_logs {cli} {
	upvar $cli cli_sess
	set cmd_list {}
	set file [generate_file_name cli_sess]
	lappend cmd_list "show logging process wncd start marker m1 | redirect tftp://9.9.71.130/traces_$file"
    lappend cmd_list "set platform software filter-trace slot c a r wncd marker m1"
	array set ret [execute_command_list cli_sess cmd_list]
}

##### MAIN #####

array set cli_sess [cli_session_start]
set ret [stop_cndtn_and_rotate_logs cli_sess]

