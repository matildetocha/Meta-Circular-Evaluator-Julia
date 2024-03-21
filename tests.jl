using Test

include("metajulia_evaluator.jl")

function test_project()
  println("\n-------------------- TESTS --------------------\n")
  test_self_evaluating()
  test_primitives()
  test_conditional()
  test_blocks()
  test_let()
  # test_assignment()    
end

function test_self_evaluating()
  println(">> Evaluating: Self-Evaluating")
  @test metajulia_eval(:(1)) == 1
  @test metajulia_eval(:("Hello, World!")) == "Hello, World!"
end

function test_primitives()
  println(">> Evaluating: Primitive Functions")
  @test metajulia_eval(:(1 + 2)) == 3
  @test metajulia_eval(:((2 + 3) * (4 + 5))) == 45
  @test metajulia_eval(:(3 > 2)) == true
  @test metajulia_eval(:(3 < 2)) == false
  @test metajulia_eval(:(3 > 2 && 3 < 2)) == false
  @test metajulia_eval(:(3 > 2 || 3 < 2)) == true
end

function test_conditional()
  println(">> Evaluating: Conditional Expressions")
  @test metajulia_eval(:(3 > 2 ? 1 : 0)) == 1
  @test metajulia_eval(:(3 < 2 ? 1 : 0)) == 0
  @test metajulia_eval(:( if 3 > 2
                            1
                          else
                            0
                          end)) == 1
  @test metajulia_eval(:( if 3 < 2
                            1
                          elseif 2 > 3
                            2
                          else
                            0
                          end)) == 0
end 

function test_blocks()
  println(">> Evaluating: Block")
  @test metajulia_eval(:((1+2; 2*3; 3/4))) == 0.75
  @test metajulia_eval(:(begin 1+2; 2*3; 3/4 end)) == 0.75
end

function test_let()
  println(">> Evaluating: Let")
  @test metajulia_eval(:(let x = 1; x end)) == 1
  @test metajulia_eval(:(let x = 2; x*3 end)) == 6
  @test metajulia_eval(:(let a = 1, b = 2; let a = 3; a+b end end)) == 5
  @test metajulia_eval(:( let a = 1
                            a + 2
                          end)) == 3
  @test metajulia_eval(:(let x(y) = y+1; x(1) end)) == 2
  @test metajulia_eval(:(let x(y,z) = y+z; x(1,2) end)) == 3
  @test metajulia_eval(:(let x = 1, y(x) = x+1; y(x+1) end)) == 3
end

function test_assignment()
end

@testset "Test Project" begin
  test_project()
end