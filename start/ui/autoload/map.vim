function map#setup_buffermap()
    nmap <buffer> <silent> <F3> :call client#document_hover(bufnr('%'), getpos('.'))<CR>
endfunction