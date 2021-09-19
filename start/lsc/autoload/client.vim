let s:server_list = {}

function client#get_running_server()
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    return keys(s:server_list)
endfunction

function client#start(lang, buf)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if !setting#isSupport(a:lang)
        return
    endif
    if has_key(s:server_list, a:lang)
        return
    endif
    let l:server = s:start_server(a:lang)
    let l:cwd = util#getcwd(a:buf)
    let l:workspaceFolder = lsp#WorkspaceFolder(l:cwd, l:cwd)
    let l:params = lsp#InitializeParams(l:server['options'], [l:workspaceFolder], v:none)
    call s:send_request(l:server, 'initialize', l:params)
endfunction

function client#stop(filetype)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if util#isNone(a:filetype)
        for l:server in values(s:server_list)
            call s:send_request(l:server, 'shutdown', v:none)
        endfor
        call util#wait({-> empty(client#get_running_server())})
    else
        if has_key(s:server_list, a:filetype)
            let l:server = s:server_list[a:filetype]
            call s:send_request(l:server, 'shutdown', v:none)
            call util#wait({-> !util#isContain(client#get_running_server(), a:filetype)})
        endif
    endif
endfunction

function client#document_open(buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:filetype = util#getfiletype(a:buf)
    if !has_key(s:server_list, l:filetype)
        return client#start(l:filetype, a:buf)
    endif
    let l:server = s:server_list[l:filetype]
    if util#isContain(l:server['files'], a:path)
        return
    endif
    let l:text = util#getbuftext(a:buf)
    let l:changedtick = util#getchangedtick(a:buf)
    let l:params = lsp#DidOpenTextDocumentParams(util#encode_uri(a:path), util#getfiletype(a:buf), l:changedtick, l:text)
    call add(l:server['files'], a:path)
    call s:send_notification(l:server, 'textDocument/didOpen', l:params)

    call complete#set_completefunc(a:buf)
    call textprop#setup_proptypes(a:buf)
    call cmd#setup_buffercmd(a:buf)
endfunction

function client#document_close(buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:filetype = util#getfiletype(a:buf)
    if !has_key(s:server_list, l:filetype)
        return
    endif
    let l:server = s:server_list[l:filetype]
    if !util#isContain(l:server['files'], a:path)
        return
    endif
    let l:params = lsp#DidCloseTextDocumentParams(util#encode_uri(a:path))
    call s:send_notification(l:server, 'textDocument/didClose', l:params)
    call filter(l:server['files'], {idx, val -> val != a:path})
endfunction

function client#document_change(buf, path, pos, char)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:filetype = util#getfiletype(a:buf)
    if !has_key(s:server_list, l:filetype)
        return
    endif
    let l:server = s:server_list[l:filetype]
    if !util#isContain(l:server['files'], a:path)
        return
    endif
    if !empty(a:char)
        let l:line = a:pos[1] - 1
        let l:character = a:pos[2] - 1
        let l:position = lsp#Position(l:line, l:character)
        let l:range = lsp#Range(l:position, l:position)
        let l:change = lsp#TextDocumentContentChangeEvent(l:range, a:char)
    else
        let l:text = util#getbuftext(a:buf)
        let l:change = lsp#TextDocumentContentChangeEvent(v:none, l:text)
    endif
    let l:version = util#getchangedtick(a:buf)
    let l:params = lsp#DidChangeTextDocumentParams(util#encode_uri(a:path), l:version, [l:change])
    call s:send_notification(l:server, 'textDocument/didChange', l:params)
endfunction

function client#document_save(buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:filetype = util#getfiletype(a:buf)
    if !has_key(s:server_list, l:filetype)
        return
    endif
    let l:server = s:server_list[l:filetype]
    if !util#isContain(l:server['files'], a:path)
        return
    endif
    let l:text = util#getbuftext(a:buf)
    let l:params = lsp#DidSaveTextDocumentParams(util#encode_uri(a:path), l:text)
    call s:send_notification(l:server, 'textDocument/didSave', l:params)
endfunction

function client#document_hover(buf, pos)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:filetype = util#getfiletype(a:buf)
    if !has_key(s:server_list, l:filetype)
        return
    endif
    let l:server = s:server_list[l:filetype]
    let l:path = util#buf2path(a:buf)
    if !util#isContain(l:server['files'], l:path)
        return
    endif
    let l:lnum = a:pos[1]
    let l:col = a:pos[2]
    let l:position = lsp#Position(l:lnum - 1, l:col - 1)
    let l:params = lsp#HoverParams(util#encode_uri(l:path), l:position, v:none)
    call s:send_request(l:server, 'textDocument/hover', l:params)
endfunction

function client#goto_definition(buf, pos, preview)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:filetype = util#getfiletype(a:buf)
    if !has_key(s:server_list, l:filetype)
        return
    endif
    let l:server = s:server_list[l:filetype]
    let l:path = util#buf2path(a:buf)
    if !util#isContain(l:server['files'], l:path)
        return
    endif
    let l:server.preview = a:preview
    let l:lnum = a:pos[1]
    let l:col = a:pos[2]
    let l:position = lsp#Position(l:lnum - 1, l:col - 1)
    let l:params = lsp#DefinitionParams(util#encode_uri(l:path), l:position, v:none, v:none)
    call s:send_request(l:server, 'textDocument/definition', l:params)
endfunction

function client#find_references(buf, pos, preview)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:filetype = util#getfiletype(a:buf)
    if !has_key(s:server_list, l:filetype)
        return
    endif
    let l:server = s:server_list[l:filetype]
    let l:path = util#buf2path(a:buf)
    if !util#isContain(l:server['files'], l:path)
        return
    endif
    let l:server.preview = a:preview
    let l:lnum = a:pos[1]
    let l:col = a:pos[2]
    let l:position = lsp#Position(l:lnum - 1, l:col - 1)
    let l:context = lsp#ReferenceContext(v:false)
    let l:params = lsp#ReferenceParams(util#encode_uri(l:path), l:position, l:context, v:none, v:none)
    call s:send_request(l:server, 'textDocument/references', l:params)
endfunction

function client#goto_implementation(buf, pos, preview)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:filetype = util#getfiletype(a:buf)
    if !has_key(s:server_list, l:filetype)
        return
    endif
    let l:server = s:server_list[l:filetype]
    let l:path = util#buf2path(a:buf)
    if !util#isContain(l:server['files'], l:path)
        return
    endif
    let l:server.preview = a:preview
    let l:lnum = a:pos[1]
    let l:col = a:pos[2]
    let l:position = lsp#Position(l:lnum - 1, l:col - 1)
    let l:params = lsp#ImplementationParams(util#encode_uri(l:path), l:position, v:none, v:none)
    call s:send_request(l:server, 'textDocument/implementation', l:params)
endfunction

function client#code_lens(buf)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:filetype = util#getfiletype(a:buf)
    if !has_key(s:server_list, l:filetype)
        return
    endif
    let l:server = s:server_list[l:filetype]
    let l:path = util#buf2path(a:buf)
    if !util#isContain(l:server['files'], l:path)
        return
    endif
    let l:params = lsp#CodeLensParams(util#encode_uri(l:path), v:none, v:none)
    call s:send_request(l:server, 'textDocument/codeLens', l:params)
endfunction

function client#document_completion(buf, path, pos, char)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:filetype = util#getfiletype(a:buf)
    if !has_key(s:server_list, l:filetype)
        return v:false
    endif
    let l:server = s:server_list[l:filetype]
    if util#isContain(l:server['capabilities']['completionProvider']['triggerCharacters'], a:char)
        let l:kind = lsp#CompletionTriggerKind().TriggerCharacter
    else
        let l:kind = lsp#CompletionTriggerKind().Invoked
    endif
    if l:kind != lsp#CompletionTriggerKind().TriggerCharacter
        if !util#isNone(a:char)
            return v:false
        endif
    endif
    let l:line = a:pos[1] - 1
    let l:character = a:pos[2] - 1
    let l:position = lsp#Position(l:line, l:character)
    let l:context = lsp#CompletionContext(l:kind, a:char)
    let l:params = lsp#CompletionParams(l:context, util#encode_uri(a:path), l:position, v:none, v:none)
    call s:send_request(l:server, 'textDocument/completion', l:params)
    return v:true
endfunction

function client#code_action()
endfunction

function client#document_symbol(buf)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:filetype = util#getfiletype(a:buf)
    if !has_key(s:server_list, l:filetype)
        return v:false
    endif
    let l:server = s:server_list[l:filetype]
    let l:path = util#buf2path(a:buf)
    " if !util#isContain(l:server['files'], l:path)
    "     return
    " endif
    let l:params = lsp#DocumentSymbolParams(util#encode_uri(l:path), v:none, v:none)
    call s:send_request(l:server, 'textDocument/documentSymbol', l:params)
endfunction

function client#completion_resolve(buf, item)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:filetype = util#getfiletype(a:buf)
    if !has_key(s:server_list, l:filetype)
        return v:false
    endif
    let l:server = s:server_list[l:filetype]
    call s:send_request(l:server, 'completionItem/resolve', a:item)
endfunction

let s:fn = {}
function s:fn.initialize(server, message, ...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if has_key(a:message, 'error')
        call s:print_error(a:message['error'])
        call s:send_request(a:server, 'shutdown', v:none)
        return
    endif
    let a:server['capabilities'] = get(a:message['result'], 'capabilities', {})
    let a:server['serverInfo'] = get(a:message['result'], 'serverInfo', {})
    call log#log_debug('Update server info ' . string(a:server))

    " let l:serverCapabilities = a:server['capabilities']
    " call log#log_error(string(l:serverCapabilities))
    " let l:completionProvider = l:serverCapabilities['completionProvider']
    " call log#log_error(string(l:completionProvider))
    " let l:triggerCharacters = l:completionProvider['triggerCharacters']
    " call log#log_error(string(l:triggerCharacters))

    " for l:triggerCharacter in l:triggerCharacters
        " call log#log_error(l:triggerCharacter)

        " let maplocalleader = l:triggerCharacter
        " call log#log_error(maplocalleader)
        " call s:defmap(l:triggerCharacter)
        " imap <buffer><nowait> <LocalLeader>a <Esc>:<C-u>call dialog#info('trigger characters!')<CR>
    " endfor

    let l:params = lsp#InitializedParams()
    call s:send_notification(a:server, 'initialized', l:params)

    let l:bufinfolist = util#loadedbufinfolist()
    for l:bufinfo in l:bufinfolist
        let l:buftype = util#getbuftype(l:bufinfo.bufnr)
        if !util#isSpecialbuffers(l:buftype)
            call client#document_open(l:bufinfo['bufnr'], l:bufinfo['name'])
            " call listener_add(funcref('s:bufchange_listener'), l:bufnr)
            " call autocmd#add_event_listener()
        endif
    endfor
endfunction

function s:fn.shutdown(server, message, ...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call s:send_notification(a:server, 'exit', v:none)
    call a:server.stop()
    call remove(s:server_list, a:server.lang)
endfunction

function s:fn.textDocument_publishDiagnostics(server, message, ...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:location = []
    let l:file = util#uri2path(a:message['params']['uri'])
    let l:buf = util#path2buf(l:file)
    " let l:winid = bufwinid(l:buf)
    call textprop#clear(l:buf)
    let l:diagnostics = a:message['params']['diagnostics']

    " Save diagnostics
    call setbufvar(l:buf, 'diagnostics', l:diagnostics)

    for l:diagnostic in l:diagnostics
        let l:lnum = l:diagnostic['range']['start']['line']
        let l:col = l:diagnostic['range']['start']['character']
        let l:nr = get(l:diagnostic, 'code', v:none)
        let l:text = l:diagnostic['message']
        let l:type = get(l:diagnostic, 'severity', v:none)
        call add(l:location, quickfix#location(l:file, l:lnum, l:col, l:nr, l:text, l:type))
        let l:start = l:diagnostic['range']['start']
        let l:end = l:diagnostic['range']['end']
        call textprop#add(l:buf, l:start, l:end, l:type)
    endfor
    call quickfix#set_quickfix(l:location, l:file)
endfunction

function s:fn.textDocument_hover(server, message, ...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if util#isNull(a:message.result)
        return
    endif
    let l:contents = a:message.result.contents
    if empty(l:contents)
        return
    endif
    let l:values = []
    let l:title = v:none
    if type(l:contents) != v:t_list
        " MarkedString
        if type(l:contents) == v:t_string
            let l:contents = [l:contents]
        else
            if has_key(l:contents, 'language') && has_key(l:contents, 'value')
                let l:contents = [l:contents]
            endif
        endif
    endif
    if type(l:contents) == v:t_list
        " MarkedString[]
        for l:content in l:contents
            if type(l:content) == v:t_string
                let l:values += [l:content]
            else
                if has_key(l:content, 'language') && has_key(l:content, 'value')
                    let l:values += [l:content.language . ': ' . l:content.value]
                endif
            endif
        endfor
    elseif type(l:contents) == v:t_dict 
        " MarkupContent
        if has_key(l:contents, 'kind')
            call log#log_debug('MarkupKind: ' . l:contents.kind)
        endif
        if has_key(l:contents, 'value')
            let l:values += [l:contents.value]
        endif
    endif
    let l:opt = v:none
    if has_key(a:message.result, 'range')
        let l:range = a:message.result.range
        let l:screenpos = screenpos(bufwinid('%'), l:range.start.line + 1, l:range.start.character + 1)
        let l:opt = {}
        let l:opt.col = l:screenpos.col
        let l:opt.moved = [l:range.start.character + 1, l:range.end.character + 1]
    endif
    let l:lines = []
    for l:value in l:values
        let l:line = substitute(l:value, '\(\r\n\)', '\n', 'g')
        let l:lines += util#split(l:line, '\n', 0)
    endfor
    call popup#hover(l:title, l:lines, l:opt)
endfunction

function s:fn.textDocument_definition(server, message, ...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if util#isNull(a:message.result)
        return
    endif
    if type(a:message.result) == v:t_list
        " interface Location[]
        let l:results = a:message.result
    elseif type(a:message.result) == v:t_dict
        " interface Location
        let l:results = [a:message.result]
    endif
    let l:locations = []
    for l:result in l:results
        let l:path = util#uri2path(l:result.uri)
        let l:range = l:result.range
        let l:lnum = l:range.start.line
        let l:col = l:range.start.character
        let l:locations += [quickfix#location(l:path, l:lnum, l:col, v:none, v:none, v:none)]
    endfor
    if empty(l:locations)
        return
    endif
    call quickfix#set_loclist(win_getid(), l:locations)
    if len(l:locations) == 1
        execute 'll!'
    else
        execute 'lopen'
    endif
endfunction

function s:fn.textDocument_references(server, message, ...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if util#isNull(a:message.result)
        return
    endif
    " interface Location[]
    let l:results = a:message.result
    let l:locations = []
    for l:result in l:results
        let l:path = util#uri2path(l:result.uri)
        let l:range = l:result.range
        let l:lnum = l:range.start.line
        let l:col = l:range.start.character
        let l:locations += [quickfix#location(l:path, l:lnum, l:col, v:none, v:none, v:none)]
    endfor
    if empty(l:locations)
        return
    endif
    call quickfix#set_loclist(win_getid(), l:locations)
    if len(l:locations) == 1
        execute 'll!'
    else
        execute 'lopen'
    endif
endfunction

function s:fn.textDocument_implementation(server, message, ...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if util#isNull(a:message.result)
        return
    endif
    if type(a:message.result) == v:t_list
        " interface Location[]
        let l:results = a:message.result
    elseif type(a:message.result) == v:t_dict
        " interface Location
        let l:results = [a:message.result]
    endif
    let l:locations = []
    for l:result in l:results
        let l:path = util#uri2path(l:result.uri)
        let l:range = l:result.range
        let l:lnum = l:range.start.line
        let l:col = l:range.start.character
        let l:locations += [quickfix#location(l:path, l:lnum, l:col, v:none, v:none, v:none)]
    endfor
    if empty(l:locations)
        return
    endif
    call quickfix#set_loclist(win_getid(), l:locations)
    if len(l:locations) == 1
        execute 'll!'
    else
        execute 'lopen'
    endif
endfunction

function s:fn.textDocument_completion(server, message, ...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:result = a:message.result
    if util#isNull(l:result)
        return
    elseif has_key(l:result, 'isIncomplete')
        " interface CompletionList
        if l:result.isIncomplete
            let l:items = l:result.items
        else
            let l:items = l:result.items
        endif
    elseif type(l:result) == v:t_list
        " CompletionItem[]
        let l:items = l:result
    endif
    let l:request = get(a:, 1, v:none)
    let l:params = l:request.params
    let l:position = l:params.position
    call complete#complete(l:position, l:items)
endfunction

" function s:fn.response_error(server, message, ...)
" 	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
"     call log#log_error('Unknown event listener function call')
"     call log#log_error(string(a:server))
"     call log#log_error(string(a:message))
" endfunction

let s:listener = {}
let s:listener['initialize'] = s:fn.initialize
let s:listener['shutdown'] = s:fn.shutdown
let s:listener['textDocument/publishDiagnostics'] = s:fn.textDocument_publishDiagnostics
let s:listener['textDocument/hover'] = s:fn.textDocument_hover
let s:listener['textDocument/definition'] = s:fn.textDocument_definition
let s:listener['textDocument/references'] = s:fn.textDocument_references
let s:listener['textDocument/implementation'] = s:fn.textDocument_implementation
let s:listener['textDocument/completion'] = s:fn.textDocument_completion
" let s:listener['unknown'] = funcref('s:fn.response_error')

function s:send_request(server, method, params)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:message = jsonrpc#request_message(a:server.id, a:method, a:params)
	call log#log_debug('Send request: ' . a:method)
    return a:server.send(l:message)
endfunction

function s:send_response(server, message)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	call log#log_debug('Send response: ' . a:method)
    return a:server.send(l:message)
endfunction

function s:send_notification(server, method, params)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:message = jsonrpc#notification_message(a:method, a:params)
	call log#log_debug('Send notification: ' . a:method)
    return a:server.send(l:message)
endfunction

function s:print_error(message)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call dialog#error(a:message['message'])
    if has_key(a:message, 'data')
        call dialog#error(a:message['data'])
    endif
endfunction

function s:start_server(lang)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if !has_key(s:server_list, a:lang)
        if setting#isSupport(a:lang)
            let l:server = server#create(a:lang, s:listener)
            call l:server.start()
            let s:server_list[a:lang] = l:server
        endif
    endif
    return s:server_list[a:lang]
endfunction

" function client#bufchange_listener(bufnr, start, end, added, changes)
" 	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
" 	call log#log_error(expand('<sfile>') . ':' . expand('<sflnum>'))
" 	call log#log_error(a:bufnr)
" endfunction
