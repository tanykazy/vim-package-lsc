if exists("g:loaded_client")
	finish
endif
let g:loaded_client= 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


let s:server_info = {}

function client#Start(lang, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:server = server#Create(a:lang, a:path, function('client#Callback'))
    let s:server_info[l:server] = {}
    let s:server_info[l:server]['server'] = l:server
    let s:server_info[l:server]['lang'] = a:lang
    let s:server_info[l:server]['path'] = a:path
    let s:server_info[l:server]['unique'] = 0
    let l:id = s:unique(s:server_info[l:server])
    let l:message = jsonrpc#request_message(l:id, 'initialize', lsp#InitializeParams(v:null, v:null))
    let s:server_info[l:server][l:id] = {}
    let s:server_info[l:server][l:id]['message'] = l:message
	call channel#Send(l:server, l:message)
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
    let l:server = s:server_info[a:channel]
	call log#log_trace('State: ' . s:state . ', Event: ' . s:event)
    return s:matrix[s:state][s:event].fn(l:server, a:content)
endfunction

let s:stateIdle = 0
let s:stateActive = 1

" tbd
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
endfunction

function s:matrix[s:stateIdle][s:eventResponse].fn(server, content) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:id = a:content['id']
    if has_key(a:server, l:id)
        let l:method = a:server[l:id]['message']['method']
        if l:method == 'initialize'
            let l:message = jsonrpc#notification_message('initialized', lsp#InitializedParams())
            call channel#Send(a:server['server'], l:message)
        else
        endif
    endif
endfunction

function s:matrix[s:stateIdle][s:eventNotification].fn(server, content) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
endfunction

function s:matrix[s:stateActive][s:eventRequest].fn(server, content) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
endfunction

function s:matrix[s:stateActive][s:eventResponse].fn(server, content) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
endfunction

function s:matrix[s:stateActive][s:eventNotification].fn(server, content) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
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

function client#Test()
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
