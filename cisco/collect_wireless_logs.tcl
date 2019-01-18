::cisco::eem::event_register_none tag ev_none maxrun 2000

namespace import ::cisco::eem::*
namespace import ::cisco::lib::*


set DEBUG_FLAG         1

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
    set now [clock seconds]

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


proc run_cmd {cli cmd_list} {
	upvar $cli cli_sess
	array set ret [execute_command_list cli_sess cmd_list]
}

proc get_trace_timestamp {} {
     set now [clock seconds]
     set lastrun [get_lastrun]

     set x [clock format $now -format "%Y/%m/%d %H:%M:%S.000"]
     set y [clock format $lastrun -format "%Y/%m/%d %H:%M:%S.000"]
    return "start timestamp \"$y\" end timestamp \"$x\""
}

proc set_lastrun {} {
	set fd [open "a.txt" w]
        set now [clock seconds]
        puts $fd $now
        close $fd
}

proc get_lastrun {} {
    if [catch {set fd [open "a.txt" r]} errmsg] {
	set lastrun 1 
    } else {
        set lastrun [read $fd]
        close $fd
    }
    return $lastrun
}

##### MAIN #####
array set cli_sess [cli_session_start]

## Get latest timestamp
set timestamp_str [get_trace_timestamp]

set cmds {}
set filename [clock seconds]
lappend cmds "show logging profile wireless $timestamp_str | redirect tftp://9.9.71.130/traces_$filename.log"

set ret [run_cmd cli_sess $cmds]
set_lastrun