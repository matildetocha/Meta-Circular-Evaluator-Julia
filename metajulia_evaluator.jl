function metajulia_repl()
    while true
        print(">> ") 
        line = readline() 
        expr = Meta.parse(line)
        #We need to make our own eval function
        # result = our_eval(expr)
        # println(result)
    end
end

function metajulia_eval()
#We need to make our own eval function
end