if exists("g:loaded_server")
	finish
endif
let g:loaded_server = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


function server#Create(server, cwd, receiver)
	let l:channel = channel#Open('npx vscode-json-languageserver --stdio', a:cwd, a:receiver)
    return l:channel
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions