function lib#uri#URI(scheme = '', authority = '', path = '', query = '', fragment = '')
    return s:URI(a:scheme, a:authority, a:path, a:query, a:fragment)
endfunction

function lib#uri#parse(value = '')
    return s:parse(a:value)
endfunction

function lib#uri#format(uri)
    return s:format(a:uri)
endfunction

let s:uri = {}
let s:uri['scheme'] = ''
let s:uri['authority'] = ''
let s:uri['path'] = ''
let s:uri['query'] = ''
let s:uri['fragment'] = ''
function s:uri.format() dict
    return s:format(self)
endfunction

function s:URI(scheme, authority, path, query, fragment)
	let l:uri = {}
    let l:uri['scheme'] = a:scheme
    let l:uri['authority'] = a:authority
    let l:uri['path'] = a:path
    let l:uri['query'] = a:query
    let l:uri['fragment'] = a:fragment
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
