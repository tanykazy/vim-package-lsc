if exists("g:loaded_client")
	finish
endif
let g:loaded_client= 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


function client#Callback(channel, msg)
    call ch_log('===== debug =====' . string(a:msg))

    " if has_key(l:message, 'content')

    " endif
    " return s:matrix[s:state][s:event].fn(event, data)
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

function s:matrix[s:stateIdle][s:eventRequest].fn(event, data) dict
endfunction

function s:matrix[s:stateIdle][s:eventResponse].fn(event, data) dict
endfunction

function s:matrix[s:stateIdle][s:eventNotification].fn(event, data) dict
endfunction

function s:matrix[s:stateActive][s:eventRequest].fn(event, data) dict
endfunction

function s:matrix[s:stateActive][s:eventResponse].fn(event, data) dict
endfunction

function s:matrix[s:stateActive][s:eventNotification].fn(event, data) dict
endfunction


function client#Test()
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
