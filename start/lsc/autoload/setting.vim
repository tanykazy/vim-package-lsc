const s:server_setting_file = expand('<sfile>:p:h:h') . '/servers.json'
const s:client_setting_file = expand('<sfile>:p:h:h') . '/client.json'
const s:install_path = expand('<sfile>:p:h:h') . '/servers'
const s:settings = util#parse_json_file(s:server_setting_file)

function setting#get_install_path()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return s:install_path
endfunction

function setting#load_server_setting(lang)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	if !has_key(s:settings['language'], a:lang)
		call log#log_error('Not found setting ' . a:lang . ' in ' . s:server_setting_file)
	endif
	return get(s:settings['language'], a:lang, {})
endfunction

function setting#isSupport(lang)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return has_key(s:settings['language'], a:lang)
endfunction

function setting#getLangList()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return keys(s:settings['language'])
endfunction

function setting#getInstalledList()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:list =  glob(util#build_path(s:install_path, '*'), v:false, v:true, v:true)
	return map(l:list, {idx, val -> fnamemodify(val, ':t')})
endfunction

function setting#isInstalled(lang)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:server_path = util#build_path(s:install_path, a:lang)
	return isdirectory(l:server_path)
endfunction

function setting#install(lang, finished) abort
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))

	let l:server_path = util#build_path(s:install_path, a:lang)
	if !isdirectory(l:server_path)
		let l:result = mkdir(l:server_path, 'p')
		if l:result
			call log#log_debug('Create directory: ' . l:server_path)
		else
			call log#log_debug('Directory creation failure: ' . l:server_path)
			call dialog#error('Directory creation failure:', l:server_path)
			return
		endif
	endif

	let l:setting = setting#load_server_setting(a:lang)
	let l:commands = []
	if has_key(l:setting.command, 'dependents')
		let l:commands += l:setting.command.dependents
	endif
	let l:commands += [l:setting.command.install]

	call log#log_debug('Install language server: ' . join(l:commands, "\n"))
    call s:install(l:server_path, l:commands, a:finished)
endfunction

function setting#uninstall(lang) abort
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:server_path = util#build_path(s:install_path, a:lang)
	call log#log_debug('Delete: ' . l:server_path)
	let l:result =  delete(l:server_path, 'rf')
	if l:result == -1
		call dialog#error('Failed to delete:', l:server_path)
		return v:false
	endif
	call dialog#notice('Uninstall complete:', l:server_path)
	return v:true
endfunction

function s:install(path, commands, finished, ...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if !empty(a:commands)
		let l:cmd = a:commands[0]
		let l:more = a:commands[1 : -1]

		let l:options = {}
		let l:options.stoponexit = 'term'
		let l:options.cwd = a:path
		let l:options.term_kill = 'term'
		" let l:options.term_finish = 'close'
		let l:options.exit_cb = funcref('s:install', [a:path, l:more, a:finished])
		call term_start(l:cmd, l:options)
    else
		call log#log_debug('Finished install')
		if type(a:finished) == v:t_func
			call call(a:finished, [])
		endif
	endif
endfunction
