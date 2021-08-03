command -nargs=0 Lsc :call lsc#Lsc(<f-args>)
command -nargs=0 Test :call lsc#Test(<f-args>)

let g:log_level = log#level_trace
call log#start_log()
call log#log_trace('load: plugin/lsc.vim')
call log#log_debug('load: plugin/lsc.vim')
call log#log_error('load: plugin/lsc.vim')

call lsc#Lsc()
