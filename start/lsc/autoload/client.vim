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
            call s:send_textDocument_didClose(l:server, a:buf, a:path)
        endif
    endif
endfunction

function client#document_change(buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:filetype = util#getfiletype(a:buf)
    if has_key(s:server_list, l:filetype)
        let l:server = s:server_list[l:filetype]
        if util#isContain(l:server['files'], a:path)
            call s:send_textDocument_didChange(l:server, a:buf, a:path)
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
        if util#isContain(l:server['files'], l:path)
            let l:lnum = a:pos[1]
            let l:col = a:pos[2]

            let l:position = lsp#Position(l:lnum - 1, l:col - 1)
            let l:params = lsp#HoverParams(l:path, l:position, v:none)
            call s:send_request(l:server, 'textDocument/hover', l:params)
        endif
    endif
endfunction

function client#goto_definition(buf, pos)
    let l:filetype = util#getfiletype(a:buf)
    if has_key(s:server_list, l:filetype)
        let l:server = s:server_list[l:filetype]
        let l:path = util#buf2path(a:buf)
        if util#isContain(l:server['files'], l:path)
            let l:lnum = a:pos[1]
            let l:col = a:pos[2]

            let l:position = lsp#Position(l:lnum - 1, l:col - 1)
            let l:params = lsp#DefinitionParams(l:path, l:position, v:none, v:none)
            call s:send_request(l:server, 'textDocument/definition', l:params)
        endif
    endif
endfunction

let s:fn = {}
function s:fn.initialize(server, message)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    if has_key(a:message, 'error')
        call s:print_error(a:message['error'])
        call s:send_request(a:server, 'shutdown', v:none)
    else
        let a:server['capabilities'] = get(a:message['result'], 'capabilities', {})
        let a:server['serverInfo'] = get(a:message['result'], 'serverInfo', {})
        call log#log_debug('Update server info ' . string(a:server))

        let l:params = lsp#InitializedParams()
        call s:send_notification(a:server, 'initialized', l:params)

        " let l:unopened = a:server['unopened']
        " for l:file in l:unopened
        "     call s:send_textDocument_didOpen(a:server, l:bufinfo['bufnr'], l:file)
        " endfor
        let l:bufinfolist = util#loadedbufinfolist()
        for l:bufinfo in l:bufinfolist
            call s:send_textDocument_didOpen(a:server, l:bufinfo['bufnr'], l:bufinfo['name'])
            " call listener_add(funcref('s:bufchange_listener'), l:bufnr)
            " call autocmd#add_event_listener()
            call ui#set_buffer_cmd()
        endfor
    endif
endfunction

function s:fn.shutdown(server, message)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    call s:send_notification(a:server, 'exit', v:none)
    call a:server.stop()
    call remove(s:server_list, a:server.lang)
endfunction

function s:fn.textDocument_publishDiagnostics(server, message)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))

    let l:file = util#uri2path(a:message['params']['uri'])
    let l:buf = util#path2buf(l:file)
    let l:winid = bufwinid(l:buf)

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
    call quickfix#set_location(l:winid, l:location, 'r')
endfunction

function s:fn.textDocument_hover(server, message)
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
            let l:opt = {}
            let l:opt.moved = [l:range.start.character + 1, l:range.end.character + 1]
        endif
        call filter(l:values, {idx, val -> !empty(val)})
        call map(l:values, {key, val -> trim(val, v:none, 2)})
        call popup#hover(l:values, l:opt)
    endif
endfunction

function s:fn.textDocument_definition(server, message)
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

" function s:fn.response_error(server, message)
" 	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
"     call log#log_error('Unknown event listener function call')
"     call log#log_error(string(a:server))
"     call log#log_error(string(a:message))
" endfunction

let s:listener = {}
let s:listener['initialize'] = funcref('s:fn.initialize')
let s:listener['shutdown'] = funcref('s:fn.shutdown')
let s:listener['textDocument/publishDiagnostics'] = funcref('s:fn.textDocument_publishDiagnostics')
let s:listener['textDocument/hover'] = funcref('s:fn.textDocument_hover')
let s:listener['textDocument/definition'] = funcref('s:fn.textDocument_definition')
" let s:listener['unknown'] = funcref('s:fn.response_error')

function s:send_textDocument_didOpen(server, buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:text = util#getbuftext(a:buf)
    let l:changedtick = util#getchangedtick(a:buf)
    let l:params = lsp#DidOpenTextDocumentParams(a:path, &filetype, l:changedtick, l:text)
    call add(a:server['files'], a:path)
    call s:send_notification(a:server, 'textDocument/didOpen', l:params)
endfunction

function s:send_textDocument_didClose(server, buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:params = lsp#DidCloseTextDocumentParams(a:path)
    call filter(a:server['files'], {idx, val -> val != a:path})
    call s:send_notification(a:server, 'textDocument/didClose', l:params)
endfunction

function s:send_textDocument_didChange(server, buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:version = util#getchangedtick(a:buf)
    let l:change = lsp#TextDocumentContentChangeEvent(v:none, util#getbuftext(a:buf))
    let l:params = lsp#DidChangeTextDocumentParams(a:path, l:version, [l:change])
    return s:send_notification(a:server, 'textDocument/didChange', l:params)
endfunction

function s:send_textDocument_didSave(server, buf, path)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
    let l:text = util#getbuftext(a:buf)
    let l:params = lsp#DidSaveTextDocumentParams(a:path, l:text)
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

            " call s:install_server(a:lang)

            let l:server = server#create(a:lang, s:listener)
            call l:server.start()
            let s:server_list[a:lang] = l:server
        endif
    endif
    return s:server_list[a:lang]
endfunction

" function s:install_server(lang)
" 	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
"     call setting#install(a:lang, funcref('s:test_finish'))
" endfunction

" function s:test_finish()
"     call log#log_error('test finish')
" endfunction

" function client#bufchange_listener(bufnr, start, end, added, changes)
" 	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
" 	call log#log_error(expand('<sfile>') . ':' . expand('<sflnum>'))
" 	call log#log_error(a:bufnr)
" endfunction
