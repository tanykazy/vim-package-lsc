function complete#completefunc(findstart, base)
    let l:buf = bufnr('%')
	if a:findstart
        let l:path = expand('%:p')
        let l:pos = getpos('.')
        let l:char = v:none
        " call log#log_debug(string(l:pos))
        call client#document_completion(l:buf, l:path, l:pos, l:char)
        " Locate the start of the keyword.
        let l:pattern = '\a'
        let l:flags = 'bn'
        let l:timeout = 0
        let l:skip = v:none
        let l:match = searchpos(l:pattern, l:flags, l:pos[1], l:timeout, l:skip)
        " call log#log_debug(string(l:match))
		return l:match[1]
	else
        " Find matches starting with a:base.
        let l:matches = []
        call util#wait(-1, { -> client#completion_status(l:buf) || complete_check()})
        let l:items = client#get_completion(l:buf)
        call complete_add(l:items)
        " call filter(l:matches, {idx, val -> stridx(val, a:base) == 0})
        " call log#log_debug('after get completion')
        " call log#log_debug(string(l:matches))
        return l:matches
	endif
endfunction
