const s:terminater = "\r\n"
const s:separator = ": "
const s:content_length = "Content-Length"
const s:content_type = "Content-Type"
const s:encoding = 'utf-8'

function jsonrpc#message()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:message = {}
	let l:message['jsonrpc'] = '2.0'
	return l:message
endfunction

function jsonrpc#request_message(id, method, params)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:message = jsonrpc#message()
	let l:message['id'] = a:id
	let l:message['method'] = a:method
	if !util#isNone(a:params)
		let l:message['params'] = a:params
	endif
	return l:message
endfunction

function jsonrpc#response_message(id, result, error)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:message = jsonrpc#message()
	let l:message['id'] = a:id
	if !util#isNone(a:result)
		let l:message['result'] = a:result
	endif
	if !util#isNone(a:error)
		let l:message['error'] = a:error
	endif
	return l:message
endfunction

function jsonrpc#notification_message(method, params)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:message = jsonrpc#message()
	let l:message['method'] = a:method
	if !util#isNone(a:params)
		let l:message['params'] = a:params
	endif
	return l:message
endfunction

function jsonrpc#build_payload(content)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:body = iconv(s:serialize_content(a:content), &encoding, s:encoding)
	let l:header = iconv(s:make_header(l:body) . s:terminater, &encoding, 'latin1')
	return l:header . l:body
endfunction

function jsonrpc#isMessage(message)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return has_key(a:message, 'jsonrpc')
endfunction

function jsonrpc#isRequest(message)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	if jsonrpc#isMessage(a:message)
		return has_key(a:message, 'id') && has_key(a:message, 'method')
	endif
	return v:false
endfunction

function jsonrpc#isResponse(message)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	if jsonrpc#isMessage(a:message)
		return has_key(a:message, 'id') && !has_key(a:message, 'method')
	endif
	return v:false
endfunction

function jsonrpc#isResponseError(message)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	if jsonrpc#isResponse(a:message)
		return has_key(a:message, 'error')
	endif
	return v:false
endfunction

function jsonrpc#isNotification(message)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	if jsonrpc#isMessage(a:message)
		return !has_key(a:message, 'id') && has_key(a:message, 'method')
	endif
	return v:false
endfunction

function jsonrpc#contain_header(data)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return stridx(a:data, s:terminater . s:terminater) != -1
endfunction

function jsonrpc#split_header(data)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return util#split(a:data, s:terminater . s:terminater, 2)
endfunction

function jsonrpc#parse_header(part)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:headers = {}
	let l:fields = split(a:part, s:terminater)
	if !empty(l:fields)
		for l:field in l:fields
			if stridx(l:field, s:content_length) == 0
				let l:header = split(l:field, s:separator)
				let l:headers[l:header[0]] = l:header[1]
			elseif stridx(l:field, s:content_type) == 0
				let l:header = split(l:field, s:separator)
				let l:headers[l:header[0]] = l:header[1]
			endif
		endfor
	endif
	return l:headers
endfunction

function jsonrpc#parse_content(part)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:content = {}
	try
		let l:content = json_decode(a:part)
	catch
		call log#log_error('Failed decode: ' . a:part)
		call log#log_error(v:exception)
	endtry
	return l:content
endfunction

function s:make_header(body)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:length = s:content_length . s:separator . len(a:body)
	let l:type = s:content_type . s:separator . 'application/vscode-jsonrpc; charset=' . s:encoding
	return l:length . s:terminater . l:type . s:terminater
endfunction

function s:serialize_content(params)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	try
		let l:data = json_encode(a:params)
	catch
		call log#log_error('Failed encode: ' . a:params)
		call log#log_error(v:exception)
	endtry
	return l:data
endfunction
