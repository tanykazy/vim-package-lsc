if exists("g:loaded_languageserver")
	finish
endif
let g:loaded_languageserver= 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim

let s:ls_dir = expand('<sfile>:p:h:h')


function languageserver#GetPath()
	return simplify(s:ls_dir)
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions

