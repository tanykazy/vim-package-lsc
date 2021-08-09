if exists("g:loaded_autocmd")
	finish
endif
let g:loaded_autocmd = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


augroup vim_package_lsc
	autocmd BufRead * LscOpen
	autocmd BufUnload * LscClose
	autocmd TextChanged * LscChange
	autocmd InsertLeave * LscChange
	" autocmd InsertCharPre * LscChange
	autocmd BufWrite * LscSave
	autocmd VimLeave * LscStop
augroup END


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
