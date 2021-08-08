if exists("g:loaded_autocmd")
	finish
endif
let g:loaded_autocmd = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


function autocmd#setup_autocmd()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	" autocmd [group] {events} {file-pattern} [++nested] {command}
	augroup vim_package_lsp
		autocmd BufAdd * call s:bufadd_listener(expand('<abuf>'), expand('<afile>:p'))
		autocmd BufRead * call s:bufread_listener(expand('<abuf>'), expand('<afile>:p'))
		autocmd VimLeavePre * call s:vimleavepre_listener(expand('<abuf>'), expand('<afile>:p'))
		autocmd BufDelete * call s:bufdelete_listener(expand('<abuf>'), expand('<afile>:p'))
		autocmd BufWrite * call s:bufwrite_listener(expand('<abuf>'), expand('<afile>:p'))
		autocmd BufWinLeave * call s:bufwinleave_listener(expand('<abuf>'), expand('<afile>:p'))
		autocmd BufUnload * call s:bufunload_listener(expand('<abuf>'), expand('<afile>:p'))
	augroup END
endfunction

function autocmd#add_event_listener()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	if !util#isSpecialbuffers(&buftype)
		augroup vim_package_lsp
			autocmd TextChanged * call s:textchanged_listener(expand('<abuf>'), expand('<afile>:p'))
			" autocmd InsertCharPre * call s:insertcharpre_listener()
			" autocmd InsertChange * call s:insertchange_listener()
			" autocmd InsertLeavePre * call s:insertleavepre_listener()
			autocmd InsertLeave * call s:insertleave_listener(expand('<abuf>'), expand('<afile>:p'))
		augroup END
	endif
endfunction

function s:bufadd_listener(buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_error('==== buf add ====')
	call log#log_error(&buftype)
	call log#log_error(&filetype)
	if !util#isSpecialbuffers(&buftype)
		call client#Openfile(&filetype, str2nr(a:buf), a:path)
	endif
endfunction

function s:bufread_listener(buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_error('==== buf read ====')
	call log#log_error(&buftype)
	call log#log_error(&filetype)
	if !util#isSpecialbuffers(&buftype)
		call client#Openfile(&filetype, str2nr(a:buf), a:path)
	endif
endfunction

function s:vimleavepre_listener(buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_error('==== vim leave pre ====')
	if !util#isSpecialbuffers(&buftype)
		call client#Stop(v:none)
	endif
endfunction

function s:bufdelete_listener(buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_error('==== buf delete ====')
	call log#log_error(&buftype)
	call log#log_error(&filetype)
	if !util#isSpecialbuffers(&buftype)
		call client#Closefile(str2nr(a:buf), a:path)
	endif
endfunction

function s:bufwinleave_listener(buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_error('==== buf win leave ====')
	call log#log_error(&buftype)
	call log#log_error(&filetype)
	" if !util#isSpecialbuffers(&buftype)
	" 	call client#Closefile(str2nr(a:buf), a:path)
	" endif
endfunction

function s:bufunload_listener(buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_error('==== buf unload ====')
	call log#log_error(&buftype)
	call log#log_error(&filetype)
	" if !util#isSpecialbuffers(&buftype)
	" 	call client#Closefile(str2nr(a:buf), a:path)
	" endif
endfunction

function s:bufwrite_listener(buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	if !util#isSpecialbuffers(&buftype)
		call client#Savefile(str2nr(a:buf), a:path)
	endif
endfunction

function s:openfile_listener(buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	if !util#isSpecialbuffers(&buftype)
		call client#Openfile(&filetype, str2nr(a:buf), a:path)
	endif
endfunction

function s:textchanged_listener(buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	if !util#isSpecialbuffers(&buftype)
		call client#Changefile(str2nr(a:buf), a:path)
	endif
endfunction

function s:insertcharpre_listener(buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	if !util#isSpecialbuffers(&buftype)
		call client#Changefile(str2nr(a:buf), a:path)
	endif
endfunction

function s:insertchange_listener(buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	if !util#isSpecialbuffers(&buftype)
		call client#Changefile(str2nr(a:buf), a:path)
	endif
endfunction

" function s:insertleavepre_listener(buf, path)
" 	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
" 	call client#Changefile(str2nr(a:buf), a:path)
" endfunction

function s:insertleave_listener(buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	if !util#isSpecialbuffers(&buftype)
		call client#Changefile(str2nr(a:buf), a:path)
	endif
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
