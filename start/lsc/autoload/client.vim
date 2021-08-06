if exists("g:loaded_client")
	finish
endif
let g:loaded_client= 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


let s:server_info = {}

function client#Start(lang, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if !has_key(s:server_info, a:lang)
        let l:cmd = server#load_setting(a:lang)
        let l:channel = channel#Open(l:cmd, a:path, function('client#Callback'))
        let l:server = {}
        let l:server['id'] = l:channel['id']
        let l:server['channel'] = l:channel
        let l:server['lang'] = a:lang
        let l:server['path'] = a:path
        let l:server['unique'] = 0
        let l:unique = s:unique(l:server)
        let l:message = jsonrpc#request_message(l:unique, 'initialize', lsp#InitializeParams(v:null, v:null))
        let l:server[l:unique] = {}
        let l:server[l:unique]['message'] = l:message
        let s:server_info[a:lang] = l:server
        call channel#Send(l:server['channel'], l:message)
    endif
endfunction

function client#Stop(lang)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if has_key(s:server_info, a:lang)
        let l:server = s:server_info[a:lang]
        let l:unique = s:unique(l:server)
        let l:message = jsonrpc#request_message(l:unique, 'shutdown', v:none)
        let l:server[l:unique] = {}
        let l:server[l:unique]['message'] = l:message
        call channel#Send(l:server['channel'], l:message)
    endif
endfunction

function client#Callback(channel, content)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if jsonrpc#isRequest(a:content)
        let s:event = s:eventRequest
    elseif jsonrpc#isResponse(a:content)
        let s:event = s:eventResponse
    elseif jsonrpc#isNotification(a:content)
        let s:event = s:eventNotification
    else
        call log#log_error('Undetected event: ' string(a:message))
    endif
    for l:server in values(s:server_info)
        if l:server['id'] == a:channel['id']
            return s:matrix[s:state][s:event].fn(l:server, a:content)
        endif
    endfor
endfunction

function client#change_listener(buf)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call s:send_textDocument_didChange(v:none, bufname(a:buf))
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
            let l:message = jsonrpc#notification_message('initialized', lsp#InitializedParams())
            call channel#Send(a:server['channel'], l:message)
            call remove(a:server, l:id)
            let s:state = s:stateActive

            let l:buflist = util#loadedbuflist()
            for l:buf in l:buflist
                let l:bufnr = l:buf['bufnr']
                let l:name = l:buf['name']
                let l:changedtick = l:buf['changedtick']
                let l:text = util#getbuftext(l:bufnr)

                let l:message = jsonrpc#notification_message('textDocument/didOpen', lsp#DidOpenTextDocumentParams(l:name, &filetype, l:changedtick, l:text))

                call channel#Send(a:server['channel'], l:message)

                " call listener_add(function('s:bufchange_listener'), l:bufnr)
                call autocmd#add_event_listener()
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
            let l:message = jsonrpc#notification_message('exit', v:none)
            call channel#Send(a:server['channel'], l:message)
            call remove(a:server, l:id)
            call channel#Close(a:server['channel'])
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

        call textprop#clear('%')

        for l:value in a:content['params']['diagnostics']
            let l:file = util#uri2path(a:content['params']['uri'])
            let l:lnum = l:value['range']['start']['line']
            let l:col = l:value['range']['start']['character']
            let l:nr = l:value['code']
            let l:text = l:value['message']
            let l:type = l:value['severity']
            call add(l:location, quickfix#location(l:file, l:lnum, l:col, l:nr, l:text, l:type))

            let l:start = l:value['range']['start']
            let l:end = l:value['range']['end']
            call textprop#add(l:start, l:end, l:type)
        endfor
        call quickfix#set_quickfix(v:none, l:location, 'r')
    endif
endfunction

function s:send_textDocument_didChange(server, buf)
	" call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    " call log#log_error(string(a:buf))
    let l:bufinfo = getbufinfo(a:buf)
    let l:path = l:bufinfo[0]['name']
    let l:version = l:bufinfo[0]['changedtick']
    let l:changes = []
    call add(l:changes, lsp#TextDocumentContentChangeEvent(v:none, util#getbuftext(a:buf)))
    let l:params = lsp#DidChangeTextDocumentParams(l:path, l:version, l:changes)
    call log#log_debug(string(l:params))

    let l:message = jsonrpc#notification_message('textDocument/didChange', l:params)

    call channel#Send(s:server_info['typescript']['channel'], l:message)
endfunction

function s:unique(server)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:num = a:server['unique'] + 1
    if l:num > pow(2, 31) - 1
        let l:num = 1
    endif
    let a:server['unique'] = l:num
    return l:num
endfunction

" function client#bufchange_listener(bufnr, start, end, added, changes)
function client#bufchange_listener(bufnr)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_error(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_error(a:bufnr)
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
