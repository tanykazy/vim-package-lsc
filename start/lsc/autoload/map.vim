function map#setup_buffermap()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    nmap <silent> <F3> <Plug>(lsc-hover)
    nmap <silent> <F4> <Plug>(lsc-document-symbol)
    nmap <silent> <F11> :<C-u>call client#code_lens(bufnr('%'))<CR>
    nmap <silent> <F12> :<C-u>call client#goto_definition(bufnr('%'), getpos('.'), v:false)<CR>
    nmap <silent> <C-F12> :<C-u>call client#goto_implementation(bufnr('%'), getpos('.'), v:true)<CR>
    nmap <silent> <S-F12> :<C-u>call client#find_references(bufnr('%'), getpos('.'), v:false)<CR>
    " nmap <silent> <C-k> :<C-u>call client#goto_definition(bufnr('%'), getpos('.'), v:false)<CR>

    " 補完表示時のEnterで改行をしない
    " inoremap <expr><CR>  pumvisible() ? "<C-y>" : "<CR>"
    " inoremap <expr><C-n> pumvisible() ? "<Down>" : "<C-n>"
    " inoremap <expr><C-p> pumvisible() ? "<Up>" : "<C-p>"
endfunction
