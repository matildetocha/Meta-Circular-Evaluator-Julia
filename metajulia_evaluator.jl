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
    #println("Head of expression: ", expr.head)
    #println("Arguments of expression: ", expr.args[1])


    if is_self_evaluating(expr)
        return expr
    elseif is_call(expr)
        return process_call(expr)
    elseif is_gate(expr)
        return process_gate(expr)
    elseif is_cond(expr)
        return process_condition(expr)
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

function is_cond(expr)
    return expr.head == :if
end

# Process Calls ----------------------------------------------------------------------
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
    # If the expression is a call to the greater function, evaluate it
    if is_greater(expr)
        return process_greater(expr)
    end
    # If the expression is a call to the less function, evaluate it
    if is_less(expr)
        return process_less(expr)
    end
    # If the expression is a call to the equal function, evaluate it
    if is_equal(expr)
        return process_equal(expr)
    end
    # If the expression is a call to the not_equal function, evaluate it
    if is_not_equal(expr)
        return process_not_equal(expr)
    end
    # If the expression is a call to the greater_equal function, evaluate it
    if is_greater_equal(expr)
        return process_greater_equal(expr)
    end
    # If the expression is a call to the less_equal function, evaluate it
    if is_less_equal(expr)
        return process_less_equal(expr)
    end
    
end

function is_gate(expr)
    return is_and(expr) || is_or(expr)
end

function process_gate(expr)
    if is_and(expr)
        return process_and(expr)
    end
    if is_or(expr)
        return process_or(expr)
    end
    
end

function is_and(expr)
    return expr.head == :(&&)
end

function is_or(expr)
    return expr.head == :(||)
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

function is_greater(expr)
    return expr.args[1] == :>
end

function is_less(expr)
    return expr.args[1] == :<
end

function is_equal(expr)
    return expr.args[1] == :(==)
end

function is_not_equal(expr)
    return expr.args[1] == :(!=)
end

function is_greater_equal(expr)
    return expr.args[1] == :(>=)
end

function is_less_equal(expr)
    return expr.args[1] == :(<=)
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

# Process Operations ------------------------------------------------------------------
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

# Process Comparison Operations ------------------------------------------------------------------
function process_greater(expr)
    return metajulia_eval(first_argument(expr)) > metajulia_eval(second_argument(expr))
end

function process_less(expr)
    return metajulia_eval(first_argument(expr)) < metajulia_eval(second_argument(expr))
end

function process_equal(expr)
    return metajulia_eval(first_argument(expr)) == metajulia_eval(second_argument(expr))
end

function process_not_equal(expr)
    return metajulia_eval(first_argument(expr)) != metajulia_eval(second_argument(expr))
end

function process_greater_equal(expr)
    return metajulia_eval(first_argument(expr)) >= metajulia_eval(second_argument(expr))
end

function process_less_equal(expr)
    return metajulia_eval(first_argument(expr)) <= metajulia_eval(second_argument(expr))
end

# Process Gate Operations ------------------------------------------------------------------
function process_and(expr)
    return metajulia_eval(first_argument_gate(expr)) && metajulia_eval(second_argument_gate(expr))
end

function process_or(expr)
    return metajulia_eval(first_argument_gate(expr)) || metajulia_eval(second_argument_gate(expr))
end

function first_argument_gate(expr)
    return expr.args[1]
end

function second_argument_gate(expr)
    return expr.args[2]
end
# Process Condition ----------------------------------------------------------------------
function process_condition(expr)
     
end