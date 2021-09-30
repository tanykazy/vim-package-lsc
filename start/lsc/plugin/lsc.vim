if exists("g:loaded_lsc")
	finish
endif
const g:loaded_lsc = 1

const s:save_cpoptions = &cpoptions
set cpoptions&vim


let g:log_level = log#level_trace
" let g:log_level = log#level_debug
" let g:log_level = log#level_error
call log#init()
call log#start_chlog()

command -nargs=1 -complete=custom,cmd#completion_support_lang LscInstallServer call cmd#install(<f-args>)
command -nargs=1 -complete=custom,cmd#completion_installed_lang LscUninstallServer call cmd#uninstall(<f-args>)
command -nargs=? -complete=custom,cmd#completion_installed_lang LscStart call cmd#start(<f-args>)
command -nargs=? -complete=custom,cmd#completion_running_server LscStop call cmd#stop(<f-args>)
command -nargs=? -complete=buffer LscOpen call cmd#open(<f-args>)
command -nargs=? -complete=buffer LscClose call cmd#close(<f-args>)
command -nargs=? -complete=buffer LscChange call cmd#change(<f-args>)
command -nargs=? -complete=buffer LscSave call cmd#save(<f-args>)
command -nargs=? -complete=buffer LscCodeLens call cmd#code_lens(<f-args>)
command -nargs=? -range=% -complete=custom,cmd#completion_code_action_kind LscCodeAction <line1>,<line2>call cmd#code_action(<f-args>)
command -nargs=0 LscGotoDefinition call cmd#goto_definition()
command -nargs=0 LscGotoImplementation call cmd#goto_implementation()
command -nargs=0 LscFindReferences call cmd#find_references()
command -nargs=? -complete=buffer LscDocumentSymbol call cmd#document_symbol(<f-args>)
command -nargs=0 LscHover call cmd#hover()

noremap <silent> <unique> <Plug>(lsc-start) :<C-u>LscStart<CR>
noremap <silent> <unique> <Plug>(lsc-stop) :<C-u>LscStop<CR>
noremap <silent> <unique> <Plug>(lsc-open) :<C-u>LscOpen<CR>
noremap <silent> <unique> <Plug>(lsc-close) :<C-u>LscClose<CR>
noremap <silent> <unique> <Plug>(lsc-change) :<C-u>LscChange<CR>
noremap <silent> <unique> <Plug>(lsc-save) :<C-u>LscSave<CR>
noremap <silent> <unique> <Plug>(lsc-code-lens) :<C-u>LscCodeLens<CR>
noremap <silent> <unique> <Plug>(lsc-code-action) :LscCodeAction<CR>
noremap <silent> <unique> <Plug>(lsc-goto-definition) :<C-u>LscGotoDefinition<CR>
noremap <silent> <unique> <Plug>(lsc-goto-implementation) :<C-u>LscGotoImplementation<CR>
noremap <silent> <unique> <Plug>(lsc-find-references) :<C-u>LscFindReferences<CR>
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

" sample key mapping
map <silent> <F3> <Plug>(lsc-hover)
map <silent> <F4> <Plug>(lsc-document-symbol)
map <silent> <F11> <Plug>(lsc-code-lens)
map <silent> <C-F11> <Plug>(lsc-code-action)
nmap <silent> <F12> <Plug>(lsc-goto-definition)
nmap <silent> <C-F12> <Plug>(lsc-goto-implementation)
nmap <silent> <S-F12> <Plug>(lsc-find-references)


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
