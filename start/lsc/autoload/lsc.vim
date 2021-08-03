if exists("g:loaded_lsc")
	finish
endif
let g:loaded_lsc = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


function lsc#Lsc()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	" set cmdheight=10
	let l:ch = client#Start('npx vscode-json-languageserver --stdio', s:GetCwd())
	" let l:result = lsp#initialize()
	" let l:b = channel#Send(l:ch, l:result)
endfunction

function lsc#Test()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call client#Stop('npx vscode-json-languageserver --stdio')
endfunction

function s:GetCwd()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return getcwd(bufwinnr(bufnr("#")))
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
