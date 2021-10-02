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

function s:format() dict
    return s:asFormatted(self)
endfunction

function s:fspath() dict
    return s:uriToFsPath(self)
endfunction

function s:URI(scheme, authority, path, query, fragment)
	let l:uri = deepcopy(s:uri_component)
    let l:uri['scheme'] = a:scheme
    let l:uri['authority'] = a:authority
    let l:uri['path'] = a:path
    let l:uri['query'] = a:query
    let l:uri['fragment'] = a:fragment
    let l:uri['format'] = funcref('s:format', l:uri)
    let l:uri['fspath'] = funcref('s:fspath', l:uri)
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

function s:uriToFsPath(uri)
    let l:value = ''
    if !empty(a:uri.authority) && !empty(a:uri.path) && a:uri.scheme == 'file'
        let l:value = '//' . a:uri.authority . a:uri.path
    elseif a:uri.path[0] == '/' && a:uri.path[1] =~ '\a' && a:uri.path[2] == ':'
        let l:value = slice(a:uri.path, 1)
    else
        let l:value = a:uri.path
    endif
    return l:value
endfunction

function s:asFormatted(uri)
    let l:result = ''
    if !empty(a:uri.scheme)
        let l:result = l:result . a:uri.scheme
        let l:result = l:result . ':'
    endif
    if !empty(a:uri.authority) || a:uri.scheme == 'file'
        let l:result = l:result . '//'
    endif
    if !empty(a:uri.authority)
        let l:idx = stridx(a:uri.authority, '@')
        if l:idx != -1
            let l:userinfo = slice(a:uri.authority, 0, l:idx)
            let a:uri.authority = slice(a:uri.authority, l:idx + 1)
            let l:idx = stridx(l:userinfo, ':')
            if l:idx == -1
                let l:result = l:result . lib#urihandling#encodeURIComponent(l:userinfo)
            else
                let l:result = l:result . lib#urihandling#encodeURIComponent(slice(l:userinfo, 0, l:idx))
                let l:result = l:result . ':'
                let l:result = l:result . lib#urihandling#encodeURIComponent(slice(l:userinfo, l:idx + 1))
            endif
            let l:result = l:result . '@'
        endif
        let a:uri.authority = tolower(a:uri.authority)
        let l:idx = stridx(a:uri.authority, ':')
        if l:idx == -1
            let l:result = l:result . lib#urihandling#encodeURIComponent(a:uri.authority)
        else
            let l:result = l:result . lib#urihandling#encodeURIComponent(slice(a:uri.authority, 0, l:idx))
            let l:result = l:result . slice(a:uri.authority, l:idx)
        endif
    endif
    if !empty(a:uri.path)
        let l:result = l:result . lib#urihandling#encodeURI(a:uri.path)
    endif
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

let s:url = 'https://user:password@www.example.com:123/forum/questions/?tag=networking&order=newest#top'
" let s:u = s:file('/home/tanykazy/repos/vim-package-lsc/README.md')
let s:u = s:parse(s:url)
echo s:u
echo s:u.format()
