let s:has_popupwin = has('popupwin')

function popup#hover(title, text, options)
    let b:hover_id = get(b:, 'hover_id', v:none)
    let b:hover_text = get(b:, 'hover_text', [])
    if b:hover_text ==# a:text
        return
    endif
    if !util#isNone(b:hover_id)
        call s:popup_close(b:hover_id, -1)
    endif
    let l:maxheight = len(a:text)
    let l:winwidth = winwidth(0)
    let l:winheight = winheight(0)
    let l:maxwidth = 0
    for l:line in a:text
        let l:width = strdisplaywidth(l:line)
        if l:maxwidth < l:width
            let l:maxwidth = l:width
        endif
    endfor
    let l:opt = {}
    let l:opt.maxheight = l:winheight / 2
    if l:opt.maxheight > l:maxheight
        let l:opt.minheight = l:maxheight
    else
        let l:opt.minheight = l:opt.maxheight
    endif
    let l:opt.maxwidth = l:winwidth / 2
    if l:opt.maxwidth > l:maxwidth
        let l:opt.minwidth = l:maxwidth
    else
        let l:opt.minwidth = l:opt.maxwidth
    endif
    let l:opt.pos = 'botleft'
    let l:opt.line = 'cursor-1'
    let l:opt.col = 'cursor'
    let l:opt.moved = 'WORD'
    let l:opt.fixed = v:false
    let l:opt.mapping = v:false
    let l:opt.scrollbar = v:true
    let l:opt.filter = funcref('s:hover_filter')
    let l:opt.callback = funcref('s:hover_close')
    if !util#isNone(a:title)
        let l:opt.title = a:title
    endif
    if !util#isNone(a:options)
        call extend(l:opt, a:options)
    endif
    if l:winwidth - l:opt.col < l:opt.minwidth
        let l:opt.col = l:winwidth - l:opt.minwidth
    endif
    let l:id = popup#atcursor(a:text, l:opt)
    let b:hover_id = l:id
    let b:hover_text = a:text
endfunction

function popup#close_hover()
    let b:hover_id = get(b:, 'hover_id', v:none)
    if !util#isNone(b:hover_id)
        call s:popup_close(b:hover_id)
    endif
endfunction

function s:hover_filter(winid, key)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if !util#isNormal()
    endif
    let l:pos = popup_getpos(a:winid)
    if a:key == "\<Esc>"
        return popup_filter_menu(a:winid, a:key)
    elseif a:key == "\<C-N>"
        let l:buf = winbufnr(a:winid)
        let l:bufinfo = getbufinfo(l:buf)[0]
        if l:pos.lastline < l:bufinfo.linecount
            call s:hover_down(a:winid, l:pos)
        endif
        return popup_filter_menu(a:winid, a:key)
    elseif a:key == "\<C-P>"
        if l:pos.firstline != 1
            call s:hover_up(a:winid, l:pos)
        endif
        return popup_filter_menu(a:winid, a:key)
    endif
    return v:false
endfunction

function s:hover_up(winid, pos)
    call s:setoptions_firstline(a:winid, a:pos.firstline - 1)
endfunction

function s:hover_down(winid, pos)
    call s:setoptions_firstline(a:winid, a:pos.firstline + 1)
endfunction

function s:setoptions_firstline(winid, line)
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
