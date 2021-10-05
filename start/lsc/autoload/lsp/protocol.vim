" Base Protocol

" https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#headerPart
function lsp#base#Header(length, type)
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
function lsp#base#Content(content, encoding)
	return iconv(s:serialize_content(a:content), &encoding, a:encoding)
endfunction

" The language server protocol always uses “2.0” as the jsonrpc version.
let s:version = '2.0'

" https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#message
function lsp#base#Message()
	let l:message = {}
	let l:message['jsonrpc'] = s:version
	return l:message
endfunction

" https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#requestMessage
function lsp#base#RequestMessage(id, method, params = v:none)
	let l:message = lsp#base#Message()
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
function lsp#base#ResponseMessage(id, result = v:none, error = v:none)
	let l:message = lsp#base#Message()
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
function lsp#base#ResponseError(code, message, data = v:none)
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
let lsp#base#ErrorCodes = {}
" Defined by JSON RPC
let lsp#base#ErrorCodes['ParseError'] = -32700
let lsp#base#ErrorCodes['InvalidRequest'] = -32600
let lsp#base#ErrorCodes['MethodNotFound'] = -32601
let lsp#base#ErrorCodes['InvalidParams'] = -32602
let lsp#base#ErrorCodes['InternalError'] = -32603
" This is the start range of JSON RPC reserved error codes.
" It doesn't denote a real error code. No LSP error codes should be defined between the start and end range. For backwards compatibility the `ServerNotInitialized` and the `UnknownErrorCode` are left in the range.
let lsp#base#ErrorCodes['jsonrpcReservedErrorRangeStart'] = -32099
let lsp#base#ErrorCodes['serverErrorStart'] = lsp#base#ErrorCodes['jsonrpcReservedErrorRangeStart']
" Error code indicating that a server received a notification or request before the server has received the `initialize` request.
let lsp#base#ErrorCodes['ServerNotInitialized'] = -32002
let lsp#base#ErrorCodes['UnknownErrorCode'] = -32001
" This is the end range of JSON RPC reserved error codes. It doesn't denote a real error code.
let lsp#base#ErrorCodes['jsonrpcReservedErrorRangeEnd'] = -32000
let lsp#base#ErrorCodes['serverErrorEnd'] = lsp#base#ErrorCodes['jsonrpcReservedErrorRangeEnd']
" This is the start range of LSP reserved error codes. It doesn't denote a real error code.
let lsp#base#ErrorCodes['lspReservedErrorRangeStart'] = -32899
" A request failed but it was syntactically correct, e.g the method name was known and the parameters were valid. The error message should contain human readable information about why the request failed.
let lsp#base#ErrorCodes['RequestFailed'] = -32803
" The server cancelled the request. This error code should only be used for requests that explicitly support being server cancellable.
let lsp#base#ErrorCodes['ServerCancelled'] = -32802
" The server detected that the content of a document got modified outside normal conditions. A server should NOT send this error code if it detects a content change in it unprocessed messages. The result even computed on an older state might still be useful for the client.
" If a client decides that a result is not of any use anymore the client should cancel the request.
let lsp#base#ErrorCodes['ContentModified'] = -32801
" The client has canceled a request and a server as detected the cancel.
let lsp#base#ErrorCodes['RequestCancelled'] = -32800
" This is the end range of LSP reserved error codes. It doesn't denote a real error code.
let lsp#base#ErrorCodes['lspReservedErrorRangeEnd'] = -32800

" https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#notificationMessage
function lsp#base#NotificationMessage(method, params = v:none)
	let l:message = lsp#base#Message()
	" The method to be invoked.
	let l:message['method'] = a:method
	" The notification's params.
	if a:params != v:none
		let l:message['params'] = a:params
	endif
	return l:message
endfunction

" https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#cancelRequest
function lsp#base#CancelParams(id)
	let l:params = {}
	" The request id to cancel.
	let l:params['id'] = a:id
	return l:params
endfunction

" https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#progress
function lsp#base#ProgressParams(token, value)
	let l:params = {}
	" The progress token provided by the client or server.
	let l:params['token'] = a:token
	" The progress data.
	let l:params['value'] = a:value
	return l:params
endfunction


function s:serialize_content(content)
	return json_encode(a:content)
endfunction
