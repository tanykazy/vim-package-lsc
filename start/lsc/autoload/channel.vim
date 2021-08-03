if exists("g:loaded_channel")
	finish
endif
let g:loaded_channel = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


let s:channel_info = {}

function channel#Open(command, cwd, callback)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:opt = {}
    let l:opt['mode'] = 'raw'
    " let l:opt['in_io'] = 'pipe'
    " let l:opt['out_io'] = 'pipe'
    " let l:opt['err_io'] = 'pipe'
    " let l:opt['out_mode'] = 'json'
    let l:opt['out_cb'] = function('s:OutCallbackhandler')
    let l:opt['err_cb'] = function('s:ErrCallbackhandler')
    let l:opt['cwd'] = a:cwd
	let l:job = job_start(a:command, l:opt)
	let l:channel = job_getchannel(l:job)
    let l:info = s:AddChannelInfo(l:channel)
	let l:info['callback'] = a:callback
	return l:channel
endfunction

function channel#Send(channel, data)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:info = s:GetChannelInfo(a:channel)
	let l:payload = jsonrpc#build_payload(a:data)
	call log#log_debug('Send data to[' . a:channel . ']:' . l:payload)
	return ch_sendraw(l:info['channel'], l:payload, {})
endfunction

function channel#Close(channel)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:info = s:GetChannelInfo(a:channel)
	let l:job = ch_getjob(a:channel)	
	call job_stop(l:job, 'term')
	call ch_chlose(a:channel)
	call s:DelChannelInfo(a:channel)
	return a:channel
endfunction

function s:OutCallbackhandler(channel, msg)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_debug('Receive data from[' . a:channel . ']:' . a:msg)
	let l:info = s:GetChannelInfo(a:channel)
	let l:message = jsonrpc#parse_message(a:msg)
	if !has_key(l:info, 'message')
		let l:info['message'] = {}
	endif
	if has_key(l:message, 'header')
		let l:info['message']['header'] = l:message['header']
	endif
	if has_key(l:message, 'content')
		let l:info['message']['content'] = l:message['content']
	endif
	if has_key(l:info['message'], 'header') && has_key(l:info['message'], 'content')
		if has_key(s:channel_info[a:channel], 'callback')
			let l:message = remove(l:info, 'message')
			call s:channel_info[a:channel]['callback'](a:channel, l:message['content'])
		endif
	endif
endfunction

function s:ErrCallbackhandler(channel, msg)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_debug(a:channel . a:msg)
endfunction

function s:AddChannelInfo(channel)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	if !has_key(s:channel_info, a:channel)
		let l:info = {}
		let l:info['channel'] = a:channel
		let s:channel_info[a:channel] = l:info
	endif
    return s:channel_info[a:channel]
endfunction

function s:GetChannelInfo(channel)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	if has_key(s:channel_info, a:channel)
		return get(s:channel_info, a:channel, v:null)
	endif
	return v:null
endfunction

function s:DelChannelInfo(channel)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return remove(s:channel_info, a:channel)
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
