if exists("g:loaded_log")
	finish
endif
let g:loaded_log = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


let log#level_trace = 0
let log#level_debug = 1
let log#level_error = 2
let log#level_none = 3


let log#log_level = log#level_trace

function log#trace_log(src, msg)
    if !(log#log_level > log#level_trace)
        call s:log('[TRACE]' . a:msg, a:src)
    endif
endfunction

function log#debug_log(src, msg)
    if !(log#log_level > log#level_debug)
        call s:log('[DEBUG]' . a:msg, a:src)
    endif
endfunction

function log#error_log(src, msg)
    if !(log#log_level > log#level_error)
        call s:log('[ERROR]' . a:msg, a:src)
    endif
endfunction

function s:log(msg, handle)
    call ch_log(a:msg, a:handle)
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
