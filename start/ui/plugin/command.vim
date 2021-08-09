if exists("g:loaded_command")
	finish
endif
let g:loaded_command = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


command -nargs=? -complete=filetype LscStart call command#start(<f-args>)
command -nargs=? -complete=filetype LscStop call command#stop(<f-args>)
command -nargs=? -complete=buffer LscOpen call command#open(<f-args>)
command -nargs=? -complete=buffer LscClose call command#close(<f-args>)
command -nargs=? -complete=buffer LscChange call command#change(<f-args>)
command -nargs=? -complete=buffer LscSave call command#save(<f-args>)


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
