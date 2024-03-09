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

    if is_self_evaluating(expr)
        return expr
    elseif is_call(expr)
        return process_call(expr)
    else
        # Error handling, simply return the expression with a message "Unknown expression" and its type
        println("Unknown expression: ", expr, " of type ", typeof(expr))
    end
end


function is_self_evaluating(expr)
    # If the expression is a number, string or boolean, then it's self evaluating and return true
    return isa(expr, Number) || isa(expr, String) || isa(expr, Boolean)
end        

function is_call(expr)
    return expr.head == :call
end

function process_call(expr)
    # If the expression is a call to the addition function, evaluate it
    if is_addition(expr)
        return process_addition(expr)
    end

    # If the expression is a call to the subtraction function, evaluate it
    if expr.args[1] == :-
        return metajulia_eval(expr.args[2]) - sum(metajulia_eval(arg) for arg in expr.args[3:end])
    end
    
    #If the expression is a call to the multiplication function, evaluate it
    if expr.args[1] == :*
        return prod(metajulia_eval(arg) for arg in expr.args[2:end])
    end

    #If the expression is a call to the division function, evaluate it
    if isa(expr, Expr) && expr.head == :call && expr.args[1] == :/
        return metajulia_eval(expr.args[2]) / metajulia_eval(expr.args[3])
    end
end

function is_addition(expr)
    return expr.args[1] == :+
end

function process_addition(expr)
    return first_argument(expr) + second_argument(expr)
end

function first_argument(expr)
    return expr.args[2]
end

function second_argument(expr)
    return expr.args[3]
end