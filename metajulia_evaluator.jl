function metajulia_repl()
    println()
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

# foo(x, y=1) = x + y
# make_primitives(f) = [:primitive, f]

function metajulia_eval(expr, env = initial_bindings())

    println("Evaluating expression: ", expr)
    println("Type of expression: ", typeof(expr))
    #println("Head of expression: ", expr.head)
    #println("Arguments of expression: ", expr.args[1])

    if is_self_evaluating(expr)
        return expr
    elseif is_call(expr)
        return process_call(expr, env)
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

# Slide 163
# Primitives ----------------------------------------------------------------------
function make_primitive(f)
    return [:primitive, f]
end

function is_primitive(obj)
    println(primitives)
    println("Is primitive ?: ", obj)
    return obj[1] == :primitive
end

function initial_bindings()
    primitives = [
    :(+) => make_primitive(+);
    :(-) => make_primitive(-);
    :(*) => make_primitive(*);
    :(/) => make_primitive(/);
    # :(=) => make_primitives(=);
    :(>) => make_primitive(>);
    :(<) => make_primitive(<);
    :(==) => make_primitive(==);
    :(!=) => make_primitive(!=);
    :(>=) => make_primitive(>=);
    :(<=) => make_primitive(<=);
    ]
    return primitives
end

function primitive_operation(obj)
    return obj[2] 
end

function apply_primitive(prim, args)
    apply(primitive_operation(prim), args)
end

# Slide 290 (284 explains why)
# Frames - a frame is basically symbols/ names and its values
function make_frame(names, values)
    return (names, values)
end

# Environment 
function make_environment(frame, old_env) #! check, probably change to augment_environment
    return (frame, old_env)
end

function empty_environment()
    return []
end

function initial_environment()
    make_environment(initial_bindings(), empty_environment())
end

# Process Calls ----------------------------------------------------------------------
function process_call(expr, env)
    # Verify what type the call is, then process it
    func = eval_name(call_operator(expr), env)
    call_operator = expr.args[1] = +
    eval-name = [:primitive, +]   

    # If the call is a primitive operation
    if is_primitive(func)
        println("PRIMITIVE")
        return apply_primitive(primitive_operation(expr), rest_arguments(expr))
    end
    #= if is_addition(expr)
        return process_addition(expr)
    elseif is_subtraction(expr)
        return process_subtraction(expr)
    elseif is_multiplication(expr)
        return process_multiplication(expr)
    elseif is_division(expr)
        return process_division(expr)
    elseif is_greater(expr)
        return process_greater(expr)
    elseif is_less(expr)
        return process_less(expr)
    elseif is_equal(expr)
        return process_equal(expr)
    elseif is_not_equal(expr)
        return process_not_equal(expr)
    elseif is_greater_equal(expr)
        return process_greater_equal(expr)
    elseif is_less_equal(expr)
        return process_less_equal(expr)
    end =#
end

call_operator(expr) = expr.args[1]

function eval_name(name, env)
        
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