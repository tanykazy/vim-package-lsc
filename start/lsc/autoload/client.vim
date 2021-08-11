let s:server_info = {}

function client#start(lang, buf, cwd)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:server = server#create(a:lang, funcref('client#callback'))
    call l:server.start()

    let l:params = lsp#InitializeParams(l:server['options'], v:none)
    
    call s:send_request(l:server, 'initialize', l:params)

    " if !has_key(s:server_info, a:lang) && server#isSupport(&filetype)
    "     let l:server = s:start_server(a:lang, a:cwd)
    "     if !has_key(l:server, 'capabilities')
    "         let l:params = lsp#InitializeParams(l:server['options'], v:none)
    "         call s:send_request(l:server, 'initialize', l:params)
    "     endif
    " endif
endfunction

function client#stop(filetype)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    " call log#log_debug('Debug server info ' . string(s:server_info))

    let l:server = server#create(a:filetype, funcref('client#callback'))
    " if l:server.running
        call s:send_request(l:server, 'shutdown', v:none)
        " call l:server.stop()
    " endif


    " if util#isNone(a:filetype)
    "     for l:server in values(s:server_info)
    "         call s:send_request(l:server, 'shutdown', v:none)
    "     endfor
    " elseif has_key(s:server_info, a:filetype)
    "     let l:server = s:server_info[a:filetype]
    "     call s:send_request(l:server, 'shutdown', v:none)
    " endif
endfunction

function client#document_open(buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))

    let l:filetype = util#getfiletype(a:buf)

    let l:server = server#create(l:filetype, funcref('client#callback'))

    " if !l:server.running
        call l:server.start()
        let l:params = lsp#InitializeParams(l:server['options'], v:none)
    
        call s:send_request(l:server, 'initialize', l:params)
    " endif


    " if has_key(s:server_info, l:filetype)
    "     let l:server = s:server_info[l:filetype]
    "     if !util#isContain(l:server['files'], a:path)
    "         call s:send_textDocument_didOpen(l:server, a:buf, a:path)
    "     endif
    " else
    "     if server#isSupport(l:filetype)
    "         let l:server = s:start_server(l:filetype, util#getcwd(a:buf))
    "         if !has_key(l:server, 'capabilities')
    "             let l:params = lsp#InitializeParams(l:server['options'], v:none)
    "             call s:send_request(l:server, 'initialize', l:params)
    "         endif
    "     endif
    " endif
endfunction

function client#document_close(buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:filetype = util#getfiletype(a:buf)
    if has_key(s:server_info, l:filetype)
        let l:server = s:server_info[l:filetype]
        if util#isContain(l:server['files'], a:path)
            call s:send_textDocument_didClose(l:server, a:buf, a:path)
        endif
    endif
endfunction

function client#document_change(buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:filetype = util#getfiletype(a:buf)
    if has_key(s:server_info, l:filetype)
        let l:server = s:server_info[l:filetype]
        if util#isContain(l:server['files'], a:path)
            call s:send_textDocument_didChange(l:server, a:buf, a:path)
        endif
    endif
endfunction

function client#document_save(buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:filetype = util#getfiletype(a:buf)
    if has_key(s:server_info, l:filetype)
        let l:server = s:server_info[l:filetype]
        if util#isContain(l:server['files'], a:path)
            call s:send_textDocument_didSave(l:server, a:buf, a:path)
        endif
    endif
endfunction

function client#document_hover(buf, pos)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:path = util#buf2path(a:buf)
    let l:lnum = a:pos[1]
    let l:col = a:pos[2]
    let l:serverlist = s:getserverlist(l:path)
    let l:position = lsp#Position(l:lnum - 1, l:col - 1)
    let l:params = lsp#HoverParams(l:path, l:position, v:none)
    call s:send_request(l:serverlist[0], 'textDocument/hover', l:params)
endfunction

function client#callback(channel, content)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if jsonrpc#isRequest(a:content)
        let s:event = s:eventRequest
    elseif jsonrpc#isResponse(a:content)
        let s:event = s:eventResponse
    elseif jsonrpc#isNotification(a:content)
        let s:event = s:eventNotification
    else
        call log#log_error('Undetected event: ' . string(a:message))
    endif
    for l:server in values(s:server_info)
        if l:server['id'] == a:channel['id']
            return s:matrix[s:state][s:event].fn(l:server, a:content)
        endif
    endfor
endfunction


let s:stateIdle = 0
let s:stateActive = 1

let s:eventRequest = 0
let s:eventResponse = 1
let s:eventNotification = 2

let s:matrix = {}
let s:matrix[s:stateIdle] = {}
let s:matrix[s:stateIdle][s:eventRequest] = {}
let s:matrix[s:stateIdle][s:eventResponse] = {}
let s:matrix[s:stateIdle][s:eventNotification] = {}
let s:matrix[s:stateActive] = {}
let s:matrix[s:stateActive][s:eventRequest] = {}
let s:matrix[s:stateActive][s:eventResponse] = {}
let s:matrix[s:stateActive][s:eventNotification] = {}

let s:state = s:stateIdle
let s:event = s:eventRequest

function s:matrix[s:stateIdle][s:eventRequest].fn(server, content) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call log#log_error('Unimplemented function call')
    call log#log_error(string(a:server))
    call log#log_error(string(a:content))
endfunction

function s:matrix[s:stateIdle][s:eventResponse].fn(server, content) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:id = a:content['id']
    if has_key(a:server, l:id)
        let l:method = a:server[l:id]['message']['method']
        if l:method == 'initialize'
            call remove(a:server, l:id)
            let a:server['capabilities'] = get(a:content['result'], 'capabilities', {})
            let a:server['serverInfo'] = get(a:content['result'], 'serverInfo', {})
            call log#log_debug('Update server info ' . string(a:server))

            let l:params = lsp#InitializedParams()
            call s:send_notification(a:server, 'initialized', l:params)

            let s:state = s:stateActive
            " let l:unopened = a:server['unopened']
            " for l:file in l:unopened
            "     call s:send_textDocument_didOpen(a:server, l:bufinfo['bufnr'], l:file)
            " endfor
            let l:bufinfolist = util#loadedbufinfolist()
            for l:bufinfo in l:bufinfolist
                call s:send_textDocument_didOpen(a:server, l:bufinfo['bufnr'], l:bufinfo['name'])
                " call listener_add(funcref('s:bufchange_listener'), l:bufnr)
                " call autocmd#add_event_listener()
            endfor

        else
        endif
    endif
endfunction

function s:matrix[s:stateIdle][s:eventNotification].fn(server, content) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call log#log_error('Unimplemented function call')
    call log#log_error(string(a:server))
    call log#log_error(string(a:content))
endfunction

function s:matrix[s:stateActive][s:eventRequest].fn(server, content) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call log#log_error('Unimplemented function call')
    call log#log_error(string(a:server))
    call log#log_error(string(a:content))
endfunction

function s:matrix[s:stateActive][s:eventResponse].fn(server, content) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:id = a:content['id']
    if has_key(a:server, l:id)
        let l:method = a:server[l:id]['message']['method']
        if l:method == 'shutdown'
            call s:send_notification(a:server, 'exit', v:none)
            call remove(a:server, l:id)
            call channel#close(a:server['channel'])
            call remove(s:server_info, a:server['lang'])
            let s:state = s:stateIdle
        else
        endif
    endif
endfunction

function s:matrix[s:stateActive][s:eventNotification].fn(server, content) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if a:content['method'] == 'textDocument/publishDiagnostics'
        let l:location = []
        " call textprop#clear('%')
        for l:value in a:content['params']['diagnostics']
            let l:file = util#uri2path(a:content['params']['uri'])
            let l:lnum = l:value['range']['start']['line']
            let l:col = l:value['range']['start']['character']
            let l:nr = get(l:value, 'code', v:none)
            let l:text = l:value['message']
            let l:type = get(l:value, 'severity', v:none)
            " call add(l:location, quickfix#location(l:file, l:lnum, l:col, l:nr, l:text, l:type))

            let l:start = l:value['range']['start']
            let l:end = l:value['range']['end']
            " call textprop#add(l:start, l:end, l:type)
        endfor
        " call quickfix#set_quickfix(v:none, l:location, 'r')
    endif
endfunction

function s:send_textDocument_didOpen(server, buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:text = util#getbuftext(a:buf)
    let l:changedtick = util#getchangedtick(a:buf)
    let l:params = lsp#DidOpenTextDocumentParams(a:path, &filetype, l:changedtick, l:text)
    call add(a:server['files'], a:path)
    call s:send_notification(a:server, 'textDocument/didOpen', l:params)
endfunction

function s:send_textDocument_didClose(server, buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:params = lsp#DidCloseTextDocumentParams(a:path)
    call filter(a:server['files'], {idx, val -> val != a:path})
    call s:send_notification(a:server, 'textDocument/didClose', l:params)
endfunction

function s:send_textDocument_didChange(server, buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:version = util#getchangedtick(a:buf)
    let l:change = lsp#TextDocumentContentChangeEvent(v:none, util#getbuftext(a:buf))
    let l:params = lsp#DidChangeTextDocumentParams(a:path, l:version, [l:change])
    return s:send_notification(a:server, 'textDocument/didChange', l:params)
endfunction

function s:send_textDocument_didSave(server, buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:text = util#getbuftext(a:buf)
    let l:params = lsp#DidSaveTextDocumentParams(a:path, l:text)
    return s:send_notification(a:server, 'textDocument/didSave', l:params)
endfunction

function s:send_request(server, method, params)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    " let l:unique = s:unique(a:server)
    let l:message = jsonrpc#request_message(a:server.id, a:method, a:params)
    " let a:server[l:unique] = {}
    " let a:server[l:unique]['message'] = l:message
    return a:server.send(l:message)
endfunction

function s:send_response(server, message)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    return channel#send(a:server['channel'], a:message)
endfunction

function s:send_notification(server, method, params)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:message = jsonrpc#notification_message(a:method, a:params)
    return channel#send(a:server['channel'], l:message)
endfunction

function s:start_server(filetype, cwd)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if has_key(s:server_info, a:filetype)
        let l:server = s:server_info[a:filetype]
    else
        let l:setting = server#load_setting(a:filetype)
        if has_key(l:setting, 'alternative')
            let l:alternative = l:setting['alternative']
            call log#log_debug('Alternative to ' . a:filetype . ' is ' . l:alternative)
            let l:server = s:start_server(l:alternative, a:cwd)
        else
            let l:channel = channel#open(l:setting['cmd'], a:cwd, funcref('client#callback'))
            let l:server = {}
            let l:server['options'] = get(l:setting, 'options', v:none)
            let l:server['id'] = l:channel['id']
            let l:server['channel'] = l:channel
            let l:server['files'] = []
            " let l:server['unopened'] = []
            " let l:server['langs'] = [a:filetype, l:alternative]
            let l:server['cwd'] = a:cwd
        endif
        let s:server_info[a:filetype] = l:server
    endif
    return l:server
endfunction

function s:unique(server)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if !has_key(a:server, 'unique')
        let a:server['unique'] = 0
    endif
    let l:num = a:server['unique'] + 1
    if l:num > pow(2, 31) - 1
        let l:num = 1
    endif
    let a:server['unique'] = l:num
    return l:num
endfunction

function s:getserverlist(path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:serverlist = []
    for l:server in values(s:server_info)
        if util#isContain(l:server['files'], a:path)
            call add(l:serverlist, l:server)
        endif
    endfor
    return l:serverlist
endfunction

" function client#bufchange_listener(bufnr, start, end, added, changes)
" 	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
" 	call log#log_error(expand('<sfile>') . ':' . expand('<sflnum>'))
" 	call log#log_error(a:bufnr)
" endfunction
