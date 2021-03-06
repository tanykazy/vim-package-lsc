const s:log_name = 'vim-package-lsc.log'

let s:log_level = {}
let s:log_level.trace = 0
let s:log_level.debug = 1
let s:log_level.error = 2
let s:log_level.none = 3

const log#level_trace = s:log_level.trace
const log#level_debug = s:log_level.debug
const log#level_error = s:log_level.error
const log#level_none = s:log_level.none

let g:log_level = get(g:, 'log_level', s:log_level.none)
let g:log_file = get(g:, 'log_file', expand('<sfile>:p:h:h') . '/' . s:log_name)

function log#start_chlog()
    if g:log_level < s:log_level.none
        call lib#channel#logfile(g:log_file)
    endif
endfunction

function log#stop_chlog()
    call lib#channel#logfile('')
endfunction

function log#init()
    call delete(g:log_file)
endfunction

function log#log_trace(msg)
    if !(g:log_level > s:log_level.trace)
        call s:log('[TRACE]', a:msg)
    endif
endfunction

function log#log_debug(msg)
    if !(g:log_level > s:log_level.debug)
        call s:log('[DEBUG]', a:msg)
    endif
endfunction

function log#log_error(msg)
    if !(g:log_level > s:log_level.error)
        call s:log('[ERROR]', a:msg)
    endif
endfunction

function s:log(level, msg)
    call writefile([a:level . a:msg], g:log_file, 'as')
endfunction
