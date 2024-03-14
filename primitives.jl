# Primitives -------------------------------------------------------------------------

# Constructor
function make_primitive(symb)
  return [:primitive, symb]
end

# Predicate
function is_primitive(expr)
  return length(expr) == 2 && expr[1] == :primitive
end

# Selectors
primitive_operation(prim) = prim[2]

primitive_name(prim) = prim[1]

function initial_bindings()
  primitives = [
    # Arithmetic Operators
    :(+) => make_primitive(+);
    :(-) => make_primitive(-);
    :(*) => make_primitive(*);
    :(/) => make_primitive(/);
    :(\) => make_primitive(\);
    :(^) => make_primitive(^);
    :(%) => make_primitive(%);  
    # Bitwise Operators
    :(~) => make_primitive(~);
    :(&) => make_primitive(&);
    :(|) => make_primitive(|);
    :(xor) => make_primitive(xor);
    :(nand) => make_primitive(nand);
    :(nor) => make_primitive(nor);
    :(>>>) => make_primitive(>>>);
    :(>>) => make_primitive(>>);
    :(<<) => make_primitive(<<);
    # Numeric Comparisons
    :(==) => make_primitive(==);
    :(!=) => make_primitive(==);
    :(>) => make_primitive(>);
    :(>=) => make_primitive(>=);
    :(<) => make_primitive(<);
    :(<=) => make_primitive(<=);
  ]
  return primitives
end

function apply_primitive(func, args)
  return primitive_operation(func)(args...)
end
