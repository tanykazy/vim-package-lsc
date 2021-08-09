function command#test(...)
    call log#log_debug(a:000)
endfunction

function command#start(...) abort
    if a:0 > 0
        let l:filetype = a:1
    else
        let l:filetype = &filetype
    endif
    let l:bufnr = bufnr('%')
    let l:cwd = util#getcwd(l:bufnr)
    call client#start(l:filetype, l:bufnr, l:cwd)
endfunction

function command#stop() abort
    call client#stop()
endfunction

function command#open(...) abort
    call log#log_debug(string(a:000))
    let l:path = expand('%:p')
    call log#log_debug(l:path)
endfunction

function command#close(...) abort
    call log#log_debug(string(a:000))
    let l:path = expand('%:p')
    call log#log_debug(l:path)
endfunction

function command#change(...) abort
    call log#log_debug(string(a:000))
    let l:path = expand('%:p')
    call log#log_debug(l:path)
endfunction
