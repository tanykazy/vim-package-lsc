function lib#uri#URI(scheme = '', authority = '', path = '', query = '', fragment = '')
    return s:URI(a:scheme, a:authority, a:path, a:query, a:fragment)
endfunction

function lib#uri#parse(value = '')
    return s:parse(a:value)
endfunction

function lib#uri#format(uri)
    return s:format(a:uri)
endfunction

function lib#uri#file(path)
    return s:file(a:path)
endfunction

let s:uri_component = {}
let s:uri_component['scheme'] = ''
let s:uri_component['authority'] = ''
let s:uri_component['path'] = ''
let s:uri_component['query'] = ''
let s:uri_component['fragment'] = ''

function s:URI(scheme, authority, path, query, fragment)
	let l:uri = deepcopy(s:uri_component)
    let l:uri['scheme'] = a:scheme
    let l:uri['authority'] = a:authority
    let l:uri['path'] = a:path
    let l:uri['query'] = a:query
    let l:uri['fragment'] = a:fragment

    function l:uri.format() dict
        return s:format(self)
    endfunction

    function l:uri.fspath() dict
        return s:fspath(self)
    endfunction

    return l:uri
endfunction

" https://datatracker.ietf.org/doc/html/rfc3986#appendix-B
const s:regexp = '^\(\([^:/?#]\+\):\)\?\(//\([^/?#]*\)\)\?\([^?#]*\)\(?\([^#]*\)\)\?\(#\(.*\)\)\?'

function s:parse(value)
    let l:matched = matchlist(a:value, s:regexp)
    if empty(l:matched)
        return s:URI('', '', '', '', '')
    else
        return s:URI(l:matched[2], l:matched[4], l:matched[5], l:matched[7], l:matched[9])
    endif
endfunction

function s:format(uri)
    let l:result = ''
    if !empty(a:uri.scheme)
        let l:result .= a:uri.scheme
        let l:result .= ':'
    endif
    let l:result .= '//'
    if !empty(a:uri.authority)
        let l:result .= a:uri.authority
    endif
    let l:result .= a:uri.path
    if !empty(a:uri.query)
        let l:result .= '?'
        let l:result .= a:uri.query
    endif
    if !empty(a:uri.fragment)
        let l:result .= '#'
        let l:result .= a:uri.fragment
    endif
    return l:result
endfunction

function s:file(path)
    let l:path = a:path
    let l:authority = ''
    if l:path[0] == '/' && l:path[1] == '/'
        let l:idx = stridx(l:path, '/', 2)
        if l:idx == -1
            let l:authority = slice(l:path, 2)
            let l:path = '/'
        else
            let l:authority = slice(l:path, 2, l:idx)
            let l:path = slice(l:path, l:idx) ?? '/'
        endif
    endif
    return s:URI('file', l:authority, l:path, '', '')
endfunction

function s:fspath(uri)
    let l:result = ''
    if !empty(a:uri.authority) && !empty(a:uri.path) && a:uri.scheme == 'file'
        let l:result = '//' . a:uri.authority . a:uri.path
    else
        let l:result = a:uri.path
    endif
    return l:result
endfunction
