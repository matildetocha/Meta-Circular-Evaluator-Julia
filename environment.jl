include("primitives.jl")

# Environment ------------------------------------------------------------------------
# ((name-0 . value-0) (name-1 . value-1) ... (name-n . value-n))

empty_environment() = Dict{Symbol, Any}()

# Constructor
function make_environment(name, value, env)
  env[name] = value

  return env
end

# Operations
function augment_environment(names, values, env)
  if isempty(names)
    return env
  else
    return augment_environment(names[2:end], values[2:end], make_environment(names[1], metajulia_eval(values[1], env), env))
  end
end

function initial_environment()
  return initial_bindings()
end
