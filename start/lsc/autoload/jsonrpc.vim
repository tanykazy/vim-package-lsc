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

function jsonrpc#parse_header(message)
	let l:parts = split(a:message, "\r\n\r\n")
	let l:headers = {}
	if !empty(l:parts)
		for l:part in l:parts
			let l:fields = split(l:part, "\r\n")
			if !empty(l:fields)
				for l:field in l:fields
					" let l:first = get(l:field, 0, '')
					if stridx(l:field, 'Content-Length') == 0
						let l:header= split(l:field, ": ")
						let l:headers[l:header[0]] = l:header[1]
					endif
					if stridx(l:field, 'Content-Type') == 0
						let l:header= split(l:field, ": ")
						let l:headers[l:header[0]] = l:header[1]
					endif
				endfor
			endif
		endfor
	endif
	return l:headers
endfunction





let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
