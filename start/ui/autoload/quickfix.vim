let s:has_quickfix = has('quickfix')

function quickfix#set_quickfix(list, file, ...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:what = {}
    let l:what.title = a:file
    let l:what.items = a:list
    let l:context = get(a:, 1, v:none)
    if util#isNone(l:context)
        let l:what.context = {}
        let l:what.context.filename = a:file
    else
        let l:what.context = l:context
    endif
    return s:setqflist([], 'r', l:what)
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
    let l:location['vcol'] = 1
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

function s:setqflist(list, action, what)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if !s:has_quickfix
        return
    endif
    return setqflist(a:list, a:action, a:what)
endfunction

function s:setloclist(nr, list, action, what)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if !s:has_quickfix
        return
    endif
    return setloclist(a:nr, a:list, a:action, a:what)
endfunction
