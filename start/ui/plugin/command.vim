if exists("g:loaded_command")
	finish
endif
let g:loaded_command = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim


command -nargs=? -complete=filetype LscStart call command#start(<f-args>)
command -nargs=0 LscStop call command#stop()
command -nargs=? -complete=buffer LscOpen call command#open(<f-args>)
command -nargs=? -complete=file LscClose call command#close(<f-args>)
command -nargs=? -complete=file LscChange call command#change(<f-args>)


let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
