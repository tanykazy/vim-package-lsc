function util#split(str, pattern, max)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:list = split(a:str, a:pattern, v:true)
	if !(len(l:list) > a:max) || a:max < 1
		return l:list
	endif
	let l:first = l:list[0 : a:max - 1]
	let l:second = l:list[a:max : -1]
	if len(l:second) != 0
		let l:first[-1] = join([l:first[-1], join(l:second, a:pattern)], a:pattern)
	endif
	return l:first
endfunction

function util#build_path(...)
	return simplify(join(a:000, '/'))
endfunction

function util#uri2path(uri)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:component = util#uri2components(a:uri)
	let l:path = util#build_path(l:component.authority, l:component.path)
	return util#decode_uri(l:path)
endfunction

let s:exclude_chars = '^[a-zA-Z0-9_.~/-]$'

function util#encode_uri(uri)
	let l:result = ''
    for l:index in range(len(a:uri))
		let l:char = a:uri[l:index]
		if match(l:char, s:exclude_chars) == -1
			let l:result = l:result . util#encode_uri_char(l:char)
        else
            let l:result = l:result . l:char
        endif
    endfor
    return l:result
endfunction

function util#decode_uri(uri)
    return substitute(a:uri, '%\(\x\x\)', {m -> util#decode_uri_char(m[1])}, 'g')
endfunction

function util#encode_uri_char(char)
	let l:code = char2nr(a:char)
    return printf('%%%02X', l:code)
endfunction

function util#decode_uri_char(code)
	let l:hex = str2nr(a:code, 16)
	return printf('%c', l:hex)
endfunction

function util#get_prefix(path)
    return matchstr(a:path, '\(^\w\+::\|^\w\+://\)')
endfunction

function util#uri2components(uri)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:component = {}
	let l:tmp = util#split(a:uri, ':', 2)
	let l:component.scheme = l:tmp[0]
	if stridx(l:tmp[1], '#') != -1
		let l:tmp2 = util#split(l:tmp[1], '#', 2)
		let l:component.fragment = l:tmp2[1]
		let l:tmp[1] = l:tmp2[0]
	endif
	if stridx(l:tmp[1], '?') != -1
		let l:tmp2 = util#split(l:tmp[1], '?', 2)
		let l:component.query = l:tmp2[1]
		let l:tmp[1] = l:tmp2[0]
	endif
	if stridx(l:tmp[1], '//') != -1
		let l:tmp2 = util#split(l:tmp[1], '//', 2)
		let l:tmp2 = util#split(l:tmp2[1], '/', 2)
		let l:component.authority = l:tmp2[0]
		let l:component.path = l:tmp2[1]
	else
		let l:component.path = l:tmp[1]
	endif
	return l:component
endfunction

function util#isSpecialbuffers(buftype)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:specialbuffers = ['quickfix', 'help', 'terminal', 'directory', 'scratch', 'unlisted']
	return util#isContain(l:specialbuffers, a:buftype)
endfunction

function util#getfiletype(buf)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return getbufvar(a:buf, '&filetype')
endfunction

function util#getbuftext(buf)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:lines = getbufline(a:buf, 1, '$')
	let l:text = join(l:lines, "\n")
	return l:text
endfunction

function util#buf2path(buf)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:bufinfolist = util#getbufinfolist(a:buf)
	let l:bufinfo = get(l:bufinfolist, 0, {})
	return l:bufinfo['name']
endfunction

function util#path2buf(path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:bufinfolist = getbufinfo()
	for l:bufinfo in l:bufinfolist
		if a:path == l:bufinfo['name']
			return l:bufinfo['bufnr']
		endif
	endfor
	return v:none
endfunction

function util#getchangedtick(buf)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:bufinfolist = util#getbufinfolist(a:buf)
	let l:bufinfo = get(l:bufinfolist, 0, {})
	return l:bufinfo['changedtick']
endfunction

function util#loadedbufinfolist()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:bufinfolist = getbufinfo({'bufloaded': 1})
	if empty(l:bufinfolist)
        call log#log_error('Not found loaded buffer')
	endif
	return l:bufinfolist
endfunction

function util#getbufinfolist(buf)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:bufinfolist = getbufinfo(a:buf)
	if empty(l:bufinfolist)
        call log#log_error('Not found buffer ' . a:buf)
	endif
	return l:bufinfolist
endfunction

function util#getcwd(buf)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return getcwd(bufwinnr(a:buf))
endfunction

function util#isContain(list, value)
	return !(index(a:list, a:value) == -1)
endfunction

function util#isNone(none)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return (type(a:none) == v:t_none) && (string(a:none) == 'v:none')
endfunction

function util#isNull(none)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return (type(a:none) == v:t_none) && (string(a:none) == 'v:null')
endfunction

function util#read_text_file(path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:file = expand(a:path)
	let l:text = ''
	if !filereadable(l:file)
		call log#log_error('Unreadable file: ' . l:file)
	else
		let l:lines = readfile(l:file)
		let l:text = join(l:lines, '')
	endif
	return l:text
endfunction

function util#parse_json_file(path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:text = util#read_text_file(a:path)
	let l:json = {}
	try
		let l:json = json_decode(l:text)
	catch
		call log#log_error('Decode failure: ' . l:file)
		call log#log_error('Failure cause: ' . v:exception)
	endtry
	return l:json
endfunction
