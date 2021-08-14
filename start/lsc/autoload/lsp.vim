let lsp#DiagnosticSeverity = {}
let lsp#DiagnosticSeverity['Error'] = 1
let lsp#DiagnosticSeverity['Warning'] = 2
let lsp#DiagnosticSeverity['Information'] = 3
let lsp#DiagnosticSeverity['Hint'] = 4

let lsp#ErrorCodes = {}
let lsp#ErrorCodes['ParseError'] = -32700
let lsp#ErrorCodes['InvalidRequest'] = -32600
let lsp#ErrorCodes['MethodNotFound'] = -32601
let lsp#ErrorCodes['InvalidParams'] = -32602
let lsp#ErrorCodes['InternalError'] = -32603
let lsp#ErrorCodes['jsonrpcReservedErrorRangeStart'] = -32099
let lsp#ErrorCodes['serverErrorStart'] = lsp#ErrorCodes['jsonrpcReservedErrorRangeStart']
let lsp#ErrorCodes['ServerNotInitialized'] = -32002
let lsp#ErrorCodes['UnknownErrorCode'] = -32001
let lsp#ErrorCodes['jsonrpcReservedErrorRangeEnd'] = -32000
let lsp#ErrorCodes['serverErrorEnd'] = lsp#ErrorCodes['jsonrpcReservedErrorRangeEnd']
let lsp#ErrorCodes['lspReservedErrorRangeStart'] = -32899
let lsp#ErrorCodes['ServerCancelled'] = -32802
let lsp#ErrorCodes['ContentModified'] = -32801
let lsp#ErrorCodes['RequestCancelled'] = -32800
let lsp#ErrorCodes['lspReservedErrorRangeEnd'] = -32800

function lsp#InitializeParams(initializationOptions, workspaceFolders, token)
	let l:params = {}
	call extend(l:params, lsp#WorkDoneProgressParams(a:token))
	let l:params['processId'] = getpid()
	let l:params['clientInfo'] = {}
	let l:params['clientInfo']['name'] = "vim-package-lsp"
	let l:params['clientInfo']['version'] = "0.0"
	let l:params['locale'] = "en"
	" let l:params['rootPath'] = v:null " @deprecated
	" let l:params['rootUri'] = v:null " @deprecated
	if !util#isNone(a:initializationOptions)
		let l:params['initializationOptions'] = a:initializationOptions
	endif
	let l:params['capabilities'] = lsp#ClientCapabilities()
	let l:params['trace'] = "verbose" " 'off' | 'messages' | 'verbose'
	if !util#isNone(a:workspaceFolders)
		let l:params['workspaceFolders'] = a:workspaceFolders
	endif
	return l:params
endfunction

function lsp#InitializedParams()
	let l:params = {}
	return l:params
endfunction

function lsp#DidOpenTextDocumentParams(path, languageId, version, text)
	let l:params = {}
	let l:params['textDocument'] = lsp#TextDocumentItem(a:path, a:languageId, a:version, a:text)
	return l:params
endfunction

function lsp#DidChangeTextDocumentParams(path, version, contentChanges)
	let l:params = {}
	let l:params['textDocument'] = lsp#VersionedTextDocumentIdentifier(a:path, a:version)
	let l:params['contentChanges'] = a:contentChanges
	return l:params
endfunction

function lsp#DidCloseTextDocumentParams(path)
	let l:params = {}
	let l:params['textDocument'] = lsp#TextDocumentIdentifier(a:path)
	return l:params
endfunction

function lsp#DidSaveTextDocumentParams(path, text)
	let l:params = {}
	let l:params['textDocument'] = lsp#TextDocumentIdentifier(a:path)
	if !util#isNone(a:text)
		let l:params['text'] = a:text
	endif
	return l:params
endfunction

function lsp#HoverParams(path, position, token)
	let l:hoverParams = {}
	call extend(l:hoverParams, lsp#TextDocumentPositionParams(a:path, a:position))
	call extend(l:hoverParams, lsp#WorkDoneProgressParams(a:token))
	return l:hoverParams
endfunction

function lsp#TextDocumentPositionParams(path, position)
	let l:params = {}
	let l:params['textDocument'] = lsp#TextDocumentIdentifier(a:path)
	let l:params['position'] = a:position
	return l:params
endfunction

function lsp#VersionedTextDocumentIdentifier(path, version)
	let l:params = {}
	call extend(l:params, lsp#TextDocumentIdentifier(a:path))
	let l:params['version'] = a:version
	return l:params
endfunction

function lsp#TextDocumentIdentifier(path)
	let l:params = {}
	let l:params['uri'] = lsp#DocumentUri('file', v:none, a:path, v:none, v:none)
	return l:params
endfunction

function lsp#TextDocumentContentChangeEvent(range, text)
	let l:params = {}
	if !util#isNone(a:range)
		let l:params['range'] = a:range
	endif
	" let l:params['rangeLength'] = 0 " @deprecated
	let l:params['text'] = a:text
	return l:params
endfunction

function lsp#Range(start, end)
	let l:range = {}
	let l:range['start'] = a:start
	let l:range['end'] = a:end
	return l:range
endfunction

function lsp#Position(line, character)
	let l:position = {}
	let l:position['line'] = a:line
	let l:position['character'] = a:character
	return l:position
endfunction

function lsp#TextDocumentItem(path, languageId, version, text)
	let l:params = {}
	let l:params['uri'] = lsp#DocumentUri('file', v:none, a:path, v:none, v:none)
	let l:params['languageId'] = a:languageId
	let l:params['version'] = a:version
	let l:params['text'] = a:text
	return l:params
endfunction

function lsp#DocumentUri(scheme, authority, path, query, fragment)
	return lsp#Uri(a:scheme, a:authority, a:path, a:query, a:fragment)
endfunction

function lsp#Uri(scheme, authority, path, query, fragment)
	let l:params = []
	call add(l:params, a:scheme)
	call add(l:params, '://')
	if !util#isNone(a:authority)
		call add(l:params, a:authority)
	endif
	call add(l:params, a:path)
	if !util#isNone(a:query)
		call add(l:params, '?')
		call add(l:params, a:query)
	endif
	if !util#isNone(a:fragment)
		call add(l:params, '#')
		call add(l:params, a:fragment)
	endif
	return join(l:params, '')
endfunction

function lsp#WorkspaceFolder(path, name)
	let l:params = {}
	let l:params['uri'] = lsp#DocumentUri('file', v:none, a:path, v:none, v:none)
	let l:params['name'] = a:name
	return l:params
endfunction

function lsp#ClientCapabilities()
	let l:params = {}
	let l:params['workspace'] = {}
	let l:params['workspace']['applyEdit'] = v:false
	let l:params['workspace']['workspaceEdit'] = lsp#WorkspaceEditClientCapabilities()
	let l:params['workspace']['didChangeConfiguration'] = lsp#DidChangeConfigurationClientCapabilities()
	let l:params['workspace']['didChangeWatchedFiles'] = lsp#DidChangeWatchedFilesClientCapabilities()
	let l:params['workspace']['symbol'] = lsp#WorkspaceSymbolClientCapabilities()
	let l:params['workspace']['executeCommand'] = lsp#ExecuteCommandClientCapabilities()
	let l:params['workspace']['workspaceFolders'] = v:true
	let l:params['workspace']['configuration'] = v:true
	let l:params['workspace']['semanticTokens'] = lsp#SemanticTokensWorkspaceClientCapabilities()
	let l:params['workspace']['codeLens'] = lsp#CodeLensWorkspaceClientCapabilities()
	let l:params['workspace']['fileOperations'] = {}
	let l:params['workspace']['fileOperations']['dynamicRegistration'] = v:false
	let l:params['workspace']['fileOperations']['didCreate'] = v:false
	let l:params['workspace']['fileOperations']['willCreate'] = v:false
	let l:params['workspace']['fileOperations']['didRename'] = v:false
	let l:params['workspace']['fileOperations']['willRename'] = v:false
	let l:params['workspace']['fileOperations']['didDelete'] = v:false
	let l:params['workspace']['fileOperations']['willDelete'] = v:false
	let l:params['textDocument'] = lsp#TextDocumentClientCapabilities()
	let l:params['window'] = {}
	let l:params['window']['workDoneProgress'] = v:true
	let l:params['window']['showMessage'] = lsp#ShowMessageRequestClientCapabilities()
	let l:params['window']['showDocument'] = lsp#ShowDocumentClientCapabilities()
	let l:params['general'] = {}
	let l:params['general']['staleRequestSupport'] = {}
	let l:params['general']['staleRequestSupport']['cancel'] = v:false
	let l:params['general']['staleRequestSupport']['retryOnContentModified'] = [""]
	let l:params['general']['regularExpressions'] = lsp#RegularExpressionsClientCapabilities()
	let l:params['general']['markdown'] = lsp#MarkdownClientCapabilities()
	let l:params['experimental'] = v:null
	return l:params
endfunction

function lsp#WorkspaceEditClientCapabilities()
	let l:params = {}
	let l:params['documentChanges'] = v:false
	let l:params['resourceOperations'] = [] " ['create', 'rename', 'delete']
	let l:params['failureHandling'] = "abort" " 'abort' | 'transactional' | 'undo' | 'textOnlyTransactional'
	let l:params['normalizesLineEndings'] = v:false
	let l:params['changeAnnotationSupport'] = {}
	let l:params['changeAnnotationSupport']['groupsOnLabel'] = v:false
	return l:params
endfunction

function lsp#DidChangeConfigurationClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#DidChangeWatchedFilesClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction


function lsp#WorkspaceSymbolClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['symbolKind'] = {}
	let l:params['symbolKind']['valueSet'] = []
	let l:params['tagSupport'] = {}
	let l:params['tagSupport']['valueSet'] = []
	return l:params
endfunction

function lsp#ExecuteCommandClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#SemanticTokensWorkspaceClientCapabilities()
	let l:params = {}
	let l:params['refreshSupport'] = v:false
	return l:params
endfunction

function lsp#CodeLensWorkspaceClientCapabilities()
	let l:params = {}
	let l:params['refreshSupport'] = v:false
	return l:params
endfunction

function lsp#TextDocumentClientCapabilities()
	let l:params = {}
	let l:params['synchronization'] = lsp#TextDocumentSyncClientCapabilities()
	let l:params['completion'] = lsp#CompletionClientCapabilities()
	let l:params['hover'] = lsp#HoverClientCapabilities()
	let l:params['signatureHelp'] = lsp#SignatureHelpClientCapabilities()
	let l:params['declaration'] = lsp#DeclarationClientCapabilities()
	let l:params['definition'] = lsp#DefinitionClientCapabilities()
	let l:params['typeDefinition'] = lsp#TypeDefinitionClientCapabilities()
	let l:params['implementation'] = lsp#ImplementationClientCapabilities()
	let l:params['references'] = lsp#ReferenceClientCapabilities()
	let l:params['documentHighlight'] = lsp#DocumentHighlightClientCapabilities()
	let l:params['documentSymbol'] = lsp#DocumentSymbolClientCapabilities()
	let l:params['codeAction'] = lsp#CodeActionClientCapabilities()
	let l:params['codeLens'] = lsp#CodeLensClientCapabilities()
	let l:params['documentLink'] = lsp#DocumentLinkClientCapabilities()
	let l:params['colorProvider'] = lsp#DocumentColorClientCapabilities()
	let l:params['formatting'] = lsp#DocumentFormattingClientCapabilities()
	let l:params['rangeFormatting'] = lsp#DocumentRangeFormattingClientCapabilities()
	let l:params['onTypeFormatting'] = lsp#DocumentOnTypeFormattingClientCapabilities()
	let l:params['rename'] = lsp#RenameClientCapabilities()
	let l:params['publishDiagnostics'] = lsp#PublishDiagnosticsClientCapabilities()
	let l:params['foldingRange'] = lsp#FoldingRangeClientCapabilities()
	let l:params['selectionRange'] = lsp#SelectionRangeClientCapabilities()
	let l:params['linkedEditingRange'] = lsp#LinkedEditingRangeClientCapabilities()
	let l:params['callHierarchy'] = lsp#CallHierarchyClientCapabilities()
	let l:params['semanticTokens'] = lsp#SemanticTokensClientCapabilities()
	let l:params['moniker'] = lsp#MonikerClientCapabilities()
	return l:params
endfunction

function lsp#ShowMessageRequestClientCapabilities()
	let l:params = {}
	let l:params['messageActionItem'] = {}
	let l:params['messageActionItem']['additionalPropertiesSupport'] = v:false
	return l:params
endfunction

function lsp#ShowDocumentClientCapabilities()
	let l:params = {}
	let l:params['support'] = v:false
	return l:params
endfunction

function lsp#RegularExpressionsClientCapabilities()
	let l:params = {}
	let l:params['engine'] = ""
	let l:params['version'] = "0.0"
	return l:params
endfunction

function lsp#MarkdownClientCapabilities()
	let l:params = {}
	let l:params['parser'] = ""
	let l:params['version'] = "0.0"
	return l:params
endfunction

function lsp#TextDocumentSyncClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['willSave'] = v:false
	let l:params['willSaveWaitUntil'] = v:false
	let l:params['didSave'] = v:true
	return l:params
endfunction

function lsp#CompletionClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['completionItem'] = {}
	let l:params['completionItem']['snippetSupport'] = v:true
	let l:params['completionItem']['commitCharactersSupport'] = v:true
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
	let l:params['completionItem']['labelDetailsSupport'] = v:true
	let l:params['completionItemKind'] = {}
	let l:params['completionItemKind']['valueSet'] = []
	let l:params['contextSupport'] = v:true
	let l:params['insertTextMode'] = 1
	return l:params
endfunction

function lsp#HoverClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:true
	let l:params['contentFormat'] = ['plaintext']
	return l:params
endfunction

function lsp#SignatureHelpClientCapabilities()
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

function lsp#DeclarationClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['linkSupport'] = v:false
	return l:params
endfunction

function lsp#DefinitionClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['linkSupport'] = v:false
	return l:params
endfunction

function lsp#TypeDefinitionClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['linkSupport'] = v:false
	return l:params
endfunction

function lsp#ImplementationClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['linkSupport'] = v:false
	return l:params
endfunction

function lsp#ReferenceClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#DocumentHighlightClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#DocumentSymbolClientCapabilities()
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

function lsp#CodeActionClientCapabilities()
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

function lsp#CodeLensClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#DocumentLinkClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['tooltipSupport'] = v:false
	return l:params
endfunction

function lsp#DocumentColorClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#DocumentFormattingClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#DocumentRangeFormattingClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#DocumentOnTypeFormattingClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#RenameClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['prepareSupport'] = v:false
	let l:params['prepareSupportDefaultBehavior'] = 1
	let l:params['honorsChangeAnnotations'] = v:false
	return l:params
endfunction

function lsp#PublishDiagnosticsClientCapabilities()
	let l:params = {}
	let l:params['relatedInformation'] = v:false
	let l:params['tagSupport'] = {}
	let l:params['tagSupport']['valueSet'] = [1]
	let l:params['versionSupport'] = v:false
	let l:params['codeDescriptionSupport'] = v:false
	let l:params['dataSupport'] = v:false
	return l:params
endfunction

function lsp#FoldingRangeClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['rangeLimit'] = 0
	let l:params['lineFoldingOnly'] = v:true
	return l:params
endfunction

function lsp#SelectionRangeClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#LinkedEditingRangeClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#CallHierarchyClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#SemanticTokensClientCapabilities()
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

function lsp#MonikerClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#PrepareSupportDefaultBehavior()
	let l:params = {}
	let l:params['Identifier'] = 1
	return l:params
endfunction

function lsp#WorkDoneProgressParams(workDoneToken)
	let l:workDoneProgressParams = {}
	if !util#isNone(a:workDoneToken)
		let l:workDoneProgressParams['workDoneToken'] = a:workDoneToken
	endif
	return l:workDoneProgressParams
endfunction
