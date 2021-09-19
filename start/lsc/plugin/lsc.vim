if exists("g:loaded_lsc")
	finish
endif
const g:loaded_lsc = 1

const s:save_cpoptions = &cpoptions
set cpoptions&vim


" let g:log_level = log#level_trace
let g:log_level = log#level_debug
" let g:log_level = log#level_error
call log#init()
" call log#start_chlog()

command -nargs=1 -complete=custom,cmd#completion_support_lang LscInstallServer call cmd#install(<f-args>)
command -nargs=1 -complete=custom,cmd#completion_installed_lang LscUninstallServer call cmd#uninstall(<f-args>)
command -nargs=? -complete=custom,cmd#completion_installed_lang LscStart call cmd#start(<f-args>)
command -nargs=? -complete=custom,cmd#completion_running_server LscStop call cmd#stop(<f-args>)
command -nargs=? -complete=buffer LscOpen call cmd#open(<f-args>)
command -nargs=? -complete=buffer LscClose call cmd#close(<f-args>)
command -nargs=? -complete=buffer LscChange call cmd#change(<f-args>)
command -nargs=? -complete=buffer LscSave call cmd#save(<f-args>)
command -nargs=? -complete=buffer LscDocumentSymbol call cmd#document_symbol(<f-args>)
command -nargs=0 LscHover call cmd#hover()

noremap <silent> <unique> <Plug>(lsc-start) :<C-u>LscStart<CR>
noremap <silent> <unique> <Plug>(lsc-stop) :<C-u>LscStop<CR>
noremap <silent> <unique> <Plug>(lsc-open) :<C-u>LscOpen<CR>
noremap <silent> <unique> <Plug>(lsc-close) :<C-u>LscClose<CR>
noremap <silent> <unique> <Plug>(lsc-change) :<C-u>LscChange<CR>
noremap <silent> <unique> <Plug>(lsc-save) :<C-u>LscSave<CR>
noremap <silent> <unique> <Plug>(lsc-document-symbol) :<C-u>LscDocumentSymbol<CR>
noremap <silent> <unique> <Plug>(lsc-hover) :<C-u>LscHover<CR>

augroup vim_package_lsc
	autocmd BufRead * LscOpen
	" autocmd BufReadPost * LscOpen
	" autocmd BufWinEnter * LscOpen
	autocmd BufEnter * LscOpen
	autocmd VimLeave * LscStop
augroup END

call complete#set_completeopt()
call highlight#setup_highlight()

nmap <silent> <F3> <Plug>(lsc-hover)
nmap <silent> <F4> <Plug>(lsc-document-symbol)
nmap <silent> <F11> :<C-u>call client#code_lens(bufnr('%'))<CR>
nmap <silent> <F12> :<C-u>call client#goto_definition(bufnr('%'), getpos('.'), v:false)<CR>
nmap <silent> <C-F12> :<C-u>call client#goto_implementation(bufnr('%'), getpos('.'), v:true)<CR>
nmap <silent> <S-F12> :<C-u>call client#find_references(bufnr('%'), getpos('.'), v:false)<CR>
" nmap <silent> <C-k> :<C-u>call client#goto_definition(bufnr('%'), getpos('.'), v:false)<CR>

" 補完表示時のEnterで改行をしない
" inoremap <expr><CR>  pumvisible() ? "<C-y>" : "<CR>"
" inoremap <expr><C-n> pumvisible() ? "<Down>" : "<C-n>"
" inoremap <expr><C-p> pumvisible() ? "<Up>" : "<C-p>"


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
