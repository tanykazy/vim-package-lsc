function cmd#setup_install_cmd()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    command -nargs=1 -complete=custom,s:completion_support_lang LscInstallServer call lsc#install_server(<f-args>)
    command -nargs=1 -complete=custom,s:completion_installed_lang LscUninstallServer call lsc#uninstall_server(<f-args>)
endfunction

function cmd#setup_command()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    command -nargs=? -complete=filetype LscStart call cmd#start(<f-args>)
    command -nargs=? -complete=filetype LscStop call cmd#stop(<f-args>)
    command -nargs=? -complete=buffer LscOpen call cmd#open(<f-args>)
    command -nargs=? -complete=buffer LscClose call cmd#close(<f-args>)
    command -nargs=? -complete=buffer LscChange call cmd#change(<f-args>)
    command -nargs=? -complete=buffer LscSave call cmd#save(<f-args>)
endfunction

function cmd#setup_autocmd()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	augroup vim_package_lsc
		autocmd BufRead * LscOpen
		autocmd VimLeave * LscStop
	augroup END
endfunction

function cmd#setup_buffercmd(buf)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call log#log_debug('set up buffer autocmd')
	augroup vim_package_lsc
        call util#set_autocmd_buflocal(a:buf, 'BufDelete', 'call cmd#close()')
		call util#set_autocmd_buflocal(a:buf, 'BufDelete', 'call cmd#close()')
		call util#set_autocmd_buflocal(a:buf, 'TextChanged', 'call cmd#change()')
		call util#set_autocmd_buflocal(a:buf, 'InsertLeave', 'call cmd#change()')
		call util#set_autocmd_buflocal(a:buf, 'InsertCharPre', 'call cmd#change()')
		call util#set_autocmd_buflocal(a:buf, 'InsertCharPre', 'call cmd#complement()')
		call util#set_autocmd_buflocal(a:buf, 'CompleteDonePre', 'call cmd#change()')
		call util#set_autocmd_buflocal(a:buf, 'BufWrite', 'call cmd#save()')
		call util#set_autocmd_buflocal(a:buf, 'SafeState', 'call cmd#hover()')
	augroup END
endfunction

function s:completion_support_lang(arglead, cmdline, cursorpos)
    let l:list = setting#getLangList()
    return join(l:list, "\n")
endfunction

function s:completion_installed_lang(arglead, cmdline, cursorpos)
    let l:list = setting#getInstalledList()
    return join(l:list, "\n")
endfunction

function cmd#start(...) abort
    call log#log_debug('command start' . string(a:000))
    if a:0 > 0
        let l:filetype = a:1
    else
        let l:filetype = &filetype
    endif
    let l:bufnr = bufnr('%')
    let l:cwd = util#getcwd(l:bufnr)
    call client#start(l:filetype, l:bufnr, l:cwd)
endfunction

function cmd#stop(...) abort
    call log#log_debug('command stop' . string(a:000))
    if a:0 > 0
        let l:filetype = a:1
    else
        let l:filetype = v:none
    endif
    call client#stop(l:filetype)
endfunction

function cmd#open(...) abort
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
    return client#document_hover(bufnr('%'), getpos('.'))
endfunction

function cmd#complement(...) abort
    call log#log_debug('command complement' . string(a:000))
    if a:0 > 0
        let l:buffer = bufnr(a:1)
    else
        let l:buffer = bufnr('%')
    endif
    if !util#isSpecialbuffers(&buftype)
        let l:path = expand('%:p')
        if !empty(l:path)
            call client#document_completion(l:buffer, l:path, getpos('.'), v:char)
        endif
    endif
endfunction
