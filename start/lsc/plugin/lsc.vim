if exists("g:loaded_lsc")
	finish
endif
let g:loaded_lsc = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


" command -nargs=0 Lsc :call lsc#Lsc(<f-args>)
" command -nargs=0 Test :call lsc#Test(<f-args>)





" let g:log_level = log#level_trace
let g:log_level = log#level_debug
call log#start_log()
call log#log_trace('load: plugin/lsc.vim')
call log#log_debug('load: plugin/lsc.vim')
call log#log_error('load: plugin/lsc.vim')

call cmd#setup_install_cmd()

" call log#log_error(string(conf#getLangList()))
" call conf#install('typescript')


" call log#log_error(exists('?listener_add'))

" call lsc#Lsc()
" call autocmd#setup_autocmd()
" call highlight#setup_highlight()
" call textprop#setup_proptypes()

" function s:test(...)
" endfunction

" let s = server#create('typescript', funcref('s:test'))
" call s.start()
" call s.recv('aa')
" let s2 = server#create('typescript', funcref('s:test'))

" let str = 'The quick brown fox jumps over the lazy dog.'
" call log#log_debug(string(util#split(str, ' ', 2)))
" call log#log_debug(strpart(str, 0, 3))



let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
