function map#setup_buffermap()
    " nmap <buffer> <silent> <F3> :call client#document_hover(bufnr('%'), getpos('.'))<CR>
    " nmap <buffer> <silent> <F3> :call client#document_hover(bufnr('%'), getpos('.'))<CR>
    " nmap <buffer> <silent> <F12> :call client#goto_definition(bufnr('%'), getpos('.'))<CR>
    nmap <silent> <F3> :call client#document_hover(bufnr('%'), getpos('.'))<CR>
    nmap <silent> <F12> :call client#goto_definition(bufnr('%'), getpos('.'))<CR>

    " 補完表示時のEnterで改行をしない
    " inoremap <expr><CR>  pumvisible() ? "<C-y>" : "<CR>"
    " inoremap <expr><C-n> pumvisible() ? "<Down>" : "<C-n>"
    " inoremap <expr><C-p> pumvisible() ? "<Up>" : "<C-p>"
endfunction
