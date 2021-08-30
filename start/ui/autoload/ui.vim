function ui#set_buffer_cmd(buf)
    call log#log_debug('set up buffer cmd: ' . a:buf)
    call cmd#setup_buffercmd(a:buf)
endfunction
