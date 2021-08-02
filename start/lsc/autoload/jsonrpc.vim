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

function s:BuildHeader(content)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return 'Content-Length: ' . len(a:content) . s:rn
endfunction

function s:BuildContent(params)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
