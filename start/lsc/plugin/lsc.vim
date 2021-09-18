if exists("g:loaded_lsc")
	finish
endif
const g:loaded_lsc = 1

const s:save_cpoptions = &cpoptions
set cpoptions&vim


" let g:log_level = log#level_trace
let g:log_level = log#level_debug
" let g:log_level = log#level_error
call log#init()
" call log#start_chlog()

command -nargs=1 -complete=custom,cmd#completion_support_lang LscInstallServer call cmd#install(<f-args>)
command -nargs=1 -complete=custom,cmd#completion_installed_lang LscUninstallServer call cmd#uninstall(<f-args>)
command -nargs=? -complete=custom,cmd#completion_installed_lang LscStart call cmd#start(<f-args>)
command -nargs=? -complete=custom,cmd#completion_running_server LscStop call cmd#stop(<f-args>)
command -nargs=? -complete=buffer LscOpen call cmd#open(<f-args>)
command -nargs=? -complete=buffer LscClose call cmd#close(<f-args>)
command -nargs=? -complete=buffer LscChange call cmd#change(<f-args>)
command -nargs=? -complete=buffer LscSave call cmd#save(<f-args>)

" noremap <silent> <unique> <Plug>(lsc-hover)



augroup vim_package_lsc
	autocmd BufRead * LscOpen
	" autocmd BufReadPost * LscOpen
	" autocmd BufWinEnter * LscOpen
	autocmd BufEnter * LscOpen
	autocmd VimLeave * LscStop
augroup END

call complete#set_completeopt()

call highlight#setup_highlight()


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
