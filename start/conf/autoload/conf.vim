let s:server_setting_file = expand('<sfile>:p:h:h') . '/server.json'
let s:client_setting_file = expand('<sfile>:p:h:h') . '/client.json'
let s:server_path = expand('<sfile>:p:h:h') . '/servers'

let conf#server_path = s:server_path
function conf#get_server_path()
	return s:server_path
	" return util#getcwd('%')
endfunction

function conf#load_server_setting(lang)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:server_table = util#parse_json_file(s:server_setting_file)
	if !has_key(l:server_table['language'], a:lang)
		call log#log_error('Not found setting ' . a:lang . ' in ' . s:server_setting_file)
	endif
	return get(l:server_table['language'], a:lang, {})
endfunction

function conf#isSupport(lang)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:server_table = util#parse_json_file(s:server_setting_file)
	return has_key(l:server_table['language'], a:lang)
endfunction

function conf#getLangList()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:server_table = util#parse_json_file(s:server_setting_file)
	return keys(l:server_table['language'])
endfunction
