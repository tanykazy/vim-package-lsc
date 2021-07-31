if exists("g:loaded_channel")
	finish
endif
let g:loaded_channel = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


let s:channels = []

function channel#Open(cmd, cwd)
    let l:opt = {}
    let l:opt['mode'] = 'raw'
    let l:opt['in_io'] = 'pipe'
    let l:opt['out_io'] = 'pipe'
    let l:opt['err_io'] = 'pipe'
    let l:opt['callback'] = function('s:callbackhandler')
    let l:opt['cwd'] = a:cwd
	let l:job = s:JobStart(a:cmd, l:opt)
	let l:channel = JobGetchannel(l:job)
    let l:id = s:AddChannel(l:channel)
    return l:id
endfunction

function channel#Send(id, data)
endfunction

function channel#Close(id)
endfunction

function s:AddChannel(channel)
    s:Add(s:channels, a:channel)
    return s:Len(s:channels) - 1
endfunction

function s:GetChannel(id)
    let l:channel s:Get(s:channels, id, v:null)
    return l:channel
endfunction

function s:Get(list, idx, default)
    return get(a:list, a:idx, a:default)
endfunction

function s:Add(object, expr)
    return add(a:object, a:expr)
endfunction

function s:Len(expr)
    return len(a:expr)
endfunction

function s:JobStart(command, options)
	return job_start(a:command, a:options)
endfunction

function s:JobGetchannel(job)
	return job_getchanne(a:job)
endfunction

function lsc#Test()
	" echo s:GetCwd()
	" let g:ch = s:StartImpl('npx typescript-language-server --stdio', s:GetCwd())
	let g:ch = s:StartImpl('npx vscode-json-languageserver --stdio', s:GetCwd())
	" echo ch_info(l:ch)
	" echo ch_status(l:ch)
	" echo l:result
	let l:result = lsp#initialize()
	let l:b = ch_sendraw(g:ch, l:result)
endfunction

function s:StartImpl(cmd, cwd)
	let l:job = s:JobStart(a:cmd, {
				\ 'mode': 'raw',
				\ 'in_io': 'pipe',
				\ 'out_io': 'pipe',
				\ 'err_io': 'pipe',
				\ "callback": function('s:callbackhandler'),
				"\ "out_cb": function('s:callbackhandler'),
				"\ "err_cb": function('s:callbackhandler'),
				\ "cwd": a:cwd})
	let l:channel = job_getchannel(l:job)
	call ch_logfile('logfile', 'w')
	" echo job_info(l:job)
	return l:channel
endfunction

function s:WaitStartedImpl(channel, msg)
	let l:matched = matchlist(a:msg, s:reSwankPort)
	"if len(l:matched) > 0
	if !empty(l:matched)
		"let b:port = str2nr(l:matched[1])
		let self.channel = self.ConnectImpl(s:swankHost, str2nr(l:matched[1]))
	endif
endfunction

function s:ConnectImpl(host, port) 
	let l:options = {
				\"mode": "json",
				\"callback": self.callbackhandler}
	let l:channel = s:ChOpen(a:host, a:port, l:options)
	"echo ch_info(l:channel)
	return l:channel
endfunction

function s:callbackhandler(channel, msg)
	" let l:buf = bufnr(join(a:cmd), v:true)
	" echo a:channel
	" echo a:msg
	" call ch_log(a:channel)
	call ch_log(a:msg)
endfunction

function s:SendText(line)
	return ch_sendraw(self.channel, join(s:TrimLines(a:line)) . "\n")
endfunction

function s:ShowBuffer(buffer)
	let l:w = bufwinnr(bufnr("#"))
	execute "vertical rightbelow sbuffer" a:buffer
	execute l:w . "wincmd w"
	return a:buffer
endfunction

function s:ChOpen(host, port, options)
	return ch_open(a:host . ':' . a:port, a:options)
endfunction


function s:TrimLines(line)
	return map(a:line, {_, val -> trim(val)})
endfunction

function s:GetLinePos(start, end)
	let l:l = s:GetLine(a:start[0], a:end[0])
	let l:l[-1] = strpart(l:l[-1], 0, a:end[1])
	let l:l[0] = strpart(l:l[0], a:start[1] - 1)
	return l:l
endfunction

function s:GetLine(start, end)
	return getline(a:start, a:end)
endfunction

function s:GetCwd()
	return getcwd(bufwinnr(bufnr("#")))
endfunction


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
