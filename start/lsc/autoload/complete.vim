function complete#set_completeopt()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    const s:save_completeopt = &completeopt
    set completeopt+=menu,menuone,preview,noselect
endfunction

function complete#set_completefunc(buf)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call setbufvar(a:buf, '&completefunc', 'complete#completefunc')
endfunction

function complete#findstart()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
endfunction

function complete#completefunc(findstart, base)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	if a:findstart
        " Locate the start of the keyword.
        let l:pos = getpos('.')
        let l:text = strpart(getline('.'), 0, l:pos[2] - 1)
        let l:match = match(l:text, '\k*$')
        let l:buf = bufnr('%')
        let l:path = expand('%:p')
        let l:char = v:none
        let l:pos[2] = l:match + 1
        let l:success = client#document_completion(l:buf, l:path, l:pos, l:char)
        if !l:success
            return -3
        endif
		return l:match
	else
        " Find matches starting with a:base.
        let b:base = a:base
        " call util#wait({-> s:ready_completion() || complete_check()})
        " for l:item in b:completion_list
        "     if stridx(l:item.word, a:base) == 0
        "         call complete_add(l:item)
        "     endif
        "     if complete_check()
        "         return -3
        "     endif
        " endfor
        " unlet b:completion_list
        return v:none
	endif
endfunction

function complete#complete(position, completion_items)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:items = []
    for l:completion_item in a:completion_items
        let l:item = {}
        let l:item.word = l:completion_item.label
        if has_key(l:completion_item, 'detail')
            let l:item.menu = l:completion_item.detail
        endif
        if has_key(l:completion_item, 'documentation')
            let l:item.info = l:completion_item.documentation
        endif
        if has_key(l:completion_item, 'kind')
            let l:item.kind = util#lsp_kind2vim_kind(l:completion_item.kind)
        endif
        let l:item.user_data = l:completion_item
        if stridx(l:item.word, get(b:, 'base', '')) == 0
            call add(l:items, l:item)
        endif
    endfor
    let l:col = a:position.character + 1
    call complete(l:col, l:items)
    call complete#onCompleteStart()
    unlet! b:base
endfunction

function complete#onCompleteStart()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	augroup vim_package_lsc
		autocmd CompleteChanged <buffer> call complete#onCompleteChanged(bufnr('%'), v:event.completed_item)
		autocmd CompleteDonePre <buffer> call complete#onCompleteDonePre()
	augroup END
endfunction

function complete#onCompleteChanged(buf, item)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if !empty(a:item)
        call log#log_debug('onCompleteChanged!!!')
        call log#log_debug(string(a:item))
        " call client#completion_resolve(a:buf, a:item)
    endif
endfunction

function complete#onCompleteDonePre()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	augroup vim_package_lsc
		autocmd! CompleteChanged <buffer>
		autocmd! CompleteDonePre <buffer>
	augroup END
endfunction

" function complete#set_completion(list)
"     let b:completion_list = a:list
"     " for l:item in b:completion_list
"     "     call complete_add(l:item)
"     " endfor
" endfunction

" function s:ready_completion()
"     return exists('b:completion_list')
" endfunction
