function lsc#Lsc()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	" call client#Start('typescript', s:GetCwd())
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
	let l:cmd = l:setting.command.install

	let l:options = {}
	let l:options.stoponexit = 'term'
	let l:options.cwd = l:install_path
	" let l:options.term_name = 'Install language server: ' . a:lang
	let l:options.term_kill = 'term'
	" let l:options.term_finish = 'close'
	let l:options.exit_cb = funcref('s:finished_install')


	call log#log_debug(string(l:options))
	call log#log_debug(string(l:cmd))


	let l:buf = term_start(l:cmd, l:options)
endfunction

function s:finished_install(...)
	" call log#log_error(string(a:000))
	" call dialog#error('end!!')
endfunction
