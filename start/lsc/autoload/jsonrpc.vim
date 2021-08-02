if exists("g:loaded_jsonrpc")
	finish
endif
let g:loaded_jsonrpc = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


" let s:field_separator = "\r\n"
" let s:part_separator = "\r\n\r\n"
" let s:name_value_separator = ": "
" let s:content_length = "Content-Length"
" let s:content_type = "Content-Type"

function jsonrpc#parse_message(message)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:result = {}
	let l:parts = split(a:message, "\r\n\r\n")
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
				endtry
			endif
		endfor
	endif
	return l:result
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

function jsonrpc#build_header(content)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:header = []
	call add(l:header, 'Content-Length: ' . len(a:content))
	call add(l:header, 'Content-Type: application/vscode-jsonrpc; charset=utf-8')
	return join(l:header, "\r\n") . "\r\n"
endfunction

function jsonrpc#serialize_content(params)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:content = json_encode(a:params)
	return l:content
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

let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
