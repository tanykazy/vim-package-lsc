function installer#install(commands, finished)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call s:install(a:commands, a:finished)
endfunction

function s:install(commands, finished, ...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if !empty(a:commands)
		let l:cmd = a:commands[0]
		let l:more = a:commands[1 : -1]

		let l:options = {}
		let l:options.stoponexit = 'term'
		let l:options.cwd = conf#get_server_path()
		let l:options.term_kill = 'term'
		" let l:options.term_finish = 'close'
		let l:options.exit_cb = funcref('s:install', [l:more, a:finished])
		call term_start(l:cmd, l:options)
    else
        call call(a:finished, [])
	endif
endfunction
