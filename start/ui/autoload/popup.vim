let s:has_popupwin = has('popupwin')

function popup#hover(title, text, options)
    call log#log_error(string(a:title))
    call log#log_error(string(a:text))
    let b:hover_id = get(b:, 'hover_id', v:none)
    let b:hover_text = get(b:, 'hover_text', [])
    if b:hover_text ==# a:text
        return
    endif
    if !util#isNone(b:hover_id)
        call s:popup_close(b:hover_id, -1)
    endif
    let l:len = len(a:text)
    let l:maxwidth = 0
    for l:line in a:text
        let l:width = strdisplaywidth(l:line)
        if l:maxwidth < l:width
            let l:maxwidth = l:width
        endif
    endfor
    call log#log_error(string(l:maxwidth))
    let l:opt = {}
    let l:opt.pos = 'botleft'
    let l:opt.line = 'cursor-1'
    let l:opt.col = 'cursor'
    let l:opt.moved = 'WORD'
    let l:opt.fixed = v:false
    let l:opt.mapping = v:false
    let l:opt.maxheight = 5
    if l:opt.maxheight > l:len
        let l:opt.minheight = l:len
    else
        let l:opt.minheight = l:opt.maxheight
    endif
    let l:opt.maxwidth = winwidth(0)
    if l:opt.maxwidth > l:maxwidth
        let l:opt.minwidth = l:maxwidth
    else
        let l:opt.minwidth = l:opt.maxwidth
    endif
    let l:opt.scrollbar = v:true
    let l:opt.filter = funcref('s:hover_filter')
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

function s:hover_filter(winid, key)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if a:key == "\<C-N>"
        call s:hover_down(a:winid)
        return popup_filter_menu(a:winid, a:key)
    elseif a:key == "\<C-P>"
        call s:hover_up(a:winid)
        return popup_filter_menu(a:winid, a:key)
    endif
    return v:false
endfunction

function s:hover_up(winid)
    let l:pos = popup_getpos(a:winid)
    call s:setoptions_firstline(a:winid, l:pos.firstline - 1)
endfunction

function s:hover_down(winid)
    let l:pos = popup_getpos(a:winid)
    call s:setoptions_firstline(a:winid, l:pos.firstline + 1)
endfunction

function s:setoptions_firstline(winid, line)
    " redraw!
    call popup_setoptions(a:winid, {'firstline': a:line})
    redraw!
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
    unlet! b:hover_id
    unlet! b:hover_text
    redraw!
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
