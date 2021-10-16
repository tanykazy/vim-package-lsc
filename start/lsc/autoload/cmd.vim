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

function cmd#completion_code_action_kind(arglead, cmdline, cursorpos)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:list = keys(lsp#lsp#CodeActionKind())
    return join(l:list, "\n")
endfunction

function cmd#install(lang) abort
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if !util#isContain(setting#getLangList(), a:lang)
        call dialog#error('"' . a:lang . '" not found.')
        return
	endif
    let l:result = setting#install(a:lang, funcref('s:post_install'))
    if l:result
        call dialog#notice('Install...')
    else
        call dialog#error('Installation failed.')
    endif
endfunction

function cmd#uninstall(lang) abort
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if !util#isContain(setting#getInstalledList(), a:lang)
        call dialog#error('"' . a:lang . '" not found.')
        return
	endif
    let l:result = setting#uninstall(a:lang)
    if l:result
        call dialog#notice('Uninstall complete:', a:lang)
    endif
endfunction

function s:post_install()
	call dialog#notice('Installation finished.')
endfunction

function cmd#start(...) abort
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if a:0 > 0
        let l:filetype = a:1
    else
        let l:filetype = &filetype
    endif
    if !util#isContain(setting#getInstalledList(), l:filetype)
        call dialog#error('"' . l:filetype. '" not installed.')
        return
	endif
    let l:bufnr = bufnr('%')
    call client#start(l:filetype, l:bufnr)
endfunction

function cmd#stop(...) abort
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if a:0 > 0
        let l:filetype = a:1
    else
        let l:filetype = v:none
    endif
    call client#stop(l:filetype)
endfunction

function cmd#open(...) abort
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if a:0 > 0
        let l:buffer = bufnr(a:1)
    else
        let l:buffer = bufnr('%')
    endif
    let l:buftype = util#getbuftype(l:buffer)
    if !util#isSpecialbuffers(l:buftype)
        let l:path = expand('%:p')
        if !empty(l:path)
            call client#document_open(l:buffer, l:path)
        endif
    endif
endfunction

function cmd#close(...) abort
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if a:0 > 0
        let l:buffer = bufnr(a:1)
    else
        let l:buffer = bufnr('%')
    endif
    let l:buftype = util#getbuftype(l:buffer)
    if !util#isSpecialbuffers(l:buftype)
        let l:path = expand('%:p')
        if !empty(l:path)
            call client#document_close(l:buffer, l:path)
        endif
    endif
endfunction

function cmd#change(...) abort
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if a:0 > 0
        let l:buffer = bufnr(a:1)
    else
        let l:buffer = bufnr('%')
    endif
    let l:buftype = util#getbuftype(l:buffer)
    if !util#isSpecialbuffers(l:buftype)
        let l:path = expand('%:p')
        if !empty(l:path)
            let l:pos = util#getcursorcharpos()
            call client#document_change(l:buffer, l:path, l:pos, v:char)
        endif
    endif
endfunction

function cmd#save(...) abort
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if a:0 > 0
        let l:buffer = bufnr(a:1)
    else
        let l:buffer = bufnr('%')
    endif
    let l:buftype = util#getbuftype(l:buffer)
    if !util#isSpecialbuffers(l:buftype)
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
    if a:0 > 0
        let l:buffer = bufnr(a:1)
    else
        let l:buffer = bufnr('%')
    endif
    let l:buftype = util#getbuftype(l:buffer)
    if !util#isSpecialbuffers(l:buftype)
        let l:path = expand('%:p')
        if !empty(l:path)
            " let l:pos = getpos('.')
            let l:pos = util#getcursorcharpos()
            let l:pos[2] += 1
            call client#document_completion(l:buffer, l:path, l:pos, v:char)
        endif
    endif
endfunction

function cmd#code_lens(...) abort
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if a:0 > 0
        let l:buffer = bufnr(a:1)
    else
        let l:buffer = bufnr('%')
    endif
    call client#code_lens(l:buffer)
endfunction

function cmd#code_action(...) range abort
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:kind = get(a:, 1, v:none)
    let l:buffer = bufnr('%')
    call client#code_action(l:buffer, a:firstline, a:lastline, l:kind)
endfunction

function cmd#goto_definition() abort
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:buffer = bufnr('%')
    " let l:pos = getpos('.')
    let l:pos = util#getcursorcharpos()
    call client#goto_definition(l:buffer, l:pos)
endfunction

function cmd#goto_implementation() abort
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:buffer = bufnr('%')
    " let l:pos = getpos('.')
    let l:pos = util#getcursorcharpos()
    call client#goto_implementation(l:buffer, l:pos)
endfunction

function cmd#find_references() abort
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:buffer = bufnr('%')
    " let l:pos = getpos('.')
    let l:pos = util#getcursorcharpos()
    call client#find_references(l:buffer, l:pos)
endfunction

function cmd#document_symbol(...) abort
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if a:0 > 0
        let l:buffer = bufnr(a:1)
    else
        let l:buffer = bufnr('%')
    endif
    call client#document_symbol(l:buffer)
endfunction
