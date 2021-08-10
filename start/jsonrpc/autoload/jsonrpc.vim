" let s:field_separator = "\r\n"
" let s:part_separator = "\r\n\r\n"
" let s:name_value_separator = ": "
" let s:content_length = "Content-Length"
" let s:content_type = "Content-Type"

function jsonrpc#message()
	let l:message = {}
	let l:message['jsonrpc'] = '2.0'
	return l:message
endfunction

function jsonrpc#request_message(id, method, params)
	let l:message = jsonrpc#message()
	let l:message['id'] = a:id
	let l:message['method'] = a:method
	if !util#isNone(a:params)
		let l:message['params'] = a:params
	endif
	return l:message
endfunction

function jsonrpc#response_message(id, result, error)
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
	let l:message = jsonrpc#message()
	let l:message['method'] = a:method
	if !util#isNone(a:params)
		let l:message['params'] = a:params
	endif
	return l:message
endfunction

function jsonrpc#parse_message(message)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:result = {}
	let l:parts = split(a:message, "\r\n\r\n")
	" if !empty(l:parts)
		for l:part in l:parts
			if stridx(l:part, 'Content-Length') == 0 || stridx(l:part, 'Content-Type') == 0
				let l:result['header'] = s:parse_header(l:part)
			else
				let l:result['content'] = l:part
				" try
				" 	let l:result['content'] = s:parse_content(l:part)
				" catch
				" 	let l:result['catch'] = v:exception
				" 	let l:result['error'] = l:part
				" 	call log#log_error('Failed decode: ' . string(l:result))
				" endtry
			endif
		endfor
	" endif
	return l:result
endfunction

function jsonrpc#build_payload(content)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:body = iconv(s:serialize_content(a:content), &encoding, 'utf-8')
	let l:header = iconv(s:make_header(l:body) . "\r\n\r\n", &encoding, 'latin1')
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

function jsonrpc#isNotification(message)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	if jsonrpc#isMessage(a:message)
		return !has_key(a:message, 'id') && has_key(a:message, 'method')
	endif
	return v:false
endfunction

function jsonrpc#parse_header(data)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))

	let l:result = {}

	let l:parts = split(a:data, "\r\n\r\n")

	if !empty(l:parts)
		for l:part in l:parts
			if stridx(l:part, 'Content-Length') == 0 || stridx(l:part, 'Content-Type') == 0
				let l:result['header'] = s:parse_header(l:part)
			else
				try
					let l:result['content'] = s:parse_content(l:part)
				catch
					let l:result['catch'] = v:exception
					let l:result['error'] = l:part
					call log#log_error('Failed decode: ' . string(l:result))
				endtry
			endif
		endfor
	endif
	return l:result

	let l:headers = {}
	let l:fields = split(a:part, "\r\n")
	if !empty(l:fields)
		for l:field in l:fields
			if stridx(l:field, 'Content-Length') == 0
				let l:header = split(l:field, ": ")
				let l:headers[l:header[0]] = l:header[1]
			elseif stridx(l:field, 'Content-Type') == 0
				let l:header = split(l:field, ": ")
				let l:headers[l:header[0]] = l:header[1]
			endif
		endfor
	endif
	return l:headers
endfunction

function s:parse_header(part)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:headers = {}
	let l:fields = split(a:part, "\r\n")
	if !empty(l:fields)
		for l:field in l:fields
			if stridx(l:field, 'Content-Length') == 0
				let l:header = split(l:field, ": ")
				let l:headers[l:header[0]] = l:header[1]
			elseif stridx(l:field, 'Content-Type') == 0
				let l:header = split(l:field, ": ")
				let l:headers[l:header[0]] = l:header[1]
			endif
		endfor
	endif
	return l:headers
endfunction

function s:parse_content(part)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:content = json_decode(a:part)
	return l:content
endfunction

function s:make_header(body)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:length = 'Content-Length: ' . len(a:body)
	let l:type = 'Content-Type: application/vscode-jsonrpc; charset=utf-8'
	return l:length . "\r\n" . l:type
endfunction

function s:serialize_content(params)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:data = json_encode(a:params)
	return l:data
endfunction
