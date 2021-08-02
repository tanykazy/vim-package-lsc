if exists("g:loaded_log")
	finish
endif
let g:loaded_log = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


let s:log_level_trace = 0
let s:log_level_debug = 1
let s:log_level_error = 2
let s:log_level_none = 3

let log#level_trace = s:log_level_trace
let log#level_debug = s:log_level_debug
let log#level_error = s:log_level_error
let log#level_none = s:log_level_none

let g:log_level = get(g:, 'log_level', s:log_level_none)
let g:log_file = get(g:, 'log_file', expand('<sfile>:p:h:h') . '/lsc.log')

function log#start_log()
    if g:log_level < s:log_level_none
        call ch_logfile(g:log_file, 'w')
    endif
endfunction

function log#stop_log()
    call ch_logfile('')
endfunction

function log#log_trace(msg)
    if !(g:log_level > s:log_level_trace)
        call s:log('[TRACE]' . a:msg)
    endif
endfunction

function log#log_debug(msg)
    if !(g:log_level > s:log_level_debug)
        call s:log('[DEBUG]' . a:msg)
    endif
endfunction

function log#log_error(msg)
    if !(g:log_level > s:log_level_error)
        call s:log('[ERROR]' . a:msg)
    endif
endfunction

function s:log(msg)
    call ch_log(a:msg)
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
