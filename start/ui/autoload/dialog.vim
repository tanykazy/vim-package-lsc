function dialog#select(msgs)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call map(a:msgs, {idx, val -> join([idx, val], ' ')})
    let l:choices = range(len(a:msgs))
    let l:result = dialog#confirm(join(a:msgs, "\n"), join(l:choices, "\n"))
    if l:result == -1
        return v:none
    else
        return l:result
    endif
endfunction

function dialog#confirm(msg, ...) " choices, default, type
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:choices = get(a:, 1, [])
    let l:default = get(a:, 2, 1)
    let l:type = get(a:, 3, 'Generic')
    let l:answer = s:confirm(a:msg, l:choices, l:default, l:type)
    return l:answer - 1
endfunction

function dialog#info(...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    redraw
    echohl Normal
    echomsg join(a:000)
    echohl Normal
endfunction

function dialog#notice(...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    redraw
    echohl Title
    echomsg join(a:000)
    echohl Normal
endfunction

function dialog#warning(...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    redraw
    echohl WarningMsg
    echomsg join(a:000)
    echohl Normal
endfunction

function dialog#error(...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    redraw
    echohl ErrorMsg
    echomsg join(a:000)
    echohl Normal
endfunction

function dialog#get(...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:result = input(join(a:000))
    return l:result
endfunction

function s:confirm(...)
    return call('confirm', a:000)
endfunction
