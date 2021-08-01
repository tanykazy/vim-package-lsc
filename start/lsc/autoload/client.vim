if exists("g:loaded_client")
	finish
endif
let g:loaded_client= 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


let s:server_info = {}

function client#Start(lang, path)
    let l:server = server#Create(a:lang, a:path, function('client#Callback'))
    let s:server_info[l:server] = {}
    let s:server_info[l:server]['server'] = l:server
    let s:server_info[l:server]['lang'] = a:lang
    let s:server_info[l:server]['path'] = a:path
    let s:server_info[l:server]['unique'] = 0
    let l:id = s:unique(s:server_info[l:server])
	let l:initialize = lsp#initialize(l:id)
    let s:server_info[l:server][l:id] = {}
    let s:server_info[l:server][l:id]['message'] = l:initialize
	return channel#Send(l:server, l:initialize)
endfunction

function client#Callback(channel, message)
    let l:content = a:message['content']
    if lsp#isRequest(l:content)
        let s:event = s:eventRequest
    elseif lsp#isResponse(l:content)
        let s:event = s:eventResponse
    elseif lsp#isNotification(l:content)
        let s:event = s:eventNotification
    else
        call ch_log(string(a:message))
        throw 'Event undetected.'
    endif
    let l:server = s:server_info[a:channel]
    return s:matrix[s:state][s:event].fn(l:server, l:content)
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
endfunction

function s:matrix[s:stateIdle][s:eventResponse].fn(server, content) dict
    let l:id = a:content['id']
    if has_key(a:server, l:id)
        " a:server[l:id]['method']
    endif
endfunction

function s:matrix[s:stateIdle][s:eventNotification].fn(server, content) dict
endfunction

function s:matrix[s:stateActive][s:eventRequest].fn(server, content) dict
endfunction

function s:matrix[s:stateActive][s:eventResponse].fn(server, content) dict
endfunction

function s:matrix[s:stateActive][s:eventNotification].fn(server, content) dict
endfunction


function s:unique(server)
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
