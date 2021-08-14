let s:server_setting_file = expand('<sfile>:p:h:h') . '/server.json'
let s:client_setting_file = expand('<sfile>:p:h:h') . '/client.json'
let s:server_path = expand('<sfile>:p:h:h') . '/language-server/'

let conf#server_path = s:server_path

function conf#load_server_setting(lang)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:server_table = util#parse_json_file(s:server_setting_file)
	if !has_key(l:server_table, a:lang)
		call log#log_error('Not found setting ' . a:lang . ' in ' . s:server_setting_file)
	endif
	return get(l:server_table, a:lang, {})
endfunction

function conf#isSupport(lang)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:server_table = util#parse_json_file(s:server_setting_file)
	return has_key(l:server_table, a:lang)
endfunction


function conf#install(lang)

	if !isdirectory(s:server_path)
		let l:result = mkdir(s:server_path, 'p')
	endif

	let l:options = {}
	let l:options.stoponexit = 'term'
	let l:options.cwd = s:server_path
	let l:options.term_name = 'Install language server: ' . a:lang
	" let l:options.term_kill
	" let l:options.term_finish
	let l:setting = conf#load_server_setting(a:lang)
	let l:cmd = l:setting.command.install

	" for debug


	let l:buf = term_start(l:cmd, l:options)



endfunction
