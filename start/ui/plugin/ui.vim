if exists("g:loaded_ui")
	finish
endif
let g:loaded_ui = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


call cmd#setup_install_cmd()

call cmd#setup_command()
call cmd#setup_autocmd()
" call cmd#setup_buffercmd()
" augroup vim_package_lsc
" 	autocmd BufRead * LscOpen
" 	autocmd BufUnload * LscClose
" 	autocmd VimLeave * LscStop
" augroup END


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
