function complete#completefunc(findstart, base)
    let l:buf = bufnr('%')
	if a:findstart
        let l:path = expand('%:p')
        let l:pos = getpos('.')
        let l:char = v:none
        call client#document_completion(l:buf, l:path, l:pos, l:char)
        " Locate the start of the keyword.
        let l:pattern = '\a'
        let l:flags = 'bn'
        let l:timeout = 0
        let l:skip = v:none
        let l:match = searchpos(l:pattern, l:flags, l:pos[1], l:timeout, l:skip)
		return l:match[1]
	else
        " Find matches starting with a:base.
        call util#wait({-> client#completion_status(l:buf) || complete_check()})
        let l:items = client#get_completion(l:buf)
        for l:item in l:items
            if stridx(l:item.word, a:base) == 0
                call complete_add(l:item)
            endif
            if complete_check()
                break
            endif
        endfor
        return []
	endif
endfunction
