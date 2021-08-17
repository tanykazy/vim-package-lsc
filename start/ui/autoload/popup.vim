let s:has_popupwin = has('popupwin')

let s:hover_id = v:none

function popup#hover(text, options)
    if !util#isNone(s:hover_id)
        call popup_close(s:hover_id)
    endif
    let l:id = popup#atcursor(a:text, a:options)
    let s:hover_id = l:id
endfunction

function popup#atcursor(what, options)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if !s:has_popupwin
        return
    endif
    if empty(a:what)
        return
    endif
    let l:opt = {}
    if !util#isNone(a:options)
        call extend(l:opt, a:options)
    endif
    let l:opt.pos = 'botleft'
    let l:opt.line = 'cursor-1'
    let l:opt.col = 'cursor'
    " let l:opt.moved = 'WORD'
    let l:opt.fixed = v:true
    call log#log_debug(string(a:what))
    return popup_atcursor(a:what, l:opt)
endfunction
