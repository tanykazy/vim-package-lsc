if exists("g:loaded_client")
	finish
endif
let g:loaded_client= 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim

function client#Callback(channel, msg)
    " echo a:channel
    call ch_log('---------- debug ----------')
    call ch_log(string(jsonrpc#parse_header(a:msg)))
    echo split(a:msg, "\r\n\r\n")
    " echo json_decode(a:msg)
    " echo '---' . a:msg . '---'
    " try
    " endtry
    " return s:matrix[s:state][s:event].fn(event, data)
endfunction

function client#ErrorCallback(channel, msg)
    " echo a:channel
    echo a:msg
    " try
    " endtry
    " return s:matrix[s:state][s:event].fn(event, data)
endfunction

let s:stateIdle = 0
let s:stateInitialized = 1
let s:stateShutdown = 2

let s:eventRequest = 0
let s:eventResponse = 1
let s:eventNotification = 2

let s:matrix = {}
let s:matrix[s:stateIdle] = {}
let s:matrix[s:stateIdle][s:eventRequest] = {}
let s:matrix[s:stateIdle][s:eventResponse] = {}
let s:matrix[s:stateIdle][s:eventNotification] = {}
let s:matrix[s:stateInitialized] = {}
let s:matrix[s:stateInitialized][s:eventRequest] = {}
let s:matrix[s:stateInitialized][s:eventResponse] = {}
let s:matrix[s:stateInitialized][s:eventNotification] = {}
let s:matrix[s:stateShutdown] = {}
let s:matrix[s:stateShutdown][s:eventRequest] = {}
let s:matrix[s:stateShutdown][s:eventResponse] = {}
let s:matrix[s:stateShutdown][s:eventNotification] = {}

let s:state = s:stateIdle
let s:event = s:eventRequest

function s:matrix[s:stateIdle][s:eventRequest].fn(event, data) dict
endfunction

function s:matrix[s:stateIdle][s:eventResponse].fn(event, data) dict
endfunction

function s:matrix[s:stateIdle][s:eventNotification].fn(event, data) dict
endfunction

function s:matrix[s:stateInitialized][s:eventRequest].fn(event, data) dict
endfunction

function s:matrix[s:stateInitialized][s:eventResponse].fn(event, data) dict
endfunction

function s:matrix[s:stateInitialized][s:eventNotification].fn(event, data) dict
endfunction

function s:matrix[s:stateShutdown][s:eventRequest].fn(event, data) dict
endfunction

function s:matrix[s:stateShutdown][s:eventResponse].fn(event, data) dict
endfunction

function s:matrix[s:stateShutdown][s:eventNotification].fn(event, data) dict
endfunction


function client#Test()
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
