if exists("g:loaded_lsc")
	finish
endif
let g:loaded_lsc = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


" let g:log_level = log#level_trace
let g:log_level = log#level_debug
" let g:log_level = log#level_error
call log#start_log()
call log#log_trace('load: plugin/lsc.vim')
call log#log_debug('load: plugin/lsc.vim')
call log#log_error('load: plugin/lsc.vim')

call cmd#setup_install_cmd()
call complete#set_completeopt()
call cmd#setup_command()

call highlight#setup_highlight()
call textprop#setup_proptypes(v:none)


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
