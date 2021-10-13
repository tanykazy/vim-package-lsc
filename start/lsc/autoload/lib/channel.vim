const s:has_channel = has('channel')
const s:has_job = has('job')

function lib#channel#log(...)
	call ch_log(join(a:000, '\n'))
endfunction

function lib#channel#logfile(logfile)
	call ch_logfile(a:logfile, 'a')
endfunction

function lib#channel#open(cmd, cwd, cb)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:ch = s:channel.new()

	let l:opt = {}
	let l:opt.mode = 'raw'
	let l:opt.stoponexit = 'term'
	let l:opt.noblock = 1
	let l:opt.cwd = a:cwd

	let l:opt.out_cb = funcref('l:ch.out_cb', l:ch)
	let l:opt.err_cb = funcref('l:ch.err_cb', l:ch)
	let l:opt.close_cb = funcref('l:ch.close_cb', l:ch)
	let l:opt.exit_cb = funcref('l:ch.exit_cb', l:ch)

	let l:ch.job = job_start(a:cmd, l:opt)
	call log#log_debug('Job start: ' . string(l:ch.job))

	let l:ch.handle = job_getchannel(l:ch.job)
	call log#log_debug('Open channel: ' . string(l:ch.handle))

	let l:ch.id = ch_info(l:ch.handle).id
	let l:ch.callback = a:cb
	let l:ch.buffer = ''

	return l:ch
endfunction

let s:channel = {}
function s:channel.new() dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
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
	call log#log_trace('Send data to[' . self.id . ']:' . l:payload)
	call ch_sendraw(self.handle, l:payload, {})
endfunction

function s:channel.out_cb(ch, msg) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_trace('Receive data from[' . self.id . ']:' . a:msg)
	let self.buffer = self.buffer . a:msg
	while jsonrpc#contain_header(self.buffer)
		let l:parts = jsonrpc#split_header(self.buffer)
		let l:header = jsonrpc#parse_header(l:parts[0])
		let l:length = l:header['Content-Length']
		let l:content = l:parts[1][0 : l:length - 1]
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
	call log#log_debug('error callback ' . a:ch . a:msg)
endfunction

function s:channel.close_cb(ch) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_debug('close callback ' . a:ch)
endfunction

function s:channel.exit_cb(job, status) dict
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_debug('exit callback ' . a:job . a:status)
endfunction
