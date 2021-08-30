function ui#set_buffer_cmd(buf)
    call log#log_debug('set up buffer cmd')
    call cmd#setup_buffercmd(a:buf)
    call map#setup_buffermap()
endfunction
