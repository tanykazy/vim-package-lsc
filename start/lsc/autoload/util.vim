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

function util#relativize_path(path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return fnamemodify(a:path, ':~:.')
endfunction

function util#build_path(...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
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
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
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
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    return substitute(a:uri, '%\(\x\x\)', {m -> util#decode_uri_char(m[1])}, 'g')
endfunction

function util#encode_uri_char(char)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:code = char2nr(a:char)
    return printf('%%%02X', l:code)
endfunction

function util#decode_uri_char(code)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:hex = str2nr(a:code, 16)
	return printf('%c', l:hex)
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
		" call log#log_error(string(l:tmp2))
		" let l:tmp2 = util#split(l:tmp2[1], '/', 2)
		" let l:component.authority = l:tmp2[0]
		" let l:component.path = l:tmp2[1]
		if stridx(l:tmp2[1], '/') != -1
			let l:tmp3 = util#split(l:tmp2[1], '/', 2)
			let l:component.authority = l:tmp3[0]
			let l:component.path = l:tmp3[1]
		endif
	else
		let l:component.path = l:tmp[1]
	endif
	return l:component
endfunction

function util#lsp_kind2vim_kind(kind)
	if a:kind == 1
		return ''
	elseif a:kind == 2
		return 'f'
	elseif a:kind == 3
		return 'f'
	elseif a:kind == 4
		return 'f'
	elseif a:kind == 5
		return 'm'
	elseif a:kind == 6
		return 'v'
	elseif a:kind == 7
		return 't'
	elseif a:kind == 8
		return 't'
	elseif a:kind == 9
		return 't'
	elseif a:kind == 10
		return 'm'
	elseif a:kind == 11
		return 't'
	elseif a:kind == 12
		return 'v'
	elseif a:kind == 13
		return 't'
	elseif a:kind == 14
		return 't'
	elseif a:kind == 15
		return 'd'
	elseif a:kind == 16
		return 'd'
	elseif a:kind == 17
		return 'd'
	elseif a:kind == 18
		return ''
	elseif a:kind == 19
		return 'd'
	elseif a:kind == 20
		return 'm'
	elseif a:kind == 21
		return 'v'
	elseif a:kind == 22
		return 't'
	elseif a:kind == 23
		return 't'
	elseif a:kind == 24
		return 'd'
	elseif a:kind == 25
		return ''
	endif
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

function util#getbuftype(buf)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return getbufvar(a:buf, '&buftype')
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

function util#listedbufinfolist()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:bufinfolist = getbufinfo({'buflisted': 1})
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

function util#wait(condition, ...) " timeout
	let l:timeout = get(a:, 1, -1) / 1000.0
	let l:start = reltime()
	let l:progress = reltime(l:start)
	try
		while l:timeout < 0 || reltimefloat(l:progress) < l:timeout
			if call(a:condition, [])
				return 0
			endif
			call util#sleep(10)
			let l:progress = reltime(l:start)
		endwhile
		return -1
	catch /^Vim:Interrupt$/
		return -2
	endtry
endfunction

function util#sleep(ms)
	execute 'sleep' a:ms . 'm'
endfunction

function util#set_autocmd_buflocal(buf, event, cmd)
	execute 'autocmd' a:event '<buffer=' . a:buf . '>' a:cmd
endfunction
