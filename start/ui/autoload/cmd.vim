function cmd#setup_install_cmd()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    command -nargs=? -complete=custom,s:completion_support_lang LscInstallServer call lsc#install_server(<f-args>)
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

function cmd#setup_buffercmd()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call log#log_debug('set up buffer autocmd')
	augroup vim_package_lsc
		autocmd BufDelete <buffer> LscClose
		autocmd TextChanged <buffer> LscChange
		autocmd InsertLeave <buffer> LscChange
		autocmd InsertCharPre <buffer> LscChange
		autocmd BufWrite <buffer> LscSave
		autocmd SafeState <buffer> call client#document_hover(bufnr('%'), getpos('.'))
	augroup END
endfunction

function s:completion_support_lang(arglead, cmdline, cursorpos)
    let l:list = conf#getLangList()
    return join(l:list, "\n")
endfunction

function cmd#install(...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call log#log_error(string(a:000))
    " call conf#install('')
endfunction

function cmd#test(...)
    call log#log_debug(string(a:000))
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
            call client#document_change(l:buffer, l:path)
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

" function autocmd#setup_autocmd()
" 	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
" 	" autocmd [group] {events} {file-pattern} [++nested] {command}
" 	augroup vim_package_lsp
" 		autocmd BufAdd * call s:bufadd_listener(expand('<abuf>'), expand('<afile>:p'))
" 		autocmd BufRead * call s:bufread_listener(expand('<abuf>'), expand('<afile>:p'))
" 		autocmd VimLeavePre * call s:vimleavepre_listener(expand('<abuf>'), expand('<afile>:p'))
" 		autocmd BufDelete * call s:bufdelete_listener(expand('<abuf>'), expand('<afile>:p'))
" 		autocmd BufWrite * call s:bufwrite_listener(expand('<abuf>'), expand('<afile>:p'))
" 		autocmd BufWinLeave * call s:bufwinleave_listener(expand('<abuf>'), expand('<afile>:p'))
" 		autocmd BufUnload * call s:bufunload_listener(expand('<abuf>'), expand('<afile>:p'))
" 	augroup END
" endfunction

" function autocmd#add_event_listener()
" 	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
" 	if !util#isSpecialbuffers(&buftype)
" 		augroup vim_package_lsp
" 			autocmd TextChanged * call s:textchanged_listener(expand('<abuf>'), expand('<afile>:p'))
" 			" autocmd InsertCharPre * call s:insertcharpre_listener()
" 			" autocmd InsertChange * call s:insertchange_listener()
" 			" autocmd InsertLeavePre * call s:insertleavepre_listener()
" 			autocmd InsertLeave * call s:insertleave_listener(expand('<abuf>'), expand('<afile>:p'))
" 		augroup END
" 	endif
" endfunction

" function s:bufadd_listener(buf, path)
" 	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
" 	call log#log_error('==== buf add ====')
" 	call log#log_error(&buftype)
" 	call log#log_error(&filetype)
" 	if !util#isSpecialbuffers(&buftype)
" 		call client#Openfile(&filetype, str2nr(a:buf), a:path)
" 	endif
" endfunction

" function s:bufread_listener(buf, path)
" 	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
" 	call log#log_error('==== buf read ====')
" 	call log#log_error(&buftype)
" 	call log#log_error(&filetype)
" 	if !util#isSpecialbuffers(&buftype)
" 		call client#Openfile(&filetype, str2nr(a:buf), a:path)
" 	endif
" endfunction

" function s:vimleavepre_listener(buf, path)
" 	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
" 	call log#log_error('==== vim leave pre ====')
" 	if !util#isSpecialbuffers(&buftype)
" 		call client#Stop(v:none)
" 	endif
" endfunction

" function s:bufdelete_listener(buf, path)
" 	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
" 	call log#log_error('==== buf delete ====')
" 	call log#log_error(&buftype)
" 	call log#log_error(&filetype)
" 	if !util#isSpecialbuffers(&buftype)
" 		call client#Closefile(str2nr(a:buf), a:path)
" 	endif
" endfunction

" function s:bufwinleave_listener(buf, path)
" 	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
" 	call log#log_error('==== buf win leave ====')
" 	call log#log_error(&buftype)
" 	call log#log_error(&filetype)
" 	" if !util#isSpecialbuffers(&buftype)
" 	" 	call client#Closefile(str2nr(a:buf), a:path)
" 	" endif
" endfunction

" function s:bufunload_listener(buf, path)
" 	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
" 	call log#log_error('==== buf unload ====')
" 	call log#log_error(&buftype)
" 	call log#log_error(&filetype)
" 	" if !util#isSpecialbuffers(&buftype)
" 	" 	call client#Closefile(str2nr(a:buf), a:path)
" 	" endif
" endfunction

" function s:bufwrite_listener(buf, path)
" 	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
" 	if !util#isSpecialbuffers(&buftype)
" 		call client#Savefile(str2nr(a:buf), a:path)
" 	endif
" endfunction

" function s:openfile_listener(buf, path)
" 	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
" 	if !util#isSpecialbuffers(&buftype)
" 		call client#Openfile(&filetype, str2nr(a:buf), a:path)
" 	endif
" endfunction

" function s:textchanged_listener(buf, path)
" 	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
" 	if !util#isSpecialbuffers(&buftype)
" 		call client#Changefile(str2nr(a:buf), a:path)
" 	endif
" endfunction

" function s:insertcharpre_listener(buf, path)
" 	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
" 	if !util#isSpecialbuffers(&buftype)
" 		call client#Changefile(str2nr(a:buf), a:path)
" 	endif
" endfunction

" function s:insertchange_listener(buf, path)
" 	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
" 	if !util#isSpecialbuffers(&buftype)
" 		call client#Changefile(str2nr(a:buf), a:path)
" 	endif
" endfunction

" " function s:insertleavepre_listener(buf, path)
" " 	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
" " 	call client#Changefile(str2nr(a:buf), a:path)
" " endfunction

" function s:insertleave_listener(buf, path)
" 	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
" 	if !util#isSpecialbuffers(&buftype)
" 		call client#Changefile(str2nr(a:buf), a:path)
" 	endif
" endfunction