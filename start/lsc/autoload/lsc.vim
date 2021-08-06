if exists("g:loaded_lsc")
	finish
endif
let g:loaded_lsc = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


function lsc#Lsc()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	" call client#Start('typescript', s:GetCwd())
	call client#Start('typescript', bufname('<abuf>'), util#getcwd())
endfunction

function lsc#Test()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call client#Stop('typescript')
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
