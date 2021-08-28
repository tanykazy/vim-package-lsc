let s:has_popupwin = has('popupwin')

function popup#hover(title, text, options)
    let b:hover_id = get(b:, 'hover_id', v:none)
    let b:hover_text = get(b:, 'hover_text', [])
    if b:hover_text ==# a:text
        return
    endif
    if !util#isNone(b:hover_id)
        call s:popup_close(b:hover_id)
    endif
    let l:opt = {}
    let l:opt.pos = 'botleft'
    let l:opt.line = 'cursor-1'
    let l:opt.col = 'cursor'
    let l:opt.moved = 'WORD'
    let l:opt.fixed = v:false
    let l:opt.mapping = v:false
    let l:opt.maxheight = 5
    let l:opt.scrollbar = v:true
    let l:opt.callback = funcref('s:hover_close')
    if !util#isNone(a:title)
        let l:opt.title = a:title
    endif
    if !util#isNone(a:options)
        call extend(l:opt, a:options)
    endif
    let l:id = popup#atcursor(a:text, l:opt)
    let b:hover_id = l:id
    let b:hover_text = a:text
endfunction

function popup#atcursor(what, options)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:opt = {}
    if !util#isNone(a:options)
        call extend(l:opt, a:options)
    endif
    return s:popup_atcursor(a:what, l:opt)
endfunction

function s:hover_close(id, result)
    let b:hover_id = v:none
    let b:hover_text = []
endfunction

function s:popup_atcursor(...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if s:has_popupwin
        return call('popup_atcursor', a:000)
    endif
endfunction

function s:popup_close(...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if s:has_popupwin
        return call('popup_close', a:000)
    endif
endfunction
