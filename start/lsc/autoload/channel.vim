if exists("g:loaded_channel")
	finish
endif
let g:loaded_channel = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim

call ch_logfile('logfile', 'w')

let s:channel_info = {}

function channel#Open(command, cwd, options)
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
    let l:info = s:AddChannelInfo(l:channel, a:options)
	return l:channel
endfunction

function channel#Send(channel, data)
	let l:info = s:GetChannelInfo(a:channel)
	call s:ChSendraw(l:info['channel'], a:data, {})
endfunction

function channel#Close(channel)
	let l:info = s:GetChannelInfo(a:channel)
	let l:job = s:ChGetjob(a:channel)	
	call s:JobStop(l:job)
	call s:ChClose(a:channel)
	call s:DelChannel(a:channel)
	return a:channel
endfunction

function s:OutCallbackhandler(channel, msg)
	" call ch_log(a:channel)
	" call ch_log('===' . a:msg . '===')
    call ch_log(string(split(a:msg, "\r\n\r\n")))
	if has_key(s:channel_info[a:channel], 'out_cb')
		call s:channel_info[a:channel]['out_cb'](a:channel, a:msg)
	endif
endfunction

function s:ErrCallbackhandler(channel, msg)
	" call ch_log(a:channel)
	" call ch_log(a:msg)
	if has_key(s:channel_info[a:channel], 'err_cb')
		call s:channel_info[a:channel]['err_cb'](a:channel, a:msg)
	endif
endfunction

function s:ChannelInfo(channel, options)
	let l:info = extend({}, a:options, 'error')
	let l:info['channel'] = a:channel
	return l:info
endfunction

function s:AddChannelInfo(channel, options)
	if !has_key(s:channel_info, a:channel)
		let s:channel_info[a:channel] = s:ChannelInfo(a:channel, a:options)
	endif
    return s:channel_info[a:channel]
endfunction

function s:GetChannelInfo(channel)
	if has_key(s:channel_info, a:channel)
		return get(s:channel_info, a:channel, v:null)
	endif
	return v:null
endfunction

function s:DelChannelInfo(channel)
	return remove(s:channel_info, a:channel)
endfunction

function s:ChSendraw(handle, expr, options)
	return ch_sendraw(a:handle, a:expr, a:options)
endfunction

function s:ChClose(handle)
	return ch_chlose(a:handle)
endfunction

function s:ChGetjob(channel)
	return ch_getjob(a:channel)
endfunction

function s:JobStart(command, options)
	return job_start(a:command, a:options)
endfunction

function s:JobStop(job, how)
	return job_stop(a:job, a:how)
endfunction

function s:JobGetchannel(job)
	return job_getchannel(a:job)
endfunction


function s:GetCwd()
	return getcwd(bufwinnr(bufnr("#")))
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
