function lsc#install_server(lang)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	if !util#isNone(a:lang)
		call setting#install(a:lang, funcref('s:post_install'))
	endif
endfunction

function lsc#uninstall_server(lang)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	if !util#isNone(a:lang)
		call setting#uninstall(a:lang)
	endif
endfunction

function s:post_install()
	call cmd#setup_autocmd()
endfunction
