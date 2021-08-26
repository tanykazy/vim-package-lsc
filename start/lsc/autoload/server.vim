let s:servers = {}

function server#create(lang, listener)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if has_key(s:servers, a:lang)
        return s:servers[a:lang]
    endif
    let l:server = s:server.new()
    let l:setting = setting#load_server_setting(a:lang)
    let l:install_path = setting#get_install_path()
    let l:server.lang = a:lang
    let l:server.listener = a:listener
    let l:server.cmd = './' . l:setting.command.name . ' ' . join(l:setting.command.options, ' ')
    let l:server.cwd = util#build_path(l:install_path, a:lang, l:setting.path)
    let l:server.options = get(l:setting, 'initializationOptions', v:none)
    let l:server.files = []
    let l:server.wait_res = []
    let l:server.id = 0
    let l:server.running = v:false
    let s:servers[a:lang] = l:server
    call log#log_trace('Create server: ' . string(l:server))
    call log#log_debug('Create server: ' . a:lang)
    return l:server
endfunction

let s:server = {}
function s:server.new() dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    return deepcopy(self)
endfunction

function s:server.start() dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let self.channel = channel#open(self.cmd, self.cwd, funcref('self.recv', self))
    let self.running = v:true
endfunction

function s:server.stop() dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call self.channel.close()
    let self.running = v:false
endfunction

function s:server.send(data) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if jsonrpc#isRequest(a:data)
        call add(self.wait_res, a:data)
        call log#log_debug('Wait for a response to ' . a:data.method)
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
    call log#log_trace('Receive from channel: ' . a:data)
    let l:content= jsonrpc#parse_content(a:data)
    let l:event = v:none
    let l:hit = v:none
    if jsonrpc#isRequest(l:content)
        let l:event = l:content.method
    elseif jsonrpc#isResponse(l:content)
        if jsonrpc#isResponseError(l:content)
            call log#log_error('Request fails: ' . string(l:content))
            call dialog#error(l:content.error.message)
        endif
        for l:wait in self.wait_res
            if l:wait.id == l:content.id
                let l:event = l:wait.method
                let l:hit = l:wait
                " call remove(self.wait_res, index(self.wait_res, l:wait))
            endif
        endfor
    elseif jsonrpc#isNotification(l:content)
        let l:event = l:content.method
    else
        call log#log_error('Undetected event: ' . string(l:content))
    endif
    if has_key(self.listener, l:event)
        call log#log_debug('Call in event: ' . l:event)
        call self.listener[l:event](self, l:content)
    else
        call log#log_debug('Unimplemented listener function call')
        call log#log_debug(string(self))
        call log#log_debug(l:event)
        call log#log_debug(string(a:data))
    endif
    if !util#isNone(l:hit)
        call remove(self.wait_res, index(self.wait_res, l:hit))
    endif
endfunction
