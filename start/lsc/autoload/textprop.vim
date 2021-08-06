if exists("g:loaded_textprop")
	finish
endif
let g:loaded_textprop = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


function textprop#setup_proptypes()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:error= {}
    " let l:error['bufnr'] = bufnr('%')
    let l:error['highlight'] = 'ErrorMsg'
    let l:error['priority'] = 4
    let l:error['combine'] = v:true
    let l:error['start_incl'] = v:true
    let l:error['end_incl'] = v:true
    call s:type_add('Error', l:error)
    let l:warning = {}
    " let l:warning['bufnr'] = bufnr('%')
    let l:warning['highlight'] = 'WarningMsg'
    let l:warning['priority'] = 3
    let l:warning['combine'] = v:true
    let l:warning['start_incl'] = v:true
    let l:warning['end_incl'] = v:true
    call s:type_add('Warning', l:warning)
    let l:information = {}
    " let l:information['bufnr'] = bufnr('%')
    let l:information['highlight'] = 'Underlined'
    let l:information['priority'] = 2
    let l:information['combine'] = v:true
    let l:information['start_incl'] = v:true
    let l:information['end_incl'] = v:true
    call s:type_add('Information', l:information)
    let l:hint = {}
    " let l:hint['bufnr'] = bufnr('%')
    let l:hint['highlight'] = 'Diagnostic'
    let l:hint['priority'] = 1
    let l:hint['combine'] = v:true
    let l:hint['start_incl'] = v:true
    let l:hint['end_incl'] = v:true
    call s:type_add('Hint', l:hint)
endfunction

function textprop#add(startpos, endpos, severity)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:lnum = a:startpos['line'] + 1
    let l:col = a:startpos['character'] + 1
    let l:props = {}
    " let l:props['length']
    let l:props['end_lnum'] = a:endpos['line'] + 1
    let l:props['end_col'] = a:endpos['character'] + 1
    " let l:props['bufnr']
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
    return prop_add(l:lnum, l:col, l:props)
endfunction

function textprop#clear(buf)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:bufinfo = getbufinfo(a:buf)
    let l:props = {}
    let l:props['bufnr'] = bufname(a:buf)
    return prop_clear(1, l:bufinfo[0]['linecount'], l:props)
endfunction

function s:type_add(name, props)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if empty(prop_type_get(a:name, a:props))
        return prop_type_add(a:name, a:props)
    endif
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
