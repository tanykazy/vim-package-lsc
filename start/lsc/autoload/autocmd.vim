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
		autocmd BufAdd * call s:bufadd_listener()
		autocmd BufRead * call s:bufread_listener()
		autocmd VimLeavePre * call s:vimleavepre_listener()
		autocmd BufDelete * call s:bufdelete_listener()
	augroup END
endfunction

function autocmd#add_event_listener()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	augroup vim_package_lsp
		autocmd TextChanged * call s:textchanged_listener()
		" autocmd InsertCharPre * call s:insertcharpre_listener()
		" autocmd InsertChange * call s:insertchange_listener()
		" autocmd InsertLeavePre * call s:insertleavepre_listener()
		autocmd InsertLeave * call s:insertleave_listener()
	augroup END
endfunction

function s:bufadd_listener()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	" call log#log_debug(&filetype)
	call log#log_debug('=== bufadd ===')
	let l:buf = str2nr(expand('<abuf>'))
	let l:path = expand('<afile>:p') 
	call client#Openfile('typescript', l:buf, l:path)
endfunction

function s:bufread_listener()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_debug('=== bufread ===')
	" call log#log_debug(&filetype)
	let l:buf = str2nr(expand('<abuf>'))
	let l:path = expand('<afile>:p') 
	call client#Openfile('typescript', l:buf, l:path)
endfunction

function s:vimleavepre_listener()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call client#Stop(v:none)
endfunction

function s:bufdelete_listener()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:buf = str2nr(expand('<abuf>'))
	let l:path = expand('<afile>:p') 
	call client#Closefile(l:buf, l:path)
endfunction

function s:openfile_listener()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:buf = str2nr(expand('<abuf>'))
	let l:path = expand('<afile>:p') 
	call client#Openfile('typescript', l:buf, l:path)
endfunction

function s:textchanged_listener()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	" call log#log_error(a:buf)
	" call log#log_error(a:path)
	let l:buf = str2nr(expand('<abuf>'))
	let l:path = expand('<afile>:p') 
	call client#Changefile(l:buf, l:path)
endfunction

function s:insertcharpre_listener()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	" call log#log_error(a:buf)
	" call log#log_error(a:path)
	let l:buf = str2nr(expand('<abuf>'))
	let l:path = expand('<afile>:p') 
	call client#Changefile(l:buf, l:path)
endfunction

function s:insertchange_listener()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	" call log#log_error(a:buf)
	" call log#log_error(a:path)
	let l:buf = str2nr(expand('<abuf>'))
	let l:path = expand('<afile>:p') 
	call client#Changefile(l:buf, l:path)
endfunction

" function s:insertleavepre_listener()
" 	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
" 	call log#log_error(a:buf)
" 	call log#log_error(a:path)
	" let l:buf = str2nr(expand('<abuf>'))
	" let l:path = expand('<afile>:p') 
" 	call client#Changefile(l:buf, l:path)
" endfunction

function s:insertleave_listener()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	" call log#log_error(expand('<abuf>') . expand('<afile>:p'))
	let l:buf = str2nr(expand('<abuf>'))
	let l:path = expand('<afile>:p') 
	" call log#log_error(l:buf)
	" call log#log_error(l:path)
	call client#Changefile(l:buf, l:path)
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
