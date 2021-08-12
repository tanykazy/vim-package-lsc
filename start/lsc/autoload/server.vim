let s:servers = {}

function server#create(lang, listener)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if !has_key(s:servers, a:lang)
        let s:servers[a:lang] = s:server.create(a:lang, a:listener)
        call log#log_debug('Create server: ' . string(s:servers[a:lang]))
    endif
    return s:servers[a:lang]
endfunction

let s:server = {}
function s:server.create(lang, listener) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:setting = conf#load_server_setting(a:lang)
    let self.lang = a:lang
    let self.listener = a:listener
    let self.cmd = l:setting.cmd
    let self.options = get(l:setting, 'options', v:none)
    let self.files = []
    let self.wait_res = []
    let self.id = 0
    " let self.channel = channel#open(l:setting.cmd, self.recv)
    return deepcopy(self)
endfunction

function s:server.start() dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let self.channel = channel#open(self.cmd, funcref('self.recv', self))
endfunction

function s:server.stop() dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call self.channel.close()
endfunction

function s:server.send(data) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if jsonrpc#isRequest(a:data)
        call add(self.wait_res, a:data)
    endif
    call self.channel.send(a:data)
    let l:id = self.id + 1
    if l:id > pow(2, 31) - 1
        let l:id = 1
    endif
    let self.id = l:id
endfunction

function s:server.recv(data) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:content= jsonrpc#parse_content(a:data)
    if jsonrpc#isRequest(l:content)
        let l:event = l:content.method
    elseif jsonrpc#isResponse(l:content)
        for l:wait in self.wait_res
            if l:wait.id == l:content.id
                let l:event = l:wait.method
                " remove
            endif
        endfor
    elseif jsonrpc#isNotification(l:content)
        let l:event = l:content.method
    else
        let l:event = 'Unknown'
        call log#log_error('Undetected event: ' . string(l:content))
    endif
    call log#log_debug('===== EVENT ===== ' . l:event)
    if has_key(self.listener, l:event)
        call self.listener[l:event](l:content)
    endif
endfunction
