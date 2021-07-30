if exists("g:loaded_lsp")
	finish
endif
let g:loaded_lsp = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


let s:rn = "\r\n"

function lsp#initialize()
	let l:init = s:InitializeParams({}, v:null, v:null)
	return s:BuildMessage(1, 'initialize', l:init)
endfunction

function s:BuildMessage(id, method, params)
	let l:message = s:Message({})
	let l:message = s:RequestMessage(l:message, a:id, a:method, a:params)	
	let l:content = json_encode(l:message)
	let l:header = s:BuildHeader(l:content)
	return l:header . s:rn . l:content
endfunction

function s:BuildHeader(content)
	return 'Content-Length: ' . len(a:content) . s:rn
endfunction

function s:BuildContent()
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
	let l:workspaceFolder = {
		" 'uri'
		" 'name'
	}
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
	let l:params['tagSupport']['valueSet'] = []
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

function RegularExpressionsClientCapabilities()
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
let l:TextDocumentSyncClientCapabilities = {
	" 'dynamicRegistration'
	" 'willSave'
	" 'willSaveWaitUntil'
	" 'didSave'
}
endfunction

function s:CompletionClientCapabilities()
let l:CompletionClientCapabilities = {
	" 'dynamicRegistration'	
	" 'completionItem':{
	" 	'snippetSupport'
	" 	'commitCharactersSupport'
	" 	'documentationFormat'
	" 	'deprecatedSupport'
	" 	'preselectSupport'
	" 	'tagSupport':{
	" 		'valueSet'
	" 	}
	" 	'insertReplaceSupport'
	" 	'resolveSupport':{
	" 		'properties'
	" 	}
	" 	'insertTextModeSupport':{
	" 		'valueSet'
	" 	}
	" 	'labelDetailsSupport'
	" }
	" 'completionItemKind':{
	" 	'valueSet'
	" }
	" 'contextSupport'
	" 'insertTextMode'
}
endfunction

function s:HoverClientCapabilities()
let l:HoverClientCapabilities = {
	" 'dynamicRegistration'	
	" 'contentFormat'
}
endfunction

function s:SignatureHelpClientCapabilities()
let l:SignatureHelpClientCapabilities = {
	" 'dynamicRegistration'	
	" 'signatureInformation':{
	" 	'documentationFormat'
	" 	'parameterInformation':{
	" 		'labelOffsetSupport'
	" 	}
	" 	'activeParameterSupport'
	" }
	" 'contextSupport'
}
endfunction

function s:DeclarationClientCapabilities()
let l:DeclarationClientCapabilities = {
	" 'dynamicRegistration'
	" 'linkSupport'
}
endfunction

function s:DefinitionClientCapabilities()
let l:DefinitionClientCapabilities = {
	" 'dynamicRegistration'
	" 'linkSupport'
}
endfunction

function s:TypeDefinitionClientCapabilities()
let l:TypeDefinitionClientCapabilities = {
	" 'dynamicRegistration'
	" 'linkSupport'
}
endfunction

function s:ImplementationClientCapabilities()
let l:ImplementationClientCapabilities = {
	" 'dynamicRegistration'
	" 'linkSupport'
}
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
let l:DocumentSymbolClientCapabilities = {
	" 'dynamicRegistration'
	" 'symbolKind':{
	" 	'valueSet'
	" }
	" 'hierarchicalDocumentSymbolSupport'
	" 'tagSupport'{
	" 	'valueSet'
	" }
	" 'labelSupport'
}
endfunction

function s:CodeActionClientCapabilities()
let l:CodeActionClientCapabilities = {
	" 'dynamicRegistration'
	" 'codeActionLiteralSupport':{
	" 	'codeActionKind':{
	" 		'valueSet'
	" 	}
	" }
	" 'isPreferredSupport'
	" 'disabledSupport'
	" 'dataSupport'
	" 'resolveSupport':{
	" 	'properties'
	" }
	" 'honorsChangeAnnotations'
}
endfunction

function s:CodeLensClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function s:DocumentLinkClientCapabilities()
let l:DocumentLinkClientCapabilities = {
	" 'dynamicRegistration'
	" 'tooltipSupport'
}
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
let l:RenameClientCapabilities = {
	" 'dynamicRegistration'
	" 'prepareSupport'
	" 'prepareSupportDefaultBehavior'
	" 'honorsChangeAnnotations'
}
endfunction

function s:PublishDiagnosticsClientCapabilities()
let l:PublishDiagnosticsClientCapabilities = {
	" 'relatedInformation'
	" 'tagSupport':{
	" 	'valueSet'
	" }
	" 'versionSupport'
	" 'codeDescriptionSupport'
	" 'dataSupport'
}
endfunction

function s:FoldingRangeClientCapabilities()
let l:FoldingRangeClientCapabilities = {
	" 'dynamicRegistration'
	" 'rangeLimit'
	" 'lineFoldingOnly'
}
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
let l:SemanticTokensClientCapabilities = {
	" 'dynamicRegistration'
	" 'requests':{
	" 	'range'
	" 	'full'
	" }
	" 'tokenTypes'
	" 'tokenModifiers'
	" 'formats'
	" 'overlappingTokenSupport'
	" 'multilineTokenSupport'
}
endfunction

function s:MonikerClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function s:PrepareSupportDefaultBehavior()
let l:prepareSupportDefaultBehavior = {
	" 'Identifier'
}
endfunction

function s:WorkDoneProgressParams(params, progressToken)
	let a:params['workDoneToken'] = a:porkDoneToken
	return a:params
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
