function map#setup_buffermap()
    " nmap <buffer> <silent> <F3> :call client#document_hover(bufnr('%'), getpos('.'))<CR>
    nmap <buffer> <silent> <F12> :call client#goto_definition(bufnr('%'), getpos('.'))<CR>
endfunction
