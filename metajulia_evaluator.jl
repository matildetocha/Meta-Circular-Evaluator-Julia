function metajulia_repl()
    while true
        print(">> ") 
        line = readline() 
        #If the user types "exit", break the loop
        if line == "exit"
            break
        end
        expr = Meta.parse(line)
        result = metajulia_eval(expr)
        println(result)
    end
end

function metajulia_eval(expr)
    #If the expression is a single number, return it
    if isa(expr, Number)
        return expr
    end
end