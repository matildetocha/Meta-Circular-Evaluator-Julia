# Julia Meta-Circular Evaluator 

include("environment.jl")
include("primitives.jl")

global global_environment = initial_environment()

# -------------------------------------------------------------------------------------------------
# - Eval
# -------------------------------------------------------------------------------------------------

# Evaluating a Line Number Node -------------------------------------------------------------------
is_line_number_node(expr) = isa(expr, LineNumberNode)

# Evaluating an Anonymous Function ---------------------------------------------------------------------------
is_anonymous_function(expr) = expr.head == :(->)

function eval_anonymous_funtion(expr)
    params = expr.args[1]
    body = expr.args[2]
    return Expr(:function, params, body) 
end

# Evaluating a Self-Evaluating Expression ---------------------------------------------------------

# Predicate
function is_self_evaluating(expr)
    # If the expression is a number, string or boolean, then it's self evaluating
    return isa(expr, Number) || isa(expr, String) || isa(expr, Bool)
end  

# Evaluating a Name -------------------------------------------------------------------------------

# Predicate
function is_name(exp)
    return isa(exp, Symbol)
end

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
    println("EXPR: ", exprs)
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

    println("FUNC NAME: ", call_operator(expr))
    println("FUNC: ", func)
    #println("FUNC BODY: ", func)
    println("ARGS: ", args)
    
    if is_primitive(call_operator(expr))
        func(args)
    else
        extended_environment = augment_environment(func.args[1], args, env)
        return metajulia_eval(func.args[2], extended_environment)
    end   
end


# Evaluating a Boolean Operator -------------------------------------------------------------------
#! check this, change it to primitive
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

is_let_function(expr) = expr.args[1].head == :call

# Selectors
function let_names(expr) 
    if is_assignment(expr.args[1]) 
        if isa(expr.args[1].args[1], Symbol)
            return [expr.args[1].args[1]]
        else    
            return [function_name(expr)]
        end
    elseif is_block(expr.args[1])
        println("is block NAMES _-----------------")
        println(map(x -> is_let_function(x) ? [:($(function_parameters(x)) -> $(function_body(x)))] : x.args[2], expr.args[1].args))        
       
        return map(x -> is_let_function(expr) ? function_name(expr) : x.args[1], expr.args[1].args)
    end
end
 
function let_inits(expr)
    print("EXPR INITS: ")
    dump(expr)
    if is_assignment(expr.args[1]) 
        if isa(expr.args[1].args[1], Symbol)
            println("is var assignment")
            return [expr.args[1].args[2]]
        else
            println("is func assignment")
            return [:($(function_parameters(expr)) -> $(function_body(expr)))]
        end
    elseif is_block(expr.args[1])
        println("is block inits -----------------")
        println([[:($(function_parameters(arg)) -> $(function_body(arg)))] for arg in expr.args[1].args if is_assignment(arg)])
        println(map(x -> is_let_function(x) ? [:($(function_parameters(x)) -> $(function_body(x)))] : x.args[2], expr.args[1].args))        
        return map(x -> is_let_function(expr) ? [:($(function_parameters(expr)) -> $(function_body(expr)))] : x.args[2], expr.args[1].args)
    end
end

let_body(expr) = expr.args[2]

function_name(expr) = expr.args[1].args[1].args[1]
function_parameters(expr) = expr.args[1].args[1].args[2:end]
function_body(expr) = expr.args[1].args[2].args[2]

# Eval Let
function eval_let(expr, env)
    println("INITS: ", let_inits(expr))
    println("NAMES: ", let_names(expr))
    
    values = eval_exprs(let_inits(expr), env)
    println("VALUES: ", values)
    extended_environment = augment_environment(let_names(expr), values, env)
    println("ex_env: ", extended_environment)
    return metajulia_eval(let_body(expr), extended_environment)

end

# Evaluating an Assignment ------------------------------------------------------------------------

# Predicate
function is_assignment(expr)
    return expr.head == :(=)
end

# Selectors
assignment_name(expr) = expr.args[1]

assignment_init(expr) = expr.args[2]

# Eval Assignment
function eval_assignment(expr, env)
    value = metajulia_eval(assignment_init(expr), env)
    name = assignment_name(expr)
    global_environment = augment_environment([name], [value], env)
    return value
end


# Meta Julia Eval ---------------------------------------------------------------------------------

function metajulia_eval(expr, env = global_environment)
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
    elseif is_assignment(expr)
        return eval_assignment(expr, env)
    elseif is_anonymous_function(expr)
        return eval_anonymous_funtion(expr)
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

        if (!isa(expr, Expr))
            break
        end

        while expr.head == :incomplete
            line = readline()

            push!(input_lines, line)
            input = join(input_lines, "\n")

            # Evaluate the input
            expr = Meta.parse(input)
        end

        result = metajulia_eval(expr, global_environment)
        #write(stdout, result)
        println(result)
    end
end
