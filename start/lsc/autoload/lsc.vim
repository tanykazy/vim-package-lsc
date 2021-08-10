function lsc#Lsc()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	" call client#Start('typescript', s:GetCwd())
	call client#Start('typescript', str2nr(expand('<abuf>')), util#getcwd(str2nr(expand('<abuf>'))))
endfunction

function lsc#start()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call client#Start('typescript', str2nr(expand('<abuf>')), util#getcwd(str2nr(expand('<abuf>'))))
endfunction

function lsc#stop()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call client#Stop('typescript')
endfunction

function lsc#openfile()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call client#Openfile(str2nr(expand('<abuf>')), expand('<afile>'))
endfunction

function lsc#Test()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call client#Stop('typescript')
endfunction
