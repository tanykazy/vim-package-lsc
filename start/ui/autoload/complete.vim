function complete#completefunc(findstart, base)
    let l:buf = bufnr('%')
	if a:findstart
        let l:path = expand('%:p')
        let l:pos = getpos('.')
        let l:char = v:none
        let l:success = client#document_completion(l:buf, l:path, l:pos, l:char)
        if !l:success
            return -2
        endif
        " Locate the start of the keyword.
        let l:text = strpart(getline('.'), 0, l:pos[2] - 1)
        let l:match = match(l:text, '\k*$')
		return l:match
	else
        " Find matches starting with a:base.
        call util#wait({-> client#completion_status(l:buf) || complete_check()})
        let l:items = client#get_completion(l:buf)
        let l:result = []
        for l:item in l:items
            if stridx(l:item.word, a:base) == 0
                call complete_add(l:item)
                call add(l:result, l:item)
            endif
            if complete_check()
                return -3
            endif
        endfor
        return {'words': l:result, 'refresh': 'always'}
	endif
endfunction
