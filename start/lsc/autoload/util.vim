if exists("g:loaded_util")
	finish
endif
let g:loaded_util = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


function util#isNone(none)
	return (type(a:none) == v:t_none) && (string(a:none) == 'v:none')
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
