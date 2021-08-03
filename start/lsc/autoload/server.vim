if exists("g:loaded_server")
	finish
endif
let g:loaded_server = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


let s:server_file = expand('<sfile>:p:h') . '/server.json'

function s:read_server_file()
	let l:lines = readfile(s:server_file)
	let l:text = join(l:lines, '')
	let l:json = json_decode(l:text)
	return l:json
endfunction



function server#Create(server, cwd, receiver)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:channel = channel#Open('npx vscode-json-languageserver --stdio', a:cwd, a:receiver)
    return l:channel
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
