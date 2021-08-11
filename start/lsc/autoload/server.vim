function server#create(lang, callback)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if !has_key(s:servers, a:lang)
        let l:setting = conf#load_server_setting(a:lang)
        " let l:server = copy(s:server)
        let s:server.lang = a:lang
        let s:server.listener = a:callback
        let s:server.cmd = l:setting.cmd
        let s:server.options = get(l:setting, 'options', v:none)
        let s:server.files = []
        let s:server.id = 0
        " let s:server.handle = s:server.recv
        " let s:server.channel = v:none
        " let s:server.id = 0
        let s:server.channel = channel#open(l:setting.cmd, s:server.recv)
        let s:servers[a:lang] = copy(s:server)
    endif
    return s:servers[a:lang]
endfunction

let s:servers = {}

let s:server = {}
function s:server.start() dict
	call log#log_error(string(self))

	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    " let l:channel = channel#open(self.cmd, self.handle)
    " let self.channel = l:channel
    return self
endfunction

function s:server.stop() dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call self.channel.close()
    return self
endfunction

function s:server.send(data) dict
	call log#log_error(string(self))

	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:payload = jsonrpc#build_payload(a:data)
    call self.channel.send(l:payload)
    let l:id = self.id + 1
    if l:id > pow(2, 31) - 1
        let l:id = 1
    endif
    let self.id = l:id
    return self
endfunction

function s:server.recv(data) dict
	call log#log_error('=== server ===' . string(self))

	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call self.listener(a:data)
    return self
endfunction
