function lsc#Lsc()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call client#Start('typescript', str2nr(expand('<abuf>')), util#getcwd(str2nr(expand('<abuf>'))))
endfunction

function lsc#start()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call client#Start('typescript', str2nr(expand('<abuf>')), util#getcwd(str2nr(expand('<abuf>'))))
endfunction

function lsc#stop()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call client#Stop('typescript')
endfunction

function lsc#openfile()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call client#Openfile(str2nr(expand('<abuf>')), expand('<afile>'))
endfunction

function lsc#Test()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call client#Stop('typescript')
endfunction

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

function s:post_install(...)
	call cmd#setup_command()
	call cmd#setup_autocmd()
endfunction
