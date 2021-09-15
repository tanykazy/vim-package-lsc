function cmd#setup_autocmd()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	augroup vim_package_lsc
		autocmd BufRead * LscOpen
		" autocmd BufReadPost * LscOpen
		" autocmd BufWinEnter * LscOpen
		autocmd BufEnter * LscOpen
		autocmd VimLeave * LscStop
	augroup END
endfunction

function cmd#setup_buffercmd(buf)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	augroup vim_package_lsc
		call util#set_autocmd_buflocal(a:buf, 'BufDelete', 'call cmd#close()')
		call util#set_autocmd_buflocal(a:buf, 'TextChanged', 'call cmd#change()')
		call util#set_autocmd_buflocal(a:buf, 'InsertLeave', 'call cmd#change()')
		call util#set_autocmd_buflocal(a:buf, 'InsertCharPre', 'call cmd#change()')
		call util#set_autocmd_buflocal(a:buf, 'InsertCharPre', 'call cmd#complement()')
		call util#set_autocmd_buflocal(a:buf, 'CompleteDonePre', 'call cmd#change()')
		call util#set_autocmd_buflocal(a:buf, 'BufWrite', 'call cmd#save()')
		call util#set_autocmd_buflocal(a:buf, 'CursorHold', 'call cmd#hover()')
		" call util#set_autocmd_buflocal(a:buf, 'InsertEnter', 'call popup#close_hover()')
	augroup END
endfunction

function cmd#completion_running_server(arglead, cmdline, cursorpos)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:list = client#get_running_server()
    return join(l:list, "\n")
endfunction

function cmd#completion_support_lang(arglead, cmdline, cursorpos)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:list = setting#getLangList()
    return join(l:list, "\n")
endfunction

function cmd#completion_installed_lang(arglead, cmdline, cursorpos)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:list = setting#getInstalledList()
    return join(l:list, "\n")
endfunction

function cmd#start(...) abort
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call log#log_debug('command start' . string(a:000))
    if a:0 > 0
        let l:filetype = a:1
    else
        let l:filetype = &filetype
    endif
    let l:bufnr = bufnr('%')
    call client#start(l:filetype, l:bufnr)
endfunction

function cmd#stop(...) abort
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call log#log_debug('command stop' . string(a:000))
    if a:0 > 0
        let l:filetype = a:1
    else
        let l:filetype = v:none
    endif
    call client#stop(l:filetype)
    call util#wait({-> empty(client#get_running_server())})
endfunction

function cmd#open(...) abort
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call log#log_debug('command open' . string(a:000))
    if a:0 > 0
        let l:buffer = bufnr(a:1)
    else
        let l:buffer = bufnr('%')
    endif
    if !util#isSpecialbuffers(&buftype)
        let l:path = expand('%:p')
        if !empty(l:path)
            call client#document_open(l:buffer, l:path)
        endif
    endif
endfunction

function cmd#close(...) abort
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call log#log_debug('command close' . string(a:000))
    if a:0 > 0
        let l:buffer = bufnr(a:1)
    else
        let l:buffer = bufnr('%')
    endif
    if !util#isSpecialbuffers(&buftype)
        let l:path = expand('%:p')
        if !empty(l:path)
            call client#document_close(l:buffer, l:path)
        endif
    endif
endfunction

function cmd#change(...) abort
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call log#log_debug('command change' . string(a:000))
    if a:0 > 0
        let l:buffer = bufnr(a:1)
    else
        let l:buffer = bufnr('%')
    endif
    if !util#isSpecialbuffers(&buftype)
        let l:path = expand('%:p')
        if !empty(l:path)
            call client#document_change(l:buffer, l:path, getpos('.'), v:char)
        endif
    endif
endfunction

function cmd#save(...) abort
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call log#log_debug('command save' . string(a:000))
    if a:0 > 0
        let l:buffer = bufnr(a:1)
    else
        let l:buffer = bufnr('%')
    endif
    if !util#isSpecialbuffers(&buftype)
        let l:path = expand('%:p')
        if !empty(l:path)
            call client#document_save(l:buffer, l:path)
        endif
    endif
endfunction

function cmd#hover()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:cursorcharpos = getcursorcharpos()
    let b:hover_cursorcharpos  = get(b:, 'hover_cursorcharpos', [])
    if l:cursorcharpos == b:hover_cursorcharpos
        return
    endif
    let b:hover_cursorcharpos = l:cursorcharpos
    let l:buf = bufnr('%')
    return client#document_hover(l:buf, l:cursorcharpos)
endfunction

function cmd#complement(...) abort
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call log#log_debug('command complement' . string(a:000))
    if a:0 > 0
        let l:buffer = bufnr(a:1)
    else
        let l:buffer = bufnr('%')
    endif
    if !util#isSpecialbuffers(&buftype)
        let l:path = expand('%:p')
        if !empty(l:path)
            let l:pos = getpos('.')
            let l:pos[2] += 1
            call client#document_completion(l:buffer, l:path, l:pos, v:char)
        endif
    endif
endfunction