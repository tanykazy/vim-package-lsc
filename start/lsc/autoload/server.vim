if exists("g:loaded_server")
	finish
endif
let g:loaded_server = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


let s:server_file = expand('<sfile>:p:h') . '/language-server.json'

function server#load_setting(lang)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:server_table = util#parse_json_file(s:server_file)
	if !has_key(l:server_table, a:lang)
		call log#log_error('Not found setting ' . a:lang . ' in ' . s:server_file)
	endif
	let l:setting = get(l:server_table, a:lang, {})
	if has_key(l:setting, 'alternative')
		let l:alternative = l:setting['alternative']
		if !has_key(l:server_table, l:alternative)
			call log#log_error('Not found setting ' . l:alternative . ' in ' . s:server_file)
		endif
		let l:setting = get(l:server_table, l:alternative, {})
	endif
	return l:setting
endfunction

function server#isSupport(lang)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:server_table = util#parse_json_file(s:server_file)
	return has_key(l:server_table, a:lang)
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
