let s:has_popupwin = has('popupwin')

function popup#atcursor(what, options)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if !s:has_popupwin
        return
    endif
    let l:opt = {}
    if !util#isNone(a:options)
        call extend(l:opt, a:options)
    endif
    let l:opt.pos = 'botleft'
    let l:opt.line = 'cursor-1'
    let l:opt.col = 'cursor'
    let l:opt.moved = 'WORD'
    return popup_atcursor(a:what, l:opt)
endfunction
