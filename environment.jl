include("primitives.jl")

# Frames -----------------------------------------------------------------------------

# Constructor
function make_frame(names, values)
  return (names, values)
end

# Selectors
frame_variables(frame) = frame[1]

frame_names(frame) = frame[2]


# Environment ------------------------------------------------------------------------
# ((name-0 . value-0) (name-1 . value-1) ... (name-n . value-n))

# Constructor
function empty_environment()
  return []
end

# Operations
function make_environment(frame, env)
  return push!(env, frame)
end

function augment_environment(names, values, env)
  if isempty(names)
    return env
  else
    return augment_environment(names[2:end], values[2:end], make_environment(make_frame(names[1], values[1]), env))
  end
end

function initial_environment()
  return augment_environment(map(names -> names[1], initial_bindings()), map(values -> values[2], initial_bindings()), empty_environment())
end