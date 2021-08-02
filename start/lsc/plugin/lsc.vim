command -nargs=0 Lsc :call lsc#Lsc(<f-args>)
command -nargs=0 Test :call lsc#Test(<f-args>)

call lsc#Lsc()
" call client#Test()

" let l = []

" echo len(l)
" echo l[1]

function s:default(a, b = 'b')
    call ch_log(a:a)
    call ch_log(a:b)
endfunction

call ch_log('###############################')
call s:default('aa', 'bb')
call s:default('aa')

