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
    let l:opt['out_cb'] = function('s:OutCallbackhandler')
    let l:opt['err_cb'] = function('s:ErrCallbackhandler')
    let l:opt['cwd'] = a:cwd
	let l:job = s:JobStart(a:command, l:opt)
	let l:channel = s:JobGetchannel(l:job)
    let l:info = s:AddChannelInfo(l:channel)
	let l:info['callback'] = a:callback
	return l:channel
endfunction

function channel#Send(channel, data)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:info = s:GetChannelInfo(a:channel)
	return s:ChSendraw(l:info['channel'], a:data, {})
endfunction

function channel#Close(channel)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:info = s:GetChannelInfo(a:channel)
	let l:job = s:ChGetjob(a:channel)	
	call s:JobStop(l:job)
	call s:ChClose(a:channel)
	call s:DelChannel(a:channel)
	return a:channel
endfunction

function s:OutCallbackhandler(channel, msg)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:info = s:GetChannelInfo(a:channel)
	let l:message = jsonrpc#parse_message(a:msg)
	if !has_key(l:info, 'message')
		let l:info['message'] = {}
	endif
	call extend(l:info['message'], l:message)
	" if has_key(l:message, 'header')
	" 	call extend(l:info['message'], l:message)
	" endif
	" if has_key(l:message, 'content')
	" 	call extend(l:info['message'], l:message)
	" endif
	if has_key(l:info['message'], 'header') && has_key(l:info['message'], 'content')
		if has_key(s:channel_info[a:channel], 'callback')
			let l:message = remove(l:info, 'message')
			call s:channel_info[a:channel]['callback'](a:channel, l:message)
		endif
	endif
endfunction

function s:ErrCallbackhandler(channel, msg)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call ch_log(a:channel)
	call ch_log(a:msg)
endfunction

function s:ChannelInfo(channel)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:info = {}
	let l:info['channel'] = a:channel
	return l:info
endfunction

function s:AddChannelInfo(channel)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	if !has_key(s:channel_info, a:channel)
		let s:channel_info[a:channel] = s:ChannelInfo(a:channel)
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

function s:ChSendraw(handle, expr, options)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return ch_sendraw(a:handle, a:expr, a:options)
endfunction

function s:ChClose(handle)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return ch_chlose(a:handle)
endfunction

function s:ChGetjob(channel)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return ch_getjob(a:channel)
endfunction

function s:JobStart(command, options)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return job_start(a:command, a:options)
endfunction

function s:JobStop(job, how)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return job_stop(a:job, a:how)
endfunction

function s:JobGetchannel(job)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return job_getchannel(a:job)
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
