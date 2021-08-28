let s:server_list = {}

function client#start(lang, buf, cwd)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if !has_key(s:server_list, a:lang)
        if setting#isSupport(a:lang)
            let l:server = s:start_server(a:lang)

            let l:winid = bufwinid(a:buf)
            let l:cwd = getcwd(l:winid)
            let l:workspaceFolder = lsp#WorkspaceFolder(l:cwd, l:cwd)
            let l:params = lsp#InitializeParams(l:server['options'], [l:workspaceFolder], v:none)
            call s:send_request(l:server, 'initialize', l:params)
        endif
    endif
endfunction

function client#stop(filetype)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if has_key(s:server_list, a:filetype)
        let l:server = s:server_list[a:filetype]
        call s:send_request(l:server, 'shutdown', v:none)
    endif
    if util#isNone(a:filetype)
        for l:server in values(s:server_list)
            call s:send_request(l:server, 'shutdown', v:none)
        endfor
    endif
endfunction

function client#document_open(buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))

    let l:filetype = util#getfiletype(a:buf)

    if !has_key(s:server_list, l:filetype)
        if setting#isSupport(l:filetype)
            let l:server = s:start_server(l:filetype)

            let l:winid = bufwinid(a:buf)
            let l:cwd = getcwd(l:winid)
            let l:workspaceFolder = lsp#WorkspaceFolder(l:cwd, l:cwd)
            let l:params = lsp#InitializeParams(l:server['options'], [l:workspaceFolder], v:none)
            call s:send_request(l:server, 'initialize', l:params)
        endif
    else
        let l:server = s:server_list[l:filetype]
        if !util#isContain(l:server['files'], a:path)
            call s:send_textDocument_didOpen(l:server, a:buf, a:path)

            call ui#set_buffer_cmd()
        endif
    endif
endfunction

function client#document_close(buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:filetype = util#getfiletype(a:buf)
    if has_key(s:server_list, l:filetype)
        let l:server = s:server_list[l:filetype]
        if util#isContain(l:server['files'], a:path)
            let l:params = lsp#DidCloseTextDocumentParams(util#encode_uri(a:path))
            call s:send_notification(l:server, 'textDocument/didClose', l:params)
            call filter(l:server['files'], {idx, val -> val != a:path})
        endif
    endif
endfunction

function client#document_change(buf, path, pos, char)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:filetype = util#getfiletype(a:buf)
    if has_key(s:server_list, l:filetype)
        let l:server = s:server_list[l:filetype]
        if util#isContain(l:server['files'], a:path)
            " call log#log_error(typename(a:char))
            " call log#log_error(string(a:char))
            " call log#log_error(string(empty(a:char)))
            " call log#log_error(len(a:char))
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
        endif
    endif
endfunction

function client#document_save(buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:filetype = util#getfiletype(a:buf)
    if has_key(s:server_list, l:filetype)
        let l:server = s:server_list[l:filetype]
        if util#isContain(l:server['files'], a:path)
            call s:send_textDocument_didSave(l:server, a:buf, a:path)
        endif
    endif
endfunction

function client#document_hover(buf, pos)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:filetype = util#getfiletype(a:buf)
    if has_key(s:server_list, l:filetype)
        let l:server = s:server_list[l:filetype]
        let l:path = util#buf2path(a:buf)
        " if util#isContain(l:server['files'], l:path)
            let l:lnum = a:pos[1]
            let l:col = a:pos[2]

            let l:position = lsp#Position(l:lnum - 1, l:col - 1)
            let l:params = lsp#HoverParams(util#encode_uri(l:path), l:position, v:none)
            call s:send_request(l:server, 'textDocument/hover', l:params)
        " endif
    endif
endfunction

function client#goto_definition(buf, pos)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:filetype = util#getfiletype(a:buf)
    if has_key(s:server_list, l:filetype)
        let l:server = s:server_list[l:filetype]
        let l:path = util#buf2path(a:buf)
        " if util#isContain(l:server['files'], l:path)
            let l:lnum = a:pos[1]
            let l:col = a:pos[2]

            let l:position = lsp#Position(l:lnum - 1, l:col - 1)
            let l:params = lsp#DefinitionParams(util#encode_uri(l:path), l:position, v:none, v:none)
            call s:send_request(l:server, 'textDocument/definition', l:params)
        " endif
    endif
endfunction

let s:wait_completion = v:none

function client#document_completion(buf, path, pos, char)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:filetype = util#getfiletype(a:buf)
    if !has_key(s:server_list, l:filetype)
        return v:false
    endif
    let l:server = s:server_list[l:filetype]
    if util#isNone(a:char)
        let l:kind = 1
    else
        let l:kind = 2
    endif
    if util#isContain(l:server['capabilities']['completionProvider']['triggerCharacters'], a:char) || l:kind == 1
        let l:line = a:pos[1] - 1
        if util#isNone(a:char)
            let l:character = a:pos[2] - 1
        else
            let l:character = a:pos[2]
        endif
        let l:position = lsp#Position(l:line, l:character)
        let l:context = lsp#CompletionContext(l:kind, a:char)
        let l:params = lsp#CompletionParams(l:context, util#encode_uri(a:path), l:position, v:none, v:none)
        call s:send_request(l:server, 'textDocument/completion', l:params)

        let s:wait_completion = a:char

        return v:true
    endif
    return v:false
endfunction

function client#completion_resolve(buf, item)
endfunction

function client#completion_status(buf)
    let l:filetype = util#getfiletype(a:buf)
    let l:status = v:false
    if has_key(s:server_list, l:filetype)
        let l:server = s:server_list[l:filetype]
        if has_key(l:server, 'complete-items')
            let l:status = v:true
        endif
    endif
    return l:status
endfunction

function client#get_completion(buf)
    let l:filetype = util#getfiletype(a:buf)
    let l:items = []
    if has_key(s:server_list, l:filetype)
        let l:server = s:server_list[l:filetype]
        if has_key(l:server, 'complete-items')
            let l:items = remove(l:server, 'complete-items')
        endif
    endif
    return l:items
endfunction

let s:fn = {}
function s:fn.initialize(server, message, ...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if has_key(a:message, 'error')
        call s:print_error(a:message['error'])
        call s:send_request(a:server, 'shutdown', v:none)
    else
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
                call s:send_textDocument_didOpen(a:server, l:bufinfo['bufnr'], l:bufinfo['name'])
                " call listener_add(funcref('s:bufchange_listener'), l:bufnr)
                " call autocmd#add_event_listener()
                call ui#set_buffer_cmd()
            endif
        endfor
    endif
endfunction

function s:fn.shutdown(server, message, ...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call s:send_notification(a:server, 'exit', v:none)
    call a:server.stop()
    call remove(s:server_list, a:server.lang)
endfunction

function s:fn.textDocument_publishDiagnostics(server, message, ...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))

    let l:file = util#uri2path(a:message['params']['uri'])
    " let l:buf = util#path2buf(l:file)
    " let l:winid = bufwinid(l:buf)

    " TODO mod to event target buffer with filename
    " call textprop#clear('%')

    let l:location = []
    for l:value in a:message['params']['diagnostics']
        let l:lnum = l:value['range']['start']['line']
        let l:col = l:value['range']['start']['character']
        let l:nr = get(l:value, 'code', v:none)
        let l:text = l:value['message']
        let l:type = get(l:value, 'severity', v:none)
        call add(l:location, quickfix#location(l:file, l:lnum, l:col, l:nr, l:text, l:type))
        let l:start = l:value['range']['start']
        let l:end = l:value['range']['end']
        " call textprop#add(l:start, l:end, l:type)
    endfor
    call quickfix#set_quickfix(l:location, l:file)
endfunction

function s:fn.textDocument_hover(server, message, ...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if !util#isNull(a:message.result)
        let l:contents = a:message.result.contents
        if type(l:contents) == v:t_list
            let l:values = []
            for l:content in l:contents
                if type(l:content) == v:t_dict
                    if has_key(l:content, 'value')
                        for l:line in split(l:content.value, "\n")
                            call add(l:values, l:line)
                        endfor
                    endif
                else
                    for l:line in split(l:content, "\n")
                        call add(l:values, l:line)
                    endfor
                endif
            endfor
        elseif type(l:contents) == v:t_dict 
            if has_key(l:contents, 'value')
                let l:values = split(l:contents.value, "\n")
            endif
        else
            let l:values = split(l:contents, "\n")
        endif
        let l:opt = v:none
        if has_key(a:message.result, 'range')
            let l:range = a:message.result.range
            let l:screenpos = screenpos(bufwinid('%'), l:range.start.line + 1, l:range.start.character + 1)
            let l:opt = {}
            let l:opt.col = l:screenpos.col
            let l:opt.moved = [l:range.start.character + 1, l:range.end.character + 1]
        endif
        call filter(l:values, {idx, val -> !empty(val)})
        call map(l:values, {key, val -> trim(val, v:none, 2)})
        call popup#hover(v:none, l:values, l:opt)
    endif
endfunction

function s:fn.textDocument_definition(server, message, ...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if !util#isNull(a:message.result)
        if type(a:message.result) == v:t_list
            " interface Location[]
            let l:locations = a:message.result
            for l:location in l:locations
                let l:path = util#uri2path(l:location.uri)
                let l:range = l:location.range

                let l:buf = bufadd(l:path)
                call execute(l:buf . 'buffer', 'silent')
                call cursor(l:range.start.line + 1, l:range.start.character + 1)
            endfor
            

        elseif type(a:message.result) == v:t_dict
            " interface Location
            let l:location = a:message.result
            let l:path = util#uri2path(l:location.uri)
            let l:range = l:location.range

            let l:buf = bufadd(l:path)
            call execute(l:buf . 'buffer', 'silent')
            call cursor(l:range.start.line + 1, l:range.start.character + 1)
        endif
    endif
endfunction

function s:fn.textDocument_completion(server, message, ...)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:complete_items = []
    if !util#isNull(a:message.result)
        let l:result = a:message.result
        if has_key(l:result, 'isIncomplete')
            if l:result.isIncomplete
                let l:items = l:result.items
            else
                let l:items = l:result.items
            endif
        elseif type(l:result) == v:t_list
            let l:items = l:result
        endif
        for l:item in l:items
            let l:complete_item = {}
            let l:complete_item.word = l:item.label
            if has_key(l:item, 'detail')
                let l:complete_item.menu = l:item.detail
            endif
            if has_key(l:item, 'documentation')
                let l:complete_item.info = l:item.documentation
            endif
            if has_key(l:item, 'kind')
                let l:complete_item.kind = util#lsp_kind2vim_kind(l:item.kind)
            endif
            call add(l:complete_items, l:complete_item)
        endfor
        if util#isNone(s:wait_completion)
            let a:server['complete-items'] = l:complete_items
        else
            let l:col = col('.')
            call complete(l:col + 1, l:complete_items)
            let s:wait_completion = v:none
        endif
    else
        let a:server['complete-items'] = l:complete_items
    endif
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
let s:listener['textDocument/completion'] = s:fn.textDocument_completion
" let s:listener['unknown'] = funcref('s:fn.response_error')

function s:send_textDocument_didOpen(server, buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:text = util#getbuftext(a:buf)
    let l:changedtick = util#getchangedtick(a:buf)
    let l:params = lsp#DidOpenTextDocumentParams(util#encode_uri(a:path), &filetype, l:changedtick, l:text)
    call add(a:server['files'], a:path)
    call s:send_notification(a:server, 'textDocument/didOpen', l:params)
endfunction

function s:send_textDocument_didSave(server, buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:text = util#getbuftext(a:buf)
    let l:params = lsp#DidSaveTextDocumentParams(util#encode_uri(a:path), l:text)
    return s:send_notification(a:server, 'textDocument/didSave', l:params)
endfunction

function s:send_request(server, method, params)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:message = jsonrpc#request_message(a:server.id, a:method, a:params)
    return a:server.send(l:message)
endfunction

function s:send_response(server, message)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    return a:server.send(l:message)
endfunction

function s:send_notification(server, method, params)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:message = jsonrpc#notification_message(a:method, a:params)
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
