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
    let l:opt['out_cb'] = funcref('s:OutCallbackhandler')
    let l:opt['err_cb'] = funcref('s:ErrCallbackhandler')
	let l:opt['exit_cb'] = funcref('s:ExitCallbackhandler')
    let l:opt['stoponexit'] = 'term'
    let l:opt['noblock'] = 1
    let l:opt['cwd'] = a:cwd
	let l:job = job_start(a:command, l:opt)
	let l:channel = job_getchannel(l:job)
	let l:id = ch_info(l:channel)['id']
	let l:info = {}
	let l:info['handle'] = l:channel
	let l:info['id'] = l:id
	let l:info['callback'] = a:callback
	let l:info['job'] = l:job
	let s:channel_info[l:id] = l:info
	return l:info
endfunction

function channel#Send(channel, data)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:payload = jsonrpc#build_payload(a:data)
	call log#log_debug('Send data to[' . a:channel['id'] . ']:' . l:payload)
	return ch_sendraw(a:channel['handle'], l:payload, {})
endfunction

function channel#Close(channel)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call job_stop(a:channel['job'], 'term')
	" call log#log_error(job_status(a:channel['job']))
	call ch_close(a:channel['handle'])
	let l:id = a:channel['id']
	if has_key(s:channel_info, l:id)
		call remove(s:channel_info, l:id)
	endif
	return a:channel
endfunction

function s:OutCallbackhandler(channel, msg)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:info = s:GetChannelInfo(a:channel)
	call log#log_debug('Receive data from[' . l:info['id'] . ']:' . a:msg)
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
		if has_key(l:info, 'callback')
			if ch_status(a:channel) == 'open'
				let l:message = remove(l:info, 'message')
				call l:info['callback'](l:info, l:message['content'])
			endif
		endif
	endif
endfunction

function s:ErrCallbackhandler(channel, msg)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_debug(a:channel . a:msg)
endfunction

function s:ExitCallbackhandler(job, status)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_debug(a:job. a:status)
	call log#log_error(a:job. a:status)
endfunction

function s:GetChannelInfo(channel)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:id = ch_info(a:channel)['id']
	if has_key(s:channel_info, l:id)
		return s:channel_info[l:id]
	endif
	return v:null
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
