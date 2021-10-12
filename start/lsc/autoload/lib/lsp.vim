" Base Protocol

" https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#headerPart
function lib#lsp#Header(length, type)
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
function lib#lsp#Content(content, encoding)
	return iconv(s:serialize_content(a:content), &encoding, a:encoding)
endfunction

" The language server protocol always uses “2.0” as the jsonrpc version.
let s:version = '2.0'

" https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#message
function lib#lsp#Message()
	let l:message = {}
	let l:message['jsonrpc'] = s:version
	return l:message
endfunction

" https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#requestMessage
function lib#lsp#RequestMessage(id, method, params = v:none)
	let l:message = lib#lsp#Message()
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
function lib#lsp#ResponseMessage(id, result = v:none, error = v:none)
	let l:message = lib#lsp#Message()
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
function lib#lsp#ResponseError(code, message, data = v:none)
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
let lib#lsp#ErrorCodes = {}
" Defined by JSON RPC
let lib#lsp#ErrorCodes['ParseError'] = -32700
let lib#lsp#ErrorCodes['InvalidRequest'] = -32600
let lib#lsp#ErrorCodes['MethodNotFound'] = -32601
let lib#lsp#ErrorCodes['InvalidParams'] = -32602
let lib#lsp#ErrorCodes['InternalError'] = -32603
" This is the start range of JSON RPC reserved error codes.
" It doesn't denote a real error code. No LSP error codes should be defined between the start and end range. For backwards compatibility the `ServerNotInitialized` and the `UnknownErrorCode` are left in the range.
let lib#lsp#ErrorCodes['jsonrpcReservedErrorRangeStart'] = -32099
let lib#lsp#ErrorCodes['serverErrorStart'] = lib#lsp#ErrorCodes['jsonrpcReservedErrorRangeStart']
" Error code indicating that a server received a notification or request before the server has received the `initialize` request.
let lib#lsp#ErrorCodes['ServerNotInitialized'] = -32002
let lib#lsp#ErrorCodes['UnknownErrorCode'] = -32001
" This is the end range of JSON RPC reserved error codes. It doesn't denote a real error code.
let lib#lsp#ErrorCodes['jsonrpcReservedErrorRangeEnd'] = -32000
let lib#lsp#ErrorCodes['serverErrorEnd'] = lib#lsp#ErrorCodes['jsonrpcReservedErrorRangeEnd']
" This is the start range of LSP reserved error codes. It doesn't denote a real error code.
let lib#lsp#ErrorCodes['lspReservedErrorRangeStart'] = -32899
" A request failed but it was syntactically correct, e.g the method name was known and the parameters were valid. The error message should contain human readable information about why the request failed.
let lib#lsp#ErrorCodes['RequestFailed'] = -32803
" The server cancelled the request. This error code should only be used for requests that explicitly support being server cancellable.
let lib#lsp#ErrorCodes['ServerCancelled'] = -32802
" The server detected that the content of a document got modified outside normal conditions. A server should NOT send this error code if it detects a content change in it unprocessed messages. The result even computed on an older state might still be useful for the client.
" If a client decides that a result is not of any use anymore the client should cancel the request.
let lib#lsp#ErrorCodes['ContentModified'] = -32801
" The client has canceled a request and a server as detected the cancel.
let lib#lsp#ErrorCodes['RequestCancelled'] = -32800
" This is the end range of LSP reserved error codes. It doesn't denote a real error code.
let lib#lsp#ErrorCodes['lspReservedErrorRangeEnd'] = -32800

" https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#notificationMessage
function lib#lsp#NotificationMessage(method, params = v:none)
	let l:message = lib#lsp#Message()
	" The method to be invoked.
	let l:message['method'] = a:method
	" The notification's params.
	if a:params != v:none
		let l:message['params'] = a:params
	endif
	return l:message
endfunction

" https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#cancelRequest
function lib#lsp#CancelParams(id)
	let l:params = {}
	" The request id to cancel.
	let l:params['id'] = a:id
	return l:params
endfunction

" https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#progress
function lib#lsp#ProgressParams(token, value)
	let l:params = {}
	" The progress token provided by the client or server.
	let l:params['token'] = a:token
	" The progress data.
	let l:params['value'] = a:value
	return l:params
endfunction


" Basic Structures

function lib#lsp#DocumentUri(string)
	return a:string
endfunction

function lib#lsp#URI(string)
	return a:string
endfunction

" Client capabilities specific to regular expressions.
function lib#lsp#RegularExpressionsClientCapabilities(engine, version = v:none)
	let l:capabilities = {}
	" The engine's name.
	let l:capabilities['engine'] = a:engine
	" The engine's version.
	if a:version != v:none
		let l:capabilities['version'] = a:version
	endif
	return l:capabilities
endfunction

const lib#lsp#EOL = ['\n', '\r\n', '\r']

function lib#lsp#Position(line, character)
	let l:position = {}
	" Line position in a document (zero-based).
	let l:position['line'] = a:line
	" Character offset on a line in a document (zero-based). Assuming that the line is represented as a string, the `character` value represents the gap between the `character` and `character + 1`.
	" If the character value is greater than the line length it defaults back to the line length.
	let l:position['character'] = a:character
	return l:position
endfunction

function lib#lsp#Range(start, end)
	let l:range = {}
	" The range's start position.
	let l:range['start'] = a:start
	" The range's end position.
	let l:range['end'] = a:end
	return l:range
endfunction

function lib#lsp#Location(uri, range)
	let l:location = {}
	let l:location['uri'] = a:uri
	let l:location['range'] = a:range
	return l:location
endfunction

function lib#lsp#LocationLink(originSelectionRange, targetUri, targetRange, targetSelectionRange)
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

let lib#lsp#DiagnosticSeverity = {}
" Reports an error.
let lib#lsp#DiagnosticSeverity['Error'] = 1
" Reports a warning.
let lib#lsp#DiagnosticSeverity['Warning'] = 2
" Reports an information.
let lib#lsp#DiagnosticSeverity['Information'] = 3
" Reports a hint.
let lib#lsp#DiagnosticSeverity['Hint'] = 4

" The diagnostic tags.
let lib#lsp#DiagnosticTag = {}
" Unused or unnecessary code.
" Clients are allowed to render diagnostics with this tag faded out instead of having an error squiggle.
let lib#lsp#DiagnosticTag['Unnecessary'] = 1
" Deprecated or obsolete code.
" Clients are allowed to rendered diagnostics with this tag strike through.
let lib#lsp#DiagnosticTag['Deprecated'] = 2

function lib#lsp#Command(title, command, arguments = v:none)
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

function lib#lsp#TextEdit(range, newText)
	let l:textedit = {}
	" The range of the text document to be manipulated. To insert text into a document create a range where start === end.
	let l:textedit['range'] = a:range
	" The string to be inserted. For delete operations use an empty string.
	let l:textedit['newText'] = a:newText
	return l:textedit
endfunction

function lib#lsp#InitializeParams(processId, capabilities, clientInfo = v:none, locale = v:none, initializationOptions = v:none, trace = v:none, workspaceFolders = v:none, workDoneToken = v:none)
	let l:params = {}
	let l:params = extend(l:params, lib#lsp#WorkDoneProgressParams(a:workDoneToken))
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


let lib#lsp#TraceValue = {}
let lib#lsp#TraceValue['off'] = 'off'
let lib#lsp#TraceValue['messages'] = 'messages'
let lib#lsp#TraceValue['verbose'] = 'verbose'

function lib#lsp#WorkspaceFolder(uri, name)
	let l:workspaceFolder = {}
	" The associated URI for this workspace folder.
	let l:workspaceFolder['uri'] = a:uri
	" The name of the workspace folder. Used to refer to this workspace folder in the user interface.
	let l:workspaceFolder['name'] = a:name
	return l:workspaceFolder
endfunction

function lib#lsp#WorkDoneProgressParams(workDoneToken = v:none)
	let l:params = {}
	" An optional token that a server can use to report work done progress.
	if a:workDoneToken != v:none
		let l:params['workDoneToken'] = a:workDoneToken
	endif
	return l:params
endfunction











function s:serialize_content(content)
	return json_encode(a:content)
endfunction
