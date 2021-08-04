if exists("g:loaded_lsc")
	finish
endif
let g:loaded_lsc = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


function lsc#Lsc()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call client#Start('typescript', s:GetCwd())
	" call lsc#define_autocmd()
endfunction

function lsc#Test()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call client#Stop('typescript')
endfunction

function lsc#define_autocmd()
	" autocmd [group] {events} {file-pattern} [++nested] {command}
	augroup vim_package_lsp
		autocmd BufReadPre * call lsc#Lsc()
		autocmd ExitPre * call lsc#Test()
	augroup END
endfunction

function s:GetCwd()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return getcwd(bufwinnr(bufnr("#")))
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
