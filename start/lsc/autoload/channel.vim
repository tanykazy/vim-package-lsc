function channel#open(cmd, cb)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return s:channel.open(a:cmd, a:cb)
endfunction

let s:channel = {}
function s:channel.open(cmd, cb) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))

	let l:opt = {}
	let l:opt.mode = 'raw'
	let l:opt.stoponexit = 'term'
	let l:opt.noblock = 1
	let l:opt.cwd = conf#get_server_path()

	let l:opt.out_cb = funcref('self.out_cb', self)
	let l:opt.err_cb = funcref('self.err_cb', self)
	let l:opt.close_cb = funcref('self.close_cb', self)
	let l:opt.exit_cb = funcref('self.exit_cb', self)

	let self.job = job_start(a:cmd, l:opt)
	call log#log_debug('Job start: ' . string(self.job))

	let self.handle = job_getchannel(self.job)
	call log#log_debug('Open channel: ' . string(self.handle))

	let self.id = ch_info(self.handle).id
	let self.callback = a:cb
	let self.buffer = ''

	return deepcopy(self)
endfunction

function s:channel.close() dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call job_stop(self.job, 'term')
	call log#log_debug('Job stop: ' . string(self.job))
	call ch_close(self.handle)
	call log#log_debug('Close channel: ' . string(self))
endfunction

function s:channel.send(data) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:payload = jsonrpc#build_payload(a:data)
	call log#log_debug('Send data to[' . self.id . ']:' . l:payload)
	call ch_sendraw(self.handle, l:payload, {})
endfunction

function s:channel.out_cb(ch, msg) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_debug('Receive data from[' . self.id . ']:' . a:msg)
	let self.buffer = self.buffer . a:msg
	while jsonrpc#contain_header(self.buffer)
		let l:parts = jsonrpc#split_header(self.buffer)
		let l:header = jsonrpc#parse_header(l:parts[0])
		let l:length = l:header['Content-Length']
		let l:content = l:parts[1][0 : l:length]
		if len(l:content) == l:length
			let self.buffer = l:parts[1][l:length : -1]
			call self.callback(l:content)
		else
			break
		endif
	endwhile
endfunction

function s:channel.err_cb(ch, msg) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_debug(a:ch. a:msg)
endfunction

function s:channel.close_cb(ch) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_debug(a:ch)
endfunction

function s:channel.exit_cb(job, status) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_debug(a:job . a:status)
endfunction
