if exists("g:loaded_langserver")
	finish
endif
let g:loaded_langserver= 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim

let s:langserver_dir = expand('<sfile>:p:h')


function langserver#getpath()
	return simplify(s:ls_dir)
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions

