function lib#uri#URI(scheme = '', authority = '', path = '', query = '', fragment = '')
    return s:URI(a:scheme, a:authority, a:path, a:query, a:fragment)
endfunction

function lib#uri#parse(value = '')
    return s:parse(a:value)
endfunction

function lib#uri#format(uri)
    return s:asFormatted(a:uri)
endfunction

function lib#uri#file(path)
    return s:file(a:path)
endfunction

function s:encodeURIComponent(component)
    return lib#urihandling#encodeURIComponent(a:component)
endfunction

function s:decodeURIComponent(component)
    return lib#urihandling#decodeURIComponent(a:component)
endfunction

" https://datatracker.ietf.org/doc/html/rfc3986#section-2.2
const s:gen_delims = ":/?#[]@"
const s:sub_delims = "!$&'()*+,;="
const s:reserved = s:gen_delims . s:sub_delims

" https://datatracker.ietf.org/doc/html/rfc3986#section-2.3 
const s:ALPHA = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
const s:DIGIT = '0123456789'
const s:unreserved = s:ALPHA . s:DIGIT . "-._~"

" https://datatracker.ietf.org/doc/html/rfc3986#appendix-B
const s:regexp = '^\(\([^:/?#]\+\):\)\?\(//\([^/?#]*\)\)\?\([^?#]*\)\(?\([^#]*\)\)\?\(#\(.*\)\)\?'

function s:URI(scheme, authority, path, query, fragment)
	let l:uri = {}
    let l:uri['scheme'] = a:scheme
    let l:uri['authority'] = a:authority
    let l:uri['path'] = s:referenceResolution(a:scheme, a:path)
    let l:uri['query'] = a:query
    let l:uri['fragment'] = a:fragment

    function l:uri.fspath() dict
        return s:uriToFsPath(self)
    endfunction

    function l:uri.with(change) dict
        if empty(a:change)
            return self
        endif
        let l:scheme = get(a:change, 'scheme', v:none)
        let l:authority = get(a:change, 'authority', v:none)
        let l:path = get(a:change, 'path', v:none)
        let l:query = get(a:change, 'query', v:none)
        let l:fragment = get(a:change, 'fragment', v:none)
        if l:scheme == v:none
            let l:scheme = self.scheme
        elseif l:scheme == v:null
            let l:scheme = ''
        endif
        if l:authority == v:none
            let l:authority = self.authority
        elseif l:authority == v:null
            let l:authority = ''
        endif
        if l:path == v:none
            let l:path = self.path
        elseif l:path == v:null
            let l:path = ''
        endif
        if l:query == v:none
            let l:query = self.query
        elseif l:query == v:null
            let l:query = ''
        endif
        if l:fragment == v:none
            let l:fragment = self.fragment
        elseif l:fragment == v:null
            let l:fragment = ''
        endif
        if l:scheme == self.scheme && l:authority == self.authority && l:path == self.path && l:query == self.query && l:fragment == self.fragment
            return self
        endif
        return s:URI(l:scheme, l:authority, l:path, l:query, l:fragment)
    endfunction

    function l:uri.format() dict
        return s:asFormatted(self)
    endfunction

    return l:uri
endfunction

function s:parse(value)
    let l:matched = matchlist(a:value, s:regexp)
    if empty(l:matched)
        return s:URI('', '', '', '', '')
    else
        return s:URI(l:matched[2], s:decodeURIComponent(l:matched[4]), s:decodeURIComponent(l:matched[5]), s:decodeURIComponent(l:matched[7]), s:decodeURIComponent(l:matched[9]))
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
    let l:scheme = a:uri.scheme
    let l:authority = a:uri.authority
    let l:path = a:uri.path
    if !empty(l:authority) && !empty(l:path) && l:scheme == 'file'
        let l:value = '//' . l:authority . l:path
    elseif l:path[0] == '/' && l:path[1] =~ '\a' && l:path[2] == ':'
        let l:value = slice(l:path, 1)
    else
        let l:value = l:path
    endif
    return l:value
endfunction

function s:asFormatted(uri)
    let l:result = ''
    let l:scheme = a:uri.scheme
    let l:authority = a:uri.authority
    let l:path = a:uri.path
    let l:query = a:uri.query
    let l:fragment = a:uri.fragment
    if !empty(l:scheme)
        let l:result = l:result . l:scheme
        let l:result = l:result . ':'
    endif
    if !empty(l:authority) || l:scheme == 'file'
        let l:result = l:result . '//'
    endif
    if !empty(l:authority)
        let l:idx = stridx(l:authority, '@')
        if l:idx != -1
            let l:userinfo = slice(l:authority, 0, l:idx)
            let l:authority = slice(l:authority, l:idx + 1)
            let l:idx = stridx(l:userinfo, ':')
            if l:idx == -1
                let l:result = l:result . s:encodeURIComponentFast(l:userinfo, v:false)
            else
                let l:result = l:result . s:encodeURIComponentFast(slice(l:userinfo, 0, l:idx), v:false)
                let l:result = l:result . ':'
                let l:result = l:result . s:encodeURIComponentFast(slice(l:userinfo, l:idx + 1), v:false)
            endif
            let l:result = l:result . '@'
        endif
        let l:authority = tolower(l:authority)
        let l:idx = stridx(l:authority, ':')
        if l:idx == -1
            let l:result = l:result . s:encodeURIComponentFast(l:authority, v:false)
        else
            let l:result = l:result . s:encodeURIComponentFast(slice(l:authority, 0, l:idx), v:false)
            let l:result = l:result . slice(l:authority, l:idx)
        endif
    endif
    if !empty(l:path)
        let l:result = l:result . s:encodeURIComponentFast(l:path, v:true)
    endif
    if !empty(l:query)
        let l:result = l:result . '?'
        let l:result = l:result . s:encodeURIComponentFast(l:query, v:false)
    endif
    if !empty(l:fragment)
        let l:result = l:result . '#'
        let l:result = l:result . s:encodeURIComponentFast(l:fragment, v:false)
    endif
    return l:result
endfunction

function s:referenceResolution(scheme, path)
    let l:path = a:path
    if a:scheme == 'https' || a:scheme == 'http' || a:scheme == 'file'
        if empty(l:path)
            let l:path = '/'
        elseif l:path[0] != '/'
            let l:path = '/' . l:path
        endif
    endif
    return l:path
endfunction

function s:encodeURIComponentFast(uriComponent, allowSlash)
    let l:result = ''
    let l:nativeEncodePos = -1
    for l:pos in range(strchars(a:uriComponent))
        let l:code = strcharpart(a:uriComponent, l:pos, 1)
        if stridx(s:unreserved, l:code) != -1 || (a:allowSlash && l:code == '/')
            if l:nativeEncodePos != -1
                let l:result = l:result . s:encodeURIComponent(slice(a:uriComponent, l:nativeEncodePos, l:pos))
                let l:nativeEncodePos = -1
            endif
            if !empty(l:result)
                " let l:result = l:result . a:uriComponent[l:pos]
                let l:result = l:result . slice(a:uriComponent, l:pos, l:pos + 1)
            endif
        else
            if empty(l:result)
                let l:result = slice(a:uriComponent, 0, l:pos)
            endif
            if stridx(s:reserved, l:code) != -1
                if l:nativeEncodePos != -1
                    let l:result = l:result . s:encodeURIComponent(slice(a:uriComponent, l:nativeEncodePos, l:pos))
                    let l:nativeEncodePos = -1
                endif
                let l:result = l:result . s:encodeURIComponent(l:code)
            elseif l:nativeEncodePos == -1
                let l:nativeEncodePos = l:pos
            endif
        endif
    endfor
    if l:nativeEncodePos != -1
        let l:result = l:result . s:encodeURIComponent(slice(a:uriComponent, l:nativeEncodePos))
    endif
    if empty(l:result)
        return a:uriComponent
    else
        return l:result
    endif
endfunction

let s:url = 'https://user:password@www.example.com:123/𠮷forum/questions/?𠮷tag=𠮷networking&𠮷order=𠮷newest#𠮷top'
" let s:url = 'https://𠮷top.com'
" let s:u = s:file('/home/tanykazy/repos/vim-package-lsc/𠮷README.md')
let s:u = s:parse(s:url)
echo s:u
echo s:u.format()
