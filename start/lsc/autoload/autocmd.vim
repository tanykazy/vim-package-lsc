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
		autocmd BufReadPre * call lsc#Lsc()
		autocmd ExitPre * call lsc#Test()
	augroup END
endfunction

function autocmd#add_event_listener()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	augroup vim_package_lsp
		autocmd TextChanged * call s:textchanged_listener(expand('<abuf>'), expand('<afile>'))
		" autocmd InsertCharPre * call s:insertcharpre_listener(expand('<abuf>'), expand('<afile>'))
		" autocmd InsertChange * call s:insertchange_listener(expand('<abuf>'), expand('<afile>'))
		autocmd InsertLeavePre * call s:insertleavepre_listener(expand('<abuf>'), expand('<afile>'))
		" autocmd InsertLeave * call s:insertleave_listener(expand('<abuf>'), expand('<afile>'))
	augroup END
endfunction

function s:textchanged_listener(buf, file)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	" call log#log_error(a:buf)
	" call log#log_error(a:file)
	call client#change_listener(a:buf)
endfunction

function s:insertcharpre_listener(buf, file)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	" call log#log_error(a:buf)
	" call log#log_error(a:file)
	call client#change_listener(a:buf)
endfunction

function s:insertchange_listener(buf, file)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	" call log#log_error(a:buf)
	" call log#log_error(a:file)
	call client#change_listener(a:buf)
endfunction

function s:insertleavepre_listener(buf, file)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	" call log#log_error(a:buf)
	" call log#log_error(a:file)
	call client#change_listener(a:buf)
endfunction

function s:insertleave_listener(buf, file)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	" call log#log_error(a:buf)
	" call log#log_error(a:file)
	call client#change_listener(a:buf)
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
