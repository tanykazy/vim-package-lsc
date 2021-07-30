if exists("g:loaded_lsp")
	finish
endif
let g:loaded_lsp = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


let s:rn = "\r\n"

function lsp#initialize()
	let l:init = s:InitializeParams({}, getpid(),v:null,v:null,v:null,v:null,v:null,{},'verbose',v:null)
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

function RegularExpressionsClientCapabilities(engine, varsion)
endfunction

function s:InitializeParams(params, processId, clientInfo,locale, rootPath, rootUri, initializationOptions, capabilities, trace, workspaceFolders)
	let a:params = {
				\ 'processId': a:processId,
				\ 'rootPath': a:rootPath,
				\ 'rootUri': a:rootUri,
				\ 'initializationOptions': a:initializationOptions,
				\ 'capabilities': a:capabilities,
				\ 'trace': a:trace,
				\ 'workspaceFolders': a:workspaceFolders}
				" \ 'clientInfo': 
				" \ 'name':
				" \ 'version':
				" \ 'locale'
	return a:parama
endfunction

function s:ClientInfo(name, version)
endfunction

function s:ClientCapabilities()
let l:clientCapabilities = {
	" 'applyEdit'
	" 'workspaceEdit'
	" 'didChangeConfiguration'
	" 'didChangeWatchedFiles'
	" 'symbol'
	" 'executeCommand'
	" 'workspaceFolders'
	" 'configuration'
	" 'semanticTokens'
	" 'codeLens'
	" 'fileOperations': {
	" 	'dynamicRegistration'
	" 	'didCreate'
	" 	'willCreate'
	" 	'didRename'
	" 	'willRename'
	" 	'didDelete'
	" 	'willDelete'
	" },
	" 'textDocument'
	" 'window':{
	" 	'workDoneProgress'
	" 	'showMessage'
	" 	'showDocument'
	" },
	" 'general':{
	" 	'staleRequestSupport'{
	" 		'cancel'
	" 		'retryOnContentModified'
	" 	},
	" 	'regularExpressions'
	" 	'markdown'
	" },
	" 'experimental'
}
endfunction

function s:WorkspaceEditClientCapabilities()
let l:workspaceEditClientCapabilities = {
	" 'documentChanges'
	" 'resourceOperations'
	" 'failureHandling'
	" 'normalizesLineEndings'
	" 'changeAnnotationSupport':{
	" 	'groupsOnLabel'
	" }
}
endfunction

function s:DidChangeConfigurationClientCapabilities()
let l:didChangeConfigurationClientCapabilities = {
	" 'dynamicRegistration'
}
endfunction

function s:DidChangeWatchedFilesClientCapabilities()
let l:didChangeWatchedFilesClientCapabilities = {
	" 'dynamicRegistration'
}
endfunction


function s:WorkspaceSymbolClientCapabilities()
let l:workspaceSymbolClientCapabilities={
	" 'dynamicRegistration'
	" 'symbolKind':{
	" 	'valueSet'
	" },
	" 'tagSupport':{
	" 	'valueSet'
	" }
}
endfunction

function s:ExecuteCommandClientCapabilities()
let l:executeCommandClientCapabilities = {
	" 'dynamicRegistration'
}
endfunction

function s:SemanticTokensWorkspaceClientCapabilities()
let l:semanticTokensWorkspaceClientCapabilities = {
	" 'refreshSupport'
}
endfunction

function s:CodeLensWorkspaceClientCapabilities()
let l:codeLensWorkspaceClientCapabilities = {
	" 'refreshSupport'
}
endfunction

function s:TextDocumentClientCapabilities()
let l:textDocumentClientCapabilities = {
	" 'synchronization'
	" 'completion'
	" 'hover'
	" 'signatureHelp'
	" 'declaration'
	" 'definition'
	" 'typeDefinition'
	" 'implementation'
	" 'references'
	" 'documentHighlight'
	" 'documentSymbol'
	" 'codeAction'
	" 'codeLens'
	" 'documentLink'
	" 'colorProvider'
	" 'formatting'
	" 'rangeFormatting'
	" 'onTypeFormatting'
	" 'rename'
	" 'publishDiagnostics'
	" 'foldingRange'
	" 'selectionRange'
	" 'linkedEditingRange'
	" 'callHierarchy'
	" 'semanticTokens'
	" 'moniker'
}
endfunction

function s:TextDocumentSyncClientCapabilities()
let l:TextDocumentSyncClientCapabilities = {
	'dynamicRegistration'
	'willSave'
	'willSaveWaitUntil'
	'didSave'
}
endfunction

function s:CompletionClientCapabilities()
let l:CompletionClientCapabilities = {
	''	
}
endfunction

function s:HoverClientCapabilities()
let l:HoverClientCapabilities = {
	'dynamicRegistration'	
	'contentFormat'
}
endfunction

function s:SignatureHelpClientCapabilities()
let l:SignatureHelpClientCapabilities = {
	'dynamicRegistration'	
	'signatureInformation'

}
endfunction

function s:DeclarationClientCapabilities()
let l:DeclarationClientCapabilities = {
	
}
endfunction

function s:DefinitionClientCapabilities()
let l:DefinitionClientCapabilities = {
	
}
endfunction

function s:TypeDefinitionClientCapabilities()
let l:TypeDefinitionClientCapabilities = {
	
}
endfunction

function s:ImplementationClientCapabilities()
let l:ImplementationClientCapabilities = {
	
}
endfunction

function s:ReferenceClientCapabilities()
let l:ReferenceClientCapabilities = {
	
}
endfunction

function s:DocumentHighlightClientCapabilities()
let l:DocumentHighlightClientCapabilities = {
	
}
endfunction

function s:DocumentSymbolClientCapabilities()
let l:DocumentSymbolClientCapabilities = {
	
}
endfunction

function s:CodeActionClientCapabilities()
let l:CodeActionClientCapabilities = {
	
}
endfunction

function s:CodeLensClientCapabilities()
let l:CodeLensClientCapabilities = {
	
}
endfunction

function s:DocumentLinkClientCapabilities()
let l:DocumentLinkClientCapabilities = {
	
}
endfunction

function s:DocumentColorClientCapabilities()
let l:DocumentColorClientCapabilities = {
	
}
endfunction

function s:DocumentFormattingClientCapabilities()
let l:DocumentFormattingClientCapabilities = {
	
}
endfunction

function s:DocumentRangeFormattingClientCapabilities()
let l:DocumentRangeFormattingClientCapabilities = {
	
}
endfunction

function s:DocumentOnTypeFormattingClientCapabilities()
let l:DocumentOnTypeFormattingClientCapabilities = {
	
}
endfunction

function s:RenameClientCapabilities()
let l:RenameClientCapabilities = {
	
}
endfunction

function s:PublishDiagnosticsClientCapabilities()
let l:PublishDiagnosticsClientCapabilities = {
	
}
endfunction

function s:FoldingRangeClientCapabilities()
let l:FoldingRangeClientCapabilities = {
	
}
endfunction

function s:SelectionRangeClientCapabilities()
let l:SelectionRangeClientCapabilities = {
	
}
endfunction

function s:LinkedEditingRangeClientCapabilities()
let l:LinkedEditingRangeClientCapabilities = {
	
}
endfunction

function s:CallHierarchyClientCapabilities()
let l:CallHierarchyClientCapabilities = {
	
}
endfunction

function s:SemanticTokensClientCapabilities()
let l:SemanticTokensClientCapabilities = {
	
}
endfunction

function s:MonikerClientCapabilities()
let l:MonikerClientCapabilities = {
	
}
endfunction






function s:WorkDoneProgressParams(params, progressToken)
	let a:params['workDoneToken'] = a:porkDoneToken
	return a:params
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
