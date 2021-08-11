function channel#open(cmd, callback)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:ch = {}
	function l:ch.close() dict
		call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
		call job_stop(self.job, 'term')
		call ch_close(self.handle)
		call log#log_debug('Close channel: ' . string(self))
		return self
	endfunction

	function l:ch.send(data) dict
		call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
		call log#log_debug('Send data to[' . self.id . ']:' . a:data)
		return ch_sendraw(self.handle, a:data, {})
	endfunction

	function l:ch.out_cb(ch, msg) dict
		call log#log_error('=== channel ===' . string(self))
		call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
		call log#log_debug('Receive data from[' . self.id . ']:' . a:msg)

		call log#log_error('=== test1 ===' . string(self))
		let self.test = 'test'
		call log#log_error('=== test2 ===' . string(self))

		call self.callback(a:msg)
		" if !has_key(self, 'message')
		" 	let self.message = {}
		" endif
		" if !jsonrpc#contain_header(a:msg)
		" 	let self.message = self.message.content . a:msg
		" endif


		" " while jsonrpc#contain_header(a:msg)

		" " 	let l:parts = jsonrpc#split_header(a:msg)

		" " endwhile

		" if !has_key(self.message, 'content')
		" 	let self.message.content = ''
		" endif
		" let l:content = self.message.content . a:msg



		" if jsonrpc#contain_header(a:msg)
		" 	call log#log_debug('== header == ' . string(l:parts[0]))
		" 	let self.message.header = l:parts[0]
		" 	let a:msg = l:parts[2]
		" else
		" 	let self.message.content
		" endif
		" let l:length = l:header['Content-Length']
		" if len(l:content) > l:length
		" 	let self.message.content = l:content[0 : l:length]
		" 	let a:msg = l:content[l:length : -1]
		" endif
		" if len(self.message.content) == l:length
		" 	if has_key(self, 'callback')
		" 		if ch_status(a:ch) == 'open'
		" 			let l:message = remove(self, 'message')
		" 			call self.callback(l:message.content)
		" 		endif
		" 	endif
		" endif
	endfunction

	function l:ch.err_cb(ch, msg) dict
		call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
		call log#log_debug(a:ch. a:msg)
	endfunction

	function l:ch.exit_cb(job, status) dict
		call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
		call log#log_debug(a:job . a:status)
	endfunction

	let l:opt = {}
	let l:opt.mode = 'raw'
	let l:opt.stoponexit = 'term'
	let l:opt.noblock = 1
	let l:opt.out_cb = l:ch.out_cb
	let l:opt.err_cb = l:ch.err_cb
	let l:opt.exit_cb = l:ch.exit_cb

	let l:ch.job = job_start(a:cmd, l:opt)
	let l:ch.handle = job_getchannel(l:ch.job)
	let l:ch.id = ch_info(l:ch.handle).id
	let l:ch.callback = a:callback

	return copy(l:ch)
endfunction
