function dialog#choice(msg, choices, default, type)
    let l:answer = confirm(a:msg, join(a:choices, '\n'), a:default, a:type)

    return 
endfunction
