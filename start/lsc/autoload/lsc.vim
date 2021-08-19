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

	let l:install_path = conf#get_server_path()
	if !isdirectory(l:install_path)
		let l:result = mkdir(l:install_path, 'p')
	endif
	let l:setting = conf#load_server_setting(a:lang)
	let l:commands = []
	if has_key(l:setting.command, 'dependents')
		let l:dependents = l:setting.command.dependents
		call extend(l:commands, l:dependents)
	endif
	call add(l:commands, l:setting.command.install)

	call installer#install(l:commands, funcref('s:post_install'))
endfunction

function s:post_install(...)
	call cmd#setup_command()
	call cmd#setup_autocmd()
endfunction
