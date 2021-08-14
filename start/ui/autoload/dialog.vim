function dialog#choice(msg, ...) " choices, default, type
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:choices = get(a:, 1, v:none)
    let l:default = get(a:, 2, 1)
    let l:type = get(a:, 3, 'Generic')
    let l:answer = confirm(a:msg, join(l:choices, '\n'), l:default, l:type)
    return l:answer - 1
endfunction

function dialog#error(...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    redraw
    echohl ErrorMsg
    echomsg join(a:000)
    " echohl None
    echohl Normal
endfunction
