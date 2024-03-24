# Julia Meta-Circular Evaluator 
include("environment.jl")
include("primitives.jl")

struct fexpr

end
Base.show(io::IO, result::fexpr) = print(io, "<fexpr>")

mutable struct MetaJuliaFunction
    params
    body
    namespace
end
Base.show(io::IO, result::MetaJuliaFunction) = print(io, "<function>")

# -------------------------------------------------------------------------------------------------
# - Eval
# -------------------------------------------------------------------------------------------------

# Evaluating a Line Number Node -------------------------------------------------------------------
is_line_number_node(expr) = isa(expr, LineNumberNode)

# Evaluating a Self-Evaluating Expression ---------------------------------------------------------

# Predicate
function is_self_evaluating(expr)
    # If the expression is a number, string or boolean, then it's self evaluating
    return isa(expr, Number) || isa(expr, String) || isa(expr, Bool) || isa(expr, MetaJuliaFunction) 
end  

# Evaluating a Name -------------------------------------------------------------------------------

# Predicate
is_name(exp) = isa(exp, Symbol)

# Eval Name
function eval_name(name, env)
    if isempty(env)
        return error("Unbound name -- EVAL-NAME ", name)
    else
        return env[name]
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
is_call(expr) = expr.head == :call

# Selectors
call_operator(expr) = expr.args[1]
  
call_operands(expr) = expr.args[2:end]

call_function_params(func) = func.args[1...]

call_function_body(func) = func.args[2]

# Eval Call 
function eval_call(expr, env)
    # Verify what type the call is, then process it

    args = eval_exprs(call_operands(expr), env)

    if is_name(expr.args[1]) # is a function
        func = eval_name(call_operator(expr), env) 
    else # is anonymous function
        anonymous_func = :($(anonymous_param(expr)) -> $(anonymous_body(expr)))
        
        extended_environment = augment_environment([:anonymous], [eval_anonymous_funtion(anonymous_func, env)], env)
        func = eval_name(:anonymous, extended_environment)
        if args == [] || isa(args, Symbol)
            args = [args]
        end
    end

    if is_primitive(call_operator(expr))
        return func(args)
    else
        if func.params != :(())
            extended_environment = augment_environment(func.params, args, func.namespace)
        else
            extended_environment = func.namespace
        end

        return metajulia_eval(func.body, extended_environment)
    end   
end

anonymous_param(expr) = isa(expr.args[1].args[1], Symbol) ? [expr.args[1].args[1]] : expr.args[1].args[1].args
anonymous_body(expr) = expr.args[1].args[2].args[2]

# Evaluating a Boolean Operator -------------------------------------------------------------------

# Predicates
is_and(expr) = expr.head == :(&&)

is_or(expr) = expr.head == :(||)

is_bool_operator(expr) = is_and(expr) || is_or(expr)

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
    elseif is_or(expr)
        return eval_or(expr, env)
    end
end

# Evaluating an If-Elseif-Else --------------------------------------------------------------------

# Predicates
is_if(expr) = expr.head == :if

is_elseif(expr) = expr.head == :elseif 

is_true(value) = value == true

is_false(value) = value == false

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
is_block(expr) = expr.head == :block  

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

# Predicates
is_let(expr) = expr.head == :let

is_let_function(expr) = expr.args[1].head == :call

is_variable(expr) = isa(expr.args[1], Symbol)

# Selectors
function_name(expr) = expr.args[1].args[1]

function_parameters(expr) = expr.args[1].args[2:end]

function_body(expr) = expr.args[2].args[2]

var_name(expr) = expr.args[1]

var_init(expr) = expr.args[2]

let_assignment(expr) = expr.args[1]

let_body(expr) = expr.args[2]

function let_names(expr) 
    if is_assignment(expr) 
        if is_variable(expr)
            return [var_name(expr)]
        else    
            return [function_name(expr)]
        end
    elseif is_block(expr)
        return [is_variable(arg) ? var_name(arg) : function_name(arg) for arg in expr.args]
    end
end
 
function let_inits(expr)
    if is_assignment(expr) 
        if is_variable(expr)
            return [var_init(expr)]
        else
            return [:($(function_parameters(expr)) -> $(function_body(expr)))]
        end
    elseif is_block(expr)
        return [is_variable(arg) ? var_init(arg) : :($(function_parameters(arg)) -> $(function_body(arg))) for arg in expr.args]
    end
end

# Eval Let
function eval_let(expr, env)
    let_env = deepcopy(env)
    assignment_expr = let_assignment(expr)
    values = let_inits(assignment_expr)
    names = let_names(assignment_expr)

    extended_environment = augment_environment(names, values, let_env)
    println("Extended Environment: ", extended_environment)
    
    for (value, name) in zip(values, names)
        if isa(value, MetaJuliaFunction) # If it's a function, we need to extend the namespace to have the function itself
            function_namespace = extended_environment[name].namespace 
            extended_environment[name].namespace = augment_environment([name], [value], function_namespace) 
        end
    end
    
    for exp in let_body(expr).args
        if (!is_line_number_node(exp) && !is_self_evaluating(exp) && !isa(exp, Symbol))
            if (is_global(exp))
                eval_global(exp.args[1], env, extended_environment)
            end
        end
    end
    

    result = metajulia_eval(let_body(expr), extended_environment)

    return result
end

# Evaluating an Assignment ------------------------------------------------------------------------

# Predicate
is_assignment(expr) = expr.head == :(=)

# Selectors
assignment_name(expr) =  is_variable(expr) ? var_name(expr) : function_name(expr)

assignment_init(expr) = is_variable(expr) ? var_init(expr) : :($(function_parameters(expr)) -> $(function_body(expr)))

# Eval Assignment
function eval_assignment(expr, env)
    value = metajulia_eval(assignment_init(expr), env)
    name = assignment_name(expr)
    augment_environment([name], [value], env)

    if isa(value, MetaJuliaFunction) # If it's a function, we need to extend the namespace to have the function itself
        function_namespace = env[name].namespace 
        env[name].namespace = augment_environment([name], [value], function_namespace) 
    end

    return value
end

# Evaluating an Anonymous Function ---------------------------------------------------------------------------
is_anonymous_function(expr) = expr.head == :(->)

function eval_anonymous_funtion(expr, env)
    params = expr.args[1]
    body = expr.args[2]
    namespace = deepcopy(env)

    if (isa(params, Symbol))
        params = [params]        
    end

    return MetaJuliaFunction(params, body, namespace)
end

# Global ------------------------------------------------------------------------------------------
is_global(expr) = expr.head == :global

function eval_global(expr, env, extended_environment = initial_environment())
    value = eval_assignment(expr, env)
    name = assignment_name(expr)

    function_namespace = extended_environment
    env[name].namespace = augment_environment([name], [value], function_namespace) 
    return value
end

# Reflection --------------------------------------------------------------------------------------

is_quote(expr) = isa(expr, QuoteNode) || expr.head == :quote
is_unquote(expr) = expr.head == :$
is_quote_node(expr) = isa(expr, QuoteNode)

function eval_quote(expr, env)
    if is_quote_node(expr)
        return expr.value
    elseif is_self_evaluating(expr) || is_name(expr)
        return expr
    else
        if is_unquote(expr)
            return metajulia_eval(expr.args[1], env)
        elseif is_call(expr)
            for i in 2:length(expr.args)
                expr.args[i] = eval_quote(expr.args[i], env)
            end
            return expr
        elseif is_unquote(expr.args[1])
            return metajulia_eval(expr.args[1].args[1], env)
        else
            for i in 2:length(expr.args[1].args)
                expr.args[1].args[i] = eval_quote(expr.args[1].args[i], env)
            end

            return expr.args[1] 
        end
    end
end

# Meta Julia Eval ---------------------------------------------------------------------------------

function metajulia_eval(expr, env = initial_bindings())
    if is_line_number_node(expr)
        return
    elseif is_self_evaluating(expr)
        return expr
    elseif is_name(expr)
        return eval_name(expr, env)
    elseif is_quote(expr)
        return eval_quote(expr,env)
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
    elseif is_assignment(expr)
        return eval_assignment(expr, env)
    elseif is_anonymous_function(expr)
        return eval_anonymous_funtion(expr, env)
    elseif is_global(expr)
        return eval_global(expr.args[1], env)
    else
        # Error handling, simply return the expression with a message "Unknown expression" and its type
        println("Unknown expression: ", expr, " of type ", typeof(expr))
    end
end

# -------------------------------------------------------------------------------------------------
# - REPL
# -------------------------------------------------------------------------------------------------

function metajulia_repl()
    global_environment = initial_environment()
    
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

        if (!isa(expr, Expr))
            result = metajulia_eval(expr, global_environment)
            show(result)
            println("")
            continue
        end

        while expr.head == :incomplete
            line = readline()

            push!(input_lines, line)
            input = join(input_lines, "\n")

            # Evaluate the input
            expr = Meta.parse(input)
        end
                
        result = metajulia_eval(expr, global_environment)
        show(result)
        println("")
    end
end