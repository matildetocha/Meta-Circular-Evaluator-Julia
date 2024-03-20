# Julia Meta-Circular Evaluator 

include("environment.jl")
include("primitives.jl")

# -------------------------------------------------------------------------------------------------
# - Eval
# -------------------------------------------------------------------------------------------------

# Evaluating a Self-Evaluating Expression ---------------------------------------------------------

# Predicate
function is_self_evaluating(expr)
    # If the expression is a number, string or boolean, then it's self evaluating
    return isa(expr, Number) || isa(expr, String) || isa(expr, Bool)
end  

# Evaluating a Name -------------------------------------------------------------------------------

function eval_name(name, env)
    function lookup_in_frame(frame)
        if isempty(frame)
            return eval_name(name, env[2:end])
        elseif name == frame[1]
            return frame[2]
        else
            return eval_name(name, env[2:end])
        end
    end

    if isempty(env)
        return error("Unbound name -- EVAL-NAME ", name)
    else
        frame = env[1]
        lookup_in_frame(frame)
    end
end


# Evaluating an Expression ------------------------------------------------------------------------

function eval_exprs(exprs, env)
    if isempty(exprs)
        return []
    else
        evaluated_expr = metajulia_eval(exprs[1], env)
        remaining_exprs = eval_exprs(exprs[2:end], env)
        return [evaluated_expr, remaining_exprs...]
    end
end

# Evaluating a Call -------------------------------------------------------------------------------

# Predicate
function is_call(expr)
    println("IS call: ", expr)
    return expr.head == :call
end

# Selectors
call_operator(expr) = expr.args[1]
  
call_operands(expr) = expr.args[2:end]

call_function_params(func) = func.args[1...]

call_function_body(func) = func.args[2]

#= Eval Call 

(define (eval-call exp env)
(let ((func (eval-name (call-operator exp) env))
(args (eval-exprs (call-operands exp) env)))
(let ((extended-environment
(augment-environment (function-parameters func)
args
env)))
(eval (function-body func) extended-environment))))

(:x, :(Any[:y]->Any[:(y + 1)]))
(y, 1)

=#
function eval_call(expr, env)
    # Verify what type the call is, then process it
    func = eval_name(call_operator(expr), env)
    args = eval_exprs(call_operands(expr), env)
    println("function_params: ", call_function_params(func))
    
    println("func: ", func)
    println("args: ", args)
    println("function_body: ", call_function_body(func))
    
    # If the call is a primitive operation
    if is_primitive(func)
        return apply_primitive(func, args)
    else
        extended_environment = augment_environment(call_function_params(func), args, env)
        return metajulia_eval(call_function_body(func), extended_environment)
    end
end

# Evaluating a Boolean Operator -------------------------------------------------------------------

# Predicates
function is_bool_operator(expr)
    return is_and(expr) || is_or(expr)
end
  
function is_and(expr)
    return expr.head == :(&&)
end

function is_or(expr)
    return expr.head == :(||)
end

# Selectors
first_argument_gate(expr) = expr.args[1]

second_argument_gate(expr) = expr.args[2]

# Eval Boolean Operator
function eval_and(expr, env)
    return metajulia_eval(first_argument_gate(expr), env) && metajulia_eval(second_argument_gate(expr), env)
end

function eval_or(expr, env)
    return metajulia_eval(first_argument_gate(expr), env) || metajulia_eval(second_argument_gate(expr), env)
end

function eval_bool_operator(expr, env)
    if is_and(expr)
        return eval_and(expr, env)
    end
    if is_or(expr)
        return eval_or(expr, env)
    end
end

# Evaluating an If-Elseif-Else --------------------------------------------------------------------

# Predicates:(x(1))
function is_if(expr)
    return expr.head == :if
end

function is_elseif(expr)
    return expr.head == :elseif 
end

function is_true(value)
    return value == true
end

function is_false(value)
    return value == false
end

# Selectors
if_condition(expr) = expr.args[1]

if_consequent(expr) = expr.args[2]

if_alternative(expr) = expr.args[3]

# Eval If
function eval_if(expr, env)
    if is_true(metajulia_eval(if_condition(expr), env))
        return metajulia_eval(if_consequent(expr), env)
    else
        return metajulia_eval(if_alternative(expr), env)
    end 
end

# Evaluating a Block ------------------------------------------------------------------------------

# Predicate
function is_block(expr)
    return expr.head == :block  
end

# Selector
block_expressions(block) = block.args

# Eval Block
function eval_sequence_expr(block_expr, env)
    if isempty(block_expr[2:end])
        return metajulia_eval(block_expr[1], env)
    else
        metajulia_eval(block_expr[1], env)
        return eval_sequence_expr(block_expr[2:end], env)  
    end  
end

function eval_block(block, env)
    return eval_sequence_expr(block_expressions(block), env)
end

# Evaluating a Let --------------------------------------------------------------------------------

# Predicate
function is_let(expr) 
    return expr.head == :let
end

# Selector
function let_names(expr) 
    if is_block(expr.args[1])
        return map(x -> x.args[1], expr.args[1].args)
    else
        println("let_names: ", expr.args[1].args[1])
        return [expr.args[1].args[1]]
    end
end

function let_inits(expr)
    if is_block(expr.args[1])
        return map(x -> x.args[2], expr.args[1].args)
    else 
        println("let_inits: ", expr.args[1].args[2])
        return [expr.args[1].args[2]]
    end
end

let_body(expr) = expr.args[2]

# Eval Let
function eval_let(expr, env)
    #println(function_name(expr))
    #println(function_arguments(expr))
    #println(function_body(expr))

    if (is_let_function(expr))
        println("Expr before", expr)
        expr_new = reform_function(expr)
        println("Expr after", expr_new)
    end

    values = eval_exprs(let_inits(expr_new), env)
    println("Names: ", let_names(expr_new))
    println("Values: ", values)
    extended_environment = augment_environment(let_names(expr_new), values, env)
    return metajulia_eval(let_body(expr), extended_environment)
end

reform_function(expr) = Expr(:let, Expr(:(=), function_name(expr), Expr(:->, function_arguments(expr), function_body(expr))))
function_name(expr) = expr.args[1].args[1].args[1]
function_arguments(expr) = expr.args[1].args[1].args[2:end]
function_body(expr) = expr.args[1].args[2].args[2:end]

    

#=Expr(:let, Expr(:(=), functionname, Expr(:->, arguments, Expr(:call,))))
function eval_function(expr, env)
    extended_environment = augment_environment(function_names(expr), functions(expr), env)
    return metajulia_eval(function_body(expr), extended_environment) 
end


function functions(expr)
    #println("Dentro de functions, body: ", function_body(expr.args))
    #println("params do functions: ", function_params(expr.args))
    if is_block(expr)
        return map((f -> make_function(function_params(f), function_body(f))), expr.args)
    else
        println("MAKE FUNCTIOn")
        println("params: ", function_params(expr))
        println("body: ", function_body(expr))
        return make_function(function_params(expr), function_body(expr))
    end
end

get_function(expr) = expr.args[1].args[1]

function_params(expr) = expr.args[1].args[1].args[2]

function make_function(parameters, body)
    return [[:function, [parameters, body]]]
end

function function_names(expr)
    if is_block(expr.args[1])
        return map(x -> x.args[1].args[1], expr.args[1].args)
    else
        return [expr.args[1].args[1].args[1]]
    end
    
end

function function_body(expr)
    println("")
    println("body expr - ", expr)
    return expr.args[1].args[2].args[2:end]
end

=#

function is_lambda(expr)
    return expr.head == :(->)
end

function is_let_function(expr)
    return length(expr.args) > 1
end

is_function(expr) = expr[1]== :function

# Evaluating a Line Number Node -------------------------------------------------------------------

is_line_number_node(expr) = isa(expr, LineNumberNode)

# Evaluating a Name -------------------------------------------------------------------------------

function is_name(exp)
    return isa(exp, Symbol)
end

# Meta Julia Eval ---------------------------------------------------------------------------------

function metajulia_eval(expr, env = initial_environment())
    if is_line_number_node(expr)
        return
    elseif is_self_evaluating(expr)
        return expr
    elseif is_name(expr)
        return eval_name(expr, env)
    elseif is_call(expr)
        return eval_call(expr, env)
    elseif is_bool_operator(expr)
        return eval_bool_operator(expr, env)
    elseif is_if(expr)
        return eval_if(expr, env)
    elseif is_elseif(expr)
        return eval_if(expr, env)
    elseif is_block(expr)
        return eval_block(expr, env)
    elseif is_let(expr)
        return eval_let(expr, env)
    elseif is_lambda(expr)
        return expr
    else
        # Error handling, simply return the expression with a message "Unknown expression" and its type
        println("Unknown expression: ", expr, " of type ", typeof(expr))
    end
end

# -------------------------------------------------------------------------------------------------
# - REPL
# -------------------------------------------------------------------------------------------------
function metajulia_repl()
    while true
        print(">> ")
        
        line = readline() 

        # Read multiple lines of input until an empty line is encountered
        input_lines = String[]
        push!(input_lines, line)
        input = join(input_lines, "\n")
        
        # Evaluate the input
        expr = Meta.parse(input)

        if expr == :(exit())
            return
        end

        while expr.head == :incomplete
            line = readline()

            push!(input_lines, line)
            input = join(input_lines, "\n")

            # Evaluate the input
            expr = Meta.parse(input)
        end

        result = metajulia_eval(expr, initial_environment())
        println(result)
    end
end
