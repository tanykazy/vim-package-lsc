function dialog#select_definition()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    return dialog#select()
endfunction

function dialog#select(msg, contexts)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:choices = []
    for l:context in a:contexts
        if type(l:context) == v:t_dict && has_key(l:context, 'text')
            call add(l:choices, l:context.text)
        else
            call add(l:choices, string(l:context))
        endif
    endfor
    let l:result = dialog#confirm(a:msg, l:choices)
    if l:result != -1
        return a:contexts[l:result]
    endif
endfunction

function dialog#confirm(msg, ...) " choices, default, type
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:choices = get(a:, 1, [])
    let l:default = get(a:, 2, 1)
    let l:type = get(a:, 3, 'Generic')
    call map(l:choices, {idx, val -> join([idx, val], ' ')})
    let l:answer = confirm(a:msg, join(l:choices, "\n"), l:default, l:type)
    return l:answer - 1
endfunction

function dialog#info(...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    redraw
    echohl Normal
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
