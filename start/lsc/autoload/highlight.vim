function highlight#setup_highlight()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    highlight Diagnostic term=underline cterm=underline gui=underline
    highlight Emphasis term=italic cterm=italic gui=italic
    highlight Strong term=bold cterm=bold gui=bold
    highlight Code term=reverse cterm=reverse gui=reverse
endfunction
