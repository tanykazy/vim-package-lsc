function command#test(...)
    call log#log_debug(a:000)
endfunction

function command#start(...) abort
    call log#log_debug('command start' . string(a:000))
    if a:0 > 0
        let l:filetype = a:1
    else
        let l:filetype = &filetype
    endif
    let l:bufnr = bufnr('%')
    let l:cwd = util#getcwd(l:bufnr)
    call client#start(l:filetype, l:bufnr, l:cwd)
endfunction

function command#stop(...) abort
    call log#log_debug('command stop' . string(a:000))
    if a:0 > 0
        let l:filetype = a:1
    else
        let l:filetype = v:none
    endif
    call client#stop(l:filetype)
endfunction

function command#open(...) abort
    call log#log_debug('command open' . string(a:000))
    if a:0 > 0
        let l:buffer = bufnr(a:1)
    else
        let l:buffer = bufnr('%')
    endif
    let l:path = expand('%:p')
    if !empty(l:path)
        call client#document_open(l:buffer, l:path)
    endif
endfunction

function command#close(...) abort
    call log#log_debug('command close' . string(a:000))
    if a:0 > 0
        let l:buffer = bufnr(a:1)
    else
        let l:buffer = bufnr('%')
    endif
    let l:path = expand('%:p')
    if !empty(l:path)
        call client#document_close(l:buffer, l:path)
    endif
endfunction

function command#change(...) abort
    call log#log_debug('command change' . string(a:000))
    if a:0 > 0
        let l:buffer = bufnr(a:1)
    else
        let l:buffer = bufnr('%')
    endif
    let l:path = expand('%:p')
    if !empty(l:path)
        call client#document_change(l:buffer, l:path)
    endif
endfunction

function command#save(...) abort
    call log#log_debug('command save' . string(a:000))
    if a:0 > 0
        let l:buffer = bufnr(a:1)
    else
        let l:buffer = bufnr('%')
    endif
    let l:path = expand('%:p')
    if !empty(l:path)
        call client#document_save(l:buffer, l:path)
    endif
endfunction
