if exists("g:loaded_quickfix")
	finish
endif
let g:loaded_quickfix = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


function quickfix#set_location(nr, list, action)
    call setloclist(a:nr, a:list, a:action)
endfunction

function  quickfix#location(filename, lnum, col, nr, text, type)
    let l:location = {}
    " let l:location['bufnr']
    let l:location['filename'] = a:filename
    " let l:location['module']
    let l:location['lnum'] = a:lnum
    " let l:location['pattern']
    let l:location['col'] = a:col
    " let l:location['vcol']
    let l:location['nr'] = a:nr
    let l:location['text'] = a:text
    let l:location['type'] = a:type
    " let l:location['valid']
    return l:location
endfunction




let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
