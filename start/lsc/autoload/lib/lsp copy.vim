let lib#lsp#DiagnosticSeverity = {}
let lib#lsp#DiagnosticSeverity['Error'] = 1
let lib#lsp#DiagnosticSeverity['Warning'] = 2
let lib#lsp#DiagnosticSeverity['Information'] = 3
let lib#lsp#DiagnosticSeverity['Hint'] = 4

let lib#lsp#ErrorCodes = {}
let lib#lsp#ErrorCodes['ParseError'] = -32700
let lib#lsp#ErrorCodes['InvalidRequest'] = -32600
let lib#lsp#ErrorCodes['MethodNotFound'] = -32601
let lib#lsp#ErrorCodes['InvalidParams'] = -32602
let lib#lsp#ErrorCodes['InternalError'] = -32603
let lib#lsp#ErrorCodes['jsonrpcReservedErrorRangeStart'] = -32099
let lib#lsp#ErrorCodes['serverErrorStart'] = lsp#ErrorCodes['jsonrpcReservedErrorRangeStart']
let lib#lsp#ErrorCodes['ServerNotInitialized'] = -32002
let lib#lsp#ErrorCodes['UnknownErrorCode'] = -32001
let lib#lsp#ErrorCodes['jsonrpcReservedErrorRangeEnd'] = -32000
let lib#lsp#ErrorCodes['serverErrorEnd'] = lsp#ErrorCodes['jsonrpcReservedErrorRangeEnd']
let lib#lsp#ErrorCodes['lspReservedErrorRangeStart'] = -32899
let lib#lsp#ErrorCodes['ServerCancelled'] = -32802
let lib#lsp#ErrorCodes['ContentModified'] = -32801
let lib#lsp#ErrorCodes['RequestCancelled'] = -32800
let lib#lsp#ErrorCodes['lspReservedErrorRangeEnd'] = -32800

function lib#lsp#CompletionTriggerKind()
	let l:CompletionTriggerKind = {}
	let l:CompletionTriggerKind['Invoked'] = 1
	let l:CompletionTriggerKind['TriggerCharacter'] = 2
	let l:CompletionTriggerKind['TriggerForIncompleteCompletions'] = 3
	return l:CompletionTriggerKind
endfunction

function lib#lsp#CodeActionKind()
	let l:CodeActionKind = {}
	let l:CodeActionKind['Empty'] = ''
	let l:CodeActionKind['QuickFix'] = 'quickfix'
	let l:CodeActionKind['Refactor'] = 'refactor'
	let l:CodeActionKind['RefactorExtract'] = 'refactor.extract'
	let l:CodeActionKind['RefactorInline'] = 'refactor.inline'
	let l:CodeActionKind['RefactorRewrite'] = 'refactor.rewrite'
	let l:CodeActionKind['Source'] = 'source'
	let l:CodeActionKind['SourceOrganizeImports'] = 'source.organizeImports'
	return l:CodeActionKind
endfunction

function lib#lsp#InitializeParams(initializationOptions, workspaceFolders, token)
	let l:params = {}
	call extend(l:params, lib#lsp#WorkDoneProgressParams(a:token))
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
	let l:params['capabilities'] = lib#lsp#ClientCapabilities()
	let l:params['trace'] = "verbose" " 'off' | 'messages' | 'verbose'
	if !util#isNone(a:workspaceFolders)
		let l:params['workspaceFolders'] = a:workspaceFolders
	endif
	return l:params
endfunction

function lib#lsp#InitializedParams()
	let l:params = {}
	return l:params
endfunction

function lib#lsp#DidOpenTextDocumentParams(path, languageId, version, text)
	let l:params = {}
	let l:params['textDocument'] = lib#lsp#TextDocumentItem(a:path, a:languageId, a:version, a:text)
	return l:params
endfunction

function lib#lsp#DidChangeTextDocumentParams(path, version, contentChanges)
	let l:params = {}
	let l:params['textDocument'] = lib#lsp#VersionedTextDocumentIdentifier(a:path, a:version)
	let l:params['contentChanges'] = a:contentChanges
	return l:params
endfunction

function lib#lsp#DidCloseTextDocumentParams(path)
	let l:params = {}
	let l:params['textDocument'] = lib#lsp#TextDocumentIdentifier(a:path)
	return l:params
endfunction

function lib#lsp#DidSaveTextDocumentParams(path, text)
	let l:params = {}
	let l:params['textDocument'] = lib#lsp#TextDocumentIdentifier(a:path)
	if !util#isNone(a:text)
		let l:params['text'] = a:text
	endif
	return l:params
endfunction

function lib#lsp#HoverParams(path, position, token)
	let l:hoverParams = {}
	call extend(l:hoverParams, lib#lsp#TextDocumentPositionParams(a:path, a:position))
	call extend(l:hoverParams, lib#lsp#WorkDoneProgressParams(a:token))
	return l:hoverParams
endfunction

function lib#lsp#TextDocumentPositionParams(path, position)
	let l:params = {}
	let l:params['textDocument'] = lib#lsp#TextDocumentIdentifier(a:path)
	let l:params['position'] = a:position
	return l:params
endfunction

function lib#lsp#VersionedTextDocumentIdentifier(path, version)
	let l:params = {}
	call extend(l:params, lib#lsp#TextDocumentIdentifier(a:path))
	let l:params['version'] = a:version
	return l:params
endfunction

function lib#lsp#TextDocumentIdentifier(path)
	let l:params = {}
	let l:params['uri'] = lib#lsp#DocumentUri('file', v:none, a:path, v:none, v:none)
	return l:params
endfunction

function lib#lsp#TextDocumentContentChangeEvent(range, text)
	let l:params = {}
	if !util#isNone(a:range)
		let l:params['range'] = a:range
	endif
	" let l:params['rangeLength'] = 0 " @deprecated
	let l:params['text'] = a:text
	return l:params
endfunction

function lib#lsp#DefinitionParams(path, position, workDoneToken, partialResultToken)
	let l:params = {}
	call extend(l:params, lib#lsp#TextDocumentPositionParams(a:path, a:position))
	call extend(l:params, lib#lsp#WorkDoneProgressParams(a:workDoneToken))
	call extend(l:params, lib#lsp#PartialResultParams(a:partialResultToken))
	return l:params
endfunction

function lib#lsp#ReferenceParams(path, position, context, workDoneToken, partialResultToken)
	let l:params = {}
	call extend(l:params, lib#lsp#TextDocumentPositionParams(a:path, a:position))
	call extend(l:params, lib#lsp#WorkDoneProgressParams(a:workDoneToken))
	call extend(l:params, lib#lsp#PartialResultParams(a:partialResultToken))
	let l:params['context'] = a:context
	return l:params
endfunction

function lib#lsp#ImplementationParams(path, position, workDoneToken, partialResultToken)
	let l:params = {}
	call extend(l:params, lib#lsp#TextDocumentPositionParams(a:path, a:position))
	call extend(l:params, lib#lsp#WorkDoneProgressParams(a:workDoneToken))
	call extend(l:params, lib#lsp#PartialResultParams(a:partialResultToken))
	return l:params
endfunction

function lib#lsp#ReferenceContext(includeDeclaration)
	let l:params = {}
	let l:params['includeDeclaration'] = a:includeDeclaration
	return l:params
endfunction

function lib#lsp#CompletionParams(context, path, position, workDoneToken, partialResultToken)
	let l:params = {}
	call extend(l:params, lib#lsp#TextDocumentPositionParams(a:path, a:position))
	call extend(l:params, lib#lsp#WorkDoneProgressParams(a:workDoneToken))
	call extend(l:params, lib#lsp#PartialResultParams(a:partialResultToken))
	if !util#isNone(a:context)
		let l:params['context'] = a:context
	endif
	return l:params
endfunction

function lib#lsp#CompletionContext(triggerKind, triggerCharacter)
	let l:params = {}
	let l:params['triggerKind'] = a:triggerKind
	if !util#isNone(a:triggerCharacter)
		let l:params['triggerCharacter'] = a:triggerCharacter
	endif
	return l:params
endfunction

function lib#lsp#CompletionItem()
endfunction

function lib#lsp#CodeLensParams(path, workDoneToken, partialResultToken)
	let l:params = {}
	call extend(l:params, lib#lsp#WorkDoneProgressParams(a:workDoneToken))
	call extend(l:params, lib#lsp#PartialResultParams(a:partialResultToken))
	let l:params['textDocument'] = lib#lsp#TextDocumentIdentifier(a:path)
	return l:params
endfunction

function lib#lsp#CodeActionParams(path, range, context, workDoneToken, partialResultToken)
	let l:params = {}
	call extend(l:params, lib#lsp#WorkDoneProgressParams(a:workDoneToken))
	call extend(l:params, lib#lsp#PartialResultParams(a:partialResultToken))
	let l:params['textDocument'] = lib#lsp#TextDocumentIdentifier(a:path)
	let l:params['range'] = a:range
	let l:params['context'] = a:context
	return l:params
endfunction

function lib#lsp#CodeActionContext(diagnostics, kind)
	let l:params = {}
	let l:params['diagnostics'] = a:diagnostics
	if !util#isNone(a:kind)
		let l:params['only'] = a:kind
	endif
	return l:params
endfunction

function lib#lsp#DocumentSymbolParams(path, workDoneToken, partialResultToken)
	let l:params = {}
	call extend(l:params, lib#lsp#WorkDoneProgressParams(a:workDoneToken))
	call extend(l:params, lib#lsp#PartialResultParams(a:partialResultToken))
	let l:params['textDocument'] = lib#lsp#TextDocumentIdentifier(a:path)
	return l:params
endfunction

function lib#lsp#WorkDoneProgressParams(workDoneToken)
	let l:workDoneProgressParams = {}
	if !util#isNone(a:workDoneToken)
		let l:workDoneProgressParams['workDoneToken'] = a:workDoneToken
	endif
	return l:workDoneProgressParams
endfunction

function lib#lsp#PartialResultParams(progressToken)
	let l:params = {}
	if !util#isNone(a:progressToken)
		let l:params['partialResultToken'] = a:progressToken
	endif
	return l:params
endfunction

function lib#lsp#Range(start, end)
	let l:range = {}
	let l:range['start'] = a:start
	let l:range['end'] = a:end
	return l:range
endfunction

function lib#lsp#Position(line, character)
	let l:position = {}
	let l:position['line'] = a:line
	let l:position['character'] = a:character
	return l:position
endfunction

function lib#lsp#TextDocumentItem(path, languageId, version, text)
	let l:params = {}
	let l:params['uri'] = lib#lsp#DocumentUri('file', v:none, a:path, v:none, v:none)
	let l:params['languageId'] = a:languageId
	let l:params['version'] = a:version
	let l:params['text'] = a:text
	return l:params
endfunction

function lib#lsp#DocumentUri(scheme, authority, path, query, fragment)
	return lib#lsp#Uri(a:scheme, a:authority, a:path, a:query, a:fragment)
endfunction

function lib#lsp#Uri(scheme, authority, path, query, fragment)
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

function lib#lsp#WorkspaceFolder(path, name)
	let l:params = {}
	let l:params['uri'] = lib#lsp#DocumentUri('file', v:none, a:path, v:none, v:none)
	let l:params['name'] = a:name
	return l:params
endfunction

function lib#lsp#ClientCapabilities()
	let l:params = {}
	let l:params['workspace'] = {}
	let l:params['workspace']['applyEdit'] = v:false
	let l:params['workspace']['workspaceEdit'] = lib#lsp#WorkspaceEditClientCapabilities()
	let l:params['workspace']['didChangeConfiguration'] = lib#lsp#DidChangeConfigurationClientCapabilities()
	let l:params['workspace']['didChangeWatchedFiles'] = lib#lsp#DidChangeWatchedFilesClientCapabilities()
	let l:params['workspace']['symbol'] = lib#lsp#WorkspaceSymbolClientCapabilities()
	let l:params['workspace']['executeCommand'] = lib#lsp#ExecuteCommandClientCapabilities()
	let l:params['workspace']['workspaceFolders'] = v:true
	let l:params['workspace']['configuration'] = v:true
	let l:params['workspace']['semanticTokens'] = lib#lsp#SemanticTokensWorkspaceClientCapabilities()
	let l:params['workspace']['codeLens'] = lib#lsp#CodeLensWorkspaceClientCapabilities()
	let l:params['workspace']['fileOperations'] = {}
	let l:params['workspace']['fileOperations']['dynamicRegistration'] = v:false
	let l:params['workspace']['fileOperations']['didCreate'] = v:false
	let l:params['workspace']['fileOperations']['willCreate'] = v:false
	let l:params['workspace']['fileOperations']['didRename'] = v:false
	let l:params['workspace']['fileOperations']['willRename'] = v:false
	let l:params['workspace']['fileOperations']['didDelete'] = v:false
	let l:params['workspace']['fileOperations']['willDelete'] = v:false
	let l:params['textDocument'] = lib#lsp#TextDocumentClientCapabilities()
	let l:params['window'] = {}
	let l:params['window']['workDoneProgress'] = v:true
	let l:params['window']['showMessage'] = lib#lsp#ShowMessageRequestClientCapabilities()
	let l:params['window']['showDocument'] = lib#lsp#ShowDocumentClientCapabilities()
	let l:params['general'] = {}
	let l:params['general']['staleRequestSupport'] = {}
	let l:params['general']['staleRequestSupport']['cancel'] = v:false
	let l:params['general']['staleRequestSupport']['retryOnContentModified'] = [""]
	let l:params['general']['regularExpressions'] = lib#lsp#RegularExpressionsClientCapabilities()
	let l:params['general']['markdown'] = lib#lsp#MarkdownClientCapabilities()
	let l:params['experimental'] = v:null
	return l:params
endfunction

function lib#lsp#WorkspaceEditClientCapabilities()
	let l:params = {}
	let l:params['documentChanges'] = v:false
	let l:params['resourceOperations'] = [] " ['create', 'rename', 'delete']
	let l:params['failureHandling'] = "abort" " 'abort' | 'transactional' | 'undo' | 'textOnlyTransactional'
	let l:params['normalizesLineEndings'] = v:false
	let l:params['changeAnnotationSupport'] = {}
	let l:params['changeAnnotationSupport']['groupsOnLabel'] = v:false
	return l:params
endfunction

function lib#lsp#DidChangeConfigurationClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:true
	return l:params
endfunction

function lib#lsp#DidChangeWatchedFilesClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lib#lsp#WorkspaceSymbolClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['symbolKind'] = {}
	let l:params['symbolKind']['valueSet'] = []
	let l:params['tagSupport'] = {}
	let l:params['tagSupport']['valueSet'] = []
	return l:params
endfunction

function lib#lsp#ExecuteCommandClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lib#lsp#SemanticTokensWorkspaceClientCapabilities()
	let l:params = {}
	let l:params['refreshSupport'] = v:false
	return l:params
endfunction

function lib#lsp#CodeLensWorkspaceClientCapabilities()
	let l:params = {}
	let l:params['refreshSupport'] = v:false
	return l:params
endfunction

function lib#lsp#TextDocumentClientCapabilities()
	let l:params = {}
	let l:params['synchronization'] = lib#lsp#TextDocumentSyncClientCapabilities()
	let l:params['completion'] = lib#lsp#CompletionClientCapabilities()
	let l:params['hover'] = lib#lsp#HoverClientCapabilities()
	let l:params['signatureHelp'] = lib#lsp#SignatureHelpClientCapabilities()
	let l:params['declaration'] = lib#lsp#DeclarationClientCapabilities()
	let l:params['definition'] = lib#lsp#DefinitionClientCapabilities()
	let l:params['typeDefinition'] = lib#lsp#TypeDefinitionClientCapabilities()
	let l:params['implementation'] = lib#lsp#ImplementationClientCapabilities()
	let l:params['references'] = lib#lsp#ReferenceClientCapabilities()
	let l:params['documentHighlight'] = lib#lsp#DocumentHighlightClientCapabilities()
	let l:params['documentSymbol'] = lib#lsp#DocumentSymbolClientCapabilities()
	let l:params['codeAction'] = lib#lsp#CodeActionClientCapabilities()
	let l:params['codeLens'] = lib#lsp#CodeLensClientCapabilities()
	let l:params['documentLink'] = lib#lsp#DocumentLinkClientCapabilities()
	let l:params['colorProvider'] = lib#lsp#DocumentColorClientCapabilities()
	let l:params['formatting'] = lib#lsp#DocumentFormattingClientCapabilities()
	let l:params['rangeFormatting'] = lib#lsp#DocumentRangeFormattingClientCapabilities()
	let l:params['onTypeFormatting'] = lib#lsp#DocumentOnTypeFormattingClientCapabilities()
	let l:params['rename'] = lib#lsp#RenameClientCapabilities()
	let l:params['publishDiagnostics'] = lib#lsp#PublishDiagnosticsClientCapabilities()
	let l:params['foldingRange'] = lib#lsp#FoldingRangeClientCapabilities()
	let l:params['selectionRange'] = lib#lsp#SelectionRangeClientCapabilities()
	let l:params['linkedEditingRange'] = lib#lsp#LinkedEditingRangeClientCapabilities()
	let l:params['callHierarchy'] = lib#lsp#CallHierarchyClientCapabilities()
	let l:params['semanticTokens'] = lib#lsp#SemanticTokensClientCapabilities()
	let l:params['moniker'] = lib#lsp#MonikerClientCapabilities()
	return l:params
endfunction

function lib#lsp#ShowMessageRequestClientCapabilities()
	let l:params = {}
	let l:params['messageActionItem'] = {}
	let l:params['messageActionItem']['additionalPropertiesSupport'] = v:false
	return l:params
endfunction

function lib#lsp#ShowDocumentClientCapabilities()
	let l:params = {}
	let l:params['support'] = v:false
	return l:params
endfunction

function lib#lsp#RegularExpressionsClientCapabilities()
	let l:params = {}
	let l:params['engine'] = ""
	let l:params['version'] = "0.0"
	return l:params
endfunction

function lib#lsp#MarkdownClientCapabilities()
	let l:params = {}
	let l:params['parser'] = ""
	let l:params['version'] = "0.0"
	return l:params
endfunction

function lib#lsp#TextDocumentSyncClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['willSave'] = v:false
	let l:params['willSaveWaitUntil'] = v:false
	let l:params['didSave'] = v:true
	return l:params
endfunction

function lib#lsp#CompletionClientCapabilities()
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

function lib#lsp#HoverClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:true
	let l:params['contentFormat'] = ['plaintext']
	return l:params
endfunction

function lib#lsp#SignatureHelpClientCapabilities()
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

function lib#lsp#DeclarationClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['linkSupport'] = v:false
	return l:params
endfunction

function lib#lsp#DefinitionClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['linkSupport'] = v:false
	return l:params
endfunction

function lib#lsp#TypeDefinitionClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['linkSupport'] = v:false
	return l:params
endfunction

function lib#lsp#ImplementationClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['linkSupport'] = v:false
	return l:params
endfunction

function lib#lsp#ReferenceClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lib#lsp#DocumentHighlightClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lib#lsp#DocumentSymbolClientCapabilities()
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

function lib#lsp#CodeActionClientCapabilities()
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

function lib#lsp#CodeLensClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lib#lsp#DocumentLinkClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['tooltipSupport'] = v:false
	return l:params
endfunction

function lib#lsp#DocumentColorClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lib#lsp#DocumentFormattingClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lib#lsp#DocumentRangeFormattingClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lib#lsp#DocumentOnTypeFormattingClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lib#lsp#RenameClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['prepareSupport'] = v:false
	let l:params['prepareSupportDefaultBehavior'] = 1
	let l:params['honorsChangeAnnotations'] = v:false
	return l:params
endfunction

function lib#lsp#PublishDiagnosticsClientCapabilities()
	let l:params = {}
	let l:params['relatedInformation'] = v:false
	let l:params['tagSupport'] = {}
	let l:params['tagSupport']['valueSet'] = [1]
	let l:params['versionSupport'] = v:false
	let l:params['codeDescriptionSupport'] = v:false
	let l:params['dataSupport'] = v:false
	return l:params
endfunction

function lib#lsp#FoldingRangeClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['rangeLimit'] = 0
	let l:params['lineFoldingOnly'] = v:true
	return l:params
endfunction

function lib#lsp#SelectionRangeClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lib#lsp#LinkedEditingRangeClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lib#lsp#CallHierarchyClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lib#lsp#SemanticTokensClientCapabilities()
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

function lib#lsp#MonikerClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lib#lsp#PrepareSupportDefaultBehavior()
	let l:params = {}
	let l:params['Identifier'] = 1
	return l:params
endfunction
