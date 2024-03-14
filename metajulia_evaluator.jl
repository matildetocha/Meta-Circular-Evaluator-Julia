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


function metajulia_eval(expr, env = initial_bindings())

    if is_self_evaluating(expr)
        return expr
    elseif is_call(expr)
        return process_call(expr, env)
    elseif is_gate(expr)
        return process_gate(expr)
    elseif is_cond(expr)
        println("is cond")
        return process_condition(expr, env)
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
    return obj[1] == :primitive
end

function initial_bindings()
    primitives = [
    :(+) => make_primitive(+);
    :(-) => make_primitive(-);
    :(*) => make_primitive(*);
    :(/) => make_primitive(/);
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

apply_primitive(prim, args) = prim(args...)

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
    args = eval_exprs(call_operands(expr), env)
      
    # If the call is a primitive operation
    if is_primitive(func)
        return apply_primitive(primitive_operation(func), args)
    end
end

call_operator(expr) = expr.args[1]

call_operands(expr) = expr.args[2:end]

# Eval functions ---------------------------------------------------------------------

function eval_name(name, env)
    if isempty(env)
        return error("Unbound name -- EVAL-NAME", name)
    elseif env[1][1] == name
        return env[1][2]
    else
        return eval_name(name, env[2:end])
    end
end

function eval_exprs(exprs, env)
    if isempty(exprs)
        return []
    else
        evaluated_expr = metajulia_eval(exprs[1], env)
        remaining_exprs = eval_exprs(exprs[2:end], env)
        return [evaluated_expr, remaining_exprs...]
    end
end

# Process Gates ---------------------------------------------------------------------

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

if_condition(expr) = expr.args[1]

if_consequent(expr) = expr.args[2]

if_alternative(expr) = expr.args[3]

function process_condition(expr, env)   
    if metajulia_eval(if_condition(expr), env)
        return metajulia_eval(if_consequent(expr), env)
    else
        return metajulia_eval(if_alternative(expr), env)
    end
end

# NOT FINISHED YET
# WE NEED TO CHECK BLOCK CASES
