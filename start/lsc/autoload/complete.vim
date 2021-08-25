let s:break = v:false

function complete#completefunc(findstart, base)
	if a:findstart
        
        augroup vim_package_lsc
            autocmd! CompleteChanged * call log#log_error('complete changed!')
            autocmd! CompleteChanged * let s:break = v:true
        augroup END
        
        let l:buf = bufnr('%')
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
        while !complete_check()
            sleep 100m
            call log#log_debug('wait!')
            if s:break
                let s:break = v:false
                break
            endif
        endwhile
        " "a:base" にマッチする月を探す
        " for m in split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec")
        "     if m =~ '^' . a:base
        "         call complete_add(m)
        "     endif
        "         sleep 300m        " 次の候補の検索をシミュレートする
        "     if complete_check()
        "         break
        "     endif
        " endfor
		" let res = []
		" for m in split("feat: fix: docs: style: refactor: perf: test: chore:")
		" 	if m =~ '^' . a:base
		" 		call add(res, m)
		" 	endif
		" endfor
        return l:matches
	endif
endfunction
