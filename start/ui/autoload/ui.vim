function ui#set_buffer_cmd()
    call log#log_debug('set up buffer cmd')
    call cmd#setup_buffercmd()
    " call map#setup_buffermap()
endfunction
