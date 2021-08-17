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

function util#uri2path(uri)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:tmp = split(a:uri, '://', 1)
	let l:scheme = get(l:tmp, 0, '')
	let l:path = get(l:tmp, 1, '')
	return l:path
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
