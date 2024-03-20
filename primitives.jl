primitives = Dict{Symbol, Any}(
  # Arithmetic Operators
  :(+) => ((args...) -> apply_primitive(make_primitive(+), args...)),
  :(-) => ((args...) -> apply_primitive(make_primitive(-), args...)),
  :(*) => ((args...) -> apply_primitive(make_primitive(*), args...)),
  :(/) => ((args...) -> apply_primitive(make_primitive(/), args...)),
  :(\) => ((args...) -> apply_primitive(make_primitive(\), args...)),
  :(^) => ((args...) -> apply_primitive(make_primitive(^), args...)),
  :(%) => ((args...) -> apply_primitive(make_primitive(%), args...)),  
  # Bitwise Operators
  :(~) => ((args...) -> apply_primitive(make_primitive(~), args...)),
  :(&) => ((args...) -> apply_primitive(make_primitive(&), args...)),
  # :(|) => make_primitive(|),
  # :(xor) => make_primitive(xor),
  # :(nand) => make_primitive(nand),
  # :(nor) => make_primitive(nor),
  # :(>>>) => make_primitive(>>>),
  # :(>>) => make_primitive(>>),
  # :(<<) => make_primitive(<<),
  # # Numeric Comparisons
  # :(==) => make_primitive(==),
  # :(!=) => make_primitive(==),
  :(>) => ((args...) -> apply_primitive(make_primitive(>), args...)),
  :(>=) => ((args...) -> apply_primitive(make_primitive(>=), args...)),
  :(<) => ((args...) -> apply_primitive(make_primitive(<), args...)),
  :(<=) => ((args...) -> apply_primitive(make_primitive(<=), args...)),
  # Print and Println
  # :(print) => make_primitive(print),
  # :(println) => make_primitive(println),
)

# Primitives -------------------------------------------------------------------------
# Predicate
function is_primitive(func)
  println("is_primitive? ")
  println("haskey(primitives, func): ", haskey(primitives, func))
  return haskey(primitives, func)
end

# Selectors
primitive_operation(prim) = prim[2]

primitive_name(prim) = prim[1]

# ------------------------------------------------------------------------------------

function initial_bindings()
  return primitives
end

function apply_primitive(prim, args)
  result = primitive_operation(prim)(args...)

  if isnothing(result)
    result = ""
  end

  return result
end
