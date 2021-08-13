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
    if !util#isNone(a:col)
        let l:location['col'] = a:col + 1
    endif
    " let l:location['vcol']
    if !util#isNone(a:nr)
        let l:location['nr'] = a:nr
    endif
    if !util#isNone(a:text)
        let l:location['text'] = a:text
    endif
    if !util#isNone(a:type)
        let l:location['type'] = a:type
    endif
    " let l:location['valid']
    return l:location
endfunction
