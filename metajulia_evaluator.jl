# Julia Meta-Circular Evaluator 

include("environment.jl")
include("primitives.jl")

# ------------------------------------------------------------------------------------
# - Eval
# ------------------------------------------------------------------------------------

# Evaluating a Self-Evaluating Expression --------------------------------------------

# Predicate
function is_self_evaluating(expr)
    # If the expression is a number, string or boolean, then it's self evaluating and return true
    return isa(expr, Number) || isa(expr, String) || isa(expr, Bool)
end  

# Evaluating a Name ------------------------------------------------------------------

function eval_name(name, env)
    if isempty(env)
        return error("Unbound name -- EVAL-NAME ", name)
    elseif env[1][1] == name
        return env[1][2]
    else
        return eval_name(name, env[2:end])
    end
end

# Evaluating an Expression -----------------------------------------------------------

function eval_exprs(exprs, env)
    if isempty(exprs)
        return []
    else
        evaluated_expr = metajulia_eval(exprs[1], env)
        remaining_exprs = eval_exprs(exprs[2:end], env)
        return [evaluated_expr, remaining_exprs...]
    end
end

# Evaluating a Call ------------------------------------------------------------------

# Predicate
function is_call(expr)
    return expr.head == :call
end

# Selectors
call_operator(expr) = expr.args[1]
  
call_operands(expr) = expr.args[2:end]

# Eval Call
function eval_call(expr, env)
    # Verify what type the call is, then process it
    func = eval_name(call_operator(expr), env)
    args = eval_exprs(call_operands(expr), env)
        
    # If the call is a primitive operation
    if is_primitive(func)
        return apply_primitive(func, args)
    else
        println("Unknown procedure type -- EVAL-CALL ", procedure);
    end
end

# Evaluating a Boolean Operator ------------------------------------------------------

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
function eval_and(expr)
    return metajulia_eval(first_argument_gate(expr)) && metajulia_eval(second_argument_gate(expr))
end

function eval_or(expr)
    return metajulia_eval(first_argument_gate(expr)) || metajulia_eval(second_argument_gate(expr))
end

# Eval Boolean Operator
function eval_bool_operator(expr)
    if is_and(expr)
        return eval_and(expr)
    end
    if is_or(expr)
        return eval_or(expr)
    end
end

# Evaluating an If -------------------------------------------------------------------
function is_if(expr)
    return expr.head == :if
end

function is_true(value)
    return value == true
end

function is_false(value)
    return value == false
end
  
function if_condition(expr) 
    return expr.args[1]
end

if_consequent(expr) = expr.args[2]

if_alternative(expr) = expr.args[3]

# Evaluating an ElseIf ----------------------------------------------------------------

function is_elseif(expr)
    return expr.head ==:elseif 
end

function eval_if(expr, env)
    if is_true(metajulia_eval(if_condition(expr), env))
        return metajulia_eval(if_consequent(expr), env)
    else
        return metajulia_eval(if_alternative(expr), env)
    end
      
end

# Evaluating a Block -----------------------------------------------------------------
function is_block(expr)
    return expr.head == :block  
end

block_expressions(block) = block.args

function eval_block(block, env)
    return eval_sequence_expr(block_expressions(block), env)
end

function eval_sequence_expr(block_expr, env)
    if isempty(block_expr[2:end])
        return metajulia_eval(block_expr[1], env)
    else
        metajulia_eval(block_expr[1], env)
        return eval_sequence_expr(block_expr[2:end], env)  
    end  
end
    
# Evaluating a Line Number Node ------------------------------------------------------

is_line_number_node(expr) = isa(expr, LineNumberNode)

# Evaluating a Cond ------------------------------------------------------------------




# Meta Julia Eval --------------------------------------------------------------------
function metajulia_eval(expr, env = initial_bindings())
    if is_line_number_node(expr)
        return 
    elseif is_self_evaluating(expr)
        return expr
    elseif is_call(expr)
        return eval_call(expr, env)
    elseif is_bool_operator(expr)
        return eval_bool_operator(expr)
    elseif is_if(expr)
        return eval_if(expr, env)
    elseif is_elseif(expr)
        return eval_if(expr, env)
    elseif is_block(expr)
        return eval_block(expr, env)
    else
        # Error handling, simply return the expression with a message "Unknown expression" and its type
        println("Unknown expression:", expr, " of type ", typeof(expr))
    end
end

# ------------------------------------------------------------------------------------
# - REPL
# ------------------------------------------------------------------------------------
function metajulia_repl()
    while true
        print(">> ")
        
        # Read multiple lines of input until an empty line is encountered
        input_lines = String[]
        while true
            line = readline()

            if line == ""
                break
            end

            if line == "exit"
                return
            end

            push!(input_lines, line)
        end
        
        # Join the input lines into a single string
        input = join(input_lines, "\n")
        
        # Evaluate the input
        expr = Meta.parse(input)
        result = metajulia_eval(expr)
        println(result)
    end
end
