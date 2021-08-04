if exists("g:loaded_util")
	finish
endif
let g:loaded_util = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


function util#isNone(none)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return (type(a:none) == v:t_none) && (string(a:none) == 'v:none')
endfunction

function util#parse_json_file(path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:file = expand(a:path)
	let l:json = {}
	if !filereadable(l:file)
		call log#log_error('Unreadable file: ' . l:file)
	else
		let l:lines = readfile(l:file)
		let l:text = join(l:lines, '')
		try
			let l:json = json_decode(l:text)
		catch
			call log#log_error('Decode failure: ' . l:file)
			call log#log_error('Failure cause: ' . v:exception)
		endtry
	endif
	return l:json
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
