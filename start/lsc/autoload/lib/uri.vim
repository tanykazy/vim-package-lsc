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

let s:uri = {}

let s:uri['scheme'] = ''
let s:uri['authority'] = ''
let s:uri['path'] = ''
let s:uri['query'] = ''
let s:uri['fragment'] = ''

function s:uri.format() dict
    return s:format(self)
endfunction

function s:uri.fspath() dict
    return s:fspath(self)
endfunction

function s:URI(scheme, authority, path, query, fragment)
	let l:uri = deepcopy(s:uri)
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

function s:file(path)
    return s:URI('file', '', a:path, '', '')
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

" const s:exclude_chars = '^[a-zA-Z0-9_.~/-]$'

" function util#encode_uri(uri)
" 	let l:result = ''
"     for l:index in range(len(a:uri))
" 		let l:char = a:uri[l:index]
" 		if match(l:char, s:exclude_chars) == -1
" 			let l:result = l:result . util#encode_uri_char(l:char)
"         else
"             let l:result = l:result . l:char
"         endif
"     endfor
"     return l:result
" endfunction

" function util#decode_uri(uri)
"     return substitute(a:uri, '%\(\x\x\)', {m -> util#decode_uri_char(m[1])}, 'g')
" endfunction

" function util#encode_uri_char(char)
" 	let l:code = char2nr(a:char)
"     return printf('%%%02X', l:code)
" endfunction

" function util#decode_uri_char(code)
" 	let l:hex = str2nr(a:code, 16)
" 	return printf('%c', l:hex)
" endfunction

const s:uriAlpha="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
const s:DecimalDigit = "0123456789"
const s:uriMark = "-_.!~*'()"
const s:uriUnescaped = s:uriAlpha . s:DecimalDigit . s:uriMark

function s:encodeURIComponent(component)
    let l:componentString = string(a:component)
    let l:unescapedURIComponentSet = 
    return s:Encode(l:componentString, )
endfunction

function s:CodePointAt(string, position)
    let l:cp = char2nr(strcharpart(a:string, a:position, 1))
    return {'CodePoint': l:cp, 'CodeUnitCount': 1, 'IsUnpairedSurrogate': v:false}

    " " let l:size = strchars(a:string)
    " let l:size = strlen(a:string)
    " " let l:size = len(a:string)
    " echo [l:size, a:position]
    " " let l:first = char2nr(strcharpart(a:string, a:position, 1))
    " echo strpart(a:string, a:position, 1)
    " " echo strcharpart(a:string, a:position, 1)
    " let l:first = char2nr(strpart(a:string, a:position, 1))
    " " let l:first = char2nr(strcharpart(a:string, a:position, 1))
    " " let l:first = char2nr(a:string[a:position])
    " let l:cp = l:first
    " let l:cp = printf('%#x', l:cp)
    " if !(0xD800 <= l:first && l:first >= 0xDBFF) || !(0xDC00 <= l:first && l:first >= 0xDFFF)
    "     echo 'a'
    "     return {'CodePoint': l:cp, 'CodeUnitCount': 1, 'IsUnpairedSurrogate': v:false}
    " endif
    " if (0xDC00 <= l:first && l:first >= 0xDFFF) || ((a:position + 1) == l:size)
    "     echo 'b'
    "     return {'CodePoint': l:cp, 'CodeUnitCount': 1, 'IsUnpairedSurrogate': v:true}
    " endif
    " " let l:second = char2nr(strcharpart(a:string, a:position + 1, 1))
    " let l:second = char2nr(strpart(a:string, a:position + 1))
    " if !(0xDC00 <= l:second && l:second >= 0xDFFF)
    "     echo 'c'
    "     return {'CodePoint': l:cp, 'CodeUnitCount': 1, 'IsUnpairedSurrogate': v:true}
    " endif
    " let l:cp = s:UTF16SurrogatePairToCodePoint(l:first, l:second)
    " let l:cp = printf('%#x', l:cp)
    "     echo 'd'
    " return {'CodePoint': l:cp, 'CodeUnitCount': 2, 'IsUnpairedSurrogate': v:false}
endfunction

function s:Encode(string, unescapedSet)
    let l:strLen = strchars(a:string)
    let l:R = ''
    let l:k = 0
    while v:true
        if l:k == l:strLen
            return l:R
        endif
        let l:C = strcharpart(a:string, l:k, 1)
        echo l:C
        if stridx(a:unescapedSet, l:C) != -1
            let l:k = l:k + 1
            let l:R = l:R . l:C
        else
            let l:cp = s:CodePointAt(a:string, l:k)
            if l:cp.IsUnpairedSurrogate == v:true
                throw 'URIError'
            endif
            let l:k = l:k + l:cp.CodeUnitCount
            let l:Octets = [l:cp.CodePoint]
            echo l:Octets
            " for each element octet of Octets
        endif
    endwhile
endfunction

function s:UTF16EncodeCodePoint(cp)
    if a:cp <= 0xFFFF
        return printf('%X', a:cp)
    endif
    let l:cu1 = float2nr(floor((a:cp - 0x10000) / 0x400) + 0xD800)
    let l:cu2 = ((a:cp - 0x10000) % 0x400) + 0xDC00
    return printf('%X%X', l:cu1, l:cu2)
endfunction

function s:UTF16SurrogatePairToCodePoint(lead, trail)
    let l:cp = (a:lead - 0xD800) * 0x400 + (a:trail - 0xDC00) + 0x10000
    return l:cp
endfunction

let s:test = 'aあ𠮷b'
" let s:test = iconv(s:test, 'utf-8', 'utf-16')
call s:Encode(s:test, s:uriUnescaped)

" echo s:CodePointAt(s:test, 0)
" echo s:CodePointAt(s:test, 1)
" echo s:CodePointAt(s:test, 2)
" echo s:CodePointAt(s:test, 3)
" echo s:CodePointAt(s:test, 4)
" echo s:CodePointAt(s:test, 5)
" echo s:CodePointAt(s:test, 6)
