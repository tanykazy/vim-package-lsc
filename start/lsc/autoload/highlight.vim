function highlight#setup_highlight()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    highlight Diagnostic term=underline cterm=underline gui=underline
endfunction
