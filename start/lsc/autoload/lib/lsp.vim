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



function s:serialize_content(content)
	return json_encode(a:content)
endfunction
