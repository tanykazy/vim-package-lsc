if exists("g:loaded_highlight")
	finish
endif
let g:loaded_highlight = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


function highlight#setup_highlight()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    highlight Diagnostic term=underline cterm=underline gui=underline
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
