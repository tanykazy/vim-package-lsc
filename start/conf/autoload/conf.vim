let s:server_setting_file = expand('<sfile>:p:h:h') . '/server.json'
let s:alternative_setting_file = expand('<sfile>:p:h:h') . '/alternative.json'
let s:client_setting_file = expand('<sfile>:p:h:h') . '/client.json'

function conf#load_server_setting(lang)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:server_table = util#parse_json_file(s:server_setting_file)
	if !has_key(l:server_table, a:lang)
		call log#log_error('Not found setting ' . a:lang . ' in ' . s:server_setting_file)
	endif
	return = get(l:server_table, a:lang, {})
endfunction

function conf#resolve_alternative(lang)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:alternative_table = util#parse_json_file(s:alternative_setting_file)
	if !has_key(l:alternative_table, a:lang)
		call log#log_debug('Not found setting ' . a:lang . ' in ' . s:alternative_setting_file)
	endif
	return get(l:alternative_table, a:lang, v:none)
endfunction

function conf#isSupport(lang)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:server_table = util#parse_json_file(s:server_setting_file)
	return has_key(l:server_table, a:lang)
endfunction
