function map#setup_buffermap()
    call log#log_debug('call map#setup_buffermap()')
    nmap <silent> <F3> :<C-u>call client#document_hover(bufnr('%'), getpos('.'))<CR>
    nmap <silent> <F12> :<C-u>call client#goto_definition(bufnr('%'), getpos('.'), v:false)<CR>
    nmap <silent> <S-F12> :<C-u>call client#find_references(bufnr('%'), getpos('.'), v:false)<CR>
    " nmap <silent> <C-k> :<C-u>call client#goto_definition(bufnr('%'), getpos('.'), v:false)<CR>

    " 補完表示時のEnterで改行をしない
    " inoremap <expr><CR>  pumvisible() ? "<C-y>" : "<CR>"
    " inoremap <expr><C-n> pumvisible() ? "<Down>" : "<C-n>"
    " inoremap <expr><C-p> pumvisible() ? "<Up>" : "<C-p>"
endfunction
