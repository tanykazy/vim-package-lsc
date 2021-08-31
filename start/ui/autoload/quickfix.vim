let s:has_quickfix = has('quickfix')

let s:quickfixes = {}

function quickfix#set_quickfix(list, file)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))

    call s:setqflist([], 'r')

    let s:quickfixes[a:file] = a:list
    for [key, value] in items(s:quickfixes)
        let l:what = {}
        " let l:what.title = key
        let l:what.items = value
        " let l:what.context = {}
        " let l:what.context.filename = key
        call s:setqflist([], 'a', l:what)
    endfor
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

function quickfix#preview(file, lnum)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    return s:pedit('+' . a:lnum, a:file)
endfunction

function s:pedit(...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if s:has_quickfix
        execute 'pedit!' join(a:000, ' ')
    else
        execute 'split' '+' . a:lnum a:path
    endif
endfunction

function s:setqflist(...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if s:has_quickfix
        return call('setqflist', a:000)
    endif
endfunction

function s:setloclist(...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if s:has_quickfix
        return call('setloclist', a:000)
    endif
endfunction
