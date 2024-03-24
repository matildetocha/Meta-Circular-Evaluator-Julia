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
  :(|) => ((args...) -> apply_primitive(make_primitive(|), args...)),
  :(xor) => ((args...) -> apply_primitive(make_primitive(xor), args...)),
  :(nand) => ((args...) -> apply_primitive(make_primitive(nand), args...)),
  :(nor) => ((args...) -> apply_primitive(make_primitive(nor), args...)),
  :(>>>) => ((args...) -> apply_primitive(make_primitive(>>>), args...)),
  :(>>) => ((args...) -> apply_primitive(make_primitive(>>), args...)),
  :(<<) => ((args...) -> apply_primitive(make_primitive(<<), args...)),
  # # Numeric Comparisons
  :(==) => ((args...) -> apply_primitive(make_primitive(==), args...)),
  :(!=) => ((args...) -> apply_primitive(make_primitive(!=), args...)),
  :(!) => ((args...) -> apply_primitive(make_primitive(!), args...)),
  :(>) => ((args...) -> apply_primitive(make_primitive(>), args...)),
  :(>=) => ((args...) -> apply_primitive(make_primitive(>=), args...)),
  :(<) => ((args...) -> apply_primitive(make_primitive(<), args...)),
  :(<=) => ((args...) -> apply_primitive(make_primitive(<=), args...)),
  # Print and Println
  :(print) => ((args...) -> apply_primitive(make_primitive(print), args...)),
  :(println) => ((args...) -> apply_primitive(make_primitive(println), args...))
)

# Primitives -------------------------------------------------------------------------

# Predicate
is_primitive(func) = haskey(primitives, func)

# Constructor
make_primitive(func) = [:primitive, func]

# Selectors
primitive_operation(prim) = prim[2]

primitive_name(prim) = prim[1]

# Basic Operations -------------------------------------------------------------------

function initial_bindings()
  inits = deepcopy(primitives)
  return inits
end

function apply_primitive(prim, args)
  result = primitive_operation(prim)(args...)

  if isnothing(result)
    result = ""
  end

  return result
end
