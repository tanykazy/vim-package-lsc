function channel#open(cmd, callback)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let s:options.out_cb = s:channel.out_cb
	let s:options.err_cb = s:channel.err_cb
	let s:options.exit_cb = s:channel.exit_cb
	let l:job = job_start(a:cmd, s:options)
	let l:channel = job_getchannel(l:job)
	let l:id = ch_info(l:channel).id
	let s:channel.job = l:job
	let s:channel.handle = l:channel
	let s:channel.callback = a:callback
	let s:channel.id = l:id
	return deepcopy(s:channel)
endfunction

function channel#close(channel)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call job_stop(a:channel.job, 'term')
	call ch_close(a:channel.handle)
	return a:channel
endfunction

function channel#send(channel, data)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_debug('Send data to[' . a:channel.id . ']:' . a:data)
	return ch_sendraw(a:channel.handle, a:data, {})
endfunction

let s:options = {}
let s:options.mode = 'raw'
let s:options.stoponexit = 'term'
let s:options.noblock = 1

let s:channel = {}
function s:channel.out_cb(ch, msg) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_debug('Receive data from[' . self.id . ']:' . a:msg)
	if !has_key(self, 'message')
		let self.message = {}
	endif
	if !jsonrpc#contain_header(a:msg)
		let self.message = self.message.content . a:msg
	endif


	while jsonrpc#contain_header(a:msg)

		let l:parts = jsonrpc#split_header(a:msg)

	endwhile

	if !has_key(self.message, 'content')
		let self.message.content = ''
	endif
	let l:content = self.message.content . a:msg



	if jsonrpc#contain_header(a:msg)
		call log#log_debug('== header == ' . string(l:parts[0]))
		let self.message.header = l:parts[0]
		let a:msg = l:parts[2]
	else
		let self.message.content
	endif
	let l:length = l:header['Content-Length']
	if len(l:content) > l:length
		let self.message.content = l:content[0 : l:length]
		let a:msg = l:content[l:length : -1]
	endif
	if len(self.message.content) == l:length
		if has_key(self, 'callback')
			if ch_status(a:ch) == 'open'
				let l:message = remove(self, 'message')
				call self.callback(l:message.content)
			endif
		endif
	endif
endfunction

function s:channel.err_cb(ch, msg) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_debug(a:ch. a:msg)
endfunction

function s:channel.exit_cb(job, status) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_debug(a:job . a:status)
endfunction
