" Basic Structures

function lsp#base#DocumentUri(string)
	return a:string
endfunction

function lsp#base#URI(string)
	return a:string
endfunction

" Client capabilities specific to regular expressions.
function lsp#base#RegularExpressionsClientCapabilities(engine, version = v:none)
	let l:capabilities = {}
	" The engine's name.
	let l:capabilities['engine'] = a:engine
	" The engine's version.
	if a:version != v:none
		let l:capabilities['version'] = a:version
	endif
	return l:capabilities
endfunction

const lsp#base#EOL = ['\n', '\r\n', '\r']

function lsp#base#Position(line, character)
	let l:position = {}
	" Line position in a document (zero-based).
	let l:position['line'] = a:line
	" Character offset on a line in a document (zero-based). Assuming that the line is represented as a string, the `character` value represents the gap between the `character` and `character + 1`.
	" If the character value is greater than the line length it defaults back to the line length.
	let l:position['character'] = a:character
	return l:position
endfunction

function lsp#base#Range(start, end)
	let l:range = {}
	" The range's start position.
	let l:range['start'] = a:start
	" The range's end position.
	let l:range['end'] = a:end
	return l:range
endfunction

function lsp#base#Location(uri, range)
	let l:location = {}
	let l:location['uri'] = a:uri
	let l:location['range'] = a:range
	return l:location
endfunction

function lsp#base#LocationLink(originSelectionRange, targetUri, targetRange, targetSelectionRange)
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
