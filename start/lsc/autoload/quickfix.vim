if exists("g:loaded_quickfix")
	finish
endif
let g:loaded_quickfix = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


function quickfix#set_quickfix(nr, list, action)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    return setqflist(a:list, a:action)
endfunction

function quickfix#set_location(nr, list, action)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    return setloclist(a:nr, a:list, a:action)
endfunction

function quickfix#location(filename, lnum, col, nr, text, type)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:location = {}
    " let l:location['bufnr']
    let l:location['filename'] = a:filename
    " let l:location['module']
    let l:location['lnum'] = a:lnum + 1
    " let l:location['pattern']
    let l:location['col'] = a:col + 1
    " let l:location['vcol']
    let l:location['nr'] = a:nr
    let l:location['text'] = a:text
    let l:location['type'] = a:type
    " let l:location['valid']
    return l:location
endfunction




let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
