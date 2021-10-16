" Base Protocol

" https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#headerPart
function lsp#lsp#Header(length, type = 'charset=utf-8')
	let l:header = {}
	" The length of the content part in bytes.
	" This header is required.
	let l:header['Content-Length'] = a:length
	" The mime type of the content part.
	" Defaults to application/vscode-jsonrpc; charset=utf-8
	let l:header['Content-Type'] = a:type
	return l:header
endfunction

" https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#contentPart
function lsp#lsp#Content(content, encoding = 'utf-8')
	return iconv(s:serialize_content(a:content), &encoding, a:encoding)
endfunction

" The language server protocol always uses “2.0” as the jsonrpc version.
const s:version = '2.0'

" https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#message
function lsp#lsp#Message(version = '2.0')
	let l:message = {}
	" let l:message['jsonrpc'] = s:version
	let l:message['jsonrpc'] = a:version
	return l:message
endfunction

" https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#requestMessage
function lsp#lsp#RequestMessage(id, method, params = v:none)
	let l:message = lsp#lsp#Message()
	" The request id.
	let l:message['id'] = a:id
	" The method to be invoked.
	let l:message['method'] = a:method
	" The method's params.
	if a:params != v:none
		let l:message['params'] = a:params
	endif
	return l:message
endfunction

" https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#responseMessage
function lsp#lsp#ResponseMessage(id, result = v:none, error = v:none)
	let l:message = lsp#lsp#Message()
	" The request id.
	let l:message['id'] = a:id
	" The result of a request. This member is REQUIRED on success.
	" This member MUST NOT exist if there was an error invoking the method.
	if a:result != v:none
		let l:message['result'] = a:result
	endif
	" The error object in case a request fails.
	if a:error != v:none
		let l:message['error'] = a:error
	endif
	return l:message
endfunction

" https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#responseError
function lsp#lsp#ResponseError(code, message, data = v:none)
	let l:error = {}
	" A number indicating the error type that occurred.
	let l:error['code'] = a:code
	" A string providing a short description of the error.
	let l:error['message'] = a:message
	" A primitive or structured value that contains additional information about the error. Can be omitted.
	if a:data != v:none
		let l:error['data'] = a:data
	endif
	return l:error
endfunction

" https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#errorCodes
let lsp#lsp#ErrorCodes = {}
" Defined by JSON RPC
let lsp#lsp#ErrorCodes['ParseError'] = -32700
let lsp#lsp#ErrorCodes['InvalidRequest'] = -32600
let lsp#lsp#ErrorCodes['MethodNotFound'] = -32601
let lsp#lsp#ErrorCodes['InvalidParams'] = -32602
let lsp#lsp#ErrorCodes['InternalError'] = -32603
" This is the start range of JSON RPC reserved error codes.
" It doesn't denote a real error code. No LSP error codes should be defined between the start and end range. For backwards compatibility the `ServerNotInitialized` and the `UnknownErrorCode` are left in the range.
let lsp#lsp#ErrorCodes['jsonrpcReservedErrorRangeStart'] = -32099
let lsp#lsp#ErrorCodes['serverErrorStart'] = lsp#lsp#ErrorCodes['jsonrpcReservedErrorRangeStart']
" Error code indicating that a server received a notification or request before the server has received the `initialize` request.
let lsp#lsp#ErrorCodes['ServerNotInitialized'] = -32002
let lsp#lsp#ErrorCodes['UnknownErrorCode'] = -32001
" This is the end range of JSON RPC reserved error codes. It doesn't denote a real error code.
let lsp#lsp#ErrorCodes['jsonrpcReservedErrorRangeEnd'] = -32000
let lsp#lsp#ErrorCodes['serverErrorEnd'] = lsp#lsp#ErrorCodes['jsonrpcReservedErrorRangeEnd']
" This is the start range of LSP reserved error codes. It doesn't denote a real error code.
let lsp#lsp#ErrorCodes['lspReservedErrorRangeStart'] = -32899
" A request failed but it was syntactically correct, e.g the method name was known and the parameters were valid. The error message should contain human readable information about why the request failed.
let lsp#lsp#ErrorCodes['RequestFailed'] = -32803
" The server cancelled the request. This error code should only be used for requests that explicitly support being server cancellable.
let lsp#lsp#ErrorCodes['ServerCancelled'] = -32802
" The server detected that the content of a document got modified outside normal conditions. A server should NOT send this error code if it detects a content change in it unprocessed messages. The result even computed on an older state might still be useful for the client.
" If a client decides that a result is not of any use anymore the client should cancel the request.
let lsp#lsp#ErrorCodes['ContentModified'] = -32801
" The client has canceled a request and a server as detected the cancel.
let lsp#lsp#ErrorCodes['RequestCancelled'] = -32800
" This is the end range of LSP reserved error codes. It doesn't denote a real error code.
let lsp#lsp#ErrorCodes['lspReservedErrorRangeEnd'] = -32800

" https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#notificationMessage
function lsp#lsp#NotificationMessage(method, params = v:none)
	let l:message = lsp#lsp#Message()
	" The method to be invoked.
	let l:message['method'] = a:method
	" The notification's params.
	if a:params != v:none
		let l:message['params'] = a:params
	endif
	return l:message
endfunction

" https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#cancelRequest
function lsp#lsp#CancelParams(id)
	let l:params = {}
	" The request id to cancel.
	let l:params['id'] = a:id
	return l:params
endfunction

" https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#progress
function lsp#lsp#ProgressParams(token, value)
	let l:params = {}
	" The progress token provided by the client or server.
	let l:params['token'] = a:token
	" The progress data.
	let l:params['value'] = a:value
	return l:params
endfunction


" Basic Structures

function lsp#lsp#DocumentUri(string)
	return a:string
endfunction

function lsp#lsp#URI(string)
	return a:string
endfunction

" Client capabilities specific to regular expressions.
function lsp#lsp#RegularExpressionsClientCapabilities(engine, version = v:none)
	let l:capabilities = {}
	" The engine's name.
	let l:capabilities['engine'] = a:engine
	" The engine's version.
	if a:version != v:none
		let l:capabilities['version'] = a:version
	endif
	return l:capabilities
endfunction

const lsp#lsp#EOL = ['\n', '\r\n', '\r']

function lsp#lsp#Position(line, character)
	let l:position = {}
	" Line position in a document (zero-based).
	let l:position['line'] = a:line
	" Character offset on a line in a document (zero-based). Assuming that the line is represented as a string, the `character` value represents the gap between the `character` and `character + 1`.
	" If the character value is greater than the line length it defaults back to the line length.
	let l:position['character'] = a:character
	return l:position
endfunction

function lsp#lsp#Range(start, end)
	let l:range = {}
	" The range's start position.
	let l:range['start'] = a:start
	" The range's end position.
	let l:range['end'] = a:end
	return l:range
endfunction

function lsp#lsp#Location(uri, range)
	let l:location = {}
	let l:location['uri'] = a:uri
	let l:location['range'] = a:range
	return l:location
endfunction

function lsp#lsp#LocationLink(originSelectionRange, targetUri, targetRange, targetSelectionRange)
	let l:locationlink = {}
	" Span of the origin of this link.
	" Used as the underlined span for mouse interaction. Defaults to the word range at the mouse position.
	let l:locationlink['originSelectionRange'] = a:originSelectionRange
	" The target resource identifier of this link.
	let l:locationlink['targetUri'] = a:targetUri
	" The full target range of this link. If the target for example is a symbol then target range is the range enclosing this symbol not including leading/trailing whitespace but everything else like comments. This information is typically used to highlight the range in the editor.
	let l:locationlink['targetRange'] = a:targetRange
	" The range that should be selected and revealed when this link is being followed, e.g the name of a function. Must be contained by the the `targetRange`. See also `DocumentSymbol#range`
	let l:locationlink['targetSelectionRange'] = a:targetSelectionRange
	return l:locationlink
endfunction

let lsp#lsp#DiagnosticSeverity = {}
" Reports an error.
let lsp#lsp#DiagnosticSeverity['Error'] = 1
" Reports a warning.
let lsp#lsp#DiagnosticSeverity['Warning'] = 2
" Reports an information.
let lsp#lsp#DiagnosticSeverity['Information'] = 3
" Reports a hint.
let lsp#lsp#DiagnosticSeverity['Hint'] = 4

" The diagnostic tags.
let lsp#lsp#DiagnosticTag = {}
" Unused or unnecessary code.
" Clients are allowed to render diagnostics with this tag faded out instead of having an error squiggle.
let lsp#lsp#DiagnosticTag['Unnecessary'] = 1
" Deprecated or obsolete code.
" Clients are allowed to rendered diagnostics with this tag strike through.
let lsp#lsp#DiagnosticTag['Deprecated'] = 2

function lsp#lsp#Command(title, command, arguments = v:none)
	let l:command = {}
	" Title of the command, like `save`.
	let l:command['title'] = a:title
	" The identifier of the actual command handler.
	let l:command['command'] = a:command
	" Arguments that the command handler should be invoked with.
	if a:arguments != v:none
		let l:command['arguments'] = a:arguments
	endif
	return l:command
endfunction

function lsp#lsp#TextEdit(range, newText)
	let l:textedit = {}
	" The range of the text document to be manipulated. To insert text into a document create a range where start === end.
	let l:textedit['range'] = a:range
	" The string to be inserted. For delete operations use an empty string.
	let l:textedit['newText'] = a:newText
	return l:textedit
endfunction

" Request:
" method: ‘initialize’
function lsp#lsp#InitializeParams(processId, capabilities, clientInfo = v:none, locale = v:none, initializationOptions = v:none, trace = v:none, workspaceFolders = v:none, workDoneToken = v:none)
	let l:params = lsp#lsp#WorkDoneProgressParams(a:workDoneToken)
	" The process Id of the parent process that started the server. Is null if the process has not been started by another process. If the parent process is not alive then the server should exit (see exit notification) its process.
	let l:params['processId'] = a:processId
	" Information about the client
	if a:clientInfo != v:none
		let l:params['clientInfo'] = {}
		" The name of the client as defined by the client.
		let l:params['clientInfo']['name'] = a:clientInfo['name']
		" The client's version as defined by the client.
		if has_key(a:clientInfo, 'version')
			let l:params['clientInfo']['version'] = a:clientInfo['version']
		endif
	endif
	" The locale the client is currently showing the user interface in. This must not necessarily be the locale of the operating system.
	" Uses IETF language tags as the value's syntax
	" (See https://en.wikipedia.org/wiki/IETF_language_tag)
	if a:locale != v:none
		let l:params['locale'] = a:locale
	endif
	" The rootPath of the workspace. Is null if no folder is open.
	" @deprecated in favour of `rootUri`.
	" rootPath?: string | null;

	" The rootUri of the workspace. Is null if no folder is open. If both `rootPath` and `rootUri` are set `rootUri` wins.
	" @deprecated in favour of `workspaceFolders`
	" rootUri: DocumentUri | null;

	" User provided initialization options.
	if a:initializationOptions != v:none
		let l:params['initializationOptions'] = a:initializationOptions
	endif
	" The capabilities provided by the client (editor or tool)
	let l:params['capabilities'] = a:capabilities
	" The initial trace setting. If omitted trace is disabled ('off').
	if a:trace != v:none
		let l:params['trace'] = a:trace
	endif
	" The workspace folders configured in the client when the server starts.
	" This property is only available if the client supports workspace folders.
	" It can be `null` if the client supports workspace folders but none are configured.
	if a:workspaceFolders != v:none
		let l:params['workspaceFolders'] = a:workspaceFolders
	endif
	return l:params
endfunction

" Text document specific client capabilities.
function lsp#lsp#TextDocumentClientCapabilities(synchronization = v:none, completion = v:none, hover = v:none, signatureHelp = v:none, declaration = v:none, definition = v:none, typeDefinition = v:none, implementation = v:none, references = v:none, documentHighlight = v:none, documentSymbol = v:none, codeAction = v:none, codeLens = v:none, documentLink = v:none, colorProvider = v:none, formatting = v:none, rangeFormatting = v:none, onTypeFormatting = v:none, rename = v:none, publishDiagnostics = v:none, foldingRange = v:none, selectionRange = v:none, linkedEditingRange = v:none, callHierarchy = v:none, semanticTokens = v:none, moniker = v:none)
	let l:capabilities = {}
	let l:capabilities['synchronization'] = a:synchronization
	" Capabilities specific to the `textDocument/completion` request.
	let l:capabilities['completion'] = a:completion
	" Capabilities specific to the `textDocument/hover` request.
	let l:capabilities['hover'] = a:hover
	" Capabilities specific to the `textDocument/signatureHelp` request.
	let l:capabilities['signatureHelp'] = a:signatureHelp
	" Capabilities specific to the `textDocument/declaration` request.
	let l:capabilities['declaration'] = a:declaration
	" Capabilities specific to the `textDocument/definition` request.
	let l:capabilities['definition'] = a:definition
	" Capabilities specific to the `textDocument/typeDefinition` request.
	let l:capabilities['typeDefinition'] = a:typeDefinition
	" Capabilities specific to the `textDocument/implementation` request.
	let l:capabilities['implementation'] = a:implementation
	" Capabilities specific to the `textDocument/references` request.
	let l:capabilities['references'] = a:references
	" Capabilities specific to the `textDocument/documentHighlight` request.
	let l:capabilities['documentHighlight'] = a:documentHighlight
	" Capabilities specific to the `textDocument/documentSymbol` request.
	let l:capabilities['documentSymbol'] = a:documentSymbol
	" Capabilities specific to the `textDocument/codeAction` request.
	let l:capabilities['codeAction'] = a:codeAction
	" Capabilities specific to the `textDocument/codeLens` request.
	let l:capabilities['codeLens'] = a:codeLens
	" Capabilities specific to the `textDocument/documentLink` request.
	let l:capabilities['documentLink'] = a:documentLink
	" Capabilities specific to the `textDocument/documentColor` and the `textDocument/colorPresentation` request.
	let l:capabilities['colorProvider'] = a:colorProvider
	" Capabilities specific to the `textDocument/formatting` request.
	let l:capabilities['formatting'] = a:formatting
	" Capabilities specific to the `textDocument/rangeFormatting` request.
	let l:capabilities['rangeFormatting'] = a:rangeFormatting
	" Capabilities specific to the `textDocument/onTypeFormatting` request.
	let l:capabilities['onTypeFormatting'] = a:onTypeFormatting
	" Capabilities specific to the `textDocument/rename` request.
	let l:capabilities['rename'] = a:rename
	" Capabilities specific to the `textDocument/publishDiagnostics` notification.
	let l:capabilities['publishDiagnostics'] = a:publishDiagnostics
	" Capabilities specific to the `textDocument/foldingRange` request.
	let l:capabilities['foldingRange'] = a:foldingRange
	" Capabilities specific to the `textDocument/selectionRange` request.
	let l:capabilities['selectionRange'] = a:selectionRange
	" Capabilities specific to the `textDocument/linkedEditingRange` request.
	let l:capabilities['linkedEditingRange'] = a:linkedEditingRange
	" Capabilities specific to the various call hierarchy requests.
	let l:capabilities['callHierarchy'] = a:callHierarchy
	" Capabilities specific to the various semantic token requests.
	let l:capabilities['semanticTokens'] = a:semanticTokens
	" Capabilities specific to the `textDocument/moniker` request.
	let l:capabilities['moniker'] = a:moniker
	return filter(l:capabilities, {key, val -> val != v:none})
endfunction

function lsp#lsp#ClientCapabilities(workspace = v:none, textDocument = v:none, window = v:none, general = v:none, experimental = v:none)
	let l:capabilities = {}
	" Workspace specific client capabilities.
	if a:workspace != v:none
		let l:capabilities['workspace'] = {}
		" The client supports applying batch edits to the workspace by supporting the request 'workspace/applyEdit'
		if has_key(a:workspace, 'applyEdit')
			let l:capabilities['workspace']['applyEdit'] = a:workspace['applyEdit']
		endif
		" Capabilities specific to `WorkspaceEdit`s
		if has_key(a:workspace, 'workspaceEdit')
			let l:capabilities['workspace']['workspaceEdit'] = a:workspace['workspaceEdit']
		endif
		" Capabilities specific to the `workspace/didChangeConfiguration` notification.
		if has_key(a:workspace, 'didChangeConfiguration')
			let l:capabilities['workspace']['didChangeConfiguration'] = a:workspace['didChangeConfiguration']
		endif
		" Capabilities specific to the `workspace/didChangeWatchedFiles` notification.
		if has_key(a:workspace, 'didChangeWatchedFiles')
			let l:capabilities['workspace']['didChangeWatchedFiles'] = a:workspace['didChangeWatchedFiles']
		endif
		" Capabilities specific to the `workspace/symbol` request.
		if has_key(a:workspace, 'symbol')
			let l:capabilities['workspace']['symbol'] = a:workspace['symbol']
		endif
		" Capabilities specific to the `workspace/executeCommand` request.
		if has_key(a:workspace, 'executeCommand')
			let l:capabilities['workspace']['executeCommand'] = a:workspace['executeCommand']
		endif
		" The client has support for workspace folders.
		if has_key(a:workspace, 'workspaceFolders')
			let l:capabilities['workspace']['workspaceFolders'] = a:workspace['workspaceFolders']
		endif
		" The client supports `workspace/configuration` requests.
		if has_key(a:workspace, 'configuration')
			let l:capabilities['workspace']['configuration'] = a:workspace['configuration']
		endif
		" Capabilities specific to the semantic token requests scoped to the workspace.
		if has_key(a:workspace, 'semanticTokens')
			let l:capabilities['workspace']['semanticTokens'] = a:workspace['semanticTokens']
		endif
		" Capabilities specific to the code lens requests scoped to the workspace.
		if has_key(a:workspace, 'codeLens')
			let l:capabilities['workspace']['codeLens'] = a:workspace['codeLens']
		endif
		" The client has support for file requests/notifications.
		if has_key(a:workspace, 'fileOperations')
			let l:capabilities['workspace']['fileOperations'] = {}
			" Whether the client supports dynamic registration for file requests/notifications.
			if has_key(a:workspace['fileOperations'], 'dynamicRegistration')
				let l:capabilities['workspace']['fileOperations']['dynamicRegistration'] = a:workspace['fileOperations']['dynamicRegistration']
			endif
			" The client has support for sending didCreateFiles notifications.
			if has_key(a:workspace['fileOperations'], 'didCreate')
				let l:capabilities['workspace']['fileOperations']['didCreate'] = a:workspace['fileOperations']['didCreate']
			endif
			" The client has support for sending willCreateFiles requests.
			if has_key(a:workspace['fileOperations'], 'willCreate')
				let l:capabilities['workspace']['fileOperations']['willCreate'] = a:workspace['fileOperations']['willCreate']
			endif
			" The client has support for sending didRenameFiles notifications.
			if has_key(a:workspace['fileOperations'], 'didRename')
				let l:capabilities['workspace']['fileOperations']['didRename'] = a:workspace['fileOperations']['didRename']
			endif
			" The client has support for sending willRenameFiles requests.
			if has_key(a:workspace['fileOperations'], 'willRename')
				let l:capabilities['workspace']['fileOperations']['willRename'] = a:workspace['fileOperations']['willRename']
			endif
			" The client has support for sending didDeleteFiles notifications.
			if has_key(a:workspace['fileOperations'], 'didDelete')
				let l:capabilities['workspace']['fileOperations']['didDelete'] = a:workspace['fileOperations']['didDelete']
			endif
			" The client has support for sending willDeleteFiles requests.
			if has_key(a:workspace['fileOperations'], 'willDelete')
				let l:capabilities['workspace']['fileOperations']['willDelete'] = a:workspace['fileOperations']['willDelete']
			endif
		endif
	endif
	" Text document specific client capabilities.
	if a:textDocument != v:none
		let l:capabilities['textDocument'] = a:textDocument
	endif
	" Window specific client capabilities.
	if a:window != v:none
		let l:capabilities['window'] = {}
		" Whether client supports handling progress notifications. If set servers are allowed to report in `workDoneProgress` property in the request specific server capabilities.
		if has_key(a:window, 'workDoneProgress')
			let l:capabilities['window']['workDoneProgress'] = a:window['workDoneProgress']
		endif
		" Capabilities specific to the showMessage request
		if has_key(a:window, 'showMessage')
			let l:capabilities['window']['showMessage'] = a:window['showMessage']
		endif
		" Client capabilities for the show document request.
		if has_key(a:window, 'showDocument')
			let l:capabilities['window']['showDocument'] = a:window['showDocument']
		endif
	endif
	" General client capabilities.
	if a:general != v:none
		let l:capabilities['general'] = {}
		" Client capability that signals how the client handles stale requests (e.g. a request for which the client will not process the response anymore since the information is outdated).
		if has_key(a:general, 'staleRequestSupport')
			let l:capabilities['general']['staleRequestSupport'] = {}
			" The client will actively cancel the request.
			let l:capabilities['general']['staleRequestSupport']['cancel'] = a:general['staleRequestSupport']['cancel']
			" The list of requests for which the client will retry the request if it receives a response with error code `ContentModified``
			let l:capabilities['general']['staleRequestSupport']['retryOnContentModified'] = a:general['staleRequestSupport']['retryOnContentModified']
		endif
		" Client capabilities specific to regular expressions.
		if has_key(a:general, 'regularExpressions')
			let l:capabilities['general']['regularExpressions'] = a:general['regularExpressions']
		endif
		" Client capabilities specific to the client's markdown parser.
		if has_key(a:general, 'markdown')
			let l:capabilities['general']['markdown'] = a:general['markdown']
		endif
	endif
	" Experimental client capabilities.
	if a:experimental != v:none
		let l:capabilities['experimental'] = a:experimental
	endif
	return l:capabilities
endfunction

let lsp#lsp#TraceValue = {}
let lsp#lsp#TraceValue['off'] = 'off'
let lsp#lsp#TraceValue['messages'] = 'messages'
let lsp#lsp#TraceValue['verbose'] = 'verbose'

function lsp#lsp#WorkspaceFolder(uri, name)
	let l:workspaceFolder = {}
	" The associated URI for this workspace folder.
	let l:workspaceFolder['uri'] = a:uri
	" The name of the workspace folder. Used to refer to this workspace folder in the user interface.
	let l:workspaceFolder['name'] = a:name
	return l:workspaceFolder
endfunction

function lsp#lsp#WorkDoneProgressParams(workDoneToken = v:none)
	let l:params = {}
	" An optional token that a server can use to report work done progress.
	if a:workDoneToken != v:none
		let l:params['workDoneToken'] = a:workDoneToken
	endif
	return l:params
endfunction




" function lsp#lsp#InitializeParams(initializationOptions, workspaceFolders, token)
" 	let l:params = {}
" 	call extend(l:params, lsp#lsp#WorkDoneProgressParams(a:token))
" 	let l:params['processId'] = getpid()
" 	let l:params['clientInfo'] = {}
" 	let l:params['clientInfo']['name'] = "vim-package-lsp"
" 	let l:params['clientInfo']['version'] = "0.0"
" 	let l:params['locale'] = "en"
" 	" let l:params['rootPath'] = v:null " @deprecated
" 	" let l:params['rootUri'] = v:null " @deprecated
" 	if !util#isNone(a:initializationOptions)
" 		let l:params['initializationOptions'] = a:initializationOptions
" 	endif
" 	let l:params['capabilities'] = lsp#lsp#ClientCapabilities()
" 	let l:params['trace'] = "verbose" " 'off' | 'messages' | 'verbose'
" 	if !util#isNone(a:workspaceFolders)
" 		let l:params['workspaceFolders'] = a:workspaceFolders
" 	endif
" 	return l:params
" endfunction

function lsp#lsp#InitializedParams()
	let l:params = {}
	return l:params
endfunction

function lsp#lsp#DidOpenTextDocumentParams(path, languageId, version, text)
	let l:params = {}
	let l:params['textDocument'] = lsp#lsp#TextDocumentItem(a:path, a:languageId, a:version, a:text)
	return l:params
endfunction

function lsp#lsp#DidChangeTextDocumentParams(path, version, contentChanges)
	let l:params = {}
	let l:params['textDocument'] = lsp#lsp#VersionedTextDocumentIdentifier(a:path, a:version)
	let l:params['contentChanges'] = a:contentChanges
	return l:params
endfunction

function lsp#lsp#DidCloseTextDocumentParams(path)
	let l:params = {}
	let l:params['textDocument'] = lsp#lsp#TextDocumentIdentifier(a:path)
	return l:params
endfunction

function lsp#lsp#DidSaveTextDocumentParams(path, text)
	let l:params = {}
	let l:params['textDocument'] = lsp#lsp#TextDocumentIdentifier(a:path)
	if !util#isNone(a:text)
		let l:params['text'] = a:text
	endif
	return l:params
endfunction

function lsp#lsp#HoverParams(path, position, token)
	let l:hoverParams = {}
	call extend(l:hoverParams, lsp#lsp#TextDocumentPositionParams(a:path, a:position))
	call extend(l:hoverParams, lsp#lsp#WorkDoneProgressParams(a:token))
	return l:hoverParams
endfunction

function lsp#lsp#TextDocumentPositionParams(path, position)
	let l:params = {}
	let l:params['textDocument'] = lsp#lsp#TextDocumentIdentifier(a:path)
	let l:params['position'] = a:position
	return l:params
endfunction

function lsp#lsp#VersionedTextDocumentIdentifier(path, version)
	let l:params = {}
	call extend(l:params, lsp#lsp#TextDocumentIdentifier(a:path))
	let l:params['version'] = a:version
	return l:params
endfunction

function lsp#lsp#TextDocumentIdentifier(path)
	let l:params = {}
	" let l:params['uri'] = lsp#lsp#DocumentUri('file', v:none, a:path, v:none, v:none)
	let l:params['uri'] = lsp#lsp#DocumentUri(a:path)
	return l:params
endfunction

function lsp#lsp#TextDocumentContentChangeEvent(range, text)
	let l:params = {}
	if !util#isNone(a:range)
		let l:params['range'] = a:range
	endif
	" let l:params['rangeLength'] = 0 " @deprecated
	let l:params['text'] = a:text
	return l:params
endfunction

function lsp#lsp#DefinitionParams(path, position, workDoneToken, partialResultToken)
	let l:params = {}
	call extend(l:params, lsp#lsp#TextDocumentPositionParams(a:path, a:position))
	call extend(l:params, lsp#lsp#WorkDoneProgressParams(a:workDoneToken))
	call extend(l:params, lsp#lsp#PartialResultParams(a:partialResultToken))
	return l:params
endfunction

function lsp#lsp#ReferenceParams(path, position, context, workDoneToken, partialResultToken)
	let l:params = {}
	call extend(l:params, lsp#lsp#TextDocumentPositionParams(a:path, a:position))
	call extend(l:params, lsp#lsp#WorkDoneProgressParams(a:workDoneToken))
	call extend(l:params, lsp#lsp#PartialResultParams(a:partialResultToken))
	let l:params['context'] = a:context
	return l:params
endfunction

function lsp#lsp#ImplementationParams(path, position, workDoneToken, partialResultToken)
	let l:params = {}
	call extend(l:params, lsp#lsp#TextDocumentPositionParams(a:path, a:position))
	call extend(l:params, lsp#lsp#WorkDoneProgressParams(a:workDoneToken))
	call extend(l:params, lsp#lsp#PartialResultParams(a:partialResultToken))
	return l:params
endfunction

function lsp#lsp#ReferenceContext(includeDeclaration)
	let l:params = {}
	let l:params['includeDeclaration'] = a:includeDeclaration
	return l:params
endfunction

function lsp#lsp#CompletionParams(context, path, position, workDoneToken, partialResultToken)
	let l:params = {}
	call extend(l:params, lsp#lsp#TextDocumentPositionParams(a:path, a:position))
	call extend(l:params, lsp#lsp#WorkDoneProgressParams(a:workDoneToken))
	call extend(l:params, lsp#lsp#PartialResultParams(a:partialResultToken))
	if !util#isNone(a:context)
		let l:params['context'] = a:context
	endif
	return l:params
endfunction

function lsp#lsp#CompletionContext(triggerKind, triggerCharacter)
	let l:params = {}
	let l:params['triggerKind'] = a:triggerKind
	if !util#isNone(a:triggerCharacter)
		let l:params['triggerCharacter'] = a:triggerCharacter
	endif
	return l:params
endfunction

function lsp#lsp#CompletionItem()
endfunction

function lsp#lsp#CodeLensParams(path, workDoneToken, partialResultToken)
	let l:params = {}
	call extend(l:params, lsp#lsp#WorkDoneProgressParams(a:workDoneToken))
	call extend(l:params, lsp#lsp#PartialResultParams(a:partialResultToken))
	let l:params['textDocument'] = lsp#lsp#TextDocumentIdentifier(a:path)
	return l:params
endfunction

function lsp#lsp#CodeActionParams(path, range, context, workDoneToken, partialResultToken)
	let l:params = {}
	call extend(l:params, lsp#lsp#WorkDoneProgressParams(a:workDoneToken))
	call extend(l:params, lsp#lsp#PartialResultParams(a:partialResultToken))
	let l:params['textDocument'] = lsp#lsp#TextDocumentIdentifier(a:path)
	let l:params['range'] = a:range
	let l:params['context'] = a:context
	return l:params
endfunction

function lsp#lsp#CodeActionContext(diagnostics, kind)
	let l:params = {}
	let l:params['diagnostics'] = a:diagnostics
	if !util#isNone(a:kind)
		let l:params['only'] = a:kind
	endif
	return l:params
endfunction

function lsp#lsp#DocumentSymbolParams(path, workDoneToken, partialResultToken)
	let l:params = {}
	call extend(l:params, lsp#lsp#WorkDoneProgressParams(a:workDoneToken))
	call extend(l:params, lsp#lsp#PartialResultParams(a:partialResultToken))
	let l:params['textDocument'] = lsp#lsp#TextDocumentIdentifier(a:path)
	return l:params
endfunction

" function lsp#lsp#WorkDoneProgressParams(workDoneToken)
" 	let l:workDoneProgressParams = {}
" 	if !util#isNone(a:workDoneToken)
" 		let l:workDoneProgressParams['workDoneToken'] = a:workDoneToken
" 	endif
" 	return l:workDoneProgressParams
" endfunction

function lsp#lsp#PartialResultParams(progressToken)
	let l:params = {}
	if !util#isNone(a:progressToken)
		let l:params['partialResultToken'] = a:progressToken
	endif
	return l:params
endfunction

" function lsp#lsp#Range(start, end)
" 	let l:range = {}
" 	let l:range['start'] = a:start
" 	let l:range['end'] = a:end
" 	return l:range
" endfunction

" function lsp#lsp#Position(line, character)
" 	let l:position = {}
" 	let l:position['line'] = a:line
" 	let l:position['character'] = a:character
" 	return l:position
" endfunction

function lsp#lsp#TextDocumentItem(path, languageId, version, text)
	let l:params = {}
	" let l:params['uri'] = lsp#lsp#DocumentUri('file', v:none, a:path, v:none, v:none)
	let l:params['uri'] = lsp#lsp#DocumentUri(a:path)
	let l:params['languageId'] = a:languageId
	let l:params['version'] = a:version
	let l:params['text'] = a:text
	return l:params
endfunction

" function lsp#lsp#DocumentUri(scheme, authority, path, query, fragment)
" 	return lsp#lsp#Uri(a:scheme, a:authority, a:path, a:query, a:fragment)
" endfunction

" function lsp#lsp#Uri(scheme, authority, path, query, fragment)
" 	let l:params = []
" 	call add(l:params, a:scheme)
" 	call add(l:params, '://')
" 	if !util#isNone(a:authority)
" 		call add(l:params, a:authority)
" 	endif
" 	call add(l:params, a:path)
" 	if !util#isNone(a:query)
" 		call add(l:params, '?')
" 		call add(l:params, a:query)
" 	endif
" 	if !util#isNone(a:fragment)
" 		call add(l:params, '#')
" 		call add(l:params, a:fragment)
" 	endif
" 	return join(l:params, '')
" endfunction

" function lsp#lsp#WorkspaceFolder(path, name)
" 	let l:params = {}
" 	let l:params['uri'] = lsp#lsp#DocumentUri('file', v:none, a:path, v:none, v:none)
" 	let l:params['name'] = a:name
" 	return l:params
" endfunction

" function lsp#lsp#ClientCapabilities()
" 	let l:params = {}
" 	let l:params['workspace'] = {}
" 	let l:params['workspace']['applyEdit'] = v:false
" 	let l:params['workspace']['workspaceEdit'] = lsp#lsp#WorkspaceEditClientCapabilities()
" 	let l:params['workspace']['didChangeConfiguration'] = lsp#lsp#DidChangeConfigurationClientCapabilities()
" 	let l:params['workspace']['didChangeWatchedFiles'] = lsp#lsp#DidChangeWatchedFilesClientCapabilities()
" 	let l:params['workspace']['symbol'] = lsp#lsp#WorkspaceSymbolClientCapabilities()
" 	let l:params['workspace']['executeCommand'] = lsp#lsp#ExecuteCommandClientCapabilities()
" 	let l:params['workspace']['workspaceFolders'] = v:true
" 	let l:params['workspace']['configuration'] = v:true
" 	let l:params['workspace']['semanticTokens'] = lsp#lsp#SemanticTokensWorkspaceClientCapabilities()
" 	let l:params['workspace']['codeLens'] = lsp#lsp#CodeLensWorkspaceClientCapabilities()
" 	let l:params['workspace']['fileOperations'] = {}
" 	let l:params['workspace']['fileOperations']['dynamicRegistration'] = v:false
" 	let l:params['workspace']['fileOperations']['didCreate'] = v:false
" 	let l:params['workspace']['fileOperations']['willCreate'] = v:false
" 	let l:params['workspace']['fileOperations']['didRename'] = v:false
" 	let l:params['workspace']['fileOperations']['willRename'] = v:false
" 	let l:params['workspace']['fileOperations']['didDelete'] = v:false
" 	let l:params['workspace']['fileOperations']['willDelete'] = v:false
" 	let l:params['textDocument'] = lsp#lsp#TextDocumentClientCapabilities()
" 	let l:params['window'] = {}
" 	let l:params['window']['workDoneProgress'] = v:true
" 	let l:params['window']['showMessage'] = lsp#lsp#ShowMessageRequestClientCapabilities()
" 	let l:params['window']['showDocument'] = lsp#lsp#ShowDocumentClientCapabilities()
" 	let l:params['general'] = {}
" 	let l:params['general']['staleRequestSupport'] = {}
" 	let l:params['general']['staleRequestSupport']['cancel'] = v:false
" 	let l:params['general']['staleRequestSupport']['retryOnContentModified'] = [""]
" 	let l:params['general']['regularExpressions'] = lsp#lsp#RegularExpressionsClientCapabilities()
" 	let l:params['general']['markdown'] = lsp#lsp#MarkdownClientCapabilities()
" 	let l:params['experimental'] = v:null
" 	return l:params
" endfunction

function lsp#lsp#WorkspaceEditClientCapabilities()
	let l:params = {}
	let l:params['documentChanges'] = v:false
	let l:params['resourceOperations'] = [] " ['create', 'rename', 'delete']
	let l:params['failureHandling'] = "abort" " 'abort' | 'transactional' | 'undo' | 'textOnlyTransactional'
	let l:params['normalizesLineEndings'] = v:false
	let l:params['changeAnnotationSupport'] = {}
	let l:params['changeAnnotationSupport']['groupsOnLabel'] = v:false
	return l:params
endfunction

function lsp#lsp#DidChangeConfigurationClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:true
	return l:params
endfunction

function lsp#lsp#DidChangeWatchedFilesClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#lsp#WorkspaceSymbolClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['symbolKind'] = {}
	let l:params['symbolKind']['valueSet'] = []
	let l:params['tagSupport'] = {}
	let l:params['tagSupport']['valueSet'] = []
	return l:params
endfunction

function lsp#lsp#ExecuteCommandClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#lsp#SemanticTokensWorkspaceClientCapabilities()
	let l:params = {}
	let l:params['refreshSupport'] = v:false
	return l:params
endfunction

function lsp#lsp#CodeLensWorkspaceClientCapabilities()
	let l:params = {}
	let l:params['refreshSupport'] = v:false
	return l:params
endfunction

" function lsp#lsp#TextDocumentClientCapabilities()
" 	let l:params = {}
" 	let l:params['synchronization'] = lsp#lsp#TextDocumentSyncClientCapabilities()
" 	let l:params['completion'] = lsp#lsp#CompletionClientCapabilities()
" 	let l:params['hover'] = lsp#lsp#HoverClientCapabilities()
" 	let l:params['signatureHelp'] = lsp#lsp#SignatureHelpClientCapabilities()
" 	let l:params['declaration'] = lsp#lsp#DeclarationClientCapabilities()
" 	let l:params['definition'] = lsp#lsp#DefinitionClientCapabilities()
" 	let l:params['typeDefinition'] = lsp#lsp#TypeDefinitionClientCapabilities()
" 	let l:params['implementation'] = lsp#lsp#ImplementationClientCapabilities()
" 	let l:params['references'] = lsp#lsp#ReferenceClientCapabilities()
" 	let l:params['documentHighlight'] = lsp#lsp#DocumentHighlightClientCapabilities()
" 	let l:params['documentSymbol'] = lsp#lsp#DocumentSymbolClientCapabilities()
" 	let l:params['codeAction'] = lsp#lsp#CodeActionClientCapabilities()
" 	let l:params['codeLens'] = lsp#lsp#CodeLensClientCapabilities()
" 	let l:params['documentLink'] = lsp#lsp#DocumentLinkClientCapabilities()
" 	let l:params['colorProvider'] = lsp#lsp#DocumentColorClientCapabilities()
" 	let l:params['formatting'] = lsp#lsp#DocumentFormattingClientCapabilities()
" 	let l:params['rangeFormatting'] = lsp#lsp#DocumentRangeFormattingClientCapabilities()
" 	let l:params['onTypeFormatting'] = lsp#lsp#DocumentOnTypeFormattingClientCapabilities()
" 	let l:params['rename'] = lsp#lsp#RenameClientCapabilities()
" 	let l:params['publishDiagnostics'] = lsp#lsp#PublishDiagnosticsClientCapabilities()
" 	let l:params['foldingRange'] = lsp#lsp#FoldingRangeClientCapabilities()
" 	let l:params['selectionRange'] = lsp#lsp#SelectionRangeClientCapabilities()
" 	let l:params['linkedEditingRange'] = lsp#lsp#LinkedEditingRangeClientCapabilities()
" 	let l:params['callHierarchy'] = lsp#lsp#CallHierarchyClientCapabilities()
" 	let l:params['semanticTokens'] = lsp#lsp#SemanticTokensClientCapabilities()
" 	let l:params['moniker'] = lsp#lsp#MonikerClientCapabilities()
" 	return l:params
" endfunction

function lsp#lsp#ShowMessageRequestClientCapabilities()
	let l:params = {}
	let l:params['messageActionItem'] = {}
	let l:params['messageActionItem']['additionalPropertiesSupport'] = v:false
	return l:params
endfunction

function lsp#lsp#ShowDocumentClientCapabilities()
	let l:params = {}
	let l:params['support'] = v:false
	return l:params
endfunction

" function lsp#lsp#RegularExpressionsClientCapabilities()
" 	let l:params = {}
" 	let l:params['engine'] = ""
" 	let l:params['version'] = "0.0"
" 	return l:params
" endfunction

function lsp#lsp#MarkdownClientCapabilities()
	let l:params = {}
	let l:params['parser'] = ""
	let l:params['version'] = "0.0"
	return l:params
endfunction

function lsp#lsp#TextDocumentSyncClientCapabilities(dynamicRegistration = v:none, willSave = v:none, willSaveWaitUntil = v:none, didSave = v:none)
	let l:capabilities = {}
	" Whether text document synchronization supports dynamic registration.
	let l:capabilities['dynamicRegistration'] = a:dynamicRegistration
	" The client supports sending will save notifications.
	let l:capabilities['willSave'] = a:willSave
	" The client supports sending a will save request and waits for a response providing text edits which will be applied to the document before it is saved.
	let l:capabilities['willSaveWaitUntil'] = a:willSaveWaitUntil
	" The client supports did save notifications.
	let l:capabilities['didSave'] = a:didSave
	return filter(l:capabilities, {key, val -> val != v:none})
endfunction

function lsp#lsp#CompletionClientCapabilities()
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

function lsp#lsp#HoverClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:true
	let l:params['contentFormat'] = ['plaintext']
	return l:params
endfunction

function lsp#lsp#SignatureHelpClientCapabilities()
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

function lsp#lsp#DeclarationClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['linkSupport'] = v:false
	return l:params
endfunction

function lsp#lsp#DefinitionClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['linkSupport'] = v:false
	return l:params
endfunction

function lsp#lsp#TypeDefinitionClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['linkSupport'] = v:false
	return l:params
endfunction

function lsp#lsp#ImplementationClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['linkSupport'] = v:false
	return l:params
endfunction

function lsp#lsp#ReferenceClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#lsp#DocumentHighlightClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#lsp#DocumentSymbolClientCapabilities()
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

function lsp#lsp#CodeActionClientCapabilities()
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

function lsp#lsp#CodeLensClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#lsp#DocumentLinkClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['tooltipSupport'] = v:false
	return l:params
endfunction

function lsp#lsp#DocumentColorClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#lsp#DocumentFormattingClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#lsp#DocumentRangeFormattingClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#lsp#DocumentOnTypeFormattingClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#lsp#RenameClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['prepareSupport'] = v:false
	let l:params['prepareSupportDefaultBehavior'] = 1
	let l:params['honorsChangeAnnotations'] = v:false
	return l:params
endfunction

function lsp#lsp#PublishDiagnosticsClientCapabilities()
	let l:params = {}
	let l:params['relatedInformation'] = v:false
	let l:params['tagSupport'] = {}
	let l:params['tagSupport']['valueSet'] = [1]
	let l:params['versionSupport'] = v:false
	let l:params['codeDescriptionSupport'] = v:false
	let l:params['dataSupport'] = v:false
	return l:params
endfunction

function lsp#lsp#FoldingRangeClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	let l:params['rangeLimit'] = 0
	let l:params['lineFoldingOnly'] = v:true
	return l:params
endfunction

function lsp#lsp#SelectionRangeClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#lsp#LinkedEditingRangeClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#lsp#CallHierarchyClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#lsp#SemanticTokensClientCapabilities()
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

function lsp#lsp#MonikerClientCapabilities()
	let l:params = {}
	let l:params['dynamicRegistration'] = v:false
	return l:params
endfunction

function lsp#lsp#PrepareSupportDefaultBehavior()
	let l:params = {}
	let l:params['Identifier'] = 1
	return l:params
endfunction


function lsp#lsp#CompletionTriggerKind()
	let l:CompletionTriggerKind = {}
	let l:CompletionTriggerKind['Invoked'] = 1
	let l:CompletionTriggerKind['TriggerCharacter'] = 2
	let l:CompletionTriggerKind['TriggerForIncompleteCompletions'] = 3
	return l:CompletionTriggerKind
endfunction

function lsp#lsp#CodeActionKind()
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








function s:serialize_content(content)
	return json_encode(a:content)
endfunction
