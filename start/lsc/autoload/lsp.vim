if exists("g:loaded_lsp")
	finish
endif
let g:loaded_lsp = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


let s:rn = "\r\n"

function lsp#isMessage(message)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return has_key(a:message, 'jsonrpc')
endfunction

function lsp#isRequest(message)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	if lsp#isMessage(a:message)
		return has_key(a:message, 'id') && has_key(a:message, 'method')
	endif
	return v:false
endfunction

function lsp#isResponse(message)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	if lsp#isMessage(a:message)
		return has_key(a:message, 'id') && !has_key(a:message, 'method')
	endif
	return v:false
endfunction

function lsp#isNotification(message)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	if lsp#isMessage(a:message)
		return !has_key(a:message, 'id') && has_key(a:message, 'method')
	endif
	return v:false
endfunction

function lsp#initialize(id)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:params = s:InitializeParams({}, v:null, v:null)
	return s:BuildMessage(a:id, 'initialize', l:params)
endfunction

function s:BuildMessage(id, method, params)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	let l:message = s:Message({})
	let l:message = s:RequestMessage(l:message, a:id, a:method, a:params)	
	let l:content = json_encode(l:message)
	let l:header = s:BuildHeader(l:content)
	return l:header . s:rn . l:content
endfunction

function s:BuildHeader(content)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
	return 'Content-Length: ' . len(a:content) . s:rn
endfunction

function s:BuildContent(params)
	call log#log_trace(expand('<sfile>') . ':' . expand('<sflnum>'))
endfunction

function s:Message(message)
	let a:message['jsonrpc'] = '2.0'
	return a:message
endfunction

function s:RequestMessage(message, id, method, params)
	let a:message['id'] = a:id
	let a:message['method'] = a:method
	let a:message['params'] = a:params
	return a:message
endfunction

function s:NotificationMessage(message, method, params)
	let a:message['method'] = a:method
	let a:message['params'] = a:params
	return a:message
endfunction

function s:DocumentUri(scheme, authority, path, query, fragment)
endfunction

function s:Uri(scheme, authority, path, query, fragment)
endfunction

function s:InitializeParams(params, initializationOptions, workspaceFolders)
	let a:params['processId'] = getpid()
	let a:params['clientInfo'] = {}
	let a:params['clientInfo']['name'] = "vim-package-lsp"
	let a:params['clientInfo']['version'] = "0.0"
	let a:params['locale'] = "en"
	" let a:params['rootPath'] @deprecated
	" let a:params['rootUri'] @deprecated
	let a:params['initializationOptions'] = a:initializationOptions
	let a:params['capabilities'] = s:ClientCapabilities()
	let a:params['trace'] = "messages" " 'off' | 'messages' | 'verbose'
	let a:params['workspaceFolders'] = a:workspaceFolders ? a:workspaceFolders : v:null
	return a:params
endfunction

function s:WorkspaceFolder()
	" let l:workspaceFolder = {
		" 'uri'
		" 'name'
	" }
endfunction

function s:ClientCapabilities()
	let l:params = {}
	let l:params['workspace'] = {}
	let l:params['workspace']['applyEdit'] = v:false
	let l:params['workspace']['workspaceEdit'] = s:WorkspaceEditClientCapabilities()
	let l:params['workspace']['didChangeConfiguration'] = s:DidChangeConfigurationClientCapabilities()
	let l:params['workspace']['didChangeWatchedFiles'] = s:DidChangeWatchedFilesClientCapabilities()
	let l:params['workspace']['symbol'] = s:WorkspaceSymbolClientCapabilities()
	let l:params['workspace']['executeCommand'] = s:ExecuteCommandClientCapabilities()
	let l:params['workspace']['workspaceFolders'] = v:false
	let l:params['workspace']['configuration'] = v:false
	let l:params['workspace']['semanticTokens'] = s:SemanticTokensWorkspaceClientCapabilities()
	let l:params['workspace']['codeLens'] = s:CodeLensWorkspaceClientCapabilities()
	let l:params['workspace']['fileOperations'] = {}
	let l:params['workspace']['fileOperations']['dynamicRegistration'] = v:false
	let l:params['workspace']['fileOperations']['didCreate'] = v:false
	let l:params['workspace']['fileOperations']['willCreate'] = v:false
	let l:params['workspace']['fileOperations']['didRename'] = v:false
	let l:params['workspace']['fileOperations']['willRename'] = v:false
	let l:params['workspace']['fileOperations']['didDelete'] = v:false
	let l:params['workspace']['fileOperations']['willDelete'] = v:false
	let l:params['textDocument'] = s:TextDocumentClientCapabilities()
	let l:params['window'] = {}
	let l:params['window']['workDoneProgress'] = v:false
	let l:params['window']['showMessage'] = s:ShowMessageRequestClientCapabilities()
	let l:params['window']['showDocument'] = s:ShowDocumentClientCapabilities()
	let l:params['general'] = {}
	let l:params['general']['staleRequestSupport'] = {}
	let l:params['general']['staleRequestSupport']['cancel'] = v:false
	let l:params['general']['staleRequestSupport']['retryOnContentModified'] = [""]
	let l:params['general']['regularExpressions'] = s:RegularExpressionsClientCapabilities()
	let l:params['general']['markdown'] = s:MarkdownClientCapabilities()
	let l:params['experimental'] = v:null
	return l:params
endfunction

function s:WorkspaceEditClientCapabilities()
	let l:params = {}
	let l:params['documentChanges'] = v:false
	let l:params['resourceOperations'] = [] " ['create', 'rename', 'delete']
	let l:params['failureHandling'] = "abort" " 'abort' | 'transactional' | 'undo' | 'textOnlyTransactional'
	let l:params['normalizesLineEndings'] = v:false
	let l:params['changeAnnotationSupport'] = {}
	let l:params['changeAnnotationSupport']['groupsOnLabel'] = v:false
	return l:params
endfunction

function s:DidChangeConfigurationClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function s:DidChangeWatchedFilesClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction


function s:WorkspaceSymbolClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['symbolKind'] = {}
	let l:params['symbolKind']['valueSet'] = []
	let l:params['tagSupport'] = {}
	let l:params['tagSupport']['valueSet'] = []
	return l:params
endfunction

function s:ExecuteCommandClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function s:SemanticTokensWorkspaceClientCapabilities()
	let l:params = {}
	let l:params['refreshSupport'] = v:false
	return l:params
endfunction

function s:CodeLensWorkspaceClientCapabilities()
	let l:params = {}
	let l:params['refreshSupport'] = v:false
	return l:params
endfunction

function s:TextDocumentClientCapabilities()
	let l:params = {}
	let l:params['synchronization'] = s:TextDocumentSyncClientCapabilities()
	let l:params['completion'] = s:CompletionClientCapabilities()
	let l:params['hover'] = s:HoverClientCapabilities()
	let l:params['signatureHelp'] = s:SignatureHelpClientCapabilities()
	let l:params['declaration'] = s:DeclarationClientCapabilities()
	let l:params['definition'] = s:DefinitionClientCapabilities()
	let l:params['typeDefinition'] = s:TypeDefinitionClientCapabilities()
	let l:params['implementation'] = s:ImplementationClientCapabilities()
	let l:params['references'] = s:ReferenceClientCapabilities()
	let l:params['documentHighlight'] = s:DocumentHighlightClientCapabilities()
	let l:params['documentSymbol'] = s:DocumentSymbolClientCapabilities()
	let l:params['codeAction'] = s:CodeActionClientCapabilities()
	let l:params['codeLens'] = s:CodeLensClientCapabilities()
	let l:params['documentLink'] = s:DocumentLinkClientCapabilities()
	let l:params['colorProvider'] = s:DocumentColorClientCapabilities()
	let l:params['formatting'] = s:DocumentFormattingClientCapabilities()
	let l:params['rangeFormatting'] = s:DocumentRangeFormattingClientCapabilities()
	let l:params['onTypeFormatting'] = s:DocumentOnTypeFormattingClientCapabilities()
	let l:params['rename'] = s:RenameClientCapabilities()
	let l:params['publishDiagnostics'] = s:PublishDiagnosticsClientCapabilities()
	let l:params['foldingRange'] = s:FoldingRangeClientCapabilities()
	let l:params['selectionRange'] = s:SelectionRangeClientCapabilities()
	let l:params['linkedEditingRange'] = s:LinkedEditingRangeClientCapabilities()
	let l:params['callHierarchy'] = s:CallHierarchyClientCapabilities()
	let l:params['semanticTokens'] = s:SemanticTokensClientCapabilities()
	let l:params['moniker'] = s:MonikerClientCapabilities()
	return l:params
endfunction

function s:ShowMessageRequestClientCapabilities()
	let l:params = {}
	let l:params['messageActionItem'] = {}
	let l:params['messageActionItem']['additionalPropertiesSupport'] = v:false
	return l:params
endfunction

function s:ShowDocumentClientCapabilities()
	let l:params = {}
	let l:params['support'] = v:false
	return l:params
endfunction

function s:RegularExpressionsClientCapabilities()
	let l:params = {}
	let l:params['engine'] = ""
	let l:params['version'] = "0.0"
	return l:params
endfunction

function s:MarkdownClientCapabilities()
	let l:params = {}
	let l:params['parser'] = ""
	let l:params['version'] = "0.0"
	return l:params
endfunction

function s:TextDocumentSyncClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['willSave'] = v:false
	let l:params['willSaveWaitUntil'] = v:false
	let l:params['didSave'] = v:false
	return l:params
endfunction

function s:CompletionClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['completionItem'] = {}
	let l:params['completionItem']['snippetSupport'] = v:false
	let l:params['completionItem']['commitCharactersSupport'] = v:false
	let l:params['completionItem']['documentationFormat'] = ['plaintext']
	let l:params['completionItem']['deprecatedSupport'] = v:false
	let l:params['completionItem']['preselectSupport'] = v:false
	let l:params['completionItem']['tagSupport'] = {}
	let l:params['completionItem']['tagSupport']['valueSet'] = [1]
	let l:params['completionItem']['insertReplaceSupport'] = v:false
	let l:params['completionItem']['resolveSupport'] = {}
	let l:params['completionItem']['resolveSupport']['properties'] = ['']
	let l:params['completionItem']['insertTextModeSupport'] = {}
	let l:params['completionItem']['insertTextModeSupport']['valueSet'] = [1]
	let l:params['completionItem']['labelDetailsSupport'] = v:false
	let l:params['completionItemKind'] = {}
	let l:params['completionItemKind']['valueSet'] = []
	let l:params['contextSupport'] = v:false
	let l:params['insertTextMode'] = 1
	return l:params
endfunction

function s:HoverClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['contentFormat'] = ['plaintext']
	return l:params
endfunction

function s:SignatureHelpClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['signatureInformation'] = {}
	let l:params['signatureInformation']['documentationFormat'] = ['plaintext']
	let l:params['signatureInformation']['parameterInformation'] = {}
	let l:params['signatureInformation']['parameterInformation']['labelOffsetSupport'] = v:false
	let l:params['signatureInformation']['activeParameterSupport'] = v:false
	let l:params['contextSupport'] = v:false
	return l:params
endfunction

function s:DeclarationClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['linkSupport'] = v:false
	return l:params
endfunction

function s:DefinitionClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['linkSupport'] = v:false
	return l:params
endfunction

function s:TypeDefinitionClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['linkSupport'] = v:false
	return l:params
endfunction

function s:ImplementationClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['linkSupport'] = v:false
	return l:params
endfunction

function s:ReferenceClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function s:DocumentHighlightClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function s:DocumentSymbolClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['symbolKind'] = {}
	let l:params['symbolKind']['valueSet'] = []
	let l:params['hierarchicalDocumentSymbolSupport'] = v:false
	let l:params['tagSupport'] = {}
	let l:params['tagSupport']['valueSet'] = [1]
	let l:params['labelSupport'] = v:false
	return l:params
endfunction

function s:CodeActionClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['codeActionLiteralSupport'] = {}
	let l:params['codeActionLiteralSupport']['codeActionKind'] = {}
	let l:params['codeActionLiteralSupport']['codeActionKind']['valueSet'] = ['']
	let l:params['isPreferredSupport'] = v:false
	let l:params['disabledSupport'] = v:false
	let l:params['dataSupport'] = v:false
	let l:params['resolveSupport'] = {}
	let l:params['resolveSupport']['properties'] = ['']
	let l:params['honorsChangeAnnotations'] = v:false
	return l:params
endfunction

function s:CodeLensClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function s:DocumentLinkClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['tooltipSupport'] = v:false
	return l:params
endfunction

function s:DocumentColorClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function s:DocumentFormattingClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function s:DocumentRangeFormattingClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function s:DocumentOnTypeFormattingClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function s:RenameClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['prepareSupport'] = v:false
	let l:params['prepareSupportDefaultBehavior'] = 1
	let l:params['honorsChangeAnnotations'] = v:false
	return l:params
endfunction

function s:PublishDiagnosticsClientCapabilities()
	let l:params = {}
	let l:params['relatedInformation'] = v:false
	let l:params['tagSupport'] = {}
	let l:params['tagSupport']['valueSet'] = [1]
	let l:params['versionSupport'] = v:false
	let l:params['codeDescriptionSupport'] = v:false
	let l:params['dataSupport'] = v:false
	return l:params
endfunction

function s:FoldingRangeClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['rangeLimit'] = 0
	let l:params['lineFoldingOnly'] = v:true
	return l:params
endfunction

function s:SelectionRangeClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function s:LinkedEditingRangeClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function s:CallHierarchyClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function s:SemanticTokensClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['requests'] = {}
	let l:params['requests']['range'] = v:false
	let l:params['requests']['full'] = v:false
	let l:params['tokenTypes'] = ['']
	let l:params['tokenModifiers'] = ['']
	let l:params['formats'] = ['relative']
	let l:params['overlappingTokenSupport'] = v:false
	let l:params['multilineTokenSupport'] = v:false
	return l:params
endfunction

function s:MonikerClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function s:PrepareSupportDefaultBehavior()
	let l:params = {}
	let l:params['Identifier'] = 1
	return l:params
endfunction

function s:WorkDoneProgressParams(params, progressToken)
	let a:params['workDoneToken'] = a:progressToken
	return a:params
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
