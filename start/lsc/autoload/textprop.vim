if exists("g:loaded_textprop")
	finish
endif
let g:loaded_textprop = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


function textprop#define_types()
    let props = {}
    " let props['bufnr'] = bufnr('%')
    let props['highlight'] = 'Diagnostic'
    let props['priority'] = 1
    let props['combine'] = v:true
    let props['start_incl'] = v:true
    let props['end_incl'] = v:true
    call s:type_add('Diagnostic', props)
endfunction

function textprop#add(startpos, endpos, severity)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_error(string(a:startpos))
	call log#log_error(string(a:endpos))
    let l:lnum = a:startpos['line'] + 1
    let l:col = a:startpos['character'] + 1
    let l:props = {}
    " let l:props['length']
    let l:props['end_lnum'] = a:endpos['line'] + 1
    let l:props['end_col'] = a:endpos['character'] + 1
    " let l:props['bufnr']
    " let l:props['id']
    let l:props['type'] = 'Diagnostic'
    call prop_add(l:lnum, l:col, l:props)
endfunction

function s:type_add(name, props)
    if empty(prop_type_get(a:name, a:props))
        call prop_type_add(a:name, a:props)
    endif
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
