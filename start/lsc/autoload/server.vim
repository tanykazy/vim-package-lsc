function server#create(lang, callback)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if !has_key(s:servers, a:lang)
        let l:setting = conf#load_server_setting(a:lang)
        let s:server.lang = a:lang
        let s:server.callback = a:callback
        let s:server.cmd = l:setting.cmd
        let s:server.options = get(l:setting, 'options', v:none)
        let s:server.files = []

        " let l:channel = channel#open(l:setting.cmd, s:server.recv)
        " let s:server.channel = l:channel

        let s:servers[a:lang] = deepcopy(s:server)
    endif
    " call log#log_debug(string(s:servers))
    return s:servers[a:lang]
endfunction

let s:servers = {}

let s:server = {}
let s:server.id = 0
let s:server.running = v:false
let s:server.channel = v:none
function s:server.start() dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))



    let l:channel = channel#open(self.cmd, self.recv)
    let self.channel = l:channel
    let self.running = v:true
    return self
endfunction

function s:server.stop() dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call channel#close(self.channel)
    self.running = v:false
    return self
endfunction

function s:server.send(data) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:payload = jsonrpc#build_payload(a:data)
    call channel#send(self.channel, l:payload)
    let l:id = self.id + 1
    if l:id > pow(2, 31) - 1
        let l:id = 1
    endif
    let self.id = l:id
    return self
endfunction

function s:server.recv(data) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call self.callback(a:data)
    return self
endfunction
