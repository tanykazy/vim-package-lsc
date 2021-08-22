let s:has_popupwin = has('popupwin')

function popup#hover(text, options)
    let b:hover_id = get(b:, 'hover_id', v:none)
    let b:hover_text = get(b:, 'hover_text', [])
    if b:hover_text ==# a:text
        return
    endif
    if !util#isNone(b:hover_id)
        call popup_close(b:hover_id)
    endif
    let l:id = popup#atcursor(a:text, a:options)
    let b:hover_id = l:id
    let b:hover_text = a:text
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
    let l:opt.pos = 'botleft'
    let l:opt.line = 'cursor-1'
    let l:opt.col = 'cursor'
    " let l:opt.moved = 'WORD'
    let l:opt.fixed = v:true
    let l:opt.mapping = v:false
    if !util#isNone(a:options)
        call extend(l:opt, a:options)
    endif
    call log#log_debug(string(l:opt))
    return popup_atcursor(a:what, l:opt)
endfunction
