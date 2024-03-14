include("primitives.jl")

# Frames -----------------------------------------------------------------------------
# Basics

function make_frame(names, values)
  return (names, values)
end

# Operations


# Environment ------------------------------------------------------------------------
# ((name-0 . value-0) (name-1 . value-1) ... (name-n . value-n))

# Basics
function empty_environment()
  return []
end

# Operations
function make_environment(frame, old_env) #! check, probably change to augment_environment
  return (frame, old_env)
end

function initial_environment()
  make_environment(initial_bindings(), empty_environment()) # currently the frame is only values
end