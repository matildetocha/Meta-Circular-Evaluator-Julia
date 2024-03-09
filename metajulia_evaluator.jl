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

    println("Evaluating expression: ", expr)
    println("Type of expression: ", typeof(expr))

    if is_self_evaluating(expr)
        return expr
    elseif is_call(expr)
        println("Processing call")
        return process_call(expr)
    else
        # Error handling, simply return the expression with a message "Unknown expression" and its type
        println("Unknown expression: ", expr, " of type ", typeof(expr))
    end
end

function is_self_evaluating(expr)
    # If the expression is a number, string or boolean, then it's self evaluating and return true
    return isa(expr, Number) || isa(expr, String) || isa(expr, Bool)
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
    if is_subtraction(expr)
        return process_subtraction(expr)
    end
    # If the expression is a call to the multiplication function, evaluate it
    if is_multiplication(expr)
        return process_multiplication(expr)
    end
    # If the expression is a call to the division function, evaluate it
    if is_division(expr)
        return process_division(expr)
    end
end

function is_addition(expr)
    return expr.args[1] == :+
end

function is_subtraction(expr)
    return expr.args[1] == :-
end

function is_multiplication(expr)
    return expr.args[1] == :*
end

function is_division(expr)
    return expr.args[1] == :/
end

function first_argument(expr)
    return expr.args[2]
end

function second_argument(expr)
    return expr.args[3]
end

function rest_arguments(expr)
    return expr.args[3:end]
end

function process_addition(expr)
    return metajulia_eval(first_argument(expr)) + metajulia_eval(second_argument(expr))
end

function process_subtraction(expr)
    return metajulia_eval(first_argument(expr)) - metajulia_eval(second_argument(expr))
end

function process_multiplication(expr)
    return metajulia_eval(first_argument(expr)) * metajulia_eval(second_argument(expr)) 
end

function process_division(expr)
    return metajulia_eval(first_argument(expr)) / metajulia_eval(second_argument(expr))
end
