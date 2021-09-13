let s:has_textprop = has('textprop')

let s:error= {}
let s:error['highlight'] = 'ErrorMsg'
let s:error['priority'] = 4
let s:error['combine'] = v:true
let s:error['start_incl'] = v:true
let s:error['end_incl'] = v:true

let s:warning = {}
let s:warning['highlight'] = 'WarningMsg'
let s:warning['priority'] = 3
let s:warning['combine'] = v:true
let s:warning['start_incl'] = v:true
let s:warning['end_incl'] = v:true

let s:information = {}
let s:information['highlight'] = 'Underlined'
let s:information['priority'] = 2
let s:information['combine'] = v:true
let s:information['start_incl'] = v:true
let s:information['end_incl'] = v:true

let s:hint = {}
let s:hint['highlight'] = 'Diagnostic'
let s:hint['priority'] = 1
let s:hint['combine'] = v:true
let s:hint['start_incl'] = v:true
let s:hint['end_incl'] = v:true

function textprop#setup_proptypes(buf)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call s:type_add(a:buf, 'Error', s:error)
    call s:type_add(a:buf, 'Warning', s:warning)
    call s:type_add(a:buf, 'Information', s:information)
    call s:type_add(a:buf, 'Hint', s:hint)
endfunction

function textprop#add(buf, startpos, endpos, severity)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:lnum = a:startpos['line'] + 1
    let l:col = a:startpos['character'] + 1
    let l:props = {}
    " let l:props['length']
    let l:props['end_lnum'] = a:endpos['line'] + 1
    let l:props['end_col'] = a:endpos['character'] + 1
    let l:props['bufnr'] = a:buf
    " let l:props['id']
    if a:severity == 1
        let l:props['type'] = 'Error'
    elseif a:severity == 2
        let l:props['type'] = 'Warning'
    elseif a:severity == 3
        let l:props['type'] = 'Information'
    elseif a:severity == 4
        let l:props['type'] = 'Hint'
    endif
    return s:prop_add(l:lnum, l:col, l:props)
endfunction

function textprop#clear(buf)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:props = {}
    let l:props['bufnr'] = a:buf
    return s:prop_clear(1, line('$'), l:props)
endfunction

function s:type_add(buf, name, props)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let a:props['bufnr'] = a:buf
    if empty(s:prop_type_get(a:name, a:props))
        return s:prop_type_add(a:name, a:props)
    else
        call log#log_error('Property type ' . a:name . ' already defined')
    endif
endfunction

function s:prop_add(...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if s:has_textprop
        return call('prop_add', a:000)
    endif
endfunction

function s:prop_clear(...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if s:has_textprop
        return call('prop_clear', a:000)
    endif
endfunction

function s:prop_type_add(...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if s:has_textprop
        return call('prop_type_add', a:000)
    endif
endfunction

function s:prop_type_get(...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if s:has_textprop
        return call('prop_type_get', a:000)
    endif
    return {}
endfunction
